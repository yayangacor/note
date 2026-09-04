# P03 — Ansible core system (semua node)

**Status:** 📝 kode lengkap (role `common`, `containerd`, `k8s_base`), **nol perintah dijalankan** · **Dependency:** P02 · **Catatan 09-04:** `skip_verify` dibuang dari cabang registry HTTP ([[G-24]]), dan cabang TLS kini benar-benar menyalin `ca.crt` dari VM CI/CD ([[D-22]]) — sebelumnya menunjuk file yang tak pernah dibuat

Kode: `Group B/ComMX-Forgejo/ansible/roles/{common,containerd,k8s_base,security}`

## Yang sudah benar

- Modul kernel `overlay`+`br_netfilter`, sysctl trio Kubernetes, swap dimatikan (runtime + fstab).
- containerd + `SystemdCgroup = true` + handler restart.
- Repo Kubernetes pakai keyring modern, versi di-`hold`.
- Role `security` meng-assert tidak ada `.env`/`tfstate`/`tfvars`/private key yang ter-track, dan
  meng-grep kredensial case yang dilarang. **Ini kontrol negatif yang bagus — pertahankan.**

## Yang kurang (dibanding kebutuhan P04–P07)

1. **Paket prasyarat Longhorn belum ada:** `open-iscsi`, `nfs-common`, dan service `iscsid`
   enabled. Kalau ini terlewat, Longhorn di P05 gagal dengan gejala volume `attaching` selamanya.
2. **`qemu-guest-agent`** belum dipasang → Proxmox tidak bisa melaporkan IP VM, dan output
   Terraform yang mengandalkan guest agent kosong.
3. **Trust ke private registry belum ada.** containerd butuh `config_path = "/etc/containerd/certs.d"`
   di `config.toml` **dan** file `/etc/containerd/certs.d/<host>:5000/hosts.toml`. Tanpa ini semua
   image dari registry lokal gagal pull dengan `x509` atau `http: server gave HTTP response to
   HTTPS client` — gejala yang mudah disalahartikan sebagai salah kredensial.
   Registry Group A memakai TLS (ada `domain.crt`); registry kita di dokumen masih `insecure`.
   Pilih satu dan konsisten di semua node:
   - insecure: `server = "http://<host>:5000"` + `skip_verify = true`
   - TLS: salin `ca.crt` ke `/etc/containerd/certs.d/<host>:5000/ca.crt`
4. **`/etc/hosts`** belum diisi daftar node + VIP. Berguna saat DNS belum siap.
5. **Hostname** belum diseragamkan (`k8s-cp-01` dst). Nama node Kubernetes ikut hostname, dan
   label MetalLB di P05 memakai `kubernetes.io/hostname` — jadi ini harus ditetapkan **sebelum**
   `kubeadm init`, karena mengubah hostname sesudahnya berarti node baru.

## Langkah

1. Tambahkan tugas-tugas di atas ke role `common` / `containerd`.
2. Jalankan bertahap: `ansible-playbook site.yml --tags core --limit <satu host>` dulu, baru semua.
3. Jalankan **dua kali** untuk membuktikan idempotensi.

## Definition of Done

- [ ] `ansible-playbook -i ansible/hosts.ini ansible/site.yml --tags core` selesai untuk 6 host,
      `failed=0`.
- [ ] Jalankan ulang → `changed=0` di semua host (bukti idempotensi; requirement eksplisit case).
- [ ] Di satu node: `systemctl is-active containerd iscsid` → `active` keduanya.
- [ ] `swapon --show` kosong; `sysctl net.ipv4.ip_forward` = 1.
- [ ] `kubeadm version` menampilkan versi yang diinginkan di semua node.
- [ ] **Bukti trust registry (B1 — bukan sekadar file ada):**
      `sudo ctr -n k8s.io images pull <registry>/<image>:<tag>` berhasil dari node worker.
      Ini menguji jalur yang sebenarnya dipakai kubelet, bukan `docker pull`.

## Hasil eksekusi

_(kosong)_
