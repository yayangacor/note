# TRACE — Traceability requirement → bukti

Satu baris per requirement di `case.md`. Audit dijalankan terhadap **daftar ini**, bukan terhadap
kesan "kelihatannya lengkap".

Status: `❌` belum dikerjakan · `📝` kode sudah ditulis tapi **belum pernah dijalankan** ·
`🚧` sedang dikerjakan · `⚠️` ada tapi belum dibuktikan · `✅` terbukti dengan output mentah ·
`👤` bagian anggota lain (jaringan), di luar scope deployment.

`📝` adalah status yang paling gampang disalahartikan sebagai selesai. Ia berarti: file-nya ada,
sintaksnya lolos, dan **nol perintah pernah dijalankan di mesin.**

Kolom **Bukti** hanya boleh diisi output mentah / perintah yang dijalankan. Baris berstatus `✅`
dengan Bukti kosong lebih berbahaya daripada baris `❌` — itu klaim tanpa dasar.

---

## Bagian jaringan (dikerjakan anggota lain — dicatat supaya tidak hilang dari audit)

| § | Bunyi (potongan) | Status | Di mana dipenuhi | Bukti | Tgl |
|---|---|---|---|---|---|
| Internet | NAT untuk semua server & VM, 5 PC dapat internet | 👤 | MikroTik | — | — |
| DNS | forward ke 10.22.64.21/.22 + record `ComMX.local.com`, `Grafana.local.com` | 👤 ⚠️ | MikroTik | **butuh IP dari kita** (Gateway + Grafana LB). Ejaan record bebas — DNS tidak peka huruf; kode kita memakai huruf kecil ([[D-21]]), dan itu **tidak** menuntut perubahan di sisi MikroTik | — |
| DHCP | DHCP server + pool, ≥2 PC ambil IP dari pool | 👤 | MikroTik | — | — |
| Wireless | SSID `Wi-Fi-[box]`, user hotspot + user tiap anggota | 👤 | MikroTik | — | — |
| Firewall | blokir >5 login/menit + NAT masquerade | 👤 | MikroTik | — | — |
| VPN | L2TP/IPSec `network26-1`, IPSec secret, bisa internet | 👤 | MikroTik | — | — |
| Queues | queue per subnet, profil high-bandwidth & normal | 👤 | MikroTik | — | — |

> Ketergantungan dua arah yang gampang terlupa: record DNS `ComMX.local.com` dan
> `Grafana.local.com` menunjuk ke IP MetalLB yang baru ada **setelah** Gateway & Grafana punya
> EXTERNAL-IP. Jadi bagian jaringan belum bisa `✅` sampai kita menyerahkan IP-nya. Lihat [[Q-02]].

---

## Virtualization

| § | Bunyi (potongan) | Status | Di mana dipenuhi | Bukti | Tgl |
|---|---|---|---|---|---|
| V-1 | Proxmox untuk semua VM node Kubernetes | ❌ | 3 PC lab → VMware → Proxmox (**nested**) | ~~⚠️ 3 node Proxmox sudah ada~~ → **salah baca: `pve1/2/3` di terraform vars itu NAMA yang direncanakan, bukan node yang berdiri.** Proxmox belum terpasang di mana pun. Runbook lengkap dari Windows kosong sampai KVM nested terbukti: **`plans/P00-vmware-host.md`** (baru 09-04). Jebakan utamanya [[G-26]] | 09-04 |
| V-2 | user Proxmox `Group-1` / `tpanetkelar` | ❌ | P01 | nilai sudah pasti ([[Q-01]] ditutup), user belum dibuat | 09-03 |
| V-3 | tuning supaya Proxmox tidak melempem | ❌ | P01 | — | — |
| V-4 | 3–4 node Proxmox jadi 1 datacenter (cluster) | ❌ | P01 | — | — |
| V-5 | backup tiap malam 12:00 | ❌ | P01 | jam sudah pasti **12:00 siang**, cron `0 12 * * *` ([[Q-03]]); job belum dibuat | 09-04 |
| V-6 | migrasi otomatis saat node down (HA) | ❌ | P01 | — | — |

