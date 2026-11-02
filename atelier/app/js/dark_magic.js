// GearSwap Atelier · dark_magic.js: a set for dark magic (Drain, Aspir, the Absorbs, Stun, Bio, Dread Spikes, Endark,
// the job's Dark Magic set), judged on what the spell does. BG Wiki read 2026-11-02 (Dark_Magic, Drain, Aspir,
// Aspir_III, Absorb-*, Stun, Bio to Bio_III, Dread_Spikes, Endark, Endark_II); the figures in atelier/opt_enf.js
// O.darkFigures:
//   Dark Magic skill decides the accuracy of every dark spell and the potency of some (Drain, Aspir, Bio, Endark),
//   never the Absorbs' potency
//   Drain    skill + 20 to 300 of skill, skill x 5/8 + 132.5 past it; Drain II / III: no formula on BG, Drain's taken
//   Aspir    (skill / 3 + 20) to 300, skill x 0.4 past it, Aspir III skill x 0.8; x (1 + potency); Pixie Hairpin +1's
//            dark magic attack x 1.28 on Aspir III (taken on every tier); MAB and INT nothing
//   Absorb   the pieces' potency ("Absorb" effect, absorb potency), its 90 s by the duration pieces; Absorb-TP the
//            pieces' "TP absorbed" (Heathen's Gauntlets +3: +30 %)
//   Stun     no potency: landing only
//   Bio      HP a tick by skill up to the tier's cap (Bio III 17, Bio II 8, Bio I 3)
//   Dread Spikes  the HP at the cast x 50 % x (1 + the pieces' potency), + 10 % with a DRK's 1200 job points
//   Endark   by skill (Endark II from a DRK's 100 job points) + the weapon's flat bonus (Malfeasance +1: +21)
// Magic accuracy as for the other spells (opt_enf.js): skill + Magic Accuracy + the weapon's Magic Accuracy skill +
// the INT part against the target (INT: ours, BG's dark magic pages do not name the stat)

Object.assign(T.fr, {statGrp_dark: 'Magie noire',
  statObj_darkSkill: 'Skill de magie noire', statD_darkSkill: 'ton skill sans équipement + le skill des pièces (« All magic skills » compris)',
  statObj_darkAcc: 'Précision magique', statD_darkAcc: 'skill de magie noire + précision magique + skill de précision magique de l’arme + écart d’INT avec la cible (l’INT est notre choix : BG ne la nomme pas)',
  statObj_drainPot: 'HP drainés (max)', statD_drainPot: 'skill + 20 jusqu’à 300 de skill, puis skill × 5/8 + 132,5 ; × (1 + puissance « Drain » et « Aspir » des pièces). Le jet tombe entre la moitié et ce max (BG Wiki Drain)',
  statObj_aspirPot: 'MP aspirés (max)', statD_aspirPot: 'skill / 3 + 20 jusqu’à 300, puis skill × 0,4 (Aspir III : × 0,8) ; × (1 + puissance) × l’attaque magique de ténèbres (Pixie Hairpin +1 : × 1,28). Ni MAB ni INT (BG Wiki Aspir III)',
  statObj_absorbPot: 'Puissance Absorb', statD_absorbPot: 'l’effet « Absorb » des pièces (Erra Pendant, Mekosuchus Blade…) ; le skill ne change pas la puissance des Absorb (BG Wiki Dark Magic)',
  statObj_darkTime: 'Durée Absorb', statD_darkTime: '90 s × (1 + durée Absorb + durée de magie noire des pièces) ; les % sont additionnés (supposé, BG ne le dit pas)',
  statObj_absorbTp: 'TP absorbés', statD_absorbTp: 'le % des pièces « Absorb-TP » (Heathen’s Gauntlets +3 : +30 %, BG Wiki Absorb-TP)',
  statObj_bioDot: 'HP par tick (Bio)', statD_bioDot: 'par le skill jusqu’au plafond du tier : Bio III floor((skill + 59) / 27), 17 au plus ; Bio II 5 à 8 de 200 à 291 de skill ; Bio I 3 (BG Wiki)',
  statObj_dreadSpikes: 'HP absorbables (Dread Spikes)', statD_dreadSpikes: 'HP au lancement × 50 % × (1 + puissance des pièces : Heathen’s Cuirass, Crepuscular Scythe) + 10 % des HP avec 1200 points de job de DRK (BG Wiki Dread Spikes)',
  statObj_endark: 'Endark (dégâts par coup)', statD_endark: 'par le skill (Endark II avec 100 points de job de DRK) + le bonus de l’arme (Malfeasance +1 : +21) ; donne autant d’attaque (BG Wiki Endark)',
  darkNote: 'Calculé pour {sp} avec {k} de skill de magie noire sans équipement et {i} d’INT{t}.',
  darkNoteTarget: ', contre {tg} (INT {ti})',
  darkNoteDread: 'Calculé avec les HP du set ({h}) : Dread Spikes ne lit ni le skill ni l’INT.{j}', darkNoteDreadJp: ' Les +10 % des 1200 points de job de DRK sont comptés.',
  darkNoteDrain: 'Drain II et III : BG ne donne pas leur formule, celle de Drain sert de repère (elle classe les sets pareil).',
  darkNoteAspir: 'Aspir II : pas de formule sur BG, celle d’Aspir sert de repère.',
  darkNoteNether: 'Nether Void (+50 % et plus avec la Heathen’s Flanchard) n’est pas compté : c’est une capacité, son set à lui.'});
