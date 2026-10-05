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
  statObj_cureSelf: 'Cure IV sur toi', statD_cureSelf: 'HP vraiment soignés : la puissance du Cure (MND, VIT, skill, Cure Potency) dans l’écart de HP ouvert par le Fast Cast',
  statCure4: 'Puissance du Cure IV', statCure4Tip: 'Ce que ton Cure IV soignerait sans limite (BG Wiki, Cure Formula ; en PLD Majesty toujours compté, +25 de Cure Potency II), le jour et la météo à part.',
  statObj_hpLow: 'HP les plus bas', statD_hpLow: 'Fast Cast d’un Cure sur toi : HP bas, le set de Cure les remonte et le Cure remplit l’écart',
  statKeepOwn: 'Garder les pièces propres à ce set ({p})', statKeepOwnTip: 'Les pièces que ce set met par-dessus {b} (celle qui renforce la JA) restent : la recherche choisit le reste.',
  statRef: 'HP vs Fast Cast', statRefTip: 'HP du set moins ceux du Fast Cast {f} ({h} HP), le set classique le plus bas en HP, porté avant chaque sort : '
    + 'les autres sets visent entre lui et lui + 200 pour qu’un changement de set ne fasse pas perdre de HP (guide Paladin, HP Management : écart de 200 au plus).',
  statRefLine: 'HP de référence : {h} (Fast Cast {f}) · les sets tank visent {a} à {b}.',
  statGap: 'HP gagnés au midcast', statGapTip: 'HP du set {m} moins ceux du Fast Cast {f} : ce qui manque au moment du Cure, donc ce qu’il peut soigner en entier (guide Paladin, CURE SELF).',
  statD_def: 'VIT × 1,5 + DEF du gear (+ bouclier sous Protect en PLD)', statD_hp: 'HP avec les HP %', statD_enmity: 'jusqu’au plafond +200, buffs compris',
  statD_phalanx: 'palier du skill de renfort + Phalanx reçu', statD_fc: 'jusqu’à 80 %', statD_sird: 'jusqu’à 102 %',
  statD_meva: 'résister aux sorts', statD_mdb: 'divise les dégâts magiques', statD_pdtRed: 'DT+PDT plafonnés à −50 %, puis PDT II',
  statD_mdtRed: 'DT+MDT (+ Shell) plafonnés, puis MDT II', statD_ecritRed: 'réduction du gear (10 % → 1 % : −9 avec les mérites −5… à toi de compter)',
  statD_cure: 'jusqu’à 50 %', statD_refresh: 'MP par tick', statD_regen: 'HP par tick',
  aliasTip: '{a} est le même set que {s} (une ligne « = » dans ton fichier) : le modifier modifie les deux.', statThen: 'puis', statNone: '—', statFloors: 'Planchers', statHpMin: 'HP ≥', statHpMax: 'HP ≤', statSird: 'SIRD ≥', statFc: 'Fast Cast ≥',
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
  statObj_cureSelf: 'Cure IV on yourself', statD_cureSelf: 'HP really healed: the Cure’s power (MND, VIT, skill, Cure Potency) within the HP gap the Fast Cast opened',
  statCure4: 'Cure IV power', statCure4Tip: 'What your Cure IV would heal with no limit (BG Wiki, Cure Formula; on PLD Majesty always counted, Cure Potency II +25), day and weather aside.',
  statObj_hpLow: 'Lowest HP', statD_hpLow: 'Fast Cast of a Cure on yourself: low HP, the Cure set raises them and the Cure fills the gap',
  statKeepOwn: 'Keep this set’s own pieces ({p})', statKeepOwnTip: 'The pieces this set lays over {b} (the one that boosts the ability) stay: the search picks the rest.',
  statRef: 'HP vs Fast Cast', statRefTip: 'HP of the set less those of the Fast Cast {f} ({h} HP), the lowest classic set in HP, worn before every spell: '
    + 'the other sets aim between it and it + 200 so a set change loses no HP (Paladin guide, HP Management: 200 apart at most).',
  statRefLine: 'Reference HP: {h} (Fast Cast {f}) · the tank sets aim at {a} to {b}.',
  statGap: 'HP gained at midcast', statGapTip: 'HP of the set {m} less those of the Fast Cast {f}: what is missing when the Cure lands, so what it can heal in full (Paladin guide, CURE SELF).',
  statD_def: 'VIT × 1.5 + gear DEF (+ the shield under Protect on PLD)', statD_hp: 'HP with HP %', statD_enmity: 'up to the +200 cap, buffs in',
  statD_phalanx: 'the enhancing skill’s step + Phalanx received', statD_fc: 'up to 80 %', statD_sird: 'up to 102 %',
  statD_meva: 'resist spells', statD_mdb: 'divides magic damage', statD_pdtRed: 'DT+PDT capped at −50 %, then PDT II',
  statD_mdtRed: 'DT+MDT (+ Shell) capped, then MDT II', statD_ecritRed: 'the gear’s cut (10 % → 1 %: −9 with the −5 merits… yours to count)',
  statD_cure: 'up to 50 %', statD_refresh: 'MP a tick', statD_regen: 'HP a tick',
  aliasTip: '{a} is the same set as {s} (a “=” line in your file): changing it changes both.', statThen: 'then', statNone: '—', statFloors: 'Floors', statHpMin: 'HP ≥', statHpMax: 'HP ≤', statSird: 'SIRD ≥', statFc: 'Fast Cast ≥',
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

