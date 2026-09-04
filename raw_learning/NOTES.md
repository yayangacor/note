# NOTES — Ledger (append-only)

Aturan: satu entri = satu fakta ber-ID. Tidak pernah dihapus; kalau salah, ubah status
jadi `❌ DIBANTAH oleh [[G-xx]]`. Setiap append **wajib** memperbarui tabel indeks.

**Status yang dipakai:**
`✅ TERVERIFIKASI` = kita sendiri yang mengukur di lingkungan kita.
`⚠️ SEBAGIAN` = berasal dari artefak Group A / pembacaan kode, **belum kami ukur**.
`❌ DIBANTAH` = terbukti salah.

> Peringatan yang paling gampang dilanggar di sesi berikutnya: hampir semua entri di
> bawah masih `⚠️`. Kode Group A adalah bukti bahwa **mereka** melakukan sesuatu, bukan
> bukti bahwa hal itu jalan **di lingkungan kita**. Naikkan ke `✅` hanya dengan output mentah.

---

## Indeks (cari lewat GEJALA, bukan nama fitur)

| ID | Gejala / pertanyaan yang membawamu ke sini | Status | Tgl |
|---|---|---|---|
| G-01 | haproxy gagal start, "address already in use" di control plane | ⚠️ | 09-03 |
| G-02 | VIP keepalived tidak pernah pindah / dua node sama-sama MASTER | ⚠️ | 09-03 |
| G-03 | Service LoadBalancer dapat IP tapi tidak bisa di-ping dari PC lain | ⚠️ | 09-03 |
| G-04 | Frontend jalan tapi tetap connect ke ws://localhost, bukan wss:// | ⚠️ · kode diperbaiki 09-03 | 09-03 |
| G-05 | Backend CrashLoop: Cannot find module '/app/dist/main.js' | ✅ TERUKUR · kode diperbaiki 09-04 | 09-04 |
| G-06 | Buka https://ComMX.local.com/ dapat 404, padahal pod frontend Running | ⚠️ | 09-03 |
| G-07 | Instalasi Longhorn/monitoring ditolak admission webhook sesudah Kyverno dipasang | ⚠️ | 09-03 |
| G-08 | kubectl apply -k k8s/ bilang tidak menemukan kustomization | ⚠️ · kode diperbaiki 09-03 | 09-03 |
| G-09 | Terraform provider Proxmox 401, atau template tidak ketemu di node kedua | ⚠️ | 09-03 |
| G-10 | Pod redis CrashLoop "Permission denied" di /data sesudah pakai PVC | ⚠️ | 09-03 |
| G-11 | Backend Running tapi Service tidak punya endpoint sehat / port aneh | ⚠️ · kode diperbaiki 09-03 | 09-03 |
| G-12 | Mau menambah control plane ke-2, join ditolak / cert tidak memuat VIP | ⚠️ · kode diperbaiki 09-03 | 09-03 |
| G-13 | Playbook hijau semua tapi Forgejo tidak pernah terpasang | ⚠️ | 09-03 |
| G-14 | Job migrasi DB gagal, drizzle-kit: not found | ⚠️ | 09-03 |
| G-15 | Tool Bash gagal `unexpected EOF` saat menulis file panjang lewat heredoc | ✅ | 09-04 |
| G-16 | Pod backend CrashLoop tanpa log aplikasi; error di drizzle `params[0] is undefined` | ✅ TERUKUR | 09-04 |
| G-17 | `docker run ... ls /app/dist` bilang `C:/Program Files/Git/app/dist` tidak ada | ✅ TERUKUR | 09-04 |
| G-18 | `--tags cicd` mati di play pertama; error soal git / "hardcoded credentials" | ✅ TERUKUR · kode diperbaiki 09-04 | 09-04 |
| G-19 | Mau jalankan ansible tapi `ansible-playbook` tidak ada di mesin ini | ✅ TERUKUR | 09-04 |
| G-20 | GatewayClass stuck `ACCEPTED: Unknown`, log Cilium sebut `tlsroutes` CRD hilang | ⚠️ (diukur Group A) · kode diperbaiki 09-04 | 09-04 |
| G-21 | Gateway tidak dapat ADDRESS; event `Unable to create Service ... blocked by Kyverno` | ⚠️ (diukur Group A) · kode diperbaiki 09-04 | 09-04 |
| G-22 | Login sukses tapi chat gagal konek; socket ditolak walau URL sudah benar | ⚠️ (diukur Group A) · **DITUTUP** kode 09-04 [[D-21]] | 09-04 |
| G-23 | Pipeline CI gagal di runner: docker not found / disk penuh / Trivy no space | ⚠️ (diukur Group A) | 09-04 |
| G-24 | `skip_verify` di hosts.toml http:// — no-op, dan buggy di containerd 2.2.1 | ⚠️ · kode dibersihkan 09-04 | 09-04 |
| G-25 | `docker: command not found` di langkah pertama pipeline | ⚠️ · kode diperbaiki 09-04 | 09-04 |
| G-26 | Proxmox terpasang normal tapi `qm start` selalu gagal "KVM not available" | ⚠️ BELUM DIUKUR DI LAB | 09-04 |

| ID | Keputusan | Tgl |
|---|---|---|
| D-01 | Group A dipakai sebagai referensi pola, bukan sumber salin-tempel | 09-03 |
| D-02 | HAProxy + keepalived menumpang di control plane, frontend 8443 | 09-03 |
| D-03 | kubeadm init wajib --control-plane-endpoint VIP:8443 sejak init pertama | 09-03 |
| D-04 | Cilium menggantikan kube-proxy, diarahkan ke VIP, gatewayAPI aktif | 09-03 |
| D-05 | MetalLB L2, speaker dibatasi lewat label node | 09-03 |
| D-06 | Longhorn sebagai CSI, jadi default StorageClass | 09-03 |
| D-07 | Expose lewat Gateway API (GatewayClass cilium), bukan Ingress | 09-03 |
| D-08 | Forgejo + registry di VM DI LUAR cluster | 09-03 |
| D-09 | Kyverno dipasang paling akhir, policy meng-exclude namespace sistem | 09-03 |
| D-10 | Urutan bootstrap dikunci, dijalankan bertahap dengan --tags | 09-03 |
| D-11 | Kredensial lewat ansible-vault + file *.example, tidak pernah di-commit | 09-03 |
| D-12 | Strategi deployment RollingUpdate maxUnavailable 0 (justifikasi tertulis) | 09-03 |
| D-13 | Build image lewat SSH ke PC, bukan runner container | 09-03 |
| D-14 | basePath /frontend dipertahankan, root di-redirect lewat HTTPRoute | 09-03 |
| D-15 | Angka jaringan hidup di satu file per lapisan | 09-03 |
| D-16 | Application ArgoCD di-apply role Ansible; manifest jadi cadangan manual | 09-04 |
| D-17 | Satu token Forgejo (write) untuk CI + ArgoCD, ditempel di dua tempat | 09-04 |
| D-18 | Secret aplikasi & TLS dibuat role argocd dari vault, bukan langkah manual | 09-04 |
| D-19 | metrics-server jadi role sendiri; Prometheus tidak memberi makan HPA | 09-04 |
| D-20 | Migrasi DB lewat Job psql (PreSync hook), bukan drizzle-kit | 09-04 |
| D-21 | Domain diturunkan ke huruf kecil semua (deviasi ejaan dari case) | 09-04 |
| D-22 | Jalur TLS registry dilengkapi; default tetap HTTP polos | 09-04 |
| D-23 | Gerbang statis manifest `scripts/validate-manifests.py`, kontrol negatif di dalamnya | 09-04 |
| D-24 | Render semua template Ansible di laptop; tiruan filter Ansible wajib (B4) | 09-04 |
| D-25 | `k8s_join` membuktikan node terdaftar & Ready, bukan berhenti di rc 0 | 09-04 |

| ID | Aturan kerja | Tgl |
|---|---|---|
| R-01 | Salin polanya, jangan salin angkanya (IP/user/grup Group A) | 09-03 |
| R-02 | Bukti = klien menerima hasil, bukan manifest ter-apply | 09-03 |
| R-03 | Cek tag & label sebelum apply — Kyverno menolak, dan gejalanya menyamar | 09-03 |

| ID | Pertanyaan terbuka | Status |
|---|---|---|
| Q-01 | Nomor grup kita untuk kredensial Proxmox/registry | ✅ TERJAWAB 09-03: **kita = Group-1**, Group A = Group-2 |
| Q-02 | Rentang IP yang boleh untuk VIP + pool MetalLB | menunggu user/Astdev |
| Q-03 | Jadwal backup Proxmox | ✅ TERJAWAB 09-04: **12:00 siang** |
| Q-04 | Email anggota + kredensial SMTP | ⚠️ SEBAGIAN 09-04: 1 email diketahui, App Password & email anggota lain belum |
| Q-05 | Apakah host Forgejo/registry tetap 192.168.1.197 | menunggu user |

---

## Keputusan (D)

### D-01 — Artefak Group A dipakai sebagai referensi pola, bukan sumber salin-tempel ✅ TERVERIFIKASI (2026-09-03, sesi 1)

**Masalah.** Group A lebih jauh, tapi artefaknya terpecah di 5 repo dari lingkungan yang
berbeda-beda (lihat tabel bentrok nilai di `refs/GROUPA-CODE-MAP.md`).
**Keputusan.** Ambil urutan, struktur role, dan flag perintahnya. Angka (IP, user, grup,
nama node) diambil dari lingkungan kita sendiri.
**Alasan.** Tiga repo mereka memakai tiga rentang IP berbeda dan dua nomor grup berbeda;
menyalin bulat-bulat menjamin bentrok.
**Konsekuensi.** Setiap file yang disalin dari mereka wajib lewat checklist [[R-01]].
**Terkait.** [[R-01]]

### D-02 — HAProxy + keepalived menumpang di control plane, frontend di 8443 ⚠️ SEBAGIAN (2026-09-03)

**Masalah.** Case minta load balancer + floating IP, tapi tidak ada sisa resource untuk 2 VM LB khusus.
**Keputusan.** HAProxy + keepalived jalan di cp-01 (MASTER, priority 110) dan cp-02
(BACKUP, priority 100). Frontend HAProxy bind `*:8443`, backend ke `:6443` semua control plane.
**Alasan.** Hemat RAM (24 GB per PC sudah ketat), dan Group A menempuh jalur yang sama.
**Konsekuensi.** Port frontend TIDAK BOLEH 6443 → [[G-01]]. Kedua node LB wajib satu subnet → [[G-02]].
**Sumber.** `K2Help/FinalAnsible/roles/load_balancer/` + `inventory/hosts.ini`.
**Terkait.** [[G-01]] [[G-02]] [[D-03]]

### D-03 — kubeadm init memakai --control-plane-endpoint VIP:8443 sejak init pertama ⚠️ SEBAGIAN (2026-09-03)

**Masalah.** HA butuh 3 control plane; endpoint harus stabil.
**Keputusan.** `kubeadm init --control-plane-endpoint <VIP>:8443 --upload-certs
--pod-network-cidr=<cidr> --apiserver-advertise-address <ip node> --apiserver-bind-port 6443`
(+ `--skip-phases=addon/kube-proxy` karena Cilium menggantikan kube-proxy).
**Alasan.** VIP tertanam di sertifikat cluster saat init. Mengubahnya sesudah init = reset cluster.
**Konsekuensi.** VIP **wajib sudah hidup** sebelum init → role load_balancer dijalankan lebih dulu,
dan init didahului `wait_for` ke VIP:8443 yang menggagalkan play kalau VIP belum ada.
**Sumber.** `roles/cluster/tasks/init.yml` + `group_vars/all/vars.yml` Group A.
**Terkait.** [[D-02]] [[G-12]]

### D-04 — Cilium sebagai CNI, menggantikan kube-proxy, diarahkan ke VIP ⚠️ SEBAGIAN (2026-09-03)

**Keputusan.** Helm chart cilium dengan values: `ipam.mode=kubernetes`, `k8sServiceHost=<VIP>`,
`k8sServicePort=8443`, `kubeProxyReplacement=true`, `operator.replicas=2`, `gatewayAPI.enabled=true`.
**Alasan.** CNI Cilium wajib menurut case. `gatewayAPI.enabled` diperlukan supaya GatewayClass
`cilium` muncul — syarat [[D-07]].
**Konsekuensi.** Kalau `kubeProxyReplacement=true`, `kubeadm init` harus `--skip-phases=addon/kube-proxy`.
CRD Gateway API harus terpasang sebelum Cilium dinyalakan dengan gatewayAPI aktif.
**Bukti dari cluster hidup Group A.** `Enjoy/backup-tpa/cilium-values.yaml` berisi persis values
di atas dengan `k8sServiceHost: 192.168.3.100`, `k8sServicePort: 8443` — dua artefak independen
(kubeconfig + values) sepakat soal 8443.
**Terkait.** [[D-03]] [[D-07]] [[G-01]]

