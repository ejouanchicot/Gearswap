// Atelier check "enhancing figures": every set the stats optimizer takes, for every character, job and exported
// subjob, with what the page makes of it: its default objectives and floors, on whom it is cast, the enhancing
// context (spell, tier, base seconds) and its figures. Saved once (--save), then compared (--compare): the Red Mage's
// sets must not move by a single figure; every other change is printed for review.
//
//   node scripts/atelier/enh_figures_test.js --save <file.json>
//   node scripts/atelier/enh_figures_test.js --compare <file.json> [--only RDM] [--cases]
//   (--cases first checks the tier each job and subjob casts against BG Wiki's levels: TIER_CASES)
//
// PAGE_URL: the page to open; else data/atelier/index.html.
//
// @file    scripts/atelier/enh_figures_test.js
// @author  ejouanchicot
const path = require('path'), fs = require('fs');
const puppeteer = require(process.env.PUPPETEER || path.join(process.env.APPDATA || '', 'npm/node_modules/@modelcontextprotocol/server-puppeteer/node_modules/puppeteer'));
const args = process.argv.slice(2), mode = args[0], file = args[1], only = args.includes('--only') ? args[args.indexOf('--only') + 1] : null;
if (!['--save', '--compare'].includes(mode) || !file) { console.log('usage: --save <file> | --compare <file> [--only JOB]'); process.exit(2); }

async function snapshot(){
  const browser = await puppeteer.launch({executablePath: process.env.CHROME || 'C:/Program Files/Google/Chrome/Application/chrome.exe', headless: 'new', args: ['--allow-file-access-from-files']});
  const page = await browser.newPage(), errs = [];
  page.on('pageerror', e => errs.push(e.message));
  await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); try { localStorage.clear(); localStorage.setItem('atelier', JSON.stringify({guide: {mode: 'off', seen: {tour: true}}})); } catch (e) {} });
  await page.goto(process.env.PAGE_URL || 'file:///' + path.resolve(__dirname, '../../atelier/index.html').split(path.sep).join('/'), {waitUntil: 'load'});
  await page.waitForFunction(() => typeof render === 'function' && typeof CHARS === 'object' && Object.keys(CHARS).length && window.FFXI && FFXI.opt, {timeout: 60000});
  await new Promise(r => setTimeout(r, 4000));
  const out = await page.evaluate(() => {
    const res = {};
    const round = v => typeof v === 'number' ? Math.round(v * 1000) / 1000 : v;
    for (const c of Object.keys(CHARS).sort()) for (const j of CHARS[c].jobs.slice().sort()) for (const sub of Object.keys(exportsOf(c, j)).sort()) {
      S.char = c; S.job = j; S.subs[c + '|' + j] = sub; S._bypath = null;
      try { render(); } catch (e) {}
      const d = data();
      if (!d || !d.sets) continue;
      for (const s of d.sets) {
        if (!statSet(s)) continue;
        const key = `${c}|${j}|${sub}|${s.path}`, row = {};
        try {
          row.objs = statDefault(s); row.floor = statOpts(s).floor; row.target = enhTarget(s);
          const e = enhContext(s); row.enh = e ? JSON.parse(JSON.stringify(e)) : null;
          const f = statFigures(s, true), fig = {};
          for (const k of Object.keys(f).sort()) fig[k] = round(f[k]);
          row.fig = fig;
        } catch (e) { row.error = String(e && e.message || e); }
        res[key] = row;
      }
    }
    return res;
  });
  await browser.close();
  return {sets: out, errors: errs};
}

// The tier each job casts (enh_jobs.js enhTier), against BG Wiki's levels (Category:Enhancing_Magic, read 2026-10-22):
// [job, sub, main level, sub level, job points spent, set kind, the spell expected (null: none)]
const TIER_CASES = [
  ['BLM', 'RDM', 99, 49, 0, 'refresh', 'Refresh'], ['BLM', 'RDM', 99, 49, 0, 'phalanx', 'Phalanx'], ['BLM', 'RDM', 99, 49, 0, 'aquaveil', 'Aquaveil'],
  ['BLM', 'DRG', 99, 49, 0, 'aquaveil', null], ['WAR', 'RUN', 99, 49, 0, 'refresh', null], ['WAR', 'RUN', 99, 49, 0, 'phalanx', null],
  ['WAR', 'RUN', 99, 49, 0, 'regen', 'Regen II'], ['WAR', 'RUN', 99, 59, 0, 'regen', 'Regen II'], ['WHM', 'BLM', 99, 49, 0, 'regen', 'Regen IV'],
  ['SCH', 'RDM', 99, 49, 0, 'regen', 'Regen V'], ['RDM', 'NIN', 99, 49, 0, 'refresh', 'Refresh II'], ['RDM', 'NIN', 99, 49, 1200, 'refresh', 'Refresh III'],
  ['RDM', 'SCH', 99, 49, 0, 'regen', 'Regen II'], ['RDM', 'SCH', 99, 59, 0, 'regen', 'Regen III'], ['PLD', 'RUN', 99, 49, 0, 'stoneskin', null],
  ['PLD', 'RUN', 99, 59, 0, 'stoneskin', 'Stoneskin'],
  // a /RDM's tier I enspells: BG Wiki Enspell does not say whether a support job casts them; the game's levels and
  // shared/data/magic (Enfire, Enthunder, Enwater marked main job only, Enaero not) are what the page follows
  ['WAR', 'RDM', 99, 49, 0, 'enspell', 'Enaero'], ['RDM', 'WHM', 99, 49, 0, 'enspell', 'Enaero'],
  ['RUN', 'WAR', 99, 49, 0, 'phalanx', 'Phalanx'], ['RUN', 'WAR', 99, 49, 550, 'temper', 'Temper'], ['RUN', 'WAR', 99, 49, 0, 'temper', null],
  ['RDM', 'WHM', 99, 49, 1200, 'temper', 'Temper II'], ['WHM', 'SCH', 99, 49, 0, 'gain', /^Boost-/], ['PLD', 'WAR', 99, 49, 0, 'phalanx', 'Phalanx']];

