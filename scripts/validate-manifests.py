#!/usr/bin/env python3
"""
Gerbang statis untuk manifest k8s. Jalankan SEBELUM apply / sebelum push.

    python scripts/validate-manifests.py              # merakit sendiri (butuh kubectl)
    python scripts/validate-manifests.py build.yaml   # baca manifest yang sudah dirakit
    kustomize build k8s/ | python scripts/validate-manifests.py -

Yang diperiksa, semuanya kelas kesalahan yang pernah benar-benar terjadi:

  1. `kubectl kustomize k8s/` benar-benar merakit            -> [[G-08]]
  2. Tiga policy Kyverno, disimulasikan di sini supaya penolakannya ketahuan
     SEKARANG, bukan nanti sebagai "sync failed" di ArgoCD    -> [[R-03]]
       - disallow-latest-tag
       - disallow-default-namespace
       - require-labels (app, owner, app.kubernetes.io/name)
  3. HPA menunjuk workload yang benar-benar ada               -> [[K-7]]
  4. Service selector benar-benar memilih pod, dan targetPort ada
  5. HTTPRoute backendRef menunjuk Service + port yang ada
  6. Container punya resources.requests -- tanpa itu HPA tidak pernah scale
     walau metrics-server sudah hidup                          -> [[D-19]]

KENAPA ADA KONTROL NEGATIF DI DALAM SKRIP INI (B3). Pemeriksa yang tidak pernah
gagal tidak membuktikan apa pun. Sebelum memeriksa manifest sungguhan, skrip ini
memeriksa manifest rusak buatan dan MEMASTIKAN ia tertangkap. Kalau kontrol
negatifnya lolos, skrip berhenti dan bilang hasilnya tidak bernilai.

Yang TIDAK dibuktikan skrip ini: bahwa apa pun berjalan. Ia memeriksa bentuk,
bukan perilaku. Status di TRACE.md tetap `📝` sesudah ini hijau.
"""
import subprocess
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    sys.exit("butuh PyYAML:  pip install pyyaml")

REQUIRED_LABELS = ["app", "owner", "app.kubernetes.io/name"]
LABELED_KINDS = {"Pod", "Deployment", "StatefulSet", "Service", "Job"}
REPO = Path(__file__).resolve().parent.parent

# Manifest yang SEHARUSNYA ditolak. Dipakai untuk menguji pemeriksanya sendiri.
NEGATIVE_CONTROL = """
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sengaja-rusak
  namespace: default
  labels:
    app: commx
spec:
  template:
    metadata:
      labels:
        app: commx
    spec:
      containers:
        - name: pakai-latest
          image: nginx:latest
        - name: tanpa-tag
          image: registry.local/commx-backend
          resources: {}
"""


def check(docs):
    """Kembalikan daftar pelanggaran. Kosong = lolos."""
    bad = []
    names = {d["kind"]: {} for d in docs}
    for d in docs:
        names.setdefault(d["kind"], {})[d["metadata"]["name"]] = d
    workloads = {**names.get("Deployment", {}), **names.get("StatefulSet", {})}
    services = names.get("Service", {})

    for d in docs:
        kind = d["kind"]
        meta = d.get("metadata", {})
        name = meta.get("name")
        where = f"{kind}/{name}"
        ns = meta.get("namespace")

        if ns == "default":
            bad.append(f"{where}: namespace `default` -- ditolak disallow-default-namespace")
        elif kind != "Namespace" and not ns:
            bad.append(f"{where}: namespace kosong")

        if kind in LABELED_KINDS:
            missing = [l for l in REQUIRED_LABELS if l not in (meta.get("labels") or {})]
            if missing:
                bad.append(f"{where}: label wajib hilang {missing} -- ditolak require-labels")

        spec = d.get("spec") or {}
        tpl = spec.get("template")
        if isinstance(tpl, dict):
            tpl_labels = (tpl.get("metadata") or {}).get("labels") or {}
            missing = [l for l in REQUIRED_LABELS if l not in tpl_labels]
            if missing:
                # Pod hasil Deployment ikut lewat admission, jadi label template
                # sama wajibnya dengan label resource induknya.
                bad.append(f"{where}: podTemplate label wajib hilang {missing}")

            containers = (tpl.get("spec") or {}).get("containers") or []
            for c in containers:
                img = c.get("image", "")
                tag_part = img.rsplit("/", 1)[-1]
                if img.endswith(":latest") or ":" not in tag_part:
                    bad.append(f"{where}/{c['name']}: image `{img}` tanpa tag tetap -- ditolak disallow-latest-tag")
                if not (c.get("resources") or {}).get("requests"):
                    bad.append(f"{where}/{c['name']}: tanpa resources.requests -- HPA tidak akan pernah scale")

            selector_owner = tpl_labels
            for svc_name, svc in services.items():
                sel = svc["spec"].get("selector") or {}
                if sel and all(selector_owner.get(k) == v for k, v in sel.items()):
                    declared = {p["containerPort"] for c in containers for p in (c.get("ports") or [])}
                    named = {p["name"] for c in containers for p in (c.get("ports") or []) if p.get("name")}
                    for p in svc["spec"]["ports"]:
                        tp = p.get("targetPort", p["port"])
                        if isinstance(tp, int) and declared and tp not in declared:
                            bad.append(f"Service/{svc_name}: targetPort {tp} tidak ada di containerPort {sorted(declared)}")
                        if isinstance(tp, str) and named and tp not in named:
                            bad.append(f"Service/{svc_name}: targetPort '{tp}' bukan nama port mana pun {sorted(named)}")

        if kind == "HorizontalPodAutoscaler":
            target = spec["scaleTargetRef"]["name"]
            if target not in workloads:
                bad.append(f"{where}: scaleTargetRef `{target}` tidak ada di manifest")

        if kind == "HTTPRoute":
            for rule in spec.get("rules", []):
                for ref in rule.get("backendRefs", []):
                    svc = services.get(ref["name"])
                    if svc is None:
                        bad.append(f"{where}: backendRef Service `{ref['name']}` tidak ada")
                    elif ref.get("port") not in [p["port"] for p in svc["spec"]["ports"]]:
                        bad.append(f"{where}: backendRef {ref['name']}:{ref.get('port')} bukan port Service itu")

    for svc_name, svc in services.items():
        sel = svc["spec"].get("selector") or {}
        matched = any(
            sel and all((((w.get("spec") or {}).get("template") or {}).get("metadata") or {}).get("labels", {}).get(k) == v
                        for k, v in sel.items())
            for w in workloads.values()
        )
        if sel and not matched:
            bad.append(f"Service/{svc_name}: selector {sel} tidak memilih pod mana pun -- Service tanpa endpoint")

    return bad


