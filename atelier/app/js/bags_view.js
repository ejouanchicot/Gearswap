// GearSwap Atelier · bags_view.js: the "Bags" view of the My character tab: every bag of the character as the game
// holds it (export `bags`: shared/utils/atelier/atelier_export_bags.lua), to see where everything is before tidying.
// On top, each bag as a tile with how full it is, what is on the character apart from the Mog House; a click shows
// that bag, "All the bags" shows each item once with the bags it is in. A search, the kinds of items as filters, and
// "In several bags": what is split between bags and could be put together.
// The bags are the character's, not a job's: the freshest export that holds them is read.
// (loaded after module_items.js: see atelier/src/legacy/files.ts)

Object.assign(T.fr, {bvLockedTip: '{b} : sac pas débloqué, il garde ses {c} objet(s) mais rien ne peut y entrer.', bvStats: 'Stats & mérites', bvBags: 'Sacs', bvStatsTip: 'Tes stats mesurées en jeu, PorterPacker et tes mérites.', bvBagsTip: 'Le contenu de chacun de tes sacs, pour voir où est quoi.',
  bvNone: 'Cet export ne contient pas tes sacs. En jeu, tape //gs c atelier (ou recharge ton job) : ils seront lus et affichés ici.',
  bvAt: 'Sacs lus en jeu le {at}. Les sacs du Mog House sont ceux de ta dernière visite.', bvSelf: 'Sur toi', bvHouse: 'Mog House', bvPorter: 'Rangé ailleurs', bvPorterTip: '{c} pièce(s) confiée(s) au Porter Moogle, sur tes slips. Clique pour les voir.', bvAll: 'Tous les sacs', bvAllSub: 'chaque objet une fois', bpPlanSub: 'est-ce que ça rentre ?',
  bvTileTip: '{b} : {c} emplacement(s) pris sur {m}, {f} libre(s). Clique pour voir son contenu.', bvAllTip: 'Chaque objet une seule fois, avec les sacs où il se trouve.',
  bvSearch: 'Chercher un objet…', bvCatAll: 'Tout', bvDup: 'Dans plusieurs sacs', bvDupTip: 'Seulement les objets présents dans plus d’un sac : ce qui pourrait être regroupé.',
  bvNoSet: 'aucun set', bvNoSetTip: 'Dans aucun set des jobs lus.', bvCfg: 'réglages', bvUsedBy: 'Porté par : {l} (nombre de sets).', bvCfgTip: 'Nommé dans : {l}.',
  bvLs: 'style {l}', bvUseLock: 'Lockstyle', bvGoes: 'Sa place : {d}.', bvUseAll: 'Tout', bvUseBad: 'Mal rangé', bvUseNone: 'Dans aucun set',
  bvRoleOf: 'Ce sac sert à', bvRole2: 'et aussi à', bvRole2Tip: 'Un second rôle : deux sortes d’objets se partagent la place de ce sac.', bvRoleTip: 'Dis à quoi sert ce sac : la page signale ce qui n’y a pas sa place. Rien ne bouge en jeu.', bvBadN: '{n} objet(s) mal rangé(s) dans ce sac.',
  bvRs_free: 'libre', bvRs_job: 'job en cours', bvRs_gear: 'autres jobs', bvRs_spare: 'lockstyle, surplus', bvRs_unused: 'inutilisé', bvRs_craft: 'craft', bvRs_usable: 'consommables', bvRs_mats: 'vente, craft', bvRs_currency: 'currencies', bvRs_keys: 'objets clés', bvRs_furnish: 'meubles', bvRs_slips: 'slips', bvRs_archive: 'archives',
  bvR_free: 'pas de règle', bvR_job: 'job en cours', bvR_gear: 'équipement des jobs', bvR_unused: 'ce qui ne sert pas', bvR_craft: 'craft', bvR_usable: 'consommables', bvR_mats: 'à vendre et composants de craft', bvR_currency: 'currencies', bvR_keys: 'objets clés (améliorations, accès)', bvR_spare: 'lockstyle, pièces à activer et surplus', bvR_furnish: 'meubles et rangement', bvR_slips: 'slips', bvR_archive: 'archives',
  bvW_role: 'pas dans un sac de sa catégorie', bvW_spare: 'en surplus ici alors qu’il reste de la place dans les sacs des jobs', bvW_inv: 'rangé par le plan hors de l’inventaire', bvW_far: 'porté par un set, mais ne peut pas être équipé depuis ce sac', bvW_type: 'pas le type d’objet de ce sac', bvW_unused: 'dans aucun set : ce sac est pour l’équipement qui sert',
  bvW_used: 'porté par un set : ce sac est pour ce qui ne sert pas', bvUseOne: 'Un seul job', bvUseMany: 'Plusieurs jobs', bvUseTip: 'Qui porte chaque pièce, d’après les sets des jobs exportés : {j}. Un job jamais exporté ne compte pas, et les lockstyles ne sont pas connus de la page.',
  bvEmpty: 'Ce sac est vide.', bvNoHit: 'Aucun objet ne correspond.', bvCount: '{n} objet(s) · {s} emplacement(s)',
  bvC_Weapon: 'Armes', bvC_Armor: 'Armures', bvC_Usable: 'Utilisables', bvC_General: 'Divers', bvC_Furnishing: 'Mobilier', bvC_Automaton: 'Automate', bvC_Maze: 'Labyrinthe', bvC_Slips: 'Storage Slips', bvC_Gil: 'Gils'});
