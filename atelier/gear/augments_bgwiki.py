"""Fetch BG Wiki page wikitext through its API, cached in cache/bgwiki/<page>.json.

    python augments_bgwiki.py Nyame_Mail "Rudianos's_Mantle" ...
    from augments_bgwiki import wikitext; wikitext('Nyame_Mail')
"""
import json, os, sys, time, urllib.parse, urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, 'cache', 'bgwiki')
API = 'https://www.bg-wiki.com/api.php?action=parse&prop=wikitext&format=json&redirects=1&page='


def _path(page):
    safe = ''.join(c if c.isalnum() or c in '-_+' else '_' for c in page)
    return os.path.join(CACHE, safe + '.json')


def wikitext(page):
    """Wikitext of a BG Wiki page ('' if the page does not exist)."""
    os.makedirs(CACHE, exist_ok=True)
    p = _path(page)
    if not os.path.exists(p):
        req = urllib.request.Request(API + urllib.parse.quote(page.replace(' ', '_')),
                                     headers={'User-Agent': 'atelier-catalog/1.0'})
        data = urllib.request.urlopen(req, timeout=30).read()
        open(p, 'wb').write(data)
        time.sleep(0.5)
    d = json.load(open(p, encoding='utf-8'))
    return d.get('parse', {}).get('wikitext', {}).get('*', '')


if __name__ == '__main__':
    for a in sys.argv[1:]:
        t = wikitext(a)
        print(a, len(t))
