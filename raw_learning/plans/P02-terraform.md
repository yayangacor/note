# P02 — Terraform: provisioning 6 VM + IP statis + inventory

**Status:** 🚧 kode ada, belum pernah di-apply · **Dependency:** P01 · **Blokir:** [[Q-02]]

Kode: `Group B/ComMX-Forgejo/terraform-commx/`

## Yang sudah benar

- Provider `bpg/proxmox` 0.111.1, endpoint tanpa `/api2/json`, token dari `TF_VAR_*` → memenuhi
  requirement "env var untuk data sensitif".
- `.gitignore` sudah menutup `.terraform/`, `terraform.tfstate*`, `*.tfvars`.
- `template_vm_ids` per node — sadar bahwa `local-lvm` tidak shared ([[G-09]]).

## Yang harus diperbaiki (tiga cacat nyata)

1. **IP masih DHCP.** `main.tf` menulis `ip_config { ipv4 { address = "dhcp" } }`, padahal
   `control_plane_actual_ips` dan `worker_actual_ips` sudah didefinisikan dan **tidak dipakai**.
   Case mewajibkan IP server statis. Perbaikannya:
   ```hcl
   ip_config {
     ipv4 {
       address = "${var.control_plane_actual_ips[count.index]}/24"
       gateway = var.network_gateway     # variabel baru
     }
   }
   ```
   Tambahkan juga `dns { servers = ["10.22.64.21", "10.22.64.22"] }`.
2. **`outputs.tf` menghitung IP dengan rumus yang tidak dipakai siapa pun.** Blok `locals`
   (`cp_ips`, `worker_ips`) menghasilkan `192.168.2.51` dst — tidak cocok dengan
   `control_plane_actual_ips` (`.111`) dan tidak dirujuk resource mana pun. Hapus, lalu buat
   inventory dari variabel IP statis, bukan dari laporan guest agent (yang bisa kosong saat VM
   baru boot dan membuat `terraform apply` gagal di tengah).
3. **Inventory yang di-generate belum lengkap.** Perlu grup tambahan agar P04–P07 jalan:
   `[loadbalancer]` (cp-01 MASTER prio 110, cp-02 BACKUP prio 100), `[cicd]` (VM Forgejo),
   `[speaker]` (node sesubnet pool MetalLB). Kalau grup ini ditulis manual, ia akan hilang setiap
   `terraform apply` — masukkan ke template `outputs.tf`. Ini pelajaran langsung dari [[G-13]]:
   Group A menulis `[loadbalancer]` manual dan grup `[cicd]` yang dirujuk `site.yml` malah tidak
   pernah ada.

## Langkah

1. Tentukan alokasi IP final ([[Q-02]]): 6 IP node + 1 VIP + rentang MetalLB + IP VM CI/CD.
   Tulis semuanya di dokumentasi (case menuntut daftar IP yang direservasi).
2. Perbaiki `main.tf` (IP statis + DNS), `variables.tf` (tambah `network_gateway`), `outputs.tf`
   (inventory lengkap, tanpa `locals` mati).
3. Cloud-init: `user_account` hanya berisi `username` + `keys` — sesuai case "cloud-init drive
   dengan nilai kosong", jangan menanam password.
4. **State.** Case meminta state dikelola supaya tidak hilang. Minimal: state lokal di VM operator
   + `chmod 600` + backup terjadwal ke luar VM. Lebih baik: backend HTTP milik Forgejo, atau
   backend S3 (MinIO) kalau sempat. Putuskan dan catat sebagai `D-xx`.
5. `terraform init` → `plan` → `apply`.

## Definition of Done

- [ ] `terraform plan` bersih (0 error) — tempel ringkasannya.
- [ ] `terraform apply` membuat 6 VM; `qm list` di 3 node menunjukkan semuanya `running`.
- [ ] `ssh ubuntu@<ip>` berhasil ke keenam VM dengan key yang sama.
- [ ] `ip -4 addr` di tiap VM menunjukkan **IP statis yang direncanakan**, bukan IP DHCP.
- [ ] `ansible/hosts.ini` ter-generate dan memuat grup `control_plane`, `workers`, `loadbalancer`,
      `cicd`, `speaker`.
- [ ] **Kontrol negatif idempotensi:** `terraform apply` kedua kali menghasilkan
      `No changes. Your infrastructure matches the configuration.`
- [ ] `git status` bersih dari `terraform.tfstate` dan `*.tfvars`.

## Hasil eksekusi

_(kosong)_
