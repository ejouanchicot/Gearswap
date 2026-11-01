// GearSwap Atelier · stat_opt.js: the optimizer for the sets judged by their stats (idle, Enmity, Phalanx, Fast Cast,
// Cure, Refresh...), the PLD / RUN tank sets first. No damage engine: the page reads each piece's stats (stats.js
// pieceStats) and the search (atelier/opt.js, its "stats" mode: O.statFigures) adds them up. The figures follow the
// Paladin guide's solvers (Guide_Paladin tools/solver_common.py, solve_idle / solve_enmity / solve_phalanx / solve_fc):
// objectives in order (the first, then the next ones to part sets as good on it), and floors (DT+PDT, DT+MDT, HP between
// two values, SIRD, Fast Cast, enemy critical hit rate)
// (loaded after opt_page.js: see atelier/src/legacy/files.ts)

const STAT_OBJS = ['def', 'hp', 'hpLow', 'cureSelf', 'cureOther', 'enmity', 'enmityLow', 'phalanx', 'fc', 'sird', 'meva', 'mdb', 'pdtRed', 'mdtRed', 'ecritRed', 'cure', 'cmp', 'refresh', 'regen', 'enhdur', 'stoneskin', 'enlight', 'enhSkill', 'divSkill', 'enhTime', 'refreshTick', 'refreshMp', 'regenTick', 'regenHp', 'gainPot', 'temper', 'enspell', 'barEle', 'aquaveil', 'cureEnm', 'blockGear', 'statusRes', 'eleRes', 'ceLoss', 'eleCover', 'luDt', 'luRegen', 'luCharm', 'geomancy', 'geoSkill', 'enfPot', 'enfTime', 'enfAcc', 'enfEff', 'enfSkill', 'edDown', 'edDot', 'edTime', 'edAcc',
  'cursna', 'healSkill', 'auspice', 'barStatus', 'esunaPlus', 'erasePlus', 'naVeil', 'divAcc', 'mab',
  // a BST's pet (bst_pet.js)
  'petAcc', 'petAtk', 'petHaste', 'petStp', 'petDa', 'petDt', 'petMdt', 'petRegen', 'petMab', 'petMacc', 'petInt', 'petMelee', 'petTpb', 'chr', 'macc', 'charmPlus', 'charmDur',
  // a movement set's (moveSet)
  'move',
  // the Doom set's (doomSet)
  'holyWater', 'cursnaRecv',
  // the Chevalier's set's absorb (opt.js STAT_SETS), a PLD's experience sets' (xpSet)
  'absorb',
  // a job ability's set: its pieces that boost that ability (abilityName)
  'jaPlus'];
const STAT_PCT = new Set(['holyWater', 'absorb', 'fc', 'sird', 'cmp', 'pdtRed', 'mdtRed', 'ecritRed', 'cure', 'enhdur', 'blockGear', 'statusRes', 'eleRes', 'ceLoss', 'luDt', 'petHaste', 'petDt', 'petMdt', 'move']);
// a reduction of the enemy's critical hits reads as the gear says it (−7 %)
// the enmity of a Cure reads as its two parts (CE + VE, the total being 7 CE: opt.js cureEnm), not a bare figure that
// looks like HP
// a spell's length reads as minutes and seconds (12:36)
const enhTimeText = v => `${Math.floor(v / 60)}:${String(Math.round(v % 60)).padStart(2, '0')}`;
// (the least enmity is ranked by its opposite: shown as the Enmity it is)
// the figures kept as a reduction (68 = 68 % less damage taken): written as the game writes them, "−68 %"
const STAT_NEG = new Set(['ecritRed', 'pdtRed', 'mdtRed']);
const statFmt = k => v => v == null ? '—' : k === 'enmityLow' ? statFmt('enmity')(-v) : k === 'cureEnm' ? cureEnmText(v) : k === 'enhTime' || k === 'enfTime' || k === 'edTime' || k === 'charmDur' ? enhTimeText(v)
  : (STAT_NEG.has(k) && v > 0 ? '−' : '') + ((Math.round(v * 10) / 10) || 0).toLocaleString(S.lang === 'fr' ? 'fr-FR' : 'en-US') + (STAT_PCT.has(k) ? ' %' : '');
