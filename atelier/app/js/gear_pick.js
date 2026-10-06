// GearSwap Atelier · gear_pick.js: the new layout's piece picker (2026-10-06). A click on a slot opens a window over
// the page in place of the drawer on the right: filters on the left (where the pieces come from, the stat they are
// chosen for, the pieces of no use hidden), the pieces on the right as cards, each with what it gives the set and,
// when a stat is chosen, its value and the gap to the piece worn. The choices are the drawer's (pieceChoices, drawer.js)
// and a click tries a piece the same way (data-try, events.js); the old layout keeps the drawer.
// (loaded by atelier/index.html after party_builder.js: see the list there)

Object.assign(T.fr, {
  gpFrom: 'Provenance', gpMine: 'Mes pièces', gpSets: 'Dans mes sets', gpGame: 'Tout le jeu', gpFor: 'Choisie pour', gpAny: 'Ce que le set cherche',
  gpSearch: 'Chercher un nom, une stat…', gpJunk: 'Montrer les pièces sans intérêt ({n})', gpNone: 'Aucune pièce avec ces filtres.',
  gpSortRel: 'Pertinence', gpSortHi: 'Valeur décroissante', gpSortLo: 'Valeur croissante', gpSortAz: 'Nom A → Z', gpSortZa: 'Nom Z → A', gpSortIlv: 'Niveau d’objet', gpSortLbl: 'Trier',
  gpKind: 'Type', gpKindAll: 'Tous', gpKindOther: 'Autres',
  gpWorn: 'portée', gpVs: 'vs portée', gpCount: '{n} pièce(s)', gpCurrent: 'Portée dans ce set', gpGameWait: 'chargement du catalogue…',
});
Object.assign(T.en, {
  gpFrom: 'From', gpMine: 'My pieces', gpSets: 'In my sets', gpGame: 'Whole game', gpFor: 'Chosen for', gpAny: 'What the set is after',
  gpSearch: 'Search a name, a stat…', gpJunk: 'Show the pieces of no use ({n})', gpNone: 'No piece with these filters.',
  gpSortRel: 'Relevance', gpSortHi: 'Value, highest first', gpSortLo: 'Value, lowest first', gpSortAz: 'Name A → Z', gpSortZa: 'Name Z → A', gpSortIlv: 'Item level', gpSortLbl: 'Sort',
  gpKind: 'Type', gpKindAll: 'All', gpKindOther: 'Others',
  gpWorn: 'worn', gpVs: 'vs worn', gpCount: '{n} piece(s)', gpCurrent: 'Worn in this set', gpGameWait: 'loading the catalogue…',
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
  const fx = S._gpFx && gpStats(s).includes(S._gpFx) ? S._gpFx : '';
  // the piece worn without the stat counts as 0 of it: every gap is then to the set as it is
  const worn = fx && p ? gpValue(p, slot, fx) || {good: 0} : null;
  const shown = opts.map((o, i) => [o, i]).filter(([o]) => gpInSrc(o, S.gpSrc));
  const junk = shown.filter(([o]) => o.grp === 5).length;
  let rows = shown.filter(([o]) => S._showJunk || o.grp !== 5);
  // the hands and the ammo by kind (Sword, Great Axe, Shield, Grip...): the kinds among the pieces listed, with their count
  const kinds = WEAPON_SLOTS.has(slot) ? gpKinds(rows) : [];
  const kind = (S._gpKind || {}).slot === slot && kinds.some(([k]) => k === S._gpKind.k) ? S._gpKind.k : null;
  if (kind != null) rows = rows.filter(([o]) => itemKind(o.piece.name) === kind);
  if (fx) rows = rows.map(([o, i]) => [o, i, gpValue(o.piece, slot, fx)]).filter(x => x[2] && x[2].good > 0).sort((a, b) => b[2].good - a[2].good);
  const sorts = gpSorts(fx), sort = sorts.some(([k]) => k === S.gpSort) ? S.gpSort : 'rel';
  if (GP_SORT[sort]) rows.sort(GP_SORT[sort]);
  const sortSel = `<label class="gpsort">${esc(t('gpSortLbl'))}<select class="buffsel" data-gpsort>${sorts.map(([k, l]) => `<option value="${k}" ${k === sort ? 'selected' : ''}>${esc(t(l))}</option>`).join('')}</select></label>`;
  const seg = `<div class="gpseg" role="group">${GP_SRC.map(([k, l]) => `<button data-gpsrc="${k}" aria-pressed="${S.gpSrc === k}">${esc(t(l))}</button>`).join('')}</div>`;
  const stats = [['', t('gpAny')]].concat(gpStats(s).map(k => [k, statLabel(k, {label: k.toUpperCase()})]));
  const fxList = `<div class="gpfx">${stats.map(([k, l]) => `<button data-gpfx="${k}" aria-pressed="${fx === k}">${esc(l)}</button>`).join('')}</div>`;
  const side = `<aside class="gpside"><input id="drawq" class="gpq" type="search" placeholder="${esc(t('gpSearch'))}" autocomplete="off" spellcheck="false">` +
    `<h4>${esc(t('gpFrom'))}</h4>${seg}` +
    (kinds.length > 1 ? `<h4>${esc(t('gpKind'))}</h4><div class="gpfx">` + [[null, t('gpKindAll'), kinds.reduce((n, x) => n + x[1], 0)]].concat(kinds.map(([k, n]) => [k, k || t('gpKindOther'), n]))
      .map(([k, l, n]) => `<button data-gpkind="${k == null ? '*' : esc(k)}" aria-pressed="${kind === k}"><span>${esc(l)}</span><small>${n}</small></button>`).join('') + `</div>` : '') +
    `<h4>${esc(t('gpFor'))}</h4>${fxList}` +
    (junk ? `<label class="chk gpjunk"><input type="checkbox" data-gpjunk ${S._showJunk ? 'checked' : ''}> ${esc(t('gpJunk', {n: junk}))}</label>` : '') +
    (p && !(['main', 'sub'].includes(slot) && family(s.path, s.pieces) !== 'weapons') ? `<button class="btn ghost" data-tryempty>${t('tryEmpty')}</button>` : '') + `</aside>`;
  const item = ([o, i, v]) => gpCard(o, i, slot, v, worn);
  const list = rows.length ? rows.map(item).join('') : `<p class="muted">${esc(t('gpNone'))}</p>`;
  const wl = wantsLine(s);
  const body = `<div class="gpgrid">${side}<section class="gpmain"><div class="gphead"><div class="gpbar"><span class="muted small">${esc(t('gpCount', {n: rows.length}))}</span>${sortSel}</div>` +
    `${wl ? `<p class="gpwants small">${wl}</p>` : ''}</div><div class="choice gplist">${list}</div></section></div>`;
  const title = `${esc(label)} <span class="gpcur">${p ? esc(p.name) : '—'}</span><small>${esc(niceName(card))} · <code>${esc(s.path)}</code></small>`;
  showDialog('gpdlg', title, body, '');
  const q = $('#drawq');
  if (q) q.focus();
}
// One piece: its icon, name and rank, its tags (the set's piece, tried, its best version), its augments, what it gives the
// set, where it is; with a stat chosen, its value and the gap to the piece worn on the right
function gpCard(o, i, slot, v, worn){
  const r = o.cat ? null : pieceStats(o.piece, slot), augs = o.piece.augs || [], up = o.upgrade;
  const where = o.cat ? [t('notOwned'), o.ilv ? 'iLv ' + o.ilv : t('lvShort', {n: o.lv})].join(' · ')
    : [o.owned ? (o.count > 1 ? '×' + o.count + ' · ' : '') + (o.where && o.where.length ? o.where.map(whereLabel).join(', ') : t('inBag')) : t('notOwned'), o.seen ? t('inSets', {n: o.seen}) : ''].filter(Boolean).join(' · ');
  const tag = (o.orig ? `<em class="tag orig">${t('setPiece')}</em>` : o.cur ? `<em class="tag cur">${t('triedTag')}</em>` : o.curMax ? `<em class="tag cur">${t('triedMax')}</em>` : '') +
    (up ? `<span class="tag up ${o.curMax ? 'on' : ''}" data-trymax="${i}" role="button" tabindex="0" title="${esc(t('maxChipTip'))}">${up.to ? `→ R${up.to}` : t('capeMaxTag')}</span>` : '');
  const gap = v && worn ? v.good - worn.good : null;
  const val = v ? `<span class="gpval"><b>${esc(fmtStat(v.e))}</b>${gap != null ? `<small class="${gap > 0 ? 'up' : gap < 0 ? 'down' : ''}">${gap > 0 ? '+' : gap < 0 ? '−' : '±'}${Math.abs(Math.round(gap * 10) / 10)} ${esc(t('gpVs'))}</small>` : ''}</span>` : '';
  return `<button type="button" class="gpcard ${o.orig ? 'orig' : ''} ${o.cur || o.curMax ? 'cur' : ''} ${o.grp === 5 ? 'junk' : ''}" data-try="${i}">${icon(o.piece.name)}` +
    `<span class="gpinfo"><span class="gpname"><b>${esc(o.piece.name)}</b>${r && r.rank != null ? `<span class="rk">R${r.rank}</span>` : ''}${tag}</span>` +
    (augs.length ? `<span class="augl">◆ ${esc(augs.filter(a => !/^Path:/.test(a)).join(' · ') || augs.join(' · '))}</span>` : '') +
    (o.fit && o.fit.length ? `<span class="fitl">${esc(o.fit.join(' · '))}</span>` : o.junk && o.why ? `<span class="whyl">${esc(o.why)}</span>` : '') +
    `<small>${esc(where)}</small></span>${val}</button>`;
}
// The window's filters: drawn again with the same piece list
function gpClick(d){
  const {ci, slot} = S._drawer || {};
  if (ci == null) return;
  if (d.gpsrc) { S.gpSrc = d.gpsrc; save(); }
  if (d.gpfx != null) S._gpFx = d.gpfx;
  if (d.gpkind != null) S._gpKind = {slot, k: d.gpkind === '*' ? null : d.gpkind};
  openSlot(ci, slot);
}
