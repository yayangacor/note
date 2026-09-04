# Bukti dari repo upstream Group A yang HIDUP (bukan zip)

Sumber: `github.com/LBRT87/ComMX` dan `github.com/Kne34/K2Help`, di-clone 2026-09-04.
Commit terakhir keduanya **2026-09-03**, jadi ini lebih baru dari zip di `Group A/`.

**Kenapa file ini ada.** `refs/GROUPA-CODE-MAP.md` memetakan *isi* zip. File ini memetakan
*pengalaman* — 30 error yang mereka temui sampai cluster benar-benar jalan end-to-end.
Nilainya beda: yang satu memberi tahu apa yang mereka tulis, yang satu memberi tahu apa yang
mereka **temukan salah setelah dijalankan**. Jangan clone ulang; ambil dari sini.

Sumber aslinya: `ComMX/md/Panduan-CICD-ComMX.md` (Bagian 7 = katalog error) dan
`ComMX/md/Ansible-Review-dan-Rekap.md`.

---

## 1. Kenapa ini bisa dipercaya lebih dari kode zip

Riwayat git `LBRT87/ComMX` memuat commit `CI Bot — ci: update image tag to <sha>` berkali-kali.
Itu bukan kode yang ditulis lalu diharapkan jalan: itu jejak pipeline yang benar-benar
mengeksekusi, mem-push image, dan commit balik. Judul commit manusianya juga berupa perbaikan
berurutan (`fix port frontend and backend ref port to 3000`, `fix add url rewrite`,
`fix: correct NEXT_PUBLIC_SOCKET_URL, remove backend-isolation policy`), yang cocok satu-satu
dengan katalog error mereka.

**Tetap berlaku [[R-01]].** Angka mereka bukan angka kita. Yang disalin mekanismenya.

---

## 2. Topologi mereka — dan apa artinya untuk [[Q-02]]

```
Subnet 192.168.3.x : cp-01 .21, cp-02 .23, worker-01 .20, worker-02 .24
Subnet 192.168.1.x : cp-03 .21, worker-03 .22
VM CI/CD (Forgejo) : 192.168.2.5
VIP apiserver      : 192.168.3.100:8443
MetalLB pool aktif : 192.168.3.200-220  (bukti: ComMX.local.com -> .203, Grafana -> .201)
MikroTik mereka    : 10.22.103.201
DNS                : 10.22.64.21 / .22
```

**Yang paling berguna buat kita:** MikroTik mereka `10.22.103.201`, MikroTik kita
`10.22.103.205`, dan DNS-nya sama persis dengan yang dikunci `case.md`. Artinya `10.22.103.0/24`
adalah **jaringan lab bersama tempat tiap kelompok menaruh MikroTik-nya**, dan subnet
`192.168.x.x` adalah jaringan privat yang mereka bikin sendiri **di belakang** MikroTik.

Konsekuensinya untuk Q-02: `10.22.103.205` hampir pasti sisi uplink, **bukan** subnet tempat VM
kita lahir. Itu memperkuat dugaan yang sudah ditulis, tapi belum menggantikan pengukuran —
`/ip address print detail` di MikroTik kita tetap wajib, karena yang menentukan bukan pola
tetangga melainkan konfigurasi kita sendiri.

Mereka juga memisahkan speaker MetalLB lewat grup inventory `[subnet3]`, karena node di subnet
1.x tidak punya interface di 3.x sehingga tidak bisa mengumumkan pool 3.x lewat ARP. Itu
konfirmasi lapangan untuk [[G-03]], dan pola yang sama sudah ada di inventory kita sebagai
grup `[speaker]`.

---

## 3. Katalog error mereka → status di kode kita

Kolom "kita" diisi dari pemeriksaan langsung repo kita pada 2026-09-04.

