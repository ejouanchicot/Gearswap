// GearSwap Atelier · eng_modes.js: an engaged set's goal by its mode, and the Dual Wield tiers searched for that mode
// (SPEC notes/docs-perso/engaged-par-mode-2026-11-06).
// - A mode is read from the set's name, on every job: sets.engaged and .STP the time to the weaponskill, .Acc the share
//   of the attacks that land then that time, .SB Subtle Blow (to its cap) then that time, a Kraken Club set (.PDTKC,
//   NaeglingKC: weapons.js isKraken) the time with the club kept in the off hand. Each holds DT+PDT -50 and DT+MDT -21
//   (Shell V's -29 does the rest: it counts under the same -50 cap, statlines.ts; -29 until 2026-11-06 took Shell's
//   figure for the gear's). A .Group / .Solo / .Trust version is its mode's.
//   WAR names its Subtle Blow mode .SubtleBlow, and orders it its own way: Subtle Blow, then DT, then the time, no DT
//   floor held (ENG_JOB_MODE, opt_round.js "sb_dt").
//   The goal and limits chosen on the optimizer's page for such a set are kept for that set (S.optOpts.engBy[path]):
//   they come before the mode's (ws_page.js engOpts). Another engaged set keeps the page's shared settings.
// - A Dual Wield tier (sets.DW.<Tier>, or a mode's own sets.DW.<Mode>.<Tier>: shared/utils/equipment/dual_wield.lua)
//   is searched laid over its mode's engaged set (the common tiers over sets.engaged), at the tier's magic haste (0,
//   15, 30 %, the cap 43.75 %), for the subjob that needs the most Dual Wield (/DNC: Dual Wield II), with the mode's
//   goal and limits; only the slots that differ from the engaged set go in the tier.
// The run over every engaged set and its tiers is "Tout optimiser" (opt_sets.js) with its "Engaged only" shortcut.
// (loaded after opt_sets.js: see atelier/src/legacy/files.ts)
//
// @file    atelier/app/js/eng_modes.js
// @author  ejouanchicot

Object.assign(T.fr, {engObj_acc: 'Chance de toucher, puis temps jusqu’à la WS', engObj_sb: 'Subtle Blow au cap, puis temps jusqu’à la WS',
  objD_acc: 'le plus de coups qui touchent, puis la vitesse', objD_sb: 'le Subtle Blow au plus haut (75 %), puis la vitesse',
  objTip_acc: 'La part des attaques d’un round qui touchent (les deux mains, plafonnées à 99 % en main principale à une main, 95 % en main gauche et à deux mains : BG Wiki Hit_Rate). À chance égale, le temps réel jusqu’à la WS départage.',
  objTip_sb: 'Le Subtle Blow du set comme le jeu le compte : I et II plafonnés à 50 % chacun, 75 % ensemble (BG Wiki Subtle_Blow). À Subtle Blow égal, le temps réel jusqu’à la WS départage.',
  engDone_acc: 'Optimisé : chance de toucher {a} → {b}, {n} pièce(s) changée(s) dans ton essai · DT+PDT {p} · DT+MDT {m} · Subtle Blow {sb}.',
  engDone_sb: 'Optimisé : Subtle Blow {a} → {b}, {n} pièce(s) changée(s) dans ton essai · DT+PDT {p} · DT+MDT {m}.',
  engObj_sb_dt: 'Subtle Blow au cap, puis DT, puis temps jusqu’à la WS', objD_sb_dt: 'le Subtle Blow (75 %), puis le DT, puis la vitesse',
  objTip_sb_dt: 'D’abord le Subtle Blow du set comme le jeu le compte (I et II 50 % chacun, 75 % ensemble). À Subtle Blow égal, le plus de DT : DT+PDT jusqu’à -50 % et DT+MDT jusqu’à -21 % (Shell V fait le reste). À égalité, le temps réel jusqu’à la WS.',
  engDone_sb_dt: 'Optimisé : Subtle Blow {a} → {b}, {n} pièce(s) changée(s) dans ton essai · DT+PDT {p} · DT+MDT {m}.',
  engHitLbl: 'Chance de toucher (round)', engModeNote: 'But de ce set par son nom ({m}) : gardé pour ce set seulement.', engModeReset: 'But du mode',
  dwNoBase: 'Pas de set engaged sous ce palier ({p}).', dwNoTwo: 'Le set {p} ne tient pas deux armes : pas de Dual Wield à chercher.',
  dwDone: 'Palier {t} sur {p} · Haste magique {h} % · /{sub}', osOnlyEng: 'Engaged seulement', osEngBtn: 'Optimiser tous les engaged',
  osEngTip: 'Chaque mode engaged avec son but, puis ses paliers Dual Wield, sans rien écrire avant que tu coches.'});
