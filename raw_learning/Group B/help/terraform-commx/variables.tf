# Kredensial Proxmox API
# [PENTING] Sesuai requirement case: JANGAN taruh nilai token di file .tf/.tfvars yang di-commit.
# Isi lewat environment variable saat apply, contoh:
#   export TF_VAR_proxmox_api_token_id="group-x@pve!terraform"
#   export TF_VAR_proxmox_api_token_secret="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
variable "proxmox_api_url" {
  type        = string
  description = "Base URL endpoint API Proxmox, TANPA suffix /api2/json (contoh: https://192.168.2.10:8006/)"
}

variable "proxmox_api_token_id" {
  type        = string
  description = "Token ID dari Proxmox Datacenter (format: user@realm!tokenname)"
}

variable "proxmox_api_token_secret" {
  type        = string
  sensitive   = true
  description = "Kunci Rahasia Token Proxmox"
}

variable "ssh_public_key" {
  type        = string
  description = "Isi teks dari public key SSH untuk dimasukkan ke dalam VM"
}


# Konfigurasi VM Utama
variable "proxmox_node_names" {
  type        = list(string)
  default     = ["pve1", "pve2", "pve3"]
  description = "Daftar node Proxmox untuk menyebarkan VM secara merata"
}

# [PENTING] Template local-lvm bersifat lokal per node, TIDAK shared antar node,
# makanya tiap node punya template sendiri dengan VMID berbeda.
# Verifikasi via `qm list` di tiap node kalau angka ini berubah.
variable "template_vm_ids" {
  type = map(number)
  default = {
    pve1 = 101
    pve2 = 103
    pve3 = 102
  }
  description = "VMID template cloud-init per node"
}

# ==============================================================================
# ALOKASI IP UNIK UNTUK CLUSTER K8S (WAJIB BERBEDA PER VM)
# ==============================================================================

variable "control_plane_actual_ips" {
  type        = list(string)
  description = "Daftar IP statis untuk 3 node Control Plane (Wajib Unik)"
  default     = [
    "192.168.2.111", # VM k8s-cp-01 (di pve1 -> subnet .2.x)
    "192.168.3.112", # VM k8s-cp-02 (di pve2 -> subnet .3.x)
    "192.168.3.113"  # VM k8s-cp-03 (di pve3 -> subnet .3.x)
  ]
}

variable "worker_actual_ips" {
  type        = list(string)
  description = "Daftar IP statis untuk 3 node Worker (Wajib Unik & Beda dari CP)"
  default     = [
    "192.168.2.121", # VM k8s-worker-01 (di pve1 -> subnet .2.x)
    "192.168.3.122", # VM k8s-worker-02 (di pve2 -> subnet .3.x)
    "192.168.3.123"  # VM k8s-worker-03 (di pve3 -> subnet .3.x)
  ]
}
