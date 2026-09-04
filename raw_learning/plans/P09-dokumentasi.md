# P09 — Dokumentasi

**Status:** ❌ belum mulai · **Dependency:** semua (tapi **ditulis sambil jalan**)

Case menuntut dokumentasi yang memuat **semua perintah** dan **semua IP yang direservasi**, cukup
jelas untuk direplikasi orang lain. Mengumpulkan itu di akhir hampir selalu gagal: perintah yang
sudah jalan terlupakan, dan IP yang sempat berubah tidak terlacak.

**Aturan operasionalnya:** setiap kali sebuah langkah lulus DoD di plan mana pun, perintah dan
outputnya langsung disalin ke draf dokumentasi. Plan menyimpan bukti; dokumentasi menyimpan
narasi yang bisa diikuti orang lain.

## Struktur yang ditargetkan

1. **Ringkasan arsitektur** — diagram sederhana: 3 PC Proxmox → 6 VM + 1 VM CI/CD → cluster →
   Gateway → MikroTik.
2. **Tabel alokasi IP** (ini yang paling sering diminta saat penilaian):

   | Host / resource | IP | Subnet | Keterangan |
   |---|---|---|---|
   | pve1 / pve2 / pve3 | | | node Proxmox |
   | k8s-cp-01..03 | | | control plane |
   | k8s-worker-01..03 | | | worker |
   | VIP kube-apiserver | | | keepalived, port 8443 |
   | Pool MetalLB | | | di luar DHCP pool |
   | Gateway ComMX | | | → record DNS `ComMX.local.com` |
   | Grafana LB | | | → record DNS `Grafana.local.com` |
   | VM CI/CD (Forgejo+registry) | | | port 3000 / 5000 |

3. **Setup Proxmox** (P01) — termasuk kenapa template harus ada di tiap node.
4. **Terraform** (P02) — variabel, cara mengisi `TF_VAR_*`, cara state dijaga.
5. **Ansible** (P03–P05) — daftar role, urutan `--tags`, dan **kenapa urutannya begitu**.
6. **Konfigurasi aplikasi** (P06) — env yang dibutuhkan, sertifikat, kenapa `--build-arg` wajib.
7. **Kubernetes** (P04–P06) — init HA, CNI, MetalLB, Gateway, Kyverno, HPA.
8. **Monitoring & alerting** (P08).
9. **CI/CD** (P07).
10. **Justifikasi strategi deployment** — salin dari [[D-12]]. Case meminta ini secara eksplisit
    dan bernilai sendiri.
11. **Troubleshooting** — ambil dari indeks gejala `NOTES.md`. Bagian ini yang membedakan
    dokumentasi yang bisa direplikasi dari yang hanya bisa dibaca.

## Aturan penulisan

- Setiap perintah diberi **satu baris alasan**. Case menyatakan peserta yang tidak bisa menjelaskan
  sebuah perintah tidak mendapat nilai penuh — dokumentasi adalah tempat menyiapkan jawaban itu.
- Tidak ada kredensial asli di dokumentasi yang di-commit. Pakai placeholder + tunjukkan di mana
  nilai aslinya disimpan.
- Format bebas (`.txt` atau Word). Tulis dulu sebagai Markdown, ekspor belakangan.

## Definition of Done

- [ ] Semua 11 bagian terisi.
- [ ] Tabel IP lengkap dan cocok dengan kenyataan (`kubectl get nodes -o wide`, `qm list`).
- [ ] **Uji replikasi:** satu anggota yang tidak mengerjakan bagian tertentu mengikuti dokumentasi
      itu dan berhasil tanpa bertanya. Kalau dia bertanya, yang ditanyakan adalah lubang di
      dokumentasi — catat dan tambal.

## Hasil eksekusi

_(kosong)_