### D-05 — MetalLB mode L2, speaker dibatasi lewat label node ⚠️ SEBAGIAN (2026-09-03)

**Keputusan.** Pasang MetalLB via Helm; `IPAddressPool` + `L2Advertisement` dengan `nodeSelectors`
ke label `metallb-speaker: "true"`, dan label itu hanya dipasang di node yang sesubnet dengan pool.
**Alasan.** Cluster kita lintas subnet (node ada di 2.x dan 3.x). ARP tidak melewati router → [[G-03]].
**Konsekuensi.** Pool MetalLB wajib di luar DHCP pool MikroTik dan sesubnet dengan node speaker.
Butuh jawaban [[Q-02]].
**Terkait.** [[G-03]] [[Q-02]]

### D-06 — Longhorn sebagai CSI dan default StorageClass ⚠️ SEBAGIAN (2026-09-03)

**Keputusan.** Helm longhorn dengan `persistence.defaultClass=true`, `defaultClassReplicaCount=2`.
Prasyarat `open-iscsi` + `nfs-common` + service `iscsid` dipasang lebih dulu di role core_system.
**Alasan.** Case membebaskan pilihan CSI. Longhorn paling ringan disiapkan lewat Helm, dan
replica 2 cukup untuk 6 node tanpa memberatkan disk.
**Konsekuensi.** PVC tanpa `storageClassName` ikut default. Tapi StatefulSet yang menulis eksplisit
`storageClassName: longhorn` akan Pending selamanya kalau Longhorn belum terpasang.
**Terkait.** [[G-10]]

### D-07 — Expose lewat Gateway API (gatewayClassName cilium), bukan Ingress ⚠️ SEBAGIAN (2026-09-03)

**Keputusan.** `Gateway` dengan listener HTTP:80 + HTTPS:443 (`mode: Terminate`, `certificateRefs`
ke Secret TLS), lalu `HTTPRoute` memisahkan `/api` → backend, `/socket.io` → backend, `/` → frontend.
**Alasan.** Case menyebut Gateway API + MetalLB secara eksplisit. Annotation `nginx.ingress.*`
tidak berlaku di GatewayClass cilium — annotation itu hanya dibaca oleh ingress-nginx, jadi
Ingress kita yang sekarang praktis tidak melakukan apa pun yang tertulis di annotation-nya.
**Konsekuensi.** WSS jalan lewat listener HTTPS yang sama; tidak perlu annotation websocket.
Path `/api` di-rewrite `ReplacePrefixMatch: /` karena backend NestJS tidak punya global prefix.
**Sumber.** `ComMX-main/k8s/gateway/*.yaml`.
**Terkait.** [[G-06]] [[D-04]]

### D-08 — Forgejo + private registry di VM DI LUAR cluster ⚠️ SEBAGIAN (2026-09-03)

**Keputusan.** Satu VM Ubuntu terpisah menjalankan `forgejo` + `registry:2` + `forgejo-runner`
lewat Docker Compose di `/opt/cicd`.
**Alasan.** Kalau cluster di-reset — dan pada case ini itu sangat mungkin — sumber kebenaran dan
image tetap selamat. Runner juga butuh akses `docker.sock`, merepotkan kalau di dalam cluster.
**Konsekuensi.** Node cluster harus mempercayai registry lewat
`/etc/containerd/certs.d/<host>/hosts.toml`, dan `imagePullSecrets` wajib ada di namespace aplikasi.
**Sumber.** `K2Help/roles/forgejo_host/` (forgejo 9.0.3, registry 2.8.3, runner 6.3.1).
**Terkait.** [[G-13]]

### D-09 — Kyverno dipasang PALING AKHIR, policy meng-exclude namespace sistem ⚠️ SEBAGIAN (2026-09-03)

**Keputusan.** Kyverno di urutan terakhir; ketiga ClusterPolicy (`disallow-latest-tag`,
`disallow-default-namespace`, `require-labels`) meng-exclude
`kube-system, kyverno, longhorn-system, metallb-system, monitoring, argocd`.
**Alasan.** Banyak chart pihak ketiga memakai tag `latest` atau tidak punya label wajib.
**Konsekuensi.** Manifest kita sendiri wajib punya `app`, `owner`, `app.kubernetes.io/name`
dan tag versi eksplisit → [[R-03]].
**Terkait.** [[G-07]] [[R-03]]

### D-10 — Urutan bootstrap dikunci dan dijalankan bertahap ⚠️ SEBAGIAN (2026-09-03)

**Keputusan.** `forgejo → core → lb → cluster → metallb → storage → monitoring → argocd → kyverno`,
dijalankan per tahap dengan `ansible-playbook site.yml --tags <tahap>`, bukan sekaligus.
**Alasan.** Tiap tahap punya prasyarat keras (VIP sebelum init, MetalLB sebelum Service
LoadBalancer, Longhorn sebelum PVC monitoring). Menjalankan sekaligus di PC 24 GB juga berisiko
VM mati di tengah — case memang mengizinkan Ansible tidak dijalankan penuh setiap saat.
**Konsekuensi.** Tiap tahap wajib punya bukti sendiri sebelum lanjut ke tahap berikutnya.
**Terkait.** [[D-03]] [[D-05]] [[D-06]] [[D-09]]

### D-11 — Kredensial lewat ansible-vault + file *.example, tidak pernah masuk repo ⚠️ SEBAGIAN (2026-09-03)

**Keputusan.** `group_vars/all/vault.yml` (terenkripsi) untuk grafana/keepalived/registry/SMTP;
`k8s/config/secret.example.yaml` di-commit sementara `secret.yaml` tidak; Terraform lewat
`TF_VAR_*` environment variable.
**Alasan.** Case melarang push `.env` dan kredensial apa pun.
**Konsekuensi.** `.gitignore` wajib menutup `*.tfvars`, `terraform.tfstate*`, `secret.yaml`, `.env`.
Role `security` milik kita sudah meng-assert ini — itu kontrol negatif yang bagus, pertahankan.
**Catatan.** `k8s/postgres.yaml` kita sekarang masih memuat password database sebagai literal
di manifest. Itu melanggar keputusan ini dan harus pindah ke Secret.

### D-12 — Strategi deployment: RollingUpdate maxSurge 1, maxUnavailable 0 ⚠️ SEBAGIAN (2026-09-03)

**Keputusan.** Backend & frontend memakai RollingUpdate dengan `maxUnavailable: 0`, `maxSurge: 1`.
**Alasan — ini yang diminta case sebagai justifikasi tertulis.** Aplikasi memegang koneksi
WebSocket persisten. `Recreate` memutus semua sesi sekaligus. Blue/green dan canary butuh kapasitas
ganda atau traffic-splitting — mahal di PC 24 GB dan menambah komponen yang harus dijaga.
`maxUnavailable: 0` menjamin jumlah replika siap tidak pernah turun selama rollout; dan karena
state sesi Socket.IO dipegang bersama lewat **Redis adapter**, klien yang terputus dari pod lama
bisa reconnect ke pod baru tanpa kehilangan room. Jadi RollingUpdate adalah strategi termurah yang
tetap zero-downtime untuk beban kerja ini.
**Konsekuensi.** Selama rollout jumlah pod naik 1 di atas replika — sisakan headroom RAM.
**Terkait.** [[G-11]]

### D-13 — Build image lewat SSH ke PC, bukan di dalam runner container ⚠️ SEBAGIAN (2026-09-03)

**Masalah.** Runner Forgejo butuh akses `docker.sock` untuk membangun image. Di lab ini akses itu
tidak selalu stabil, dan kegagalannya muncul sebagai job yang menggantung tanpa pesan jelas.
**Keputusan.** Pipeline memakai `appleboy/ssh-action` ke PC yang sudah punya Docker, lalu
menjalankan build/scan/push di sana.
**Alasan.** Peluang berhasilnya jauh lebih tinggi dengan komponen yang lebih sedikit.
**Konsekuensi yang harus dibela saat penilaian, bukan disembunyikan:** menambah rahasia (SSH key)
dan membuat seluruh CI bergantung pada satu PC. Kalau PC itu mati, pipeline mati. Alternatifnya
(runner container dengan docker.sock ter-mount) lebih rapi tapi lebih rapuh di lingkungan ini.
**Terkait.** [[D-08]]

### D-14 — `basePath: "/frontend"` dipertahankan, root di-redirect di HTTPRoute ⚠️ SEBAGIAN (2026-09-03)

**Masalah.** `next.config.ts` menyetel `basePath: "/frontend"`, jadi `/` menghasilkan 404 [[G-06]].
**Keputusan.** Jangan sentuh kode aplikasi. HTTPRoute memetakan `/frontend` ke Service frontend,
dan `/` (Exact) di-redirect 302 ke `/frontend`. Readiness probe frontend juga menunjuk `/frontend`.
**Alasan.** Mengubah `next.config.ts` berarti menyentuh kode aplikasi milik developer dan
membangun ulang image; redirect di Gateway lebih murah dan bisa dibalik kapan saja.
**Konsekuensi.** URL yang dilihat pengguna jadi `https://ComMX.local.com/frontend`. Kalau saat
demo diminta root yang bersih, hapus `basePath`, rebuild image, lalu ganti rule redirect itu
menjadi `PathPrefix: /` → frontend. Keduanya sudah ditulis sebagai komentar di `httproute.yaml`.
**Terkait.** [[G-06]] [[D-07]]

### D-15 — Angka jaringan hidup di satu file per lapisan ✅ TERVERIFIKASI (2026-09-03)

**Masalah.** IP asli belum diketahui (menunggu cek MikroTik), tapi kode harus ditulis sekarang.
**Keputusan.** Tiga rumah tunggal: `terraform-commx/variables.tf` (IP VM, gateway, DNS),
`ansible/group_vars/all/vars.yml` (VIP, port, pool MetalLB, registry, versi),
`k8s/kustomization.yaml` (registry + tag). Inventory Ansible **di-generate Terraform**, tidak
pernah diedit manual. Semua placeholder ditandai `TODO(Q-02)`.
**Alasan.** Menyesuaikan IP nanti harus jadi kerja lima menit, bukan perburuan lintas 50 file.
**Bukti.** `grep -rn "TODO(Q-02)" "Group B/ComMX-Forgejo"` → 15 baris, semuanya terkumpul di
tiga file di atas plus inventory yang akan ditimpa Terraform.
**Konsekuensi.** Kalau ada yang menulis IP langsung di role atau manifest, itu regresi —
kembalikan ke variabel.
**Terkait.** [[Q-02]] [[R-01]]

### D-16 — Application ArgoCD di-apply oleh role Ansible, bukan oleh file manifest ✅ (2026-09-04)

**Masalah yang diperbaiki.** `roles/argocd` memasang ArgoCD lalu berhenti. `k8s/argocd/application.yaml`
ada tapi tidak pernah tersentuh siapa pun. Akibatnya ArgoCD berdiri, UI hijau, dan cluster kosong —
GitOps tidak pernah menyala, padahal "push → berubah sendiri tanpa perintah manual" adalah DoD.
Lubang yang sama diakui Group A tentang playbook mereka sendiri (`refs/UPSTREAM-EVIDENCE.md` §4).

**Keputusan.** Role `argocd` yang meng-apply Application, dan `repoURL` dirakit dari
`group_vars/all/vars.yml` (`cicd_host_ip` + `forgejo_repo_owner` + `forgejo_repo_name`).
`k8s/argocd/application.yaml` **diturunkan jadi cadangan jalur manual** dan diberi stempel di
kepalanya bahwa role akan menimpanya.

**Alasan.** Manifest itu memuat `repoURL: http://192.168.1.197:3000/...` — IP mentah, di file yang
bukan salah satu dari empat rumah angka jaringan di [[D-15]]. Membiarkannya berarti punya dua sumber
kebenaran, dan yang satu pasti membusuk begitu [[Q-05]] terjawab.

**Yang ikut ditambahkan, dan kenapa.**
1. **Secret kredensial repo** (`argocd.argoproj.io/secret-type: repository`) dari
   `forgejo_repo_user`/`forgejo_repo_token` di vault. Repo privat tanpa ini gagal fetch, dan
   ArgoCD melaporkannya sebagai `ComparisonError` yang **tidak menyebut autentikasi** — gejala
   yang gampang dikejar ke arah jaringan.
2. **Task peringatan** kalau token kosong. Sengaja bukan `when:` yang diam: skip diam-diam adalah
   pola [[G-13]] — hijau tanpa mengerjakan apa pun.
