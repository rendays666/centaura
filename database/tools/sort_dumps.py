#!/usr/bin/env python3
"""sort_dumps.py - sortir dump DUMPER ke database Centaura. Hanya stdlib.

Pakai (dari root repo):
    python3 database/tools/sort_dumps.py            # proses nyata
    python3 database/tools/sort_dumps.py --dry      # laporan saja, tidak menulis/memindah apa pun

Alur: baca database/input/unshorted/*.txt -> dedupe sha256 -> parse -> merge delta ke memory/*.json
      -> render database/knowledge/*.md -> pindahkan file mentah ke database/input/shorted/<game>/<batch>/.
Tidak pernah menyentuh *.lua. Aturan lengkap: database/AGENT.md
"""
import argparse
import hashlib
import json
import re
import shutil
import sys
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path

SCHEMA = 2
FNAME = re.compile(r'^(?P<type>ai_brief|config|full|index|mechanics|paths|remotes|smart|tree)_(?P<batch>\d{8}_\d{6})\.txt$')
RCLS = r'(?:RemoteEvent|RemoteFunction|UnreliableRemoteEvent)'
SERVICES = ('Workspace', 'Players')


# ---------------------------------------------------------------- util
def jload(path, default):
    try:
        return json.loads(Path(path).read_text(encoding='utf-8'))
    except (OSError, ValueError):
        return default


def jdump(obj):
    return json.dumps(obj, indent=1, sort_keys=True, ensure_ascii=False) + '\n'


def sha256(path):
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        for chunk in iter(lambda: f.read(1 << 20), b''):
            h.update(chunk)
    return h.hexdigest()


def esc(s):
    return s.replace('|', '\\|')


# ---------------------------------------------------------------- header & players
def parse_header(text):
    head = text[:4000]
    h = {}
    for key, rx in (('game', r'(?m)^Game\s*:\s*([^|\n]+?)\s*(?:\||$)'),
                    ('place_id', r'PlaceId\s*:\s*(\d+)'),
                    ('player', r'(?m)^Player\s*:\s*(\S+)'),
                    ('generated', r'Generated\s*:\s*(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})'),
                    ('dumper', r'DUMPER v([\d.]+)'),
                    ('readable', r'readable=(\d+)')):
        m = re.search(rx, head)
        if m:
            h[key] = m.group(1)
    return h


def find_players(texts, local):
    pl = set()
    for t in texts:
        pl.update(re.findall(r'(?m)^  (\S+) \[Player\]\s*$', t))
        pl.update(re.findall(r'\bPlayers\.([^.\s\[\]*<>]+)\.', t))
    if local:
        pl.add(local)
    return {p for p in pl if p and p != '*'}


def norm_path(p, players, local=None, local_token=None):
    p = p.replace('.*.', '.<PLAYER>.')
    parts = p.split('.')
    if len(parts) >= 2 and parts[0] in SERVICES and parts[1] in players:
        parts[1] = local_token if (local_token and parts[1] == local) else '<PLAYER>'
    return '.'.join(parts)


def mask(s, players):
    if not players:
        return s
    rx = r'\b(?:' + '|'.join(re.escape(p) for p in sorted(players, key=len, reverse=True)) + r')\b'
    return re.sub(rx, '<PLAYER>', s)


# ---------------------------------------------------------------- parsers (semua mengembalikan data per-file)
def parse_remotes(text, players):
    res = Counter()
    for m in re.finditer(r'(?m)^\[(' + RCLS + r')\] (\S.*?)\s*$', text):
        path = norm_path(m.group(2), players)
        if '.' in path:  # baris tanpa path (cuplikan 'mechanic hits') dilewati
            res[(path, m.group(1))] += 1
    return res


def parse_brief(text, players):
    """Signature remote dari ai_brief: [(container, name, method, sig, n)]. sig '?' = tidak diketahui."""
    out, container = [], None
    for line in text.splitlines():
        m = re.match(r'^@ (.+?)\s*$', line)
        if m:
            container = None if m.group(1) == '?' else norm_path(m.group(1), players)
            continue
        m = re.match(r'^\s+\[(\w+)\] (.+?):(FireServer|InvokeServer)\((.*)\)(?: ×(\d+))?\s*$', line)
        if m:
            out.append((container, m.group(2), m.group(3), m.group(4), int(m.group(5) or 1)))
    return out


