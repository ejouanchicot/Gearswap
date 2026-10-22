// GearSwap Atelier · list_prefs.js: the list of sets as the player arranges it.
// Pinned sets on top, groups of the player's own (made, named, filled and deleted here), the categories the page
// makes from the sets' names hidden or renamed, the list's menu, its width. A category comes from a set's name in
// the file, which GearSwap reads: nothing here renames or moves a set, it is a layer over the list.
//
// Kept per character and job in S.listPrefs (the browser) and in <Char>/atelier/overrides/list_layout.js, which the
// page reads back at start (the newer of the two wins): the same arrangement in every browser.
//   {pins: [set path], groups: [{id, name, sets: [set path]}], hide: [family], names: {family: label}}

Object.assign(T.fr, {mcGrp_enhancing: 'Renfort', mcGrp_enfeebling: 'Affaiblissement', mcGrp_elemental: 'Élémentaire', mcGrp_dark: 'Ténèbres', mcGrp_cure: 'Soin', mcGrp_divine: 'Divine',
  mcGrp_song: 'Chants', mcGrp_blue: 'Magie bleue', mcGrp_ninjutsu: 'Ninjutsu', mcGrp_geomancy: 'Géomancie', mcGrp_summoning: 'Invocation', mcGrp_enmity: 'Inimitié', mcGrp_other: 'Autres sorts',
  lpFoldTip: 'Ouvre ou ferme toutes les catégories et leurs groupes en une fois', lpModeTag: 'mode', lpPinned: 'Épinglés', lpPin: 'Épingler en haut de la liste', lpUnpin: 'Retirer des épinglés', lpGroup: 'Ranger dans un groupe',
  lpMenu: 'Options de la liste', lpOpenAll: 'Tout déplier', lpCloseAll: 'Tout replier', lpPaths: 'Afficher les chemins', lpPathsTip: 'Le nom de chaque set dans ton fichier (sets.engaged.Laphria…)',
  lpAll: 'Afficher les sets d’un autre sub', lpNewGroup: 'Nouveau groupe…', lpGroupName: 'Nom du groupe', lpRename: 'Renommer', lpDelete: 'Supprimer ce groupe (les sets restent)',
  lpHide: 'Masquer cette catégorie', lpHidden: 'Catégories masquées', lpShow: 'réafficher', lpOut: 'Retirer de ce groupe', lpEmptyGroup: 'Vide : passe la souris sur un set et clique ▤ pour le ranger ici.',
  lpMissing: 'Il manque au moins une pièce de ce set dans tes sacs', lpNoGroup: 'Aucun groupe encore.', lpSaveFile: 'Enregistrer dans tes fichiers', lpBrowserOnly: 'Rangement gardé dans ce navigateur seulement.',
  lpSaved: 'Rangement enregistré dans tes fichiers.', lpDeleteAsk: 'Supprimer le groupe « {n} » ? Ses sets restent dans la liste.', lpResize: 'Glisse pour régler la largeur de la liste',
  lpSearchTip: 'Chercher un set ou un objet. ↑ ↓ pour passer d’un set à l’autre.', lpHistory: 'Historique', lpHistoryTip: 'Ce que la page a écrit dans tes fichiers, avec le retour en arrière'});