Object.assign(T.en, {engObj_acc: 'Hit chance, then time to the weaponskill', engObj_sb: 'Subtle Blow to its cap, then time to the weaponskill',
  objD_acc: 'the most hits landing, then speed', objD_sb: 'Subtle Blow as high as it goes (75 %), then speed',
  objTip_acc: 'The share of a round’s attacks that land (both hands, capped at 99 % for a one-handed main hand, 95 % for an off hand and a two-handed weapon: BG Wiki Hit_Rate). At equal chance, the real time to the weaponskill breaks the tie.',
  objTip_sb: 'The set’s Subtle Blow as the game counts it: I and II capped at 50 % each, 75 % together (BG Wiki Subtle_Blow). At equal Subtle Blow, the real time to the weaponskill breaks the tie.',
  engDone_acc: 'Optimized: hit chance {a} → {b}, {n} piece(s) changed in your draft · DT+PDT {p} · DT+MDT {m} · Subtle Blow {sb}.',
  engDone_sb: 'Optimized: Subtle Blow {a} → {b}, {n} piece(s) changed in your draft · DT+PDT {p} · DT+MDT {m}.',
  engObj_sb_dt: 'Subtle Blow to its cap, then DT, then time to the weaponskill', objD_sb_dt: 'Subtle Blow (75 %), then DT, then speed',
  objTip_sb_dt: 'First the set’s Subtle Blow as the game counts it (I and II 50 % each, 75 % together). At equal Subtle Blow, the most DT: DT+PDT down to -50 % and DT+MDT down to -21 % (Shell V does the rest). Then the real time to the weaponskill.',
  engDone_sb_dt: 'Optimized: Subtle Blow {a} → {b}, {n} piece(s) changed in your draft · DT+PDT {p} · DT+MDT {m}.',
  engHitLbl: 'Hit chance (round)', engModeNote: 'This set’s goal by its name ({m}): kept for this set only.', engModeReset: 'Mode’s goal',
  dwNoBase: 'No engaged set under this tier ({p}).', dwNoTwo: 'The set {p} does not hold two weapons: no Dual Wield to search.',
  dwDone: 'Tier {t} over {p} · magic haste {h} % · /{sub}', osOnlyEng: 'Engaged only', osEngBtn: 'Optimize all engaged',
  osEngTip: 'Each engaged mode with its goal, then its Dual Wield tiers, nothing written before you tick.'});

/* ---- an engaged set's mode ---- */
const ENG_MODE_GOAL = {base: 'tp_real', STP: 'tp_real', Acc: 'acc', SB: 'sb', KC: 'tp_real'};
const ENG_MODE_FLOOR = {pdt: -50, mdt: -21};
// the name a job gives its Subtle Blow mode (WAR's HybridMode SubtleBlow: war/keys/WAR_STATES.lua)
const ENG_MODE_ALIAS = {SubtleBlow: 'SB'};
// A job's own order for a mode: WAR's Subtle Blow first, then DT+PDT and DT+MDT, then the time to the weaponskill
// (the player's choice, 2026-11-06), so no DT floor held before the Subtle Blow
const ENG_JOB_MODE = {WAR: {SB: {engObj: 'sb_dt', pdt: 0, mdt: 0}}};
// The mode of an engaged set by its name, or null (a set named otherwise: the page's shared settings):
// {key: base|STP|Acc|SB|KC, name: the word in the path}
function engModeOf(path){
  if (!/^sets\.engaged\b/.test(path || '')) return null;
  const k = segs(path).slice(1);
  if (k.length && /^(Group|Solo|Trust)$/.test(k[k.length - 1])) k.pop();
  if (!k.length) return {key: 'base', name: 'engaged'};
  if (k.length !== 1) return null;
  const m = k[0];
  if (ENG_MODE_GOAL[m] && m !== 'base' && m !== 'KC') return {key: m, name: m};
  if (ENG_MODE_ALIAS[m]) return {key: ENG_MODE_ALIAS[m], name: m};
  return /KC$/.test(m) ? {key: 'KC', name: m} : null;
}
// The settings a mode gives its set, then those kept for that set ({} for a set with no mode)
function engModeOpts(s){
  const m = s && engModeOf(s.path);
  if (!m) return {};
  return Object.assign({engObj: ENG_MODE_GOAL[m.key]}, ENG_MODE_FLOOR, (ENG_JOB_MODE[S.job] || {})[m.key] || {},
    (((S.optOpts || {}).engBy || {})[s.path]) || {});
}
const ENG_KEPT = ['engObj', 'pdt', 'mdt', 'sb'];
// A goal or limit changed on the optimizer's page of a set with a mode: kept for that set (events.js); false otherwise
function engModeWrite(key, v){
  const s = S._optSet;
  if (!ENG_KEPT.includes(key) || !s || !engModeOf(s.path) || !optPageOpen(s)) return false;
  const by = Object.assign({}, (S.optOpts || {}).engBy);
  by[s.path] = Object.assign({}, by[s.path], {[key]: v});
  S.optOpts = Object.assign({}, S.optOpts, {engBy: by});
  return true;
}
// Back to the mode's goal and limits (events.js data-engreset)
function engModeReset(path){
  const by = Object.assign({}, (S.optOpts || {}).engBy);
  delete by[path];
  S.optOpts = Object.assign({}, S.optOpts, {engBy: by});
}
// How a goal's figure reads (the time objectives keep theirs: optimizer.js, opt_sets.js), or null
const engObjFmt = obj => obj === 'acc' ? v => (+v).toFixed(2) + ' %' : obj === 'sb' || obj === 'sb_dt' ? v => String(Math.round(v)) : null;
// A round's hit chance, in % (opt_round.js hitShare), for the page's table
const engHitPct = r => r && r.attacks && r.attacks.swings ? 100 * r.attacks.hits / r.attacks.swings : null;
// A Kraken Club set's off hand stays the club, free weapons or not
function engKrakenOnly(s, weapons){
  const m = engModeOf(s.path);
  if (!weapons || !m || m.key !== 'KC') return weapons;
  const kept = weapons.filter(w => w.sub && w.sub.name === KRAKEN);
  return kept.length ? kept : null;
}

