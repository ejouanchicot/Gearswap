// Atelier check "engine free": the figure the page shows for every set of every character, job and exported subjob
// (stats, Cure, enhancing, weaponskill, attack round, nuke), how many times our engine handed a case to the old one
// (FFXI.engine.fell) and why, and the result of a fixed sample of optimizer searches. Saved once as the reference
// (--save), then compared (--compare) after each step of notes/docs-perso/moteur-sans-wsdist-2026-10-22/SPEC.md.
//
//   node scripts/atelier/engine_free_check.js <mode> [--save f.json] [--compare f.json] [--only Char/JOB] [--no-search]
//   mode  ref     the page as it is, both engines loaded
//         noold   the old engine's code blocked (atelier/engine/ but a catalog/ left in it, and cycle.js)
//         noengine  all of atelier/engine/ blocked, and cycle.js: what the page meets when the folder is gone
//         (the gear catalogue is atelier/gear/ since 2026-10-22: neither mode blocks it)
//         absent  atelier/engine/ really gone: renamed to engine.__off for the run, then put back (also after a
//                 Ctrl+C, and by the next run when one was killed half way)
//
// The searches run on the page with FFXI.opt.run, one after the other: the page's own workers split the walks by the
// machine's cores and stop waiting for the shuffled ones on a clock (app/js/optimizer.js optWalks, optLaunch), so
// they are not the same twice. The worker path is checked by hand at the end of the work (SPEC, end-to-end check 2).
//
// PAGE_URL: the page to open; else data/atelier/index.html.
//
// @file    scripts/atelier/engine_free_check.js
// @author  ejouanchicot
const path = require('path'), fs = require('fs'), os = require('os'), crypto = require('crypto');
const puppeteer = require(process.env.PUPPETEER || path.join(process.env.APPDATA || '', 'npm/node_modules/@modelcontextprotocol/server-puppeteer/node_modules/puppeteer'));
const CHROME = process.env.CHROME || 'C:/Program Files/Google/Chrome/Application/chrome.exe';
const ATELIER = path.resolve(__dirname, '../../atelier');
const ENGINE = path.join(ATELIER, 'engine'), ENGINE_OFF = path.join(ATELIER, 'engine.__off');

const args = process.argv.slice(2), mode = args[0];
const opt = k => args.includes(k) ? args[args.indexOf(k) + 1] : null;
const saveTo = opt('--save'), compareTo = opt('--compare'), only = opt('--only'), noSearch = args.includes('--no-search');
if (!['ref', 'noold', 'noengine', 'absent'].includes(mode) || (!saveTo && !compareTo)) {
  console.log('usage: <ref|noold|noengine|absent> [--save f.json] [--compare f.json] [--only Char/JOB] [--no-search]'); process.exit(2);
}
const BLOCK = mode === 'noold' ? /\/atelier\/(engine\/(?!catalog\/)|cycle\.js)/ : mode === 'noengine' ? /\/atelier\/(engine\/|cycle\.js)/ : null;
// the characters whose sets are searched (the ones with an export from the game: the others have no base attributes)
const SEARCHED = ['Tetsouo', 'Kaories'];

/* ---- absent: the folder moved aside, with a pid file so a killed run is put back by the next one ---- */
const LOCK = path.join(os.tmpdir(), 'gs_engine_free_check.pid');
const alive = pid => { try { process.kill(pid, 0); return true; } catch (e) { return e.code === 'EPERM'; } };
function putBack(){
  if (fs.existsSync(ENGINE_OFF) && !fs.existsSync(ENGINE)) fs.renameSync(ENGINE_OFF, ENGINE);
  fs.rmSync(LOCK, {force: true});
}
function recover(){
  if (fs.existsSync(LOCK)) {
    const pid = +fs.readFileSync(LOCK, 'utf8');
    if (pid !== process.pid && alive(pid)) { console.log(`another run (pid ${pid}) has atelier/engine moved aside: wait for it`); process.exit(2); }
    if (fs.existsSync(ENGINE_OFF)) console.log('atelier/engine put back from a run that stopped half way');
    putBack();
  }
  if (fs.existsSync(ENGINE_OFF)) { console.log('atelier/engine.__off exists with no run behind it: look at it by hand'); process.exit(2); }
}
function moveAside(){
  if (!fs.existsSync(ENGINE)) { console.log('atelier/engine is missing: nothing to move aside'); process.exit(2); }
  fs.writeFileSync(LOCK, String(process.pid));
  try { fs.renameSync(ENGINE, ENGINE_OFF); } catch (e) {
    fs.rmSync(LOCK, {force: true});
    // Windows refuses to rename a folder a program holds open (an editor's file watcher, an Explorer window)
    console.log(`atelier/engine cannot be moved aside (${e.code}): a program holds it open; close it, or use the mode "noengine"`);
    process.exit(2);
  }
}
recover();
if (mode === 'absent') {
  process.on('SIGINT', () => { putBack(); console.log('atelier/engine put back'); process.exit(130); });
  moveAside();
}

