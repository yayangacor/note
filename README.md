# ComMX — Deployment TPA Network 26-1

Deployment aplikasi chat **ComMX** (Next.js + NestJS + Redis adapter) di atas Kubernetes HA,
lengkap dengan provisioning (Terraform), konfigurasi (Ansible), pipeline DevSecOps (Forgejo
Actions), GitOps (ArgoCD), dan monitoring (Prometheus/Grafana/Alertmanager).

Kelompok 1.

---

## Status jujur

**Kode di repo ini lengkap. Belum ada satu pun perintah yang pernah dijalankan di cluster.**

Semua manifest, role, dan pipeline sudah ditulis dan lolos pemeriksaan statis, tapi belum pernah
diuji di mesin sungguhan. Repo ini adalah *rencana yang bisa dieksekusi*, bukan laporan sistem yang
sudah berjalan. Jangan membaca kelengkapan struktur sebagai bukti bahwa sesuatu bekerja.

Yang **sudah** dibuktikan (berjalan di laptop, bukan di cluster):

| Apa | Cara | Hasil |
|---|---|---|
| Entrypoint image backend | `docker build` + `ls -R /app/dist` | output ada di `dist/src/`, bukan `dist/` |
| Rakitan manifest | `kubectl kustomize k8s/` | 16 dokumen, rc 0 |
| Policy + rujukan silang | `scripts/validate-manifests.py` | 0 pelanggaran |
| Semua template Ansible | `scripts/render-templates.py` | 7 template, 0 gagal |

---

## Arsitektur mesin — tiga lapis

```
PC lab (Windows, 24 GB RAM)  ×3
└── VMware Workstation ─────────── nested virtualization WAJIB aktif
    └── Proxmox VE  (pve1 / pve2 / pve3, satu cluster)
        ├── k8s-cp-01 … cp-03        control plane (HAProxy + keepalived, VIP :8443)
        ├── k8s-worker-01 … 03       worker
        └── (satu PC) VM CI/CD       Forgejo + registry + runner, DI LUAR cluster
```

CI/CD sengaja di luar cluster: kalau cluster di-reset — dan pada case ini itu sangat mungkin —
sumber kebenaran dan image tetap selamat.

**Lapisan ketiga itu yang membuat setup mesin tidak bisa dilewati.** Tanpa VT-x diteruskan sampai
ke Proxmox, Proxmox tetap terpasang dan terlihat sehat, lalu **setiap** VM gagal start. Baca
[`docs/01-setup-mesin.md`](docs/01-setup-mesin.md) §1.2 sebelum menginstall apa pun.

---

## Mulai dari mana

Berurutan. Tiap tahap punya bentuk output yang dianggap lulus; jangan lompat.

| # | Tahap | Dokumen / perintah |
|---|---|---|
| 1 | PC Windows → Proxmox nested, ×3 | [`docs/01-setup-mesin.md`](docs/01-setup-mesin.md) |
| 2 | Cluster Proxmox, user, API token, template cloud-init, backup, HA | `pvecm create` / `pvecm add` |
| 3 | Provisioning 6 VM + inventory | `terraform-commx/` |
| 4 | Konfigurasi node, cluster k8s, platform, aplikasi | `ansible/site.yml`, bertahap `--tags` |

### Prasyarat di mesin operator

```bash
# Ansible tidak punya control node native di Windows -- pakai WSL Ubuntu / Linux
sudo apt update && sudo apt install -y ansible
cd ansible && ansible-galaxy collection install -r requirements.yml

# Kunci SSH yang ditanam ke VM lewat cloud-init
ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519
```

### Kredensial — tidak ada satu pun yang ada di repo ini

```bash
cp ansible/group_vars/all/vault.yml.example ansible/group_vars/all/vault.yml
# isi nilainya, lalu WAJIB dienkripsi sebelum commit:
ansible-vault encrypt ansible/group_vars/all/vault.yml
```

Terraform membaca rahasianya dari environment, bukan dari file:

```bash
export TF_VAR_proxmox_api_url="https://<ip-proxmox>:8006/"
export TF_VAR_proxmox_api_token_id="Group-1@pve!terraform"
export TF_VAR_proxmox_api_token_secret="<secret>"
export TF_VAR_ssh_public_key="$(cat ~/.ssh/id_ed25519.pub)"
```

### Provisioning

```bash
cd terraform-commx
cp terraform.tfvars.example terraform.tfvars     # sesuaikan IP, lalu JANGAN di-commit
terraform init && terraform plan
terraform apply                                   # menulis ansible/inventory/hosts.ini
```

### Konfigurasi, bertahap

```bash
cd ansible
ansible-playbook site.yml --tags cicd   --ask-vault-pass   # Forgejo + registry (di luar cluster)
ansible-playbook site.yml --tags core                      # containerd, kubeadm, trust registry
ansible-playbook site.yml --tags lb                        # HAProxy + keepalived
#  ^^ BUKTIKAN VIP hidup sebelum lanjut:  nc -vz <VIP> 8443
ansible-playbook site.yml --tags init                      # kubeadm init (HANYA cp pertama)
ansible-playbook site.yml --tags cni                       # Cilium + CRD Gateway API
ansible-playbook site.yml --tags join                      # cp-02/03 + worker
ansible-playbook site.yml --tags metallb
ansible-playbook site.yml --tags storage                   # Longhorn
ansible-playbook site.yml --tags metrics                   # metrics-server (HPA butuh ini)
ansible-playbook site.yml --tags monitoring --ask-vault-pass
ansible-playbook site.yml --tags argocd     --ask-vault-pass
ansible-playbook site.yml --tags kyverno                   # PALING AKHIR
```

