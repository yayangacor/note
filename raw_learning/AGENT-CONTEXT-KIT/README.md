# LRC — Ledger-Routed Context

> Framework manajemen memori/konteks untuk kerja panjang bersama AI agent, diekstrak dari
> project **TPA Network 26-1 (MinoXis)** — 7 sesi, ~500 KB dokumen, 22 keputusan dan 74 gotcha
> terekam, dikerjakan solo dengan agent sebagai eksekutor.
>
> Isi folder ini **domain-agnostik**. Bisa dipakai untuk case jaringan, coding, riset, skripsi,
> audit — apa pun yang: (a) lebih panjang dari satu sesi, (b) punya requirement eksternal yang
> tidak boleh dilanggar, (c) dikerjakan bersama agent yang lupa segalanya tiap sesi.

---

## 1. Masalah yang dipecahkan

Agent tidak punya memori antar sesi. Tiga kegagalan yang muncul karena itu:

| Kegagalan | Bentuknya | Ongkosnya |
|---|---|---|
| **Amnesia** | keputusan yang sudah diambil diulang, diperdebatkan lagi, atau dibalik diam-diam | jam kerja + hasil tidak konsisten |
| **Halusinasi lingkungan** | agent yakin sebuah perintah/API ada, padahal tool-nya tidak punya | putaran diagnosis buta |
| **Ledakan konteks** | semua dokumen dibaca tiap sesi "supaya aman" | jendela konteks habis sebelum kerja dimulai |

LRC menjawab ketiganya dengan tiga mekanisme: **ledger** (fakta ber-ID, ditulis sekali, dirujuk
selamanya), **router** (peta topik→dokumen, supaya tidak membaca semuanya), dan **gerbang
stateless/stateful** (filter apa yang layak ditulis).

**Prinsip inti:** dokumen bukan tempat menyimpan *pengetahuan*. Pengetahuan sudah ada di model.
Dokumen adalah tempat menyimpan **apa yang tidak bisa ditebak ulang**: keputusan yang kamu ambil,
perilaku nyata tool yang kamu ukur, dan bukti bahwa sesuatu benar-benar jalan.

---

## 2. Enam lapis

Setiap lapis punya satu pemilik, satu tingkat volatilitas, dan satu batas ukuran. Batas ukuran itu
bukan estetika — lapis 2 dibaca **setiap sesi tanpa kecuali**, jadi tiap barisnya dibayar berulang.

| # | Lapis | File umum | Volatilitas | Batas | Yang boleh menulis |
|---|---|---|---|---|---|
| 0 | **Sumber** | `CASE.md` / `REQUIREMENTS.md` | **beku** | — | tidak ada (transkrip apa adanya) |
| 1 | **Charter** | `INSTRUCTION.md` | jarang | ~300 baris | manusia; agent hanya menambah konstanta terkunci |
| 2 | **Aturan operasi** | `CLAUDE.md` / `AGENTS.md` | sedang | **≤250 baris** | agent, tiap akhir sesi |
| 3 | **Router** | `DOC-MAP.md` | jarang | ~150 baris | siapa pun yang menambah dokumen |
| 4 | **Ledger** | `NOTES.md` + `TRACE.md` | append-only | bebas, **wajib berindeks** | agent, tiap temuan |
| 5 | **Unit kerja** | `plans/PXX-*.md` | per-plan | ~500 baris/plan | agent, saat mengeksekusi |
| 6 | **Jembatan sesi** | `HANDOFF.md` | **ditulis ulang tiap sesi** | ~250 baris | agent, saat sesi ditutup |

Aturan yang menyatukannya: **satu fakta hidup di satu lapis saja.** Lapis lain merujuk dengan ID,
tidak menyalin. Salinan adalah calon kontradiksi.

### Kenapa lapis 6 terpisah dari lapis 2

