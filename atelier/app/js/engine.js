// GearSwap Atelier · engine.js: the damage engine and its workers, a set's context, merits, accuracy, the character's stats
// (cut from atelier.html, loaded by it in order: see the list there)
/* ---- ranks and Ambuscade capes (atelier/engine/catalog, kept on this PC only: augments_ranked.js
   from LandSandBoat's augment bundles, capes.js), loaded when present ---- */
// The damage engine (atelier/engine/: its formulas, its gear catalogue, ranks and capes,
// kept on this PC only) and the optimizer (atelier/opt.js): loaded once, run into window.FFXI
const CALC_FILES = ['abilities', 'attributes', 'derived', 'gear', 'jobs_fighters', 'jobs_mages', 'round_average', 'round_damage', 'round_swings',
  'round_time', 'sets', 'skills', 'stats', 'tables', 'traits', 'ws_average', 'ws_base', 'ws_details', 'ws_hits', 'ws_pdif', 'ws_table',
  'ws_tp', 'page'];
const ENGINE_FILES = ['math', 'helpers', 'weaponskills', 'buffs', 'player_data', 'player', 'actions', 'enemies']
  .map(f => `atelier/engine/${f}.js`).concat(['catalog/items', 'catalog/augments_ranked', 'catalog/capes', 'catalog/augments_parse']
  .map(f => `atelier/engine/${f}.js`), ['atelier/opt.js', 'atelier/cycle.js'])
  // our own engine (atelier/calc/: its parts, then calc_load.js builds CALC), and last the switch between the two
  // (calc_bridge.js, S.engine: 'own' or 'old')
  .concat(CALC_FILES.concat(['load', 'bridge']).map(f => `atelier/calc/calc_${f}.js`))
  // read again at each page load: a browser keeps an older copy of a script otherwise
  .map(f => f + '?v=' + Date.now());
