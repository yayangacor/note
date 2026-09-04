# Prompt Siap Pakai

Empat prompt. Salin apa adanya ke agent mana pun (Claude Code, Cursor, Codex, ChatGPT, Gemini —
tidak ada yang spesifik ke satu tool). Ganti bagian `<...>`.

| Prompt | Kapan dipakai | Frekuensi |
|---|---|---|
| **P1 — Bootstrap** | sekali, di awal project baru | 1× |
| **P2 — Buka sesi** | tiap sesi baru | tiap sesi |
| **P3 — Tutup sesi** | sebelum berhenti kerja | tiap sesi |
| **P4 — Audit konteks** | tiap ~5 sesi, atau saat dokumen terasa berat | berkala |

---

## P1 — Bootstrap sistem memori

```text
Kamu akan bekerja bersamaku pada project ini selama beberapa sesi. Kamu tidak punya memori
antar sesi, jadi hal pertama yang kita bangun adalah SISTEM MEMORI-nya, bukan pekerjaannya.

Bangun struktur berikut. Jangan mengarang isinya — untuk hal yang belum kamu ketahui, tulis
placeholder dan tanyakan padaku di akhir dalam satu daftar bernomor.

STRUKTUR (6 lapis, satu fakta hanya boleh hidup di satu lapis):

  0. <SUMBER>.md      requirement asli, transkrip apa adanya, DIBERI NOMOR BARIS/SECTION.
                      Tidak pernah diedit. Kalau konflik dengan dokumen lain, file ini menang.
  1. INSTRUCTION.md   peranmu, gambaran besar, Definition of Done, prioritas, konstanta
                      terkunci (kredensial/versi/nama/nilai yang dipakai berulang).
  2. <AUTO-LOAD>.md   file yang otomatis kamu baca tiap sesi (CLAUDE.md / AGENTS.md / .cursorrules).
                      ISI: aturan kerja + konvensi + tabel progress. MAKS 250 BARIS. Bukan
                      tempat narasi sesi.
  3. DOC-MAP.md       tabel "topik -> dokumen mana yang perlu dibuka". Fungsinya mencegah
                      membaca semua dokumen tiap sesi.
  4. NOTES.md         ledger append-only ber-ID + TRACE.md (traceability requirement).
  5. plans/PXX-*.md   unit kerja: scope, dependency, langkah, Definition of Done, hasil eksekusi.
  6. HANDOFF.md       keadaan hari ini. DITULIS ULANG DARI NOL tiap akhir sesi.

LEDGER — empat ruang nama ID, satu entri satu fakta, tidak pernah dihapus:
  D-xx  keputusan desain (masalah -> keputusan -> alasan -> konsekuensi)
  G-xx  gotcha / perilaku nyata tool yang DIUKUR (gejala -> ukuran -> sebab -> refleks)
  R-xx  aturan kerja yang lahir dari kesalahan
  Q-xx  pertanyaan terbuka yang menunggu jawaban orang lain
Tiap entri wajib: status (TERVERIFIKASI / SEBAGIAN / DIBANTAH) + tanggal + BUKTI MENTAH
(output apa adanya, bukan ringkasan) + link [[ID]] ke entri terkait.

TRACE.md — satu baris per requirement dari lapis 0:
  | Req | Bunyi (potongan) | Status | Di mana dipenuhi | Bukti | Tgl |
  Isi SEKARANG untuk SELURUH requirement dengan status belum-terpenuhi. Baris yang kosong
  adalah requirement yang belum pernah kita lihat, dan itu informasi yang berharga.

ATURAN YANG BERLAKU UNTUKMU SEJAK SEKARANG:

1. GERBANG STATELESS/STATEFUL. Sebelum menulis apa pun ke dokumen, tanya: "besok masih
   dibutuhkan, DAN tidak bisa ditebak ulang tanpa dokumen ini?" Kalau tidak dua-duanya,
   jangan ditulis. Penjelasan teori TIDAK PERNAH ditulis — kamu sudah tahu teorinya, dan
   menuliskannya membebani konteks tiap sesi.

2. DISIPLIN BUKTI — tidak bisa ditawar:
   B1 config/kode tersimpan BUKAN bukti fitur jalan. Bukti = klien/pengguna benar-benar
      menerima hasil.
   B2 perintah diterima BUKAN perintah tersimpan. Baca ulang nilainya dari sumber otoritatif;
      jangan percaya ketiadaan error.
   B3 tes lulus tanpa KONTROL NEGATIF bukan bukti. Sediakan kasus yang SEHARUSNYA gagal, dan
      pastikan ia memang gagal.
   B4 ukur alat ukurnya dulu. Sebelum menyimpulkan "fitur X tidak ada", jalankan alat ukur
      yang sama pada kasus yang SUDAH terbukti bekerja. Kalau kontrolnya ikut gagal, yang
      rusak alat ukurnya.

3. KLAIM NEGATIF BUTUH BUKTI. Dilarang menulis "API/perintah/fitur ini tidak ada" tanpa
   mencantumkan apa saja yang sudah dicoba (varian nama, versi, model/tool lain). Klaim
   negatif yang salah lebih berbahaya daripada dokumen kosong: sesi berikutnya mewarisinya
   sebagai kebenaran dan berhenti mencari.

4. SUPERSESSION IN-PLACE. Saat sebuah nilai berubah, stempel di TEMPAT NILAI LAMANYA:
   ~~nilai lama~~ -> nilai baru (diganti [[D-xx]], tanggal). Bukan hanya di entri barunya.

5. PRESEDENSI saat dokumen berselisih:
   lapis 0 > ledger (entri terbaru) > charter > unit kerja > handoff.
   Pengecualian: kalau lapis 0 mustahil dieksekusi (bertabrakan dengan dirinya sendiri atau
   dengan batas teknis), menangnya jatuh ke keputusan D-xx yang membuat requirement itu bisa
   didemokan — dan alasannya WAJIB ditulis supaya deviasinya bisa dibela.

6. ANGGARAN BACA. Jangan membaca semua dokumen. Buka DOC-MAP, tentukan yang relevan, baca itu
   saja + dependency-nya.

Setelah struktur jadi, laporkan: file apa saja yang dibuat, apa yang masih placeholder, dan
daftar pertanyaan bernomor untukku.
```