Object.assign(T.en, {mcGrp_enhancing: 'Enhancing', mcGrp_enfeebling: 'Enfeebling', mcGrp_elemental: 'Elemental', mcGrp_dark: 'Dark', mcGrp_cure: 'Healing', mcGrp_divine: 'Divine',
  mcGrp_song: 'Songs', mcGrp_blue: 'Blue magic', mcGrp_ninjutsu: 'Ninjutsu', mcGrp_geomancy: 'Geomancy', mcGrp_summoning: 'Summoning', mcGrp_enmity: 'Enmity', mcGrp_other: 'Other spells',
  lpFoldTip: 'Opens or closes every category and its groups at once', lpModeTag: 'mode', lpPinned: 'Pinned', lpPin: 'Pin to the top of the list', lpUnpin: 'Unpin', lpGroup: 'Put in a group',
  lpMenu: 'List options', lpOpenAll: 'Open all', lpCloseAll: 'Close all', lpPaths: 'Show the paths', lpPathsTip: 'Each set’s name in your file (sets.engaged.Laphria…)',
  lpAll: 'Show another subjob’s sets', lpNewGroup: 'New group…', lpGroupName: 'Group name', lpRename: 'Rename', lpDelete: 'Delete this group (its sets stay)',
  lpHide: 'Hide this category', lpHidden: 'Hidden categories', lpShow: 'show again', lpOut: 'Take out of this group', lpEmptyGroup: 'Empty: hover a set and click ▤ to put it here.',
  lpMissing: 'At least one piece of this set is not in your bags', lpNoGroup: 'No group yet.', lpSaveFile: 'Save to your files', lpBrowserOnly: 'Arrangement kept in this browser only.',
  lpSaved: 'Arrangement saved to your files.', lpDeleteAsk: 'Delete the group "{n}"? Its sets stay in the list.', lpResize: 'Drag to set the list’s width',
  lpSearchTip: 'Find a set or an item. ↑ ↓ to move between sets.', lpHistory: 'History', lpHistoryTip: 'What the page wrote to your files, with the way back'});

const LIST_FILE = 'list_layout.js', LIST_W = [220, 520];

/* ---- the spells' sets by kind of magic ---- */
// A category with more spell sets than this is cut into kinds of magic (a Red Mage has 21 of them in one run)
const MIDCAST_GROUP_FROM = 8;
const MIDCAST_ORDER = ['enhancing', 'enfeebling', 'elemental', 'dark', 'cure', 'divine', 'song', 'blue', 'ninjutsu', 'geomancy', 'summoning', 'enmity', 'other'];
// Inside a kind: the skill's own set first (sets.midcast['Enhancing Magic']: the one every spell without a set of
// its own wears, and the others are laid over), then the spells by what they are for rather than by their letters
// (what gives back, what protects, what strengthens, the bars), any other name after them as the list had it
const MIDCAST_FIRST = ['refresh', 'regen', 'phalanx', 'stoneskin', 'aquaveil', 'blink', 'haste', 'flurry', 'gain', 'boost', 'temper', 'enspell',
  'storm', 'spikes', 'barelement', 'barailment', 'protect', 'shell'];
function midcastRank(name){
  const n = name.toLowerCase().replace(/[^a-z]/g, '');
  if (/magic$|^ninjutsu$|^geomancy$|^singing$|^bardsong$/.test(n)) return 0;
  const at = MIDCAST_FIRST.findIndex(x => n.startsWith(x));
  return at < 0 ? 100 : 1 + at;
}
// true when a version's name is the value of one of the job's modes (EnfeebleMode Potency, NukeMode Magic Burst)
const listModeValue = label => ((data() || {}).modes || []).some(m => /mode/i.test(m.name) && (m.values || []).includes(label));
// the kind of a spell set (core.js magicKindOf), 'other' when none fits. A set the job lays over its nuke set
// (nuke_layers.js NUKE_LAYERS: BLM's QuanpurStone, ElementalMatch, MPConservation) goes with the nukes: its name
// names no spell, and it was left under "other" (2026-10-22)
function midcastGroup(name, paths){
  const layers = (typeof NUKE_LAYERS === 'object' && NUKE_LAYERS[S.job]) || [];
  if ((paths || []).some(p => layers.some(L => L.path === p))) return 'elemental';
  return magicKindOf(name) || 'other';
}

