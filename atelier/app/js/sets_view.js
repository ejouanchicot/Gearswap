// GearSwap Atelier · sets_view.js: rendering: the side, the set list, a set's card, the Macro / Functions tabs, the job list
// (loaded by atelier/index.html, in the order of the list there)
/* ---- render ---- */
// The top bar is the Svelte application's (atelier/src/screens/topbar, told at the end of render). Here only what the
// whole document follows: its language and its theme
function renderSide(){
  document.documentElement.lang = S.lang;
  document.documentElement.setAttribute('data-theme', themeNow());
}
function counts(c){ const d = recordOf(S.char, c); return d ? {sets:d.sets.length, keys:keysShown(d).length} : null; }
// The home page (the played jobs, or how to fill the page) is the Svelte application's (atelier/src/screens/home)
function renderHome(){ return ''; }
// Whether you hold a piece the set shows (any bag, slips and the Mog House included): 'missing' when you
// do not, 'short' when yours is below what the page counts (a lower rank than the one counted, a cape
// counted with its materials at their maximum), '' when yours is it or the page knows no bags (no export yet)
function holdState(slot, p){
  if (!p || isEmpty(p) || ['main', 'sub', 'range'].includes(slot)) return '';
  const owned = ownedOf() || {};
  if (!Object.keys(owned).length) return '';
  const mine = (owned[slot] || []).filter(x => x.name === p.name);
  if (!mine.length) return 'missing';
  if (mine.every(atPorter)) return 'porter';
  if (p.capeMax) return 'short';
  if (p.rank != null && !mine.some(x => { const r = ownRank({name: x.name, augs: x.augs}).rank; return r == null || r >= p.rank; })) return 'short';
  return '';
}
// The legend of the gear grid: every look a cell can take, each with what it means in its tooltip. The three about
// what you hold (not yours, to upgrade, at the Porter Moogle) are lit when the set has such a piece
Object.assign(T.fr, {lgEmpty: 'vide', lgAug: 'augmentée', lgRank: 'rang',
  lgT_own: 'Une pièce que ce set définit lui-même.', lgT_inh: 'Une pièce que ce set ne définit pas : elle vient du set sur lequel il est construit.',
  lgT_weap: 'L’arme choisie par ton mode d’arme, pas par le set.', lgT_try: 'Une pièce que tu essaies dans la page : rien n’est encore écrit dans tes fichiers. La flèche ↺ dans le coin la retire.',
  lgT_empty: 'Rien dans cet emplacement.', lgT_lock: 'Emplacement verrouillé : l’optimiseur n’y touche pas. Ctrl+clic sur une case pour la verrouiller ou la libérer.',
  lgT_aug: 'La pièce porte des augments.', lgT_rank: 'Le rang de la pièce.',
  lgT_missing: 'Tu ne possèdes pas cette pièce.', lgT_short: 'Tu l’as, mais pas encore à ce rang ou avec ces augments.',
  lgT_porter: 'Elle est rangée chez le Porter Moogle : à retirer avant de pouvoir la porter.'});
Object.assign(T.en, {lgEmpty: 'empty', lgAug: 'augmented', lgRank: 'rank',
  lgT_own: 'A piece this set defines itself.', lgT_inh: 'A piece this set does not define: it comes from the set it is built on.',
  lgT_weap: 'The weapon chosen by your weapon mode, not by the set.', lgT_try: 'A piece you are trying in the page: nothing is written to your files yet. The ↺ arrow in the corner takes it off.',
  lgT_empty: 'Nothing in this slot.', lgT_lock: 'Locked slot: the optimizer leaves it alone. Ctrl+click a cell to lock or free it.',
  lgT_aug: 'The piece carries augments.', lgT_rank: 'The piece’s rank.',
  lgT_missing: 'You do not own this piece.', lgT_short: 'You have it, but not yet at this rank or with these augments.',
  lgT_porter: 'It is stored with the Porter Moogle: to take out before you can wear it.'});
