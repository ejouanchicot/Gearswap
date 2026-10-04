// GearSwap Atelier · buffs.js: the buffs' tables, the support profiles, what follows the set opened
// (cut from atelier.html, loaded by it in order: see the list there)
/* ---- buffs and conditions (atelier-engine/buffs.js and its catalogue, Guide_Paladin 01_prologue, 03_magic, 03_job_ability) ---- */
// Foods: flat stats; atkf = Attack added after the Attack % (the engine's "Food Attack"); a [%, cap] pair is a % of the stat with its cap
const FOODS = {
  'Grape Daifuku +1': {str: 3, vit: 4, atkf: 55, acc: 85, mab: 4}, 'Grape Daifuku': {str: 2, vit: 3, atkf: 50, acc: 80, mab: 3},
  'Sublime Sushi +1': {str: 7, dex: 8, mnd: -4, chr: 7, acc: 105}, 'Sublime Sushi': {str: 6, dex: 7, mnd: -3, chr: 6, acc: 100},
  'Red Curry Bun +1': {str: 7, agi: 1, int: -2, atkf: 150}, 'Red Curry Bun': {str: 7, agi: 1, int: -2, atkf: 150},
  'Om. Sandwich +1': {acc: 85, vit: 8, mnd: 8}, 'Om. Sandwich': {acc: 80, vit: 7, mnd: 7},
  'Gyudon +1': {da: 6, wsd: 6}, 'Gyudon': {da: 5, wsd: 5}, 'Marine Stewpot': {acc: 90, macc: 90},
  'Crepe des rois': {macc: 95, int: 2, mnd: 2, mdb: 1}, 'Tropical Crepe': {macc: 90, int: 2, mnd: 2, mdb: 1},
  "Altana's Repast": {str: 10, dex: 10, vit: 10, agi: 10, int: 10, mnd: 10, chr: 10, stp: 6, acc: 70, macc: 70, eva: 70, meva: 70, atkf: 70, mdb: 3, mab: 10},
  'Miso Ramen +1': {hp: 105, deff: [11, 175], mdb: 6, mevaf: [11, 55]}, 'Miso Ramen': {hp: 100, deff: [10, 170], mdb: 5, mevaf: [10, 50]},
};
// Songs: stat -> [base, per Songs+], up to the song's own Songs+ limit; Magic Haste in %
const SONGS = {
  'Honor March': {lim: 4, mhaste: [12.305, 1.172], atk: [168, 16], acc: [42, 4]}, 'Victory March': {lim: 8, mhaste: [15.918, 1.587]},
  'Advancing March': {lim: 8, mhaste: [10.547, 1.05]}, 'Minuet V': {lim: 8, atk: [149, 12.375]}, 'Minuet IV': {lim: 8, atk: [137, 11.2]},
  'Minuet III': {lim: 8, atk: [121, 9.5]}, 'Blade Madrigal': {lim: 9, acc: [60, 6]}, 'Sword Madrigal': {lim: 9, acc: [45, 4.5]},
  'Aria of Passion': {lim: 7, pdl: [13, 1.3]},
  'Herculean Etude': {lim: 9, str: [15, 1]}, 'Uncanny Etude': {lim: 9, dex: [15, 1]}, 'Vital Etude': {lim: 9, vit: [15, 1]},
  'Swift Etude': {lim: 9, agi: [15, 1]}, 'Sage Etude': {lim: 9, int: [15, 1]}, 'Logical Etude': {lim: 9, mnd: [15, 1]}, 'Bewitching Etude': {lim: 9, chr: [15, 1]},
};
// Rolls: the value of each number I..XI, then per Rolls+ (Attack % as a fraction)
const ROLLS = {
  'Chaos': {atkp: [[.0625, .0781, .0937, .25, .1093, .125, .1562, .0312, .1718, .1875, .3125], 32 / 1024]},
  "Samurai": {stp: [[8, 32, 10, 12, 14, 4, 16, 20, 22, 24, 40], 4]}, "Fighter's": {da: [[1, 2, 3, 4, 10, 5, 6, 6, 1, 7, 15], 1]},
  "Rogue's": {crit: [[1, 2, 3, 4, 10, 5, 6, 7, 1, 8, 14], 1]}, "Hunter's": {acc: [[10, 13, 15, 40, 18, 20, 25, 5, 28, 30, 50], 5]},
  "Wizard's": {mab: [[4, 6, 8, 10, 25, 12, 14, 17, 2, 20, 30], 2]}, "Warlock's": {macc: [[10, 13, 15, 40, 18, 20, 25, 5, 28, 30, 50], 5]},
  "Monk's": {sb: [[8, 10, 32, 12, 14, 16, 4, 20, 22, 24, 40], 4]}, "Tactician's": {regain: [[10, 10, 10, 10, 30, 10, 10, 0, 20, 20, 40], 2]},
};
const ROMAN = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', 'XI'];
// A roll's bonus when its job is in the party (you count), as the engine has it (atelier-engine/buffs.js, BG Wiki for
// Chaos, Samurai, Fighter's, Rogue's, Hunter's); Crooked Cards: the roll x1.2, after Rolls+ and the job bonus (BG Wiki)
const ROLL_JOB = {'Chaos': ['DRK', 100 / 1024], 'Samurai': ['SAM', 10], "Fighter's": ['WAR', 5], "Rogue's": ['THF', 5], "Hunter's": ['RNG', 15],
  "Wizard's": ['BLM', 10], "Warlock's": ['RDM', 15], "Monk's": ['MNK', 10], "Tactician's": ['SCH', 10]};
