// GearSwap Atelier · stat_figures.js: a set's figures as the stats optimizer counts them (statFigures, opt.js
// O.statFigures), the tank figures the Paladin guide adds (Shield Barrier, the Protect gift, the shields' block) and
// the HP cycle; the optimizer reads them, atelier/src/screens/sets/figures.ts shows them
// (loaded before stat_opt.js, whose statContext and withVec it calls: see atelier/src/legacy/files.ts)

const CRUSADE_ENMITY = 30;

/* ---- the tank figures the guide adds (Guide_Paladin 03 Defense, 02 Enmity), shown in the Tanking compartment ---- */
// Shield Barrier (PLD trait): Protect cast by a PLD adds its shield's DEF (taken when cast; here the set's shield).
// Returns the buff totals with it (a copy), or as they are
// Only on a Protect you cast yourself (BG Wiki: "Protect spells cast by a Paladin"; the buffs window's Protect row says
// when another job casts it: protectOther), the gift's +10 % on it too
function shieldBarrier(B, sub){
  const b = buffState();
  if (S.job !== 'PLD' || !PROTECT[b.protect] || b.protectOther || !sub || isEmpty(sub)) return B;
  const it = itemOf(sub.name), r = it && it.Type === 'Shield' ? pieceStats(sub, 'sub') : null, def = r && r.stats.def ? Math.floor(r.stats.def.v * protectGift()) : 0;
  if (!def) return B;
  return Object.assign({}, B, {def: (B.def || 0) + def, _by: B._by.concat([{src: 'Shield Barrier · ' + sub.name, k: 'def', v: def}])});
}
// A PLD's job gift Protect Effect (BG Wiki Paladin: Protect received +10 %, from 550 job points spent): the factor on
// Protect's Defense (on the shield's part too: BG Wiki does not say, to check in game)
function protectGift(){
  const c = typeof measuredChar === 'function' ? measuredChar() : null;
  return S.job === 'PLD' && c && (c.jp_spent || 0) >= 550 ? 1.1 : 1;
}
// Whether the set's shield blocks every hit at its base already (Duban, Ochain: ~108 %): its block gains nothing more
function shieldBlocksAll(s){
  const sub = (withWeapons(s).pieces.sub || {}).name, sh = ULTIMATE_SHIELDS[sub];
  return !!sh && sh[0] >= 100;
}
// The shields the guide gives figures for: base block rate (at the attacker's skill) and the damage a block takes off
// (the lines that read them: atelier/src/screens/sets/figures.ts tankExtra)
const ULTIMATE_SHIELDS = {Aegis: [50, 75], Srivatsa: [50, 75], Ochain: [108, 60], Duban: [108, 60]};
// A set's figures (the try as shown, or plain: the file's set)
function statFigures(s, plain){
  const pieces = plain ? withoutTrial(() => withWeapons(s).pieces) : withWeapons(s).pieces;
  const v = {};
  for (const [slot, p] of Object.entries(optPieces(pieces))) v[slot] = withVec(p, slot);
  return FFXI.opt.statFigures(statContext(s).stat, v);
}

/* ---- the HP cycle (Guide_Paladin HP Management): every action's sets, idle -> precast -> midcast -> idle ---- */
// A set's max HP as shown (its tried pieces in), the character's HP without gear given
function setMaxHp(x, nakedHp){
  const v = {};
  for (const [slot, p] of Object.entries(optPieces(withWeapons(x).pieces))) v[slot] = withVec(p, slot);
  return FFXI.opt.statFigures({base: {hp: nakedHp}}, v).hp;
}
// The actions and their sets: each spell with a midcast set (its own name, or a name it shares: sets.midcast.Flash =
// sets.FullEnmity) after its Fast Cast (sets.precast.FC.<spell>, the self Cure's, else sets.precast.FC); each job
// ability's set alone. Actions with the same two sets go on one line
function hpCycleRows(){
  const by = S._bypath || {}, d = data(), fc = by['sets.precast.FC'], out = new Map();
  const pathOf = (root, name) => by[`${root}.${name}`] || by[`${root}["${name}"]`];
  const paths = new Set();
  for (const x of d.sets) for (const p of [x.path, ...(x.aliases || [])]) paths.add(p);
  for (const p of paths) {
    const sg = segs(p);
    let pre = null, mid = null, name = sg[sg.length - 1];
    if (sg[0] === 'midcast' && sg.length === 2) {
      mid = by[p];
      pre = /cur(e|a)/i.test(name) && /self/i.test(name) ? (Object.values(by).find(x => family(x.path, x.pieces) === 'fc' && /cure/i.test(x.path) && /self/i.test(x.path)) || fc) : pathOf('sets.precast.FC', name) || fc;
    } else if (sg[0] === 'precast' && sg[1] === 'JA' && sg.length === 3) pre = by[p];
    else continue;
    if (!pre && !mid) continue;
    const key = (pre ? pre.path : '') + '|' + (mid ? mid.path : '');
    if (!out.has(key)) out.set(key, {pre, mid, names: [], ja: !mid, self: !!mid && /cure/i.test(name) && /self/i.test(name)});
    out.get(key).names.push(name);
  }
  return [...out.values()];
}
