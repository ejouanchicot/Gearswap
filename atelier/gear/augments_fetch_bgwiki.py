"""Fetch (once, cached) the BG Wiki page of every item of augments_ranked.json,
for augments_check_bgwiki.js.      python augments_fetch_bgwiki.py"""
import json, os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from augments_bgwiki import wikitext

items = json.load(open(os.path.join(HERE, 'augments_ranked.json'), encoding='utf-8'))['items']
missing = []
for en, it in items.items():
    try:
        if not wikitext(it['wiki']):
            missing.append(it['wiki'])
    except Exception as e:  # network or page error: reported, the check skips it
        missing.append('%s (%s)' % (it['wiki'], e))
print(len(items), 'items,', len(missing), 'without a page:', missing)
