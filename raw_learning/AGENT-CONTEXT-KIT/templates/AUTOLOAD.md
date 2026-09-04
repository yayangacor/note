# <NAMA PROJECT>

> Lapis 2 — file yang **otomatis dibaca agent tiap sesi** (CLAUDE.md / AGENTS.md / .cursorrules).
> Batas keras: **250 baris**. Tiap baris di sini dibayar berulang tiap sesi, termasuk sesi yang
> tidak menyentuh topiknya. Kalau lewat batas: pindahkan narasinya ke ledger, sisakan pointer.
>
> Isi file ini hanya tiga hal: **aturan**, **konvensi**, **progress**. Bukan buku harian.

## Baca dulu

| Urutan | Dokumen | Kapan |
|---|---|---|
| 1 | `HANDOFF.md` | tiap sesi — keadaan hari ini + langkah berikutnya |
| 2 | `DOC-MAP.md` | menentukan dokumen mana yang relevan hari ini |
| 3 | `docs/plans/PXX-*.md` | plan aktif + dependency-nya saja |
| 4 | `NOTES.md` | saat sebuah ID (`D-xx`/`G-xx`/`R-xx`) dirujuk |
| 5 | `TRACE.md` | saat menutup requirement atau menjelang serah terima |

**Jangan** membaca semua plan sekaligus.

---

## Aturan kerja

> Aturan lengkap ada di `NOTES.md` sebagai `R-01`..`R-nn`. Di sini hanya yang berlaku di
> **setiap** tindakan. Rujuk selalu dengan ID lengkap (`R-07`), jangan "aturan 7".

### Disiplin bukti (tidak bisa ditawar)

| Kode | Aturan | Bentuk pelanggaran yang paling sering |
|---|---|---|
| **B1** | Tersimpan ≠ jalan | config/kode terbaca rapi, fitur tetap mati |
| **B2** | Diterima ≠ tersimpan | tool tidak melempar error, dan juga tidak menyimpan |
| **B3** | Lulus tanpa kontrol negatif ≠ bukti | tes yang tidak pernah bisa gagal |
| **B4** | Ukur alat ukurnya dulu | melaporkan temuan dari alat ukur yang rusak |

### Aturan tetap

1. **Stateless vs stateful.** Teori tidak ditulis. Keputusan, nilai konkret, gotcha, progress
   ditulis sesuai `DOC-MAP.md`.
2. **Hormati dependency.** Plan yang dependency-nya belum `DONE` tidak dieksekusi.
3. **Klaim negatif butuh daftar yang sudah dicoba.** "Tidak ada" tanpa itu = tebakan.
4. **Supersession in-place.** Nilai yang diganti distempel di tempat lamanya.
5. **Pengamatan mengalahkan teori.** Kalau layar dan penalaran berselisih, layar yang menang;
   periksa dulu apakah panggilan sendiri yang salah.
6. **<aturan spesifik domain — mis. "jangan ubah jalur yang sedang dipakai">**

---

## Konvensi

<Penamaan, format, struktur file, ID, satuan. Bagian yang harus dijawab identik oleh siapa pun
yang mengerjakan. Tabel, bukan paragraf.>

| Item | Format | Contoh |
|---|---|---|
| <hostname/nama file/branch> | `<pola>` | `<contoh>` |

---

## Progress

Status: `NOT STARTED` · `IN PROGRESS` · `DONE` · `BLOCKED`

| Unit | Judul | Prioritas | Dependency | Status |
|---|---|---|---|---|
| P00 | <...> | 🔴 | — | DONE |
| P01 | <...> | 🔴 | P00 | IN PROGRESS |

> **Satu baris per unit.** Detail hasil ada di file plan-nya; cerita sesi ada di `HANDOFF.md`.
> Kalau sebuah baris butuh lebih dari dua kalimat, isinya salah tempat.

**Blocker aktif:** <— / deskripsi satu baris + ID>

---

## Aturan baru yang lahir sesi terakhir

| ID | Inti | Lahir dari |
|---|---|---|
| `R-xx` | <satu kalimat> | <G-xx / kejadian> |

> Hanya **pointer**. Isi lengkapnya di ledger. Kalau tabel ini lebih panjang dari 10 baris,
> yang tertua dipangkas jadi rujukan ID saja.