def parse_tree(text, players):
    start = text.find('=== STRUCTURE TREE ===')
    if start < 0:
        return None
    end = text.find('Legend:', start)
    block = text[start:end if end > 0 else len(text)]
    tops, stack = {}, []
    for line in block.splitlines():
        m = re.match(r'^\[(\w+)\]\s*$', line)
        if m:
            tops[m.group(1)] = []
            stack = [(0, tops[m.group(1)])]
            continue
        m = re.match(r'^( +)(.*) \[([^\]]+)\]((?: [*!]+)?)\s*$', line)
        if not m or not stack:
            continue
        depth = len(m.group(1)) // 2
        node = {'n': m.group(2), 'c': m.group(3), 'f': m.group(4).strip(), 'k': []}
        while len(stack) > 1 and stack[-1][0] >= depth:
            stack.pop()
        stack[-1][1].append(node)
        stack.append((depth, node['k']))
    return {svc: collapse(nodes, players, svc in SERVICES) for svc, nodes in tops.items()}


def collapse(nodes, players, is_player_level):
    acc = {}
    for nd in nodes:
        name = '<PLAYER>' if (is_player_level and nd['n'] in players) else nd['n']
        key = f"{name} [{nd['c']}]"
        e = acc.setdefault(key, {'x': 0, 'f': set(), 'k': []})
        e['x'] += 1
        e['f'].update(nd['f'].replace(' ', ''))
        e['k'].extend(nd['k'])
    out = {}
    for key, e in acc.items():
        r = {'x': e['x']}
        if e['f']:
            r['f'] = ''.join(sorted(e['f']))
        kids = collapse(e['k'], players, False)
        if kids:
            r['k'] = kids
        out[key] = r
    return out


def parse_values(text, players):
    out = {}
    for m in re.finditer(r'(?m)^\[(\w+Value)\] (\S.*?) = (.*)$', text):
        path = norm_path(m.group(2), players)
        val = mask(m.group(3).strip(), players)[:120]
        e = out.setdefault(path, {'c': m.group(1), 'n': 0, 'v': Counter()})
        e['n'] += 1
        e['v'][val] += 1
    return out


def split_attrs(body):
    marks = [(m.start(1), m.end(), m.group(1)) for m in re.finditer(r'(?:^|, )([A-Za-z_]\w*)=', body)]
    res = {}
    for i, (s, e, k) in enumerate(marks):
        stop = marks[i + 1][0] - 2 if i + 1 < len(marks) else len(body)
        res[k] = body[e:stop].strip()
    return res


def parse_attrs(text, players):
    out = {}
    for m in re.finditer(r'(?m)^\[Attr\] (\S.*?): \{(.*)\}\s*$', text):
        path = norm_path(m.group(1), players)
        ent = out.setdefault(path, {})
        for k, v in split_attrs(m.group(2)).items():
            v = mask(v, players)[:80]
            a = ent.setdefault(k, {'n': 0, 'ex': [], 'min': None, 'max': None})
            a['n'] += 1
            if v not in a['ex'] and len(a['ex']) < 4:
                a['ex'].append(v)
            try:
                f = float(v)
                a['min'] = f if a['min'] is None else min(a['min'], f)
                a['max'] = f if a['max'] is None else max(a['max'], f)
            except ValueError:
                a['min'] = a['max'] = None
                a['nonnum'] = True
    return out


def section_lines(text, header_rx):
    lines = text.splitlines()
    for i, ln in enumerate(lines):
        if re.match(header_rx, ln):
            j = i + 1
            while j < len(lines) and not lines[j].startswith('## ') and not lines[j].startswith('=====') \
                    and not lines[j].startswith('───'):
                j += 1
            return lines[i + 1:j]
    return []


def parse_ui(text, players, local):
    out, cur = {}, None
    for ln in section_lines(text, r'^## UI —'):
        m = re.match(r'^\[\d+\] (\S+) \[(\w+)\]\s*$', ln)
        if m:
            p = m.group(1)
            pre = f'Players.{local}.PlayerGui.'
            p = 'PlayerGui.' + p[len(pre):] if local and p.startswith(pre) else norm_path(p, players, local, '<LOCAL>')
            cur = out.setdefault(p, {'c': m.group(2), 'n': 0, 't': [], 'img': []})
            cur['n'] += 1
            continue
        if cur is None:
            continue
        m = re.match(r'^\s+text="(.*)"\s*$', ln)
        if m and m.group(1) not in cur['t'] and len(cur['t']) < 80:
            cur['t'].append(mask(m.group(1), players)[:80])
        m = re.match(r'^\s+image=(\S+)', ln)
        if m and m.group(1) not in cur['img'] and len(cur['img']) < 3:
            cur['img'].append(m.group(1)[:120])
    return out


def split_args(args):
    toks, buf, depth, instr, i = [], '', 0, False, 0
    while i < len(args):
        ch = args[i]
        if instr:
            buf += ch
            if ch == '\\' and i + 1 < len(args):
                buf += args[i + 1]
                i += 1
            elif ch == '"':
                instr = False
        elif ch == '"':
            instr = True
            buf += ch
        elif ch in '([{':
            depth += 1
            buf += ch
        elif ch in ')]}':
            depth -= 1
            buf += ch
        elif ch == ',' and depth == 0:
            toks.append(buf.strip())
            buf = ''
        else:
            buf += ch
        i += 1
    if buf.strip():
        toks.append(buf.strip())
    return toks