// whether roll i gets its job bonus: ticked, or the roll's job is yours
const rollJobOn = (b, i) => { const rj = ROLL_JOB[b['roll' + i]]; return !!rj && (!!b['roll' + i + 'job'] || rj[0] === S.job); };
// Geomancy bubbles: [base, per Geomancy+]; the same bubble twice (Indi and Geo) counts once
const BUBBLES = {
  'Fury': {atkp: [.347, .027]}, 'Haste': {mhaste: [29.9, 1.1]}, 'Precision': {acc: [50, 5]}, 'Focus': {macc: [50, 5]}, 'Acumen': {mab: [15, 3]},
  'STR': {str: [25, 2]}, 'DEX': {dex: [25, 2]}, 'VIT': {vit: [25, 2]}, 'AGI': {agi: [25, 2]}, 'INT': {int: [25, 2]}, 'MND': {mnd: [25, 2]}, 'CHR': {chr: [25, 2]},
};
// Geomancy on the enemy (atelier-engine/buffs.js geo_debuffs: [base, + per Geomancy+]): e* = the enemy's stat
// (edefp a fraction of its Defense, eeva its Evasion, emdb its Magic Defense Bonus, emeva its Magic Evasion)
// A GEO's abilities on its bubbles (BG Wiki), Geomancy+ included: Bolster doubles Indi- and Geo- (not an
// Entrust) and leaves Blaze of Glory and Ecliptic Attrition out; without it, Blaze of Glory +50 % and Ecliptic
// Attrition +25 % on the luopan (Geo-), added together
// b.geoScale: a bubble weaker than a player's (a trust's: TRUST_BUFFS), {indi, geo, entrust} multipliers
function geoMul(b){
  const foe = geoKeep(enemyKey(b.enemy)), sc = b.geoScale || {}, x = k => sc[k] == null ? 1 : +sc[k];
  if (b.bolster) return {indi: 2 * x('indi'), geo: 2 * x('geo'), entrust: x('entrust'), foe};
  return {indi: x('indi'), geo: (1 + (b.bog ? .5 : 0) + (b.ecliptic ? .25 : 0)) * x('geo'), entrust: x('entrust'), foe};
}
// What is left of an offensive bubble (Frailty, Torpor, Malaise, Languor) on the target: NMs resist it.
// Sortie NMs -50 %, Odyssey Sheol Gaol bosses -85 % (BG Wiki Category:Sortie and Category:Odyssey; a test at
// V15 found -75 %); a monster takes it whole
const geoKeep = key => { const z = (TARGETS[key] || {}).zone || ''; return /^Sortie/.test(z) ? .5 : /Odyssey/.test(z) ? .15 : 1; };
const GEO_DEBUFFS = {'Frailty': {edefp: [.148, .027]}, 'Torpor': {eeva: [50, 5]}, 'Malaise': {emdb: [15, 3]}, 'Languor': {emeva: [50, 5]}};
// The other jobs' Defense down on the enemy (atelier-engine/buffs.js whm_debuffs, cor_debuffs)
const DIA = {'Dia': 104 / 1024, 'Dia II': 156 / 1024, 'Dia III': 208 / 1024};
// Distract's Evasion down at its cap (BG Wiki: a RDM at full enfeebling skill and +50 MND over the target),
// Saboteur's multiplier: x2 on a monster, x1.25 on an NM (a Sortie or Odyssey boss), Lethargy Gantherots +3
// +14 % (x2.14 / x1.39). the engine's Distract III is 280: 130 x 2.14
const DISTRACT = {'Distract': 35, 'Distract II': 50, 'Distract III': 130};
const isNmTarget = key => /Sortie|Odyssey/.test((TARGETS[key] || {}).zone || '');
function distractEva(b){
  const base = DISTRACT[b.distract];
  if (!base) return 0;
  if (!b.saboteur) return base;
  const nm = isNmTarget(enemyKey(b.enemy));
  return Math.floor(base * (nm ? (b.sabGloves ? 1.39 : 1.25) : (b.sabGloves ? 2.14 : 2)));
}
const LIGHT_SHOT = 28 / 1024;
// Bio and Bio II (BLM, RDM, DRK), Bio III (RDM): the target's Attack down (BG Wiki), nothing on your damage; Bio and
// Dia overwrite each other, so a Bio takes Dia's Defense down off
const BIO = {'Bio': 104 / 1024, 'Bio II': 156 / 1024, 'Bio III': 208 / 1024};
// Which tab's switch a Dia or Bio goes with: its caster's
const DIA_OWNER = {'Dia': 'Dia', 'Dia II': 'Dia', 'Dia III': 'Distract', 'Bio': 'BLM', 'Bio II': 'BLM', 'Bio III': 'Distract'};
// The debuffs a party puts on the target, a tab a job (BG Wiki's Defense / Evasion / Magic Defense Down tables), each
// with what it takes off: edefp a share of its Defense, eeva its Evasion, emdb / emeva its Magic Defense / Evasion,
// eatkp its Attack (shown only), eres its resistance to a damage type. stacks: adds up with the others; evd: an Evasion
// Down (one counts, it or Distract); without either a Defense Down (one counts) — foeCounted() applies the rules.
// Tomahawk cuts a resistance by a quarter (50 % -> 37 %), nothing on a target that does not resist the weaponskill's
// type; Corrosive Ooze is -33 % from a Slug, -5 % as blue magic
const FOE_JA = {
  WAR: {'Armor Break': {edefp: .25}, 'Tomahawk': {eres: .25, stacks: true}},
  THF: {'Feint': {eeva: 150, evd: true}},
  // BLM (BG Wiki): the elemental debuffs take 13 of a stat at 150+ INT, +2 a merit (-23 at 5/5), -30 more with
  // Archmage's Sabots +3 (-63); Impact takes 20 % of each of the target's base stats
  BLM: {'Burn': {elem: 'INT'}, 'Frost': {elem: 'AGI'}, 'Choke': {elem: 'VIT'}, 'Rasp': {elem: 'DEX'}, 'Shock': {elem: 'MND'}, 'Drown': {elem: 'STR'},
    'Impact': {impact: .2, stacks: true, excl: 'Impact'}},
  // WHM / PLD's Banish II on an undead (BG Wiki): its damage resistance cut by 70 % (50 % -> 15 %), 30 s; shown in
  // the WHM tab with Dia, the stronger of it and Tomahawk counts
  WHM: {'Banish II': {eresu: .7, stacks: true}},
  // COR's Quick Draw (BG Wiki): an element's shot strengthens that element's debuff on the target, its stat -4 a first
  // shot, -6 after a second (cap); Dark Shot a Bio's Attack down +2.73 % (28/1024). Shown in the COR tab, Light Shot's
  COR: {'Fire Shot': {shot: 'Burn', stacks: true}, 'Ice Shot': {shot: 'Frost', stacks: true}, 'Wind Shot': {shot: 'Choke', stacks: true},
    'Earth Shot': {shot: 'Rasp', stacks: true}, 'Thunder Shot': {shot: 'Shock', stacks: true}, 'Water Shot': {shot: 'Drown', stacks: true},
    'Dark Shot': {darkShot: 28 / 1024, stacks: true}},
  // RUN (BG Wiki), with the runes chosen in its tab: Gambit, damage taken of the runes' element +10 % a rune
  // (Rayke, a resistance rank lower a rune, is only a note in the tab: the targets' elemental ranks are unknown)
  RUN: {'Gambit': {gambit: 10, stacks: true}},
  // BRD: Carnage Elegy (Slow -50 %) and Foe Requiem VII (8 HP a tick) shown, nothing on your damage (Threnody II is a
  // note in the tab: a Magic Evasion down)
  BRD: {'Carnage Elegy': {eslow: .5, stacks: true}, 'Foe Requiem VII': {edot: 8, stacks: true}},
  // SMN blood pacts (BG Wiki): Shiva's Diamond Storm Evasion -25 and Fenrir's Lunar Cry -31 at a new moon (16 at half
  // moon), Evasion Downs as Distract and Feint are; Ifrit's Conflag Strike a Burn of INT -63 (the BLM's Burn, the same
  // effect); Leviathan's Tidal Roar the target's Attack -25 %, nothing on your damage
  // Fenrir's Impact (BG Wiki Impact (Blood Pact)): every attribute -floor(Summoning skill / 20), the skill chosen in
  // the tab; it and the spell Impact are both "Impact", one at a time
  SMN: {'Diamond Storm': {eeva: 25, evd: true}, 'Lunar Cry': {eeva: 31, evd: true}, 'Conflag Strike': {elem: 'INT', fixed: 63, as: 'Burn'},
    'Tidal Roar': {eatkp: .25, stacks: true}, 'Impact (Fenrir)': {smnImpact: true, stacks: true, excl: 'Impact'}},
  // NIN: Aisha: Ichi Attack -15 %, shown (the elemental ninjutsu's resistance -30 is a note in the tab)
  NIN: {'Aisha: Ichi': {eatkp: .15, stacks: true}},
  SAM: {'Tachi: Ageha': {edefp: .25}},
  // DRG: Angon, and Jump under Spirit Surge (BG Wiki Spirit Surge: Defense -20 %, 60 s), both Defense Downs
  DRG: {'Angon': {edefp: .2}, 'Jump (Spirit Surge)': {edefp: .2}},
  // PUP automaton (BG Wiki): Sharpshot's Armor Shatterer Defense -15 %, Harlequin / Stormwaker's Knockout Evasion -50
  PUP: {'Armor Shatterer': {edefp: .15}, 'Knockout': {eeva: 50, evd: true}},
  // DNC steps at 10 levels (a DNC main): Box Step (Sluggish Daze) -23 % as the engine has it, Quickstep
  // (Lethargic Daze) (10 + 1) x 4, Feather Step crit +1 % a level (Stutter Step, a Magic Evasion down, is a note); sub,
  // 5 levels from a /DNC (b.dncSub; Box Step -13 %, the engine again)
  DNC: {'Box Step': {edefp: .23, stacks: true, sub: {edefp: .13}}, 'Quickstep': {eeva: 44, stacks: true, sub: {eeva: 24}},
    'Feather Step': {ecrit: 10, stacks: true, sub: {ecrit: 5}}},
  // BLU (BG Wiki Defense / Evasion / Magic Defense Down): Tourbillion about -33 %, Frightful Roar and Benthic Typhoon
  // -10 % (26/256), Enervation -10 % with Magic Defense -8, Acrid Stream Magic Defense -10, Tearing Gust about -30
  // (Unbridled), Infrasonics Evasion -20
  BLU: {'Bilgestorm': {edefp: .25}, 'Tenebral Crush': {edefp: .2}, 'Sweeping Gouge': {edefp: .15}, 'Corrosive Ooze': {edefp: .05},
    'Tourbillion': {edefp: .33}, 'Frightful Roar': {edefp: .1}, 'Benthic Typhoon': {edefp: .1, emdb: 10}, 'Enervation': {edefp: .1, emdb: 8},
    'Acrid Stream': {emdb: 10}, 'Tearing Gust': {emdb: 30}, 'Infrasonics': {eeva: 20, evd: true}, 'Seedspray': {edefp: .08}},
  // BST jug pets: Horn Beetle's Rhinowrecker and Raaz's Sweeping Gouge Defense -25 %, Lizard's Infrasonics and
  // Beetle's Hi-Freq. Field Evasion -40, Acuex's Pestilent Plume Magic Defense -25
  BST: {'Slug: Corrosive Ooze': {edefp: .33}, 'Tulfaire: Swooping Frenzy': {edefp: .25, emdb: 25}, 'Adamantoise: Tortoise Stomp': {edefp: .25},
    'Horn Beetle: Rhinowrecker': {edefp: .25}, 'Raaz: Sweeping Gouge': {edefp: .25}, 'Lizard: Infrasonics': {eeva: 40, evd: true}, 'Beetle: Hi-Freq. Field': {eeva: 40, evd: true},
    'Acuex: Pestilent Plume': {emdb: 25}},
  // Weaponskills' additional effects, bolts and weapons, whoever lays them (BG Wiki Defense / Evasion / Magic Defense
  // Down tables): Defense Downs Shell Crusher -25 %, Metatron Torment -18.75 %, Full Break and Garland of Bliss
  // -12.5 %, Abrasion Bolt -20.5 %, Acid and Gashing Bolt -12.5 %, Gungnir -17.5 %, Nitric Baselard -18.75 %, Oxidant
  // Baselard -12.5 %; Evasion Downs Shield Break -40, Randgrith -32, Full Break -20, Pyrrhic Kleos -10; Vidohunir and
  // Shattersoul Magic Defense -10; Sniper Shot and Skullbreaker INT -10 (decaying; one INT Down, apart from Burn)
  WS: {'Shell Crusher': {edefp: .25}, 'Metatron Torment': {edefp: .1875}, 'Full Break': {edefp: .125, eeva: 20, evd: true, eatkp: .125},
    'Garland of Bliss': {edefp: .125}, 'Shield Break': {eeva: 40, evd: true}, 'Randgrith': {eeva: 32, evd: true}, 'Pyrrhic Kleos': {eeva: 10, evd: true},
    'Vidohunir': {emdb: 10}, 'Shattersoul': {emdb: 10}, 'Abrasion Bolt': {edefp: .205}, 'Acid Bolt': {edefp: .125}, 'Gashing Bolt': {edefp: .125},
    'Gungnir': {edefp: .175}, 'Nitric Baselard': {edefp: .1875}, 'Oxidant Baselard': {edefp: .125},
    'Sniper Shot': {eint: 10, intd: true}, 'Skullbreaker': {eint: 10, intd: true}},
};
const FOE_JA_FX = Object.assign({}, ...Object.values(FOE_JA));
// A debuff tab's switch key where the job's own is Party support's (BRD's songs)
const FOE_SW = {BRD: 'Threnody'};
// Elemental ascendancy (BG Wiki): each elemental debuff overwrites its neighbours on the wheel Burn > Frost > Choke >
// Rasp > Shock > Drown > Burn, so Burn / Choke / Shock and Frost / Rasp / Drown are the three that hold together
const ELEM_WHEEL = ['Burn', 'Frost', 'Choke', 'Rasp', 'Shock', 'Drown'];
// (Ifrit's Conflag Strike is a Burn: it and the BLM's Burn replace each other)
const elemClash = n => { const as = (FOE_JA_FX[n] || {}).as || n, i = ELEM_WHEEL.indexOf(as);
  if (i < 0) return [];
  const near = [ELEM_WHEEL[(i + 1) % 6], ELEM_WHEEL[(i + 5) % 6]];
  return [...near, as, ...Object.keys(FOE_JA_FX).filter(x => near.includes(FOE_JA_FX[x].as) || FOE_JA_FX[x].as === as)].filter(x => x !== n); };
