# ==============================================================================
# 1. BUAT 3 NODE CONTROL PLANE (Master K8s)
# ==============================================================================
resource "proxmox_virtual_environment_vm" "k8s_control_planes" {
  count     = 3
  name      = "k8s-cp-0${count.index + 1}"
  vm_id     = 300 + count.index + 1 # 301, 302, 303
  node_name = var.proxmox_node_names[count.index % length(var.proxmox_node_names)]

  clone {
    vm_id = var.template_vm_ids[var.proxmox_node_names[count.index % length(var.proxmox_node_names)]]
    full  = true
  }

  scsi_hardware = "virtio-scsi-single"

  cpu {
    cores = 2
  }

  memory {
    dedicated = 4096
  }

  on_boot = true

  agent {
    enabled = true
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 30
  }

  network_device {
    bridge = "vmbr0"
  }

  # Logika IP Statis Berdasarkan Node Penempatan (pve1 = 192.168.2.5x, pve2/3 = 192.168.3.5x)
  initialization {
    datastore_id = "local-lvm"

    user_account {
      username = "ubuntu"
      keys     = [var.ssh_public_key]
    }

    ip_config {
      ipv4 {
	address = "dhcp"
      }
    }
  }

}

# ==============================================================================
# 2. BUAT 3 NODE WORKERS
# ==============================================================================
resource "proxmox_virtual_environment_vm" "k8s_workers" {
  count     = 3
  name      = "k8s-worker-0${count.index + 1}"
  vm_id     = 400 + count.index + 1 # 401, 402, 403
  node_name = var.proxmox_node_names[count.index % length(var.proxmox_node_names)]

  clone {
    vm_id = var.template_vm_ids[var.proxmox_node_names[count.index % length(var.proxmox_node_names)]]
    full  = true
  }

  scsi_hardware = "virtio-scsi-single"

  cpu {
    cores = 2
  }

  memory {
    dedicated = 3072
  }

  on_boot = true

  agent {
    enabled = true
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 25
  }

  network_device {
    bridge = "vmbr0"
  }

  # Logika IP Statis Berdasarkan Node Penempatan (pve1 = 192.168.2.6x, pve2/3 = 192.168.3.6x)
  # Menggunakan pembeda 6x agar IP Worker tidak bertabrakan dengan Control Plane
  initialization {
    datastore_id = "local-lvm"

    user_account {
      username = "ubuntu"
      keys     = [var.ssh_public_key]
    }

    ip_config {
      ipv4 {
	address = "dhcp"
      }
    }
  }

}