## Automation

| § | Bunyi (potongan) | Status | Di mana dipenuhi | Bukti | Tgl |
|---|---|---|---|---|---|
| A-1 | Terraform provisioning massal semua VM | ⚠️ | `terraform-commx/` | main.tf membuat 3 CP + 3 worker, **belum pernah di-apply** | 09-03 |
| A-2 | variable + env var untuk data sensitif | ✅ | `variables.tf` | token via `TF_VAR_*`, `*.tfvars` di-gitignore | 09-03 |
| A-3 | state Terraform dikelola benar (tidak hilang saat update) | 🚧 | P02 | `.gitignore` menutup `terraform.tfstate*`; **backend/backup state belum diputuskan** | 09-03 |
| A-4 | IP server statis (manual), bukan DHCP | 📝 | `terraform-commx/main.tf` | ~~dhcp~~ → `ip_config` memakai `control_plane_ips`/`worker_ips` + gateway + DNS | 09-03 |
| A-5 | Cloud-init drive dengan nilai kosong | 📝 | `terraform-commx/main.tf` | `user_account` hanya username + SSH key, tidak ada password ditanam | 09-03 |
| A-6 | Ansible Playbook berstruktur Roles | 📝 | `ansible/roles/` | ~~14 role~~ → **17 role** (angka lama salah hitung; namanya sudah 16). Urutan site.yml: security, cicd_host, common, containerd, k8s_base, load_balancer, k8s_control_plane, cni, k8s_join, helm, metallb, storage, **metrics_server** ([[D-19]], baru 09-04), monitoring, argocd, kyverno, kubectl_client. **Ketujuh templatnya dirender sungguhan 09-04, 0 gagal** ([[D-24]]) | 09-04 |
| A-7 | idempotent (boleh dijalankan berulang) | 📝 | idem | `kubeadm init` & join sekarang dijaga `stat` admin.conf/kubelet.conf; helm `state: present`. **Belum dibuktikan dengan dua kali run** | 09-03 |
| A-8a | provisioning: Core System Setup | 📝 | common+containerd+k8s_base | +open-iscsi, qemu-guest-agent, hostname, /etc/hosts, trust registry containerd. **09-04: `skip_verify` dibuang dari cabang HTTP** (no-op di skema `http://`, dan buggy di containerd 2.2.1 menurut Group A — [[G-24]]); cabang TLS kini benar-benar dapat `ca.crt`-nya ([[D-22]]) | 09-04 |
| A-8b | provisioning: Load Balancer Setup | 📝 | role `load_balancer` | HAProxy `:8443` + keepalived VIP, template tervalidasi `haproxy -c` | 09-03 |
| A-8c | provisioning: Cluster Setup | 📝 | `k8s_control_plane` + `k8s_join` | `--control-plane-endpoint` + `--upload-certs`, init hanya di CP-1 → [[G-12]] tertutup di kode | 09-03 |
| A-8d | provisioning: Monitoring & Alerting | 📝 | role `monitoring` | kube-prometheus-stack + PrometheusRule + Alertmanager SMTP | 09-03 |
| A-8e | provisioning: CI/CD Integration | 📝 | role `cicd_host` + `argocd` | compose forgejo/registry/runner; ArgoCD via Helm | 09-03 |

## Repository Management

| § | Bunyi (potongan) | Status | Di mana dipenuhi | Bukti | Tgl |
|---|---|---|---|---|---|
| RM-1 | fork repo ComMX ke akun pribadi | ⚠️ | GitHub | belum diverifikasi di sesi ini | — |
| RM-2 | branch `dev` dan `main` | ❌ | — | — | — |
| RM-3 | semua perubahan di-commit & push | ⚠️ | Forgejo lokal | folder `Group B/` di PC ini bukan git repo | 09-03 |

