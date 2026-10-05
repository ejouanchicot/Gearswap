// GearSwap Atelier · core.js: state, saved settings, helpers, characters / jobs / subjobs, the exports, item icons
// (cut from atelier.html, loaded by it in order: see the list there)
let DATA = {};
// Moves on whenever an export is read (the start, the live link): what is worked out from the exports is kept until then
let DATA_GEN = 0;
function loadScripts(files, done){ let i = 0; const next = () => { if (i >= files.length) return done();
  const el = document.createElement("script"); el.src = files[i++]; el.onload = next; el.onerror = next; document.head.appendChild(el); }; next(); }
const SLOTS = ['main','sub','range','ammo','head','neck','ear1','ear2','body','hands','ring1','ring2','back','waist','legs','feet'];
const JOBS = [['PLD','Paladin','tank'],['RUN','Rune Fencer','tank'],
  ['WHM','White Mage','healer'],['RDM','Red Mage','healer'],['SMN','Summoner','healer'],
  ['GEO','Geomancer','support'],['COR','Corsair','support'],['BRD','Bard','support'],
  ['WAR','Warrior','dd'],['MNK','Monk','dd'],['THF','Thief','dd'],['DRK','Dark Knight','dd'],['SAM','Samurai','dd'],
  ['NIN','Ninja','dd'],['DRG','Dragoon','dd'],['DNC','Dancer','dd'],['BST','Beastmaster','dd'],['BLU','Blue Mage','dd'],
  ['PUP','Puppetmaster','dd'],['SCH','Scholar','dd'],['RNG','Ranger','dd'],['BLM','Black Mage','dd']];
let CHARS = {};
// Mote's internal modes, never shown; its default modes (OffenseMode 'Normal'...) only once a job gives
// them a choice (BLU, DRG, DRK, MNK, NIN bind OffenseMode, Blody's COR RangedMode...)
const HIDDEN_MODES = new Set(['EquipStop','PCTargetMode','RestingMode','SelectNPCTargets','Moving']);
const MOTE_DEFAULT_MODES = new Set(['CastingMode','DefenseMode','MagicalDefenseMode','PhysicalDefenseMode','RangedMode','WeaponskillMode','OffenseMode','IdleMode','HybridMode','Kiting']);
const modeHidden = m => HIDDEN_MODES.has(m.name) || (MOTE_DEFAULT_MODES.has(m.name) && m.values.length < 2);

let S = {char:'', job:null, section:'sets', variant:{}, sel:{}, subs:{}, weapons:{}, slotForce:{}, heldSub:{}, meritEdits:{}, q:'', lang:'fr', theme:null,
  trial:{}, drafts:{}, buffs:{}, buffTier:{}, held:{}, famOpen:{}, keyOv:{}, keyDirty:{}, setOv:{}, layout:'auto', toast:'', _live:{}, _link:{}, sim:{}, simOpen:{}, statHide:{}, statSort:'group', statOnlyWant:false, statPresets:{}, statPreset:'', optOpts:{obj: 'damage', pdt: -50, mdt: -21, sb: 0}, boxOpen:{}, wsTp:null, _tpb:{}, macroAlt:{}};
