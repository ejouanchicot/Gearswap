// GearSwap Atelier · tp_table.js: the TP pieces worth putting on before a weaponskill, worked out with the engine
// (loaded in the order of atelier/src/legacy/files.ts, after ws_page.js)
//
// The fTP of a weaponskill rises in a straight line between 1000, 2000 and 3000 TP and a TP Bonus counts as that much
// more TP (measured in game 2026-11-11/12: notes/docs-perso/moonshade-ftp-2026-11-11/SPEC.md). A TP piece is worth
// what the weaponskill gains with it, against the set piece it replaces: FFXI.opt.tpBest (atelier/opt.js) tries every
// combination of the job's TP pieces (<JOB>_TP_CONFIG.lua, the export's tp_rule) and keeps the one with the most
// damage, none when none beats the set alone.
//
//   tpTableAfterExport(c, d)   a new export of the job shown came in, or the buffs ticked in the page changed
//                              (tpTableWatch): the table worked out again and written to
//                              <Char>/atelier/overrides/tp_pieces_<JOB>.lua when it changed, one file a job (the game
//                              reads only its job's, before each weaponskill: shared/utils/weaponskill/tp_pieces_table.lua,
//                              tp_piece_decision.lua). Worked out with the buffs ticked in the page (the player's
//                              choice, 2026-11-14): ticking others works it out again.
//                              A set the engine cannot work out (a ranged weaponskill, an fTP unknown) is skipped and
//                              named in the toast; the job's other sets are still written
//   tpStepsTable(s)            the TP where the pieces put on change, for the weaponskill page's chips (S._tpWhy)
//   tpBestGear(s, pieces, tp)  the pieces put on at that TP, {slot: name}, as the game will
//
// The table's TP is the TP shown plus the buffs' TP Bonus (Warcry): the weapon's and Fencer's are in the engine's
// figures for that weapon, so the page's own Warcry is left out of the engine here.
//
// @file    atelier/app/js/tp_table.js
// @author  ejouanchicot
// version 2: segments (the TP where the pieces change) in place of a row every 50 TP (version 1: 334 KB for a WAR)
const TP_TABLE = {from: 1000, step: 50, to: 3000, version: 2};
let TP_TABLE_BUSY = false;
// the tables the game refused (a body over its limit, a write error): not sent again until they change
const TP_TABLE_FAILED = {};
const TP_STEPS_MEMO = {};
// The last table written this session, by character and job: {at, skipped} (the weaponskill head shows it, tpTableStatus)
const TP_TABLE_STATUS = {};

