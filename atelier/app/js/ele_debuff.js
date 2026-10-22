// GearSwap Atelier · ele_debuff.js: a set for the elemental debuffs (Burn, Frost, Choke, Rasp, Shock, Drown), judged
// on what they do. They deal no direct damage: they lower a stat of the target and take HP every 3 s, both from the
// caster's INT by steps, the Black Mage's merits and the "Elemental magic status ailment effects" gear; magic attack
// and magic damage do nothing for them (BG Wiki Category:Elemental_Debuff, read 2026-10-22; the figures in
// atelier/opt_enf.js O.eleDebuffFigures). A Magic Burst gives them magic accuracy only, not potency (BG Wiki
// Magic_Burst): one set serves both.

Object.assign(T.fr, {statGrp_eled: 'Burn, Frost, Choke, Rasp, Shock, Drown',
  statObj_edDown: 'Baisse de la stat', statD_edDown: 'palier d’INT (−5 à −13 au-dessus de 150) + 2 par mérite d’effet + « Elemental magic status ailment effects » des pièces (Arch. Sabots +3 : +30) + 2 par mérite avec un Tonban (BG Wiki)',
  statObj_edDot: 'HP par tick', statD_edDot: 'toutes les 3 s : palier d’INT (1 à 5) + 1 par mérite d’effet + la moitié de l’effet des pièces + 1 par mérite avec un Tonban (BG Wiki)',
  statObj_edTime: 'Durée du debuff', statD_edTime: '90 s + 12 s par mérite de durée + 6 s par mérite avec un Archmage’s ou Sorcerer’s Tonban (180 s au plus, BG Wiki)',
  statObj_edAcc: 'Précision magique', statD_edAcc: 'skill de magie élémentaire + précision magique + skill de précision magique de l’arme + écart d’INT avec la cible (le Magic Burst ajoute de la précision, pas de puissance)',
  edNote: 'Calculé pour Burn et ses cousins avec {i} d’INT sans équipement, {e}/5 mérites d’effet et {d}/5 de durée{t}. L’attaque magique ne compte pas pour ces sorts.',
  edNoteTarget: ', contre {tg} (INT {ti})',
  edGear: 'Ce que tes pièces apportent ici : « status ailment effects » {e} (−{e} à la stat, +{h} HP par tick){t}.',
  edTonban: ' ; Archmage’s Tonban (relic) : −{s} à la stat, +{h} HP par tick, +{d} s', edNoTonban: ' ; pas d’Archmage’s Tonban (relic) : il ajouterait −{s}, +{h} HP par tick et +{d} s avec tes mérites'});
Object.assign(T.en, {statGrp_eled: 'Burn, Frost, Choke, Rasp, Shock, Drown',
  statObj_edDown: 'Stat lowered', statD_edDown: 'INT step (−5 to −13 over 150) + 2 per effect merit + the pieces’ “Elemental magic status ailment effects” (Arch. Sabots +3: +30) + 2 per merit with a Tonban (BG Wiki)',
  statObj_edDot: 'HP per tick', statD_edDot: 'every 3 s: INT step (1 to 5) + 1 per effect merit + half the pieces’ effect + 1 per merit with a Tonban (BG Wiki)',
  statObj_edTime: 'Debuff length', statD_edTime: '90 s + 12 s per duration merit + 6 s per merit with an Archmage’s or Sorcerer’s Tonban (180 s at most, BG Wiki)',
  statObj_edAcc: 'Magic accuracy', statD_edAcc: 'elemental magic skill + magic accuracy + the weapon’s magic accuracy skill + INT against the target (a Magic Burst adds accuracy, not potency)',
  edNote: 'Worked out for Burn and its kin with {i} INT without gear, {e}/5 effect merits and {d}/5 duration merits{t}. Magic attack does not count for these spells.',
  edNoteTarget: ', against {tg} (INT {ti})',
  edGear: 'What your pieces bring here: “status ailment effects” {e} (−{e} to the stat, +{h} HP per tick){t}.',
  edTonban: '; Archmage’s Tonban (relic): −{s} to the stat, +{h} HP per tick, +{d} s', edNoTonban: '; no Archmage’s Tonban (relic): it would add −{s}, +{h} HP per tick and +{d} s with your merits'});

// The spells, and Mote's map of them (sets.midcast.ElementalEnfeeble)
const ED_NAMES = /\b(Burn|Frost|Choke|Rasp|Shock|Drown|ElementalEnfeeble)\b/;
const ED_OBJS = ['edDown', 'edTime', 'edAcc'];
// A set worn for them: {int, effM, durM, skill, tInt, target} (the character without gear, its Black Mage merits, the
// target's INT), or null. The merits are a Black Mage's: the export lists every job's merits, another job counts none
function edContext(s){
  if (!s || family(s.path, s.pieces) !== 'midcast' || !ED_NAMES.test(setNames(s)) || /precast/.test(s.path)) return null;
  const c = measuredChar() || {}, r = charStats(s, {}), blm = S.job === 'BLM', m = c.merits || {};
  const key = enemyKey(buffState().enemy), tgt = ENEMIES[key] || [];
  return {int: r && r.cur ? r.cur.int || 0 : 0, effM: blm ? Math.min(5, m.elemental_magic_debuff_effect || 0) : 0,
    durM: blm ? Math.min(5, m.elemental_magic_debuff_duration || 0) : 0, skill: c.skills ? skillLevel(c, 'elemental magic') : 0,
    tInt: tgt[6] || 0, target: key};
}
const edObjectives = s => edContext(s) ? ED_OBJS : null;
const edRelevant = () => ['edDown', 'edDot', 'edTime', 'edAcc', 'fc', 'sird', 'hp', 'pdtRed'];
// The context's part for the figures (stat_opt.js statContext)
function edBase(s){
  const e = edContext(s);
  return e ? {edOn: true, int: e.int, edEffM: e.effM, edDurM: e.durM, edSkill: e.skill, tInt: e.tInt} : null;
}
// A piece's part (stat_opt.js statVec): the effect (the game words it two ways: Arch. Sabots +3 "status ailment
// effects", +4 "status down effect"), the elemental magic skill, and the Tonban whose augment follows the merits
// (the relic's: Archmage's to +4, BG Wiki Arch._Tonban_+4 same augment as the +3; and Sorcerer's +2)
function edVec(r, all, name){
  const out = {}, v = k => r.stats[k] ? r.stats[k].v || 0 : 0;
  const eff = v('x:elemental magic status ailment effects') + v('x:elemental magic status down effect');
  if (eff) out.edeff = eff;
  if (v('skill:elemental magic skill') + all) out.edskill = v('skill:elemental magic skill') + all;
  if (/^(Arch\.|Archmage's) Tonban|^(Sorc\.|Sorcerer's) Tonban \+2/.test(name || '')) out.edtonban = 1;
  return out;
}
// The line under the objectives (atelier/src/screens/optimizer/statpage.ts)
function edNote(s){
  const e = edContext(s);
  if (!e) return '';
  const f = statFigures(s), tb = {s: 2 * e.effM, h: e.effM, d: 6 * e.durM};
  return t('edNote', {i: e.int, e: e.effM, d: e.durM, t: e.target ? t('edNoteTarget', {tg: e.target, ti: e.tInt}) : ''})
    + ' ' + t('edGear', {e: f.edEff || 0, h: Math.floor((f.edEff || 0) / 2), t: t(f.edTonban ? 'edTonban' : 'edNoTonban', tb)});
}
