// GearSwap Atelier · stat_enh.js: the stats optimizer's enhancing magic and cures: what a set is cast for, on whom,
// and what the spell is worth (the figures: atelier/opt.js O.enhancingFigures). Out of stat_opt.js, which reads it
// (loaded right after it: see atelier/src/legacy/files.ts)

/* ---- enhancing magic: what a set is cast for, on whom, and what the spell is worth (opt_stat.js O.enhancingFigures) ---- */
// Any job's enhancing set: {kind, base, comp, name, ...} or null. The set's spell, its tier and its base seconds are the
// highest the job or its subjob can cast (enh_jobs.js enhSpellOf: "Enhancing Magic", laid under the others, on its
// shortest spell so a long one never hides what a piece adds); the job's bonuses come with it (enhJobBonus).
// A Red Mage's (bases measured in game 2026-10-14, Kaories): Composure taken as always up (2 hours, 5 minutes of
// recast): a set named Composure is the one cast on the others (shared/utils/midcast/midcast_manager.lua
// get_enhancing_target), any other is cast on oneself. The other jobs cast without Composure (comp 'none')
function enhContext(s){
  if (!s || family(s.path, s.pieces) !== 'midcast') return null;
  const p = s.path.replace(/^sets\.midcast/, ''), rdm = S.job === 'RDM', others = rdm && /composure/i.test(p);
  // not a set of another skill that names its own enhancing spells (sets.midcast.Ninjutsu.Enhancing: Utsusemi) or a
  // pet's (sets.midcast.Pet['Enhancing Magic']: an avatar's ward)
  if (/ninjutsu|\bpet\b|blue ?magic|geomancy|singing|song/i.test(p)) return null;
  const sp = enhSpellOf(p.replace(/composure/i, ''), others);
  if (!sp) return null;
  const c = measuredChar() || {}, jp = c.jp_spent || 0, bonus = enhJobBonus(sp.kind, c, sp.via);
  // a spell neither the job nor the shown subjob casts: worked out with the subjob that does (enh_jobs.js enhTierAny)
  if (sp.via) bonus.notes.unshift(t('enhVia', {j: S.job, s: (data() || {}).sub, v: sp.via}));
  // a Red Mage's job points' seconds: Enhancing Magic Duration, 1 s a rank, 20 ranks (210 job points in all; the export
  // has the total spent only, taken as bought from 500 spent: measured 20 on Kaories); the merits' 6 s a level
  const seconds = rdm ? (jp >= 500 ? 20 : 0) + 6 * ((c.merits || {}).enhancing_magic_duration || 0) : 0;
  return {kind: sp.kind, spell: sp.spell, comp: rdm ? (others ? 'others' : 'self') : 'none', base: sp.base + seconds + (sp.kind === 'regen' ? bonus.regenSec : 0), name: sp.kind,
    refBase: sp.kind === 'refresh' ? sp.pot : 0, regenBase: sp.kind === 'regen' ? sp.pot + bonus.regenAdd : 0,
    // Temper II caps at 40 % (BG Wiki Temper_II); Temper I has no cap
    temperCap: sp.spell === 'Temper II' ? 40 : 0,
    // the "En"spell Damage gifts, 5 + 5 + 6 + 7 (atelier/calc/calc_jobs_mages.js; measured +23 on Kaories, 2026-10-14):
    // counted once all the gifts are had (2100 spent), the spent points of each one not being known here
    enGifts: rdm && jp >= 2100 ? 23 : 0,
    skill: bonus.skill, barAdd: bonus.barAdd, durMul: bonus.durMul, potMul: bonus.potMul, perp: bonus.perp, notes: bonus.notes};
}
// On whom a Red Mage's enhancing set is cast, for the page to say beside its name ('Self' / 'Others'), or '': a set
// named Composure reads as "with Composure" when it means "on the others" (both are cast with Composure up)
function enhTarget(s){
  const e = enhContext(s);
  return e && e.comp !== 'none' ? (e.comp === 'others' ? 'Others' : 'Self') : '';
}
// Potency first, then how long it lasts, then the least damage taken with what is left (the player's order,
// 2026-10-14). No skill after them: past what the potency
// reads of it (500 for Phalanx, Gain and Bar-element, 501 for Aquaveil) it gives nothing, and asking for it moved
// pieces for no gain. Refresh and Regen also have "a cast" objectives (potency x ticks) to choose instead
const ENH_OBJS = {refresh: ['refreshTick', 'enhTime', 'pdtRed'], regen: ['regenTick', 'enhTime', 'pdtRed'], gain: ['gainPot', 'enhTime', 'pdtRed'],
  temper: ['temper', 'enhTime', 'pdtRed'], enspell: ['enspell', 'enhTime', 'pdtRed'], barele: ['barEle', 'enhTime', 'pdtRed'],
  aquaveil: ['aquaveil', 'enhTime', 'pdtRed'], phalanx: ['phalanx', 'enhTime', 'pdtRed'], stoneskin: ['stoneskin', 'enhTime', 'pdtRed'],
  // Bar-status: its fixed resistance + Sroda Necklace; Auspice: its Subtle Blow. Their length (and Sneak's,
  // Invisible's, ENH_PLAIN with the Dream pieces' seconds) by the enhancing duration: assumed, BG Wiki's pages are silent
  barail: ['barStatus', 'enhTime', 'pdtRed'], auspice: ['auspice', 'enhTime', 'pdtRed']};
