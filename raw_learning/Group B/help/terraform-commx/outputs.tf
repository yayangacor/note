# ==============================================================================
# HELPER UNTUK MENGHITUNG IP STATIS SECARA PASTI (SAMA DENGAN RUMUS DI MAIN.TF)
# ==============================================================================
locals {
  # Menghitung IP Control Plane: pve1 = .2.5x, pve2/3 = .3.5x
  cp_ips = [
    for index, name in var.proxmox_node_names : 
    name == "pve1" ? "192.168.2.5${index + 1}" : "192.168.3.5${index + 1}"
  ]

  # Menghitung IP Worker Node: pve1 = .2.6x, pve2/3 = .3.6x
  worker_ips = [
    for index, name in var.proxmox_node_names : 
    name == "pve1" ? "192.168.2.6${index + 1}" : "192.168.3.6${index + 1}"
  ]
}

# ==============================================================================
# OTOMATIS MEMBUAT FILE HOSTS.INI UNTUK ANSIBLE (MENGAMBIL IP ASLI DARI BPG AGENT)
# ==============================================================================
resource "local_file" "ansible_inventory" {
  filename = "../ansible/hosts.ini" # Lokasi folder project Ansible Anda
  content  = <<EOT
[control_plane]
%{ for vm in proxmox_virtual_environment_vm.k8s_control_planes ~}
${length(vm.ipv4_addresses) > 1 ? vm.ipv4_addresses[1][0] : vm.ipv4_addresses[0][0]} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_ed25519
%{ endfor ~}

[workers]
%{ for vm in proxmox_virtual_environment_vm.k8s_workers ~}
${length(vm.ipv4_addresses) > 1 ? vm.ipv4_addresses[1][0] : vm.ipv4_addresses[0][0]} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_ed25519
%{ endfor ~}

[k8s_cluster:children]
control_plane
workers
EOT
}

# ==============================================================================
# OUTPUT UNTUK DITAMPILKAN DI TERMINAL SAAT TERRAFORM SELESAI
# ==============================================================================
output "control_plane_actual_ips" {
  value       = [for vm in proxmox_virtual_environment_vm.k8s_control_planes : length(vm.ipv4_addresses) > 1 ? vm.ipv4_addresses[1][0] : vm.ipv4_addresses[0][0]]
  description = "Daftar IP asli Control Plane yang dilaporkan oleh QEMU Guest Agent BPG"
}

output "worker_actual_ips" {
  value       = [for vm in proxmox_virtual_environment_vm.k8s_workers : length(vm.ipv4_addresses) > 1 ? vm.ipv4_addresses[1][0] : vm.ipv4_addresses[0][0]]
  description = "Daftar IP asli Worker Node yang dilaporkan oleh QEMU Guest Agent BPG"
}