## Kubernetes Cluster

| § | Bunyi (potongan) | Status | Di mana dipenuhi | Bukti | Tgl |
|---|---|---|---|---|---|
| K-1 | manifest mengikuti best practice (aman & andal) | 📝 | `k8s/` | probe readiness+liveness, limits, securityContext non-root, secret keluar dari manifest. **09-04 diverifikasi statis** dengan `python scripts/validate-manifests.py`: `kubectl kustomize k8s/` merakit 16 dokumen (rc 0), 0 pelanggaran policy, rujukan silang konsisten. Gerbangnya sendiri diuji: kontrol negatif internal menangkap 7 pelanggaran, dan `newTag: latest` membuatnya exit 1 ([[D-23]]). **Ini bentuk, bukan perilaku** — belum ada pod yang pernah jalan. | 09-04 |
| K-2 | CRI bebas | ✅ | role containerd | containerd + SystemdCgroup | 09-03 |
| K-3 | CSI bebas | 📝 | role `storage` | Longhorn defaultClass, replica 2; StatefulSet memakai `storageClassName: longhorn` | 09-03 |
| K-4 | CNI **wajib Cilium** | 📝 | role `cni` | Helm cilium + kubeProxyReplacement + gatewayAPI. **09-04: ditambah CRD `experimental-install` + penjaga `fail` kalau `tlsroutes` tidak ada** — tanpa itu GatewayClass macet `ACCEPTED:Unknown` ([[G-20]], diukur Group A) | 09-04 |
| K-5 | ≥3 control plane + ≥3 worker | 📝 | inventory + `k8s_join` | 6 host; join CP memakai `--control-plane --certificate-key`. **09-04: role sendiri yang menegakkan requirement ini** — `until` menunggu semua node terdaftar & `Ready`, lalu `assert` menuntut ≥3 CP dan ≥3 worker dan mencocokkan namanya dengan inventory ([[D-25]]). Sebelumnya role berhenti di rc 0 `kubeadm join`. Ekspresinya diuji dengan 3 kasus tiruan termasuk yang harus tertahan | 09-04 |
| K-6 | HA: cluster tetap jalan kalau 1 node mati | 📝 | P04 | 3 etcd + VIP failover. **Wajib dibuktikan dengan mematikan node, bukan dibaca dari config** | 09-03 |
| K-7 | workload auto-scale saat traffic tinggi | 📝 | `k8s/*/hpa.yaml` + role `metrics_server` | HPA backend 3-8 & frontend 3-6 (CPU 70%). ~~metrics-server belum dipasang~~ → **role `metrics_server` baru, tag `metrics`** ([[D-19]]), dengan `--kubelet-insecure-tls` (tanpa itu pod Running tapi APIService False dan HPA tetap `<unknown>`). Diverifikasi dua lapis: APIService Available, lalu `kubectl top nodes` harus mengembalikan baris. Belum dijalankan | 09-04 |
| K-8 | resource seimbang antar node | 📝 | backend+frontend deployment | `topologySpreadConstraints` maxSkew 1 per hostname | 09-03 |
| K-9 | load balancer + floating IP (Keepalived/HAProxy) | 📝 | role `load_balancer` | VIP keepalived + HAProxy, stats di `:8404` | 09-03 |
| K-10 | MetalLB untuk trafik L2 masuk | 📝 | role `metallb` | pool + L2Advertisement, speaker dibatasi label node | 09-03 |
| K-11 | Kyverno: disallow latest tag | 📝 | `roles/kyverno/templates/policies.yaml.j2` | Enforce + exclude namespace sistem. **Manifest kita lolos policy ini secara statis**, dan kontrol negatifnya sudah ada di `scripts/validate-manifests.py` ([[D-23]]) — tapi kontrol negatif terhadap **Kyverno yang benar-benar jalan** masih wajib | 09-04 |
| K-12 | Kyverno: disallow default namespace | 📝 | idem | Enforce | 09-03 |
| K-13 | Kyverno: require labels | 📝 | idem | wajib `app`+`owner`+`app.kubernetes.io/name`; semua manifest kita sudah memenuhinya. **09-04: ditambah exclude `cilium-gateway-*`** — Service auto-generate Cilium tidak berlabel dan memblokir Gateway ([[G-21]]). Jumlah label wajib tetap 3. Kontrol negatif belum dijalankan | 09-04 |
| K-14 | expose lewat MetalLB + **Gateway API** | 📝 | `k8s/gateway/` | ~~Ingress nginx~~ → Gateway (HTTP+HTTPS) + HTTPRoute, diganti [[D-07]]. **09-04: keempat rule HTTPRoute diverifikasi menunjuk Service+port yang benar-benar ada** (`/api`, `/socket.io`, `/frontend`, `/` → backend:3000 / frontend:3000) ([[D-23]]) | 09-04 |
| K-15 | strategi deployment + justifikasi tertulis | 📝 | [[D-12]] | RollingUpdate maxSurge 1 / maxUnavailable 0 sudah ada di kedua Deployment | 09-03 |