/* ---- in the page ---- */
// The page's state for the bench: every figure read the way the page shows it, nothing tried on
function pageSetup(){
  S.optOpts = Object.assign({}, S.optOpts, {where: 'mine'});
  S.trial = {};
}
// Every set of one character and job, every exported subjob: its kind and figure, and what fell to the old engine
function pageSets(c, j){
  const round = v => typeof v === 'number' ? Math.round(v * 1000) / 1000 : v;
  const scalars = o => { const out = {}; if (!o || typeof o !== 'object') return out;
    for (const k of Object.keys(o).sort()) if (o[k] == null || ['number', 'string', 'boolean'].includes(typeof o[k])) out[k] = round(o[k]); return out; };
  const fellNow = () => Object.assign({}, (window.FFXI && FFXI.engine && FFXI.engine.fell) || {});
  const fellSince = before => { const now = fellNow(), out = {}; for (const k of Object.keys(now)) if (now[k] > (before[k] || 0)) out[k] = now[k] - (before[k] || 0); return out; };
  const err = e => ({err: String(e && e.message || e).slice(0, 160)});
  const res = {};
  for (const sub of Object.keys(exportsOf(c, j)).sort()) {
    S.char = c; S.job = j; S.subs[c + '|' + j] = sub; S._bypath = null;
    try { render(); } catch (e) {}
    const d = data();
    if (!d || !d.sets) continue;
    for (const s of d.sets) {
      const fam = family(s.path, s.pieces);
      const kind = fam === 'ws' ? 'ws' : isNukeSet(s.path) ? 'nuke' : isJumpSet(s.path) ? 'jump' : roundSet(s) ? 'eng' : statSet(s) ? 'stat' : 'none';
      const row = {fam, kind};
      if (kind === 'stat') row.sort = cardFamily(s.path, s.pieces) === 'cure' ? 'cure' : enhContext(s) ? 'enh' : 'stat';
      const before = fellNow();
      try {
        if (kind === 'ws') {
          row.ws = wsOfSet(s) || null;
          row.shown = round(wsDamage(s));
          const r = engineReady() ? FFXI.opt.ws(optContext(s), optPieces(withoutTrial(() => withWeapons(s).pieces)), +(S.wsTp || 3000)) : null;
          row.fig = r ? (r[1] || []).filter(x => typeof x === 'number').map(round) : null;
        } else if (kind === 'nuke') {
          const f = fightFigures(s);
          row.fig = f && f.r ? scalars({damage: f.r.damage, unresisted: f.r.unresisted, hitRate: f.r.hitRate, macc: f.r.macc}) : null;
          if (f && f.fell && f.fell.length) row.nukeFell = f.fell.slice().sort();
        } else if (kind === 'eng' || kind === 'jump') {
          const r = engRound(s, true);
          row.fig = r ? scalars({time: r.time, real: r.real && r.real.time, dps: r.dps, tp: r.tp, damage: r.damage}) : null;
        } else if (kind === 'stat') {
          row.fig = scalars(statFigures(s, true));
          const main = statRows(s)[0];
          row.main = main ? main.id : null;
        }
      } catch (e) { row.fig = err(e); }
      const fell = fellSince(before);
      if (Object.keys(fell).length) row.fell = fell;
      res[`${c}|${j}|${sub}|${s.path}`] = row;
    }
  }
  return res;
}
// The search of one set, the way its button builds it (app/js/optimizer.js, stat_opt.js), run on the page
function pageSearch(c, j, sub, p, kind){
  S.char = c; S.job = j; S.subs[c + '|' + j] = sub; S._bypath = null;
  try { render(); } catch (e) {}
  const s = data().sets.find(x => x.path === p), o = S.optOpts || {};
  const round = v => typeof v === 'number' ? Math.round(v * 1000) / 1000 : v;
  if (!engineReady()) return {err: 'engine not ready'};
  try {
    const base = lockedBase(s, withoutTrial(() => withWeapons(s).pieces));
    const keep = new Set(Object.keys(ONLY_AUGS)), fast = (o.search || 'fast') !== 'classic';
    let input;
    if (kind === 'stat') {
      const so = statOpts(s), choices = optChoices(keep);
      for (const slot of keptSlots(s)) delete choices[slot];
      lockChoices(s, choices);
      for (const slot of Object.keys(choices)) choices[slot] = choices[slot].map(q => withVec(q, slot));
      input = {ctx: statContext(s), start: withVecs(startOf(base, lockedSlots(s))), choices, prefilter: 0,
        opts: {fast, objective: so.objs[0], then: so.objs.slice(1), floor: so.floor}};
      enhPotencyFirst(s, input, so);
    } else if (kind === 'ws') {
      const ws = wsOfSet(s) || segs(s.path).pop();
      if (!FFXI.opt.defineWs(ws, wsInfoOf(ws), wsSkills()[ws])) return {err: 'no ws ' + ws};
      const wsBase = lockedBase(s, withoutTrial(() => { S._noTpGear = true; try { return withWeapons(s).pieces; } finally { S._noTpGear = false; } }));
      const r = tpAsk(s, wsBase, null), tpNames = new Set(((r && r.piece_list) || []).map(q => q.name).concat(Object.keys(ONLY_AUGS)));
      input = {ctx: optContextInput(s), start: startOf(wsBase, lockedSlots(s)), choices: lockChoices(s, optChoices(tpNames)), prefilter: 0,
        opts: {fast, tp: +(S.wsTp || 3000), tps: avgTps(o), tpRule: tpRuleOf(r), objective: o.obj || 'damage', floor: {pdt: +o.pdt || 0, mdt: +o.mdt || 0, sb: +o.sb || 0, hit: +o.hit || 0}}};
    } else if (kind === 'eng') {
      const e = engOpts(s);
      input = {ctx: engContextInput(s), start: startOf(base, lockedSlots(s)), choices: lockChoices(s, optChoices(keep)), prefilter: 0,
        opts: {fast, objective: e.engObj || 'tp_real', wsAt: +e.engAt || 1000, floor: {pdt: +e.pdt || 0, mdt: +e.mdt || 0, sb: +e.sb || 0}}};
    } else {
      const choices = lockChoices(s, optChoices(keep));
      for (const slot of nukeSituation(s).fixed) delete choices[slot];
      input = {ctx: nukeContextInput(s), start: startOf(base, lockedSlots(s)), choices, prefilter: 0, opts: {fast, objective: 'nuke', floor: {}}};
    }
    const r = FFXI.opt.run(input), pieces = {};
    for (const slot of Object.keys(r.pieces || {}).sort()) pieces[slot] = r.pieces[slot] && r.pieces[slot].name;
    return {best: round(r.best && r.best.raw), start: round(r.start && r.start.raw), score: round(r.score), pieces};
  } catch (e) { return {err: String(e && e.message || e).slice(0, 160)}; }
}

