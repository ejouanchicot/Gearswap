// GearSwap Atelier · add_set.js: the "+ Set" window (2026-10-06). It offers the sets the job's code reads, from the
// export's catalog (shared/utils/atelier/set_catalog.lua: the common names and shared/jobs/<job>/set_catalog.lua, filled
// with the character's modes, spells, abilities and weaponskills): 1. which kind, 2. which set (one that exists opens,
// one that does not can be created; its parent table first when it has none yet), 3. what it starts from (a copy of the
// set worn in its place today, nothing, or what you wear in game). The game writes it after its parent and its base
// (set_push.lua create_new: same preview, backup, history and undo as a push). An export with no catalog (written before
// 2026-10-06) keeps the weaponskill list (push.js addWsList).
// (loaded by atelier/index.html after push.js: see the list there; the window is drawn by atelier/src/screens/dialogs/addset.ts)

Object.assign(T.fr, {
  addSearch: 'Chercher un set, un sort, une ability…', addParentFirst: 'Crée d’abord {p} : ce set va dedans.',
  addCount: '{n} set(s) · {h} existe(nt)', addNoCatalog: 'Cet export ne contient pas la liste des sets que lit le job : relance //gs c atelier en jeu (ou l’export de tous les jobs).',
  addWhereAny: 'Nouveau set {p}, écrit dans {f} :', addBuiltOn: 'Il hérite de {b} : il ne change que ce que tu y mets.',
  addPlain: 'Il part de ce que tu vois ci-dessous, sans hériter d’un autre set.', addSafetyAny: 'Une copie du fichier va dans atelier/backups/, l’historique permet d’annuler, GearSwap recharge ensuite.',
  addToday: 'Aujourd’hui à sa place : {b}', addTodayNone: 'Aujourd’hui à sa place : rien de plus',
  fromWornNone: 'Le jeu n’a pas envoyé ce que tu portes.', addWornReading: 'Lecture de ce que tu portes…',
  pushErr_catalog: 'Ce set n’est pas dans la liste de ce que lit ton job : le code ne le porterait jamais.',
  pushErr_exists: 'Ce set existe déjà dans ton fichier : ouvre-le dans la liste.',
  pushErr_parent: 'Le tableau qui doit contenir ce set n’est écrit dans aucun de tes fichiers de sets : crée-le d’abord.',
  pushErr_base: 'Le set de base n’est pas écrit comme un tableau dans le même fichier : choisis « Vide » ou « Ce que tu portes ».',
});
Object.assign(T.en, {
  addSearch: 'Search a set, a spell, an ability…', addParentFirst: 'Create {p} first: this set goes in it.',
  addCount: '{n} set(s) · {h} there already', addNoCatalog: 'This export does not hold the list of sets the job reads: run //gs c atelier in game again (or the all-jobs export).',
  addWhereAny: 'New set {p}, written in {f}:', addBuiltOn: 'It inherits {b}: it only changes what you put in it.',
  addPlain: 'It starts from what you see below, without inheriting another set.', addSafetyAny: 'A copy of the file goes to atelier/backups/, the history can undo it, GearSwap reloads afterwards.',
  addToday: 'Worn in its place today: {b}', addTodayNone: 'Worn in its place today: nothing more',
  fromWornNone: 'The game did not send what you wear.', addWornReading: 'Reading what you wear…',
  pushErr_catalog: 'This set is not in the list your job reads: the code would never wear it.',
  pushErr_exists: 'This set is in your file already: open it from the list.',
  pushErr_parent: 'The table this set goes in is written in none of your set files: create it first.',
  pushErr_base: 'The base set is not written as a table in the same file: choose "Empty" or "What you wear".',
});

