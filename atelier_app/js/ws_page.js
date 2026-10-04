// GearSwap Atelier · ws_page.js: TP bonus, the weaponskill page, the engaged / Jump round
// (cut from atelier.html, loaded by it in order: see the list there)
// Your set and the try side by side: the objective chosen first (marked), the other figures, then the floors set
// (DT+PDT, DT+MDT, Subtle Blow) with their limit, the better one in gold, a set short of a floor in red
const ENG_COLS = {
  tp_real: {key: 'rdvReal', get: r => r.real ? r.real.time : r.time, fmt: v => v.toFixed(2) + ' s', low: true},
  tp_time: {key: 'rdvAvg', get: r => r.time, fmt: v => v.toFixed(2) + ' s', low: true},
  rounds: {key: 'rdvRounds', get: r => r.real ? r.real.rounds : null, fmt: v => v.toFixed(2), low: true},
  dps: {label: 'DPS', get: r => r.dps, fmt: v => fmtDmg(v), low: false},
  tp_round: {key: 'cmpEngTp', get: r => r.tp, fmt: v => String(Math.round(v)), low: false},
  // the attacks of a round in theory (Double / Triple / Quadruple Attack, the weapons' multi-attacks) and those that land
  attacks: {key: 'rdvAttacks', get: r => r.attacks ? r.attacks.swings : null, fmt: v => v.toFixed(2), low: false},
  landed: {key: 'rdvLanded', get: r => r.attacks ? r.attacks.hits : null, fmt: v => v.toFixed(2), low: false}};
function roundVsHTML(a, b, o = S.optOpts || {}){
  const obj = ENG_COLS[o.engObj] ? o.engObj : 'tp_real';
  const cols = [obj, ...Object.keys(ENG_COLS).filter(k => k !== obj)].map(k => Object.assign({id: k}, ENG_COLS[k]));
  // the floors set: their value, the limit in the head, red when a set does not keep it
  const floors = [['pdt', 'DT+PDT', '≤', +o.pdt], ['mdt', 'DT+MDT', '≤', +o.mdt], ['sb', 'Subtle Blow', '≥', +o.sb]].filter(f => f[3]);
  cols.push(...floors.map(([k, label, op, lim]) => ({label: `${label} ${op} ${lim}`, get: r => r.def ? r.def[k] : null, fmt: v => String(Math.round(v)),
    low: op === '≤', floor: v => op === '≤' ? v <= lim : v >= lim})));
  const cell = (c, r, other) => { const v = c.get(r), w = c.get(other);
    if (v == null) return `<td>—</td>`;
    const better = w != null && (c.low ? v < w - 1e-9 : v > w + 1e-9), bad = c.floor && !c.floor(v);
    return `<td class="${better ? 'better' : ''} ${bad ? 'short' : ''} ${c.id === obj ? 'obj' : ''}">${c.fmt(v)}</td>`; };
  // a line a figure, your set and the try in two columns
  const line = c => `<tr class="${c.id === obj ? 'obj' : ''}"><th ${c.id === obj ? `title="${esc(t('rdvObjTip'))}"` : ''}>${esc(c.label || t(c.key))}${c.id === obj ? ' ★' : ''}</th>` +
    `${cell(c, a, b)}${cell(c, b, a)}</tr>`;
  return `<table class="rdvs"><thead><tr><th></th><th>${esc(t('rdvMine'))}</th><th>${esc(t('rdvTry'))}</th></tr></thead><tbody>${cols.map(line).join('')}</tbody></table>`;
}
/* ---- TP bonus: the pieces the job's own rules add to a weaponskill at a TP (Moonshade...) ----
   The game computes them (GET /tpbonus: TPBonusCalculator with <JOB>_TP_CONFIG.lua, the buffs on
   now, the main / sub shown): the page asks once per TP and weapons and keeps the answer */
