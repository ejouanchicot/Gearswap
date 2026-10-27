// GearSwap Atelier · bst_pet.js: a BST's jug pet in its engaged sets (2026-10-26, SPEC notes/docs-perso/bst-pet-engaged-2026-10-26).
// The three sets the BST wears in a fight (shared/jobs/bst/functions/logic/set_builder.lua engaged_for_situation):
//   - sets.pet.engaged (the pet fights alone): the stats optimizer on the pieces' "Pet:" stats, the same for every pet
//     (in a fight a pet only makes plain hits, physical for all; physical / magic only counts for the Ready moves,
//     ready_move_categorizer.lua): Pet Accuracy up to what hits the page's target, then Pet Attack, then Pet Haste
//     (25 % cap from gear); the .PDT version Pet damage taken first (-87.5 % cap);
//   - sets.pet.engagedBoth (both fight): the master's engaged optimizer as it is, then Pet damage taken, then the pet's
//     levels, where the master's figure loses 0.1 % at most (the player's rules, 2026-10-26: "the master, and with
//     what is left, pet DT", then the level pieces too);
//     the pass is opt.js petDtPass.
// Figures from players' guides, none measured here (HYP):
//   - Accuracy first, then Attack (FFXIAH The Beastmaster Compendium, ffxiah.com/node/227); the Attack factor of each
//     pet multiplies every piece's Attack alike, so it never changes which one wins: not counted;
//   - the pet's Accuracy without gear: one value for all, 1050 at level 119 (Suspicious Alice 1075, FFXIAH topic 45830
//     p. 171; Daring Roland 1007, Warlike Patrick 974, forum.square-enix.com/ffxi/threads/59983), changed in the page;
//   - Accuracy that hits: the player's formula (75 % + (Acc - Eva) / 2, 95 % at most): the target's Evasion + 40;
//   - a level over 119 ("Summoned Pet: Lv.+N", Spalirisos' "Lv. +N"): +37 Accuracy and +30 Attack (Welf's /checkparam,
//     Square Enix forum 2022-09-23; Suspicious Alice 119 to 124, FFXIAH p. 171), counted while worn (FFXIAH p. 170-171);
//     a Nukumi Earring in the right ear only, the best weapon only (wiki.ffo.jp 19758).
// (loaded by atelier/index.html after luopan.js: atelier/src/legacy/files.ts)

