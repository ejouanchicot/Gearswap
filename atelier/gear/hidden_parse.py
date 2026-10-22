"""
Reads the cached BG Wiki pages (catalog/cache_bgwiki/<id>.json, from hidden_fetch.py) and
proposes the hidden value of each effect the game names without a number.

For each catalogue item with a text_only effect (or a multi-attack proc), every sentence of
its page outside the game description ({{item |description=...}}) that names the effect and
carries a number is a candidate. Output: catalog/cache_bgwiki/_candidates.json, read by hand
(hidden_review) before the values go to hidden_values.json.

Usage: python atelier-engine/catalog/hidden_parse.py [--show]

@author ejouanchicot
"""
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, "cache_bgwiki")

# text_only phrase -> (catalogue key, words the wiki uses for it)
EFFECTS = [
    (r'"Refresh"', "Refresh", r"refresh"),
    (r'Fast Cast', "Fast Cast", r"fast ?cast"),
    (r'"Regen"', "Regen", r"regen"),
    (r'critical hit damage', "Crit Damage", r"crit(?:ical)?(?: hit)? damage|critical hit dmg"),
    (r'critical hit rate', "Crit Rate", r"crit(?:ical)?(?: hit)? rate"),
    (r'Snapshot', "Snapshot", r"snapshot"),
    (r'Zanshin', "Zanshin", r"zanshin"),
    (r'Dual Wield', "Dual Wield", r"dual wield"),
    (r'song effect', "All Songs", r"song|all songs"),
    (r'Quick Draw', "Quick Draw Damage%", r"quick draw"),
    (r'Martial Arts', "Martial Arts", r"martial arts"),
    (r'magic burst', "Magic Burst Damage", r"magic burst|burst"),
    (r'"Counter"', "Counter", r"counter"),
    (r'Sneak Attack', "Sneak Attack Bonus", r"sneak attack"),
    (r'Trick Attack', "Trick Attack Bonus", r"trick attack"),
    (r'Skillchain', "Skillchain Bonus", r"skillchain"),
    (r'Recycle', "Recycle", r"recycle"),
    (r'Double Shot', "Double Shot", r"double shot"),
    (r'Triple Shot', "Triple Shot", r"triple shot"),
    (r'"Double Attack"', "DA", r"double attack"),
    (r'"Triple Attack"', "TA", r"triple attack"),
    (r'Occult', "Occult Acumen", r"occult acumen"),
    (r'Barrage', "Barrage", r"barrage"),
    (r'Hasso', "Hasso+ JA Haste", r"hasso|haste"),
    (r'Klimaform', "Klimaform Damage%", r"klimaform"),
    (r'Futae', "Futae Bonus", r"futae"),
    (r'Ebullience', "Ebullience Bonus", r"ebullience"),
    (r'Rapture', "Rapture Bonus", r"rapture"),
    (r'Conserve MP', "Conserve MP", r"conserve mp"),
    (r'Conserve TP', "Conserve TP", r"conserve tp"),
    (r'Store TP', "Store TP", r"store tp"),
    (r'Subtle Blow', "Subtle Blow", r"subtle blow"),
    (r'Kick', "Kick Attacks", r"kick"),
    (r'Treasure', "Treasure Hunter", r"treasure hunter"),
    (r'Cure', "Cure Potency", r"cure"),
    (r'Climactic Flourish', "Climactic Crit Damage", r"climactic|critical"),
    (r'Striking Flourish', "Striking Crit Rate", r"striking|critical"),
    (r'Unlimited Shot', "Unlimited Shot", r"unlimited shot"),
    (r'Velocity Shot', "Velocity Shot", r"velocity"),
    (r'Sharpshot', "Sharpshot", r"sharpshot"),
    (r'Saboteur', "Saboteur", r"saboteur"),
    (r'magic effect', "Magic effect", r"magic|potency|damage"),
]
MULTI = re.compile(r"^(Occasionally|Occ\.) (attacks|deals)", re.I)
NUM = re.compile(r"[+-]?\d+(?:\.\d+)?\s?%?")


def notes_of(wikitext):
    """The page text a reader wrote: everything but the game's own description line and
    the item/armor/weapon/synth/NPC templates' fields."""
    w = re.sub(r"\|description=[^\n]*", "", wikitext)
    # references and links carry numbers of their own (thread and post ids)
    w = re.sub(r"<ref[^>]*>.*?</ref>|<ref[^>]*/>", "", w, flags=re.S)
    w = re.sub(r"\[https?://[^\]]*\]|https?://\S+", "", w)
    w = re.sub(r"<br\s*/?>", "\n", w)
    w = re.sub(r"\[\[(?:[^|\]]*\|)?([^\]]*)\]\]", r"\1", w)
    w = re.sub(r"'''?|<[^>]+>", "", w)
    out = []
    for line in w.split("\n"):
        line = line.strip(" *:#")
        if not line or line.startswith(("|", "{{", "}}", "[[Category")) or "=" in line[:25] and line.startswith("|"):
            continue
        out.extend(s.strip() for s in re.split(r"(?<=[.;])\s+(?=[A-Z])", line) if s.strip())
    return out


def candidates_of(item, rec):
    notes = notes_of(rec["wikitext"])
    out = []
    phrases = list(item.get("text_only", []))
    phrases += [c for c in item.get("cond", []) if MULTI.match(c)]
    for ph in phrases:
        if MULTI.match(ph):
            key, words = "OA", r"attack|activation|proc|rate|times"
        else:
            hit = next(((k, w) for p, k, w in EFFECTS if re.search(p, ph, re.I)), None)
            if not hit:
                continue
            key, words = hit
        found = [n for n in notes if re.search(words, n, re.I) and NUM.search(n)]
        out.append({"phrase": ph, "key": key, "notes": found})
    return out


def main():
    with open(os.path.join(HERE, "items.json"), encoding="utf-8") as f:
        items = {e["id"]: e for e in json.load(f)["items"]}
    res = []
    for fn in sorted(os.listdir(CACHE)):
        if not fn[0].isdigit():
            continue
        with open(os.path.join(CACHE, fn), encoding="utf-8") as f:
            rec = json.load(f)
        item = items.get(rec["id"])
        if not item:
            continue
        c = candidates_of(item, rec) if rec["wikitext"] else []
        res.append({"id": rec["id"], "name": item["name"], "level": item["level"],
                    "ilvl": item["ilvl"], "url": rec["url"], "title": rec["title"],
                    "cands": c})
    with open(os.path.join(CACHE, "_candidates.json"), "w", encoding="utf-8") as f:
        json.dump(res, f, ensure_ascii=False, indent=1)
    if "--show" in sys.argv:
        for r in res:
            for c in r["cands"]:
                print(f"{r['id']} {r['name']} [{r['level']}/{r['ilvl']}] {c['key']} <- {c['phrase']}")
                for n in c["notes"][:4]:
                    print("      ", n[:220])


if __name__ == "__main__":
    main()
