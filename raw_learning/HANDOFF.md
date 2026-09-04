# HANDOFF — keadaan setelah sesi 2 (ditutup 2026-09-04)

**Ditulis ulang dari nol tiap akhir sesi.** Jangan menambah di bawah.

---

## a. Urutan baca untuk sesi berikutnya

1. `CLAUDE.md` — aturan + tabel progress + **dua gerbang verifikasi** (auto-load, gratis).
2. File ini.
3. `DOC-MAP.md` → tentukan plan mana yang relevan. Sebutkan pilihannya sebelum membaca.
4. Indeks gejala di kepala `NOTES.md` — cari lewat **gejala**, jangan baca seluruh ledger.
5. Plan yang aktif saja.

**Jangan** buka zip Group A lagi, dan **jangan** clone ulang repo upstream — semuanya sudah
diekstrak ke `NOTES.md`, `refs/GROUPA-CODE-MAP.md`, dan `refs/UPSTREAM-EVIDENCE.md`.

## b. Keadaan sekarang

Semua plan kecuali P01 dan P09 berstatus `📝`: **kode lengkap, nol perintah pernah dijalankan
di cluster mana pun.** Yang berubah dari sesi 1 bukan status itu, melainkan seberapa banyak yang
sudah **dibuktikan tanpa mesin**.

**Yang benar-benar diukur hari ini** (bukan dibaca, bukan disimpulkan):

| Apa | Alat | Hasil |
|---|---|---|
| Output `nest build` | `docker build` + `ls -R /app/dist` | `dist/src/main.js`, bukan `dist/main.js` → [[G-05]] ditutup |
| Env backend | `grep process.env backend/src/` | 6 env, cocok [[G-11]]; DB kosong = mati saat import [[G-16]] |
| uid image postgres | `docker run --entrypoint id` | alpine **70**, debian **999** |
| Rakitan manifest | `kubectl kustomize k8s/` | 16 dokumen, rc 0 → [[G-08]] ditutup |
| Policy + rujukan silang | `scripts/validate-manifests.py` | 0 pelanggaran, kontrol negatif lulus |
| Semua template Ansible | `scripts/render-templates.py` | 7 template, 0 gagal |
| Config Alertmanager | render `values.yaml.j2` | SMTP + App Password + **7 penerima** keluar benar |
| Urutan CI baru | `docker run` dua container | kustomize 16 dokumen, gerbang exit 0 |

**Dua gerbang baru, keduanya menguji dirinya sendiri lebih dulu** — perintahnya ada di `CLAUDE.md`.
Jalankan sebelum apply atau push apa pun.

**Q terbuka:**

| ID | Status |
|---|---|
| [[Q-01]] nomor kelompok | ✅ kelompok 1 |
| [[Q-03]] jadwal backup | ✅ 12:00 siang, `0 12 * * *` |
| [[Q-04]] email alert | ✅ **ditutup** — App Password + 7 alamat di vault, render terbukti |
| [[Q-02]] IP & subnet | ❌ **penghambat utama** — butuh output MikroTik |
| [[Q-05]] host Forgejo | ❌ Forgejo belum diinstall sama sekali |

## c. Langkah berikutnya

**Tiga langkah ini tidak menunggu apa pun dan memblokir SEMUA yang lain** ([[G-18]], [[G-19]]):

```bash
cd "/mnt/d/_WORK/ASLAB/TPA/NET/ONSITE/learning/Group B/ComMX-Forgejo"
git init && git add -A && git commit -m "baseline sesi 1+2"
git ls-files | wc -l                                    # LULUS: != 0
git ls-files | grep -E 'vault\.yml$|\.env|\.tfstate'    # LULUS: kosong

sudo apt install -y ansible                             # di WSL Ubuntu
cd ansible && ansible-galaxy collection install -r requirements.yml
ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519
ansible-vault encrypt group_vars/all/vault.yml
```

`git init` **tanpa commit tidak cukup** — `git ls-files` kosong membuat role `security` lolos
secara hampa. Lihat [[G-18]].

**Untuk [[Q-02]], jalankan di Winbox → New Terminal dan tempel hasilnya:**

```
/ip address print detail
/ip route print where dst-address=0.0.0.0/0
/ip pool print
/ip dhcp-server network print
```

Dari `refs/UPSTREAM-EVIDENCE.md`: MikroTik Group A `10.22.103.201`, kita `10.22.103.205`, DNS sama
persis. Jadi `10.22.103.0/24` adalah **uplink lab bersama**, dan subnet `192.168.x.x` dibangun
sendiri **di belakang** MikroTik. Placeholder `192.168.10.x` kita mungkin tidak perlu diubah sama
sekali — tapi itu tetap harus diukur, bukan disimpulkan dari pola tetangga.

**Urutan eksekusi begitu ada mesin:** P01 (Proxmox, manual GUI) → P02 → `--tags cicd` → `--tags
core` → `--tags lb` → **buktikan VIP hidup** → `--tags init`. Jangan pernah membalik dua yang
terakhir ([[G-12]]).