const elemDown = b => b.sabots ? 63 : 23;
const smnSkill = b => +(b.smnSkill || 600);
// The runes and the element each one is (the damage Gambit raises, the resistance Rayke lowers)
const RUNES = {Ignis: 'Fire', Gelus: 'Ice', Flabra: 'Wind', Tellus: 'Earth', Sulpor: 'Thunder', Unda: 'Water', Lux: 'Light', Tenebrae: 'Dark'};
const runeOf = b => RUNES[b.rune] ? b.rune : 'Ignis', runeCount = b => +(b.runes || 3);
const STAT_KEYS = ['STR', 'DEX', 'VIT', 'AGI', 'INT', 'MND', 'CHR'];
// What one ability takes off the target, as numbers (e + the stat: estr, evit...; estatp: Impact's share)
function foeFx(n, b){
  const a = FOE_JA_FX[n] || {};
  if (a.elem) return {['e' + a.elem.toLowerCase()]: a.fixed || elemDown(b)};
  if (a.impact) return {estatp: a.impact};
  if (a.smnImpact) return {eallstat: Math.floor(smnSkill(b) / 20)};
  if (a.gambit) return {egambit: a.gambit * runeCount(b)};
  // a shot without its debuff on the target does nothing
  if (a.shot) return (b.foeJa || []).some(x => x === a.shot || (FOE_JA_FX[x] || {}).as === a.shot)
    ? {['e' + FOE_JA_FX[a.shot].elem.toLowerCase()]: b.corShots === '1' ? 4 : 6} : {};
  if (a.darkShot) return BIO[b.dia] ? {eatkp: a.darkShot} : {};
  return Object.fromEntries(Object.entries(a.sub && b.dncSub ? a.sub : a).filter(([k, v]) => typeof v === 'number'));
}
// What counts on the target, effect by effect (BG Wiki): one Defense Down (the strongest; Dia, Box Step and Frailty
// stack with it), one Evasion Down (the strongest of them and Distract; Quickstep stacks), one Magic Defense Down from
// weaponskills, blue magic and pets; the rest adds up. [{n, k, v}] counted, and Distract's place
function foeCounted(b){
  const on = (b.foeJa || []).filter(n => FOE_JA_FX[n]), all = [];
  for (const n of on) for (const [k, v] of Object.entries(foeFx(n, b))) {
    const a = FOE_JA_FX[n];
    all.push({n, k, v, fam: k === 'edefp' && !a.stacks ? 'dd' : k === 'eeva' && a.evd ? 'evd' : k === 'emdb' ? 'mdd' : a.intd ? 'intd' : ''});
  }
  const best = {};
  for (const e of all) if (e.fam && (!best[e.fam] || e.v > best[e.fam].v)) best[e.fam] = e;
  const distractWins = !best.evd || distractEva(b) >= best.evd.v;
  const list = all.filter(e => !e.fam || (best[e.fam] === e && !(e.fam === 'evd' && distractWins)));
  return {list, distractWins};
}
// The abilities with something counted
const foeJaActive = b => [...new Set(foeCounted(b).list.map(e => e.n))];
// The Evasion the target loses: the stronger Evasion Down (Distract or another), and Quickstep
function foeEva(b){
  const c = foeCounted(b);
  return (c.distractWins ? distractEva(b) : 0) + c.list.filter(e => e.k === 'eeva').reduce((m, e) => m + e.v, 0);
}
// The damage type of a skill's weaponskills (BG Wiki; a few weaponskills differ from their skill)
const SKILL_DMG = {Sword: 'slash', 'Great Sword': 'slash', Axe: 'slash', 'Great Axe': 'slash', Scythe: 'slash', Katana: 'slash',
  'Great Katana': 'slash', Dagger: 'pierce', Polearm: 'pierce', Club: 'blunt', Staff: 'blunt', 'Hand-to-Hand': 'blunt',
  Archery: 'ranged', Marksmanship: 'ranged'};
