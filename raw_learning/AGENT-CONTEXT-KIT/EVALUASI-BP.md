# Evaluasi Sistem Konteks — Project BP (MinoXis)

> Audit terhadap direktori ini per 2026-09-03, memakai kriteria di `README.md`.
> Semua angka diukur, bukan diperkirakan.

---

## Ringkasan

Sistem yang ada di direktori ini **sudah termasuk yang paling matang** yang bisa dibangun tanpa
tooling khusus: pemisahan stateless/stateful, ledger ber-ID dengan 22 keputusan dan 75 gotcha,
router dokumen, unit kerja bergantung dependency, disiplin bukti yang eksplisit, dan — bagian
yang paling jarang ada di mana pun — **ledger koreksi kesalahan agent sendiri**.

Yang kurang bukan konsepnya, melainkan **higienenya**: file yang tumbuh melewati fungsinya, ID
yang bertabrakan, salinan basi yang ikut terjaring pencarian, dan satu lapis yang benar-benar
belum ada (traceability). Tujuh temuan, diurutkan berdasarkan dampak.

| # | Temuan | Dampak | Ongkos perbaikan |
|---|---|---|---|
| E1 | Tidak ada traceability requirement→bukti | **tinggi** | 1–2 jam |
| E2 | File auto-load 3× melewati anggaran | **tinggi** (tiap sesi) | 45 menit |
| E3 | Tabrakan & penyebaran ruang nama ID aturan | sedang-tinggi | 30 menit |
| E4 | 6 salinan basi mencemari pencarian | sedang | 5 menit |
| E5 | Ledger 4.346 baris tanpa indeks | sedang | 40 menit |
| E6 | Nilai yang disuperseded tidak distempel di sumbernya | sedang | 10 menit |
| E7 | Tidak ada version control | sedang | 2 menit |

---

## E1 — Tidak ada lapis traceability ⚠️ paling mahal

**Fakta.** `docs/plans/P09` §2 memuat audit requirement, tapi bentuknya **7 bullet kelompok**
("A. General — Place Note, hostname, SSH semua device, EtherChannel, VTP, SNMP, BGP, PAT, ...").
Satu checkbox menampung belasan requirement. Tidak ada kolom bukti, tidak ada tanggal.

**Kenapa ini masalah, dengan bukti dari project ini sendiri.** Dua kegagalan yang tercatat di
`CLAUDE.md` keduanya berbentuk requirement pasif yang gagal **tanpa gejala**:

- Aturan 31: `OUTSIDE-IN` di ASA "lengkap dan rapi sejak P03, tapi tidak punya satu pun permit ke
  DMZ — requirement inti CASE §82 tidak terpenuhi selama **tiga plan** tanpa gejala apa pun."
- G-50: `snmp-server` / `ntp` / `logging` ternyata tidak terpasang di **satu pun dari 17 switch**.
  Template B tidak pernah dieksekusi, dan tidak ada yang menyadarinya sampai audit menyeluruh.

Keduanya adalah kegagalan traceability, bukan kegagalan teknis. Aturan 31 sendiri sudah menuliskan
obatnya — *"baca ACL terhadap daftar requirement, bukan terhadap kesan rapi"* — tapi **daftarnya
belum pernah dibuat**. Aturannya ada; artefaknya tidak.

**Perbaikan.** `docs/TRACE.md` dari `templates/TRACE.md`. Satu baris per baris requirement
`CASE.md`, kolom Bukti diisi output mentah. Sebagian besar bisa diisi dari yang sudah ada:
`HANDOFF.md` sudah memuat 8 artefak demo dan daftar "demo yang sudah lunas" — itu bahan mentah
kolom Bukti, tinggal dipetakan ke nomor requirement.

**Nilai tambahannya di luar audit:** saat presentasi, tabel ini adalah jawaban langsung untuk
"requirement nomor sekian mana buktinya" — tanpa mencari di 6 dokumen.

---

