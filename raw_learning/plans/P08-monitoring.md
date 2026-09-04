# P08 — Prometheus + Grafana + Alertmanager (email)

**Status:** 📝 kode role selesai, belum dijalankan · **Dependency:** P05 (MetalLB + Longhorn) · ~~**Blokir:** Gmail App Password~~ → **tidak lagi memblokir**: App Password dan 7 alamat anggota lengkap di vault, dan `values.yaml.j2` **dirender sungguhan** 09-04 — SMTP, TLS, dan ketujuh penerima terbukti keluar benar ([[D-24]]). Yang tersisa murni eksekusi + bukti email benar-benar sampai

Referensi lengkap ada di `K2Help/roles/monitoring/` — values dan alert rules-nya bisa dipakai
hampir apa adanya, kecuali kredensial dan email.

## Instalasi

`kube-prometheus-stack` (chart `prometheus-community`) ke namespace `monitoring`.

Values yang penting:

- `grafana.adminUser: tormonitor`, `adminPassword` dari vault (case: `monitor`).
- `grafana.service.type: LoadBalancer` dan `prometheus.service.type: LoadBalancer` → IP dari
  MetalLB. **IP Grafana inilah yang diberikan ke anggota jaringan** untuk record DNS
  `Grafana.local.com`. Catat di dokumentasi.
- `grafana.grafana.ini.server.root_url: https://Grafana.local.com` — kalau tidak, link di email
  alert menunjuk IP internal.
- Persistensi Grafana/Prometheus/Alertmanager ke `storageClassName: longhorn`.
- `serviceMonitorSelectorNilUsesHelmValues: false` dan `ruleSelectorNilUsesHelmValues: false` —
  tanpa dua ini, PrometheusRule buatan sendiri **diabaikan diam-diam**. Gejalanya: rule terlihat
  ada di `kubectl get prometheusrule`, tapi tidak pernah muncul di UI Prometheus.
- `defaultRules.rules.kubeProxy: false` — kube-proxy tidak ada karena digantikan Cilium ([[D-04]]);
  kalau tidak dimatikan, akan ada alert palsu yang menyala terus.
- Retensi 7 hari cukup; jangan lebih, disk terbatas.

## Alert yang wajib ada (case)

| Alert | Ekspresi (inti) | for |
|---|---|---|
| CPU node ≥90% | `100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 90` | 5m |
| RAM node ≥90% | `(1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100 > 90` | 5m |
| Pod error | `kube_pod_status_phase{phase=~"Failed\|Unknown"} > 0` | 2m |
| Pod crashloop | `kube_pod_container_status_waiting_reason{reason=~"CrashLoopBackOff\|ImagePullBackOff\|ErrImagePull"} > 0` | 5m |

Tambahkan `NodeNotReady` — murah dan sangat membantu saat demo failover.

## Email

Alertmanager `smtp_smarthost: smtp.gmail.com:587`, `smtp_require_tls: true`.
Pengirim dan penerima: `yayan.gacor07@gmail.com` (tambahkan email anggota lain ke `team_emails`).

`smtp_password` **wajib Gmail App Password 16 karakter**, bukan password akun Google — login biasa
ditolak sejak Google mematikan "less secure apps". Aktifkan 2FA dulu, lalu buat di
Google Account → Security → 2-Step Verification → App passwords. Simpan di `vault.yml`
terenkripsi, jangan di `vars.yml`.

Kegagalan SMTP bersifat **diam**: alert tetap `Firing` di UI Prometheus, log Alertmanager
menyebut auth error, dan email tidak pernah sampai. Karena itu DoD di bawah menuntut inbox,
bukan tampilan UI.

Rute `Watchdog` ke receiver kosong ("blackhole") — kalau tidak, inbox dibanjiri alert heartbeat
tiap beberapa menit dan alert asli tenggelam.

## Definition of Done

- [ ] `kubectl -n monitoring get svc` → Grafana & Prometheus punya EXTERNAL-IP. Catat kedua IP.
- [ ] Login Grafana dengan `tormonitor` berhasil **dari PC lain**.
- [ ] Dashboard bawaan menampilkan CPU & RAM **per node** dengan angka (bukan "No data") —
      ini membuktikan node-exporter terjangkau, bukan sekadar terpasang.
- [ ] Dashboard pod menampilkan status pod namespace aplikasi.
- [ ] `kubectl -n monitoring get prometheusrule` memuat rule kita **dan** rule itu terlihat di
      Prometheus UI → Alerts. Dua-duanya, karena yang pertama saja bisa menipu.
- [ ] **Alert email benar-benar sampai.** Cara mengujinya tanpa membebani cluster: turunkan
      sementara ambang jadi `> 1` di satu rule, tunggu alert `Firing`, pastikan email masuk,
      lalu kembalikan ke 90 dan pastikan alert `Resolved` juga terkirim.
      "Alert muncul di UI" bukan bukti email jalan — SMTP gagal secara diam-diam.
- [ ] Screenshot/log dari inbox salah satu anggota ditempel ke plan ini.

## Hasil eksekusi

_(kosong)_
