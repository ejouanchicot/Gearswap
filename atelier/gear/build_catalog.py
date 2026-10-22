"""
Base item catalogue for the Atelier gear optimizer.

Reads the Windower resources (res/items.lua + res/item_descriptions.lua), keeps every
equippable item (weapons and armor with a slot) and turns the game client's text into
stat dicts keyed in the catalogue's vocabulary (STAT_KEYS.md: the names the engine before, a port of
wsdist, reads, so both engines read the same entries; names only, no value of wsdist's).

Output: catalog/items.json and catalog/items.js (the same data as an engine part).
Usage:  python atelier-engine/catalog/build_catalog.py [--res D:/Windower Tetsouo/res]

The text rules start from atelier.html (STAT_ALIAS, parseLine, statOf, unsigned, COND),
ported to Python and extended. The vocabulary is documented in catalog/STAT_KEYS.md.

@author ejouanchicot
"""
import json
import os
import re
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
DEFAULT_RES = r"D:\Windower Tetsouo\res"

# ---------------------------------------------------------------------------
# Resource fields
# ---------------------------------------------------------------------------
JOBS = ["war", "mnk", "whm", "blm", "rdm", "thf", "pld", "drk", "bst", "brd", "rng",
        "sam", "nin", "drg", "smn", "blu", "cor", "pup", "dnc", "sch", "geo", "run"]
# slots bitmask bit -> wsdist slot name(s); earring/ring bits exist per hand but an
# item equippable in one is equippable in both
SLOT_BITS = [(0, "main"), (1, "sub"), (2, "ranged"), (3, "ammo"), (4, "head"), (5, "body"),
             (6, "hands"), (7, "legs"), (8, "feet"), (9, "neck"), (10, "waist"),
             (11, "ear1"), (12, "ear2"), (13, "ring1"), (14, "ring2"), (15, "back")]
SKILLS = {1: "Hand-to-Hand", 2: "Dagger", 3: "Sword", 4: "Great Sword", 5: "Axe",
          6: "Great Axe", 7: "Scythe", 8: "Polearm", 9: "Katana", 10: "Great Katana",
          11: "Club", 12: "Staff", 25: "Archery", 26: "Marksmanship", 27: "Throwing",
          41: "String Instrument", 42: "Wind Instrument", 45: "Handbell", 48: "Fishing"}
MELEE_SKILLS = set(range(1, 13))
ARMOR_TYPE = {"head": "Head", "neck": "Neck", "ear1": "Earring", "body": "Body",
              "hands": "Hands", "ring1": "Ring", "back": "Back", "waist": "Waist",
              "legs": "Legs", "feet": "Feet"}


def dump_lua(res_dir, name, cache_dir):
    """Turns a Windower resource file into JSON with lua5.1 (dump_lua.lua)."""
    out = os.path.join(cache_dir, f"_raw_{name}.json")
    src = os.path.join(res_dir, f"{name}.lua")
    if not os.path.exists(out) or os.path.getmtime(out) < os.path.getmtime(src):
        lua = shutil.which("lua5.1") or shutil.which("lua5.1.exe") or shutil.which("lua")
        subprocess.run([lua, os.path.join(HERE, "dump_lua.lua"), src, out], check=True)
    with open(out, encoding="utf-8") as f:
        return json.load(f)


def jobs_of(mask):
    return [j for i, j in enumerate(JOBS, start=1) if mask & (1 << i)]


def slots_of(mask):
    out = [name for bit, name in SLOT_BITS if mask & (1 << bit)]
    for a, b in (("ear1", "ear2"), ("ring1", "ring2")):
        if (a in out) != (b in out):
            out = [s for s in out if s not in (a, b)] + [a, b]
    return out


