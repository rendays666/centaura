# CENTAURA — Knowledge Index

> Titik masuk untuk AI. Baca file ini dulu, lalu hanya file yang relevan. **Jangan baca `input/shorted/` (mentah, besar).**

- PlaceId: `8735521924` · batch terakhir: `20261125_083600` (dump 2026-11-25 08:36:05) · total batch: 1

| File | Isi | Jumlah |
|---|---|---|
| [remotes.md](remotes.md) | semua remote + kategori + call tertangkap | 85 (game 44, tool 7, internal 34) |
| [tree.md](tree.md) | struktur game | 7 service |
| [values.md](values.md) | Value/Attribute (harga, cooldown, state) | 252 value, 27 atribut |
| [ui.md](ui.md) | tombol UI + teks (nama senjata dll) | 155 |
| [scripts.md](scripts.md) | inventaris script | 371 unik |
| [CHANGELOG.md](CHANGELOG.md) | riwayat tiap batch | - |

## Kekurangan data saat ini

- Source script tidak terbaca (0/1192) → aktifkan *Decompile fallback (DC)* di Scan options dumper.
- Baru 1 remote punya call tertangkap → aktifkan *Record game actions (REC)* di dumper dan main sebentar sebelum dump.

## Untuk AI

- Aturan kerja: [`../AGENT.md`](../AGENT.md). Data mesin: `../../memory/*.json`.
- Jawab dari file di atas; jika datanya tidak ada, katakan tidak ada — jangan mengarang.
