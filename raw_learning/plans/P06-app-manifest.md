# P06 — Manifest aplikasi: Gateway API, TLS/WSS, HPA, Kyverno

**Status:** 📝 manifest lengkap dan lolos gerbang statis, **belum pernah di-apply** · **Dependency:** P05 · ~~ada tapi cacat~~ → **09-04 diverifikasi**: `kustomize build` merakit 16 dokumen, 0 pelanggaran policy Kyverno, rujukan HPA/Service/HTTPRoute konsisten ([[D-23]]). Ditambah Job migrasi DB ([[D-20]]), exclude `cilium-gateway-*` ([[G-21]]), domain turun ke huruf kecil ([[D-21]]), Secret aplikasi & TLS dibuat role ([[D-18]])

Kode: `Group B/ComMX-Forgejo/k8s/`. Referensi struktur: `ComMX-main/k8s/` (Group A) —
salin polanya, bukan angkanya ([[R-01]]).

## Daftar cacat yang harus diperbaiki (semuanya sudah diukur dari file)

| # | Cacat | Entri |
|---|---|---|
| 1 | `kostumization.yaml` salah nama, dan `resources` menunjuk `backend.yaml`/`frontend.yaml` yang tidak ada | [[G-08]] |
| 2 | `newTag: latest` → akan ditolak Kyverno | [[R-03]] |
| 3 | Backend hanya menerima 2 dari 6 env yang dibutuhkan | [[G-11]] |
| 4 | Password Postgres literal di manifest, Secret masih `${VAR}` yang tidak pernah diekspansi | [[D-11]] |
| 5 | Ingress dengan annotation nginx di cluster Cilium — praktis tidak berefek; case minta Gateway API | [[D-07]] |
| 6 | `host: "://local.com"` — bukan hostname yang valid | — |
| 7 | Dockerfile frontend tidak menerima `--build-arg` → `wss://` tidak pernah masuk bundle | [[G-04]] |
| 8 | `basePath: "/frontend"` di next.config vs route `/` | [[G-06]] |
| 9 | `CMD node dist/main.js` vs kemungkinan output `dist/src/main.js` | [[G-05]] |
| 10 | Job migrasi memanggil drizzle-kit yang tidak ada di image produksi | [[G-14]] |
| 11 | PVC tanpa `storageClassName`, redis tanpa perbaikan izin `/data` | [[G-10]] |
| 12 | Tidak ada HPA, probe, `strategy`, maupun label wajib Kyverno | [[D-12]] [[R-03]] |
| 13 | Namespace manifest `commx-prod` vs ArgoCD Application `commx` | — |

## Urutan pengerjaan

1. **Ukur dulu, baru tulis** — jalankan pengukuran [[G-05]] (`docker build` + `ls -R /app/dist`)
   dan putuskan CMD. Ini satu-satunya cacat yang statusnya masih dugaan.
2. **Struktur ulang folder** mengikuti pola Group A: `config/`, `postgres/`, `redis/`, `backend/`,
   `frontend/`, `gateway/`, `policies/`, `kustomization.yaml`, `namespace.yaml`.
3. **ConfigMap + Secret.** ConfigMap: `NODE_ENV=production`, `PORT=3000`, `REDIS_HOST`, `REDIS_PORT`.
   Secret (tidak di-commit, hanya `secret.example.yaml`): `POSTGRES_*`, `DATABASE_URL`, `JWT_SECRET`,
   `REDIS_URL`, `SOCKET_ORIGIN=https://ComMX.local.com`.
   Kalau redis pakai `--requirepass`, `REDIS_URL` harus `redis://:<pass>@redis:6379`.
4. **Postgres & Redis** sebagai StatefulSet dengan `volumeClaimTemplates` `storageClassName: longhorn`,
   probe `pg_isready`, dan pola izin `/data` untuk redis ([[G-10]]).
5. **Backend & frontend Deployment:** `envFrom` ConfigMap + Secret, probe readiness/liveness,
   resource requests+limits, `imagePullSecrets`, label wajib (`app`, `owner`,
   `app.kubernetes.io/name`, `app.kubernetes.io/component`, `app.kubernetes.io/part-of`),
   `strategy: RollingUpdate` `maxSurge:1` `maxUnavailable:0` ([[D-12]]).
   Tambahkan `topologySpreadConstraints` berdasarkan `kubernetes.io/hostname` — case meminta
   "resource seimbang antar node", dan itu tidak terjadi sendiri.
6. **TLS.** Buat sertifikat untuk `ComMX.local.com` (self-signed cukup; case tidak menuntut CA
   publik) dan simpan sebagai Secret `kubernetes.io/tls`:
   ```bash
   openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
     -keyout tls.key -out tls.crt \
     -subj "/CN=ComMX.local.com" -addext "subjectAltName=DNS:ComMX.local.com"
   kubectl create secret tls commx-tls-cert --cert=tls.crt --key=tls.key -n <ns>
   ```
   `subjectAltName` wajib — browser modern mengabaikan CN.
7. **Gateway + HTTPRoute** ([[D-07]]): listener HTTP:80 + HTTPS:443 `mode: Terminate`;
   route `/api` (rewrite ke `/`), `/socket.io`, `/`. Selesaikan [[G-06]] lebih dulu supaya
   route `/` benar-benar melayani halaman.
8. **HPA** backend & frontend (min 2, max 5, CPU 70%). Prasyarat: metrics-server terpasang dan
   `kubectl top nodes` sudah memberi angka — kalau belum, HPA hanya akan menampilkan `<unknown>`.
9. **Kyverno** paling akhir ([[D-09]]): tiga ClusterPolicy + exclude namespace sistem.
10. **NetworkPolicy**: hanya backend yang boleh ke Postgres (5432) dan Redis (6379).

## Definition of Done

- [ ] `kubectl kustomize k8s/` merender tanpa error (uji **sebelum** apply).
- [ ] Semua pod `Running`+`Ready`; `kubectl get endpoints` berisi IP pod untuk tiap Service.
- [ ] `kubectl get gateway` punya `ADDRESS` dari pool MetalLB, `HTTPRoute` `Accepted=True`.
- [ ] **Dari PC lain:** `curl -k https://ComMX.local.com/` mengembalikan HTML aplikasi.
- [ ] **WSS terbukti:** DevTools → Network → WS menunjukkan `wss://ComMX.local.com/socket.io/...`
      dengan status `101`. Bukan sekadar "halaman terbuka".
- [ ] **Dua browser, satu lobby:** pesan sampai real-time. Ini yang membuktikan Redis adapter
      benar-benar dipakai.
- [ ] `kubectl get hpa` menampilkan target CPU dengan angka, bukan `<unknown>`.
- [ ] **Kontrol negatif Kyverno:**
      `kubectl run bad --image=nginx:latest -n commx-prod` → **ditolak**;
      `kubectl run bad2 --image=nginx:1.27 -n default` → **ditolak**;
      pod dengan tag versi + label lengkap di namespace yang benar → **diterima**.
      Ketiganya harus dijalankan; policy yang tidak pernah menolak apa pun tidak membuktikan apa pun.
- [ ] `git grep -n "password\|PASSWORD"` di `k8s/` tidak menemukan nilai asli.

## Hasil eksekusi

_(kosong)_
