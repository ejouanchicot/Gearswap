// GearSwap Atelier · gear_pick.js: the new layout's piece picker (2026-10-06). A click on a slot opens a window over
// the page in place of the drawer on the right: filters on the left (where the pieces come from, the stat they are
// chosen for, the pieces of no use hidden), the pieces on the right as cards, each with what it gives the set and,
// when a stat is chosen, its value and the gap to the piece worn. The choices are the drawer's (pieceChoices, drawer.js)
// and a click tries a piece the same way (data-try, events.js); the old layout keeps the drawer.
// (loaded by atelier/index.html after party_builder.js: see the list there)

Object.assign(T.fr, {
  gpFrom: 'Provenance', gpMine: 'Mes pièces', gpSets: 'Dans mes sets', gpGame: 'Tout le jeu', gpFor: 'Choisie pour', gpAny: 'Ce que le set cherche',
  gpSearch: 'Chercher un nom, une stat…', gpJunk: 'Montrer les pièces sans intérêt ({n})', gpNone: 'Aucune pièce avec ces filtres.',
  gpSortRel: 'Pertinence', gpSortHi: 'Valeur décroissante', gpSortLo: 'Valeur croissante', gpSortAz: 'Nom A → Z', gpSortZa: 'Nom Z → A', gpSortIlv: 'Niveau d’objet', gpSortLbl: 'Trier par',
  gpKind: 'Type', gpKindAll: 'Tous', gpKindOther: 'Autres',
  gpWorn: 'portée', gpVs: 'vs portée', gpCount: '{n} pièce(s)', gpCurrent: 'Portée dans ce set', gpGameWait: 'chargement du catalogue…',
});
Object.assign(T.en, {
  gpFrom: 'From', gpMine: 'My pieces', gpSets: 'In my sets', gpGame: 'Whole game', gpFor: 'Chosen for', gpAny: 'The set’s key stats',
  gpSearch: 'Search a name, a stat…', gpJunk: 'Show pieces that are not useful ({n})', gpNone: 'No piece with these filters.',
  gpSortRel: 'Relevance', gpSortHi: 'Value, highest first', gpSortLo: 'Value, lowest first', gpSortAz: 'Name A → Z', gpSortZa: 'Name Z → A', gpSortIlv: 'Item level', gpSortLbl: 'Sort by',
  gpKind: 'Type', gpKindAll: 'All', gpKindOther: 'Others',
  gpWorn: 'worn', gpVs: 'vs worn', gpCount: '{n} piece(s)', gpCurrent: 'Worn in this set', gpGameWait: 'loading the catalog…',
});

// Where the pieces come from: yours (in your bags), the ones your sets name (yours or not), every item of the game
// your job can wear (the catalogue, loaded on demand)
const GP_SRC = [['mine', 'gpMine'], ['sets', 'gpSets'], ['game', 'gpGame']];
const gpInSrc = (o, src) => src === 'mine' ? o.owned : src === 'sets' ? o.seen > 0 || o.orig : true;

// The orders of the list: the page's own (the closest to the set first; the highest value first when a stat is chosen),
// the chosen stat's value from the lowest, the name either way, the item level (the level when it has none)
const gpLevel = o => o.ilv || o.lv || 0;
const GP_SORT = {
  lo: (a, b) => a[2].good - b[2].good,
  az: (a, b) => a[0].piece.name.localeCompare(b[0].piece.name),
  za: (a, b) => b[0].piece.name.localeCompare(a[0].piece.name),
  ilv: (a, b) => gpLevel(b[0]) - gpLevel(a[0]) || a[0].piece.name.localeCompare(b[0].piece.name),
};
const gpSorts = fx => (fx ? [['rel', 'gpSortHi'], ['lo', 'gpSortLo']] : [['rel', 'gpSortRel']]).concat([['az', 'gpSortAz'], ['za', 'gpSortZa'], ['ilv', 'gpSortIlv']]);

// The kinds of the pieces listed (itemKind, stats.js), the most common first, those of no known kind last
function gpKinds(rows){
  const n = {};
  for (const [o] of rows) { const k = itemKind(o.piece.name); n[k] = (n[k] || 0) + 1; }
  return Object.entries(n).sort((a, b) => (a[0] === '') - (b[0] === '') || b[1] - a[1] || a[0].localeCompare(b[0]));
}

// The stats offered as filters: what the set is after, heaviest first (drawer.js setWants), the always-counted ones
// (DT, PDT, MDT) left to the "what the set is after" default
function gpStats(s){
  const {want} = setWants(s);
  return Object.keys(want).filter(k => !k.endsWith('*') && !(k in ALWAYS) && want[k] >= 0.3).sort((a, b) => want[b] - want[a] || statOrder(a, b)).slice(0, 12);
}
// A piece's value for one stat, its direction counted (less damage taken is more)
function gpValue(p, slot, key){
  const r = pieceStats(p, slot), e = r && Object.entries(r.stats || {}).find(([k]) => baseKey(k) === key);
  if (!e) return null;
  return {e: e[1], good: (GOOD_DOWN.has(key) ? -1 : 1) * e[1].v};
}

function gpOpen(card, s, slot, p, opts, label){
  if (!S.gpSrc) S.gpSrc = 'mine';
  // the whole game is the catalogue: loaded once, then the window comes back
  if (S.gpSrc === 'game' && !S.allItems) { S.allItems = true; save(); return loadCatalog(() => openSlot(S._drawer.ci, slot)); }
  // the window's body: drawn by the Svelte application (atelier/src/screens/dialogs/gearpick.ts)
  const title = `${esc(label)} <span class="gpcur">${p ? esc(p.name) : '—'}</span><small>${esc(niceName(card))} · <code>${esc(s.path)}</code></small>`;
  ATELIER_DIALOG.show({cls: 'gpdlg', titleHtml: title, gearPick: ATELIER_DIALOG.gearPickView(s, slot, p, opts)});
  const q = $('#drawq');
  if (q) q.focus();
}
// The window's filters: drawn again with the same piece list
function gpClick(d){
  const {ci, slot} = S._drawer || {};
  if (ci == null) return;
  if (d.gpsrc) { S.gpSrc = d.gpsrc; save(); }
  if (d.gpfx != null) S._gpFx = d.gpfx;
  if (d.gpsort) { S.gpSort = d.gpsort; save(); }
  if (d.gpkind != null) S._gpKind = {slot, k: d.gpkind === '*' ? null : d.gpkind};
  openSlot(ci, slot);
}