Object.assign(T.en, {bvLockedTip: '{b}: bag not unlocked, it keeps its {c} item(s) but nothing can go in.', bvStats: 'Stats & merits', bvBags: 'Bags', bvStatsTip: 'Your stats measured in game, PorterPacker and your merits.', bvBagsTip: 'What each of your bags holds, to see where everything is.',
  bvNone: 'This export does not hold your bags. In game, type //gs c atelier (or reload your job): they will be read and shown here.',
  bvAt: 'Bags read in game on {at}. The Mog House bags are those of your last visit.', bvSelf: 'On you', bvHouse: 'Mog House', bvPorter: 'Stored elsewhere', bvPorterTip: '{c} piece(s) left with the Porter Moogle, on your slips. Click to see them.', bvAll: 'All the bags', bvAllSub: 'each item once', bpPlanSub: 'does it fit?',
  bvTileTip: '{b}: {c} slot(s) taken of {m}, {f} free. Click to see what it holds.', bvAllTip: 'Each item once, with the bags it is in.',
  bvSearch: 'Search an item…', bvCatAll: 'All', bvDup: 'In several bags', bvDupTip: 'Only the items held in more than one bag: what could be put together.',
  bvNoSet: 'no set', bvNoSetTip: 'In no set of the jobs read.', bvCfg: 'settings', bvUsedBy: 'Worn by: {l} (number of sets).', bvCfgTip: 'Named in: {l}.',
  bvLs: 'style {l}', bvUseLock: 'Lockstyle', bvGoes: 'Its place: {d}.', bvUseAll: 'All', bvUseBad: 'Misplaced', bvUseNone: 'In no set',
  bvRoleOf: 'This bag is for', bvRole2: 'and also for', bvRole2Tip: 'A second role: two kinds of things share this bag’s room.', bvRoleTip: 'Say what this bag is for: the page points at what has no place in it. Nothing moves in game.', bvBadN: '{n} item(s) misplaced in this bag.',
  bvRs_free: 'free', bvRs_job: 'job loaded', bvRs_gear: 'other jobs', bvRs_spare: 'lockstyle, overflow', bvRs_unused: 'unused', bvRs_craft: 'crafting', bvRs_usable: 'consumables', bvRs_mats: 'sale, crafting', bvRs_currency: 'currencies', bvRs_keys: 'key items', bvRs_furnish: 'furniture', bvRs_slips: 'slips', bvRs_archive: 'archive',
  bvR_free: 'no rule', bvR_job: 'job loaded', bvR_gear: 'the jobs’ gear', bvR_unused: 'what is not used', bvR_craft: 'crafting', bvR_usable: 'consumables', bvR_mats: 'to sell and crafting materials', bvR_currency: 'currencies', bvR_keys: 'key items (upgrades, entries)', bvR_spare: 'lockstyle, pieces to activate and overflow', bvR_furnish: 'furniture and storage', bvR_slips: 'slips', bvR_archive: 'archive',
  bvW_role: 'not in a bag of its category', bvW_spare: 'overflow here while the jobs’ bags have room', bvW_inv: 'filed by the plan out of the inventory', bvW_far: 'worn by a set, but cannot be put on from this bag', bvW_type: 'not this bag’s kind of item', bvW_unused: 'in no set: this bag is for the gear in use',
  bvW_used: 'worn by a set: this bag is for what is not used', bvUseOne: 'One job only', bvUseMany: 'Several jobs', bvUseTip: 'Who wears each piece, from the sets of the jobs exported: {j}. A job never exported does not count, and the page does not know the lockstyles.',
  bvEmpty: 'This bag is empty.', bvNoHit: 'No item matches.', bvCount: '{n} item(s) · {s} slot(s)',
  bvC_Weapon: 'Weapons', bvC_Armor: 'Armor', bvC_Usable: 'Usable', bvC_General: 'Misc', bvC_Furnishing: 'Furnishing', bvC_Automaton: 'Automaton', bvC_Maze: 'Maze', bvC_Slips: 'Storage Slips', bvC_Gil: 'Gil'});

