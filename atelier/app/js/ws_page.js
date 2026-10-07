// GearSwap Atelier · ws_page.js: TP bonus, the weaponskill page, the engaged / Jump round
// (cut from atelier.html, loaded by it in order: see the list there)
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
// The game's answer for these weapons and buffs (and this TP, when given), asked once and kept
function tpAsk(s, pieces, tp){
  const c = S.char, L = S._live[c] || {};
  if (family(s.path, s.pieces) !== 'ws' || !liveOk(c) || L.job !== S.job) return null;
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
// The TP line of a weaponskill set: off (the set as written) or a TP, its pieces from the game
// An ⓘ that opens or closes the explanation `key` (S._help) in the page
const helpBtn = key => `<button type="button" class="helpbtn" data-help="${esc(key)}" aria-expanded="${S._help === key}" aria-label="?">ⓘ</button>`;
// The settings of a weaponskill set, for anyone: its version, the weapon held, the TP; one line each,
// the explanations under their ⓘ (the optimizer has its own page: opt_page.js)
function wsHeadHTML(card, ci, vi, s){
  // the explanation of a line opens under it on a click of its ⓘ (never over the page)
  const line = (label, body, tip = '', key = '') => `<div class="wsline"><span class="wslbl">${esc(label)}${tip ? ` ${helpBtn(key)}` : ''}</span><div class="wsval">${body}</div></div>` +
    (tip && S._help === key ? `<p class="wshelp">${esc(tip)}</p>` : '');
  // the base set (sets.precast.WS) has no weaponskill: no weapon, TP or optimizer line, it is what the others inherit
  if (!wsOfSet(s)) return `<p class="muted small wsbase">${t('wsBaseNote')}</p>`;
  // a job with a stance or a switch on its weapons keeps the full weapon picker, under the lines
  const weapon = wsWeaponLine(s, line), inGrid = weapon.startsWith('<div class="wsline"');
  return `<div class="wshead">${wsPickLines(card, ci, vi, line)}${inGrid ? weapon : ''}${wsTpLine(s, line)}</div>${inGrid ? '' : weapon}`;
}
// The shown weaponskill's versions (Full = the set, Group, Solo...); the weaponskills themselves are in the set list
function wsPickLines(card, ci, vi, line){
  const list = [...variantGroups(card).groups.values()];
  const cur = list.find(g => g.main === vi || g.subs.some(x => x.i === vi)) || list[0];
  if (!cur) return '';
  const btn = (i, label) => `<button aria-pressed="${i === vi}" data-card="${ci}" data-variant="${i}">${esc(label)}</button>`;
  let out = '';
  if (cur.subs.length) {
    const tiers = cur.subs.some(x => /^(Group|Solo|Trust)$/.test(x.label));
    out += line(t('verLbl'), (cur.main != null ? btn(cur.main, tiers ? 'Full' : t('verSet')) : '') + cur.subs.map(x => btn(x.i, x.label)).join(''), t('verTip'), 'ver');
  }
  return out;
}
const itemOf = name => (window.FFXI && FFXI.opt && FFXI.opt.item && name) ? FFXI.opt.item(name) : null;
// Your weapons that can open a weaponskill: its skill, and the weapon itself for a relic or prime one
function heldChoices(ws){
  const skill = wsSkills()[ws], lock = (wsInfoOf(ws).lock || '').toLowerCase(), seen = new Set(), out = [];
  for (const x of ((ownedOf() || {}).main || [])) {
    if (seen.has(x.name)) continue;
    seen.add(x.name);
    const it = itemOf(x.name);
    if (it && it['Skill Type'] === skill && (!lock || lock.includes(x.name.toLowerCase()))) out.push(x.name);
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
// The weapon line: the weapon mode's weapon by default, or one of yours of the weaponskill's category, best first
function wsWeaponLine(s, line){
  const d = data(), ws = wsOfSet(s);
  // a job with a stance or a gated state on its weapons (PLD, THF): its weapon states' menus, as on any set
  if (hybridMode(d) || weaponModes(d).some(m => WEAPON_GATES[m.name])) return (weaponMenus(s) || []).map(([name, sel]) => line(name, sel)).join('');
  const auto = withWeapons(s, 'held').pieces.main, held = heldWeapon(ws), list = heldChoices(ws), rank = heldRanking(s, ws, list);
  const sorted = rank ? list.slice().sort((a, b) => (rank[b] || 0) - (rank[a] || 0)) : list;
  const dmg = n => rank && rank[n] != null ? ' — ' + fmtDmg(rank[n]) : '';
  // a weapon out of reach (a slip, the Mog House) says where it is: it has to be taken out first
  const where = n => { const w = [...new Set(((ownedOf() || {}).main || []).filter(x => x.name === n).flatMap(x => x.where || []))];
    return w.length && !w.some(x => /^(Inventory|Wardrobe)/.test(x)) ? ' · ' + w.map(whereLabel).join(', ') : ''; };
  const menu = `<select class="heldsel buffsel ${held ? 'set' : ''}" data-heldws="${esc(ws)}">` +
    `<option value="">${esc(t('heldMode', {w: auto && !isEmpty(auto) ? auto.name : '—'}))}</option>` +
    (held && !sorted.includes(held) ? `<option value="${esc(held)}" selected>${esc(held + ' · ' + t('heldGone'))}</option>` : '') +
    sorted.map(n => `<option value="${esc(n)}" ${n === held ? 'selected' : ''}>${esc(n + dmg(n) + where(n))}</option>`).join('') + `</select>`;
  return line(t('weaponLbl'), menu + heldSubMenu(s, ws), t('weaponTip'), 'weapon');
}
// The off hand for a weaponskill: Auto (what the weapon set or the grip rule gives), then yours; one the main hand
// cannot take greyed with why (a grip for a two-handed weapon, a shield, a weapon only with Dual Wield)
function heldSubMenu(s, ws){
  const main = withWeapons(s).pieces.main, auto = withWeapons(s, 'heldsub').pieces.sub, cur = (S.heldSub || {})[heldKey(ws)];
  const why = x => subWhy(main, x), list = forceList('sub');
  const shown = cur && list.some(x => x.name === cur.name && !why(x));
  return `<select class="heldsubsel buffsel ${cur ? 'set' : ''}" data-heldws="${esc(ws)}" aria-label="Sub">` +
    `<option value="">${esc('Sub · ' + t('auto') + ' · ' + (auto && !isEmpty(auto) ? auto.name : '—'))}</option>` +
    (cur && !shown ? `<option value="cur" selected>${esc(cur.name + ' · ' + (why(cur) || t('heldGone')))}</option>` : '') +
    fitOptions(list, why, cur, main) + `</select>`;
}
// A menu's pieces that fit, each with its index in the list (the option's value); the ones that do not, one line
// at the end saying how many and why (an option greyed one by one cannot be picked nor even lit, and reads as broken)
function fitOptions(list, why, cur, main){
  const ok = list.map((x, i) => [x, i]).filter(([x]) => !why(x)), off = list.filter(x => why(x));
  const reasons = [...new Set(off.map(why))];
  return ok.map(([x, i]) => `<option value="${i}" ${cur && cur.name === x.name ? 'selected' : ''}>${esc(x.name)}</option>`).join('') +
    (off.length ? `<option disabled>${esc(t('subOff', {n: off.length, w: (main && main.name) || '—', r: reasons.join(' · ')}))}</option>` : '');
}
// The TP steps, then the TP the weaponskill opens with (its make-up on hover)
function wsTpLine(s, line){
  const chip = (v, label) => `<button data-wstp="${v}" aria-pressed="${String(S.wsTp || '') === String(v)}">${label}</button>`;
  const live = liveWrite();
  const r = tpAsk(s, withWeapons(s).pieces, null), steps = tpSteps(r, s), parts = tpTotalParts(s, r);
  const bonus = r && r.bonus ? ` ${t('tpBonusOf', {n: r.bonus})}` : '';
  const note = !live ? t('tpNeedLive') : r && r.config === false ? t('tpNoConfig') : (S.wsTp ? t('tpLiveNote') : t('tpOffNote')) + bonus;
  // past 3000 the game keeps 3000: what is over is TP Bonus spent for nothing
  const res = parts ? `<span class="tpres">→ <b>${parts.total}</b> TP` +
    (parts.raw > 3000 ? ` <span class="tpover">${t('tpOver', {t: parts.raw, n: parts.raw - 3000})}</span>` : '') + `</span>` : '';
  const input = `<input class="tpin" type="number" min="0" max="3000" step="10" value="${S.wsTp && !steps.includes(+S.wsTp) ? S.wsTp : ''}" placeholder="${t('tpOther')}" aria-label="TP">`;
  // the make-up of the total joins the explanation
  const fallback = !r ? `<span class="muted small">${t(live ? 'tpAsking' : 'tpDefault')}</span>` : '';
  // the TP Bonus in total, in view, its make-up beside it
  const tb = tpBonusParts(s, r), tbBits = [tb.base ? t('tpTotBase', {n: tb.base}) : '', tb.party ? t('tpTotParty', {n: tb.party}) : '',
    tb.gear ? t('tpbGear', {n: tb.gear}) : ''].filter(Boolean);
  const tbHTML = `<span class="tpbtot">TP Bonus <b>+${tb.total}</b>${tbBits.length ? ` <span class="muted small">(${esc(tbBits.join(' · '))})</span>` : ''}</span>`;
  return line(t('tpLbl'), chip('', t('tpOff')) + steps.map(v => chip(v, v)).join('') + input + res + fallback + tbHTML, (parts ? parts.text + '. ' : '') + note + Object.entries(S._tpWhy || {}).map(([v, w]) => ` ${v} : ${w}.`).join(''), 'tp') +
    (parts && r && !r.worn_aware ? `<p class="kwarn">${t('tpOldCode')}</p>` : '');
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
// The round worked out as the engine does it (atelier/engine: average_attack_round, get_tp, get_delay_timing), each step with
// its figures; then the rounds counted whole (the TP comes at the end of a round)
function roundCalcHTML(x, real){
  const f = (v, n = 0) => (+v).toLocaleString(S.lang === 'fr' ? 'fr-FR' : 'en-US', {minimumFractionDigits: n, maximumFractionDigits: n});
  const pc = v => f(v * 100, 1), cap = (v, c) => Math.min(v, c), hits = Object.values(x.hits).reduce((a, b) => a + b, 0);
  const g = cap(x.haste.gear, .25), m = cap(x.haste.magic, 448 / 1024), j = cap(x.haste.ja, .25), tot = g + m + j;
  const delay = x.delay1 + x.delay2, rdelay = Math.max(.2 * delay, (delay - x.ma) * (1 - x.dw / 100) * (1 - tot));
  const rounds = (x.at - x.start) / x.tpRound;
  const hitsP = real ? Object.keys(real.dist).filter(k => real.dist[k] >= .0005).map(k => t('rdHitN', {n: k, p: pc(real.dist[k])})).join(' · ') : '';
  const roundsP = real ? real.probs.map((p, i) => [i + 1, p]).filter(([, p]) => p >= .0005).map(([n, p]) => t('rdRoundN', {n, p: pc(p)})).join(' · ') : '';
  const extra = [x.hits.sub ? t('rdSub', {n: f(x.hits.sub, 2)}) : '', x.hits.zanshin > .005 ? 'Zanshin ' + f(x.hits.zanshin, 2) : '',
    x.hits.kick ? t('rdKick', {n: f(x.hits.kick, 2)}) : '', x.hits.daken ? 'Daken ' + f(x.hits.daken, 2) : ''].filter(Boolean).join(' · ');
  const steps = [
    t('rdDelay', {d: f((x.delay1 + (x.delay2 || x.delay1)) / 2), ma: x.ma ? ` − Martial Arts ${f(x.ma)}` : '', dw: x.dw ? ` × (1 − Dual Wield ${f(x.dw)} %)` : '', m: f(x.mdelay)}),
    t('rdTp', {m: f(x.handDelay), b: f(x.baseTp), stp: f(x.stp * 100), t: f(x.tpPerHit)}),
    t('rdHits', {h: f(hits, 2), m: f(x.hits.main, 2), x: extra ? ' · ' + extra : '', hr: pc(x.hitRate.main) + (x.hits.sub > 0 ? ' / ' + t('rdHandSub').toLowerCase() + ' ' + pc(x.hitRate.sub) : ''), da: pc(x.multi.da), ta: pc(x.multi.ta), qa: pc(x.multi.qa)}),
    procsHTML(x, f, pc),
    t('rdTpRound', {h: f(hits, 2), t: f(x.tpPerHit), rg: x.regain ? t('rdRegain', {n: f(x.regain)}) : '', r: f(x.tpRound, 1)}),
    t('rdHaste', {g: pc(x.haste.gear), m: pc(x.haste.magic), j: pc(x.haste.ja), tot: pc(tot)}),
    t('rdTime', {d: x.ma ? `(${f(delay)} − ${f(x.ma)})` : f(delay), dw: x.dw ? ` × (1 − ${f(x.dw)} %)` : '', tot: pc(tot), rd: f(rdelay, 1), fl: f(.2 * delay, 1), s: f(x.timeRound, 3)}),
    t('rdWs', {at: f(x.at), st: f(x.start), r: f(x.tpRound, 1), n: f(rounds, 2), s: f(x.timeRound, 3), t: f(x.timeWs, 2)}),
    real ? t('rdReal', {h: hitsP, r: roundsP, n: f(real.rounds, 2), t: f(real.time, 2), tp: f(real.tpAt)}) : ''].filter(Boolean);
  return `<details class="rdcalc" data-rdcalc ${S._rdOpen ? 'open' : ''}><summary>${esc(t('rdTitle'))}</summary><ol>${steps.map(z => `<li>${z}</li>`).join('')}</ol>` +
    `<p class="muted small">${esc(t('rdNote'))}</p></details>`;
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