## d. Jebakan yang aktif hari ini

- **Urutan `--tags` tidak boleh dilompati.** `--tags init` sebelum `--tags lb` terbukti hidup
  menanam VIP salah di sertifikat; obatnya hanya `kubeadm reset` semua node.
- **`--tags cicd` wajib sebelum `--tags core`** kalau `registry_insecure: false` ([[D-22]]) —
  sertifikat registry lahir di VM CI/CD dan node menyalinnya dari sana.
- **Semua nilai jaringan masih placeholder.** `terraform apply` sekarang membuat 6 VM di
  `192.168.10.x` yang belum diverifikasi.
- **`vault.yml` masih POLOS.** Sudah ditutup `.gitignore`, tapi itu bukan pengganti enkripsi.
- **`forgejo_repo_token` masih kosong** dan itu benar — Forgejo belum ada. Role `argocd`
  memperingatkan, tidak skip diam-diam.
- [[G-25]] Job CI yang memanggil `docker run` wajib punya step `Siapkan Docker CLI`.
- [[G-15]] Jangan menulis file panjang lewat heredoc Bash di project ini.

## e. Koreksi ledger — di mana kesimpulan agent keliru hari ini

1. **DUA KALI melaporkan template Ansible "rusak" padahal sehat.** Pertama `bool`/`to_json`,
   lalu `contains` plus `hostvars` tiruan yang cuma berisi 2 dari 7 host. Ketiganya filter/test
   **milik Ansible**, bukan Jinja2 polos. Kalau laporan itu dipercaya, tiga role sehat akan
   "diperbaiki" tanpa sebab. **Polanya: sebelum menyimpulkan sesuatu rusak, jalankan alat ukurnya
   pada kasus yang sudah terbukti bekerja (B4).** Peringatan ini sekarang dicetak skripnya sendiri.

2. **Mencurigai label `metallb-speaker` tidak terpakai.** Terlihat seperti pola cacat yang sama
   dengan yang lain hari itu. Ternyata `pool.yaml.j2` memang memakainya lewat
   `L2Advertisement.nodeSelectors` — mekanisme yang benar. **Polanya: kecurigaan yang beruntun
   benar beberapa kali mulai terasa seperti bukti. Tetap periksa.**

3. **Menulis scope token `read:repository`.** Benar untuk dua token terpisah, **salah** begitu
   user memilih satu token untuk CI + ArgoCD — CI mem-push, jadi wajib `write`. Kalau tidak
   ketahuan, tahap 6 pipeline gagal di `git push` dengan pesan yang tidak menyebut scope.

4. **Memakai `postgres:16-alpine` dengan `runAsUser: 999`.** Diukur: alpine uid **70**, debian
   **999**. Diganti ke `postgres:16.4`, image yang sama persis dengan StatefulSet.

5. **Menyebut `10.22.103.205` "hampir pasti salah subnet" untuk VM.** Terlalu keras. Bukti
   upstream menunjukkan itu memang uplink lab, dan subnet privat di belakangnya dibangun sendiri —
   jadi placeholder kita tidak sekonyol yang saya bilang.

6. **Emoji di `print()` skrip** → `UnicodeEncodeError` di konsol Windows **setelah** semua
   pemeriksaan lolos, sehingga terlihat seperti gerbangnya menolak padahal lulus.

**Koreksi yang ditemukan di dokumen, bukan kesalahan hari ini:** `TRACE.md` C-6 dan C-8 berstempel
`✅` padahal nol perintah dijalankan — keduanya diturunkan ke `📝`/`🚧`. `A-6` menulis "14 role"
padahal daftarnya 16 dan sekarang 17. **Stempel `✅` yang berasal dari membaca kode, bukan dari
menjalankannya, ternyata ada lebih dari satu. Curigai baris `✅` mana pun yang kolom Bukti-nya
tidak memuat output mentah.**

## f. Satu hal yang belum terverifikasi dan gampang disalahartikan sebagai selesai

**Kedua gerbang hijau, dan itu bisa terasa seperti "sudah beres".** Bukan. Keduanya memeriksa
**bentuk**: bahwa manifest merakit, policy tidak dilanggar, rujukan nyambung, template merender.
Tidak satu pun dari itu membuktikan Cilium naik, VIP berpindah, Longhorn mengikat volume, Kyverno
benar-benar menolak, email benar-benar sampai, atau WSS terbentuk di browser.

Bahaya konkretnya: sesi berikutnya melihat dua skrip `exit 0`, 17 role rapi, dan 26 baris `TRACE`
bertanggal hari ini, lalu memperlakukan `📝` sebagai `✅`. Yang benar-benar terbukti hari ini
hanya delapan baris di tabel bagian (b) — semuanya berjalan di **laptop**, tidak satu pun di
cluster, dan clusternya sendiri belum ada.
