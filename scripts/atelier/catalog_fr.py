"""Add the French line (`fr`) of set catalog entries, for the Atelier's set cards.

A catalog entry (shared/utils/atelier/set_catalog.lua) says in `when` when the job's code wears a set; the page shows
`fr` in French. This writes `fr = '...'` right after an entry's `when` string, the entry found by its path (its first
string), from a JSON file {path: phrase}; an entry that has a `fr` already is replaced. Then it lists the entries of
the file still without one.

    python scripts/atelier/catalog_fr.py <catalog.lua> <phrases.json>     write, then list the missing ones
    python scripts/atelier/catalog_fr.py <catalog.lua>                    list the missing ones only

Phrases: plain French for a newcomer, no code names but the set names and the game's words; an apostrophe is the
typographic one (U+2019), so a Lua string never needs escaping.

@author ejouanchicot
"""
import json
import re
import sys

# {'path', when = '...'(, fr = '...')?
ENTRY = re.compile(r"""\{\s*'((?:[^'\\]|\\.)*)'\s*,\s*when\s*=\s*'((?:[^'\\]|\\.)*)'(\s*,\s*fr\s*=\s*'(?:[^'\\]|\\.)*')?""")


def missing(text):
    return [m.group(1) for m in ENTRY.finditer(text) if not m.group(3)]


def main():
    path = sys.argv[1]
    text = open(path, encoding='utf-8').read()
    if len(sys.argv) > 2:
        phrases = json.load(open(sys.argv[2], encoding='utf-8'))
        bad = [k for k, v in phrases.items() if "'" in v or '\\' in v]
        if bad:
            sys.exit('a phrase holds a straight apostrophe or a backslash: ' + ', '.join(bad))
        seen = set()

        def put(m):
            key = m.group(1)
            if key not in phrases:
                return m.group(0)
            seen.add(key)
            return m.group(0)[:m.end(2) + 1 - m.start(0)] + ", fr = '" + phrases[key] + "'"
        text = ENTRY.sub(put, text)
        open(path, 'w', encoding='utf-8', newline='').write(text)
        unused = [k for k in phrases if k not in seen]
        if unused:
            print('phrases for no entry:', unused)
    left = missing(text)
    print('%s: %d entries without fr%s' % (path, len(left), (': ' + ', '.join(left)) if left else ''))
    sys.exit(1 if left else 0)


if __name__ == '__main__':
    main()
