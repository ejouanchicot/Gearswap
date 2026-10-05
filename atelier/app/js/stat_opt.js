// GearSwap Atelier · stat_opt.js: the optimizer for the sets judged by their stats (idle, Enmity, Phalanx, Fast Cast,
// Cure, Refresh...), the PLD / RUN tank sets first. No damage engine: the page reads each piece's stats (stats.js
// pieceStats) and the search (atelier/opt.js, its "stats" mode: O.statFigures) adds them up. The figures follow the
// Paladin guide's solvers (Guide_Paladin tools/solver_common.py, solve_idle / solve_enmity / solve_phalanx / solve_fc):
// objectives in order (the first, then the next ones to part sets as good on it), and floors (DT+PDT, DT+MDT, HP between
// two values, SIRD, Fast Cast, enemy critical hit rate)
// (loaded by atelier/index.html after opt_page.js: see the list there)

Object.assign(T.fr, {
  statObj_def: 'DEF', statObj_hp: 'HP', statObj_enmity: 'Enmity', statObj_phalanx: 'Phalanx', statObj_fc: 'Fast Cast', statObj_sird: 'SIRD',
  statObj_meva: 'Évasion magique', statObj_mdb: 'Bonus déf. magique', statObj_pdtRed: 'Dégâts physiques reçus', statObj_mdtRed: 'Dégâts magiques reçus',
  statObj_ecritRed: 'Critiques ennemis', statObj_cure: 'Cure potency', statObj_refresh: 'Refresh', statObj_regen: 'Regen',
  statD_def: 'VIT × 1,5 + DEF du gear (+ bouclier sous Protect en PLD)', statD_hp: 'HP avec les HP %', statD_enmity: 'jusqu’au plafond +200, buffs compris',
  statD_phalanx: 'palier du skill de renfort + Phalanx reçu', statD_fc: 'jusqu’à 80 %', statD_sird: 'jusqu’à 102 %',
  statD_meva: 'résister aux sorts', statD_mdb: 'divise les dégâts magiques', statD_pdtRed: 'DT+PDT plafonnés à −50 %, puis PDT II',
  statD_mdtRed: 'DT+MDT (+ Shell) plafonnés, puis MDT II', statD_ecritRed: 'réduction du gear (10 % → 1 % : −9 avec les mérites −5… à toi de compter)',
  statD_cure: 'jusqu’à 50 %', statD_refresh: 'MP par tick', statD_regen: 'HP par tick',
  statThen: 'puis', statNone: '—', statFloors: 'Planchers', statHpMin: 'HP ≥', statHpMax: 'HP ≤', statSird: 'SIRD ≥', statFc: 'Fast Cast ≥',
  statEcrit: 'Crit. ennemis ≤', statEnm: 'Enmity ≥', statPhx: 'Phalanx ≥',
  statWhy: 'Les sets sans dégâts à calculer (repos, Enmity, Phalanx, Fast Cast, Cure…) se jugent sur leurs stats : la recherche ' +
    'additionne celles de chaque pièce, comme les solveurs du guide Paladin. Le premier objectif décide ; les suivants départagent les sets ' +
    'aussi bons sur lui. Un plancher à 0 est ignoré. DEF : ta DEF mesurée en jeu sans gear, + DEF et VIT × 1,5 du set ; en PLD sous Protect, ' +
    'la DEF du bouclier en plus (Shield Barrier, prise au moment du sort). Les dégâts physiques reçus selon l’attaque du monstre ne sont ' +
    'pas calculés : la formule des monstres n’est pas publiée (BG Wiki PDIF). Plus de DEF = moins de dégâts, sans chiffre exact.',
  statDone: 'Optimisé : {o} {a} → {b}, {n} pièce(s) changée(s) dans ton essai · DT+PDT {p} · DT+MDT {m}.',
  statSame: 'Ton set est déjà le meilleur trouvé : {o} {v}.', statShield: 'dont bouclier (Shield Barrier) +{n}',
  tkBlock: 'Blocage', tkBlockTip: '{s} : {b} % de base à skill égal à celui du monstre (+0,2325 % par point d’écart), Palisade +30, Reprisal ×1,5 (×3 avec Priwen) ; un coup bloqué perd {r} % (guide Paladin).',
  tkCrit: 'Critiques ennemis', tkCritTip: '10 % au plus, 1 % au moins : mérites −{m}, gear {g}.', tkOver: '{n} de trop',
  tkLoss: 'Perte d’inimitié', tkLossTip: 'Réduction de la perte d’inimitié quand tu prends un coup : 1 % pour +2 d’Enmity, 50 % au plus. Le gear « Reduces Enmity loss » (Burtgang, Chev. Cuisses +3) et Foe Sirvente s’y multiplient, non comptés ici (−75 % au total au plus).'});