def type_of(item, slots):
    """wsdist's "Type": Weapon/Shield/Grip, Bow/Gun/Crossbow/Instrument for ranged,
    Bullet/Arrow/Bolt/Shuriken/Throwing/Equipment for ammo; armor gets its slot."""
    skill = item.get("skill", 0)
    if item.get("shield_size"):
        return "Shield"
    if "main" in slots or ("sub" in slots and skill in MELEE_SKILLS):
        return "Weapon" if skill in MELEE_SKILLS else ("Grip" if "main" not in slots else "Weapon")
    if "sub" in slots and item.get("category") == "Weapon":
        return "Grip"
    if "ranged" in slots:
        rt = item.get("range_type")
        if rt in ("Bow", "Gun", "Crossbow"):
            return rt
        if rt == "Cannon":
            return "Gun"
        if skill in (41, 42, 45):
            return "Instrument"
        if skill == 27:
            return "Throwing"
        return rt or ("Animator" if not skill else "Ranged")
    if "ammo" in slots:
        at = item.get("ammo_type")
        if at in ("Bullet", "Arrow", "Bolt"):
            return at
        if at == "Shell":
            return "Bullet"
        if at:
            return at
        if skill == 27:
            return "Shuriken" if "shuriken" in item["en"].lower() else "Throwing"
        return "Equipment"
    for s in slots:
        if s in ARMOR_TYPE:
            return ARMOR_TYPE[s]
    return "Equipment"




# ---------------------------------------------------------------------------
# Stat vocabulary: normalised phrase -> catalogue key(s)
# ---------------------------------------------------------------------------
def norm(s):
    s = s.lower()
    s = re.sub(r'["“”]', "", s)
    s = re.sub(r"\.\s*", ".", s)
    s = re.sub(r"\s+", " ", s)
    return s.strip(" /:,")


ALIAS = {}


def alias(key, *phrases):
    """key: one catalogue key, or a tuple when one phrase raises several stats.
    A key starting with "-" is counted negated ("Slow"+5% is Gear Haste -5)."""
    keys = key if isinstance(key, tuple) else (key,)
    for p in phrases:
        ALIAS[norm(p)] = keys


ATTRS = ["STR", "DEX", "VIT", "AGI", "INT", "MND", "CHR"]
COMBAT_SKILLS = ["Hand-to-Hand Skill", "Dagger Skill", "Sword Skill", "Great Sword Skill",
                 "Axe Skill", "Great Axe Skill", "Scythe Skill", "Polearm Skill", "Katana Skill",
                 "Great Katana Skill", "Club Skill", "Staff Skill", "Archery Skill",
                 "Marksmanship Skill", "Throwing Skill"]

# --- wsdist keys ---
for a in ATTRS:
    alias(a, a)
alias("Accuracy", "accuracy", "acc.", "acc")
alias("Attack", "attack", "atk.", "atk")
alias("Ranged Accuracy", "ranged accuracy", "rng.acc.", "rng.acc", "ranged acc.", "r.acc.")
alias("Ranged Attack", "ranged attack", "rng.atk.", "rng.atk", "ranged atk.", "r.atk.")
alias("Evasion", "evasion", "eva.")
alias("Magic Evasion", "magic evasion", "mag.eva.", "mag.evasion", "magic eva.")
alias("Magic Defense", "magic def.bonus", "m.def.b.", "mag.def.bns.", "magic defense bonus",
      "magic def.bns.", "mag.def.bonus", "magic defense")
alias("Magic Accuracy", "magic accuracy", "mag.acc.", "mag.acc", "magic acc.", "m.acc.")
alias("Magic Attack", "magic atk.bonus", "mag.atk.bns.", "mag.atk.bns", "m.atk.b.", "magic atk.",
      "magic attack bonus", "magic attack")
alias("Magic Damage", "magic damage", "mag.dmg.", "magic dmg.")
alias("DT", "damage taken", "dt", "dmg.taken")
alias("PDT", "physical damage taken", "phys.dmg.taken", "physical dmg.taken", "phys.damage taken",
      "pdt")
