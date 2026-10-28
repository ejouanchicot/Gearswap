// GearSwap Atelier · module_items.js: the lists of the Modules part (modules.js), made to be handled rather than typed:
// each entry a tile that is dragged to its place (the order of a list is the order GearSwap uses), an item with the
// game's own icon, a new item picked in a window of icons, a bag picked among the bags that exist.
// The usable items (medicine, food, tools) come from usables_data.js; equipment from the page's catalog and exports.
// (loaded before modules.js: see atelier/src/legacy/files.ts)

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

/* ---- the window of items ---- */
// The items the character's settings already name (the lists of the catalog marked `items`): offered first
function miUsed(){
  const d = data(), names = new Set();
  for (const fam of MOD_CATALOG) for (const r of mcRows(d, fam)) if (r.it.items) for (const v of mrNames(modValue(r.f.file, r.x.path))) names.add(v);
  return [...names].sort();
}
// A picker of the Modules (S._miPick: the list it adds to): drawn by the Svelte application
// (atelier/src/screens/dialogs/modpick.ts), opened with no search, drawn again in place for one typed
function miShow(q){
  const v = ATELIER_DIALOG.modPickView(q || ''), spec = {cls: 'midlg', titleHtml: esc(v.title), modPick: v, buttonsHtml: ''};
  if (q == null) { ATELIER_DIALOG.show(spec); const el = document.getElementById('miq'); if (el) el.focus(); } else ATELIER_DIALOG.update(spec);
}
function openItemPick(file, path, rows){
  S._miPick = {file, path, rows};
  miShow();
}
const miAppend = (file, path, v) => { const cur = modValue(file, path) || []; if (!cur.includes(v)) modStage(file, path, [...cur, v]); };

document.addEventListener('click', e => {
  const b = e.target.closest('[data-modpick],[data-modaddv],[data-mipick]'); if (!b) return; const d = b.dataset;
  if ('modpick' in d) { if ('wspick' in d) openWsPick(d.modfile, d.modpath); else if ('actpick' in d) openActPick(d.modfile, d.modpath); else openItemPick(d.modfile, d.modpath, 'rowpick' in d); return; }
  if (d.modaddv != null) { miAppend(d.modfile, d.modpath, d.modaddv); return; }
  if (d.mipick != null && S._miPick) { const p = S._miPick; S._miPick = null; closeOverlay(); if (p.rows) mrAdd(p.file, p.path, d.mipick); else miAppend(p.file, p.path, d.mipick); }
});
document.addEventListener('input', e => { if (e.target.id === 'miq' && S._miPick) miShow(e.target.value); });

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