---

## P2 — Pembuka sesi

```text
Sesi baru. Ikuti protokol pembukaan, jangan langsung mengerjakan.

1. Baca <AUTO-LOAD>.md (aturan + progress) dan HANDOFF.md (keadaan hari ini).
2. Buka DOC-MAP.md, tentukan dokumen mana yang relevan dengan target hari ini. Sebut
   pilihanmu sebelum membacanya.
3. Buka unit kerja aktif + dependency-nya saja. Jangan membaca seluruh plan.
4. Sebelum mengeksekusi apa pun, laporkan dalam <=10 baris:
   - target sesi ini dan dari mana kamu menyimpulkannya
   - dependency yang belum DONE (kalau ada, berhenti dan tanya)
   - entri ledger yang RELEVAN dengan target ini (sebut ID-nya) — terutama G-xx yang membatasi
     apa yang bisa dilakukan tool
   - asumsi yang kamu pakai dan belum terverifikasi

Yang berlaku sepanjang sesi:
- Temuan lingkungan langsung jadi entri G-xx saat itu juga, bukan ditunda ke akhir sesi.
- Tiap langkah selesai butuh bukti mentah (output/screenshot/hasil ukur), bukan pernyataan
  "sudah beres".
- Kalau pengamatanku bertentangan dengan teorimu, PENGAMATAN YANG MENANG. Periksa dulu apakah
  panggilan/asumsimu sendiri yang salah sebelum menyalahkan tool.
```

---

## P3 — Penutup sesi