alias("MDT", "magic damage taken", "mag.dmg.taken", "magic dmg.taken", "mdt")
alias("PDT2", "physical damage taken ii", "phys.dmg.taken ii", "physical dmg.taken ii")
alias("MDT2", "magic damage taken ii", "mag.dmg.taken ii", "magic dmg.taken ii")
alias("Gear Haste", "haste")
alias("-Gear Haste", "slow")
alias("DA", "double attack", "dbl.atk.", "dbl.atk")
alias("TA", "triple attack", "trip.atk.", "trpl.atk.")
alias("QA", "quadruple attack", "quad attack", "quad.atk.")
alias("DA Damage%", "double attack damage")
alias("TA Damage%", "triple attack damage")
alias("Store TP", "store tp")
alias("Crit Rate", "critical hit rate", "crit.hit rate", "crit.rate")
alias("Crit Damage", "critical hit damage", "crit.hit damage", "crit.hit dmg.", "crit.dmg.")
alias("Weapon Skill Damage", "weapon skill damage", "weapon skill dmg.", "ws damage")
alias("Weapon Skill Accuracy", "weapon skill accuracy", "weapon skill acc.")
alias("TP Bonus", "tp bonus")
alias("Dual Wield", "dual wield")
alias("Subtle Blow", "subtle blow")
alias("Subtle Blow II", "subtle blow ii")
alias("Skillchain Bonus", "skillchain bonus", "skillchain damage")
alias("PDL", "physical damage limit")
alias("Regain", "regain")
alias("Magic Burst Damage", "magic burst damage", "magic burst dmg.", "mag.burst dmg.")
alias("Magic Burst Damage II", "magic burst damage ii", "magic burst dmg.ii")
alias("Magic Burst Accuracy", "magic burst accuracy", "magic burst acc.")
alias("Magic Crit Rate II", "magic critical hit rate ii", "magic crit.hit rate ii")
alias("Martial Arts", "martial arts")
alias("Kick Attacks", "kick attacks")
# wsdist files "Kicks" Attack (Anchorite's Gaiters) under its kick damage key
alias("Kick Attacks DMG", "kick attacks damage", "kick attacks dmg.", "kicks attack",
      "kick attacks attack")
alias("Zanshin", "zanshin")
alias("Daken", "daken")
alias("Recycle", "recycle")
alias("True Shot", "true shot")
alias("Double Shot", "double shot")
alias("Triple Shot", "triple shot")
alias("Double Shot Damage%", "double shot damage")
alias("Triple Shot Damage%", "triple shot damage")
alias("Barrage", "barrage")
alias("Barrage Ranged Accuracy", "barrage accuracy")
alias("Ranged Crit Damage", "dead aim")
alias("Conserve TP", "conserve tp")
alias("Fencer", "fencer")
alias("Occult Acumen", "occult acumen")
alias("Blood Pact Damage", "blood pact damage", "blood pact dmg.")
alias("EnSpell Damage", "enspell damage", "en spell damage", "sword enhancement spell damage")
alias("Elemental Magic Skill", "elemental magic skill")
alias("Ninjutsu Magic Attack", "ninjutsu damage", "elemental ninjutsu damage")
alias(("Quick Draw Damage", "Quick Draw Magic Accuracy"), "quick draw")
alias("Quick Draw Damage", "quick draw damage")
alias("Sneak Attack Bonus", "sneak attack bonus", "sneak attack", "sneak attack damage")
alias("Trick Attack Bonus", "trick attack bonus", "trick attack", "trick attack damage")
alias("Futae Bonus", "futae")
alias("Klimaform Damage%", "klimaform")
alias("Ebullience Bonus", "ebullience")
alias("Hasso+ JA Haste", "hasso")
alias(tuple(COMBAT_SKILLS), "combat skills")
for el, wel in [("fire", "Fire"), ("ice", "Ice"), ("wind", "Wind"), ("earth", "Earth"),
                ("lightning", "Thunder"), ("thunder", "Thunder"), ("water", "Water"),
                ("light", "Light"), ("dark", "Dark")]:
    alias(f"{wel} Elemental Bonus", f"{el} elemental magic atk.bonus", f"{el} elemental damage")
    alias(f"{wel} Elemental Magic Accuracy", f"{el} elemental magic accuracy")

# --- extra keys (not read by wsdist; kept for other scores) ---
alias("HP", "hp")
alias("DEF", "def")
alias("Waltz Potency", "waltz potency")
alias("MP", "mp")
alias("Fast Cast", "fast cast")
alias("Quick Magic", "quick magic")
alias("Enmity", "enmity")
alias("Cure Potency", "cure potency")
alias("Cure Potency II", "cure potency ii")
alias("Cure Potency Received", "cure potency received")
alias("Cure Spellcasting Time", "cure spellcasting time")
alias("Conserve MP", "conserve mp")
alias("SIRD", "spell interruption rate down", "spell interruption rate")
alias("Enhancing Magic Duration", "enhancing magic duration", "enh.mag.eff.dur.",
      "enhancing magic effect duration")
