"""
Fetches (once, cached) the BG Wiki page of every catalogue item whose description names
an effect without its value (text_only) or a multi-attack proc, for hidden_parse.py.

Cache: catalog/cache_bgwiki/<item id>.json = {"id", "name", "title", "url", "wikitext"}
(wikitext "" when no title matched). Sequential, ~1 request per second, resumes from cache.

Usage: python atelier-engine/catalog/hidden_fetch.py [--min-level 75] [--limit N] [--stages]
       [--names "Name A|Name B"]
--stages: also resolves Relic/Mythic/Empyrean names to their ilvl 119 stage page.

@author ejouanchicot
"""
import json
import os
import re
import sys
import time
import urllib.parse
import urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, "cache_bgwiki")
API = "https://www.bg-wiki.com/api.php?action=parse&prop=wikitext&format=json&redirects=1&page="
WIKI = "https://www.bg-wiki.com/ffxi/"

# Effects an optimizer scores (wsdist keys or catalogue extra keys); "Resist X", "X Killer"
# and most job-ability enhancements are left out
RELEVANT = re.compile(
    r'Refresh|Fast Cast|Regen|critical hit|Snapshot|Zanshin|Dual Wield|song effect|Quick Draw'
    r'|Martial Arts|magic burst|Counter"|Sneak Attack|Trick Attack|Skillchain|Recycle'
    r'|Double Shot|Triple Shot|Double Attack|Triple Attack|Occult|Barrage|Hasso|Klimaform'
    r'|Futae|Ebullience|Rapture|Flourish|magic effect|Conserve|Store TP|Subtle|Kick|Treasure'
    r'|Cure|Unlimited Shot|Velocity|Sharpshot|Saboteur', re.I)
MULTI = re.compile(r"^(Occasionally|Occ\.) (attacks|deals)", re.I)
SMALL = {"of", "the", "a", "an", "and", "de", "du", "la", "le", "in", "on", "to"}


def candidates(items, min_level):
    """Items to look up, endgame first (level, then item level)."""
    out = []
    for e in items:
        rel = [t for t in e.get("text_only", []) if RELEVANT.search(t)]
        oa = [c for c in e.get("cond", []) if MULTI.match(c)]
        if (rel or oa) and e["level"] >= min_level:
            out.append(e)
    out.sort(key=lambda e: (-e["ilvl"], -e["level"], e["id"]))
    return out


def titles(e):
    """Page titles to try: the long name title-cased (BG Wiki's page name), then the short."""
    words = e["enl"].split(" ")
    long = " ".join(w if (i and w in SMALL) else w[:1].upper() + w[1:] for i, w in enumerate(words))
    long = re.sub(r"-([a-z])", lambda m: "-" + m.group(1).upper(), long)
    out = [long]
    if e["name"] not in out:
        out.append(e["name"])
    return out


_MEMO = {}


def fetch(title):
    if title in _MEMO:
        return _MEMO[title]
    req = urllib.request.Request(API + urllib.parse.quote(title.replace(" ", "_")),
                                 headers={"User-Agent": "atelier-catalog/1.0 (hidden values)"})
    data = json.load(urllib.request.urlopen(req, timeout=30))
    time.sleep(1.0)
    _MEMO[title] = data.get("parse", {})
    return _MEMO[title]


def page_of(e):
    """Cached page of an item, fetched if missing."""
    path = os.path.join(CACHE, f"{e['id']}.json")
    if os.path.exists(path):
        with open(path, encoding="utf-8") as f:
            return json.load(f)
    rec = {"id": e["id"], "name": e["name"], "title": "", "url": "", "wikitext": ""}
    for t in titles(e):
        p = fetch(t)
        if p.get("wikitext"):
            rec.update(title=p["title"], url=WIKI + urllib.parse.quote(p["title"].replace(" ", "_")),
                       wikitext=p["wikitext"]["*"])
            break
    with open(path, "w", encoding="utf-8") as f:
        json.dump(rec, f, ensure_ascii=False)
    return rec


def api(query):
    req = urllib.request.Request("https://www.bg-wiki.com/api.php?" + query,
                                 headers={"User-Agent": "atelier-catalog/1.0 (hidden values)"})
    data = json.load(urllib.request.urlopen(req, timeout=30))
    time.sleep(1.0)
    return data


def resolve_stage(rec):
    """Relic/Mythic/Empyrean/Ergon names are a disambiguation page ("{{RME Page"): the
    stage page "Kenkonken (Level 119 III)" is the one whose ffxidb is the item id.
    Tries the Level 119 stages first; records the match in the cache file."""
    page = rec["wikitext"]
    if rec.get("stage_checked") or ("{{RME Page" not in page and "share this name" not in page):
        return rec
    base = rec["title"]
    found = api("action=query&list=prefixsearch&format=json&pslimit=30&pssearch="
                + urllib.parse.quote(base + " ("))["query"]["prefixsearch"]
    subs = sorted((f["title"] for f in found), key=lambda t: (0 if "119" in t else 1, -len(t)))
    for t in subs:
        p = fetch(t)
        w = p.get("wikitext", {}).get("*", "")
        if re.search(r"ffxidb\s*=\s*%d\b" % rec["id"], w):
            rec.update(stage_title=p["title"], wikitext=w,
                       url=WIKI + urllib.parse.quote(p["title"].replace(" ", "_")))
            break
    rec["stage_checked"] = True
    with open(os.path.join(CACHE, f"{rec['id']}.json"), "w", encoding="utf-8") as f:
        json.dump(rec, f, ensure_ascii=False)
    return rec


def main():
    min_level = int(sys.argv[sys.argv.index("--min-level") + 1]) if "--min-level" in sys.argv else 75
    limit = int(sys.argv[sys.argv.index("--limit") + 1]) if "--limit" in sys.argv else 10 ** 6
    os.makedirs(CACHE, exist_ok=True)
    with open(os.path.join(HERE, "items.json"), encoding="utf-8") as f:
        items = json.load(f)["items"]
    extra = sys.argv[sys.argv.index("--names") + 1].split("|") if "--names" in sys.argv else []
    todo = candidates(items, min_level) + [e for e in items if e["name"] in extra]
    missing, done = [], 0
    for e in todo[:limit]:
        try:
            rec = page_of(e)
            if rec["wikitext"] and ("--stages" in sys.argv) and e["ilvl"] >= 119:
                rec = resolve_stage(rec)
        except Exception as ex:  # network error: reported, retried on the next run
            print("ERR", e["id"], e["name"], ex)
            continue
        done += 1
        if not rec["wikitext"]:
            missing.append(f"{e['id']} {e['name']}")
    print(f"{done} pages ({len(todo)} candidates), {len(missing)} without a page:")
    print("\n".join(missing))


if __name__ == "__main__":
    main()
