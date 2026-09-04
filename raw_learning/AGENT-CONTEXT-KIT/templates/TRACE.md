# TRACE — Requirement → Bukti

> Lapis 4b. Satu baris per requirement di lapis 0. Ini satu-satunya artefak yang bisa menangkap
> **requirement pasif**: yang tidak menimbulkan gejala apa pun ketika dilanggar (logging, audit
> trail, penamaan, header, lisensi, kebijakan akses, dokumentasi wajib).
>
> Diisi **penuh sejak hari pertama** dengan status `❌` semua. Baris yang belum pernah disentuh
> adalah informasi, bukan kekosongan.

## Cara mengisi

| Kolom | Isinya | Kesalahan yang sering |
|---|---|---|
| **Req** | nomor baris/section di lapis 0 | mengarang penomoran sendiri |
| **Bunyi** | potongan kata aslinya | menulis tafsir, bukan bunyinya |
| **Status** | ✅ / ⚠️ sebagian / ❌ / 🚫 sengaja tidak (butuh `D-xx`) | ✅ berdasarkan kesan |
| **Di mana** | lokasi konkret implementasinya | "sudah ada di sistem" |
| **Bukti** | hasil ukur mentah + tanggal | "sudah diverifikasi" |
| **Tgl** | kapan bukti itu diambil | dibiarkan kosong |

**Aturan status ⚠️:** wajib menyebut angka. "19/24 device" bisa ditindaklanjuti; "sebagian
besar" tidak.

**Aturan status 🚫:** hanya sah kalau menunjuk `D-xx` yang berisi alasan tertulis. Requirement
yang sengaja tidak dikerjakan tanpa alasan tertulis akan terbaca sebagai kelalaian saat
diperiksa orang lain.

---

## A. <Kelompok requirement>

| Req | Bunyi (potongan) | Status | Di mana dipenuhi | Bukti | Tgl |
|---|---|---|---|---|---|
| §<n> | <kutipan pendek> | ❌ | — | — | — |
| §<n> | <kutipan pendek> | ✅ | <lokasi> | <output mentah / hasil ukur> | <tgl> |
| §<n> | <kutipan pendek> | ⚠️ <x>/<y> | <lokasi> | <bukti + apa yang kurang> | <tgl> |
| §<n> | <kutipan pendek> | 🚫 | — | alasan: [[D-xx]] | <tgl> |

## B. <Kelompok berikutnya>

| Req | Bunyi (potongan) | Status | Di mana dipenuhi | Bukti | Tgl |
|---|---|---|---|---|---|

---

## Rekap

| Status | Jumlah |
|---|---|
| ✅ terpenuhi + berbukti | <n> |
| ⚠️ sebagian | <n> |
| ❌ belum | <n> |
| 🚫 sengaja tidak (beralasan) | <n> |
| **Belum punya baris sama sekali** | **<n>** ← paling berbahaya |

> Baris terakhir itu ukuran seberapa besar bagian requirement yang **belum pernah dilihat**.
> Selama angkanya bukan nol, klaim "semua sudah dikerjakan" tidak punya dasar.

---

## Artefak demo

> Bukti terkuat yang sudah ada, siap ditunjukkan tanpa mengerjakan ulang. Simpan di sini supaya
> tidak dicari-cari saat dibutuhkan.

| # | Artefak | Membuktikan | Cara menunjukkannya |
|---|---|---|---|
| 1 | <output/tampilan spesifik> | <requirement> | <langkah, 1–2 kalimat> |

**Kontrol negatif yang sudah terekam** — jawaban untuk "dari mana tahu ini benar-benar bekerja,
bukan kebetulan?":

| Kontrol | Hasil yang seharusnya | Hasil sebenarnya |
|---|---|---|
| <kasus yang seharusnya GAGAL> | gagal | <...> |
