// GearSwap Atelier · bags_view.js: the "Bags" view of the My character tab: every bag of the character as the game
// holds it (export `bags`: shared/utils/atelier/atelier_export_bags.lua), to see where everything is before tidying.
// On top, each bag as a tile with how full it is, what is on the character apart from the Mog House; a click shows
// that bag, "All the bags" shows each item once with the bags it is in. A search, the kinds of items as filters, and
// "In several bags": what is split between bags and could be put together.
// The bags are the character's, not a job's: the freshest export that holds them is read.
// (loaded by atelier/index.html after module_items.js)

Object.assign(T.fr, {bvStats: 'Stats & mérites', bvBags: 'Sacs', bvStatsTip: 'Tes stats mesurées en jeu, PorterPacker et tes mérites.', bvBagsTip: 'Le contenu de chacun de tes sacs, pour voir où est quoi.',
  bvNone: 'Cet export ne contient pas tes sacs. En jeu, tape //gs c atelier (ou recharge ton job) : ils seront lus et affichés ici.',
  bvAt: 'Sacs lus en jeu le {at}. Les sacs du Mog House sont ceux de ta dernière visite.', bvSelf: 'Sur toi', bvHouse: 'Mog House', bvAll: 'Tous les sacs', bvAllSub: 'chaque objet une fois',
  bvFree: '{n} libre(s)', bvFull: 'plein', bvTileTip: '{b} : {c} emplacement(s) pris sur {m}, {f} libre(s). Clique pour voir son contenu.', bvAllTip: 'Chaque objet une seule fois, avec les sacs où il se trouve.',
  bvSearch: 'Chercher un objet…', bvCatAll: 'Tout', bvDup: 'Dans plusieurs sacs', bvDupTip: 'Seulement les objets présents dans plus d’un sac : ce qui pourrait être regroupé.',
  bvEmpty: 'Ce sac est vide.', bvNoHit: 'Aucun objet ne correspond.', bvCount: '{n} objet(s) · {s} emplacement(s)', bvIn: 'Dans : ', bvAlso: 'Aussi dans : ', bvStack: 'pile de {n}',
  bvC_Weapon: 'Armes', bvC_Armor: 'Armures', bvC_Usable: 'Utilisables', bvC_General: 'Divers', bvC_Furnishing: 'Mobilier', bvC_Automaton: 'Automate', bvC_Maze: 'Labyrinthe', bvC_Gil: 'Gils'});
Object.assign(T.en, {bvStats: 'Stats & merits', bvBags: 'Bags', bvStatsTip: 'Your stats measured in game, PorterPacker and your merits.', bvBagsTip: 'What each of your bags holds, to see where everything is.',
  bvNone: 'This export does not hold your bags. In game, type //gs c atelier (or reload your job): they will be read and shown here.',
  bvAt: 'Bags read in game on {at}. The Mog House bags are those of your last visit.', bvSelf: 'On you', bvHouse: 'Mog House', bvAll: 'All the bags', bvAllSub: 'each item once',
  bvFree: '{n} free', bvFull: 'full', bvTileTip: '{b}: {c} slot(s) taken of {m}, {f} free. Click to see what it holds.', bvAllTip: 'Each item once, with the bags it is in.',
  bvSearch: 'Search an item…', bvCatAll: 'All', bvDup: 'In several bags', bvDupTip: 'Only the items held in more than one bag: what could be put together.',
  bvEmpty: 'This bag is empty.', bvNoHit: 'No item matches.', bvCount: '{n} item(s) · {s} slot(s)', bvIn: 'In: ', bvAlso: 'Also in: ', bvStack: 'stack of {n}',
  bvC_Weapon: 'Weapons', bvC_Armor: 'Armor', bvC_Usable: 'Usable', bvC_General: 'Misc', bvC_Furnishing: 'Furnishing', bvC_Automaton: 'Automaton', bvC_Maze: 'Maze', bvC_Gil: 'Gil'});

