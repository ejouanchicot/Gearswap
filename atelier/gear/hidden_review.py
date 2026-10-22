"""
Turns the BG Wiki candidates (cache_bgwiki/_candidates.json, hidden_parse.py) into
catalog/hidden_values.json, read by build_catalog.py.

A value is taken automatically when a note names the effect next to a number ("Fast Cast
+5%", "+9% Snapshot", "Regen +2 HP/tick", "2MP/tick"); notes about durations, recasts or
job abilities are skipped. REVIEW below holds what was read by hand: a value for a page
whose wording the rule does not read, a correction, or None to drop a wrong automatic one.
ELSEWHERE: values the item's own page does not give but another BG Wiki page or table does,
each with its page and why (2026-10-22: these replace the values once taken from wsdist's gear.py).

Usage: python atelier-engine/catalog/hidden_review.py [--show]

@author ejouanchicot
"""
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, "cache_bgwiki")

SKIP = re.compile(r"duration|second|recast|minute|\btic(?:k|ks)? ?(?:interval|rate)|"
                  r"job ability|stack|cap(?:ped)?\b|level \d|\bilvl|\bi\.?lv", re.I)
# Words around the number per key
WORDS = {
    "Refresh": r"refresh", "Fast Cast": r"fast ?cast", "Regen": r"regen",
    "Crit Damage": r"crit(?:ical)?(?: hit)? (?:damage|dmg)", "Crit Rate": r"crit(?:ical)?(?: hit)? rate",
    "Snapshot": r"snapshot", "Zanshin": r"zanshin", "Dual Wield": r"dual wield",
    "Martial Arts": r"martial arts", "Magic Burst Damage": r"magic burst (?:damage|bonus)|burst damage",
    "Counter": r"counter", "Sneak Attack Bonus": r"sneak attack", "Trick Attack Bonus": r"trick attack",
    "Skillchain Bonus": r"skillchain", "Recycle": r"recycle", "Double Shot": r"double shot",
    "Triple Shot": r"triple shot", "DA": r"double attack", "TA": r"triple attack",
    "Occult Acumen": r"occult acumen", "Conserve MP": r"conserve mp", "Conserve TP": r"conserve tp",
    "Store TP": r"store tp", "Subtle Blow": r"subtle blow", "Kick Attacks": r"kick attack",
    "Treasure Hunter": r"treasure hunter", "Cure Potency": r"cure potency",
    "OA": r"activation rate|proc rate|attacks twice|occasionally attacks",
}
NUM_AFTER = re.compile(r"^[^0-9\n]{0,18}?([+-]?\d+(?:\.\d+)?)\s?(%|\s?(?:hp|mp)\s?/\s?tic)?", re.I)
NUM_BEFORE = re.compile(r"([+-]?\d+(?:\.\d+)?)\s?(%?)\s{0,2}(?:\"|')?\s?$")

