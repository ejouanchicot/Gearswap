// GearSwap Atelier · add_set.js: the "+ Set" window (2026-10-06). It offers the sets the job's code reads, from the
// export's catalog (shared/utils/atelier/set_catalog.lua: the common names and shared/jobs/<job>/set_catalog.lua, filled
// with the character's modes, spells, abilities and weaponskills): 1. which kind, 2. which set (one that exists opens,
// one that does not can be created; its parent table first when it has none yet), 3. what it starts from (a copy of the
// set worn in its place today, nothing, or what you wear in game). The game writes it after its parent and its base
// (set_push.lua create_new: same preview, backup, history and undo as a push). An export with no catalog (written before
// 2026-10-06) keeps the weaponskill list (push.js addWsList).
// (loaded by atelier/index.html after push.js: see the list there)

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

function renderAdd(){
  const cat = catalogEntries(), cards = S._cards || buildCards(data()).cards;
  const steps = [t('step1'), t('step2'), t('step3')].map((s, i) => `<span class="${i === addStep ? 'on' : ''}">${i + 1}. ${s}</span>`).join('');
  let body;
  if (addStep === 0) {
    const fams = cat ? [...new Set(cat.map(catFamily))] : [...new Set(cards.map(c => c.fam))];
    const order = ['idle', 'engaged', 'fc', 'ws', 'ja', 'cure', 'midcast', 'enmity', 'pet', 'special', 'xp', 'weapons', 'other'];
    fams.sort((a, b) => order.indexOf(a) - order.indexOf(b));
    body = (cat ? '' : `<p class="kwarn small">${esc(t('addNoCatalog'))}</p>`) +
      fams.map(f => `<button class="opt" data-addfam="${f}"><span>${t('fam.' + f)}<small>${t('famWhen.' + f)}</small></span><span>›</span></button>`).join('');
  } else if (addStep === 1 && cat) body = addCatalogList(cat);
  else if (addStep === 1 && addFam === 'ws') body = addWsList(cards);
  else if (addStep === 1) body = cards.filter(c => c.fam === addFam).flatMap(c => c.variants.map(v => v.set.path)).map(p =>
      `<button class="opt" data-addopen="${esc(p)}"><span style="font-family:var(--mono);font-size:13px">${esc(p)}</span><span class="state">${t('exists')} ›</span></button>`).join('');
  else body = addStartList();
  $('#overlay').innerHTML = `<div class="scrim" data-close></div><div class="dialog" role="dialog" aria-label="${t('addTitle')}"><header><h3>${t('addTitle')}</h3><div class="steps">${steps}</div></header>
    <div class="body">${body}</div><footer><button class="btn ghost" data-back ${addStep === 0 ? 'disabled' : ''}>${t('back')}</button><button class="btn ghost" data-close>${t('cancel')}</button></footer></div>`;
  $('#overlay').hidden = false;
  const q = $('#addq'); if (q) q.focus();
}
// Step 2: the kind's sets, one folding group a catalog line (the ones with a set there first), in each the sets to
// create first; a search box over all of them
function addCatalogList(cat){
  const live = liveWrite(), rows = cat.filter(e => catFamily(e) === addFam);
  const groups = {};
  for (const e of rows) (groups[e.group] = groups[e.group] || []).push(e);
  const have = list => list.filter(isThere).length;
  const order = Object.keys(groups).sort((a, b) => (have(groups[b]) > 0) - (have(groups[a]) > 0) || groups[a].length - groups[b].length);
  const row = e => {
    const there = isThere(e), q = esc((shortPath(e.path) + ' ' + (e.when || '')).toLowerCase());
    if (there) return `<button class="opt addrow" data-q="${q}" data-addopen="${esc(e.path)}"><span style="font-family:var(--mono);font-size:13px">${esc(shortPath(e.path))}</span><span class="state">${t('exists')} ›</span></button>`;
    const parent = parentThere(e), why = !live ? t('pushNeedsGame') : !parent ? t('addParentFirst', {p: shortPath(parentOf(e.path))}) : '';
    return `<button class="opt addrow" data-q="${q}" data-addpick="${esc(e.path)}" ${why ? `disabled title="${esc(why)}"` : ''}>` +
      `<span style="font-family:var(--mono);font-size:13px">${esc(shortPath(e.path))}</span><span class="state new">${t('addNew')}</span></button>`;
  };
  return `<input id="addq" class="gpq" type="search" placeholder="${esc(t('addSearch'))}" autocomplete="off" spellcheck="false">` +
    order.map(g => { const list = groups[g], h = have(list), one = list.length === 1;
      const head = `<summary><b style="font-family:var(--mono)">${esc(lineLabel(g))}</b><span class="muted small">${esc(t('addCount', {n: list.length, h}))}</span>` +
        `${list[0].when ? `<small class="muted">${esc(list[0].when)}</small>` : ''}</summary>`;
      const sorted = list.filter(e => !isThere(e)).concat(list.filter(isThere));
      return `<details class="wsgroup addgroup" ${one || (S._addOpen || {})[g] ? 'open' : ''} data-addgroup="${esc(g)}">${head}${sorted.map(row).join('')}</details>`; }).join('');
}
// Step 3: what the new set starts from
function addStartList(){
  const e = (catalogEntries() || []).find(x => x.path === addPath);
  if (!e) return '';
  const base = e.base && setThere(e.base) ? e.base : null;
  const opts = [];
  if (base) opts.push(['copy', t('fromCopy', {b: shortPath(base)}), t('fromCopyD')]);
  opts.push(['empty', t('fromEmpty'), t('fromEmptyD')]);
  opts.push(['worn', t('fromWorn'), t('fromWornD')]);
  return `<p><code>${esc(shortPath(e.path))}</code></p>` + (e.when ? `<p class="muted small">${esc(e.when)}</p>` : '') +
    `<p class="muted small">${esc(base ? t('addToday', {b: shortPath(base)}) : t('addTodayNone'))}</p>` +
    opts.map(([k, a, b]) => `<button class="opt" data-addfrom="${k}"><span>${esc(a)}<small>${esc(b)}</small></span><span>›</span></button>`).join('');
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
  showDialog('pushdlg', t('addTitle'), `<p>${t('addWhereAny', {p: `<code>${esc(shortPath(path))}</code>`, f: `<code>${esc(r.file)}</code>`})}</p>` +
    diffHTML(r.before, r.after) + `<p class="muted small">${esc(base ? t('addBuiltOn', {b: shortPath(base)}) : t('addPlain'))} ${esc(t('addSafetyAny'))}</p>`,
    `<button class="btn" data-creatego>${t('addGo')}</button>`);
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