// The variants of a card, laid out like the weapon rows: a label, then its buttons. A variant with
// its own variants (Savage Blade · TPBonus) keeps them stuck to it; weaponskills go one row per
// combat skill (export ws_skill), the others in one row
// A card's variants by what leads them: {head, main (its own index), subs [{label, i}]}
function variantGroups(card){
  const groups = new Map(), skills = card.fam === 'ws' ? wsSkills() : {};
  card.variants.forEach((x, i) => { const parts = x.label.split(' · ');
    // the weaponskill leads its group wherever it sits in the path (sets.precast.WS.SCH["Knights of Round"])
    // a weaponskill variant naming no weaponskill (sets.precast.WS.TPBonus) is a variant of the base set
    const found = parts.findIndex(p => skills[p]), ws = card.fam === 'ws' && found < 0 && parts[0] !== 'Base';
    const at = Math.max(0, found), head = ws ? 'Base' : parts[at], tail = ws ? parts : parts.filter((_, k) => k !== at);
    if (!groups.has(head)) groups.set(head, {head, main: null, subs: []});
    const g = groups.get(head); if (tail.length) g.subs.push({label: tail.join(' · '), i}); else g.main = i; });
  return {groups, skills};
}
// What brings a spell to a family or mode set under a skill (MidcastManager, shared/utils/midcast/
// midcast_manager.lua): sets.midcast['Enfeebling Magic'].duration is the family "duration" of the
// spell database (Sleep, Bind...), .Duration the EnfeebleMode value, used by spells of no family.
// The families come from the game (window.ATELIER_FAMILIES, shared/utils/atelier/atelier_families.lua)
// Variants named by a condition rather than a family: the target (target_func Composure / Self /
// Other), Magic Burst (BLM, SCH, NIN mode_value), RDM's Saboteur overlay
const STATIC_NOTES = {Composure: 'famComposure', Self: 'famSelf', Other: 'famOther', MagicBurst: 'famMB', Saboteur: 'famSabo'};
function familyNote(s){
  const all = window.ATELIER_FAMILIES || {}, parts = segs(s.path), last = parts[parts.length - 1];
  if (parts.length > 2 && STATIC_NOTES[last]) return t(STATIC_NOTES[last]);
  const modeOf = v => data().modes.find(m => m.values.includes(v) && /mode/i.test(m.name));
  // the deepest parent whose next step is one of its families, or a mode value
  // (sets.midcast.IntEnfeebles.duration, sets.midcast['Blue Magic'].Magical, sets.midcast.Minne)
  for (let i = parts.length - 2; i >= 0; i--) {
    const fams = all[parts[i]], key = parts[i + 1], next = parts[i + 2];
    if (!fams) continue;
    if (fams[key]) { const sub = next && modeOf(next);
      return t('famSpells', {f: esc(key), s: fams[key].map(esc).join(', ')}) + (sub ? ' ' + t('famMode', {m: esc(sub.desc || sub.name), v: esc(next)}) : ''); }
    const mode = modeOf(key);
    if (mode && parts[i] !== 'midcast') return t('modeNoFamily', {m: esc(mode.desc || mode.name), v: esc(key)});
  }
  // the skill's own set: the last step, for a spell no other set catches
  if (all[last] && last !== 'midcast') return t('famBase', {k: esc(last)});
  return '';
}
// The note's room is kept on every variant of a card that has one: switching variants moves nothing
// The title of every set, one shape whatever its content so nothing under it moves from a set to the next: the name
// on a line, what it is on the next (when it is worn, or a weaponskill's facts), its path on the third; each line
// keeps its height and cuts what is too long (the whole text in its tooltip); the actions at the right
function setTitleBox(kicker, name, what, whatTip, path, acts){
  return `<div class="settitle"><div class="stmain"><div class="stname">${kicker ? `<span class="kicker">${esc(kicker)}</span>` : ''}<h2>${name}</h2></div>` +
    `<div class="stwhat" ${whatTip ? `title="${esc(whatTip)}"` : ''}>${what}</div><code class="path wspath" title="${esc(t('ttPath'))}">${esc(path)}</code></div>${acts}</div>`;
}
// The title of a weaponskill set: its weapon, its name and version, what it uses (type, attributes, hits,
// fTP by TP, critical hits, fTP on every hit: the weaponskill database, exported as ws_info), the set's path
function wsTitleHTML(s, acts = ''){
  const ws = wsOfSet(s);
  // the common set is one of the job's base sets: never deleted from the page (set_push.lua PROTECTED)
  if (!ws) return setTitleBox(t('wsKick'), esc(t('wsCommon')), '', '', s.path, acts);
  const info = wsInfoOf(ws), version = segs(s.path).slice(segs(s.path).lastIndexOf(ws) + 1).join(' · ');
  const n = v => (+v).toLocaleString(S.lang === 'fr' ? 'fr-FR' : 'en-US', {minimumFractionDigits: 1, maximumFractionDigits: 3});
  const mods = typeof info.mods === 'string' ? [info.mods] : Object.entries(info.mods || {}).map(([k, v]) => `${v} % ${k}`);
  const ftp = info.ftp && info.ftp['1000'] != null ? 'fTP ' + ['1000', '2000', '3000'].map(k => info.ftp[k] != null ? n(info.ftp[k]) : '—').join(' / ') : '';
  const facts = [info.type ? t('wsType_' + info.type) : '', mods.join(' + '), info.hits ? t(info.hits > 1 ? 'wsHitN' : 'wsHit1', {n: info.hits}) : '', ftp,
    info.crit ? t('wsCritTag') : '', info.replicating ? t('wsReplTag') : '', info.element ? info.element : ''].filter(Boolean);
  return setTitleBox((wsSkills()[ws] || '') + ' · ' + t('wsKickOne'), esc(ws) + (version ? ` <span class="wsver">· ${esc(version)}</span>` : ''),
    facts.length ? `<span class="wsfacts">${facts.map(f => `<span>${esc(f)}</span>`).join('')}</span>` : '', facts.join(' · '), s.path, acts);
}
const famOpen = (fam, q) => !!q || !!S.famOpen[S.job + '|' + fam];
// A version of a set for a party: the label of a variant against its set's ("Laphria · Group" against "Laphria",
// "Trust" against the family's own set, "Base"); null for anything else
const TIER_LABELS = ['Group', 'Solo', 'Trust'];
function tierLabel(label, head){
  const rest = head === 'Base' ? label : label.startsWith(head + ' · ') ? label.slice(head.length + 3) : '';
  return TIER_LABELS.includes(rest) ? rest : null;
}
Object.assign(T.fr, {rowTry: 'Des pièces sont à l’essai dans ce set', rowVoid: 'vide', listPaths: 'Chemins', openShort: 'Déplier', closeShort: 'Replier', listPathsTip: 'Montre sous chaque set son nom dans ton fichier (sets.engaged.Laphria…)', searchShort: 'Chercher…'});
Object.assign(T.en, {rowTry: 'Pieces are on trial in this set', rowVoid: 'empty', listPaths: 'Paths', openShort: 'Open', closeShort: 'Close', listPathsTip: 'Shows under each set its name in your file (sets.engaged.Laphria…)', searchShort: 'Search…'});
// The variant of a card shown in its detail
function shownSet(card, ci){ return card.variants[Math.min(S.variant[S.job + '|' + ci] ?? 0, card.variants.length - 1)].set; }