const BV_CATS = ['Weapon', 'Armor', 'Usable', 'General', 'Slips', 'Furnishing', 'Automaton', 'Maze'];
const bvCatName = c => t('bvC_' + c) !== 'bvC_' + c ? t('bvC_' + c) : c || '?';
// The bags of the freshest export that holds them, with what is kept at the Porter Moogle as one more "bag" (export
// `porter`: {item id: 'Slip N'}; the names come from the page's gear catalog)
let BV_BAGS = null;
function bvBags(){
  // the bags read last, by their own date (two jobs exported in one minute carry the same export date)
  const x = Object.values(DATA[S.char] || {}).flatMap(j => Object.values(j)).filter(e => e.bags).sort((a, b) => (b.bags.at || '').localeCompare(a.bags.at || ''))[0]; if (!x) return null;
  const px = latestExport(S.char, 'porter'), cat = typeof catalog === 'function' && catalog(), key = DATA_GEN + '|' + S.char + '|' + !!cat;
  if (BV_BAGS && BV_BAGS.key === key) return BV_BAGS.B;
  // A wardrobe the character has not unlocked (the game sends it with its size, enabled false) takes nothing: an empty
  // one is left out, one that still holds things is shown full, so no plan or move ever sends anything there
  const bags = x.bags.bags.filter(b => b.enabled !== false || b.items.length)
    .map(b => b.enabled === false ? Object.assign({}, b, {max: b.items.length, count: b.items.length, locked: true}) : b);
  const B = {at: x.bags.at, run: x.bags.run, bags, items: Object.assign({}, x.bags.items)};
  // the Storage Slips: a kind of their own in the list (the game files them as Maze, the Maze Mongers' kind)
  for (const [id, it] of Object.entries(B.items)) if (it && /^Storage Slip/.test(it.name)) B.items[id] = Object.assign({}, it, {cat: 'Slips'});
  if (px && px.porter && cat) { if (!cat.byId) { cat.byId = {}; for (const r of cat.src.items) cat.byId[r[0]] = r; }
    const items = [];
    for (const [id, slip] of Object.entries(px.porter)) { const r = cat.byId[id]; if (!r) continue;
      items.push({id: +id, n: 1, slip});
      if (!B.items[id]) B.items[id] = {name: r[1], cat: /\b(main|sub|range|ammo)\b/.test(r[2] || '') && !/Shield|Grip/.test(r[10] || '') ? 'Weapon' : 'Armor'}; }
    if (items.length) B.bags.push({id: -1, name: 'Porter Moogle', place: 'porter', count: items.length, items}); }
  BV_BAGS = {key, B};
  return B;
}
const bvNorm = s => String(s).toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '');
// One copy of an item as a key: two capes with other augments are two things, two stacks of one potion are one
const bvKey = it => it.id + '|' + (it.augs || []).join('|');
// Where each thing is: {key: [{bag, n, slots}]}, across every bag
function bvWhere(B){
  const by = {};
  for (const bag of B.bags) for (const it of bag.items) { const k = bvKey(it), list = by[k] = by[k] || [], at = list.find(w => w.bag === bag.name);
    if (at) { at.n += it.n; at.slots++; } else list.push({bag: bag.name, n: it.n, slots: 1, slip: it.slip}); }
  return by;
}
// The rows of the list: one a thing, {key, id, info, augs, n (count), slots, where}
function bvRowsRaw(B, sel, where){
  const rows = new Map();
  for (const bag of B.bags) { if (sel !== 'all' && bag.name !== sel) continue;
    for (const it of bag.items) { const k = bvKey(it), info = B.items[it.id] || {name: '#' + it.id}, r = rows.get(k) || {key: k, id: it.id, info, augs: it.augs, n: 0, slots: 0, where: where[k], use: bvUseOf(info.name)};
      r.n += it.n; r.slots++; rows.set(k, r); } }
  return [...rows.values()];
}
function bvRows(B, sel, where){
  const out = bvRowsRaw(B, sel, where);
  for (const r of out) r.bad = bvBad(B, r).filter(x => sel === 'all' || x.bag === sel);
  return out;
}
function bvFilter(rows){
  const q = bvNorm(S.bagQ || ''), cat = S.bagCat || 'all';
  const use = S.bagUse || 'all', nj = r => Object.keys(r.use.jobs).length;
  const used = r => use === 'all' || (use === 'unk' ? bpCat(bvBags(), r) === 'unknown' : use === 'bad' ? r.bad.length > 0 : use === 'lock' ? bvLockSets(r).length > 0 : use === 'none' ? bvIsGear(r) && !nj(r) && !r.use.files.size && !bvLockSets(r).length : use === 'one' ? nj(r) === 1 : use === 'many' ? nj(r) > 1 : nj(r) > 0);
  const pc = S.bagPc || '', B0 = pc ? bvBags() : null;
  return rows.filter(r => used(r) && (!pc || bpCat(B0, r) === pc) && (cat === 'all' || r.info.cat === cat) && (!S.bagDup || r.where.length > 1) && (!q || bvNorm(r.info.name + ' ' + (r.augs || []).join(' ')).includes(q)));
}
const bvRank = c => { const i = BV_CATS.indexOf(c); return i < 0 ? 99 : i; };
// A bag's name in a few letters, for the tags of the list (Wardrobe 3 -> W3, Mog Safe 2 -> Safe 2)
const bvShort = n => n === 'Wardrobe' ? 'W1' : n.replace(/^Wardrobe (\d)$/, 'W$1').replace(/^Mog /, '').replace(/^Porter Moogle$/, 'Porter').replace(/^Inventory$/, 'Inv.');
/* ---- who uses what ---- */
// For every item name (lower case): the jobs whose sets wear it, with how many of their sets ({JOB: n}), and the
// settings files that name it (a refill list, the TP Bonus pieces, the cure items). From every export of the
// character: a job never exported is not counted, and the page says which jobs were read.
let BV_USE = null;
function bvUsage(){
  const key = DATA_GEN + '|' + S.char;
  if (BV_USE && BV_USE.key === key) return BV_USE;
  const by = {}, jobs = [], at = n => by[n.toLowerCase()] = by[n.toLowerCase()] || {jobs: {}, files: new Set()};
  for (const [job, subs] of Object.entries(DATA[S.char] || {})) {
    const paths = {};                                    // a set counted once, whatever the subjob it was exported with
    for (const x of Object.values(subs)) for (const s of x.sets || []) for (const p of Object.values(s.pieces || {})) if (p && p.name && p.name !== 'empty') (paths[p.name.toLowerCase()] = paths[p.name.toLowerCase()] || new Set()).add(s.path);
    if (Object.keys(paths).length) jobs.push(job);
    for (const [n, set] of Object.entries(paths)) at(n).jobs[job] = set.size;
    // the names its settings files hold (lists and tables of lines)
    const x = Object.values(subs).sort((a, b) => (b.at || '').localeCompare(a.at || ''))[0];
    for (const f of (x && x.configs) || []) { let fields = []; try { fields = Object.values(modParsed(f).byPath); } catch (e) {}
      for (const fld of fields) if (fld.kind === 'list' || fld.kind === 'rows') for (const v of mrNames(fld.value)) if (typeof v === 'string' && v.length > 2) at(v).files.add(f.file.split('/').pop()); }
  }
  return (BV_USE = {key, by, jobs: jobs.sort()});
}
const bvUseOf = name => bvUsage().by[String(name).toLowerCase()] || {jobs: {}, files: new Set()};
const bvIsGear = r => r.info.cat === 'Weapon' || r.info.cat === 'Armor';
// The numbers of the lockstyle sets a piece is in (bags_plan.js bpLock: '4 (WAR)' -> '4')
const bvLockSets = r => (bpLock()[r.id] || []).map(s => s.split(' ')[0]);
const bvUseTip = r => { const u = r.use, jobs = Object.entries(u.jobs).sort((a, b) => b[1] - a[1]);
  return [jobs.length ? t('bvUsedBy', {l: jobs.map(([j, n]) => j + ' (' + n + ')').join(', ')}) : bvIsGear(r) ? t('bvNoSetTip') : '', u.files.size ? t('bvCfgTip', {l: [...u.files].join(', ')}) : ''].filter(Boolean).join('\n'); };