// The target's resistance to it, percent (+25 takes more, -25 resists), for the damage engine
const physResOf = (b, skill) => ((TARGETS[enemyKey(b.enemy)] || {}).res || {})[SKILL_DMG[skill]] || 0;
// What those take off, for the damage engine (it counts Dia, Light Shot and the bubbles itself)
function foeJaDown(b){
  const out = {def: 0, mdb: 0, crit: 0, stats: {}}, x = TARGETS[enemyKey(b.enemy)] || {};
  for (const {k, v} of foeCounted(b).list) {
    if (k === 'egambit') out.gambit = {elem: RUNES[runeOf(b)], pct: v};
    if (k === 'edefp') out.def += v; if (k === 'emdb') out.mdb += v; if (k === 'ecrit') out.crit += v;
    for (const st of STAT_KEYS) { const d = (k === 'e' + st.toLowerCase() || k === 'eallstat' ? v : 0) + (k === 'estatp' ? Math.floor(v * (x[st.toLowerCase()] || 0)) : 0);
      if (d) out.stats[st] = (out.stats[st] || 0) + d; } }
  return out;
}
// WHM's Auspice (level 55: main, or a subjob with enough Master Levels): the party's Subtle Blow +10, more with the
// caster's feet (BG Wiki); it counts toward Subtle Blow I's cap. It and a tier I Enspell overwrite each other
const AUSPICE_SB = 10, AUSPICE_FEET = {'Orison Duckbills +1': 5, 'Orison Duckbills +2': 10, 'Ebers Duckbills': 13, 'Ebers Duckbills +1': 15,
  'Ebers Duckbills +2': 17, 'Ebers Duckbills +3': 19};
const auspiceSb = b => b.auspice ? AUSPICE_SB + (AUSPICE_FEET[b.auspiceFeet] || 0) : 0;
const enSkill = b => +(b.enSkill || 600);
const enspellDmg = k => k < 600 ? Math.trunc((k - 223) / 7.70) + 29 : Math.trunc((k - 202.5) / 8.05) + 29;
const PROTECT = {'Protect': 20, 'Protect II': 50, 'Protect III': 90, 'Protect IV': 140, 'Protect V': 220};
const SHELL = {'Shell': 27, 'Shell II': 42, 'Shell III': 56, 'Shell IV': 67, 'Shell V': 75};
// Haste spells and Garuda's blood pacts (BG Wiki: Hastega 153/1024, Hastega II 307/1024): one Haste effect, one at a time
const HASTE = {'Haste': 14.648, 'Haste II': 29.98, 'Hastega': 14.941, 'Hastega II': 29.98};
const STORMS = {'Firestorm II': {str: 7}, 'Thunderstorm II': {dex: 7}, 'Sandstorm II': {vit: 7}, 'Windstorm II': {agi: 7}, 'Hailstorm II': {int: 7},
  'Rainstorm II': {mnd: 7}, 'Aurorastorm II': {chr: 7}, 'Voidstorm II': {str: 3, dex: 3, vit: 3, agi: 3, int: 3, mnd: 3, chr: 3}};
