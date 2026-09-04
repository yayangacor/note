# P<NN> — <Judul unit kerja>

| Field | Value |
|---|---|
| **Status** | `NOT STARTED` / `IN PROGRESS` / `DONE` / `BLOCKED` |
| **Prioritas** | 🔴 wajib · 🟡 bobot besar · 🟢 kalau sempat |
| **Dependency** | P<NN> — <harus `DONE` sebelum unit ini dimulai> |
| **Estimasi** | <...> |
| **Output** | <apa yang ada di dunia nyata setelah unit ini selesai> |

---

## Tujuan

<Satu paragraf. Apa yang berubah setelah ini selesai, bukan apa yang dikerjakan.>

## Scope

- <...>

## Out of scope

- <hal yang mirip tapi milik unit lain> → **P<NN>**

> Section ini mencegah scope creep dan mencegah dua unit mengerjakan hal yang sama.

---

## Requirement yang ditutup unit ini

| Req (lapis 0) | Bunyi | Ditutup oleh langkah |
|---|---|---|
| §<n> | <...> | <langkah 3> |

> Diisi **sebelum** mulai. Kalau sebuah langkah tidak menutup requirement mana pun, tanyakan
> kenapa ia dikerjakan.

---

## Prasyarat pemahaman

Centang sebelum eksekusi. Yang belum tercentang dijalankan sebagai sesi **stateless** (tanya
jawab, tidak ditulis ke dokumen mana pun).

- [ ] <konsep yang harus bisa dijelaskan saat ditanya>

---

## Catatan pra-eksekusi

> Diisi oleh sesi sebelumnya. **Dibaca lebih dulu daripada Langkah Kerja.** Isinya hal yang
> sudah diukur dan tidak boleh diulang, serta blocker yang sudah diketahui.

- <hal yang sudah diaudit — jangan diulang>
- **Blocker terukur:** <...> ([[G-xx]])

---

## Langkah kerja

### 1. <Nama langkah>

- [ ] <tindakan konkret>
- **Verifikasi:** <perintah/ukuran yang membuktikan langkah ini jalan>
- **Kontrol negatif:** <kasus yang seharusnya gagal — kalau tidak ada, tulis "tidak berlaku"
  dan alasannya>

### 2. <Nama langkah>

...

---

## Verifikasi (Definition of Done)

Centang **hanya** yang benar-benar diuji. Tempelkan buktinya, bukan pernyataannya.

- [ ] <hasil yang bisa diamati> — bukti: `<output mentah>`
- [ ] <hasil yang bisa diamati> — bukti: `<output mentah>`

> Ingat B1: yang dicentang adalah **hasil yang diterima pengguna/klien**, bukan konfigurasi yang
> terbaca rapi.

---

## Hasil eksekusi — sesi <n> (<tgl>)

### <Blok/langkah>

<Apa yang dikerjakan, dan buktinya apa adanya:>

```
<output mentah>
```

**Yang gagal dan kenapa:** <jujur — ini yang paling berguna untuk sesi berikutnya>

**Entri ledger yang lahir dari sini:** [[G-xx]] [[D-xx]] [[R-xx]]

---

## Sisa pekerjaan

> Kalau ada pekerjaan yang harus dilakukan manusia (GUI, akses fisik, approval), tulis sebagai
> **checklist bernomor** dengan tiga hal per item: apa yang ditekan, kenapa tidak bisa
> diotomasi, dan **cara memverifikasinya**.

1. **<Apa yang dilakukan>** — di <lokasi/panel persis>
   - kenapa manual: <...>
   - verifikasi: <"daftar harus berubah dari 9 baris jadi 25 baris">
