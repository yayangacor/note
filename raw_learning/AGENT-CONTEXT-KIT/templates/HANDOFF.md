# HANDOFF — <tanggal>, sesi <n>

> Lapis 6. **Ditulis ulang dari nol tiap akhir sesi** — bukan ditambahkan di bawah. Handoff yang
> ditumpuk berubah jadi arsip dalam tiga sesi, dan bagian basinya terbaca sebagai yang terbaru.
> Batas: ~250 baris. Kalau melewati, isinya sudah bercampur dengan hal yang seharusnya di ledger.

---

## 1. Urutan baca

Sebutkan **apa yang dicari** di tiap dokumen, bukan hanya nama filenya.

| # | Dokumen | Yang dicari di sana |
|---|---|---|
| 1 | `<AUTO-LOAD>.md` | aturan + tabel progress |
| 2 | `<SUMBER>.md` §<n> | requirement yang sedang dikerjakan |
| 3 | `docs/plans/PXX` | plan aktif — baca section "Catatan Pra-Eksekusi" DULU |
| 4 | `NOTES.md` | hanya ID yang disebut di §4 di bawah |

⚠️ **Nilai yang sudah disuperseded** dan masih terbaca di dokumen lain:

| Dokumen | Tertulis | Yang berlaku | Sumber |
|---|---|---|---|
| `<file>` §<n> | ~~<lama>~~ | **<baru>** | [[D-xx]] |

---

## 2. Keadaan sekarang

| Unit | Status | Sisa konkret |
|---|---|---|
| P0x | DONE | — |
| P0x | IN PROGRESS | <apa persisnya yang tersisa, bukan "lanjutkan"> |

**Yang RUSAK / setengah jalan** — sebut walaupun kecil, dan sebut dampaknya:

- <hal yang rusak> → dampak: <...> → penanganannya: <...>

**Utang teknis yang disengaja** (dengan alasan tertulis, supaya tidak "diperbaiki" oleh sesi
berikutnya yang mengira itu bug):

- <...> → alasan: [[D-xx]]

---

## 3. Langkah berikutnya

Sudah berupa pilihan konkret. "Lanjutkan pekerjaan" bukan langkah.

**[A] <nama langkah>**
- prasyarat yang sudah terukur: <...>
- blocker yang diketahui: <...>
- langkah pertama yang konkret: <...>

**[B] <alternatif>**

---

## 4. Jebakan yang aktif hari ini

Hanya entri yang akan **langsung** mengenai sesi berikutnya. Bukan seluruh ledger.

| ID | Yang akan terjadi kalau lupa |
|---|---|
| `G-xx` | <...> |

---

## 5. Koreksi ledger — di mana penalaran agent keliru

> Bagian paling berharga di seluruh dokumen ini, dan yang paling sering dihaluskan sampai tidak
> berguna. Tulis apa adanya. Formatnya: **apa yang disimpulkan → kenapa keliru → apa yang
> membongkarnya → polanya.**

**(a) <ringkasan satu baris>**
- disimpulkan: <klaim agent>
- kenyataannya: <...>
- yang membongkarnya: <ukuran/pengamatan spesifik, sebut siapa yang menemukan>
- polanya: <bentuk umum kesalahan ini>

**Pola gabungan sejauh ini:** <kalimat yang menyatukan koreksi-koreksi di atas — inilah yang
paling banyak menghemat waktu di sesi berikutnya>

**Pengamatan user yang mengalahkan teori agent:** <daftar singkat; kalau daftar ini tumbuh,
bobot yang diberikan pada pengamatan layar harus naik, bukan turun>

---

## 6. Sudah dibahas, tidak perlu diulang

<Daftar topik teori yang sudah tuntas. Fungsinya mencegah agent menjelaskan ulang hal yang sudah
dipahami, dan mencegah putaran tanya-jawab yang sama.>

---

## 7. Batasan tool yang sudah terpetakan

> Ringkasan operasional, bukan pengganti ledger. Tiap baris menunjuk ke `G-xx`.

**BISA:** <...>
**TIDAK BISA — jangan buang waktu mencoba:** <...> ([[G-xx]])
**BERBAHAYA:** <panggilan/perintah yang pernah merusak sesuatu> ([[G-xx]])

---

## 8. Satu hal yang belum terverifikasi

<Hal yang paling gampang disalahartikan sebagai selesai. Wajib diisi — kalau benar-benar tidak
ada, tulis alasannya kenapa tidak ada.>