## E2 — `CLAUDE.md` 3× melewati anggaran, isinya sebagian besar narasi sesi

**Fakta terukur.**

| File | Baris | Ukuran | Dibaca |
|---|---|---|---|
| `CLAUDE.md` | **734** | 46 KB | **tiap sesi, otomatis** |
| `docs/HANDOFF.md` | 635 | 46 KB | tiap sesi, manual |

Dari 734 baris `CLAUDE.md`, **371 baris (baris 230–600)** adalah narasi sesi: "SESI 6 — P07
SECURITY, tiga blok tegak", "Blok G LUNAS", "Gotcha sesi 5 juga: G-59 (...)", ringkasan hasil
per blok, dan daftar file `.pkt`. Isi ini **sudah ada** di `docs/plans/PXX` → Hasil Eksekusi dan
di `NOTES.md`, dan sebagian besar juga di `HANDOFF.md`.

Artinya: ~92 KB konteks dibaca tiap sesi, dengan overlap besar, untuk informasi yang mayoritasnya
tidak relevan dengan target sesi hari itu. Sesi yang mengerjakan P06 tetap membayar ringkasan
lengkap Blok G P05.

**Perbaikan.** `CLAUDE.md` disisakan tiga hal: aturan (dengan ID), konvensi + template baseline,
dan tabel progress satu baris per plan. Narasi per sesi pindah ke plan masing-masing (sudah ada di
sana) dan `HANDOFF.md`. Target ≤250 baris. Yang **jangan** dipindah: bagian "Baseline Config" dan
"Konvensi Penamaan" — itu memang milik lapis 2 dan memang dipakai berulang.

---

## E3 — Tiga daftar bernomor berbagi kata "aturan"

**Fakta.** Di dokumen ini hidup empat penomoran paralel:

| Daftar | Lokasi | Rentang |
|---|---|---|
| `R1`–`R9` "Aturan Kerja" | `CLAUDE.md` baris 23–58 | 9 entri |
| "Aturan baru dari P02..P07" | `CLAUDE.md` baris **352–410 dan 618–714** | 1–34 |
| "Catatan Penting" | `CLAUDE.md` baris 719+ | 1–7 |
| "BATAS YANG SEBENARNYA" | `HANDOFF.md` | 1–7 |

Dua akibat konkret:

1. **Rujukan jadi ambigu.** `HANDOFF.md` baris 87 menulis *"Aturan 7 berlaku untuk PANGGILAN API
   juga."* Pembaca yang membuka "Aturan 7" di `CLAUDE.md` menemukan **EtherChannel: buat Po1
   dulu** — tidak berhubungan. Yang dimaksud sebenarnya **butir 7 daftar "BATAS YANG SEBENARNYA"
   di HANDOFF** ("uji API asing di device sementara dulu"). Rujukan ini tidak bisa diselesaikan
   oleh pembaca yang tidak sudah tahu jawabannya.
2. **Urutan baca terbalik.** Aturan **28–34 tertulis di baris 352–410**, sedangkan aturan **1–27
   ada di baris 618–714** — jadi pembaca menemui aturan 28 ratusan baris sebelum aturan 1.

**Perbaikan.** Satu ruang nama: `R-01`..`R-34` pindah ke `NOTES.md` (mereka memang entri ledger —
tiap satunya lahir dari kesalahan yang bisa dilacak). `CLAUDE.md` menyisakan tabel pointer
"ID | inti satu kalimat". Selalu rujuk `R-07`, tidak pernah "aturan 7".

---

## E4 — 229 KB salinan basi ikut terjaring pencarian

**Fakta.** `docs/` berisi 6 file `HANDOFF.md.bak-*` berjumlah **229.208 byte** — hampir sebesar
`NOTES.md` (237 KB). Mereka tidak ditandai apa pun sebagai arsip dan hidup di direktori yang sama
dengan dokumen aktif.

