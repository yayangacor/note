# ==============================================================================
#  SEMUA ANGKA JARINGAN TERKUMPUL DI FILE INI.
#  Saat IP asli dari MikroTik sudah diketahui, ganti default di sini
#  (atau override lewat terraform.tfvars yang tidak di-commit).
#
#  Nilai bertanda TODO(Q-02) masih placeholder.
# ==============================================================================

# ---- Kredensial Proxmox ------------------------------------------------------
# JANGAN taruh nilainya di file .tf atau .tfvars yang di-commit. Isi lewat
# environment variable saat apply:
#   export TF_VAR_proxmox_api_url="https://<ip-proxmox>:8006/"
#   export TF_VAR_proxmox_api_token_id="Group-1@pve!terraform"
#   export TF_VAR_proxmox_api_token_secret="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

variable "proxmox_api_url" {
  type        = string
  description = "Base URL API Proxmox, TANPA suffix /api2/json (provider bpg berbeda dari telmate)"
}

variable "proxmox_api_token_id" {
  type        = string
  description = "Token ID Proxmox, format user@realm!tokenname"
}

variable "proxmox_api_token_secret" {
  type        = string
  sensitive   = true
  description = "Kunci rahasia token Proxmox"
}

variable "ssh_public_key" {
  type        = string
  description = "Isi teks public key SSH yang ditanam ke setiap VM lewat cloud-init"
}

# ---- Node Proxmox ------------------------------------------------------------
variable "proxmox_node_names" {
  type        = list(string)
  default     = ["pve1", "pve2", "pve3"]
  description = "Node Proxmox tempat VM disebar merata"
}

# Template cloud-init bersifat LOKAL per node kalau storage-nya local-lvm --
# tidak shared antar node. Verifikasi dengan `qm list` di TIAP node (G-09).
variable "template_vm_ids" {
  type = map(number)
  default = {
    pve1 = 9000
    pve2 = 9000
    pve3 = 9000
  }
  description = "VMID template cloud-init di masing-masing node"
}

variable "vm_datastore" {
  type        = string
  default     = "local-lvm"
  description = "Datastore untuk disk VM. Ganti ke storage shared kalau ingin live migration."
}

variable "network_bridge" {
  type        = string
  default     = "vmbr0"
  description = "Bridge jaringan Proxmox"
}

# ---- Jaringan ----------------------------------------------------------------
# TODO(Q-02): tiga variabel di bawah ini yang paling sering perlu diganti.
variable "network_cidr_bits" {
  type        = number
  default     = 24
  description = "Panjang prefix subnet, misal 24 untuk /24"
}

variable "network_gateway" {
  type        = string
  default     = "192.168.10.1"
  description = "TODO(Q-02): gateway subnet node"
}

variable "dns_servers" {
  type        = list(string)
  default     = ["10.22.64.21", "10.22.64.22"]
  description = "DNS forwarder dari case -- jangan diubah"
}

# IP STATIS. Case mewajibkan IP server dikonfigurasi manual, bukan DHCP.
# Urutannya menentukan penamaan: elemen ke-0 jadi k8s-cp-01, dst.
variable "control_plane_ips" {
  type = list(string)
  default = [
    "192.168.10.11", # k8s-cp-01  TODO(Q-02)
    "192.168.10.12", # k8s-cp-02  TODO(Q-02)
    "192.168.10.13", # k8s-cp-03  TODO(Q-02)
  ]
  description = "IP statis control plane (wajib unik)"
}

variable "worker_ips" {
  type = list(string)
  default = [
    "192.168.10.21", # k8s-worker-01  TODO(Q-02)
    "192.168.10.22", # k8s-worker-02  TODO(Q-02)
    "192.168.10.23", # k8s-worker-03  TODO(Q-02)
  ]
  description = "IP statis worker (wajib unik dan beda dari control plane)"
}

# Dipakai hanya untuk menulis inventory Ansible, bukan membuat VM.
variable "cicd_host_ip" {
  type        = string
  default     = "192.168.1.197"
  description = "TODO(Q-05): VM Forgejo + registry, di luar cluster"
}

# ---- Spesifikasi VM ----------------------------------------------------------
# Anggaran RAM ketat: 3 PC x 24 GB. Lihat INSTRUCTION.md bagian 3.
variable "control_plane_spec" {
  type = object({ cores = number, memory = number, disk = number })
  default = { cores = 2, memory = 4096, disk = 30 }
}

variable "worker_spec" {
  type = object({ cores = number, memory = number, disk = number })
  default = { cores = 2, memory = 3584, disk = 30 }
}

variable "vm_username" {
  type        = string
  default     = "ubuntu"
  description = "User Linux di VM, dibuat oleh cloud-init"
}
