// Atelier check "engaged modes" (atelier/app/js/eng_modes.js; notes/docs-perso/engaged-par-mode-2026-11-06/SPEC.md):
//   1. a mode read from the set's name on every job (base, STP, Acc, SB, a Kraken Club set; Solo / Group / Trust
//      their mode's; any other name none), its goal and the DT+PDT -50 / DT+MDT -21 limits, a setting kept for a set
//      before the mode's;
//   2. on Tetsouo's BRD, each mode's search (its own pieces): the mode's goal, the limits held, the Acc set's hit
//      chance and the SB set's Subtle Blow never lower than before, the Kraken Club kept in the PDTKC set's off hand;
//   3. each common Dual Wield tier searched over sets.engaged at the tier's magic haste (the round's own figure), for
//      /DNC, the limits held, only the slots that differ from the engaged set in the tier's try; the attack delay of
//      each tier's result printed against BG Wiki's 20 % floor.
//
//   node scripts/atelier/eng_modes_test.js      (PAGE_URL: the page to open; else data/atelier/index.html)
//
// @file    scripts/atelier/eng_modes_test.js
// @author  ejouanchicot
const path = require('path');
const B = require(path.join(__dirname, 'lib/browser.js'));

const NAMES = [['sets.engaged', 'tp_real'], ['sets.engaged.STP', 'tp_real'], ['sets.engaged.Acc', 'acc'], ['sets.engaged.SB', 'sb'],
  ['sets.engaged.PDTKC', 'tp_real'], ['sets.engaged.PDTKC.Solo', 'tp_real'], ['sets.engaged.NaeglingKC', 'tp_real'], ['sets.engaged.Acc.Trust', 'acc'],
  ['sets.engaged.DT', null], ['sets.engaged.Naegling', null], ['sets.idle', null], ['sets.engaged.Acc.PDT', null]];
const MODES = [['sets.engaged.STP', 'tp_real'], ['sets.engaged.Acc', 'acc'], ['sets.engaged.SB', 'sb'], ['sets.engaged.PDTKC', 'tp_real']];
const TIERS = ['NoHaste', 'Haste', 'HasteII', 'MaxHaste'];