// The played jobs by role, the shown one marked: a click changes job and keeps the tab
// Every job's level and master level, from the game (char.jobs of the latest in-game export of the
// character: packet 0x01B), or null before any
function jobLevels(c = S.char){
  let best = null;
  for (const subs of Object.values(DATA[c] || {})) for (const d of Object.values(subs))
    if (d && d.char && d.char.jobs && (!best || (d.char.at || d.at || '') > best.at)) best = {at: d.char.at || d.at || '', jobs: d.char.jobs};
  return best && best.jobs;
}
const masterOf = c => { const L = jobLevels(); return L && L[c] ? L[c].ml || 0 : null; };
// The played jobs split: the ones with master levels first (highest first), then the others, by role
function jobGroups(){
  const played = JOBS.filter(j => plays(j[0])), L = jobLevels();
  if (!L) return [{label: null, jobs: played}];
  const ml = j => (L[j[0]] || {}).ml || 0, order = j => ROLES.indexOf(j[2]);
  const mastered = played.filter(j => ml(j) > 0).sort((a, b) => ml(b) - ml(a) || order(a) - order(b));
  const others = played.filter(j => ml(j) === 0).sort((a, b) => order(a) - order(b));
  return [{label: t('jobsMaster'), jobs: mastered, master: true}, {label: t('jobsOther'), jobs: others}].filter(g => g.jobs.length);
}
const jobBadge = c => { const L = jobLevels(), j = L && L[c];
  return j ? (j.ml ? `<span class="mlbadge" title="${t('mlTip', {n: j.ml})}">ML${j.ml}</span>` : `<span class="lvbadge">${j.level}</span>`) : ''; };