const STAT_OBJS = ['def', 'hp', 'hpLow', 'cureSelf', 'enmity', 'phalanx', 'fc', 'sird', 'meva', 'mdb', 'pdtRed', 'mdtRed', 'ecritRed', 'cure', 'refresh', 'regen'];
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
  // a self Cure's Fast Cast: capped, then as few HP as can be (Guide_Paladin CURE SELF: the midcast's HP open the gap)
  if (fam === 'fc' && /cure/i.test(p) && /self/i.test(p)) return ['fc', 'hpLow'];
  if (fam === 'fc') return ['fc', 'hp', 'pdtRed'];
  if (/cur(e|a|aga)/i.test(p) && /self/i.test(p)) return ['cureSelf', 'pdtRed', 'hp'];
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
// (SIRD sets and Cures: SIRD 102 with the merits, the guide's benchmark; a Fast Cast: capped at 80)
// A tank's other sets: their HP between the reference and 200 more (hpRef)
function statFloorDefault(s, first){
  const fam = family(s.path, s.pieces), sird = /sird/i.test(s.path) ? {sird: 102} : {};
  if (first === 'fc') return {fc: 80};
  if (!['PLD', 'RUN'].includes(S.job)) return sird;
  const ref = hpRef(s), hp = ref && !cureGap(s) ? {hp: ref.hp, hpMax: ref.hp + HP_SPREAD} : {};
  if (first === 'def' && ['idle', 'special'].includes(fam)) return Object.assign({pdt: -50, ecrit: -5}, hp);
  if (first === 'enmity') return Object.assign({pdt: -50}, sird, hp);
  if (first === 'cure' || first === 'cureSelf') return {sird: 102};
  return Object.assign({}, sird, hp);
}
// The reference HP of a tank's sets (Guide_Paladin HP Management): the classic Fast Cast set's (sets.precast.FC), the
// lowest in HP of the sets worn in the cycle (idle, Fast Cast, midcast or ability, idle) and worn before every spell.
// Swapping to a set with fewer max HP cuts the current HP, and swapping back does not give them back: the other sets
// keep within HP_SPREAD over it (the guide: idle 3197, Fast Cast 3044, Full Enmity 3045). Not for the Fast Cast sets
// themselves, nor the self Cure pair (its gap is on purpose: cureGap). {hp, path} or null
const HP_SPREAD = 200;
function hpRef(s){
  if (!['PLD', 'RUN'].includes(S.job) || family(s.path, s.pieces) === 'fc') return null;
  const d = data(), fc = d && d.sets.find(x => x.path === 'sets.precast.FC');
  return fc ? {hp: statFigures(fc, true).hp, path: fc.path} : null;
}
// A set laid over another one (sets.precast.JA.Sentinel = FullEnmity + Caballarius Leggings): its own pieces stay
// when asked (a job ability's set: on by default), only the rest is searched. The slots kept, or none
function keptSlots(s){
  if (!s.base || !(s.own || []).length) return [];
  const mine = ((S.optOpts || {}).statBy || {})[s.path] || {};
  const on = mine.keepOwn != null ? mine.keepOwn : family(s.path, s.pieces) === 'ja';
  return on ? s.own.slice() : [];
}
// The HP a self Cure's midcast set opens over its Fast Cast (the other set of the pair: sets.precast.FC.CureSelf and
// sets.midcast.CureSelf, any names with Cure and Self), or null
function cureGap(s){
  if (!/cure/i.test(s.path) || !/self/i.test(s.path)) return null;
  const fc = family(s.path, s.pieces) === 'fc', d = data();
  const other = d && d.sets.find(x => x.path !== s.path && /cure/i.test(x.path) && /self/i.test(x.path) && (family(x.path, x.pieces) === 'fc') !== fc && family(x.path, x.pieces) !== 'ws');
  if (!other) return null;
  const hp = set => statFigures(set, true).hp;
  return {other, gap: f => fc ? hp(other) - f.hp : f.hp - hp(other), mid: fc ? other.path : s.path, pre: fc ? s.path : other.path};
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
  if (r.stats['x:potency of cure effect received']) out.curerecv = r.stats['x:potency of cure effect received'].v;
  if (v('skill:healing magic skill')) out.heal = v('skill:healing magic skill');
  for (const k of ['hp', 'hp%', 'def', 'vit', 'mnd', 'cure2', 'dt', 'pdt', 'mdt', 'pdt2', 'mdt2', 'bdt', 'enmity', 'phalanx', 'sird', 'fc', 'meva', 'mdb', 'ecrit', 'cure', 'refresh', 'regen'])
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
  // a self Cure's set: the HP its Fast Cast leaves (cureGap), MND / VIT / Healing skill for the Cure's power
  // (a PLD: Majesty's Cure Potency II +25 counted, on or not: the guide's Cure sets take it as always up)
  const pair = s && cureGap(s), pre = pair && family(s.path, s.pieces) !== 'fc' ? statFigures(pair.other, true).hp : null;
  return {preHp: pre, mnd: cur.mnd || 0, vit: cur.vit || 0, heal: c.skills ? skillLevel(c, 'healing magic') : 0, cure2: Math.max(B.cure2 || 0, S.job === 'PLD' ? 25 : 0),
    hp: cur.hp || 0, def: cur.def || 0, enh: c.skills ? skillLevel(c, 'enhancing magic') : 0, enmity: B.enmity || 0, sird: 2 * ((c.merits || {}).spell_interruption_rate || 0),
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
  for (const slot of keptSlots(s)) delete choices[slot];
  for (const slot of Object.keys(choices)) choices[slot] = choices[slot].map(p => withVec(p, slot));
  if (o.freeWeapons && !keptSlots(s).some(x => x === 'main' || x === 'sub')) choices.weapons = weaponPairs(base).map(x => ({main: withVec(x.main, 'main'), sub: x.sub ? withVec(x.sub, 'sub') : null}));
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
  const own = family(s.path, s.pieces) === 'ja' && s.base && (s.own || []).length ? `<div class="opparams"><label class="opf" title="${esc(t('statKeepOwnTip', {b: shortPath(s.base)}))}"><input type="checkbox" data-statkeep ${keptSlots(s).length ? 'checked' : ''}> ` +
    `${esc(t('statKeepOwn', {p: s.own.map(sl => (withWeapons(s).pieces[sl] || {}).name || sl).join(', ')}))}</label></div>` : '';
  const ref = cureGap(s) ? null : hpRef(s);
  const refLine = ref ? `<p class="muted small">${esc(t('statRefLine', {h: ref.hp, f: shortPath(ref.path), a: ref.hp, b: ref.hp + HP_SPREAD}))}</p>` : '';
  return `<h3 class="ophd">${t('opWhat')} ${helpBtn('optpage')}</h3>${help}${objs}<div class="opparams"><span class="opf">${esc(t('statThen'))}</span>${then(1)}${then(2)}</div>` +
    own + floors + refLine + search;
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
  const pair = cureGap(s), ref = pair ? null : hpRef(s);
  if (pair && family(s.path, s.pieces) !== 'fc') rows.push({id: 'cure4', label: t('statCure4'), get: f => f.cureIV, fmt: v => String(Math.round(v)), tip: t('statCure4Tip')});
  if (ref) rows.push({id: 'ref', label: t('statRef'), get: f => f.hp - ref.hp, fmt: v => (v > 0 ? '+' : '') + Math.round(v), tip: t('statRefTip', {f: shortPath(ref.path), h: ref.hp}),
    floor: v => v >= 0 && v <= HP_SPREAD});
  if (pair) rows.push({id: 'gap', label: t('statGap'), get: f => pair.gap(f), fmt: v => String(Math.round(v)), tip: t('statGapTip', {m: shortPath(pair.mid), f: shortPath(pair.pre)})});
  const first = so.objs.map(k => rows.find(r => r.id === k)).filter(Boolean);
  // the gap (and the Cure's power) right under the objectives: it is what the pair of sets is for; Lowest HP only as an objective
  const near = rows.filter(r => ['gap', 'ref', 'cure4'].includes(r.id) && !first.includes(r));
  const rest = rows.filter(r => !first.includes(r) && !near.includes(r) && r.id !== 'hpLow');
  return first.concat(near, rest);
}
function statResultHTML(s){
  const now = statFigures(s), was = trialCount(s) ? statFigures(s, true) : null, rows = statRows(s), main = rows[0];
  const v = main.get(now), w = was ? main.get(was) : null, d = was ? v - w : null;
  const big = `<div class="opbig"><div><span class="muted small">${esc(main.label)}${was ? ' · ' + t('rdvTry') : ''}</span><div class="opval"><b>${main.fmt(v)}</b>` +
    (d ? `<em class="${d >= 0 ? 'up' : 'down'}">${d >= 0 ? '+' : '−'}${main.fmt(Math.abs(d))}</em>` : '') + `</div>` +
    (was ? `<span class="muted small">${t('opNow')} : ${main.fmt(w)}</span>` : '') +
    (now.shield && main.id === 'def' ? `<span class="muted small"> · DEF ${esc(t('statShield', {n: now.shield}))}</span>` : '') + `</div></div>`;
  const cell = (r, x, y) => { const a = r.get(x), b = y ? r.get(y) : null;
    const better = b != null && (r.low ? a < b - 1e-9 : a > b + 1e-9), bad = r.floor && !r.floor(a);
    return `<td class="${better ? 'better' : ''} ${bad ? 'short' : ''}">${r.fmt(a)}</td>`; };
  const shown = rows.filter((r, i) => i < 3 || r.get(now) || (was && r.get(was)) || r.floor);
  const table = `<table class="rdvs optable"><thead><tr><th></th>${was ? `<th>${t('rdvMine')}</th>` : ''}<th>${was ? t('rdvTry') : t('rdvMine')}</th></tr></thead><tbody>` +
    shown.map((r, i) => `<tr class="${i ? '' : 'obj'}"><th ${r.tip ? `title="${esc(r.tip)}"` : ''}>${esc(r.label)}${i ? '' : ' ★'}</th>${was ? cell(r, was, now) : ''}${cell(r, now, was)}</tr>`).join('') + `</tbody></table>`;
  return `<h3 class="ophd">${t('opResult')}</h3>${big}<div class="opres">${table}<div class="opside">${opChangesHTML(s)}</div></div>` +
    `${trialRow(s) || `<p class="muted small">${esc(t('opNoTry'))}</p>`}`;
}
// The toast once a search is done
function statDoneText(s, res, tr){
  const k = statOpts(s).objs[0], f = statFmt(k), def = res.best.def || {}, label = t('statObj_' + k);
  return Object.keys(tr).length ? t('statDone', {o: label, a: f(res.start.raw), b: f(res.best.raw), n: Object.keys(tr).length, p: Math.round(def.pdt || 0), m: Math.round(def.mdt || 0)})
    : t('statSame', {o: label, v: f(res.best.raw)});
}
