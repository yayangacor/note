# CLAUDE.md — aturan operasi (lapis 2, auto-load)

Batas keras: **250 baris.** Kalau lewat, pindahkan narasinya ke `NOTES.md`.
File ini berisi aturan yang berlaku selamanya + tabel progress. **Bukan** buku harian sesi —
keadaan hari ini ada di `HANDOFF.md`.

## Project

Deployment case TPA Network 26-1 — aplikasi chat **ComMX** (React/Next + NestJS + Redis adapter)
di atas Kubernetes HA, di 3 PC Proxmox. Requirement asli: `case.md` (lapis 0, **jangan diedit**).
Peran, DoD, dan konstanta: `INSTRUCTION.md`.

Bagian jaringan MikroTik (internet, DNS, DHCP, wireless, firewall, VPN, queues) dikerjakan
anggota lain — di luar scope, tapi tetap ada barisnya di `TRACE.md`.

## Protokol pembukaan sesi

1. Baca file ini + `HANDOFF.md`.
2. Buka `DOC-MAP.md`, **sebutkan** dokumen mana yang akan dibaca hari ini sebelum membacanya.
3. Baca unit kerja aktif + dependency-nya saja. Jangan membaca semua plan.
4. Sebelum eksekusi, laporkan ≤10 baris: target sesi, dependency yang belum DONE, ID ledger yang
   relevan (terutama G-xx yang membatasi), dan asumsi yang belum terverifikasi.

## Disiplin bukti — tidak bisa ditawar

**B1. Config tersimpan ≠ fitur jalan.** Bukti sah = klien benar-benar menerima hasil.
**B2. Perintah diterima ≠ perintah tersimpan.** Baca ulang nilainya dari sumber otoritatif;
ketiadaan error bukan bukti.
**B3. Tes tanpa kontrol negatif bukan bukti.** Sediakan kasus yang **seharusnya gagal** dan
pastikan ia memang gagal (contoh: Kyverno harus **menolak** manifest bertag `latest`).
**B4. Ukur alat ukurnya dulu.** Sebelum menyimpulkan "fitur X tidak ada", jalankan alat ukur yang
sama pada kasus yang sudah terbukti bekerja.

Turunan yang berlaku khusus di project ini: **agent tidak memegang mesin.** Setiap langkah wajib
disertai perintah verifikasi yang bisa di-copy-paste user + bentuk output yang dianggap lulus.
Tanpa itu, langkah tersebut belum selesai ditulis.

## Aturan kerja

- **Klaim negatif butuh bukti.** Dilarang menulis "fitur/perintah ini tidak ada" tanpa menyebut apa
  saja yang sudah dicoba. Klaim negatif yang salah diwarisi sesi berikutnya sebagai kebenaran.
- **Supersession in-place.** Saat sebuah nilai berubah, stempel di tempat nilai lamanya berada:
  `~~lama~~ → **baru** (diganti [[D-xx]], tanggal)`, bukan hanya di entri barunya.
- **Gerbang stateless/stateful.** Sebelum menulis ke dokumen: "besok masih dibutuhkan DAN tidak
  bisa ditebak ulang tanpa dokumen ini?" Kalau tidak dua-duanya, jangan ditulis. Penjelasan teori
  tidak pernah ditulis.
- **[[R-01]] Salin polanya, jangan salin angkanya.** Artefak Group A berasal dari 3 lingkungan
  berbeda dengan 2 nomor grup berbeda. Setiap file yang disalin dicek: IP, nomor grup, user Linux,
  nama node, host registry, repoURL, StorageClass.
- **[[R-02]]** `apply` sukses / `rc 0` bukan bukti. Lihat B1.
- **[[R-03]]** Sesudah Kyverno aktif, cek tag & label sebelum apply — penolakannya muncul sebagai
  "sync failed" di ArgoCD dan gampang disalahartikan sebagai masalah jaringan.

## Presedensi saat dokumen berselisih

```
case.md  >  NOTES.md (entri terbaru)  >  INSTRUCTION.md  >  plans/PXX  >  HANDOFF.md
```