def arg_type(tok):
    if tok.startswith('"'):
        return 'string'
    if tok.startswith('table'):
        return 'table'
    if re.fullmatch(r'-?\d+(\.\d+)?', tok):
        return 'number'
    if tok in ('true', 'false'):
        return 'boolean'
    return re.split(r'[(\[ ]', tok, 1)[0][:20] or '?'


def parse_calls(text, players):
    res, unresolved = {}, 0
    entries = []
    for ln in section_lines(text, r'^## FireServer/InvokeServer —'):
        if re.match(r'^\[\d+\] ', ln):
            entries.append(ln)
        elif entries and ln.strip() and not ln[0].isspace():
            entries[-1] += ' ' + ln  # argumen string bisa memuat newline mentah
    for ln in entries:
        m = re.match(r'^\[\d+\] (FireServer|InvokeServer) ([^(]*)\((.*)\)\s*$', ln)
        if not m:
            continue
        path = norm_path(m.group(2).strip(), players)
        if '.' not in path:
            unresolved += 1
            continue
        sig = ','.join(arg_type(t) for t in split_args(m.group(3))) or '()'
        e = res.setdefault(path, {'method': m.group(1), 'sigs': Counter(), 'ex': []})
        e['sigs'][sig] += 1
        ex = mask(m.group(3), players)[:100]
        if ex not in e['ex'] and len(e['ex']) < 2:
            e['ex'].append(ex)
    return res, unresolved


def parse_scripts(text, players):
    out = Counter()
    meta = {}
    pats = (r'(?m)^\[\d+/\d+\] (\w+) \| (\w+) \| (\d+)B \| (.+?)\s*$',
            r'(?m)^\[(\w+) \| (\w+) \| (\d+)B\] (.+?)\s*$')
    for rx in pats:
        for m in re.finditer(rx, text):
            parts = norm_path(m.group(4), players).split('.')
            if parts[0] in players:
                parts[0] = '<PLAYER>'
            p = '.'.join(parts)
            key = (p, m.group(1), m.group(2))
            out[key] += 1
            meta[key] = max(meta.get(key, 0), int(m.group(3)))
        if out:
            break
    return out, meta


def parse_mech_totals(text):
    return {m.group(2).strip(): int(m.group(1))
            for m in re.finditer(r'Total:\s*(\d+)\s+([A-Za-z ]+?)\s*─', text)}


# ---------------------------------------------------------------- merge helpers
def merge_tree(a, b):
    for k, v in b.items():
        e = a.setdefault(k, {'x': 0})
        e['x'] = max(e['x'], v['x'])
        f = ''.join(sorted(set(e.get('f', '')) | set(v.get('f', ''))))
        if f:
            e['f'] = f
        if 'k' in v:
            merge_tree(e.setdefault('k', {}), v['k'])


def maxmerge(dst, src):
    for k, v in src.items():
        dst[k] = max(dst.get(k, 0), v)


# ---------------------------------------------------------------- classification
class Cats:
    def __init__(self, path):
        d = jload(path, {})
        self.scope = [(s, re.compile(r)) for s, r in d.get('scope', [])]
        self.scope_default = d.get('scope_default', 'game')
        self.cat = [(c, re.compile(r)) for c, r in d.get('category', [])]
        self.cat_default = d.get('category_default', 'uncategorized')
        self.cat_scope = d.get('category_for_scope', {})
        self.vgroups = [(g, re.compile(r)) for g, r in d.get('value_groups', [])]

    def classify(self, path):
        name = path.rsplit('.', 1)[-1]
        scope = next((s for s, rx in self.scope if rx.search(path)), self.scope_default)
        if scope in self.cat_scope:
            return scope, self.cat_scope[scope]
        cat = next((c for c, rx in self.cat if rx.search(name)), self.cat_default)
        return scope, cat

    def vgroup(self, path):
        return next((g for g, rx in self.vgroups if rx.search(path)), 'other')


# ---------------------------------------------------------------- renderers
def banner(title, meta, note=''):
    last = meta['batches'][-1]['id'] if meta.get('batches') else '-'
    return (f"# {title} — {meta.get('game', '?')}\n\n> Dibuat otomatis oleh `database/tools/sort_dumps.py` dari `memory/*.json`. "
            f"JANGAN edit manual. Batch terakhir: `{last}`.{note}\n\n")


