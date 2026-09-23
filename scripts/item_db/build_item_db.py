"""
FFXI item database builder.

Reads the resource files Windower extracts from the game DATs
(res/items.lua, res/item_descriptions.lua, res/jobs.lua, res/slots.lua,
res/skills.lua) and writes a queryable database of every item with its
stats parsed out of the in-game description.

Outputs (in ./out/ next to this script):
    items.sqlite   - tables `items` and `stats` (one row per item x stat)
    items.json     - every item, stats grouped by context
    equipment.csv  - armor + weapons, one row per item, one column per base stat

Stats are split by context: '' is the item's unconditional stats, anything
else is the label the description puts in front of them ('Pet', 'Set',
'Unity Ranking', 'Aftermath', 'Dusk to dawn', ...). A context applies to
everything after its label until the next label.

What the game data cannot contain, and this database therefore lacks:
augments (they live on your own copy of an item), your Unity rank (Unity
stats are stored as a min..max range) and set bonus values.

Usage:
    python build_item_db.py [--res "D:/Windower Tetsouo/res"]

@file    scripts/item_db/build_item_db.py
@author  Tetsouo
@version 1.0
@date    Created: 2026-09-23
"""

import argparse
import csv
import json
import re
import sqlite3
from collections import Counter
from pathlib import Path

# scripts/item_db -> data -> GearSwap -> addons -> Windower root
DEFAULT_RES = Path(__file__).resolve().parents[5] / "res"
OUT_DIR = Path(__file__).resolve().parent / "out"

# --------------------------------------------------------------------------
# Lua resource parsing
# --------------------------------------------------------------------------

ENTRY_RE = re.compile(r"^\s*\[(\d+)\]\s*=\s*\{(.*)\},?\s*$")
LUA_ESCAPES = {"n": "\n", "t": "\t", "r": "\r", '"': '"', "'": "'", "\\": "\\"}


def parse_lua_fields(body):
    """Parse `k=v,k="str",...` (one flat Lua table body) into a dict."""
    fields, i, n = {}, 0, len(body)
    while i < n:
        while i < n and body[i] in " ,":
            i += 1
        if i >= n:
            break
        eq = body.index("=", i)
        key = body[i:eq].strip()
        i = eq + 1
        if body[i] == '"':
            i += 1
            out = []
            while body[i] != '"':
                if body[i] == "\\":
                    nxt = body[i + 1]
                    if nxt.isdigit():
                        digits = re.match(r"\d{1,3}", body[i + 1:]).group()
                        out.append(chr(int(digits)))
                        i += 1 + len(digits)
                        continue
                    out.append(LUA_ESCAPES.get(nxt, nxt))
                    i += 2
                    continue
                out.append(body[i])
                i += 1
            fields[key] = "".join(out)
            i += 1
        else:
            end = i
            while end < n and body[end] != ",":
                end += 1
            raw = body[i:end].strip()
            fields[key] = {"true": True, "false": False}.get(raw) if raw in ("true", "false") else _number(raw)
            i = end
    return fields


def _number(raw):
    try:
        return int(raw)
    except ValueError:
        return float(raw)


def load_resource(path):
    """Load one Windower res/*.lua file as {id: fields}."""
    table = {}
    with open(path, encoding="utf-8") as fh:
        for line in fh:
            m = ENTRY_RE.match(line)
            if m:
                table[int(m.group(1))] = parse_lua_fields(m.group(2))
    return table


# --------------------------------------------------------------------------
# Description -> stats
# --------------------------------------------------------------------------

