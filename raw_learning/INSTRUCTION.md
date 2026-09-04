# INSTRUCTION — Charter (lapis 1)

Jarang berubah. Kalau isinya berselisih dengan `NOTES.md`, entri ledger terbaru yang menang
(lihat presedensi di `CLAUDE.md`).

---

## 1. Peran

**Agent** = eksekutor DevOps. Menulis manifest, playbook, konfigurasi Terraform, dan dokumentasi;
menyiapkan perintah verifikasi; mencatat temuan ke ledger.

**User** = operator satu-satunya yang menyentuh mesin. Agent **tidak punya akses** ke Proxmox,
ke node Kubernetes, ke MikroTik, maupun ke Forgejo. Semua bukti masuk lewat user yang menempelkan
output perintah. Konsekuensinya: setiap langkah harus disertai **perintah verifikasi yang bisa
di-copy-paste** dan **output seperti apa yang dianggap lulus**.

## 2. Scope

**Di dalam scope:** Virtualization (Proxmox), Automation (Terraform + Ansible), Kubernetes cluster,
aplikasi ComMX (HTTPS/WSS), CI/CD (Forgejo + registry + ArgoCD), Monitoring/Alerting, Dokumentasi.

**Di luar scope (anggota lain, sudah dikerjakan):** Internet/NAT, DNS, DHCP, Wireless/Hotspot,
Firewall, VPN L2TP/IPSec, Queues di MikroTik.
Tetap dicatat di `TRACE.md` dengan tanda 👤 karena ada dua titik singgung: record DNS
`ComMX.local.com` / `Grafana.local.com` menunggu IP dari kita, dan pool MetalLB harus di luar
DHCP pool MikroTik.

## 3. Lingkungan fisik

3 PC, masing-masing 24 GB RAM / 10 core / 1 TB, menjalankan Proxmox dan digabung jadi satu datacenter.
Di atasnya: 3 VM control plane + 3 VM worker + 1 VM CI/CD (Forgejo + registry) di luar cluster.

Anggaran kasar yang harus dijaga (RAM adalah batas yang paling cepat kena):

| Peran | Jumlah | RAM | Disk | Core |
|---|---|---|---|---|
| Control plane | 3 | 4 GB | 30 GB | 2 |
| Worker | 3 | 3–4 GB | 25–30 GB | 2 |
| VM CI/CD | 1 | 4 GB | 40 GB | 2 |

Sisakan ~6 GB per PC untuk Proxmox sendiri + overhead Longhorn. Kalau harus memilih, kurangi
worker sebelum mengurangi control plane — HA control plane adalah requirement, jumlah worker tidak.

## 4. Definition of Done — dalam bentuk skenario demo

Bukan daftar fitur. Ini yang akan **ditunjukkan** saat penilaian, dan tiap poin harus punya baris
bukti di `TRACE.md`.

1. **Buka `https://ComMX.local.com` dari PC di jaringan** → halaman ComMX muncul, gembok TLS ada,
   DevTools menunjukkan koneksi `wss://` yang `101 Switching Protocols`.
2. **Dua browser, dua akun, satu lobby** → pesan dari satu muncul di yang lain secara real-time.
3. **Matikan satu node worker** (`qm stop` di Proxmox) → pod-nya terjadwal ulang, aplikasi tetap
   bisa dipakai selama proses itu.
4. **Matikan control plane MASTER keepalived** → VIP berpindah, `kubectl get nodes` dari VM operator
   tetap menjawab.
5. **Push commit ke branch main di Forgejo** → pipeline jalan (scan → build → scan image → push →
   IaC scan → commit tag baru), ArgoCD mendeteksi dan menyinkronkan, pod berjalan dengan tag baru
   (bukan `latest`).
6. **Apply manifest dengan tag `latest` atau tanpa label wajib** → Kyverno **menolak**. Ini kontrol
   negatif; policy yang tidak pernah menolak apa pun tidak membuktikan apa-apa.
7. **Buka `https://Grafana.local.com`**, login `tormonitor` → dashboard CPU/RAM per node dan status
   pod terisi.
