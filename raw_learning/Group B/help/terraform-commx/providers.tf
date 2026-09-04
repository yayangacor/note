terraform {
  required_version = ">= 1.5.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.111.1" # cek versi terbaru di registry.terraform.io/providers/bpg/proxmox
    }
  }
}

provider "proxmox" {
  # [PENTING] endpoint bpg TANPA suffix /api2/json (beda dari telmate)
  # contoh: https://192.168.2.10:8006/
  endpoint = var.proxmox_api_url

  # bpg gabungin token id + secret jadi satu string "tokenid=secret"
  api_token = "${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}"

  insecure = true # abaikan eror SSL/TLS sertifikat self-signed lokal
}