Pengecualian: kalau `case.md` mustahil dieksekusi, yang menang adalah entri `D-xx` yang membuat
requirement itu **bisa didemokan** — dan alasannya wajib ditulis supaya deviasinya bisa dibela.

## Konvensi ID

`D-xx` keputusan · `G-xx` gotcha terukur · `R-xx` aturan hasil kesalahan · `Q-xx` pertanyaan terbuka
· `PXX` unit kerja. Semua hidup di `NOTES.md` kecuali plan. Rujuk dengan `[[ID]]`, jangan menyalin isinya.

## Tabel progress

| Plan | Isi | Status | Dependency |
|---|---|---|---|
| P00 | Host VMware Workstation → Proxmox nested (3 PC lab) | ❌ belum mulai | — |
| P01 | Proxmox: cluster datacenter, template cloud-init, backup, HA/migrasi | ❌ belum mulai (kerja manual di GUI) | P00 |
| P02 | Terraform: provisioning 6 VM + IP statis + inventory | 📝 kode SELESAI, belum di-apply | P01 |
| P03 | Ansible core_system: containerd, kernel, kubeadm, trust registry | 📝 kode SELESAI, belum dijalankan | P02 |
| P04 | HAProxy + keepalived, lalu kubeadm init HA + join | 📝 kode SELESAI, belum dijalankan | P03 |
| P05 | Cilium → MetalLB → Longhorn | 📝 kode SELESAI, belum dijalankan | P04 |
| P06 | Manifest aplikasi: Gateway API, TLS/WSS, HPA, Kyverno | 📝 kode SELESAI, belum di-apply | P05 |
| P07 | Forgejo + registry + runner + ArgoCD + pipeline | 📝 kode SELESAI, belum dijalankan | P05 |
| P08 | Prometheus + Grafana + Alertmanager email | 📝 kode SELESAI, belum dijalankan | P05 |
| P09 | Dokumentasi (ditulis sambil jalan, bukan di akhir) | ❌ belum mulai | semua |

**Arti `📝`: kode sudah ditulis dan lolos cek sintaks YAML, TAPI NOL PERINTAH
PERNAH DIJALANKAN.** Itu bukan setengah selesai — itu belum diuji sama sekali.
Naikkan status hanya dengan bukti mentah dari mesin, sesuai B1.

Detail tiap plan ada di `plans/`. Status requirement per baris ada di `TRACE.md` — itu yang
dipakai untuk audit, bukan tabel ini.

## Dua gerbang yang wajib hijau sebelum apply / push

Keduanya jalan di laptop, tanpa cluster, dan **masing-masing menguji dirinya sendiri lebih dulu**
dengan kasus yang seharusnya gagal — pemeriksa yang tidak pernah gagal tidak membuktikan apa pun (B3).

```
cd "Group B/ComMX-Forgejo"
python scripts/validate-manifests.py    # kustomize + policy Kyverno + rujukan HPA/Service/HTTPRoute
python scripts/render-templates.py      # render SEMUA .j2 dengan vars+vault sungguhan
```

Keduanya `exit 0` = lulus. Yang mereka buktikan cuma **bentuk**, bukan perilaku — status di
`TRACE.md` tetap `📝` sesudah keduanya hijau.

**Kalau `render-templates.py` melapor gagal, jangan langsung menyalahkan templatnya.** Jinja2 polos
tidak punya filter/test milik Ansible (`bool`, `to_json`, `contains`, …). Cek dulu `ansible_filters()`
di skrip itu — dua kali pada 2026-09-04 laporan "gagal" ternyata harness-nya yang kurang, bukan
kodenya. Lihat B4 dan [[D-24]].

## Di mana angka jaringan hidup

Satu nilai, satu rumah. Jangan menyebar IP ke banyak file.

| Lapisan | File | Isi |
|---|---|---|
| Terraform | `terraform-commx/variables.tf` | IP statis VM, gateway, DNS, spec |
| Ansible | `ansible/group_vars/all/vars.yml` | VIP, port LB, pool MetalLB, host registry, versi |
| Kubernetes | `k8s/kustomization.yaml` | host registry + tag image |
| Inventory | di-generate Terraform → `ansible/inventory/hosts.ini` | jangan diedit manual |