// Job abilities and spells on oneself: the job that has it, whether a subjob has it too, what it gives
// (main: the effect as main job). party: a buff a party member gives, always offered
const JAS = {
  // lvl: the level the job learns it (BG Wiki); a subjob has it at its own level (49, +1 per 5 Master
  // Levels). fx(main, level): main = used as main job. Values: atelier-engine/player.js
  'Berserk': {job: 'WAR', lvl: 15, fx: (m, l) => ({atkp: m ? 89 / 256 : l >= 50 ? 69 / 256 : .25, atk: m ? 40 : 0, defp: -.25})},
  'Defender': {job: 'WAR', lvl: 25, fx: () => ({defp: .25, atkp: -.25})},
  // Warcry's TP Bonus (Savagery merits, Agoge) comes from the job's TP config, for the TP steps
  'Warcry': {job: 'WAR', lvl: 35, tp: true, excl: 'warcry', fx: (m, l) => ({atkp: Math.trunc(l / 4 + 4.75) / 256, atk: m ? 60 : 0})},
  'Aggressor': {job: 'WAR', lvl: 45, fx: m => ({acc: 25 + (m ? 20 : 0), eva: -25})},
  'Blood Rage': {job: 'WAR', lvl: 87, excl: 'warcry', fx: m => ({crit: m ? 40 : 20})},
  'Mighty Strikes': {job: 'WAR', lvl: 1, sp: true, fx: () => ({crit: 100, acc: 40})},
  // Double Attack +100 % at its start, nothing after 30 s; +80 Attack from its job points (atelier-engine/player.js)
  'Brazen Rush': {job: 'WAR', lvl: 96, sp: true, mainOnly: true, fx: () => ({da: 100, atk: 80})},
  'Focus': {job: 'MNK', lvl: 25, fx: (m, l) => m ? {crit: 20, acc: 120} : {crit: 20 * (1 - (99 - l) / 100), acc: 100 * (1 - (99 - l) / 100)}},
  'Impetus': {job: 'MNK', lvl: 88, fx: () => ({crit: 45, atk: 126})},
  'Composure': {job: 'RDM', lvl: 50, mainOnly: true, fx: () => ({acc: 70})},
  'Conspirator': {job: 'THF', lvl: 87, fx: () => ({acc: 45, sb: 50})},
  'Last Resort': {job: 'DRK', lvl: 15, twoHanded: ['jahaste'], fx: m => ({atkp: .25 + (m ? 100 / 1024 : 0), atk: m ? 40 : 0, defp: -.25, jahaste: m ? 25 : 15})},
  'Sharpshot': {job: 'RNG', lvl: 1, fx: m => ({racc: 40, ratk: m ? 40 : 0})},
  'Hasso': {job: 'SAM', lvl: 25, twoHanded: true, fx: (m, l) => ({str: m ? 34 : Math.trunc(l / 7), jahaste: 10, acc: 10})},
  'Hagakure': {job: 'SAM', lvl: 95, tp: true, fx: () => ({})},
  'Innin': {job: 'NIN', lvl: 40, fx: m => m ? {acc: 20, scb: 5, crit: 24, eva: -24} : {crit: 24, eva: -24}},
  'Building Flourish': {job: 'DNC', lvl: 50, fx: () => ({crit: 10, acc: 40, atkp: .25})},
  // the dances (BG Wiki), a main DNC's merit abilities, one at a time: their floor, what holds through the effect
  'Saber Dance': {job: 'DNC', lvl: 75, mainOnly: true, excl: 'dance', fx: () => ({da: danceFloor('saber', shownPieces())})},
  'Fan Dance': {job: 'DNC', lvl: 75, mainOnly: true, excl: 'dance', fx: () => ({pdmgmul: 1 - danceFloor('fan', shownPieces()) / 100})},
  'Haste Samba': {job: 'DNC', from: 'DNC', lvl: 45, party: true, fx: (m, l, ja) => ({jahaste: sambaHaste(ja)})},
  'Swordplay': {job: 'RUN', lvl: 20, fx: () => ({acc: 54, eva: 54})},
  'Sentinel': {job: 'PLD', lvl: 30, fx: m => ({enmity: m ? 100 : 50})},
  'Rampart': {job: 'PLD', lvl: 62, fx: () => ({dmgmul: .75})},
  'Crusade': {job: ['PLD', 'RUN'], lvl: 88, fx: () => ({enmity: 30})},
  'Cocoon': {job: 'BLU', lvl: 8, fx: () => ({defp: .5})},
  // excl: abilities that overwrite each other, one at a time (BG Wiki: Blood Rage "overwrites and is
  // overwritten by Warcry from Warrior main or sub job")
  // cast by someone else in the party, offered to every job: a WAR main's Warcry (its TP Bonus comes only
  // from the WAR's Savagery merits, +100 each, and +40 each more with Agoge Mask +3 / +4 worn: warcryTp) and Blood Rage
  'Warcry · party': {party: true, excl: 'warcry', from: 'WAR', tpParty: 'warcry', fx: () => ({atkp: Math.trunc(99 / 4 + 4.75) / 256})},
  'Blood Rage · party': {party: true, excl: 'warcry', from: 'WAR', fx: () => ({crit: 20})},
  // a party SMN (BG Wiki): Crimson Howl, Ifrit's Warcry (overwrites Warcry and Blood Rage), Crystal Blessing, Shiva's
  // TP Bonus +250, and one avatar's Favor at its top (Ifrit DA +23 %, Ramuh crit +25 %, Shiva MAB +57, Siren Subtle
  // Blow II +27, Garuda Evasion +55, Titan Defense +127). fams: the set families where it serves; eng: what the damage
  // engine is given instead of its own Favor values
  'Crimson Howl · party': {party: true, excl: 'warcry', from: 'SMN', fams: ['ws', 'engaged'], fx: () => ({atkp: Math.trunc(99 / 4 + 4.75) / 256})},
  'Crystal Blessing · party': {party: true, from: 'SMN', fams: ['ws'], tpParty: 250, fx: () => ({})},
  "Ifrit's Favor · party": {party: true, excl: 'favor', from: 'SMN', fams: ['ws', 'engaged'], fx: () => ({da: 23}), eng: {DA: 23}},
  "Ramuh's Favor · party": {party: true, excl: 'favor', from: 'SMN', fams: ['ws', 'engaged'], fx: () => ({crit: 25}), eng: {'Crit Rate': 25}},
  "Siren's Favor · party": {party: true, excl: 'favor', from: 'SMN', fams: ['engaged'], fx: () => ({sb: 27}), eng: {'Subtle Blow II': 27}},
  "Shiva's Favor · party": {party: true, excl: 'favor', from: 'SMN', fams: ['midcast', 'ws'], fx: () => ({mab: 57}), eng: {'Magic Attack': 57}},
  "Garuda's Favor · party": {party: true, excl: 'favor', from: 'SMN', fams: ['idle', 'special', 'engaged'], fx: () => ({eva: 55})},
  "Titan's Favor · party": {party: true, excl: 'favor', from: 'SMN', fams: ['idle', 'special', 'engaged'], fx: () => ({def: 127})},
};
// Targets: atelier_targets.js (monsters as players measured them, level by level) and the engine's
// "BG Wiki sets" reference, the default. TARGETS[key] the whole entry; ENEMIES[key] = level, Defense,
// Evasion, VIT, AGI, MND, INT, CHR
const DEFAULT_ENEMY = 'BG Wiki sets';
const TARGETS = Object.fromEntries((typeof ATELIER_TARGETS !== 'undefined' ? ATELIER_TARGETS : []).map(x => [x.key, x]));
TARGETS[DEFAULT_ENEMY] = {key: DEFAULT_ENEMY, name: DEFAULT_ENEMY, zone: '', job: '', lv: null, def: 1500, eva: 1350, vit: 340, agi: 340,
  int: 280, mnd: 280, chr: 280, res: null, est: [], src: 'ref'};
const ENEMIES = Object.fromEntries(Object.values(TARGETS).map(x => [x.key, [x.lv, x.def, x.eva, x.vit, x.agi, x.mnd, x.int, x.chr]]));
// the names an older page saved (the engine's former list, one level each)
const OLD_ENEMIES = {'Apex Bats': 'Apex Bats · Lv129', 'Apex Toad': 'Apex Toad · Lv132', 'Apex Bat': 'Apex Bat · Lv135',
  'Apex Lugcrawler Hunter': 'Apex Lugcrawler Hunter · Lv138', 'Apex Knight Lugcrawler': 'Apex Knight Lugcrawler · Lv140',
  'Apex Idle Drifter': 'Apex Idle Drifter · Lv142', 'Apex Archaic Cog': 'Apex Archaic Cog · Lv145', 'Apex Archaic Cogs': 'Apex Archaic Cogs · Lv147'};
const enemyKey = k => ENEMIES[k] ? k : ENEMIES[OLD_ENEMIES[k]] ? OLD_ENEMIES[k] : DEFAULT_ENEMY;
// The damage engine reads them by name: one more engine part, so the background search has them too
function targetsPart(){
  const list = Object.values(TARGETS).map(x => ({Name: x.key, Level: x.lv || 0, Defense: x.def, Evasion: x.eva, VIT: x.vit, AGI: x.agi,
    MND: x.mnd, INT: x.int, CHR: x.chr, 'Magic Evasion': 0, 'Magic Defense': 0, 'Magic DT%': -((x.res || {}).magic || 0), Location: x.zone}));
  return new Function('FFXI', 'FFXI.ENEMIES = ' + JSON.stringify(list) + ';');
}
// The usual end-game support, what a character starts with in the page (and the "End game" button)
const ENDGAME_BUFFS = {protect: 'Protect V', shell: 'Shell V', haste: 'Haste II',
  song0: 'Honor March', song1: 'Minuet V', song2: 'Minuet IV', song3: 'Aria of Passion',
  roll0: 'Chaos', roll1: 'Samurai', indi: 'Fury', geo: 'Frailty', dia: 'Dia III', lightshot: true,
  // the support's gear at its best: each song stops at its own cap (SONGS lim), Rolls +8 (Rostam C), Geomancy +10
  songsPlus: '9', rollsPlus: '8', geoPlus: '10',
  // Haste Samba on its own whenever the shown subjob is DNC (a click turns it off there: jaOff)
  autoSamba: true};