`CLAUDE.md` auto-load; `HANDOFF.md` tidak. Godaannya menaruh status terbaru di `CLAUDE.md` supaya
"pasti terbaca". Akibatnya file auto-load berubah jadi buku harian: di project asal ia tumbuh ke
**734 baris / 46 KB**, sekitar 60% berupa narasi sesi, dan **dibayar tiap sesi selamanya** —
termasuk sesi yang tidak menyentuh topik itu sama sekali.

Pembagian yang benar:

- `CLAUDE.md` = **aturan yang berlaku selamanya** + tabel progress satu baris per unit kerja.
- `HANDOFF.md` = **keadaan hari ini**: apa yang baru selesai, apa yang rusak, langkah berikutnya.

---

## 3. Tabel routing tulis

Ini jantung framework. Sebelum menulis apa pun, agent menjawab: *jenis informasi ini apa?*

| Jenis informasi | Rumahnya | ID |
|---|---|---|
| Requirement asli dari klien/soal | lapis 0 — **jangan diubah** | kutip nomor baris |
| Peran agent, DoD, prioritas, kredensial terkunci | Charter | — |
| Aturan kerja yang lahir dari kesalahan | Ledger, pointer di lapis 2 | `R-xx` |
| Keputusan desain + alasan + konsekuensi | Ledger | `D-xx` |
| Perilaku nyata tool/lingkungan yang diukur | Ledger | `G-xx` |
| Pertanyaan terbuka ke stakeholder | Ledger | `Q-xx` |
| Bukti bahwa requirement N terpenuhi | `TRACE.md` | `T-<req>` |
| Langkah eksekusi, scope, DoD per tahap | Unit kerja | `PXX` |
| Status hari ini, langkah berikutnya | Jembatan sesi | — |
| Teori, penjelasan konsep, tanya-jawab | **tidak ditulis ke mana pun** | — |

Baris terakhir itu yang paling sering dilanggar dan paling mahal.

---

## 4. Gerbang stateless / stateful

Sebelum menulis, satu pertanyaan:

> **"Besok, atau saat presentasi/serah terima, apakah informasi ini dibutuhkan lagi — dan apakah ia
> bisa ditebak ulang oleh agent tanpa dokumen ini?"**

- Dibutuhkan lagi **dan** tidak bisa ditebak ulang → **STATEFUL**, tulis sesuai tabel routing.
- Selain itu → **STATELESS**, buang.

Penjelasan teori ("apa itu VTP", "bedanya X dan Y") hampir selalu stateless: model sudah tahu, dan
menuliskannya membengkakkan konteks yang dibayar tiap sesi. Yang stateful bukan teorinya, melainkan
**keputusan yang kamu ambil berdasarkan teori itu**.

---

## 5. Ledger: format entri

Satu entri = satu fakta ber-ID, ditulis sekali, dirujuk dari mana-mana. Empat ruang nama:

| Prefix | Isi | Pertanyaan yang dijawabnya |
|---|---|---|
| `D-xx` | Keputusan desain | "kenapa dulu kita pilih ini?" |
| `G-xx` | Gotcha / fakta lingkungan terukur | "apakah tool ini benar-benar bisa X?" |
| `R-xx` | Aturan kerja hasil kesalahan | "bagaimana supaya tidak terulang?" |
| `Q-xx` | Pertanyaan terbuka | "apa yang masih menunggu jawaban orang lain?" |

Template entri (versi lengkap di `templates/LEDGER.md`):

```markdown
### G-42 — <klaim dalam satu kalimat> ✅ TERVERIFIKASI (2026-09-02, sesi 5)

**Gejalanya.**  apa yang terlihat di layar
**Ukurannya.**  perintah/panggilan yang dijalankan + output apa adanya
**Sebabnya.**   penjelasan sependek mungkin
**Refleksnya.** apa yang harus dilakukan lain kali
**Terkait.**    [[G-33]] [[R-22]]
```

Empat hal yang **wajib** ada, dan alasannya:

1. **Status + tanggal** (`✅ TERVERIFIKASI` / `⚠️ SEBAGIAN` / `❌ DIBANTAH`). Fakta lingkungan basi
   diam-diam saat tool di-update. Tanpa stempel, pembaca tidak tahu boleh percaya sejauh apa.