def render_remotes(rem, fn, meta):
    items = rem['remotes']
    by = {}
    for p, e in items.items():
        by.setdefault(e['scope'], {}).setdefault(e['category'], []).append((p, e))
    o = [banner('Remotes', meta)]
    cnt = {s: sum(len(v) for v in c.values()) for s, c in by.items()}
    o.append(f"Total {len(items)} · " + ' · '.join(f'{s} {n}' for s, n in sorted(cnt.items())) + '\n\n')
    for scope, title in (('game', 'Game remotes'), ('tool', 'Tool remotes (ada di Backpack/Workspace pemain)'),
                         ('roblox_internal', 'Roblox internal (abaikan)')):
        if scope not in by:
            continue
        o.append(f'## {title}\n\n')
        for cat in sorted(by[scope]):
            o.append(f'### {cat} ({len(by[scope][cat])})\n')
            for p, e in sorted(by[scope][cat], key=lambda x: x[0]):
                o.append(f"- `{e['name']}` — {e['class']} — `{p}`" + (f" — ×{e['instances']}" if e['instances'] > 1 else '') + '\n')
            o.append('\n')
    o.append('## Call yang pernah tertangkap\n\n')
    calls = fn.get('calls', {})
    if calls:
        for p, e in sorted(calls.items()):
            sigs = '; '.join(f'`({s})` ×{n}' for s, n in sorted(e['sigs'].items()))
            o.append(f"- `{p}` — {e['method']} — {sigs}\n")
    else:
        o.append('_Belum ada._\n')
    u = fn.get('unresolved', {})
    if u.get('count'):
        o.append(f"\n{u['count']} call lain tertangkap tanpa path remote (batch `{u.get('batch')}`) — tidak bisa dipakai.\n")
    decl = fn.get('declared_sigs', {})
    if decl:
        o.append('\n## Signature dari ai_brief\n\n')
        for p, e in sorted(decl.items()):
            o.append(f"- `{p}` — {e['method']}({e['sig']})\n")
    return ''.join(o)


def render_tree(tree, meta):
    o = [banner('Struktur game', meta, '\n> Nama pemain diganti `<PLAYER>`; saudara kembar digabung `×N`. `*` = script, `!` = remote.')]

    def walk(d, depth):
        for key in sorted(d):
            v = d[key]
            o.append('  ' * depth + key + (f" ×{v['x']}" if v['x'] > 1 else '') + (f" {' '.join(v['f'])}" if v.get('f') else '') + '\n')
            if 'k' in v:
                walk(v['k'], depth + 1)
    for svc in sorted(tree['tree']):
        o.append(f'## {svc}\n\n```\n')
        walk(tree['tree'][svc], 0)
        o.append('```\n\n')
    return ''.join(o)


def render_values(vals, cats, meta):
    o = [banner('Value & atribut', meta, '\n> Nilai = yang terlihat di dump; beberapa nilai berubah tiap ronde.')]
    groups = {}
    for p, e in vals['values'].items():
        groups.setdefault(cats.vgroup(p), []).append((p, e))
    for g in sorted(groups):
        o.append(f'## {g} ({len(groups[g])})\n\n')
        for p, e in sorted(groups[g]):
            seen = e['v']
            shown = ' | '.join(seen[:4]) + (f' (+{len(seen) - 4})' if len(seen) > 4 else '')
            o.append(f"- `{p}` [{e['c']}] = {shown}" + (f" ×{e['n']}" if e['n'] > 1 else '') + '\n')
        o.append('\n')
    o.append('## Atribut\n\n')
    for p, ent in sorted(vals['attributes'].items()):
        o.append(f'- `{p}`\n')
        for k, a in sorted(ent.items()):
            rng = f" (rentang {a['min']:g}..{a['max']:g})" if a.get('min') is not None and not a.get('nonnum') else ''
            o.append(f"  - {k}: {', '.join(a['ex'])}{rng}\n")
    return ''.join(o)


def render_ui(ui, meta):
    o = [banner('UI (tombol PlayerGui)', meta)]
    groups = {}
    for p, e in ui['ui'].items():
        segs = p.split('.')
        g = segs[1] if segs[0] == 'PlayerGui' and len(segs) > 1 else segs[0]
        groups.setdefault(g, []).append((p, e))
    for g in sorted(groups):
        o.append(f'## {g}\n\n')
        for p, e in sorted(groups[g]):
            txt = (': ' + ', '.join(f'"{t}"' for t in e['t'])) if e['t'] else ''
            o.append(f"- `{p}` [{e['c']}]" + (f" ×{e['n']}" if e['n'] > 1 else '') + txt + '\n')
        o.append('\n')
    return ''.join(o)


