# ==============================================================================
#  Menulis inventory Ansible LENGKAP.
#
#  Dua perbaikan penting:
#    1. IP diambil dari variabel IP statis, bukan dari laporan QEMU guest agent.
#       Guest agent bisa belum siap saat VM baru boot dan membuat apply gagal
#       di tengah jalan.
#    2. Grup [loadbalancer], [speaker], [cicd], dan [operator] ikut ditulis.
#       Kalau grup ini hanya ditambahkan manual, ia hilang setiap
#       `terraform apply` -- dan play yang menargetkannya akan di-skip
#       diam-diam dengan rc 0 (G-13).
# ==============================================================================

locals {
  cp_names     = [for i in range(length(var.control_plane_ips)) : format("k8s-cp-%02d", i + 1)]
  worker_names = [for i in range(length(var.worker_ips)) : format("k8s-worker-%02d", i + 1)]

  # Node yang boleh jadi MetalLB speaker: hanya yang sesubnet dengan pool,
  # karena ARP tidak melewati router (G-03). Rumus di bawah memakai tiga oktet
  # pertama gateway sebagai penanda subnet.
  subnet_prefix = join(".", slice(split(".", var.network_gateway), 0, 3))
  speaker_nodes = concat(
    [for i, ip in var.control_plane_ips : local.cp_names[i] if startswith(ip, "${local.subnet_prefix}.")],
    [for i, ip in var.worker_ips : local.worker_names[i] if startswith(ip, "${local.subnet_prefix}.")],
  )

  # keepalived butuh minimal 2 node SESUBNET. Diambil dari control plane
  # yang lolos filter subnet di atas.
  lb_candidates = [for i, ip in var.control_plane_ips : local.cp_names[i] if startswith(ip, "${local.subnet_prefix}.")]
}

resource "local_file" "ansible_inventory" {
  filename        = "../ansible/inventory/hosts.ini"
  file_permission = "0644"
  content         = <<-EOT
    # DI-GENERATE TERRAFORM -- jangan diedit manual, perubahannya akan hilang.
    # Sumber angka: terraform-commx/variables.tf

    [control_plane]
    %{~for i, name in local.cp_names~}
    ${name} ansible_host=${var.control_plane_ips[i]}
    %{~endfor~}

    [workers]
    %{~for i, name in local.worker_names~}
    ${name} ansible_host=${var.worker_ips[i]}
    %{~endfor~}

    # HAProxy + keepalived. VRRP protokol Layer 2: kedua node WAJIB satu subnet.
    [loadbalancer]
    %{~for i, name in slice(local.lb_candidates, 0, min(2, length(local.lb_candidates)))~}
    ${name} keepalived_state=${i == 0 ? "MASTER" : "BACKUP"} keepalived_priority=${110 - i * 10}
    %{~endfor~}

    # Kandidat MetalLB speaker: hanya node sesubnet dengan pool.
    [speaker]
    %{~for name in local.speaker_nodes~}
    ${name}
    %{~endfor~}

    [cicd]
    cicd-01 ansible_host=${var.cicd_host_ip}

    [operator]
    cicd-01 ansible_host=${var.cicd_host_ip}

    [k8s_cluster:children]
    control_plane
    workers

    [all:vars]
    ansible_user=${var.vm_username}
    ansible_ssh_private_key_file=~/.ssh/id_ed25519
  EOT
}

output "control_plane_ips" {
  value       = var.control_plane_ips
  description = "IP statis control plane -- salin ke tabel alokasi IP di dokumentasi"
}

output "worker_ips" {
  value       = var.worker_ips
  description = "IP statis worker -- salin ke tabel alokasi IP di dokumentasi"
}

output "loadbalancer_nodes" {
  value       = slice(local.lb_candidates, 0, min(2, length(local.lb_candidates)))
  description = "Node yang menjalankan HAProxy + keepalived (wajib >= 2 dan sesubnet)"
}

output "metallb_speaker_nodes" {
  value       = local.speaker_nodes
  description = "Node yang boleh mengumumkan IP MetalLB lewat ARP"
}