const cureEnmText = v => { const ce = Math.round(v / 7), n = x => x.toLocaleString(S.lang === 'fr' ? 'fr-FR' : 'en-US'); return `${n(ce)} CE · ${n(Math.round(v - ce))} VE`; };
// A set the stats optimizer takes: every set but the weaponskill, engaged and Jump ones (their own optimizers), and
// the weapon sets
// RDM's Saboteur set is laid over the enfeeble's set while Saboteur is up (RDM_MIDCAST.lua): only Lethargy Gantherots
// belong there ("Enhances Saboteur effect", counted at the cast: 415.5 s with them, 390.1 s without, Kaories 2026-10-14).
// Searched as a set of its own it took HP pieces in every slot, which then replaced the enfeeble's gear in game
const sabOverlay = s => { const p = segs(s.path); return p[p.length - 1] === 'Saboteur' && p.includes('Enfeebling Magic'); };
// A movement set, laid over the idle set while running (sets.MoveSpeed), kiting (Mote's sets.Kiting) or in Adoulin
// (sets.Adoulin: base_set_builder.lua lay_town): only the equipment's highest Movement speed counts (BG Wiki
// Movement_Speed: "Only the highest value from equipment counts"), so its search starts empty and keeps the one
// fastest piece; every other slot is left to the idle set under it
const moveSet = s => ['MoveSpeed', 'Kiting', 'Adoulin'].includes(segs(s.path)[0]);
// sets.buff.Doom, laid over the set worn while Doomed (Mote's sets.buff): the pieces that help remove it, by Holy Water
// first (the one a player uses on oneself), then by the Cursna others cast; like a movement set, it starts empty and
// every slot it leaves goes to the set under it
const doomSet = s => { const sg = segs(s.path); return sg[0] === 'buff' && sg[1] === 'Doom'; };
// Its Holy Water given back for Cursna received, about 3 points at 80 % at most (4 % of the figure: opt.js tolGainPass):
// Purity Ring's Cursna +7 for the 3 % a second Blenmot's Ring +1 adds (the player, 2026-11-01)
const DOOM_TOL = {gain: 'crecv', keep: ['holyWater'], tol: 0.04};
// A PLD's experience sets (sets.idleXp, sets.meleeXp: worn with Xp On, a pull of 50 to 100 monsters): damage taken at
// its cap as floors, then the Chevalier's set's absorb and the DEF standing, the block and the absorb fighting (the
// player, 2026-11-01: block first, as the game rolls it first). Their weapons are the stance's, not searched
const xpSet = s => !!s && S.job === 'PLD' && ['idleXp', 'meleeXp'].includes(segs(s.path)[0]);
// a set laid over another one and searched from empty (opt.js opts.bare, optimizer.js clearRest)
const bareSet = s => moveSet(s) || doomSet(s);
// A tank's sets.EnmityMax (PLD, the Tanking stance: enmity_override.lua): the most Enmity there is, the sword and the
// shield searched too, no floor of damage taken or HP (the player, 2026-10-31: "full enmity, no concession")
const enmityMaxSet = s => !!s && segs(s.path)[0] === 'EnmityMax' && ['PLD', 'RUN'].includes(S.job);
// Movement speed a piece gives in one city only (res/item_descriptions.lua: Councilor's Garb "While in Adoulin:
// Movement speed +25%", the only one; read by no stat parser), counted in that city's set
const CITY_MOVE = {Adoulin: {"Councilor's Garb": 25}};
const cityMove = (p, s) => { const m = s && CITY_MOVE[segs(s.path)[0]]; return (m && p && m[p.name]) || 0; };
// (a BST's sets.pet.engaged is one: the pet's stats, bst_pet.js; its Ready move sets are not)
const statSet = s => !!s && (isPetSet(s) || !['ws', 'engaged', 'weapons', 'pet'].includes(family(s.path, s.pieces))) && !isJumpSet(s.path) && !sabOverlay(s);
// What a set is for when nothing was chosen: the guide's profiles (idle DEF then Enmity then MDB; Enmity then DEF;
// Phalanx then DEF; Fast Cast then HP)
// A tank (PLD, RUN) wants Enmity on every action its set is worn for, after what the action itself needs (the
// Phalanx, the Cure...): Enmity goes second when it is not first. Not on a Fast Cast set: a spell's enmity comes at its
// midcast. A job ability's set: Enmity first, its own piece kept (keptSlots)
function statDefault(s){
  const list = withSird(s, statDefaultOf(s)), fam = family(s.path, s.pieces);
  if (xpSet(s)) return list;
  // a job ability's set: the pieces that boost that ability first (Cab. Surcoat's Fealty, Cab. Leggings' Sentinel); a
  // tank's then Enmity and DEF
  if (abilityName(s)) return ['PLD', 'RUN'].includes(S.job) ? ['jaPlus', 'enmity', 'def'] : ['jaPlus', ...list.filter(k => k !== 'jaPlus')].slice(0, 3);
  // (the Cure's enmity counts Enmity already)
  if (!['PLD', 'RUN'].includes(S.job) || ['fc', 'idle', 'special'].includes(fam) || list.includes('enmity') || list[0] === 'cureEnm' || list[0] === 'phalanx') return list;
  if (fam === 'ja') return ['enmity', 'def', 'hp'];
  // after the set's own (and SIRD on a SIRD set), Enmity
  const lead = list[1] === 'sird' ? 2 : 1;
  return [...list.slice(0, lead), 'enmity', ...list.slice(lead).filter(k => k !== 'enmity')].slice(0, 3);
}
// A SIRD set (SIRDPhalanx, SIRDEnmity...): SIRD right after what the set is for, so the objective itself says it
// (its floor at 102 holds it too: statFloorDefault)
// Every name a set goes by (the export keeps one, the others as aliases: sets.midcast.SIRDEnmity is shared by
// Banishga, Cocoon, Foil... and may come under any of them): what it is for is read from all of them
const setNames = s => [s.path, ...(s.aliases || [])].join(' ');
function withSird(s, list){
  if (!/sird/i.test(setNames(s)) || list[0] === 'sird') return list;
  return [list[0], 'sird', ...list.slice(1).filter(k => k !== 'sird')].slice(0, 3);
}
/* ---- enhancing magic: what a set is cast for, on whom, and what the spell is worth (opt.js O.enhancingFigures) ---- */
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
  // a self Cure: a tank wants the most enmity from it (its HP healed x (1 + Enmity): opt.js cureEnm), then the heal
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
  // a BST's Charm set: worn for the ability's instant (bst_pet.js isCharmSet)
  if (isCharmSet(s)) return {};
  // a Ready set : worn for the move's instant, no damage taken floor ; a physical one starts from the pet's Accuracy
  if (readyKind(s)) return readyKind(s) === 'phys' || readyKind(s) === 'multi' ? {petAccBase: PET_ENG.accBase} : {};
  const tank = ['PLD', 'RUN'].includes(S.job), always = tank || gains || enhContext(s) || enfContext(s) || edContext(s) || healerCure(s) ? {} : {pdt: -50, mdt: -29};
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
  for (const x of list) { const hp = statFigures(x, true).hp; if (!low || hp < low.hp) low = {hp, path: x.path}; }
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

