// GearSwap Atelier · bags_view.js: the "Bags" view of the My character tab: every bag of the character as the game
// holds it (export `bags`: shared/utils/atelier/atelier_export_bags.lua), to see where everything is before tidying.
// On top, each bag as a tile with how full it is, what is on the character apart from the Mog House; a click shows
// that bag, "All the bags" shows each item once with the bags it is in. A search, the kinds of items as filters, and
// "In several bags": what is split between bags and could be put together.
// The bags are the character's, not a job's: the freshest export that holds them is read.
// (loaded by atelier/index.html after module_items.js)

Object.assign(T.fr, {bvStats: 'Stats & mérites', bvBags: 'Sacs', bvStatsTip: 'Tes stats mesurées en jeu, PorterPacker et tes mérites.', bvBagsTip: 'Le contenu de chacun de tes sacs, pour voir où est quoi.',
  bvNone: 'Cet export ne contient pas tes sacs. En jeu, tape //gs c atelier (ou recharge ton job) : ils seront lus et affichés ici.',
  bvAt: 'Sacs lus en jeu le {at}. Les sacs du Mog House sont ceux de ta dernière visite.', bvSelf: 'Sur toi', bvHouse: 'Mog House', bvPorter: 'Rangé ailleurs', bvPorterTip: '{c} pièce(s) confiée(s) au Porter Moogle, sur tes slips. Clique pour les voir.', bvAll: 'Tous les sacs', bvAllSub: 'chaque objet une fois', bpPlanSub: 'est-ce que ça rentre ?',
  bvFree: '{n} libre(s)', bvFull: 'plein', bvTileTip: '{b} : {c} emplacement(s) pris sur {m}, {f} libre(s). Clique pour voir son contenu.', bvAllTip: 'Chaque objet une seule fois, avec les sacs où il se trouve.',
  bvSearch: 'Chercher un objet…', bvCatAll: 'Tout', bvDup: 'Dans plusieurs sacs', bvDupTip: 'Seulement les objets présents dans plus d’un sac : ce qui pourrait être regroupé.',
  bvNoSet: 'aucun set', bvNoSetTip: 'Dans aucun set des jobs lus.', bvCfg: 'réglages', bvUsedBy: 'Porté par : {l} (nombre de sets).', bvCfgTip: 'Nommé dans : {l}.',
  bvLs: 'style {l}', bvUseLock: 'Lockstyle', bvGoes: 'Sa place : {d}.', bvUseAll: 'Tout', bvUseBad: 'Mal rangé', bvUseNone: 'Dans aucun set',
  bvRoleOf: 'Ce sac sert à', bvRole2: 'et aussi à', bvRole2Tip: 'Un second rôle : deux sortes d’objets se partagent la place de ce sac.', bvRoleTip: 'Dis à quoi sert ce sac : la page signale ce qui n’y a pas sa place. Rien ne bouge en jeu.', bvBadN: '{n} objet(s) mal rangé(s) dans ce sac.',
  bvRs_free: 'libre', bvRs_job: 'job en cours', bvRs_gear: 'autres jobs', bvRs_spare: 'lockstyle, surplus', bvRs_unused: 'inutilisé', bvRs_craft: 'craft', bvRs_usable: 'consommables', bvRs_mats: 'vente, craft', bvRs_currency: 'currencies', bvRs_keys: 'objets clés', bvRs_furnish: 'meubles', bvRs_slips: 'slips', bvRs_archive: 'archives',
  bvR_free: 'pas de règle', bvR_job: 'job en cours', bvR_gear: 'équipement des jobs', bvR_unused: 'ce qui ne sert pas', bvR_craft: 'craft', bvR_usable: 'consommables', bvR_mats: 'à vendre et composants de craft', bvR_currency: 'currencies', bvR_keys: 'objets clés (améliorations, accès)', bvR_spare: 'lockstyle et surplus', bvR_furnish: 'meubles et rangement', bvR_slips: 'slips', bvR_archive: 'archives',
  bvW_far: 'porté par un set, mais ne peut pas être équipé depuis ce sac', bvW_farS: 'pas équipable ici', bvW_type: 'pas le type d’objet de ce sac', bvW_typeS: 'pas à sa place', bvW_unused: 'dans aucun set : ce sac est pour l’équipement qui sert', bvW_unusedS: 'ne sert pas',
  bvW_used: 'porté par un set : ce sac est pour ce qui ne sert pas', bvW_usedS: 'sert à un set', bvUseOne: 'Un seul job', bvUseMany: 'Plusieurs jobs', bvUseTip: 'Qui porte chaque pièce, d’après les sets des jobs exportés : {j}. Un job jamais exporté ne compte pas, et les lockstyles ne sont pas connus de la page.',
  bvEmpty: 'Ce sac est vide.', bvNoHit: 'Aucun objet ne correspond.', bvCount: '{n} objet(s) · {s} emplacement(s)', bvIn: 'Dans : ', bvAlso: 'Aussi dans : ', bvStack: 'pile de {n}',
  bvC_Weapon: 'Armes', bvC_Armor: 'Armures', bvC_Usable: 'Utilisables', bvC_General: 'Divers', bvC_Furnishing: 'Mobilier', bvC_Automaton: 'Automate', bvC_Maze: 'Labyrinthe', bvC_Gil: 'Gils'});
