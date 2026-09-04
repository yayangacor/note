# ==============================================================================
#  6 VM Kubernetes: 3 control plane + 3 worker, disebar merata ke 3 node Proxmox.
#
#  Perubahan penting dari versi sebelumnya:
#    - IP STATIS, bukan DHCP. Case mewajibkannya, dan Ansible butuh IP yang
#      tidak berubah setiap VM reboot.
#    - Cloud-init hanya berisi username + SSH key (case: "cloud-init drive
#      dengan nilai kosong"). Tidak ada password yang ditanam.
# ==============================================================================

locals {
  # Node Proxmox untuk VM ke-i, berputar merata: pve1, pve2, pve3, pve1, ...
  cp_nodes     = [for i in range(length(var.control_plane_ips)) : var.proxmox_node_names[i % length(var.proxmox_node_names)]]
  worker_nodes = [for i in range(length(var.worker_ips)) : var.proxmox_node_names[i % length(var.proxmox_node_names)]]
}

resource "proxmox_virtual_environment_vm" "control_plane" {
  count     = length(var.control_plane_ips)
  name      = format("k8s-cp-%02d", count.index + 1)
  vm_id     = 301 + count.index
  node_name = local.cp_nodes[count.index]
  on_boot   = true

  clone {
    vm_id = var.template_vm_ids[local.cp_nodes[count.index]]
    full  = true
  }

  agent { enabled = true }

  cpu {
    cores = var.control_plane_spec.cores
    type  = "host" # tanpa ini performa VM turun jauh
  }

  memory {
    dedicated = var.control_plane_spec.memory
  }

  scsi_hardware = "virtio-scsi-single"

  disk {
    datastore_id = var.vm_datastore
    interface    = "scsi0"
    size         = var.control_plane_spec.disk
    iothread     = true
  }

  network_device {
    bridge = var.network_bridge
  }

  initialization {
    datastore_id = var.vm_datastore

    user_account {
      username = var.vm_username
      keys     = [var.ssh_public_key]
    }

    ip_config {
      ipv4 {
        address = "${var.control_plane_ips[count.index]}/${var.network_cidr_bits}"
        gateway = var.network_gateway
      }
    }

    dns {
      servers = var.dns_servers
    }
  }
}

resource "proxmox_virtual_environment_vm" "worker" {
  count     = length(var.worker_ips)
  name      = format("k8s-worker-%02d", count.index + 1)
  vm_id     = 401 + count.index
  node_name = local.worker_nodes[count.index]
  on_boot   = true

  clone {
    vm_id = var.template_vm_ids[local.worker_nodes[count.index]]
    full  = true
  }

  agent { enabled = true }

  cpu {
    cores = var.worker_spec.cores
    type  = "host"
  }

  memory {
    dedicated = var.worker_spec.memory
  }

  scsi_hardware = "virtio-scsi-single"

  disk {
    datastore_id = var.vm_datastore
    interface    = "scsi0"
    size         = var.worker_spec.disk
    iothread     = true
  }

  network_device {
    bridge = var.network_bridge
  }

  initialization {
    datastore_id = var.vm_datastore

    user_account {
      username = var.vm_username
      keys     = [var.ssh_public_key]
    }

    ip_config {
      ipv4 {
        address = "${var.worker_ips[count.index]}/${var.network_cidr_bits}"
        gateway = var.network_gateway
      }
    }

    dns {
      servers = var.dns_servers
    }
  }
}