let addStep = 0, addFam = null, addPath = null;
// The export's catalog (an older export has none)
const catalogEntries = () => { const d = data(); return d && Array.isArray(d.catalog) ? d.catalog : null; };
// When the job's code wears a set, in the page's language, from its catalog line (shared/jobs/<job>/set_catalog.lua
// `fr` / `when`); null when the catalog has no line for it, or none in French (the card keeps its family's line)
function catalogWhen(path){
  const e = (catalogEntries() || []).find(x => x.path === path.replace(/'/g, '"'));
  return e ? (S.lang === 'en' ? e.when : e.fr) || null : null;
}
// A catalog line of a weapon state ({MainWeapon}, {WeaponSet}...): the weapon sets, laid on idle and engaged
const WEAPON_LINE = /^\{(MainWeapon|SubWeapon|RangeWeapon|WeaponSet|SubSet|AbyWeapon|SubWeaponOverride)[^}]*\}$/;
const catFamily = e => WEAPON_LINE.test(e.group) ? 'weapons' : cardFamily(e.path, {});
// Whether a set is there now: the page's sets (a set created or deleted since the export), else the export's word
const setThere = path => !!(S._bypath && S._bypath[path]);
const isThere = e => S._bypath ? setThere(e.path) : !!e.exists;
const parentOf = path => { const sg = segs(path); sg.pop(); return sg.length ? 'sets' + sg.map(k => /^[A-Za-z_]\w*$/.test(k) ? '.' + k : '["' + k + '"]').join('') : null; };
const parentThere = e => e.parent || !parentOf(e.path) || setThere(parentOf(e.path));
// A catalog line as the page writes it: sets.precast.JA.{ja} -> precast.JA.‹ja›
const lineLabel = g => g.replace(/\{([^}]+)\}/g, (m, n) => /^[^:~]*\|/.test(n) ? '‹' + n.split('|').join(' | ') + '›' : '‹' + n.split(/[:~]/)[0] + '›');

// The window at its step: drawn by the Svelte application (atelier/src/screens/dialogs/addset.ts)
function renderAdd(){
  ATELIER_DIALOG.show({cls: '', titleHtml: '', addSet: ATELIER_DIALOG.addStepView()});
  const q = $('#addq'); if (q) q.focus();
}
// The body sent to the game: the path, #create, the base for a copy, the pieces for what you wear
async function addFrom(kind){
  const e = (catalogEntries() || []).find(x => x.path === addPath);
  if (!e) return;
  let lines = [];
  if (kind === 'worn') {
    showDialog('pushdlg', t('addTitle'), `<p class="muted">${t('addWornReading')}</p>`, '');
    let ch = null;
    try { ch = await liveFetch(S.char, '/measure', {timeout: 4000}); } catch (err) {}
    const worn = (ch && ch.worn) || (measuredChar() || {}).worn;
    if (!worn) return showDialog('pushdlg', t('addTitle'), `<p class="kwarn">${esc(t('fromWornNone'))}</p>`, '');
    const owned = ownedOf() || {};
    lines = SLOTS.filter(slot => worn[slot] && worn[slot].name).map(slot => pushLine(pushEntry(slot, worn[slot], owned)));
  }
  const base = kind === 'copy' && e.base && setThere(e.base) ? e.base : null;
  const body = [e.path, '#create'].concat(base ? ['#base\t' + base] : [], lines).join('\n') + '\n';
  createPreview(e.path, body, base);
}
// The game shows where the set goes, then writes it (createGo, push.js)
async function createPreview(path, body, base){
  S._create = {path, body};
  showDialog('pushdlg', t('addTitle'), `<p class="muted">${t('pushReading')}</p>`, '');
  let r;
  try { r = await liveFetch(S.char, '/push?mode=preview' + jobQuery(), {method: 'POST', body, timeout: 8000}); } catch (err) { r = {error: 'live'}; }
  if (!S._create || S._create.path !== path) return;
  if (r.error) return showDialog('pushdlg', t('addTitle'), `<p class="kwarn">${esc(t('pushErr_' + r.error))}</p>`, '');
  S._create.hash = r.hash;
  ATELIER_DIALOG.show({cls: 'pushdlg', titleHtml: t('addTitle'), push: ATELIER_DIALOG.createView(path, r, base), buttonsHtml: `<button class="btn" data-creatego>${t('addGo')}</button>`});
}
// The window's clicks (events.js)
function addClick(d){
  if (d.addfam) { addFam = d.addfam; addStep = 1; renderAdd(); return true; }
  if (d.addpick) { addPath = d.addpick; addStep = 2; renderAdd(); return true; }
  if (d.addfrom) { addFrom(d.addfrom); return true; }
  if ('back' in d && $('#overlay .steps')) { addStep = Math.max(0, addStep - 1); renderAdd(); return true; }
  return false;
}
// The search box: rows hidden, the groups that still hold one opened
function addFilter(q){
  q = q.trim().toLowerCase();
  for (const r of document.querySelectorAll('.addrow')) r.hidden = !!q && !r.dataset.q.includes(q);
  for (const g of document.querySelectorAll('.addgroup')) { const any = [...g.querySelectorAll('.addrow')].some(r => !r.hidden);
    g.hidden = !any; if (q) g.open = any; }
}
