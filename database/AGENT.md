# AGENT.md — Aturan untuk AI (database Centaura)

Dokumen ini satu-satunya sumber aturan. Baca penuh sebelum menyentuh apa pun.

## 0. Magic word

Pesan user berisi **`SHORTING CENTAURA`** (besar/kecil bebas) + link repo → jalankan §2.
Ditambah kata `DRY` → hanya laporan (`--dry`), tidak ada file yang diubah atau dipindah.
Tanpa magic word: jangan memproses `unshorted/` atas inisiatif sendiri.

## 1. Aturan keras

1. **Jangan menyentuh `*.lua`** (terutama `main.lua`, `Centaura.lua`) dan `README.md` di root. Tulis hanya di `database/` dan `memory/`.
2. **Fakta hanya dari dump.** Tidak ada di dump → tulis "tidak ada" / `?`. Dilarang menebak signature argumen, isi script, harga, dsb.
3. **Jangan hapus data.** File mentah dipindah ke `input/shorted/`. Satu-satunya penghapusan: file di `unshorted/` yang sha256-nya sudah diarsipkan (duplikat persis).
4. `memory/*.json` dan `knowledge/*.md` dihasilkan script. Jangan diedit tangan, kecuali §7.
5. Nama pemain Roblox lain jangan disimpan — diganti `<PLAYER>` (script sudah melakukannya). Jangan menyimpan token/kredensial.
6. Satu repo = satu game. PlaceId dump beda dengan `memory/meta.json` → berhenti dan tanya user.
7. Ragu → berhenti dan tanya. Lebih baik batch menunggu daripada database tercemar.

## 2. Prosedur

**Jalur A — bisa menjalankan kode (wajib dipilih bila bisa):**

1. Pull repo terbaru. Baca `database/knowledge/INDEX.md`.
2. `ls database/input/unshorted/` — abaikan `README*`.
3. `python3 database/tools/sort_dumps.py --dry` → baca laporannya. Bila ada `STOP`/`SKIP`/`WARN`, tangani lewat §7.
4. `python3 database/tools/sort_dumps.py` (stdlib saja, tanpa pip).
5. Validasi (§5).
6. Satu commit untuk semua perubahan di `database/` + `memory/`: `data: sort <batch-id> (+N remotes, +M values, ...)` (ambil dari baris `OK`). Push ke branch default; ditolak → branch `data/sort-<batch-id>` + PR.
7. Lapor (§8).

**Jalur B — tidak bisa menjalankan kode:** jangan memproses manual (dump ±1 MB, hasilnya pasti salah/boros). Lapor ke user: "tidak bisa menjalankan script; jalankan `python3 database/tools/sort_dumps.py` atau pakai agen dengan shell". Selesai.

## 3. Jenis file

Nama wajib `<jenis>_<YYYYMMDD>_<HHMMSS>.txt`. Stempel yang sama = satu **batch**. Nama lain dibiarkan dan dilaporkan.

| Jenis | Isi | Dipakai untuk |
|---|---|---|
| `remotes` | semua RemoteEvent/Function | `remotes.json` |
| `tree` | pohon struktur + **daftar pemain** | `tree.json`, roster normalisasi |
| `config` | VALUES + ATTRIBUTES | `values.json` |
| `smart` | UI buttons + log FireServer/InvokeServer + diagnostik dumper | `ui.json`, `functions.json` |
| `index` / `paths` | daftar script + status | `scripts.json` |
| `ai_brief` | ringkasan terpotong | signature remote saja |
| `mechanics` | API surface, handler, modul | peringatan bila tidak kosong |
| `full` | gabungan semuanya | redundan; diparse sama, hitungan tidak dobel |

## 4. Normalisasi & merge