Object.assign(T.fr, {
  statGrp_pet: 'Pet (BST)',
  statObj_petAcc: 'Précision du pet', statD_petAcc: 'sans gear 1050 au niveau 119 (réglable) + les pièces + 37 par niveau en plus ; compte jusqu’à l’Évasion de la cible + 40 (95 % de coups, formule du joueur : non mesuré pour un pet)',
  statObj_petAtk: 'Attaque du pet', statD_petAtk: 'les pièces + 30 par niveau en plus (relevés de joueurs) ; l’ajustement d’Attaque du pet ne change pas laquelle gagne',
  statObj_petHaste: 'Hâte du pet', statD_petHaste: 'celle des pièces, 25 % au plus (guide FFXIAH)',
  statObj_petStp: 'Store TP du pet', statD_petStp: 'celui des pièces',
  statObj_petDa: 'Double Attack du pet', statD_petDa: 'celle des pièces (effet minime d’après le guide FFXIAH)',
  statObj_petDt: 'PDT du pet', statD_petDt: 'dégâts physiques reçus par le pet : Stout Servant (trait, -9 % en BST 99) + "Stout Servant"+N des pièces + Pet: DT et PDT des pièces, -87,5 % au plus (BG Wiki)',
  statObj_petRegen: 'Regen du pet', statD_petRegen: 'le Pet: Regen des pièces, HP par tick',
  statObj_petMab: 'MAB du pet', statD_petMab: 'Pet: Magic Atk. Bonus des pièces ; Fireball 2608 → 4690 avec +107 (mesuré, blog JP 2022)',
  statObj_petMacc: 'M.Acc du pet', statD_petMacc: 'Pet: Magic Accuracy des pièces + 1 par niveau du pet en plus ; ~535 au total pour toucher certains mobs (observé, blog JP 2025)',
  statObj_petInt: 'INT du pet', statD_petInt: 'Pet: INT des pièces (effet sur les moves magiques non tranché)',
  statObj_petMelee: 'Melee DMG du pet', statD_petMelee: 'Pet: Melee DMG des pièces : compte pour les moves physiques (tests de Beanen, chiffres non publiés)',
  statObj_petTpb: 'Ready TP Bonus', statD_petTpb: '"Ready" TP Bonus des pièces + Pet: TP Bonus ; compté au départ du move (wiki JP)',
  statObj_petMdt: 'MDT du pet', statD_petMdt: 'dégâts magiques reçus par le pet : Stout Servant + "Stout Servant"+N + Pet: DT et MDT des pièces, -87,5 % au plus',
  petPdtLine: 'PDT du pet', petMdtLine: 'MDT du pet', petTrait: 'Stout Servant (trait)',
  statPetBase: 'Préc. du pet sans gear (niv. 119) =',
  // a piece's pet stats in its tip, and the set sheet's tab of them (any job with a pet: tips.svelte.ts, sheet.ts)
  tipPet: 'Pet', petTab: 'Pet',
});
Object.assign(T.en, {
  statGrp_pet: 'Pet (BST)',
  statObj_petAcc: 'Pet accuracy', statD_petAcc: '1050 without gear at level 119 (can be changed) + the pieces + 37 a level over it; counts up to the target’s Evasion + 40 (95 % of hits, the player’s formula: not measured for a pet)',
  statObj_petAtk: 'Pet attack', statD_petAtk: 'the pieces + 30 a level over 119 (players’ readings); the pet’s own Attack factor does not change which one wins',
  statObj_petHaste: 'Pet haste', statD_petHaste: 'the pieces’, 25 % at most (FFXIAH guide)',
  statObj_petStp: 'Pet Store TP', statD_petStp: 'the pieces’',
  statObj_petDa: 'Pet Double Attack', statD_petDa: 'the pieces’ (a minor effect, says the FFXIAH guide)',
  statObj_petDt: 'Pet PDT', statD_petDt: 'physical damage the pet takes: Stout Servant (trait, -9 % on a level 99 BST) + the pieces’ "Stout Servant"+N + their Pet: DT and PDT, -87.5 % at most (BG Wiki)',
  statObj_petRegen: 'Pet Regen', statD_petRegen: 'the pieces’ Pet: Regen, HP a tick',
  statObj_petMab: 'Pet MAB', statD_petMab: 'the pieces’ Pet: Magic Atk. Bonus ; Fireball 2608 → 4690 with +107 (measured, JP blog 2022)',
  statObj_petMacc: 'Pet M.Acc', statD_petMacc: 'the pieces’ Pet: Magic Accuracy + 1 a pet level over 119 ; ~535 in all to land on some mobs (observed, JP blog 2025)',
  statObj_petInt: 'Pet INT', statD_petInt: 'the pieces’ Pet: INT (its weight on magic moves is not settled)',
  statObj_petMelee: 'Pet Melee DMG', statD_petMelee: 'the pieces’ Pet: Melee DMG : counts for physical moves (Beanen’s tests, figures not published)',
  statObj_petTpb: 'Ready TP Bonus', statD_petTpb: 'the pieces’ "Ready" TP Bonus + Pet: TP Bonus ; counted when the move goes off (JP wiki)',
  statObj_petMdt: 'Pet MDT', statD_petMdt: 'magic damage the pet takes: Stout Servant + "Stout Servant"+N + the pieces’ Pet: DT and MDT, -87.5 % at most',
  petPdtLine: 'Pet PDT', petMdtLine: 'Pet MDT', petTrait: 'Stout Servant (trait)',
  statPetBase: 'Pet acc. without gear (lv. 119) =',
  tipPet: 'Pet', petTab: 'Pet',
});

const PET_ENG = {accBase: 1050, lvAcc: 37, lvAtk: 30, hit: 40, bothTol: 0.001};
const PET_OBJS = ['petAcc', 'petAtk', 'petHaste', 'petStp', 'petDa', 'petDt', 'petMdt', 'petRegen', 'petMab', 'petMacc', 'petInt', 'petMelee', 'petTpb'];
// Stout Servant, a job trait: the pet's damage taken, in 256ths (BG Wiki Stout_Servant: I -12, II -16, III -23), by
// the level each job gets it at; its gear ("Stout Servant"+N: Nukumi Quijotes +3 +8) adds N % to it
const STOUT_SERVANT = {BST: [[98, 23], [88, 16], [78, 12]], PUP: [[98, 23], [88, 16], [78, 12]], SMN: [[95, 16], [85, 12]]};