> **`--tags init` tidak boleh jalan sebelum `--tags lb` terbukti hidup.** VIP tertanam di
> sertifikat cluster saat init; mengubahnya sesudahnya berarti `kubeadm reset` di semua node.
> Role `init` memasang penjaga, tapi jangan mengandalkan penjaga — jalankan urut.

---

## Dua gerbang sebelum apply atau push

Keduanya jalan di laptop tanpa cluster, dan **masing-masing menguji dirinya sendiri lebih dulu**
dengan kasus yang seharusnya gagal. Pemeriksa yang tidak pernah gagal tidak membuktikan apa pun.

```bash
python scripts/validate-manifests.py    # kustomize + policy Kyverno + rujukan HPA/Service/HTTPRoute
python scripts/render-templates.py      # render SEMUA .j2 dengan vars + vault sungguhan
```

`exit 0` = lulus. Yang dibuktikan cuma **bentuk**, bukan perilaku.

Kalau `render-templates.py` melapor gagal, jangan langsung menyalahkan templatnya: Jinja2 polos
tidak punya filter/test milik Ansible (`bool`, `to_json`, `contains`). Periksa `ansible_filters()`
di skrip itu lebih dulu.

---

## Isi repo

```
ansible/            17 role + site.yml bertahap (--tags) + group_vars + inventory
  roles/            security, cicd_host, common, containerd, k8s_base, load_balancer,
                    k8s_control_plane, cni, k8s_join, helm, metallb, storage,
                    metrics_server, monitoring, argocd, kyverno, kubectl_client
terraform-commx/    provisioning 6 VM, IP statis, generate inventory Ansible
k8s/                namespace, config, postgres, redis, backend, frontend, HPA,
                    Gateway API, NetworkPolicy, Job migrasi DB, kustomization, ArgoCD Application
.forgejo/workflows/ pipeline 6 tahap: GitLeaks → Semgrep → Trivy → build → Trivy image
                    → push → Checkov → gerbang manifest → commit tag
scripts/            dua gerbang verifikasi statis
docs/               runbook setup mesin
backend/ frontend/  aplikasi + Dockerfile
```

### Di mana angka jaringan hidup

Satu nilai, satu rumah. Jangan menyebar IP ke banyak file.

| Lapisan | File |
|---|---|
| Terraform | `terraform-commx/variables.tf` |
| Ansible | `ansible/group_vars/all/vars.yml` |
| Kubernetes | `k8s/kustomization.yaml` |
| Inventory | di-generate Terraform, **jangan diedit manual** |

---

## Keamanan

Tidak ada kredensial di repo ini. `.gitignore` menutup `vault.yml`, `k8s/config/secret.yaml`,
`*.tfvars`, `terraform.tfstate*`, `.env`, kunci SSH, dan sertifikat. Yang di-commit hanya berkas
`*.example` berisi placeholder.

Role `security` bertag `always`, jadi ia jalan di setiap invokasi dan **menggagalkan playbook**
kalau berkas rahasia ternyata ter-track git. Ia baru bermakna sesudah `git add` + `git commit` —
di repo yang baru di-`init` tanpa commit, pemeriksaannya lolos secara hampa.

Verifikasi manual:

```bash
git ls-files | grep -E '(^|/)\.env|\.tfstate|\.tfvars$|vault\.yml$'   # harus KOSONG
```

---

## Catatan teknis yang menghemat waktu

- **Nested virtualization membuat semuanya lebih lambat.** Itu wajar. `kubeadm init` dan
  `helm install` yang menunggu pod Ready paling terasa — beberapa role sudah memakai timeout
  15–20 menit justru karena ini.
- **HAProxy di `8443`, bukan `6443`** — kube-apiserver sudah memegang 6443 di host yang sama.
- **`NEXT_PUBLIC_*` dibakar saat build**, tidak dibaca runtime. Nilai salah berarti *rebuild image*,
  bukan restart pod. Dockerfile frontend sengaja **gagal** kalau build-arg lupa dikirim.
- **Domain ditulis huruf kecil semua** (`commx.local.com`). DNS tidak peka huruf, tapi CORS peka:
  browser mengirim `Origin` dalam huruf kecil dan backend membandingkannya sebagai string. Kapital
  membuat login berhasil tapi chat tidak pernah tersambung — dan semuanya terlihat sehat.
- **Kyverno dipasang paling akhir.** Policy aktif menolak manifest bertag `latest` atau tanpa label
  wajib, dan penolakannya muncul di ArgoCD sebagai "sync failed" yang gampang disalahartikan
  sebagai masalah jaringan.
- **Drizzle tidak auto-migrate.** Tabel `users` dibuat Job PreSync (`k8s/postgres/migration-job.yaml`).
  Tanpanya semua pod Running dan login tetap gagal.