2. **Bukti mentah**, bukan ringkasan. "SSH berhasil" tidak bisa diaudit; `SZ-ACC-GF-01#` bisa.
3. **Klaim negatif harus menyebut apa yang sudah dicoba.** "API ini tidak ada" tanpa daftar varian
   nama yang diuji adalah tebakan yang menyamar jadi fakta — dan begitu masuk dokumen, sesi
   berikutnya mewarisinya sebagai kebenaran. Di project asal ini terjadi **dua kali**.
4. **Link `[[ID]]`** ke entri terkait. Gotcha datang berumpun; yang satu sering membatasi yang lain.

**Append-only.** Entri tidak dihapus. Kalau terbukti salah, ubah statusnya jadi
`❌ DIBANTAH oleh [[G-58]]` dan biarkan. Entri yang dihapus akan ditemukan ulang dengan ongkos yang
sama persis.

### Indeks wajib

Begitu ledger lewat ~50 entri, judul saja tidak cukup — orang mencari gotcha lewat **gejala**, bukan
lewat nama. Taruh tabel indeks di kepala file dan perbarui tiap append:

```markdown
| ID | Gejala yang kamu lihat | Status | Tgl |
|---|---|---|---|
| G-56 | "DHCP request failed" di menit pertama sesudah kabel baru ditarik | ✅ | 09-02 |
```

---

## 6. Disiplin bukti — empat aturan yang tidak bisa ditawar

Bagian yang paling gampang dilewati dan paling mahal ketika dilewati. Keempatnya lahir dari
kegagalan nyata, bukan dari teori.

**B1. Config tersimpan ≠ fitur jalan.**
Sebuah pool DHCP lolos setiap pembacaan config dan tetap tidak melayani satu pun request. Verifikasi
yang sah selalu berbentuk **klien yang benar-benar menerima hasil**, bukan konfigurasi yang terbaca
rapi.

**B2. Perintah diterima ≠ perintah tersimpan.**
Mode gagal paling berbahaya adalah tool yang menerima input, tidak melempar error, dan tidak
menyimpan apa-apa. Refleksnya satu: **baca ulang nilainya dari sumber otoritatif**, jangan percaya
ketiadaan error.

**B3. Tes yang lulus tanpa kontrol negatif bukan bukti.**
Kalau kredensial yang sama juga ada di database lokal, login yang berhasil tidak membuktikan server
terpusat dipakai. Buktinya adalah **kembarannya yang tidak terdaftar harus GAGAL**, lalu hidup lagi
sesudah didaftarkan. Berlaku umum: tes yang tidak pernah bisa gagal tidak mengukur apa pun.

**B4. Ukur alat ukurnya dulu.**
Klien uji bisa rusak; port bisa belum forwarding; ping bisa menjawab pertanyaan yang berbeda dari
yang ditanyakan. Sebelum melaporkan "fitur X tidak ada", jalankan alat ukur yang **sama** pada kasus
yang **sudah terbukti bekerja**. Kalau kontrolnya ikut gagal, yang rusak alat ukurnya. Di project
asal, dua kegagalan berlawanan penyebab menghasilkan output **identik**; hanya kontrol yang
memisahkannya.

> Turunan B4 yang layak ditempel di dinding: **kalau gejalanya menyamar, aturan tertulis pun gagal
> dipakai — termasuk aturan yang baru saja kamu tulis untuk kasus itu.** Penawarnya bukan membaca
> lebih teliti, melainkan mengukur.

---

## 7. Traceability: `TRACE.md`

Lapis yang **paling sering absen** dan paling mahal ketika absen.

Requirement pasif — yang tidak punya gejala ketika dilanggar (logging, SNMP, banner, audit trail,
lisensi, header, aturan penamaan) — bisa gagal berbulan-bulan tanpa satu pun tanda. Di project asal,
sebuah ACL yang "sudah ada dan rapi" ternyata tidak punya satu pun baris yang memenuhi requirement
intinya; itu bertahan **tiga plan** tanpa gejala. Di kejadian lain, baseline config ternyata tidak
pernah terpasang di **satu pun dari 17 perangkat**.

