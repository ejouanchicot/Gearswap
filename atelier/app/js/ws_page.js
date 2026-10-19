// GearSwap Atelier · ws_page.js: TP bonus, the weaponskill page, the engaged / Jump round
// (loaded by atelier/index.html, in the order of the list there)
// The figures of an engaged set's round, worse to better (low: smaller is better), in the search window (optimizer.js)
const ENG_COLS = {
  tp_real: {key: 'rdvReal', get: r => r.real ? r.real.time : r.time, fmt: v => v.toFixed(2) + ' s', low: true},
  tp_time: {key: 'rdvAvg', get: r => r.time, fmt: v => v.toFixed(2) + ' s', low: true},
  rounds: {key: 'rdvRounds', get: r => r.real ? r.real.rounds : null, fmt: v => v.toFixed(2), low: true},
  dps: {label: 'DPS', get: r => r.dps, fmt: v => fmtDmg(v), low: false},
  tp_round: {key: 'cmpEngTp', get: r => r.tp, fmt: v => String(Math.round(v)), low: false},
  // the attacks of a round in theory (Double / Triple / Quadruple Attack, the weapons' multi-attacks) and those that land
  attacks: {key: 'rdvAttacks', get: r => r.attacks ? r.attacks.swings : null, fmt: v => v.toFixed(2), low: false},
  landed: {key: 'rdvLanded', get: r => r.attacks ? r.attacks.hits : null, fmt: v => v.toFixed(2), low: false}};
/* ---- TP bonus: the pieces the job's own rules add to a weaponskill at a TP (Moonshade...) ----
   The game computes them (GET /tpbonus: TPBonusCalculator with <JOB>_TP_CONFIG.lua, the buffs on
   now, the main / sub / ranged weapon shown): the page asks once per TP and weapons and keeps the answer */
// Without the game's answer: no weapon or buff bonus, Moonshade's 250 (2000 - 250 = 1750...)
const TP_STEPS = [1000, 1750, 2000, 2750, 3000];
// The buffs of the page that change a weaponskill's TP (Warcry, Hagakure), as the game's buffactive
const tpBuffs = () => { const b = buffState();
  return jasOf().filter(j => jaOn(b, j.name)).map(j => j.name).join(','); };