alias("Phalanx", "phalanx")
alias("Refresh", "refresh")
alias("Regen", "regen")
alias("Regen Potency", "regen potency")
alias("Movement Speed", "movement speed")
alias("Treasure Hunter", "treasure hunter")
alias("Block Rate", "chance of successful block")
alias("Shield Defense Bonus", "shield def.bonus", "shield defense bonus")
alias("Enemy Crit Rate", "enemy critical hit rate")
alias("BDT", "breath damage taken", "breath dmg.taken")
alias("Counter", "counter")
alias("Song Duration", "song effect duration")
alias("All Songs", "all songs")
alias("Snapshot", "snapshot")
alias("Rapid Shot", "rapid shot")
alias("Magic Crit Rate", "magic critical hit rate", "magic crit.hit rate")
alias("Rapture Bonus", "rapture")
alias("Magic Skills", "magic skills")
for el in ["fire", "ice", "wind", "earth", "lightning", "water", "light", "dark"]:
    alias(el.title() + " Resistance", el + " resistance")

SKILL_NAMES = ["hand-to-hand", "dagger", "sword", "great sword", "axe", "great axe", "scythe",
               "polearm", "katana", "great katana", "club", "staff", "archery", "marksmanship",
               "throwing", "evasion", "parrying", "guarding", "shield", "magic accuracy",
               "elemental magic", "dark magic", "divine magic", "enhancing magic",
               "enfeebling magic", "healing magic", "summoning magic", "ninjutsu", "singing",
               "string instrument", "wind instrument", "blue magic", "geomancy", "handbell",
               "automaton melee", "automaton ranged", "automaton magic", "stringed instrument"]


def skill_key(name):
    if name == "hand-to-hand":
        return "Hand-to-Hand Skill"
    if name == "stringed instrument":
        name = "string instrument"
    return " ".join(w.title() for w in name.split()) + " Skill"


for sk in SKILL_NAMES:
    alias(skill_key(sk), sk + " skill")

# Counted in points: "HP+10%" is a different stat, key "HP%" (value in percent)
FLAT = {"HP", "MP", "STR", "DEX", "VIT", "AGI", "INT", "MND", "CHR", "Accuracy", "Attack",
        "Ranged Accuracy", "Ranged Attack", "Evasion", "Magic Evasion", "Magic Accuracy",
        "Magic Attack", "Magic Defense", "Enmity", "Magic Damage", "DEF"}

# "Enhances "Dual Wield" effect": the game names a stat without its value
TEXT_ONLY = re.compile(r'(?:Enhances|Increases|Adds|Augments)\s+"?([^"]+?)"?\s+effect'
                       r'|Enhances [a-z ]+ [IVX]+$|Increases critical hit damage'
                       r'|Bonus damage added to magic burst', re.I)


def stat_of(phrase):
    """The stat a phrase names, the whole phrase (normalised) matched against ALIAS.
    Returns (keys, rest): rest is the text before the stat name when only a tail of the
    phrase is a stat ("Step" accuracy -> keys of accuracy, rest '"Step"')."""
    words = phrase.strip().split()
    for k in range(len(words)):
        tail = norm(" ".join(words[k:]))
        if tail in ALIAS:
            return ALIAS[tail], " ".join(words[:k])
    return None, phrase.strip()


def stats_of(phrase):
    """Several stats for one value ("DEX & AGI +15", "INT/MND +25", "All Attr.+2")."""
    name = norm(phrase)
    if name in ("all attr.", "all attributes", "all attr"):
        return [(a,) for a in ATTRS]
    parts = [p for p in re.split(r"\s*(?:&|/|\band\b)\s*", phrase.strip(" /")) if p]
    if len(parts) < 2:
        return None
    keys = [ALIAS.get(norm(p)) for p in parts]
    return keys if all(keys) else None


VALUE = re.compile(r"([+-])\s?(\d+)(%?)")


