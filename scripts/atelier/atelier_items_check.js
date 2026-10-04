// GearSwap Atelier · items cross-check (for the project, never shipped to players): every piece of every export, in
// the sets and in the bags, checked against the game's catalogue and the engine; what the page reads of each stat
// against what the engine counts (any gap is a misreading on one side); the stat spellings left unread; a piece held
// but read as not yours. Run after an export or a change to the page's or the engine's reading of items:
//   node scripts/atelier/atelier_items_check.js
// Needs Node, Puppeteer (PUPPETEER = its folder, else the global npm one) and Chrome (CHROME = chrome.exe).
const path = require('path');
const puppeteer = require(process.env.PUPPETEER || path.join(process.env.APPDATA || '', 'npm/node_modules/@modelcontextprotocol/server-puppeteer/node_modules/puppeteer'));
const CHROME = process.env.CHROME || 'C:/Program Files/Google/Chrome/Application/chrome.exe';
const PAGE = 'file:///' + path.resolve(__dirname, '../../atelier.html').split(path.sep).join('/');
(async () => {
  const b = await puppeteer.launch({executablePath: CHROME, headless: 'new', args: ['--allow-file-access-from-files']});
  const p = await b.newPage(); await p.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); });
  await p.goto(PAGE, {waitUntil: 'load'}); await new Promise(r => setTimeout(r, 8000));
  const out = await p.evaluate(() => {
    // page stat key -> engine stat name
    const MAP0 = {str: 'STR', dex: 'DEX', vit: 'VIT', agi: 'AGI', int: 'INT', mnd: 'MND', chr: 'CHR', acc: 'Accuracy', atk: 'Attack',
      racc: 'Ranged Accuracy', ratk: 'Ranged Attack', macc: 'Magic Accuracy', mab: 'Magic Attack', da: 'DA', ta: 'TA', qa: 'QA',
      stp: 'Store TP', crit: 'Crit Rate', wsd: 'Weapon Skill Damage', tpb: 'TP Bonus', dw: 'Dual Wield', haste: 'Gear Haste', pdl: 'PDL', hp: 'HP'}; const MAP = ENGINE_STAT;
    const res = {noCatalog: new Map(), noEngine: new Map(), noDesc: new Map(), diff: new Map(), unknownKeys: new Map(), notYours: new Map()};
    const seen = new Set(), cat = catalog();
    for (const c of Object.keys(DATA)) for (const j of Object.keys(DATA[c])) {
      S.char = c; S.job = j; const d = data(); if (!d) continue;
      const owned = ownedOf(), ownedNames = new Set(Object.values(owned).flat().map(x => x.name.toLowerCase()));
      const fromSets = d.sets.flatMap(st => Object.entries(st.pieces || {}).map(([slot, x]) => [slot, x, st.path]));
      const fromBags = Object.entries(owned).flatMap(([slot, l]) => l.map(x => [slot, x, 'bags']));
      for (const [slot, x, where] of fromSets.concat(fromBags)) {
        if (!x || !x.name || x.name === 'empty' || slot === 'main' && false) continue;
        // a set piece you hold under another case / name form
        if (where !== 'bags' && !['main', 'sub', 'range'].includes(slot)) {
          const st = holdState(slot, x);
          if (st === 'missing' && ownedNames.has(x.name.toLowerCase())) res.notYours.set(x.name, c + ' ' + j + ' ' + where);
        }
        const k = x.name + '|' + (x.augs || []).join('|') + '|' + slot; if (seen.has(k)) continue; seen.add(k);
        if (cat && !(x.name in cat.id)) res.noCatalog.set(x.name, c + ' ' + j + ' ' + where);
        const it = FFXI.opt.item(x.name); if (!it) { res.noEngine.set(x.name, c + ' ' + j); continue; }
        const r = pieceStats(x, slot);
        if (!r || !r.known) { res.noDesc.set(x.name, c + ' ' + j); continue; }
        for (const [key, e] of Object.entries(r.stats)) if (key.startsWith('x:')) res.unknownKeys.set(key + ' «' + e.label + '»', x.name);
        // the page's stats against the engine's (the same piece, augments and rank)
        const q = optPieces({[slot]: {name: x.name, augs: x.augs}})[slot] || x, g = FFXI.opt.gear(q, slot, {}) || {}, r2 = pieceStats(q, slot) || r;
        for (const [pk, ek] of Object.entries(MAP)) {
          const pv = (r2.stats[pk] || {}).v || 0, ev = g[ek] || 0;
          if (Math.abs(pv - ev) > 0.5) res.diff.set(x.name + ' [' + slot + '] ' + pk + ': page ' + pv + ' / engine ' + ev, (x.augs || []).join(' ; '));
        }
      }
    }
    const show = (t, m, n = 80) => t + ' (' + m.size + ')\n' + [...m].slice(0, n).map(([k, v]) => '  ' + k + (v ? '   <- ' + v : '')).join('\n');
    return [show('NOT IN GAME CATALOGUE', res.noCatalog), show('NOT IN ENGINE', res.noEngine), show('NO DESCRIPTION', res.noDesc),
      show('HELD BUT READ AS NOT YOURS', res.notYours), show('PAGE vs ENGINE STAT GAPS', res.diff, 120), show('UNKNOWN STAT SPELLINGS', res.unknownKeys, 120)].join('\n\n');
  });
  console.log(out); await b.close();
})();