// Every view of a job is the Svelte application's (atelier/src/screens: config, perso, combat, sets, sim, and
// home/NoExport.svelte for a job with no export); Simulate asks the game what it needs before it is drawn
function renderJob(){
  if (!data()) return '';
  // the Merits are in My character; the keys, modes, switches and macro book are the parts of the job's settings
  // (a page kept on one of those four names, or sent there by a link, opens that part)
  if (ui2() && S.section === 'merits') S.section = 'perso';
  if (!ui2() && ['combat', 'perso'].includes(S.section)) S.section = 'sets';
  if (S.section === 'sim') simPrepare();
  return '';
}
// Re-render, keeping the focus of the search box and the scroll of each block
// while the view stays the same (the set detail goes back to its top for another set)
// (.globalcol: the right column, its compartments folded and unfolded in place)
// What tells a folded block from the others of the page: its classes and its title without the figures in it
// (without the classes an animation leaves on it for a moment: motion.js)
const foldKey = el => [...el.classList].filter(c => !MOTION_MARKS.includes(c)).join(' ') + '|' + ((el.querySelector('summary') || {}).textContent || '').replace(/[\d.,%−+-]+/g, '').trim().slice(0, 60);
const MOTION_MARKS = ['opens', 'unfolds', 'flash', 'rolls', 'fills'];
const SCROLLERS = ['.pane', '.setlist .scroll', '.detail', '.globalcol'];
// A click redraws the page whole: no block may jump back to its top for it. Beside the four above (which have their
// own rules), every block that was scrolled is found again by its place in the page (the tag and first class of each
// of its ancestors, and its rank among its like) and put back where it was
const scrollKind = e => e.tagName + '.' + (e.classList[0] || '');
function scrollKeep(){
  const own = SCROLLERS.join(','), out = [];
  for (const el of document.querySelectorAll('#view *')) {
    if (!el.scrollTop || el.matches(own)) continue;
    const path = [];
    for (let e = el; e && e.id !== 'view'; e = e.parentElement) {
      let rank = 0;
      for (let s = e.previousElementSibling; s; s = s.previousElementSibling) if (scrollKind(s) === scrollKind(e)) rank++;
      path.unshift([scrollKind(e), rank]);
    }
    out.push({path, top: el.scrollTop});
  }
  return out;
}
function scrollPut(kept){
  for (const {path, top} of kept) {
    let el = $('#view');
    for (const [kind, rank] of path) { el = el && [...el.children].filter(c => scrollKind(c) === kind)[rank]; }
    if (el) el.scrollTop = top;
  }
}
function render(){
  // a row of the list is being dragged: the page waits (a redraw would take the row from under the pointer)
  if (LIST_DRAG) return;
  // one of the four old tab names (a page kept on it, a link): the job's settings, on that part; settled before the
  // view is named, so that the scroll kept for this view is found again
  if (JOB_CFG.includes(S.section)) { S.jobTab = S.section; S.section = 'jobcfg'; }
  const view = [S.char, S.job, S.section, S.section === 'jobcfg' ? S.jobTab : ''].join('|'), set = view + '|' + S.sel[S.job];
  const tops = SCROLLERS.map(q => { const el = $(q); return el ? el.scrollTop : 0; });
  const kept = S._view === view ? scrollKeep() : [];
  const a = document.activeElement, id = a && a.id, pos = a && a.selectionStart;
  // a folded block the player opened stays open through a redraw of the same tab: a click inside it (a job, a
  // tab, a mode) draws the page again, and the block closed under the pointer (2026-10-10)
  const opened = S._view === view ? new Set([...document.querySelectorAll('#view details[open]')].map(foldKey)) : new Set();
  renderSide(); $('#legacyview').innerHTML = S._pkg && typeof renderPackages === 'function' ? renderPackages() : S._cfg ? renderConfig() : S.job ? renderJob() : renderHome(); save();
  // the Svelte screens (atelier/src/: the top bar, the sections, the screens moved) read the state again now, before
  // the focus, the folded blocks and the scroll are put back: theirs too (they are in #view beside #legacyview)
  if (window.__atelier && window.__atelier.redraw) window.__atelier.redraw();
  for (const el of document.querySelectorAll('#view details:not([open])')) if (opened.has(foldKey(el))) el.open = true;
  // another view starts at the top: a block the Svelte screens keep between redraws (the list of sets) would
  // otherwise stay where it was scrolled for the job or tab before
  SCROLLERS.forEach((q, i) => { const el = $(q);
    if (el) el.scrollTop = S._view === view && (q !== '.detail' || S._set === set) ? tops[i] : 0; });
  scrollPut(kept);
  scrollBack(view, set);
  // the set shown, newly chosen: its row brought into the list's sight (nothing moves when it is already there)
  if (S._revealNow) { S._revealNow = false; const cur = $('.setlist .setrow[aria-current="true"]'), box = cur && cur.closest('.scroll');
    if (cur) { cur.scrollIntoView({block: 'nearest', inline: 'nearest'}); if (box) box.scrollLeft = 0; } }
  S._view = view; S._set = set;
  if (id) { const el = document.getElementById(id); if (el) { el.focus(); if (pos != null && el.setSelectionRange) el.setSelectionRange(pos, pos); } }
  shapeKeep();
  motionAfter();
  guideAfter();
}
// A block whose size follows its content (the set's own figures: an attack block, a tank's defense block, both) is
// given the tallest size it ever had for this character and job at this width: after the tallest set was seen once,
// nothing under it moves again, in this visit and the next ones (S.shapes, kept in the browser)
const SHAPES = {own: '.globalcol .ui2own', top: '.setsx.ui2 .detail > header:not(.ophead) > .settop'};
function shapeKeep(){
  S.shapes = S.shapes || {};
  let learnt = false;
  for (const [key, q] of Object.entries(SHAPES)) {
    const el = $(q);
    if (!el || !el.clientWidth) continue;
    const k = [S.char, S.job, key, Math.round(el.clientWidth / 40)].join('|');
    el.style.minHeight = '';
    const h = Math.ceil(el.getBoundingClientRect().height);
    if (h > (S.shapes[k] || 0)) { S.shapes[k] = h; learnt = true; }
    el.style.minHeight = S.shapes[k] + 'px';
  }
  if (learnt) save();
}

