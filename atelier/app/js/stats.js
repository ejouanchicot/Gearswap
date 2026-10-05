// GearSwap Atelier · stats.js: set families, a piece's stats (descriptions, augments, ranks, capes), the stats shown
// (cut from atelier.html, loaded by it in order: see the list there)
/* ---- set grouping ---- */
/* ---- item stats: read from the game's descriptions and the set's augments ---- */
// key: [group, French label, English label, cap]. A stat not listed here is still
// counted, under its own name ("Others"); "* skill" stats go to Skills.
const STAT_DEF = {
  hp:['def','HP','HP'], mp:['def','MP','MP'], def:['def','DEF','DEF'],
  dt:['def','Dégâts reçus','Damage taken'], pdt:['def','Dégâts physiques reçus','Physical damage taken'],
  mdt:['def','Dégâts magiques reçus','Magic damage taken'], pdt2:['def','Dégâts physiques reçus II','Physical damage taken II'],
  mdt2:['def','Dégâts magiques reçus II','Magic damage taken II'], bdt:['def','Dégâts de souffle reçus','Breath damage taken'],
  eva:['def','Évasion','Evasion'], meva:['def','Évasion magique','Magic evasion'], mdb:['def','Bonus déf. magique','Magic def. bonus'],
  block:['def','Chance de blocage','Block chance'], sdb:['def','Bonus déf. bouclier','Shield def. bonus'],
  ecrit:['def','Critiques ennemis','Enemy critical hit rate'], enmity:['def','Enmity','Enmity'], phalanx:['def','Phalanx','Phalanx'],
  str:['attr','STR','STR'], dex:['attr','DEX','DEX'], vit:['attr','VIT','VIT'], agi:['attr','AGI','AGI'],
  int:['attr','INT','INT'], mnd:['attr','MND','MND'], chr:['attr','CHR','CHR'],
  acc:['off','Précision','Accuracy'], atk:['off','Attaque','Attack'], haste:['off','Haste','Haste',25],
  da:['off','Double Attack','Double Attack'], ta:['off','Triple Attack','Triple Attack'], qa:['off','Quadruple Attack','Quadruple Attack'],
  stp:['off','Store TP','Store TP'], crit:['off','Coups critiques','Critical hit rate'], critdmg:['off','Dégâts critiques','Critical hit damage'],
  wsd:['off','Dégâts de WS','Weapon skill damage'], tpb:['off','TP Bonus','TP Bonus'], dw:['off','Dual Wield','Dual Wield'],
  sb:['off','Subtle Blow','Subtle Blow',50], sb2:['off','Subtle Blow II','Subtle Blow II'], scb:['off','Bonus skillchain','Skillchain bonus'],
  pdl:['off','Limite dégâts physiques','Physical damage limit'], regain:['off','Regain','Regain'], counter:['off','Counter','Counter'],
  racc:['off','Précision à distance','Ranged accuracy'], ratk:['off','Attaque à distance','Ranged attack'],
  fc:['mag','Fast Cast','Fast Cast',80], macc:['mag','Précision magique','Magic accuracy'], mab:['mag','Bonus att. magique','Magic atk. bonus'],
  mdmg:['mag','Dégâts magiques','Magic damage'], mbd:['mag','Dégâts magic burst','Magic burst damage',40],
  mbd2:['mag','Dégâts magic burst II','Magic burst damage II'], cure:['mag','Cure potency','Cure potency',50],
  cure2:['mag','Cure potency II','Cure potency II',30], curecast:['mag','Temps d\'incantation Cure','Cure casting time'],
  cmp:['mag','Conserve MP','Conserve MP'], sird:['mag','SIRD','SIRD',102],
  enhdur:['mag','Durée renfort','Enhancing duration'], refresh:['mag','Refresh','Refresh'], regen:['mag','Regen','Regen'],
  move:['mag','Vitesse de déplacement','Movement speed'], th:['mag','Treasure Hunter','Treasure Hunter'],
  res_fire:['res','Feu','Fire'], res_ice:['res','Glace','Ice'], res_wind:['res','Vent','Wind'], res_earth:['res','Terre','Earth'],
  res_lightning:['res','Foudre','Lightning'], res_water:['res','Eau','Water'], res_light:['res','Lumière','Light'], res_dark:['res','Ténèbres','Dark'],
};
const STAT_GROUPS = [['def','Défense','Defense'], ['attr','Attributs','Attributes'], ['off','Combat','Combat'],
  ['mag','Magie & divers','Magic & misc'], ['res','Résistances','Resistances'], ['skill','Compétences','Skills'], ['other','Autres','Others']];