**Dampak yang bisa diukur.** Pencarian `grep -rn "science" docs/` mengembalikan **36 hasil, 21 di
antaranya dari file `.bak`** — 58% pencemaran. Lebih buruk: `bak-20260902b/c/d` memuat
`PSK science` **tanpa** koreksi `science1`, jadi hasil pencarian yang paling banyak muncul justru
yang **salah**. Untuk kata "RADIUS", `bak-20260903` menyumbang 9 hit yang isinya keadaan kemarin.

Ini kelas kegagalan yang sama dengan yang sudah dicatat project ini sendiri: *"dokumen yang
menyimpan klaim salah lebih berbahaya daripada dokumen kosong"* (`HANDOFF.md`).

**Perbaikan.** `mkdir docs/archive && mv docs/HANDOFF.md.bak-* docs/archive/`, lalu satu baris di
`DOC-MAP.md` yang menyatakan `archive/` dikecualikan dari pencarian. Lima menit. Dengan E7 (git),
folder itu tidak perlu ada sama sekali.

---

## E5 — Ledger 4.346 baris tanpa indeks, dan sekat sectionnya sudah jebol

**Fakta.**

- `NOTES.md` = **4.346 baris**, 97 entri (22 `D-`, 75 `G-`). Tidak ada tabel indeks di kepalanya —
  file langsung masuk `## Keputusan Desain` lalu `### D-01`.
- Sekat section tidak lagi berlaku: `D-11` ada di **baris 1857**, `D-14` di 2244, `D-17` di 3258 —
  semuanya **di dalam** section `## Gotcha Packet Tracer` yang dimulai di baris 323. Entri
  di-append kronologis, section header-nya tidak diikuti.

**Dampaknya.** Satu-satunya cara menemukan sesuatu adalah `grep` dengan tebakan kata kunci. Padahal
gotcha dicari lewat **gejala** ("kenapa DHCP-nya gagal di menit pertama"), bukan lewat nama fitur.
Judul entri di file ini sudah bagus dan deskriptif — tinggal diangkat jadi indeks.

**Perbaikan.** Tabel indeks di kepala `NOTES.md`: `ID | gejala | status | tanggal`, diurutkan per
ruang nama. Bisa di-generate dari judul yang sudah ada. Section header dibiarkan sebagai penanda
kronologis, atau dihapus supaya tidak menyesatkan — indeksnya yang jadi jalan masuk.

---

## E6 — Nilai yang sudah dibatalkan masih berdiri di dokumen "kredensial terkunci"

**Fakta.** `docs/INSTRUCTION.md` §1 — dokumen yang oleh `HANDOFF.md` disebut *"SELURUH kredensial
terkunci"* — baris 39 masih berbunyi:

```
| SSID Shanghai research | `scholar` / `science` |
```

Padahal `D-18` (2026-09-02) mengganti PSK itu jadi `science1` karena WPA2-PSK menuntut 8 karakter.
Nilai lama masih berdiri di tempat yang paling otoritatif untuk kredensial. Proteksinya saat ini
berupa peringatan di `HANDOFF.md` baris 9–10 — yang berarti nilai yang benar **hanya sampai kalau
handoff dibaca lebih dulu**. Siapa pun yang membuka `INSTRUCTION.md` langsung akan membaca nilai
yang salah tanpa tanda apa pun. `NOTES.md` baris 2380 juga masih memuat `science` tanpa stempel.

**Perbaikan.** Supersession in-place:

```
| SSID Shanghai research | `scholar` / ~~`science`~~ → **`science1`** (D-18, 2026-09-02) |
```

Sepuluh menit, dan menghapus satu kelas kesalahan seluruhnya. Tambahkan juga aturan presedensi
tertulis (lapis 0 > ledger > charter > plan > handoff) — sekarang aturan itu ada, tapi hanya
tersirat lewat catatan "NOTES yang menang" di handoff.

---

## E7 — 500 KB konteks yang dirawat tangan, tanpa version control