/* ---- the objectives by kind, and the ones a set is shown ---- */
const STAT_OBJ_GROUPS = [['enh', ['enhTime', 'refreshTick', 'refreshMp', 'regenTick', 'regenHp', 'gainPot', 'temper', 'enspell', 'barEle', 'barStatus', 'aquaveil', 'auspice']], ['def', ['def', 'hp', 'pdtRed', 'mdtRed', 'ecritRed', 'blockGear', 'absorb', 'meva', 'mdb', 'statusRes', 'eleCover', 'eleRes']], ['enm', ['jaPlus', 'enmity', 'enmityLow', 'ceLoss', 'cureEnm']],
  ['cure', ['cureOther', 'cureSelf', 'cure', 'cmp', 'hpLow', 'holyWater', 'cursnaRecv', 'cursna', 'healSkill', 'esunaPlus', 'erasePlus', 'naVeil']], ['magic', ['phalanx', 'stoneskin', 'enlight', 'enhdur', 'enhSkill', 'divSkill', 'divAcc', 'mab', 'fc', 'sird']],
  ['regen', ['refresh', 'regen']], ['enf', ['enfPot', 'enfTime', 'enfAcc', 'enfEff', 'enfSkill']], ['eled', ['edDown', 'edDot', 'edTime', 'edAcc']], ['luopan', ['luDt', 'luRegen', 'geomancy', 'geoSkill', 'luCharm']], ['pet', ['petAcc', 'petAtk', 'petHaste', 'petStp', 'petDa', 'petDt', 'petMdt', 'petRegen', 'petMab', 'petMacc', 'petInt', 'petMelee', 'petTpb', 'chr', 'macc', 'charmPlus', 'charmDur']], ['move', ['move']]];
// What a set's kind can be after (its name, as statDefaultOf reads it), its chosen objectives always in
function statRelevant(s, chosen){
  const p = setNames(s), fam = family(s.path, s.pieces), out = new Set(chosen);
  const add = list => list.forEach(k => out.add(k)), def = ['def', 'hp', 'pdtRed', 'mdtRed', 'meva', 'mdb', 'enmity'];
  if (moveSet(s)) { add(['move']); return out; }
  if (doomSet(s)) { add(['holyWater', 'cursnaRecv']); return out; }
  if (xpSet(s)) add(['absorb', 'blockGear']);
  add(luopanRelevant(s));
  if (isPetSet(s)) { add([...petRelevant(s), 'pdtRed', 'mdtRed', 'hp']); return out; }
  if (isCharmSet(s)) { add(charmRelevant(s)); return out; }
  const enh = enhContext(s);
  if (enh && !tankPhalanx(s, enh)) { add([...(ENH_OBJS[enh.kind] || ENH_PLAIN), ...(ENH_MORE[enh.kind] || []), 'mdtRed', 'enhSkill', 'sird', 'cmp', 'hp',
    ...(['PLD', 'RUN'].includes(S.job) ? ['enmity', 'def'] : [])]); return out; }
  if (enfContext(s)) { add(enfRelevant(s)); return out; }
  if (edContext(s)) { add(edRelevant()); return out; }
  const sp = spellObjectives(s);
  if (sp) { add([...sp, 'pdtRed', 'mdtRed', 'cmp', 'hp', 'sird', 'divSkill', 'healSkill', 'enmity']); return out; }
  const tank = ['PLD', 'RUN'].includes(S.job);
  if (fam === 'fc') add(tank && /cure/i.test(p) && /self/i.test(p) ? ['fc', 'hpLow', 'hp'] : ['fc', 'hp', 'pdtRed', 'mdtRed']);
  else if (/cur(e|a)/i.test(p) || (fam === 'midcast' && /healing magic/i.test(p))) add(/self/i.test(p) ? (tank ? ['cureEnm', 'cureSelf', 'cure', 'cmp', 'enmity', 'hp', 'sird', 'pdtRed', 'mdtRed']
      : ['cureSelf', 'cure', 'cmp', 'enmityLow', 'enmity', 'hp', 'sird', 'pdtRed', 'mdtRed'])
    : ['cureOther', 'cure', 'cmp', 'enmityLow', 'enmity', 'hp', 'sird', 'pdtRed', 'mdtRed']);
  else if (/phalanx/i.test(p)) add(['phalanx', 'enhSkill', 'sird', 'enmity', 'def', 'hp', 'pdtRed']);
  else if (/stoneskin/i.test(p)) add(['stoneskin', 'enhSkill', 'sird', 'enmity', 'hp', 'pdtRed']);
  else if (/enlight/i.test(p)) add(['enlight', 'enhdur', 'divSkill', 'sird', 'enmity', 'hp', 'pdtRed']);
  else if (fam === 'midcast' && /enhancing|protect|shell|reprisal/i.test(s.path)) add(['enhdur', 'enhSkill', 'sird', 'enmity', 'hp', 'pdtRed']);
  else if (fam === 'enmity' || fam === 'ja') add([...(abilityName(s) ? ['jaPlus'] : []), 'enmity', 'sird', ...def]);
  else if (fam === 'idle' || fam === 'special') add([...def, 'ceLoss', 'ecritRed', 'statusRes', 'eleCover', 'eleRes', 'refresh', 'regen', ...(S.job === 'PLD' ? ['blockGear'] : [])]);
  else add([...def, 'refresh', 'regen']);
  return out;
}

/* ---- the enmity of each action (Guide_Paladin 02 Enmity Generation: base VE / CE, before the gear) ---- */
// Final = base x (1 + Enmity / 100), the Enmity of gear + Crusade + Sentinel capped at +200 (x3)
const ACTION_ENMITY = {Invincible: [7200, 0], Palisade: [1800, 900], 'Shield Bash': [900, 450], Flash: [1280, 180], Sentinel: [900, 0],
  Majesty: [340, 0], Rampart: [320, 320], 'Divine Emblem': [320, 0], Sepulcher: [320, 0], Jettatura: [1020, 180], 'Blank Gaze': [320, 320],
  'Geist Wall': [320, 320], 'Sheep Song': [320, 320], Valiance: [900, 450], Vallation: [900, 450], Pflug: [900, 450], Foil: [880, 320],
  Swordplay: [320, 160], Provoke: [1800, 1], Warcry: [320, 0]};