// Whether an ability counts: chosen, or Haste Samba under /DNC with the end-game default (not turned off)
// An ability is yours (your job or subjob: b.ja, the same in every support profile) or a party member's (b.pja, the
// profile's own, none in Solo): Haste Samba ticked under /DNC is not a party DNC's once the subjob is SAM
const jaRole = name => ((jasOf().find(j => j.name === name) || {}).as) === 'party' ? 'pja' : 'ja';
function jaOn(b, name){
  const role = jaRole(name);
  // Fan Dance renders your own sambas unusable (a party DNC's Haste Samba still counts)
  if (name === 'Haste Samba' && role === 'ja' && jaOn(b, 'Fan Dance')) return false;
  if ((b[role] || {})[name]) return true;
  return role === 'ja' && name === 'Haste Samba' && !!b.autoSamba && (data() || {}).sub === 'DNC' && !(b.jaOff || {})[name];
}
// A dance's floor (BG Wiki): Saber Dance's Double Attack ends at 20 % (from 50 %, in 30 s), Fan Dance's physical damage
// cut at 20 % (from 90 %, 10 % a hit taken); each "Saber Dance" / "Fan Dance" merit level adds 1 % to it while Etoile or
// Horos Tights / Bangles are worn: counted on the pieces of the set shown (the search weighs the Tights against any
// other legs: atelier_opt.js gearset)
const DANCE = {saber: {merit: 'saber_dance', slot: 'legs', gear: /^(Horos|Etoile) Tights/},
  fan: {merit: 'fan_dance', slot: 'hands', gear: /^(Horos|Etoile) Bangles/}};
function danceMerit(kind){ const m = (meritList() || []).find(x => x.key === DANCE[kind].merit); return m ? meritLevel(m) : 0; }
function danceFloor(kind, pieces){
  const k = DANCE[kind], worn = pieces && k.gear.test((pieces[k.slot] || {}).name || '');
  return 20 + (worn ? danceMerit(kind) : 0);
}
// The pieces of the set shown (its weapons and tries in), for what depends on the gear worn
const shownPieces = () => S._curSet ? withWeapons(S._curSet).pieces : null;
const endgameBuffs = () => JSON.parse(JSON.stringify(ENDGAME_BUFFS));
// The sets GearSwap wears a .Group / .Solo version of, by the party's support (support_tier.lua)
const TIERED = /^sets\.(precast\.WS|engaged|luopan\.engaged)\b/;
// Support profiles, as GearSwap picks the weaponskill and engaged sets (shared/utils/party/support_tier.lua): Full (a GEO
// and a BRD or a COR), Group (one of them), Solo (none), Trust (all the support from trusts). Each keeps its own party
// buffs; what is yours or the target's (PERSONAL) follows you from one profile to the next. Full is the character's
// original profile.
const TIERS = ['Full', 'Group', 'Solo', 'Trust'];
// The Trust profile: Sylvie (UC), Ulmia, Joachim, Qultada, Monberaux and an alt RDM (Kaories), from BG Wiki
// (BGWiki:Trusts, 2026-10-05); what it does not give is taken at its lowest
// - Sylvie: Indi-Fury +37.5 % (Geomancy +1 here: 37.4 %; Indi-Precision when your hit rate is low), Entrust
//   Indi-Frailty -12.5 % Defense (the page's 14.8 % x .845), her Haste replaced by the RDM's Haste II
// - Joachim and Ulmia: March and Madrigal each, no instrument or gear bonus (Joachim's said, Ulmia's taken so):
//   Victory and Advancing March (with Haste II over the Magic Haste cap either way), Blade and Sword Madrigal
// - Qultada: Chaos and Fighter's Roll, no Rolls+; he Double-Ups any 1 to 6 short of the lucky number: his
//   average without Snake Eye is Chaos 17.2 % (IX: 17.18 %) and Fighter's 6.8 (X: 7), Light Shot on Dia
// - Monberaux: Guard Drink's Protect (220) and Shell (-29 %); Samson's Strength (+10 stats, 1 min, a 60 s
//   recast shared with three other mixes) left out
// - the RDM: Haste II, Dia III, Distract III (Gravity: no damage)
const TRUST_BUFFS = {protect: 'Protect V', shell: 'Shell V', haste: 'Haste II',
  song0: 'Victory March', song1: 'Advancing March', song2: 'Blade Madrigal', song3: 'Sword Madrigal', songsPlus: '0',
  roll0: 'Chaos', roll0n: 'IX', roll1: "Fighter's", roll1n: 'X', rollsPlus: '0', lightshot: true,
  indi: 'Fury', entrust: 'Frailty', geoPlus: '1', geoScale: {entrust: .125 / .148},
  dia: 'Dia III', distract: 'Distract III', autoSamba: true};
const PERSONAL = ['food', 'am', 'amStage', 'amTp', 'enemy', 'ja', 'jaOff', 'autoSamba'];
const TIER_DROP = {Full: [], Group: ['indi', 'geo', 'entrust', 'geoPlus', 'bolster', 'bog', 'ecliptic'],
  Solo: ['pja', 'indi', 'geo', 'entrust', 'geoPlus', 'bolster', 'bog', 'ecliptic', 'songsPlus', 'rollsPlus', 'protect', 'shell', 'haste', 'song0', 'song1', 'song2', 'song3', 'song4', 'soulVoice', 'marcato', 'clarion', 'ariaStage', 'roll0job', 'roll1job', 'rollCC', 'roll0', 'roll1', 'dia', 'lightshot', 'distract', 'saboteur', 'sabGloves', 'auspice', 'auspiceFeet', 'enspell', 'enSkill']};
function tierBuffs(tier){ if (tier === 'Trust') return JSON.parse(JSON.stringify(TRUST_BUFFS));
  const b = endgameBuffs(); for (const k of TIER_DROP[tier] || []) delete b[k]; return b; }
const buffTier = () => (S.buffTier || {})[S.char] || 'Full';
const buffKey = (tier = buffTier()) => tier === 'Full' ? S.char : S.char + '|' + tier;
const buffState = () => { if (S._buffOverride) return S._buffOverride;
  const k = buffKey(); return (S.buffs[k] = S.buffs[k] || tierBuffs(buffTier())); };
