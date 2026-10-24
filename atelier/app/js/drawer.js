// GearSwap Atelier · drawer.js: the pieces offered for a slot (their window: gear_pick.js), what a set is after
// (loaded by atelier/index.html, in the order of the list there)
/* ---- the pieces offered for a slot ---- */
function openSlot(ci, slot){
  if (!window.ATELIER_CATALOG && !S._catMissing) return loadCatalog(() => openSlot(ci, slot));
  if (!S._rankTried) { S._rankTried = true; return loadRanked(() => openSlot(ci, slot)); }
  const card = S._cards[ci]; const vi = Math.min(S.variant[S.job+'|'+ci] ?? 0, card.variants.length-1);
  const s = card.variants[vi].set, eff = withWeapons(s), p = eff.pieces[slot];
  const label = SLOT_NAMES[S.lang][slot];
  S._drawer = {ci, slot, set: s};
  // the set's own piece (as written, weapon modes included) and the one tried now
  const orig = withoutTrial(() => withWeapons(s).pieces[slot]);
  // a piece named without augments is any copy of that name: the first one listed stands for it
  const sameAs = (o, q) => q && o.piece && o.piece.name === q.name && (o.piece.rank ?? null) === (q.rank ?? null) && !q.capeMax
    && (q.augs && q.augs.length ? (o.piece.augs || []).join('|') === q.augs.join('|') : opts.find(x => x.piece.name === q.name) === o);
  const opts = S._drawOpts = pieceChoices(slot, p, orig, s);
  for (const o of opts) { o.orig = sameAs(o, orig); o.cur = eff.tried[slot] && sameAs(o, p);
    // the piece tried is this row's best version
    o.curMax = !!(eff.tried[slot] && o.upgrade && samePiece(o.upgrade.piece, p)); }
  // a window over the page with filters (gear_pick.js)
  gpOpen(card, s, slot, p, opts, label);
}
// What the drawer offers for a slot: each copy in the bags the job can wear (with its own
// augments), then the pieces the job's sets name and the bags do not hold; the most used first
function pieceChoices(slot, current, orig, s){
  // how many sets use a piece: per copy (name and augments) when the sets name augments
  const seen = {}, kin = {}, d = data(), copyKey = q => q.name + '|' + (q.augs || []).join('|'), fam = s && family(s.path, s.pieces);
  // rings and earrings: either side counts. kin = names worn in a set of the same kind (another weaponskill)
  const sides = {ring1: ['ring1', 'ring2'], ring2: ['ring1', 'ring2'], ear1: ['ear1', 'ear2'], ear2: ['ear1', 'ear2']}[slot] || [slot];
  for (const x of d.sets) for (const sl of sides) { const q = x.pieces[sl]; if (!q) continue;
    if (sl === slot) { seen[q.name] = (seen[q.name] || 0) + 1; seen[copyKey(q)] = (seen[copyKey(q)] || 0) + 1; }
    if (fam && family(x.path, x.pieces) === fam) kin[q.name] = true; }
  const owned = (ownedOf() || {})[slot], names = (ofAnySub('items') || {})[slot] || [];
  const list = owned ? owned.map(x => ({piece: {name: x.name, augs: x.augs}, owned: true, where: x.where, count: x.count}))
    : names.map(n => ({piece: {name: n}, owned: true}));
  const have = new Set(list.map(o => o.piece.name));
  for (const x of d.sets) { const q = x.pieces[slot];
    if (q && q.name !== 'empty' && !have.has(q.name)) { have.add(q.name); list.push({piece: {name: q.name, augs: q.augs}, owned: false}); } }
  for (const q of [orig, current]) if (q && q.name !== 'empty' && !list.some(o => sameCopy(o, q))) list.push({piece: q, owned: false});
  for (const o of list) o.seen = (o.piece.augs && o.piece.augs.length ? seen[copyKey(o.piece)] : seen[o.piece.name]) || 0;
  // your pieces not at their best yet: the same copy at its highest rank, a cape at each material's
  // maximum, kept on your row (its chip, Shift while hovering, Shift+click)
  for (const o of list) if (o.owned) o.upgrade = upgradeOf(o.piece);
  // a path piece listed: its other paths at their top rank, as copies to get (shown with the whole game)
  const mine = list.filter(o => o.owned).map(o => o.piece);
  for (const name of new Set(list.map(o => o.piece.name))) for (const o of pathCopies(name, mine) || [])
    if (!list.some(x => sameCopy(x, o.piece))) list.push(o);
  // the game's other items for this slot and this job; a path piece on each of its paths
  const cat = S.allItems && window.ATELIER_CATALOG, all = new Set(list.map(o => o.piece.name));
  if (cat) for (const r of cat.items) if (!all.has(r[1]) && r[2].split(' ').includes(slot) && r[3].split(' ').includes(S.job)) {
    all.add(r[1]);
    const paths = pathCopies(r[1], mine);
    if (paths) for (const o of paths) list.push(Object.assign(o, {lv: r[4], ilv: r[5]}));
    else list.push({piece: {name: r[1]}, owned: false, cat: true, lv: r[4], ilv: r[5]}); }
  // below level 99 with no item level: costumes, crafting smocks, old gear; a piece a set names stays in its group
  const isOrig = isOrigOf(list, orig), rows = (catalog() || {}).row || {};
  for (const o of list) { const r = rows[o.piece.name];
    o.orig = isOrig(o); o.lv = o.lv ?? (r && r[4]); o.ilv = o.ilv ?? (r && r[5]);
    o.low = o.lv != null && o.lv < 99 && !o.ilv; }
  if (s) relevance(s, slot, list);
  // an effect that holds only in a place the set is named after (Councilor's Garb, "While in Adoulin:", in
  // sets.Adoulin): the set is worn there, so the piece is of use whatever its level, first of its group
  if (s) placeEffects(s, slot, list);
  // of no use for the set (never the set's own piece): below level 99 with no item level; armour
  // with no item level (level 119 armour replaced it); none of the stats the set is after; or less
  // than a quarter of what the best choice for the slot gives of them
  const best = Math.max(0, ...list.map(o => o.score || 0)), armour = ['head', 'body', 'hands', 'legs', 'feet'].includes(slot);
  // the hands: a weapon is not judged on the set's stats but on whether it can be there (weaponWhy), ranked by
  // the weaponskill's damage when the set is a weaponskill's; below level 99 with no item level, it is set aside
  // like the armour (only that rule: a level 99 weapon with no item level can still be the right one)
  if (WEAPON_SLOTS.has(slot) && slot !== 'ammo') weaponRanks(s, slot, list);
  for (const o of list) {
    if (o.placed) o.score = Math.max(o.score || 0, best);
    o.why = o.placed ? '' : WEAPON_SLOTS.has(slot) && slot !== 'ammo' ? (o.low ? t('whyLow', {n: o.lv}) : weaponWhy(s, slot, o.piece))
      : o.low ? t('whyLow', {n: o.lv}) : armour && o.lv != null && !o.ilv ? t('whyNoIlv') : o.lowersDamage ? ''
      : o.offTopic ? t('whyNone') : best && (o.score || 0) < best / 4 ? t('whyWeak') : '';
    // a piece you wear in a set of the same kind is never set aside: you chose it for such sets
    o.junk = !o.orig && !kin[o.piece.name] && !!o.why;
    o.grp = o.orig ? 0 : o.junk ? 5 : o.cat ? 4 : !o.owned ? 3 : o.seen ? 1 : 2; }
  return list.sort((a, b) => (a.grp - b.grp) || ((b.score || 0) - (a.score || 0)) || (b.seen - a.seen) || a.piece.name.localeCompare(b.piece.name));
}
// The pieces whose effect holds only in a place the set's name says (its path: sets.Adoulin, "While in Adoulin:"):
// marked placed, that effect added to what they bring the set
function placeEffects(s, slot, list){
  const where = s.path.toLowerCase();
  for (const o of list) {
    const r = !o.cat && pieceStats(o.piece, slot);
    const hits = ((r && r.cond) || []).map(c => /^While in ([^:]+):\s*(.+)$/i.exec(c)).filter(m => m && where.includes(m[1].trim().toLowerCase()));
    if (hits.length) { o.placed = true; o.fit = (o.fit || []).concat(hits.map(m => m[2])); }
  }
}
// The paths of a path piece (Kaykaus, Odyssey...) your copies are not on (heldPaths, optimizer.js), each at its top
// rank; null when the piece has no paths
function pathCopies(name, mine){
  const e = rankedEntry(name);
  if (!(e && e.paths)) return null;
  const held = heldPaths(name, e, mine);
  return Object.keys(e.paths).filter(path => !held.has(path)).map(path => ({piece: {name, augs: ['Path: ' + path], rank: e.max_rank}, owned: false}));
}
// Why a weapon cannot go in a hand of this set ('' when it can): a weaponskill's main hand takes the weapons that
// open it, an off hand what the main hand takes (subWhy)
function weaponWhy(s, slot, p){
  const ws = s && wsOfSet(s);
  if (slot === 'main' && ws && !heldChoices(ws).includes(p.name)) return t('whyNotWs', {ws});
  if (slot === 'sub') return subWhy(withWeapons(s).pieces.main, p);
  return '';
}
// A weaponskill's main hands ranked by its damage with each (heldRanking, worked out in the background)
function weaponRanks(s, slot, list){
  const ws = s && wsOfSet(s);
  if (slot !== 'main' || !ws) return;
  const rank = heldRanking(s, ws, heldChoices(ws)) || {}, top = Math.max(0, ...Object.values(rank));
  for (const o of list) if (rank[o.piece.name] != null && top) { o.score = rank[o.piece.name] / top; o.fit = [fmtDmg(rank[o.piece.name])]; }
}
// What a set is after: the stats that make a piece worth trying in it, with a weight. A piece
// that gives none of them is off topic for the set (so is any piece below level 99 with no item
// level: costumes, crafting smocks, old gear). HP, MP, DEF and the attributes a set does not use
// never count on their own: every level 119 piece has them.
// Weaponskill: its attributes (shared/data/weaponskills, exported as ws_info) by their %, Weapon Skill
// Damage, TP Bonus, Skillchain Bonus; physical: Attack, Accuracy, PDL, DA / TA / QA; magical: Magic
// Attack, Magic Accuracy, Magic Damage. Other sets by their kind and name (Cure, Phalanx, nukes...);
// a set of no known kind: the stats its own pieces carry, the common ones left out.
const GENERIC = new Set(['hp', 'mp', 'def', 'str', 'dex', 'vit', 'agi', 'int', 'mnd', 'chr', 'acc', 'atk', 'racc', 'ratk', 'macc', 'eva', 'meva', 'mdb']);
const WANTS = {
  engaged: 'acc atk haste da ta qa stp crit critdmg dw sb sb2 dt pdt mdt regain counter',
  idle: 'dt pdt mdt pdt2 mdt2 bdt meva mdb eva refresh regen move',
  fc: 'fc curecast',
  cure: 'cure cure2 mnd vit sird enmity skill:healing*',
  enhancing: 'enhdur phalanx regen refresh sird skill:enhancing*',
  enfeebling: 'macc mnd int skill:enfeebling*',
  elemental: 'mab macc mdmg mbd mbd2 int skill:elemental*',
  dark: 'macc int mab skill:dark*',
  divine: 'macc mnd mab skill:divine*',
  song: 'skill:singing* skill:wind* skill:string* chr macc',
  geomancy: 'skill:geomancy* skill:handbell* cmp',
  ninjutsu: 'macc mab skill:ninjutsu*',
  enmity: 'enmity sird fc',
};
// Damage taken counts in every set: a piece that lowers it is never set aside
const ALWAYS = {dt: 0.8, pdt: 0.8, mdt: 0.8, pdt2: 0.8, mdt2: 0.8};
function setWants(s){
  const r = setWantsOf(s);
  return Object.assign(r, {want: Object.assign({}, ALWAYS, r.want)});
}
function setWantsOf(s){
  const fam = family(s.path, s.pieces), path = s.path, add = (out, list, w = 1) => { for (const k of list.split(' ')) out[k] = Math.max(out[k] || 0, w); return out; };
  if (fam === 'ws') return wsWants(s);
  // a self Cure (Guide_Paladin CURE SELF): its midcast wants max HP too (the gap the Cure fills), its Fast Cast few HP
  const self = /cur(e|a)/i.test(path) && /self/i.test(path);
  if (fam === 'fc' && self) return {fam, want: add({}, WANTS.fc + ' hp hp%', 1), label: 'Cure Self',
    notes: [S.lang === 'fr' ? 'HP le plus bas possible : le set de Cure les remonte, le Cure remplit l’écart' : 'HP as low as can be: the Cure set raises them, the Cure fills the gap']};
  if (WANTS[fam]) return {fam, want: add({}, WANTS[fam])};
  if (fam === 'midcast' || fam === 'ja' || fam === 'special') {
    // a Blue Magic set wants what its spell is (Healing: a cure's stats); "blue" itself has no wants here
    const kind = magicKindOf(path) === 'blue' ? magicKindOf(path.replace(/blue magic/ig, '')) : magicKindOf(path);
    if (kind && WANTS[kind]) return {fam, want: add({}, WANTS[kind] + (kind === 'cure' && self ? ' hp hp%' : ''))};
  }
  // no known kind: what the set's own pieces carry, the stats every piece has left out
  const out = {};
  for (const p of Object.values(withoutTrial(() => withWeapons(s).pieces))) {
    const r = pieceStats(p);
    for (const [k, e] of Object.entries((r && r.stats) || {})) if (e.v && !GENERIC.has(baseKey(k))) out[baseKey(k)] = 1;
  }
  return {fam, want: out};
}
// What a weaponskill is after, from how it deals its damage (shared/data/weaponskills, exported
// as ws_info) at the TP chosen on the set (S.wsTp, 2000 by default), against the target of the
// Target window:
//   Weapon Skill Damage only lifts the first hit: worth most on a one-hit WS with a big fTP
//     (Disaster), little on five hits that carry fTP 1.0 each (Rampage);
//   DA / TA / QA add hits: worth the share one more hit brings;
//   critical weaponskills (Rampage, Blade: Hi, Chant du Cygne...) live on Crit rate, Crit damage, DEX;
//   TP Bonus is worth something only when fTP (or the crit rate) moves with TP, and not at 3000;
//   Attack is worth little once the attack / defense ratio reaches the pDIF cap: PDL raises that cap;
//   Accuracy likewise once the hit rate is capped;
//   the WS's attributes by their % (Disaster: STR 60, VIT 60).
function wsWants(s){
  const ws = wsForSet(s);
  const info = wsInfoOf(ws);
  const tp = Math.min(3000, Math.max(1000, S.wsTp || 3000)), ftps = Object.entries(info.ftp || {}).map(([k, v]) => [+k, v]).sort((a, b) => a[0] - b[0]);
  const ftpAt = x => { if (!ftps.length) return 1; if (x <= ftps[0][0]) return ftps[0][1];
    for (let i = 1; i < ftps.length; i++) if (x <= ftps[i][0]) { const [a, va] = ftps[i - 1], [c, vc] = ftps[i]; return va + (vc - va) * (x - a) / (c - a); }
    return ftps[ftps.length - 1][1]; };
  const f = ftpAt(tp), hits = info.hits || 1, rest = info.replicating ? f : 1, total = f + (hits - 1) * rest;
  const first = f / total, extra = rest / total, flat = ftps.length > 1 && ftps.every(e => e[1] === ftps[0][1]);
  const magical = /magic/i.test(info.type || ''), hybrid = /hybrid/i.test(info.type || ''), physical = !magical || hybrid;
  const ranged = /archery|marksmanship/i.test(wsSkills()[ws] || '');
  const T = targetInfo(s), atkCapped = physical && T.atk && T.atk >= T.pdifCap * T.defAfter;
  const accCapped = physical && T.acc && T.acc >= T.evaAfter + 2 * (T.cap - 75);
  const out = {wsd: 0.5 + 1.5 * first, scb: 0.4};
  out.tpb = tp >= 3000 ? 0 : flat && !info.crit ? 0.1 : 1;
  for (const [a, pct] of Object.entries(info.mods || {})) out[a.toLowerCase()] = Math.max(0.4, pct / 50);
  if (physical) {
    Object.assign(out, ranged ? {ratk: 1, racc: 1} : {atk: atkCapped ? 0.15 : 1, acc: accCapped ? 0.15 : 1});
    out.pdl = atkCapped ? 1.6 : 0.6;
    for (const k of ['da', 'ta', 'qa']) out[k] = 0.3 + 3 * extra;
    out.crit = info.crit ? 1.8 : 0.25; out.critdmg = info.crit ? 1.5 : 0.25;
    if (info.crit) out.dex = Math.max(out.dex || 0, 0.6);
  }
  if (magical || hybrid) Object.assign(out, {mab: 1.5, macc: 0.8, mdmg: 1.5});
  // what the page read, in words, for the drawer
  const notes = [t('wsHits', {n: hits}) + (info.replicating ? ' · ' + t('wsRepl') : ''),
    ftps.length ? t('wsFtp', {f: Math.round(f * 100) / 100, tp}) : '', info.crit ? t('wsCrit') : '',
    atkCapped ? t('wsAtkCap') : '', accCapped ? t('wsAccCap') : '', out.tpb <= 0.1 ? t('wsTpbNo') : ''].filter(Boolean);
  return {fam: 'ws', want: out, label: ws, notes};
}
// The weight of a stat key for a set (skill:enhancing magic skill matches skill:enhancing*)
function wantOf(want, key){
  const k = baseKey(key);
  if (k in want) return want[k];
  for (const [w, v] of Object.entries(want)) if (w.endsWith('*') && k.startsWith(w.slice(0, -1))) return v;
  return 0;
}
// The direction that is good for a stat: less damage taken, less enmity on a Cure, more of the rest
const GOOD_DOWN = new Set(['dt', 'pdt', 'mdt', 'pdt2', 'mdt2', 'bdt']);
// How much a piece gives of what the set is after: each wanted stat, the piece's value against the
// best choice's, times its weight. A ranking, not a simulation (the optimizer computes damage).
// o.score, o.fit (its best stats for the set), o.offTopic when it gives none of them
function relevance(s, slot, opts){
  const {want} = setWants(s), cure = /cur(e|a)/i.test(s.path), tank = ['PLD', 'RUN'].includes(S.job);
  // a tank's Cure wants its enmity (the guide: a Cure's enmity holds hate); a self Cure's Fast Cast wants few HP
  const lowHp = cure && /self/i.test(s.path) && family(s.path, s.pieces) === 'fc';
  const dir = k => GOOD_DOWN.has(baseKey(k)) || (baseKey(k) === 'enmity' && cure && !tank) || (lowHp && /^hp%?$/.test(baseKey(k))) ? -1 : 1;
  const good = (k, v) => Math.max(0, dir(k) * v);
  const stats = opts.map(o => pieceStats(o.piece, slot) || {}), max = {};
  for (const r of stats) for (const [k, e] of Object.entries(r.stats || {})) if (wantOf(want, k)) max[k] = Math.max(max[k] || 0, good(k, e.v));
  opts.forEach((o, i) => {
    const parts = Object.entries(stats[i].stats || {}).filter(([k, e]) => wantOf(want, k) && max[k] && good(k, e.v))
      .map(([k, e]) => [k, e, wantOf(want, k) * good(k, e.v) / max[k]]);
    o.score = parts.reduce((a, x) => a + x[2], 0);
    o.fit = parts.sort((a, b) => b[2] - a[2]).slice(0, 3).map(([k, e]) => `${statLabel(k, e)} ${fmtStat(e)}`);
    o.offTopic = stats[i].known !== false && !o.score;
    o.lowersDamage = Object.entries(stats[i].stats || {}).some(([k, e]) => GOOD_DOWN.has(baseKey(k)) && e.v < 0);
  });
}
// The stats a set is after, as the drawer names them
function wantsLine(s){
  const {want, label, notes} = setWants(s);
  const keys = Object.keys(want).filter(k => !k.endsWith('*') && !(k in ALWAYS) && want[k] >= 0.3).sort((a, b) => want[b] - want[a] || statOrder(a, b));
  const skills = Object.keys(want).filter(k => k.endsWith('*')).map(k => k.slice(6, -1));
  const names = keys.map(k => statLabel(k, {label: k.toUpperCase()})).concat(skills.map(x => t('skillOf', {s: x})), [t('wantsDt')]);
  const why = notes && notes.length ? `<br><span class="wsnotes">${esc(label)} : ${esc(notes.join(' · '))}</span>` : '';
  return names.length ? t('wantsLine', {w: esc(names.join(' · '))}) + why : '';
}
// a set naming no augments wears any copy of that name (GearSwap picks one): it is one of yours
const sameCopy = (o, q) => o.piece.name === q.name && (!(q.augs && q.augs.length) || (o.piece.augs || []).join('|') === q.augs.join('|'));
const isOrigOf = (list, orig) => o => !!orig && sameCopy(o, orig) && (orig.augs && orig.augs.length || o === list.find(x => sameCopy(x, orig)));