3. **Baca ulang + assert** (B2). Sesudah apply, Application dibaca dari apiserver dan
   `repoURL`, `destination.namespace`, serta `selfHeal` dicocokkan. `state: present` yang sukses
   bukan bukti nilainya tersimpan.
4. **Status sync hanya dilaporkan, tidak di-assert.** Sync butuh repo yang benar-benar bisa
   di-fetch, dan itu baru ada setelah kode di-push ke Forgejo. Menjadikannya gerbang akan
   menggagalkan playbook karena urutan kerja, bukan karena kesalahan.

**Konsekuensi yang harus dijaga.** `destination.namespace` memakai `{{ app_namespace }}`
(`commx-prod`) dan **wajib** sama dengan `namespace:` di `k8s/kustomization.yaml` — diverifikasi
2026-09-04, keduanya `commx-prod`. Kalau salah satu berubah sendiri, sync gagal tanpa sebab jelas.

**Belum diuji.** Nol perintah dijalankan. Yang terverifikasi baru: YAML valid (12 task), dan
`argocd_repo_url` terlipat jadi satu baris bersih tanpa spasi sisa.

**Terkait.** [[D-15]] [[D-08]] [[Q-05]] [[G-13]] [[R-02]]

### D-17 — Satu token Forgejo dipakai CI dan ArgoCD, disimpan di dua tempat ✅ (2026-09-04, user)

**Keputusan.** Satu token Forgejo, nilai yang sama ditempel di dua tempat:
`GIT_TOKEN` di Forgejo → Settings → Actions → Secrets (dipakai CI mem-push commit tag), dan
`forgejo_repo_token` di `ansible/group_vars/all/vault.yml` (dipakai role `argocd` merakit Secret
repo untuk ArgoCD). **Scope wajib `write:repository`.**

**Kenapa harus ditempel dua kali.** Ansible tidak bisa membaca Secrets milik Forgejo, dan Forgejo
tidak bisa membaca vault. Tidak ada yang menyinkronkan keduanya — kalau token diputar, dua tempat
harus diubah. Itu biaya yang diterima sadar, bukan kelalaian.

**Kenapa `write`, bukan `read`.** Tahap 6 pipeline mem-push commit tag balik ke repo. Token
read-only membuatnya gagal di `git push`. Konsekuensi yang diterima: **ArgoCD ikut memegang
kredensial yang bisa menulis ke repo**, padahal ia hanya perlu membaca. Kalau Secret di cluster
bocor, yang bocor bisa mengubah sumber kebenaran GitOps. Jalur hak-minimum (dua token terpisah)
ditolak demi kesederhanaan yang bisa dijelaskan.