/* ---- the arrangement ---- */
function listPrefs(char = S.char, job = S.job){
  S.listPrefs = S.listPrefs || {};
  const all = S.listPrefs[char] = S.listPrefs[char] || {at: '', jobs: {}};
  const p = all.jobs[job] = all.jobs[job] || {};
  for (const k of ['pins', 'groups', 'hide']) if (!Array.isArray(p[k])) p[k] = [];
  if (!p.names || typeof p.names !== 'object') p.names = {};
  return p;
}
const listPinned = path => listPrefs().pins.includes(path);
const listFamLabel = fam => listPrefs().names[fam] || t('fam.' + fam);
// after a change: kept in the browser now, written to the character's files a moment later
function listChanged(){
  S.listPrefs[S.char].at = new Date().toISOString();
  save(); render(); listSaveSoon();
}
// The file's arrangement read at start (window.ATELIER_LIST[char]): it replaces the browser's when it is newer
function listRead(){
  const files = window.ATELIER_LIST || {};
  S.listPrefs = S.listPrefs || {};
  for (const c in files) { const f = files[c], mine = S.listPrefs[c];
    if (f && f.jobs && (!mine || (mine.at || '') < (f.at || ''))) { const copy = JSON.parse(JSON.stringify(f));
      // the buff profiles (profiles.js) are written in the same file
      if (copy.profiles) { S.pbPresets = S.pbPresets || {}; S.pbPresets[c] = copy.profiles; delete copy.profiles; }
      S.listPrefs[c] = copy; } }
}
const listFileText = c => `// GearSwap Atelier: how ${c}'s list of sets is arranged in the page (pinned sets, groups, hidden and renamed\n` +
  `// categories), by job, and the buff profiles saved in the "Buffs & target" tab. Written by the page; deleting this\n` +
  `// file puts the list back as the page makes it and forgets those profiles.\n` +
  `(window.ATELIER_LIST = window.ATELIER_LIST || {})[${JSON.stringify(c)}] = ${JSON.stringify(Object.assign({}, S.listPrefs[c], {profiles: (S.pbPresets || {})[c] || {}}))};\n`;
// Written without asking anything: through the game when it is connected, else to the folder the page was already
// given. Neither: the arrangement stays in the browser and the menu offers to save it (a click may ask for the folder)
let LIST_TIMER = null;
function listSaveSoon(){ clearTimeout(LIST_TIMER); LIST_TIMER = setTimeout(() => listSave(false), 1200); }
// A file of <Char>/atelier/overrides/ written without asking anything: through the game when it is connected, else to
// the folder the page was already given (ask: a click, which may ask for the folder). True when it was written
async function charFileSave(c, file, text, ask){
  if (liveOk(c)) { try { await liveFetch(c, '/save?file=' + encodeURIComponent(file), {method: 'POST', body: text}); return true; } catch (e) {} }
  if (window.showDirectoryPicker) {
    try { let dir = await idb('readonly', st => st.get('data'));
      if (dir && (await dir.queryPermission({mode: 'readwrite'})) !== 'granted') dir = ask ? await dataFolder() : null;
      if (!dir && ask) dir = await pickFolder();
      if (dir) { await writeSaved(dir, c, file, text); return true; } } catch (e) {}
  }
  return false;
}
async function listSave(ask){
  const c = S.char, done = await charFileSave(c, LIST_FILE, listFileText(c), ask);
  const was = S._listUnsaved;
  S._listUnsaved = !done;
  if (ask) { S.toast = t(done ? 'lpSaved' : 'lpBrowserOnly'); render(); } else if (was !== S._listUnsaved && S._listMenu) render();
}

/* ---- what a row shows ---- */
// a piece of the set that no bag holds (the set's own pieces: what it inherits is its parent's business)
let LIST_MISS = {gen: null, out: {}};
function setMissing(s){
  const gen = DATA_GEN + '|' + S.char;
  if (LIST_MISS.gen !== gen) LIST_MISS = {gen, out: {}};
  if (!(s.path in LIST_MISS.out)) { let miss = false;
    try { miss = SLOTS.some(slot => s.pieces[slot] && holdState(slot, s.pieces[slot]) === 'missing'); } catch (e) {}
    LIST_MISS.out[s.path] = miss; }
  return LIST_MISS.out[s.path];
}
const listMarks = s => (setMissing(s) ? `<i class="rowmiss" title="${esc(t('lpMissing'))}">!</i>` : '') + (trialCount(s) ? `<i class="rowtry" title="${esc(t('rowTry'))}"></i>` : '') +
  (Object.keys(s.pieces || {}).length ? '' : `<small class="rowvoid">${esc(t('rowVoid'))}</small>`);
