// Atelier check "song pieces": what the stats optimizer reads of a Bard's song pieces (atelier/app/js/brd_song.js
// songVec, through stat_opt.js statVec), against the game's own text and BG Wiki's Category:Song duration table
// (read 2026-11-05; notes/docs-perso/chants-brd-2026-11-05/SPEC.md §5). Every key listed must hold its value; a key
// not listed must be absent (songall, song_*, songdur, songrecast, songextra, sing, wind, string).
//
//   node scripts/atelier/song_read_test.js      (PAGE_URL: the page to open; else data/atelier/index.html)
//
// @file    scripts/atelier/song_read_test.js
// @author  ejouanchicot
const path = require('path');
const B = require(path.join(__dirname, 'lib/browser.js'));

// [piece, slot, item id or null (the page's own choice), expected song keys]
const CASES = [
  ['Fili Calot +3', 'head', null, {song_madrigal: 1}],
  ['Fili Hongreline +3', 'body', null, {song_minuet: 1, songdur: 14, sing: 24, wind: 24}],
  ['Fili Manchettes +3', 'hands', null, {song_march: 1, sing: 22, wind: 22, string: 22}],
  ['Fili Rhingrave +3', 'legs', null, {song_ballad: 1, songrecast: -10, sing: 28}],
  ['Fili Cothurnes +3', 'feet', null, {song_scherzo: 1}],
  // "Right ear: Singing skill +12": in the right ear only (ear2)
  ['Fili Earring +2', 'ear2', null, {sing: 12}],
  ['Fili Earring +2', 'ear1', null, {}],
  ['Mousai Turban +1', 'head', null, {song_etude: 2}],
  ['Mousai Seraweels', 'legs', null, {song_minne: 1}],
  ['Mousai Gages +1', 'hands', null, {song_carol: 2}],
  ['Mousai Crackows', 'feet', null, {song_mambo: 1}],
  ['Mousai Manteel', 'body', null, {song_threnody: 1}],
  // "Song duration +15%": the other wording
  ['Brioso Slippers +4', 'feet', null, {songdur: 15, wind: 15}],
  ['Brioso Roundlet +4', 'head', null, {song_paeon: 2, string: 14}],
  ['Inyanga Shalwar +2', 'legs', null, {songdur: 17}],
  ['Gjallarhorn', 'range', null, {songall: 4, sing: 25, wind: 25}],
  ['Marsyas', 'range', null, {songdur: 50}],
  ['Nibiru Harp', 'range', null, {song_carol: 2}],
  ['Moonbow Whistle', 'range', null, {songall: 2}],
  ['Linos', 'range', null, {songall: 1}],
  ['Terpander', 'range', null, {songextra: 1}],
  ['Loughnashade', 'range', 22307, {songall: 4, songextra: 2}],
  // the duration of a text without figure: Category:Song's table
  ['Daurdabla', 'range', 18575, {songdur: 25, sing: 20, string: 20, songextra: 1}],
  ['Daurdabla', 'range', 18576, {songdur: 30, sing: 20, string: 20, songextra: 1}],
  ['Daurdabla', 'range', 18839, {songdur: 30, sing: 20, string: 20, songextra: 2}],
  ['Carnwenhan', 'main', 19000, {songdur: 10}],
  ['Carnwenhan', 'main', 19069, {songdur: 20}],
  ['Carnwenhan', 'main', 19621, {songdur: 40}],
  ['Carnwenhan', 'main', 19719, {songdur: 40}],
  ['Carnwenhan', 'main', 20586, {songdur: 50}],
  ["Aoidos' Matinee", 'neck', null, {songdur: 10}],
  ['Mdk. Shalwar +1', 'legs', null, {songdur: 10, wind: 11}],
  ['Mdk. Dastanas +1', 'hands', null, {wind: 11}],
  ['Legato Dagger', 'main', null, {songdur: 5}],
  ['Kali', 'main', null, {songdur: 5, sing: 10, wind: 10, string: 10}],
  ["Intarabus's Cape", 'back', null, {song_madrigal: 1, song_prelude: 1}]];
const SONG_KEY = /^(songall|song_\w+|songdur|songrecast|songextra|sing|wind|string)$/;

(async () => {
  const browser = await B.puppeteer.launch({executablePath: B.CHROME, headless: 'new', args: ['--allow-file-access-from-files']});
  const page = await browser.newPage(), errs = [];
  page.on('pageerror', e => errs.push(e.message));
  await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); try { localStorage.clear(); } catch (e) {} });
  await page.goto(process.env.PAGE_URL || 'file:///' + path.resolve(__dirname, '../../atelier/index.html').split(path.sep).join('/'), {waitUntil: 'load'});
  await page.waitForFunction(() => typeof statVec === 'function' && typeof songVec === 'function' && typeof CHARS === 'object' && Object.keys(CHARS).length, {timeout: 60000});
  await new Promise(r => setTimeout(r, 3000));
  const got = await page.evaluate(cases => {
    S.char = 'Tetsouo'; S.job = 'BRD'; render();
    return cases.map(([name, slot, id]) => statVec(id ? {name, id} : {name}, slot));
  }, CASES);
  let bad = 0;
  CASES.forEach(([name, slot, id, want], i) => {
    const mine = Object.fromEntries(Object.entries(got[i] || {}).filter(([k]) => SONG_KEY.test(k)));
    const keys = new Set([...Object.keys(mine), ...Object.keys(want)]);
    const diff = [...keys].filter(k => mine[k] !== want[k]).map(k => `${k} ${mine[k]} (want ${want[k]})`);
    if (diff.length) bad++;
    console.log(`${diff.length ? 'FAIL' : 'ok  '} ${name}${id ? ' #' + id : ''} ${slot}${diff.length ? ': ' + diff.join(', ') : ''}`);
  });
  if (errs.length) console.log('page errors:', errs);
  console.log(bad || errs.length ? `${bad} case(s) wrong` : `${CASES.length} cases, all read as the game writes them`);
  await browser.close();
  process.exit(bad || errs.length ? 1 : 0);
})().catch(e => { console.error(e); process.exit(1); });