/* ---- the Dual Wield tiers ---- */
const DW_TIERS = ['NoHaste', 'Haste', 'HasteII', 'MaxHaste'];
// The tier's magic haste as GearSwap picks the tier (dual_wield.lua tier): a fraction, the cap 448/1024
const DW_HASTE = {NoHaste: 0, Haste: 0.15, HasteII: 0.30, MaxHaste: 448 / 1024};
// sets.DW.<Tier> -> {mode: null, tier}; sets.DW.<Mode>.<Tier> -> {mode, tier}; else null
function dwTierOf(path){
  if (!/^sets\.DW\./.test(path || '')) return null;
  const k = segs(path);
  if (k.length === 2 && DW_TIERS.includes(k[1])) return {mode: null, tier: k[1]};
  if (k.length === 3 && DW_TIERS.includes(k[2]) && !DW_TIERS.includes(k[1])) return {mode: k[1], tier: k[2]};
  return null;
}
// The engaged set a tier is laid on: its mode's (sets.engaged.SB), the common tiers on sets.engaged
function dwBaseSet(s){
  const w = dwTierOf(s.path), by = S._bypath || {};
  return w ? by[w.mode ? 'sets.engaged.' + w.mode : 'sets.engaged'] || null : null;
}
// The subjob a tier is searched for: the job's own Dual Wield (NIN, DNC, THF, BLU) keeps its subjob; the others the one
// that gives the least (/DNC: Dual Wield II against /NIN's III, BG Wiki Dual_Wield), so the tier is never short
const dwSub = () => ['NIN', 'DNC', 'THF', 'BLU'].includes(S.job) ? ((data() || {}).sub || 'DNC') : 'DNC';
// A tier's own pieces (the try in), without the weapons
function dwOwn(s){
  const out = Object.assign({}, s.pieces, S.trial[trialKey(s)] || {});
  for (const k of Object.keys(out)) if (!out[k] || isEmpty(out[k]) || ['main', 'sub', 'range'].includes(k)) delete out[k];
  return out;
}
// The tier GearSwap lays: this one, else the closest below it with pieces, the mode's then the common ones
// (dual_wield.lua tier_set)
function dwWorn(s){
  const w = dwTierOf(s.path), by = S._bypath || {}, i = DW_TIERS.indexOf(w.tier);
  const from = mode => { for (let j = i; j >= 0; j--) { const x = by['sets.DW.' + (mode ? mode + '.' : '') + DW_TIERS[j]]; if (x && Object.keys(dwOwn(x)).length) return dwOwn(x); } return null; };
  return (w.mode && from(w.mode)) || from(null) || {};
}
// The search's context: the engaged set's, at the tier's magic haste, for that subjob; Mighty Guard and Haste Samba
// left out (GearSwap's tier reads the magic haste alone)
function dwContextInput(base, tier){
  const c = Object.assign(engContextInput(base), {sub: dwSub(), magicHaste: DW_HASTE[tier]});
  c.abilities = Object.assign({}, c.abilities);
  for (const n of ['Mighty Guard', 'Haste Samba', 'Haste Samba (sub)']) delete c.abilities[n];
  if (c.partyStats) { c.partyStats = Object.assign({}, c.partyStats); delete c.partyStats['JA Haste']; }
  return c;
}
async function optimizeDwTier(s){
  if (!engineReady()) return;
  const w = dwTierOf(s.path), b = w && dwBaseSet(s);
  if (!b) { S._toastSet = s.path; S.toast = t('dwNoBase', {p: w && w.mode ? 'engaged.' + w.mode : 'engaged'}); render(); return; }
  const k = trialKey(s), o = engOpts(b), basePieces = withWeapons(b).pieces;
  const worn = Object.assign({}, basePieces, dwWorn(s)), ctx = dwContextInput(b, w.tier);
  // two weapons, or no Dual Wield to search (a shield in the off hand: SubWeapon on one, or sets.SingleWield)
  let dual = false;
  try { const r = FFXI.opt.round(FFXI.opt.context(ctx), optPieces(worn), {lean: true}); dual = !!(r && r.detail && r.detail.delay2); } catch (e) { dual = false; }
  if (!dual) { S._toastSet = s.path; S.toast = t('dwNoTwo', {p: shortPath(b.path)}); render(); return; }
  const choices = lockChoices(s, optChoices(new Set(Object.keys(ONLY_AUGS))));
  const input = {ctx, start: startOf(worn, lockedSlots(s)), choices, prefilter: o.where === 'all' ? 25 : 0,
    opts: {fast: (o.search || 'fast') !== 'classic', objective: o.engObj || 'tp_real', wsAt: +o.engAt || 1000, floor: {pdt: +o.pdt || 0, mdt: +o.mdt || 0, sb: +o.sb || 0}}};
  optLaunch(s, k, input, Object.assign({}, o, {eng: true, freeWeapons: false,
    dw: {base: basePieces, basePath: b.path, tier: w.tier, haste: Math.round(DW_HASTE[w.tier] * 10000) / 100, sub: ctx.sub}}));
}
// The search's result as the tier's try (optimizer.js optResult): a slot that differs from the engaged set is the
// tier's; a slot the tier holds now that the result gives back to the engaged set leaves the tier (push.js overlaySet:
// its line goes). A tier that would be left empty while GearSwap lays one below it gets one slot of the engaged set,
// written: the tier then is the engaged set itself, not the one below
function dwTrialOf(s, res, dw, tr){
  // (the try is the change from the file: compared with the tier as the file writes it)
  const own = {}, base = dw.base, same = (a, b) => samePiece(a, b && !isEmpty(b) ? optPieces({x: b}).x : null);
  for (const [slot, p] of Object.entries(s.pieces || {})) if (p && !isEmpty(p) && !['main', 'sub', 'range'].includes(slot)) own[slot] = p;
  const kept = {};
  for (const [slot, p] of Object.entries(res.pieces)) {
    if (['main', 'sub', 'range'].includes(slot) || !p) continue;
    const piece = {name: p.name, augs: p.augs};
    if (p.rank != null) piece.rank = p.rank;
    if (!same(piece, base[slot])) kept[slot] = piece;
  }
  for (const slot of new Set(Object.keys(own).concat(Object.keys(kept)))) {
    if (kept[slot]) { if (!own[slot] || !same(kept[slot], own[slot])) tr[slot] = kept[slot]; }
    else tr[slot] = null;
  }
  if (!Object.keys(kept).length && !Object.keys(own).length) {
    const w = dwTierOf(s.path), i = DW_TIERS.indexOf(w.tier), by = S._bypath || {};
    const modes = w.mode ? [w.mode, null] : [null];
    const below = DW_TIERS.slice(0, i).some(x => modes.some(m => { const y = by['sets.DW.' + (m ? m + '.' : '') + x]; return y && Object.keys(dwOwn(y)).length; }));
    const slot = Object.keys(base).find(x => !['main', 'sub', 'range'].includes(x) && base[x] && !isEmpty(base[x]));
    if (below && slot) tr[slot] = {name: base[slot].name, augs: base[slot].augs};
  }
  return tr;
}