8. **Bebani satu node sampai >90%** (atau turunkan ambang sementara) → alert muncul dan **email
   benar-benar masuk** ke inbox anggota.
9. **Terraform `apply` dari nol** membuat seluruh VM; `ansible-playbook` per tahap menyiapkannya
   sampai cluster siap.
10. **Dokumentasi dibaca orang lain** dan mereka bisa mengulang seluruh langkah tanpa bertanya.

## 5. Prioritas kalau waktu habis

Urutan ini yang menentukan apa yang dikorbankan lebih dulu:

1. Cluster HA berdiri + aplikasi bisa diakses lewat HTTPS/WSS (DoD 1–2). Tanpa ini yang lain tidak
   punya tempat berdiri.
2. CI/CD sampai ArgoCD sync (DoD 5).
3. Monitoring + alert email (DoD 7–8).
4. Kyverno + kontrol negatifnya (DoD 6).
5. HA/migrasi Proxmox + backup terjadwal (DoD 3–4).
6. Dokumentasi (DoD 10) — **tapi ditulis sambil jalan, bukan di akhir.** Case menuntut semua
   perintah dan semua IP; mengumpulkannya belakangan hampir selalu gagal.

## 6. Konstanta terkunci

Dari `case.md` — jangan diubah, jangan ditebak variasinya.

| Nama | Nilai |
|---|---|
| Domain aplikasi | `ComMX.local.com` |
| Domain monitoring | `Grafana.local.com` |
| DNS forwarder | `10.22.64.21`, `10.22.64.22` |
| Proxmox user / pass | `Group-1` / `tpanetkelar` |
| Registry user / pass | `Group-1` / `kelargacor` |
| Grafana & Prometheus | `tormonitor` / `monitor` |
| VPN user / pass | `network26-1` / `tpanetgampang` |
| IPSec secret | `duaenamsatu` |
| Hotspot default | `hotspot` / `spothot` |
| Repo sumber | `https://github.com/KenHoH/ComMX.git` |
| CNI | Cilium (tidak boleh diganti) |
| Ambang alert | CPU/RAM node 90% |
| Jadwal backup VM | `12:00` siang (cron `0 12 * * *`) — [[Q-03]] dijawab user 2026-09-04 |
| Email penerima alert | `yayan.gacor07@gmail.com` (+ anggota lain, [[Q-04]]) |

**Nomor kelompok kita = 1** (dijawab user 2026-09-03, [[Q-01]] ditutup). Kelompok teman di folder
`Group A` = 2 — karena itu setiap `group-2` di artefak mereka **wajib** diganti saat menyalin ([[R-01]]).

**Nilai yang ditentukan sendiri** (belum final, isi begitu [[Q-02]] terjawab):

| Nama | Nilai | Catatan |
|---|---|---|
| VIP kube-apiserver | `<belum ditentukan>` | sesubnet dengan cp-01 & cp-02 |
| Port frontend HAProxy | `8443` | tidak boleh 6443 → [[G-01]] |
| Port kube-apiserver | `6443` | |
| Pool MetalLB | `<belum ditentukan>` | di luar DHCP pool MikroTik → [[G-03]] |
| Pod CIDR | `10.244.0.0/16` | konsisten dengan role kita sekarang |
| Namespace aplikasi | `commx-prod` | samakan di ArgoCD Application — sekarang masih beda |

## 7. Batas yang tidak boleh dilanggar

- Jangan menyentuh **Ether 1** MikroTik fisik.
- Jangan mengubah server/konfigurasi tim lain. Artefak Group A **hanya dibaca**, tidak pernah
  dijalankan terhadap lingkungan mereka.
- Jangan push `.env`, `*.tfvars`, `terraform.tfstate`, `secret.yaml`, atau private key.
- Setiap perintah yang dijalankan harus bisa dijelaskan saat penilaian — kalau agent memberi
  perintah yang tidak dipahami user, **itu bug pada agent**, bukan pada user. Sertakan alasannya
  satu baris di dokumentasi.