Penawarnya bukan kehati-hatian, melainkan **satu tabel dengan satu baris per requirement**:

```markdown
| Req | Bunyi (potongan) | Status | Di mana dipenuhi | Bukti | Tgl |
|---|---|---|---|---|---|
| §82  | internet hanya boleh HTTP+SMTP ke DMZ | ✅ | ASA `OUTSIDE-IN` | `telnet .50.10 80` Open; `21` timeout | 09-02 |
| §112 | AAA untuk semua network device | ⚠️ 19/24 | 3 region | kontrol negatif [[G-71]] | 09-03 |
```

Aturannya: **audit dijalankan terhadap daftar, bukan terhadap kesan.** Membaca artefak lalu merasa
"kelihatannya lengkap" bukan audit. Audit adalah menelusuri baris requirement satu per satu dan
menuntut bukti untuk masing-masing.

---

## 8. Ritual sesi

Framework ini hidup dari tiga ritual. Kalau hanya satu yang sanggup dijalankan, jalankan yang
penutup.

### Buka (≤5 menit, hemat konteks)

1. Baca lapis 2 (`CLAUDE.md`) — auto-load, gratis.
2. Baca lapis 6 (`HANDOFF.md`) — keadaan hari ini.
3. Buka router (lapis 3), tentukan **dokumen mana saja** yang relevan hari ini.
4. Baca unit kerja aktif + dependency-nya. **Jangan** baca semua unit kerja.

### Selama

- Temuan lingkungan → ledger `G-xx` **saat itu juga**, jangan ditunda ke akhir sesi.
- Keputusan → `D-xx` lengkap dengan alasan dan konsekuensi.
- Tiap langkah selesai → catat buktinya di unit kerja + perbarui baris `TRACE.md`.

### Tutup (wajib, ~10 menit)

1. Update status unit kerja + tabel progress lapis 2.
2. Append entri ledger baru + perbarui indeksnya.
3. Perbarui `TRACE.md` untuk requirement yang tersentuh hari ini.
4. **Tulis ulang `HANDOFF.md` dari nol.** Bukan menambah di bawah — menulis ulang. Handoff yang
   ditumpuk berubah jadi arsip dalam tiga sesi.
5. Cek anggaran: lapis 2 masih ≤250 baris? Kalau lewat, pindahkan narasinya ke ledger.

---

## 9. Presedensi & supersession

Dokumen banyak = kontradiksi pasti terjadi. Yang menentukan bukan niat baik, melainkan aturan
tertulis. Urutan menang, dari yang paling kuat:

```
lapis 0 (sumber)  >  Ledger (entri D/G terbaru)  >  Charter  >  Unit kerja  >  Handoff
```

Dengan satu pengecualian yang wajib ditulis eksplisit: **kalau lapis 0 tidak bisa dieksekusi**
(requirement bertabrakan dengan dirinya sendiri, atau dengan batas teknis di luar kendali),
menang-nya jatuh ke entri `D-xx` yang membuat requirement itu **bisa didemokan**, dan alasannya
wajib ditulis supaya deviasinya bisa dibela.

**Aturan supersession — yang paling sering dilupakan:** saat sebuah nilai diganti, **stempel di
tempat nilai lamanya berada**, bukan hanya di entri barunya.

```markdown
| PSK Shanghai | ~~`science`~~ → **`science1`** — diganti [[D-18]] 2026-09-02 |
```

Kalau tidak, nilai lama tetap terbaca oleh siapa pun yang membuka dokumen itu langsung — dan
proteksinya hanya berupa peringatan di file volatil yang mungkin tidak dibaca. Di project asal
persis ini terjadi: charter masih memuat nilai yang sudah dibatalkan sejak sesi 4.

---

## 10. Anti-pattern

Sepuluh hal ini semuanya teramati di project nyata. Tiap barisnya sudah pernah dibayar.