Object.assign(T.en, {
  statObj_def: 'DEF', statObj_hp: 'HP', statObj_enmity: 'Enmity', statObj_phalanx: 'Phalanx', statObj_fc: 'Fast Cast', statObj_sird: 'SIRD',
  statObj_meva: 'Magic evasion', statObj_mdb: 'Magic def. bonus', statObj_pdtRed: 'Physical damage taken', statObj_mdtRed: 'Magic damage taken',
  statObj_ecritRed: 'Enemy critical hits', statObj_cure: 'Cure potency', statObj_refresh: 'Refresh', statObj_regen: 'Regen',
  statD_def: 'VIT × 1.5 + gear DEF (+ the shield under Protect on PLD)', statD_hp: 'HP with HP %', statD_enmity: 'up to the +200 cap, buffs in',
  statD_phalanx: 'the enhancing skill’s step + Phalanx received', statD_fc: 'up to 80 %', statD_sird: 'up to 102 %',
  statD_meva: 'resist spells', statD_mdb: 'divides magic damage', statD_pdtRed: 'DT+PDT capped at −50 %, then PDT II',
  statD_mdtRed: 'DT+MDT (+ Shell) capped, then MDT II', statD_ecritRed: 'the gear’s cut (10 % → 1 %: −9 with the −5 merits… yours to count)',
  statD_cure: 'up to 50 %', statD_refresh: 'MP a tick', statD_regen: 'HP a tick',
  statThen: 'then', statNone: '—', statFloors: 'Floors', statHpMin: 'HP ≥', statHpMax: 'HP ≤', statSird: 'SIRD ≥', statFc: 'Fast Cast ≥',
  statEcrit: 'Enemy crit ≤', statEnm: 'Enmity ≥', statPhx: 'Phalanx ≥',
  statWhy: 'Sets with no damage to work out (idle, Enmity, Phalanx, Fast Cast, Cure…) are judged on their stats: the search adds up ' +
    'each piece’s, as the Paladin guide’s solvers do. The first objective decides; the next ones part sets as good on it. A floor at 0 is ' +
    'ignored. DEF: your DEF measured in game without gear, + the set’s DEF and VIT × 1.5; on PLD under Protect, the shield’s DEF too (Shield ' +
    'Barrier, taken when the spell is cast). Physical damage taken by the monster’s attack is not worked out: the monsters’ formula is not ' +
    'published (BG Wiki PDIF). More DEF = less damage, with no exact figure.',
  statDone: 'Optimised: {o} {a} → {b}, {n} piece(s) changed in your try · DT+PDT {p} · DT+MDT {m}.',
  statSame: 'Your set is already the best found: {o} {v}.', statShield: 'with the shield (Shield Barrier) +{n}',
  tkBlock: 'Block', tkBlockTip: '{s}: {b} % at the monster’s own skill (+0.2325 % a point of difference), Palisade +30, Reprisal ×1.5 (×3 with Priwen); a blocked hit loses {r} % (Paladin guide).',
  tkCrit: 'Enemy critical hits', tkCritTip: '10 % at most, 1 % at least: merits −{m}, gear {g}.', tkOver: '{n} too many',
  tkLoss: 'Enmity lost', tkLossTip: 'Cut of the enmity lost when you take a hit: 1 % a +2 Enmity, 50 % at most. The “Reduces Enmity loss” gear (Burtgang, Chev. Cuisses +3) and Foe Sirvente multiply in, not counted here (−75 % in all at most).'});