## Aplikasi & keamanan transport

| § | Bunyi (potongan) | Status | Di mana dipenuhi | Bukti | Tgl |
|---|---|---|---|---|---|
| APP-1 | Redis adapter untuk sesi WebSocket | 📝 | `backend/src/redis-io-adapter` | `REDIS_URL` kini dari Secret, sudah termasuk password requirepass | 09-03 |
| APP-2 | **wajib HTTPS + WSS dua arah** | 📝 | Gateway + CI + role `argocd` | listener HTTPS + rute `/socket.io` + build-arg `wss://` sudah ada. ~~Secret TLS belum dibuat, cuma komentar openssl di gateway.yaml~~ → **role `argocd` membangkitkan cert self-signed (idempoten, `creates:`) dan membuat `commx-tls-cert`** ([[D-18]]). SAN memuat varian huruf besar+kecil. ~~Sisa risiko: SOCKET_ORIGIN masih berkapital~~ → **[[G-22]] ditutup 09-04**: seluruh domain turun ke huruf kecil ([[D-21]]), rantai `APP_DOMAIN` → build-arg `wss://` → `SOCKET_ORIGIN` kini satu ejaan. Belum diuji di browser | 09-04 |
| APP-3 | backend menerima semua env yang dibutuhkan | 📝 | `backend/deployment.yaml` + role `argocd` | ~~2 dari 6~~ → `envFrom` ConfigMap + Secret. Daftar 6 env kini **terukur**, bukan perkiraan: `grep -rn "process.env" backend/src/` → `DATABASE_URL REDIS_URL JWT_SECRET SOCKET_ORIGIN PORT NODE_ENV`. Env kurang = CrashLoop saat import, lihat [[G-16]]. **09-04: `commx-secret` kini dibuat role `argocd` dari vault** ([[D-18]]), bukan lagi `kubectl apply` manual yang gampang terlewat. Belum diuji di k8s | 09-04 |
| APP-4 | image backend punya entrypoint yang benar | ⚠️ | `backend/Dockerfile` | `docker build` lulus di laptop; `ls -R /app/dist` → source ada di `dist/src/`, bukan `dist/`. CMD ~~`dist/main.js`~~ → **`dist/src/main.js`**. Kontrol negatif: CMD lama → `Cannot find module '/app/dist/main.js'`; kontrol positif: `dist/src/main.js` lolos resolusi modul. Lihat [[G-05]]. **Belum pernah jalan sebagai pod** | 09-04 |
| APP-5 | skema DB siap sebelum aplikasi melayani | 📝 | `k8s/postgres/migration-job.yaml` | Drizzle **tidak** auto-migrate; tanpa tabel `users` semua pod Running tapi login gagal. Job PreSync pakai `psql` dari image `postgres:16.4` (sama dengan StatefulSet) — **bukan** `drizzle-kit`, yang ada di devDependencies dan tidak terpasang di image produksi ([[G-14]]). DDL diturunkan dari `backend/src/db/schema.ts`. Skrip menunggu `pg_isready` lalu membaca ulang `information_schema.columns` untuk membuktikan ketiga kolom ada ([[D-20]]). Belum dijalankan | 09-04 |