**Fakta.** Direktori ini bukan repo git. Seluruh riwayat perubahan dokumen bergantung pada
penamaan manual `.bak-<tanggal>` (E4) dan file `.pkt` bernomor (R8).

**Dampaknya.** Tidak bisa menjawab "kapan baris ini berubah dan kenapa", tidak ada rollback per
file, dan `.bak` jadi satu-satunya jaring pengaman — yang justru menimbulkan E4. Untuk `.pkt`
(biner besar), penomoran manual memang wajar; untuk 500 KB markdown, tidak.

**Perbaikan.** `git init` + `.gitignore` untuk `pkt/*.pkt` (atau git-lfs). Dua menit, dan E4 hilang
dengan sendirinya.

---

## Yang sudah benar dan sebaiknya tidak diutak-atik

Supaya perbaikan di atas tidak merusak yang sudah bekerja:

| Praktik | Kenapa dipertahankan |
|---|---|
| **Ledger koreksi kesalahan agent** (`HANDOFF.md` §"pengamatan user mengalahkan teori" + "kesalahan AI murni") | Ini bagian paling berharga di seluruh sistem dan paling jarang ada di mana pun. Sembilan koreksi bertanggal, masing-masing dengan apa yang membongkarnya. Polanya sendiri sudah menghemat lebih banyak waktu daripada dokumentasi teknisnya. |
| **Gerbang stateless/stateful** | Alasan `NOTES.md` berisi 97 fakta terpakai, bukan 4.000 baris transkrip teori. |
| **Bukti mentah di entri gotcha** | Tabel "saat gagal vs sesudah konvergen" di G-56 bisa diaudit ulang orang lain. Itu standar yang benar. |
| **Aturan B1–B4 (bukti, kontrol negatif, ukur alat ukur)** | Lahir dari kegagalan nyata dan terbukti menangkap kesalahan berikutnya. Sudah diangkat jadi §6 framework. |
| **Klaim negatif menyebut yang sudah dicoba** | G-56 mencantumkan 14 varian nama yang diuji. Itulah yang membedakan fakta dari tebakan. |
| **DoD berupa 12 skenario demo, bukan daftar fitur** | Memaksa definisi selesai yang bisa diuji. |
| **Checklist GUI bernomor + cara verifikasi + nama tombol** | Menutup celah antara agent dan pekerjaan manusia. Detail "Add membuat baris baru, Save menimpa" itu presisi yang jarang. |

---

## Temuan kecil

- **`.claude/skills/` berisi 35 direktori kosong.** Isi skill sebenarnya ada di `.agents/skills/`
  (388 KB, 30 skill). Karena Claude Code membaca skill project dari `.claude/skills/`, investasi
  skill itu **tidak terjangkau** oleh agent yang membaca `CLAUDE.md`. Perlu disalin/di-symlink
  kalau memang ingin dipakai — atau direktori kosongnya dihapus supaya tidak menyesatkan.
- **`docs/HANDOFF.md` 635 baris** — melewati anggaran ~250. Sebagian isinya (peta API MCP, daftar
  "tidak bisa", perintah IOS yang tidak ada) sebenarnya **fakta lingkungan permanen**, bukan
  keadaan hari ini. Tempatnya di `NOTES.md` sebagai entri `G-xx`; handoff cukup menunjuk ID-nya.

---

## Urutan yang disarankan

Kalau hanya sempat sebagian, urutan ini memberi hasil terbesar lebih dulu:

1. **E7 + E4** (7 menit) — git init, arsipkan `.bak`. Menghilangkan pencemaran pencarian.
2. **E6** (10 menit) — stempel supersession. Menghapus satu kelas kesalahan.
3. **E1** (1–2 jam) — `TRACE.md`. Ini yang paling berpengaruh ke nilai akhir, dan sekaligus jadi
   artefak presentasi.
4. **E3 + E2** (75 menit) — konsolidasi aturan ke `R-xx`, ramping-kan `CLAUDE.md`.
5. **E5** (40 menit) — indeks gejala di ledger.