// After a reload of the page (F5): back where it was, whatever the tab: Settings open if it was, the folded blocks
// that were open, every block scrolled (the four above and any other, found again by its place) and the page itself.
// Kept in this browser only: the page works without it. Put back at the first redraw that shows the same view, and
// again at the redraws of the next seconds (the game's data comes after the files' and makes the page longer),
// until the player scrolls, clicks or types
const SCROLL_STORE = 'atelier_scroll', SCROLL_BACK_MS = 4000;
let SCROLL_KEPT = null;
try { SCROLL_KEPT = JSON.parse(localStorage.getItem(SCROLL_STORE) || 'null'); } catch (e) { SCROLL_KEPT = null; }
if (SCROLL_KEPT && SCROLL_KEPT.cfg) S._cfg = true;
function scrollBack(view, set){
  const kept = SCROLL_KEPT;
  if (!kept || S._scrollBack === true) return;
  // the files are still being read (no tab drawn yet): wait for the redraw that follows
  if (!$(kept.cfg ? '.cfg' : '.pane')) return;
  if (kept.view !== view || !!kept.cfg !== !!S._cfg) { S._scrollBack = true; return; }
  if (!S._scrollBack) S._scrollBack = Date.now();
  else if (Date.now() - S._scrollBack > SCROLL_BACK_MS) { S._scrollBack = true; return; }
  const open = new Set(kept.open || []);
  for (const el of document.querySelectorAll('#view details:not([open])')) if (open.has(foldKey(el))) el.open = true;
  SCROLLERS.forEach((q, i) => { const el = $(q); if (el && (kept.tops || [])[i] && (q !== '.detail' || kept.set === set)) el.scrollTop = kept.tops[i]; });
  scrollPut(kept.kept || []);
  if (kept.win) scrollTo({top: kept.win});
}
// the player moved: what was kept no longer says where the page should be
for (const ev of ['wheel', 'pointerdown', 'keydown', 'touchstart']) addEventListener(ev, () => { S._scrollBack = true; }, {passive: true, capture: true});
function scrollStore(){
  try { localStorage.setItem(SCROLL_STORE, JSON.stringify({view: S._view, set: S._set, cfg: !!S._cfg, tops: SCROLLERS.map(q => ($(q) || {}).scrollTop || 0),
    kept: scrollKeep(), win: window.scrollY || 0, open: [...document.querySelectorAll('#view details[open]')].map(foldKey)})); } catch (e) {}
}
window.addEventListener('beforeunload', scrollStore);
window.addEventListener('pagehide', scrollStore);