## CI/CD

| § | Bunyi (potongan) | Status | Di mana dipenuhi | Bukti | Tgl |
|---|---|---|---|---|---|
| C-1 | pipeline otomatis dari update repo → Deployment | 🚧 | `.forgejo/workflows/ci.yaml` | workflow ada; berjalan lewat SSH ke PC, bukan runner container | 09-03 |
| C-2 | CI/CD: Forgejo lokal | ⚠️ | 192.168.1.197:3000 | terhalang [[Q-05]] | — |
| C-3 | CD: ArgoCD | 📝 | role `argocd` (otoritatif) + `k8s/argocd/application.yaml` (cadangan manual) | namespace tujuan ~~commx~~ → `commx-prod`, disamakan. **09-04: role sekarang benar-benar meng-apply Application** — sebelumnya ArgoCD terpasang tapi tidak pernah tahu harus deploy apa, jadi GitOps mati diam-diam ([[D-16]]). Ditambah Secret kredensial repo, peringatan eksplisit kalau token kosong, dan baca-ulang+assert `repoURL`/`namespace`/`selfHeal` (B2). `argocd_repo_url` dirakit dari vars.yml, bukan IP mentah di manifest | 09-04 |
| C-4 | private registry + user `Group-1`/`kelargacor` | 📝 | role `cicd_host` | htpasswd dibuat role (bukan manual), nilai dari vault. **09-04: jalur TLS dilengkapi** ([[D-22]]) — cert self-signed dengan SAN `IP:`, Docker VM CI/CD + containerd tiap node dibuat percaya otomatis. **Default tetap `registry_insecure: true`**; TLS belum pernah dipilih maupun diuji | 09-04 |
| C-5 | CI tahap 1: scan source & dependency (GitLeaks, Semgrep, Trivy) | 📝 | workflow job `security-scan` | GitLeaks + Semgrep `--error` + Trivy fs `--exit-code 1`. **09-04: ditambah step `Siapkan Docker CLI`** — runner memetakan `ubuntu-latest` ke container `node:20-bookworm` yang tanpa Docker CLI, jadi job ini mati di langkah pertama tanpa itu ([[G-25]]). Kontrol negatif GitLeaks (dummy secret di branch uji) **belum dijalankan** | 09-04 |
| C-6 | CI tahap 2: containerize | 🚧 | workflow | ~~✅ (09-03, salah stempel — nol perintah dijalankan)~~ → **backend** benar-benar ter-build 09-04 di laptop, image `commx-be-test` jalan sampai bootstrap. **frontend belum pernah di-build**, dan workflow CI-nya sendiri belum pernah jalan | 09-04 |
| C-7 | CI tahap 3: image scanning (Trivy) | 📝 | workflow | loop untuk KEDUA image, bukan hanya backend | 09-03 |
| C-8 | CI tahap 4: publish ke private registry | 📝 | workflow | ~~✅ (09-03, salah stempel — nol perintah dijalankan)~~ → `docker push` kedua image ada di workflow, tapi **belum pernah dieksekusi**: registry belum berdiri, Forgejo belum diinstall | 09-04 |
| C-9 | CI tahap 5: IaC scan (Checkov) | 📝 | workflow job `iac-scan` | Checkov terhadap `k8s/`, **+ gerbang `validate-manifests.py`** ([[D-23]]): policy Kyverno + rujukan silang HPA/Service/HTTPRoute. Dua container (`kustomize build` lalu `python:3.12-slim`) supaya runner tidak perlu memasang tool apa pun ([[G-23]]). Urutan itu **dijalankan sungguhan di laptop 09-04**: 16 dokumen terakit exit 0, gerbang lolos exit 0. Checkov-nya sendiri belum pernah dijalankan | 09-04 |
| C-10 | CI tahap 6: commit tag image baru ke repo manifest | 📝 | workflow job `update-manifest` | ~~sed v0.0.0~~ → `kustomize edit set image` + `git diff --exit-code` yang menggagalkan job kalau tag tidak berubah | 09-03 |