def add(out, key, v):
    if key.startswith("-"):
        key, v = key[1:], -v
    out[key] = out.get(key, 0) + v


def add_keys(out, keys, v, pct):
    for k in keys:
        if pct and k in ("Attack", "Ranged Attack"):
            # wsdist's "Attack%" / "Ranged Attack%" are fractions (0.10 for +10 %)
            add(out, k + "%", v / 100)
        else:
            add(out, k + "%" if pct and k in FLAT else k, v)


def parse_line(line, out, extra):
    """Adds the stats of one line to out. A stat named with a qualifier the vocabulary does
    not know ('"Step" accuracy +35', 'Annuls damage taken +5%') is not the plain stat: it
    goes to extra under its full name. Returns the text left over."""
    free = []
    last = 0
    for m in VALUE.finditer(line):
        phrase = line[last:m.start()]
        last = m.end()
        v = (-1 if m.group(1) == "-" else 1) * int(m.group(2))
        pct = m.group(3) == "%"
        many = stats_of(phrase)
        if many:
            for keys in many:
                add_keys(out, keys, v, pct)
            continue
        keys, rest = stat_of(phrase)
        p = phrase.strip()
        if keys is None or rest.strip():
            if p and len(p.split()) <= 7 and re.search(r"[A-Za-z]", p) and not p.endswith(":"):
                add(extra, norm(p) + ("%" if pct else ""), v)
            else:
                free.append((p + " " + m.group(0)).strip())
            continue
        if keys == ("SIRD",):
            v = -abs(v)
        add_keys(out, keys, v, pct)
    tail = line[last:].strip()
    if tail:
        free.append(tail)
    return " ".join(free).strip()


ELEMENTS = ["fire", "ice", "wind", "earth", "lightning", "water", "light", "dark"]


def unsigned(line, out):
    """What the game writes its own way: SIRD without a sign, resistances as element glyphs
    (U+E000 fire ... U+E007 dark), MP/HP conversions, "Haste10%", "STR:10"."""
    def sird(m):
        add(out, "SIRD", -int(m.group(1)))
        return " "
    line = re.sub(r"Spell interruption rate down\s*-?(\d+)%", sird, line, flags=re.I)

    def conv(m):
        n, frm, to = int(m.group(1)), m.group(2), m.group(3)
        add(out, to, n)
        add(out, frm, -n)
        return " "
    line = re.sub(r"Converts (\d+) (MP|HP) to (HP|MP)", conv, line)
    line = re.sub(r"\b(Haste)(\d)", r"\1+\2", line)
    line = re.sub(r"\b(STR|DEX|VIT|AGI|INT|MND|CHR):(\d)", r"\1+\2", line)
    # Unity Ranking: "+15～25" is rank 10 to rank 1: keep the best (the resources of 2026-10-13 write
    # the sign again after the tilde: "Enmity-1～-5")
    line = re.sub(r"([+-])\d+[～~]\1?(\d+)", r"\1\2", line)
    return re.sub("[-]", lambda c: " " + ELEMENTS[ord(c.group(0)) - 0xE000] + " resistance",
                  line)


# A line that opens a condition (Set:, Latent effect:, Pet:, Unity Ranking:, "Hasso":...)
COND = re.compile(r"""^(?:"([A-Z][^"]{0,30})"|([A-Z][A-Za-z .()'\-]{0,40})):""")
# In a condition written on its header line ("Grimoire: Magic Accuracy+31"), a later line
# with one of these base stats is the item's own again ("Haste+5% Damage taken-11%")
BASE_MARKER = re.compile(r'\bHaste\s?[+-]|damage taken|Weapon skill damage|"Magic Def\. Bonus"', re.I)
PET = re.compile(r"^(Pet|Avatar|Automaton|Wyvern|Luopan)s?$")
# Content-only conditions: what follows the header only applies in that content, to the next
# header (Hervor: "Domain Invasion: STR+30 ... Weapon skill damage +50%" is all Domain Invasion)
EVENT = re.compile(r"^(Domain Invasion|Dynamis|Dynamis \(D\)|Besieged|Campaign|Assault|Abyssea|Salvage|Reives?|"
                   r"Einherjar|Nyzul Isle|Limbus|Odyssey|Sortie|Ambuscade|Unity|Wildskeeper Reives?|Ballista|"
                   r"Colonization Reives?|Lair Reives?|Escha|Vagary|Delve|Skirmish|Moblin Maze Mongers|Voidwatch|"
                   r"Monstrosity|Pankration|Coalition|Records of Eminence|Brenner|Walk of Echoes|Mog Garden|Garrison)\b", re.I)