Object.assign(T.en, {statGrp_dark: 'Dark magic',
  statObj_darkSkill: 'Dark magic skill', statD_darkSkill: 'your skill without gear + the pieces’ skill (“All magic skills” in)',
  statObj_darkAcc: 'Magic accuracy', statD_darkAcc: 'dark magic skill + magic accuracy + the weapon’s magic accuracy skill + INT against the target (INT is ours: BG does not name the stat)',
  statObj_drainPot: 'HP drained (max)', statD_drainPot: 'skill + 20 to 300 of skill, then skill × 5/8 + 132.5; × (1 + the pieces’ “Drain” and “Aspir” potency). The roll lands between half and this max (BG Wiki Drain)',
  statObj_aspirPot: 'MP drained (max)', statD_aspirPot: 'skill / 3 + 20 to 300, then skill × 0.4 (Aspir III: × 0.8); × (1 + potency) × the dark magic attack (Pixie Hairpin +1: × 1.28). No MAB, no INT (BG Wiki Aspir III)',
  statObj_absorbPot: 'Absorb potency', statD_absorbPot: 'the pieces’ “Absorb” effect (Erra Pendant, Mekosuchus Blade…); skill does not change the Absorbs’ potency (BG Wiki Dark Magic)',
  statObj_darkTime: 'Absorb length', statD_darkTime: '90 s × (1 + the pieces’ Absorb duration + dark magic duration); the % added (assumed, BG does not say)',
  statObj_absorbTp: 'TP absorbed', statD_absorbTp: 'the pieces’ “Absorb-TP” % (Heathen’s Gauntlets +3: +30 %, BG Wiki Absorb-TP)',
  statObj_bioDot: 'HP per tick (Bio)', statD_bioDot: 'by skill up to the tier’s cap: Bio III floor((skill + 59) / 27), 17 at most; Bio II 5 to 8 from 200 to 291 of skill; Bio I 3 (BG Wiki)',
  statObj_dreadSpikes: 'HP to absorb (Dread Spikes)', statD_dreadSpikes: 'HP at the cast × 50 % × (1 + the pieces’ potency: Heathen’s Cuirass, Crepuscular Scythe) + 10 % of the HP with a DRK’s 1200 job points (BG Wiki Dread Spikes)',
  statObj_endark: 'Endark (damage a hit)', statD_endark: 'by skill (Endark II with a DRK’s 100 job points) + the weapon’s bonus (Malfeasance +1: +21); gives as much attack (BG Wiki Endark)',
  darkNote: 'Worked out for {sp} with {k} dark magic skill without gear and {i} INT{t}.',
  darkNoteTarget: ', against {tg} (INT {ti})',
  darkNoteDread: 'Worked out with the set’s HP ({h}): Dread Spikes reads neither skill nor INT.{j}', darkNoteDreadJp: ' The +10 % of a DRK’s 1200 job points counted.',
  darkNoteDrain: 'Drain II and III: BG gives no formula, Drain’s stands in (it ranks the sets the same).',
  darkNoteAspir: 'Aspir II: no formula on BG, Aspir’s stands in.',
  darkNoteNether: 'Nether Void (+50 %, more with the Heathen’s Flanchard) is not counted: it is an ability, with a set of its own.'});

// The kinds, by the words of the set's name after sets.midcast (the first that fits): Absorb-TP before the Absorbs,
// Aspir before Drain, the job's Dark Magic set last. Not the nukes of dark magic (Kaustra, Death, the dark Helix: the
// damage optimizer's or none), nor the sets of another skill or a pet's
const DARK_KINDS = [[/absorb-tp/i, 'absorbtp'], [/absorb/i, 'absorb'], [/aspir/i, 'aspir'], [/drain/i, 'drain'], [/\bstun\b/i, 'stun'],
  [/\bbio\b/i, 'bio'], [/dread ?spikes/i, 'dread'], [/endark/i, 'endark'], [/^dark( magic)?\b/i, 'dark']];
const DARK_NOT = /helix|kaustra|death|impact|klimaform|\bpet\b|corsair|blue ?magic|ninjutsu|geomancy|elemental/i;
const DARK_OBJS = {drain: ['drainPot', 'darkAcc', 'cmp'], aspir: ['aspirPot', 'darkAcc', 'cmp'], absorb: ['darkAcc', 'absorbPot', 'darkTime'],
  absorbtp: ['absorbTp', 'darkAcc', 'cmp'], stun: ['darkAcc', 'cmp', 'pdtRed'], bio: ['bioDot', 'darkAcc', 'cmp'],
  dread: ['dreadSpikes', 'pdtRed', 'mdtRed'], endark: ['endark', 'pdtRed', 'mdtRed'], dark: ['darkSkill', 'darkAcc', 'cmp']};