// The actions a set is worn for, by its name and the names it is shared under (sets.FullEnmity: Flash, Crusade, Jettatura)
function setActions(s){
  // a Fast Cast set makes no enmity: the spell's comes at its midcast
  if (family(s.path, s.pieces) === 'fc') return [];
  const names = [s.path, ...(s.aliases || [])].map(p => segs(p).pop());
  return [...new Set(names)].filter(n => ACTION_ENMITY[n]);
}

/* ---- the pieces and the character, as plain data for the search (a worker has no page to ask) ---- */
// A piece's stats the search reads (stats.js keys), the shield flagged (Shield Barrier)
// The HP a piece adds to Stoneskin (BG Wiki Stoneskin; the game's descriptions name the effect, not always its amount:
// Stone Mufflers +30 as BG Wiki says, confirmed by the player 2026-10-14, though their description reads +20)
const STONESKIN_PLUS = {'Stone Gorget': 30, 'Nodens Gorget': 30, 'Stone Mufflers': 30, 'Siegel Sash': 20, 'Haven Hose': 20, 'Earthcry Earring': 10, 'Shedir Seraweels': 35};
// The pieces that cut the enmity lost when hit (Guide_Paladin, "Reduces Enmity Loss": their descriptions name the effect
// without its amount)
const ENMITY_LOSS_GEAR = {'Burtgang': 20, "Chev. Cuisses +3": 14, 'Creed Collar': 5};
// The weapons that raise Enlight's bonus, in hand (BG Wiki Enlight II)
const ENLIGHT_WEAPON = {Brilliance: 15, Honorbound: 7};
// A piece under level 99 the search still offers from the game's items (optimizer.js gameChoices): its effect is one
// of the above, read by name, that no level 99 piece replaces (Stone Mufflers, Siegel Sash, Earthcry Earring)
function specialPiece(name){
  return !!(STONESKIN_PLUS[name] || ENMITY_LOSS_GEAR[name] || ENLIGHT_WEAPON[name] || BAR_PLUS[name] || HEALER_PLUS[name]);
}
// A healer's spell pieces, read by their game names (their descriptions name the effect, not always its amount):
// [stat key, amount]. BG Wiki read 2026-10-25 (notes/docs-perso/sorts-whm-2026-10-25/SPEC.md):
//   Cursna+ (Cursna; the page marks Haoma's, Ephedra, Debilis, Malison, Hieros as the 2013 guide's, "known to be
//   incorrect"; Theophany Pantaloons +4 not listed)          cursna
//   "Auspice"+ (Auspice): Subtle Blow given                   auspice
//   Sneak / Invisible: Dream +1 pieces, the length set to its 600 s top then +30; Skulker's Cape +30 to both   sneaksec / invissec
//   Bar-status: Sroda Necklace +20 (Category:Barspell)        barstat
//   Esuna under Afflatus Misery: the weapons' extra effects   esuna (main hand)
//   Erase: Cleric's Torque, one more effect                   erase
//   a -na spread to the party by the Empyrean head, every time with Yagrush (the player's WHM guide §4.9)   naveil
const HEALER_PLUS = {
  Gambanteinn: [['cursna', 100]], "Menelaus's Ring": [['cursna', 20]], "Haoma's Ring": [['cursna', 15]], 'Ephedra Ring': [['cursna', 10]],
  'Debilis Medallion': [['cursna', 15]], 'Malison Medallion': [['cursna', 10]], "Alaunus's Cape": [['cursna', 25]], 'Mending Cape': [['cursna', 15]],
  'Oretan. Cape +1': [['cursna', 5]], 'Fanatic Gloves': [['cursna', 15]], 'Hieros Mittens': [['cursna', 10]], 'Theo. Pantaloons': [['cursna', 15]],
  'Theo. Pant. +1': [['cursna', 15]], 'Th. Pantaloons +2': [['cursna', 17]], 'Th. Pant. +3': [['cursna', 21]], 'Gende. Galosh. +1': [['cursna', 10]],
  'Vanya Clogs': [['cursna', 5]],
  'Orsn. Duckbills +1': [['auspice', 5]], 'Orsn. Duckbills +2': [['auspice', 10]], 'Ebers Duckbills': [['auspice', 13]], 'Ebers Duckbills +1': [['auspice', 15]],
  'Ebers Duckbills +2': [['auspice', 17]], 'Ebers Duckbills +3': [['auspice', 19]],
  'Dream Boots +1': [['sneaksec', 30]], 'Dream Mittens +1': [['invissec', 30]], "Skulker's Cape": [['sneaksec', 30], ['invissec', 30]],
  'Sroda Necklace': [['barstat', 20]],
  Asclepius: [['esuna', 3]], 'Piety Wand': [['esuna', 2]], "Cleric's Wand": [['esuna', 1]],
  "Cleric's Torque": [['erase', 1]], 'Clr. Torque +1': [['erase', 1]], 'Clr. Torque +2': [['erase', 1]],
  'Orison Cap': [['naveil', 1]], 'Orison Cap +1': [['naveil', 1]], 'Orison Cap +2': [['naveil', 1]], 'Ebers Cap': [['naveil', 1]],
  'Ebers Cap +1': [['naveil', 1]], 'Ebers Cap +2': [['naveil', 1]], 'Ebers Cap +3': [['naveil', 1]], Yagrush: [['naveil', 1]]};
