// GearSwap Atelier · trial.js: pieces tried, Compare
// (loaded by atelier/index.html, in the order of the list there)
/* ---- pieces tried in the page ---- */
const trialKey = s => S.char + '|' + S.job + '|' + s.path;
const trialCount = s => Object.entries(S.trial[trialKey(s)] || {}).filter(([slot, p]) => !heldAlready(s, slot, p)).length;
// A hand chosen for a set (main or sub; null: back to Auto): a weaponskill's set holds it for that weaponskill, any other
// set has it forced in the page, the menus of the set's top following
function chooseHand(s, slot, piece){
  const ws = wsOfSet(s);
  setTrial(s, slot, undefined);
  if (!ws) return setForce(slot, piece ? optPieces({[slot]: piece})[slot] : null);
  const k = heldKey(ws);
  if (slot === 'main') { S.held = Object.assign({}, S.held); if (piece) S.held[k] = piece.name; else delete S.held[k]; }
  else { S.heldSub = Object.assign({}, S.heldSub); if (piece) S.heldSub[k] = optPieces({sub: piece}).sub; else delete S.heldSub[k]; }
  save();
}
function setTrial(s, slot, piece){
  const k = trialKey(s), tr = S.trial[k] = S.trial[k] || {}, dr = S.drafts[k];
  if (dr && dr.info) dr.info.edited = true;
  if (piece === undefined) delete tr[slot]; else tr[slot] = piece;
  if (!Object.keys(tr).length) delete S.trial[k];
}
// The same set without the tried pieces (what the differences compare to)
function withoutTrial(fn){ S._noTrial = true; try { return fn(); } finally { S._noTrial = false; } }
// The trial's bar (drawn by atelier/src/screens/sets/trial.ts) keeps its place when nothing is tried (a line that says
// how to try a piece): the gear under it does not move when a first piece is tried
Object.assign(T.fr, {tryIdle: 'Rien à l’essai. Clique une pièce pour en essayer une autre : les écarts et le bouton pour l’écrire dans ton fichier viendront ici.'});
Object.assign(T.en, {tryIdle: 'Nothing on trial. Click a piece to try another one: the differences and the button that writes it to your file will come here.'});
// The whole set, the tried pieces in, to paste in the sets file in place of the set: every slot written out, the
// set's own pieces with their bag and priority (the hands of a set that leaves them to the weapon modes are not a
// try's: applyTrial)
function trialLua(s){
  const q = v => '"' + String(v).replace(/\\/g, '\\\\').replace(/"/g, '\\"') + '"';
  const tr = S.trial[trialKey(s)] || {}, pieces = Object.assign({}, s.pieces);
  const hands = family(s.path, s.pieces) !== 'weapons' && !handsOwn(s);
  for (const [slot, p] of Object.entries(tr)) if (!(hands && (slot === 'main' || slot === 'sub'))) pieces[slot] = p || {name: 'empty'};
  const lua = p => { if (isEmpty(p)) return 'empty';
    const f = [`name = ${q(p.name)}`];
    if (p.augs && p.augs.length) f.push(`augments = { ${p.augs.map(q).join(', ')} }`);
    if (p.bag) f.push(`bag = ${q(p.bag)}`);
    if (p.priority != null) f.push(`priority = ${p.priority}`);
    return f.length > 1 ? `{ ${f.join(', ')} }` : q(p.name); };
  const lines = SLOTS.filter(slot => pieces[slot]).map(slot => `    ${slot} = ${lua(pieces[slot])},`);
  return `-- From the Atelier: the whole set, the tried pieces in\n${s.path} = {\n${lines.join('\n')}\n}\n`;
}
// (drawn by the Svelte application: atelier/src/screens/dialogs/Dialog.svelte)
function openLua(s){
  ATELIER_DIALOG.show({cls: '', titleHtml: t('luaTitle'), ariaLabel: t('luaTitle'), lua: trialLua(s), buttonsHtml: `<button class="btn" data-copylua>${t('copy')}</button>`});
}
// The set with other tried pieces for a moment (a draft, the file's pieces, none)
function withTrialAs(s, tr, fn){
  const k = trialKey(s), keep = S.trial[k];
  S.trial[k] = tr;
  try { return fn(); } finally { if (keep === undefined) delete S.trial[k]; else S.trial[k] = keep; }
}
// The columns: your file, what the game wears when the page saved pieces, then each draft
function compareColumns(s){
  const cols = [], was = s.was || {};
  if (Object.keys(was).length) {
    const file = {};
    for (const [slot, p] of Object.entries(was)) file[slot] = !p || p.name === 'empty' ? null : p;
    cols.push({label: t('cmpFile'), tr: file}, {label: t('cmpTest'), tr: {}});
  } else cols.push({label: t('cmpFile'), tr: {}});
  if (trialCount(s)) cols.push({label: t('cmpTry'), tr: S.trial[trialKey(s)] || {}});
  ((S.drafts[trialKey(s)] || {}).kept || []).forEach((x, i) => cols.push({label: x.name, tr: x.tr, kept: i}));
  return cols.map(c => withTrialAs(s, c.tr, () => Object.assign(c, {pieces: withWeapons(s).pieces, stats: setStats(s).total})));
}
// Compare: drawn by the Svelte application (atelier/src/screens/dialogs/compare.ts), the columns from compareColumns above
function openCompare(s){
  ATELIER_DIALOG.show({cls: 'cmpdlg', titleHtml: `${t('cmpTitle')} · <code>${esc(shortPath(s.path))}</code> ${statPickBtn()}`, compare: ATELIER_DIALOG.compareView(s)});
}
// A dialog over the page: title, body, the buttons beside Close
// (drawn by the Svelte application: atelier/src/screens/dialogs/Dialog.svelte)
function showDialog(cls, title, body, buttons){
  ATELIER_DIALOG.show({cls, titleHtml: title, bodyHtml: body, buttonsHtml: buttons});
}

/* ---- tried pieces saved ---- */
// The tried pieces of a set are the ones saved for it (waiting for a reload in game)
function trialSaved(s){
  const tr = S.trial[trialKey(s)] || {}, saved = ((setOverrides()[S.job] || {})[s.path]) || {};
  const asPiece = v => v === 'empty' ? null : typeof v === 'string' ? {name: v} : {name: v.name, augs: v.augments};
  return Object.keys(tr).length > 0 && Object.entries(tr).every(([slot, p]) => slot in saved && samePiece(p, asPiece(saved[slot])));
}

/* ---- slots locked for the optimizers, and the menu of a slot ---- */
// A locked slot keeps what it shows (its tried piece, or nothing) through every search: the optimizers neither
// change it nor count another piece there. Kept by set, in the browser; never written to a file. The hands and the
// ranged slot are the weapon menus' (the optimizers keep them unless "Free weapons").
const LOCKABLE = slot => !['main', 'sub', 'range'].includes(slot);
const lockedSlots = s => Object.keys((S.locks || {})[trialKey(s)] || {}).filter(LOCKABLE);
const isLocked = (s, slot) => !!((S.locks || {})[trialKey(s)] || {})[slot];
function toggleLock(s, slot){
  const k = trialKey(s), mine = Object.assign({}, (S.locks || {})[k]);
  if (mine[slot]) delete mine[slot]; else mine[slot] = true;
  S.locks = Object.assign({}, S.locks);
  if (Object.keys(mine).length) S.locks[k] = mine; else delete S.locks[k];
  save();
}
function unlockAll(s){ S.locks = Object.assign({}, S.locks); delete S.locks[trialKey(s)]; save(); }
// The set a search starts from (the file's, without the tried pieces), its locked slots as the page shows them
function lockedBase(s, base){
  const shown = withWeapons(s).pieces;
  for (const slot of lockedSlots(s)) { if (shown[slot] && !isEmpty(shown[slot])) base[slot] = shown[slot]; else delete base[slot]; }
  return base;
}
// A search's choices without the locked slots: a slot with no choice keeps the piece the search starts with
function lockChoices(s, choices){
  for (const slot of lockedSlots(s)) delete choices[slot];
  // an Impact set's body and head are the cloak's (nuke_layers.js isImpactSet)
  if (isImpactSet(s)) { delete choices.body; delete choices.head; }
  return choices;
}
// The menu of a slot of the grid: choose a piece, lock it, empty it, put the set's piece back (drawn by the Svelte
// application: atelier/src/screens/dialogs/slotmenus.svelte.ts), placed under the slot or above it, inside the window
function openSlotMenu(el, ci, slot){
  const v = ATELIER_SLOTMENU.view(ci, slot);
  if (!v) return;
  const menu = ATELIER_SLOTMENU.show(v);
  menu.hidden = false; $('#tip').hidden = true;
  const b = el.getBoundingClientRect(), w = menu.offsetWidth, h = menu.offsetHeight;
  menu.style.left = Math.max(8, Math.min(b.left, innerWidth - w - 8)) + 'px';
  menu.style.top = (b.bottom + 6 + h < innerHeight ? b.bottom + 6 : Math.max(8, b.top - 6 - h)) + 'px';
  const first = menu.querySelector('button'); if (first) first.focus();
}
function closeSlotMenu(){ const m = $('#slotmenu'); if (m) m.hidden = true; }
function slotMenuAct(act, ci, slot){
  const card = S._cards[ci], s = card && shownSet(card, ci);
  closeSlotMenu();
  if (!s) return;
  if (act === 'pick') return openSlot(ci, slot);
  if (act === 'lock') toggleLock(s, slot);
  else if (act === 'exclude') { const p = withWeapons(s).pieces[slot];
    if (p) { const was = isExcluded(p.name); setExcluded(p.name, !was);
      // the piece a search offered goes back to the set's: the next search fills the slot without it
      if (!was && withWeapons(s).tried[slot]) setTrial(s, slot, undefined); } }
  else if (act === 'empty') setTrial(s, slot, null);
  else if (act === 'reset') setTrial(s, slot, undefined);
  save(); render();
}
Object.assign(T.fr, {slotPick: 'Choisir une pièce…', slotLock: 'Verrouiller', slotUnlock: 'Déverrouiller',
  slotLockHint: 'l’optimiseur n’y touche plus', slotUnlockHint: 'l’optimiseur peut la changer', lgLock: 'verrouillé',
  lockTip: 'Verrouillé : l’optimiseur garde cette case telle quelle',
  locksLine: '{n} case(s) verrouillée(s) : {l}', locksClear: 'Tout déverrouiller'});
Object.assign(T.en, {slotPick: 'Choose a piece…', slotLock: 'Lock', slotUnlock: 'Unlock',
  slotLockHint: 'the optimizer leaves it alone', slotUnlockHint: 'the optimizer may change it', lgLock: 'locked',
  lockTip: 'Locked: the optimizer keeps this slot as it is',
  locksLine: '{n} locked slot(s): {l}', locksClear: 'Unlock all'});

/* ---- pieces left out of the searches ---- */
// A piece the character will not get (or does not want): by name, for every job and set of the character, kept in
// the browser. The optimizers neither offer it nor start from it (a locked slot keeps its piece all the same).
// A piece left out while the character did not hold it ('missing') comes back by itself the day it is in the bags:
// it dropped, the reason to leave it out is gone. One left out while held ('owned': not wanted) stays out.
const ownsPiece = name => Object.values(ownedOf() || {}).some(list => list.some(x => x.name === name));
function excludedOf(){
  const mine = (S.excluded || {})[S.char] || {}, got = Object.keys(mine).filter(n => mine[n] === 'missing' && ownsPiece(n));
  if (!got.length) return mine;
  const left = Object.assign({}, mine);
  for (const n of got) delete left[n];
  S.excluded = Object.assign({}, S.excluded, {[S.char]: left}); save();
  return left;
}
const isExcluded = name => !!excludedOf()[name];
function setExcluded(name, on){
  const mine = Object.assign({}, excludedOf());
  if (on) mine[name] = ownsPiece(name) ? 'owned' : 'missing'; else delete mine[name];
  S.excluded = Object.assign({}, S.excluded, {[S.char]: mine});
  save();
}
Object.assign(T.fr, {slotExclude: 'Exclure des recherches', slotExcludeHint: 'l’optimiseur ne la proposera plus (réautorisée d’elle-même si tu l’obtiens)',
  slotInclude: 'Ne plus exclure', slotIncludeHint: 'l’optimiseur peut de nouveau la proposer',
  exclLine: 'Exclues des recherches :', exclClear: 'Tout réautoriser', exclBack: 'Réautoriser {p}'});
Object.assign(T.en, {slotExclude: 'Exclude from searches', slotExcludeHint: 'the optimizer will not offer it again (allowed again by itself once you get it)',
  slotInclude: 'Stop excluding', slotIncludeHint: 'the optimizer may offer it again',
  exclLine: 'Excluded from searches:', exclClear: 'Allow all again', exclBack: 'Allow {p} again'});