const BV_CATS = ['Weapon', 'Armor', 'Usable', 'General', 'Furnishing', 'Automaton', 'Maze'];
const bvCatName = c => t('bvC_' + c) !== 'bvC_' + c ? t('bvC_' + c) : c || '?';
const bvBags = () => { const x = latestExport(S.char, 'bags'); return x && x.bags; };
const bvNorm = s => String(s).toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '');
// One copy of an item as a key: two capes with other augments are two things, two stacks of one potion are one
const bvKey = it => it.id + '|' + (it.augs || []).join('|');
// Where each thing is: {key: [{bag, n, slots}]}, across every bag
function bvWhere(B){
  const by = {};
  for (const bag of B.bags) for (const it of bag.items) { const k = bvKey(it), list = by[k] = by[k] || [], at = list.find(w => w.bag === bag.name);
    if (at) { at.n += it.n; at.slots++; } else list.push({bag: bag.name, n: it.n, slots: 1}); }
  return by;
}
// The rows of the list: one a thing, {key, id, info, augs, n (count), slots, where}
function bvRows(B, sel, where){
  const rows = new Map();
  for (const bag of B.bags) { if (sel !== 'all' && bag.name !== sel) continue;
    for (const it of bag.items) { const k = bvKey(it), r = rows.get(k) || {key: k, id: it.id, info: B.items[it.id] || {name: '#' + it.id}, augs: it.augs, n: 0, slots: 0, where: where[k]};
      r.n += it.n; r.slots++; rows.set(k, r); } }
  return [...rows.values()];
}
function bvFilter(rows){
  const q = bvNorm(S.bagQ || ''), cat = S.bagCat || 'all';
  return rows.filter(r => (cat === 'all' || r.info.cat === cat) && (!S.bagDup || r.where.length > 1) && (!q || bvNorm(r.info.name + ' ' + (r.augs || []).join(' ')).includes(q)));
}
const bvRank = c => { const i = BV_CATS.indexOf(c); return i < 0 ? 99 : i; };
// A bag's name in a few letters, for the tags of the list (Wardrobe 3 -> W3, Mog Safe 2 -> Safe 2)
const bvShort = n => n === 'Wardrobe' ? 'W1' : n.replace(/^Wardrobe (\d)$/, 'W$1').replace(/^Mog /, '').replace(/^Inventory$/, 'Inv.');
// One item of the list: its icon, its name, how many, its augments, and the other bags it is in
function bvItemHTML(r, sel){
  const others = sel === 'all' ? r.where : r.where.filter(w => w.bag !== sel);
  const places = others.length ? `<small class="bvw">${sel === 'all' ? '' : '+ '}${others.map(w => `<i>${esc(bvShort(w.bag))}</i>`).join('')}</small>` : '';
  const tip = [r.info.name + (r.n > 1 ? ' ×' + r.n : ''), r.augs ? r.augs.join(' · ') : '', r.where.map(w => w.bag + (w.n > 1 ? ' ×' + w.n : '')).join(', ')].filter(Boolean).join('\n');
  return `<div class="bvitem ${r.where.length > 1 ? 'split' : ''}" title="${esc(tip)}">${itemIco(r.info.name, r.id)}<b>${esc(r.info.name)}</b>` +
    `${r.augs ? `<small class="bva">${esc(r.augs.join(' · '))}</small>` : ''}${places}${r.n > 1 ? `<em>×${r.n}</em>` : ''}</div>`;
}
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
  const used = bag.count != null ? bag.count : bag.items.length, free = bag.max - used, pct = Math.round(100 * used / bag.max);
  return `<button class="bvtile ${free <= 0 ? 'full' : pct >= 90 ? 'tight' : ''}" data-bagsel="${esc(bag.name)}" aria-pressed="${sel === bag.name}" title="${esc(t('bvTileTip', {b: bag.name, c: used, m: bag.max, f: Math.max(0, free)}))}">` +
    `<b>${esc(bag.name)}</b><span class="bvnum">${used}<i>/${bag.max}</i></span><span class="bvbar"><i style="width:${Math.min(100, pct)}%"></i></span></button>`;
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
  const sel = B.bags.some(b => b.name === S.bagSel) ? S.bagSel : 'all', total = B.bags.reduce((n, b) => n + (b.count != null ? b.count : b.items.length), 0), room = B.bags.reduce((n, b) => n + b.max, 0);
  const group = (place, title) => { const list = B.bags.filter(b => b.place === place);
    return list.length ? `<div class="bvgroup ${place}"><h4>${esc(title)}</h4><div class="bvtiles">${list.map(b => bvTileHTML(b, sel)).join('')}</div></div>` : ''; };
  const all = `<div class="bvgroup"><h4>&nbsp;</h4><div class="bvtiles"><button class="bvtile all" data-bagsel="all" aria-pressed="${sel === 'all'}" title="${esc(t('bvAllTip'))}"><b>${esc(t('bvAll'))}</b><span class="bvnum">${total}<i>/${room}</i></span>` +
    `<span class="bvbar"><i style="width:${Math.round(100 * total / room)}%"></i></span></button></div></div>`;
  const have = new Set(Object.values(B.items).map(i => i.cat)), cats = ['all', ...BV_CATS.filter(c => have.has(c)), ...[...have].filter(c => !BV_CATS.includes(c))];
  const filters = `<div class="bvbar2"><input id="bagq" class="tgq" type="search" value="${esc(S.bagQ || '')}" placeholder="${esc(t('bvSearch'))}" autocomplete="off">` +
    `<span class="modseg">${cats.map(c => `<button data-bagcat="${esc(c)}" aria-pressed="${(S.bagCat || 'all') === c}">${esc(c === 'all' ? t('bvCatAll') : bvCatName(c))}</button>`).join('')}</span>` +
    `<button class="modsw" role="switch" aria-checked="${!!S.bagDup}" data-bagdup title="${esc(t('bvDupTip'))}"><span class="sw ${S.bagDup ? 'on' : ''}" aria-hidden="true"></span><b>${esc(t('bvDup'))}</b></button></div>`;
  return `<div class="bagsview"><p class="muted small bvat">${esc(t('bvAt', {at: B.at || '?'}))}</p><div class="bvtop">${all}${group('self', t('bvSelf'))}${group('house', t('bvHouse'))}</div>` +
    box('g-attr wide', esc(sel === 'all' ? t('bvAll') : sel), `${filters}<div id="bvlist" class="bvlist">${bvListHTML(B)}</div>`) + `</div>`;
}
// The switch between the two views of the tab
const persoViewsHTML = () => `<span class="seg persoviews" role="group">${[['stats', 'bvStats'], ['bags', 'bvBags']].map(([v, k]) =>
  `<button data-persoview="${v}" aria-pressed="${(S.persoView || 'stats') === v}" title="${esc(t(k + 'Tip'))}">${esc(t(k))}</button>`).join('')}</span>`;

document.addEventListener('click', e => {
  const b = e.target.closest('[data-persoview],[data-bagsel],[data-bagcat],[data-bagdup]'); if (!b) return; const d = b.dataset;
  if (d.persoview) S.persoView = d.persoview; else if (d.bagsel) S.bagSel = d.bagsel; else if (d.bagcat) S.bagCat = d.bagcat; else S.bagDup = !S.bagDup;
  save(); render();
});
let BV_TIMER = 0;
document.addEventListener('input', e => { if (e.target.id !== 'bagq') return; const v = e.target.value; clearTimeout(BV_TIMER);
  BV_TIMER = setTimeout(() => { S.bagQ = v; const el = document.getElementById('bvlist'), B = bvBags(); if (el && B) { el.innerHTML = bvListHTML(B); el.scrollTop = 0; } }, 120); });
