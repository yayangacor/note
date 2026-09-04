# P04 — HAProxy + keepalived, lalu kubeadm init HA

**Status:** 📝 kode lengkap, **nol perintah dijalankan** · **Dependency:** P03 · **Blokir:** [[Q-02]] (VIP) · ~~role LB belum ada; role control plane cacat~~ → keduanya **sudah ada sejak 09-03**: `load_balancer` memverifikasi VIP lewat `wait_for`, `k8s_control_plane` dijaga agar init hanya di `control_plane[0]` dan menolak jalan kalau VIP belum hidup ([[G-12]]). **09-04:** `k8s_join` sekarang membuktikan node terdaftar & `Ready` dan menegakkan ≥3 CP / ≥3 worker ([[D-25]])

Ini plan paling berisiko: keputusan di sini **tertanam di sertifikat cluster** dan tidak bisa
diubah tanpa reset ([[D-03]]).

## Urutan yang tidak boleh dibalik

```
load_balancer (VIP hidup)  →  kubeadm init CP-1  →  CNI  →  join CP-2, CP-3  →  join worker
```

## Bagian 1 — Load balancer

Role baru `load_balancer`, target grup `[loadbalancer]` (cp-01 + cp-02, **wajib satu subnet** → [[G-02]]).

- `apt`: `haproxy`, `keepalived`, `psmisc`.
- sysctl `net.ipv4.ip_nonlocal_bind=1` — tanpa ini HAProxy tidak bisa bind ke VIP yang belum
  dimiliki node.
- `haproxy.cfg`: mode tcp, `frontend bind *:8443` ([[G-01]] — **bukan** 6443), backend ke `:6443`
  ketiga control plane, `option tcp-check`, plus `listen stats bind *:8404`.
  Pakai `validate: haproxy -c -f %s` di modul template supaya config rusak ditolak sebelum ditulis.
- `keepalived.conf`: `vrrp_script check_haproxy` (`killall -0 haproxy`, weight 2),
  `virtual_router_id` unik di jaringan (kalau tim lain memakai VRRP juga, angka yang sama membuat
  dua cluster saling merebut VIP), `state`/`priority` dari variabel inventory.

## Bagian 2 — kubeadm init (perbaiki role yang ada)

Role `k8s_control_plane` sekarang **salah dan berbahaya** ([[G-12]]): tidak ada
`--control-plane-endpoint`, tidak ada `--upload-certs`, dan play-nya menargetkan ketiga host
sehingga ketiganya akan meng-init cluster sendiri-sendiri.

Perbaikan:

1. Guard: `stat /etc/kubernetes/admin.conf` → skip kalau sudah ada (idempotensi).
2. `wait_for` VIP:8443 dan **gagalkan play** kalau belum hidup — jangan biarkan init jalan dengan
   endpoint mati.
3. Init hanya di `groups['control_plane'][0]`:
   ```
   kubeadm init \
     --control-plane-endpoint <VIP>:8443 \
     --upload-certs \
     --pod-network-cidr=10.244.0.0/16 \
     --apiserver-advertise-address <ip node ini> \
     --apiserver-bind-port 6443 \
     --skip-phases=addon/kube-proxy      # hanya kalau Cilium menggantikan kube-proxy
   ```
4. Ambil `kubeadm token create --print-join-command` dan
   `kubeadm init phase upload-certs --upload-certs` → simpan sebagai fact.
5. Join CP lain: join command + `--control-plane --certificate-key <key> --apiserver-advertise-address <ip>`.
   Join worker: join command apa adanya. Keduanya di-guard `stat /etc/kubernetes/kubelet.conf`.
6. Salin `admin.conf` ke `~/.kube/config` user di semua control plane, dan ke VM operator.

**Catatan penting:** kalau `--skip-phases=addon/kube-proxy` dipakai, cluster belum punya jaringan
sampai Cilium terpasang (P05) — node akan `NotReady` dan CoreDNS `Pending`. Itu **normal**,
bukan kegagalan; jangan mendiagnosis ke arah lain.

## Definition of Done

- [ ] `ip a | grep <VIP>` muncul di node MASTER, tidak muncul di BACKUP.
- [ ] `curl -k https://<VIP>:8443/healthz` → `ok` (dari node lain, bukan dari MASTER sendiri).
- [ ] `kubectl get nodes` menampilkan 6 node.
- [ ] `kubectl -n kube-system get pods` → etcd 3 anggota, apiserver 3 replika.
- [ ] Kubeconfig menunjuk `https://<VIP>:8443` — bukan IP node.
- [ ] **Kontrol negatif failover ([[B3]]):** matikan haproxy di MASTER
      (`systemctl stop haproxy`) → VIP pindah ke BACKUP dalam beberapa detik dan
      `kubectl get nodes` dari VM operator **tetap menjawab**. Hidupkan lagi, VIP kembali.
      Tanpa uji ini, "HA" hanya konfigurasi yang tersimpan.
- [ ] **Kontrol negatif node down:** `qm stop` satu control plane → cluster tetap melayani
      (quorum etcd 2/3).

## Hasil eksekusi

_(kosong)_