def render_scripts(sc, meta):
    o = [banner('Inventaris script', meta)]
    s = sc.get('summary', {})
    o.append(f"Batch `{s.get('batch', '-')}`: total {s.get('total', 0)} · readable {s.get('readable', 0)} · "
             f"empty {s.get('empty', 0)} · unik {len(sc['scripts'])}\n\n")
    if s.get('total') and not s.get('readable'):
        o.append('> **Source belum terbaca** — semua script kosong di dump. Aktifkan *Decompile fallback (DC)* di Scan options dumper lalu dump ulang.\n\n')
    for p, e in sorted(sc['scripts'].items()):
        o.append(f"- `{p}` — {e['c']} — {'/'.join(e['s'])}" + (f" — {e['b']}B" if e['b'] else '') + (f" ×{e['n']}" if e['n'] > 1 else '') + '\n')
    return ''.join(o)


def render_index(meta, stores, gaps, cats_doc):
    rem, fn, tr, va, ui, sc = stores
    b = meta['batches'][-1] if meta.get('batches') else {}
    rs = Counter(e['scope'] for e in rem['remotes'].values())
    o = [f"# {meta.get('game', '?')} — Knowledge Index\n\n",
         "> Titik masuk untuk AI. Baca file ini dulu, lalu hanya file yang relevan. **Jangan baca `input/shorted/` (mentah, besar).**\n\n",
         f"- PlaceId: `{meta.get('place_id', '?')}` · batch terakhir: `{b.get('id', '-')}` (dump {b.get('generated', '?')}) · total batch: {len(meta.get('batches', []))}\n\n",
         '| File | Isi | Jumlah |\n|---|---|---|\n',
         f"| [remotes.md](remotes.md) | semua remote + kategori + call tertangkap | {len(rem['remotes'])} (game {rs['game']}, tool {rs['tool']}, internal {rs['roblox_internal']}) |\n",
         f"| [tree.md](tree.md) | struktur game | {len(tr['tree'])} service |\n",
         f"| [values.md](values.md) | Value/Attribute (harga, cooldown, state) | {len(va['values'])} value, {len(va['attributes'])} atribut |\n",
         f"| [ui.md](ui.md) | tombol UI + teks (nama senjata dll) | {len(ui['ui'])} |\n",
         f"| [scripts.md](scripts.md) | inventaris script | {len(sc['scripts'])} unik |\n",
         '| [CHANGELOG.md](CHANGELOG.md) | riwayat tiap batch | - |\n\n',
         '## Kekurangan data saat ini\n\n']
    o.extend(f'- {g}\n' for g in gaps) if gaps else o.append('_Tidak ada._\n')
    o.append('\n## Untuk AI\n\n- Aturan kerja: [`../AGENT.md`](../AGENT.md). Data mesin: `../../memory/*.json`.\n'
             '- Jawab dari file di atas; jika datanya tidak ada, katakan tidak ada — jangan mengarang.\n')
    return ''.join(o)