## Monitoring & Alerting

| § | Bunyi (potongan) | Status | Di mana dipenuhi | Bukti | Tgl |
|---|---|---|---|---|---|
| M-1 | Grafana + Prometheus untuk cluster | 📝 | role `monitoring` | kube-prometheus-stack via Helm, keduanya `type: LoadBalancer` | 09-04 |
| M-2 | kredensial `tormonitor` / `monitor` | 📝 | `roles/monitoring/templates/values.yaml.j2` | `adminUser: tormonitor`, password dari vault | 09-04 |
| M-3 | metrik CPU & RAM tiap node | 📝 | role `monitoring` | node-exporter bawaan chart | 09-04 |
| M-4 | kondisi tiap Pod | 📝 | role `monitoring` | kube-state-metrics bawaan chart | 09-04 |
| M-5 | alert CPU/RAM node ≥90% | 📝 | `alert-rules.yaml.j2` | `NodeCPUHigh` + `NodeMemoryHigh`, ambang 90%, for 5m | 09-04 |
| M-6 | alert error pada pod | 📝 | `alert-rules.yaml.j2` | `PodNotRunning`, `PodCrashLooping`, `ContainerWaiting` | 09-04 |
| M-7 | alert dikirim via email ke tiap anggota | 📝 | P08 | ~~❌ App Password + email anggota belum ada~~ → **keduanya lengkap 09-04**. `values.yaml.j2` **dirender sungguhan** dengan vault: `smtp.gmail.com:587`, auth user terisi, App Password 16 karakter, `smtp_require_tls: true`, dan **7 penerima** di `email_configs.to` ([[D-24]]). Watchdog dibuang ke receiver blackhole. **Belum diuji kirim** — App Password salah ditolak SMTP secara DIAM-DIAM ([[Q-04]]) | 09-04 |

## Dokumentasi & aturan umum

| § | Bunyi (potongan) | Status | Di mana dipenuhi | Bukti | Tgl |
|---|---|---|---|---|---|
| DOC-1 | dokumentasi semua langkah (Proxmox, Terraform/Ansible, app, k8s, monitoring, CI/CD) | ❌ | P09 | — | — |
| DOC-2 | memuat semua perintah + semua IP yang direservasi | ❌ | P09 | — | — |
| DOC-3 | jelas & bisa direplikasi orang lain | ❌ | P09 | — | — |
| N-1 | tidak push `.env` / kredensial | 📝 | role `security` + `.gitignore` | password Postgres ~~literal di manifest~~ → Secret; `.gitignore` menutup secret.yaml, vault.yml, tfvars, tfstate, key. **Case baris 254 membebaskan metode** ("any method may be used", HashiCorp Vault hanya contoh) — jadi `ansible-vault` sah, tidak perlu Vault. Daftar string terlarang role `security` = 4 kredensial yang dicetak case (baris 84, 85, 110, 200). **`case.md` ada di luar repo** (`learning/`, bukan `Group B/ComMX-Forgejo/`) — jangan pindahkan root repo ke atas, ia memuat keempat kredensial itu sebagai teks. Belum diuji: role security butuh repo yang sudah di-commit ([[G-18]]) | 09-04 |
| N-2 | tiap anggota paham setiap perintah | 🚧 | P09 | dokumentasi harus memuat penjelasan, bukan hanya perintah | — |
