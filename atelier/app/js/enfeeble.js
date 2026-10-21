// GearSwap Atelier · enfeeble.js: a set of enfeebling magic judged on the spells GearSwap casts in it. Their figures
// (length, potency, magic accuracy) are worked out in atelier/opt_enf.js, its header holding the formulas.
//
// Which set a spell is cast in (shared/utils/midcast/midcast_manager.lua): its own set by name
// (sets.midcast.Dispelga), else sets.midcast['Enfeebling Magic'].<its type>, else sets.midcast['Enfeebling Magic'].
// The types are the spell database's (shared/data/magic/enfeebling/*.lua, enfeebling_type), copied below; each list
// starts with the spell the set is judged on first. EnfeebleMode: Auto (the default) leaves each spell its type's
// set; another mode puts its own set (sets.midcast['Enfeebling Magic'].Potency...) on every enfeeble, a type's set
// for that mode first (.mnd_potency.Skill) (RDM_MIDCAST.lua enfeeble_mode_forced): a mode's set is judged on every
// spell, in the order the mode is about (ENF_MODES).

Object.assign(T.fr, {
  statGrp_enf: 'Magie d’affaiblissement',
  statObj_enfPot: 'Puissance', statD_enfPot: 'du premier sort du set qui en a une : MND / INT contre la cible, skill, × « Enfeebling magic effect », Saboteur ; Paralyze II plafonné à 50 % (mesures japonaises et en jeu)',
  statObj_enfTime: 'Durée de l’affaiblissement', statD_enfTime: '(base × Saboteur + job points + mérites) × Composure (set Lethargy) × % écrits × % en augment (mesuré en jeu)',
  statObj_enfAcc: 'Précision magique', statD_enfAcc: 'skill d’affaiblissement + précision magique + skill de précision magique de l’arme + écart MND / INT avec la cible (sans les gifts ni les mérites)',
  statObj_enfEff: 'Enfeebling magic effect', statD_enfEff: 'le total des pièces (Lethargy Sayon, Regal Gem, Duelist’s Torque…)',
  statObj_enfSkill: 'Skill d’affaiblissement', statD_enfSkill: 'le tien + le gear : Distract III, Frazzle III, Poison II en dépendent',
  enfCapped: '(plafond)', enfNoSab: 'sans Saboteur', enfComp: 'Composure compté (set Lethargy)', enfNoComp: 'sans Composure',
  enfKindType: 'Set {k} : GearSwap le porte pour',
  enfKindBase: 'Set de base : GearSwap le porte pour les sorts dont le type n’a pas de set à lui, et ceux sans type :',
  enfKindMode: 'Set du mode {m} (EnfeebleMode) : quand ce mode est choisi (Auto, le défaut, jamais), GearSwap le porte pour tout affaiblissement, à la place du set de son type :',
  enfKindSpell: 'Set au nom du sort : GearSwap le porte pour',
  enfKindMap: 'Set {m} : GearSwap le porte pour les affaiblissements de magie {w} sans set à leur nom, que ton job ou ton sub lance :', enfWhite: 'blanche', enfBlack: 'noire',
  enfSabBox: 'Sous Saboteur (×2 sur un monstre, ×1,25 sur un NM, + les gants)',
  enfNote: 'Calculé pour {s} contre {tg} (MND {m}, INT {i}, la cible choisie dans la page), {sab}, {c}.'});