# Labels that are part of a stat, not a context switch.
INLINE_LABELS = {"DEF", "DMG", "Delay"}
LABEL_RE = re.compile(r"(?:(?<=^)|(?<=[\s|]))(\"[^\"|]+\"|[A-Z][A-Za-z0-9 ().'/&-]*?):(?=\s|\||$)")
# Flavor text ("This slip allows the customer to store...") is not a stat.
PROSE_RE = re.compile(r"^(this|a|an|the|it|you|when|if|used)\b")
STAT_RE = re.compile(
    r"(?<![A-Za-z.'\"])"
    r"(?P<name>\"[^\"|]+\"(?:\s[A-Za-z.'/&]+)*|[A-Z][A-Za-z.'/&]*(?:\s[A-Za-z.'\"/&()]+)*?)"
    r"\s?(?P<sign>[+-])\s?(?P<val>\d+)(?:～(?P<max>\d+))?(?P<pct>%?)"
)
INLINE_RE = re.compile(r"\b(DEF|DMG|Delay):(\d+)")
CONVERT_RE = re.compile(r"Converts (\d+) (HP|MP) to (HP|MP)")

ABBREVIATIONS = [
    (r"\bAcc\.", "Accuracy"), (r"\bAtk\.", "Attack"), (r"\bEva\.", "Evasion"),
    (r"\bMag\.", "Magic"), (r"\bPhys\.", "Physical"), (r"\bdmg\.", "damage"),
    (r"\bDmg\.", "Damage"), (r"\bDef\.", "Defense"),
]


def stat_key(name, pct):
    """Normalize a stat name so the same stat always gets the same key."""
    key = name.replace('"', "")
    for pattern, full in ABBREVIATIONS:
        key = re.sub(pattern, full, key)
    key = re.sub(r"\s+", " ", key).strip().lower()
    return key + ("%" if pct else "")


def split_contexts(text):
    """Cut a description into (context, text) chunks at each 'Label:'."""
    chunks, context, pos = [], "", 0
    for m in LABEL_RE.finditer(text):
        if m.group(1) in INLINE_LABELS:
            continue
        label = m.group(1).strip().strip('"')
        between = text[pos:m.start()]
        # "Enchantment: Consumes 1000 gil:" - a label right after another one
        # refines it instead of replacing it.
        if context and not between.strip(" |"):
            context, pos = f"{context}: {label}", m.end()
            continue
        chunks.append((context, between))
        context, pos = label, m.end()
    chunks.append((context, text[pos:]))
    return chunks


def parse_stats(description):
    """Return a list of stat rows parsed from an item description."""
    text = description.replace("\n", " | ")
    rows = []
    for context, chunk in split_contexts(text):
        for label, value in INLINE_RE.findall(chunk):
            rows.append((context, label.lower(), int(value), None, False))
        chunk = INLINE_RE.sub(" ", chunk)
        for amount, src, dst in CONVERT_RE.findall(chunk):
            rows.append((context, src.lower(), -int(amount), None, False))
            rows.append((context, dst.lower(), int(amount), None, False))
        chunk = CONVERT_RE.sub(" ", chunk)
        for m in STAT_RE.finditer(chunk):
            sign = -1 if m.group("sign") == "-" else 1
            value = sign * int(m.group("val"))
            vmax = sign * int(m.group("max")) if m.group("max") else None
            key = stat_key(m.group("name"), m.group("pct"))
            if PROSE_RE.match(key):
                continue
            rows.append((context, key, value, vmax, bool(m.group("pct"))))
    return rows


# --------------------------------------------------------------------------
# Bitmask decoding
# --------------------------------------------------------------------------

def decode_mask(mask, table, field):
    if not mask:
        return []
    return [table[i][field] for i in sorted(table) if mask & (1 << i) and i in table]


# --------------------------------------------------------------------------
# Build
# --------------------------------------------------------------------------

ITEM_COLUMNS = [
    "id", "name", "name_log", "category", "type", "level", "item_level", "superior_level",
    "jobs", "jobs_mask", "slots", "slots_mask", "skill", "damage", "delay", "shield_size",
    "stack", "flags", "races", "max_charges", "cast_time", "recast_delay", "description",
]