// the two actions of a row, shown when the pointer is on it (the star stays when the set is pinned)
function listRowActs(path, group){
  const pin = listPinned(path);
  return `<span class="rowacts ${pin ? 'pinned' : ''}"><button class="ract" data-listpin="${esc(path)}" aria-pressed="${pin}" title="${esc(t(pin ? 'lpUnpin' : 'lpPin'))}">${pin ? '★' : '☆'}</button>` +
    (group ? `<button class="ract" data-listout="${esc(group)}|${esc(path)}" title="${esc(t('lpOut'))}">×</button>`
      : `<button class="ract" data-listgrp="${esc(path)}" aria-expanded="${S._listGrpFor === path}" title="${esc(t('lpGroup'))}">▤</button>`) + `</span>`;
}
// under a row whose ▤ was clicked: the groups to tick, and a new one to name
function listGroupPicker(path){
  if (S._listGrpFor !== path) return '';
  const groups = listPrefs().groups;
  return `<div class="grppick">` + (groups.length ? groups.map(g => `<button class="gpick" data-listin="${esc(g.id)}|${esc(path)}" aria-pressed="${g.sets.includes(path)}">${esc(g.name)}</button>`).join('')
    : `<span class="muted">${esc(t('lpNoGroup'))}</span>`) + listNameInput('newfor:' + path, '', t('lpNewGroup')) + `</div>`;
}
const listNameInput = (what, value, hint) => `<input class="listname" data-listname="${esc(what)}" value="${esc(value)}" placeholder="${esc(hint)}" maxlength="32" autocomplete="off" spellcheck="false">`;

/* ---- the sections of the player's own, over the page's categories ---- */
// rowOf(path, group) draws one set's row (sets_view.js gives it: it knows the cards); a set no longer in the file
// is left out, and stays in the arrangement in case it comes back
function listOwnSections(rowOf, known, q){
  const p = listPrefs();
  let out = '';
  const section = (key, label, n, here, acts) => { const open = !!q || S.famOpen[S.job + '|' + key] !== false;
    return [`<div class="famrow own" data-owngrp="${esc(key)}" ${key.startsWith('g:') ? 'draggable="true"' : ''}><button class="fam own ${here ? 'here' : ''}" data-owntoggle="${esc(key)}" aria-expanded="${open}" title="${esc(t(key === 'pin' ? 'ttPinned' : 'ttGroup'))}"><span>${label}</span><span>${n}</span></button>${acts}</div>`, open]; };
  const pins = p.pins.filter(x => known.has(x));
  if (pins.length) { const [head, open] = section('pin', '★ ' + esc(t('lpPinned')), pins.length, false, '');
    out += head + (open ? pins.map(x => rowOf(x, '')).join('') : ''); }
  for (const g of p.groups) { const sets = g.sets.filter(x => known.has(x)), editing = S._listEdit === 'group:' + g.id;
    const acts = `<span class="famacts"><button class="ract" data-listedit="group:${esc(g.id)}" title="${esc(t('lpRename'))}">✎</button><button class="ract" data-listdel="${esc(g.id)}" title="${esc(t('lpDelete'))}">🗑</button></span>`;
    const [head, open] = section('g:' + g.id, editing ? '' : esc(g.name), sets.length, false, acts);
    out += (editing ? `<div class="famrow own edit">${listNameInput('group:' + g.id, g.name, t('lpGroupName'))}</div>` : head) +
      (open ? (sets.length ? sets.map(x => rowOf(x, g.id)).join('') : `<p class="grpempty">${esc(t('lpEmptyGroup'))}</p>`) : ''); }
  if (S._listEdit === 'new') out += `<div class="famrow own edit">${listNameInput('new', '', t('lpGroupName'))}</div>`;
  return out;
}
// a category of the page's: its header, with what to do with it when the pointer is on it
function listFamHead(fam, n, here, open){
  if (S._listEdit === 'fam:' + fam) return `<div class="famrow edit">${listNameInput('fam:' + fam, listFamLabel(fam), t('fam.' + fam))}</div>`;
  return `<div class="famrow"><button class="fam ${here ? 'here' : ''}" data-famtoggle="${fam}" aria-expanded="${open}" title="${esc(t('ttFam', {w: t('famWhen.' + fam)}))}"><span>${esc(listFamLabel(fam))}</span><span>${n}</span></button>` +
    `<span class="famacts"><button class="ract" data-listedit="fam:${fam}" title="${esc(t('lpRename'))}">✎</button><button class="ract" data-listhide="${fam}" title="${esc(t('lpHide'))}">⦸</button></span></div>`;
}