// The weapons whose effect is theirs in the main hand only (Gambanteinn counts in either hand: the player's guide §11.4)
const HEALER_MAIN_ONLY = new Set(['Asclepius', 'Piety Wand', "Cleric's Wand", 'Yagrush']);
// A casting time cut of one kind of spell ("Cure" spellcasting time, Song, Elemental magic... casting time: the
// pieces' stats as stats.js reads them, x:<what> casting time, curecast) and its kind, the stat key cc_<kind> it adds to
const CAST_CUTS = [[/^curecast$|cure (spell)?casting/, 'cure'], [/healing magic/, 'healing'], [/enhancing magic/, 'enhancing'],
  [/stoneskin/, 'stoneskin'], [/enfeebling magic/, 'enfeebling'], [/elemental magic/, 'elemental'], [/dark magic/, 'dark'],
  [/black magic/, 'black'], [/blue magic/, 'blue'], [/song (spell)?casting/, 'song'], [/utsusemi/, 'utsusemi'], [/summoning magic/, 'summoning'],
  [/arts casting/, 'arts']];
function castVec(r){
  const out = {};
  for (const [k, e] of Object.entries(r.stats)) {
    if (k !== 'curecast' && !/casting time/.test(k)) continue;
    const hit = CAST_CUTS.find(([re]) => re.test(k));
    if (hit && e.v < 0) out['cc_' + hit[1]] = (out['cc_' + hit[1]] || 0) - e.v;
  }
  // a SCH's "Grimoire: Spellcasting time -12%" (Pedagogy Mortarboard): a condition the page shows as text, its figure
  // read from it ("Reduces spellcasting time" with no figure counts nothing)
  for (const c of r.cond || []) { const m = /^Grimoire: Spellcasting time -(\d+)%/i.exec(c); if (m) out.cc_grimoire = (out.cc_grimoire || 0) + +m[1]; }
  return out;
}
// The kinds of casting time cut a Fast Cast set counts, by the spells it is named for (core.js magicKindOf): a Cure's
// own and Healing magic's, a nuke's Elemental and Black magic's... A SCH's Arts cut on every spell (its Arts held up:
// the player's rule, 2026-10-22), and its Grimoire cut on the set named for it. A Fast Cast set of no kind
// (sets.precast.FC) counts none. Its own name only: the names it is shared under (BLM's sets.precast.FC is also its
// FC.Cure) are spells it is worn for among others
function castKindsOf(s){
  if (family(s.path, s.pieces) !== 'fc') return [];
  const p = s.path, kind = /statusremoval/i.test(p) ? 'cure' : magicKindOf(p), out = [];
  if (kind === 'cure') out.push(...(/cur(e|a)/i.test(p) ? ['cure', 'healing'] : ['healing']));
  if (kind === 'enhancing') out.push('enhancing', ...(/stoneskin/i.test(p) ? ['stoneskin'] : []));
  if (kind === 'enfeebling') out.push('enfeebling');
  if (kind === 'elemental') out.push('elemental', 'black');
  if (kind === 'dark') out.push('dark', 'black');
  if (kind === 'song') out.push('song');
  if (kind === 'ninjutsu' && /utsusemi/i.test(p)) out.push('utsusemi');
  if (kind === 'blue') out.push('blue');
  if (kind === 'summoning') out.push('summoning');
  if (S.job === 'SCH' && kind) out.push('arts');
  if (S.job === 'SCH' && /grimoire/i.test(p)) out.push('grimoire');
  return out;
}
function healerVec(name, slot){
  const out = {};
  if (HEALER_MAIN_ONLY.has(name) && slot !== 'main') return out;
  for (const [k, n] of HEALER_PLUS[name] || []) out[k] = n;
  return out;
}
// The resistance a piece adds to a Bar-element spell, over its 150 cap (BG Wiki Category:Barspell; Shedir Seraweels
// measured in game on Kaories 2026-10-14: 150 + 15 = 165)
const BAR_PLUS = {'Shedir Seraweels': 15, 'Piety Pantaloons +3': 36, "Cleric's Pantaloons +2": 25};
function statVec(p, slot){
  const r = p && !isEmpty(p) ? pieceStats(p, slot) : null, v = k => r && r.stats[k] ? r.stats[k].v || 0 : 0, out = {};
  if (!r) return {};
  if (r.stats['x:potency of cure effect received']) out.curerecv = r.stats['x:potency of cure effect received'].v;
  // "All magic skills" (Stikini Ring +1) counts in each magic skill read here
  const all = r.stats['x:all magic skills'] ? r.stats['x:all magic skills'].v : 0;
  if (v('skill:healing magic skill') + all) out.heal = v('skill:healing magic skill') + all;
  if (v('skill:divine magic skill') + all) out.div = v('skill:divine magic skill') + all;
  if (STONESKIN_PLUS[p.name]) out.ss = STONESKIN_PLUS[p.name];
  // Doom removal (stats.js DOOM_GEAR)
  if (v('x:holy water')) out.hw = v('x:holy water');
  if (v('x:cursna received')) out.crecv = v('x:cursna received');
  if (BAR_PLUS[p.name]) out.barplus = BAR_PLUS[p.name];
  if (S.job === 'GEO') Object.assign(out, luopanVec(r, all));
  if (S.job === 'BST') Object.assign(out, petVec(r, slot));
  Object.assign(out, enfVec(r, all, p.name), edVec(r, all, p.name), healerVec(p.name, slot), castVec(r));
  if (v('mab')) out.mab = v('mab');
  if (slot === 'main' && ENLIGHT_WEAPON[p.name]) out.enl = ENLIGHT_WEAPON[p.name];
  if (ENMITY_LOSS_GEAR[p.name]) out.lossRed = ENMITY_LOSS_GEAR[p.name];
  if (v('skill:shield skill')) out.shield = v('skill:shield skill');
  if (v('block')) out.block = v('block');
  const sr = v('x:resistance to all status ailments') + v('x:all status ailment resistance');
  if (sr) out.statusRes = sr;
  const er = ['fire', 'ice', 'wind', 'earth', 'lightning', 'water', 'light', 'dark'].reduce((n, e) => { if (v('res_' + e)) out['res_' + e] = v('res_' + e); return n + v('res_' + e); }, 0);
  if (er) out.eleRes = er;
  for (const k of ['hp', 'hp%', 'def', 'vit', 'mnd', 'cure2', 'dt', 'pdt', 'mdt', 'pdt2', 'mdt2', 'bdt', 'enmity', 'phalanx', 'sird', 'fc', 'meva', 'mdb', 'ecrit', 'cure', 'cmp', 'refresh', 'regen', 'enhdur', 'move'])
    if (v(k)) out[k] = v(k);
  if (v('skill:enhancing magic skill') + all) out.enh = v('skill:enhancing magic skill') + all;
  // Enhancing magic (opt.js O.enhancingFigures). The duration's two kinds multiply: what the description gives
  // (Ammurapi Shield, Embla Sash, Atrophy Gloves, Sucellos's Cape...) and what the augments add (Telchine, Colada,
  // Ghostfyre Cape, a Duelist's Torque's rank): r.base and r.aug, as measured in game on 2026-10-14
  const base = k => r.base[k] ? r.base[k].v || 0 : 0, aug = k => r.aug[k] ? r.aug[k].v || 0 : 0;
  if (base('enhdur')) out.enhdurL = base('enhdur');
  if (aug('enhdur')) out.enhdurA = aug('enhdur');
  // the Lethargy set ("Set: Augments "Composure""): its count gives Composure its length on the others
  if (r.cond.some(c => /^Set: Augments "Composure"/i.test(c))) out.leth = 1;
  if (v('x:refresh potency')) out.refpot = v('x:refresh potency');
  if (v('x:duration of refresh effects received')) out.refsec = v('x:duration of refresh effects received');
  // Regen potency: a % in a description (Bolelabunga +10 %), a flat amount in an augment (Telchine +3)
  if (base('x:regen potency')) out.regenpct = base('x:regen potency');
  if (aug('x:regen potency')) out.regenflat = aug('x:regen potency');
  if (v('x:regen effect duration')) out.regensec = v('x:regen effect duration');
  if (v('x:gain magic effect')) out.gain = v('x:gain magic effect');
  if (v('x:aquaveil')) out.aquaveil = v('x:aquaveil');
  // Perpetuance's figure with the Bracers (enh_jobs.js enhPerpOf)
  if (enhPerpOf(p.name)) out.perp = enhPerpOf(p.name);
  return out;
}
// s: the set the piece is weighed in (a city's set counts the movement speed of that city: CITY_MOVE)
function withVec(p, slot, s){
  if (!p) return p;
  const q = Object.assign({}, p, {st: statVec(p, slot)}), city = cityMove(p, s), ja = abilityName(s);
  if (city > (q.st.move || 0)) q.st = Object.assign({}, q.st, {move: city});
  if (ja && boostsAbility(p, slot, ja)) q.st = Object.assign({}, q.st, {ja: 1});
  if (slot === 'sub') { const it = itemOf(p.name); if (it && it.Type === 'Shield') q.shield = true; }
  return q;
}
function withVecs(pieces, s){
  const out = {};
  for (const [slot, p] of Object.entries(pieces || {})) out[slot] = withVec(p, slot, s);
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
  // the enemy's critical hits the gear can still take off: 10 % to the 1 % floor, less the merits
  const ecritRoom = Math.max(0, 9 - ((c.merits || {}).enemy_critical_hit_rate || 0));
  // the job points added to a Cure's base (opt.js O.cure): a PLD's gift Cure Potency Bonus (BG Wiki Paladin: 50 more,
  // from 1200 job points spent); a mastered WHM's 23, 63 in a set worn under Afflatus Solace (BG Wiki Cure_Formula)
  const whmJp = S.job === 'WHM' && (c.jp_spent || 0) >= 2100 ? (s && /solace/i.test(setNames(s)) ? 63 : 23) : 0;
  const cureJp = S.job === 'PLD' && (c.jp_spent || 0) >= 1200 ? 50 : whmJp;
  // the Cure the figures are for: the highest the job or its subjob casts (cureSpellOf)
  const cure = cureSpellOf();
  // a tank (PLD, RUN): Crusade's Enmity +30 counted, on or not (the guide: "essentially always up", 5 min, refreshed in
  // the rotation), in the equipment Enmity capped at +200
  const crusade = ['PLD', 'RUN'].includes(S.job) && !jaOn(buffState(), 'Crusade') ? CRUSADE_ENMITY : 0;
  return {ecritRoom, cureJp, cureTier: cure.tier, cureSpell: cure.name, geoSkill: S.job === 'GEO' && c.skills ? skillLevel(c, 'geomancy') + skillLevel(c, 'handbell') : 0, div: c.skills ? skillLevel(c, 'divine magic') : 0, preHp: pre, mnd: cur.mnd || 0, vit: cur.vit || 0, chr: cur.chr || 0, heal: c.skills ? skillLevel(c, 'healing magic') : 0, cure2: Math.max(B.cure2 || 0, S.job === 'PLD' ? 25 : 0),
    hp: cur.hp || 0, def: cur.def || 0, enh: c.skills ? skillLevel(c, 'enhancing magic') : 0, enmity: (B.enmity || 0) + crusade, enmityJa: B.enmityJa || 0, sird: 2 * ((c.merits || {}).spell_interruption_rate || 0),
    shell: B.shell || 0, mdb: (B.mdb || 0) + (r ? traitOf('mdb', c) + giftOf('mdb', c) : 0), meva: 0,
    // the Fast Cast the job gives before any piece (a Red Mage's trait and gifts, main job or subjob)
    fc: traitOf('fc', c) + fastCastGift(c),
    // the Conserve MP of the job's trait (main job or subjob: engine.js TRAITS)
    cmp: traitOf('cmp', c),
    shieldBarrier: S.job === 'PLD' && !!PROTECT[b.protect] && !b.protectOther, shieldMul: protectGift()};
}
// (an enhancing set's spell, target and base length ride with the character: opt.js O.enhancingFigures)
function statContext(s){
  const base = statBase(s), enh = enhContext(s);
  const enf = enfBase(s);
  if (enf) Object.assign(base, enf);
  const ed = edBase(s);
  if (ed) Object.assign(base, ed);
  const pet = petBase(s);
  if (pet) Object.assign(base, pet);
  if (enh) Object.assign(base, {enhKind: enh.kind, comp: enh.comp, enhBase: enh.base, refBase: enh.refBase, regenBase: enh.regenBase, temperCap: enh.temperCap, enGifts: enh.enGifts,
    barAdd: enh.barAdd, durMul: enh.durMul, potMul: enh.potMul, perp: enh.perp,
    // Bar-status: +30 on oneself, +20 for the -ra (BG Wiki Category:Barspell); a WHM's set is for the -ra it casts on
    // the party (the player's guide §4.6)
    barailBase: enh.kind === 'barail' ? (S.job === 'WHM' || /ra$/i.test(enh.spell) ? 20 : 30) : 0}, enh.skill != null ? {enh: enh.skill} : {});
  base.castKinds = castKindsOf(s);
  return {mode: 'stats', job: S.job, stat: {base}};
}