/* ---- roles, job emblems, the other character, macro book and lockstyle shown ---- */
// Roles and colours of AioHUD (job_role_color, src/model/party_state.cpp): icon tint, border, text
const ROLE_COLOR = {tank:'var(--r-tank)',healer:'var(--r-healer)',support:'var(--r-support)',dd:'var(--r-dd)'};
const ROLES = ['tank','healer','support','dd'];
const emblem = c => `<span class="em" style="--icon:url(${ICONS[c]})"></span>`;
// Another character with exported jobs, offered when this one has none for the job
const otherChar = () => Object.keys(CHARS).find(c => c !== S.char);
const bookOf = d => { const b = bookFor(d); return b && b.book ? b.book + ' · ' + b.page : '—'; };
const styleOf = d => { const l = d.lockstyle || {}; return esc((l.by_subjob || {})[d.sub] ?? l.default ?? d.lockstyle_fallback ?? '—'); };



/* ---- the set list: cards, their names, the search ---- */
// How many path segments name the card; the rest are its variants
function topOf(path, fam){
  const s = segs(path);
  let n = 2;
  if (fam==='ja') n = 3;
  if (fam==='idle' || fam==='engaged') n = ['me', 'luopan'].includes(s[0]) ? 2 : 1;
  if (fam==='special') n = s[0]==='buff' ? 2 : 1;
  if (fam==='weapons' || fam==='other' || fam==='xp') n = s.length;
  // a Cure set's card: down to its Cure name (precast.FC.CureSelf, midcast.CureSelf), its versions under it
  if (fam==='cure') n = s.findIndex(x => /^Cur/.test(x)) + 1 || s.length;
  return s.slice(0, Math.min(n, s.length));
}
function buildCards(d){
  // a set shared under several names (sets.idle.MDT = sets.engaged.MDT) is found by each of them
  const bypath = {}; for (const s of d.sets) { bypath[s.path] = s; for (const a of s.aliases || []) bypath[a] = bypath[a] || s; }
  const cards = [], index = {};
  for (const s of d.sets) {
    const fam = cardFamily(s.path, s.pieces);
    const top = topOf(s.path, fam); const key = fam + '|' + top.join('/');
    if (!index[key]) { index[key] = {fam, name: top[top.length-1], top, variants:[]}; cards.push(index[key]); }
    const rest = segs(s.path).slice(top.length).join(' · ');
    index[key].variants.push({label: rest || 'Base', set: s});
  }
  for (const c of cards) c.variants.sort((a,b) => (a.label==='Base'?-1:b.label==='Base'?1:a.label.localeCompare(b.label)));
  const order = ['idle','engaged','fc','ws','ja','cure','midcast','enmity','pet','special','xp','weapons','other'];
  const lead = c => c.top.length === 1 && c.top[0] === c.fam ? 0 : 1;
  cards.sort((a,b) => order.indexOf(a.fam)-order.indexOf(b.fam) || lead(a)-lead(b) || a.name.localeCompare(b.name));
  return {cards, bypath};
}
function niceName(card){
  const n = card.name;
  // the game's and GearSwap's own words in every language (a category or a set is not translated: the player reads
  // "engaged" in the file and in every guide); only what the file abbreviates is written out
  const map = {idle: 'Idle', engaged: 'Engaged', FC: 'Fast Cast', WS: 'Weaponskills', TreasureHunter: 'Treasure Hunter'};
  return map[n] || n;
}
// A card matches the search when one of its variants has the text in its path, in a name it is shared under
// (sets.midcast.Flash = sets.FullEnmity) or in a piece name
function cardMatch(card, q){
  return !q || card.variants.some(v => v.set.path.toLowerCase().includes(q) || (v.set.aliases || []).some(a => a.toLowerCase().includes(q))
    || Object.values(v.set.pieces).some(p => p.name.toLowerCase().includes(q)));
}
// The names a set is shared under, each in the family its own name belongs to (sets.midcast.Flash = sets.FullEnmity
// is a spell's set: listed with the spells), a link to the set it is: [{fam, label, path, of, i, k}]
function aliasRows(cards, q){
  const out = [];
  cards.forEach((c, i) => c.variants.forEach((v, k) => { for (const a of v.set.aliases || []) {
    if (q && !a.toLowerCase().includes(q)) continue;
    out.push({fam: cardFamily(a, v.set.pieces), label: segs(a).pop(), path: a, of: v.set.path, i, k}); } }));
  return out.sort((a, b) => a.label.localeCompare(b.label));
}