// The set worn while the pet fights alone (and its versions: .PDT, the party ones), not the one where both fight
const isPetEngaged = s => S.job === 'BST' && !!s && /^sets\.pet\.engaged(\.|$)/.test(s.path);
// The sets worn with the pet out and resting (set_builder.lua idle_with_pet : sets.pet.idle, .PDT under PetIdleMode
// PetPDT) : the pet is the one protected
const isPetIdle = s => S.job === 'BST' && !!s && /^sets\.pet\.idle(\.|$)/.test(s.path);
// The Ready move sets (shared/jobs/bst/functions/logic/ready_move_categorizer.lua : which set a move uses), worn at
// the move's impact (JP blogs 2022 / 2023 : the gear at the hit counts) : 'phys', 'multi', 'matk', 'macc' or null
const READY_SETS = {pet_physical_moves: 'phys', pet_physicalMulti_moves: 'multi', pet_magicAtk_moves: 'matk', pet_magicAcc_moves: 'macc'};
function readyKind(s){
  if (S.job !== 'BST' || !s) return null;
  const m = s.path.match(/^sets\.midcast\.(pet_\w+_moves)$/);
  return m ? READY_SETS[m[1]] || null : null;
}
// a set the pet's stats optimizer takes
const isPetSet = s => isPetEngaged(s) || isPetIdle(s) || !!readyKind(s);
// The set worn while both fight (sets.pet.engagedBoth and its versions)
const isPetBoth = s => S.job === 'BST' && !!s && /^sets\.pet\.engagedBoth(\.|$)/.test(s.path);

// The objectives of a pet set, null for any other
// (a .PDT set and the idle ones : the pet's PDT, then its Regen -- the player's order, 2026-10-27)
// The Ready move sets (FFXIAH Beastmaster Compendium, the JP wiki しじをさせろ / bstpet, 2026-10-27) : a physical move
// lands then hits by Attack (and its TP) ; a multi-hit one by Double Attack before Attack, as the FFXIAH guide's
// multi-hit set (the player's choice, 2026-10-27 : with Attack first, 20 Attack outranked a Bst. Collar +2's Pet DA
// +25 %) ; a magic one by MAB first (measured x1.8) ; a debuff by M.Acc
const READY_OBJS = {phys: ['petAcc', 'petAtk', 'petTpb'], multi: ['petAcc', 'petDa', 'petAtk'], matk: ['petMab', 'petMacc', 'petTpb'], macc: ['petMacc', 'petTpb', 'petInt']};
function petObjectives(s){
  if (readyKind(s)) return READY_OBJS[readyKind(s)];
  if (isPetIdle(s)) return ['petDt', 'petRegen', 'pdtRed'];
  if (!isPetEngaged(s)) return null;
  return /\.PDT\b/.test(s.path) ? ['petDt', 'petRegen', 'petAcc'] : ['petAcc', 'petAtk', 'petHaste'];
}
const petRelevant = s => isPetSet(s) ? PET_OBJS : [];