- Pemain → `<PLAYER>` (UI lokal → `<LOCAL>`); saudara kembar di tree digabung `×N`.
- Remote dikelompokkan: `scope` = `game` / `tool` (di Backpack/Workspace pemain) / `roblox_internal`; `category` dari `database/tools/categories.json` (aturan pertama yang cocok menang). Untuk ubah kategori, **edit JSON itu**, bukan kode.
- Merge bersifat delta: kunci sudah ada → hitungan diambil **maksimum** (bukan dijumlah), nilai baru ditambahkan (maks 8), `first_seen`/`last_seen` diperbarui. Tidak ada entri lama yang dihapus.
- Batch tanpa daftar pemain (`tree_`/`full_`) → `STOP`. Batch PlaceId beda → `STOP`. Keduanya: file tetap di `unshorted/`.

## 5. Validasi sebelum commit

1. `git status --short` hanya memuat `database/` dan `memory/` (tidak ada `.lua`).
2. `unshorted/` hanya berisi `README*` + file yang dilaporkan `SKIP`/`STOP`.
3. Tiap `memory/*.json` valid: `python3 -m json.tool memory/<f>.json > /dev/null`.
4. Angka di tabel `knowledge/INDEX.md` masuk akal terhadap baris `OK` (script menjamin; cek sekilas).
5. `git diff --stat` tidak menunjukkan penghapusan file di luar `unshorted/`.

## 6. Menjawab pertanyaan tentang game

Baca `knowledge/INDEX.md` → buka hanya file yang relevan (`remotes.md`, `values.md`, `ui.md`, `tree.md`, `scripts.md`). **Jangan membaca `input/shorted/`** (mentah, besar). Sebut batch terakhir. Data tidak ada → katakan tidak ada, sebut apa yang perlu di-dump (lihat "Kekurangan data" di INDEX).

## 7. Kasus khusus

- **`uncategorized`**: tambahkan aturan ke `categories.json`, jalankan `python3 database/tools/sort_dumps.py --render-only`.
- **`WARN ada script readable`**: pertama kali source terbaca; parser belum menanganinya. Simpan source apa adanya di `database/knowledge/source/<path-ternormalisasi>.lua.txt`, catat di `CHANGELOG.md`, lapor ke user bahwa parser perlu dilengkapi. Jangan mengarang ringkasan fungsi.
- **`WARN mechanics berisi data baru`**: salin baris asli ke `memory/functions.json` → `handlers`/`modules` (kunci = nama, nilai = teks), lapor ke user bahwa renderer belum menampilkannya.
- **`--allow-partial`**: hanya bila user eksplisit meminta batch tanpa `tree_`/`full_`; hasilnya nama pemain bisa bocor — peringatkan user.
- **File di `unshorted/` bernama tidak dikenal**: biarkan, lapor.
- **Script error**: jangan memperbaiki diam-diam sambil memproses data. Lapor traceback; perbaikan script = commit terpisah.

## 8. Format laporan (maks 10 baris)

```
Batch: <id> (dump <waktu>)
Diproses: <jenis...> | Dilewati: <alasan>
Baru: +N remotes, +M values, ...
WARN/STOP: <ringkas atau "tidak ada">
Kekurangan data: <dari INDEX.md>
Commit: <hash> -> <branch>
```

## 9. Skema `memory/` (semua `schema: 2`)

| File | Isi |
|---|---|
| `meta.json` | `game`, `place_id`, `batches[]` (id, generated, dumper, files) |
| `files.json` | `files{sha256 → {name,type,batch,archive,bytes,processed_at}}` — kunci dedupe |
| `remotes.json` | `remotes{path → {name,class,scope,category,instances,first_seen,last_seen,seen}}` |
| `functions.json` | `calls{path → {method,sigs{tipe→n},ex[]}}`, `declared_sigs`, `unresolved`, `handlers`, `modules` |
| `tree.json` | `tree{service → {"Nama [Class]" → {x,f?,k?}}}` (`x` jumlah, `f` flag `*`/`!`, `k` anak) |
| `values.json` | `values{path → {c,n,v[]}}`, `attributes{path → {key → {n,ex[],min,max}}}` |
| `ui.json` | `ui{path → {c,n,t[],img[]}}` |
| `scripts.json` | `summary{batch,total,empty,readable,...}`, `scripts{path → {c,s[],b,n}}` |
