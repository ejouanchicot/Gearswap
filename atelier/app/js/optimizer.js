// GearSwap Atelier · optimizer.js: the searches: launch, the cost of the wrong profile, the search window, the result
// (loaded in the order of atelier/src/legacy/files.ts)
// The two searches' buttons: the best set possible (from nothing, the set you start from changing nothing; slower),
// and improving the set shown (from it, quicker)
const optGoButtons = act => `<button class="btn optgo" data-${act}="best" title="${esc(t('optBestTip'))}">${t('optBest')}</button>` +
  `<button class="btn" data-${act}="improve" title="${esc(t('optImproveTip'))}">${t('optImprove')}</button>`;
// The cores a search may take: what the processor has (the browser says how many), one left free for the game and
// the page, eight at most; each worker paced to about half a core
const OPT_CORES = Math.max(1, Math.min(8, (navigator.hardwareConcurrency || 2) - 1));
const optCores = n => Math.min(n, OPT_CORES);
// The walks of a search: the ones its choices and floors call for, then shuffled ones ("mix<n>") on the cores left.
// The fast search makes four a core: a walk costs it next to nothing, and an objective that moves by steps (the real
// time to the weaponskill, whole rounds) is found by few walks (4 in 32 on Laphria, 2026-10-05), so more walks find it
const OPT_FAST_WALKS = 4;
function optWalks(input){
  const base = FFXI.opt.startsFor(input.choices, input.opts), n = OPT_CORES * (input.opts && input.opts.fast ? OPT_FAST_WALKS : 1);
  return base.concat([...Array(Math.max(0, n - base.length))].map((_, i) => 'mix' + (i + 1)));
}
// The best of the workers' results ([{i: share, out}]), whatever order they came back in: the higher score (the rank
// before the Pet DT / Charm+ passes, opt_search.js runGen), at the same score the one that changes fewer pieces of the
// set, then the first share. Before 2026-11-07 the first to come back won a tie, so a set searched alone and in a run
// over every set (at full speed: other timings) could get two sets of the same value (sets.buff.Doom's rings swapped)
function optBestOut(list, start){
  const rk = o => o.rank != null ? o.rank : o.score;
  const key = p => p && p.name ? p.name + '|' + (p.augs || []).join('|') : '';
  const moved = o => Object.keys(Object.assign({}, start, o.pieces)).filter(k => key(o.pieces[k]) !== key(start[k])).length;
  return list.reduce((a, b) => {
    const d = rk(b.out) - rk(a.out), tol = 1e-12 * Math.max(Math.abs(rk(a.out)), 1);
    if (d > tol) return b;
    if (d < -tol) return a;
    const ma = moved(a.out), mb = moved(b.out);
    return mb < ma || (mb === ma && b.i < a.i) ? b : a;
  }).out;
}
const walkLabel = w => /^mix\d+$/.test(w) ? t('orWalk_mix', {n: w.slice(3)}) : t('orWalk_' + w);
// Stop a search: its workers are dropped
// The search running: a new one or a stop moves it on, so what an older one sends is dropped
let OPT_SEQ = 0;
function optStop(){
  // a run over every set (opt_sets.js) waits for this search: told it was stopped
  osSearchEnd({stopped: true});
  OPT_SEQ++;
  optPoolStopAll();
  if (OPT_PAGE_STOP) { OPT_PAGE_STOP(); OPT_PAGE_STOP = null; }
  clearInterval(OPT_RUN_CLOCK); S._optRun = null;
  searchPark().replaceChildren();
  if ($('#overlay .optrun')) closeOverlay();
  S._optBusy = false; S._optProgress = null; render();
}
/* ---- the cost of the wrong set: each version of a weaponskill set under each profile's buffs ---- */
// The versions of a weaponskill set the file has (the set itself is the Full one), and the one GearSwap
// wears in each tier (shared/utils/party/support_tier.lua: Solo falls back to Group, then to the set; Trust to the set)
function tierVersions(s){
  const base = s.path.replace(/\.(Group|Solo|Trust)$/, ''), by = S._bypath || {};
  const out = [{name: 'Full', path: base, set: by[base] || s}];
  for (const v of ['Group', 'Solo', 'Trust']) if (by[base + '.' + v]) out.push({name: v, path: base + '.' + v, set: by[base + '.' + v]});
  const has = v => out.some(x => x.name === v);
  // without a .Trust version, trusts with a GEO and a BRD or a COR give the Full set (support_tier.lua)
  const worn = {Full: 'Full', Group: has('Group') ? 'Group' : 'Full', Solo: has('Solo') ? 'Solo' : has('Group') ? 'Group' : 'Full',
    Trust: has('Trust') ? 'Trust' : 'Full'};
  return {base, rows: out, worn};
}
// What the table compares: a weaponskill set's average damage, an engaged set's figure for the objective
// chosen (time to the weaponskill, DPS, TP a round); low: the smaller the better
function tierMetric(s){
  if (family(s.path, s.pieces) !== 'engaged')
    return {of: (set, draft) => draft ? wsDamage(set) : withoutTrial(() => wsDamage(set)), fmt: fmtDmg, low: false};
  const obj = (S.optOpts || {}).engObj || 'tp_real';
  const pick = {tp_real: r => r.real ? r.real.time : r.time, tp_time: r => r.time, dps: r => r.dps, tp_round: r => r.tp}[obj];
  const fmt = obj === 'dps' ? fmtDmg : obj === 'tp_round' ? v => String(Math.round(v)) : v => v.toFixed(2) + ' s';
  return {of: (set, draft) => { const r = engRound(set, !draft); return r ? pick(r) : null; }, fmt, obj, low: obj === 'tp_real' || obj === 'tp_time'};
}
// Each row's figure under each profile: {row name: {tier: value}}
function tierCosts(rows, m){
  const out = {};
  for (const row of rows) {
    out[row.name] = {};
    for (const tier of TIERS) out[row.name][tier] = withTierBuffs(tier, () => m.of(row.set, row.draft));
  }
  return out;
}
function openTierCost(s){
  showDialog('cmpdlg', t('tcTitle') + ` · <code>${esc(shortPath(s.path))}</code>`, `<p class="muted">${t('tcBusy')}</p>`, '');
  setTimeout(() => {
    const {rows, worn} = tierVersions(s);
    if (trialCount(s)) rows.push({name: 'draft', set: s, draft: true, label: t('tcDraft', {p: shortPath(s.path)})});
    const m = tierMetric(s);
    // the table: drawn by the Svelte application (atelier/src/screens/dialogs/tiercost.ts)
    ATELIER_DIALOG.show({cls: 'cmpdlg', titleHtml: t('tcTitle') + ` · <code>${esc(shortPath(s.path))}</code>`, tierCost: ATELIER_DIALOG.tierCostView(rows, worn, tierCosts(rows, m), m)});
  }, 30);
}
// The optimizer on a weaponskill set: your pieces for every slot but the weapons, the TP pieces of
// the job's config left to its rule (never in the set), at the TP chosen; the result goes to draft B
// Where the optimizer looks (S.optOpts.where): your pieces (wardrobes only when asked), your pieces at
// their best (top rank, cape materials at their maximum), or every item of the game your job wears
function optChoices(tpNames){
  const o = S.optOpts || {}, owned = ownedOf() || {}, choices = {};
  const reach = x => !o.wardOnly || !(x.where && x.where.length) || x.where.some(w => /^(Inventory|Wardrobe)/.test(w));
  // the pieces the player left out of the searches (trial.js)
  const excl = excludedOf();
  // a BST's jug broths are held ammo ("Calls Blackbeard Randy.", shared/utils/atelier/atelier_export_char.lua jug_broth) :
  // worn at Call Beast only (BST_PRECAST.lua equip_broth), never a search's piece
  const broth = (x, slot) => slot === 'ammo' && /^Calls /.test((pieceStats({name: x.name, id: x.id}, 'ammo') || {}).text || '');
  for (const slot of SLOTS) if (!['main', 'sub', 'range'].includes(slot)) {
    choices[slot] = (owned[slot] || []).filter(x => !tpNames.has(x.name) && !excl[x.name] && reach(x) && !broth(x, slot)).map(x => {
      // how many you have (an export before 2026-10-03 counts the bags they are in)
      const mine = ownRank({name: x.name, id: x.id, augs: x.augs, copies: x.count || (x.where || []).length, keep: true, rare: isRare(x.name)});
      const up = o.where === 'mine_max' ? upgradeOf(mine) : null;
      return up ? Object.assign({}, up.piece, {copies: mine.copies, keep: true, maxed: true, from: mine}) : mine; });
    if (o.where === 'all') choices[slot] = choices[slot].concat(gameChoices(slot, choices[slot], tpNames).filter(x => !excl[x.name]));
  }
  return choices;
}
// The paths of a path piece your copies are on: 'Path: X' as Windower writes Odyssey gear, or augments written out
// (Kaykaus: 'MP+80', '"Cure" spellcasting time -7%'...) matched against each path's stats at its top rank.
// A copy no path matches (an older rank) is on none, so every path stays offered.
function heldPaths(name, e, have){
  const out = new Set();
  for (const x of have) if (x.name === name) {
    const tag = (x.augs || []).map(a => a.match(/^Path:\s*(\w+)/)).find(Boolean);
    if (tag) { out.add(tag[1]); continue; }
    if (!(x.augs && x.augs.length)) continue;
    const read = FFXI.parse_augments(name, x.augs), got = Object.assign({}, read.extra, read.stats);
    for (const path of Object.keys(e.paths)) {
      const want = FFXI.ranked_stats(name, path, e.max_rank), keys = Object.keys(want);
      if (keys.length && keys.length === Object.keys(got).length && keys.every(k => got[k] === want[k])) out.add(path);
    }
  }
  return out;
}
// The game's items of a slot a job wears that a search may offer (level 99, an item level, or a piece read by name),
// by job and slot, once per catalogue: what changes from a search to the next (what you hold, the TP pieces, the
// one-choice rewards) is filtered in gameChoices
let GAME_IDX = {items: null, by: {}};
function gameItemsOf(job, slot){
  const items = FFXI.CATALOG.items;
  if (GAME_IDX.items !== items) GAME_IDX = {items, by: {}};
  const k = job + '|' + slot;
  if (!GAME_IDX.by[k]) GAME_IDX.by[k] = items.filter(it => it.slots.includes(FFXI.opt.SLOT[slot]) && it.jobs.includes(job) && (it.level >= 99 || it.ilvl > 0 || specialPiece(it.name)));
  return GAME_IDX.by[k];
}
// The game's items for a slot your job wears and you do not hold (level 99, an item level, or a piece whose effect the
// search reads by name: stat_opt.js specialPiece), a rank
// item on each of its paths at its top rank
function gameChoices(slot, have, tpNames){
  const job = S.job.toLowerCase(), names = new Set(have.map(x => x.name)), out = [], seen = new Set();
  // a one-choice mission reward you chose already rules out the group's others (FFXI.opt.EXCLUSIVE)
  const mine = new Set(Object.values(ownedOf() || {}).flat().map(x => x.name));
  const ruledOut = name => { const g = FFXI.opt.groupOf(name); return !!g && g.items.some(n => n !== name && mine.has(n)); };
  for (const it of gameItemsOf(job, slot)) {
    const e = rankedEntry(it.name);
    // a path piece you hold: its other paths stay in the search, as a copy to get
    const held = names.has(it.name) && e && e.paths ? heldPaths(it.name, e, have) : null;
    const ambu = slot === 'back' && FFXI.AMBU_CAPE_BY_NAME && FFXI.AMBU_CAPE_BY_NAME[it.name];
    if ((names.has(it.name) && !held && !ambu) || tpNames.has(it.name) || seen.has(it.name) || ruledOut(it.name)) continue;
    seen.add(it.name);
    // an Ambuscade cape bare is worth nothing: the search builds it at each material's maximum (opt.js ambuGen)
    // (one you hold too: the builds are other copies to make, yours stay as they are)
    if (ambu) { out.push({name: it.name, ambu: true, missing: true}); continue; }
    // engineFill: what the description gives that the engine's catalogue lacks, as for your own pieces (without it
    // a piece the catalogue reads nothing of counted for nothing: Hoxne Ampulla's Double Attack)
    // a rank piece at the rank asked for its family (opt_page.js rankWanted), none when not unlocked
    const rank = e && e.paths ? rankWanted(it.name, e) : null;
    if (e && e.paths && rank == null) continue;
    if (e && e.paths) for (const path of Object.keys(e.paths)) {
      if (!(held && held.has(path))) out.push(engineFill({name: it.name, augs: ['Path: ' + path], rank, missing: true}));
    }
    else out.push(engineFill({name: it.name, missing: true, copies: twoAllowed(it.name) ? 2 : 1, rare: isRare(it.name)}));
  }
  // rings and earrings: a second copy to get of one you have once, when the game lets you hold two
  if (/^(ring|ear)[12]$/.test(slot)) for (const x of have)
    if (x.copies === 1 && !(x.augs && x.augs.length) && !x.missing && twoAllowed(x.name)) out.push({name: x.name, missing: true, copies: 2});
  return out;
}
// The optimizer on a weaponskill set: weapons kept, the TP pieces of the job's config left to its rule
// (never in the set), at the TP chosen; the result goes to draft B
// The TP the average objective covers: the range chosen (the TP you weaponskill at), every 250
function avgRange(o){
  const clamp = v => Math.min(3000, Math.max(1000, Math.round((+v || 0) / 250) * 250));
  const a = clamp(o.tpFrom || 1000), b = clamp(o.tpTo || 3000);
  return a <= b ? [a, b] : [b, a];
}
function avgTps(o){ const [a, b] = avgRange(o), out = []; for (let x = a; x <= b; x += 250) out.push(x); return out; }
async function optimizeWs(s){
  if (!engineReady()) return;
  // a weaponskill our engine does not know: said plainly rather than a search over nothing
  const ws = wsForSet(s);
  if (!FFXI.opt.knowsWs(ws)) { S._toastSet = s.path; S.toast = t('optNoWs', {ws}); render(); return; }
  // the search starts from the set itself (the file, or what is in test in game), never from a draft:
  // a draft can hold pieces this search may not use (not yours, another reward of a one-choice group)
  const k = trialKey(s), base = lockedBase(s, withoutTrial(() => { S._noTpGear = true; try { return withWeapons(s).pieces; } finally { S._noTpGear = false; } }));
  S._optBusy = true; S._optProgress = null; render();
  const at = S.char + '|' + S.job, seq = OPT_SEQ;
  const r = await tpAskWait(s, base, null);
  if (!S._optBusy || seq !== OPT_SEQ || at !== S.char + '|' + S.job) { if (seq === OPT_SEQ && S._optBusy) optStop(); return; }
  const rule = tpRuleOf(r);
  const tpNames = new Set(((r && r.piece_list) || []).map(p => p.name).concat(Object.keys(ONLY_AUGS))), o = S.optOpts || {};
  // the TP config's pieces (Moonshade...) are not searched: the job's TP rule lays them at the weaponskill when
  // they help (opts.tpRule), never the set
  const start = startOf(base, lockedSlots(s)), choices = lockChoices(s, optChoices(tpNames));
  const weapons = o.freeWeapons ? weaponPairs(base, ws) : gripPairs(s, base, ws);
  if (weapons) choices.weapons = weapons;
  const input = {ctx: optContextInput(s), start, choices, prefilter: o.where === 'all' ? 25 : 0,
    opts: {fast: (o.search || 'fast') !== 'classic', tp: +(S.wsTp || 3000), tps: avgTps(o), tpRule: rule, objective: o.obj || 'damage', floor: Object.assign({pdt: +o.pdt || 0, mdt: +o.mdt || 0, sb: +o.sb || 0, hit: +o.hit || 0}, hpFloorWorn(s))}};
  optLaunch(s, k, input, o);
}
// The engaged optimizer: the set as it is (weapons kept), its objective, the defense floors; no TP piece rule
// The set a search starts from: in a search of your pieces (not every item of the game), a piece of the set you do not
// hold leaves it (Revelation Gaunt. pushed from an every-item search), the search fills its slot with yours
// (a locked slot keeps its piece, yours or not: `locked`)
function startOf(base, locked = []){
  const start = optPieces(base), owned = ownedOf() || {}, excl = excludedOf();
  // a piece left out of the searches is not started from either (a locked slot keeps its piece)
  for (const slot of Object.keys(start)) if (!['main', 'sub', 'range'].includes(slot) && !locked.includes(slot) && excl[start[slot].name]) delete start[slot];
  // a piece in both ears (both rings) held once: the search's moves check the piece they bring, never the two the set
  // starts with, so a set written so (an older search, a copy upgraded since: Kaories' WHM idle.Refresh with two
  // Ebers Earring +1, 2026-10-25) stayed as it was. Kept in the first slot, the other one searched. Only when the
  // export counts the copies: a piece listed with no count nor bag (Moonlight Ring, held twice, each written with its
  // wardrobe) or the two in different bags stay
  for (const [a, b] of [['ear1', 'ear2'], ['ring1', 'ring2']]) {
    if (!start[a] || !start[b] || start[a].name !== start[b].name || locked.includes(b)) continue;
    if (start[a].bag && start[b].bag && start[a].bag !== start[b].bag) continue;
    const list = (owned[a] || []).filter(x => x.name === start[a].name);
    if (!list.length || list.some(x => x.count == null && !(x.where || []).length)) continue;
    if (list.reduce((n, x) => n + (x.count || x.where.length), 0) < 2) delete start[b];
  }
  if ((S.optOpts || {}).where === 'all') return start;
  for (const slot of Object.keys(start)) if (!['main', 'sub', 'range'].includes(slot) && !locked.includes(slot) && !(owned[slot] || []).some(x => x.name === start[slot].name)) delete start[slot];
  return start;
}
// Weapons not free: under a two-handed weapon (a grip's), the main hand stays and its grip is searched (Utu Grip or
// Telopanos Grip under Foenaria); a one-handed weapon's off hand is a weapon of the player's choice, kept. Null to
// search no weapon
function gripPairs(s, base, ws){
  const it = itemOf(base.main && base.main.name);
  if (!isTwoHanded(it) || lockedSlots(s).includes('sub')) return null;
  return weaponPairs(base, ws, base.main.name);
}
// Free weapons: every main hand you hold with every off hand it can take ({main, sub}, the engine's "weapons"
// choice), the pair worn now first; a copy in both hands only when you have two. Searching every item of the game
// (S.optOpts.where 'all'), the game's weapons your job wears join yours (gameChoices: a mythic or prime too)
function weaponPairs(base, ws, keepMain){
  const owned = ownedOf() || {}, piece = x => ownRank({name: x.name, augs: x.augs, copies: x.count || (x.where || []).length, keep: true});
  const all = (S.optOpts || {}).where === 'all', none = new Set();
  const hand = slot => { const mine = (owned[slot] || []).map(piece); return all ? mine.concat(gameChoices(slot, mine, none)) : mine; };
  // a weaponskill set: only the weapons that open that weaponskill (its combat skill; a relic or prime's own)
  const opens = ws ? opensWs(ws) : null;
  // a hand you chose (a weaponskill's held weapon or off hand, an engaged set's forced ones) stays: only the other is
  // searched. A forced hand the set does not wear is no choice of its (a midcast set's own weapons go over the page's
  // forced ones, weapons.js withWeapons: a BLM's nuke set kept Daybreak, forced by an older engaged search, unseen)
  const forced = slot => { const f = slotForce()[slot]; return f && base[slot] && base[slot].name === f.name ? f.name : undefined; };
  const fixMain = keepMain || (ws ? heldWeapon(ws) : forced('main')), fixSub = ws ? ((S.heldSub || {})[heldKey(ws)] || {}).name : forced('sub');
  const mains = hand('main').filter(x => (!opens || opens(x.name)) && (!fixMain || x.name === fixMain));
  const subs = hand('sub').filter(x => !fixSub || x.name === fixSub), out = [];
  const now = optPieces({main: base.main, sub: base.sub});
  // the main hand kept and not among yours (a weapon of the game, or a set's you do not hold): it stays the set's
  if (keepMain && !mains.length && now.main) mains.push(now.main);
  if (now.main) out.push({main: now.main, sub: now.sub || null});
  for (const m of mains) {
    const fits = subs.filter(x => subFits(m, x) && !(x.name === m.name && !(m.copies > 1)));
    if (!fits.length) out.push({main: m, sub: null});
    for (const x of fits) out.push({main: m, sub: x});
  }
  return out;
}
async function optimizeEngaged(s){
  if (!engineReady()) return;
  const k = trialKey(s), o = engOpts(s), base = lockedBase(s, withoutTrial(() => withWeapons(s).pieces));
  // pieces worn for their TP Bonus only (ONLY_AUGS: Moonshade) do nothing for an engaged set
  const choices = lockChoices(s, optChoices(new Set(Object.keys(ONLY_AUGS))));
  // (a Kraken Club set keeps the club in the off hand: eng_modes.js engKrakenOnly)
  const weapons = engKrakenOnly(s, o.freeWeapons ? weaponPairs(base) : gripPairs(s, base));
  if (weapons) choices.weapons = weapons;
  const input = {ctx: engContextInput(s), start: startOf(base, lockedSlots(s)), choices, prefilter: o.where === 'all' ? 25 : 0,
    opts: {fast: (o.search || 'fast') !== 'classic', objective: o.engObj || 'tp_real', wsAt: +o.engAt || 1000, floor: Object.assign({pdt: +o.pdt || 0, mdt: +o.mdt || 0, sb: +o.sb || 0}, hpFloorWorn(s))}};
  // a BST's set worn while both fight: the pieces carry their Pet damage taken and the levels they give the pet, which
  // the search adds once the master's set is found, within 0.1 % of its figure (bst_pet.js, opt.js petDtPass)
  if (isPetBoth(s)) {
    const withDt = (p, slot) => p && !isEmpty(p) ? Object.assign({}, p, {petdt: petDtOf(p, slot), petlv: petLvOf(p, slot)}) : p;
    for (const slot of Object.keys(choices)) if (slot !== 'weapons') choices[slot] = choices[slot].map(p => withDt(p, slot));
    for (const slot of Object.keys(input.start)) input.start[slot] = withDt(input.start[slot], slot);
    input.opts.petDtTol = PET_ENG.bothTol;
  }
  // the whole fight (opt_page.js, atelier/cycle.js): its weaponskill set and how you play, as data for the workers
  if (o.engObj === 'cycle') {
    const cy = cycleReady() && !isJumpSet(s.path) ? cycleInput(s) : null;
    if (!cy) { S._toastSet = s.path; S.toast = t('cycNoWs'); render(); return; }
    input.opts.cycle = cy;
  }
  optLaunch(s, k, input, Object.assign({}, o, {eng: true}));
}
// The nuke optimizer: a set of elemental magic or ninjutsu (opt_page.js isNukeSet), weapons kept, no defense floor (a
// nuke set is worn for the cast only); its value is the average damage over the spells chosen (FFXI.opt.nuke)
async function optimizeNuke(s){
  if (!engineReady()) return;
  const k = trialKey(s), o = S.optOpts || {}, base = lockedBase(s, withoutTrial(() => withWeapons(s).pieces));
  const choices = lockChoices(s, optChoices(new Set(Object.keys(ONLY_AUGS))));
  // a mage's staff and grip are part of the nuke set: with free weapons they go in the try like the other pieces
  if (o.freeWeapons) choices.weapons = weaponPairs(base);
  // the slots the game fills over the set in the situation chosen (nuke_layers.js: the automatic belt, MPConservation)
  for (const slot of nukeSituation(s).fixed) delete choices[slot];
  const input = {ctx: nukeContextInput(s), start: startOf(base, lockedSlots(s)), choices, prefilter: o.where === 'all' ? 25 : 0,
    opts: {fast: (o.search || 'fast') !== 'classic', objective: 'nuke', floor: {}}};
  optLaunch(s, k, input, Object.assign({}, o, {nuke: true}));
}
// A search in the worker (on the page when there is none), its progress, then its result
async function optLaunch(s, k, input, o){
  S._optBusy = true; S._optProgress = null; render();
  const seq = ++OPT_SEQ, at = S.char + '|' + S.job, mine = () => seq === OPT_SEQ && S._optBusy;
  // a case our engine does not compute says why (atelier/calc/calc_bridge.js; fight_stats.js notComputedText)
  const fail = msg => { if (!mine()) return; osSearchEnd({error: notComputedText(msg)}); optStop(); S._toastSet = s.path; S.toast = notComputedText(msg); render(); };
  const why = notComputedFor(input);
  if (why) return fail(why);
  // the walks shared among the cores, round robin
  input.opts.scratch = !!S._optScratch;
  const starts = optWalks(input), n = optCores(starts.length), shares = [...Array(n)].map(() => []);
  // smooth (25 ms of work, 25 of pause: about half a core a worker) or full speed (no pause: about twice as fast)
  input.pace = (S.optOpts || {}).fullSpeed ? {work: 50, rest: 0} : {work: 25, rest: 25};
  starts.forEach((x, i) => shares[i % n].push(x));
  optRunOpen(s, o, starts, n, input.opts.floor);
  // the end: the best walk, shown done a moment before the result comes up
  const finish = out => { optRunDone(); setTimeout(() => {
    if (!mine()) return;
    // left for another character or job meanwhile: the result is not laid on that one's sets
    if (at !== S.char + '|' + S.job) return optStop();
    optResult(s, k, out, out.gains, o); }, 500); };
  // the end: every walk waited for, the best kept (optBestOut). Before 2026-11-07 the classic search did not wait for
  // the shuffled walks once the main ones were done: which had finished by then hung on the speed (a run over every set
  // goes at full speed), so the same set searched twice could come out two ways
  const outs = [], left = new Set(starts);
  let workers = null;
  const end = () => {
    // ranked on the score before the Pet DT / Charm+ passes (opt.js runGen `rank`), which lower it on purpose
    const best = optBestOut(outs, input.start);
    best.evals = outs.reduce((a, b) => a + b.out.evals, 0);
    optPoolGive(workers);
    finish(best);
  };
  try {
    workers = optPoolRun(input, shares, {
      step: (i, p) => { if (mine()) optRunStep(i, p); },
      fail: msg => fail(msg),
      done: (i, out) => {
        if (!mine()) return;
        outs.push({i, out});
        shares[i].forEach(walk => { optRunWalkDone(walk); left.delete(walk); });
        if (!left.size || outs.length === shares.length) end();
      }});
  } catch (e) { workers = null; }
  if (!workers) {   // no worker (an old browser): the search runs on the page, paced so it stays usable
    OPT_PAGE_STOP = FFXI.opt.runPaced(Object.assign({}, input, {starts}), p => optRunStep(0, p), out => { OPT_PAGE_STOP = null; finish(out); }, e => fail(e.message), input.pace.work, input.pace.rest);
    return;
  }
}
/* ---- the search window: what each walk does, the best set found so far, the moves as they come ---- */
// S._optRun: {t0, cores, walks: {walk: {stage, phase, round, evals, start, best, done}}, feed: [], series: [[s, value]],
// fmt, low (a time: smaller is better), done}
function optRunOpen(s, o, starts, cores, floor){
  const eng = !!o.eng, obj = o.stat || (eng ? (o.engObj || 'tp_real') : (o.obj || 'damage')), time = eng && /^tp_(real|time)$/.test(obj);
  const fmt = o.stat ? statFmt(obj) : time ? v => v.toFixed(2) + ' s' : eng && engObjFmt(obj) ? engObjFmt(obj) : obj === 'tp_round' || obj === 'tp_return' ? v => String(Math.round(v)) : v => fmtDmg(v);
  const objLabel = o.nuke ? t(isBurstSet(s.path) ? 'nukeObjMb' : 'nukeObj') : o.stat ? t('statObj_' + obj) : eng ? t('engObj_' + obj) : t('optObj_' + obj, {tp: S.wsTp || 3000, a: o.tpFrom || 1000, b: o.tpTo || 3000});
  const floors = !floor ? [] : o.stat ? [['pdt', 'DT+PDT ≤'], ['mdt', 'DT+MDT ≤'], ['hp', t('statHpMin')], ['hpMax', t('statHpMax')], ['sird', t('statSird')], ['fc', t('statFc')],
    ['ecrit', t('statEcrit')], ['enmity', t('statEnm')], ['phalanx', t('statPhx')]].filter(([k]) => +floor[k]).map(([k, l]) => `${l} ${floor[k]}`)
    : [['pdt', pdtLabel() + ' ≤'], ['mdt', 'DT+MDT ≤'], ['sb', 'Subtle Blow ≥'], ['hp', t('statHpMin')], ['hpMax', t('statHpMax')]].filter(([k]) => +floor[k]).map(([k, l]) => `${l} ${floor[k]}`);
  // the window is the Svelte application's (atelier/src/screens/optimizer/OptRun.svelte): it reads this, told when it
  // changes (ATELIER_RUN.changed)
  const mog = mogOn();
  S._optRun = {t0: performance.now(), cores, fmt, objLabel, low: time || obj === 'hpLow', done: false, walks: Object.fromEntries(starts.map(w => [w, {evals: 0}])), feed: [], series: [],
    path: s.path, chips: [objLabel, t('optWhere_' + ((S.optOpts || {}).where || 'mine')), ...floors], mog, sceneHtml: mog ? mogSceneHTML() : '', moves: 0};
  searchPark().replaceChildren();
  ATELIER_RUN.open(S._optRun);
  mogStart();
  clearInterval(OPT_RUN_CLOCK);
  OPT_RUN_CLOCK = setInterval(optRunClock, 100);
}
let OPT_RUN_CLOCK = null;
// The clock, the tries a second, and the big number easing to the best found
function optRunClock(){
  const R = S._optRun;
  if (!R) { clearInterval(OPT_RUN_CLOCK); return; }
  const sec = (performance.now() - R.t0) / 1000, evals = optRunEvals(R);
  if (!R.done) R.clockText = sec.toLocaleString(S.lang === 'fr' ? 'fr-FR' : 'en-US', {minimumFractionDigits: 1, maximumFractionDigits: 1}) + ' s';
  R.rateText = t('orRate', {n: evals.toLocaleString(), r: Math.round(evals / Math.max(sec, .1)).toLocaleString()});
  const best = optRunBest(R);
  if (best) R.shown = R.shown == null ? best.raw : R.shown + (best.raw - R.shown) * .25;
  ATELIER_RUN.changed();
}
// The tries so far: each worker's count (it runs over all of that worker's walks)
const optRunEvals = R => Object.values(R.byWorker || {}).reduce((a, n) => a + n, 0);
// The best set found so far over every walk: one that keeps the floors (a walk with no floor does not count yet)
function optRunBest(R){
  let best = null;
  for (const w of Object.values(R.walks)) {
    if (!w.best || w.stage === 'nofloor' || w.best.miss) continue;
    if (!best || (R.low ? w.best.raw < best.raw : w.best.raw > best.raw)) best = w.best;
  }
  return best;
}
// One worker's progress: its walk's state, the moves it kept, the curve of the best found
function optRunStep(i, p){
  const R = S._optRun;
  if (!R || !p.walk) return;
  const w = R.walks[p.walk] = Object.assign(R.walks[p.walk] || {}, {stage: p.stage, phase: p.phase, round: p.round, start: p.startRaw, best: p.best});
  // a worker counts its tries over all its walks: what it did since its last step goes to the walk it is on
  R.byWorker = R.byWorker || {};
  w.evals = (w.evals || 0) + Math.max(0, p.evals - (R.byWorker[i] || 0));
  R.byWorker[i] = p.evals;
  R.start = R.start == null ? p.startRaw : R.start;
  w.painted = true;
  for (const m of p.moves || []) R.feed.unshift(Object.assign({walk: p.walk, at: (performance.now() - R.t0) / 1000, id: ++R.moves}, m));
  R.feed.length = Math.min(R.feed.length, 40);
  const best = optRunBest(R);
  const last = R.series[R.series.length - 1];
  if (best && (!last || last[1] !== best.raw)) R.series.push([(performance.now() - R.t0) / 1000, best.raw]);
  // the window may be closed (Hide): the compartment's line goes on
  S._optProgress = {round: p.round, evals: optRunEvals(R), ms: performance.now() - R.t0};
  ATELIER_RUN.changed();
}
// The search window once done: the set found against yours (the value, the pieces changed, the figures, what is still
// to get), and what to do next: Compare in detail, test it in game, push it to GearSwap
function optRunResult(s, res, tr, plain, gains){
  const R = S._optRun, dlg = document.querySelector('.optrun');
  if (!R || !dlg) return;
  // the same piece in another copy (other augments, another path or rank) said so
  const changes = Object.keys(tr).map(slot => { const from = plain[slot] && !isEmpty(plain[slot]) ? plain[slot].name : '—', to = tr[slot] ? tr[slot].name : t('empty');
    return {slot, from, name: tr[slot] ? tr[slot].name : null, to: to === from ? to + ' · ' + t('orOtherCopy') : to}; });
  // (a figure at 0 on both, an enfeebling set's potency for spells that have none: no gain, not 0 / 0)
  const dRaw = (R.low ? res.start.raw / res.best.raw - 1 : res.best.raw / res.start.raw - 1) * 100, d = isFinite(dRaw) ? dRaw : 0;
  const fig = [];
  if (res.best.round && res.start.round) for (const c of Object.values(ENG_COLS)) {
    const a = c.get(res.start.round), b = c.get(res.best.round);
    if (a != null && b != null) fig.push([c.label || t(c.key), c.fmt(a), c.fmt(b), Math.abs(a - b) < 1e-9 ? 0 : (c.low ? b < a : b > a) ? 1 : -1]);
  }
  // a set judged by its stats (stat_opt.js): the lines of its result, its objectives first, then the heal, the gap,
  // each action's enmity and the floors, your set beside the try
  const relevant = res.best.stats ? statRelevant(s, statOpts(s).objs) : null;
  if (res.best.stats && res.start.stats) for (const r of statRows(s).filter((r, i) => i < 3 || ['gap', 'ref', 'cure4', 'pdt', 'mdt'].includes(r.id) || r.id.startsWith('act:') || relevant.has(r.id))) {
    const a = r.get(res.start.stats), b = r.get(res.best.stats);
    if (a == null && b == null) continue;
    fig.push([r.label, r.fmt(a), r.fmt(b), Math.abs((b || 0) - (a || 0)) < 1e-9 ? 0 : (r.low ? b < a : b > a) ? 1 : -1]);
  }
  // a weaponskill: its average damage (or TP return), then its hit rates
  if (!res.best.round && !res.best.stats) {
    fig.push([t('orObjWs'), R.fmt(res.start.raw), R.fmt(res.best.raw), Math.abs(res.best.raw - res.start.raw) < 1e-9 ? 0 : res.best.raw > res.start.raw ? 1 : -1]);
    const h0 = res.start.hits || {}, h1 = res.best.hits || {}, pc = h => h == null ? '—' : Math.floor(h) + ' %';
    for (const [k, key] of [['first', 'wsvHit1'], ['rest', 'wsvHit2']]) if (h0[k] != null || h1[k] != null)
      fig.push([t(key), pc(h0[k]), pc(h1[k]), Math.floor(h1[k] || 0) === Math.floor(h0[k] || 0) ? 0 : (h1[k] || 0) > (h0[k] || 0) ? 1 : -1]);
  }
  const sd = res.start.def || {}, bd = res.best.def || {};
  if (!res.best.stats) for (const [k, label, low] of [['pdt', bd.fan ? t('pdtFan') : 'DT+PDT', true], ['mdt', 'DT+MDT', true], ['sb', 'Subtle Blow', false]]) {
    // damage taken counts down to its -50 cap only: past it, no better
    // (with Fan Dance the figure is the total, the cap already inside it: nothing to cut)
    const a = Math.round(sd[k] || 0), b = Math.round(bd[k] || 0), cut = low && !(k === 'pdt' && bd.fan), ca = cut ? Math.max(a, -50) : a, cb = cut ? Math.max(b, -50) : b;
    if (a || b) fig.push([label, String(a), String(b), ca === cb ? 0 : (low ? cb < ca : cb > ca) ? 1 : -1]);
  }
  const live = liveWrite();
  const porter = (slot, name) => { const at = (ownedOf()[slot] || []).filter(x => x.name === name);
    return at.length && at.every(atPorter) ? ` <span class="orporter">${esc(at[0].where.map(whereLabel).join(', '))}</span>` : ''; };
  // the window draws it (OptRun.svelte): the moogle's scene stops first, its cheering starts once it is drawn
  mogClear(dlg);
  R.result = {best: res.best.raw, start: res.start.raw, mogWinHtml: mogWinHTML(changes.length > 0), figs: fig,
    changes: changes.map(c => ({iconHtml: icon(c.name), slot: SLOT_NAMES[S.lang][c.slot] || c.slot, from: c.from, to: c.to, porterHtml: porter(c.slot, c.to)})),
    lack: gains.map(g => ({name: g.piece.name, gain: `${g.gain >= 0 ? '+' : ''}${g.gain.toFixed(1)} %`})),
    footer: {set: s, live, changed: changes.length > 0}};
  ATELIER_RUN.changed();
  mogWinStart(dlg);
}
// A walk finished: its card says so
function optRunWalkDone(walk){
  const R = S._optRun;
  if (R && R.walks[walk]) { R.walks[walk].done = true; ATELIER_RUN.changed(); }
}
// The whole search finished: the window shows it a moment, then the result takes its place
function optRunDone(){
  const R = S._optRun;
  if (!R) return;
  R.done = true; clearInterval(OPT_RUN_CLOCK); optRunClock(); mogStop();
  Object.keys(R.walks).forEach(optRunWalkDone);
  ATELIER_RUN.changed();
}
// The result into draft B (the pieces that differ from the set itself), the message, then Compare
function optResult(s, k, res, gains, o){
  S._opView = 'detail';
  const tr = {}, plain = withoutTrial(() => { S._noTpGear = true; try { return withWeapons(s).pieces; } finally { S._noTpGear = false; } });
  // a slot another piece blocks (Onca Suit: no leggear) is emptied in the draft
  const blocked = FFXI.opt.blocked(res.pieces);
  // a Dual Wield tier (eng_modes.js): only what differs from the engaged set it is laid on
  if (o.dw) dwTrialOf(s, res, o.dw, tr);
  else for (const slot of Object.keys(blocked)) if (plain[slot] && !isEmpty(plain[slot])) tr[slot] = null;
  if (!o.dw) for (const [slot, p] of Object.entries(res.pieces)) {
    // a stats set's weapons go in its try like its other pieces (a PLD's shield is part of each set); the other
    // optimizers force them in the page (below)
    if ((['main', 'sub'].includes(slot) && !o.stat && !o.nuke) || slot === 'range' || !p || blocked[slot]) continue;
    const a = plain[slot], piece = {name: p.name, augs: p.augs};
    if (p.rank != null) piece.rank = p.rank;
    if (p.capeMax) piece.capeMax = true;
    // the file names the piece alone and you hold one copy of it: GearSwap wears that copy, nothing changes
    if (a && !isEmpty(a) && a.name === p.name && !(a.augs && a.augs.length) && !p.maxed && !p.missing
      && ((ownedOf() || {})[slot] || []).filter(x => x.name === p.name).length <= 1) continue;
    if (!samePiece(piece, a && !isEmpty(a) ? optPieces({x: a}).x : null)) tr[slot] = piece;
  }
  // a movement set's search started empty (stat_opt.js moveSet): a piece of the set it did not keep is taken out, and
  // an `empty` the file writes too (laid over the idle set, it strips the idle's piece: push.js overlaySet)
  // (withWeapons leaves the `empty` out: the set's own pieces bring them back)
  if (o.clearRest) for (const [slot, a] of Object.entries(Object.assign({}, s.pieces, plain))) if (!res.pieces[slot] && a && !['main', 'sub', 'range'].includes(slot)) tr[slot] = null;
  // free weapons: the pair found becomes the page's forced weapons (never written to a set)
  let weapons = '';
  const wsHeld = !o.eng && wsOfSet(s);
  if (o.freeWeapons && !o.stat && !o.nuke) for (const slot of ['main', 'sub']) {
    const p = res.pieces[slot], a = plain[slot];
    if (!p || samePiece({name: p.name, augs: p.augs}, a && !isEmpty(a) ? optPieces({x: a}).x : null)) continue;
    if (!wsHeld) setForce(slot, {name: p.name, augs: p.augs});
    else if (slot === 'main') S.held = Object.assign({}, S.held, {[heldKey(wsHeld)]: p.name});
    else S.heldSub = Object.assign({}, S.heldSub, {[heldKey(wsHeld)]: {name: p.name, augs: p.augs}});
    weapons = 'set';
  }
  if (weapons) weapons = ' ' + t(wsHeld ? 'wsWeapons' : 'engWeapons', {m: (res.pieces.main || {}).name || '—', s: (res.pieces.sub || {}).name || '—'});
  // the result becomes the try, labelled (profile, time); the try it replaces stays one click away
  const now = new Date(), hm = String(now.getHours()).padStart(2, '0') + ':' + String(now.getMinutes()).padStart(2, '0');
  const keep = x => ({raw: x.raw, def: x.def, hits: x.hits || null});
  S.drafts[k] = Object.assign({}, S.drafts[k], {prev: Object.assign({}, S.trial[k] || {}), info: {tier: buffTier(), at: hm},
    res: {start: keep(res.start), best: keep(res.best), obj: o.stat || (o.eng ? o.engObj || 'tp_real' : o.obj || 'damage'), tp: +(S.wsTp || 3000), range: avgRange(o),
      floor: {pdt: o.pdt, mdt: o.mdt, sb: o.sb, hit: o.hit}}});
  // a locked slot stays as it was shown, whatever the search hands back for it (its tried piece, or emptied)
  for (const slot of lockedSlots(s)) { const old = S.trial[k] || {}; if (slot in old) tr[slot] = old[slot]; else delete tr[slot]; }
  if (Object.keys(tr).length) S.trial[k] = tr; else delete S.trial[k];
  const low = o.eng && /^tp_(real|time)$/.test(o.engObj || 'tp_real');
  const gain = (((low ? res.start.raw / res.best.raw : res.best.raw / res.start.raw) - 1) * 100).toFixed(1), def = res.best.def || {};
  const extra = gains.map(g => `${g.piece.name}${g.piece.rank != null ? ' R' + g.piece.rank : ''}${g.piece.capeMax ? ' (max)' : ''} ${g.gain >= 0 ? '+' : ''}${g.gain.toFixed(1)} %`);
  S._toastSet = s.path;
  // the set itself short of the floors: the result meets them, which can cost damage
  // the hit rates: the first hit (+100 accuracy), then the others (a multi-hit weaponskill's, a double / triple attack's)
  const pct = h => h == null ? '—' : Math.floor(h) + ' %', bh = res.best.hits;
  const hitTxt = bh ? ' ' + t('optHit', {f: pct(bh.first), h: pct(bh.rest), e: enemyKey(buffState().enemy)}) : '';
  const sd = res.start.def || {}, startMiss = res.start.miss ? t('optStartMiss', {p: Math.round(sd.pdt || 0), m: Math.round(sd.mdt || 0), sb: Math.round(sd.sb || 0), h: pct((res.start.hits || {}).rest)}) + ' ' : '';
  const engV = v => engObjFmt(o.engObj) ? engObjFmt(o.engObj)(v) : o.engObj === 'dps' || o.engObj === 'cycle' ? fmtDmg(v) : o.engObj === 'tp_round' ? Math.round(v) : v.toFixed(2) + ' s';
  const done = o.eng ? t('engDone_' + (o.engObj || 'tp_real'), {a: engV(res.start.raw), b: engV(res.best.raw), g: (+gain > 0 ? '+' : '') + gain, n: Object.keys(tr).length,
      p: Math.round(def.pdt || 0), m: Math.round(def.mdt || 0), sb: Math.round(def.sb || 0)})
    : t(o.obj === 'tp_return' ? 'optDoneTp' : 'optDone', {g: gain, d: fmtDmg(res.best.raw), n: Object.keys(tr).length,
      p: Math.round(def.pdt || 0), m: Math.round(def.mdt || 0), sb: Math.round(def.sb || 0)});
  // a Dual Wield tier says what it was searched over, at which magic haste and for which subjob
  const dwTxt = o.dw ? t('dwDone', {t: o.dw.tier, p: shortPath(o.dw.basePath), h: o.dw.haste, sub: o.dw.sub}) + ' · ' : '';
  S.toast = `${buffTier()} · ` + dwTxt + startMiss + (res.best.miss ? t('optMiss') + ' ' : '') + done + weapons + hitTxt + (extra.length ? ' ' + t('optLack', {l: extra.join(' · ')}) : '');
  // nothing better found: said plainly, draft B left empty, no Compare with nothing to compare
  if (!Object.keys(tr).length) S.toast = `${buffTier()} · ` + dwTxt + startMiss + (o.eng ? t('engSame', {v: engV(res.best.raw)}) : t('optSame', {d: fmtDmg(res.best.raw)})) + weapons + hitTxt;
  // a set judged by its stats (stat_opt.js): its own words, no damage
  if (o.stat) S.toast = `${buffTier()} · ` + (res.best.miss ? t('optMiss') + ' ' : '') + statDoneText(s, res, tr) + weapons + (extra.length ? ' ' + t('optLack', {l: extra.join(' · ')}) : '');
  save();
  S._optBusy = false; render();
  // a run over every set (opt_sets.js) takes the result and goes on to the next set: no result window, no Compare
  if (osSearchEnd({res, tr, o})) { searchPark().replaceChildren(); S._optRun = null; return; }
  // the search window still open: the result in it, with what to do next; else Compare
  if (S._optRun && $('#overlay .optrun')) optRunResult(s, res, tr, plain, gains);
  else if (Object.keys(tr).length) openCompare(s);
  searchPark().replaceChildren();
  S._optRun = null;
}