# ---------------------------------------------------------------- main
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--dry', action='store_true')
    ap.add_argument('--root')
    ap.add_argument('--render-only', action='store_true', help='render ulang knowledge/*.md dari memory/*.json (+klasifikasi ulang remote) tanpa memproses file')
    ap.add_argument('--allow-partial', action='store_true', help='izinkan batch tanpa tree_/full_ (normalisasi pemain tidak lengkap)')
    a = ap.parse_args()
    root = Path(a.root).resolve() if a.root else Path(__file__).resolve().parents[2]
    db, mem = root / 'database', root / 'memory'
    uns, sho, know = db / 'input' / 'unshorted', db / 'input' / 'shorted', db / 'knowledge'
    cats = Cats(db / 'tools' / 'categories.json')
    log = []

    def say(s):
        log.append(s)
        print(s)

    meta = jload(mem / 'meta.json', {})
    if meta.get('schema') != SCHEMA:
        meta = {'schema': SCHEMA, 'batches': []}
    reg = jload(mem / 'files.json', {})
    reg = reg if reg.get('schema') == SCHEMA else {'schema': SCHEMA, 'files': {}}
    rem = jload(mem / 'remotes.json', {})
    rem = rem if rem.get('schema') == SCHEMA else {'schema': SCHEMA, 'remotes': {}}
    fn = jload(mem / 'functions.json', {})
    fn = fn if fn.get('schema') == SCHEMA else {'schema': SCHEMA, 'calls': {}, 'declared_sigs': {}, 'handlers': {}, 'modules': {}, 'unresolved': {}}
    tr = jload(mem / 'tree.json', {})
    tr = tr if tr.get('schema') == SCHEMA else {'schema': SCHEMA, 'tree': {}}
    va = jload(mem / 'values.json', {})
    va = va if va.get('schema') == SCHEMA else {'schema': SCHEMA, 'values': {}, 'attributes': {}}
    ui = jload(mem / 'ui.json', {})
    ui = ui if ui.get('schema') == SCHEMA else {'schema': SCHEMA, 'ui': {}}
    sc = jload(mem / 'scripts.json', {})
    sc = sc if sc.get('schema') == SCHEMA else {'schema': SCHEMA, 'summary': {}, 'scripts': {}}

    # ---- kumpulkan file
    uns.mkdir(parents=True, exist_ok=True)
    groups, unknown = {}, []
    for p in ([] if a.render_only else sorted(uns.iterdir())):
        if p.is_dir() or p.name.startswith('.') or p.name.lower().startswith('readme'):
            continue
        m = FNAME.match(p.name)
        if m:
            groups.setdefault(m['batch'], []).append((m['type'], p))
        else:
            unknown.append(p.name)
    for n in unknown:
        say(f'SKIP  nama tidak dikenal, dibiarkan di unshorted: {n}')
    if not groups and not a.render_only:
        say('Tidak ada file dump baru di database/input/unshorted/.')

    changelog = []
    processed = 0
    if a.render_only:
        for k, e in rem['remotes'].items():
            e['scope'], e['category'] = cats.classify(k)
        processed = 1
        say('RENDER knowledge/*.md dirender ulang dari memory/*.json')
    for batch in sorted(groups):
        entries = groups[batch]
        new, dups = [], []
        for typ, p in entries:
            h = sha256(p)
            old = reg['files'].get(h)
            if old and (root / old['archive']).exists():
                dups.append((typ, p, h))
            else:
                new.append((typ, p, h))
        dup_texts = [p.read_text(encoding='utf-8', errors='replace') for typ, p, h in dups if typ in ('tree', 'full')]
        for typ, p, h in dups:
            say(f'DUP   {p.name} sama dengan {reg["files"][h]["archive"]} — ' + ('akan dihapus dari unshorted' if a.dry else 'dihapus dari unshorted'))
            if not a.dry:
                p.unlink()
        if not new:
            continue
        texts = {typ: p.read_text(encoding='utf-8', errors='replace') for typ, p, _ in new}
        hdr = {}
        for typ in ('smart', 'full', 'mechanics', 'ai_brief', 'index'):
            if typ in texts:
                hdr = parse_header(texts[typ])
                break
        if not hdr.get('place_id'):
            say(f'WARN  batch {batch}: tidak ada file ber-header — PlaceId tidak terverifikasi')
        if hdr.get('place_id') and meta.get('place_id') and hdr['place_id'] != str(meta['place_id']):
            say(f"STOP  batch {batch}: PlaceId {hdr['place_id']} != {meta['place_id']} (game lain). File dibiarkan di unshorted.")
            continue
        if hdr.get('place_id') and not meta.get('place_id'):
            meta['place_id'] = int(hdr['place_id'])
            meta['game'] = hdr.get('game', 'CENTAURA')
        meta.setdefault('game', hdr.get('game', 'CENTAURA'))
        local = hdr.get('player')
        alltexts = list(texts.values()) + dup_texts
        players = find_players(alltexts, local)
        if not any(re.search(r'(?m)^  \S+ \[Player\]\s*$', t) for t in alltexts) and not a.allow_partial:
            say(f'STOP  batch {batch}: tidak ada daftar pemain (butuh tree_ atau full_ di batch yang sama) — '
                'tanpa itu nama pemain tidak bisa dinormalkan. File dibiarkan di unshorted.')
            continue

        # gabungkan hasil parse semua file di batch: ambil maksimum agar file redundan (full) tidak menggandakan hitungan
        b_rem, b_tree, b_vals, b_attrs, b_ui, b_calls = Counter(), {}, {}, {}, {}, {}
        b_unres, b_brief, b_scripts, b_smeta, b_mech = 0, [], Counter(), {}, {}
        for typ, t in texts.items():
            for k, n in parse_remotes(t, players).items():
                b_rem[k] = max(b_rem[k], n)
            tt = parse_tree(t, players)
            for svc, kids in (tt or {}).items():
                merge_tree(b_tree.setdefault(svc, {}), kids)
            for p_, e in parse_values(t, players).items():
                d = b_vals.setdefault(p_, {'c': e['c'], 'n': 0, 'v': Counter()})
                d['n'] = max(d['n'], e['n'])
                maxmerge(d['v'], e['v'])
            for p_, ent in parse_attrs(t, players).items():
                d = b_attrs.setdefault(p_, {})
                for k, at in ent.items():
                    x = d.setdefault(k, {'n': 0, 'ex': [], 'min': None, 'max': None})
                    x['n'] = max(x['n'], at['n'])
                    for v in at['ex']:
                        if v not in x['ex'] and len(x['ex']) < 4:
                            x['ex'].append(v)
                    if at.get('nonnum') or x.get('nonnum'):
                        x['nonnum'] = True
                    for kk, f in (('min', min), ('max', max)):
                        if at[kk] is not None:
                            x[kk] = at[kk] if x[kk] is None else f(x[kk], at[kk])
            for p_, e in parse_ui(t, players, local).items():
                d = b_ui.setdefault(p_, {'c': e['c'], 'n': 0, 't': [], 'img': []})
                d['n'] = max(d['n'], e['n'])
                d['t'] += [x for x in e['t'] if x not in d['t']][:80 - len(d['t'])]
                d['img'] += [x for x in e['img'] if x not in d['img']][:3 - len(d['img'])]
            c, u = parse_calls(t, players)
            b_unres = max(b_unres, u)
            for p_, e in c.items():
                d = b_calls.setdefault(p_, {'method': e['method'], 'sigs': Counter(), 'ex': []})
                maxmerge(d['sigs'], e['sigs'])
                d['ex'] += [x for x in e['ex'] if x not in d['ex']][:2 - len(d['ex'])]
            b_brief += parse_brief(t, players)
            s, sm = parse_scripts(t, players)
            for k, n in s.items():
                b_scripts[k] = max(b_scripts[k], n)
            for k, v in sm.items():
                b_smeta[k] = max(b_smeta.get(k, 0), v)
            if typ == 'mechanics':
                b_mech = parse_mech_totals(t)

        # ---- merge ke store
        diff = Counter()
        for (p_, cls), n in b_rem.items():
            scope, cat = cats.classify(p_)
            e = rem['remotes'].get(p_)
            if e is None:
                diff['remotes'] += 1
                e = rem['remotes'][p_] = {'name': p_.rsplit('.', 1)[-1], 'class': cls, 'instances': 0, 'first_seen': batch, 'seen': 0}
            e.update({'class': cls, 'scope': scope, 'category': cat, 'last_seen': batch})
            e['instances'] = max(e['instances'], n)
            e['seen'] += 1
        if b_tree:
            before = json.dumps(tr['tree'], sort_keys=True)
            for svc, kids in b_tree.items():
                merge_tree(tr['tree'].setdefault(svc, {}), kids)
            if json.dumps(tr['tree'], sort_keys=True) != before:
                diff['tree'] += 1
        for p_, e in b_vals.items():
            old = va['values'].get(p_)
            existed = old is not None
            if old is None:
                diff['values'] += 1
                old = va['values'][p_] = {'c': e['c'], 'n': 0, 'v': []}
            old['n'] = max(old['n'], e['n'])
            for v, _ in e['v'].most_common():
                if v not in old['v'] and len(old['v']) < 8:
                    if existed and old['v']:
                        diff['values_changed'] += 1
                    old['v'].append(v)
        for p_, ent in b_attrs.items():
            old = va['attributes'].setdefault(p_, {})
            for k, at in ent.items():
                if k not in old:
                    diff['attributes'] += 1
                o = old.setdefault(k, {'n': 0, 'ex': [], 'min': None, 'max': None})
                o['n'] = max(o['n'], at['n'])
                o['ex'] += [x for x in at['ex'] if x not in o['ex']][:4 - len(o['ex'])]
                if at.get('nonnum') or o.get('nonnum'):
                    o['nonnum'] = True
                for kk, f in (('min', min), ('max', max)):
                    if at[kk] is not None:
                        o[kk] = at[kk] if o[kk] is None else f(o[kk], at[kk])
        for p_, e in b_ui.items():
            old = ui['ui'].get(p_)
            if old is None:
                diff['ui'] += 1
                old = ui['ui'][p_] = {'c': e['c'], 'n': 0, 't': [], 'img': []}
            old['n'] = max(old['n'], e['n'])
            old['t'] += [x for x in e['t'] if x not in old['t']][:80 - len(old['t'])]
            old['img'] += [x for x in e['img'] if x not in old['img']][:3 - len(old['img'])]
        for p_, e in b_calls.items():
            old = fn['calls'].get(p_)
            if old is None:
                diff['calls'] += 1
                old = fn['calls'][p_] = {'method': e['method'], 'sigs': {}, 'ex': [], 'first_seen': batch}
            maxmerge(old['sigs'], e['sigs'])
            old['ex'] += [x for x in e['ex'] if x not in old['ex']][:2 - len(old['ex'])]
            old['last_seen'] = batch
        if b_unres:
            fn['unresolved'] = {'batch': batch, 'count': max(b_unres, fn.get('unresolved', {}).get('count', 0) if fn.get('unresolved', {}).get('batch') == batch else 0)}
        for container, name, method, sig, _n in b_brief:
            if sig != '?' and container:
                key = f'{container}.{name}'
                if key not in fn['declared_sigs']:
                    diff['signatures'] += 1
                fn['declared_sigs'][key] = {'method': method, 'sig': sig}
        for k, v in b_mech.items():
            if v:
                say(f'WARN  mechanics berisi data baru ({k}={v}) — parser belum menangani; proses manual sesuai AGENT.md §7')
        if b_scripts:
            tot = Counter()
            for (p_, cls, st), n in b_scripts.items():
                tot[st] += n
                old = sc['scripts'].get(p_)
                if old is None:
                    diff['scripts'] += 1
                    old = sc['scripts'][p_] = {'c': cls, 's': [], 'b': 0, 'n': 0}
                if st not in old['s']:
                    old['s'] = sorted(old['s'] + [st])
                old['b'] = max(old['b'], b_smeta[(p_, cls, st)])
                old['n'] = max(old['n'], n)
            sc['summary'] = {'batch': batch, 'total': sum(tot.values()), **{k: v for k, v in sorted(tot.items())}}
            if tot.get('readable') or int(hdr.get('readable', 0) or 0):
                say('WARN  ada script readable — source belum diparse; simpan sesuai AGENT.md §7 dan lapor ke user')

        # ---- arsip file mentah
        slug = re.sub(r'[^a-z0-9]+', '-', meta['game'].lower()).strip('-')
        for typ, p, h in new:
            dest = sho / slug / batch / p.name
            if dest.exists():
                dest = dest.with_name(dest.name + '.' + h[:8])
            rel = dest.relative_to(root).as_posix()
            reg['files'][h] = {'name': p.name, 'type': typ, 'batch': batch, 'archive': rel,
                               'bytes': p.stat().st_size, 'processed_at': datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')}
            if not a.dry:
                dest.parent.mkdir(parents=True, exist_ok=True)
                shutil.move(str(p), str(dest))
        meta['batches'] = [x for x in meta['batches'] if x['id'] != batch] + [
            {'id': batch, 'generated': hdr.get('generated'), 'dumper': hdr.get('dumper'),
             'files': sorted(p.name for _, p, _ in new)}]
        meta['batches'].sort(key=lambda x: x['id'])
        processed += 1
        summary = ', '.join(f'+{n} {k}' for k, n in sorted(diff.items())) or 'tidak ada data baru'
        say(f"OK    batch {batch}: {len(new)} file diproses ({', '.join(sorted(t for t, _, _ in new))}); {summary}")
        changelog.append(f"## {batch}\n\n- Dump: {hdr.get('generated', '?')} · dumper {hdr.get('dumper', '?')}\n"
                         f"- File: {', '.join(sorted(p.name for _, p, _ in new))}\n- Hasil: {summary}\n\n")

    # ---- tulis hasil
    if processed and not a.dry:
        gaps = []
        s = sc.get('summary', {})
        if s.get('total') and not s.get('readable'):
            gaps.append(f"Source script tidak terbaca ({s.get('readable', 0)}/{s['total']}) → aktifkan *Decompile fallback (DC)* di Scan options dumper.")
        if len(fn['calls']) < 5:
            gaps.append(f"Baru {len(fn['calls'])} remote punya call tertangkap → aktifkan *Record game actions (REC)* di dumper dan main sebentar sebelum dump.")
        if not rem['remotes']:
            gaps.append('Belum ada data remote.')
        mem.mkdir(parents=True, exist_ok=True)
        know.mkdir(parents=True, exist_ok=True)
        for name, obj in (('meta', meta), ('files', reg), ('remotes', rem), ('functions', fn), ('tree', tr), ('values', va), ('ui', ui), ('scripts', sc)):
            (mem / f'{name}.json').write_text(jdump(obj), encoding='utf-8')
        (know / 'remotes.md').write_text(render_remotes(rem, fn, meta), encoding='utf-8')
        (know / 'tree.md').write_text(render_tree(tr, meta), encoding='utf-8')
        (know / 'values.md').write_text(render_values(va, cats, meta), encoding='utf-8')
        (know / 'ui.md').write_text(render_ui(ui, meta), encoding='utf-8')
        (know / 'scripts.md').write_text(render_scripts(sc, meta), encoding='utf-8')
        (know / 'INDEX.md').write_text(render_index(meta, (rem, fn, tr, va, ui, sc), gaps, None), encoding='utf-8')
        cl = know / 'CHANGELOG.md'
        old = cl.read_text(encoding='utf-8') if cl.exists() else f"# Changelog — {meta['game']}\n\n> Satu blok per batch dump yang diproses.\n\n"
        cl.write_text(old + ''.join(changelog), encoding='utf-8')
    if a.dry:
        say('DRY   tidak ada yang ditulis/dipindah.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
