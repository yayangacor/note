# INSTRUCTION — <Nama Project>

> Lapis 1. Berubah jarang. Isinya: **peran agent**, **gambaran besar**, **kapan selesai**,
> **prioritas**, dan **konstanta terkunci**. Bukan tempat progress, bukan tempat teori.

---

## 1. Identitas project

| Item | Nilai |
|---|---|
| Nama | <...> |
| Jenis / konteks | <...> |
| Tool & versi | <— versi itu penting: gotcha `G-xx` hanya berlaku untuk versi ini> |
| Dikerjakan oleh | <solo / tim; inisial> |
| Deadline | <...> |
| Output akhir | <artefak konkret yang diserahkan> |
| Sumber requirement | `<SUMBER>.md` — **sumber kebenaran tunggal** |

### Konstanta terkunci

Nilai yang dipakai berulang. **Jangan improvisasi.** Kalau sebuah nilai berubah, stempel di sini
juga — jangan hanya di ledger.

| Item | Nilai | Catatan |
|---|---|---|
| <...> | `<...>` | |
| <...> | ~~`<lama>`~~ → **`<baru>`** | diganti [[D-xx]] <tgl> |

---

## 2. Peran agent

<Satu kalimat peran. Contoh: "eksekutor yang menjalankan langsung lewat tool, bukan pemberi
instruksi untuk diketik manual" — perbedaan ini mengubah bentuk seluruh sesi.>

### Wajib

1. **Jelaskan sebelum bertindak** — apa fungsinya, kenapa perlu, akibatnya kalau tidak ada.
2. **Sebutkan cara verifikasinya** untuk tiap langkah.
3. **Hormati dependency** antar unit kerja.
4. **Update status + ledger** setiap tahap selesai.
5. **Jujur soal yang belum diverifikasi.** Tandai eksplisit, jangan diselipkan.

### Dilarang

1. ❌ Memberi hasil panjang tanpa penjelasan.
2. ❌ Mengarang perintah/API yang belum diverifikasi ada.
3. ❌ Mengubah lapis 0.
4. ❌ Melewati fase fondasi demi terlihat cepat.
5. ❌ Menulis sesi teori ke dokumen mana pun.

### Kapan berhenti dan bertanya

Berhenti **hanya** untuk keputusan yang mahal dibatalkan: <mis. menambah komponen baru, mengubah
fondasi yang sudah terkunci, menyentuh artefak yang sudah jadi bukti>. Selain itu: kerjakan,
verifikasi, lalu laporkan buktinya — jangan minta izin tiap langkah.

---

## 3. Gambaran besar

<Diagram ASCII atau 5–10 baris. Cukup untuk menempatkan pekerjaan hari ini di dalam keseluruhan.
Detailnya ada di dokumen lain — jangan diduplikasi ke sini.>

---

## 4. Definition of Done

> Ditulis sebagai **daftar skenario yang bisa ditunjukkan**, bukan daftar fitur. Pertanyaan
> "apa yang akan saya tunjukkan?" memaksa DoD yang bisa diuji; "fitur X selesai" tidak.

| # | Skenario | Membuktikan | Status |
|---|---|---|---|
| 1 | <tindakan konkret → hasil yang terlihat> | <requirement> | ❌ |

Tambahan yang juga dinilai tapi bukan skenario:

- <...>

---

## 5. Prioritas / triase

Kalau waktu habis, kerjakan berdasarkan urutan ini. **Jangan** mengerjakan hal kosmetik sebelum
fondasi selesai.

### 🔴 Tier 1 — tanpa ini tidak ada yang berfungsi
- <...>

### 🟡 Tier 2 — bobot besar, dikejar setelah Tier 1
- <...>

### 🟢 Tier 3 — kalau waktu tersisa
- <...>

> **Peringatan jujur:** lebih baik Tier 1+2 sempurna dan bisa dijelaskan daripada semuanya
> setengah jadi. <Sesuaikan dengan aturan penilaian/penerimaan project ini.>

---

## 6. Alur kerja stateless vs stateful

| Jenis | Contoh | Nasibnya |
|---|---|---|
| **Stateless** | tanya-jawab teori, klarifikasi konsep | dibuang, tidak ditulis |
| **Stateful** | keputusan, nilai konkret, gotcha, progress, bukti | ditulis sesuai `DOC-MAP.md` |

Uji cepat: *"besok masih dibutuhkan, dan tidak bisa ditebak ulang tanpa dokumen ini?"*

---

## 7. Cara memulai sesi baru

1. Baca lapis 2 (auto-load) → tabel progress.
2. Baca `HANDOFF.md` → keadaan hari ini + langkah berikutnya.
3. Buka `DOC-MAP.md` → tentukan dokumen yang relevan.
4. Buka unit kerja aktif + dependency-nya. Cek **prasyarat pemahaman**.
5. Setelah selesai → jalankan protokol penutupan sesi (P3 di `BOOTSTRAP.md`).