| # | Anti-pattern | Gejala | Penawarnya |
|---|---|---|---|
| A1 | File auto-load jadi buku harian | lapis 2 > 400 baris, isinya narasi sesi | pindahkan ke ledger; sisakan aturan + pointer |
| A2 | Ruang nama ID bertabrakan | ada "Aturan 7", "R7", dan "batas nomor 7" di tiga dokumen | **satu** ruang nama ber-prefix; rujuk `R-07` |
| A3 | Aturan bernomor tersebar | aturan 28–34 tertulis di atas aturan 1–27 | semua aturan di ledger, urut, satu tempat |
| A4 | Backup di dalam pohon yang di-grep | `X.md.bak-*` bertebaran | pakai git; atau `archive/` yang dikecualikan |
| A5 | Ledger tanpa indeks | 4.000 baris, pencarian hanya lewat grep | tabel indeks berbasis **gejala** di kepala file |
| A6 | Nilai lama tidak distempel | charter dan ledger berselisih diam-diam | supersession in-place (§9) |
| A7 | Tidak ada traceability | requirement gagal tanpa gejala berbulan-bulan | `TRACE.md`, satu baris per requirement |
| A8 | Klaim negatif tanpa bukti | "API ini tidak ada" — padahal namanya salah ditebak | wajib mencantumkan varian yang sudah diuji |
| A9 | Bukti berupa ringkasan | "sudah diverifikasi, aman" | tempel output mentahnya |
| A10 | Handoff ditumpuk, bukan ditulis ulang | handoff jadi arsip; yang basi terbaca sebagai terbaru | tulis ulang dari nol tiap penutupan sesi |

---

## 11. Checklist adopsi (hari-0, ~30 menit)

- [ ] `git init`. Ini menggantikan seluruh kebutuhan file `.bak` (A4).
- [ ] Salin `templates/` → dokumen project, isi bagian `<...>`.
- [ ] Transkrip requirement ke lapis 0. **Beri nomor baris/section** supaya bisa dirujuk `TRACE.md`.
- [ ] Tulis Definition of Done sebagai **daftar skenario demo konkret**, bukan daftar fitur.
      Bertanya "apa yang akan saya tunjukkan" memaksa DoD yang bisa diuji.
- [ ] Isi `TRACE.md` dengan **semua** requirement, status `❌` semua. Baris kosong = requirement
      yang belum pernah dilihat, dan itu sendiri adalah informasi.
- [ ] Isi tabel progress unit kerja + dependency-nya.
- [ ] Tulis `HANDOFF.md` pertama.
- [ ] Tempel §6 (empat aturan bukti) ke lapis 2 — bagian yang paling sering dilanggar.

---

## 12. Yang membuat framework ini berbeda

Kebanyakan "memory system" untuk agent menyimpan **ringkasan percakapan**. LRC tidak. Ia menyimpan
tiga hal yang tidak bisa direkonstruksi oleh model secanggih apa pun:

1. **Keputusan beserta alasan dan opsi yang sudah gugur.** Model bisa menyimpulkan ulang keputusan
   yang sama, tapi tidak tahu opsi mana yang sudah dicoba dan kenapa ditolak.
2. **Perilaku lingkungan yang diukur.** Training data selalu tertinggal dari tool di depanmu. Ledger
   `G-xx` adalah satu-satunya sumber kebenaran soal apa yang tool **benar-benar** lakukan.
3. **Kesalahan agent sendiri, beserta polanya.** Ini bagian yang paling jarang ada di framework lain
   dan paling berdampak. Catat: apa yang disimpulkan agent, kenapa keliru, apa yang membongkarnya.
   Di project asal, sembilan koreksi tercatat — pola yang muncul dari sana (*"sebelum menyimpulkan
   fitur tidak ada, periksa apakah panggilanmu sendiri yang salah"*) mencegah lebih banyak putaran
   sia-sia daripada seluruh dokumentasi teknis di project itu.

Bagian 3 punya nama sendiri: **koreksi ledger**. Formatnya ada di `templates/HANDOFF.md`.