Object.assign(T.en, {
  statGrp_enf: 'Enfeebling magic',
  statObj_enfPot: 'Potency', statD_enfPot: 'of the set’s first spell that has one: MND / INT against the target, skill, × “Enfeebling magic effect”, Saboteur; Paralyze II capped at 50 % (Japanese and in-game measures)',
  statObj_enfTime: 'Enfeeble length', statD_enfTime: '(base × Saboteur + job points + merits) × Composure (Lethargy set) × % written × % in augments (measured in game)',
  statObj_enfAcc: 'Magic accuracy', statD_enfAcc: 'enfeebling skill + magic accuracy + the weapon’s magic accuracy skill + MND / INT against the target (gifts and merits left out)',
  statObj_enfEff: 'Enfeebling magic effect', statD_enfEff: 'the pieces’ total (Lethargy Sayon, Regal Gem, Duelist’s Torque…)',
  statObj_enfSkill: 'Enfeebling skill', statD_enfSkill: 'yours + the gear: Distract III, Frazzle III, Poison II depend on it',
  enfCapped: '(capped)', enfNoSab: 'without Saboteur', enfComp: 'Composure counted (Lethargy set)', enfNoComp: 'without Composure',
  enfKindType: '{k} set: GearSwap wears it for',
  enfKindBase: 'Base set: GearSwap wears it for the spells whose type has no set of its own, and those of no type:',
  enfKindMode: '{m} mode set (EnfeebleMode): while that mode is chosen (Auto, the default, never), GearSwap wears it for every enfeeble instead of its type’s set:',
  enfKindSpell: 'Set named for the spell: GearSwap wears it for',
  enfKindMap: '{m} set: GearSwap wears it for the {w} magic enfeebles with no set of their own name that your job or subjob casts:', enfWhite: 'white', enfBlack: 'black',
  enfSabBox: 'Under Saboteur (×2 on a monster, ×1.25 on an NM, + the gloves)',
  enfNote: 'Worked out for {s} against {tg} (MND {m}, INT {i}, the target chosen in the page), {sab}, {c}.'});

const ENF_TYPES = {
  mnd_potency: ['Slow II', 'Paralyze II', 'Addle II'],
  int_potency: ['Blind II'],
  potency: ['Gravity II', 'Dia III', 'Dia II', 'Dia', 'Diaga'],
  skill_potency: ['Poison II'],
  skill_mnd_potency: ['Distract III', 'Frazzle III'],
  macc: ['Paralyze', 'Slow', 'Dispel', 'Dispelga', 'Blind', 'Gravity', 'Distract', 'Distract II', 'Frazzle', 'Frazzle II', 'Addle', 'Poison', 'Poisonga'],
  duration: ['Sleep II', 'Sleep', 'Sleepga', 'Sleepga II', 'Silence', 'Bind', 'Break', 'Breakga']
};
// spells of no type: the job's own set
const ENF_UNTYPED = ['Inundation'];
// What a type's set is after, in order. Potency first where the type is named for it (a capped potency, Paralyze II's
// 50 %, leaves the length to part the sets), magic accuracy first for the others, the length first for the spells
// that have no potency
const ENF_OBJS = {mnd_potency: ['enfPot', 'enfTime', 'enfAcc'], int_potency: ['enfPot', 'enfTime', 'enfAcc'], potency: ['enfPot', 'enfTime', 'enfAcc'],
  skill_potency: ['enfPot', 'enfTime', 'enfAcc'], skill_mnd_potency: ['enfPot', 'enfTime', 'enfAcc'], macc: ['enfAcc', 'enfTime', 'enfPot'],
  duration: ['enfTime', 'enfAcc'], base: ['enfAcc', 'enfTime'], map: ['enfAcc', 'enfTime', 'enfPot']};
