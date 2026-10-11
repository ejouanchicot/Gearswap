// GearSwap Atelier · module_items.js: the lists of the Modules part (modules.js), made to be handled rather than typed:
// each entry a tile that is dragged to its place (the order of a list is the order GearSwap uses), an item with the
// game's own icon, a new item picked in a window of icons, a bag picked among the bags that exist.
// The usable items (medicine, food, tools) come from usables_data.js; equipment from the page's catalog and exports.
// (loaded by atelier/index.html before modules.js)

Object.assign(T.fr, {miAdd: '+ Ajouter un objet', miAddTip: 'Ouvre la liste des objets du jeu, avec leurs icônes : clique sur celui à ajouter.',
  miTitle: 'Ajouter un objet', miSearch: 'Chercher parmi {n} objets…', miUsed: 'Déjà dans tes listes', miFound: 'Objets du jeu', miMore: 'Tape quelques lettres pour chercher dans tous les objets utilisables du jeu.',
  miNone: 'Aucun objet à ce nom.', miPickTip: 'Ajouter {v} à la fin de la liste.', miHas: 'Déjà dans cette liste', miBagTip: 'Ajouter {v} à la fin de la liste.',
  miDragTip: 'Glisse-le pour changer sa place : l’ordre de la liste est l’ordre utilisé. La croix le retire.',
  miMode: 'Sort du mode {m}', miModeTip: 'Pas un sort fixe : celui qui est choisi dans ce mode au moment où tu lances la commande. Écrit « {v} » dans le fichier.'});
Object.assign(T.en, {miAdd: '+ Add an item', miAddTip: 'Opens the list of the game\'s items, with their icons: click the one to add.',
  miTitle: 'Add an item', miSearch: 'Search {n} items…', miUsed: 'Already in your lists', miFound: 'Items of the game', miMore: 'Type a few letters to search every usable item of the game.',
  miNone: 'No item of that name.', miPickTip: 'Add {v} at the end of the list.', miHas: 'Already in this list', miBagTip: 'Add {v} at the end of the list.',
  miDragTip: 'Drag it to change its place: the order of the list is the order used. The cross removes it.',
  miMode: 'Spell of the {m} mode', miModeTip: 'Not a fixed spell: the one chosen in that mode when you use the command. Written "{v}" in the file.'});

const USABLE_ID = (() => { const m = {}; for (const [id, n] of (typeof USABLE_ITEMS === 'undefined' ? [] : USABLE_ITEMS)) if (!(n in m)) m[n] = id; return m; })();
// The icon of an item by its name (a usable item, a piece of an export, a piece of the gear catalog), or by its id
const itemIconId = name => USABLE_ID[name] || iconIds()[name] || ((catalog() || {id: {}}).id || {})[name];
const itemIco = (name, id) => { id = id || itemIconId(name);
  return `<span class="ico" aria-hidden="true">${id ? `<img src="atelier/icons/${id}.bmp" alt="" onerror="iconMiss(this, ${+id})">` : ''}</span>`; };

// An entry written `$Mode` in a list of buffs stands for the spell chosen in that mode at the moment (the mode's own
// name when the job shown has it): shown in words, written back as it is
function miLabel(v){
  const m = typeof v === 'string' && /^\$([A-Za-z_]\w*)(.*)$/.exec(v); if (!m) return v;
  const mode = ((data() || {}).modes || []).find(x => x.name === m[1]);
  return t('miMode', {m: (mode && mode.desc) || m[1]}) + m[2];
}
const miIsMode = v => typeof v === 'string' && v[0] === '$';
// A list's entries as tiles, then what adds one. opts: {items: true} (game items, with icons), {bags: [names]}
function modChips(x, val, id, off, opts = {}){
  const drag = off ? '' : 'draggable="true"';
  const pic = opts.items || opts.gear;
  const tiles = val.map((v, i) => `<span class="modchip ${pic ? 'item' : ''}" ${drag} data-moddrag="${i}" ${id} ${modTip(off, 'miDragTip')}>` +
    `${pic ? itemIco(v) : `<i class="mcnum">${i + 1}</i>`}<span class="mcn ${miIsMode(v) ? 'mode' : ''}" ${miIsMode(v) ? `title="${esc(t('miModeTip', {v}))}"` : ''}>${esc(miLabel(v))}</span>` +
    `<button data-moddel="${i}" ${id} ${off} title="${esc(t('modDel', {v}))}" aria-label="${esc(t('modDel', {v}))}">×</button></span>`).join('');
  const add = opts.ws ? `<button class="modaddbtn" data-modpick data-wspick ${id} ${off} ${modTip(off, 'mxWsTip')}>${esc(t('mxWsAdd'))}</button>`
    : opts.acts ? `<button class="modaddbtn" data-modpick data-actpick ${id} ${off} ${modTip(off, 'mxActTip')}>${esc(t('mxActAdd'))}</button>`
    : opts.items ? `<button class="modaddbtn" data-modpick ${id} ${off} ${modTip(off, 'miAddTip')}>${esc(t('miAdd'))}</button>`
    : opts.bags ? opts.bags.filter(b => !val.includes(b)).map(b => `<button class="modaddbtn" data-modaddv="${esc(b)}" ${id} ${off} ${modTip(off, 'miBagTip', {v: b})}>+ ${esc(b)}</button>`).join('')
    : `<input class="modin add" type="text" placeholder="${esc(t('modAdd'))}" ${opts.gear ? 'list="mrgear"' : ''} ${id} data-modadd ${off} ${modTip(off, 'ttModAdd')}>`;
  return `<div class="modchips">${tiles}${add}${opts.gear ? mrGearList() : ''}</div>`;
}