/* ---- the run ---- */
// index.js and every export file it lists: the game rewrites an export when the job loads, index.js can stay the same
const fingerprint = () => { const f = path.join(ATELIER, 'index.js');
  if (!fs.existsSync(f)) return null;
  const index = fs.readFileSync(f), hash = crypto.createHash('sha1').update(index);
  const files = [...new Set((String(index).match(/"file":"[^"]+"/g) || []).map(m => m.slice(8, -1)))].sort();
  for (const rel of files) { const p = path.join(ATELIER, '..', rel); hash.update(rel).update(fs.existsSync(p) ? fs.readFileSync(p) : ''); }
  return hash.digest('hex').slice(0, 12); };

async function snapshot(){
  const t0 = Date.now(), exportsAtStart = fingerprint();
  const browser = await puppeteer.launch({executablePath: CHROME, headless: 'new', protocolTimeout: 0, args: ['--allow-file-access-from-files']});
  const page = await browser.newPage(), errors = [], blocked = new Set();
  page.setDefaultTimeout(0);
  if (BLOCK) { await page.setRequestInterception(true);
    page.on('request', r => { if (BLOCK.test(r.url())) { blocked.add(r.url().replace(/.*atelier\//, '').replace(/\?.*/, '')); r.abort(); } else r.continue(); }); }
  page.on('pageerror', e => errors.push(e.message.slice(0, 200)));
  page.on('console', m => { if (m.type() === 'error' && !/Failed to load resource/.test(m.text())) errors.push('console: ' + m.text().slice(0, 200)); });
  await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); try { localStorage.clear(); localStorage.setItem('atelier', JSON.stringify({guide: {mode: 'off', seen: {tour: true}}})); } catch (e) {} });
  await page.goto(process.env.PAGE_URL || 'file:///' + path.join(ATELIER, 'index.html').split(path.sep).join('/') + '?nolive', {waitUntil: 'load'});
  await page.waitForFunction(() => window.__atelier && window.__atelier.loaded && typeof CHARS === 'object' && Object.keys(CHARS).length, {timeout: 60000});
  // the engine loads 300 ms after the exports (app/js/events.js loadRanked); without the old one it never gets ready
  await page.waitForFunction(() => engineReady(), {timeout: mode === 'ref' ? 60000 : 15000}).catch(() => {});
  await new Promise(r => setTimeout(r, 2000));
  const engine = await page.evaluate(() => ({ready: engineReady(), name: engineName(), partErr: S._engPartErr || null,
    has: Object.fromEntries(['CATALOG', 'RANKED', 'aggregate_buffs', 'make_enemy', 'WS', 'player_data', 'average_ws', 'opt'].map(k => [k, !!(window.FFXI && FFXI[k])]))}));
  await page.evaluate(pageSetup);
  await page.evaluate(`window.__bench = {sets: ${pageSets.toString()}, search: ${pageSearch.toString()}}`);
  const chars = await page.evaluate(() => Object.keys(CHARS).sort().map(c => [c, CHARS[c].jobs.slice().sort()]));
  const sets = {};
  for (const [c, jobs] of chars) for (const j of jobs) {
    if (only && only !== c + '/' + j && only !== c) continue;
    Object.assign(sets, await page.evaluate((c, j) => __bench.sets(c, j), c, j));
    process.stderr.write(`\r${c}/${j}      `);
  }
  process.stderr.write('\n');
  // the sample: the first set of each sort, each job of the characters played, its first exported subjob
  const searches = {};
  if (!noSearch) {
    const firsts = {};
    for (const [key, row] of Object.entries(sets)) {
      const [c, j, sub, p] = key.split('|');
      const sort = row.kind === 'stat' ? row.sort : row.kind === 'jump' ? null : row.kind;
      // a weaponskill set for no weaponskill in particular (sets.precast.WS) is worked out by neither engine
      if (!SEARCHED.includes(c) || !sort || sort === 'none' || (sort === 'ws' && !row.ws)) continue;
      const id = `${c}|${j}|${sort}`;
      if (!firsts[id]) firsts[id] = [c, j, sub, p, row.kind === 'stat' ? 'stat' : row.kind];
    }
    // compared with a reference: its own sample, whatever this run's sets
    const ref = compareTo ? JSON.parse(fs.readFileSync(compareTo, 'utf8')).searches : null;
    if (ref) for (const id of Object.keys(firsts)) delete firsts[id];
    for (const key of Object.keys(ref || {})) { const [c, j, sort, sub, ...p] = key.split('|');
      firsts[`${c}|${j}|${sort}`] = [c, j, sub, p.join('|'), ['cure', 'enh'].includes(sort) ? 'stat' : sort]; }
    for (const id of Object.keys(firsts).sort()) {
      const [c, j, sub, p, kind] = firsts[id];
      process.stderr.write(`\rsearch ${id}      `);
      searches[`${id}|${sub}|${p}`] = await page.evaluate((...a) => __bench.search(...a), c, j, sub, p, kind);
    }
    process.stderr.write('\n');
  }
  await browser.close();
  // the game rewrites an export when a job loads: one rewritten during the run leaves the run with both
  const exports = fingerprint();
  return {mode, at: new Date().toISOString(), exports: exports === exportsAtStart ? exports : exportsAtStart + '>' + exports, engine, blocked: [...blocked].sort(), errors, seconds: Math.round((Date.now() - t0) / 1000), sets, searches};
}

function summary(snap){
  const count = {}, fell = {}, errs = {};
  for (const [key, row] of Object.entries(snap.sets)) {
    const c = key.split('|')[0], sort = row.kind === 'stat' ? row.sort : row.kind;
    count[sort] = count[sort] || {}; count[sort][c] = (count[sort][c] || 0) + 1;
    for (const k of Object.keys(row.fell || {})) { const kk = /^base attributes/.test(k) ? 'base attributes unknown' : k; fell[kk] = fell[kk] || {}; fell[kk][c] = (fell[kk][c] || 0) + 1; }
    if (row.fig && row.fig.err) { const e = sort + ': ' + row.fig.err.slice(0, 70); errs[e] = (errs[e] || 0) + 1; }
  }
  const line = o => Object.entries(o).map(([k, v]) => `${k} ${v}`).join(', ');
  const total = o => Object.values(o).reduce((a, b) => a + b, 0);
  console.log(`mode ${snap.mode}, ${snap.seconds} s, exports ${snap.exports}; engine ${JSON.stringify(snap.engine)}`);
  if (snap.exports.includes('>')) console.log('WARNING: an export was rewritten during this run (the game loaded a job): run it again');
  if (snap.blocked.length) console.log(`blocked: ${snap.blocked.join(' ')}`);
  console.log('sets by sort:'); for (const k of Object.keys(count).sort()) console.log(`  ${k} ${total(count[k])} (${line(count[k])})`);
  console.log('handed to the old engine (sets):'); for (const k of Object.keys(fell).sort()) console.log(`  ${k}: ${total(fell[k])} (${line(fell[k])})`);
  if (Object.keys(errs).length) { console.log('figures not worked out:'); for (const k of Object.keys(errs).sort()) console.log(`  ${errs[k]} × ${k}`); }
  const se = Object.values(snap.searches), bad = se.filter(r => r.err);
  if (se.length) console.log(`searches: ${se.length}, ${bad.length} failed${bad.length ? ' (' + [...new Set(bad.map(r => r.err))].slice(0, 4).join(' | ') + ')' : ''}`);
  console.log(`page errors: ${snap.errors.length}${snap.errors.length ? ' — ' + snap.errors.slice(0, 3).join(' | ') : ''}`);
}

function compare(was, now){
  if (was.exports !== now.exports) console.log(`WARNING: the exports changed since the reference (${was.exports} -> ${now.exports}): set by set differences may be theirs`);
  const lines = [];
  let same = 0, all = 0;
  const diff = (part, a, b) => {
    for (const key of [...new Set([...Object.keys(a), ...Object.keys(b)])].sort()) {
      if (only && !key.startsWith(only.replace('/', '|'))) continue;
      all++;
      const x = a[key], y = b[key];
      if (!x || !y) { lines.push(`${x ? 'gone' : 'new '} ${part} ${key}`); continue; }
      const out = [];
      for (const k of new Set([...Object.keys(x), ...Object.keys(y)])) { const p = JSON.stringify(x[k]), q = JSON.stringify(y[k]); if (p !== q) out.push(`${k} ${p} -> ${q}`); }
      if (!out.length) { same++; continue; }
      lines.push(`changed ${part} ${key}\n    ${out.join('\n    ')}`);
    }
  };
  diff('set', was.sets, now.sets);
  diff('search', was.searches || {}, now.searches || {});
  if (lines.length) console.log(lines.join('\n'));
  console.log(`${same}/${all} identical`);
  return same === all;
}

(async () => {
  let snap;
  try { snap = await snapshot(); } finally { if (mode === 'absent') putBack(); }
  summary(snap);
  if (saveTo) { fs.mkdirSync(path.dirname(path.resolve(saveTo)), {recursive: true}); fs.writeFileSync(saveTo, JSON.stringify(snap, null, 1)); console.log(`saved ${Object.keys(snap.sets).length} sets, ${Object.keys(snap.searches).length} searches to ${saveTo}`); }
  if (compareTo) process.exit(compare(JSON.parse(fs.readFileSync(compareTo, 'utf8')), snap) ? 0 : 1);
})().catch(e => { if (mode === 'absent') putBack(); console.error(e); process.exit(1); });
