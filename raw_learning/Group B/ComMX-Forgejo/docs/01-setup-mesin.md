# 01 — Setup mesin: VMware Workstation → Proxmox (nested)

Dari PC Windows kosong sampai Proxmox hidup dengan KVM **terbukti** aktif, dikerjakan identik di
ketiga PC. Dokumen berikutnya (`02-cluster-proxmox.md`) mulai dari titik ini.

**Cara membaca dokumen ini.** Tiap langkah punya perintah yang bisa disalin apa adanya, dan
**bentuk output yang dianggap lulus**. Jangan lanjut ke langkah berikutnya sebelum bentuk itu
muncul — beberapa kegagalan di lapisan ini baru terasa berjam-jam kemudian, jauh dari sebabnya.

## Scope

Dari PC Windows kosong sampai Proxmox hidup di dalam VMware Workstation, dengan KVM **terbukti
aktif**, di ketiga PC, dan ketiganya bisa saling menjangkau. P01 mulai dari titik itu (`pvecm
create`), jadi dokumen ini menutup celah yang selama ini tidak dimiliki siapa pun.

Lapisannya tiga tingkat:

```
Windows (PC lab)
└── VMware Workstation  ──> VM "pve1"  (nested virtualization WAJIB aktif)
    └── Proxmox VE
        └── VM Kubernetes (cp-01, worker-01, …)   <- dibuat Terraform, P02
```

Tingkat ketiga itu yang membuat langkah 1 tidak bisa dilewati: tanpa VT-x diteruskan ke Proxmox,
Proxmox tetap terpasang tapi **tidak bisa menjalankan VM sama sekali**.

---

## 1. Prasyarat host — kerjakan di TIAP PC sebelum apa pun

### 1.1 Virtualisasi aktif di firmware

Masuk BIOS/UEFI → aktifkan **Intel VT-x + VT-d** (AMD: **SVM Mode + IOMMU**). Namanya berbeda-beda:
`Intel Virtualization Technology`, `SVM Mode`, `Vanderpool`.

### 1.2 Hyper-V HARUS mati — ini penyebab kegagalan yang paling mahal

Selama Hyper-V hidup, VMware berjalan di mode **WHP** dan **tidak bisa meneruskan VT-x ke guest**.
Proxmox akan terpasang dan terlihat normal, lalu setiap `qm start` gagal. Gejalanya jauh dari
sebabnya, jadi periksa sekarang, bukan nanti.

Yang menyalakan Hyper-V diam-diam: **WSL2, Docker Desktop, Windows Sandbox, Memory Integrity,
Credential Guard, Virtual Machine Platform.**

**Cek (PowerShell biasa):**
```powershell
(Get-CimInstance Win32_ComputerSystem).HypervisorPresent
```
`False` = aman. `True` = masih ada hypervisor, lanjut ke perintah di bawah.

**Matikan (PowerShell sebagai Administrator), lalu REBOOT:**
```powershell
bcdedit /set hypervisorlaunchtype off
dism /online /disable-feature /featurename:Microsoft-Hyper-V-All /norestart
dism /online /disable-feature /featurename:VirtualMachinePlatform  /norestart
dism /online /disable-feature /featurename:HypervisorPlatform      /norestart
dism /online /disable-feature /featurename:Windows-Defender-ApplicationGuard /norestart
```
Lalu **Windows Security → Device security → Core isolation → Memory integrity: Off**, dan reboot.

**Bukti lulus, sesudah reboot:**
```powershell
(Get-CimInstance Win32_ComputerSystem).HypervisorPresent   # harus False
bcdedit /enum "{current}" | Select-String hypervisorlaunchtype   # harus: Off
```

> **Konsekuensi yang harus diterima sadar:** WSL2 dan Docker Desktop **berhenti bekerja** di PC itu
> selama Hyper-V mati. Kalau salah satu PC juga dipakai untuk hal lain, pilih PC yang lain — jangan
> menyalakan Hyper-V lagi lalu heran kenapa Proxmox tiba-tiba rusak.

### 1.3 Versi VMware

Pakai **VMware Workstation Pro 17** (gratis untuk penggunaan personal sejak 2024). VMware **Player**
versi lama tidak menampilkan checkbox nested virtualization di UI — masih bisa dipaksa lewat file
`.vmx` (langkah 4.2), tapi Pro 17 jauh lebih sedikit kejutannya.