async function tierCases(){
  const browser = await puppeteer.launch({executablePath: process.env.CHROME || 'C:/Program Files/Google/Chrome/Application/chrome.exe', headless: 'new', args: ['--allow-file-access-from-files']});
  const page = await browser.newPage();
  await page.goto(process.env.PAGE_URL || 'file:///' + path.resolve(__dirname, '../../atelier/index.html').split(path.sep).join('/'), {waitUntil: 'load'});
  await page.waitForFunction(() => typeof enhTier === 'function' && typeof SPELL_ACCESS === 'object', {timeout: 60000});
  const got = await page.evaluate(cases => cases.map(([job, sub, main, subLv, jp, kind]) => {
    const row = ENH_SPELLS.find(k => k[1] === kind), t = row && enhTier(row[2], job, sub, {main, sub: subLv}, jp);
    return t ? t[0] : null;
  }), TIER_CASES.map(c => c.slice(0, 6)));
  await browser.close();
  let bad = 0;
  TIER_CASES.forEach((c, i) => { const want = c[6], ok = want instanceof RegExp ? want.test(got[i] || '') : got[i] === want;
    if (!ok) bad++; console.log(`${ok ? 'ok  ' : 'FAIL'} ${c[0]}/${c[1]} main ${c[2]} sub ${c[3]} jp ${c[4]} ${c[5]}: ${got[i]} (expected ${want})`); });
  return bad;
}

(async () => {
  if (args.includes('--cases')) { const bad = await tierCases(); console.log(bad ? `${bad} tier case(s) failed` : 'ok   every tier case'); if (bad) process.exit(1); }
  const snap = await snapshot();
  const n = Object.keys(snap.sets).length;
  if (mode === '--save') {
    fs.writeFileSync(file, JSON.stringify(snap, null, 1));
    console.log(`saved ${n} sets to ${file}; page errors ${JSON.stringify(snap.errors)}`);
    return;
  }
  const was = JSON.parse(fs.readFileSync(file, 'utf8')).sets, now = snap.sets;
  let rdmMoved = 0, other = 0, same = 0;
  const lines = [];
  for (const key of [...new Set([...Object.keys(was), ...Object.keys(now)])].sort()) {
    const job = key.split('|')[1];
    if (only && job !== only) continue;
    const a = was[key], b = now[key];
    const diff = [];
    if (!a || !b) diff.push(a ? 'gone' : 'new');
    else {
      for (const k of ['objs', 'floor', 'target', 'error']) if (JSON.stringify(a[k]) !== JSON.stringify(b[k])) diff.push(`${k}: ${JSON.stringify(a[k])} -> ${JSON.stringify(b[k])}`);
      for (const k of new Set([...Object.keys(a.fig || {}), ...Object.keys(b.fig || {})])) { const x = JSON.stringify((a.fig || {})[k]), y = JSON.stringify((b.fig || {})[k]); if (x !== y) diff.push(`${k} ${x} -> ${y}`); }
    }
    if (!diff.length) { same++; continue; }
    if (job === 'RDM') rdmMoved++; else other++;
    lines.push(`${job === 'RDM' ? 'RDM-MOVED' : 'changed  '} ${key}\n    ${diff.join('\n    ')}`);
  }
  console.log(lines.join('\n'));
  console.log(`\n${same} same, ${other} changed (other jobs), ${rdmMoved} RDM moved; page errors ${JSON.stringify(snap.errors)}`);
  console.log(rdmMoved ? 'FAIL: a Red Mage set moved' : 'ok   Red Mage sets identical');
  process.exit(rdmMoved ? 1 : 0);
})();
