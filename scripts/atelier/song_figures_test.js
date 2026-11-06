// Atelier check "song figures": a Bard's song set judged on its song (atelier/opt_song.js O.songFigures, the page's
// app/js/brd_song.js songOf / songBase). Two parts:
//   1. cases worked out by hand from BG Wiki's rules (opt_song.js header): Song+ at its cap, potency, duration with
//      the gift and Troubadour, the combined skill by instrument, a debuff song's landing figure;
//   2. which song each of Tetsouo's BRD sets is judged on, and the figures of its song sets as the page gives them.
//
//   node scripts/atelier/song_figures_test.js      (PAGE_URL: the page to open; else data/atelier/index.html)
//
// @file    scripts/atelier/song_figures_test.js
// @author  ejouanchicot
const path = require('path');
const B = require(path.join(__dirname, 'lib/browser.js'));

const MINUET = {songKind: 'buff', songFam: 'minuet', songCap: 8, songPot: [149, 12.375], songDurBase: 120, songGift: 5,
  songSing: 448, songWind: 448, songString: 448, chr: 100};
const HORN = {songall: 4, sing: 25, wind: 25, instwind: 1}, FILI_BODY = {song_minuet: 1, songdur: 14, sing: 24, wind: 24};
// [what, context, pieces' stats by slot, expected figures]
const CASES = [
  // 5 Song+: 149 + 5 x 12.375; 14 + 50 + 5 = 69 % of 120 s = 202.8 -> 202; Singing 448 + 49, Wind 448 + 49
  ['Minuet, horn + Fili body', MINUET, {range: HORN, body: FILI_BODY},
    {songPlus: 5, songPlusRaw: 5, songLost: 0, songPot: 210.875, songDurPct: 69, songTime: 202, songTimeTroub: 404, songSkill: 994}],
  // 10 Song+ asked, 8 kept: 149 + 99 = 248 (BG Wiki Minuet: 372 under Marcato x 1.5); 14 + 80 + 5 = 99 % -> 238 s
  ['Minuet over its cap', MINUET, {range: HORN, body: FILI_BODY, hands: {song_minuet: 5}},
    {songPlus: 8, songPlusRaw: 10, songLost: 2, songPot: 248, songDurPct: 99, songTime: 238}],
  // a family's Song+ counts only in its own set: the Minuet piece is nothing to the base set (no family)
  ['BardSong ignores Minuet+', Object.assign({}, MINUET, {songFam: null, songCap: null, songPot: null}), {range: HORN, body: FILI_BODY},
    {songPlus: 4, songLost: 0, songPot: 0, songDurPct: 59, songTime: 190}],
  // Honor March: +4 at most
  ['Honor March cap +4', Object.assign({}, MINUET, {songFam: 'march', songCap: 4, songPot: [168, 16]}), {range: HORN, hands: {song_march: 1}},
    {songPlus: 4, songPlusRaw: 5, songLost: 1, songPot: 232}],
  // a harp: Singing + String; no instrument: Singing alone
  ['harp: Singing + String', MINUET, {range: {sing: 20, string: 20, inststring: 1}}, {songSkill: 448 + 20 + 448 + 20}],
  ['no instrument: Singing alone', MINUET, {body: FILI_BODY}, {songSkill: 448 + 24}],
  // no gift under 1200 job points
  ['no gift', Object.assign({}, MINUET, {songGift: 0}), {range: HORN}, {songDurPct: 40, songTime: 168}],
  // Foe Lullaby II: 60 s, BG Wiki's table 84 s at +4 (with the 5 % gift: 87 s); landing CHR + skill + Magic Accuracy
  // a filler song: 120 s base, the shorter the better (songTimeShort); here the horn's All songs +4 lengthens it:
  // 40 % + the 5 % gift -> 174 s
  ['DummySong', Object.assign({}, MINUET, {songKind: 'dummy', songFam: null, songCap: null, songPot: null}), {range: HORN},
    {songPlus: 4, songTime: 174, songTimeShort: -174}],
  ['Lullaby', {songKind: 'debuff', songFam: 'lullaby', songCap: 9, songDurBase: 60, songGift: 5, songSing: 448, songWind: 448, chr: 100},
    {range: HORN, body: {songchr: 40, macc: 50}}, {songPlus: 4, songTime: 87, songSkill: 946, songAcc: 100 + 40 + 946 + 50}]];

