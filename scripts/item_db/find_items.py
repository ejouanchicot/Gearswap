"""
Query the item database built by build_item_db.py.

Examples:
    python find_items.py "Boii Mask +3"                 # show one item (name or id)
    python find_items.py --stat hp --slot Head --job WAR --top 10
    python find_items.py --stat "double attack%" --slot Ear --top 15
    python find_items.py --stat "store tp" --job SAM --level 99

--stat ranks items by one base stat (unconditional stats only; Pet/Set/
Unity/... bonuses are listed with the item but never counted).

@file    scripts/item_db/find_items.py
@author  Tetsouo
@version 1.0
@date    Created: 2026-09-23
"""

import argparse
import sqlite3
import sys
from pathlib import Path

# The Windows console defaults to cp1252, which cannot print the full-width
# tilde of Unity ranges (HP+10～35).
sys.stdout.reconfigure(encoding="utf-8", errors="replace")

DB_PATH = Path(__file__).resolve().parent / "out" / "items.sqlite"


def show_item(db, needle):
    if needle.isdigit():
        rows = db.execute("SELECT id, name, category, slots, jobs, level, item_level, description "
                          "FROM items WHERE id = ?", (int(needle),)).fetchall()
    else:
        rows = db.execute("SELECT id, name, category, slots, jobs, level, item_level, description "
                          "FROM items WHERE name = ? COLLATE NOCASE OR name_log = ? COLLATE NOCASE",
                          (needle, needle)).fetchall()
    if not rows:
        rows = db.execute("SELECT id, name, category, slots, jobs, level, item_level, description "
                          "FROM items WHERE name LIKE ? LIMIT 20", (f"%{needle}%",)).fetchall()
    for iid, name, cat, slots, jobs, lvl, ilvl, desc in rows:
        print(f"\n{name}  [id {iid}]  {cat} | {slots or '-'} | Lv{lvl}{f' / iLv{ilvl}' if ilvl else ''} | {jobs or '-'}")
        for ctx, stat, v, vmax in db.execute(
                "SELECT context, stat, value, value_max FROM stats WHERE item_id = ?", (iid,)):
            print(f"   {(ctx or 'base'):<14} {stat:<32} {v}{f'~{vmax}' if vmax is not None else ''}")
        print("   " + desc.replace("\n", "\n   "))
    if not rows:
        print(f"No item matching '{needle}'")


def rank_by_stat(db, stat, slot, job, level, top):
    sql = ["SELECT i.id, i.name, i.slots, i.level, i.item_level, SUM(s.value) AS total",
           "FROM stats s JOIN items i ON i.id = s.item_id",
           "WHERE s.context = '' AND s.stat = ?"]
    params = [stat.lower()]
    if slot:
        sql.append("AND i.slots LIKE ?")
        params.append(f"%{slot}%")
    if job:
        sql.append("AND (i.jobs LIKE ? OR i.jobs = 'All jobs')")
        params.append(f"%{job.upper()}%")
    if level:
        sql.append("AND i.level <= ?")
        params.append(level)
    sql.append("GROUP BY i.id ORDER BY total DESC, i.item_level DESC LIMIT ?")
    params.append(top)
    for iid, name, slots, lvl, ilvl, total in db.execute(" ".join(sql), params):
        print(f"{total:>6}  {name:<28} {slots:<22} Lv{lvl}{f'/iLv{ilvl}' if ilvl else '':<9} id {iid}")


def main():
    parser = argparse.ArgumentParser(description="Search the FFXI item database.")
    parser.add_argument("item", nargs="?", help="item name or id to display")
    parser.add_argument("--stat", help="rank items by this base stat (e.g. hp, 'store tp', 'haste%%')")
    parser.add_argument("--slot", help="filter by slot (Head, Body, Ear, Ring, Back, ...)")
    parser.add_argument("--job", help="filter by job (WAR, PLD, ...)")
    parser.add_argument("--level", type=int, help="maximum equip level")
    parser.add_argument("--top", type=int, default=20, help="number of results (default 20)")
    args = parser.parse_args()

    if not DB_PATH.exists():
        raise SystemExit(f"{DB_PATH} not found - run build_item_db.py first")
    db = sqlite3.connect(DB_PATH)
    if args.stat:
        rank_by_stat(db, args.stat, args.slot, args.job, args.level, args.top)
    elif args.item:
        show_item(db, args.item)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