| # | Error mereka | Sebab | Di kita |
|---|---|---|---|
| E9 | `Cannot find module '/app/dist/main'` | output nest di `dist/src/` | **sudah beres** — kita ukur sendiri hari ini, [[G-05]] |
| E10/E11 | Redis CrashLoop `chown: Operation not permitted` | `drop: [ALL]` mencabut CAP_CHOWN, lost+found milik root | **sudah ada** — `fsGroup: 999` + initContainer `runAsUser: 0` + `runAsUser: 999` |
| E12 | Postgres `directory exists but is not empty ... lost+found` | init ditolak di root mount point | **sudah ada** — `PGDATA` subfolder |
| E8 | PVC Pending, StorageClass `local-path` tidak ada | cluster cuma punya longhorn | **sudah ada** — `storageClassName: longhorn` |
| E25 | Login 404 `Cannot POST /api/auth/login` | prefix `/api` tidak dilucuti | **sudah ada** — URLRewrite `ReplacePrefixMatch` |
| E26 | Login `connection timeout` | NetworkPolicy `backend-isolation` memblokir Envoy | **sudah aman** — kita hanya punya `commx-database-isolation`, persis kondisi akhir mereka |
| E14/E15 | `JwtStrategy requires a secret`, `ECONNREFUSED 6379` | env kurang | **sudah ada** — [[G-11]] [[G-16]] |
| E17/E18 | `server gave HTTP response to HTTPS client`, `x509 unknown authority` | containerd node tidak percaya registry | **sebagian** — kita pilih `registry_insecure: true` + `certs.d`; jalur TLS mereka belum kita punya |
| **E21** | GatewayClass `ACCEPTED: Unknown`, `tlsroutes CRD not found` | Cilium butuh 6 CRD; `standard-install` hanya 5 | ❌ **CACAT DI KITA** → [[G-20]] |
| **E22** | Gateway `Unable to create Service ... blocked by Kyverno` | Service `cilium-gateway-*` tidak punya label wajib | ❌ **CACAT DI KITA** → [[G-21]] |
| **E28** | Chat gagal walau socket URL benar | CORS case-sensitive, host di-lowercase browser | ❌ **CACAT DI KITA** → [[G-22]] |
| E27 | socket `Invalid namespace` | `NEXT_PUBLIC_SOCKET_URL` memuat `/frontend` | **cek saat CI** — nilai kita sudah tanpa `/frontend`, [[G-04]] |
| E24 | `no healthy upstream` | CiliumEnvoyConfig menyimpan port lama | catat sebagai gejala; obatnya hapus CEC + restart cilium-operator |
| E19 | node NotReady + apiserver crash-loop | efek samping restart Cilium | **pelajaran operasional**: jangan restart CNI sembarangan; obatnya restart containerd+kubelet di node terdampak |
| E20 | Kyverno webhook 0/1 | efek samping E19 | sembuh sendiri setelah Cilium stabil |
| E23 | Gateway `Invalid CertificateRef` | Secret `commx-tls-cert` belum dibuat | **sudah tercatat** sebagai kredensial yang belum ada |
| E13/E29 | pod pakai image tag lama | ArgoCD belum sync / selfHeal mati | kita sudah pakai `syncPolicy.automated` + `selfHeal` |
| E30 | `Failed to fetch` di PC lain | cert self-signed belum dipercaya browser, atau DNS PC salah | **masuk dokumentasi P09** — perlu langkah trust sekali per PC klien |
| E1–E7 | error pipeline: docker CLI, duplicate socket mount, base image tanpa node, disk penuh, Trivy cache/socket | lingkungan runner | → [[G-23]] |

---

## 4. Yang mereka temukan tidak lengkap di Ansible sendiri

Dari `Ansible-Review-dan-Rekap.md` bagian 2 — ditulis oleh mereka **tentang playbook mereka
sendiri**, jadi ini pengakuan, bukan tuduhan. Dua di antaranya juga ada di kita:

1. **Role `argocd` install ArgoCD tapi tidak pernah apply `Application`.** Akibatnya ArgoCD hidup
   tapi tidak tahu harus men-deploy apa — GitOps tidak otomatis, dan itu DoD. **Kita kena hal yang
   sama**: `k8s/argocd-app.yaml` ada, tapi `ansible/roles/argocd/tasks/main.yml` tidak meng-apply-nya.
2. **Nama secret registry tidak konsisten** (`registry-cred` vs `registry-credentials`) → ImagePullBackOff.
   **Kita aman**: `registry-credentials` dipakai konsisten di deployment dan role argocd.
3. Registry TLS + distribusi CA ke tiap node belum ada di Ansible mereka sama sekali.
4. Drizzle **tidak auto-migrate** — tabel `users` harus dibuat manual atau lewat Job. Terkait [[G-14]].

---

## 5. Perubahan di K2Help yang membatalkan satu baris dokumen kita

Role **`forgejo_host` sudah DIHAPUS** dari `Kne34/K2Help` (terlihat sebagai `D` di
`git log --name-status`; ia pernah ada, lalu dibuang pada rangkaian commit
"remove unnecessary things"). Yang tersisa 9 role: argocd, cluster, core_system, kubectl_client,
kyverno, load_balancer, metallb, monitoring, storage.

Artinya `refs/GROUPA-CODE-MAP.md` yang menyebut "10 role termasuk forgejo_host" dan [[D-08]] yang
menyebut sumbernya `K2Help/roles/forgejo_host/` **menggambarkan versi zip, bukan versi hidup**.
Keduanya tidak salah saat ditulis — tapi jangan mencari role itu di repo upstream dan menyimpulkan
dokumen kita bohong. Role `cicd_host` kita tetap sah; ia diturunkan dari versi zip.

Catatan praktik yang layak ditiru: `FinalAnsible/group_vars/all/vault.yml` mereka **ter-commit
dalam keadaan terenkripsi** (`$ANSIBLE_VAULT;1.1;AES256`). Itu memang cara yang benar, dan cocok
dengan langkah `ansible-vault encrypt` yang sudah kita rencanakan.

---

## 6. Hal yang TIDAK boleh disalin dari mereka

- Semua IP `192.168.x.x` mereka. [[R-01]].
- `group-2` di path image. Kita `Group-1` / kelompok 1.
- `repoURL` `http://192.168.2.5:3000/prk/tpaonsite.git`.
- Keputusan `basePath: /frontend` yang mereka pertahankan sampai akhir — mereka mengakses lewat
  `https://commx.local.com/frontend`, dan menandai "akses di root" sebagai pekerjaan yang belum
  rapi. Kita sudah memilih jalur redirect di HTTPRoute ([[G-06]]); jangan ikut mundur ke sana
  hanya karena itu yang terlihat "terbukti jalan".