// Every spelling met in the descriptions and augments, written as normName() gives it
const STAT_ALIAS = {
  'hp':'hp','mp':'mp','str':'str','dex':'dex','vit':'vit','agi':'agi','int':'int','mnd':'mnd','chr':'chr',
  'accuracy':'acc','acc.':'acc','acc':'acc','attack':'atk','atk.':'atk',
  'ranged accuracy':'racc','rng.acc.':'racc','ranged attack':'ratk','rng.atk.':'ratk',
  'evasion':'eva','eva.':'eva','magic evasion':'meva','mag.eva.':'meva','mag.evasion':'meva','magic eva.':'meva',
  'magic def.bonus':'mdb','m.def.b.':'mdb','mag.def.bns.':'mdb',
  'magic accuracy':'macc','mag.acc.':'macc','mag.acc':'macc','magic atk.bonus':'mab','mag.atk.bns.':'mab','m.atk.b.':'mab',
  'magic damage':'mdmg','mag.dmg.':'mdmg',
  'damage taken':'dt','dt':'dt','physical damage taken':'pdt','phys.dmg.taken':'pdt','magic damage taken':'mdt','mag.dmg.taken':'mdt',
  'physical damage taken ii':'pdt2','phys.dmg.taken ii':'pdt2','magic damage taken ii':'mdt2','mag.dmg.taken ii':'mdt2',
  'breath damage taken':'bdt','breath dmg.taken':'bdt',
  'haste':'haste','fast cast':'fc','double attack':'da','dbl.atk.':'da','triple attack':'ta','quadruple attack':'qa','quad attack':'qa',
  'store tp':'stp','critical hit rate':'crit','crit.hit rate':'crit','critical hit damage':'critdmg','crit.hit damage':'critdmg',
  'weapon skill damage':'wsd','tp bonus':'tpb','dual wield':'dw','subtle blow':'sb','subtle blow ii':'sb2',
  'skillchain bonus':'scb','physical damage limit':'pdl','regain':'regain','counter':'counter',
  'cure potency':'cure','cure potency ii':'cure2','cure spellcasting time':'curecast','conserve mp':'cmp',
  'spell interruption rate down':'sird','spell interruption rate':'sird',
  'enhancing magic duration':'enhdur','enh.mag.eff.dur.':'enhdur','phalanx':'phalanx','phalanx received':'phalanx',
  'refresh':'refresh','regen':'regen','enmity':'enmity','magic burst damage':'mbd','magic burst damage ii':'mbd2',
  'movement speed':'move','treasure hunter':'th','chance of successful block':'block',
  'shield def.bonus':'sdb','enemy critical hit rate':'ecrit','trip.atk.':'ta','magic defense bonus':'mdb',
  'fire resistance':'res_fire','ice resistance':'res_ice','wind resistance':'res_wind','earth resistance':'res_earth',
  'lightning resistance':'res_lightning','water resistance':'res_water','light resistance':'res_light','dark resistance':'res_dark',
  'mag.atk.bns':'mab','rng.acc':'racc','rng.atk':'ratk',
  'ranged acc.':'racc','ranged atk.':'ratk','magic acc.':'macc','magic atk.':'mab',
  'magic critical hit rate':'x:magic critical hit rate','magic crit.hit rate':'x:magic critical hit rate',
  'slow':'slow','annuls damage taken':'x:annuls damage taken','physical damage converted to mp':'x:physical damage converted to mp','m.accuracy':'macc','m.acc.':'macc',
  // a weaponskill's own accuracy (Fallen's Cuirass, Karieyh Ring): never the general one
  'weapon skill accuracy':'x:weapon skill accuracy','weapon skill acc.':'x:weapon skill accuracy',
  'triple atk.':'ta','quadruple atk.':'qa','magic burst dmg.':'mbd','magic burst dmg':'mbd',
  'enha.mag.skill':'skill:enhancing magic skill','enfb.mag.skill':'skill:enfeebling magic skill',
  'def':'def','magic dmg.taken':'mdt','magic attack bonus':'mab','mag.def.bonus':'mdb','magic defense':'mdb',
};
const normName = s => s.toLowerCase().replace(/["“”]/g, '').replace(/\.\s*/g, '.').replace(/\s+/g, ' ').replace(/^[\s/:]+|[\s/:]+$/g, '').trim();
// A line that opens a condition (Set:, Latent effect:, Pet:, Unity ranking:...): what follows is not always on
// "Synergy Damage taken-25%" (the craft smocks) has no colon: only while synergizing, never a defense of the set
const COND = /^(?:Synergy\s|(?!DEF:|DMG:|Delay:)[A-Z][A-Za-z .()'\-]{1,30}:)/;

// The stat a phrase ends with: the longest known name at its end, the rest is free text
function statOf(phrase){
  const words = phrase.trim().split(/\s+/);
  for (let k = 0; k < words.length; k++) {
    const tail = normName(words.slice(k).join(' '));
    const key = STAT_ALIAS[tail] || (/ skill$/.test(tail) && tail.split(' ').length <= 4 ? 'skill:' + tail : null);
    // never the end of a name in quotes ("Triple Atk."+3, "Sneak Attack"+10 are not Attack): an unknown name stays whole
    if (key && (words.slice(0, k).join(' ').match(/"/g) || []).length % 2) break;
    // nor a stat named after an ability ("Step" accuracy +35, "Jump" attack): that ability's, never the general one
    if (key && k > 0 && /"[^"]*"\s*$/.test(words.slice(0, k).join(' '))) break;
    // nor one element's (Earth Elemental "Magic Atk. Bonus"+5)
    if (key && k > 0 && /elemental\s*$/i.test(words.slice(0, k).join(' '))) break;
    if (key) return {key, label: words.slice(k).join(' ').replace(/^[\s/]+/, ''), rest: words.slice(0, k).join(' ')};
  }
  const short = words.length <= 5 && /[A-Za-z]/.test(phrase);
  return short ? {key: 'x:' + normName(phrase), label: phrase.trim().replace(/^[\s/]+/, ''), rest: ''} : {key: null, rest: phrase.trim()};
}
const ATTRS = ['str','dex','vit','agi','int','mnd','chr'];
// The keys of a phrase naming several stats for one value, or null
function statsOf(phrase){
  const name = normName(phrase);
  if (name === 'all attr.' || name === 'all attributes') return ATTRS;
  const parts = phrase.replace(/^[\s/]+/, '').split(/\s*(?:&|\/)\s*/).filter(Boolean);
  if (parts.length < 2) return null;
  const keys = parts.map(x => STAT_ALIAS[normName(x)]);
  return keys.every(Boolean) ? keys : null;
}
// Stats of one line of text ("HP+145 MP+129 STR+36", "Eva.+20 /Mag. Eva.+20"): adds to out, returns free text
function parseLine(line, out){
  const free = [];
  let last = 0;
  // "STR+2～5" (Rajas Ring): the top of the range, as the engine counts it
  for (const m of line.matchAll(/([+-])\s?(\d+)(?:～(\d+))?(%?)/g)) {
    const phrase = line.slice(last, m.index);
    last = m.index + m[0].length;
    let v = (m[1] === '-' ? -1 : 1) * +(m[3] || m[2]);
    // several stats for one value (rank stats): "DEX & AGI +15", "INT/MND +25", "All Attr.+2"
    const many = statsOf(phrase);
    if (many) { for (const k of many) add(out, k, v, m[4], k); continue; }
    const s = statOf(phrase);
    // "Atonement: Enmity +100" (a path's rank stat) is for that ability only: shown, never counted
    if (!s.key || /:\s*$/.test(s.rest)) { free.push((phrase.trim() + ' ' + m[0]).trim()); continue; }
    if (s.rest) free.push(s.rest);
    if (s.key === 'sird') v = Math.abs(v);
    // "Slow"+7% (Lustratio, Hecatomb) is Haste taken off
    if (s.key === 'slow') { add(out, 'haste', -v, '%', s.label); continue; }
    // "HP+10%" is not "HP+10": a stat counted in points elsewhere gets its own % line
    const key = m[4] && FLAT.has(s.key) ? s.key + '%' : s.key;
    add(out, key, v, m[4], s.label);
  }
  const tail = line.slice(last).trim();
  if (tail) free.push(tail);
  return free.join(' ').trim();
}
// Always in %, even where an augment leaves the sign out ("Fast Cast"+10)
const PCT = new Set(['dt','pdt','mdt','pdt2','mdt2','bdt','haste','fc','da','ta','qa','crit','critdmg','wsd','sird','cure','cure2',
  'curecast','enhdur','mbd','mbd2','ecrit','cmp','pdl']);
function add(out, key, v, unit, label){
  if (PCT.has(key)) unit = '%';
  const e = out[key] || (out[key] = {v: 0, unit, label});
  e.v += v; if (unit) e.unit = unit;
}
// Every stat of one piece: its description (always on part), then its augments. slot: where it is worn, for
// an earring whose bonus works in one ear only ("Right ear: "Double Attack"+9%", the Empyrean earrings): counted
// in that ear (ear2 is the right one, GearSwap's right_ear), a condition shown in the other or with no slot
const PIECE_CACHE = {}, EAR_SIDE = {ear1: 'left', ear2: 'right'};
const ONLY_AUGS = {'Moonshade Earring': ['TP Bonus +250']};
// "All BP" by mastery rank (BG Wiki, Hoxne Earring)
const MASTERY_BP = {1: -30, 2: -20, 3: -10, 4: 0, 5: 5, 6: 10, 7: 15, 8: 20, 9: 25, 10: 30};
// The item id of your copy of a piece (the export gives each its id), the highest when you hold several; null when
// you have none or the export predates ids
function ownId(name, slot){
  const owned = ownedOf() || {}, list = slot && owned[slot] ? owned[slot] : Object.values(owned).flat();
  const mine = list.filter(x => x.name === name && x.id).sort((a, b) => b.id - a.id)[0];
  return mine ? mine.id : null;
}
function pieceStats(p, slot){
  if (!p || isEmpty(p)) return null;
  // a piece worn for one augment only (Moonshade Earring: its TP Bonus +250, its Accuracy+4 or Attack+4 never)
  if (ONLY_AUGS[p.name]) p = Object.assign({}, p, {augs: ONLY_AUGS[p.name]});
  // the piece's own item id first, else your copy's (a set names a piece only: Laphria, your Laphria IV), else the name's
  const cat = catalog(), id = p.id || ownId(p.name, slot) || iconIds()[p.name] || (cat && cat.id[p.name]);
  const text = id ? descTexts()[id] || (cat && cat.desc[id]) || null : null;
  const side = EAR_SIDE[slot] || '';
  const key = DATA_GEN + '|' + S.char + '|' + p.name + '|' + (id || '') + '|' + (p.augs || []).join('|') + '|' + (p.rank ?? '') + '|' + (window.FFXI && FFXI.RANKED ? 1 : 0) + '|' + side;
  if (PIECE_CACHE[key] && PIECE_CACHE[key].text === text) return PIECE_CACHE[key];
  // base: what the description gives; aug: what the augments add (the set's, the scanned ones, a path's rank)
  const r = {text, base: {}, aug: {}, stats: {}, pet: {}, free: [], cond: [], unity: {}, path: null, weapon: null, known: !!text};
  // after "Pet:" (or Avatar:, Wyvern:...) the lines are the pet's, after any other condition they only apply sometimes
  let mode = null, cur = -1;
  // the game wraps long phrases: a line starting in lower case goes on the previous one
  const lines = (text || '').split('\n').reduce((acc, l) => { if (acc.length && /^[a-z]/.test(l)) acc[acc.length - 1] += ' ' + l; else acc.push(l); return acc; }, []);
  for (const raw of lines) {
    // "Converts 150 MP to HP" (Tuisto, Odnowa...): that much HP more, MP less
    let line = raw.replace(/Converts (\d+) (MP|HP) to (HP|MP)/g, (_, n, from, to) => {
      add(r.base, to.toLowerCase(), +n, '', to); add(r.base, from.toLowerCase(), -n, '', from); return ' '; });
    // the bonus of the ear it is worn in counts as the rest of the piece
    const ear = line.match(/^(Left|Right) ear:\s*/i);
    if (ear && ear[1].toLowerCase() === side) { mode = null; line = line.slice(ear[0].length); if (!line.trim()) continue; }
    line = unsigned(line, r.base);
    // "Cannot Equip Headgear DEF:51..." (Twilight Cloak, Onca Suit): what follows is the piece's, not a condition
    line = line.replace(/^Cannot [Ee]quip \w+\s*/, '');
    // "Unity Ranking: HP+30～80" (Blistering Sallet +1): your Unity's weekly ranking gives it all the time, not a
    // condition; at its top, as the game measured it (2026-10-04: Sailfi Belt +1 Attack +15, Gelatinous Ring +1 HP +35)
    // "Mastery Rank: All BP -30 to +30" (Hoxne Earring): the seven attributes by your mastery rank (BG Wiki: rank 1
    // -30 ... 4 +0 ... 10 +30), read by the export (packet 0x01B); a condition while the rank is not known
    const mrank = /^Mastery Rank:\s*All BP/i.test(line) && (measuredChar() || {}).mastery_rank;
    if (mrank && MASTERY_BP[mrank] != null) {
      mode = null;
      for (const a of ['str', 'dex', 'vit', 'agi', 'int', 'mnd', 'chr']) add(r.base, a, MASTERY_BP[mrank], '', a.toUpperCase());
      continue;
    }
    const unity = line.match(/^Unity Ranking:\s*/i);
    if (unity) {
      mode = null;
      const u = {}; parseLine(line.slice(unity[0].length), u);
      for (const [k, e] of Object.entries(u)) { add(r.base, k, e.v, e.unit, e.label); r.unity[k] = (r.unity[k] || 0) + e.v; }
      continue;
    }
    if (COND.test(line)) mode = /^(Pet|Avatar|Automaton|Wyvern|Luopan):/.test(line) ? 'pet' : 'cond';
    if (mode === 'pet') { const f = parseLine(line.replace(/^[A-Za-z]+:\s*/, ''), r.pet); if (f) r.cond.push(f); continue; }
    // one condition per entry: its title line, then the lines under it ("Aftermath:" / "Increases Accuracy...")
    if (mode === 'cond') {
      if (COND.test(line) || cur < 0) cur = r.cond.push(line.trim()) - 1;
      else r.cond[cur] += (/[,:]$/.test(r.cond[cur]) ? ' ' : ' · ') + line.trim();
      continue;
    }
    // "STR:10" (Cornelia's Belt): an attribute written with a colon is STR+10
    line = line.replace(/\b(STR|DEX|VIT|AGI|INT|MND|CHR|HP|MP):(\d+)/g, '$1+$2');
    // a hand-to-hand weapon writes "DMG:+39 Delay:+51": its delay is added to the base 480
    line = line.replace(/\b(DEF|DMG|Delay):\s?(\+?)(\d+)/g, (_, k, plus, n) => {
      if (k === 'DEF') add(r.base, 'def', +n, '', 'DEF');
      else (r.weapon = r.weapon || {})[k] = k === 'Delay' && plus ? 480 + +n : +n;
      return ' '; });
    const free = parseLine(line, r.base);
    if (free) r.free.push(free);
  }
  // Fast Cast the description only names ("Enhances "Fast Cast" effect"): its value, from BG-Wiki
  const hidden = HIDDEN_FC[p.name];
  if (hidden && r.free.some(f => /(Enhances|Increases) "Fast Cast" effect/.test(f))) {
    add(r.base, 'fc', hidden, '%', 'Fast Cast');
    r.free = r.free.map(f => f.replace(/(Enhances|Increases) "Fast Cast" effect/, '').trim()).filter(Boolean);
    r.hidden = true;
  }
  // another effect the description only names (Brutal Earring: Enhances "Double Attack" effect): the engine's value
  // (atelier/engine/catalog, BG Wiki's), when it has one for that stat
  const engineIt = window.FFXI && FFXI.opt && FFXI.opt.item ? FFXI.opt.item(p.name) : null;
  const named = f => { for (const [re, key] of HIDDEN_PHRASES) { const m = f.match(re); if (m) return key || STAT_ALIAS[normName(m[1])]; } return null; };
  const hiddenOf = f => { const k = named(f), v = k && !r.base[k] && engineIt && (engineIt.stats || {})[ENGINE_STAT[k]];
    if (v) { add(r.base, k, v, '', f); r.hidden = true; } return !!v; };
  r.free = r.free.filter(f => !hiddenOf(f));
  r.cond.forEach(hiddenOf);
  // The set's augments; without any, those //gs c gearscan read on the character's own copy
  const scan = scanOf()[p.name];
  let augs = p.augs;
  if (!augs && scan && !scan.differ && scan.augments) { augs = scan.augments; r.scanned = true; }
  for (const a of augs || []) {
    const path = a.match(/^Path:\s*(\w+)/); if (path) { r.path = path[1]; continue; }
    if (/^System:/.test(a)) continue;
    addAugment(a, r);
  }
  // The rank gearscan read on the character's copy, when that copy is the one the set names:
  // same path, or the scanned augments themselves
  if (scan && scan.rank != null && (r.path ? scan.path === r.path : r.scanned || (augs && !scan.differ))) {
    r.rank = scan.rank; r.path = r.path || scan.path;
  }
  // A piece asked at a rank (your copy at its best): that rank's stats from the local catalogue
  if (p.rank != null && r.path && rankedEntry(p.name)) {
    r.rank = p.rank; r.rankStats = true; r.atRank = true;
    addRanked(p.name, r.path, p.rank, r);
  }
  // A path's rank stats (Odyssey gear), known when the scanned copy is on the same path
  else if (r.path && scan && scan.path === r.path && scan.rank_stats) {
    r.rankStats = true;
    for (const a of scan.rank_stats) addAugment(a, r);
  }
  // a path whose rank gearscan never read: its top rank, as the engine counts it (atelier/engine augments_parse:
  // rank_assumed), said in the hover card
  else if (r.path && rankedEntry(p.name)) {
    const top = rankedEntry(p.name).max_rank;
    if (top != null) { r.rank = top; r.rankStats = true; r.rankAssumed = true; addRanked(p.name, r.path, top, r); }
  }
  for (const part of [r.base, r.aug]) for (const [k, e] of Object.entries(part)) add(r.stats, k, e.v, e.unit, e.label);
  return (PIECE_CACHE[key] = r);
}
// What the game writes its own way: SIRD without a sign ("Spell interruption rate down 10%"),
// elemental resistances as the element's icon (U+E000 fire ... U+E007 dark, the in-game order)
const ELEMENTS = ['fire', 'ice', 'wind', 'earth', 'lightning', 'water', 'light', 'dark'];
function unsigned(line, out){
  return line.replace(/Spell interruption rate down\s*-?(\d+)%/gi, (_, n) => { add(out, 'sird', +n, '%', 'SIRD'); return ' '; })
    .replace(/[-]/g, c => ' ' + ELEMENTS[c.charCodeAt(0) - 0xE000] + ' resistance');
}
// The catalogue's stat names, as the page names them ([key, unit]); the rest are shown as effects
const RANK_KEYS = {Accuracy: 'acc', 'Ranged Accuracy': 'racc', 'Magic Accuracy': 'macc', 'Store TP': 'stp', PDL: 'pdl', 'Crit Rate': 'crit',
  'Crit Damage': 'critdmg', Attack: 'atk', 'Ranged Attack': 'ratk', 'Weapon Skill Damage': 'wsd', DA: 'da', TA: 'ta', QA: 'qa', 'Magic Attack': 'mab',
  'Magic Damage': 'mdmg', 'Magic Burst Damage': 'mbd', 'Magic Burst Damage II': 'mbd2', STR: 'str', DEX: 'dex', VIT: 'vit', AGI: 'agi', INT: 'int',
  MND: 'mnd', CHR: 'chr', 'Subtle Blow': 'sb', 'Subtle Blow II': 'sb2', 'TP Bonus': 'tpb', DT: 'dt', PDT: 'pdt', Counter: 'counter', Regen: 'regen',
  Refresh: 'refresh', Evasion: 'eva', 'Magic Evasion': 'meva', 'Magic Defense': 'mdb', Defense: 'def', HP: 'hp', MP: 'mp', 'Cure Potency': 'cure',
  'Skillchain Bonus': 'scb', Enmity: 'enmity', 'Spell Interruption Down': 'sird', 'Fast Cast': 'fc', 'Enhancing Duration': 'enhdur',
  'Gear Haste': 'haste', 'Block Rate': 'block', 'Dual Wield': 'dw', 'Healing Magic Skill': 'skill:healing magic skill',
  'Enhancing Magic Skill': 'skill:enhancing magic skill', 'Enfeebling Magic Skill': 'skill:enfeebling magic skill',
  'Dark Magic Skill': 'skill:dark magic skill', 'Shield Skill': 'skill:shield skill', 'Parrying Skill': 'skill:parrying skill'};
// A path's stats at a rank, added to the piece (TP Bonus is kept in tenths there)
function addRanked(name, path, rank, r){
  for (const [k, v0] of Object.entries(FFXI.ranked_stats(name, path, rank) || {})) {
    if (!v0) continue;
    // the table already scales TP Bonus (its keys: "TP Bonus": 10): Ikenga's Axe R23 is +200, as the game shows
    const v = v0, pet = k.match(/^(Pet|Avatar|Automaton|Wyvern|Luopan):(.+)$/);
    const key = RANK_KEYS[pet ? pet[2] : k];
    if (key) add(pet ? r.pet : r.aug, key, v, PCT.has(key) ? '%' : '', pet ? pet[2] : k);
    else r.free.push(`${k} ${v > 0 ? '+' : ''}${v}`);
  }
}
// An Ambuscade cape with each material at its maximum (thread, dust, dye, sap, resin: BG Wiki,
// atelier/engine/catalog/capes.js), from the augments the copy carries; the materials it lacks named
const CAPE_MAX = [[/^(STR|DEX|VIT|AGI|INT|MND|CHR)\+\d+$/, 20, 10], [/^(HP|MP)\+\d+$/, 60, 20], [/Accuracy\+\d+ Attack\+\d+|Rng\.Acc\.\+\d+ Rng\.Atk\.\+\d+|Mag\. Acc\+\d+ \/Mag\. Dmg\.\+\d+|Eva\.\+\d+ \/Mag\. Eva\.\+\d+/, 20],
  [/^(Accuracy|Attack|Rng\.Acc\.|Rng\.Atk\.|Mag\. Acc\.|Mag\. Dmg\.|Evasion|Mag\. Evasion)\+\d+$/, 10],
  [/Weapon skill damage|Crit\.hit rate|"Store TP"|"Dbl\.Atk\."|^Haste|"Dual Wield"|^Enmity|"Snapshot"|"Mag\.Atk\.Bns\."|"Fast Cast"|"Cure" potency|"Waltz" potency/, 10],
  [/^DEF\+\d+$/, 50], [/Phys\. dmg\. taken|Magic dmg\. taken|Mag\. dmg\. taken/, 10], [/^Damage taken/, 5], [/Spell interruption rate down|Occ\. inc\. resist/, 10],
  [/^"Regen"\+\d+$|Chance of successful block|Parrying rate/, 5], [/^"Counter"\+\d+$/, 10]];
function capeMax(p){
  const ambu = window.FFXI && FFXI.AMBU_CAPES && FFXI.AMBU_CAPES.some(c => c.en === p.name || c.name === p.name);
  if (!ambu || !p.augs || !p.augs.length) return null;
  const seen = {}, augs = [];
  let changed = false;
  for (const a of p.augs) {
    const rule = CAPE_MAX.find(([re]) => re.test(a));
    if (!rule) { augs.push(a); continue; }
    // the same attribute twice: the first is the thread's (20), the second the dye's (10)
    const attr = a.match(/^(STR|DEX|VIT|AGI|INT|MND|CHR|HP|MP)\+/), twice = attr && seen[attr[1]];
    if (attr) seen[attr[1]] = true;
    const max = twice && rule[2] ? rule[2] : rule[1];
    const out = a.replace(/([+-])\d+/g, (m, sign) => sign + max);
    if (out !== a) changed = true;
    augs.push(out);
  }
  const has = re => p.augs.some(a => re.test(a));
  const missing = [[/^(STR|DEX|VIT|AGI|INT|MND|CHR|HP|MP)\+\d+$/, 'matThread'], [/Accuracy\+\d+ Attack\+\d+|Rng\.Acc\.\+\d+ Rng\.Atk\.|Mag\. Acc\+\d+ \/|Eva\.\+\d+ \//, 'matDust'],
    [/Weapon skill damage|Crit\.hit rate|"Store TP"|"Dbl\.Atk\."|^Haste|"Dual Wield"|^Enmity|"Snapshot"|"Mag\.Atk\.Bns\."|"Fast Cast"|"Cure" potency|"Waltz" potency/, 'matSap'],
    [/dmg\. taken|^Damage taken|^DEF\+|"Regen"|"Counter"|block|Parrying|interruption|resist/, 'matResin']].filter(([re]) => !has(re)).map(([, k]) => t(k));
  if (!changed && !missing.length) return null;
  return {piece: {name: p.name, augs, capeMax: true}, missing};
}
// Your copy at its best: a rank item at its highest rank, an Ambuscade cape at each material's maximum
function upgradeOf(p){
  const r = pieceStats(p), e = rankedEntry(p.name);
  if (e && r && r.path && e.paths && e.paths[r.path] && (r.rank == null || r.rank < e.max_rank)) {
    const augs = p.augs && p.augs.length ? p.augs : ['Path: ' + r.path];
    return {piece: {name: p.name, augs, rank: e.max_rank}, from: r.rank, to: e.max_rank};
  }
  return capeMax(p);
}
function addAugment(a, r){
  a = unsigned(a, r.aug);
  a = a.replace(/DMG:\s?\+?(\d+)/, (_, n) => { (r.weapon = r.weapon || {}).DMG = ((r.weapon || {}).DMG || 0) + +n; return ' '; });
  for (const part of a.split(/(?=Pet:)/)) {
    const pet = /^Pet:/.test(part);
    const free = parseLine(part.replace(/^Pet:\s*/, ''), pet ? r.pet : r.aug);
    if (free) r.free.push(free);
  }
}
// Fast Cast hidden behind "Enhances "Fast Cast" effect" (BG-Wiki; Guide_Paladin gear_pld.py)
const HIDDEN_FC = {"Loquac. Earring": 2, "Prolix Ring": 2, "Orunmila's Torque": 5};
// Effects a description names without a value (Brutal Earring, Charis Feather, Locus Ring, Lycurgos...): the stat
// they are (null: the quoted name's), their value taken from the engine's catalogue
const HIDDEN_PHRASES = [[/^(?:Enhances|Increases) "([^"]+)" effect$/i, null], [/^(TP Bonus) based on/i, null],
  [/^Increases critical hit damage$/i, 'critdmg'], [/^Bonus damage added to magic burst$/i, 'mbd'], [/Increases magic burst damage/i, 'mbd']];
// The engine's name of a page stat, for the effects a description only names
const ENGINE_STAT = {da: 'DA', ta: 'TA', qa: 'QA', stp: 'Store TP', crit: 'Crit Rate', critdmg: 'Crit Damage', wsd: 'Weapon Skill Damage',
  dw: 'Dual Wield', haste: 'Gear Haste', tpb: 'TP Bonus', sb: 'Subtle Blow', acc: 'Accuracy', atk: 'Attack', fc: 'Fast Cast',
  str: 'STR', dex: 'DEX', vit: 'VIT', agi: 'AGI', int: 'INT', mnd: 'MND', chr: 'CHR', hp: 'HP', mp: 'MP', racc: 'Ranged Accuracy',
  ratk: 'Ranged Attack', macc: 'Magic Accuracy', mab: 'Magic Attack', eva: 'Evasion', meva: 'Magic Evasion', mdb: 'Magic Defense',
  def: 'DEF', pdl: 'PDL', dt: 'DT', pdt: 'PDT', mdt: 'MDT', enmity: 'Enmity', mdmg: 'Magic Damage', mbd: 'Magic Burst Damage'};
// What //gs c gearscan read on your copies (augments, a path's rank): the character's, newest export last, whatever job's
// export carries it (a job exported without it counted the Path pieces at rank 0, the engine at their best)
let SCAN_MEMO = {key: null, out: null};
const scanOf = () => { const key = DATA_GEN + '|' + S.char; if (SCAN_MEMO.key === key) return SCAN_MEMO.out;
  const all = Object.values(DATA[S.char] || {}).flatMap(j => Object.values(j)).filter(x => x.scan).sort((a, b) => (a.at || '').localeCompare(b.at || ''));
  return (SCAN_MEMO = {key, out: Object.assign({}, ...all.map(x => x.scan))}).out; };
const descTexts = () => mergedOf('descs');
// Every gear item of the game (data/atelier/catalog.js, written by the export from Windower's
// resources: shared/utils/atelier/atelier_catalog.lua), loaded when the picker asks for it.
// Rows: [id, name, slots, jobs, level, item level, description, rare 1/0 (from catalog v2), ex 1/0 (v3), alt 1/0 (v4)]
let CAT = null;
function catalog(){
  const c = window.ATELIER_CATALOG;
  if (!c) return null;
  if (!CAT || CAT.src !== c) { CAT = {src: c, id: {}, desc: {}, row: {}, rare: new Set(), ex: new Set(), alt: new Set()};
    // several items of one name (Kusanagi's stages): the highest item level, then the last id (its last stage), as the
    // engine reads it; a copy you hold is read by its own id (the export's icons)
    for (const r of c.items) { const o = CAT.row[r[1]]; if (!o || (r[5] || 0) > (o[5] || 0) || ((r[5] || 0) === (o[5] || 0) && r[0] > o[0])) { CAT.id[r[1]] = r[0]; CAT.row[r[1]] = r; } CAT.desc[r[0]] = r[6];
      if (r[7]) CAT.rare.add(r[1]); if (r[8]) CAT.ex.add(r[1]); if (r[9]) CAT.alt.add(r[1]); } }
  return CAT;
}
// Whether a character can hold two of an item: not Rare, as the game's resources say (an older catalog without
// the flag: never assumed)
// A Rare item (the game's flag, from the catalog): one copy a character, whatever its augments
const isRare = name => { const c = catalog(); return !!c && c.rare.has(name); };
function twoAllowed(name){ const c = catalog(); return !!c && c.src.v >= 2 && !c.rare.has(name); }
// A piece's badges for its hover card, in the game's order and look: Alt (it can be sent to your other characters),
// Aug (it carries augments), Rare and Ex (the catalog, from the game's flags)
function rareExHTML(name, aug){
  const c = catalog();
  const b = [c && c.alt.has(name) ? `<i class="alt">Alt</i>` : '', aug ? `<i class="aug">Aug</i>` : '', c && c.rare.has(name) ? `<i class="rare">Rare</i>` : '', c && c.ex.has(name) ? `<i class="ex">Ex</i>` : ''].join('');
  return b ? `<span class="rx">${b}</span>` : '';
}
function loadCatalog(done){
  if (window.ATELIER_CATALOG) return done();
  const el = document.createElement('script');
  el.src = 'atelier/catalog.js';
  el.onload = () => { el.remove(); done(); };
  el.onerror = () => { el.remove(); S._catMissing = true; done(); };
  document.head.appendChild(el);
}
// Stats counted in points: a % of them (HP+10%) is its own line, key 'hp%'
const FLAT = new Set(['hp','mp','def','str','dex','vit','agi','int','mnd','chr','acc','atk','racc','ratk','eva','meva','macc','mab','mdb','enmity','mdmg']);
const baseKey = key => key.endsWith('%') ? key.slice(0, -1) : key;
const statLabel = (key, e) => STAT_DEF[baseKey(key)] ? STAT_DEF[baseKey(key)][S.lang === 'fr' ? 1 : 2] + (key.endsWith('%') ? ' %' : '') : e.label;
const statGroup = key => STAT_DEF[baseKey(key)] ? STAT_DEF[baseKey(key)][0] : key.startsWith('skill:') ? 'skill' : 'other';
const fmtStat = e => (e.v > 0 ? '+' : e.v < 0 ? '−' : '') + Math.abs(e.v) + (e.unit ? ' %' : '');
// One stat row, three aligned columns: name, value, then the difference or the cap
const statLi = (label, value, extra = '', cls = '', tip = '') =>
  `<li class="${cls}"${tip ? ` title="${esc(tip)}"` : ''}><span title="${label}">${label}</span><b>${value}</b><i>${extra}</i></li>`;
const signed = n => (n > 0 ? '+' : n < 0 ? '−' : '') + Math.abs(n);
// Past the cap the game counts the cap: the line shows it, with the total and what goes to waste
function cappedLi(label, sum, cap, detail){
  const r = x => Math.round(x * 10) / 10, over = Math.abs(sum) > Math.abs(cap);
  if (!over) return statLi(label, signed(r(sum)) + ' %', `cap ${signed(cap)} %`, '', detail);
  return `<li class="over"${detail ? ` title="${esc(detail)}"` : ''}><span title="${label}">${label}</span><b>${signed(cap)} %</b><i>cap</i>` +
    `<em class="overl">${t('overCap', {t: signed(r(sum)), n: r(Math.abs(sum - cap))})}</em></li>`;
}
// A damage taken with its II stat on one line: the first layer stops at -50 %, the II one adds past it, -87.5 % in all
// (the line's total; its small text: the first layer against its cap, what is wasted past it, the II)
function layeredLi(label, raw, two, name, detail){
  const r = x => Math.round(x * 10) / 10, first = Math.max(raw, -50), total = Math.max(first + two, -87.5), over = raw < -50 ? r(-50 - raw) : 0;
  const extra = `${signed(r(first))} / −50` + (over ? ` (${t('cmpOver', {n: over})})` : '') + ` + ${name} ${signed(two)}`;
  return statLi(label, signed(r(total)) + ' %', extra, '', `${detail} = ${r(raw)}, ${t('dtCapNote')} ; + ${name} ${two} = ${r(total)} % (−87,5 % max)`);
}
// Damage taken (Guide_Paladin, 03_defense): DT + PDT and DT + MDT stop at -50 %; PDT II
// (Burtgang) and MDT II (Aegis) go on past it, up to -87.5 % in all
function damageTakenLines(v){
  // the totals before the cap, so a line shows what is wasted past it
  // Shell (Buffs and conditions) lowers magic damage under the same -50 % cap: its share counts here
  const B = buffTotals(), shell = B.shell ? Math.round(-B.shell / 256 * 1000) / 10 : 0;
  const pdtRaw = v('dt') + v('pdt'), mdtRaw = v('dt') + v('mdt') + shell, pdt = Math.max(pdtRaw, -50), mdt = Math.max(mdtRaw, -50);
  // one line a kind of damage: with a II stat (PDT II: Burtgang, MDT II: Aegis) its total, the two layers in its detail
  const pDetail = `DT ${v('dt')} + PDT ${v('pdt')}`, mDetail = `DT ${v('dt')} + MDT ${v('mdt')}` + (shell ? ` + ${buffState().shell} ${shell}` : '');
  let out = v('pdt2') ? layeredLi(t('pdtTotal'), pdtRaw, v('pdt2'), 'PDT II', pDetail) : cappedLi(t('pdtEff'), pdtRaw, -50, pDetail);
  out += v('mdt2') ? layeredLi(t('mdtTotal'), mdtRaw, v('mdt2'), 'MDT II', mDetail) : cappedLi(shell ? t('mdtShell') : t('mdtEff'), mdtRaw, -50, mDetail);
  if (v('bdt')) out += cappedLi(t('bdtEff'), v('dt') + v('bdt'), -50, `DT ${v('dt')} + BDT ${v('bdt')}`);
  return out;
}
// One piece's stats as label / value rows, in the groups' order
function statRows(stats){
  const keys = Object.keys(stats).filter(k => stats[k].v && statVisible(k)), sorter = statSorter(curSet(), stats);
  const ordered = S.statSort === 'group' ? STAT_GROUPS.flatMap(([g]) => keys.filter(k => statGroup(k) === g).sort(sorter)) : keys.sort(sorter);
  return ordered.map(k => statLi(esc(statLabel(k, stats[k])), fmtStat(stats[k]))).join('');
}
const STAT_ORDER = Object.keys(STAT_DEF);
const statOrder = (a, b) => (STAT_ORDER.indexOf(a) + 1 || 999) - (STAT_ORDER.indexOf(b) + 1 || 999) || a.localeCompare(b);
// What the set's gear brings: every piece added up, the caps shown where the game has one
function setStats(s){
  const total = {}, paths = [], unknown = [], cond = [], pieces = withWeapons(s).pieces;
  for (const slot of SLOTS) {
    const p = pieces[slot], r = pieceStats(p, slot);
    if (!r) continue;
    if (!r.known) unknown.push(p.name);
    if (r.path && !r.rankStats) paths.push(`${p.name} (Path ${r.path})`);
    for (const [k, e] of Object.entries(r.stats)) add(total, k, e.v, e.unit, e.label);
    for (const c of r.cond) cond.push(`${p.name} — ${c}`);
  }
  return {total, paths, unknown, cond};
}
/* ---- which stats the set stats and the simulation show (S.statHide: the keys left out) ---- */
// 'dtEff' stands for the damage taken lines (DT+PDT, DT+MDT, PDT II / MDT II, breath)
const statShown = k => !S.statHide[k];
const DT_KEYS = ['dt', 'pdt', 'mdt', 'pdt2', 'mdt2', 'bdt'];
// The set shown in the Sets tab (what "the set is after" refers to), or null
const curSet = () => { try { return S._cards && S.sel[S.job] != null ? shownSet(S._cards[S.sel[S.job]], S.sel[S.job]) : null; } catch (e) { return null; } };
// One filter for every stat list: the ticks (S.statHide), "only what the set is after" (S.statOnlyWant,
// damage taken always kept) and the order (S.statSort: by group, what the set is after first, A to Z)
function statVisible(k, s = curSet()){
  const b = baseKey(k);
  if (!statShown(DT_KEYS.includes(b) ? 'dtEff' : b)) return false;
  if (!S.statOnlyWant || !s || DT_KEYS.includes(b)) return true;
  return wantOf(setWants(s).want, k) >= 0.3;
}
function statSorter(s = curSet(), stats = {}){
  const want = s && S.statSort === 'want' ? setWants(s).want : null;
  if (want) return (a, b) => wantOf(want, b) - wantOf(want, a) || statOrder(a, b);
  if (S.statSort === 'name') return (a, b) => statLabel(a, stats[a] || {}).localeCompare(statLabel(b, stats[b] || {}));
  return statOrder;
}
const statPickBtn = () => { const n = Object.keys(S.statHide).length;
  const bits = [S.statPreset ? `« ${esc(S.statPreset)} »` : '', n ? t('statHidden', {n}) : '', S.statOnlyWant ? t('statOnlyShort') : '',
    S.statSort !== 'group' ? t('statSort_' + S.statSort) : ''].filter(Boolean);
  return `<button class="linkbtn statpickbtn" data-statpick>${t('statPick')}${bits.length ? ' · ' + bits.join(' · ') : ''}</button>`; };
// Above the ticks: the order, "only what the set is after", the saved filters
function statPickTools(){
  const sorts = ['group', 'want', 'name'].map(k => `<button class="seg ${S.statSort === k ? 'on' : ''}" data-statsort="${k}">${t('statSort_' + k)}</button>`).join('');
  const presets = Object.keys(S.statPresets).sort().map(n => `<span class="chip ${S.statPreset === n ? 'on' : ''}"><button class="linkbtn" data-statpreset="${esc(n)}">${esc(n)}</button>` +
    `<button class="linkbtn x" data-statdel="${esc(n)}" title="${esc(t('statDel'))}">×</button></span>`).join('');
  return `<div class="pickTools"><div><b>${t('statSortLbl')}</b><span class="segs">${sorts}</span></div>` +
    `<label class="chk"><input type="checkbox" id="statonly" ${S.statOnlyWant ? 'checked' : ''}> ${t('statOnly')}</label>` +
    `<div class="presets"><b>${t('statPresets')}</b>${presets || `<span class="muted small">${t('statNoPreset')}</span>`}` +
    `<input id="statpresetname" class="nameinput" placeholder="${esc(t('statPresetName'))}" value="${esc(S.statPreset)}"><button class="btn ghost" data-statsave>${t('statSave')}</button></div></div>`;
}
// One column per stat group, in its colour: a title band with all / none, one tick per line
function openStatPick(){
  const keys = ['dtEff'].concat(Object.keys(STAT_DEF).filter(k => !['dt', 'pdt', 'mdt', 'pdt2', 'mdt2', 'bdt'].includes(k)));
  const groups = STAT_GROUPS.map(([g, fr, en]) => {
    const list = keys.filter(k => (k === 'dtEff' ? 'def' : statGroup(k)) === g);
    if (!list.length) return '';
    const on = list.filter(statShown).length;
    return `<section class="box g-${g} pickcol"><header class="boxh"><h3>${S.lang === 'fr' ? fr : en}</h3>` +
      `<span class="meta">${on}/${list.length} · <button class="linkbtn" data-statgroup="${g}|1">${t('statAll')}</button> · ` +
      `<button class="linkbtn" data-statgroup="${g}|0">${t('statNone')}</button></span></header><div class="pickrows">` +
      list.map(k => `<label class="pickrow"><input type="checkbox" class="statpick" data-stat="${k}" ${statShown(k) ? 'checked' : ''}>` +
        `<span>${esc(k === 'dtEff' ? t('dtEff') : statLabel(k, {}))}</span></label>`).join('') + `</div></section>`; }).join('');
  $('#overlay').innerHTML = `<div class="scrim" data-close></div><div class="dialog statpickdlg" role="dialog" aria-label="${t('statPick')}">
    <header><h3>${t('statPick')}</h3><p class="muted small">${t('statPickWhy')}</p>${statPickTools()}</header>
    <div class="body"><div class="pickgrid">${groups}</div></div>
    <footer><span><button class="btn ghost" data-statall>${t('statAll')}</button> <button class="btn ghost" data-statnone>${t('statNone')}</button></span>
      <button class="btn" data-close>${t('close')}</button></footer></div>`;
  $('#overlay').hidden = false;
}
function setStatsHTML(s){
  const {total, paths, unknown, cond} = setStats(s);
  const v = k => (total[k] || {}).v || 0;
  const capped = (label, sum, cap, detail) => cappedLi(label, sum, cap, detail);
  const sorter = statSorter(s, total), lineOf = k => { const cap = STAT_DEF[k] && STAT_DEF[k][3];
    return cap ? capped(esc(statLabel(k, total[k])), total[k].v, cap, t('gearOnly')) : statLi(esc(statLabel(k, total[k])), fmtStat(total[k])); };
  // what the set is after: a tab of its own, first and open by default, by weight (damage taken on top);
  // the groups keep the rest
  const wantFirst = setWants(s).want;
  const isWanted = k => wantFirst && !DT_KEYS.includes(baseKey(k)) && wantOf(wantFirst, k) >= 0.3;
  const wantedKeys = wantFirst ? Object.keys(total).filter(k => total[k].v && isWanted(k) && statVisible(k, s)).sort(sorter) : [];
  const groups = STAT_GROUPS.map(([g, fr, en]) => {
    const keys = Object.keys(total).filter(k => total[k].v && statGroup(k) === g && !isWanted(k) && statVisible(k, s)).sort(sorter);
    let rows = keys.map(lineOf).join('');
    // Damage taken: DT counts in both, physical and magic, up to -50 % together
    if (g === 'def' && (v('dt') || v('pdt') || v('mdt')) && statShown('dtEff'))
      rows = damageTakenLines(v) + rows;
    return rows ? {key: g, label: S.lang === 'fr' ? fr : en, n: (rows.match(/<li[ >]/g) || []).length, body: `<ul class="statlist">${rows}</ul>`} : null;
  }).filter(Boolean);
  if (wantedKeys.length) { const dt = (v('dt') || v('pdt') || v('mdt')) && statShown('dtEff') ? damageTakenLines(v) : '', rows = dt + wantedKeys.map(lineOf).join('');
    groups.unshift({key: 'want', label: t('cmpWanted'), n: (rows.match(/<li[ >]/g) || []).length, body: `<ul class="statlist">${rows}</ul>`}); }
  const notes = [];
  if (paths.length) notes.push(`<p>${t('pathNote')} ${paths.map(esc).join(', ')}</p>`);
  if (unknown.length) notes.push(`<p>${t('unknownNote')} ${unknown.map(esc).join(', ')}</p>`);
  // what only applies sometimes (Set:, latent, Unity, Aftermath...): a tab of its own, one line per effect, its piece first
  if (cond.length) groups.push({key: 'cond', label: t('condTab'), n: cond.length, body: `<ul class="condlist">${cond.map(c => { const [piece, ...txt] = c.split(' — ');
    return `<li><b>${esc(piece)}</b><span>${esc(txt.join(' — '))}</span></li>`; }).join('')}</ul>`});
  if (!(groups.length || Object.keys(S.statHide).length || S.statOnlyWant)) return '';
  // one group at a time, its tab kept from set to set (the first when that group is not there)
  const cur = groups.find(g => g.key === S._statTab) || groups[0];
  const tabs = groups.map(g => `<button role="tab" data-stattab="${g.key}" aria-selected="${g === cur}">${esc(g.label)}<small>${g.n}</small></button>`).join('');
  return `<div class="setstats"><div class="sshead"><span class="kicker">${t('setStats')}</span>${statPickBtn()}</div>` +
    `<div class="stabs" role="tablist">${tabs}</div>${cur ? `<div class="stabbody">${cur.body}</div>` : ''}${notes.join('')}</div>`;
}