// A profile's buffs: its own, or (never opened yet) its usual party buffs with what is yours from the profile shown
function tierBuffsOf(tier){
  if (S.buffs[buffKey(tier)]) return S.buffs[buffKey(tier)];
  const b = tierBuffs(tier), cur = buffState();
  for (const k of PERSONAL) if (cur[k] !== undefined) b[k] = cur[k];
  return b;
}
// fn() worked out with another profile's buffs
function withTierBuffs(tier, fn){
  const keep = S._buffOverride, b = tierBuffsOf(tier);
  S._buffOverride = b;
  try { return fn(); } finally { S._buffOverride = keep; }
}
// The buffs follow the set opened (once, when it changes): a .Group, .Solo or .Trust version opens that profile, a weaponskill
// or engaged set that has such versions opens Full; another set leaves the profile as it is
function tierFollowsSet(path, bypath){
  const at = S.char + '|' + S.job + '|' + path;
  if (!path || at === S._tierPath) return;
  S._tierPath = at;
  const v = (path.match(/\.(Group|Solo|Trust)$/) || [])[1];
  const tier = v || (TIERED.test(path) && (bypath[path + '.Group'] || bypath[path + '.Solo'] || bypath[path + '.Trust']) ? 'Full' : null);
  if (tier && tier !== buffTier()) { setBuffTier(tier); save(); setTimeout(render, 0); }
}
// The subjob a job plays with each way of holding its weapons: a two-handed weapon, a weapon in each hand, one
// weapon (and a shield)
const SUB_FOR_GRIP = {WAR: {two: 'SAM', dual: 'DNC', one: 'DRG'}};
// How a set holds its weapons ('two', 'dual', 'one'), null while the engine is not loaded
function gripOf(pieces){
  const it = itemOf((pieces.main || {}).name), su = itemOf((pieces.sub || {}).name);
  if (!it) return null;
  if (it.Type === 'Weapon' && !(it.slots || []).includes('sub')) return 'two';
  return su && su.Type === 'Weapon' ? 'dual' : 'one';
}
// The subjob follows the engaged or weaponskill set opened (once, when it changes), from its weapons; a Jump set is /DRG
function subFollowsSet(path, bypath){
  const s = bypath[path], rule = SUB_FOR_GRIP[S.job], jump = isJumpSet(path) && S.job !== 'DRG';
  const at = S.char + '|' + S.job + '|' + path;
  if (!s || at === S._subPath || !(jump || (rule && ['engaged', 'ws'].includes(family(s.path, s.pieces))))) return;
  const grip = jump ? 'jump' : gripOf(withWeapons(s).pieces);
  if (!grip) return;
  S._subPath = at;
  const sub = jump ? 'DRG' : rule[grip];
  if (sub && sub !== subOf(S.char, S.job) && allSubs(S.char, S.job).includes(sub)) { S.subs[S.char + '|' + S.job] = sub; save(); setTimeout(render, 0); }
}
// The engaged objective follows the set opened (once, when it changes): an Aftermath Lv.3 set (<Weapon>AFM3) is worn for
// its damage, DPS; another engaged set builds TP, real time to the weaponskill (a set named DPS too: PLD's sets.engaged.DPS
// and GEO's sets.luopan.engaged.DPS are the melee sets, as against the tanky / DT ones, worn to build TP fast)
function objFollowsSet(path, bypath){
  const s = bypath[path];
  const at = S.char + '|' + S.job + '|' + path;
  if (!s || at === S._objPath || family(s.path, s.pieces) !== 'engaged') return;
  S._objPath = at;
  // the whole-fight objective, once chosen, stays for every engaged set
  if ((S.optOpts || {}).engObj === 'cycle') return;
  const obj = isAfm3(path) ? 'dps' : 'tp_real';
  if ((S.optOpts || {}).engObj !== obj) { S.optOpts = Object.assign({}, S.optOpts, {engObj: obj}); save(); }
}
function setBuffTier(tier){
  if (!TIERS.includes(tier) || tier === buffTier()) return;
  const from = buffState();
  S.buffTier = Object.assign({}, S.buffTier, {[S.char]: tier});
  const to = buffState();
  for (const k of PERSONAL) { if (from[k] === undefined) delete to[k]; else to[k] = JSON.parse(JSON.stringify(from[k])); }
}
// The abilities the shown job and subjob have (as main: full effect), and the party ones
// The levels abilities are offered at: the main job's, and the subjob's (measured, else 49 + 1 per 5 Master Levels)
function jaLevels(){
  const c = measuredChar() || {}, ml = ((c.jobs || {})[S.job] || {}).ml ?? c.master_level ?? 0;
  return {main: c.main_level || 99, sub: c.sub_level || Math.min(59, 49 + Math.floor(ml / 5)), ml};
}
// kept per character, job, subjob and set opened until an export is read again (asked for hundreds of times a render)
let JAS_MEMO = {key: null, out: null};
function jasOf(){
  const sub = (data() || {}).sub, fam = S._curSet ? family(S._curSet.path, S._curSet.pieces) : null;
  const key = [DATA_GEN, S.char, S.job, sub, fam].join('|');
  if (JAS_MEMO.key === key) return JAS_MEMO.out;
  const lv = jaLevels(), out = [];
  for (const [name, a] of Object.entries(JAS)) {
    const jobs = [].concat(a.job || []), asMain = jobs.includes(S.job) && a.lvl <= lv.main;
    const asSub = !asMain && !a.sp && !a.mainOnly && jobs.includes(sub) && a.lvl <= lv.sub;
    // a party buff from another job stays offered (where it serves the set shown); a WAR does not need the party
    // Warcry on top of its own
    if (a.fams && fam && !a.fams.includes(fam)) continue;
    if (asMain || asSub || (a.party && !(a.from && a.from === S.job)))
      out.push({name, main: asMain, lvl: asMain ? lv.main : asSub ? lv.sub : 99, a, as: asMain ? 'main' : asSub ? 'sub' : 'party'});
  }
  JAS_MEMO = {key, out};
  return out;
}
// A support job switched off in its card (b.off): its choices stay, the sums (page and engine) leave them out
const JOB_KEYS = {WHM: ['protect', 'shell', 'haste', 'storm', 'auspice', 'auspiceFeet', 'enspell', 'enSkill'],
  BLM: ['sabots'], RUN: ['rune', 'runes'], DNC: ['dncSub'], SMN: ['smnSkill'],
  BRD: ['song0', 'song1', 'song2', 'song3', 'song4', 'songsPlus', 'soulVoice', 'marcato', 'clarion', 'ariaStage'],
  COR: ['roll0', 'roll1', 'roll0n', 'roll1n', 'rollsPlus', 'lightshot', 'roll0job', 'roll1job', 'rollCC'], GEO: ['indi', 'geo', 'entrust', 'geoPlus', 'bolster', 'bog', 'ecliptic'],
  'Light Shot': ['lightshot'], Distract: ['distract', 'saboteur', 'sabGloves']};
function liveBuffs(b){
  const off = Object.keys(b.off || {}).filter(j => b.off[j]);
  if (!off.length) return b;
  const out = Object.assign({}, b);
  for (const j of off) for (const k of JOB_KEYS[j] || []) delete out[k];
  // Dia goes with its caster's switch: Dia III the RDM's (Distract tab), Dia and Dia II the WHM's
  if (out.dia && off.includes(DIA_OWNER[out.dia])) delete out.dia;
  if (off.includes('Dia') && out.foeJa) out.foeJa = out.foeJa.filter(n => n !== 'Banish II');
  if ((off.includes('Light Shot') || off.includes('COR')) && out.foeJa) out.foeJa = out.foeJa.filter(n => !FOE_JA.COR[n]);
  // a party job's abilities on you (pWAR: a party WAR's Warcry...) go with its tab's switch
  const pOff = off.filter(j => j[0] === 'p').map(j => j.slice(1));
  if (pOff.length && out.pja) out.pja = Object.fromEntries(Object.entries(out.pja).filter(([n]) => {
    const a = JAS[n] || {}; return !(a.party && pOff.includes(a.from || [].concat(a.job)[0])); }));
  // a job's abilities on the target (WAR Armor Break...) go with its switch
  if (out.foeJa) out.foeJa = out.foeJa.filter(n => !off.some(j => FOE_JA[j] && FOE_JA[j][n] && !FOE_SW[j]) &&
    !off.some(j => Object.entries(FOE_SW).some(([job, sw]) => sw === j && FOE_JA[job][n])));

  return out;
}
// TP Bonus a party member's ability adds before a weaponskill (a WAR's Warcry), counted by the page.
// A party Warcry's: the WAR's Savagery merits (BG Wiki: 100 TP Bonus a level, 5 by default) and, worn when it is
// used, Agoge Mask +3 / +4 (40 more a level, on by default): 700 at 5/5 with the mask
// own: b.savagery / b.noAgoge; a party WAR's: b.pSavagery / b.pNoAgoge (5/5 with the mask by default)
const warcryTp = (b, party) => { const lv = party ? b.pSavagery : b.savagery, no = party ? b.pNoAgoge : b.noAgoge;
  return (lv == null ? 5 : +lv) * (no ? 100 : 140); };
