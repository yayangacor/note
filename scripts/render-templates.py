#!/usr/bin/env python3
"""
Render SEMUA template Ansible dengan variabel sungguhan, tanpa menyentuh mesin.

    python scripts/render-templates.py

Kenapa ada. `ansible-playbook --syntax-check` TIDAK merender template; kesalahan
seperti variabel salah ketik atau YAML yang rusak setelah substitusi baru
ketahuan saat playbook benar-benar jalan di node -- yaitu saat paling mahal.
Skrip ini memindahkan penemuan itu ke laptop.

Yang dilakukan:
  1. Baca `group_vars/all/vars.yml` + `vault.yml`, lalu selesaikan variabel yang
     saling merujuk (`registry_host` memakai `cicd_host_ip`, dst).
  2. Bangun `groups` dan `hostvars` dari `inventory/hosts.ini` yang SUNGGUHAN,
     bukan dari daftar tebakan -- kalau inventory berubah, harness ikut berubah.
  3. Render tiap `.j2` dengan StrictUndefined: variabel yang tidak terdefinisi
     jadi ERROR, bukan string kosong yang diam-diam merusak hasil.
  4. Untuk template YAML, parse hasilnya.

PERINGATAN [[B4]] -- ukur alat ukurnya dulu. Jinja2 polos tidak punya filter
milik Ansible (`bool`, `to_json`, `b64encode`, ...). Tanpa tiruan di bawah,
skrip ini melaporkan "RENDER GAGAL" pada template yang sebenarnya sehat, dan
itu klaim negatif yang salah -- persis yang dilarang di CLAUDE.md. Kalau nanti
ada template memakai filter Ansible baru, TAMBAHKAN di sini; jangan simpulkan
templatnya rusak.

Yang TIDAK dibuktikan: bahwa hasil rendernya benar secara semantik. Ia hanya
membuktikan template bisa dirender dan hasilnya YAML yang sah.
"""
import base64
import glob
import io
import json
import re
import sys
from pathlib import Path

try:
    import yaml
    from jinja2 import Environment, StrictUndefined
except ImportError:
    sys.exit("butuh PyYAML + Jinja2:  pip install pyyaml jinja2")

REPO = Path(__file__).resolve().parent.parent
ANSIBLE = REPO / "ansible"


def ansible_filters(env):
    """Tiruan filter Ansible yang dipakai template kita. Lihat peringatan B4."""
    def to_bool(v):
        return str(v).strip().lower() in ("true", "yes", "on", "1")
    env.filters.update({
        "bool": to_bool,
        "to_json": json.dumps,
        "to_nice_json": lambda v, **k: json.dumps(v, indent=4),
        "to_yaml": lambda v, **k: yaml.safe_dump(v),
        "to_nice_yaml": lambda v, **k: yaml.safe_dump(v, default_flow_style=False),
        "b64encode": lambda v: base64.b64encode(str(v).encode()).decode(),
        "b64decode": lambda v: base64.b64decode(str(v)).decode(),
        "regex_replace": lambda v, p, r: re.sub(p, r, str(v)),
    })
    # Test milik Ansible, bukan Jinja2. `contains` dipakai role k8s_join untuk
    # memisahkan control plane dari worker lewat label. Tanpa tiruan ini,
    # harness melapor "No test named 'contains'" pada kode yang sehat.
    env.tests["contains"] = lambda seq, val: val in seq
    return env


def load_inventory(path):
    """Bangun groups + hostvars dari hosts.ini sungguhan."""
    groups, hostvars, children = {}, {}, {}
    current = None
    for line in io.open(path, encoding="utf-8"):
        line = line.split("#", 1)[0].strip()
        if not line:
            continue
        if line.startswith("["):
            name = line.strip("[]")
            if name.endswith(":children"):
                current = ("children", name[: -len(":children")])
                children[current[1]] = []
            elif name.endswith(":vars"):
                current = ("vars", name[: -len(":vars")])
            else:
                current = ("hosts", name)
                groups.setdefault(name, [])
            continue
        if current is None:
            continue
        kind, gname = current
        if kind == "children":
            children[gname].append(line)
        elif kind == "hosts":
            parts = line.split()
            host = parts[0]
            groups[gname].append(host)
            hv = hostvars.setdefault(host, {})
            for kv in parts[1:]:
                if "=" in kv:
                    k, v = kv.split("=", 1)
                    hv[k] = int(v) if v.isdigit() else v
    for parent, kids in children.items():
        merged = []
        for k in kids:
            merged += groups.get(k, [])
        groups[parent] = merged
    return groups, hostvars


def load_vars(env):
    merged = {}
    for f in ("group_vars/all/vars.yml", "group_vars/all/vault.yml"):
        p = ANSIBLE / f
        if p.exists():
            merged.update(yaml.safe_load(io.open(p, encoding="utf-8")) or {})
    # Variabel bisa merujuk variabel lain; selesaikan berulang sampai stabil.
    loose = ansible_filters(Environment())
    for _ in range(8):
        changed = False
        for k, v in list(merged.items()):
            if isinstance(v, str) and "{{" in v:
                try:
                    new = loose.from_string(v).render(**merged).strip()
                    if new != v:
                        merged[k] = new
                        changed = True
                except Exception:
                    pass
        if not changed:
            break
    return merged


def main():
    env = ansible_filters(Environment(undefined=StrictUndefined))
    V = load_vars(env)
    groups, hostvars = load_inventory(ANSIBLE / "inventory/hosts.ini")
    print(f"inventory: {len(hostvars)} host, grup {sorted(groups)}\n")

    first_cp = groups.get("control_plane", ["k8s-cp-01"])[0]
    V.update({
        "groups": groups,
        "hostvars": hostvars,
        "inventory_hostname": first_cp,
        "ansible_user": V.get("node_user", "ubuntu"),
        "ansible_default_ipv4": {
            "address": hostvars.get(first_cp, {}).get("ansible_host", "0.0.0.0"),
            "interface": "eth0",
        },
    })
    V.update(hostvars.get(first_cp, {}))

    templates = sorted(glob.glob(str(ANSIBLE / "roles/*/templates/*.j2")))
    print(f"{len(templates)} template\n")
    bad = 0
    for t in templates:
        label = str(Path(t).relative_to(ANSIBLE / "roles")).replace("\\", "/").replace("/templates/", "  ")
        src = io.open(t, encoding="utf-8").read()
        try:
            out = env.from_string(src).render(**V)
        except Exception as e:
            print(f"  RENDER GAGAL  {label}\n        {type(e).__name__}: {e}")
            bad += 1
            continue
        if t.endswith((".yaml.j2", ".yml.j2")):
            try:
                n = len([d for d in yaml.safe_load_all(out) if d])
                print(f"  ok  {label:42} render + YAML valid ({n} dokumen)")
            except Exception as e:
                print(f"  YAML RUSAK    {label}\n        {e}")
                bad += 1
        else:
            print(f"  ok  {label:42} render OK ({len(out.splitlines())} baris)")

    print(f"\nGAGAL: {bad}")
    if bad:
        print("Sebelum menyimpulkan templatnya rusak: cek dulu apakah ia memakai")
        print("filter Ansible yang belum ditiru di ansible_filters(). Lihat B4.")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