def build_items(res):
    items = load_resource(res / "items.lua")
    descs = load_resource(res / "item_descriptions.lua")
    jobs = load_resource(res / "jobs.lua")
    slots = load_resource(res / "slots.lua")
    skills = load_resource(res / "skills.lua")

    records = []
    for item_id in sorted(items):
        it = items[item_id]
        description = descs.get(item_id, {}).get("en", "")
        job_list = [j for j in decode_mask(it.get("jobs"), jobs, "ens") if j != "NON"]
        records.append({
            "id": item_id,
            "name": it.get("en"),
            "name_log": it.get("enl"),
            "category": it.get("category"),
            "type": it.get("type"),
            "level": it.get("level"),
            "item_level": it.get("item_level"),
            "superior_level": it.get("superior_level"),
            "jobs": "/".join(job_list) if len(job_list) < 22 else "All jobs",
            "jobs_mask": it.get("jobs"),
            "slots": "/".join(decode_mask(it.get("slots"), slots, "en")),
            "slots_mask": it.get("slots"),
            "skill": skills.get(it.get("skill"), {}).get("en") if it.get("skill") else None,
            "damage": it.get("damage"),
            "delay": it.get("delay"),
            "shield_size": it.get("shield_size"),
            "stack": it.get("stack"),
            "flags": it.get("flags"),
            "races": it.get("races"),
            "max_charges": it.get("max_charges"),
            "cast_time": it.get("cast_time"),
            "recast_delay": it.get("recast_delay"),
            "description": description,
            "stats": parse_stats(description),
        })
    return records


def write_sqlite(records, path):
    path.unlink(missing_ok=True)
    db = sqlite3.connect(path)
    db.execute(f"CREATE TABLE items ({', '.join(c + (' INTEGER PRIMARY KEY' if c == 'id' else '') for c in ITEM_COLUMNS)})")
    db.execute("""CREATE TABLE stats (
        item_id INTEGER REFERENCES items(id), context TEXT, stat TEXT,
        value INTEGER, value_max INTEGER, percent INTEGER)""")
    db.executemany(
        f"INSERT INTO items VALUES ({', '.join('?' * len(ITEM_COLUMNS))})",
        [tuple(r[c] for c in ITEM_COLUMNS) for r in records],
    )
    db.executemany(
        "INSERT INTO stats VALUES (?, ?, ?, ?, ?, ?)",
        [(r["id"], ctx, key, val, vmax, int(pct)) for r in records for ctx, key, val, vmax, pct in r["stats"]],
    )
    db.execute("CREATE INDEX stats_item ON stats(item_id)")
    db.execute("CREATE INDEX stats_stat ON stats(stat, context)")
    db.execute("CREATE INDEX items_name ON items(name COLLATE NOCASE)")
    db.commit()
    db.close()


def write_json(records, path):
    out = []
    for r in records:
        entry = {c: r[c] for c in ITEM_COLUMNS if r[c] is not None}
        grouped = {}
        for ctx, key, val, vmax, _ in r["stats"]:
            grouped.setdefault(ctx or "base", {})[key] = [val, vmax] if vmax is not None else val
        entry["stats"] = grouped
        out.append(entry)
    path.write_text(json.dumps(out, ensure_ascii=False, indent=1), encoding="utf-8")


def write_equipment_csv(records, path, min_items=5):
    """Wide CSV for armor/weapons: frequent base stats get their own column."""
    gear = [r for r in records if r["category"] in ("Armor", "Weapon")]
    freq = Counter(key for r in gear for ctx, key, *_ in r["stats"] if ctx == "")
    stat_cols = [k for k, n in freq.most_common() if n >= min_items]
    base_cols = ["id", "name", "category", "slots", "jobs", "level", "item_level", "skill", "damage", "delay"]
    with open(path, "w", newline="", encoding="utf-8-sig") as fh:
        w = csv.writer(fh)
        w.writerow(base_cols + stat_cols + ["other_stats", "description"])
        for r in gear:
            base = {}
            other = []
            for ctx, key, val, vmax, _ in r["stats"]:
                shown = f"{val}~{vmax}" if vmax is not None else val
                if ctx == "" and key in stat_cols:
                    base[key] = base.get(key, 0) + val if vmax is None else shown
                else:
                    other.append(f"{ctx + ': ' if ctx else ''}{key} {shown}")
            w.writerow([r[c] for c in base_cols] + [base.get(k, "") for k in stat_cols]
                       + ["; ".join(other), r["description"].replace("\n", " | ")])
    return len(gear), len(stat_cols)


