# P07 — Forgejo + registry + runner + ArgoCD + pipeline

**Status:** 📝 kode lengkap (workflow + role argocd sudah meng-apply Application, [[D-16]]), **nol perintah dijalankan** · **Dependency:** P05 · **Blokir:** [[Q-05]] host Forgejo, dan [[G-18]]/[[G-19]] untuk bisa menjalankan playbook sama sekali

Kode: `.forgejo/workflows/ci.yaml`, `k8s/argocd-app.yaml`.
Referensi: `K2Help/roles/forgejo_host/` (compose) dan `ComMX-main/.forgejo/workflows/ci.yml` (tahapan).

## Arsitektur ([[D-08]])

VM Ubuntu **di luar cluster** menjalankan `forgejo` + `registry:2` + `forgejo-runner` lewat
Docker Compose di `/opt/cicd`. ArgoCD di **dalam** cluster. Alasannya: kalau cluster di-reset,
sumber kebenaran dan image tetap selamat.

Bisa dikerjakan **paling awal**, paralel dengan P01–P05 — tidak bergantung cluster.

## Bagian 1 — Stack CI/CD

- `docker-compose.yml`: forgejo (port 3000 + 2222), registry:2 dengan `REGISTRY_AUTH=htpasswd`,
  runner dengan mount `/var/run/docker.sock`.
- htpasswd: `Group-1` / `kelargacor`, bcrypt. Baris contoh di `help/.misc/forgejo-docs.md` kebetulan
  sudah memakai `Group-1` — untuk kita itu benar, tapi pastikan itu keputusan, bukan warisan salin-tempel.
- Aktifkan Forgejo Actions (`[actions] ENABLED = true`).
- Registrasi runner butuh token dari UI Forgejo — langkah manual sekali, catat di dokumentasi.
- Semua node cluster harus mempercayai registry ini (P03 langkah 3).

## Bagian 2 — Perbaikan pipeline

Workflow sekarang jalan lewat `appleboy/ssh-action` ke PC lalu `docker build` di sana. Itu bekerja,
tapi tiga hal harus diperbaiki dan satu keputusan harus diambil:

1. **Tahapan yang hilang** (case menuntut 6 tahap berurutan):
   GitLeaks dan Semgrep belum ada; Trivy image scan hanya untuk backend, frontend terlewat;
   Checkov (IaC scan) belum ada sama sekali.
2. **Build-arg frontend wajib** ([[G-04]]):
   ```
   docker build \
     --build-arg NEXT_PUBLIC_SOCKET_URL=wss://ComMX.local.com \
     --build-arg NEXT_PUBLIC_BACKEND_URL=https://ComMX.local.com/api \
     -t <registry>/commx-frontend:<tag> ./frontend
   ```
   Dockerfile frontend harus diberi `ARG`+`ENV` dulu — tanpa itu build-arg diabaikan diam-diam.
3. **Update manifest tidak akan mengenai apa pun.** Workflow menjalankan
   `sed -i "s/v0.0.0/<tag>/g"` pada `k8s/backend-development.yaml`, padahal manifest berisi
   `image: commx-backend` polos — literal `v0.0.0` tidak ada di file. Jadi `sed` sukses,
   `git commit` gagal ("nothing to commit"), dan **pipeline tetap hijau**. Ini persis pola [[G-13]].
   Perbaikannya: pakai `kustomize edit set image commx-backend=<registry>/commx-backend:<tag>`
   (menyunting `kustomization.yaml`, satu sumber kebenaran), atau `sed` dengan pola yang benar-benar
   ada. Lalu **verifikasi** commit-nya benar terjadi:
   `git diff --exit-code` harus mengembalikan kode ≠ 0 sebelum commit.
4. **Keputusan yang perlu diambil dan dicatat sebagai D-xx:** build lewat SSH ke PC, atau lewat
   runner container? SSH lebih gampang berhasil di lingkungan terbatas, tapi menambah rahasia
   (SSH key) dan membuat build bergantung pada satu PC. Apa pun pilihannya, tulis alasannya —
   case menuntut setiap perintah bisa dijelaskan.

## Bagian 3 — ArgoCD

- Helm install ke namespace `argocd`, `server.service.type=LoadBalancer` (dapat IP dari MetalLB).
- Ambil password awal dari Secret `argocd-initial-admin-secret`.
- ~~`Application` perlu dibuat manual~~ → **role `argocd` yang meng-apply Application** sejak
  2026-09-04 ([[D-16]]). `repoURL` dirakit dari `vars.yml`, bukan ditulis di manifest.
  `k8s/argocd/application.yaml` turun jadi cadangan jalur manual dan sudah diberi stempel.
- ~~**Perbaiki:** `destination.namespace` `commx` vs manifest `commx-prod`~~ → **sudah sama**,
  keduanya `commx-prod` (`app_namespace` dan `namespace:` di `kustomization.yaml`), diverifikasi 09-04.
- ~~Repo privat butuh kredensial repo di ArgoCD, bukan hanya URL~~ → **role sudah membuat Secret**
  `repo-forgejo-commx` dari `forgejo_repo_user`/`forgejo_repo_token` di vault. Kalau token kosong
  role **memperingatkan**, tidak skip diam-diam. Isi token kalau repo Forgejo dibuat privat.
- Yang tersisa untuk dikerjakan di mesin: buat token di Forgejo
  (Settings → Applications → Generate Token, scope `read:repository`), isi ke vault, lalu buktikan
  ArgoCD benar-benar bisa fetch — `Synced`, bukan `ComparisonError`.

## Definition of Done

- [ ] Forgejo bisa dibuka, repo ComMX ter-push, branch `main` dan `dev` ada.
- [ ] `docker login <registry>` berhasil dengan `Group-1`; `docker push` sebuah image uji berhasil.
- [ ] **Dari node worker** (bukan dari VM CI/CD): `ctr -n k8s.io images pull` image itu berhasil.
- [ ] Push commit ke `main` → workflow jalan dan **semua 6 tahap hijau**, tempel ringkasan log.
- [ ] **Kontrol negatif scan:** tambahkan sementara sebuah dummy secret ke repo di branch uji →
      GitLeaks **gagal**. Kalau tidak pernah gagal, tahap scan tidak membuktikan apa pun.
- [ ] Commit tag baru benar-benar muncul di repo (`git log -1` menampilkan commit dari CI bot),
      dan tag-nya bukan `latest`.
- [ ] ArgoCD `Synced` + `Healthy`; `kubectl get deploy -o jsonpath` menunjukkan image dengan tag baru.
- [ ] **Uji end-to-end:** ubah satu teks di frontend → push → tunggu → teks berubah di browser
      tanpa satu pun perintah manual. Ini DoD #5 di `INSTRUCTION.md`.

## Hasil eksekusi

_(kosong)_