Object.assign(T.en, {bvStats: 'Stats & merits', bvBags: 'Bags', bvStatsTip: 'Your stats measured in game, PorterPacker and your merits.', bvBagsTip: 'What each of your bags holds, to see where everything is.',
  bvNone: 'This export does not hold your bags. In game, type //gs c atelier (or reload your job): they will be read and shown here.',
  bvAt: 'Bags read in game on {at}. The Mog House bags are those of your last visit.', bvSelf: 'On you', bvHouse: 'Mog House', bvPorter: 'Stored elsewhere', bvPorterTip: '{c} piece(s) left with the Porter Moogle, on your slips. Click to see them.', bvAll: 'All the bags', bvAllSub: 'each item once', bpPlanSub: 'does it fit?',
  bvFree: '{n} free', bvFull: 'full', bvTileTip: '{b}: {c} slot(s) taken of {m}, {f} free. Click to see what it holds.', bvAllTip: 'Each item once, with the bags it is in.',
  bvSearch: 'Search an item…', bvCatAll: 'All', bvDup: 'In several bags', bvDupTip: 'Only the items held in more than one bag: what could be put together.',
  bvNoSet: 'no set', bvNoSetTip: 'In no set of the jobs read.', bvCfg: 'settings', bvUsedBy: 'Worn by: {l} (number of sets).', bvCfgTip: 'Named in: {l}.',
  bvLs: 'style {l}', bvUseLock: 'Lockstyle', bvGoes: 'Its place: {d}.', bvUseAll: 'All', bvUseBad: 'Misplaced', bvUseNone: 'In no set',
  bvRoleOf: 'This bag is for', bvRole2: 'and also for', bvRole2Tip: 'A second role: two kinds of things share this bag’s room.', bvRoleTip: 'Say what this bag is for: the page points at what has no place in it. Nothing moves in game.', bvBadN: '{n} item(s) misplaced in this bag.',
  bvRs_free: 'free', bvRs_job: 'job loaded', bvRs_gear: 'other jobs', bvRs_spare: 'lockstyle, overflow', bvRs_unused: 'unused', bvRs_craft: 'crafting', bvRs_usable: 'consumables', bvRs_mats: 'sale, crafting', bvRs_currency: 'currencies', bvRs_keys: 'key items', bvRs_furnish: 'furniture', bvRs_slips: 'slips', bvRs_archive: 'archive',
  bvR_free: 'no rule', bvR_job: 'job loaded', bvR_gear: 'the jobs’ gear', bvR_unused: 'what is not used', bvR_craft: 'crafting', bvR_usable: 'consumables', bvR_mats: 'to sell and crafting materials', bvR_currency: 'currencies', bvR_keys: 'key items (upgrades, entries)', bvR_spare: 'lockstyle and overflow', bvR_furnish: 'furniture and storage', bvR_slips: 'slips', bvR_archive: 'archive',
  bvW_far: 'worn by a set, but cannot be put on from this bag', bvW_farS: 'not wearable here', bvW_type: 'not this bag’s kind of item', bvW_typeS: 'out of place', bvW_unused: 'in no set: this bag is for the gear in use', bvW_unusedS: 'not used',
  bvW_used: 'worn by a set: this bag is for what is not used', bvW_usedS: 'used by a set', bvUseOne: 'One job only', bvUseMany: 'Several jobs', bvUseTip: 'Who wears each piece, from the sets of the jobs exported: {j}. A job never exported does not count, and the page does not know the lockstyles.',
  bvEmpty: 'This bag is empty.', bvNoHit: 'No item matches.', bvCount: '{n} item(s) · {s} slot(s)', bvIn: 'In: ', bvAlso: 'Also in: ', bvStack: 'stack of {n}',
  bvC_Weapon: 'Weapons', bvC_Armor: 'Armor', bvC_Usable: 'Usable', bvC_General: 'Misc', bvC_Furnishing: 'Furnishing', bvC_Automaton: 'Automaton', bvC_Maze: 'Maze', bvC_Gil: 'Gil'});