// The SIRD of the merits (res/merit_points.lua: "Spell Interruption Rate" 2 % a level), as the Merits tab has them
function sirdMeritsOf(c){
  const m = (meritList() || []).find(x => x.key === 'spell_interruption_rate');
  if (m) return 2 * meritLevel(m);
  return 2 * Object.entries((c && c.merits) || {}).reduce((n, [k, lv]) => k.toLowerCase().replace(/_/g, ' ') === 'spell interruption rate' ? n + lv : n, 0);
}
/* ---- the column of figures beside a set ---- */
function globalsHTML(s, only){
  S._curSet = s;
  const r = charStats(s);
  if (!r) return `<div class="globals">${box('g-you', t('youTitle'), `<p class="muted">${t('noChar')}</p>`)}</div>`;
  const {c, out, set, vsSet} = r;
  const row = (label, o) => { const d = o.set - o.now;
    return statLi(label, o.set, d ? `<em class="delta ${d > 0 ? 'up' : 'down'}">${d > 0 ? '+' : '−'}${Math.abs(d)}</em>` : ''); };
  const v = k => (set[k] || {}).v || 0;
  const pct = (label, sum, cap) => cappedLi(label, sum, cap, '');
  const main = [['HP', out.hp], ['MP', out.mp], [t('defLabel'), out.def], [t('atkLabel'), out.atk], [t('accLabel'), out.acc], [t('evaLabel'), out.eva]]
    .filter(([, o]) => o).map(([l, o]) => row(l, o)).join('');
  const attrs = ATTRS.map(a => row(a.toUpperCase(), out[a])).join('');
  // merits the game counts per level (res/merit_points.lua: "Spell Interruption Rate" 2 % a level)
  const sirdMerits = sirdMeritsOf(c);
  const sird = v('sird') + sirdMerits;
  const gear = damageTakenLines(v) + pct('Haste', v('haste'), 25) + pct('Fast Cast', v('fc'), 80) +
    (sird ? statLi('SIRD', sird + ' %', sirdMerits ? `<em class="delta">${t('withMerits')}</em>` : '', '', `${t('gearOnly')} ${v('sird')} % + ${t('merits')} ${sirdMerits} %`) : '');
  const levels = [c.master_level ? `ML ${c.master_level}` : '', c.jp_spent ? `${c.jp_spent} JP` : ''].filter(Boolean).join(' · ');
  const edited = Object.keys(S.meritEdits[meritKey()] || {}).length;
  const you = fbox('you', 'g-you', t('youTitle') + (edited ? ` <span class="edited">· ${t('meritsEdited', {n: edited})}</span>` : ''),
    `${vsSet ? `<p class="vsset">${t('vsSet')}</p>` : ''}<ul class="statlist big">${main}</ul>`);
  // the new layout's "every stat" fold ('stats') and My character tab ('cards': open, without the note): the
  // character's figures alone (layout2.js)
  if (only === 'cards') return box('g-you', t('youTitle'), `<ul class="statlist big">${main}</ul>`) +
    box('g-attr', t('attrTitle'), `<ul class="statlist">${attrs}</ul>`) + box('g-caps', t('gearKey'), `<ul class="statlist">${gear}</ul>`);
  if (only === 'stats') return `<div class="globals">${you}${fbox('attr', 'g-attr', t('attrTitle'), `<ul class="statlist">${attrs}</ul>`)}` +
    `${fbox('caps', 'g-caps', t('gearKey'), `<ul class="statlist">${gear}</ul>`)}<p class="note-m">${levels ? esc(levels) + ' · ' : ''}${t('measured', {at: esc(c.at), s: esc(c.sub || '—')})}</p></div>`;
  // (only the two above are drawn: the new layout's figures and My character's cards)
  return '';
}