// (a spell with no potency to look for: its length, then the damage taken, physical then magical)
const ENH_PLAIN = ['enhTime', 'pdtRed', 'mdtRed'];
const ENH_MORE = {refresh: ['refreshMp'], regen: ['regenHp']};
// A tank's Phalanx (PLD, RUN) keeps the tank's own objectives and search (Guide_Paladin: Phalanx, then the damage
// taken; enmity after it): its 3 minutes are recast in the rotation, their length is not what the set is for
const tankPhalanx = (s, e) => !!e && e.kind === 'phalanx' && ['PLD', 'RUN'].includes(S.job);
// A healer's spell set the formulas above do not take (notes/docs-perso/sorts-whm-2026-10-25/SPEC.md, the player's
// rule 2026-10-25): what the spell gains first, then the damage taken and the MP saved; a spell with nothing to gain
// (Raise, the -na, Teleport) wears defence and Conserve MP, its Fast Cast being the precast's. A tank's divine sets
// (Flash, Banish: Enmity) keep its own rules. The first that fits
const SPELL_OBJS = [[/cursna/i, ['cursna', 'healSkill', 'pdtRed']], [/esuna/i, ['esunaPlus', 'pdtRed', 'cmp']],
  [/\berase\b/i, ['erasePlus', 'pdtRed', 'cmp']], [/repose/i, ['divAcc', 'pdtRed', 'cmp']], [/flash/i, ['divAcc', 'enmity', 'pdtRed']],
  // Holy and Banish: their damage first (the player's guide, notes/docs-perso/whm-guide/WHM_Guide_Technique.md §9.7: MAB, Magic Damage, MND),
  // then landing; the Divine set (Flash and Banish without a set of their own) landing first
  [/banish|holy/i, ['mab', 'divAcc', 'pdtRed']], [/divine magic/i, ['divAcc', 'mab', 'pdtRed']],
  // a -na: the Empyrean head spreads it around its target, every time with Yagrush (the player's guide §4.9)
  [/statusremoval|poisona|paralyna|blindna|silena|stona|viruna/i, ['naVeil', 'pdtRed', 'cmp']],
  [/\b(raise|arise|reraise)\b|teleport|recall|warp|retrace|escape|deodorize/i, ['pdtRed', 'mdtRed', 'cmp']]];