/* ---- the search ---- */
// An enhancing spell's potency goes up by steps of skill (a Temper's 1 % every 10 points): from a set a step short, no
// single piece gets there, and each one tried costs length, so the search stopped under what the gear can give (Temper
// 34 % with 36 % within reach, 2026-10-14). The potency is searched first, with the skill after it to climb between two
// steps; the real search then starts from that set and keeps that potency as a floor while it looks for the rest
// (the longest spell). Only when the potency comes first and something follows it.
const ENH_STEPPED = new Set(['temper', 'enspell', 'gainPot', 'barEle', 'aquaveil', 'phalanx', 'stoneskin']);
function enhPotencyFirst(s, input, so){
  const e = enhContext(s);
  if (!e || tankPhalanx(s, e) || !ENH_STEPPED.has(so.objs[0]) || so.objs.length < 2 || input.prefilter) return;
  let top;
  try { top = FFXI.opt.run(Object.assign({}, input, {opts: Object.assign({}, input.opts, {then: ['enhSkill']})})); } catch (e) { return; }
  const reached = top && top.pieces && FFXI.opt.statFigures(input.ctx.stat, top.pieces)[so.objs[0]];
  if (reached == null) return;
  // the set as it is already gives that much: the search starts from it (from the other one it lost a little of
  // what comes after the potency, with nothing to gain); else from the pre-search's set (seed), the result still
  // compared with the set as it is (input.start)
  const has = FFXI.opt.statFigures(input.ctx.stat, input.start)[so.objs[0]];
  if (has == null || reached > has) input.seed = top.pieces;
  input.opts = Object.assign({}, input.opts, {floor: Object.assign({}, input.opts.floor, {min: {[so.objs[0]]: reached}})});
}
async function optimizeStats(s){
  if (!engineReady() || !statSet(s)) return;
  const k = trialKey(s), o = Object.assign({}, S.optOpts), so = statOpts(s), base = lockedBase(s, withoutTrial(() => withWeapons(s).pieces));
  const choices = optChoices(new Set(Object.keys(ONLY_AUGS)));
  for (const slot of keptSlots(s)) delete choices[slot];
  lockChoices(s, choices);
  for (const slot of Object.keys(choices)) choices[slot] = choices[slot].map(p => withVec(p, slot, s));
  // (never a BST's Charm set's: a weapon change loses the TP, the guide's set has none)
  // (sets.EnmityMax: its weapons always searched, the main hand included: enmityMaxSet)
  if ((o.freeWeapons || enmityMaxSet(s)) && !isCharmSet(s) && !keptSlots(s).some(x => x === 'main' || x === 'sub')) choices.weapons = weaponPairs(base).map(x => ({main: withVec(x.main, 'main'), sub: x.sub ? withVec(x.sub, 'sub') : null}));
  // a movement set (and the Doom set) starts empty but for its locked slots (bareSet): its other pieces go, left to
  // the set under it
  const move = bareSet(s);
  let from = move ? Object.fromEntries(lockedSlots(s).filter(x => base[x]).map(x => [x, base[x]])) : base;
  // a job ability's set on sets.precast.JA (jaOverlayBase): from the base's pieces, only the ones that boost the
  // ability tried; a slot with none keeps the base's piece (pushed as `inherit`: push.js pushPlan)
  const over = jaOverlayBase(s);
  if (over) {
    const ja = abilityName(s), mine = withoutTrial(() => withWeapons(s).pieces);
    from = Object.assign({}, withoutTrial(() => withWeapons(over).pieces));
    for (const slot of keptSlots(s)) from[slot] = mine[slot];
    for (const slot of Object.keys(choices)) {
      if (slot === 'weapons') { delete choices[slot]; continue; }
      choices[slot] = choices[slot].filter(p => boostsAbility(p, slot, ja));
      if (!choices[slot].length) delete choices[slot];
    }
  }
  const start = withVecs(startOf(from, lockedSlots(s)), s);
  const input = {ctx: statContext(s), start, choices, prefilter: o.where === 'all' ? 25 : 0,
    opts: {fast: (o.search || 'fast') !== 'classic', objective: so.objs[0], then: so.objs.slice(1), floor: so.floor, bare: move}};
  // a healer's Cure set: the least enmity parts what the chosen objectives leave tied (a Kaykaus path that gives none
  // of them: its Enmity-6 path rather than any other)
  if (healerCure(s) && !so.objs.some(k => k === 'enmity' || k === 'enmityLow')) input.opts.then = input.opts.then.concat('enmityLow');
  // a BST's Charm set: Charm+ given back for 2 % of CHR and Magic Accuracy at most, on its default objectives (bst_pet.js)
  if (isCharmSet(s) && so.objs[0] === 'chr') input.opts.tolGain = CHARM_TOL;
  if (doomSet(s) && so.objs[0] === 'holyWater') input.opts.tolGain = DOOM_TOL;
  enhPotencyFirst(s, input, so);
  optLaunch(s, k, input, Object.assign({}, o, {stat: so.objs[0], statFloor: so.floor, clearRest: move}));
}