// What a reload keeps: where you were (character, job, tab, set, subjob), what you were trying
// (weapons, pieces, merits, buffs) and the open categories
const KEEP = ['lang', 'theme', 'char', 'job', 'section', 'selPath', 'subs', 'weapons', 'slotForce', 'forceSrc', 'heldSub', 'meritEdits', 'trial', 'buffs', 'buffTier', 'held', 'famOpen', 'keyOv', 'keyDirty', 'setOv', 'layout', 'sim', 'simOpen', 'statHide', 'boxOpen', 'wsTp', 'allItems', 'drafts', 'statSort', 'statOnlyWant', 'statPresets', 'statPreset', 'optOpts', 'macroAlt', 'bFold'];
S.selPath = {};
try { const s = JSON.parse(localStorage.getItem('atelier') || '{}'); for (const k of KEEP) if (s[k] != null) S[k] = s[k]; } catch(e) {}
if (S.section === 'worn') S.section = 'sets';
// drafts A / B saved by an older page: the draft not shown becomes a try kept for comparing, nothing is lost
for (const d of Object.values(S.drafts || {})) if (d && d.cur) {
  const other = d.cur === 'A' ? 'B' : 'A';
  if (d[other] && Object.keys(d[other]).length) d.kept = (d.kept || []).concat([{name: 'Brouillon ' + other, tr: d[other]}]);
  delete d.cur; delete d.A; delete d.B; delete d.info;
}
const $ = s => document.querySelector(s);
const esc = s => String(s ?? '').replace(/[&<>"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));
const t = (k, v={}) => { let s = k.split('.').reduce((o,p) => o && o[p], T[S.lang]) ?? k; for (const [a,b] of Object.entries(v)) s = s.split('{'+a+'}').join(b); return s; };
const role = c => JOBS.find(j => j[0]===c)[2];
const plays = c => !!CHARS[S.char] && CHARS[S.char].jobs.includes(c);
// DATA[char][job][sub]: one export per subjob. The one shown first is the last
// in-game export, else the last one; the subjob chosen in the page wins.
const exportsOf = (c, j) => (DATA[c] || {})[j] || {};
function defaultSub(c, j){
  const m = exportsOf(c, j), rank = d => (d.offline ? '0' : '1') + (d.main_sub ? '1' : '0') + (d.at || '');
  return Object.keys(m).sort((a, b) => rank(m[b]).localeCompare(rank(m[a])))[0];
}
// Subjobs the player chose: the macro book list, and a lockstyle only when it differs
// from the default (BST lists all 19 subjobs at the default style)
function namedSubs(d){
  const m = d.macro || {}, l = d.lockstyle || {};
  const named = Object.keys(m.solo || {}).concat(Object.keys(l.by_subjob || {}).filter(s => l.by_subjob[s] !== l.default));
  return named.filter(s => s !== d.job && JOBS.some(j => j[0] === s));
}
// Subjobs shown as buttons: the main one and those of the player's settings; every
// other subjob is in the picker's list (Kaories' RDM differs on all 21: no room for 21 buttons)
function subsOf(c, j){
  const m = exportsOf(c, j), main = m[defaultSub(c, j)];
  return [...new Set([defaultSub(c, j)].concat(main ? namedSubs(main) : []))].filter(Boolean).sort();
}
const ALL_SUBS = {};
const allSubs = (c, j) => { const k = DATA_GEN + '|' + c + '|' + j;
  return ALL_SUBS[k] || (ALL_SUBS[k] = [...new Set(JOBS.map(x => x[0]).filter(x => x !== j).concat(Object.keys(exportsOf(c, j))))].sort()); };
const subOf = (c, j) => { const s = S.subs[c + '|' + j]; return allSubs(c, j).includes(s) ? s : defaultSub(c, j); };
// A subjob without an export of its own shows the main export: same sets, keys and
// modes; its macro book, lockstyle and keys of one subjob follow d.sub
// A subjob without a file shows the export it has the same content as (same_as, written by
// the offline export: PLD /WAR is like /RUN, not like /SCH), else the main one
function recordOf(c, j){
  const m = exportsOf(c, j), s = subOf(c, j), main = m[defaultSub(c, j)];
  const twin = m[sameAsOf(c, j)[s]] || main;
  return m[s] || (twin && Object.assign({}, twin, {sub: s, sameAs: twin.sub}));
}
const sameAsOf = (c, j) => Object.assign({}, ...Object.values(exportsOf(c, j)).map(x => x.same_as || {}));
const data = () => S.job && recordOf(S.char, S.job);
// What only the game sees (bag items) or any export knows (icons) is shared by the job's subjobs
const ofAnySub = key => { const d = data(); if (d && d[key]) return d[key];
  const other = Object.values(exportsOf(S.char, S.job)).find(x => x[key]); return other ? other[key] : null; };
// The pieces you hold, by slot (the shown export's owned), with every piece kept at the Porter Moogle this job can
// wear: the export lists the whole Porter (porter: {item id: 'Slip N'}, every job's gear), the catalogue says each item's
// slots and jobs, so a job not loaded since gets its stored pieces too (an export with no such list: the job's latest
// export that read its slips)
let OWNED_MEMO = {key: null, out: null};
const isSlip = w => /^Slip \d+/.test(w);
const atPorter = x => !!(x.where && x.where.length) && x.where.every(isSlip);
// The character's Porter Moogle: the list of its latest export that has one
const porterOf = c => (latestExport(c, 'porter') || {}).porter || null;
function addCopy(out, slot, x){
  const mine = out[slot] = out[slot] || [];
  if (!mine.some(y => y.name === x.name && (y.id || 0) === (x.id || 0) && (y.augs || []).join('|') === (x.augs || []).join('|') && (y.where || []).join() === (x.where || []).join()))
    mine.push(x);
}
function ownedOf(){
  const d = data(), cat = catalog(), key = [DATA_GEN, S.char, S.job, d && d.sub, !!cat].join('|');
  if (OWNED_MEMO.key === key) return OWNED_MEMO.out;
  const cur = ofAnySub('owned') || {}, out = {}, porter = porterOf(S.char);
  for (const [slot, list] of Object.entries(cur)) out[slot] = list.filter(x => !(porter && atPorter(x)));
  if (porter && cat) {
    const byId = CAT.byId || (CAT.byId = Object.fromEntries(cat.src.items.map(r => [r[0], r])));
    for (const [id, where] of Object.entries(porter)) {
      const r = byId[id];
      if (!r || !r[3].split(' ').includes(S.job)) continue;
      for (const slot of r[2].split(' ')) addCopy(out, slot, {name: r[1], id: +id, where: [where], count: 1});
    }
  } else {
    const hasSlips = o => Object.values(o || {}).some(list => list.some(atPorter));
    const other = hasSlips(cur) ? null : Object.values(exportsOf(S.char, S.job)).filter(x => hasSlips(x.owned))
      .sort((a, b) => (b.at || '').localeCompare(a.at || ''))[0];
    for (const [slot, list] of Object.entries((other && other.owned) || {})) for (const x of list.filter(atPorter)) addCopy(out, slot, x);
  }
  OWNED_MEMO = {key, out};
  return out;
}
// The game's short name for every piece of an export's sets: a set file may write the long one ("Maculele Earring +1"
// for "Macu. Earring +1") or another case, and the bags list the short one, so the piece read as not yours (an export
// written before shared/utils/atelier/atelier_names.lua). Needs the engine's catalogue (both names, any case)
function canonNames(d){
  if (!d || !window.FFXI || !FFXI.opt || !FFXI.opt.item) return;
  const fix = p => { if (!p || !p.name || p.name === 'empty') return; const it = FFXI.opt.item(p.name); if (it && it.name !== p.name) p.name = it.name; };
  for (const s of d.sets || []) { Object.values(s.pieces || {}).forEach(fix); Object.values(s.was || {}).forEach(fix); }
}
const canonAll = () => { for (const c of Object.values(DATA)) for (const j of Object.values(c)) Object.values(j).forEach(canonNames); DATA_GEN++; };
// Where a piece is, as the page says it: a slip is the Porter Moogle's
const whereLabel = w => isSlip(w) ? t('porterAt', {n: w.slice(5)}) : w;
// One field of every export of the shown job merged (icons, descriptions, scans), kept until an export is read again:
// the stats of each piece ask for them, and merging ~800 entries each time was most of a render
let MERGED = {}, MERGED_GEN = -1;
function mergedOf(field){
  if (MERGED_GEN !== DATA_GEN) { MERGED = {}; MERGED_GEN = DATA_GEN; }
  const k = S.char + '|' + S.job + '|' + field;
  return MERGED[k] || (MERGED[k] = Object.assign({}, ...Object.values(exportsOf(S.char, S.job)).map(x => x[field] || {})));
}
const iconIds = () => mergedOf('icons');
// The character's latest export that holds `field` (key_overrides, set_overrides: written by every job), or undefined
const latestExport = (c, field) => Object.values(DATA[c] || {}).flatMap(j => Object.values(j)).filter(x => x[field] !== undefined)
  .sort((a, b) => (b.at || '').localeCompare(a.at || ''))[0];
function save(){ try { localStorage.setItem('atelier', JSON.stringify(Object.fromEntries(KEEP.map(k => [k, S[k]])))); } catch(e) {} }
// The game's icon of an item (data/atelier/icons/<id>.bmp, written by the export); an empty frame without one
const icon = name => { const id = name && (iconIds()[name] || (catalog() || {id: {}}).id[name]);
  return `<span class="ico" aria-hidden="true">${id ? `<img src="atelier/icons/${id}.bmp" alt="" onerror="iconMiss(this, ${+id})">` : ''}</span>`; };
// An icon not on the disk yet (a piece you do not hold: the export writes only yours and your sets'):
// the game writes it on demand (POST /icons, item_icons.lua), the ids gathered for a moment, then the
// page is drawn again; an id already asked for is not asked again
const ICON_WANT = new Set(), ICON_ASKED = new Set();
let ICON_TIMER = null;
function iconMiss(img, id){
  img.remove();
  if (!id || ICON_ASKED.has(id) || !liveOk()) return;
  ICON_WANT.add(id); clearTimeout(ICON_TIMER); ICON_TIMER = setTimeout(iconFetch, 150);
}
async function iconFetch(){
  if (!liveOk()) return;
  const ids = [...ICON_WANT].slice(0, 300);
  ids.forEach(id => { ICON_WANT.delete(id); ICON_ASKED.add(id); });
  if (!ids.length) return;
  try { await liveFetch(S.char, '/icons?ids=' + ids.join(','), {method: 'POST', timeout: 15000}); }
  catch (e) { ids.forEach(id => { ICON_ASKED.delete(id); ICON_WANT.add(id); }); clearTimeout(ICON_TIMER); ICON_TIMER = setTimeout(iconFetch, 10000); return; }
  render();
  if (ICON_WANT.size) iconFetch();
}
// Macro book and lockstyle in force for the export's subjob: its own setting, else the default
// The alt the book is shown for: the page's choice, else the one online in game (ping), else none
const macroAlt = d => { const pick = S.macroAlt[S.char + '|' + S.job];
  if (pick !== undefined) return pick || null;
  const L = S._live[S.char] || {}; return L.ok && L.job === S.job ? L.alt || null : null; };
// The book GearSwap loads (macrobook_manager.lua resolve_config): the alt's book for this subjob, else
// its 'default', else the solo one, else the default, else the factory's (no config file)
function bookFor(d, alt = macroAlt(d)){
  const m = d.macro || {}, du = alt && (m.dualbox || {})[alt];
  return (du && (du[d.sub] || du.default)) || (m.solo || {})[d.sub] || (m.solo || {}).default || m.default || d.macro_fallback || null;
}

/* ---- the set's path and family, read by every part of the page ---- */
function family(path, pieces){
  const p = path;
  const slots = Object.keys(pieces||{});
  if (/^sets(\.\w+|\["[^"]+"\])$/.test(p) && slots.length && slots.every(s => ['main','sub','range','ammo'].includes(s)) && !/^sets\.(idle|engaged|MoveSpeed)/.test(p)) return 'weapons';
  // GEO keeps its own sets (sets.me.*) and the ones with a luopan out (sets.luopan.*)
  if (/^sets\.(idle|Adoulin|Town|me\.idle|luopan\.idle|resting|MoveSpeed|Kiting)/.test(p)) return 'idle';
  if (/^sets\.(engaged|me\.engaged|luopan\.engaged)/.test(p)) return 'engaged';
  if (/^sets\.pet|Pet|pet_/.test(p)) return 'pet';
  // the enmity sets a tank wears for its job abilities and spells (sets.FullEnmity, EnmityMax, midcast.SIRDEnmity)
  if (/^sets\.(midcast\.)?\w*Enmity\w*$/.test(p)) return 'enmity';
  if (/^sets\.precast\.FC/.test(p)) return 'fc';
  if (/^sets\.precast\.WS/.test(p)) return 'ws';
  if (/^sets\.precast/.test(p)) return 'ja';
  if (/^sets\.midcast/.test(p)) return 'midcast';
  if (/^sets\.(buff|defense|TreasureHunter|CombatMode|Doom|latent|FullEnmity|Enmity)/.test(p)) return 'special';
  return 'other';
}
function segs(path){ return path.match(/\.[\w-]+|\["[^"]+"\]/g).map(s => s.startsWith('.') ? s.slice(1) : s.slice(2,-2)); }
function shortPath(p){ return p ? p.replace(/^sets\./,'') : ''; }

/* ---- the exports' weaponskill tables, and an empty slot ---- */
// Pieces tried in the page come last: they win over the set and the weapon modes
const isEmpty = p => p && p.name === 'empty';
// The weaponskill a set is for (sets.precast.WS["Savage Blade"] -> Savage Blade), or null
// The weaponskill of a set: the last part of its path that is one (sets.precast.WS.Disaster.Solo: Disaster)
function wsOfSet(s){
  if (family(s.path, s.pieces) !== 'ws') return null;
  const known = wsSkills();
  return segs(s.path).reverse().find(x => known[x]) || null;
}
// Weaponskill -> its combat skill (export ws_skill), weapon -> its combat skill (export wskill)
const wsSkills = () => mergedOf('ws_skill');
// Whether a weapon of a mode can open a weaponskill: its skill, and for a relic or prime one the
// weapon itself (export ws_info.lock names them; empyrean and mythic ones are unlocked for any weapon)
const wsInfoOf = ws => mergedOf('ws_info')[ws] || {};
// Each weapon's combat skill (Great Axe, Sword...), every export of the shown job merged
const weaponSkills = () => mergedOf('wskill');

/* ---- shared HTML helpers: a compartment, damage figures ---- */
// A compartment: a card with a title band in its section's colour (g-def, g-tank...)
const box = (cls, title, body, meta = '') =>
  `<section class="box ${cls}"><header class="boxh"><h3>${title}</h3>${meta}</header><div class="boxb">${body}</div></section>`;
// A stats compartment that folds: closed until opened (S.boxOpen[key]); closed, its band says how many lines it holds
function fbox(key, cls, title, body){
  const open = !!S.boxOpen[key], n = (body.match(/<li[ >]/g) || []).length;
  return `<section class="box ${cls}"><button class="boxh bufftoggle" data-fold="${esc(key)}" aria-expanded="${open}"><h3>${title}</h3>` +
    `<span class="meta">${n || ''}</span></button>${open ? `<div class="boxb">${body}</div>` : ''}</section>`;
}
const fmtDmg = n => Math.round(n).toLocaleString(S.lang === 'fr' ? 'fr-FR' : 'en-US');

/* ---- two pieces compared ---- */
const samePiece = (a, b) => (!a || a.name === 'empty') ? (!b || b.name === 'empty') : !!b && a.name === b.name && (a.augs || []).join('|') === (b.augs || []).join('|')
  && (a.rank ?? null) === (b.rank ?? null);

/* ---- the windows closed ---- */
// GearSwap Atelier · events.js: clicks, menus, keyboard, the hover card, start-up
// (cut from atelier.html, loaded by it in order: see the list there)
// a search still running is set aside, not destroyed: Hide (or Escape) parks its window where it goes on painting,
// and "See the search" on the optimizer page brings it back
function closeOverlay(){ const ov = $('#overlay');
  // drawn again after, so the optimizer page shows the button that brings it back
  if (S._optRun && ov.querySelector('.optrun')) { searchPark().replaceChildren(...ov.childNodes); setTimeout(render); }
  ov.hidden = true; ov.innerHTML = ''; KEYEDIT = null; S._buffDlg = false; S._tgtDlg = false; S._tgtPick = false;
  S._push = S._del = S._create = null; const tip = $('#tip'); if (tip) tip.hidden = true; S._tipEl = null; }
function searchPark(){
  let park = document.getElementById('orpark');
  if (!park) { park = document.createElement('div'); park.id = 'orpark'; park.hidden = true; document.body.appendChild(park); }
  return park;
}
const searchParked = () => !!document.querySelector('#orpark .optrun');
function searchShow(){
  if (!searchParked()) return;
  closeOverlay();
  const ov = $('#overlay'); ov.replaceChildren(...searchPark().childNodes); ov.hidden = false;
}