HP_MP_LUA = Path(__file__).resolve().parents[2] / "shared" / "data" / "equipment" / "ITEM_HP_MP.lua"


def hp_mp_entry(record):
    """(hp, mp, unity_hp_min, unity_hp_max, unity_mp_min, unity_mp_max) or None."""
    base = {"hp": 0, "mp": 0}
    unity = {"hp": [0, 0], "mp": [0, 0]}
    for ctx, key, val, vmax, pct in record["stats"]:
        if pct or key not in base:
            continue
        if ctx == "":
            base[key] += val
        elif ctx == "Unity Ranking":
            unity[key] = [val, vmax if vmax is not None else val]
    values = (base["hp"], base["mp"], *unity["hp"], *unity["mp"])
    return values if any(values) else None


def write_hp_mp_lua(records, path):
    """Lua lookup {name_lower = {hp, mp[, uhp_min, uhp_max, ump_min, ump_max]}}.

    Read by shared/utils/equipment/hp_priority.lua at job load. Only
    equipment giving HP or MP is listed; a name missing from it gives none.
    Several items can share a name (weapon stages, NQ/HQ log names): the
    highest level one wins, being the one a level 99 set means.
    """
    chosen = {}
    for r in records:
        if not r["slots_mask"] or r["category"] not in ("Armor", "Weapon"):
            continue
        entry = hp_mp_entry(r)
        rank = (r["item_level"] or 0, r["level"] or 0, r["id"])
        for name in {n.lower() for n in (r["name"], r["name_log"]) if n}:
            if name not in chosen or rank > chosen[name][0]:
                chosen[name] = (rank, entry)
    lines = [
        "-- GENERATED by scripts/item_db/build_item_db.py - do not edit by hand.",
        "-- HP / MP of every equipment piece, from Windower res (game data).",
        "-- {hp, mp} or {hp, mp, unity_hp_min, unity_hp_max, unity_mp_min, unity_mp_max}",
        "return {",
    ]
    count = 0
    for name in sorted(chosen):
        entry = chosen[name][1]
        if entry is None:
            continue
        values = entry if any(entry[2:]) else entry[:2]
        key = name.replace("\\", "\\\\").replace('"', '\\"')
        lines.append(f'["{key}"]={{{",".join(str(v) for v in values)}}},')
        count += 1
    lines.append("}")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")
    return count


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("--res", type=Path, default=DEFAULT_RES.resolve(),
                        help="Windower res/ folder (default: %(default)s)")
    args = parser.parse_args()

    records = build_items(args.res)
    OUT_DIR.mkdir(exist_ok=True)
    write_sqlite(records, OUT_DIR / "items.sqlite")
    write_json(records, OUT_DIR / "items.json")
    n_gear, n_cols = write_equipment_csv(records, OUT_DIR / "equipment.csv")

    n_stats = sum(len(r["stats"]) for r in records)
    print(f"{len(records)} items, {n_stats} stat rows -> {OUT_DIR}")
    print(f"equipment.csv: {n_gear} armor/weapons, {n_cols} stat columns")
    n_hp = write_hp_mp_lua(records, HP_MP_LUA)
    print(f"{HP_MP_LUA.name}: {n_hp} names with HP/MP -> {HP_MP_LUA.parent}")


if __name__ == "__main__":
    main()