const DARK_SPELL = {drain: 'Drain', aspir: 'Aspir', absorb: 'Absorb', absorbtp: 'Absorb-TP', stun: 'Stun', bio: 'Bio', dread: 'Dread Spikes', endark: 'Endark', dark: 'Dark Magic'};
// A dark magic set: {kind, skill, int, tInt, target, aspirIII, bioTier, endarkII, dreadJp} (the character without
// gear, the target's INT, the tiers the job or its subjob casts), or null
function darkContext(s){
  if (!s || family(s.path, s.pieces) !== 'midcast') return null;
  const k = segs(s.path);
  if (k[0] !== 'midcast') return null;
  const words = k.slice(1).join(' ');
  if (DARK_NOT.test(words)) return null;
  const hit = DARK_KINDS.find(([re]) => re.test(words));
  if (!hit) return null;
  const c = measuredChar() || {}, r = charStats(s, {}), key = enemyKey(buffState().enemy), tgt = ENEMIES[key] || [], jp = c.jp_spent || 0;
  const can = n => typeof SPELL_ACCESS !== 'undefined' && !!SPELL_ACCESS[n] && accessSpell(SPELL_ACCESS[n], S.job, (data() || {}).sub || '', jaLevels());
  return {kind: hit[1], skill: c.skills ? skillLevel(c, 'dark magic') : 0, int: r && r.cur ? r.cur.int || 0 : 0, tInt: tgt[6] || 0, target: key,
    aspirIII: can('Aspir III'), bioTier: can('Bio III') ? 3 : can('Bio II') ? 2 : 1,
    // the Endark II gift (BG Wiki: job point gift level 100) and Dread Spikes' +10 % (1200), a DRK's
    endarkII: S.job === 'DRK' && jp >= 100, dreadJp: S.job === 'DRK' && jp >= 1200};
}
const darkObjectives = s => { const d = darkContext(s); return d ? DARK_OBJS[d.kind] : null; };
function darkRelevant(s){
  const d = darkContext(s);
  return d ? [...new Set([...DARK_OBJS[d.kind], 'darkSkill', 'darkAcc', 'cmp', 'fc', 'sird', 'hp', 'pdtRed', 'mdtRed'])] : [];
}
// The context's part for the figures (stat_opt.js statContext)
function darkBase(s){
  const d = darkContext(s);
  return d ? {darkKind: d.kind, darkSkill: d.skill, int: d.int, tInt: d.tInt, aspirIII: d.aspirIII, bioTier: d.bioTier,
    endarkII: d.endarkII, dreadJp: d.dreadJp, darkDur: d.kind === 'absorb' ? 90 : 0} : null;
}
// A piece's part (stat_opt.js statVec; its Magic Accuracy, Magic Accuracy skill and INT are enfeeble.js enfVec's):
// dark magic skill ("All magic skills" in), Drain / Aspir potency, the Absorbs' potency ("Absorb" effect: Erra
// Pendant) and duration (the "Absorb" effect duration of a cape, the Burgeonet +4's "Absorb" duration), the dark magic
// duration (Ratri Sollerets), Absorb-TP, Dread Spikes (the Cuirass' potency and the Scythe's absorption, added: BG
// "stacks"), Endark, the dark magic attack (Pixie Hairpin +1, Archon Ring)
function darkVec(r, all){
  const out = {}, v = k => r.stats[k] ? r.stats[k].v || 0 : 0;
  const put = (key, n) => { if (n) out[key] = n; };
  put('darkskill', v('skill:dark magic skill') + all);
  put('drainpot', v('x:drain and aspir potency'));
  put('absorbpot', v('x:absorb potency') + v('x:absorb effect'));
  put('absorbdur', v('x:absorb effect duration') + v('x:absorb duration'));
  put('darkdur', v('x:dark magic duration'));
  put('abstp', v('x:absorb-tp effect'));
  put('dreadpot', v('x:dread spikes potency') + v('x:dread spikes absorption'));
  put('endark', v('x:endark'));
  put('darkmab', v('x:dark elemental magic atk.bonus'));
  return out;
}
// The line under the objectives (atelier/src/screens/optimizer/statpage.ts)
function darkNote(s){
  const d = darkContext(s);
  if (!d) return '';
  if (d.kind === 'dread') return t('darkNoteDread', {h: statFigures(s).hp, j: d.dreadJp ? t('darkNoteDreadJp') : ''});
  const sp = d.kind === 'aspir' && d.aspirIII ? 'Aspir III' : d.kind === 'bio' ? ['Bio', 'Bio II', 'Bio III'][d.bioTier - 1]
    : d.kind === 'endark' && d.endarkII ? 'Endark II' : DARK_SPELL[d.kind];
  const more = d.kind === 'drain' ? ' ' + t('darkNoteDrain') + ' ' + t('darkNoteNether') : d.kind === 'aspir' && !d.aspirIII ? ' ' + t('darkNoteAspir')
    : d.kind === 'absorb' ? ' ' + t('darkNoteNether') : '';
  return t('darkNote', {sp, k: d.skill, i: d.int, t: d.target ? t('darkNoteTarget', {tg: d.target, ti: d.tInt}) : ''}) + more;
}