// The job's TP pieces (the export's tp_rule), as FFXI.opt.tpBest reads them, or null
function tpTableRule(){
  const r = (data() || {}).tp_rule;
  return r && Array.isArray(r.piece_list) && r.piece_list.length ? {pieces: r.piece_list} : null;
}
// The engine's context for a set, without the page's own Warcry TP Bonus (in game it moves the table's row)
function tpTableCtx(s){
  const inp = optContextInput(s);
  inp.ownWarcryTp = 0; inp.partyWarcry = null;
  return FFXI.opt.context(inp);
}
// The set's pieces with its weapons, before any TP piece
function tpNoGear(fn){ const was = S._noTpGear; S._noTpGear = true; try { return fn(); } finally { S._noTpGear = was; } }
// The hands a weaponskill set is worked out with: the ones the page shows, then each weapon of the job's weapon
// modes that opens the weaponskill (its set's main and off hand), one per main weapon
function tpTableHands(s){
  const d = data(), ws = wsOfSet(s), base = tpNoGear(() => withWeapons(s).pieces), all = [base];
  for (const m of weaponModes(d)) if (isMainMode(m)) for (const v of m.values || []) {
    if (m.sets && m.sets[v] && wsWeaponFits(m, v, ws)) all.push(Object.assign({}, base, m.sets[v].pieces));
  }
  const seen = new Set();
  return all.filter(p => { const n = p.main && !isEmpty(p.main) ? p.main.name : ''; if (!n || seen.has(n)) return false; seen.add(n); return true; });
}
// One row a step of TP: the pieces worth it ({slot: name}, {} for none) and what they add (0.17 = +17 %)
function tpTableRows(s, pieces, rule){
  const ctx = tpTableCtx(s), p = optPieces(pieces), rows = [];
  for (let tp = TP_TABLE.from; tp <= TP_TABLE.to; tp += TP_TABLE.step) {
    const b = FFXI.opt.tpBest(ctx, p, tp, rule);
    rows.push({p: Object.fromEntries(Object.entries(b.add).map(([k, v]) => [k, v.name])), g: Math.round(b.gain * 10000) / 10000});
  }
  return rows;
}
// The rows as written for the game: one segment where the pieces change, from its TP to the next one's
// ({tp, p, g}: g = what its pieces add at its first TP)
function tpSegments(rows){
  const out = [];
  rows.forEach((r, i) => {
    const prev = out[out.length - 1];
    if (!prev || JSON.stringify(prev.p) !== JSON.stringify(r.p)) out.push({tp: TP_TABLE.from + i * TP_TABLE.step, p: r.p, g: r.g});
  });
  return out;
}
// The set's own armor as GearSwap puts it on (the game uses a variant only while this is what it wears)
function tpTableSetOf(s){
  const out = {};
  for (const slot of SLOTS) if (!WEAPON_SLOTS.has(slot) || slot === 'ammo') { const p = s.pieces[slot]; if (p && p.name) out[slot] = p.name; }
  return out;
}
// The weaponskill sets of the job shown, each with its hands
function tpTableInputs(){
  const d = data();
  return d ? d.sets.filter(s => s.pieces && family(s.path, s.pieces) === 'ws' && wsOfSet(s))
    .map(s => ({s, ws: wsOfSet(s), hands: tpTableHands(s)})) : [];
}
// The buffs ticked in the page, as the table depends on them
function tpTableBuffs(){ try { return JSON.stringify(buffState()); } catch (e) { return ''; } }
// What the table depends on: when it is the same as the one written, nothing is written. The buffs ticked are in
// it: other buffs, another table (audit 2026-11-14 P2-2: before, the first buffs stayed for good)
function tpTableSig(inputs, rule){
  const ctx = (() => { try { const i = optContextInput(inputs[0].s); return [i.enemy, i.sub, i.ml, JSON.stringify(i.base || null), tpTableBuffs()]; } catch (e) { return []; } })();
  const text = JSON.stringify([TP_TABLE.version, rule.pieces, ctx, inputs.map(x => [x.s.path, tpTableSetOf(x.s), x.hands.map(h => [h.main && h.main.name, h.sub && h.sub.name])])]);
  let h = 0;
  for (let i = 0; i < text.length; i++) h = (h * 31 + text.charCodeAt(i)) | 0;
  return (h >>> 0).toString(16);
}
// A Lua value written as data (shared/utils/core/lua_data.lua reads it back)
function tpLuaVal(v, pad){
  if (v == null) return 'nil';
  if (typeof v === 'number') return String(v);
  if (typeof v === 'boolean') return v ? 'true' : 'false';
  if (typeof v === 'string') return luaStr(v);
  const inner = pad + '    ';
  if (Array.isArray(v)) return v.length ? '{\n' + v.map(x => inner + tpLuaVal(x, inner) + ',').join('\n') + '\n' + pad + '}' : '{}';
  const keys = Object.keys(v).sort();
  if (!keys.length) return '{}';
  const key = k => /^[A-Za-z_]\w*$/.test(k) ? k : '[' + luaStr(k) + ']';
  // a segment, and a table of plain values (a set, a segment's pieces): on one line
  if ('p' in v && 'g' in v) return '{tp = ' + v.tp + ', p = ' + tpLuaVal(v.p, '') + ', g = ' + v.g + '}';
  if (keys.every(k => typeof v[k] !== 'object' || v[k] === null)) return '{' + keys.map(k => key(k) + ' = ' + tpLuaVal(v[k], '')).join(', ') + '}';
  return '{\n' + keys.map(k => inner + key(k) + ' = ' + tpLuaVal(v[k], inner) + ',').join('\n') + '\n' + pad + '}';
}
function tpTableLua(all){
  return '-- The TP pieces worth putting on before a weaponskill, worked out by the Atelier page with its damage engine\n' +
    '-- (atelier/app/js/tp_table.js) at each export of a job, with the buffs ticked in the page; read by GearSwap\n' +
    '-- before each weaponskill of this job (shared/utils/weaponskill/tp_pieces_table.lua). Segments: from tp to the next one; p = the pieces, g = what they add.\n' +
    '-- Delete this file: the game falls back on the fTP formula (tp_piece_decision.lua). Written ' + stamp() + '.\n' +
    'return ' + tpLuaVal(all, '') + '\n';
}
// The whole job worked out, a set at a time (the page keeps drawing in between)
// {sets: {path: set}, weaponskills: {ws: {weapon: [{path, segments}]}}}: each set written once, its weapons pointing at it.
// A set and weapon the engine cannot work out is left out and listed in `skipped` (not written): before 2026-11-14
// one such set threw the whole job away (Kaories COR: Blast Shot took the two Savage Blade sets with it)
async function tpTableJob(inputs, rule){
  const sets = {}, weaponskills = {}, skipped = [];
  for (const x of inputs) {
    for (const hands of x.hands) {
      const weapon = hands.main.name;
      let rows;
      try { rows = tpTableRows(x.s, hands, rule); }
      catch (e) { skipped.push(x.ws + ' (' + weapon + ')'); console.warn('tp_table', x.s.path, weapon, e); continue; }
      sets[x.s.path] = tpTableSetOf(x.s);
      const byWs = weaponskills[x.ws] = weaponskills[x.ws] || {}, list = byWs[weapon] = byWs[weapon] || [];
      list.push({path: x.s.path, segments: tpSegments(rows)});
    }
    await new Promise(r => setTimeout(r, 0));
  }
  return {sets, weaponskills, skipped: [...new Set(skipped)]};
}
// A new export of character c came in (live.js): the table of its job worked out again and written when it changed.
// Only for the job shown (the engine's context is the page's); the engine may still be loading: tried again a while
async function tpTableAfterExport(c, d, tries = 0){
  if (TP_TABLE_BUSY || S.char !== c || S.job !== d.job || data() !== d || !liveOk(c)) return;
  if (!engineReady()) { if (tries < 15) setTimeout(() => tpTableAfterExport(c, d, tries + 1), 2000); return; }
  const rule = tpTableRule(), inputs = rule ? tpTableInputs() : [];
  if (!inputs.length) return;
  // the export brings this job's table only (tp_pieces_<JOB>.lua)
  const sig = tpTableSig(inputs, rule), kept = d.tp_pieces || {};
  if ((kept[d.job] && kept[d.job].sig === sig) || TP_TABLE_FAILED[d.job + '|' + sig]) return;
  TP_TABLE_BUSY = true;
  render();   // the weaponskill head says it is being worked out
  try {
    const {sets, weaponskills, skipped} = await tpTableJob(inputs, rule);
    if (data() !== d) return;
    const mine = {[d.job]: {at: stamp(), sig, sets, weaponskills}};
    const done = await saveFile('tp_pieces_' + d.job + '.lua', tpTableLua(mine), true);
    if (done) {
      d.tp_pieces = mine;
      TP_TABLE_STATUS[c + '|' + d.job] = {at: mine[d.job].at, skipped};
      S.toast = t('tpTableSaved', {job: d.job}) + (skipped.length ? ' · ' + t('tpTableSkipped', {ws: skipped.join(', ')}) : '');
      render();
    }
    else TP_TABLE_FAILED[d.job + '|' + sig] = true;
  } catch (e) { console.warn('tp_table', e); TP_TABLE_FAILED[d.job + '|' + sig] = true; }
  finally { TP_TABLE_BUSY = false; render(); }
}
// The line under the weaponskill head's TP (atelier/src/screens/sets/wshead.ts): the table the game uses for this job,
// when it was worked out, being worked out now, or none yet. '' without the job's TP pieces. A toast shows only on some
// screens: on the sets' one the player saw nothing when the buffs changed (2026-11-14)
function tpTableStatus(){
  const d = data();
  if (!d || !tpTableRule()) return '';
  if (TP_TABLE_BUSY) return t('tpTableBusy');
  const st = TP_TABLE_STATUS[S.char + '|' + d.job], kept = (d.tp_pieces || {})[d.job];
  const at = st ? st.at : kept && kept.at;
  if (!at) return t('tpTableNone');
  const when = String(at).slice(11) || String(at);
  return t('tpTableAt', {at: when}) + (st && st.skipped.length ? ' · ' + t('tpTableSkipped', {ws: st.skipped.join(', ')}) : '');
}
// The buffs ticked in the page changed and held still TP_WATCH_CALM ms: the job's table worked out again (it is
// worked out with them). Nothing more when they are the ones of the table written (tpTableAfterExport's signature)
const TP_WATCH_EVERY = 2000, TP_WATCH_CALM = 3000;
const TP_WATCH = {key: '', buffs: '', since: 0, done: ''};
function tpTableWatch(){
  try {
    const d = data();
    if (!d || !S.char || TP_TABLE_BUSY || !liveOk(S.char)) return;
    const key = S.char + '|' + S.job, buffs = tpTableBuffs(), now = Date.now();
    if (key !== TP_WATCH.key) { Object.assign(TP_WATCH, {key, buffs, since: now, done: buffs}); return; }
    if (buffs !== TP_WATCH.buffs) { Object.assign(TP_WATCH, {buffs, since: now}); return; }
    if (buffs === TP_WATCH.done || now - TP_WATCH.since < TP_WATCH_CALM) return;
    TP_WATCH.done = buffs;
    tpTableAfterExport(S.char, d);
  } catch (e) { console.warn('tp_table watch', e); }
}
if (typeof window !== 'undefined') setInterval(tpTableWatch, TP_WATCH_EVERY);
// The rows of the set shown (the page's own context, hands as shown), kept while nothing changes
function tpShownRows(s){
  const rule = tpTableRule();
  if (!rule || !engineReady() || family(s.path, s.pieces) !== 'ws') return null;
  const hands = tpNoGear(() => withWeapons(s).pieces);
  const key = [DATA_GEN, S.char, S.job, s.path, JSON.stringify(S.trial[trialKey(s)] || {}), (hands.main || {}).name, (hands.sub || {}).name, JSON.stringify(buffState())].join('|');
  if (!(key in TP_STEPS_MEMO)) { try { TP_STEPS_MEMO[key] = tpTableRows(s, hands, rule); } catch (e) { TP_STEPS_MEMO[key] = null; } }
  return TP_STEPS_MEMO[key];
}
const tpRowText = r => { const names = Object.values(r.p); return names.length ? names.join(' + ') + ' · ' + (r.g >= 0 ? '+' : '') + (r.g * 100).toFixed(1) + ' %' : t('tpWhyNone'); };
// The TP where the pieces worth putting on change (1000 and 3000 always), each with what it puts on (S._tpWhy);
// null without the engine or the job's TP pieces
function tpStepsTable(s){
  const rows = tpShownRows(s);
  if (!rows) return null;
  const out = [], why = {};
  rows.forEach((r, i) => {
    const tp = TP_TABLE.from + i * TP_TABLE.step, prev = rows[i - 1];
    if (i === 0 || tp === TP_TABLE.to || JSON.stringify(r.p) !== JSON.stringify(prev.p)) { out.push(tp); why[tp] = tpRowText(r); }
  });
  S._tpWhy = why;
  return out;
}
// The pieces put on at that TP, {slot: name}, as the game will (the row of the TP shown + the page's Warcry)
// Kept per page state: the page asks it at every drawing, and for each weapon it ranks (ws_page.js heldRanking),
// up to four weaponskill figures each time (156 ms a ranking before it was kept, 2026-11-12)
const TP_BEST_MEMO = new Map();
function tpBestGear(s, pieces, tp){
  const rule = tpTableRule();
  if (!rule || !engineReady()) return null;
  const key = [DATA_GEN, S.char, S.job, s.path, tp, JSON.stringify(pieces), JSON.stringify(buffState())].join('|');
  if (TP_BEST_MEMO.has(key)) return TP_BEST_MEMO.get(key);
  let gear = null;
  try {
    // your own Warcry's TP Bonus moves the row, as in game (the engine's context here leaves it out)
    const b = tpNoGear(() => FFXI.opt.tpBest(tpTableCtx(s), optPieces(pieces),
      Math.min(3000, +tp + (optContextInput(s).ownWarcryTp || 0)), rule));
    gear = Object.fromEntries(Object.entries(b.add).map(([k, v]) => [k, v.name]));
  } catch (e) { gear = null; }
  if (TP_BEST_MEMO.size > 500) TP_BEST_MEMO.clear();
  TP_BEST_MEMO.set(key, gear);
  return gear;
}