const BV_CATS = ['Weapon', 'Armor', 'Usable', 'General', 'Furnishing', 'Automaton', 'Maze'];
const bvCatName = c => t('bvC_' + c) !== 'bvC_' + c ? t('bvC_' + c) : c || '?';
// The bags of the freshest export that holds them, with what is kept at the Porter Moogle as one more "bag" (export
// `porter`: {item id: 'Slip N'}; the names come from the page's gear catalog)
let BV_BAGS = null;
function bvBags(){
  const x = latestExport(S.char, 'bags'); if (!x || !x.bags) return null;
  const px = latestExport(S.char, 'porter'), cat = typeof catalog === 'function' && catalog(), key = DATA_GEN + '|' + S.char + '|' + !!cat;
  if (BV_BAGS && BV_BAGS.key === key) return BV_BAGS.B;
  const B = {at: x.bags.at, bags: [...x.bags.bags], items: Object.assign({}, x.bags.items)};
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
function bvRows(B, sel, where){
  const rows = new Map();
  for (const bag of B.bags) { if (sel !== 'all' && bag.name !== sel) continue;
    for (const it of bag.items) { const k = bvKey(it), info = B.items[it.id] || {name: '#' + it.id}, r = rows.get(k) || {key: k, id: it.id, info, augs: it.augs, n: 0, slots: 0, where: where[k], use: bvUseOf(info.name)};
      r.n += it.n; r.slots++; rows.set(k, r); } }
  const out = [...rows.values()];
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
// One item of the list: its icon, its name, how many, its augments, and the other bags it is in
function bvItemHTML(r, sel){
  const others = sel === 'all' ? r.where : r.where.filter(w => w.bag !== sel);
  const places = others.length ? `<small class="bvw">${sel === 'all' ? '' : '+ '}${others.map(w => `<i>${esc(bvShort(w.bag))}</i>`).join('')}</small>` : '';
  const tip = [r.info.name + (r.n > 1 ? ' ×' + r.n : ''), r.augs ? r.augs.join(' · ') : '', r.where.map(w => w.bag + (w.slip ? ' (' + w.slip + ')' : '') + (w.n > 1 ? ' ×' + w.n : '')).join(', '), bvUseTip(r)].filter(Boolean).join('\n');
  const why = r.bad.map(x => x.bag + ' : ' + t(x.why)).join('\n') + (r.bad.length ? '\n' + t('bvGoes', {d: bpDest(bvBags(), r)}) : '');
  const cat = bpCat(bvBags(), r), mine = !!bpTags()[r.id];
  return `<div class="bvitem ${r.where.length > 1 ? 'split' : ''} ${r.bad.length ? 'bad' : ''} ${(S._bagPick || new Set()).has(String(r.id)) ? 'picked' : ''} ${cat === 'unknown' ? 'unk' : ''}" data-bpick="${r.id}" title="${esc(tip + '\n' + t('bpCatTip', {c: bpCatName(cat), m: mine ? t('bpByYou') : ''}) + (cat === 'npc' && bpNpc(r.info.name) ? '\n' + t('bpNpcAt', {n: bpNpc(r.info.name)}) : '') + (bpLock()[r.id] ? '\n' + t('bpLockOf', {l: bpLock()[r.id].join(', ')}) : '') + (why ? '\n⚠ ' + why : ''))}">${itemIco(r.info.name, r.id)}<b>${esc(r.info.name)}</b>${r.bad.length ? `<small class="bvx">${esc((sel === 'all' ? r.bad.map(x => bvShort(x.bag)).join(', ') + ' ' : '') + '→ ' + bpDest(bvBags(), r))}</small>` : ''}` +
    `${r.augs ? `<small class="bva">${esc(r.augs.join(' · '))}</small>` : ''}${bvUseHTML(r)}${places}${r.n > 1 ? `<em>×${r.n}</em>` : ''}</div>`;
}
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
// What a row is used by, as small tags: the jobs (the one with the most sets first), then "settings" when a file names it
function bvUseHTML(r){
  const u = r.use, jobs = Object.entries(u.jobs).sort((a, b) => b[1] - a[1]), ls = bvLockSets(r);
  const lock = ls.length ? `<i class="ls">${esc(t('bvLs', {l: ls.join(' ')}))}</i>` : '';
  if (!jobs.length && !u.files.size && !lock) return bvIsGear(r) ? `<small class="bvu none">${esc(t('bvNoSet'))}</small>` : '';
  const max = lock ? 3 : 4;
  return `<small class="bvu">${lock}${jobs.slice(0, max).map(([j]) => `<i>${j}</i>`).join('')}${jobs.length > max ? `<i class="more">+${jobs.length - max}</i>` : ''}${u.files.size ? `<i class="cfg">${esc(t('bvCfg'))}</i>` : ''}</small>`;
}
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
const BV_ROLE_START = {'Mog Case': 'usable', 'Mog Satchel': 'mats', 'Mog Sack': 'mats', 'Mog Safe': 'currency+furnish', 'Mog Safe 2': 'currency+keys', 'Storage': 'unused', 'Mog Locker': 'unused'};
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
// The bags a row is misplaced in: [{bag, why}]
const bvRoles = (B, bag) => bvRole(B, bag).split('+');
const bvRoleName = (B, bag) => bvRoles(B, bag).map(r => t('bvR_' + r)).join(' + ');
const bvRoleShort = (B, bag) => bvRoles(B, bag).map(r => t('bvRs_' + r)).join(' · ');
const bvBad = (B, r) => r.where.map(w => { const bag = B.bags.find(b => b.name === w.bag), why = bag ? bvRoles(B, bag).map(role => bvWrong(r, w.bag, role)) : [''];
  return {bag: w.bag, why: why.includes('') ? '' : why[0]}; }).filter(x => x.why);
// The list under the filters (redrawn alone while the search is typed: the field keeps the caret)
function bvListHTML(B){
  const sel = B.bags.some(b => b.name === S.bagSel) ? S.bagSel : 'all', where = bvWhere(B), rows = bvFilter(bvRows(B, sel, where));
  if (!rows.length) return `<p class="muted bvnone">${esc(t(bvRows(B, sel, where).length ? 'bvNoHit' : 'bvEmpty'))}</p>`;
  rows.sort((a, b) => bvRank(a.info.cat) - bvRank(b.info.cat) || a.info.name.localeCompare(b.info.name));
  const cats = [...new Set(rows.map(r => r.info.cat))];
  return `<p class="bvcount muted small">${esc(t('bvCount', {n: rows.length, s: rows.reduce((n, r) => n + r.slots, 0)}))}</p>` +
    cats.map(c => { const list = rows.filter(r => r.info.cat === c);
      return `<h4 class="bvcat">${esc(bvCatName(c))}<small>${list.length}</small></h4><div class="bvgrid">${list.map(r => bvItemHTML(r, sel)).join('')}</div>`; }).join('');
}
// A bag as a tile: its name, how full it is
function bvTileHTML(bag, sel){
  const used = bag.count != null ? bag.count : bag.items.length;
  if (!bag.max) return `<button class="bvtile" data-bagsel="${esc(bag.name)}" aria-pressed="${sel === bag.name}" title="${esc(t('bvPorterTip', {c: used}))}"><b>${esc(bag.name)}</b><span class="bvnum">${used}</span><span class="bvbar"></span>${bvTileRole(bag)}</button>`;
  const free = bag.max - used, pct = Math.round(100 * used / bag.max);
  return `<button class="bvtile ${free <= 0 ? 'full' : pct >= 90 ? 'tight' : ''}" data-bagsel="${esc(bag.name)}" aria-pressed="${sel === bag.name}" title="${esc(t('bvTileTip', {b: bag.name, c: used, m: bag.max, f: Math.max(0, free)}))}">` +
    `<b>${esc(bag.name)}</b><span class="bvnum">${used}<i>/${bag.max}</i></span><span class="bvbar"><i style="width:${Math.min(100, pct)}%"></i></span>${bvTileRole(bag)}</button>`;
}
// Under a tile's gauge: what the bag is for, and how many things are not where they should be in it
function bvTileRole(bag){
  const B = bvBags(), n = bvRows(B, bag.name, bvWhere(B)).filter(r => r.bad.length).length;
  return `<small class="bvrole" title="${esc(bvRoleName(B, bag))}"><span>${esc(bvRoleShort(B, bag))}</span>${n ? `<i title="${esc(t('bvBadN', {n}))}">${n}</i>` : ''}</small>`;
}
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
function renderBags(){
  requestAnimationFrame(bvFit);
  const B = bvBags();
  if (!B) return `<div class="placeholder"><p>${esc(t('bvNone'))}</p></div>`;
  const sel = B.bags.some(b => b.name === S.bagSel) ? S.bagSel : 'all', sized = B.bags.filter(b => b.max), total = sized.reduce((n, b) => n + (b.count != null ? b.count : b.items.length), 0), room = sized.reduce((n, b) => n + b.max, 0);
  const group = (place, title) => { const list = B.bags.filter(b => b.place === place);
    return list.length ? `<div class="bvgroup ${place}"><h4>${esc(title)}</h4><div class="bvtiles">${list.map(b => bvTileHTML(b, sel)).join('')}</div></div>` : ''; };
  const all = `<div class="bvgroup"><h4>&nbsp;</h4><div class="bvtiles"><button class="bvtile all" data-bagsel="all" aria-pressed="${sel === 'all'}" title="${esc(t('bvAllTip'))}"><b>${esc(t('bvAll'))}</b><span class="bvnum">${total}<i>/${room}</i></span>` +
    `<span class="bvbar"><i style="width:${Math.round(100 * total / room)}%"></i></span><small class="bvrole">${esc(t('bvAllSub'))}</small></button>` +
    `<button class="bvtile plan" data-bagsel="plan" aria-pressed="${S.bagSel === 'plan'}" title="${esc(t('bpPlanTip'))}"><b>${esc(t('bpPlan'))}</b><span class="bvnum"></span><span class="bvbar"></span><small class="bvrole">${esc(t('bpPlanSub'))}</small></button></div></div>`;
  const have = new Set(Object.values(B.items).map(i => i.cat)), cats = ['all', ...BV_CATS.filter(c => have.has(c)), ...[...have].filter(c => !BV_CATS.includes(c))];
  const filters = `<div class="bvbar2"><input id="bagq" class="tgq" type="search" value="${esc(S.bagQ || '')}" placeholder="${esc(t('bvSearch'))}" autocomplete="off">` +
    `<span class="modseg">${cats.map(c => `<button data-bagcat="${esc(c)}" aria-pressed="${(S.bagCat || 'all') === c}">${esc(c === 'all' ? t('bvCatAll') : bvCatName(c))}</button>`).join('')}</span>` +
    `<span class="modseg bvuse" title="${esc(t('bvUseTip', {j: bvUsage().jobs.join(' ') || '—'}))}">${[['all', 'bvUseAll'], ['unk', 'bpUnk'], ['bad', 'bvUseBad'], ['lock', 'bvUseLock'], ['none', 'bvUseNone'], ['one', 'bvUseOne'], ['many', 'bvUseMany']].map(([v, k]) =>
      `<button data-baguse="${v}" aria-pressed="${(S.bagUse || 'all') === v}">${esc(t(k))}</button>`).join('')}</span>` +
    `<label class="bvpick" title="${esc(t('bpPcTip'))}">${esc(t('bpPc'))}<select data-bagpc><option value="">${esc(t('bvCatAll'))}</option>${[...BP_CATS, 'unknown'].map(c => `<option value="${c}" ${S.bagPc === c ? 'selected' : ''}>${esc(bpCatName(c))}</option>`).join('')}</select></label>` +
    `<button class="modsw" role="switch" aria-checked="${!!S.bagDup}" data-bagdup title="${esc(t('bvDupTip'))}"><span class="sw ${S.bagDup ? 'on' : ''}" aria-hidden="true"></span><b>${esc(t('bvDup'))}</b></button></div>`;
  const top = `<p class="muted small bvat">${esc(t('bvAt', {at: B.at || '?'}))}</p><div class="bvtop">${all}${group('self', t('bvSelf'))}${group('house', t('bvHouse'))}${group('porter', t('bvPorter'))}</div>${bpStatusHTML(B)}`;
  if (S.bagSel === 'plan') return `<div class="bagsview">${top}` + box('g-attr wide', esc(t('bpTitle')), `<div id="bvlist" class="bvlist">${renderBagPlan(B)}</div>`) + `</div>`;
  return `<div class="bagsview">${top}` +
    box('g-attr wide', esc(sel === 'all' ? t('bvAll') : sel), `${filters}<div id="bpsel">${bpSelBarHTML(bvFilter(bvRows(B, sel, bvWhere(B))).length)}</div><div id="bvlist" class="bvlist">${bvListHTML(B)}</div>`, sel === 'all' ? '' : bvRolePick(B, B.bags.find(b => b.name === sel))) + `</div>`;
}
// What the bag shown is for: a menu in its header
function bvRolePick(B, bag){
  const [cur, also] = bvRoles(B, bag), wardrobe = /^Wardrobe/.test(bag.name), list = wardrobe ? ['free', 'job', 'gear', 'spare', 'unused', 'craft'] : bag.place === 'porter' ? ['archive'] : BV_ROLES.filter(r => r !== 'job');
  const opts = (sel, none) => (none ? `<option value="">—</option>` : '') + list.filter(r => !none || (r !== 'free' && r !== cur)).map(r => `<option value="${r}" ${r === sel ? 'selected' : ''}>${esc(t('bvR_' + r))}</option>`).join('');
  // a second role for a bag that is not a wardrobe: two kinds of things share its room
  return `<label class="bvpick" title="${esc(t('bvRoleTip'))}">${esc(t('bvRoleOf'))}<select data-bagrole="${esc(bag.name)}" data-part="0">${opts(cur)}</select></label>` +
    (wardrobe || bag.place === 'porter' || cur === 'free' ? '' : `<label class="bvpick" title="${esc(t('bvRole2Tip'))}">${esc(t('bvRole2'))}<select data-bagrole="${esc(bag.name)}" data-part="1">${opts(also, true)}</select></label>`);
}
document.addEventListener('change', e => { const pc = e.target.closest && e.target.closest('[data-bagpc]'); if (pc) { S.bagPc = pc.value; render(); return; }
  const el = e.target.closest && e.target.closest('[data-bagrole]'); if (!el) return;
  const B = bvBags(), bag = B && B.bags.find(b => b.name === el.dataset.bagrole), now = bag ? bvRoles(B, bag) : ['free'];
  const next = el.dataset.part === '1' ? [now[0], el.value] : [el.value, now[1]], role = next[0] === 'free' ? 'free' : next.filter((r, i) => r && (i === 0 || r !== next[0])).join('+');
  S.bagRoles = Object.assign({}, S.bagRoles); S.bagRoles[S.char] = Object.assign({}, S.bagRoles[S.char], {[el.dataset.bagrole]: role}); save(); render(); });
// The switch between the two views of the tab
const persoViewsHTML = () => `<span class="seg persoviews" role="group">${[['stats', 'bvStats'], ['bags', 'bvBags']].map(([v, k]) =>
  `<button data-persoview="${v}" aria-pressed="${(S.persoView || 'stats') === v}" title="${esc(t(k + 'Tip'))}">${esc(t(k))}</button>`).join('')}</span>`;

document.addEventListener('click', e => {
  const b = e.target.closest('[data-persoview],[data-bagsel],[data-bagcat],[data-bagdup],[data-baguse]'); if (!b) return; const d = b.dataset;
  if (d.persoview) S.persoView = d.persoview; else if (d.baguse) S.bagUse = d.baguse; else if (d.bagsel) S.bagSel = d.bagsel; else if (d.bagcat) S.bagCat = d.bagcat; else S.bagDup = !S.bagDup;
  save(); render();
});
let BV_TIMER = 0;
document.addEventListener('input', e => { if (e.target.id !== 'bagq') return; const v = e.target.value; clearTimeout(BV_TIMER);
  BV_TIMER = setTimeout(() => { S.bagQ = v; const el = document.getElementById('bvlist'), B = bvBags(); if (el && B) { el.innerHTML = bvListHTML(B); el.scrollTop = 0; } }, 120); });