# One-line conditions without a colon: procs, day/weather/time windows
COND_LINE = re.compile(r"^(Occ\.|Occasionally|Night|Daytime|Dusk|Dawn|During |"
                       r"(?:Fire|Ice|Wind|Earth|Lightning|Thunder|Water|Light|Dark)s?day|"
                       r".* weather\b)", re.I)
# Conditions naming the slot they apply in (Sortie earrings "Right ear:", "Main hand:")
SLOT_COND = {"right ear": "ear2", "left ear": "ear1", "main hand": "main", "sub": "sub",
             "right ring": "ring2", "left ring": "ring1"}
# Job-ability conditions wsdist models with a key of its own
JA_COND = {"climactic flourish": {"Crit Damage": "Climactic Crit Damage"},
           "striking flourish": {"Crit Rate": "Striking Crit Rate"},
           "innin": {"DA": "Innin DA%"},
           "hasso": {"Gear Haste": "Hasso+ JA Haste"}}


def cond_prefix(line):
    """The condition a line opens, or None ("DEF:", "DMG:", "Delay:" are not conditions)."""
    m = COND.match(line)
    if not m:
        return None
    p = m.group(1) or m.group(2)
    # "DEF:", "DMG:", "Delay:" and a misprinted "STR:10" are values, not conditions
    if re.search(r"\b(DEF|DMG|Delay)$", p) or re.match(r"\s*\+?\d", line[m.end():]):
        return None
    return p


def join_wrapped(text):
    """The game wraps long phrases: a line starting in lower case or with a digit, or after
    a line ending mid-phrase ("Wind elemental", "by", "and", ","), continues the previous."""
    out = []
    for line in text.split("\n"):
        if out and (re.match(r"^[a-z0-9]", line)
                    or re.search(r"(\belemental|\bby|\band|\bof|\bwhen|,)\s*$", out[-1], re.I)):
            out[-1] = out[-1].rstrip() + " " + line
        else:
            out.append(line)
    return out


def parse_description(text):
    r = {"stats": {}, "pet": {}, "conds": [], "unparsed": [], "extra": {}, "text_only": []}
    if not text:
        return r
    cur = None          # the open condition: {"when", "lines", "pet"}

    def weapon(m):
        k, n = m.group(1), int(m.group(2))
        if k == "DEF":
            add(r["stats"], "DEF", n)
        else:
            r.setdefault("weapon", {})[k] = n
        return " "
    for raw in join_wrapped(text):
        line = raw.strip()
        # "DEF:2 Latent effect:", "DMG:30 Delay:224 Main hand: DMG:36": the item's own
        # numbers first, then a condition on the same line
        if cur is None:
            head = re.match(r"^(?:(?:DEF|DMG|Delay):\s?\+?\d+\s*)+", line)
            if head and cond_prefix(line[head.end():]) is not None:
                re.sub(r"\b(DEF|DMG|Delay):\s?\+?(\d+)", weapon, head.group(0))
                line = line[head.end():]
        prefix = cond_prefix(line)
        if prefix is not None:
            body = line[line.index(":") + 1:].strip()
            cur = {"when": prefix, "lines": [body] if body else [], "pet": bool(PET.match(prefix)),
                   "inline": bool(body)}
            r["conds"].append(cur)
            continue
        if cur is not None and cur["inline"] and not cur["pet"] and not EVENT.match(cur["when"] or "") and BASE_MARKER.search(line):
            cur = None
        if cur is not None:
            cur["lines"].append(line)
            continue
        if COND_LINE.match(line):
            r["conds"].append({"when": None, "lines": [line], "pet": False})
            continue
        line = unsigned(line, r["stats"])
        line = re.sub(r"\b(DEF|DMG|Delay):\s?\+?(\d+)", weapon, line)
        for m in TEXT_ONLY.finditer(line):
            r["text_only"].append(m.group(0))
        free = parse_line(line, r["stats"], r["extra"])
        if free:
            r["unparsed"].append(free)
    return r


