// Atelier check "song searches": the stats optimizer on Tetsouo's BRD song sets (atelier/app/js/brd_song.js
// songObjectives; notes/docs-perso/chants-brd-2026-11-05/SPEC.md §3.3, §4.3). For each set: its default objectives,
// then a search among the character's own pieces, the result checked against what the set is for:
//   a family set takes its family's piece, its Song+ at the family's cap with nothing lost past it;
//   every song set keeps its instrument (range) and its ammo slot (an instrument leaves none); a filler song gets no longer, a debuff loses no song accuracy;
//   the instrument-only sets (sets.midcast.Songs.Gjallarhorn...) are left to GearSwap (no stats search).
//
//   node scripts/atelier/song_search_test.js      (PAGE_URL: the page to open; else data/atelier/index.html)
//
// @file    scripts/atelier/song_search_test.js
// @author  ejouanchicot
const path = require('path');
const B = require(path.join(__dirname, 'lib/browser.js'));

// [set, default objectives, the piece the result must hold (null: none asked)]
const CASES = [
  ['sets.midcast.BardSong', ['songPlus', 'songDurPct', 'pdtRed'], null],
  ['sets.midcast.Minuet', ['songPlus', 'songDurPct', 'pdtRed'], 'Fili Hongreline +3'],
  ['sets.midcast.Madrigal', ['songPlus', 'songDurPct', 'pdtRed'], 'Fili Calot +3'],
  ['sets.midcast.March', ['songPlus', 'songDurPct', 'pdtRed'], 'Fili Manchettes +3'],
  ['sets.midcast.HonorMarch', ['songPlus', 'songDurPct', 'pdtRed'], null],
  ['sets.midcast.Etude', ['songPlus', 'songDurPct', 'pdtRed'], 'Mousai Turban +1'],
  ['sets.midcast.Lullaby', ['songAcc', 'songDurPct', 'pdtRed'], null],
  ['sets.midcast.Threnody', ['songAcc', 'songPlus', 'songDurPct'], null],
  ['sets.midcast.DummySong', ['songTimeShort', 'pdtRed', 'mdtRed'], null]];

(async () => {
  const browser = await B.puppeteer.launch({executablePath: B.CHROME, headless: 'new', args: ['--allow-file-access-from-files']});
  const page = await browser.newPage(), errs = [];
  page.on('pageerror', e => errs.push(e.message));
  await page.setViewport({width: 1600, height: 900});
  await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); try { localStorage.clear(); } catch (e) {} });
  await page.goto(process.env.PAGE_URL || 'file:///' + path.resolve(__dirname, '../../atelier/index.html').split(path.sep).join('/'), {waitUntil: 'load'});
  await page.waitForFunction(() => window.__atelier && window.__atelier.loaded && typeof songObjectives === 'function', {timeout: 60000});
  await new Promise(r => setTimeout(r, 5000));
  let bad = 0;
  const fail = m => { bad++; console.log('FAIL ' + m); };
  const inst = await page.evaluate(() => {
    S.char = 'Tetsouo'; S.job = 'BRD'; S.section = 'sets'; render();
    return data().sets.filter(s => /^sets\.midcast\.Songs\./.test(s.path)).map(s => ({path: s.path, stat: statSet(s)}));
  });
  for (const r of inst) if (r.stat) fail(`${r.path} is searched (only its range is worn)`); else console.log(`ok   ${r.path} left to GearSwap`);
  for (const [path, objs, must] of CASES) {
    const r = await page.evaluate(async (path) => {
      const wait = ms => new Promise(res => setTimeout(res, ms));
      S.char = 'Tetsouo'; S.job = 'BRD'; S.section = 'sets'; render();
      S.selPath = Object.assign({}, S.selPath, {BRD: path}); S._found = null; render();
      const s = shownSet(S._cards[S.sel.BRD], S.sel.BRD);
      if (!s || s.path !== path) return {missing: true};
      S.optOpts = Object.assign({}, S.optOpts, {where: 'mine'}); S._optScratch = false;
      const before = statFigures(s, true);
      const objs = statDefault(s), locked = lockedSlots(s), range0 = (withWeapons(s).pieces.range || {}).name || null, ammo0 = (withWeapons(s).pieces.ammo || {}).name || null;
      const res = window.optResult; let got = null;
      window.optResult = function (set, k, o) { got = o; return res.apply(this, arguments); };
      await window.optimizeStats(s);
      for (let n = 0; n < 1500 && S._optBusy; n++) await wait(100);
      window.optResult = res;
      const pieces = got && got.pieces || {}, f = got ? FFXI.opt.statFigures(statContext(s).stat, withVecs(pieces, s)) : null;
      closeOverlay(); render();
      const pick = k => f && {plus: f.songPlus, raw: f.songPlusRaw, lost: f.songLost, pct: f.songDurPct, time: f.songTime, acc: f.songAcc, skill: f.songSkill}[k];
      return {objs, locked, range0, ammo0, ammo1: (pieces.ammo || {}).name || null, floor: (statOpts(s).floor.min || {}).songSkill || 0, range1: (pieces.range || {}).name || null, names: Object.values(pieces).map(p => p && p.name).filter(Boolean),
        before: {plus: before.songPlus, pct: before.songDurPct, time: before.songTime, acc: before.songAcc},
        after: f && {plus: pick('plus'), raw: pick('raw'), lost: pick('lost'), pct: pick('pct'), time: pick('time'), acc: pick('acc'), skill: pick('skill')}};
    }, path);
    if (r.missing) { fail(`${path} not found`); continue; }
    const tag = `${path} ${JSON.stringify(r.before)} -> ${JSON.stringify(r.after)}`;
    if (r.objs.join() !== objs.join()) { fail(`${path} objectives ${r.objs} (want ${objs})`); continue; }
    if (!r.locked.includes('range')) { fail(`${path} range not kept`); continue; }
    if (!r.after) { fail(`${path} no result`); continue; }
    if (r.range0 !== r.range1) { fail(`${path} instrument ${r.range0} -> ${r.range1}`); continue; }
    // an instrument leaves no room for ammo (opt.js O.blocks): the search proposed Aurgelmir Orb +1 with Gjallarhorn
    if (r.ammo0 !== r.ammo1) { fail(`${path} ammo ${r.ammo0} -> ${r.ammo1} with an instrument on`); continue; }
    if (must && !r.names.includes(must)) { fail(`${tag}: ${must} not taken`); continue; }
    if (objs[0] === 'songPlus' && (r.after.plus < r.before.plus || r.after.lost > 0)) { fail(`${tag}: Song+ lost or past its cap`); continue; }
    // a buff song keeps its combined skill at the song's cap (brd_song.js songFloor: Honor March 900, Minuet V 874...)
    if (objs[0] === 'songPlus' && !r.floor) { fail(`${tag}: no skill floor`); continue; }
    if (r.floor && r.after.skill < r.floor) { fail(`${tag}: skill ${r.after.skill} under its floor ${r.floor}`); continue; }
    if (objs[0] === 'songAcc' && r.after.acc < r.before.acc) { fail(`${tag}: song accuracy lost`); continue; }
    if (objs[0] === 'songTimeShort' && r.after.time > r.before.time) { fail(`${tag}: filler song longer`); continue; }
    console.log(`ok   ${tag}${r.floor ? ' (skill floor ' + r.floor + ')' : ''}`);
  }
  if (errs.length) { bad++; console.log('page errors:', errs); }
  console.log(bad ? `${bad} case(s) wrong` : 'every song set searched for its song');
  await browser.close();
  process.exit(bad ? 1 : 0);
})().catch(e => { console.error(e); process.exit(1); });