function spellObjectives(s){
  if (['PLD', 'RUN'].includes(S.job) || family(s.path, s.pieces) !== 'midcast') return null;
  const p = setNames(s), hit = SPELL_OBJS.find(([re]) => re.test(p));
  return hit ? hit[1] : null;
}
function statDefaultOf(s){
  const p = setNames(s), fam = family(s.path, s.pieces), tank = ['PLD', 'RUN'].includes(S.job);
  if (moveSet(s)) return ['move'];
  if (doomSet(s)) return ['holyWater', 'cursnaRecv'];
  if (xpSet(s)) return segs(s.path)[0] === 'meleeXp' ? ['blockGear', 'absorb', 'def'] : ['absorb', 'def', 'meva'];
  if (enmityMaxSet(s)) return ['enmity'];
  // a Bard's song set (brd_song.js): Song+, then length; a debuff's landing; a filler's shortness
  if (songObjectives(s)) return songObjectives(s);
  // a dark magic set (dark_magic.js): Drain, Aspir, the Absorbs, Stun, Bio, Dread Spikes, Endark
  if (darkObjectives(s)) return darkObjectives(s);
  const enh = enhContext(s);
  if (enh && !tankPhalanx(s, enh)) return ENH_OBJS[enh.kind] || ENH_PLAIN;
  // Burn and the other elemental debuffs (ele_debuff.js)
  if (edObjectives(s)) return edObjectives(s);
  // an enfeebling set, by the spells cast in it (enfeeble.js)
  const enf = enfObjectives(s);
  if (enf) return enf;
  // a GEO's luopan sets and its Geo- / Indi- cast sets (luopan.js)
  if (luopanObjectives(s)) return luopanObjectives(s);
  // a BST's set worn while the pet fights alone (bst_pet.js)
  if (petObjectives(s)) return petObjectives(s);
  const sp = spellObjectives(s);
  if (sp) return sp;
  // a tank's self Cure Fast Cast: capped, then as few HP as can be (Guide_Paladin CURE SELF: the midcast's HP open the
  // gap); a Fast Cast set first (it is named for the spells it serves: precast.FC.Phalanx). A healer heals the same
  // whatever its HP: its self Cure's Fast Cast is a Fast Cast set like any (the player, 2026-10-29)
  if (tank && fam === 'fc' && /cure/i.test(p) && /self/i.test(p)) return ['fc', 'hpLow'];
  if (fam === 'fc') return ['fc', 'hp', 'pdtRed'];
  // Phalanx first, then the damage taken (no DT floor: the Phalanx comes before it)
  if (/phalanx/i.test(p)) return ['phalanx', 'pdtRed', 'mdtRed'];
  // a self Cure: a tank wants the most enmity from it (its HP healed x (1 + Enmity): opt_stat.js cureEnm), then the heal
  // itself; a healer the heal (its own Cure potency received in), then as little enmity as its Cure on the others
  if (/cur(e|a|aga)/i.test(p) && /self/i.test(p)) return tank ? ['cureEnm', 'cureSelf', 'pdtRed'] : ['cureSelf', 'enmityLow', 'pdtRed'];
  if (/enmity|flash|crusade|provoke|foil|sird|sentinel|rampart|vallation|valiance|pflug|swordplay|battuta|liement|gambit|rayke/i.test(p)) return ['enmity', 'def', 'hp'];
  // a Cure on the others, and the job's Healing Magic set (worn for a Cure with no set of its own): the HP it heals
  // (its potency was capped at 50 % on every healer's set, then the search added Enmity: Kaories' RDM, 2026-10-22);
  // a healer then wants as little enmity as it can. A tank keeps its own order (its Cure's enmity before the HP it
  // heals: the HP healed first cost a PLD's CureOther 63 Enmity, 2026-10-22)
  if (/cur(e|a|aga)/i.test(p) || (fam === 'midcast' && /healing magic/i.test(p))) return tank ? ['cure', 'enmity', 'hp'] : ['cureOther', 'enmityLow', 'pdtRed'];
  if (/stoneskin/i.test(p) && fam !== 'fc') return ['stoneskin', 'enhSkill', 'hp'];
  // Enlight II: its bonus, then how long it lasts (enhancing duration: not confirmed by BG Wiki on this divine spell), then Enmity
  if (/enlight/i.test(p) && fam !== 'fc') return ['enlight', 'enhdur', 'enmity'];
  // an enhancing set (Protect, Shell, Reprisal...): how long they last
  if (family(s.path, s.pieces) === 'midcast' && /enhancing|protect|shell|reprisal/i.test(s.path)) return ['enhdur', 'enhSkill', 'hp'];
  if (/refresh/i.test(p)) return ['refresh', 'pdtRed', 'mdtRed'];
  if (/regen/i.test(p)) return ['regen', 'pdtRed', 'mdtRed'];
  // a magic-defense set by its name (idle.MDT, MEva): not every set with Magic in it (Enhancing Magic). Guide_Paladin
  // (Idle MDT, Magical Damage Mitigation): resist first (magic evasion and the elemental resistances move the resist
  // steps 1, 1/2, 1/4, 1/8), then the Magic Defense Bonus divides what lands; the MDT at its cap is a floor
  // (Guide_Paladin tools/solve_idle.py idle_meva: Carrier's Sash, then Magic Evasion, then MDB; the enmity kept when
  // hit is no objective there: Creed Collar took the neck from the magic evasion, the player's rule of 2026-10-31)
  if (/meva|mdt/i.test(p)) return ['eleCover', 'meva', 'mdb'];
  // a tank's idle (Guide_Paladin idle sets): PDT / MDT capped, the HP pool and the enemy's crits as floors; then a PLD's
  // block (the shield skill and block chance of the gear), the DEF, the magic evasion
  // (the block only with a shield that does not block every hit already: Duban and Ochain, ~108 % at base, do)
  // the enmity kept when hit (ceLoss: Enmity up to +100) second; a PLD's block first with a shield that does not block it all
  if (fam === 'idle' || fam === 'special') return S.job === 'PLD' && !shieldBlocksAll(s) ? ['blockGear', 'ceLoss', 'def'] : tank ? ['def', 'ceLoss', 'meva'] : ['pdtRed', 'mdtRed', 'hp'];
  return ['hp', 'pdtRed', 'mdtRed'];
}
// The objectives and floors kept for that set (S.optOpts.statBy[path]: {objs, floor})
function statOpts(s){
  const by = (S.optOpts || {}).statBy || {};
  // a movement set's choices kept from before it was searched for its speed (the idle's objectives and floors, saved
  // on sets.Adoulin: the whole set filled with damage taken pieces, 2026-10-31) are left: its own apply
  let mine = by[s.path] || {};
  if (moveSet(s) && mine.objs && !mine.objs.includes('move')) mine = {};
  if (doomSet(s) && mine.objs && !mine.objs.includes('holyWater')) mine = {};
  // an experience set kept on objectives of before it knew the absorb: its own ones
  if (xpSet(s) && mine.objs && !mine.objs.includes('absorb')) mine = Object.assign({}, mine, {objs: null});
  // a job ability's set kept on the objectives it had before the pieces boosting the ability were searched for (Enmity,
  // DEF, HP: the Cab. Surcoat never taken for Fealty, 2026-10-31) takes the new ones; any other choice stays
  if (abilityName(s) && mine.objs && mine.objs.join() === 'enmity,def,hp') mine = Object.assign({}, mine, {objs: null});
  // sets.EnmityMax the same, its objectives of before (Enmity, DEF, HP) left for its own
  if (enmityMaxSet(s) && mine.objs && mine.objs.join() === 'enmity,def,hp') mine = Object.assign({}, mine, {objs: null});
  const objs = (mine.objs || statDefault(s)).slice(0, 3);
  return {objs, floor: Object.assign({pdt: 0, mdt: 0, hp: 0, hpMax: 0, sird: 0, fc: 0, ecrit: 0, enmity: 0, phalanx: 0, ceLoss: 0, luDt: 0}, statFloorDefault(s, objs[0]), mine.floor || {})};
}
// The floors a tank's idle and Enmity sets start with (the guide's solve_idle / solve_enmity: DT+PDT at the -50 % cap,
// the gear's enemy critical hit rate -5 beside the -5 of the merits); 0 (no floor) elsewhere
// (SIRD sets and Cures: SIRD 102 with the merits, the guide's benchmark; a Fast Cast: capped at 80)
// A tank's other sets: their HP between the reference and 200 more (hpRef)
// A healer's set for its Cures on the others (not a tank's, not a self Cure's, not a SIRD one: those keep their floors)
const healerCure = s => !['PLD', 'RUN'].includes(S.job) && family(s.path, s.pieces) === 'midcast' && !/self|sird/i.test(setNames(s))
  && (/cur(e|a|aga)/i.test(setNames(s)) || /healing magic/i.test(s.path));