def finish_conds(r):
    """Turns the open conditions into: pet stats, slot stats, wsdist ability keys, and
    cond (text) + cond_stats (what each condition would add)."""
    cond, cond_stats, slot_stats = [], [], {}
    for c in r.pop("conds"):
        when, lines = c["when"], [l for l in c["lines"] if l]
        if c["pet"]:
            for l in lines:
                pextra = {}
                free = parse_line(unsigned(l, {}), r["pet"], pextra)
                if when == "Automaton" and "skill" in pextra:
                    add(r["stats"], "Automaton Skill", pextra.pop("skill"))
                for k, v in pextra.items():
                    add(r.setdefault("pet_extra", {}), k, v)
                if free:
                    cond.append(f"{when}: {free}")
            continue
        text = (when + ": " if when else "") + " | ".join(lines)
        stats, extra = {}, {}
        for l in lines:
            parse_line(unsigned(l, stats), stats, extra)
        key = (when or "").lower()
        if key in SLOT_COND and stats:
            slot = SLOT_COND[key]
            for k, v in stats.items():
                add(slot_stats.setdefault(slot, {}), k, v)
            continue
        if key in JA_COND:
            for k in [k for k in stats if k in JA_COND[key]]:
                add(r["stats"], JA_COND[key][k], stats.pop(k))
        cond.append(text)
        if stats or extra:
            cs = {"when": when or lines[0], "stats": stats}
            if extra:
                cs["extra"] = extra
            cond_stats.append(cs)
    r["cond"], r["cond_stats"], r["slot_stats"] = cond, cond_stats, slot_stats
    return r


# Values the description leaves out ("Enhances "Dual Wield" effect") or that the resource
# file has no text for. Each read again on BG Wiki on 2026-10-22 (its page's notes):
#   Brutal Earring "Adds 5% Double Attack."; Suppanomimi "Dual Wield +5%"; Static Earring "Bonus to
#   magic burst is 5%."; Locus Ring "Magic Burst damage +5%."; Charis Feather "Gives Crit. Atk. Bonus
#   +5%."; Oneiros Rope "Enhances Occult Acumen effect by +20 TP/MP"; Moonshade Earring "Accuracy+4",
#   "TP Bonus +250"; Centovente, Fernagu, Thibron, Ataktos "{{augment}} TP Bonus +1000" (their pages),
#   Accipiter and Hitaki the same line on Archery_Trials and Katana_Trials. Ukaldi: no text on its page
#   or on Club_Trials (images only), ASSUMED the same as the other Magian weapons of this kind.
#   Open (not looked at): the Magian TP Bonus is one augment path of these weapons, counted here on every copy.
HIDDEN = {
    "Brutal Earring": {"DA": 5},
    "Suppanomimi": {"Dual Wield": 5},
    "Static Earring": {"Magic Burst Damage": 5},
    "Locus Ring": {"Magic Burst Damage": 5},
    "Charis Feather": {"Crit Damage": 5},
    "Oneiros Rope": {"Occult Acumen": 20},
    "Moonshade Earring": {"Accuracy": 4, "TP Bonus": 250},
    "Centovente": {"TP Bonus": 1000}, "Fernagu": {"TP Bonus": 1000},
    "Thibron": {"TP Bonus": 1000}, "Ukaldi": {"TP Bonus": 1000},
    "Accipiter": {"TP Bonus": 1000}, "Ataktos": {"TP Bonus": 1000},
    "Hitaki": {"TP Bonus": 1000},
}


# Item ids whose English description in the resources is wrong (the Japanese one is right): the text read instead.
# Seraphic Ampulla: the English says "Regain"+5; the piece gives INT+3 MND+3 "Occult Acumen"+7 (seen in game 2026-10-09).
WRONG_TEXT = {
    22250: 'INT+3 MND+3 "Occult Acumen"+7',
}