Semua placeholder ditandai `TODO(Q-02)`. Cari dengan:
`grep -rn "TODO(Q-02)" "Group B/ComMX-Forgejo"`

## Jebakan yang paling sering mengenai sesi baru

Keempat cacatnya **sudah diperbaiki di kode** (2026-09-03), tapi perbaikannya belum pernah
dijalankan. Yang tersisa adalah kewajiban untuk tidak mengembalikannya:

- [[G-12]] `--control-plane-endpoint <VIP>:8443 --upload-certs` sekarang ada, dan init dijaga
  supaya hanya jalan di `control_plane[0]`. **Jangan jalankan `--tags init` sebelum `--tags lb`
  terbukti hidup** — VIP tertanam di sertifikat dan tidak bisa diubah tanpa reset.
- [[G-01]] HAProxy di `8443`, bukan `6443`. Nilainya di `group_vars/all/vars.yml`.
- [[G-04]] `NEXT_PUBLIC_*` masuk lewat `--build-arg` di CI. Dockerfile sekarang **gagal** kalau
  build-arg lupa dikirim — itu disengaja.
- [[G-11]] Backend memakai `envFrom` ConfigMap + Secret; keenam env terpenuhi.

Ditambah 2026-09-04, dari repo upstream Group A yang hidup (`refs/UPSTREAM-EVIDENCE.md`):

- [[G-20]] Cilium Gateway API butuh CRD channel **experimental** (`TLSRoute`). `standard-install`
  saja membuat GatewayClass macet `ACCEPTED: Unknown` dan Gateway tak pernah dapat ADDRESS.
- [[G-21]] Kyverno `require-labels` menolak Service `cilium-gateway-*` yang di-generate Cilium.
  Exclude berbasis **nama**, jangan menurunkan jumlah label wajib.
- [[G-22]] CORS peka huruf. Domain kini **huruf kecil semua** ([[D-21]]) — itu deviasi ejaan dari
  `case.md` yang disengaja. Jangan "diperbaiki" balik ke `ComMX.local.com`.
- [[G-25]] Runner memetakan `ubuntu-latest` ke container `node:*` **tanpa Docker CLI**. Job yang
  memanggil `docker run` wajib punya step `Siapkan Docker CLI` lebih dulu.

## Repo & folder

```
case.md                 lapis 0, requirement asli — JANGAN DIEDIT
INSTRUCTION.md          charter: peran, DoD, konstanta
CLAUDE.md               file ini
DOC-MAP.md              router topik → dokumen
NOTES.md                ledger D/G/R/Q + indeks gejala
TRACE.md                satu baris per requirement + bukti
plans/PXX-*.md          unit kerja
refs/GROUPA-CODE-MAP.md peta artefak Group A (supaya tidak unzip ulang)
HANDOFF.md              keadaan hari ini — ditulis ulang tiap akhir sesi
Group A/                zip referensi (read-only)
Group B/                kode kita: ComMX-Forgejo (aktif) + help (basis lama)
AGENT-CONTEXT-KIT/      framework LRC yang dipakai di sini
```

`Group B/ComMX-Forgejo` = repo kerja kita. `Group B/help` = basis lama yang identik dengan salinan
di dalam zip Group A; jangan bingung menganggapnya kemajuan siapa pun.

## Protokol penutupan sesi (wajib)

1. Update status plan yang tersentuh + tabel progress di atas. Centang DoD hanya yang benar-benar diuji.
2. Append entri ledger baru + perbarui **indeks gejala** di `NOTES.md`.
3. Perbarui baris `TRACE.md` untuk requirement yang tersentuh — status, di mana, bukti mentah, tanggal.
4. **Tulis ulang `HANDOFF.md` dari nol**, termasuk bagian koreksi ledger (di mana kesimpulan agent
   keliru hari ini dan apa yang membongkarnya).
5. Cek anggaran: file ini masih ≤250 baris?
