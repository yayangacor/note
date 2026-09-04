# DOC-MAP — Router dokumen

> Lapis 3. Fungsinya satu: **menentukan dokumen mana yang perlu dibuka** untuk topik hari ini,
> supaya agent tidak membaca semuanya "biar aman". Cara pakai: cari topik → buka hanya yang
> tertulis di kolom kanan.

## Struktur

```
<root>/
├── <AUTO-LOAD>.md         ← lapis 2: aturan, konvensi, progress (auto-load, ≤250 baris)
├── <SUMBER>.md            ← lapis 0: requirement asli, tidak pernah diubah
├── HANDOFF.md             ← lapis 6: keadaan hari ini, ditulis ulang tiap sesi
├── NOTES.md               ← lapis 4: ledger D/G/R/Q
├── TRACE.md               ← lapis 4b: requirement → bukti
├── INSTRUCTION.md         ← lapis 1: peran, DoD, prioritas, konstanta terkunci
├── DOC-MAP.md             ← file ini
├── plans/PXX-*.md         ← lapis 5: unit kerja
└── archive/               ← salinan lama. DIKECUALIKAN dari pencarian.
```

---

## Rute berdasarkan kebutuhan

### Orientasi

| Kalau mau... | Buka |
|---|---|
| tahu harus mengerjakan apa berikutnya | `HANDOFF.md` §3 |
| tahu kapan project ini dianggap selesai | `INSTRUCTION.md` → Definition of Done |
| cek requirement asli / cari yang terlewat | `<SUMBER>.md` + `TRACE.md` |
| tahu kenapa sebuah keputusan diambil | `NOTES.md` → `D-xx` |
| tahu apakah tool bisa melakukan X | `NOTES.md` → indeks gejala |
| waktu mepet, harus memilih | `INSTRUCTION.md` → triase prioritas |
| memulai sesi dari nol | `HANDOFF.md`, lalu file ini |

### Per topik

| Topik | Dokumen utama | Pendukung |
|---|---|---|
| <topik 1> | `plans/P0X` | `NOTES.md` [[D-xx]] |
| <topik 2> | `plans/P0X` | — |

> Tabel ini bertambah seiring project. Aturannya: **file baru tidak sah sampai barisnya ada di
> sini.** Dokumen yang tidak bisa ditemukan lewat router sama saja dengan tidak ada.

---

## Aturan membuat dokumen baru

Sebelum membuat file baru, jawab berurutan — berhenti di jawaban "ya" yang pertama:

1. Ini **requirement**? → sudah ada di lapis 0. Jangan diduplikasi.
2. Ini **teori**? → jangan ditulis (stateless).
3. Ini **keputusan / gotcha / aturan**? → `NOTES.md` sebagai entri ber-ID.
4. Ini **bukti bahwa requirement terpenuhi**? → `TRACE.md`.
5. Ini **langkah eksekusi**? → plan yang relevan.
6. Ini **aturan kerja / konvensi**? → lapis 2.
7. Ini **keadaan hari ini**? → `HANDOFF.md`.

Kalau tidak masuk satu pun, kemungkinan besar tidak perlu disimpan. Kalau benar-benar perlu file
baru → **tambahkan barisnya ke router ini di commit yang sama.**

---

## Yang dikecualikan dari pencarian

| Path | Kenapa |
|---|---|
| `archive/` | salinan lama; hasil pencarian dari sini akan terbaca sebagai fakta terbaru |

> Jangan menyimpan backup sebagai `X.md.bak-<tgl>` di samping aslinya. Salinan seperti itu ikut
> terjaring `grep` dan mencemari hasil pencarian dengan nilai yang sudah dibatalkan. Gunakan git;
> kalau tidak bisa, pindahkan ke `archive/` dan sebutkan di tabel ini.