def load_hidden_values():
    """catalog/hidden_values.json (hidden_review.py): {item id: {"stats": {key: n}, "source"}},
    the values BG Wiki gives for effects the description names without a number."""
    path = os.path.join(HERE, "hidden_values.json")
    if not os.path.exists(path):
        return {}
    with open(path, encoding="utf-8") as f:
        return {int(k): v for k, v in json.load(f)["items"].items()}


def build(res_dir):
    hidden_values = load_hidden_values()
    cache = os.path.join(HERE, "cache_base")
    os.makedirs(cache, exist_ok=True)
    items = dump_lua(res_dir, "items", cache)
    descs = dump_lua(res_dir, "item_descriptions", cache)
    out = []
    for sid, it in items.items():
        if it.get("category") not in ("Weapon", "Armor") or not it.get("slots"):
            continue
        slots = slots_of(it["slots"])
        text = WRONG_TEXT.get(it["id"]) or (descs.get(sid) or {}).get("en", "")
        p = finish_conds(parse_description(text))
        e = {"id": it["id"], "name": it["en"], "enl": it.get("enl", it["en"]), "slots": slots,
             "jobs": jobs_of(it.get("jobs", 0)), "level": it.get("level", 0),
             "ilvl": it.get("item_level", 0), "Type": type_of(it, slots)}
        if it.get("superior_level"):
            e["su"] = it["superior_level"]
        skill = it.get("skill")
        if e["Type"] == "Shield":
            e["Skill Type"] = "Shield"
        elif skill:
            e["Skill Type"] = SKILLS.get(skill, str(skill))
        elif any(s in slots for s in ("main", "sub", "ranged", "ammo")):
            e["Skill Type"] = "None"
        if it.get("category") == "Weapon" and it.get("delay") not in (None, 0, 999):
            e["DMG"] = it.get("damage", 0)
            e["Delay"] = it["delay"]
            # Hand-to-Hand: the text gives the weapon's own DMG/Delay ("DMG:+197 Delay:+138"),
            # which is what wsdist stores (it adds the fists' base itself); items.lua the totals
            if skill == 1 and "weapon" in p:
                e["DMG"] = p["weapon"].get("DMG", e["DMG"])
                e["Delay"] = p["weapon"].get("Delay", e["Delay"])
        stats = {k: v for k, v in p["stats"].items() if v != 0}
        hidden = dict(HIDDEN.get(it["en"]) or {})
        hv = hidden_values.get(it["id"])
        if hv:
            for k, v in hv["stats"].items():
                hidden.setdefault(k, v)
            e["hidden_source"] = hv["source"]
        if hidden:
            # a value the text gives wins over the hidden one
            added = [k for k, v in hidden.items() if k not in stats]
            for k in added:
                stats[k] = hidden[k]
            if added:
                e["hidden"] = sorted(added)
        e["stats"] = stats
        for k in ("pet", "pet_extra", "slot_stats", "extra", "cond", "cond_stats", "text_only", "unparsed"):
            if p.get(k):
                e[k] = p[k]
        if not text:
            e["no_text"] = True
        out.append(e)
    out.sort(key=lambda e: e["id"])
    return out


def main():
    res = DEFAULT_RES
    if "--res" in sys.argv:
        res = sys.argv[sys.argv.index("--res") + 1]
    items = build(res)
    by_slot = {}
    for e in items:
        for s in e["slots"]:
            by_slot[s] = by_slot.get(s, 0) + 1
    catalog = {"source": "Windower res/items.lua + res/item_descriptions.lua",
               "vocabulary": "the catalogue's stat keys, see atelier/gear/STAT_KEYS.md",
               "count": len(items), "items": items}
    with open(os.path.join(HERE, "items.json"), "w", encoding="utf-8") as f:
        json.dump(catalog, f, ensure_ascii=False, separators=(",", ":"))
    with open(os.path.join(HERE, "items.js"), "w", encoding="utf-8") as f:
        f.write("(globalThis.FFXI_PARTS=globalThis.FFXI_PARTS||[]).push(function(FFXI){FFXI.CATALOG = ")
        json.dump(catalog, f, ensure_ascii=False, separators=(",", ":"))
        f.write("});\n")
    print(f"{len(items)} items")
    print(", ".join(f"{k}:{v}" for k, v in sorted(by_slot.items(), key=lambda x: -x[1])))


if __name__ == "__main__":
    main()