/* ---- the window of items ---- */
// The items the character's settings already name (the lists of the catalog marked `items`): offered first
function miUsed(){
  const d = data(), names = new Set();
  for (const fam of MOD_CATALOG) for (const r of mcRows(d, fam)) if (r.it.items) for (const v of mrNames(modValue(r.f.file, r.x.path))) names.add(v);
  return [...names].sort();
}
function miGridHTML(q){
  const has = new Set(mrNames(modValue(S._miPick.file, S._miPick.path))), needle = q.trim().toLowerCase();
  const tile = n => `<button class="mitile" data-mipick="${esc(n)}" ${has.has(n) ? 'disabled' : ''} title="${esc(has.has(n) ? t('miHas') : t('miPickTip', {v: n}))}">${itemIco(n)}<span>${esc(n)}</span></button>`;
  if (!needle) return `<h4>${esc(t('miUsed'))}</h4><div class="migrid">${miUsed().map(tile).join('')}</div><p class="muted small">${esc(t('miMore'))}</p>`;
  const found = USABLE_ITEMS.filter(([, n]) => n.toLowerCase().includes(needle)).sort((a, b) => a[1].toLowerCase().indexOf(needle) - b[1].toLowerCase().indexOf(needle)).slice(0, 72);
  return found.length ? `<h4>${esc(t('miFound'))}</h4><div class="migrid">${[...new Set(found.map(x => x[1]))].map(tile).join('')}</div>` : `<p class="muted">${esc(t('miNone'))}</p>`;
}
function openItemPick(file, path, rows){
  S._miPick = {file, path, rows};
  showDialog('midlg', esc(t('miTitle')), `<input id="miq" class="tgq" type="search" placeholder="${esc(t('miSearch', {n: USABLE_ITEMS.length}))}" autocomplete="off"><div id="mibody" class="mibody">${miGridHTML('')}</div>`, '');
  const q = document.getElementById('miq'); if (q) q.focus();
}
const miAppend = (file, path, v) => { const cur = modValue(file, path) || []; if (!cur.includes(v)) modStage(file, path, [...cur, v]); };

document.addEventListener('click', e => {
  const b = e.target.closest('[data-modpick],[data-modaddv],[data-mipick]'); if (!b) return; const d = b.dataset;
  if ('modpick' in d) { if ('wspick' in d) openWsPick(d.modfile, d.modpath); else if ('actpick' in d) openActPick(d.modfile, d.modpath); else openItemPick(d.modfile, d.modpath, 'rowpick' in d); return; }
  if (d.modaddv != null) { miAppend(d.modfile, d.modpath, d.modaddv); return; }
  if (d.mipick != null && S._miPick) { const p = S._miPick; S._miPick = null; closeOverlay(); if (p.rows) mrAdd(p.file, p.path, d.mipick); else miAppend(p.file, p.path, d.mipick); }
});
document.addEventListener('input', e => { if (e.target.id === 'miq' && S._miPick) document.getElementById('mibody').innerHTML = S._miPick.ws ? mxWsGrid(e.target.value) : S._miPick.acts ? mxActGrid(e.target.value) : miGridHTML(e.target.value); });

/* ---- dragging a tile to its place ---- */
let MOD_DRAG = null;
const modDragTile = e => e.target.closest && e.target.closest('.modchip[data-moddrag]');
const modDragSame = el => MOD_DRAG && el && el.dataset.modfile === MOD_DRAG.file && el.dataset.modpath === MOD_DRAG.path;
const modDragClear = () => document.querySelectorAll('.modchip.dropl,.modchip.dropr,.modchip.dragging').forEach(el => el.classList.remove('dropl', 'dropr', 'dragging'));
document.addEventListener('dragstart', e => { const el = modDragTile(e); if (!el) return;
  MOD_DRAG = {file: el.dataset.modfile, path: el.dataset.modpath, i: +el.dataset.moddrag};
  e.dataTransfer.effectAllowed = 'move'; try { e.dataTransfer.setData('text/plain', el.textContent); } catch (x) {}
  setTimeout(() => el.classList.add('dragging'), 0); });
document.addEventListener('dragover', e => { const el = modDragTile(e); if (!modDragSame(el)) return;
  e.preventDefault(); const r = el.getBoundingClientRect(), right = e.clientX > r.left + r.width / 2;
  document.querySelectorAll('.modchip.dropl,.modchip.dropr').forEach(x => x.classList.remove('dropl', 'dropr'));
  el.classList.add(right ? 'dropr' : 'dropl'); });
document.addEventListener('drop', e => { const el = modDragTile(e); if (!modDragSame(el)) return;
  e.preventDefault(); const r = el.getBoundingClientRect(), from = MOD_DRAG.i, list = [...(modValue(MOD_DRAG.file, MOD_DRAG.path) || [])];
  let to = +el.dataset.moddrag + (e.clientX > r.left + r.width / 2 ? 1 : 0);
  const [moved] = list.splice(from, 1); if (from < to) to--; list.splice(to, 0, moved);
  const d = MOD_DRAG; MOD_DRAG = null; modDragClear(); modStage(d.file, d.path, list); });
document.addEventListener('dragend', () => { MOD_DRAG = null; modDragClear(); });
