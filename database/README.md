# database/ — memori game CENTAURA untuk AI

Dump dari DUMPER dijatuhkan mentah, AI menyortirnya jadi pengetahuan terstruktur yang murah dibaca.

```
database/
  AGENT.md              aturan untuk AI (baca ini dulu)
  input/
    unshorted/          <- taruh file dump di sini
    shorted/<game>/<batch>/   arsip mentah setelah diproses
  knowledge/            hasil sortir (INDEX.md = pintu masuk)
  tools/
    sort_dumps.py       parser + merge + render (stdlib saja)
    categories.json     aturan kategori remote (edit ini, bukan kode)
../memory/              data mesin (JSON) — kunci dedupe & delta
```

## Cara pakai

1. Taruh semua file dump (`remotes_`, `tree_`, `config_`, `smart_`, `index_`, ... satu stempel waktu) ke `database/input/unshorted/`, commit/push.
2. Kirim ke AI (yang bisa menjalankan kode):

   ```
   SHORTING CENTAURA https://github.com/rendays666/centaura
   ```

   Tambah `DRY` di belakang untuk pratinjau tanpa mengubah apa pun.
3. AI menjalankan `python3 database/tools/sort_dumps.py`, memverifikasi, commit, lalu melapor.

Yang perlu diingat: sertakan `tree_` (atau `full_`) di setiap batch — daftar pemain di situ dipakai untuk menyamarkan nama pemain.

Manual tanpa AI: `python3 database/tools/sort_dumps.py [--dry | --render-only]`.