const ENF_RE = /^sets\.midcast\[["']Enfeebling Magic["']\](?:\.([\w]+))?$/;

// An Enfeeble Mode's set (RDM_MIDCAST.lua enfeeble_mode_forced): worn for every enfeeble while that mode is chosen
// (Auto, the default, never). Its spells in the order the mode is about, its objectives that order's
const ENF_MODES = {
  Potency: {types: ['mnd_potency', 'int_potency', 'potency', 'skill_mnd_potency', 'skill_potency', 'macc', 'duration'], objs: ['enfPot', 'enfTime', 'enfAcc']},
  Skill: {types: ['skill_mnd_potency', 'skill_potency', 'mnd_potency', 'int_potency', 'potency', 'macc', 'duration'], objs: ['enfSkill', 'enfPot', 'enfTime']},
  Duration: {types: ['duration', 'mnd_potency', 'macc', 'int_potency', 'potency', 'skill_mnd_potency', 'skill_potency'], objs: ['enfTime', 'enfAcc', 'enfPot']},
  Acc: {types: ['macc', 'mnd_potency', 'int_potency', 'potency', 'skill_mnd_potency', 'skill_potency', 'duration'], objs: ['enfAcc', 'enfTime', 'enfPot']}};
// A BLM / SCH / WHM's enfeeble sets (shared/jobs/blm/functions/logic/midcast_router.lua): sets.midcast.MndEnfeebles
// for white magic, .IntEnfeebles for black magic (the game's type: SPELL_ENF_TYPE), a spell with a set of its own name
// (Sleep, Break...) keeping it; under them a type's set (.IntEnfeebles.duration), a spell's (.IntEnfeebles.Blind) or
// the accuracy mode's (.Resistant)
const ENF_MAP_RE = /^sets\.midcast\.(Int|Mnd)Enfeebles(?:\.(\w+))?$/;
const ENF_MAP_ACC = 'Resistant';
// The spells the shown job can cast, main job or subjob at its level (enh_jobs.js enhCastable). An export made
// without the game (the page's offline export: no job points read) keeps the job point spells (Distract III)
function enfCastable(spells){
  const c = measuredChar() || {}, sub = (data() || {}).sub, lv = jaLevels(), jp = c.jp_spent == null ? Infinity : c.jp_spent;
  return spells.filter(n => enhCastable(n, S.job, sub, lv, jp));
}
// Every enfeeble the page knows, in the order of the types (the set is judged on its first)
const enfAll = () => Object.values(ENF_TYPES).flat().concat(ENF_UNTYPED);
// The spells with a set of their own name (sets.midcast.Dispelga): never cast in a shared set
const enfNamed = () => new Set(((data() || {}).sets || []).map(x => segs(x.path)).filter(p => p.length === 2 && p[0] === 'midcast').map(p => p[1]));
// A Mnd / IntEnfeebles set: {type: 'map', map, acc, spells} or null (no spell of its magic the job can cast)
function enfMapSet(m, own){
  const magic = m[1] === 'Mnd' ? 'WhiteMagic' : 'BlackMagic', sub = m[2], types = typeof SPELL_ENF_TYPE === 'object' ? SPELL_ENF_TYPE : {};
  const named = enfNamed();
  let spells;
  if (!sub || sub === ENF_MAP_ACC) spells = enfAll().filter(n => !named.has(n));
  else if (ENF_TYPES[sub]) spells = ENF_TYPES[sub];
  else if (own[sub]) spells = [sub];
  else return null;
  spells = enfCastable(spells.filter(n => types[n] === magic));
  return spells.length ? {type: 'map', map: m[1], acc: sub === ENF_MAP_ACC, spells} : null;
}
// The enfeebling spells cast in this set and the kind it is: {type, spells} or null. A shared set keeps only the
// spells the job or its subjob can cast (a BLM's sets.midcast['Enfeebling Magic'] is not judged on Slow II)
function enfSetOf(s){
  if (!s || family(s.path, s.pieces) !== 'midcast') return null;
  const m = s.path.match(ENF_RE), own = (FFXI.opt && FFXI.opt.ENF_SPELLS) || {};
  if (!m) {
    const mm = s.path.match(ENF_MAP_RE);
    if (mm) return enfMapSet(mm, own);
    const parts = segs(s.path);
    return parts.length === 2 && own[parts[1]] ? {type: 'spell', spells: [parts[1]]} : null;
  }
  const sub = m[1];
  if (sub && ENF_TYPES[sub]) return {type: sub, spells: enfCastable(ENF_TYPES[sub])};
  // a mode's set: every enfeeble but those with a set of their own name (Dispelga)
  if (sub && ENF_MODES[sub]) {
    const named = enfNamed();
    return {type: 'mode', mode: sub, spells: enfCastable(ENF_MODES[sub].types.flatMap(k => ENF_TYPES[k]).concat(ENF_UNTYPED).filter(n => !named.has(n)))};
  }
  // Saboteur's set is laid on top of the spell's (hands only): not a set of its own to fill
  if (sub) return null;
  // the job's own set: the spells of every type with no set of its own, and those of no type
  const has = new Set(((data() || {}).sets || []).map(x => x.path.replace(/'/g, '"')));
  const fall = Object.entries(ENF_TYPES).filter(([k]) => !has.has(`sets.midcast["Enfeebling Magic"].${k}`)).flatMap(([, v]) => v);
  return {type: 'base', spells: enfCastable(fall.concat(ENF_UNTYPED))};
}
// The figures the set's spells have: a potency, a length (Dispel has neither, Inundation no potency)
function enfHas(spells){
  const own = FFXI.opt.ENF_SPELLS, list = spells.map(n => own[n]).filter(Boolean);
  return {pot: list.some(x => x.pot || x.dia), time: list.some(x => x.dur)};
}
// An objective the set's spells give nothing for is left out: picked, it read 0 against 0 (2026-10-14)
function enfUseful(e, k){
  const has = enfHas(e.spells);
  return k === 'enfPot' ? has.pot : k === 'enfTime' ? has.time : true;
}
// What the figures need of the character and the target (ctx.stat.base, opt_enf.js): the set's spells, the MND / INT
// and enfeebling skill without gear, the target's MND / INT, Saboteur (a Red Mage's, off unless ticked under the
// objectives: it is cast before some spells only, RDM_SABOTEUR_CONFIG.lua),
// an NM, Composure (a Red Mage's: taken as always up, as for its enhancing sets), the seconds of job points and merits
function enfContext(s){
  if (!window.FFXI || !FFXI.opt || !FFXI.opt.ENF_SPELLS) return null;
  const set = enfSetOf(s);
  if (!set || !set.spells.length) return null;
  const c = measuredChar() || {}, b = buffState(), key = enemyKey(b.enemy), tgt = ENEMIES[key] || [];
  const naked = charStats(s, {}), cur = naked ? naked.cur : {}, rdm = S.job === 'RDM';
  // a Red Mage's job points' Enfeebling Magic Duration, 20 s (measured 20 on Kaories, 2100 spent; taken as bought from
  // 500 as the enhancing one, stat_opt.js enhContext); its merits' 6 s a level (a Red Mage's merit group: the export
  // lists every job's merits, so another job never counts them)
  const sec = rdm ? ((c.jp_spent || 0) >= 500 ? 20 : 0) + 6 * ((c.merits || {}).enfeebling_magic_duration || 0) : 0;
  return {type: set.type, mode: set.mode, map: set.map, acc: set.acc, spells: set.spells, sab: rdm && !!(S.optOpts || {}).enfSab, nm: isNmTarget(key), comp: rdm,
    mnd: cur.mnd || 0, int: cur.int || 0, enfSkill: c.skills ? skillLevel(c, 'enfeebling magic') : 0, enfSec: sec,
    tMnd: tgt[5] || 0, tInt: tgt[6] || 0, target: key};
}
function enfObjectives(s){
  const e = enfContext(s);
  if (!e) return null;
  // a spell's own set (Dispelga): potency first when it has one, else its length, else its magic accuracy
  // a Mnd / IntEnfeebles set: magic accuracy first (it carries every spell of its magic: sleeps, binds and
  // potencies), then the length, then the potency
  const objs = e.type === 'spell' ? ['enfPot', 'enfTime', 'enfAcc'] : e.type === 'mode' ? ENF_MODES[e.mode].objs
    : e.type === 'map' ? ENF_OBJS.map : ENF_OBJS[e.type] || ENF_OBJS.base;
  return objs.filter(k => enfUseful(e, k));
}
function enfRelevant(s){
  const e = enfContext(s);
  return e ? ['enfPot', 'enfTime', 'enfAcc', 'enfEff', 'enfSkill', 'fc', 'sird', 'hp', 'pdtRed'].filter(k => enfUseful(e, k)) : [];
}
// A piece's enfeebling stats (stat_opt.js statVec): skill ("All magic skills" in), Magic Accuracy and the weapons'
// Magic Accuracy skill, INT (MND is read there already), "Enfeebling magic effect", the duration written on the piece
// and in its augments (a Duelist's Torque's rank: "Enf. Mag. eff. dur."), Saboteur's own bonus
function enfVec(r, all, name){
  const out = {}, v = k => r.stats[k] ? r.stats[k].v || 0 : 0, base = k => r.base[k] ? r.base[k].v || 0 : 0, aug = k => r.aug[k] ? r.aug[k].v || 0 : 0;
  if (v('skill:enfeebling magic skill') + all) out.enfskill = v('skill:enfeebling magic skill') + all;
  if (v('macc')) out.macc = v('macc');
  if (v('skill:magic accuracy skill')) out.maccskill = v('skill:magic accuracy skill');
  if (v('int')) out.int = v('int');
  if (v('x:enfeebling magic effect')) out.enfeff = v('x:enfeebling magic effect');
  // A Duelist's Torque's rank: x1.25 of enfeebling length apart from the rest, measured on Kaories' +2 (2026-10-14:
  // 168 s without it, 210 with it). Its reading gives it as "Enf. Mag. eff. dur." when the set writes the augments, as
  // the enhancing duration of the rank table (augments_ranked.js) when it names the piece only: either one counts
  const torque = /^(Dls\.|Duelist's) Torque/.test(name || '') ? Math.max(v('x:enf.mag.eff.dur.'), aug('enhdur')) : v('x:enf.mag.eff.dur.');
  const dl = base('x:enfeebling magic duration'), da = v('x:enfeebling magic duration') - dl + torque;
  if (dl) out.enfdurL = dl;
  if (da) out.enfdurA = da;
  if (v('x:saboteur')) out.sabplus = v('x:saboteur');
  return out;
}
// The context's part for the figures (stat_opt.js statContext)
function enfBase(s){
  const e = enfContext(s);
  return e ? {enfSpells: e.spells, sab: e.sab, nm: e.nm, comp: e.comp, mnd: e.mnd, int: e.int, enfSkill: e.enfSkill, enfSec: e.enfSec, tMnd: e.tMnd, tInt: e.tInt} : null;
}
const ENF_UNIT = {'%': ' %', slow: ' % Slow', macc: ' Préc. mag.−', acc: ' Préc.−', eva: ' Éva.−', meva: ' Éva. mag.−', tick: ' HP/tick'};
const ENF_UNIT_EN = {'%': ' %', slow: ' % Slow', macc: ' M.Acc−', acc: ' Acc−', eva: ' Eva−', meva: ' M.Eva−', tick: ' HP/tick'};
function enfPotText(r){
  if (r.pot == null) return '';
  return r.pot + (S.lang === 'fr' ? ENF_UNIT : ENF_UNIT_EN)[r.unit] + (r.capped ? ' ' + t('enfCapped') : '');
}
// The result's lines for each spell of the set, under the objectives: its potency, its length (stat_opt.js statRows)
function enfRows(s){
  const e = enfContext(s);
  if (!e) return [];
  return e.spells.filter(n => FFXI.opt.ENF_SPELLS[n]).slice(0, 8).map(n => ({id: 'enf:' + n, label: n,
    get: f => (f.enfBy || {})[n] || null,
    fmt: r => r ? [enfPotText(r), r.time ? enhTimeText(r.time) : ''].filter(Boolean).join(' · ') || '—' : '—'}));
}