(async () => {
  const browser = await B.puppeteer.launch({executablePath: B.CHROME, headless: 'new', args: ['--allow-file-access-from-files']});
  const page = await browser.newPage(), errs = [];
  page.on('pageerror', e => errs.push(e.message));
  await page.setViewport({width: 1600, height: 900});
  await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); try { localStorage.clear(); } catch (e) {} });
  await page.goto(process.env.PAGE_URL || 'file:///' + path.resolve(__dirname, '../../atelier/index.html').split(path.sep).join('/'), {waitUntil: 'load'});
  await page.waitForFunction(() => window.__atelier && window.__atelier.loaded && typeof engModeOf === 'function', {timeout: 60000});
  await new Promise(r => setTimeout(r, 5000));
  let bad = 0;
  const fail = m => { bad++; console.log('FAIL ' + m); };

  // 1. names, goals, limits, a setting kept for one set
  const names = await page.evaluate(names => {
    S.char = 'Tetsouo'; S.job = 'BRD'; S.section = 'sets'; render();
    const out = names.map(([p]) => { const o = engModeOpts({path: p}); return [p, o.engObj || null, o.pdt, o.mdt]; });
    S.optOpts = Object.assign({}, S.optOpts, {engBy: {'sets.engaged.SB': {pdt: '-40'}}});
    const kept = engOpts({path: 'sets.engaged.SB'}), other = engOpts({path: 'sets.engaged.Acc'});
    S.optOpts = Object.assign({}, S.optOpts, {engBy: {}});
    return {out, kept: [kept.pdt, kept.mdt, kept.engObj], other: [other.pdt, other.mdt]};
  }, NAMES);
  names.out.forEach(([p, obj, pdt, mdt], i) => {
    const want = NAMES[i][1];
    if (obj !== want) fail(`${p} goal ${obj} (want ${want})`);
    else if (want && (pdt !== -50 || mdt !== -21)) fail(`${p} limits ${pdt} / ${mdt}`);
    else console.log(`ok   ${p} -> ${obj || 'no mode'}${want ? ' · -50 / -21' : ''}`);
  });
  if (names.kept.join() !== '-40,-21,sb' || names.other.join() !== '-50,-21') fail(`kept setting ${names.kept} / other set ${names.other}`);
  else console.log('ok   a limit typed for SB kept for SB alone');

  // one search, its result and its options (optimizer.js optResult)
  const search = (fn, p, job = 'BRD') => page.evaluate(async (fn, p, job) => {
    const wait = ms => new Promise(res => setTimeout(res, ms));
    S.char = 'Tetsouo'; S.job = job; S.section = 'sets'; render();
    const s = (S._bypath || {})[p];
    if (!s) return {missing: true};
    S.optOpts = Object.assign({}, S.optOpts, {where: 'mine', fullSpeed: true}); S._optScratch = false; S.toast = '';
    const keep = window.optResult; let got = null, opts = null;
    window.optResult = function (set, k, res, gains, o) { got = res; opts = o; return keep.apply(this, arguments); };
    await window[fn](s);
    for (let n = 0; n < 1500 && S._optBusy; n++) await wait(100);
    window.optResult = keep;
    const tr = S.trial[trialKey(s)] || {}, toast = S.toast;
    closeOverlay(); render();
    if (!got) return {none: true, toast};
    const rd = r => r && r.detail ? {dw: r.detail.dw, haste: r.detail.haste, delay1: r.detail.delay1, delay2: r.detail.delay2} : null;
    const pc = r => engHitPct(Object.assign({}, r, {attacks: r && r.detail ? FFXI.opt.attacksOf(r.detail) : null}));
    const base = opts.dw ? opts.dw.base : null, trial = {};
    for (const [slot, x] of Object.entries(tr)) trial[slot] = x ? x.name : null;
    const baseNames = base ? Object.fromEntries(Object.entries(base).map(([k, x]) => [k, x && x.name])) : null;
    return {obj: opts.engObj, floor: [opts.pdt, opts.mdt], start: {raw: got.start.raw, def: got.start.def, hit: pc(got.start.round)}, best: {raw: got.best.raw, def: got.best.def, miss: got.best.miss, hit: pc(got.best.round), round: rd(got.best.round)},
      sub: (got.pieces.sub || {}).name || null, trial, baseNames, dw: opts.dw ? {tier: opts.dw.tier, haste: opts.dw.haste, sub: opts.dw.sub} : null, toast};
  }, fn, p, job);

  // 2. the BRD modes
  for (const [p, want] of MODES) {
    const r = await search('optimizeEngaged', p);
    if (r.missing) { fail(`${p} not found`); continue; }
    if (r.none) { fail(`${p} no result: ${r.toast}`); continue; }
    const d = r.best.def, tag = `${p} ${r.obj} ${fmt(r.start.raw)} -> ${fmt(r.best.raw)} · DT+PDT ${d.pdt} DT+MDT ${d.mdt} SB ${d.sb} · hit ${fmt(r.start.hit)} -> ${fmt(r.best.hit)} % · sub ${r.sub}`;
    if (r.obj !== want) { fail(`${tag}: goal (want ${want})`); continue; }
    if (r.best.miss || d.pdt > -50 || d.mdt > -21) { fail(`${tag}: limits not held`); continue; }
    if (want === 'acc' && r.best.raw < r.start.raw) { fail(`${tag}: hit chance lost`); continue; }
    if (want === 'sb' && r.best.raw < r.start.raw) { fail(`${tag}: Subtle Blow lost`); continue; }
    if (/KC$/.test(p) && r.sub !== 'Kraken Club') { fail(`${tag}: Kraken Club not kept`); continue; }
    console.log(`ok   ${tag}`);
  }

  // 3. the common Dual Wield tiers
  for (const tier of TIERS) {
    const p = 'sets.DW.' + tier, r = await search('optimizeDwTier', p);
    if (r.missing) { fail(`${p} not found`); continue; }
    if (r.none) { fail(`${p} no result: ${r.toast}`); continue; }
    const d = r.best.def, rd = r.best.round || {}, mh = rd.haste ? rd.haste.magic : null;
    // attack delay over the weapons' own: (1 - Dual Wield) x (1 - haste), BG Wiki's floor 20 %; magic haste capped at 448/1024
    const total = rd.haste ? Math.min(rd.haste.gear, 0.25) + Math.min(rd.haste.ja, 0.25) + Math.min(rd.haste.magic, 448 / 1024) : 0;
    const left = (1 - (rd.dw || 0) / 100) * (1 - total);
    const tag = `${p} ${r.obj} ${fmt(r.start.raw)} -> ${fmt(r.best.raw)} s · magic haste ${mh != null ? (100 * mh).toFixed(2) : '?'} % · DW ${rd.dw} · delay ${(100 * left).toFixed(1)} % (floor 20) · DT+PDT ${d.pdt} DT+MDT ${d.mdt} · /${r.dw.sub} · try ${JSON.stringify(r.trial)}`;
    const want = {NoHaste: 0, Haste: 0.15, HasteII: 0.30, MaxHaste: 448 / 1024}[tier];
    if (mh == null || Math.abs(mh - want) > 1e-9) { fail(`${tag}: magic haste not the tier's`); continue; }
    if (r.best.miss || d.pdt > -50 || d.mdt > -21) { fail(`${tag}: limits not held`); continue; }
    const same = Object.entries(r.trial).filter(([slot, n]) => n && r.baseNames[slot] === n);
    if (same.length) { fail(`${tag}: the try repeats the engaged set's ${same.map(x => x[0])}`); continue; }
    console.log(`ok   ${tag}`);
  }
  // 4. WAR's Subtle Blow mode (sets.engaged.SubtleBlow): Subtle Blow, then DT, then the time, no DT floor before it;
  //    BRD's .SB keeps its goal and limits
  const war = await page.evaluate(() => {
    S.char = 'Tetsouo'; S.job = 'WAR'; render();
    const w = engModeOpts({path: 'sets.engaged.SubtleBlow'}), g = engModeOpts({path: 'sets.engaged.SubtleBlow.Group'});
    S.job = 'BRD'; render();
    const b = engModeOpts({path: 'sets.engaged.SB'});
    return [[w.engObj, w.pdt, w.mdt], [g.engObj], [b.engObj, b.pdt, b.mdt]];
  });
  if (war[0].join() !== 'sb_dt,0,0' || war[1].join() !== 'sb_dt' || war[2].join() !== 'sb,-50,-21') fail(`WAR SubtleBlow / BRD SB goals ${JSON.stringify(war)}`);
  else console.log('ok   WAR sets.engaged.SubtleBlow -> sb_dt, no floor · BRD sets.engaged.SB -> sb -50 / -21');
  {
    const p = 'sets.engaged.SubtleBlow', r = await search('optimizeEngaged', p, 'WAR');
    if (r.missing) fail(`WAR ${p} not found`);
    else if (r.none) fail(`WAR ${p} no result: ${r.toast}`);
    else {
      const dt = d => Math.min(50, Math.max(0, -(d.pdt || 0))) + Math.min(21, Math.max(0, -(d.mdt || 0)));
      const s0 = r.start.def, d = r.best.def;
      const tag = `WAR ${p} ${r.obj} SB ${fmt(r.start.raw)} -> ${fmt(r.best.raw)} · DT ${fmt(dt(s0))} -> ${fmt(dt(d))} (DT+PDT ${d.pdt} DT+MDT ${d.mdt})`;
      if (r.obj !== 'sb_dt') fail(`${tag}: goal`);
      else if (r.best.raw < r.start.raw) fail(`${tag}: Subtle Blow lost`);
      else if (r.best.raw === r.start.raw && dt(d) < dt(s0)) fail(`${tag}: DT lost at equal Subtle Blow`);
      else console.log(`ok   ${tag}`);
    }
  }
  if (errs.length) fail('page errors: ' + errs.slice(0, 3).join(' | '));
  await browser.close();
  console.log(bad ? `${bad} FAIL` : 'ALL PASS');
  process.exit(bad ? 1 : 0);
})();
function fmt(v){ return v == null ? '—' : (+v).toFixed(2); }