const tpOfParty = (a, b) => a.tpParty === 'warcry' ? warcryTp(b, true) : a.tpParty || 0;
// Haste Samba's JA Haste (BG Wiki): 5 % (51/1024) from any DNC, +1 % a "Haste Samba Effect" merit level (5 levels,
// a main DNC's only); no gear raises it. Yours: your merits (the page's merit edits counted); a party DNC's: the
// menu of its tab (a main DNC with its merits, 5 by default, or a /DNC)
function sambaHaste(ja){
  if (!ja || ja.as === 'sub') return 5.1;
  if (ja.as === 'main') { const m = (meritList() || []).find(x => x.key === 'haste_samba_effect'); return 5.1 + (m ? meritLevel(m) : 5); }
  const v = buffState().pSamba || '';
  return v === 'sub' ? 5.1 : 5.1 + (v ? +v.slice(1) : 5);
}
const partyTp = () => { const b = buffState(); return jasOf().filter(j => j.as === 'party' && j.a.tpParty && jaOn(b, j.name)).reduce((n, j) => n + tpOfParty(j.a, b), 0); };
// Every active buff added up: {stat: value}; atkp/defp as fractions, deff/mevaf as [%, cap], dmgmul a product
function buffTotals(){
  // B._by: what each buff gives, for the "Active effects" list ({src, k, v})
  const b = liveBuffs(buffState()), B = {_by: []}, put = (k, v, src) => { B[k] = (B[k] || 0) + v; if (src) B._by.push({src, k, v}); };
  const food = FOODS[b.food];
  for (const [k, v] of Object.entries(food || {})) { if (Array.isArray(v)) { B[k] = v; B._by.push({src: b.food, k, v}); } else put(k, v, b.food); }
  const songsPlus = +(b.songsPlus || 0), seen = new Set();
  for (const i of songSlots(b)) { const name = b['song' + i];
    if (!SONGS[name] || seen.has(name)) continue;
    seen.add(name);
    for (const [k, v] of Object.entries(SONGS[name])) if (k !== 'lim') {
      const plus = name === 'Aria of Passion' ? ariaPlus(b) : Math.min(SONGS[name].lim, songsPlus);
      const val = (v[0] + plus * v[1]) * songMul(b, i); put(k, k === 'atk' ? Math.floor(val) : val, name); } }
  const rollsPlus = +(b.rollsPlus || 0);
  for (const i of [0, 1]) { const r = ROLLS[b['roll' + i]], n = ROMAN.indexOf(b['roll' + i + 'n'] || 'XI');
    const job = rollJobOn(b, i) ? ROLL_JOB[b['roll' + i]][1] : 0, cc = b.rollCC != null && +b.rollCC === i ? 1.2 : 1;
    if (r && n >= 0) for (const [k, [vals, step]] of Object.entries(r))
      put(k, (vals[n] + rollsPlus * step + job) * cc, `${b['roll' + i]} Roll ${ROMAN[n]}${job ? ' + ' + ROLL_JOB[b['roll' + i]][0] : ''}${cc > 1 ? ' + CC' : ''}`); }
  const geoPlus = +(b.geoPlus || 0);
  // the same effect twice does not stack (Indi- and Geo- Fury): each counts once. Geomancy+ is the
  // GEO's main hand or handbell, so not on an Entrust (BG Wiki Geomancy Skill)
  const named = {}; for (const k of ['indi', 'geo', 'entrust']) if (b[k]) {
    const plus = k === 'entrust' ? 0 : geoPlus, mul = geoMul(b)[k], one = Object.values(BUBBLES[b[k]] || GEO_DEBUFFS[b[k]] || {})[0] || [0, 0];
    const strength = (one[0] + plus * one[1]) * mul;
    if (!named[b[k]] || strength > named[b[k]].strength)
      named[b[k]] = {src: {indi: 'Indi-', geo: 'Geo-', entrust: 'Entrust Indi-'}[k] + b[k], plus, mul, strength}; }
  for (const [name, {src, plus, mul}] of Object.entries(named)) if (BUBBLES[name] || GEO_DEBUFFS[name])
    for (const [k, [base, step]] of Object.entries(BUBBLES[name] || GEO_DEBUFFS[name]))
      put(k, (base + plus * step) * mul * (GEO_DEBUFFS[name] ? geoKeep(enemyKey(b.enemy)) : 1), src);
  if (DIA[b.dia]) put('edefp', DIA[b.dia], b.dia);
  if (b.lightshot && DIA[b.dia]) put('edefp', LIGHT_SHOT, 'Light Shot');
  for (const e of foeCounted(b).list) put(e.k, e.v, e.n);
  if (BIO[b.dia]) put('eatkp', BIO[b.dia], b.dia);
  if (DISTRACT[b.distract] && foeCounted(b).distractWins) put('eeva', distractEva(b), b.distract + (b.saboteur ? ' + Saboteur' + (b.sabGloves ? ' (Lethargy +3)' : '') : ''));
  if (PROTECT[b.protect]) put('def', PROTECT[b.protect], b.protect);
  if (SHELL[b.shell]) put('shell', SHELL[b.shell], b.shell);
  if (HASTE[b.haste]) put('mhaste', HASTE[b.haste], b.haste);
  if (b.auspice) put('sb', auspiceSb(b), 'Auspice');
  if (b.enspell) put('enspell', enspellDmg(enSkill(b)), 'Enspell I');
  for (const [k, v] of Object.entries(STORMS[b.storm] || {})) put(k, v, b.storm);
  // an ability for a two-handed weapon (Hasso, Last Resort's haste) with another in hand: left out
  const main = shownMain(), wsk = main && weaponSkills()[main];
  const twoHands = !main || !wsk || TWO_HANDED.test(wsk);
  for (const ja of jasOf()) if (jaOn(b, ja.name)) for (const [k, v] of Object.entries(ja.a.fx(ja.main, ja.lvl, ja))) {
    if (!twoHands && (ja.a.twoHanded === true || (ja.a.twoHanded || []).includes(k))) continue;
    if (k === 'dmgmul' || k === 'pdmgmul') { B[k] = (B[k] || 1) * v; B._by.push({src: ja.name, k, v}); } else put(k, v, ja.name); }
  // a party member's TP Bonus (a WAR's Warcry, a SMN's Crystal Blessing): shown with its other effects (the TP steps count it already)
  for (const ja of jasOf()) if (ja.as === 'party' && ja.a.tpParty && jaOn(b, ja.name)) put('tpb', tpOfParty(ja.a, b), ja.name);
  return B;
}
