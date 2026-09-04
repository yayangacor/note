# NOTES — Ledger

> Lapis 4. **Append-only.** Entri tidak pernah dihapus; kalau terbukti salah, statusnya diubah
> jadi `❌ DIBANTAH oleh [[G-xx]]` dan dibiarkan berdiri.
>
> Ruang nama: `D-xx` keputusan · `G-xx` gotcha lingkungan · `R-xx` aturan kerja · `Q-xx` pertanyaan.
> Rujuk selalu dengan ID lengkap. Requirement asli **tidak** diduplikasi ke sini.

---

## Indeks — cari lewat GEJALA

> Wajib begitu ledger lewat ~50 entri. Orang mencari gotcha lewat apa yang mereka **lihat**,
> bukan lewat nama fitur. Perbarui tabel ini tiap kali menambah entri.

| ID | Gejala / pertanyaan yang membawamu ke sini | Status | Tgl |
|---|---|---|---|
| `G-01` | <"muncul error X saat melakukan Y"> | ✅ | <tgl> |
| `D-01` | <"kenapa kita pilih A dan bukan B?"> | aktif | <tgl> |
| `R-01` | <"apa yang harus dicek sebelum melakukan Z?"> | aktif | <tgl> |
| `Q-01` | <"siapa yang menentukan ...?"> | ⏳ menunggu | <tgl> |

Legenda status: `✅ TERVERIFIKASI` · `⚠️ SEBAGIAN` (berlaku di kondisi tertentu saja) ·
`❌ DIBANTAH` · `⏳ MENUNGGU`.

---

## D — Keputusan desain

### D-01 — <keputusan dalam satu kalimat> (<tgl>)

**Masalah.** Apa yang memaksa keputusan ini diambil. Kalau ada requirement yang bertabrakan,
kutip keduanya.

**Opsi yang dipertimbangkan.**

| Opsi | Untung | Rugi | Dipilih? |
|---|---|---|---|
| A | | | ✅ |
| B | | | ❌ karena <...> |

> Kolom "kenapa ditolak" ini yang tidak bisa direkonstruksi model di sesi berikutnya. Jangan
> dilewati — tanpa itu, opsi yang sama akan diusulkan lagi.

**Keputusan.** <apa yang berlaku sekarang, dengan nilai konkretnya>

**Konsekuensi.** Apa yang jadi wajib/terlarang gara-gara ini.

**Cara membelanya kalau ditanya.** <satu-dua kalimat siap ucap>

**Status:** ditetapkan · <sudah/belum> diuji · **Terkait:** [[G-xx]]

---

## G — Gotcha / perilaku lingkungan

### G-01 — <klaim dalam satu kalimat> ✅ TERVERIFIKASI (<tgl>, sesi <n>)

**Gejalanya.** Apa yang terlihat di layar. Tulis persis seperti yang muncul — inilah yang
akan dicari orang lewat pencarian.

**Ukurannya.** Perintah/panggilan yang dijalankan dan output **mentahnya**:

```
<output apa adanya, jangan diringkas>
```

**Sebabnya.** Sependek mungkin.

**Refleks yang benar.** Apa yang dilakukan lain kali, dalam bentuk langkah, bukan wacana.

**Yang sudah dicoba dan gagal.** <wajib untuk klaim negatif: varian nama, versi, alat lain>

**Batasnya.** Berlaku di <versi/model/kondisi apa>. Di luar itu belum diuji.

**Terkait.** [[G-xx]] [[R-xx]]

---

## R — Aturan kerja hasil kesalahan

### R-01 — <perintahnya, dalam kalimat imperatif> (<tgl>)

**Kejadiannya.** Apa yang salah, dan berapa ongkosnya (putaran diagnosis, jam, kerusakan).

**Kenapa aturan lama tidak menolong.** Kalau aturan sebelumnya ada tapi gagal dipakai, tulis —
ini menjelaskan bentuk aturan barunya.

**Aturannya.** Satu kalimat imperatif yang bisa dijalankan tanpa menafsir.

**Cara mengeceknya.** Bagaimana tahu aturan ini sedang dilanggar.

**Terkait.** [[G-xx]]

---

## Q — Pertanyaan terbuka

| ID | Pertanyaan | Ditanyakan ke | Tgl | Status | Ditutup oleh |
|---|---|---|---|---|---|
| `Q-01` | <...> | <orang/peran> | <tgl> | ⏳ | — |

> Pertanyaan yang tidak jadi diajukan **tetap harus ditutup**, dengan keputusan sendiri yang
> beralasan (`D-xx`). Pertanyaan yang menggantung tanpa penutupan akan terbaca oleh sesi
> berikutnya sebagai "jawaban sedang dalam perjalanan", dan itu keliru.

---

## Log perubahan nilai terkunci

> Tiap kali nilai yang sudah "terkunci" berubah, catat di sini **dan** stempel di tempat nilai
> lamanya berada.

| Tgl | Nilai | Dari | Jadi | Penyebab |
|---|---|---|---|---|
| <tgl> | <nama nilai> | ~~lama~~ | **baru** | [[D-xx]] |