const STAT_OBJS = ['def', 'hp', 'enmity', 'phalanx', 'fc', 'sird', 'meva', 'mdb', 'pdtRed', 'mdtRed', 'ecritRed', 'cure', 'refresh', 'regen'];
const STAT_PCT = new Set(['fc', 'sird', 'pdtRed', 'mdtRed', 'ecritRed', 'cure']);
const statFmt = k => v => v == null ? '—' : ((Math.round(v * 10) / 10) || 0).toLocaleString(S.lang === 'fr' ? 'fr-FR' : 'en-US') + (STAT_PCT.has(k) ? ' %' : '');
// A set the stats optimizer takes: every set but the weaponskill, engaged and Jump ones (their own optimizers), and
// the weapon sets
const statSet = s => !!s && !['ws', 'engaged', 'weapons', 'pet'].includes(family(s.path, s.pieces)) && !isJumpSet(s.path);
// What a set is for when nothing was chosen: the guide's profiles (idle DEF then Enmity then MDB; Enmity then DEF;
// Phalanx then DEF; Fast Cast then HP)
function statDefault(s){
  const p = s.path, fam = family(s.path, s.pieces), tank = ['PLD', 'RUN'].includes(S.job);
  if (/phalanx/i.test(p)) return ['phalanx', 'def', 'hp'];
  if (fam === 'fc') return ['fc', 'hp', 'pdtRed'];
  if (/enmity|flash|crusade|provoke|foil|sird|sentinel|rampart|vallation|valiance|pflug|swordplay|battuta|liement|gambit|rayke/i.test(p)) return ['enmity', 'def', 'hp'];
  if (/cur(e|a|aga)/i.test(p)) return ['cure', 'hp', 'enmity'];
  if (/refresh/i.test(p)) return ['refresh', 'pdtRed', 'mdtRed'];
  if (/regen/i.test(p)) return ['regen', 'pdtRed', 'mdtRed'];
  if (/meva|mdt|magic/i.test(p)) return ['mdtRed', 'meva', 'mdb'];
  if (fam === 'idle' || fam === 'special') return tank ? ['def', 'enmity', 'mdb'] : ['pdtRed', 'mdtRed', 'hp'];
  return ['hp', 'pdtRed', 'mdtRed'];
}
// The objectives and floors kept for that set (S.optOpts.statBy[path]: {objs, floor})
function statOpts(s){
  const by = (S.optOpts || {}).statBy || {}, mine = by[s.path] || {}, objs = (mine.objs || statDefault(s)).slice(0, 3);
  return {objs, floor: Object.assign({pdt: 0, mdt: 0, hp: 0, hpMax: 0, sird: 0, fc: 0, ecrit: 0, enmity: 0, phalanx: 0}, statFloorDefault(s, objs[0]), mine.floor || {})};
}
// The floors a tank's idle and Enmity sets start with (the guide's solve_idle / solve_enmity: DT+PDT at the -50 % cap,
// the gear's enemy critical hit rate -5 beside the -5 of the merits); 0 (no floor) elsewhere
function statFloorDefault(s, first){
  if (!['PLD', 'RUN'].includes(S.job)) return {};
  if (first === 'def' && ['idle', 'special'].includes(family(s.path, s.pieces))) return {pdt: -50, ecrit: -5};
  if (first === 'enmity') return {pdt: -50};
  return {};
}
function setStatOpts(path, patch){
  const by = Object.assign({}, (S.optOpts || {}).statBy), cur = by[path] || {};
  by[path] = Object.assign({}, cur, patch, patch.floor ? {floor: Object.assign({}, cur.floor, patch.floor)} : {});
  S.optOpts = Object.assign({}, S.optOpts, {statBy: by}); save();
}