/* ---- the top of the list and its menu: drawn by atelier/src/screens/sets/ListHead.svelte (setlist.ts listHead) ---- */
// The history of what the page wrote, in the top bar beside the files it concerns (it was a link of the list)
const historyBadge = () => S.char && S.job ? `<button class="live act" data-pushhist title="${esc(t('lpHistoryTip'))}">⟲<span class="lbl"> ${esc(t('lpHistory'))}</span></button>` : '';

/* ---- clicks, names typed, the width ---- */
function listApplyName(what, value){
  const p = listPrefs(), name = value.trim().slice(0, 32);
  S._listEdit = null;
  if (what.startsWith('fam:')) { const fam = what.slice(4); if (name && name !== t('fam.' + fam)) p.names[fam] = name; else delete p.names[fam]; return listChanged(); }
  if (!name) return render();
  if (what.startsWith('group:')) { const g = p.groups.find(x => x.id === what.slice(6)); if (g) g.name = name; return listChanged(); }
  const g = {id: Date.now().toString(36) + Math.floor(Math.random() * 1296).toString(36), name, sets: []};
  if (what.startsWith('newfor:')) { g.sets.push(what.slice(7)); S._listGrpFor = null; }
  p.groups.push(g);
  listChanged();
}
function listFocusName(){ setTimeout(() => { const el = document.querySelector('.setlist input[data-listname]:not([data-listname^="newfor:"])') || document.querySelector('.setlist input[data-listname]'); if (el) { el.focus(); el.select(); } }, 0); }
document.addEventListener('click', e => {
  const b = e.target.closest('button'), d = b ? b.dataset : {};
  // a click anywhere else closes the menu
  if (S._listMenu && !e.target.closest('.listmenu') && !('listmenu' in d)) { S._listMenu = false; render(); }
  if (!b || !b.closest('.setlist, #top')) return;
  const p = listPrefs(), toggle = (list, x) => { const i = list.indexOf(x); if (i < 0) list.push(x); else list.splice(i, 1); };
  if ('listmenu' in d) { S._listMenu = !S._listMenu; render(); return; }
  // a section of the player's own is open until closed (the page's categories are closed until opened)
  if (d.owntoggle) { const k = S.job + '|' + d.owntoggle; S.famOpen[k] = S.famOpen[k] === false; render(); return; }
  if (d.listpin) { toggle(p.pins, d.listpin); return listChanged(); }
  if (d.listgrp) { S._listGrpFor = S._listGrpFor === d.listgrp ? null : d.listgrp; render(); return; }
  if (d.listin) { const [id, path] = [d.listin.slice(0, d.listin.indexOf('|')), d.listin.slice(d.listin.indexOf('|') + 1)], g = p.groups.find(x => x.id === id);
    if (g) toggle(g.sets, path); return listChanged(); }
  if (d.listout) { const [id, path] = [d.listout.slice(0, d.listout.indexOf('|')), d.listout.slice(d.listout.indexOf('|') + 1)], g = p.groups.find(x => x.id === id);
    if (g) g.sets = g.sets.filter(x => x !== path); return listChanged(); }
  if (d.listedit) { S._listEdit = d.listedit; render(); return listFocusName(); }
  if ('listnew' in d) { S._listEdit = 'new'; S._listMenu = false; render(); return listFocusName(); }
  if (d.listdel) { const g = p.groups.find(x => x.id === d.listdel);
    if (g && confirm(t('lpDeleteAsk', {n: g.name}))) { p.groups = p.groups.filter(x => x !== g); listPrefs().groups = p.groups; listChanged(); } return; }
  if (d.listhide) { if (!p.hide.includes(d.listhide)) p.hide.push(d.listhide); return listChanged(); }
  if (d.listshow) { p.hide = p.hide.filter(f => f !== d.listshow); listPrefs().hide = p.hide; return listChanged(); }
  if ('listsave' in d) { listSave(true); return; }
  // the menu's own lines close it once done (events.js does the work of the lines it already knew)
  if (b.closest('.listmenu') && !('listpaths' in d) && !('listall' in d)) { S._listMenu = false; setTimeout(render, 0); }
});
document.addEventListener('keydown', e => {
  const el = e.target;
  if (!el || !el.dataset || !el.dataset.listname) return;
  if (e.key === 'Enter') { e.preventDefault(); e.stopPropagation(); listApplyName(el.dataset.listname, el.value); }
  else if (e.key === 'Escape') { e.preventDefault(); e.stopPropagation(); S._listEdit = null; if (el.dataset.listname.startsWith('newfor:')) S._listGrpFor = null; render(); }
  else e.stopPropagation();
}, true);
// Dragging: a set (from anywhere in the list) dropped on "Pinned" or on a group goes into it, dropped on a set of
// one of those takes the place before it (that is how they are put in order); from a group to another, it moves.
// A group dragged on another group takes the place before it.
let LIST_DRAG = null;
const listDropAt = e => e.target.closest && e.target.closest('.setlist .setrow.own, .setlist .famrow.own');
const listDropMark = el => { for (const x of document.querySelectorAll('.setlist .dropat')) if (x !== el) x.classList.remove('dropat'); if (el) el.classList.add('dropat'); };
document.addEventListener('dragstart', e => {
  const r = e.target.closest && e.target.closest('.setlist [data-rowpath], .setlist .famrow.own[draggable]');
  if (!r) return;
  LIST_DRAG = r.dataset.rowpath ? {path: r.dataset.rowpath, from: r.dataset.rowgroup == null ? null : r.dataset.rowgroup || 'pin'} : {group: r.dataset.owngrp.slice(2)};
  e.dataTransfer.effectAllowed = 'move';
  try { e.dataTransfer.setData('text/plain', LIST_DRAG.path || LIST_DRAG.group); } catch (x) {}
});
document.addEventListener('dragover', e => {
  const at = LIST_DRAG && listDropAt(e);
  if (!at || (LIST_DRAG.group && !(at.dataset.owngrp || '').startsWith('g:'))) return listDropMark(null);
  e.preventDefault(); e.dataTransfer.dropEffect = 'move'; listDropMark(at);
});
document.addEventListener('drop', e => {
  const at = LIST_DRAG && listDropAt(e), d = LIST_DRAG;
  if (!at) return;
  e.preventDefault();
  LIST_DRAG = null; listDropMark(null);
  const p = listPrefs(), listOf = key => key === 'pin' ? p.pins : (p.groups.find(g => g.id === key) || {}).sets;
  if (d.group) { const to = (at.dataset.owngrp || '').slice(2), moved = p.groups.find(g => g.id === d.group);
    if (!moved || !to || to === d.group) return render();
    p.groups = p.groups.filter(g => g !== moved); p.groups.splice(p.groups.findIndex(g => g.id === to), 0, moved);
    listPrefs().groups = p.groups; return listChanged(); }
  // where it lands: a section's header (at its end) or one of its sets (before it)
  const key = at.dataset.owngrp ? (at.dataset.owngrp === 'pin' ? 'pin' : at.dataset.owngrp.slice(2)) : (at.dataset.rowgroup || 'pin'), list = listOf(key);
  if (!list) return render();
  if (d.from && d.from !== key && d.from !== 'pin') { const src = listOf(d.from); if (src) src.splice(src.indexOf(d.path), 1); }
  const was = list.indexOf(d.path); if (was >= 0) list.splice(was, 1);
  const before = at.dataset.owngrp ? -1 : list.indexOf(at.dataset.rowpath);
  if (before < 0) list.push(d.path); else list.splice(before, 0, d.path);
  listChanged();
});
document.addEventListener('dragend', () => { if (LIST_DRAG) { LIST_DRAG = null; listDropMark(null); render(); } });
// the width: the list's right edge is dragged; the page follows without a redraw, the width is kept
document.addEventListener('pointerdown', e => {
  if (!e.target.classList || !e.target.classList.contains('listgrip')) return;
  const box = e.target.closest('.setsx'), aside = e.target.closest('.setlist');
  if (!box || !aside) return;
  e.preventDefault();
  const left = aside.getBoundingClientRect().left;
  const move = ev => { S.listW = Math.max(LIST_W[0], Math.min(LIST_W[1], Math.round(ev.clientX - left))); box.style.setProperty('--listw', S.listW + 'px'); };
  const up = () => { removeEventListener('pointermove', move); removeEventListener('pointerup', up); document.documentElement.classList.remove('resizing'); save(); };
  document.documentElement.classList.add('resizing');
  addEventListener('pointermove', move); addEventListener('pointerup', up);
});