// Without the game's answer: no weapon or buff bonus, Moonshade's 250 (2000 - 250 = 1750...)
const TP_STEPS = [1000, 1750, 2000, 2750, 3000];
// The buffs of the page that change a weaponskill's TP (Warcry, Hagakure), as the game's buffactive
const tpBuffs = () => { const b = buffState();
  return jasOf().filter(j => jaOn(b, j.name)).map(j => j.name).join(','); };
// The game's answer for these weapons and buffs (and this TP, when given), asked once and kept
function tpAsk(s, pieces, tp){
  const c = S.char, L = S._live[c] || {};
  if (family(s.path, s.pieces) !== 'ws' || !liveOk(c) || L.job !== S.job) return null;
  const main = (pieces.main || {}).name || '', sub = (pieces.sub || {}).name || '', buffs = tpBuffs();
  // what the set wears (before any TP piece): the game counts its own TP pieces (Boii Cuisses in the base set)
  const worn = tp ? SLOTS.filter(sl => pieces[sl] && !isEmpty(pieces[sl])).map(sl => sl + ':' + pieces[sl].name).join('|') : '';
  const key = [c, S.job, L.version, tp || 'steps', main, sub, buffs, partyTp(), worn].join('|');
  if (key in S._tpb) return S._tpb[key];
  S._tpb[key] = null;
  // the TP a party member's Warcry adds is the page's own: the game is asked as if the TP were that much higher
  const q = {main, sub, buffs}; if (tp) { q.tp = Math.min(3000, +tp + partyTp()); q.worn = worn; }
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
// the explanations under their ⓘ (the optimizer is drawn under the title and these lines: wsOptHTML)
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
    const tiers = cur.subs.some(x => /^(Group|Solo)$/.test(x.label));
    out += line(t('verLbl'), (cur.main != null ? btn(cur.main, tiers ? 'Full' : t('verSet')) : '') + cur.subs.map(x => btn(x.i, x.label)).join(''), t('verTip'), 'ver');
  }
  return out;
}
const itemOf = name => (window.FFXI && FFXI.opt && FFXI.opt.item && name) ? FFXI.opt.item(name) : null;
// Your weapons that can open a weaponskill: its skill, and the weapon itself for a relic or prime one
function heldChoices(ws){
  const skill = wsSkills()[ws], lock = (wsInfoOf(ws).lock || '').toLowerCase(), seen = new Set(), out = [];
  for (const x of ((ofAnySub('owned') || {}).main || [])) {
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
  if (hybridMode(d) || weaponModes(d).some(m => WEAPON_GATES[m.name])) return weaponPicker(s);
  const auto = withWeapons(s, 'held').pieces.main, held = heldWeapon(ws), list = heldChoices(ws), rank = heldRanking(s, ws, list);
  const sorted = rank ? list.slice().sort((a, b) => (rank[b] || 0) - (rank[a] || 0)) : list;
  const dmg = n => rank && rank[n] != null ? ' — ' + fmtDmg(rank[n]) : '';
  // a weapon out of reach (a slip, the Mog House) says where it is: it has to be taken out first
  const where = n => { const w = [...new Set(((ofAnySub('owned') || {}).main || []).filter(x => x.name === n).flatMap(x => x.where || []))];
    return w.length && !w.some(x => /^(Inventory|Wardrobe)/.test(x)) ? ' · ' + w.join(', ') : ''; };
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
// The optimizer: its button, the objective and the cost by party in view; where to look, the
// floors and the wardrobe switch folded under Settings
function wsOptHTML(s){
  if (!engineReady()) return `<p class="tpnote">${t('optNoEngine')}</p>`;
  if (S._optBusy) return `<div class="optcard"><button class="btn" disabled>${t('optBusy')}</button><span class="optprog">${t('optStart')}</span>` +
    `<button class="btn ghost" data-optstop>${t('optStop')}</button></div>` + trialRow(s);
  const o = S.optOpts = Object.assign({obj: 'damage', pdt: -50, mdt: -21, sb: 0, hit: 0}, S.optOpts || {}), [ta, tb] = avgRange(o);
  const r = tpAsk(s, withWeapons(s).pieces, null);
  const objs = ['damage', 'damage_avg', 'tp_return'].map(k => `<option value="${k}" ${o.obj === k ? 'selected' : ''}>${t('optObj_' + k, {tp: S.wsTp || 3000, a: ta, b: tb})}</option>`).join('');
  const range = o.obj === 'damage_avg' ? `<label class="optnum">${t('optFrom')} <input type="number" step="250" min="1000" max="3000" data-optopt="tpFrom" value="${ta}"></label>` +
    `<label class="optnum">${t('optTo')} <input type="number" step="250" min="1000" max="3000" data-optopt="tpTo" value="${tb}"> TP</label>` : '';
  const why = t('optWhy', {tp: S.wsTp || 3000}) + (r && r.piece_list ? '' : ' ' + t('optNoRule'));
  const settings = optSettingsHTML(o, true);
  return `<div class="optcard">${optBlock(t('optGoLbl'), optGoButtons('optws') + `<button class="btn ghost" data-tiercost>${t('tcBtn')}</button>`)}` +
    optObjBlock(`<select class="buffsel" data-optopt="obj">${objs}</select>`, helpBtn('opt'), range ? `<div class="optinl">${range}</div>` : '') + `${settings}` +
    (S._help === 'opt' ? `<p class="wshelp">${esc(why)} ${esc(t('tcTip'))}.${o.obj === 'damage_avg' ? ' ' + esc(t('optRangeTip')) + '.' : ''} ${esc(optSettingsHelp(true))}</p>` : '') +
    `</div>` + wsResultHTML(s);
}
// A weaponskill set's result: the try with its buttons and message, then your set against it as the optimizer found
// them (the objective first, the hit rates, the floors set), while the try is the optimizer's own
function wsResultHTML(s){
  const tr = trialRow(s), dr = S.drafts[trialKey(s)] || {}, r = dr.res && trialCount(s) && !(dr.info || {}).edited ? dr.res : null;
  return tr || r ? `<div class="engsec"><div class="kicker">${esc(t('engResKick'))}</div>${tr}${r ? wsVsHTML(r) : ''}</div>` : '';
}
function wsVsHTML(r){
  const o = r.floor || S.optOpts || {}, objLabel = r.obj === 'tp_return' ? t('wsvTp') : r.obj === 'damage_avg' ? t('wsvAvg', {a: r.range[0], b: r.range[1]}) : t('wsvDmg', {tp: r.tp});
  const pct = h => h == null ? null : Math.floor(h);
  const lines = [{label: objLabel + ' ★', get: x => x.raw, fmt: v => r.obj === 'tp_return' ? String(Math.round(v)) : fmtDmg(v), low: false, obj: true},
    {label: t('wsvHit1'), get: x => x.hits ? pct(x.hits.first) : null, fmt: v => v + ' %', low: false},
    {label: t('wsvHit2'), get: x => x.hits ? pct(x.hits.rest) : null, fmt: v => v + ' %', low: false, floor: +o.hit ? v => v >= +o.hit : null}]
    .concat([['pdt', 'DT+PDT', '≤', +o.pdt], ['mdt', 'DT+MDT', '≤', +o.mdt], ['sb', 'Subtle Blow', '≥', +o.sb]].filter(f => f[3]).map(([k, label, op, lim]) =>
      ({label: `${label} ${op} ${lim}`, get: x => x.def ? x.def[k] : null, fmt: v => String(Math.round(v)), low: op === '≤', floor: v => op === '≤' ? v <= lim : v >= lim})));
  const cell = (c, a, b) => { const v = c.get(a), w = c.get(b);
    if (v == null) return `<td>—</td>`;
    return `<td class="${w != null && (c.low ? v < w - 1e-9 : v > w + 1e-9) ? 'better' : ''} ${c.floor && !c.floor(v) ? 'short' : ''}">${c.fmt(v)}</td>`; };
  return `<table class="rdvs"><thead><tr><th></th><th>${esc(t('rdvMine'))}</th><th>${esc(t('rdvTry'))}</th></tr></thead><tbody>` +
    lines.filter(c => c.get(r.start) != null || c.get(r.best) != null).map(c => `<tr class="${c.obj ? 'obj' : ''}"><th>${esc(c.label)}</th>${cell(c, r.start, r.best)}${cell(c, r.best, r.start)}</tr>`).join('') + `</tbody></table>`;
}
// Where the optimizer looks and the floors it keeps, in view: a line each; hit: the weaponskill's hit rate floor (an
// engaged set has none)
function optSettingsHTML(o, hit){
  const num = (k, label) => `<label class="optnum">${label} <input type="number" step="1" data-optopt="${k}" value="${esc(o[k])}"></label>`;
  const wheres = ['mine', 'mine_max', 'all'].map(k => `<option value="${k}" ${(o.where || 'mine') === k ? 'selected' : ''}>${t('optWhere_' + k)}</option>`).join('');
  return optBlock(t('optWhereLbl'), `<select class="buffsel" data-optopt="where">${wheres}</select>` +
      `<label class="optnum"><input type="checkbox" data-optopt="wardOnly" ${o.wardOnly ? 'checked' : ''}> ${t('optWard')}</label>` +
      // an engaged set: the optimizer may choose the weapons too (main and off hand, from yours)
      `<label class="optnum" title="${esc(t(hit ? 'freeWeaponsWsTip' : 'freeWeaponsTip'))}"><input type="checkbox" data-optopt="freeWeapons" ${o.freeWeapons ? 'checked' : ''}> ${t('freeWeapons')}</label>` +
      `<label class="optnum" title="${esc(t('fullSpeedTip', {n: OPT_CORES}))}"><input type="checkbox" data-optopt="fullSpeed" ${o.fullSpeed ? 'checked' : ''}> ${t('fullSpeed')}</label>`) +
    optBlock(t('optFloorsLbl'), `<div class="optfloors">${num('pdt', 'DT+PDT ≤')}${num('mdt', 'DT+MDT ≤')}${num('sb', 'Subtle Blow ≥')}${hit ? num('hit', t('optHitLbl')) : ''}</div>`);
}
// One block of the optimizer's settings: its title, then its controls one under the other
const optBlock = (title, body) => `<div class="optblk"><span class="optlbl">${esc(title)}</span>${body}</div>`;
// The objective's block: its menu with the help button beside it, then what it reads (TP range, the TP the weaponskill goes at)
const optObjBlock = (sel, help, more) => optBlock(t('optObjLbl'), `<div class="optinl">${sel}${help}</div>${more}`);
// The settings' help, for the compartment's ⓘ
function optSettingsHelp(hit){
  return [t('optWardTip'), 'DT+PDT : ' + t('optPdtTip'), 'DT+MDT : ' + t('optMdtTip'), 'Subtle Blow : ' + t('optSbTip')].concat(hit ? [t('optHitLbl') + ' : ' + t('optHitTip')] : []).join('. ') + '.';
}
/* ---- the engaged optimizer: the attack round (atelier-engine/actions.js average_attack_round) ---- */
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
// The round's pieces: its line, your set against the try (when there is one), the calculation folded
function engParts(s){
  const r = engRound(s);
  if (!r) return null;
  const was = trialCount(s) ? engRound(s, true) : null, at = (S.optOpts || {}).engAt || 1000;
  const line = isJumpSet(s.path) ? `<p class="wsdmg">${t('jumpRound', {p: `<b>${Math.round(r.tp)}</b>`, e: esc(enemyKey(buffState().enemy))})}${r.attacks ? ' · ' + t('engAttacks', {a: r.attacks.swings.toFixed(2), h: r.attacks.hits.toFixed(2)}) : ''}</p>` : `<p class="wsdmg">${t('engRound', {t: `<b>${(r.real ? r.real.time : r.time).toFixed(2)} s</b>`, avg: r.time.toFixed(2), at, d: fmtDmg(r.dps),
    p: Math.round(r.tp), e: esc(enemyKey(buffState().enemy))})}${r.attacks ? ' · ' + t('engAttacks', {a: r.attacks.swings.toFixed(2), h: r.attacks.hits.toFixed(2)}) : ''} · ${esc(t('wsDmgTier', {p: buffTier()}))}</p>`;
  const vs = was ? roundVsHTML(was, r, engOpts(s)) : '';
  return {line, vs, calc: r.detail ? roundCalcHTML(r.detail, r.real) : ''};
}
// The round worked out as the engine does it (atelier-engine: average_attack_round, get_tp, get_delay_timing), each step with
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
// The engaged optimizer's compartment: the button, the objective, the TP the weaponskill goes at, the settings
function engOptHTML(s){
  const tr = trialRow(s), p = engineReady() ? engParts(s) : null;
  const result = tr || (p && p.vs) ? `<div class="engsec"><div class="kicker">${esc(t('engResKick'))}</div>${tr}${p ? p.vs : ''}</div>` : '';
  const shown = p ? `<div class="engsec"><div class="kicker">${esc(t('engNowKick'))}</div>${p.line}${p.calc}</div>` : '';
  return engControlsHTML(isJumpSet(s.path)) + (result || shown ? `<div class="engsplit">${result}${shown}</div>` : '');
}
// The search's controls: the button (or its progress), the objective, the TP the weaponskill goes at, the settings
function engControlsHTML(jump){
  if (!engineReady()) return `<p class="tpnote">${t('optNoEngine')}</p>`;
  if (S._optBusy) return `<div class="optcard"><button class="btn" disabled>${t('optBusy')}</button><span class="optprog">${t('optStart')}</span>` +
    `<button class="btn ghost" data-optstop>${t('optStop')}</button></div>`;
  const o = S.optOpts = Object.assign({obj: 'damage', pdt: -50, mdt: -21, sb: 0, hit: 0, engObj: 'tp_real', engAt: 1000}, S.optOpts || {});
  const objs = ENG_OBJS.map(k => `<option value="${k}" ${o.engObj === k ? 'selected' : ''}>${t('engObj_' + k)}</option>`).join('');
  // the TP the weaponskill goes at: only the two times to the weaponskill read it
  if (jump) return `<div class="optcard">${optBlock(t('optGoLbl'), optGoButtons('opteng'))}` +
    optObjBlock(`<span class="optfixed">${esc(t('jumpObj'))}</span>`, helpBtn('engopt'), '') + optSettingsHTML(o, false) +
    (S._help === 'engopt' ? `<p class="wshelp">${esc(t('jumpWhy'))} ${esc(optSettingsHelp(false))}</p>` : '') + `</div>`;
  const at = o.engObj === 'tp_real' || o.engObj === 'tp_time'
    ? `<label class="optnum">${t('engAtLbl')} <input type="number" step="100" min="1000" max="3000" data-optopt="engAt" value="${esc(o.engAt)}"> TP</label>` : '';
  return `<div class="optcard">${optBlock(t('optGoLbl'), optGoButtons('opteng') + `<button class="btn ghost" data-tiercost title="${esc(t('tcTipEng'))}">${t('tcBtn')}</button>`)}` +
    optObjBlock(`<select class="buffsel" data-optopt="engObj">${objs}</select>`, helpBtn('engopt'), at) + optSettingsHTML(o, false) +
    (S._help === 'engopt' ? `<p class="wshelp">${esc(t('engWhy'))} ${esc(optSettingsHelp(false))}</p>` : '') + `</div>`;
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

/* ---- a weaponskill set's average damage line ---- */
function wsDamageHTML(s){
  const v = wsDamage(s);
  if (v == null) return '';
  const b = buffState(), ws = wsOfSet(s) || segs(s.path).pop();
  return `<p class="wsdmg">${t('wsDmg', {ws: esc(ws), d: `<b>${fmtDmg(v)}</b>`, tp: S.wsTp || 3000, e: esc(enemyKey(b.enemy))})} · ${esc(t('wsDmgTier', {p: buffTier()}))}</p>`;
}