/* ---- the pieces and the character, as plain data for the search (a worker has no page to ask) ---- */
// A piece's stats the search reads (stats.js keys), the shield flagged (Shield Barrier)
function statVec(p, slot){
  const r = p && !isEmpty(p) ? pieceStats(p, slot) : null, v = k => r && r.stats[k] ? r.stats[k].v || 0 : 0, out = {};
  if (!r) return {};
  for (const k of ['hp', 'hp%', 'def', 'vit', 'dt', 'pdt', 'mdt', 'pdt2', 'mdt2', 'bdt', 'enmity', 'phalanx', 'sird', 'fc', 'meva', 'mdb', 'ecrit', 'cure', 'refresh', 'regen'])
    if (v(k)) out[k] = v(k);
  if (v('skill:enhancing magic skill')) out.enh = v('skill:enhancing magic skill');
  return out;
}
function withVec(p, slot){
  if (!p) return p;
  const q = Object.assign({}, p, {st: statVec(p, slot)});
  if (slot === 'sub') { const it = itemOf(p.name); if (it && it.Type === 'Shield') q.shield = true; }
  return q;
}
function withVecs(pieces){
  const out = {};
  for (const [slot, p] of Object.entries(pieces || {})) out[slot] = withVec(p, slot);
  return out;
}
// The character without gear: HP before the gear's HP %, DEF (Protect in), the enhancing skill, the buffs' Enmity
// and Shell; Shield Barrier when a PLD is under Protect (BG Wiki: Protect cast by a PLD adds its shield's DEF)
function statBase(s){
  const r = charStats(s, {}), b = buffState(), B = buffTotals(), c = measuredChar() || {};
  const cur = r ? r.cur : {};
  // SIRD merits: 2 % a level (Guide_Paladin solver_common: Merit_SIRD 10 at 5/5)
  return {hp: cur.hp || 0, def: cur.def || 0, enh: c.skills ? skillLevel(c, 'enhancing magic') : 0, enmity: B.enmity || 0, sird: 2 * ((c.merits || {}).spell_interruption_rate || 0),
    shell: B.shell || 0, mdb: (B.mdb || 0) + (r ? traitOf('mdb', c) + giftOf('mdb', c) : 0), meva: 0,
    shieldBarrier: S.job === 'PLD' && !!PROTECT[b.protect]};
}
const statContext = s => ({mode: 'stats', job: S.job, stat: {base: statBase(s)}});

/* ---- the tank figures the guide adds (Guide_Paladin 03 Defense, 02 Enmity), shown in the Tanking compartment ---- */
// Shield Barrier (PLD trait): Protect cast by a PLD adds its shield's DEF (taken when cast; here the set's shield).
// Returns the buff totals with it (a copy), or as they are
function shieldBarrier(B, sub){
  if (S.job !== 'PLD' || !PROTECT[buffState().protect] || !sub || isEmpty(sub)) return B;
  const it = itemOf(sub.name), r = it && it.Type === 'Shield' ? pieceStats(sub, 'sub') : null, def = r && r.stats.def ? r.stats.def.v : 0;
  if (!def) return B;
  return Object.assign({}, B, {def: (B.def || 0) + def, _by: B._by.concat([{src: 'Shield Barrier · ' + sub.name, k: 'def', v: def}])});
}
// The shields the guide gives figures for: base block rate (at the attacker's skill) and the damage a block takes off
const ULTIMATE_SHIELDS = {Aegis: [50, 75], Srivatsa: [50, 75], Ochain: [108, 60], Duban: [108, 60]};
// The lines under the damage taken: block, the enemy's critical hits left, the Enmity lost on a hit
function tankExtraHTML(c, set, B, enm){
  const v = k => (set[k] || {}).v || 0, rows = [], sub = (S._curSet ? withWeapons(S._curSet).pieces.sub : null) || {};
  const sh = ULTIMATE_SHIELDS[sub.name];
  if (sh && S.job === 'PLD') {
    const mul = B.blockmul || 1;
    const rate = Math.min(100, (sh[0] + (B.block || 0)) * mul);
    rows.push(statLi(t('tkBlock'), `${Math.round(rate)} %`, `−${sh[1]} %`, '', t('tkBlockTip', {s: sub.name, b: sh[0], r: sh[1]})));
  }
  const merit = ((c.merits || {}).enemy_critical_hit_rate || 0), gear = v('ecrit');
  if (['PLD', 'RUN'].includes(S.job) || gear) {
    const left = Math.max(1, 10 - merit + gear), over = Math.max(0, 1 - (10 - merit + gear));
    rows.push(statLi(t('tkCrit'), `${left} %`, over ? t('tkOver', {n: over}) : '', '', t('tkCritTip', {m: merit, g: gear})));
  }
  if (enm > 0 && ['PLD', 'RUN'].includes(S.job))
    rows.push(statLi(t('tkLoss'), `−${Math.min(50, enm / 2)} %`, '', '', t('tkLossTip')));
  return rows.join('');
}
// A set's figures (the try as shown, or plain: the file's set)
function statFigures(s, plain){
  const pieces = plain ? withoutTrial(() => withWeapons(s).pieces) : withWeapons(s).pieces;
  const v = {};
  for (const [slot, p] of Object.entries(optPieces(pieces))) v[slot] = withVec(p, slot);
  return FFXI.opt.statFigures(statContext(s).stat, v);
}

