"""Read Windower's libs/extdata.lua augment_values (systems 1, 2, 4) and write
cache/extdata_augments.json: {system: {id: [{stat, offset, multiplier, percent}]}}
plus the distinct stat labels. Used to build and test augments_parse.js."""
import json, os, re

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = r'D:\Windower Tetsouo\addons\libs\extdata.lua'
src = open(SRC, encoding='utf-8', errors='replace').read()
start = src.index('augment_values = {')
end = src.index('server_timestamp_offset')
body = src[start:end]

systems = {}
cur = None
depth_sys = re.compile(r'^\s{4}\[(\d+)\]\s*=\s*\{\s*$')
entry = re.compile(r'^\s*\[(0x[0-9A-Fa-f]+|\d+)\]\s*=\s*\{(.*)\},?\s*(--.*)?$')
item = re.compile(r'\{\s*stat\s*=\s*("(?:[^"\\]|\\.)*"|\'(?:[^\'\\]|\\.)*\')\s*,\s*([^}]*)\}')
for line in body.splitlines():
    m = depth_sys.match(line)
    if m:
        cur = int(m.group(1)); systems[cur] = {}; continue
    if cur is None:
        continue
    m = entry.match(line)
    if not m:
        continue
    iid = int(m.group(1), 0)
    effs = []
    for im in item.finditer(m.group(2)):
        stat = im.group(1)[1:-1].replace('\\"', '"').replace("\\'", "'")
        rest = im.group(2)
        def opt(name, default):
            mm = re.search(name + r'\s*=\s*(-?[\w.]+)', rest)
            return mm.group(1) if mm else default
        mult = float(opt('multiplier', '1'))
        effs.append({'stat': stat, 'offset': int(opt('offset', '0')),
                     'multiplier': int(mult) if mult.is_integer() else mult,   # 0x20E..: -0.5
                     'percent': opt('percent', 'false') == 'true'})
    if effs:
        systems[cur][iid] = effs

labels = sorted({e['stat'] for s in systems.values() for v in s.values() for e in v})
json.dump({'systems': systems, 'labels': labels},
          open(os.path.join(HERE, 'cache', 'extdata_augments.json'), 'w'), indent=0)
print({k: len(v) for k, v in systems.items()}, len(labels), 'labels')