# Read by hand: {item id: {key: value}} (None drops the automatic value of that key)
REVIEW = {
    # wording the rule does not read
    15962: {"Magic Burst Damage": 5},           # Static Earring: "Bonus to magic burst is 5%"
    12513: {"Fast Cast": 10},                   # Warlock's Chapeau: "Fast Cast is +10%, recast..."
    10667: {"Regen": 2},                        # Pantin Taj +2: "Regen and Refresh ... 2/tick"
    27788: {"Regen": 2, "Refresh": 2},          # Ares' Cuirass +1: "2/tick regen and refresh"
    27820: {"Regen": 2},                        # Vishap Mail: "likely 2 a tic" (verification)
    27922: {"Refresh": 2},                      # Orvail Robe: "2 MP/tick Refresh"
    14416: {"Regen": 2}, 14417: {"Regen": 2},   # Barone/Conte Corazza: "2 HP every 3 seconds"
    12649: {"Regen": 1},                        # Drachen Mail: "1 HP every 3 seconds"
    14089: {"DA": 1},                           # Fighter's Calligae: "approximately 1%"
    11116: {"Futae Bonus": 20}, 11216: {"Futae Bonus": 10},           # Iga Tekko +2/+1
    11083: {"Ebullience Bonus": 10, "Rapture Bonus": 10},             # Svnt. Bonnet +2: 20->30, 50->60
    11183: {"Ebullience Bonus": 5, "Rapture Bonus": 5},               # Svnt. Bonnet +1
    11163: {"Klimaform Damage%": 10}, 11263: {"Klimaform Damage%": 5},  # Svnt. Loafers +2/+1
    11151: {"Occult Acumen": 25}, 11251: {"Occult Acumen": 15},       # Bale Sollerets +2/+1
    11135: {"Hasso+ JA Haste": 2.5}, 11235: {"Hasso+ JA Haste": 1.5},  # Unkai Haidate +2/+1
    27954: {"Hasso+ JA Haste": 1},              # Wakido Kote
    14900: {"Barrage": 1}, 27953: {"Barrage": 2}, 17273: {"Barrage": 1},  # extra shots
    # "Increases song effect": the pages give the song duration
    20629: {"Song Duration": 5}, 11093: {"Song Duration": 10}, 11193: {"Song Duration": 5},
    11618: {"Song Duration": 10}, 28074: {"Song Duration": 10}, 28232: {"Song Duration": 10},
    # "Increases enhancing magic effect": the pages give the duration
    11148: {"Enhancing Magic Duration": 20}, 11248: {"Enhancing Magic Duration": 10},
    16204: {"Enhancing Magic Duration": 10}, 27947: {"Enhancing Magic Duration": 15},
    # "Enhances the base damage of Quick Draw by 10": a flat Quick Draw Damage
    11467: {"Quick Draw Damage": 10}, 15266: {"Quick Draw Damage": 10},
    27679: {"Quick Draw Damage": 10}, 28239: {"Quick Draw Damage": 10},
    # Relic/Mythic/Empyrean ilvl 119 stage pages ("Kenkonken (Level 119 III)")
    20480: {"Counter": 14}, 20481: {"Counter": 14}, 20509: {"Counter": 14},       # Spharai
    20484: {"Martial Arts": 55}, 20485: {"Martial Arts": 55}, 20511: {"Martial Arts": 55},
    20561: {"Song Duration": 50}, 20562: {"Song Duration": 50},                   # Carnwenhan
    **{i: {"Snapshot": 10, "Barrage Ranged Accuracy": 70}
       for i in (21246, 21247, 21266, 22139)},                                    # Gastraphetes
    **{i: {"Quick Draw Damage%": 60, "Quick Draw Magic Accuracy": 60}
       for i in (21262, 21263, 21268, 22141)},                                    # Death Penalty
    20745: {"Crit Rate": 14}, 20746: {"Crit Rate": 14}, 21683: {"Crit Rate": 14},  # Ragnarok
    # effects the description does not name at all
    27510: {"ftp": 0.09765625}, 28420: {"ftp": 0.09765625},   # Fotia: +25/256 fTP
    26359: {"Elemental Bonus": 15},             # Orpheus's Sash: 1~15 by distance, best case
    26172: {"Crit Rate": 5, "DT": 10},          # Begrudging Ring: at full Tonberry hate
    19141: {"Crit Damage": 10},                 # Oneiros Knife: "10% damage boost to critical hits"
    19256: {"Crit Damage": 5},                  # Charis Feather: "Bonus +5%"
    22031: {"Magic Burst Damage": 4},           # Maxentius: 4% per skillchain step (one step)
    # doubtful or wrong automatic values
    19302: {"Dual Wield": 3},                   # Uguisu: "<5% (~3%, verification)"
    18447: {"Zanshin": None},                   # Nanatsusaya: "+100%" flagged for verification
    28092: {"Regen": None}, 11106: {"Regen": None}, 11206: {"Regen": None},  # Regen duration
}
# Values the item's page has no number for, read on another BG Wiki page: {item id: (stats, page, note)}.
# Left out on purpose (2026-10-22), their effect is not a stat of the piece: Mandau, Bravura and Ragnarok
# (a first swing that deals two to three times the damage, a weaponskill's damage: atelier/calc/calc_round_damage.js
# CALC.RELIC_WEAPON, calc_ws_details.js), Lycurgos (TP Bonus from the HP worn: calc_page.js), Yoichinoyumi (its first
# shot: ranged rounds are not computed yet, notes/docs-perso/moteur-sans-wsdist-2026-10-22/SPEC.md Lot 4).
WIKI_PAGE = "https://www.bg-wiki.com/ffxi/"
ELSEWHERE = {
    # "Count / Swings / Distribution %": 548 / 1 / 2.08 %, 2806 / 2 / 10.66 %, 5998 / 3 / 22.78 %, 7488 / 4 /
    # 28.44 %, 5623 / 5 / 21.36 %, 2852 / 6 / 10.83 %, 835 / 7 / 3.17 %, 177 / 8 / 0.67 %, 26,327 in all; "This
    # data was collected from the action packet, tracking the action count."
    17440: ({"OA2": 10.66, "OA3": 22.78, "OA4": 28.44, "OA5": 21.36, "OA6": 10.83, "OA7": 3.17, "OA8": 0.67},
            WIKI_PAGE + "Kraken_Club", "BG Wiki's count of 26,327 rounds (action packet), not measured by us"),
    # its page gives no rate; Joyeuse's, the same "Occasionally attacks twice": "Occasionally attacks twice effect
    # has an activation rate of 45%." ASSUMED the same rate, to measure in game
    20602: ({"OA2": 45}, WIKI_PAGE + "Joyeuse", "Joyeuse's rate (the same effect), ASSUMED for this knife"),
    # "a Magic Burst Damage II bonus that varies between a maximum of +30 and a minimum of +1 depending on when a
    # spell lands during the Magic Burst window": the maximum, the player's choice (2026-10-22), the page says when
    22042: ({"Magic Burst Damage II": 30}, WIKI_PAGE + "Wizard%27s_Rod", "the maximum of +1~+30, by timing"),
    21991: ({"Magic Burst Damage II": 30}, WIKI_PAGE + "Wizard%27s_Rod", "the maximum of +1~+30, by timing"),
}