/* ---- the search ---- */
async function optimizeStats(s){
  if (!engineReady() || !statSet(s)) return;
  const k = trialKey(s), o = Object.assign({}, S.optOpts), so = statOpts(s), base = withoutTrial(() => withWeapons(s).pieces);
  const choices = optChoices(new Set(Object.keys(ONLY_AUGS)));
  for (const slot of Object.keys(choices)) choices[slot] = choices[slot].map(p => withVec(p, slot));
  if (o.freeWeapons) choices.weapons = weaponPairs(base).map(x => ({main: withVec(x.main, 'main'), sub: x.sub ? withVec(x.sub, 'sub') : null}));
  const start = withVecs(startOf(base));
  const input = {ctx: statContext(s), start, choices, prefilter: o.where === 'all' ? 25 : 0,
    opts: {fast: (o.search || 'fast') !== 'classic', objective: so.objs[0], then: so.objs.slice(1), floor: so.floor}};
  optLaunch(s, k, input, Object.assign({}, o, {stat: so.objs[0], statFloor: so.floor}));
}

/* ---- the page: objectives, floors, the result's lines ---- */
function statWhatHTML(s){
  const so = statOpts(s), cur = so.objs[0];
  const objs = `<div class="opobjs" role="radiogroup">${STAT_OBJS.map(k => `<button class="opobj ${k === cur ? 'on' : ''}" role="radio" aria-checked="${k === cur}" ` +
    `data-statobj="${k}"><b>${esc(t('statObj_' + k))}</b><span>${esc(t('statD_' + k))}</span></button>`).join('')}</div>`;
  const then = i => `<select class="buffsel" data-statthen="${i}">${['', ...STAT_OBJS].filter(k => k !== cur).map(k =>
    `<option value="${k}" ${(so.objs[i] || '') === k ? 'selected' : ''}>${esc(k ? t('statObj_' + k) : t('statNone'))}</option>`).join('')}</select>`;
  const help = S._help === 'optpage' ? `<p class="wshelp">${esc(t('statWhy'))} ${esc(t('opHelp'))}</p>` : '';
  const num = (k, label) => `<label class="opf">${label} <input type="number" step="1" data-statfloor="${k}" value="${esc(so.floor[k])}"></label>`;
  const floors = `<h4 class="ophd2">${t('statFloors')}</h4><div class="opparams">${num('pdt', 'DT+PDT ≤')}${num('mdt', 'DT+MDT ≤')}${num('hp', t('statHpMin'))}` +
    `${num('hpMax', t('statHpMax'))}${num('sird', t('statSird'))}${num('fc', t('statFc'))}${num('ecrit', t('statEcrit'))}${num('enmity', t('statEnm'))}${num('phalanx', t('statPhx'))}</div>`;
  const search = opSearchHTML(S.optOpts || {}, false, true);
  return `<h3 class="ophd">${t('opWhat')} ${helpBtn('optpage')}</h3>${help}${objs}<div class="opparams"><span class="opf">${esc(t('statThen'))}</span>${then(1)}${then(2)}</div>` +
    floors + search;
}
// The result's lines: the objectives first, then every figure, the floors marked
function statRows(s){
  const so = statOpts(s), fl = so.floor, on = k => +fl[k];
  const rows = STAT_OBJS.map(k => ({id: k, label: t('statObj_' + k), get: f => f[k], fmt: statFmt(k)}));
  const lim = {hp: v => (!on('hp') || v >= fl.hp) && (!on('hpMax') || v <= fl.hpMax), sird: v => !on('sird') || v >= fl.sird, fc: v => !on('fc') || v >= fl.fc,
    ecritRed: v => !on('ecrit') || -v <= fl.ecrit, enmity: v => !on('enmity') || v >= fl.enmity, phalanx: v => !on('phalanx') || v >= fl.phalanx};
  for (const r of rows) if (lim[r.id]) r.floor = lim[r.id];
  rows.push({id: 'pdt', label: on('pdt') ? `DT+PDT ≤ ${fl.pdt}` : 'DT+PDT', get: f => f.pdt, fmt: v => String(Math.round(v)), low: true, floor: on('pdt') ? v => v <= fl.pdt : null},
    {id: 'mdt', label: on('mdt') ? `DT+MDT ≤ ${fl.mdt}` : 'DT+MDT', get: f => f.mdt, fmt: v => String(Math.round(v)), low: true, floor: on('mdt') ? v => v <= fl.mdt : null});
  const first = so.objs.map(k => rows.find(r => r.id === k)).filter(Boolean);
  return first.concat(rows.filter(r => !first.includes(r)));
}
function statResultHTML(s){
  const now = statFigures(s), was = trialCount(s) ? statFigures(s, true) : null, rows = statRows(s), main = rows[0];
  const v = main.get(now), w = was ? main.get(was) : null, d = was ? v - w : null;
  const big = `<div class="opbig"><div><span class="muted small">${esc(main.label)}${was ? ' · ' + t('rdvTry') : ''}</span><div class="opval"><b>${main.fmt(v)}</b>` +
    (d ? `<em class="${d >= 0 ? 'up' : 'down'}">${d >= 0 ? '+' : '−'}${main.fmt(Math.abs(d))}</em>` : '') + `</div>` +
    (was ? `<span class="muted small">${t('opNow')} : ${main.fmt(w)}</span>` : '') +
    (now.shield ? `<span class="muted small"> · DEF ${esc(t('statShield', {n: now.shield}))}</span>` : '') + `</div></div>`;
  const cell = (r, x, y) => { const a = r.get(x), b = y ? r.get(y) : null;
    const better = b != null && (r.low ? a < b - 1e-9 : a > b + 1e-9), bad = r.floor && !r.floor(a);
    return `<td class="${better ? 'better' : ''} ${bad ? 'short' : ''}">${r.fmt(a)}</td>`; };
  const shown = rows.filter((r, i) => i < 3 || r.get(now) || (was && r.get(was)) || r.floor);
  const table = `<table class="rdvs optable"><thead><tr><th></th>${was ? `<th>${t('rdvMine')}</th>` : ''}<th>${was ? t('rdvTry') : t('rdvMine')}</th></tr></thead><tbody>` +
    shown.map((r, i) => `<tr class="${i ? '' : 'obj'}"><th>${esc(r.label)}${i ? '' : ' ★'}</th>${was ? cell(r, was, now) : ''}${cell(r, now, was)}</tr>`).join('') + `</tbody></table>`;
  return `<h3 class="ophd">${t('opResult')}</h3>${big}<div class="opres">${table}<div class="opside">${opChangesHTML(s)}</div></div>` +
    `${trialRow(s) || `<p class="muted small">${esc(t('opNoTry'))}</p>`}`;
}
// The toast once a search is done
function statDoneText(s, res, tr){
  const k = statOpts(s).objs[0], f = statFmt(k), def = res.best.def || {}, label = t('statObj_' + k);
  return Object.keys(tr).length ? t('statDone', {o: label, a: f(res.start.raw), b: f(res.best.raw), n: Object.keys(tr).length, p: Math.round(def.pdt || 0), m: Math.round(def.mdt || 0)})
    : t('statSame', {o: label, v: f(res.best.raw)});
}