/* ---- what each bag is for, and what is not where it should be ---- */
// The roles a bag can be given. The player chooses (kept in the browser, S.bagRoles by character and bag); until then a
// wardrobe has the role its rules give it (WARDROBE_CONFIG.lua: USED, UNUSED, NEVER_TOUCH), another bag the one of a
// usual layout (BV_ROLE_START).
const BV_ROLES = ['free', 'job', 'gear', 'spare', 'unused', 'craft', 'usable', 'mats', 'currency', 'keys', 'furnish', 'slips', 'archive'];
const bvEquips = n => n === 'Inventory' || /^Wardrobe/.test(n);
const bvBagOf = n => { const m = /^w(?:ardrobe)? ?(\d)?$/i.exec(String(n).trim()); return m ? 'Wardrobe' + (m[1] && m[1] !== '1' ? ' ' + m[1] : '') : ''; };
function bvRoleGuess(B, bag){
  if (bag.place === 'porter') return 'archive';
  if (/^Wardrobe/.test(bag.name)) {
    const x = latestExport(S.char, 'configs'), f = x && x.configs.find(c => c.file.endsWith('/WARDROBE_CONFIG.lua'));
    let p = {}; try { p = f ? modParsed(f).byPath : {}; } catch (e) {}
    const list = k => ((p[k] && p[k].kind === 'list' && p[k].value) || []).map(bvBagOf);
    if (list('NEVER_TOUCH').includes(bag.name)) return 'craft';
    if (list('USED').includes(bag.name)) return 'job';
    // the first bag of UNUSED is the reserve, the others hold the gear of the jobs not loaded
    const un = list('UNUSED'); return un[0] === bag.name ? 'spare' : 'gear';
  }
  // the other bags start with a usual layout, every category with a home (the player changes any of them):
  // what is carried sorted by kind, the Mog House for what is kept
  return BV_ROLE_START[bag.name] || 'free';
}
const BV_ROLE_START = {'Mog Case': 'usable', 'Mog Satchel': 'mats+slips', 'Mog Sack': 'mats', 'Mog Safe': 'currency+furnish', 'Mog Safe 2': 'currency+keys', 'Storage': 'unused', 'Mog Locker': 'unused'};
const bvRole = (B, bag) => ((S.bagRoles || {})[S.char] || {})[bag.name] || bvRoleGuess(B, bag);
// Why a thing is not where it should be in a bag of that role ('' when it is): a key of the texts
function bvWrong(r, bagName, role){
  const gear = bvIsGear(r), sets = Object.keys(r.use.jobs).length > 0, named = r.use.files.size > 0;
  // a piece a set wears can only be put on from the inventory or a wardrobe: nowhere else, unless a copy is there
  // (the Porter Moogle is a storage the player chose: what waits there for its job is where it should be)
  if (gear && sets && !bvEquips(bagName) && bagName !== 'Porter Moogle' && !r.where.some(w => bvEquips(w.bag))) return 'bvW_far';
  if (role === 'job' || role === 'gear') return !gear ? 'bvW_type' : !sets && !named && !bvLockSets(r).length ? 'bvW_unused' : '';
  if (role === 'unused') return gear && sets ? 'bvW_used' : '';
  if (role === 'usable') return bpCat(bvBags(), r) !== 'usable' ? 'bvW_type' : '';
  if (role === 'mats') return gear ? 'bvW_type' : '';
  if (role === 'currency' || role === 'keys') return gear ? 'bvW_type' : '';
  if (role === 'slips') return /^Storage Slip/.test(r.info.name) ? '' : 'bvW_type';
  return '';
}
// The bags a row is misplaced in: [{bag, why, to}], from the plan's one sum (bags_target.js bpTarget)
const bvRoles = (B, bag) => bvRole(B, bag).split('+');
// The roles a bag can hold at once (three kinds of things sharing its room)
const BV_MAX_ROLES = 3;
const bvRoleName = (B, bag) => bvRoles(B, bag).map(r => t('bvR_' + r)).join(' + ');
const bvRoleShort = (B, bag) => bvRoles(B, bag).map(r => t('bvRs_' + r)).join(' · ');
const bvBad = (B, r) => bpTarget(B).bad[r.key] || [];
// The list takes what is left of the window, to the pixel: it is the only thing that scrolls, the page never does
// (measured once the tab is drawn, and again when the window changes size)
function bvFit(){
  const el = document.getElementById('bvlist'); if (!el) return;
  // what scrolls around it (the tab's own frame): the list is given a first height, then what still overflows is taken off
  const frame = el.closest('.tabmain') || document.scrollingElement;
  el.style.maxHeight = 'none';
  el.style.height = Math.max(160, Math.floor(window.innerHeight - el.getBoundingClientRect().top)) + 'px';
  const over = frame.scrollHeight - frame.clientHeight;
  if (over > 0) el.style.height = Math.max(160, el.offsetHeight - over) + 'px';
}
window.addEventListener('resize', bvFit);
document.addEventListener('change', e => { const pc = e.target.closest && e.target.closest('[data-bagpc]'); if (pc) { S.bagPc = pc.value; render(); return; }
  const el = e.target.closest && e.target.closest('[data-bagrole]'); if (!el) return;
  const B = bvBags(), bag = B && B.bags.find(b => b.name === el.dataset.bagrole), next = bag ? bvRoles(B, bag).slice() : ['free'];
  // the menu changed, the others kept; an emptied menu ('—') and a role said twice drop out
  next[+el.dataset.part || 0] = el.value;
  const role = next[0] === 'free' ? 'free' : next.filter((r, i) => r && r !== 'free' && next.indexOf(r) === i).slice(0, BV_MAX_ROLES).join('+');
  S.bagRoles = Object.assign({}, S.bagRoles); S.bagRoles[S.char] = Object.assign({}, S.bagRoles[S.char], {[el.dataset.bagrole]: role}); bpTouch(); render(); });
document.addEventListener('click', e => {
  const b = e.target.closest('[data-persoview],[data-bagsel],[data-bagcat],[data-bagdup],[data-baguse]'); if (!b) return; const d = b.dataset;
  if (d.persoview) S.persoView = d.persoview; else if (d.baguse) S.bagUse = d.baguse; else if (d.bagsel) S.bagSel = d.bagsel; else if (d.bagcat) S.bagCat = d.bagcat; else S.bagDup = !S.bagDup;
  save(); render();
});
let BV_TIMER = 0;
document.addEventListener('input', e => { if (e.target.id !== 'bagq') return; const v = e.target.value; clearTimeout(BV_TIMER);
  // the page drawn again: the Bags view (atelier/src/screens/perso) changes only the list, the field keeps its caret
  BV_TIMER = setTimeout(() => { S.bagQ = v; render(); const el = document.getElementById('bvlist'); if (el) el.scrollTop = 0; }, 120); });