**Apa yang dikatakan `case.md` soal ini: tidak ada.** Dibaca 2026-09-04 — satu-satunya aturan
rahasia ada di baris 124 (Terraform: variabel + env var) dan 252–254 (jangan push `.env`/kredensial
ke GitHub; "**any method may be used** as long as it isn't pushed to the repository, e.g. HashiCorp
Vault"). Case **tidak** mengatur scope token, rotasi, atau hak minimum, dan HashiCorp Vault hanya
contoh — `ansible-vault` sah. Jadi keputusan ini murni milik kita, dan yang mengikat justru
baris 249: setiap perintah harus bisa dijelaskan. Kriterianya "bisa dipertanggungjawabkan saat
ditanya", bukan "paling aman secara teori".

**Asumsi yang BELUM diverifikasi dan bisa menggagalkan push.** `forgejo_repo_user` diisi `ci-bot`
mengikuti URL di `.forgejo/workflows/ci.yaml`
(`http://ci-bot:${{ secrets.GIT_TOKEN }}@.../ComMX-Forgejo.git`). Belum diukur apakah Forgejo
**mengabaikan** bagian username saat password berupa token, atau **menuntut** user bernama `ci-bot`
benar-benar ada. Group A memakai pola identik, jadi kemungkinan besar aman — tapi itu bukan
pengukuran. **Cara mengukurnya, sekali, dari mesin mana pun yang bisa menjangkau Forgejo:**
```
git clone http://ci-bot:<TOKEN>@<forgejo>:3000/<owner>/ComMX-Forgejo.git /tmp/uji && \
  cd /tmp/uji && git commit --allow-empty -m uji && git push
```
Lulus = push diterima. Gagal `401`/`403` = buat user `ci-bot` di Forgejo, atau ganti bagian
username jadi pemilik token yang sebenarnya **di dua tempat** (ci.yaml dan vault).

**Terkait.** [[D-16]] [[D-11]] [[Q-05]]

### D-18 — Secret aplikasi & TLS dibuat role Ansible dari vault, bukan langkah manual ✅ (2026-09-04)

**Masalah yang diperbaiki.** `commx-secret` dan `commx-tls-cert` sama sekali **tidak dibuat oleh
kode mana pun** — diperiksa 2026-09-04, satu-satunya jejaknya adalah `secret.example.yaml` dan
komentar `openssl` di `gateway.yaml`. Keduanya langkah manual yang kalau terlewat memberi gejala
yang tidak menyebut dirinya: backend CrashLoop saat import ([[G-16]]) dan Gateway berhenti di
`Invalid CertificateRef` tanpa pernah dapat ADDRESS.

**Keputusan.** Role `argocd` yang membuat keduanya, di namespace aplikasi, **sebelum** Application
di-apply. Nilainya diambil dari `vault.yml`, jadi tidak ada rahasia yang menyentuh repo — sesuai
`case.md` baris 253 dan [[D-11]].

**Kenapa di role `argocd` dan bukan role baru.** Role itu sudah memegang namespace aplikasi dan
`registry-credentials`. Menaruhnya di sini menjaga urutan yang benar secara alami: semua Secret
sudah ada sebelum ArgoCD mulai sync, sehingga pod tidak pernah lahir ke namespace yang belum siap.

**Detail yang menentukan.**
- Ketiga label `app`/`owner`/`app.kubernetes.io/name` dipasang di kedua Secret. Tanpa itu Kyverno
  `require-labels` menolaknya, dan penolakan itu muncul jauh kemudian sebagai sync failed ([[R-03]]).
- Sertifikat dibangkitkan dengan `creates:` sehingga **idempoten** — case mewajibkannya (A-7).
  Tanpa itu tiap run melahirkan sertifikat baru dan tiap PC klien harus mempercayainya ulang.
- SAN memuat varian huruf besar dan kecil, di-`unique` supaya tidak kembar. Itu murni soal
  sertifikat; **bukan** perbaikan [[G-22]] — CORS tetap peka huruf.
- Ditutup `assert` yang membaca ulang isi namespace dan memastikan ketiga Secret ada (B2).

**Yang sengaja dibiarkan salah, dengan komentar.** `SOCKET_ORIGIN` memakai `{{ app_domain }}`
apa adanya, yang masih berkapital. Ini cacat [[G-22]] yang diketahui; perbaikannya satu kata
(`app_domain | lower`) tapi ia bagian dari keputusan domain yang lebih luas dan belum diambil.
Komentar peringatannya ada tepat di atas barisnya supaya tidak hilang.

**Belum diuji.** Nol perintah dijalankan. Terverifikasi: YAML valid (role jadi 19 task), dan
`san_list` merender `DNS:ComMX.local.com,DNS:commx.local.com,DNS:Grafana.local.com,DNS:grafana.local.com`.

**Terkait.** [[D-11]] [[D-16]] [[G-16]] [[G-22]] [[R-03]]

### D-19 — metrics-server jadi role sendiri; HPA tidak bisa memakai Prometheus ✅ (2026-09-04)

**Masalah yang diperbaiki.** Tidak ada apa pun yang memasang metrics-server. Tanpa itu
`kubectl get hpa` menampilkan `TARGETS <unknown>/70%` selamanya dan workload tidak pernah scale —
padahal auto-scale adalah requirement (K-7). Gejalanya diam: HPA tetap ada dan terlihat sehat,
hanya tidak pernah bertindak.

**Kenapa role sendiri, bukan bagian `monitoring`.** Ini kesalahpahaman yang gampang diwarisi:
**Prometheus tidak memberi makan HPA.** HPA membaca `metrics.k8s.io`, dan satu-satunya penyedianya
adalah metrics-server. Memasang kube-prometheus-stack tidak membuat HPA hidup. Play barunya
bertag `metrics`, ditaruh sesudah `storage` dan sebelum `monitoring`.

**`--kubelet-insecure-tls` wajib, dan ini menurunkan keamanan dengan sadar.** Di cluster kubeadm
biasa, sertifikat kubelet ditandatangani CA cluster dan tidak memuat IP node sebagai SAN, sehingga
metrics-server menolaknya dengan `x509: cannot validate certificate`. Gejalanya menipu: pod
metrics-server **Running dan Ready**, tapi APIService `v1beta1.metrics.k8s.io` tetap `False` dan
HPA tetap `<unknown>`. Yang benar di produksi adalah menerbitkan sertifikat kubelet dengan SAN
yang tepat; untuk lab ini kita menerima flag-nya, dan alasannya ditulis supaya bisa dibela.

**Dua lapis verifikasi, sengaja.** `helm` sukses → belum apa-apa ([[R-02]]). APIService `Available`
→ masih belum cukup. Yang dijadikan bukti adalah `kubectl top nodes` mengembalikan baris (B1) —
metrik yang benar-benar sampai ke klien.

**Belum diuji.** Nol perintah dijalankan. Terverifikasi: `site.yml` valid, 14 play, role 5 task.

**Terkait.** [[R-02]] [[D-10]]

### D-20 — Migrasi DB lewat Job psql, bukan drizzle-kit ✅ (2026-09-04)

**Masalah yang diperbaiki.** Drizzle **tidak** auto-migrate. Tanpa tabel `users`, semua pod Running,
Gateway punya ADDRESS, dan login tetap gagal — gejala yang tidak menunjuk penyebabnya sama sekali.
Group A menemukannya di mesin dan menambalnya dengan `CREATE TABLE` manual.

**Kenapa `psql` dan bukan `drizzle-kit migrate`.** Diperiksa 2026-09-04: `drizzle-kit` ada di
**devDependencies** `backend/package.json` baris 60, sedangkan image backend dibangun dengan
`npm ci --only=production`. Memanggilnya di image itu menghasilkan `drizzle-kit: not found` —
persis [[G-14]]. Jadi masalahnya struktural, bukan soal menulis perintah yang benar.

**DDL diturunkan dari `backend/src/db/schema.ts`, bukan disalin dari tim lain.** Tiga kolom:
`id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY`, `username VARCHAR(255) NOT NULL`,
`password VARCHAR(255) NOT NULL`. **Kalau `schema.ts` berubah, `k8s/postgres/migration-job.yaml`
wajib ikut berubah — tidak ada yang memeriksa kecocokannya secara otomatis.** Itu utang yang
diterima sadar sebagai ganti tidak menyeret drizzle-kit ke image produksi.

**Bentuknya ArgoCD PreSync hook** (`hook-delete-policy: BeforeHookCreation`) supaya jalan sebelum
tiap sync dan Job lama tidak bentrok. `CREATE TABLE IF NOT EXISTS` membuatnya aman diulang, jadi
tetap idempoten (A-7) baik lewat ArgoCD maupun `kubectl apply -k`.

**Isi skripnya menegakkan disiplin bukti.** Ia menunggu `pg_isready` dulu — kegagalan karena
urutan gampang terbaca sebagai kredensial salah. Lalu sesudah `CREATE TABLE` ia **membaca ulang**
`information_schema.columns` dan memastikan ketiga kolom ada. Tidak ada error bukan bukti (B2).

**Gotcha terukur yang ikut ditemukan.** uid user `postgres` berbeda antar varian image:
`postgres:16-alpine` = **70**, `postgres:16` debian = **999** (diukur `docker run --entrypoint id`
2026-09-04). Job memakai `postgres:16.4`, image yang **persis sama** dengan StatefulSet — sehingga
`runAsUser: 999` benar, dan Job tidak menambah image pull baru di node.

**Belum diuji.** Nol perintah dijalankan; yang terverifikasi baru YAML-nya dan uid image.

**Terkait.** [[G-14]] [[G-16]] [[R-03]] · sumber gejala: `refs/UPSTREAM-EVIDENCE.md`

### D-21 — Domain diturunkan ke huruf kecil semua, menyimpang dari ejaan case ✅ (2026-09-04, user)

**Keputusan.** `commx.local.com` dan `grafana.local.com`, huruf kecil semua, di seluruh kode.
Diterapkan ke 8 kemunculan di 5 file: `vars.yml`, `.forgejo/workflows/ci.yaml`,
`k8s/config/secret.example.yaml`, `k8s/gateway/gateway.yaml`, `k8s/gateway/httproute.yaml`.

**Ini deviasi dari `case.md`, dan alasannya wajib bisa dibela.** Case baris 46–47 mengejanya
`ComMX.local.com` dan `Grafana.local.com`. Deviasinya **hanya pada ejaan, bukan pada perilaku**:
DNS tidak peka huruf, jadi `commx.local.com` dan `ComMX.local.com` me-resolve ke nama yang sama
dan requirement "domain X melayani aplikasi" tetap terpenuhi utuh. Yang berubah cuma string yang
kita ketik di konfigurasi.

**Kenapa harus diubah.** Satu-satunya lapisan yang peka huruf adalah **CORS**. Browser me-lowercase
host di header `Origin`, backend membandingkan `process.env.SOCKET_ORIGIN` sebagai string apa
adanya, dan `https://ComMX.local.com` ≠ `https://commx.local.com`. Akibatnya login berhasil, pod
Running, Gateway punya ADDRESS, sertifikat valid — dan chat tidak pernah tersambung. Group A
menemukannya di mesin sesudah semua hal lain benar (E28 di `refs/UPSTREAM-EVIDENCE.md`).

**Kenapa semuanya, bukan hanya `SOCKET_ORIGIN`.** Menurunkan satu nilai saja meninggalkan repo
yang campur ejaan, dan nilai yang di-bake ke bundle frontend (`NEXT_PUBLIC_SOCKET_URL`, dari
`APP_DOMAIN` di CI) harus cocok dengan yang dibandingkan backend. Satu ejaan di semua tempat
menghapus seluruh kelas kesalahan ini, bukan satu instansinya.

**Yang tidak ikut berubah.** `ComMX` sebagai nama aplikasi, nama repo `ComMX-Forgejo`, dan judul
di dokumen tetap seperti aslinya — yang diturunkan hanya **nama domain**.

**Untuk anggota jaringan:** record DNS di MikroTik boleh ditulis dengan ejaan mana pun; DNS tidak
peka huruf. Tidak ada yang perlu diubah di sisi mereka karena keputusan ini.

**Terkait.** [[G-22]] [[G-04]] [[D-18]] · `case.md` baris 46–47

### D-22 — Jalur TLS registry dilengkapi, tapi default tetap HTTP ✅ (2026-09-04)

**Masalah yang diperbaiki.** Role `containerd` sudah punya dua cabang, dan cabang TLS-nya menunjuk
`/etc/containerd/certs.d/<host>/ca.crt`. **Tidak ada satu pun task yang pernah membuat file itu**,
dan registry-nya sendiri tidak pernah dibuatkan sertifikat. Jadi menyetel `registry_insecure: false`
menghasilkan keadaan yang lebih buruk daripada HTTP polos: registry tetap bicara HTTP, containerd
mencari file hantu, dan pull gagal dengan pesan yang tidak menyebut file itu sama sekali.
Ini kelas cacat yang sama dengan [[G-13]] — cabang yang terlihat ada tapi tidak pernah lengkap.

**Keputusan.** Jalur TLS dilengkapi jadi tiga bagian yang harus sejalan, **tapi defaultnya tetap
`registry_insecure: true`.** Menyalakan TLS bukan bagian dari perbaikan ini; yang diperbaiki adalah
"kalau dinyalakan, ia benar-benar bekerja". Menyalakannya tanpa pernah menguji justru menukar cacat
yang diketahui dengan cacat yang tidak diketahui.

| Bagian | Di mana | Isinya |
|---|---|---|
| 1. registry menyajikan TLS | `cicd_host` + compose | cert self-signed (`creates:`, idempoten) + `REGISTRY_HTTP_TLS_*` |
| 2. Docker di VM CI/CD percaya | `cicd_host` | `/etc/docker/certs.d/<host>/ca.crt` — path Docker, **beda** dari containerd |
| 3. containerd tiap node percaya | `containerd` | slurp cert dari VM CI/CD lalu tulis `ca.crt`, baru `hosts.toml` |

**Detail yang menentukan berhasil-tidaknya.** SAN wajib `IP:<alamat>`, bukan `DNS:`, karena registry
dirujuk lewat IP. Sertifikat ber-CN saja ditolak Go dengan
`x509: cannot validate certificate for <ip> because it doesn't contain any IP SANs` — pesan yang
gampang disalahartikan sebagai "cert belum dipercaya", padahal masalahnya bentuk sertifikatnya.

**Urutan yang mengikat.** `--tags cicd` wajib jalan sebelum `--tags core`: sertifikatnya lahir di VM
CI/CD dan node menyalinnya dari sana lewat `delegate_to`. Kalau belum, task gagal dengan pesan jelas
— itu disengaja, lebih baik daripada node yang diam-diam tidak mempercayai registry.

**Belum diuji.** Nol perintah dijalankan, dan jalur ini bahkan belum pernah **dipilih**.
Terverifikasi: kedua role YAML valid, dan template compose merender blok TLS hanya saat
`registry_insecure: false`.

**Terkait.** [[G-24]] [[D-08]] [[G-13]] · sumber gejala: `refs/UPSTREAM-EVIDENCE.md` E17, E18

### D-23 — Gerbang statis manifest, dengan kontrol negatif di dalamnya ✅ TERVERIFIKASI (2026-09-04)

**Keputusan.** `scripts/validate-manifests.py` menjadi gerbang yang dijalankan sebelum apply /
sebelum push. Ia merakit `kubectl kustomize k8s/` lalu memeriksa enam hal: tiga policy Kyverno
(latest-tag, default-namespace, require-labels termasuk label podTemplate), rujukan
HPA→workload, Service selector→pod + targetPort, HTTPRoute backendRef→Service+port, dan
keberadaan `resources.requests`.

**Kenapa dibuat.** [[R-03]]: penolakan Kyverno muncul di ArgoCD sebagai "sync failed" dan gampang
disalahartikan sebagai masalah jaringan. Semua yang diperiksa di sini bisa diketahui **sebelum**
manifest pernah menyentuh cluster, jadi tidak ada alasan menunggu cluster untuk mengetahuinya.

**Kontrol negatif ditanam DI DALAM skrip, bukan di sampingnya.** Sebelum memeriksa manifest asli,
skrip memeriksa manifest rusak buatan dan berhenti kalau tidak menangkap ≥6 pelanggaran — dengan
pesan bahwa hasil "lolos" tidak bernilai. Pemeriksa yang tidak pernah gagal tidak membuktikan
apa pun (B3), dan kontrol negatif yang disimpan terpisah cepat atau lambat berhenti dijalankan.

**Hasil pengukuran 2026-09-04 — ini `✅`, bukan `📝`, karena benar-benar dijalankan.**
- kontrol negatif internal: 7 pelanggaran buatan tertangkap
- `kubectl kustomize k8s/` merakit **16 dokumen**, rc 0 → [[G-08]] tertutup secara struktural
- manifest asli: **0 pelanggaran**, exit 0
- kontrol negatif ujung-ke-ujung: `newTag: v0.0.0` → `latest` di `kustomization.yaml` membuat
  gerbang **exit 1** dengan sebab yang benar (`ditolak disallow-latest-tag`, dua Deployment);
  dipulihkan, exit 0 lagi

**Batasnya, dan ini yang paling gampang disalahpahami.** Ia memeriksa **bentuk**, bukan perilaku.
Manifest yang lolos tetap belum membuktikan pod jalan, Gateway dapat ADDRESS, atau WSS terbentuk.
Status di `TRACE.md` **tetap `📝`** sesudah gerbang ini hijau — skrip mencetak kalimat itu sendiri
supaya tidak ada yang lupa.

**Catatan portabilitas.** Jangan pakai emoji di `print()` skrip ini: konsol Windows default cp1252
dan melempar `UnicodeEncodeError` setelah semua pemeriksaan lolos — kegagalan yang terlihat seperti
gerbangnya menolak, padahal ia sudah lulus. Diukur 2026-09-04.

~~Belum dilakukan: menyambungkan gerbang ini ke CI.~~ → **DILAKUKAN 2026-09-04**, dan keberatan
soal lingkungan runner diselesaikan dengan tidak memasang apa pun di runner: job `iac-scan`
menjalankan **dua container**, `registry.k8s.io/kustomize/kustomize:v5.4.2 build` untuk merakit
dan `python:3.12-slim` untuk memeriksa. Skrip diberi mode baca-dari-file/stdin supaya perakit dan
pemeriksa tidak perlu hidup di tempat yang sama.

**Urutan CI itu dijalankan sungguhan di laptop 2026-09-04**, persis seperti tertulis di workflow:
kustomize merakit 16 dokumen (exit 0), container python memasang pyyaml dan gerbangnya lolos
(exit 0). Ditambah `--root-user-action=ignore` karena pip menulis peringatan panjang ke stderr
walau sukses — di log CI itu terbaca seperti kegagalan.

**Terkait.** [[R-03]] [[G-08]] [[D-19]] [[G-23]]

### D-24 — Render semua template Ansible di laptop, dengan tiruan filter Ansible ✅ TERVERIFIKASI (2026-09-04)

**Keputusan.** `scripts/render-templates.py` merender **setiap** `.j2` memakai variabel sungguhan
dari `vars.yml` + `vault.yml`, dan `groups`/`hostvars` dibangun dari `inventory/hosts.ini` yang
nyata — bukan daftar tebakan, sehingga harness ikut berubah kalau inventory berubah.
`StrictUndefined` membuat variabel salah ketik jadi **error**, bukan string kosong yang diam-diam
merusak hasil.

**Kenapa perlu, padahal ada `--syntax-check`.** `ansible-playbook --syntax-check` **tidak
merender template**. Kesalahan variabel dan YAML yang rusak sesudah substitusi baru muncul saat
playbook benar-benar jalan di node — saat paling mahal. Skrip ini memindahkan penemuannya ke laptop.

**Pelajaran B4 yang mahal, dan terjadi DUA KALI hari ini.** Percobaan pertama melaporkan 3 dari 7
template "RENDER GAGAL". Ketiganya **sehat**: `bool` dan `to_json` adalah filter milik Ansible,
`contains` adalah test milik Ansible, dan `hostvars` tiruan saya cuma berisi 2 dari 7 host. Kalau
laporan itu dipercaya, tiga role sehat akan "diperbaiki" tanpa sebab — persis klaim negatif salah
yang dilarang CLAUDE.md. **Refleksnya: sebelum menyimpulkan template rusak, cek dulu apakah ia
memakai filter/test Ansible yang belum ditiru di `ansible_filters()`.** Peringatan itu ikut dicetak
skrip saat ada kegagalan.

**Hasil 2026-09-04 sesudah harness dibetulkan:** inventory terbaca 7 host / 7 grup, **7 template,
0 gagal**, semua yang berekstensi YAML juga parse.

**Kontrol negatif (B3), dijalankan pada file sungguhan lalu dipulihkan:** menyisipkan
`{{ variabel_yang_tidak_ada }}` ke `pool.yaml.j2` → `RENDER GAGAL`, exit 1. Menyisipkan
`ini: [rusak` → `YAML RUSAK`, exit 1. Dipulihkan → 0.

**Batasnya.** Ia membuktikan template bisa dirender dan hasilnya YAML sah. Ia **tidak** membuktikan
hasilnya benar secara semantik, dan tidak menyentuh logika task.

**Terkait.** [[D-23]] [[R-01]] · B4

### D-25 — `k8s_join` membuktikan hasilnya sendiri, bukan berhenti di rc 0 ✅ (2026-09-04)

**Masalah yang diperbaiki.** Role berhenti tepat sesudah `kubeadm join` berhasil. Itu hanya
membuktikan perintahnya selesai — node bisa saja **tidak pernah terdaftar** (token kedaluwarsa,
jam tidak sinkron, VIP tak terjangkau dari node itu) dan playbook tetap hijau. Kegagalannya lalu
muncul jauh kemudian sebagai pod yang tidak pernah ter-schedule, jauh dari sebabnya.

**Yang ditambahkan.** Tiga task, semuanya `run_once` + `delegate_to control_plane[0]` supaya yang
ditanya adalah **apiserver**, bukan node yang sedang dikonfigurasi:
1. `until` menunggu jumlah node terdaftar **dan** yang berkondisi `Ready=True` mencapai
   `control_plane + workers` (30 × 10 detik).
2. `assert` mencocokkan nama node dengan inventory, lalu menuntut ≥3 control plane dan ≥3 worker —
   ini persis requirement K-5, jadi playbook sendiri yang menegakkannya.
3. `debug` mencetak perintah `kubectl get nodes -o wide` untuk disalin ke `TRACE.md` sebagai bukti.

**Yang sengaja TIDAK diklaim.** K-6 (HA) tidak dibuktikan task ini, dan task ketiga mengatakannya
terang-terangan. HA hanya bisa dibuktikan dengan mematikan satu node dan menunjukkan cluster tetap
melayani — tidak pernah bisa dibaca dari config.

**Ekspresi `until`/`assert` diuji terpisah 2026-09-04** dengan data node tiruan, tiga kasus:
6 node Ready → lulus; 1 worker `Ready=False` → tertahan; 1 worker belum join → tertahan.
Pemeriksa yang tidak pernah menahan tidak bernilai (B3).

**Terkait.** [[R-02]] [[G-12]] [[D-03]]

---

## Gotcha (G)

### G-01 — HAProxy stacked tidak boleh bind 6443 ⚠️ SEBAGIAN (2026-09-03)

**Gejala.** HAProxy gagal start di control plane: "cannot bind socket / address already in use".
**Sebabnya.** `kube-apiserver` sudah memegang `:6443` di host yang sama.
**Refleks.** Frontend HAProxy di `8443`, backend tetap `6443`. Semua yang menyebut endpoint cluster
(kubeconfig, `k8sServicePort` Cilium, `--control-plane-endpoint`) ikut `8443`.
**Bukti pendukung.** Cluster hidup Group A: `kubeconfig` → `server: https://192.168.3.100:8443`;
`cilium-values.yaml` → `k8sServicePort: 8443`.
**Terkait.** [[D-02]] [[D-03]]

### G-02 — keepalived/VRRP tidak melewati router ⚠️ SEBAGIAN (2026-09-03)

**Gejala.** Dua node sama-sama mengklaim MASTER, atau VIP tidak pernah gagal-alih.
**Sebabnya.** VRRP adalah protokol Layer 2 (multicast 224.0.0.18). Kalau kedua node beda subnet,
advertisement tidak sampai.
**Refleks.** Node yang menjalankan keepalived wajib satu subnet. Di inventory Group A, cp-03
sengaja tidak dijadikan LB karena berada di subnet lain. Selain itu `net.ipv4.ip_nonlocal_bind=1`
wajib, supaya HAProxy bisa bind ke VIP yang belum dimiliki node itu.
**Terkait.** [[D-02]]

### G-03 — MetalLB L2 tidak bisa mengumumkan IP lintas subnet ⚠️ SEBAGIAN (2026-09-03)

**Gejala.** Service `LoadBalancer` dapat EXTERNAL-IP, tapi IP itu tidak bisa di-ping atau diakses
dari PC di jaringan.
**Sebabnya.** MetalLB L2 mengumumkan lewat ARP/NDP; node speaker harus berada di broadcast domain
yang sama dengan alamat pool.
**Refleks.** Label node yang sesubnet dengan pool, lalu pakai `nodeSelectors` di `L2Advertisement`.
Pool wajib di luar DHCP range MikroTik supaya tidak bentrok.
**Terkait.** [[D-05]] [[Q-02]]

### G-04 — NEXT_PUBLIC_* di-bake saat build, bukan saat runtime ⚠️ SEBAGIAN (2026-09-03)

**Gejala.** Frontend sudah dideploy dengan env `NEXT_PUBLIC_...` di Deployment, tapi browser tetap
memanggil URL lama / `undefined` / `ws://` bukan `wss://`.
**Ukurannya.** Kode klien memakai `process.env.NEXT_PUBLIC_BACKEND_URL` (`app/api/api.ts`) dan
`process.env.NEXT_PUBLIC_SOCKET_URL` (`app/lib/socket.ts`). Next.js menggantinya menjadi literal
**saat `npm run build`**.
**Sebabnya.** Bundle klien sudah jadi sebelum pod hidup; env pada Deployment tidak menyentuhnya.
**Refleks.** Dockerfile frontend wajib punya `ARG NEXT_PUBLIC_SOCKET_URL` / `ARG NEXT_PUBLIC_BACKEND_URL`
plus `ENV` di stage builder, dan CI wajib mengirim
`--build-arg NEXT_PUBLIC_SOCKET_URL=wss://ComMX.local.com`
`--build-arg NEXT_PUBLIC_BACKEND_URL=https://ComMX.local.com/api`.
**Selisih dengan repo kita.** Dockerfile frontend Group A punya ARG itu; Dockerfile kita belum.
Deployment frontend kita malah menyetel `NEXT_PUBLIC_API_URL` sebagai env runtime — nama variabelnya
pun berbeda dari yang dibaca kode, jadi dua kali tidak berpengaruh.
**Terkait.** [[G-06]]

### G-05 — nest build menghasilkan dist/src/main.js, bukan dist/main.js ~~⚠️ BELUM DIUKUR~~ → ✅ TERUKUR (2026-09-04)

**HASIL PENGUKURAN (2026-09-04, Docker Desktop di laptop, bukan di cluster).**
`docker build` + `docker run --rm --entrypoint ls commx-be-test -R /app/dist` memberi:

```
/app/dist:      drizzle.config.js  src  tsconfig.build.tsbuildinfo
/app/dist/src:  main.js  app.module.js  auth/  db/  redis-io-adapter/  socket/  users/
```

`drizzle.config.js` berada di **root** `dist/` — itu membuktikan mekanismenya, bukan hanya
hasilnya: `drizzle.config.ts` ikut terkompilasi, common-root bergeser ke folder project, dan
seluruh source pindah satu tingkat ke `dist/src/`. Dugaan di bawah terbukti benar **beserta
sebabnya**.

**Kontrol negatif + positif (B3).**
`docker run --rm commx-be-test` dengan CMD lama → `Error: Cannot find module '/app/dist/main.js'`
— gejala yang diramalkan muncul persis. `node -e "require('/app/dist/src/main.js')"` → resolusi
modul lolos dan eksekusi sampai `users/users.service.js:53` lalu gagal karena env DB kosong
(lihat [[G-16]]). Error runtime, bukan error path: jalur itu benar.

**Perbaikan yang diterapkan 2026-09-04.** `backend/Dockerfile`
~~`CMD ["node", "dist/main.js"]`~~ → **`CMD ["node", "dist/src/main.js"]`**, dan
`package.json` ~~`"start:prod": "node dist/main"`~~ → **`"node dist/src/main"`** (cacat yang sama,
tidak dipakai container tapi menjebak sesi berikutnya kalau dibiarkan).
Dipilih menyesuaikan CMD ke output nyata, **bukan** mengubah `tsconfig` — sama dengan pilihan
Group A yang clusternya sudah jalan, dan tidak menyentuh compiler config yang bisa merembet ke
`drizzle-kit` ([[G-14]]). Alternatif yang lebih bersih tapi belum diukur: `"rootDir": "./src"`
di tsconfig, atau exclude `drizzle.config.ts` di `tsconfig.build.json` — keduanya membuat
`dist/main.js` benar. **Jangan menerapkannya tanpa mengukur ulang.**

**Yang masih belum dibuktikan.** Image ini belum pernah dijalankan di Kubernetes. Yang terbukti
adalah jalur modulnya, bukan bahwa pod menjadi Ready.

---

**Catatan asli 2026-09-03 (dugaan, disimpan sebagai jejak penalaran):**

**Gejala yang diperkirakan.** Backend CrashLoopBackOff: `Cannot find module '/app/dist/main.js'`.
**Dasar dugaan — ini dugaan, bukan pengukuran.** `tsconfig.json` tidak menyetel `rootDir`, dan
`tsconfig.build.json` hanya meng-exclude `node_modules, test, dist, **/*spec.ts`, sehingga
`drizzle.config.ts` di root ikut terkompilasi. TypeScript memakai common-root dari seluruh input,
jadi root menjadi folder project dan output bergeser ke `dist/src/...`.
**Bukti tidak langsung.** Dockerfile Group A: `CMD ["node","dist/src/main"]`. Dockerfile kita:
`CMD ["node", "dist/main.js"]`. Keduanya dari kode backend yang sama. Salah satu pasti salah, dan
yang memilih `dist/src` adalah pihak yang clusternya sudah jalan.
**Cara mengukur — WAJIB sebelum dipercaya.** `docker build -t commx-be-test ./backend` lalu
`docker run --rm --entrypoint ls commx-be-test -R /app/dist | head -30`.
**Refleks sementara.** Jangan menebak; ukur dulu. Perbaikan yang menghilangkan masalahnya sama
sekali: tambahkan `"rootDir": "./src"` di tsconfig, atau exclude `drizzle.config.ts` di
`tsconfig.build.json`, lalu CMD `dist/main.js` menjadi benar secara pasti.
**Terkait.** [[R-02]]

### G-06 — basePath "/frontend" di next.config.ts membuat / menjadi 404 ⚠️ SEBAGIAN (2026-09-03)

**Gejala.** Pod frontend Running dan Ready, tapi `https://ComMX.local.com/` mengembalikan 404.
**Ukurannya.** `frontend/next.config.ts` berisi `output: "standalone"` **dan** `basePath: "/frontend"`.
**Sebabnya.** Dengan `basePath`, semua halaman dan aset dilayani di bawah `/frontend`; root `/`
tidak dipetakan ke apa pun.
**Refleks.** Pilih satu: (a) hapus `basePath` lalu rebuild image, atau (b) HTTPRoute mengarahkan
`/frontend` ke Service frontend dan menambah redirect dari `/`. HTTPRoute Group A memetakan
`/` → frontend, artinya mereka pasti sudah mengubah salah satunya — periksa saat menyalin.
**Terkait.** [[G-04]] [[D-07]]

### G-07 — Kyverno yang dipasang duluan memblokir instalasi komponen lain ⚠️ SEBAGIAN (2026-09-03)

**Gejala.** Helm install Longhorn/monitoring/ArgoCD gagal dengan pesan admission webhook denied.
**Sebabnya.** `disallow-latest-tag` dan `require-labels` dengan `validationFailureAction: Enforce`
berlaku ke semua namespace kalau tidak di-exclude; banyak chart memakai tag `latest` atau tidak
punya label wajib.
**Refleks.** Pasang Kyverno paling akhir, dan exclude namespace sistem di setiap rule.
**Terkait.** [[D-09]] [[R-03]]

### G-08 — Kustomize hanya membaca file bernama kustomization.yaml ⚠️ SEBAGIAN (2026-09-03)

**Gejala.** `kubectl apply -k k8s/` → "unable to find one of 'kustomization.yaml' ...".
**Ukurannya.** Di repo kita file itu bernama `k8s/kostumization.yaml` (salah eja), dan isinya
merujuk `backend.yaml` + `frontend.yaml` sedangkan file yang ada bernama `backend-development.yaml`
+ `frontend-development.yaml`. Dua kesalahan bertumpuk: nama file kustomization salah, dan daftar
`resources`-nya menunjuk file yang tidak ada.
**Refleks.** Rename file, samakan daftar `resources` dengan nama file yang benar-benar ada, lalu
verifikasi dengan `kubectl kustomize k8s/` (render saja, tanpa apply) sebelum apply.
**Terkait.** [[R-02]]

### G-09 — Provider Proxmox bpg: endpoint tanpa /api2/json, template lokal per node ⚠️ SEBAGIAN (2026-09-03)

**Gejala.** Terraform 401/404 saat konek ke Proxmox, atau clone gagal "template not found" di node kedua.
**Sebabnya.** (a) Provider `bpg/proxmox` memakai base URL **tanpa** suffix `/api2/json` — berbeda
dari `telmate` — dan `api_token` berbentuk satu string `"<tokenid>=<secret>"`.
(b) Storage `local-lvm` bersifat lokal per node, jadi template harus ada di setiap node dengan
VMID yang berbeda-beda.
**Refleks.** Verifikasi VMID template dengan `qm list` di **tiap** node sebelum apply.
**Sumber.** Komentar di `terraform-commx/providers.tf` + `variables.tf` di repo kita sendiri.
**Terkait.** [[Q-01]]

### G-10 — Redis dengan PVC butuh perbaikan kepemilikan /data ⚠️ SEBAGIAN (2026-09-03)

**Gejala.** Pod redis CrashLoop, log "Permission denied" saat membuka appendonly file.
**Sebabnya.** Volume ter-mount milik root, sementara container redis berjalan sebagai uid 999.
**Refleks.** Pola Group A: `securityContext.fsGroup: 999` + initContainer busybox
`chown -R 999:999 /data` (runAsUser 0), baru container redis dengan `runAsUser: 999`.
**Terkait.** [[D-06]]

### G-11 — Deployment backend kita hanya menyetel 2 dari 6 env yang dibutuhkan ⚠️ SEBAGIAN (2026-09-03)

**Gejala.** Backend gagal start atau listen di port yang salah; Service tidak punya endpoint sehat.
**Ukurannya.** `grep -rn "process.env" backend/src` menghasilkan kebutuhan: `JWT_SECRET`,
`SOCKET_ORIGIN`, `PORT`, `REDIS_URL`, `DATABASE_URL`, `NODE_ENV`.
`k8s/backend-development.yaml` hanya menyetel `REDIS_URL` dan `JWT_SECRET`. `main.ts` memanggil
`app.listen(process.env.PORT!)` — tanda `!` hanya menipu TypeScript; saat runtime nilainya `undefined`.
**Refleks.** Pakai pola Group A: `envFrom` ConfigMap (`NODE_ENV`, `PORT`, `REDIS_HOST`, `REDIS_PORT`)
+ `envFrom` Secret (`DATABASE_URL`, `JWT_SECRET`, `REDIS_URL`, `SOCKET_ORIGIN`). `SOCKET_ORIGIN`
harus `https://ComMX.local.com`; kalau salah, CORS memblokir WSS dan gejalanya terlihat seperti
masalah jaringan.
**Catatan tambahan.** Kalau redis dijalankan dengan `--requirepass`, `REDIS_URL` wajib berbentuk
`redis://:<password>@redis-service:6379` — repo kita menyalakan requirepass tapi Secret-nya masih
placeholder `${REDIS_URL}` yang tidak pernah diekspansi oleh Kubernetes.
**Terkait.** [[D-11]] [[D-12]] [[G-04]]

### G-12 — kubeadm init tanpa --control-plane-endpoint mengunci cluster jadi single-CP ⚠️ SEBAGIAN (2026-09-03)

**Gejala.** Saat menambah control plane kedua, join ditolak atau sertifikat apiserver tidak memuat VIP.
**Ukurannya.** `ansible/roles/k8s_control_plane/tasks/main.yml` milik kita menjalankan
`kubeadm init --pod-network-cidr=10.244.0.0/16 --cri-socket=...` tanpa `--control-plane-endpoint`
dan tanpa `--upload-certs`. Play-nya juga menargetkan seluruh grup `control_plane` (3 host), jadi
kalau dijalankan apa adanya, ketiga node akan mencoba init sendiri-sendiri menjadi 3 cluster terpisah.
**Sebabnya.** Tanpa control-plane-endpoint, sertifikat dan kubeconfig menunjuk IP node tunggal.
**Refleks.** Perbaiki role sebelum init pertama. Kalau cluster terlanjur ter-init begitu →
`kubeadm reset` di semua node; jangan ditambal.
**Terkait.** [[D-03]]

### G-13 — Play Ansible bisa "sukses" tanpa mengerjakan apa pun kalau grup host tidak ada ⚠️ SEBAGIAN (2026-09-03)

**Gejala.** `ansible-playbook site.yml --tags forgejo` selesai hijau, tapi Forgejo tidak terpasang.
**Ukurannya.** Di `K2Help/FinalAnsible`, `site.yml` play pertama menargetkan `hosts: cicd`,
sementara `inventory/hosts.ini` hanya mendefinisikan `[operator]`, `[control_plane]`, `[worker]`,
`[loadbalancer]`, `[subnet3]`. Grup `cicd` tidak pernah didefinisikan — padahal `group_vars`
menyebut "IP ini WAJIB sama dengan ansible_host grup [cicd]".
**Sebabnya.** Ansible mencetak "skipping: no hosts matched" dan tetap keluar dengan rc 0.
**Refleks.** Ini contoh langsung [[R-02]]: exit code 0 bukan bukti. Sesudah tiap tahap, verifikasi
di target (`docker ps`, `kubectl get`), bukan di layar Ansible. Kalau menyalin `site.yml` mereka,
samakan dulu nama grupnya dengan inventory kita.
**Terkait.** [[R-02]] [[D-08]]

### G-14 — Job migrasi DB memanggil drizzle-kit yang tidak ada di image produksi ⚠️ SEBAGIAN (2026-09-03)

**Gejala yang diperkirakan.** Job `commx-db-migration` gagal `drizzle-kit: not found`, atau `npx`
mencoba mengunduh dari internet lalu timeout.
**Ukurannya.** `k8s/db-migration-job.yaml` menjalankan `npx drizzle-kit migrate` memakai image
backend. Dockerfile backend melakukan `npm ci --only=production`, sementara `drizzle-kit` ada di
`devDependencies`. Selain itu `drizzle.config.ts` menunjuk `out: './drizzle'` dan folder
`backend/drizzle/` tidak ada di repo — jadi tidak ada file migrasi untuk dijalankan.
**Refleks.** Pilih satu: (a) `drizzle-kit generate`, commit folder `drizzle/`, dan buat stage image
khusus migrasi yang menyertakan drizzle-kit; atau (b) hapus Job dari alur produksi dan siapkan skema
sekali di awal. Jangan biarkan Job PreSync yang selalu gagal — ArgoCD akan menahan seluruh sync
dan gejalanya terlihat seperti "ArgoCD rusak".
**Terkait.** [[R-02]]

### G-15 — Heredoc di tool Bash pecah kalau kontennya memuat tanda kutip tunggal ✅ TERVERIFIKASI (2026-09-04, sesi 1)

**Gejala.** `cat > file <<'EOF' ... EOF` gagal dengan
`/usr/bin/bash: -c: line 1: unexpected EOF while looking for matching \`'\``
padahal delimiter heredoc-nya benar dan sudah dikutip.

**Ukurannya.** Terjadi 3x berturut-turut saat menulis `NOTES.md` dan dua batch file Ansible.
Nomor baris di pesan error menunjuk ke tengah konten, bukan ke penyebab sebenarnya —
itu yang membuatnya sempat terlihat seperti masalah isi file.

**Sebabnya.** Tool Bash membungkus perintah dalam `bash -c '...'`. Tanda kutip tunggal apa pun
di dalam konten menutup pembungkus itu lebih awal. Kutip pada delimiter heredoc tidak menolong,
karena kerusakannya terjadi satu lapis di atas heredoc.

**Refleksnya.** Untuk menulis file panjang di project ini, pilih salah satu:
1. Tool `Write` langsung (paling andal, satu file per panggilan), atau
2. tulis skrip generator Python ke scratchpad dengan `Write`, lalu jalankan
   `python gen.py` lewat Bash — dipakai untuk 63 file di sesi ini dan berhasil semua.

Di dalam skrip Python, pakai string mentah `r"""..."""`: tanpa `r`, urutan seperti `\1`
di regex Ansible (`replace: '\1'`) diterjemahkan Python jadi karakter kontrol.

**Pola yang lebih umum.** Setelah dua kegagalan dengan bentuk perintah yang sama, **ganti
mekanismenya, jangan perbaiki isinya.** Pesan error yang menunjuk lokasi salah adalah tanda
bahwa penyebabnya ada di lapisan lain.

**Terkait.** [[R-02]]

### G-16 — Backend mati saat import kalau DATABASE_URL kosong, bukan degradasi ✅ TERUKUR (2026-09-04)

**Gejala.** Pod backend CrashLoopBackOff tanpa satu pun log aplikasi — bukan "Running tapi error
saat request". Stack trace berhenti di `drizzle-orm/node-postgres/driver.cjs`:
`TypeError: Cannot destructure property 'connection' of 'params[0]' as it is undefined.`

**Ukurannya.** `docker run` image backend tanpa env apa pun. Sebabnya ada di
`backend/src/users/users.service.ts:8`: `const db = drizzle(process.env.DATABASE_URL!)` dievaluasi
di **top-level modul**, jadi ia jalan saat `require`, sebelum Nest sempat bootstrap. Tanda `!` di
TypeScript hanya mematikan pengecekan compiler; ia tidak memberi nilai saat runtime.

**Kenapa ini penting.** Secret/ConfigMap yang salah nama atau belum dibuat menghasilkan gejala yang
identik dengan image rusak atau registry tidak terjangkau. Sebelum menyalahkan image atau jaringan,
cek env dulu:
```
kubectl -n commx exec deploy/backend -- printenv | grep -E "DATABASE_URL|REDIS_URL|JWT_SECRET|SOCKET_ORIGIN|PORT|NODE_ENV"
kubectl -n commx describe pod -l app=backend | grep -A5 "Environment\|Events"
```
Lulus = keenam env muncul dan `DATABASE_URL` berisi host Postgres yang benar, bukan string kosong.

**Enam env yang dibaca kode** (hasil `grep -rn "process.env" backend/src/`, jadi ini daftar
lengkap, bukan perkiraan): `DATABASE_URL` `REDIS_URL` `JWT_SECRET` `SOCKET_ORIGIN` `PORT`
`NODE_ENV`. Cocok dengan daftar di [[G-11]] — `envFrom` ConfigMap + Secret memenuhi keenamnya.

**Terkait.** [[G-05]] [[G-11]]

### G-17 — Git Bash mengubah argumen /app/... jadi path Windows saat memanggil docker ✅ TERUKUR (2026-09-04)

**Gejala.** `docker run --rm --entrypoint ls <img> -R /app/dist` gagal dengan
`ls: C:/Program Files/Git/app/dist: No such file or directory` — terlihat seperti image tidak
memuat `/app/dist`, padahal isinya ada.

**Sebabnya.** MSYS2 di Git Bash menerjemahkan argumen yang berbentuk path absolut Unix menjadi
path Windows **sebelum** proses dijalankan. Yang rusak adalah argumennya, bukan containernya.

**Refleks.** Untuk perintah docker yang memuat path di dalam container, jalankan lewat tool
PowerShell, atau beri awalan `MSYS_NO_PATHCONV=1`, atau tulis `//app/dist`. Jangan menyimpulkan
apa pun tentang isi image dari pesan error yang menyebut `C:/Program Files/Git/`.

**Kenapa dicatat.** Ini kelas kesalahan yang sama dengan [[G-15]]: pesan errornya menunjuk ke
lapisan yang salah, sehingga waktu habis memeriksa objek yang sebenarnya sehat. Berlaku juga untuk
`kubectl exec ... -- ls /var/lib/...` nanti.

**Terkait.** [[G-15]] [[B4]]

### G-24 — `skip_verify` di hosts.toml beskema http:// adalah no-op, dan buggy ⚠️ (2026-09-04)

**Apa yang ditemukan.** `roles/containerd` cabang insecure menulis `skip_verify = true` di bawah
`[host."http://<registry>"]`. Opsi itu mengatur **verifikasi sertifikat TLS**, sedangkan skemanya
eksplisit `http://` — containerd tidak melakukan TLS sama sekali di jalur itu, jadi barisnya tidak
berefek apa pun.

**Kenapa tetap dihapus meski tidak berefek.** Group A mencatat `skip_verify` **buggy di containerd
v2.2.1** (`refs/UPSTREAM-EVIDENCE.md` E17) — mereka meninggalkan jalur HTTP justru karena itu.
Menyimpan baris yang tidak memberi manfaat tapi bisa memicu bug adalah risiko tanpa imbalan.
Dihapus 2026-09-04; yang tersisa `server = "http://..."` + `capabilities`, yang sudah cukup.

**Yang belum kita ukur.** Versi containerd di node kita belum diketahui, jadi belum bisa dipastikan
apakah bug itu relevan untuk kita. Klaimnya tetap milik Group A, bukan milik kita — statusnya `⚠️`.
Ukur dengan `containerd --version` sesudah `--tags core`.

**Refleks.** Kalau nanti pull dari registry gagal di jalur HTTP, **jangan** buru-buru menambahkan
kembali `skip_verify`. Periksa dulu skema di `hosts.toml` benar `http://` dan `config_path`
di `/etc/containerd/config.toml` benar-benar menunjuk `/etc/containerd/certs.d`.

**Terkait.** [[D-22]] [[D-08]]

### G-25 — Runner kita memetakan `ubuntu-latest` ke container tanpa Docker CLI ⚠️ (2026-09-04)

**Gejala yang akan muncul.** `docker: command not found` di **langkah pertama job pertama**
pipeline — sebelum satu tahap pun sempat berjalan.

**Bagaimana ditemukan.** Bukan dari menjalankan CI, tapi dari menyilangkan dua file kita sendiri.
`roles/cicd_host/tasks/main.yml` mencetak perintah registrasi runner dengan
`--labels ubuntu-latest:docker://node:20-bookworm`, artinya setiap job berlabel `ubuntu-latest`
dieksekusi **di dalam container `node:20-bookworm`**. Sementara `.forgejo/workflows/ci.yaml`
memanggil `docker run` langsung di job `security-scan` (GitLeaks, Semgrep, Trivy) dan `iac-scan`
(Checkov). Image node tidak memuat Docker CLI.

**Kenapa job lain tidak kena.** `build-publish` dan `update-manifest` memakai `appleboy/ssh-action`
— perintah dockernya berjalan di PC remote lewat SSH, bukan di dalam container job. Jadi cacatnya
mengenai tepat dua job, bukan empat. Ini yang membuatnya sulit terlihat: setengah pipeline
sebenarnya baik-baik saja.

**Perbaikan 2026-09-04.** Step `Siapkan Docker CLI` ditambahkan di kedua job:
`command -v docker || apt-get install -y docker.io`, lalu mencetak versinya sebagai bukti.
Base image **tetap** `node:*` — Group A pernah menggantinya ke `docker:cli` dan malah kena
`exec: "node": executable file not found` karena `actions/checkout` butuh Node ([[G-23]] E3).
Jadi arah perbaikannya menambah docker ke node, bukan menukar node dengan docker.

**Status `⚠️` dan bukan `✅`.** Pemetaan labelnya fakta yang ada di kode kita dan bisa dibaca
sekarang; **kegagalannya** belum kita ukur karena runner-nya belum pernah ada. Group A mengukur
gejala identik (E1). Naikkan ke `✅` setelah pipeline benar-benar jalan.

**Terkait.** [[G-23]] [[D-08]] [[D-23]]

### G-26 — Hyper-V hidup membuat VMware tidak bisa meneruskan VT-x; Proxmox terpasang tapi mati ⚠️ BELUM DIUKUR DI LAB (2026-09-04)

**Gejala yang diperkirakan.** Proxmox terpasang mulus, web UI hidup, `apt update` bersih — lalu
**setiap** `qm start` gagal:
`KVM virtualisation configured, but not available. Either disable in VM configuration or enable in BIOS.`
Pesannya menyuruh memeriksa BIOS, padahal BIOS sudah benar. Sebabnya ada dua lapis di atasnya.

**Sebabnya.** Kalau Windows menjalankan hypervisor sendiri (Hyper-V), VMware Workstation beralih ke
mode **WHP** dan **tidak bisa meneruskan VT-x/EPT ke guest**. Nested virtualization mati, sehingga
Proxmox — yang isinya memang menjalankan VM — tidak bisa mengerjakan tugas satu-satunya.
Yang menyalakan Hyper-V tanpa diminta: **WSL2, Docker Desktop, Windows Sandbox, Memory Integrity,
Credential Guard, Virtual Machine Platform.**

**Cara mengukur, sebelum menginstall apa pun** (PowerShell biasa, di tiap PC lab):
```
(Get-CimInstance Win32_ComputerSystem).HypervisorPresent      # LULUS: False
```
Dan di dalam Proxmox sesudah terpasang:
```
grep -o -m1 -E 'vmx|svm' /proc/cpuinfo                        # LULUS: mencetak vmx / svm
cat /sys/module/kvm_intel/parameters/nested                   # LULUS: Y
```
Bukti yang sebenarnya (B1) bukan keempat pembacaan itu, melainkan VM uji yang benar-benar menyala:
`qm create 999 ... && qm start 999 && qm status 999` → `status: running`.

**Status `⚠️ BELUM DIUKUR DI LAB`, dan alasannya penting.** Angka `HypervisorPresent: True` yang
memicu entri ini diukur di **laptop kerja**, bukan di PC lab — dan laptop itu memang menjalankan
WSL2 + Docker Desktop untuk keperluan project ini. **Jangan mewarisi ini sebagai fakta tentang PC
lab.** Ukur ulang di sana; mekanismenya yang berlaku umum, bukan angkanya. [[R-01]] versi Windows.

**Konsekuensi yang harus diterima sadar.** Mematikan Hyper-V **melumpuhkan WSL2 dan Docker Desktop**
di PC itu. Kedua gerbang verifikasi kita ([[D-23]] [[D-24]]) hanya butuh `python` + `kubectl`, jadi
tetap jalan — tapi `docker build` untuk mengukur hal seperti [[G-05]] tidak. Kalau butuh keduanya,
pisahkan mesinnya: PC lab untuk Proxmox, laptop untuk gerbang.

**Refleks.** Sebelum mendiagnosis Proxmox, cek lapisan di atasnya. Tiga tingkat virtualisasi berarti
kegagalan bisa lahir dua tingkat dari tempat pesannya muncul.

**Terkait.** [[P00]] [[G-09]] · B1, B3

### G-18 — Play `security` bertag `always` mematikan SETIAP `--tags`, dan ia menemukan dirinya sendiri ✅ TERUKUR (2026-09-04)

**Gejala.** `ansible-playbook site.yml --tags cicd` mati sebelum menyentuh VM CI/CD sama sekali.
Pesannya soal `git` atau soal "hardcoded credentials", sehingga mudah disalahartikan sebagai
masalah repo, bukan masalah playbook.

**Dua sebab terpisah, dua-duanya pasti kena, bukan kemungkinan.**

1. **`repo_root` belum repo git.** `site.yml` play pertama bertag `[always, security]`, jadi ia
   jalan di **semua** invokasi `--tags`. Task keduanya `git ls-files` dengan
   `chdir: {{ playbook_dir | dirname }}` = `Group B/ComMX-Forgejo`. Diukur 2026-09-04:
   `git rev-parse --is-inside-work-tree` → `fatal: not a git repository`. Task gagal, playbook
   berhenti. **Tidak ada tag yang bisa jalan sampai repo masuk git.**

2. **`git grep` menemukan daftar polanya sendiri.** Task "Search repository for forbidden strings"
   mencari `kelargacor` dkk, dan file yang memuat daftar itu — `roles/security/tasks/main.yml` —
   ikut ter-track, jadi `rc=0` selalu dan assert-nya selalu gagal. Sebuah pemeriksaan yang
   menggagalkan dirinya sendiri 100% dari waktu. Terbukti lewat `grep -rn` atas repo:
   hanya dua berkas yang memuat string itu, dan salah satunya adalah pemeriksanya.

**Perbaikan 2026-09-04.** (a) pathspec `-- . ':(exclude)ansible/roles/security/tasks/main.yml'`
ditambahkan ke perintah `git grep`; (b) `vault.yml.example` ~~`registry_password: "kelargacor"`~~
→ **`"LIHAT_case.md"`** — file `.example` ter-track, jadi nilai case tidak boleh tinggal di sana.
Nilai aslinya hidup di `vault.yml` yang ditutup `.gitignore` dan **tidak** terlihat `git grep`.

**Jebakan lanjutan — jangan mengira ini beres dengan `git init` saja.** Di repo yang baru di-init
tanpa commit, `git ls-files` mengembalikan daftar kosong, sehingga keempat assert lolos secara
hampa dan role `security` mencetak hijau tanpa memeriksa apa pun. Itu contoh telak [[R-02]]:
role ini baru bermakna **sesudah** `git add -A && git commit`. Verifikasi yang sah:
```
cd "Group B/ComMX-Forgejo"
git ls-files | wc -l                 # harus != 0, kalau 0 maka hijaunya palsu
git ls-files | grep -E '(^|/)\.env|\.tfstate|\.tfvars$|vault\.yml$'   # harus KOSONG
git grep -n -e kelargacor -- . ':(exclude)ansible/roles/security/tasks/main.yml'  # harus rc!=0
```

**Terkait.** [[R-02]] [[G-13]] [[D-08]]

### G-19 — Tidak ada control node Ansible di laptop ini ✅ TERUKUR (2026-09-04)

**Ukurannya.** `command -v ansible-playbook` di Windows → kosong. `wsl -l -v` → ada distro
`Ubuntu` (Stopped) dan `docker-desktop`. Di dalam `Ubuntu`: `ansible-playbook` **tidak ada**,
`git` ada, `~/.ssh` **kosong**, `python3` 3.12.3, dan `sudo` **meminta password** (jadi agent tidak
bisa memasang apa pun sendiri).

**Konsekuensi.** Ansible tidak punya control node native di Windows. Semua `ansible-playbook`
dijalankan dari WSL `Ubuntu`, dan tiga hal harus disiapkan user lebih dulu: paket ansible,
koleksi di `requirements.yml` (`community.general` dipakai task htpasswd — tanpa itu role
`cicd_host` gagal di tengah), dan kunci SSH `id_ed25519` yang di-authorize di host target.

**Koreksi terhadap HANDOFF sesi 1.** Di sana Jalur B disebut "tidak bergantung apa pun". Itu benar
untuk *cluster*, tapi tidak untuk prasyarat: ia tetap butuh host Ubuntu yang bisa di-SSH
([[Q-05]]), control node, dan repo yang sudah masuk git ([[G-18]]).

**Terkait.** [[G-18]] [[Q-05]]

### G-20 — Cilium Gateway API butuh CRD experimental; standard-install saja tidak cukup ⚠️ (diukur Group A, 2026-09-04)

**Gejala.** `kubectl get gatewayclass` berhenti di `ACCEPTED: Unknown` dan tidak pernah `True`.
Log cilium-operator menyebut CRD `tlsroutes` tidak ditemukan. Gateway tidak pernah dapat ADDRESS,
sehingga mudah disalahartikan sebagai masalah MetalLB.

**Ukurannya (milik mereka, bukan kita).** Cilium Gateway API memerlukan **6** CRD; berkas
`standard-install.yaml` hanya memuat 5 — `TLSRoute` hanya ada di channel **experimental**.

**Cacat di kode kita.** `ansible/roles/cni/tasks/main.yml` hanya memasang `standard-install.yaml`
(dua kali dirujuk, baris 13 dan 21). `experimental-install.yaml` tidak ada di mana pun di repo —
diperiksa 2026-09-04 dengan `grep -rn "experimental-install" ansible/ k8s/` → nol hasil.

**Perbaikan DITERAPKAN 2026-09-04** di `roles/cni/tasks/main.yml`: apply `experimental-install.yaml`
(+ fallback kubectl) **sebelum** helm install Cilium, memakai `{{ gateway_api_version }}` yang sama,
lalu **dua task penjaga** — `k8s_info` membaca CRD `tlsroutes...` dan `fail` menghentikan playbook
kalau ia tidak ada. Penjaga itu sengaja: apply hijau bukan bukti ([[R-02]]), dan kalau v1.2.0
ternyata memindahkan TLSRoute, kegagalannya muncul **di sini** dengan pesan yang jelas, bukan
jauh kemudian sebagai Gateway menggantung. Struktur diverifikasi: YAML valid, 10 task.
Verifikasi yang sah di mesin: 
```
kubectl get crd | grep -c gateway.networking.k8s.io   # LULUS: >= 6
kubectl get crd tlsroutes.gateway.networking.k8s.io   # LULUS: ada
kubectl get gatewayclass cilium -o jsonpath='{.status.conditions[?(@.type=="Accepted")].status}'
                                                      # LULUS: True, bukan Unknown
```
**Belum diverifikasi oleh kita.** Mereka memakai gateway-api v1.1.0; kita mengunci v1.2.0. Bahwa
`TLSRoute` masih experimental di v1.2.0 **belum kita ukur** — cek `kubectl get crd` sesudah apply
sebelum menyimpulkan.

**Terkait.** [[D-07]] [[D-04]] · sumber: `refs/UPSTREAM-EVIDENCE.md` E21

### G-21 — Kyverno require-labels memblokir Service yang dibuat Cilium sendiri ⚠️ (diukur Group A, 2026-09-04)

**Gejala.** Gateway berhenti tanpa ADDRESS; `kubectl describe gateway` memuat
`Unable to create Service ... blocked by Kyverno`. Terlihat seperti bug Cilium, padahal policy kita.

**Sebabnya.** Cilium meng-generate Service bernama `cilium-gateway-<nama-gateway>` secara otomatis.
Service itu **tidak** membawa label `app` / `owner` / `app.kubernetes.io/name`, sedangkan policy
`require-labels` mewajibkannya untuk Service juga. Admission menolak, Gateway macet.

**Cacat di kode kita.** `ansible/roles/kyverno/templates/policies.yaml.j2` hanya meng-exclude
**namespace** sistem (baris 18–21, 34–37, 77–80). Tidak ada exclude berbasis **nama**. Diperiksa
2026-09-04: `grep -n "cilium-gateway" k8s/policies/kyverno-policies.yaml ansible/roles/kyverno/` →
nol hasil.

**Perbaikan DITERAPKAN 2026-09-04** di `roles/kyverno/templates/policies.yaml.j2`: klausa exclude
kedua `- resources: {names: ["cilium-gateway-*"]}` ditambahkan ke rule `check-required-labels`.
Jumlah label wajib **tetap 3** — catatan Group A sendiri menyebut versi 3 label lebih sesuai
requirement soal daripada versi 1 label di repo git mereka. Render diverifikasi: 3 ClusterPolicy,
exclude berisi 2 klausa, `['app','owner','app.kubernetes.io/name']` masih diwajibkan.
Ini satu-satunya tempat policy didefinisikan — `k8s/policies/` kita hanya berisi `networkpolicy.yaml`.

**Kontrol negatif wajib (B3).** Sesudah exclude dipasang, policy harus **tetap** menolak Deployment
tanpa label. Kalau semua lolos, exclude-nya kelebaran dan tahap Kyverno tidak membuktikan apa pun.

**Terkait.** [[G-07]] [[R-03]] [[D-09]] · sumber: `refs/UPSTREAM-EVIDENCE.md` E22

### G-22 — CORS peka huruf besar-kecil: SOCKET_ORIGIN berhuruf kapital menggagalkan chat ⚠️ (diukur Group A, 2026-09-04)

**Gejala.** Login berhasil, halaman terbuka, tapi chat tidak pernah tersambung. Ini gejala yang
menipu karena semuanya terlihat sehat: pod Running, Gateway punya ADDRESS, sertifikat valid.

**Sebabnya.** Browser me-lowercase host di header `Origin`, jadi yang dikirim
`https://commx.local.com`. Backend membandingkan dengan `process.env.SOCKET_ORIGIN` **apa adanya**,
dan perbandingan CORS bersifat case-sensitive. `https://ComMX.local.com` ≠ `https://commx.local.com`.

**Cacat di kode kita — nilainya berhuruf kapital di empat tempat**, diperiksa 2026-09-04:
`ansible/group_vars/all/vars.yml:62` `app_domain: "ComMX.local.com"` ·
`k8s/config/secret.example.yaml:38` `SOCKET_ORIGIN: "https://ComMX.local.com"` ·
`k8s/gateway/httproute.yaml:18` hostname · `.forgejo/workflows/ci.yaml:27` `APP_DOMAIN`.

**Hati-hati saat memperbaiki — ini bukan sekadar cari-ganti.** Hostname DNS *tidak* peka huruf,
jadi entri MikroTik dan `hostnames:` di HTTPRoute boleh tetap. Yang **wajib** huruf kecil hanya
nilai yang dibandingkan sebagai string: `SOCKET_ORIGIN`, dan `NEXT_PUBLIC_*` yang di-bake ke bundle.
CN/SAN sertifikat sebaiknya ikut huruf kecil supaya cocok dengan yang diketik di browser.
Mengubah `app_domain` menyentuh sertifikat, DNS, build-arg, dan HTTPRoute sekaligus — **keputusan,
bukan penggantian teks.** ~~Belum diterapkan; menunggu keputusan.~~
→ **DITUTUP 2026-09-04 lewat [[D-21]]**: seluruh domain diturunkan ke huruf kecil, 8 kemunculan
di 5 file. Diverifikasi `grep -rn "ComMX\.local\|Grafana\.local"` → nol hasil.
**Cara ini kembali:** siapa pun yang menyelaraskan ejaan ke `case.md` baris 46–47 tanpa membaca
[[D-21]] akan mengembalikan kapitalnya, dan gejalanya muncul lagi sebagai chat yang tidak konek.

**Terkait.** [[G-04]] [[G-11]] [[G-16]] · sumber: `refs/UPSTREAM-EVIDENCE.md` E27, E28

### G-23 — Runner Forgejo: lima kegagalan lingkungan yang berulang di setiap tim ⚠️ (diukur Group A, 2026-09-04)

**Kumpulan gejala yang semuanya terjadi di pipeline mereka, urut:**
`docker: command not found` (base image `node:20-bullseye` tidak punya Docker CLI — install
`docker.io` sebagai step) · `Duplicate mount point: /var/run/docker.sock` (socket ter-mount dua kali:
`options:` manual **dan** `valid_volumes:` — hapus `options:`) · `exec: "node": not found` (base image
`docker:24-cli` tidak punya Node, padahal `actions/checkout` membutuhkannya) · `database or disk is
full` + Trivy `no space left` (disk VM 9.8 GB habis oleh image + DB Trivy 110 MB per run — pasang
volume cache `-v trivy-cache:/root/.cache/trivy`, dan siapkan `growpart`+`lvextend`) · Trivy image
scan `unable to find image` (Trivy dalam container tidak melihat daemon host — mount `docker.sock`).

**Kenapa dicatat sebagai satu entri.** Kelimanya bukan bug aplikasi; semuanya sifat lingkungan
runner yang akan menimpa siapa pun dengan arsitektur sama. Nilainya ada pada **urutan** — ini peta
kegagalan yang bisa diharapkan saat pertama kali pipeline dijalankan, sehingga tidak perlu
didiagnosis dari nol.

**Relevansi ke kita.** Workflow kita berjalan lewat `appleboy/ssh-action` ke PC, bukan di dalam
container runner ([[P07]] Bagian 2 poin 4 masih menyebutnya keputusan terbuka). Kalau keputusan itu
berubah jadi runner container, kelima jebakan ini langsung berlaku.

**Terkait.** [[G-04]] · sumber: `refs/UPSTREAM-EVIDENCE.md` E1–E7

---

## Aturan kerja (R)

### R-01 — Salin polanya, jangan salin angkanya ✅ TERVERIFIKASI (2026-09-03)

Setiap file yang diambil dari Group A wajib melewati checklist ini sebelum dipakai: IP/subnet,
nomor grup (`Group-1` vs `Group-2`), nama user Linux (`group-2` vs `ubuntu`/`prk`), nama node
Proxmox, host registry, repoURL Forgejo, nama StorageClass.
**Kenapa.** Tiga repo mereka memakai tiga rentang IP berbeda, dan salah satunya bahkan bentrok
di dalam dirinya sendiri (registry `192.168.2.5` dengan htpasswd `Group-1`).

### R-02 — Bukti adalah klien yang menerima hasil ✅ TERVERIFIKASI (2026-09-03)

`kubectl apply` sukses, `ansible-playbook` rc 0, dan "Secret sudah dibuat" bukan bukti.
Bukti yang sah: `curl -k https://<ip>/` mengembalikan HTML; DevTools/`wscat` menunjukkan frame WSS
terkirim; `kubectl get endpoints` berisi IP pod; pod di node yang di-drain benar-benar pindah.
[[G-13]] adalah contoh nyata kegagalan aturan ini di repo yang kita pelajari.

### R-03 — Periksa tag & label sebelum apply, Kyverno menolak dan gejalanya menyamar ✅ TERVERIFIKASI (2026-09-03)

Sesudah Kyverno aktif, manifest tanpa `app` + `owner` + `app.kubernetes.io/name`, atau dengan tag
`latest`, akan ditolak — dan lewat ArgoCD kegagalannya muncul sebagai "sync failed" yang mudah
disalahartikan sebagai masalah jaringan. `kostumization.yaml` kita saat ini menyetel `newTag: latest`,
jadi ia akan ditolak begitu Kyverno hidup.

---

## Pertanyaan terbuka (Q)

### Q-01 — Nomor grup kita ✅ TERJAWAB (2026-09-03, sesi 1)

**Jawaban dari user: kelompok kita = 1. Kelompok teman (folder `Group A`) = 2.**
Jadi seluruh `Group-[X]` di case menjadi **`Group-1`** untuk kita:
user Proxmox `Group-1` / `tpanetkelar`, user registry `Group-1` / `kelargacor`.
Nilai ini dikunci di `INSTRUCTION.md` §6 — jangan ditebak ulang di sesi berikutnya.

**Catatan yang layak diingat.** Group A adalah kelompok 2, tapi akun registry di backup cluster
hidup mereka bernama `Group-1` — persis nilai yang ada di baris contoh `help/.misc/forgejo-docs.md`
yang beredar antar tim. Artinya mereka menyalin baris `htpasswd` itu tanpa mengganti angkanya.
Ini contoh nyata [[R-01]] yang terjadi pada tim yang justru lebih maju: pola disalin **berikut
angkanya**, dan hasilnya kredensial yang tidak sesuai nomor kelompok sendiri. Kebetulan tidak
merusak karena tiap kelompok punya registry sendiri — tapi saat penilaian, akun bernama `Group-1`
di registry kelompok 2 adalah hal yang sulit dijelaskan.

---

**Riwayat pertanyaan ini (dipertahankan, append-only):**

Kredensial di case berbentuk `Group-[X]` (Proxmox `Group-[group-number]`, registry `Group-[X]`).
Nomor ini masuk ke user Proxmox dan htpasswd registry, jadi salah tebak berarti mengulang keduanya.

**Yang bisa disimpulkan dari artefak: hanya bahwa Group A = tim 2.** Buktinya diketik sengaja di
banyak tempat — `ansible.cfg` `remote_user = group-2`, `vars.yml` `ansible_user: group-2`,
prefix hostname `group-2-{{ inventory_hostname }}`, path `/home/group-2/.kube/config`, dan image
`192.168.2.5:5000/group-2/...`.

**Nomor kita sendiri tidak bisa disimpulkan dari file mana pun.** Satu-satunya string `Group-1` di
folder kita ada di `help/.misc/forgejo-docs.md:102` (`htpasswd -Bnb Group-1 kelargacor`) — dan file
itu **identik dengan salinan di dalam zip Group A** (`Web-Revision-Onsite-main/help/.misc/forgejo-docs.md`),
jadi ia dokumen yang beredar antar tim, bukan pernyataan nomor kita.
~~"docs kita menyebut Group-1"~~ → bukti itu gugur (2026-09-03, sesi 1).

**Catatan yang sempat terlihat seperti kontradiksi tapi bukan:** `ComMX-main/.forgejo/workflows/ci.yml:48`
login sebagai `Group-1` tapi push ke path `group-2/...`. Itu konsisten — di Docker registry, segmen
pertama nama image hanyalah nama repositori, tidak ada hubungannya dengan username autentikasi.

~~Jawabannya harus datang dari user atau Astdev, bukan dari file.~~ → dijawab user 2026-09-03.

### Q-02 — Alokasi IP: VIP keepalived + pool MetalLB
Butuh (a) satu IP bebas untuk VIP, sesubnet dengan cp-01 & cp-02; (b) rentang sekitar 20 IP untuk
MetalLB, di luar DHCP pool MikroTik, sesubnet dengan node speaker. Keduanya menentukan [[D-03]]
yang tidak bisa diubah setelah `kubeadm init`.

### Q-03 — Jadwal backup Proxmox ✅ TERJAWAB (2026-09-04, user)

**Jawaban: 12:00 PM = jam 12 siang.** Cron Proxmox: `0 12 * * *`.
Case menulis "every night at 12:00 PM" yang kontradiktif ("night" vs "PM"); user memutuskan
mengikuti angkanya, bukan kata "night". Keputusan ini **wajib disebut di dokumentasi** supaya
bisa dibela kalau penilai membacanya sebagai tengah malam.

**Konsekuensi operasional yang perlu diketahui, bukan untuk diperdebatkan:** jam 12 siang adalah
saat cluster paling ramai dipakai. Mode backup **Snapshot** (bukan Stop) yang dipakai di P01
membuat VM tetap hidup selama proses, jadi dampaknya terbatas pada I/O disk.
~~asumsi sementara 00:00~~ → **12:00** (dijawab user 2026-09-04).

### Q-04 — Alamat email tiap anggota + SMTP ⚠️ SEBAGIAN (2026-09-04)

**Sudah diketahui:** `yayan.gacor07@gmail.com` — dipakai sebagai penerima alert sekaligus
pengirim SMTP (`smtp_user` / `smtp_from`), karena akun Gmail.

**Masih dibutuhkan, dan keduanya memblokir DoD #8 (alert email benar-benar masuk):**

1. ~~**Gmail App Password** belum ada.~~ → **SUDAH DIBERIKAN user 2026-09-04**, tersimpan sebagai
   `smtp_password` di `ansible/group_vars/all/vault.yml` (spasi tampilan dibuang, jadi 16 karakter
   rapat). Nilainya **tidak** ditulis di dokumen mana pun selain vault. **Belum diuji** —
   App Password yang salah ditolak diam-diam oleh SMTP: alert tetap `Firing` di UI dan email tidak
   pernah sampai, mudah disalahartikan sebagai "monitoring sudah jalan". Uji terpisah sebelum
   percaya, jangan menunggu Alertmanager yang memberi tahu.
2. **Email anggota lain — masih memblokir.** Case meminta alert dikirim ke *each member's email
   address*. `team_emails` masih berisi satu alamat.

### Q-05 — Host Forgejo/registry
Dokumen kita menyebut `192.168.1.197:3000` (Forgejo, user `fadmin`) dan `:5000` (registry).
Apakah ini tetap dipakai, dan apakah ia VM tersendiri atau PC fisik?
