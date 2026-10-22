"""Parse LandSandBoat xi.data.augments.bundles into cache/lsb_bundles.json."""
import json, re, os
HERE = os.path.dirname(os.path.abspath(__file__))
src = open(os.path.join(HERE, 'cache', 'lsb_augments.lua'), encoding='utf-8').read()
start = src.index('xi.data.augments.bundles =')
end = src.index('xi.data.augments.rpCurves')
body = src[start:end]
bundles = {}
cur = None
comment = None
for line in body.splitlines():
    s = line.strip()
    m = re.match(r'^\[(\d+)\]\s*=\s*$', s)
    if m:
        cur = int(m.group(1)); bundles[cur] = []; comment = None; continue
    if s.startswith('--'):
        comment = s[2:].strip(); continue
    m = re.match(r'^\{\s*\{([^}]*)\}\s*,\s*\{([^}]*)\}\s*\},?$', s)
    if m and cur is not None:
        params = [p.strip() for p in m.group(1).split(',') if p.strip()]
        vals = [int(v) for v in m.group(2).split(',') if v.strip()]
        bundles[cur].append({'text': comment, 'params': params, 'values': vals})
        comment = None
json.dump(bundles, open(os.path.join(HERE, 'cache', 'lsb_bundles.json'), 'w'), indent=0)
print(len(bundles), 'bundles', sum(len(b) for b in bundles.values()), 'effects')