function statFloorDefault(s, first){
  // a base set (sets.Cure, core.js baseOnly) is never worn alone: the sets built on it hold the limits, not it
  if (baseOnly(s)) return {};
  // SIRD 102 on a set named for it, and on a tank's Cure sets (cast while taking hits)
  const fam = family(s.path, s.pieces), cureSet = fam === 'midcast' && /cur(e|a)/i.test(setNames(s)) && ['PLD', 'RUN'].includes(S.job);
  const sird = /sird/i.test(setNames(s)) || cureSet ? {sird: 102} : {};
  // every set of the other jobs: DT+PDT -50 and DT+MDT -29 at least, whatever the set is for (the player's rule,
  // 2026-10-14: no set worn with less, a spell's too); a tank's sets have their own floors below
  // (not an enhancing spell's set: its potency and its length come first, the damage taken is what the pieces left
  // give, as its last objectives: the player's rule once the floors had cost Refresh 14 % of its length; an
  // enfeebling set the same, its potency, length and magic accuracy first: enfeeble.js)
  // (a healer's Cure set the same: the floors cost Tetsouo's WHM 154 HP of its Cure IV, 2026-10-22)
  // (a healer's spell with something to gain the same, Cursna+, divine accuracy...: SPELL_OBJS; Raise and the others
  // with nothing to gain keep the floors)
  const sp = spellObjectives(s), gains = !!sp && sp[0] !== 'pdtRed';
  // (a BST's set worn while the pet fights alone the same: the pet is the one hit, its own damage taken an objective)
  if (isPetEngaged(s)) return {petAccBase: PET_ENG.accBase};
  if (isPetIdle(s)) return {};
  // a movement set: laid over the idle set, which keeps its damage taken (moveSet)
  if (moveSet(s) || doomSet(s)) return {};
  // a job ability's set on sets.precast.JA: only its boosting pieces over the base, worn for the use alone; the base
  // holds the damage taken floors (Rev. Coronet took Cover to DT+PDT -37: "floors not reached", 2026-11-01). A tank's
  // keeps the HP band all the same: a piece that takes it over the Fast Cast cuts HP when the next set goes on
  if (jaOverlayBase(s)) return hpBand(s);
  if (enmityMaxSet(s)) return {};
  // a Bard's buff song: its skill at the song's cap (brd_song.js songFloor); no damage taken floor
  if (songOf(s)) return songFloor(s) || {};
  // a BST's Charm set: worn for the ability's instant (bst_pet.js isCharmSet)
  if (isCharmSet(s)) return {};
  // a Ready set : worn for the move's instant, no damage taken floor ; a physical one starts from the pet's Accuracy
  if (readyKind(s)) return readyKind(s) === 'phys' || readyKind(s) === 'multi' ? {petAccBase: PET_ENG.accBase} : {};
  const tank = ['PLD', 'RUN'].includes(S.job), always = tank || gains || enhContext(s) || enfContext(s) || edContext(s) || darkContext(s) || healerCure(s) || songOf(s) ? {} : {pdt: -50, mdt: -29};
  if (first === 'fc') return Object.assign({fc: 80}, always);
  if (!tank) return Object.assign(always, sird);
  const hp = hpBand(s);
  // damage taken at its cap on every tank set worn more than an instant: DT+PDT -50, DT+MDT -50 less what Shell gives
  // (Shell V -29.3 %: -21 left to the gear)
  // (not on a Phalanx set: its Phalanx comes first, the damage taken after it as objectives)
  // A II layer (Aegis' "Magic damage taken II -50%", Burtgang's PDT II) adds past the first one's -50 %, the whole
  // stopping at -87.5 % (statlines.ts layeredLine): the first layer only needs what takes the total to that cap (with
  // Aegis -37.5, Shell V then leaves -9 to the gear in place of -21). The set's pieces as shown: a shield tried counts
  const worn = Object.entries(withWeapons(s).pieces), two = k => Math.abs(worn.reduce((n, [slot, p]) => n + (statVec(p, slot)[k] || 0), 0));
  const layer1 = k => Math.min(50, 87.5 - two(k));
  const shell = buffTotals().shell || 0, dt = first === 'phalanx' ? {} : {pdt: -Math.ceil(layer1('pdt2')), mdt: -Math.max(0, Math.ceil(layer1('mdt2') - shell / 256 * 100))};
  // the gear's cut of the enemy's crits the idle needs: 10 % to the 1 % floor is 9, less the merits (5/5: 4)
  const need = 9 - (((measuredChar() || {}).merits || {}).enemy_critical_hit_rate || 0);
  const ecrit = ['idle', 'special'].includes(fam) && need > 0 ? {ecrit: -need} : {};
  return Object.assign(dt, ecrit, sird, hp);
}
// The reference HP of a tank's sets: the lowest of the classic Fast Cast sets (sets.precast.FC and its spells', not
// the self Cure's, low on purpose), worn before every spell.
// Swapping to a set with fewer max HP cuts the current HP, and swapping back does not give them back. The Fast Cast is
// the ceiling (the player's rule, 2026-11-01): going to it before a spell never cuts HP, and the other sets keep within
// HP_SPREAD under it, so going from one to another cuts 100 at most (Guide_Paladin HP Management put the Fast Cast at
// the bottom, the others up to 200 over it: every spell then cut what they had over it). Not for the Fast Cast sets
// themselves, nor the self Cure pair (its gap is on purpose: cureGap). {hp, path} or null
const HP_SPREAD = 100;
// A tank's set between HP_SPREAD under the Fast Cast and the Fast Cast ({hp, hpMax} as floors), or none
function hpBand(s){
  const ref = ['PLD', 'RUN'].includes(S.job) ? hpRef(s) : null;
  return ref && !cureGap(s) ? {hp: ref.hp - HP_SPREAD, hpMax: ref.hp} : {};
}
function hpRef(s){
  if (!['PLD', 'RUN'].includes(S.job) || family(s.path, s.pieces) === 'fc') return null;
  const d = data(), list = d ? d.sets.filter(x => family(x.path, x.pieces) === 'fc' && !(/cure/i.test(x.path) && /self/i.test(x.path))) : [];
  let low = null;
  // (during a run over every set, opt_sets.js, the Fast Cast as just found: the sets after it follow its new HP)
  for (const x of list) { const hp = statFigures(x, !S._optChain).hp; if (!low || hp < low.hp) low = {hp, path: x.path}; }
  return low;
}
// A set laid over another one (sets.precast.JA.Sentinel = FullEnmity + Caballarius Leggings): its own pieces stay
// when asked (a job ability's set: on by default), only the rest is searched. The slots kept, or none
function keptSlots(s){
  const list = abilityPieces(s);
  if (!list.length) return [];
  const mine = ((S.optOpts || {}).statBy || {})[s.path] || {};
  return (mine.keepOwn != null ? mine.keepOwn : true) ? list : [];
}
// The slots of a job ability's set whose piece boosts that ability: its description or its augments name it
// (Rev. Leggings +4 "Holy Circle", Cab. Leggings "Sentinel", Chev. Sabatons "Divine Emblem"); not the set's other
// pieces, which only differ from the set it is laid over (Cryptic Earring in Holy Circle's)
function abilityPieces(s){
  const ja = abilityName(s), out = [];
  if (!ja) return [];
  for (const [slot, p] of Object.entries(withoutTrial(() => withWeapons(s).pieces))) if (boostsAbility(p, slot, ja)) out.push(slot);
  return out;
}
// The job ability a set is worn for, lower case, or null (not a BST's Charm set: every piece there is for the ability,
// "Charm"+N ones included, all searched)
// (null on sets.precast.JA itself: the set of every ability with none of its own, named for none)
// (sets.precast.JA.<name> by its path too: Provoke's set is in the Enmity family, by its name, and missed every rule
// of the ability sets, 2026-11-01)
function abilityName(s){
  const sg = s ? segs(s.path) : [], jaPath = sg.length === 3 && sg[0] === 'precast' && sg[1] === 'JA';
  return s && (family(s.path, s.pieces) === 'ja' || jaPath) && !isCharmSet(s) && !(sg.length === 2 && sg[1] === 'JA') ? sg[sg.length - 1].toLowerCase() : null;
}
// Whether a piece boosts that ability: its description or its augments name it. Cab. Surcoat's Fealty is an augment
// only (BG Wiki Cab._Surcoat_+3: "Enhances 'Fealty' effect", 4 s a merit level), on no description
// (a piece the set names without augments read as your copy of it, as the set's figures are: engine.js ownCopy)
// Not a line telling what happens to the hits taken while the effect lasts (Cab. Surcoat '"Cover": Physical damage
// converted to MP', Sahip Helm '"Cover": Damage taken-12%'): worn then, in the idle or engaged set, not in the
// ability's own set, worn for its use only (the player, 2026-10-31). '"Shield Bash": "Dispel"' acts at the use: kept
// Pieces whose line names the ability with no figure but acts while it lasts, read on BG Wiki: Valor Surcoat's
// "Augments "Cover"" converts 20 % of the intercepted damage to MP (+2: 30 %), as Cab. Surcoat does
const ABILITY_DURING = {'Valor Surcoat': 'cover', 'Vlr. Surcoat +1': 'cover', 'Vlr. Surcoat +2': 'cover'};
function boostsAbility(p, slot, ja){
  if (!p || isEmpty(p) || ABILITY_DURING[p.name] === ja) return false;
  const q = p.augs && p.augs.length ? p : ownCopy(slot, p), cat = catalog(), id = q.id || ownId(q.name, slot) || (cat && cat.id[q.name]);
  const lines = (descOf(id, cat) || '').split('\n').concat(q.augs || []).map(l => l.toLowerCase().trim());
  const during = l => (l.startsWith(`"${ja}":`) || l.startsWith(`${ja}:`)) && /damage taken|converted/.test(l);
  // the name as a word of its own: "cover" is in "MP recovered while healing" (Austerity Belt counted for Cover)
  const named = new RegExp(`(^|[^a-z])${ja}([^a-z]|$)`);
  // nor a piece that casts it (Reviler's Helm 'Enchantment: "Provoke"', Imperial Egg 'Additional effect: "Provoke"')
  const casts = l => /(enchantment|additional effect):/.test(l);
  return lines.some(l => named.test(l) && !during(l) && !casts(l));
}
// A job ability's set built on sets.precast.JA (set_combine: the job's full Enmity set, worn by every ability with no
// set of its own): only the pieces that boost that ability are its own, the rest is the base's (the player's rule,
// 2026-10-31). Its base set, or null
function jaOverlayBase(s){
  return abilityName(s) && s.base === 'sets.precast.JA' ? ((S._bypath || {})[s.base] || null) : null;
}
// Whether a piece boosts that set's ability (its description or augments name it: boostsAbility), yours or any of the
// game your job can wear (the optimizer's "Every item in the game" shows it to get: Rev. Coronet for Cover, the
// player's rule 2026-11-01): with none, its optimizer has nothing to look for (card.ts sends the player to
// sets.precast.JA). Kept per ability until the data or the catalog change
let JA_BOOST_MEMO = {key: '', out: {}};
function jaBoostable(s){
  const cat = catalog(), key = DATA_GEN + '|' + S.job + '|' + !!cat;
  if (JA_BOOST_MEMO.key !== key) JA_BOOST_MEMO = {key, out: {}};
  const ja = abilityName(s), memo = JA_BOOST_MEMO.out;
  if (!ja) return false;
  if (!(ja in memo)) memo[ja] = Object.entries(ownedOf() || {}).some(([slot, list]) => list.some(x => boostsAbility(x, slot, ja)))
    || (!!cat && Object.values(cat.row).some(r => (r[3] || '').split(' ').includes(S.job) && boostsAbility({name: r[1]}, (r[2] || '').split(' ')[0], ja)));
  return memo[ja];
}
// The HP a tank's self Cure midcast set opens over its Fast Cast (the other set of the pair: sets.precast.FC.CureSelf
// and sets.midcast.CureSelf, any names with Cure and Self), or null; null off PLD / RUN: the gap is the tank's trick
// (Guide_Paladin CURE SELF), a healer's self Cure heals the same whatever its HP
function cureGap(s){
  if (!['PLD', 'RUN'].includes(S.job) || !/cure/i.test(s.path) || !/self/i.test(s.path)) return null;
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

// The single target Cure the job casts highest (main job at its level, or its subjob: enh_jobs.js enhTierAny):
// {name, tier}; a job that casts none with the subjob shown is judged with the subjob that gives the most (a RUN's
// Cure sets: /WHM). Cure IV when no subjob casts one either
const CURE_TIERS = [['Cure', 0, 0], ['Cure II', 0, 0], ['Cure III', 0, 0], ['Cure IV', 0, 0], ['Cure V', 0, 0], ['Cure VI', 0, 0]];
function cureSpellOf(){
  const got = enhTierAny(CURE_TIERS, S.job, (data() || {}).sub, jaLevels(), (measuredChar() || {}).jp_spent || 0, '');
  return got ? {name: got.t[0], tier: got.t[3] + 1} : {name: 'Cure IV', tier: 4};
}