(async () => {
  const browser = await B.puppeteer.launch({executablePath: B.CHROME, headless: 'new', args: ['--allow-file-access-from-files']});
  const page = await browser.newPage(), errs = [];
  page.on('pageerror', e => errs.push(e.message));
  await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); try { localStorage.clear(); } catch (e) {} });
  await page.goto(process.env.PAGE_URL || 'file:///' + path.resolve(__dirname, '../../atelier/index.html').split(path.sep).join('/'), {waitUntil: 'load'});
  await page.waitForFunction(() => window.FFXI && FFXI.opt && FFXI.opt.songFigures && typeof songBase === 'function' && typeof CHARS === 'object' && Object.keys(CHARS).length, {timeout: 60000});
  await new Promise(r => setTimeout(r, 3000));
  let bad = 0;
  const got = await page.evaluate(cases => cases.map(([, base, pieces]) => {
    const ps = {};
    for (const [slot, st] of Object.entries(pieces)) ps[slot] = {name: 'test ' + slot, st};
    return FFXI.opt.statFigures({base}, ps);
  }), CASES);
  CASES.forEach(([what, , , want], i) => {
    const diff = Object.keys(want).filter(k => got[i][k] !== want[k]).map(k => `${k} ${got[i][k]} (want ${want[k]})`);
    if (diff.length) bad++;
    console.log(`${diff.length ? 'FAIL' : 'ok  '} ${what}${diff.length ? ': ' + diff.join(', ') : ''}`);
  });
  // a set that is no song set keeps its figures as before: no song figure at all
  const plain = await page.evaluate(() => FFXI.opt.statFigures({base: {}}, {body: {name: 'x', st: {songall: 4}}}).songPlus);
  if (plain !== undefined) { bad++; console.log('FAIL a set with no song has song figures'); } else console.log('ok   a set with no song has no song figure');
  // Tetsouo's BRD sets: the song each is judged on, and its figures
  const rows = await page.evaluate(() => {
    S.char = 'Tetsouo'; S.job = 'BRD'; render();
    return data().sets.filter(s => family(s.path, s.pieces) === 'midcast').map(s => {
      const g = songOf(s), b = songBase(s), f = g ? statFigures(s, true) : null;
      return {path: s.path, g, b: b && {sing: b.songSing, wind: b.songWind, string: b.songString, cap: b.songCap, gift: b.songGift},
        f: f && {plus: f.songPlus, raw: f.songPlusRaw, pot: f.songPot, pct: f.songDurPct, time: f.songTime, skill: f.songSkill, acc: f.songAcc}};
    });
  });
  // what each set must be judged on (the family's name in the set's name)
  const WANT = {'sets.midcast.BardSong': 'buff/', 'sets.midcast.Minuet': 'buff/minuet', 'sets.midcast.Madrigal': 'buff/madrigal',
    'sets.midcast.March': 'buff/march', 'sets.midcast.HonorMarch': 'buff/march', 'sets.midcast.Ballad': 'buff/ballad',
    'sets.midcast.Etude': 'buff/etude', 'sets.midcast.Minne': 'buff/minne', 'sets.midcast.Scherzo': 'buff/scherzo',
    'sets.midcast.Lullaby': 'debuff/lullaby', 'sets.midcast.DebuffSong': 'debuff/', 'sets.midcast.Threnody': 'debuff/threnody',
    'sets.midcast.DummySong': 'dummy/', 'sets.midcast.AriaPassion': 'buff/aria', 'sets.midcast.Dirge': 'buff/dirge'};
  for (const r of rows) {
    const kind = r.g ? r.g.kind + '/' + (r.g.fam || '') : 'none', want = WANT[r.path];
    const ok = want == null || want === kind;
    if (!ok) bad++;
    console.log(`${ok ? 'ok  ' : 'FAIL'} ${r.path} -> ${kind}${want != null && !ok ? ' (want ' + want + ')' : ''}${r.f ? ' ' + JSON.stringify(r.f) : ''}`);
  }
  // the line under the objectives (brd_song.js songNote): the game's song names, every stat of the song, no Song+
  // lost on a song whose potency does not grow (Adventurer's Dirge: All songs still lengthens it)
  const notes = await page.evaluate(() => { S.lang = 'fr'; S.char = 'Tetsouo'; S.job = 'BRD'; render();
    return Object.fromEntries(data().sets.filter(s => songOf(s)).map(s => [s.path, songNote(s)])); });
  for (const [p, want, not] of [['sets.midcast.Minuet', 'Valor Minuet V : Attaque +248', null],
    ['sets.midcast.HonorMarch', 'Honor March : Haste magique +17 % · Attaque +232 · Précision +58', null],
    ['sets.midcast.Dirge', 'Enmity −32', 'perdus'], ['sets.midcast.Lullaby', 'Foe Lullaby II', null]]) {
    const n = notes[p] || '', ok = n.includes(want) && !(not && n.includes(not));
    if (!ok) bad++;
    console.log(`${ok ? 'ok  ' : 'FAIL'} note ${p}${ok ? '' : ': ' + n}`);
  }
  // the result's lines on a song set: the song's and the damage taken only, every objective shown or not (the
  // player, 2026-11-05: "Soin du Cure etc on s'en fiche complètement")
  const lines = await page.evaluate(() => { S.char = 'Tetsouo'; S.job = 'BRD'; render();
    const s = data().sets.find(x => x.path === 'sets.midcast.Minuet');
    return statRows(s).map(r => r.id); });
  const allowed = new Set(['songPlus', 'songPot', 'songDurPct', 'songTime', 'songTimeShort', 'songSkill', 'songAcc', 'pdtRed', 'mdtRed', 'hp', 'pdt', 'mdt']);
  const extra = lines.filter(k => !allowed.has(k));
  if (extra.length) { bad++; console.log('FAIL Minuet result lines not about the song: ' + extra.join(', ')); } else console.log('ok   Minuet result lines: ' + lines.join(', '));
  // a luopan's lines only on a GEO, a pet's on a job with a pet, Charm's on a BST, the songs' on a BRD (stat_opt.js
  // statJobOk: the player, 2026-11-05)
  const byJob = await page.evaluate(() => Object.fromEntries(['BRD', 'WAR', 'GEO', 'BST'].map(j => { S.char = 'Tetsouo'; S.job = j; render();
    const s = data().sets.find(x => statSet(x) && family(x.path, x.pieces) === 'idle');
    return [j, s ? statRows(s).map(r => r.id) : []]; })));
  const JOB_LINES = {BRD: [/^lu|^geo/, /^pet|^charm|^chr$|^macc$/], WAR: [/^lu|^geo/, /^pet|^charm|^chr$|^macc$/, /^song/],
    GEO: [/^pet|^charm|^chr$|^macc$/, /^song/], BST: [/^lu|^geo/, /^song/]};
  for (const [j, res] of Object.entries(JOB_LINES)) {
    const wrong = byJob[j].filter(k => res.some(re => re.test(k)));
    if (wrong.length) { bad++; console.log(`FAIL ${j} idle shows ${wrong.join(', ')}`); } else console.log(`ok   ${j} idle: no line of another job's`);
  }
  const b0 = (rows.find(r => r.b) || {}).b;
  console.log('Tetsouo without gear:', JSON.stringify(b0));
  // the export's 473 Singing and Wind count Gjallarhorn's +25, worn when it was taken: 448 each without gear
  if (!b0 || b0.sing !== 448 || b0.wind !== 448 || b0.string !== 448) { bad++; console.log('FAIL Tetsouo skills without gear (want 448 each)'); }
  if (errs.length) console.log('page errors:', errs);
  console.log(bad || errs.length ? `${bad} case(s) wrong` : 'all song figures as expected');
  await browser.close();
  process.exit(bad || errs.length ? 1 : 0);
})().catch(e => { console.error(e); process.exit(1); });