```text
Tutup sesi. Jalankan seluruh langkah ini, jangan sebagian.

1. UNIT KERJA — update status tiap tahap yang tersentuh. Centang DoD HANYA yang benar-benar
   diuji, dan tempelkan bukti mentahnya di section Hasil Eksekusi.
2. LEDGER — append entri baru:
   - keputusan yang diambil hari ini      -> D-xx (masalah, keputusan, alasan, konsekuensi)
   - perilaku tool yang ditemukan         -> G-xx (gejala, ukuran, sebab, refleks)
   - kesalahan yang kita bayar hari ini   -> R-xx (aturan supaya tidak terulang)
   - pertanyaan yang menggantung          -> Q-xx
   Perbarui tabel indeks ledger. Indeksnya berbasis GEJALA, bukan nama fitur.
3. TRACE.md — perbarui baris requirement yang tersentuh: status, di mana dipenuhi, bukti,
   tanggal. Kalau requirement tersentuh tapi belum tuntas, tulis sisanya secara spesifik.
4. <AUTO-LOAD>.md — update HANYA tabel progress + aturan baru (satu baris + pointer ke R-xx).
   Kalau file ini lewat 250 baris, pindahkan narasinya ke ledger. Jangan menaruh cerita sesi
   di sini.
5. HANDOFF.md — TULIS ULANG DARI NOL, dengan urutan:
   a. urutan baca untuk sesi berikutnya (dokumen mana, dan APA yang dicari di sana)
   b. keadaan sekarang: apa yang selesai, apa yang setengah jalan, apa yang RUSAK
   c. langkah berikutnya, sudah berupa pilihan konkret, bukan "lanjutkan pekerjaan"
   d. jebakan yang aktif hari ini (ID G-xx yang akan langsung mengenai sesi berikutnya)
   e. KOREKSI LEDGER — di mana kesimpulanmu keliru hari ini, apa yang membongkarnya, dan
      polanya. Bagian ini yang paling berharga; jangan dihaluskan.
6. Sebutkan satu hal yang MASIH BELUM TERVERIFIKASI dan gampang disalahartikan sebagai selesai.

Laporkan ringkas: file apa yang berubah dan ID entri baru apa yang ditambahkan.
```

---

## P4 — Audit konteks berkala

```text
Audit sistem dokumen, bukan pekerjaannya. Jangan memperbaiki apa pun sebelum melaporkan.

1. UKURAN. Baris/KB tiap dokumen. Tandai file auto-load kalau > 250 baris, dan sebutkan
   bagian mana yang seharusnya pindah ke ledger.
2. DUPLIKASI. Cari fakta yang sama hidup di lebih dari satu file (kredensial, angka, status,
   keputusan). Tiap duplikat adalah calon kontradiksi — sebutkan mana yang seharusnya jadi
   rumahnya.
3. KONTRADIKSI. Cari nilai yang berselisih antar dokumen. Untuk tiap temuan sebut: mana yang
   menang menurut aturan presedensi, dan di mana stempel supersession-nya seharusnya dipasang.
4. TABRAKAN ID. Cari rujukan yang ambigu ("aturan 7" padahal ada tiga daftar bernomor
   berbeda). Cari juga entri bernomor yang urutannya tidak kontigu di dalam file.
5. INDEKS. Ledger > 50 entri tapi tidak punya tabel indeks berbasis gejala? Itu temuan.
6. KLAIM TANPA BUKTI. Cari kalimat berbentuk "X tidak ada/tidak bisa" yang tidak menyebutkan
   apa yang sudah dicoba, dan klaim "sudah diverifikasi" tanpa output mentah.
7. TRACE. Requirement mana yang belum punya baris sama sekali? Mana yang statusnya terpenuhi
   tapi kolom Bukti-nya kosong? Yang kedua lebih berbahaya daripada yang pertama.
8. FILE BASI. Backup/salinan/draft yang ikut terjaring pencarian. Sebutkan berapa banyak hasil
   pencarian yang tercemar olehnya.

Laporkan sebagai tabel: temuan | dampaknya kalau dibiarkan | perbaikan | ongkos perbaikan.
Urutkan berdasarkan dampak. Baru kerjakan setelah aku memilih.
```