function loadRanked(done){
  if (window.FFXI && FFXI.RANKED) return done();
  window.FFXI_PARTS = [];
  loadScripts(ENGINE_FILES, () => {
    window.FFXI = {};
    ENGINE_PARTS = (window.FFXI_PARTS || []).slice().concat([targetsPart()]);
    for (const part of ENGINE_PARTS) { try { part(FFXI); } catch (e) {} }
    window.FFXI_PARTS = [];
    useEngine(S.engine);
    done();
  });
}
// The engine in workers, built from the same parts (a page opened from the disk cannot load a worker file: the
// source is a Blob), so a search never freezes the page. Each worker runs its share of the search's walks
// (FFXI.opt.STARTS) on its own core, paced (FFXI.opt.runPaced: work, then a pause) so the game stays smooth
let ENGINE_PARTS = [], OPT_WORKER_URL = null, OPT_WORKERS = [], OPT_PAGE_STOP = null;
function optWorker(){
  if (!OPT_WORKER_URL) {
    const src = 'var CALC = {};\n' + (window.CALC_PARTS || []).map(p => '(' + p.toString() + ')(CALC);').join('\n') +
      `\nvar FFXI = {};\n` + ENGINE_PARTS.map(p => '(' + p.toString() + ')(FFXI);').join('\n') +
      `\nif (FFXI.engine) FFXI.engine.use(${JSON.stringify(engineName())});` +
      '\nself.onmessage = function (e) { var pace = e.data.pace || {}; FFXI.opt.runPaced(e.data, function (p) { self.postMessage({progress: p}); },' +
      ' function (r) { self.postMessage({done: r}); }, function (err) { self.postMessage({error: String(err && err.message || err)}); }, pace.work, pace.rest); };';
    OPT_WORKER_URL = URL.createObjectURL(new Blob([src], {type: 'text/javascript'}));
  }
  const w = new Worker(OPT_WORKER_URL);
  OPT_WORKERS.push(w);
  return w;
}
// Which engine computes: ours (atelier/calc/, 'own') or the one before it ('old'). Ours hands a case it does not
// compute yet to the old one (FFXI.engine.fell: the reasons). The workers are built for one engine: made again
function engineName(){ return window.FFXI && FFXI.engine ? FFXI.engine.name : 'old'; }
function useEngine(name){
  if (!(window.FFXI && FFXI.engine)) return;
  FFXI.engine.use(name === 'own' ? 'own' : 'old');
  for (const w of OPT_WORKERS) w.terminate();
  OPT_WORKERS = [];
  if (OPT_WORKER_URL) URL.revokeObjectURL(OPT_WORKER_URL);
  OPT_WORKER_URL = null;
}
const engineReady = () => !!(window.FFXI && FFXI.opt && FFXI.CATALOG && FFXI.average_ws);
const rankedEntry = name => window.FFXI && FFXI.ranked_entry ? FFXI.ranked_entry(name) : null;
/* ---- the engine on the page's sets: a weaponskill's average damage, and the optimizer ---- */
// A prime weapon's stage from your own copy: the catalogue's items of that name are its stages II to V in id order
// (Laphria IV holds STR +30, V +35), and the export gives each copy its item id; null when not a prime weapon or
// no copy with an id (an export written before ids)
function ownedPrimeStage(name){
  const primes = ((window.FFXI && FFXI.player_data) || {}).PRIME_WEAPONS || [];
  if (!name || !primes.includes(name) || !(FFXI.CATALOG && FFXI.CATALOG.items)) return null;
  const copy = ((ownedOf() || {}).main || []).filter(x => x.name === name && x.id).sort((a, b) => b.id - a.id)[0];
  if (!copy) return null;
  const ids = FFXI.CATALOG.items.filter(it => it.name === name).map(it => it.id).sort((a, b) => a - b), i = ids.indexOf(copy.id);
  return i < 0 ? null : ['V', 'IV', 'III', 'II'][ids.length - 1 - i] || null;
}
// The engine's view of the page: job, subjob, Master Level, the buffs ticked, abilities on, the
// aftermath, the target, the weaponskill of the set
function optContext(s, engaged){ return FFXI.opt.context(engaged ? engContextInput(s) : optContextInput(s)); }
// An engaged set's: no weaponskill, the main weapon's skill for the target's damage-type resistance
function engContextInput(s){
  const main = (withWeapons(s).pieces.main || {}).name, skills = weaponSkills();
  const b = liveBuffs(buffState()), physResBy = Object.fromEntries(Object.keys(SKILL_DMG).map(k => [k, physResOf(b, k)]));
  return Object.assign(optContextInput(s), {mode: 'engaged', ws: null, wsInfo: null, wsSkill: null, physRes: physResOf(b, skills[main] || ''), physResBy});
}
// The same as plain data, for the worker
function optContextInput(s){
  const b = liveBuffs(buffState()), d = data() || {}, lv = jaLevels(), ws = wsOfSet(s) || segs(s.path).pop();
  const abilities = {Aftermath: isAfm3(s && s.path) ? 3 : +(b.am || 0)};
  if (+b.amTp) abilities['Aftermath TP'] = +b.amTp;
  if (b.enspell) { abilities.EnSpell = true; abilities['Enhancing Skill'] = enSkill(b); }
  let partyWarcry = null; const partyStats = {};
  for (const ja of jasOf()) if (jaOn(b, ja.name)) {
    const base = ja.name.replace(' · party', '');
    if (ja.as === 'party' && base === 'Warcry') { partyWarcry = warcryTp(b, true); continue; }
    if (ja.a.eng) { Object.assign(partyStats, ja.a.eng); continue; }
    // Haste Samba at the page's value (merits, a party DNC main or sub), not the engine's fixed 10.1 / 5.1
    if (base === 'Haste Samba') { partyStats['JA Haste'] = (partyStats['JA Haste'] || 0) + sambaHaste(ja); continue; }
    // the engine counts Saber Dance at 25 % (and drops a /WAR's Double Attack trait under it): its 20 % floor instead,
    // the legs' bonus counted by the engine on the legs worn (ctx.saberMerit, atelier/opt.js gearset)
    if (base === 'Saber Dance') partyStats.DA = (partyStats.DA || 0) + 20 - 25;
    abilities[ja.as === 'sub' && base === 'Warcry' ? base + ' (sub)' : base] = true;
  }
  const skill = wsSkills()[ws] || '';
  return {job: S.job, sub: d.sub || 'WAR', ml: lv.ml, selection: FFXI.opt.selection(b, FOODS[b.food]), abilities, foeDown: foeJaDown(b),
    wsInfo: wsInfoOf(ws), wsSkill: wsSkills()[ws],
    enemy: enemyKey(b.enemy), evaDown: foeEva(b), physRes: physResOf(b, skill), tomahawk: foeJaActive(b).includes('Tomahawk'), banish: foeJaActive(b).includes('Banish II'), partyWarcry, geoMul: geoMul(b), ariaPdl: ariaPdl(b),
    rollOpts: [0, 1].map(i => ({job: rollJobOn(b, i), cc: b.rollCC != null && +b.rollCC === i})),
    saberMerit: abilities['Saber Dance'] ? danceMerit('saber') : 0,
    warcryTpDelta: S.job === 'WAR' && abilities.Warcry ? warcryTp(b) - 700 : 0, partyStats, sbBuff: auspiceSb(b), ws,
    // your measured base attributes and merits, as data: a worker has no page to ask (atelier/opt.js withBase)
    base: measuredBase((S.job || '').toLowerCase()), wsType: /archery|marksmanship/i.test(skill) ? 'ranged' : 'melee', primeStage: b.amStage || ownedPrimeStage((withWeapons(s).pieces.main || {}).name) || 'V'};
}
// A set's pieces as the engine reads them: a piece named without augments is your copy of it (its
// augments, path and the rank //gs c gearscan read)
function optPieces(pieces){
  const owned = ownedOf() || {}, out = {};
  for (const [slot, p] of Object.entries(pieces)) {
    if (!p || isEmpty(p)) continue;
    let q = Object.assign({}, p);
    // your copy: its augments, and its item id (one name, several items: a prime weapon's stages), the highest of them
    // when you hold several
    const mine = (owned[slot] || []).filter(x => x.name === q.name).sort((a, b) => (b.id || 0) - (a.id || 0))[0];
    if (!(q.augs && q.augs.length) && mine && mine.augs) q.augs = mine.augs;
    if (!q.id && mine && mine.id) q.id = mine.id;
    // else what //gs c gearscan read on your copy (a path): the engine then knows its rank, as the page's stats do
    const sc = scanOf()[q.name];
    if (!(q.augs && q.augs.length) && sc && !sc.differ && sc.augments) q.augs = sc.augments;
    // a path's rank stats only gearscan knows (no table of the engine for that piece: Cacoethic Ring +1)
    if (sc && sc.rank_stats && !rankedEntry(q.name) && (q.augs || []).includes('Path: ' + sc.path)) q.extraAugs = sc.rank_stats;
    if (isRare(q.name)) q.rare = true;
    out[slot] = ownRank(q);
  }
  return out;
}
// Your copy's rank (//gs c gearscan, same path): without it the engine counts a rank item at its top rank
function ownRank(q){
  const sc = scanOf()[q.name];
  if (q.rank == null && sc && sc.rank != null && (q.augs || []).some(a => a === 'Path: ' + sc.path)) q.rank = sc.rank;
  return engineFill(q);
}
// What the game's description gives that the engine's catalogue lacks (Raetic Bangles' "M. Accuracy", a Haste it
// left out): handed to the engine (atelier/opt.js gear: piece.fill), only for a stat it has none of
function engineFill(q){
  const it = window.FFXI && FFXI.opt && FFXI.opt.item ? FFXI.opt.item(q.name, q.id) : null, r = it && pieceStats(Object.assign({}, q, {augs: []}));
  if (!r || !r.known) return q;
  const fill = {}, unity = r.unity || {};
  for (const [k, e] of Object.entries(r.base)) { const ek = ENGINE_STAT[k], v = e.v - (unity[k] || 0); if (ek && v && !(it.stats || {})[ek]) fill[ek] = v; }
  // the Unity ranking's bonus is never in the engine's catalogue: on top of what it has (Blistering Sallet +1: HP 38 + 80)
  for (const [k, u] of Object.entries(unity)) { const ek = ENGINE_STAT[k]; if (ek && u) fill[ek] = (fill[ek] || 0) + u; }
  if (Object.keys(fill).length) q.fill = fill;
  return q;
}
// The weaponskill's average damage with the set as shown (weapons, TP pieces, tried pieces), at the TP
// chosen (3000 when none), or null
function wsDamage(s){
  if (!engineReady() || family(s.path, s.pieces) !== 'ws') return null;
  try { const r = FFXI.opt.ws(optContext(s), optPieces(withWeapons(s).pieces), +(S.wsTp || 3000)); return r ? r[0] : null; }
  catch (e) { return null; }
}
/* ---- merits: the game's levels, which the page lets you change to test ---- */
// What one level gives, read from the game's description ("Adjust your maximum HP by 10 points");
// null for a merit that changes no stat the page shows (a recast, a duration...)
function meritEffect(m){
  const d = m.desc || ''; let x;
  // only the general merits move the stats (ids below 384): a job's "Increase maximum HP by 50"
  // (NIN Yonin Effect) holds under its ability only
  const general = !(m.id >= 384);
  if (general && (x = d.match(/maximum (HP|MP) by (\d+)/))) return {key: x[1].toLowerCase(), per: +x[2], unit: ' ' + x[1]};
  if (general && (x = d.match(/Adjust your (STR|DEX|VIT|AGI|INT|MND|CHR) by (\d+)/))) return {key: x[1].toLowerCase(), per: +x[2], unit: ' ' + x[1]};
  if (general && (x = d.match(/spell interruption rate by (\d+) percent/))) return {key: 'sird', per: +x[1], unit: ' %'};
  if (general && (x = d.match(/enemies' critical hit rate by (\d+) percent/))) return {key: 'ecrit', per: -x[1], unit: ' %'};
  if (general && (x = d.match(/Adjust your critical hit rate by (\d+) percent/))) return {key: 'crit', per: +x[1], unit: ' %'};
  if ((x = d.match(/(Increase|Decrease) your enmity (\d+)/))) return {key: general ? 'enmity' : null, per: (x[1] === 'Increase' ? 1 : -1) * x[2], unit: ''};
  if ((x = d.match(/skill by (\d+) points/))) return {per: +x[1], unit: ''};
  // the verb gives the sign: "Shorten recast time by 10 seconds" is -10 s a level
  if ((x = d.match(/(\w+)[^.]*? by (\d+(?:\.\d+)?)\s*(percent|%|points?|seconds?)?/))) {
    const sign = /^(shorten|decrease|reduce|lower)/i.test(x[1]) ? -1 : 1;
    return {per: sign * x[2], unit: /^(percent|%)$/.test(x[3] || '') ? ' %' : /^second/.test(x[3] || '') ? ' s' : ''};
  }
  return null;
}
const meritKey = () => S.char + '|' + S.job;
// The merits of the latest measure (general ones and the job's two groups), or null
function meritList(){ const c = measuredChar(); return (c && c.merit_list) || null; }
const meritLevel = m => { const e = (S.meritEdits[meritKey()] || {})[m.key]; return e ?? m.level; };
// What the merits set in the page change, by stat: (level set - level measured) x one level
function meritDelta(){
  const out = {};
  for (const m of meritList() || []) {
    const e = meritEffect(m), lv = meritLevel(m);
    if (e && e.key && lv !== m.level) out[e.key] = (out[e.key] || 0) + (lv - m.level) * e.per;
  }
  return out;
}
const MERIT_COLORS = {mgHp: 'g-def', mgAttr: 'g-attr', mgCombat: 'g-off', mgMagic: 'g-mag', mgOther: 'g-other', mgJob1: 'g-you', mgJob2: 'g-buff'};
const MERIT_GROUPS = [[64, 128, 'mgHp'], [128, 192, 'mgAttr'], [192, 256, 'mgCombat'], [256, 320, 'mgMagic'], [320, 384, 'mgOther'],
  [384, 2048, 'mgJob1'], [2048, 9999, 'mgJob2']];
// A merit's highest level where it is known for sure: Max HP / MP 15, a combat or magic skill 8 (+16),
// a job group merit 5; the others keep 15, the page does not guess theirs
const meritCap = m => m.id >= 64 && m.id < 128 ? 15 : m.id >= 192 && m.id < 320 ? 8 : m.id >= 384 ? 5 : 15;
// The rows of one merit group: its name, its level (an input), what it gives
function meritRows(list, lo, hi, edits){
  return list.filter(m => m.id >= lo && m.id < hi && m.key !== 'maximum_merit_points').map(m => {
    const e = meritEffect(m), lv = meritLevel(m), changed = m.key in edits;
    const total = e ? `${e.per * lv > 0 ? '+' : e.per * lv < 0 ? '−' : ''}${Math.abs(e.per * lv)}${e.unit}` : '';
    return `<li class="${changed ? 'changed' : ''}"><span title="${esc(m.desc)}">${esc(m.en)}</span>` +
      `<input class="meritin" id="merit-${esc(m.key)}" data-merit="${esc(m.key)}" type="number" min="0" max="${meritCap(m)}" value="${lv}">` +
      `<i>${changed ? `${t('inGame')} ${m.level} · ` : ''}${esc(total)}</i></li>`; }).join('');
}
// The note over the merits and the button that puts back the levels read in game
function meritBar(edits){
  const c = measuredChar(), n = Object.keys(edits).length;
  return `<div class="meritbar"><p class="muted">${t('meritsNote', {at: esc(c.at), s: esc(c.sub || '—')})}</p>` +
    (n ? `<button class="btn ghost" data-action="meritreset">${t('meritsReset', {n})}</button>` : '') + `</div>`;
}
function renderMerits(){
  const list = meritList();
  if (!list) return `<div class="placeholder"><p>${t('noMerits')}</p></div>`;
  const edits = S.meritEdits[meritKey()] || {};
  const groups = MERIT_GROUPS.map(([lo, hi, label]) => {
    const rows = meritRows(list, lo, hi, edits);
    return rows ? box(MERIT_COLORS[label], t(label), `<ul class="meritlist">${rows}</ul>`) : '';
  }).join('');
  return meritBar(edits) + `<div class="meritgrid">${groups}</div>`;
}

/* ---- Accuracy and Evasion: the engine's formulas (atelier/engine/player.js) ---- */
// Job traits, highest tier first: [level, value]. The main job's counts, the subjob's only
// when higher (they do not stack)
const TRAITS = {
  acc: {rng: [[96, 73], [86, 60], [70, 48], [50, 35], [30, 22], [10, 10]], drg: [[76, 35], [60, 22], [30, 10]],
    dnc: [[76, 35], [60, 22], [30, 10]], run: [[90, 35], [70, 22], [50, 10]]},
  eva: {thf: [[88, 72], [76, 60], [70, 48], [50, 35], [30, 22], [10, 10]], dnc: [[86, 48], [75, 35], [45, 22], [15, 10]],
    pup: [[76, 48], [60, 35], [40, 22], [20, 10]]},
  stp: {sam: [[90, 30], [70, 25], [50, 20], [30, 15], [10, 10]]},
  da: {war: [[99, 18], [85, 16], [75, 14], [50, 12], [25, 10]]},
  dw: {nin: [[85, 35], [65, 30], [45, 25], [25, 15], [10, 10]], dnc: [[80, 30], [60, 25], [40, 15], [20, 10]], thf: [[98, 25], [90, 15], [83, 10]]},
  pdl: {drk: [[80, 50], [70, 40], [55, 30], [40, 20], [20, 10]], mnk: [[90, 30], [60, 20], [30, 10]], rng: [[90, 30], [60, 20], [30, 10]],
    drg: [[90, 30], [60, 20], [30, 10]], war: [[80, 20], [40, 10]], sam: [[80, 20], [40, 10]], bst: [[90, 20], [45, 10]], pup: [[90, 20], [45, 10]],
    dnc: [[90, 20], [45, 10]], thf: [[50, 10]], nin: [[50, 10]], rdm: [[60, 10]]},
  mdb: {run: [[99, 22], [91, 20], [76, 18], [70, 16], [50, 14], [30, 12], [10, 10]], whm: [[91, 20], [81, 18], [70, 16], [50, 14], [30, 12], [10, 10]],
    rdm: [[96, 14], [45, 12], [25, 10]]},
};
// Job point gifts of the main job, all of them (2100 job points spent)
const GIFTS = {
  war: {acc: 36, eva: 36, meva: 36, macc: 36, da: 10}, mnk: {acc: 41, eva: 42, meva: 36, macc: 36}, whm: {acc: 14, macc: 70, mdb: 50},
  blm: {macc: 32, meva: 42, mdb: 14}, rdm: {acc: 22, macc: 90, mdb: 28, meva: 56}, thf: {acc: 36, eva: 70, meva: 36, macc: 36, dw: 5},
  pld: {acc: 28, eva: 22, meva: 42, macc: 42}, drk: {acc: 22, eva: 22, meva: 36, macc: 42}, bst: {acc: 36, eva: 36, meva: 36, macc: 36},
  brd: {acc: 21, eva: 22, meva: 36, macc: 36, mdb: 15}, rng: {acc: 70, eva: 14, meva: 36}, smn: {eva: 22, meva: 22, mdb: 22},
  sam: {acc: 36, eva: 36, meva: 36, stp: 8}, nin: {acc: 56, eva: 64, meva: 50, macc: 50}, drg: {acc: 64, eva: 36, meva: 36},
  blu: {acc: 36, eva: 36, meva: 36, mdb: 36}, cor: {acc: 36, eva: 22, meva: 36, macc: 36}, pup: {acc: 50, eva: 56, meva: 36, macc: 36},
  dnc: {acc: 64, eva: 64, meva: 36, macc: 36, dw: 5}, sch: {meva: 42, macc: 42, mdb: 22}, geo: {macc: 50, meva: 50, mdb: 28},
  run: {acc: 56, eva: 56, meva: 70, macc: 36, mdb: 56},
};
function traitOf(stat, c){
  const tier = (job, level) => { const list = (TRAITS[stat] || {})[(job || '').toLowerCase()] || [];
    const hit = list.find(([lv]) => (level || 0) >= lv); return hit ? hit[1] : 0; };
  const sub = (data() || {}).sub || c.sub;
  return Math.max(tier(S.job, c.main_level || 99), tier(sub, sub === c.sub ? c.sub_level || 0 : jaLevels().sub));
}
const giftOf = (stat, c) => (c.jp_spent || 0) >= 2100 ? ((GIFTS[(S.job || '').toLowerCase()] || {})[stat] || 0) : 0;
// Accuracy from a combat skill, by steps: 1 a point to 200, 0.9 to 400, 0.8 to 600, 0.9 past it
function skillAcc(level){
  let a = Math.min(level, 200);
  if (level > 200) a += Math.floor((Math.min(level, 400) - 200) * 0.9);
  if (level > 400) a += Math.floor((Math.min(level, 600) - 400) * 0.8);
  if (level > 600) a += Math.floor((level - 600) * 0.9);
  return a;
}
// Evasion from the evasion skill: 1 a point to 300, 0.8 past it
const skillEva = level => level > 300 ? Math.floor(300 + 0.8 * (level - 300)) : level;
// A skill level read in game, by its name ("Great Sword" and "great_sword" alike), held to the job's cap (the
// engine's table + master level + 16 of merits): the skill packet can carry more than the job uses (Great Axe
// 499 read for a WAR whose skill menu and Accuracy show 478)
function skillLevel(c, name){
  const want = (name || '').toLowerCase().replace(/[^a-z]/g, '');
  // the engine's files load after the first render: no cap until they are there (the page renders again then)
  const table = (((window.FFXI || {}).player_data || {}).JOB_COMBAT_STATS || {})[(S.job || '').toLowerCase()] || {};
  const capKey = Object.keys(table).find(k => k.toLowerCase().replace(/[^a-z]/g, '') === want + 'skill');
  const cap = capKey ? table[capKey] + (c.master_level || 0) + 16 : Infinity;
  for (const [k, v] of Object.entries(c.skills || {})) if (k.toLowerCase().replace(/[^a-z]/g, '') === want) return Math.min(v, cap);
  return 0;
}
// Accuracy and Evasion of a gear total: main hand Accuracy = 0.75 x DEX + gear + its skill's
// steps + traits + gifts; Evasion = 0.5 x AGI + gear + the evasion skill's steps + traits + gifts
function combatOf(c, gear, dex, agi, mainName){
  const g = k => (gear[k] || {}).v || 0;
  const wskill = mainName && weaponSkills()[mainName];
  const level = wskill ? skillLevel(c, wskill) + g('skill:' + wskill.toLowerCase() + ' skill') : 0;
  const acc = Math.floor(0.75 * dex) + g('acc') + (wskill ? skillAcc(level) : 0) + traitOf('acc', c) + giftOf('acc', c);
  const eva = Math.floor(0.5 * agi) + g('eva') + skillEva(skillLevel(c, 'evasion') + g('skill:evasion skill')) + traitOf('eva', c) + giftOf('eva', c);
  return {acc, eva, wskill, level};
}

/* ---- tanking (Guide_Paladin 02_enmity, 03_defense, 03_magic) and offense (atelier/engine/helpers.js get_tp, get_hit_rate) ---- */
// Phalanx potency of the enhancing skill: up to 300, a tenth less 2; past it a point per 28.5, up to 35 at 500
const phalanxPotency = skill => skill <= 300 ? Math.max(0, Math.floor(skill / 10) - 2) : Math.min(35, 28 + Math.floor((skill - 300.5) / 28.5));
// Base TP of a hit from the weapon delay (atelier/engine/helpers.js get_tp)
function tpBase(d){
  if (d <= 180) return 61 + (d - 180) * 63 / 360;
  if (d <= 540) return 61 + (d - 180) * 88 / 360;
  if (d <= 630) return 149 + (d - 540) * 20 / 360;
  if (d <= 720) return 154 + (d - 630) * 28 / 360;
  if (d <= 900) return 161 + (d - 720) * 24 / 360;
  return 173 + (d - 900) * 28 / 360;
}
const TWO_HANDED = /great|scythe|polearm|staff/i;
function tankHTML(r){
  const {c, set, B} = r, v = k => (set[k] || {}).v || 0, mul = B.dmgmul || 1, pmul = mul * (B.pdmgmul || 1);
  const dt = v('dt'), shell = B.shell ? -B.shell / 256 * 100 : 0;
  const pdt = Math.max(Math.max(dt + v('pdt'), -50) + v('pdt2'), -87.5);
  const mdt = Math.max(Math.max(dt + v('mdt') + shell, -50) + v('mdt2'), -87.5);
  const mdb = v('mdb') + traitOf('mdb', c) + giftOf('mdb', c) + (B.mdb || 0);
  const fl = x => Math.floor(x + 1e-9);
  const phys = fl(1000 * (1 + pdt / 100) * pmul), mag = fl(fl(1000 * (1 + mdt / 100)) / (1 + mdb / 100) * mul);
  const breath = fl(1000 * (1 + Math.max(dt + v('bdt'), -50) / 100) * mul);
  const pctOf = n => `${signed(Math.round((n / 1000 - 1) * 1000) / 10)} %`;
  // what multiplies the damage taken (Rampart ×0.75, Fan Dance ×0.75...: past the -50 % cap)
  const muls = B._by.filter(e => e.k === 'dmgmul' || e.k === 'pdmgmul').map(e => `${e.src} ×${Math.round(e.v * 100) / 100}`).join(' · ');
  let rows = statLi(t('physHit'), phys, pctOf(phys), '', muls) +
    statLi(t('magHit'), mag, pctOf(mag), '', t('magTip', {m: Math.round(Math.max(dt + v('mdt') + shell, -50) * 10) / 10, b: mdb})) +
    statLi(t('breathHit'), breath, pctOf(breath));
  const enm = v('enmity') + (B.enmity || 0), mult = enm >= 0 ? Math.min(1 + enm / 100, 3) : Math.max(1 + enm / 100, .5);
  if (enm) rows += statLi(t('enmityLbl'), signed(enm), `×${mult.toFixed(2)}`, '', t('enmTip', {g: v('enmity'), b: B.enmity || 0}));
  if (enm && ['PLD', 'RUN'].includes(S.job)) rows += statLi(t('flashLbl'), `${Math.floor(180 * mult)} / ${Math.floor(1280 * mult)}`, '');
  rows += tankExtraHTML(c, set, B, enm);
  const skill = skillLevel(c, 'enhancing magic') + v('skill:enhancing magic skill');
  if (['PLD', 'RUN', 'RDM'].includes(S.job) && skill) {
    const pot = phalanxPotency(skill);
    rows += statLi('Phalanx', `−${pot + v('phalanx')}`, '', '', t('phalanxTip', {p: pot, s: skill, g: v('phalanx')}));
  }
  return fbox('tank', 'g-tank', t('tankTitle'), `<p class="note-m">${t('tankNote')}</p><ul class="statlist">${rows}</ul>`);
}
function offenseHTML(r, s){
  const {c, set, B, cur} = r, v = k => (set[k] || {}).v || 0;
  const pieces = withWeapons(s).pieces, rm = pieceStats(pieces.main), rs = pieceStats(pieces.sub);
  const d1 = rm && rm.weapon && +rm.weapon.Delay;
  if (!d1) return '';
  const d2 = (rs && rs.weapon && +rs.weapon.Delay) || 0, dual = d2 > 0;
  const dw = dual ? v('dw') + traitOf('dw', c) + giftOf('dw', c) : 0;
  const gh = Math.min(v('haste'), 25), mh = Math.min(B.mhaste || 0, 43.75), jh = Math.min(B.jahaste || 0, 25), haste = gh + mh + jh;
  const mdelay = dual ? (d1 + d2) / 2 * (1 - dw / 100) : d1;
  const stp = v('stp') + traitOf('stp', c) + giftOf('stp', c) + (B.stp || 0);
  const tph0 = Math.floor(tpBase(mdelay)), tph = tph0 + Math.floor(tph0 * stp / 100);
  const delay = d1 + (dual ? d2 : 0), round = Math.max(delay * (1 - dw / 100) * (1 - haste / 100), 0.2 * delay) / 60;
  const two = cur.wskill && TWO_HANDED.test(cur.wskill), enemyName = enemyKey(buffState().enemy);
  const eva = Math.max(0, ENEMIES[enemyName][2] - (B.eeva || 0)), cap = two ? 95 : 99;
  const edef = Math.round(ENEMIES[enemyName][1] * (1 - Math.min(B.edefp || 0, 1)));
  const r1 = n => Math.round(n * 10) / 10;
  // the accuracy the hit rate is worked out from, first: character (weapon skill, DEX, traits, gifts) + the set +
  // food and buffs
  const accB = Math.floor(B.acc || 0);
  let rows = (cur.acc != null ? statLi(t('accTotal'), cur.acc, t('accTotalNote', {g: v('acc'), b: accB}), '', t('accTotalTip', {g: v('acc'), b: accB, w: cur.wskill || '—', l: cur.level || 0})) : '') +
    statLi(t('hasteTot'), `${r1(haste)} %`, haste >= 93.75 ? 'cap' : '', '', t('hasteTip', {g: r1(gh), m: r1(mh), j: r1(jh)})) +
    statLi(t('tpHit'), tph, '', '', t('tpTip', {d: Math.round(mdelay), s: stp})) + statLi(t('hitsTo'), Math.ceil(1000 / tph), '') +
    statLi(t('roundLbl'), `${r1(round)} s`, '');
  if (cur.acc != null) { const rate = Math.max(20, Math.min(cap, 75 + 0.5 * (cur.acc - eva)));
    rows += statLi(t('hitRate'), `${Math.floor(rate)} %`, `cap ${cap}`, '', t('hitTip', {a: cur.acc, e: eva, n: enemyName}) + (two ? ' · ' + t('twoHand') : '')); }
  rows += statLi(t('enemyDef'), edef, B.edefp ? `−${Math.round(B.edefp * 1000) / 10} %` : '', '', t('enemyDefTip', {n: enemyName}));
  const da = v('da') + traitOf('da', c) + giftOf('da', c) + (B.da || 0);
  if (da || v('ta') || v('qa')) rows += statLi(t('multiLbl'), `${r1(da)} · ${v('ta')} · ${v('qa')} %`, '');
  const crit = v('crit') + (B.crit || 0);
  if (crit) rows += statLi(t('critLbl'), `${r1(crit)} %`, '');
  return fbox('off', 'g-off', t('offTitle'), `<ul class="statlist">${rows}</ul>`, cur.acc != null ? `${t('accLabel')} ${cur.acc}` : '');
}

/* ---- the character's real stats with a set ---- */
// The stats measured in game by //gs c atelier (this subjob's export, else another one's)
// The measure taken on the shown subjob if there is one, else the latest of the job (an offline
// export carries a copy of an older measure: the newest one has the latest merits)
function measuredChar(){
  const d = data(), all = Object.values(exportsOf(S.char, S.job)).map(x => x.char).filter(c => c && c.base);
  const latest = list => list.sort((a, b) => (b.at || '').localeCompare(a.at || ''))[0] || null;
  return latest(all.filter(c => d && c.sub === d.sub)) || latest(all);
}
// The measured base attributes ({main, sub, str: 153...}) for the damage engine's create_player (atelier/opt.js
// withBase): the character's own race and attribute merits instead of a generic character's
function measuredBase(job){
  if (!S.job || S.job.toLowerCase() !== job) return null;
  const c = measuredChar();
  return c && c.base ? Object.assign({main: S.job, sub: c.sub, merits: c.merits || null}, c.base) : null;
}
function gearTotal(pieces){
  const total = {};
  for (const slot of SLOTS) { const r = pieceStats(pieces[slot], slot); if (r) for (const [k, e] of Object.entries(r.stats)) add(total, k, e.v, e.unit, e.label); }
  return total;
}
// The Defense a Protect up when the stats were measured put in them (buff 40, the export's char.buffs), to take out
// before the page lays its own: a Protect V (its tier is not sent), a PLD's with the shield worn then (Shield Barrier,
// checked in game 2026-10-05: 2365 -> 2480 recast with Duban for Aegis, (145 - 40) x 1.1) and the gift's +10 %
function protectAtMeasure(c){
  if (!c || !(c.buffs || []).includes(40)) return 0;
  const sub = c.worn && c.worn.sub, it = sub && itemOf(sub.name), r = it && it.Type === 'Shield' && S.job === 'PLD' ? pieceStats(sub, 'sub') : null;
  const shield = r && r.stats.def ? r.stats.def.v : 0;
  return Math.floor((PROTECT['Protect V'] + shield) * protectGift());
}
// Measured stats minus the gear worn when measured, plus the set's gear. HP / MP: the
// % of gear applies to base + gear HP (Guide_Paladin solver_common.effective_hp);
// DEF moves with VIT x1.5 (calc_defense), Attack with STR (the engine: 8 + skill + STR + Attack)
function charStats(s, pieces){
  const c = measuredChar();
  if (!c || !c.base) return null;
  // pieces: the gear of a simulated step, taken as it is (no weapon mode, no tried piece over it)
  const worn = gearTotal(c.worn || {}), set = pieces ? gearTotal(pieces) : setStats(s).total;
  const held = pieces || (s ? withWeapons(s).pieces : {});
  const B = shieldBarrier(withAftermath(buffTotals(), (held.main || {}).name), held.sub);
  const g = (o, k) => (o[k] || {}).v || 0;
  // merits changed in the page (Merits tab) move the base: Max HP before the gear's HP %
  const md = meritDelta(), measured = a => (c.base[a] || 0) + (c.add[a] || 0);
  // The stats with one gear total: the measure, less the gear worn then, plus that gear and the buffs
  function calc(gear, mainName){
    const r = {};
    for (const a of ATTRS) r[a] = measured(a) - g(worn, a) + g(gear, a) + (md[a] || 0) + (B[a] || 0);
    const pool = (max, k) => {
      const naked = max / (1 + g(worn, k + '%') / 100) - g(worn, k) + (md[k] || 0) + (B[k] || 0);
      return Math.round((naked + g(gear, k)) * (1 + g(gear, k + '%') / 100));
    };
    r.hp = pool(c.max_hp, 'hp'); r.mp = pool(c.max_mp, 'mp');
    let def = (c.defense - protectAtMeasure(c) + g(gear, 'def') - g(worn, 'def') + 1.5 * (r.vit - measured('vit')) + (B.def || 0)) * (1 + (B.defp || 0));
    if (B.deff) def += Math.min(def * B.deff[0] / 100, B.deff[1]);
    r.def = Math.floor(def);
    r.atk = Math.floor((c.attack + g(gear, 'atk') - g(worn, 'atk') + (r.str - measured('str')) + (B.atk || 0)) * (1 + (B.atkp || 0)) + (B.atkf || 0));
    // Accuracy and Evasion are not in the status window: computed for the worn gear and the set alike
    if (c.skills && Object.keys(c.skills).length) {
      const cb = combatOf(c, gear, r.dex, r.agi, mainName);
      r.acc = cb.acc + Math.floor(B.acc || 0); r.eva = cb.eva + (B.eva || 0); r.wskill = cb.wskill; r.level = cb.level;
    }
    return r;
  }
  const cur = calc(set, ((pieces || withWeapons(s).pieces).main || {}).name);
  if (pieces) return {c, set, B, cur};
  // the difference: to the set without the tried pieces when some are tried, else to the gear worn when measured
  const vsSet = trialCount(s) > 0;
  const ref = vsSet ? withoutTrial(() => calc(setStats(s).total, (withWeapons(s).pieces.main || {}).name))
    : calc(worn, (c.worn && c.worn.main || {}).name);
  // Attack and Accuracy as the damage engine has them when it is loaded (the damage and the optimizer use
  // those): the measure above multiplies an Attack measured in game, its own bonuses in it, by every buff
  const eCur = engineStats(s, withWeapons(s).pieces);
  // the gear worn when measured may be unknown (a live read without it): then no difference is shown
  const eRef = (vsSet ? withoutTrial(() => engineStats(s, withWeapons(s).pieces)) : engineStats(s, c.worn || {})) || eCur;
  if (eCur) for (const k of ['atk', 'acc']) { cur[k] = eCur[k]; ref[k] = eRef[k]; }
  const out = {};
  for (const k of [...ATTRS, 'hp', 'mp', 'def', 'atk', 'acc', 'eva']) if (cur[k] != null) out[k] = {now: ref[k], set: cur[k]};
  if (out.acc && cur.wskill) out.acc.tip = `${cur.wskill} ${cur.level}`;
  // where the Attack comes from: the engine, or the measure (with why the engine gave nothing)
  if (out.atk) out.atk.src = eCur ? 'engine' : !engineReady() ? 'not loaded' : S._engErr || 'no result';
  return {c, out, set, B, cur, vsSet};
}
// Every number behind the target window, as text to copy: the measure, the set's gear, each buff, the page's
// Attack sum and the engine's (its Attack %, flat Attack, PDL, the context it was given), and any error
function debugReport(s){
  const L = [], line = (k, v) => L.push(k + ': ' + (typeof v === 'string' ? v : JSON.stringify(v)));
  const c = measuredChar() || {}, b = buffState(), B = withAftermath(buffTotals(), s ? (withWeapons(s).pieces.main || {}).name : null);
  line('page', 'atelier ' + new Date().toISOString() + ' · ' + S.char + ' ' + S.job + '/' + ((data() || {}).sub || '?') + ' · lang ' + S.lang);
  line('set', s ? s.path : 'none');
  line('engineReady', engineReady());
  line('measured', {at: c.at, attack: c.attack, defense: c.defense, base: c.base, add: c.add, main_level: c.main_level, ml: c.master_level});
  line('worn when measured', Object.fromEntries(Object.entries(c.worn || {}).map(([k, p]) => [k, p && p.name])));
  const pieces = s ? withWeapons(s).pieces : {};
  line('set pieces', Object.fromEntries(Object.entries(pieces).map(([k, p]) => [k, p && p.name + (p.augs && p.augs.length ? ' [' + p.augs.join(' / ') + ']' : '')])));
  line('buff state', b);
  line('buff totals', Object.fromEntries(Object.entries(B).filter(([k]) => k !== '_by')));
  B._by.forEach(e => L.push('  · ' + e.src + ' ' + e.k + ' ' + JSON.stringify(e.v)));
  if (s) {
    const r = charStats(s), gear = setStats(s).total, g = k => (gear[k] || {}).v || 0, worn = gearTotal(c.worn || {}), w = k => (worn[k] || {}).v || 0;
    line('page Attack sum', {measured: c.attack, setGearAtk: g('atk'), wornGearAtk: w('atk'), buffAtk: B.atk || 0, buffAtkPct: B.atkp || 0, foodAtk: B.atkf || 0,
      shownAtk: r && r.out.atk, shownAcc: r && r.out.acc, setPdl: g('pdl'), buffPdl: B.pdl || 0});
    try {
      const ci = optContextInput(s), ctx = FFXI.opt.context(ci), pc = optPieces(pieces);
      line('engine context', {job: ci.job, sub: ci.sub, ml: ci.ml, abilities: ci.abilities, enemy: ci.enemy, evaDown: ci.evaDown, foeDown: ci.foeDown,
        partyWarcry: ci.partyWarcry, geoMul: ci.geoMul, songs: ci.selection.songs, rolls: ci.selection.rolls, bubbles: ci.selection.bubbles});
      const miss = Object.keys(pc).filter(k => !FFXI.opt.gear(pc[k], k, ctx));
      line('engine: pieces not in its catalogue', miss.map(k => k + ':' + (pc[k] || {}).name));
      for (const k of miss) if (k !== 'main') delete pc[k];
      const set = FFXI.opt.gearset(ctx, pc), pl = set && FFXI.create_player(ctx.job, ctx.sub, ctx.ml, set, ctx.buffs, ctx.abilities);
      if (pl) { const st = pl.stats;
        line('engine stats', {Attack1: st.Attack1, Accuracy1: st.Accuracy1, 'Attack%': st['Attack%'], Attack: st.Attack, STR: st.STR, DEX: st.DEX, PDL: st.PDL, 'PDL Trait': st['PDL Trait'],
          'TP Bonus': st['TP Bonus'], 'Store TP': st['Store TP'], 'Weapon Skill Damage': st['Weapon Skill Damage'], 'Magic Haste': st['Magic Haste'], 'Food Attack': st['Food Attack']});
        line('engine buffs', ctx.buffs);
        line('engine enemy', ctx.enemy.stats);
      } else line('engine', 'no player (a slot the engine cannot read)');
    } catch (e) { line('engine error', e.message + ' ' + (e.stack || '').split('\n').slice(0, 3).join(' | ')); }
  }
  if (S._engErr) line('last engine error', S._engErr);
  return L.join('\n');
}
function openDebug(){
  const text = debugReport(S._tgtSet);
  S._tgtDlg = false;
  showDialog('dbgdlg', 'Debug', `<p class="muted small">${esc(t('dbgNote'))}</p><textarea id="dbgtext" class="dbgtext" readonly>${esc(text)}</textarea>`,
    `<button class="btn" data-dbgcopy>${esc(t('dbgCopy'))}</button>`);
}
// A set's main-hand Attack and Accuracy from the damage engine, with the page's buffs, target and weapons;
// null while the engine is not loaded. A piece its catalogue does not have (town gear, a ring worn when measured)
// counts as an empty slot, so the set and the gear worn when measured are always both worked out. Kept per gear and buffs
const ENG_STATS = new Map();
function engineStats(s, pieces){
  if (!engineReady() || !s || !pieces || !Object.keys(pieces).length) return null;
  try {
    const ci = optContextInput(s), pc = optPieces(pieces);
    const key = JSON.stringify([S.char, S.job, ci.sub, ci.selection, ci.abilities, ci.geoMul, ci.partyWarcry, pc]);
    if (ENG_STATS.has(key)) return ENG_STATS.get(key);
    const ctx = FFXI.opt.context(ci);
    for (const sl of Object.keys(pc)) if (sl !== 'main' && !FFXI.opt.gear(pc[sl], sl, ctx)) delete pc[sl];
    const set = FFXI.opt.gearset(ctx, pc);
    const pl = set && FFXI.create_player(ctx.job, ctx.sub, ctx.ml, set, ctx.buffs, ctx.abilities);
    const v = pl ? {atk: Math.floor(pl.stats.Attack1), acc: Math.floor(pl.stats.Accuracy1)} : null;
    if (ENG_STATS.size > 300) ENG_STATS.clear();
    ENG_STATS.set(key, v);
    return v;
  } catch (e) { S._engErr = e.message; return null; }
}
// the Attack card's total accuracy
Object.assign(T.fr, {accTotal: 'Précision totale', accTotalNote: 'set +{g} · buffs +{b}',
  accTotalTip: 'Ta précision avec ce set : perso (compétence {w} {l}, DEX, traits, gifts) + pièces du set +{g} + repas et buffs +{b}. C’est elle qui donne le taux de toucher juste en dessous'});
Object.assign(T.en, {accTotal: 'Total accuracy', accTotalNote: 'set +{g} · buffs +{b}',
  accTotalTip: 'Your accuracy with this set: character ({w} skill {l}, DEX, traits, gifts) + the set’s pieces +{g} + food and buffs +{b}. The hit rate just below is calculated from it'});
