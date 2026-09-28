"""Check every relative link and #anchor in docs/**/*.md and README.md.

Usage (from the data/ folder):
    python docs/tools/check_links.py

Anchors follow GitHub's heading slugs (lower case, punctuation dropped,
spaces to dashes, -1 / -2 suffixes for repeated headings).
"""

import glob
import os
import re


def slug(text):
    text = re.sub(r'`', '', text.strip().lower())
    text = re.sub(r'[^\w\- ]', '', text)
    return text.replace(' ', '-')


def strip_code(text):
    text = re.sub(r'```.*?```', '', text, flags=re.S)
    return re.sub(r'`[^`\n]*`', '', text)


def headings(path):
    ids, seen = set(), {}
    text = re.sub(r'```.*?```', '', open(path, encoding='utf-8').read(), flags=re.S)
    for head in re.findall(r'^#{1,6}\s+(.+?)\s*$', text, re.M):
        anchor = slug(head)
        if anchor in seen:
            seen[anchor] += 1
            anchor = '%s-%d' % (anchor, seen[anchor])
        else:
            seen[anchor] = 0
        ids.add(anchor)
    return ids


def main():
    files = [os.path.normpath(f) for f in glob.glob('docs/**/*.md', recursive=True)] + ['README.md']
    anchors = {f: headings(f) for f in files}
    bad = 0
    for f in files:
        text = strip_code(open(f, encoding='utf-8').read())
        for link in re.findall(r'\]\(([^)\s]+)\)', text):
            if re.match(r'(https?:|mailto:)', link):
                continue
            path, _, anchor = link.partition('#')
            target = os.path.normpath(os.path.join(os.path.dirname(f), path)) if path else f
            if path and not os.path.exists(target):
                print('missing  %s -> %s' % (f, link))
                bad += 1
            elif anchor and target.endswith('.md') and anchor not in anchors.get(target, headings(target)):
                print('anchor   %s -> %s' % (f, link))
                bad += 1
    print('%d broken link(s)' % bad)


if __name__ == '__main__':
    main()