/* ---- the page (atelier/src/screens/optimizer/statpage.ts): the result's lines ---- */
// The result's lines: the objectives first, then every figure, the floors marked
function statRows(s){
  const so = statOpts(s), fl = so.floor, on = k => +fl[k];
  const rows = STAT_OBJS.map(k => ({id: k, label: t('statObj_' + k), get: f => f[k], fmt: statFmt(k)}));
  const lim = {hp: v => (!on('hp') || v >= fl.hp) && (!on('hpMax') || v <= fl.hpMax), sird: v => !on('sird') || v >= fl.sird, fc: v => !on('fc') || v >= fl.fc,
    ecritRed: v => !on('ecrit') || -v <= fl.ecrit, enmity: v => !on('enmity') || v >= fl.enmity, phalanx: v => !on('phalanx') || v >= fl.phalanx,
    ceLoss: v => !on('ceLoss') || v >= fl.ceLoss, luDt: v => !on('luDt') || v >= fl.luDt};
  // (r.on: a floor given a value, the line kept in the short result beside the set: statpage.ts)
  const onOf = {hp: ['hp', 'hpMax'], sird: ['sird'], fc: ['fc'], ecritRed: ['ecrit'], enmity: ['enmity'], phalanx: ['phalanx'], ceLoss: ['ceLoss'], luDt: ['luDt']};
  for (const r of rows) if (lim[r.id]) { r.floor = lim[r.id]; r.on = onOf[r.id].some(on); }
  rows.push({id: 'pdt', label: on('pdt') ? `DT+PDT ≤ ${fl.pdt}` : 'DT+PDT', get: f => f.pdt, fmt: v => String(Math.round(v)), low: true, floor: on('pdt') ? v => v <= fl.pdt : null, on: !!on('pdt')},
    {id: 'mdt', label: on('mdt') ? `DT+MDT ≤ ${fl.mdt}` : 'DT+MDT', get: f => f.mdt, fmt: v => String(Math.round(v)), low: true, floor: on('mdt') ? v => v <= fl.mdt : null, on: !!on('mdt')});
  // the enmity each action of the set makes with it (its Enmity counted, cap x3)
  for (const n of setActions(s).slice(0, 4)) { const [ve, ce] = ACTION_ENMITY[n];
    rows.push({id: 'act:' + n, label: t('statAct', {a: n}), get: f => ve * (1 + f.enmity / 100), fmt: v => `${Math.round(v)} VE · ${Math.round(v * ce / ve)} CE`,
      tip: t('statActTip', {a: n, ve, ce})}); }
  // (the gap to the Fast Cast only on a set held to the HP band: not on one laid over another, sets.Adoulin)
  const pair = cureGap(s), ref = pair || !(on('hp') || on('hpMax')) ? null : hpRef(s);
  if (pair && family(s.path, s.pieces) !== 'fc') rows.push({id: 'cure4', label: t('statCure4'), get: f => f.cureIV, fmt: v => String(Math.round(v)), tip: t('statCure4Tip')});
  if (ref) rows.push({id: 'ref', label: t('statRef'), get: f => f.hp - ref.hp, fmt: v => (v > 0 ? '+' : '') + Math.round(v), tip: t('statRefTip', {f: shortPath(ref.path), h: ref.hp}),
    floor: v => v <= 0 && v >= -HP_SPREAD});
  rows.push(...enfRows(s));
  if (pair) rows.push({id: 'gap', label: t('statGap'), get: f => pair.gap(f), fmt: v => String(Math.round(v)), tip: t('statGapTip', {m: shortPath(pair.mid), f: shortPath(pair.pre)})});
  const first = so.objs.map(k => rows.find(r => r.id === k)).filter(Boolean);
  // the gap (and the Cure's power) right under the objectives: it is what the pair of sets is for; Lowest HP only as an objective
  const near = rows.filter(r => (['gap', 'ref', 'cure4'].includes(r.id) || r.id.startsWith('act:') || r.id.startsWith('enf:')) && !first.includes(r));
  // (the least enmity is the Enmity row again: shown only as an objective)
  const rest = rows.filter(r => !first.includes(r) && !near.includes(r) && r.id !== 'hpLow' && r.id !== 'enmityLow' && (r.id !== 'move' || moveSet(s)) && (!['holyWater', 'cursnaRecv'].includes(r.id) || doomSet(s)));
  return first.concat(near, rest);
}
// The toast once a search is done
function statDoneText(s, res, tr){
  const objs = statOpts(s).objs, k = objs[0], f = statFmt(k), def = res.best.def || {}, label = t('statObj_' + k);
  // the next objective too: it is what parts the sets as good on the first (Fast Cast capped: the lowest HP)
  const k2 = objs[1], now = k2 && statFigures(s), was = k2 && Object.keys(tr).length ? statFigures(s, true) : null;
  const then = !k2 || !now ? '' : ` ${t('statThenShort')} ${t('statObj_' + k2)} ${statFmt(k2)(now[k2])}` +
    (was && was[k2] !== now[k2] ? ` (${statFmt(k2)(was[k2])})` : '');
  // (a movement set's search starts empty: the figure before is the set's as it is)
  const before = bareSet(s) ? statFigures(s, true)[k] : res.start.raw;
  return Object.keys(tr).length ? t('statDone', {o: label, a: f(before), b: f(res.best.raw) + then, n: Object.keys(tr).length, p: Math.round(def.pdt || 0), m: Math.round(def.mdt || 0)})
    : t('statSame', {o: label, v: f(res.best.raw) + then});
}