def auto_value(key, notes):
    """(value, note) from the first note naming the key next to a number, else None."""
    words = WORDS.get(key)
    if not words:
        return None
    for n in notes:
        if SKIP.search(n):
            continue
        for m in re.finditer(words, n, re.I):
            a = NUM_AFTER.match(n[m.end():])
            if a:
                return float(a.group(1)), n
            b = NUM_BEFORE.search(n[:m.start()])
            if b:
                return float(b.group(1)), n
    return None


def main():
    with open(os.path.join(CACHE, "_candidates.json"), encoding="utf-8") as f:
        cands = json.load(f)
    out, rows = {}, []
    for r in cands:
        stats, notes = {}, {}
        for c in r["cands"]:
            key = c["key"]
            got = auto_value(key, c["notes"])
            if got:
                v, note = got
                if key == "OA":
                    key = "OA3" if "thrice" in c["phrase"] else "OA2"
                if key in ("Martial Arts", "Snapshot"):
                    v = abs(v)          # given as "Delay -10" / "-3% ranged aiming delay"
                if key in ("Double Shot", "Triple Shot") and re.search(r"damage", note, re.I):
                    key += " Damage%"
                if v > 60:
                    continue            # a page number, not a stat (checked by hand)
                stats[key] = int(v) if v == int(v) else v
                notes[key] = note
        for k, v in REVIEW.get(r["id"], {}).items():
            if v is None:
                stats.pop(k, None)
            else:
                stats[k] = v
                notes[k] = "read by hand"
        src = r["url"]
        if r["id"] in ELSEWHERE:
            values, page, note = ELSEWHERE[r["id"]]
            if not stats:
                src = page
            for k, v in values.items():
                stats.setdefault(k, v)
                notes.setdefault(k, note + " (" + page + ")")
        if stats:
            out[str(r["id"])] = {"name": r["name"], "stats": stats, "source": src, "notes": notes}
        rows.append((r, stats))
    with open(os.path.join(HERE, "hidden_values.json"), "w", encoding="utf-8") as f:
        json.dump({"source": "BG Wiki (bg-wiki.com) item pages, notes section; see hidden_review.py",
                   "count": len(out), "items": out}, f, ensure_ascii=False, indent=1)
    print(f"{len(out)} items with a hidden value, {len(cands)} pages read")
    if "--show" in sys.argv:
        for r, stats in rows:
            for c in r["cands"]:
                got = {k: v for k, v in stats.items() if k.startswith(c["key"][:2])} or "-"
                print(f"{r['id']} {r['name']} [{r['level']}/{r['ilvl']}] {c['key']}: "
                      f"{got} <- {c['phrase']}")
                for n in c["notes"][:3]:
                    print("      ", n[:200])


if __name__ == "__main__":
    main()
