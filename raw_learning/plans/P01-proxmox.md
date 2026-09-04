# P01 — Proxmox: datacenter, template, backup, HA

**Status:** ❌ belum mulai · **Dependency:** **[[P00]]** (Proxmox harus sudah hidup dengan KVM nested TERBUKTI) · **Blokir:** tidak ada

> Dokumen ini mulai dari Proxmox yang sudah terpasang dan bisa menjalankan VM. Kalau Proxmox belum ada, atau `qm start` gagal dengan `KVM virtualisation configured, but not available`, kerjakan `P00` dulu — tidak satu pun langkah di bawah bisa lulus tanpa itu.

## Scope

3 PC Proxmox digabung jadi satu datacenter, disiapkan supaya Terraform bisa meng-clone VM, dan
dipasangi backup terjadwal + HA/migrasi. Semua VM Kubernetes berdiri di atas ini.

## Langkah

1. **User Proxmox per grup.** Datacenter → Permissions → Users: `Group-1@pve` / `tpanetkelar`,
   role `PVEAdmin` (atau `Administrator`) di path `/`.
2. **Cluster datacenter.** Di PC pertama: `pvecm create tpa-net-261`. Di PC lain:
   `pvecm add <ip-pc-pertama>`. Verifikasi `pvecm status` → `Quorate: Yes`, 3 node.
   Cluster butuh jaringan yang stabil antar PC; kalau link putus, quorum hilang dan VM jadi read-only.
3. **API token untuk Terraform.** Datacenter → API Tokens → `Group-1@pve!terraform`,
   **uncheck Privilege Separation** (atau beri permission eksplisit ke token-nya). Simpan secret;
   dipakai sebagai `TF_VAR_proxmox_api_token_secret`, tidak pernah masuk repo.
4. **Template cloud-init Ubuntu**, dibuat **di setiap node** (storage `local-lvm` tidak shared → [[G-09]]):
   ```bash
   wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
   qm create 9000 --name ubuntu-2404-template --memory 2048 --core 2 --net0 virtio,bridge=vmbr0
   qm importdisk 9000 noble-server-cloudimg-amd64.img local-lvm
   qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
   qm set 9000 --ide2 local-lvm:cloudinit --boot c --bootdisk scsi0 --serial0 socket --vga serial0
   qm set 9000 --agent enabled=1
   qm template 9000
   ```
   Catat VMID template tiap node (`qm list`) → isi `template_vm_ids` di Terraform.
   Case meminta **cloud-init drive dengan nilai kosong**: jangan isi user/password/IP di template,
   biarkan Terraform yang mengisinya per VM.
5. **Tuning performa** (case: "Proxmox tidak melempem"): `qemu-guest-agent` aktif di template,
   CPU type `host`, disk `virtio-scsi-single` + `iothread`, ballooning aktif, dan **jangan**
   overcommit RAM melewati anggaran di `INSTRUCTION.md` §3.
6. **Backup terjadwal.** Datacenter → Backup → Add: semua VM, storage tujuan lokal, mode
   **Snapshot**, retention 2–3, jadwal harian **jam 12:00 siang** (`0 12 * * *`) — [[Q-03]].
   Mode Snapshot dipilih supaya VM tetap hidup selama backup; jam 12 siang adalah jam sibuk,
   dan mode Stop akan mematikan cluster di tengah hari.
   Tulis di dokumentasi bahwa "12:00 PM" dibaca sebagai jam 12 siang — case menulis
   "every night at 12:00 PM" yang kontradiktif, jadi pilihan ini harus bisa dibela.
7. **HA / migrasi.** Datacenter → HA → Groups (isi ketiga node) → Resources: tambahkan tiap VM
   dengan state `started`. Syaratnya storage bisa diakses node tujuan — dengan `local-lvm`,
   migrasi live tidak mungkin; **putuskan dan catat sebagai D-xx**: pakai replikasi ZFS,
   shared storage, atau terima migrasi offline saja.

## Definition of Done

- [ ] `pvecm status` menunjukkan 3 node, `Quorate: Yes` — tempel outputnya.
- [ ] Login web Proxmox dengan `Group-1` berhasil.
- [ ] `qm list` di **tiap** node menampilkan template, VMID tercatat di `terraform-commx/variables.tf`.
- [ ] Job backup pertama selesai — tempel baris log `Backup finished`, bukan hanya screenshot
      jadwal. Jangan menunggu jam 12: klik **Run now** untuk membuktikannya sekarang, lalu
      pastikan jadwalnya benar lewat `cat /etc/pve/jobs.cfg`.
- [ ] **Kontrol negatif HA:** matikan paksa satu node (`qm stop` / cabut), VM yang HA-nya aktif
      benar-benar hidup lagi di node lain. Tanpa uji ini, konfigurasi HA belum terbukti.

## Hasil eksekusi

_(kosong — isi dengan output mentah, jangan ringkasan)_

## Catatan

Keputusan soal storage untuk migrasi (langkah 7) belum diambil dan berdampak besar ke P02:
kalau memilih shared storage/replikasi, `datastore_id` di Terraform ikut berubah.