// The levels a piece gives the pet: "Summoned Pet: Lv.+N" (Nukumi Earring, Gleti's Boots) or, under its "Pet:" lines,
// "Lv. +N" (Spalirisos); a piece whose bonus is the right ear's (Nukumi Earring) gives it in that ear only
function petLevelOf(r, slot){
  const text = r.text || '', side = EAR_SIDE[slot];
  const ear = text.match(/^(Left|Right) ear:/m);
  if (ear && ear[1].toLowerCase() !== side) return 0;
  const m = text.match(/Summoned Pet:\s*Lv\.\s*\+\s*(\d+)/);
  if (m) return +m[1];
  return ((r.pet || {})['x:lv.'] || {}).v || 0;
}
// The trait's cut, a positive % (the main job's level read in game, else 99)
function petTrait(){
  const lv = (measuredChar() || {}).main_level || 99, step = (STOUT_SERVANT[S.job] || []).find(([at]) => lv >= at);
  return step ? Math.round(step[1] / 256 * 1000) / 10 : 0;
}
// "Stout Servant"+N of a piece (a stat of the wearer's lines, not a "Pet:" one)
const stoutOf = r => (((r.stats || {})['x:stout servant'] || {}).v) || 0;
// The physical damage a piece takes off the pet, as a positive %: its Pet: DT and PDT, its "Stout Servant"+N
const petPdtOfStats = r => stoutOf(r) - ((((r.pet || {}).dt || {}).v || 0) + (((r.pet || {}).pdt || {}).v || 0));
// A piece's pet stats for the stats optimizer (r: its pieceStats); a weapon's levels apart (only the best one counts)
function petVec(r, slot){
  const pet = k => ((r.pet || {})[k] || {}).v || 0, out = {}, lv = petLevelOf(r, slot);
  for (const [k, key] of [['acc', 'petacc'], ['atk', 'petatk'], ['haste', 'pethaste'], ['stp', 'petstp'], ['da', 'petda'], ['regen', 'petregen'],
    ['mab', 'petmab'], ['macc', 'petmacc'], ['int', 'petint'], ['x:melee dmg', 'petmelee'], ['tpb', 'pettpb']]) if (pet(k)) out[key] = pet(k);
  // "Ready" TP Bonus +700 (Nukumi Manoplas) is written on the wearer's lines, not a "Pet:" one
  const rtp = (((r.stats || {})['x:ready tp bonus'] || {}).v) || 0;
  if (rtp) out.pettpb = (out.pettpb || 0) + rtp;
  for (const [k, key] of [['dt', 'petdt'], ['pdt', 'petpdt'], ['mdt', 'petmdt']]) if (pet(k)) out[key] = pet(k);
  if (stoutOf(r)) out.petstout = stoutOf(r);
  if (lv) out[slot === 'main' || slot === 'sub' ? 'petlvw' : 'petlv'] = lv;
  return out;
}
// The pet's physical damage taken a piece cuts, as a positive % (the engaged search's pass, opt.js petDtPass)
function petDtOf(p, slot){
  const r = p && !isEmpty(p) ? pieceStats(p, slot) : null;
  return r ? petPdtOfStats(r) : 0;
}
// The levels a piece gives the pet (the engaged search's pass, opt.js petDtPass)
function petLvOf(p, slot){
  const r = p && !isEmpty(p) ? pieceStats(p, slot) : null;
  return r ? petLevelOf(r, slot) : 0;
}
// The pet's two damage taken lines of a set (the sheet's Pet tab): pet, the pet's stats added up; stats, the wearer's
// (their "Stout Servant"+N); the trait in. Negative %, -87.5 at most, and what makes each one
function petDefense(pet, stats){
  const v = k => ((pet || {})[k] || {}).v || 0, trait = petTrait(), stout = (((stats || {})['x:stout servant'] || {}).v) || 0;
  const sum = k => -Math.round((trait + stout - v('dt') - v(k)) * 10) / 10;
  const how = k => `${t('petTrait')} -${trait} + Stout Servant -${stout} + DT ${v('dt')} + ${k.toUpperCase()} ${v(k)}`;
  return {pdt: sum('pdt'), mdt: sum('mdt'), pDetail: how('pdt'), mDetail: how('mdt'), on: !!(trait || stout || v('dt') || v('pdt') || v('mdt'))};
}
// The target's Evasion once its Evasion Down is counted (buffs.js foeEva)
function petTargetEva(){
  const b = buffState();
  return Math.max(0, ((TARGETS[enemyKey(b.enemy)] || {}).eva || 0) - foeEva(b));
}
// The context's part for the figures (stat_opt.js statContext): the pet's Accuracy without gear, what hits, a level's worth
// (the trait for every set of a pet job: its damage taken figures)
function petBase(s){
  const trait = petTrait();
  // a Ready set : a level's worth too ; a physical one also the Accuracy that hits (as the engaged sets)
  const rk = readyKind(s);
  if (rk && rk !== 'phys' && rk !== 'multi') return {petTrait: trait, lvAcc: PET_ENG.lvAcc, lvAtk: PET_ENG.lvAtk, lvMacc: 1};
  if (!isPetEngaged(s) && !rk) return trait ? {petTrait: trait} : null;
  const fl = statOpts(s).floor;
  return {petTrait: trait, petAccBase: +fl.petAccBase || PET_ENG.accBase, petNeed: petTargetEva() + PET_ENG.hit, lvAcc: PET_ENG.lvAcc, lvAtk: PET_ENG.lvAtk, lvMacc: 1};
}