def main():
    # --- B3: buktikan dulu pemeriksanya bisa gagal -------------------------
    control = check([d for d in yaml.safe_load_all(NEGATIVE_CONTROL) if d])
    if len(control) < 6:
        print("GAGAL KONTROL NEGATIF: pemeriksa hanya menangkap", len(control), "dari >=6 pelanggaran.")
        print("Hasil 'lolos' dari skrip ini TIDAK BERNILAI sampai ini diperbaiki.")
        for c in control:
            print("   tertangkap:", c)
        return 2
    print(f"kontrol negatif OK -- pemeriksa menangkap {len(control)} pelanggaran buatan\n")

    # --- ambil manifest sungguhan ------------------------------------------
    # Dua mode. Tanpa argumen ia merakit sendiri lewat `kubectl kustomize` --
    # praktis di laptop. Dengan argumen ia membaca manifest yang SUDAH dirakit,
    # supaya di CI perakit dan pemeriksa bisa jadi dua container terpisah dan
    # tidak ada satu pun tool yang perlu terpasang di runner ([[G-23]]).
    arg = sys.argv[1] if len(sys.argv) > 1 else None
    if arg == "-":
        out = sys.stdin.read()
        print("membaca manifest terakit dari stdin\n")
    elif arg:
        out = Path(arg).read_text(encoding="utf-8")
        print(f"membaca manifest terakit dari {arg}\n")
    else:
        try:
            out = subprocess.run(
                ["kubectl", "kustomize", str(REPO / "k8s")],
                capture_output=True, text=True, check=True,
            ).stdout
        except FileNotFoundError:
            print("kubectl tidak ada di PATH.")
            print("Rakit di tempat lain lalu berikan hasilnya:")
            print("   kustomize build k8s/ > build.yaml && python scripts/validate-manifests.py build.yaml")
            return 2
        except subprocess.CalledProcessError as e:
            print("kustomize GAGAL merakit -- ini G-08, periksa nama file & daftar resources:")
            print(e.stderr)
            return 1

    docs = [d for d in yaml.safe_load_all(out) if d]
    print(f"{len(docs)} dokumen terakit dari k8s/")
    for d in docs:
        print(f"   {d['kind']:24} {d['metadata']['name']}")
    print()

    problems = check(docs)
    if problems:
        print(f"{len(problems)} MASALAH:")
        for p in problems:
            print("   -", p)
        return 1

    print("LOLOS: policy Kyverno, rujukan HPA/Service/HTTPRoute, dan resources.requests semuanya konsisten.")
    # Tanpa emoji: konsol Windows default cp1252 dan melempar UnicodeEncodeError.
    print("Ini pemeriksaan BENTUK, bukan bukti bahwa sesuatu berjalan.")
    print("Status di TRACE.md tetap 'kode ditulis, belum dijalankan'.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