### 1.4 Jaringan: kabel, bukan Wi-Fi

Ketiga PC **wajib** tersambung ke MikroTik lewat **Ethernet**. Mode Bridged mengirimkan banyak MAC
address berbeda dari satu kartu jaringan (Proxmox + tiap VM di dalamnya). Access point Wi-Fi
umumnya menolak itu, dan gejalanya menyesatkan: Proxmox dapat IP, tapi VM di dalamnya tidak pernah
dapat — terlihat seperti masalah DHCP, padahal masalah Wi-Fi.

---

## 2. Anggaran sumber daya per PC

Dari `INSTRUCTION.md` §3: tiap PC 24 GB RAM / 10 core / 1 TB. Tiap PC menampung **1 control plane +
1 worker**; salah satu PC menampung **VM CI/CD** juga.

| Lapisan | RAM | Core | Disk |
|---|---|---|---|
| Windows host, sisakan | 4–5 GB | 2 | — |
| **VM Proxmox di VMware** | **18 GB** | **8** | **250 GB** |
| ├─ Proxmox sendiri | ~2,5 GB | — | ~15 GB |
| ├─ control plane ×1 | 4 GB | 2 | 30 GB |
| ├─ worker ×1 | 3,5 GB | 2 | 30 GB |
| └─ (PC #3) VM CI/CD | 4 GB | 2 | 40 GB |

Disk 250 GB bukan berlebihan: 2 VM (60 GB) + template (~5 GB) + Proxmox + **backup harian dengan
retention 2–3** (jadwal backup 12:00). Backup yang kehabisan ruang gagal diam-diam dan baru ketahuan saat
dibutuhkan.

PC #3 yang menampung VM CI/CD: naikkan RAM VM Proxmox jadi **19–20 GB** kalau host mengizinkan.

---

## 3. Rencana alamat — ini juga jawaban sebagian untuk rencana alamat (§3)

Semua di **satu subnet** di belakang MikroTik. Kebutuhan minimum:

| Peran | Jumlah |
|---|---|
| Node Proxmox (pve1–pve3) | 3 |
| Control plane k8s | 3 |
| Worker k8s | 3 |
| VM CI/CD (Forgejo + registry) | 1 |
| VIP apiserver (keepalived) | 1 |
| Pool MetalLB | 20 |
| **Total** | **31** + gateway + MikroTik |

Aturan yang mengikat, jangan ditawar:
- **VIP dan pool MetalLB wajib DI LUAR pool DHCP MikroTik.** Kalau tumpang tindih, DHCP akan
  memberikan alamat yang sudah dipakai VIP, dan gejalanya muncul acak berhari-hari kemudian.
- **Pool MetalLB wajib sesubnet dengan node** — MetalLB L2 mengumumkan lewat ARP, dan ARP tidak
  melewati router (catatan MetalLB L2 / ARP).
- IP node Proxmox dan VM k8s **statis**, bukan DHCP (case A-4).

Minta ke anggota jaringan: satu blok berurutan 31+ alamat di luar pool DHCP. Angka finalnya masuk
ke `terraform-commx/variables.tf` dan `ansible/group_vars/all/vars.yml` — **hanya** dua file itu.

---

## 4. Buat VM Proxmox di VMware

### 4.1 Wizard

New Virtual Machine → **Custom (advanced)**:

| Pengaturan | Nilai | Kenapa |
|---|---|---|
| Guest OS | Linux → **Debian 12.x 64-bit** | Proxmox 8 berbasis Debian 12 |
| Firmware | **BIOS** (Legacy) | UEFI juga bisa, tapi Secure Boot wajib Off — BIOS paling sedikit kejutan |
| Processors | **8** core total | — |
| **Virtualize Intel VT-x/EPT** | ✅ **CENTANG** | **Ini inti seluruh dokumen ini** |
| Memory | **18432 MB** | lihat §2 |
| Network | **Bridged (Automatic)** | node harus terlihat di LAN fisik |
| ↳ Replicate physical network state | ✅ centang | link down ikut terbaca di guest |
| SCSI Controller | **LSI Logic** / VMware Paravirtual | — |
| Disk | **250 GB**, **Store as single file** | split file memperlambat I/O nested |
| Sound / Printer / USB | **Remove** | mengurangi overhead dan interupsi |

### 4.2 Kalau checkbox VT-x tidak ada (VMware Player)

Matikan VM, edit file `.vmx` VM itu dengan Notepad, tambahkan di baris paling bawah:

```
vhv.enable = "TRUE"
hypervisor.cpuid.v0 = "FALSE"
vpmc.enable = "TRUE"
```

`hypervisor.cpuid.v0 = FALSE` menyembunyikan tanda "kamu di dalam hypervisor" dari guest — beberapa
tool menolak menyalakan KVM kalau melihat tanda itu.

---

## 5. Install Proxmox VE

Unduh ISO Proxmox VE 8.x, pasang sebagai CD/DVD di VM, boot.

- Filesystem: **ext4** (default). ZFS di dalam VMware memakan RAM besar tanpa memberi manfaat di sini.
- Country/timezone: **Asia/Jakarta**.
- Password root: catat, dipakai lagi di P01.
- **Management network** — isi manual, jangan DHCP:

| Isian | pve1 | pve2 | pve3 |
|---|---|---|---|
| Hostname (FQDN) | `pve1.local.com` | `pve2.local.com` | `pve3.local.com` |
| IP address / CIDR | `<node-1>/24` | `<node-2>/24` | `<node-3>/24` |
| Gateway | IP MikroTik | idem | idem |
| DNS | `10.22.64.21` | idem | idem |

DNS `10.22.64.21` / `.22` **dikunci case**, jangan diganti.

> Hostname wajib **berbeda** di ketiga node dan tidak boleh diubah setelah cluster dibuat —
> `pvecm` memakainya sebagai identitas. Mengganti hostname sesudah join berarti membongkar cluster.

Setelah reboot, buka `https://<ip-node>:8006` dari browser PC lain. Peringatan sertifikat
self-signed itu normal.

---

## 6. Post-install tiap node

```bash
# Repo enterprise butuh langganan berbayar; tanpa diganti, `apt update` selalu gagal 401.
CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")
rm -f /etc/apt/sources.list.d/pve-enterprise.list
sed -i 's/^deb/#deb/' /etc/apt/sources.list.d/ceph.list 2>/dev/null || true
echo "deb http://download.proxmox.com/debian/pve $CODENAME pve-no-subscription" \
  > /etc/apt/sources.list.d/pve-no-subscription.list

apt update && apt full-upgrade -y
apt install -y chrony
```

`chrony` bukan pelengkap: **jam yang tidak sinkron membuat `pvecm add` dan `kubeadm join` ditolak**,
dan pesannya tidak menyebut waktu sama sekali. VM di dalam VMware sangat gampang melenceng jamnya
setelah host di-suspend.

**Bukti lulus:**
```bash
apt update                       # LULUS: tanpa baris 401 Unauthorized
chronyc tracking | head -3       # LULUS: "Leap status : Normal"
timedatectl | grep -i sync       # LULUS: "System clock synchronized: yes"
```

---

## 7. BUKTIKAN nested virtualization benar-benar hidup

Langkah paling penting di dokumen ini. Jangan lanjut ke P01 sebelum ini lulus — semua kegagalan
sesudahnya akan terlihat seperti masalah lain.

```bash
# 1. Modul KVM termuat
lsmod | grep kvm

# 2. CPU flag virtualisasi terlihat DI DALAM Proxmox
grep -o -m1 -E 'vmx|svm' /proc/cpuinfo

# 3. Device KVM ada
ls -l /dev/kvm

# 4. Nested tersedia untuk lapisan berikutnya
cat /sys/module/kvm_intel/parameters/nested   # Intel; AMD: kvm_amd
```

**Bentuk output yang dianggap lulus:** langkah 1 menampilkan `kvm_intel`/`kvm_amd`; langkah 2
mencetak `vmx` atau `svm`; langkah 3 menampilkan `/dev/kvm`; langkah 4 mencetak `Y` atau `1`.

**Kalau langkah 2 tidak mencetak apa pun**, VT-x tidak diteruskan. Kembali ke §1.2 dan §4.1 —
jangan mencoba memperbaiki Proxmox, masalahnya di lapisan VMware.

### 7.1 Kontrol positif — bikin VM uji sungguhan

Empat perintah di atas membaca konfigurasi. Yang membuktikan **fitur berjalan** adalah VM yang
benar-benar menyala (B1):

```bash
qm create 999 --name uji-kvm --memory 1024 --cores 1 \
  --net0 virtio,bridge=vmbr0 --ostype l26
qm start 999
qm status 999          # LULUS: "status: running"
qm stop 999 && qm destroy 999
```

**Pesan gagal yang harus dikenali:**
```
KVM virtualisation configured, but not available.
Either disable in VM configuration or enable in BIOS.
```
Itu berarti nested virt mati. Bukan masalah Proxmox, bukan masalah lisensi — kembali ke §1.2.

### 7.2 Kontrol negatif (opsional, tapi ini yang membuat §7 bernilai)

Untuk membuktikan pemeriksaan di atas memang bisa gagal: matikan VM, ubah `vhv.enable = "FALSE"`
di `.vmx`, nyalakan lagi, lalu jalankan `qm start 999`. Ia **harus** gagal dengan pesan di atas.
Kembalikan ke `TRUE` sesudahnya. Pemeriksaan yang tidak pernah gagal tidak membuktikan apa pun (B3).

---

## 8. Ketiga node harus saling menjangkau

Dikerjakan setelah ketiga PC selesai. `pvecm` di P01 akan gagal tanpa ini.

```bash
# Dari pve1, ke dua node lain
ping -c3 <ip-pve2> && ping -c3 <ip-pve3>

# Port cluster Corosync (5405/udp) dan web (8006/tcp)
ss -lntup | grep -E '8006|5405'

# Nama saling kenal -- isi /etc/hosts di KETIGA node dengan ketiga baris
cat /etc/hosts
```

**Bukti lulus:** ping 0% packet loss dua arah, dan `/etc/hosts` di ketiga node memuat ketiga
pasangan IP–hostname yang sama persis.

> Jangan pakai NAT di VMware. Dengan NAT, ketiga Proxmox berada di jaringan virtual terpisah per PC
> dan tidak akan pernah bisa membentuk cluster — dan itu baru ketahuan saat `pvecm add` menggantung
> tanpa pesan yang jelas.

---

## 9. Serah terima ke P01

Sesudah dokumen ini lulus, yang tersedia untuk P01:

- 3 node Proxmox hidup, IP statis, saling ping, jam sinkron
- KVM nested **terbukti** lewat VM uji yang benar-benar menyala
- `apt update` bersih
- Belum ada: cluster (`pvecm`), user `Group-1`, API token, template cloud-init, backup, HA
  — semuanya milik `02-cluster-proxmox.md`

---

## Definition of Done

- [ ] `(Get-CimInstance Win32_ComputerSystem).HypervisorPresent` → **False** di ketiga PC
- [ ] `grep -o -m1 -E 'vmx|svm' /proc/cpuinfo` di dalam **tiap** Proxmox → mencetak `vmx`/`svm`
- [ ] `cat /sys/module/kvm_intel/parameters/nested` → `Y`
- [ ] VM uji `qm start 999` → `status: running` di **ketiga** node — tempel outputnya
- [ ] **Kontrol negatif §7.2** dijalankan minimal di satu node: dengan `vhv.enable = FALSE`,
      `qm start` benar-benar gagal
- [ ] `apt update` tanpa 401, `timedatectl` synchronized di ketiga node
- [ ] Ping antar ketiga node 0% loss, `/etc/hosts` identik
- [ ] Blok 31+ alamat sudah disepakati dengan anggota jaringan dan ditulis di `NOTES.md` rencana alamat (§3)

## Catatan

Nested virtualization membuat VM di lapisan ketiga **jauh lebih lambat** daripada di Proxmox
bare-metal. Itu wajar dan bukan kesalahan konfigurasi. Yang paling terasa: `kubeadm init` dan
`helm install` yang menunggu pod Ready. Naikkan `timeout` di role Ansible sebelum menyimpulkan ada
yang menggantung — beberapa role sudah memakai 15–20 menit justru karena ini.