// Your weapons for this job (main, sub, ranged): the game gives each one's TP Bonus with the rule, for a search
// that tries them (60 names at most: a longer address may not go through; the engine reads the others' itself)
function tpWeaponNames(){
  const owned = ownedOf() || {};
  return [...new Set(['main', 'sub', 'range'].flatMap(sl => (owned[sl] || []).map(x => x.name)))].sort().slice(0, 60).join('|');
}
// The TP rule a search works with: what does not come from the weapons (buffs, Fencer, the party; `less`: a Warcry
// the fight times itself), each weapon's own TP Bonus (the search counts the weapons of the set it tries), the pieces
function tpRuleOf(r, less){
  if (!(r && r.piece_list)) return null;
  const perWeapon = r.weapon_bonus != null && r.weapon_tp;
  return {bonus: Math.max(0, (r.bonus || 0) - (perWeapon ? r.weapon_bonus : 0) - (less || 0)) + partyTp(),
    weaponTp: perWeapon ? r.weapon_tp : null, pieces: r.piece_list};
}
// The TP pieces a rule lays at a TP (shared/utils/weaponskill/tp_bonus_calculator.lua): none past 3000 or when all
// of them together do not reach the next step; else the smallest one that closes the gap, else the biggest first.
// eff: the TP with the weapons' and the party's bonus. A TP piece the set wears in its slot counts as there.
function tpPiecesLocal(list, pieces, eff){
  const left = [];
  for (const p of list) { if (pieces[p.slot] && pieces[p.slot].name === p.name) eff += p.bonus; else left.push(p); }
  const step = eff < 2000 ? 2000 : eff < 3000 ? 3000 : 0, gap = step - eff;
  if (!step || gap > left.reduce((n, p) => n + p.bonus, 0)) return {};
  const asc = left.slice().sort((a, b) => a.bonus - b.bonus), one = asc.find(p => p.bonus >= gap);
  if (one) return {[one.slot]: one.name};
  const out = {}; let got = 0;
  for (const p of asc.reverse()) if (got < gap) { out[p.slot] = p.name; got += p.bonus; }
  return out;
}
// The game is on another job (or closed): the rule as this job's export kept it (tp_rule: its TP pieces and each
// held weapon's TP Bonus), answered in the shape of /tpbonus. No buff and no Fencer in it: the game alone works
// those out, on that job (`offline` says so)
function tpOffline(pieces, tp){
  const rule = (data() || {}).tp_rule;
  if (!rule || !Array.isArray(rule.piece_list)) return null;
  const tpOf = rule.weapon_tp || {};
  const held = [...new Set(['main', 'sub', 'range'].map(sl => pieces[sl] && !isEmpty(pieces[sl]) ? pieces[sl].name : '').filter(Boolean))];
  const weapon = held.reduce((n, name) => n + (tpOf[name] || 0), 0);
  const names = tpWeaponNames().split('|').filter(Boolean);
  const r = {offline: true, config: true, worn_aware: true, bonus: weapon, weapon_bonus: weapon, piece_list: rule.piece_list,
    weapon_tp: Object.fromEntries(names.map(n => [n, tpOf[n] || 0])), pieces: Object.fromEntries(rule.piece_list.map(p => [p.name, p.bonus])),
    total: rule.piece_list.reduce((n, p) => n + p.bonus, 0), thresholds: rule.thresholds || [2000, 3000]};
  if (tp) r.gear = tpPiecesLocal(rule.piece_list, pieces, Math.min(3000, +tp + partyTp()) + weapon);
  return r;
}
// The game's answer for these weapons and buffs (and this TP, when given), asked once and kept
function tpAsk(s, pieces, tp){
  const c = S.char, L = S._live[c] || {};
  if (family(s.path, s.pieces) !== 'ws') return null;
  if (!liveOk(c) || L.job !== S.job) return tpOffline(pieces, tp);
  const main = (pieces.main || {}).name || '', sub = (pieces.sub || {}).name || '', buffs = tpBuffs();
  // the ranged weapon's TP Bonus counts on any weaponskill (a COR's Anarchy +2: +1000 on Savage Blade)
  const range = pieces.range && !isEmpty(pieces.range) ? pieces.range.name : '';
  // what the set wears (before any TP piece): the game counts its own TP pieces (Boii Cuisses in the base set)
  const worn = tp ? SLOTS.filter(sl => pieces[sl] && !isEmpty(pieces[sl])).map(sl => sl + ':' + pieces[sl].name).join('|') : '';
  const key = [c, S.job, L.version, tp || 'steps', main, sub, range, buffs, partyTp(), worn].join('|');
  if (key in S._tpb) return S._tpb[key];
  S._tpb[key] = null;
  // the TP a party member's Warcry adds is the page's own: the game is asked as if the TP were that much higher
  const q = {main, sub, range, buffs}; if (!tp) q.weapons = tpWeaponNames(); if (tp) { q.tp = Math.min(3000, +tp + partyTp()); q.worn = worn; }
  S._tpbWait = S._tpbWait || {};
  S._tpbWait[key] = liveFetch(c, `/tpbonus?${new URLSearchParams(q)}`, {timeout: 3000})
    .then(r => { S._tpb[key] = r || {}; render(); return S._tpb[key]; }).catch(() => { delete S._tpb[key]; return null; })
    .finally(() => { delete S._tpbWait[key]; });
  return null;
}
// The same, waiting for the game's answer when it is on its way (the optimizer needs the TP rule
// before it starts: without it a first run after a reload works another problem than the next one)
async function tpAskWait(s, pieces, tp){
  const r = tpAsk(s, pieces, tp);
  if (r) return r;
  const waits = Object.values(S._tpbWait || {});
  if (waits.length) await Promise.all(waits);
  return tpAsk(s, pieces, tp);
}
function tpBonusGear(s, pieces){
  if (!S.wsTp || S._noTpGear) return null;
  const r = tpAsk(s, pieces, S.wsTp);
  return r && r.gear;
}
// The TP that matter with these weapons and buffs: 1000, then for each step (2000, 3000) the TP from
// which the job's pieces reach it and the TP that reaches it alone, 3000 last
// The TP steps of a weaponskill in Simulate: those of its set in the Sets tab (the game's TP bonus
// config, its weapons and the buffs ticked), so both tabs offer the same ones
function simTpSteps(ws){
  const d = data(), set = d && (d.sets.find(x => wsOfSet(x) === ws) || d.sets.find(x => x.path === 'sets.precast.WS'));
  return set ? tpSteps(tpAsk(set, withWeapons(set).pieces, null), set) : TP_STEPS;
}
// A piece's TP Bonus: its value in the job's TP config, else its description (weapons: the game's bonus)
function tpbOf(p, slot, cfg){
  if (!p || isEmpty(p)) return 0;
  if (p.name in cfg) return cfg[p.name];
  return WEAPON_SLOTS.has(slot) && slot !== 'ammo' ? 0 : (((pieceStats(p) || {}).stats || {}).tpb || {}).v || 0;
}
// The steps, as the job's own rule plays (TPBonusCalculator: it counts the weapon, buffs and Fencer,
// then adds TP pieces only when all of them together reach the next threshold):
//   with the TP pieces: threshold - weapon / buffs - every TP piece of the config (where it starts adding them)
//   without them: threshold - weapon / buffs - the TP Bonus the set wears already (Boii Cuisses in the base set)
function tpSteps(r, s){
  if (!r || !r.thresholds) { S._tpWhy = {}; return TP_STEPS; }
  const cfg = r.pieces || {}, worn = s ? (() => { S._noTpGear = true; try { return withWeapons(s).pieces; } finally { S._noTpGear = false; } })() : {};
  const inSet = SLOTS.reduce((n, slot) => n + tpbOf(worn[slot], slot, cfg), 0);
  const out = new Set([1000, 3000]), bonus = r.bonus + partyTp();
  // what each step is, for its chip's tooltip (S._tpWhy)
  S._tpWhy = {};
  for (const th of r.thresholds) for (const [v, k] of [[th - bonus - r.total, 'tpWhyAdd'], [th - bonus - inSet, 'tpWhyFree']])
    if (v > 1000 && v < 3000) { out.add(v); S._tpWhy[v] = t(k, {t: th}); }
  return [...out].sort((a, b) => a - b);
}
// An ⓘ that opens or closes the explanation `key` (S._help) in the page
const helpBtn = key => `<button type="button" class="helpbtn" data-help="${esc(key)}" aria-expanded="${S._help === key}" aria-label="?" title="${esc(t('ttHelp'))}">ⓘ</button>`;
const itemOf = name => (window.FFXI && FFXI.opt && FFXI.opt.item && name) ? FFXI.opt.item(name) : null;
// Whether a weapon can open a weaponskill: its skill, and the weapon itself for a relic or prime one
function opensWs(ws){
  const skill = wsSkills()[ws], lock = (wsInfoOf(ws).lock || '').toLowerCase();
  return name => { const it = itemOf(name); return !!it && it['Skill Type'] === skill && (!lock || lock.includes(name.toLowerCase())); };
}
// Your weapons that can open a weaponskill
function heldChoices(ws){
  const opens = opensWs(ws), seen = new Set(), out = [];
  for (const x of ((ownedOf() || {}).main || [])) {
    if (seen.has(x.name)) continue;
    seen.add(x.name);
    if (opens(x.name)) out.push(x.name);
  }
  return out;
}
// The weaponskill's damage with each of them, worked out once a state of the page (later, then drawn again)
function heldRanking(s, ws, list){
  if (!engineReady() || !list.length) return null;
  const key = [S.char, S.job, s.path, buffTier(), S.wsTp, JSON.stringify((S.heldSub || {})[heldKey(ws)] || null), JSON.stringify(S.trial[trialKey(s)] || {}), JSON.stringify(buffState()), list.join(',')].join('|');
  S._heldRank = S._heldRank || {};
  if (S._heldRank[key]) return S._heldRank[key];
  if (!S._heldRankBusy) {
    S._heldRankBusy = true;
    setTimeout(() => {
      const out = {}, keep = S.held[heldKey(ws)];
      try { for (const n of list) { S.held[heldKey(ws)] = n; out[n] = wsDamage(s); } }
      finally { if (keep === undefined) delete S.held[heldKey(ws)]; else S.held[heldKey(ws)] = keep; S._heldRankBusy = false; }
      S._heldRank = {[key]: out}; render();
    }, 60);
  }
  return null;
}
// The settings' help, for the compartment's ⓘ
function optSettingsHelp(hit){
  return [t('optWardTip'), 'DT+PDT : ' + t('optPdtTip'), 'DT+MDT : ' + t('optMdtTip'), 'Subtle Blow : ' + t('optSbTip')].concat(hit ? [t('optHitLbl') + ' : ' + t('optHitTip')] : []).join('. ') + '.';
}
/* ---- the engaged optimizer: the attack round (atelier/engine/actions.js average_attack_round) ---- */
const ENG_OBJS = ['tp_real', 'tp_time', 'dps', 'tp_round'];
// A Jump (and High Jump, the same set): one attack round in its own set (BG Wiki: Double / Triple Attack and multi-hit
// weapons count), so the optimizer reads the TP of a round (the defense floors are the engaged ones)
const isJumpSet = path => /^sets\.precast\.JA(\.Jump|\["High Jump"\])$/.test(path || '');
const roundSet = s => family(s.path, s.pieces) === 'engaged' || isJumpSet(s.path);
// The engaged optimizer's settings for a set: a Jump's are fixed
const engOpts = s => Object.assign({}, S.optOpts, isJumpSet(s && s.path) ? {engObj: 'tp_round'} : {});
// An engaged set's attack round with the set as shown (weapons, tried pieces; plain: the file's, no try), or null
function engRound(s, plain){
  if (!engineReady() || !roundSet(s)) return null;
  const o = S.optOpts || {}, pieces = plain ? withoutTrial(() => withWeapons(s).pieces) : withWeapons(s).pieces;
  try { const ctx = optContext(s, true), p = optPieces(pieces), r = FFXI.opt.round(ctx, p, {wsAt: +o.engAt || 1000});
    if (r) r.def = FFXI.opt.defense(FFXI.opt.gearset(ctx, p), ctx.sbBuff);
    return r; } catch (e) { return null; }
}
// What can go off in each hand (FFXI.opt.procsOf): QA, TA, DA, the weapon's OA8..OA2, or one swing, each with its
// chance, its attacks and the TP they give when they all land
function procsHTML(x, f, pc){
  const p = FFXI.opt.procsOf ? FFXI.opt.procsOf(x) : null;
  if (!p) return '';
  const hand = (list, label) => `<span class="rdhand">${esc(label)}</span> ` + list.map(e =>
    `<span class="rdproc"><b>${e.k === '1' ? esc(t('rdProcNone')) : e.k}</b> ${pc(e.p)} % · ${e.n} × ${f(p.tpPerHit)} = <b>${f(e.n * p.tpPerHit)}</b> TP</span>`).join(' ');
  return t('rdProcs') + '<br>' + hand(p.main, t('rdHandMain')) + (p.sub ? '<br>' + hand(p.sub, t('rdHandSub')) : '');
}
// The TP the weaponskill opens with at the TP chosen: that TP, the weapon / buffs / Fencer bonus the
// game counts, a party member's Warcry, then the TP Bonus of the pieces worn (their value from the
// job's TP config, <JOB>_TP_CONFIG.lua; any other piece from its description, weapons left to the game's bonus)
// The TP Bonus the weaponskill gets, whatever the TP: the weapon / buffs / Fencer (the game's rule), the party
// (a WAR's Warcry, a SMN's Crystal Blessing) and the pieces worn
function tpBonusParts(s, r){
  const pieces = withWeapons(s).pieces, parts = [], cfg = (r && r.pieces) || {};
  let gear = 0;
  for (const slot of SLOTS) { const p = pieces[slot], v = tpbOf(p, slot, cfg);
    if (v) { gear += v; parts.push(`${p.name} ${v}`); } }
  const base = r ? r.bonus || 0 : 0, party = partyTp();
  return {base, party, gear, parts, total: base + party + gear};
}
function tpTotalParts(s, r){
  if (!S.wsTp) return null;
  const {base, party, gear, parts} = tpBonusParts(s, r), raw = +S.wsTp + base + party + gear, total = Math.min(3000, raw);
  const bits = [`${S.wsTp}`].concat(base ? [t('tpTotBase', {n: base})] : [], party ? [t('tpTotParty', {n: party})] : [],
    gear ? [t('tpTotGear', {n: gear, l: parts.join(', ')})] : []);
  const step = total >= 3000 ? 3000 : total >= 2000 ? 2000 : 1000;
  return {total, raw, step, text: t('tpTotal', {b: bits.join(' + '), t: total}) + ' · ' + t('tpStep', {s: step})};
}

