// GearSwap Atelier · module_ux.js: what makes the Modules part (modules.js) easy to handle:
//   the search across every option of every module; the bar of waiting changes at the bottom, each said before -> after;
//   a number with its bounds (- / +, a slider when the bounds are known, back to the standard value);
//   a colour shown as a colour, changed with the system's colour picker;
//   the window that picks an ability or a spell among those the job can use; the read-only banner.
// (loaded by atelier/index.html after module_rows.js, before modules.js)

Object.assign(T.fr, {mxSearch: 'Chercher une option : un mot, un objet, un sort…', mxSearchTip: 'Cherche dans le nom et l’explication de chaque option de chaque module, et dans les objets et sorts de tes listes.',
  mxFound: '{n} option(s) pour « {q} »', mxNone: 'Aucune option pour « {q} ». Essaie un autre mot, ou efface la recherche pour revoir les modules.', mxClear: 'Effacer', mxClearTip: 'Efface la recherche et revient aux modules.',
  mxInAdv: 'Avancé · {f}', mxMore: 'Les {n} premières sont affichées : précise ta recherche pour voir les autres.',
  mxWait: '{n} changement(s) à enregistrer', mxWaitTip: 'Rien n’est écrit tant que tu n’as pas cliqué « Enregistrer ».', mxRevert: 'Annuler ce changement', mxUndoAll: 'Tout annuler', mxEmptyVal: '(vide)',
  mxLockT: 'Lecture seule', mxLock: 'Le jeu n’est pas connecté : tu peux tout lire, mais pas modifier. Pour changer un réglage, lance le jeu avec GearSwap chargé sur {c} : la page s’y connecte toute seule, et les options se déverrouillent.',
  mxLess: 'Baisser de {s}', mxMore1: 'Monter de {s}', mxSlide: 'Glisse pour choisir entre {a} et {b}.', mxStd: 'Standard : {v}', mxStdTip: 'Remettre la valeur standard ({v}).', mxIsStd: 'valeur standard', mxRange: 'Entre {a} et {b}.',
  mxColor: 'Clique pour ouvrir le nuancier et choisir la couleur.', mxColorOf: 'Rouge {r} · Vert {g} · Bleu {b}', mxPresets: 'Couleurs toutes prêtes :', mxPresetTip: 'Prendre le fond « {n} » (opacité {a}).',
  mxActAdd: '+ Ajouter une ability ou un sort', mxActTip: 'Ouvre la liste des abilities et des sorts : clique sur celui à ajouter.', mxActTitle: 'Ajouter une ability ou un sort',
  mxActSearch: 'Chercher une ability ou un sort…', mxActJa: 'Abilities de {j}', mxActMa: 'Magie de {j}', mxWsAdd: '+ Ajouter une weaponskill', mxWsTip: 'Ouvre la liste des weaponskills : clique sur celle à ajouter.', mxWsTitle: 'Ajouter une weaponskill', mxWsTitleFor: 'Ajouter une weaponskill pour {w}',
  mxWsSearch: 'Chercher une weaponskill…', mxWsHint: 'Tape quelques lettres pour chercher dans toutes les weaponskills du jeu.', mxWsGiven: 'Données par {w}', mxWsKindJob: '{k} : celles de {j}', mxWsKindSub: '{k} : avec ton sub /{s}',
  mxWsKindAny: '{k} : jobs non renseignés', mxWsKindOther: '{k} : celles que {j} n’a pas', mxWsJob: 'Weaponskills de {j}', mxWsSub: 'Avec ton sub /{s}', mxWsFoundOk: 'Utilisables en {j}', mxWsFoundOther: 'Celles que {j} n’a pas',
  mxWsFrom: 'Donnée par : {w}.', mxWsJobs: 'Jobs : {j}.', mxWsNoJobs: 'Jobs non renseignés.', mxActAll: 'Dans tout le jeu', mxUsedJa: 'Abilities déjà dans tes listes (tous tes jobs)', mxUsedMa: 'Magie déjà dans tes listes (tous tes jobs)', mxUsedMode: 'Sorts qui suivent un mode', mxAllJa: 'Autres abilities du jeu', mxAllMa: 'Autre magie du jeu', mxActUse: 'Utilisable en {j}', mxActOther: 'Pas utilisable en {j}', mxActHint: 'Tape quelques lettres pour chercher dans toutes les abilities et tous les sorts du jeu.'});
Object.assign(T.en, {mxSearch: 'Search an option: a word, an item, a spell…', mxSearchTip: 'Searches the name and the explanation of every option of every module, and the items and spells of your lists.',
  mxFound: '{n} option(s) for "{q}"', mxNone: 'No option for "{q}". Try another word, or clear the search to see the modules again.', mxClear: 'Clear', mxClearTip: 'Clears the search and goes back to the modules.',
  mxInAdv: 'Advanced · {f}', mxMore: 'The first {n} are shown: narrow the search to see the others.',
  mxWait: '{n} change(s) to save', mxWaitTip: 'Nothing is written until you click "Save".', mxRevert: 'Undo this change', mxUndoAll: 'Undo all', mxEmptyVal: '(empty)',
  mxLockT: 'Read only', mxLock: 'The game is not connected: everything can be read, nothing changed. To change a setting, start the game with GearSwap loaded on {c}: the page connects by itself, and the options unlock.',
  mxLess: 'Lower by {s}', mxMore1: 'Raise by {s}', mxSlide: 'Drag to choose between {a} and {b}.', mxStd: 'Standard: {v}', mxStdTip: 'Back to the standard value ({v}).', mxIsStd: 'standard value', mxRange: 'Between {a} and {b}.',
  mxColor: 'Click to open the colour picker and choose the colour.', mxColorOf: 'Red {r} · Green {g} · Blue {b}', mxPresets: 'Ready-made colours:', mxPresetTip: 'Take the {n} background (opacity {a}).',
  mxActAdd: '+ Add an ability or a spell', mxActTip: 'Opens the list of abilities and spells: click the one to add.', mxActTitle: 'Add an ability or a spell',
  mxActSearch: 'Search an ability or a spell…', mxActJa: '{j} abilities', mxActMa: '{j} magic', mxWsAdd: '+ Add a weaponskill', mxWsTip: 'Opens the list of weaponskills: click the one to add.', mxWsTitle: 'Add a weaponskill', mxWsTitleFor: 'Add a weaponskill for {w}',
  mxWsSearch: 'Search a weaponskill…', mxWsHint: 'Type a few letters to search every weaponskill of the game.', mxWsGiven: 'Given by {w}', mxWsKindJob: '{k}: those {j} has', mxWsKindSub: '{k}: with your /{s} subjob',
  mxWsKindAny: '{k}: jobs not told', mxWsKindOther: '{k}: those {j} does not have', mxWsJob: '{j} weaponskills', mxWsSub: 'With your /{s} subjob', mxWsFoundOk: 'Usable on {j}', mxWsFoundOther: 'Those {j} does not have',
  mxWsFrom: 'Given by: {w}.', mxWsJobs: 'Jobs: {j}.', mxWsNoJobs: 'Jobs not told.', mxActAll: 'In the whole game', mxUsedJa: 'Abilities already in your lists (all your jobs)', mxUsedMa: 'Magic already in your lists (all your jobs)', mxUsedMode: 'Spells that follow a mode', mxAllJa: 'Other abilities of the game', mxAllMa: 'Other magic of the game', mxActUse: 'Usable on {j}', mxActOther: 'Not usable on {j}', mxActHint: 'Type a few letters to search every ability and spell of the game.'});

/* ---- a number with its bounds ---- */
// opts: {unit, range: [min, max, step], std}. A unit in percent is 0 to 100 by itself
function mxNumOpts(x, opts = {}){
  const range = opts.range || (opts.unit && opts.unit.includes('%') ? [0, 100] : null);
  const step = (range && range[2]) || (Number.isInteger(x.value) ? 1 : 0.1);
  return {range, step, std: opts.std, unit: opts.unit};
}
function modNum(x, val, id, off, opts){
  const o = mxNumOpts(x, opts), lim = o.range ? `data-min="${o.range[0]}" data-max="${o.range[1]}"` : '';
  const btn = (dir, sign, key) => `<button class="mcstep" data-numstep="${dir * o.step}" ${lim} ${id} ${off} title="${esc(off ? t('ttModRead') : t(key, {s: o.step}))}" aria-label="${esc(t(key, {s: o.step}))}">${sign}</button>`;
  const slide = o.range ? `<input class="modrange" type="range" min="${o.range[0]}" max="${o.range[1]}" step="${o.step}" value="${esc(val)}" data-modrange ${id} ${off} ${modTip(off, 'mxSlide', {a: o.range[0], b: o.range[1]})}>` : '';
  const std = o.std == null ? '' : val === o.std ? `<small class="mcstd is">${esc(t('mxIsStd'))}</small>` : `<button class="mcstd" data-modstd="${o.std}" ${id} ${off} ${modTip(off, 'mxStdTip', {v: o.std})}>${esc(t('mxStd', {v: o.std}))}</button>`;
  return `${slide}<span class="mcfield">${btn(-1, '−', 'mxLess')}<input class="modin num" type="text" inputmode="decimal" value="${esc(val)}" ${lim} ${id} data-modin ${off} ` +
    `${modTip(off, o.range ? 'mxRange' : 'ttModNum', o.range ? {a: o.range[0], b: o.range[1]} : {})}>${o.unit ? `<i class="mcunit">${esc(o.unit)}</i>` : ''}${btn(1, '+', 'mxMore1')}</span>${std}`;
}
const mxRound = v => Number(v.toFixed(4));
const mxClamp = (v, d) => Math.min(d.max != null && d.max !== '' ? +d.max : Infinity, Math.max(d.min != null && d.min !== '' ? +d.min : -Infinity, v));
// A typed number outside its bounds is refused (the bounds are on the field)
const mxInRange = (el, v) => typeof v !== 'number' || el.dataset.min == null || (v >= +el.dataset.min && v <= +el.dataset.max);

/* ---- a colour ---- */
const mxHex = (r, g, b) => '#' + [r, g, b].map(v => Math.max(0, Math.min(255, Math.round(+v) || 0)).toString(16).padStart(2, '0')).join('');
const mxRgb = hex => [1, 3, 5].map(i => parseInt(hex.slice(i, i + 2), 16));
const MX_RGB = [['r', 'g', 'b'], ['red', 'green', 'blue']];
// A list of three numbers from 0 to 255 in a file of colours
const mxColorList = (f, x) => x.kind === 'list' && /UI_(COLOR_)?CONFIG\.lua$/.test(f.file) && x.fields.length === 3 && x.fields.every(c => c.kind === 'num' && c.value >= 0 && c.value <= 255);
// A table that holds a colour as three named numbers (r g b, red green blue): the three names, or null
const mxColorMap = x => x.kind === 'map' ? MX_RGB.find(keys => keys.every(k => x.fields.some(c => c.key === k && c.kind === 'num'))) || null : null;
const mxSwatch = (rgb, attr, off) => `<span class="modcolor"><input type="color" value="${mxHex(...rgb)}" ${attr} ${off} ${modTip(off, 'mxColor')}><code>${mxHex(...rgb).toUpperCase()}</code>` +
  `<small>${esc(t('mxColorOf', {r: rgb[0], g: rgb[1], b: rgb[2]}))}</small></span>`;
const modColorList = (val, id, off) => mxSwatch(val, `data-modcolor="list" ${id}`, off);
function modColorMap(f, x, off){
  const keys = mxColorMap(x), rgb = keys.map(k => modValue(f.file, x.path + '.' + k));
  return mxSwatch(rgb, `data-modcolor="${keys.join(',')}" data-modfile="${esc(f.file)}" data-modpath="${esc(x.path)}"`, off);
}

// The ready-made colours of the file (a table of named {r, g, b, a}: UI_CONFIG.lua background_presets), as swatches:
// a click takes the colour and its opacity
function modPresets(f, x, from, off){
  const all = modParsed(f).byPath[from]; if (!all || all.kind !== 'map') return '';
  const cur = ['r', 'g', 'b', 'a'].map(k => modValue(f.file, x.path + '.' + k)).join(',');
  const tiles = all.fields.filter(p => mxColorMap(p)).map(p => { const v = ['r', 'g', 'b', 'a'].map(k => modValue(f.file, p.path + '.' + k)), name = p.key.replace(/_/g, ' ');
    return `<button class="modpreset" data-modpreset="${esc(p.path)}" data-modfile="${esc(f.file)}" data-modpath="${esc(x.path)}" aria-pressed="${v.join(',') === cur}" ${off} ` +
      `title="${esc(off ? t('ttModRead') : t('mxPresetTip', {n: name, a: v[3]}))}"><i style="background:${mxHex(v[0], v[1], v[2])};opacity:${Math.max(.25, (v[3] == null ? 255 : v[3]) / 255)}"></i><span>${esc(name)}</span></button>`; }).join('');
  return tiles ? `<div class="modpresets"><small>${esc(t('mxPresets'))}</small>${tiles}</div>` : '';
}
/* ---- the bar of waiting changes ---- */
// A setting's name for the player: the catalog's, else the Advanced view's, else the file's own
function mxTitle(file, path){
  for (const fam of MOD_CATALOG) for (const r of mcRows(data(), fam)) if (r.f.file === file && r.x.path === path) return r.title;
  const fr = S.lang === 'en' ? null : modRestFr(file, path), x = modField(file, path);
  // a part of a colour or of a table: said with the name of what holds it
  const up = path.includes('.') ? mxTitle(file, path.slice(0, path.lastIndexOf('.'))) : '';
  const own = fr ? fr.title : x ? modName(x) : path;
  return up && fr && own.length < 12 ? up + ' · ' + own : own;
}
const mxCut = s => { s = String(s); return s === '' ? t('mxEmptyVal') : s.length > 70 ? s.slice(0, 68) + '…' : s; };
function modSaveBar(){
  const all = (S._modEdits || {})[S.char] || {}, lines = [];
  for (const file of Object.keys(all)) for (const path of Object.keys(all[file])) { const e = all[file][path];
    lines.push(`<li><b>${esc(mxTitle(file, path))}</b><span class="was">${esc(mxCut(e.before))}</span><i aria-hidden="true">→</i><span class="now">${esc(mxCut(e.after))}</span>` +
      `<button data-modrevert data-modfile="${esc(file)}" data-modpath="${esc(path)}" title="${esc(t('mxRevert'))}" aria-label="${esc(t('mxRevert'))}">×</button></li>`); }
  if (!lines.length) return '';
  return `<div class="modsave" role="region"><div class="mshead"><b title="${esc(t('mxWaitTip'))}">${esc(t('mxWait', {n: lines.length}))}</b><span class="sp"></span>` +
    `<button class="btn ghost" data-modundo title="${esc(t('ttModUndo'))}">${esc(t('mxUndoAll'))}</button><button class="btn" data-modsave title="${esc(t('ttModSave'))}">${esc(t('modSave'))}</button></div><ul>${lines.join('')}</ul></div>`;
}

/* ---- the search ---- */
const mxNorm = s => String(s == null ? '' : s).toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '');
const mxValText = v => Array.isArray(v) ? v.map(mxValText).join(' ') : v && typeof v === 'object' ? Object.values(v).map(mxValText).join(' ') : String(v == null ? '' : v);
// Every word typed must be found in the option: its name, what it does, its module, what it holds
const mxHit = (words, ...texts) => { const hay = mxNorm(texts.join(' ')); return words.every(w => hay.includes(w)); };
const MX_MAX = 60;
function modSearch(d, q){
  const words = mxNorm(q).split(/\s+/).filter(Boolean), groups = [], name = fam => (S.lang === 'en' ? fam.en : fam.fr).split('{JOB}').join(S.job || '');
  let n = 0;
  const seen = new Set();
  for (const fam of MOD_CATALOG) {
    const rows = mcRows(d, fam).filter(r => !seen.has(r.f.file + '|' + r.x.path) && mxHit(words, r.title, r.desc, name(fam), r.x.key, mxValText(modValue(r.f.file, r.x.path))));
    rows.forEach(r => seen.add(r.f.file + '|' + r.x.path));
    if (rows.length) { groups.push({title: name(fam), n: rows.length, html: () => rows.map(r => mcCardHTML(d, r)).join('')}); n += rows.length; }
  }
  // the settings only the Advanced view holds: by file
  for (const f of modFiles(d)) {
    const known = modKnown(d, f), hits = Object.values(modParsed(f).byPath).filter(x => { if (known[x.path] || x.kind === 'map' || x.kind === 'code') return false;
      const fr = S.lang === 'en' ? null : modRestFr(f.file, x.path); return mxHit(words, fr ? fr.title : modName(x), fr ? fr.desc : modDoc(x.doc), x.key, mxValText(modValue(f.file, x.path))); });
    if (hits.length) { groups.push({title: t('mxInAdv', {f: modFileInfo(f).name}), n: hits.length, html: () => hits.map(x => modRowHTML(f, x, 0)).join('')}); n += hits.length; }
  }
  return {n, groups};
}
function modSearchHTML(d){
  const q = S.modQ.trim(), found = modSearch(d, q); let left = MX_MAX, html = '';
  for (const g of found.groups) { if (left <= 0) break; html += `<h4 class="modpart">${esc(g.title)}</h4>${g.html()}`; left -= g.n; }
  const body = found.n ? html + (found.n > MX_MAX ? `<p class="muted modnone">${esc(t('mxMore', {n: MX_MAX}))}</p>` : '') : `<p class="muted modnone">${esc(t('mxNone', {q}))}</p>`;
  return `<div class="modpanel modfound">` + box('g-attr wide', esc(t('mxFound', {n: found.n, q})), `<div class="modrows">${body}</div>`) + `</div>`;
}
// The top bar: the search, the two views; under it, the banner when nothing can be changed
function modTop(views, hint){
  const q = S.modQ || '';
  return `<div class="keybar modtop"><input id="modq" class="tgq" type="search" value="${esc(q)}" placeholder="${esc(t('mxSearch'))}" title="${esc(t('mxSearchTip'))}" autocomplete="off">` +
    (q ? `<button class="btn ghost" data-modqclear title="${esc(t('mxClearTip'))}">${esc(t('mxClear'))}</button>` : `<span class="modhint">${esc(hint)}</span>`) + views + `</div>` +
    (liveOk() ? '' : `<div class="modlock"><b>${esc(t('mxLockT'))}</b><span>${esc(t('mxLock', {c: S.char}))}</span></div>`);
}
let MX_Q_TIMER = 0;
document.addEventListener('input', e => {
  if (e.target.id === 'modq') { const v = e.target.value; clearTimeout(MX_Q_TIMER);
    MX_Q_TIMER = setTimeout(() => { S.modQ = v; render(); const el = document.getElementById('modq'); if (el) { el.focus(); el.setSelectionRange(v.length, v.length); } }, 140); return; }
  // a slider drags the number beside it; the value is taken when it is let go
  const r = e.target.closest && e.target.closest('[data-modrange]');
  if (r) { const box = r.parentElement.querySelector('.mcfield .modin'); if (box) box.value = r.value; }
});
document.addEventListener('change', e => {
  const el = e.target.closest && e.target.closest('[data-modrange],[data-modcolor]'); if (!el) return; const d = el.dataset;
  if ('modrange' in d) { modStage(d.modfile, d.modpath, Number(el.value)); return; }
  const rgb = mxRgb(el.value);
  if (d.modcolor === 'list') { modStage(d.modfile, d.modpath, rgb); return; }
  d.modcolor.split(',').forEach((k, i) => modStage(d.modfile, d.modpath + '.' + k, rgb[i]));
});
document.addEventListener('click', e => {
  const b = e.target.closest('[data-numstep],[data-modstd],[data-modrevert],[data-modqclear],[data-modpreset]'); if (!b) return; const d = b.dataset;
  if (d.modpreset) { for (const k of ['r', 'g', 'b', 'a']) { const v = modValue(d.modfile, d.modpreset + '.' + k); if (typeof v === 'number' && modField(d.modfile, d.modpath + '.' + k)) modStage(d.modfile, d.modpath + '.' + k, v); } return; }
  if ('modqclear' in d) { S.modQ = ''; render(); return; }
  if ('modrevert' in d) { delete modEdits(d.modfile)[d.modpath]; S.toast = ''; render(); return; }
  if (d.modstd != null) { modStage(d.modfile, d.modpath, Number(d.modstd)); return; }
  const cur = modValue(d.modfile, d.modpath);
  if (typeof cur === 'number') modStage(d.modfile, d.modpath, mxClamp(mxRound(cur + Number(d.numstep)), d));
});

/* ---- the window of abilities and spells ---- */
// A spell a player casts: one with a magic skill (the game's list also holds the trusts, which have none)
const mxSpell = n => typeof SPELL_SKILL === 'undefined' || (SPELL_SKILL[n] && SPELL_SKILL[n] !== '(N/A)');
// What the job shown can use with the subjob shown: {ja: [names], ma: [names]}
function mxActs(){
  if (typeof JA_ACCESS === 'undefined') return {ja: [], ma: []};
  const d = data() || {}, job = S.job, sub = d.sub || '', lv = jaLevels();
  return {ja: Object.keys(JA_ACCESS).filter(n => accessJa(JA_ACCESS[n], job, sub, lv)).sort(), ma: Object.keys(SPELL_ACCESS).filter(n => mxSpell(n) && accessSpell(SPELL_ACCESS[n], job, sub, lv)).sort()};
}
// Every name the other lists of the same file hold (the buffs of every job and subjob, for a list that is for all of
// them): what the player most likely wants here
function mxActsUsed(file){
  const f = modFiles(data()).find(x => x.file === file), names = new Set();
  if (f) for (const x of Object.values(modParsed(f).byPath)) if (x.kind === 'list') for (const v of modValue(file, x.path) || []) if (typeof v === 'string') names.add(v);
  return [...names].sort();
}
function mxActGrid(q){
  const p = S._miPick, has = new Set(modValue(p.file, p.path) || []), needle = mxNorm(q.trim()), mine = mxActs(), ok = new Set([...mine.ja, ...mine.ma]), who = {j: S.job + ((data() || {}).sub ? '/' + data().sub : '')};
  const used = new Set(needle ? [] : mxActsUsed(p.file)), tile = n => `<button class="mitile act ${ok.has(n) || used.has(n) ? '' : 'other'}" data-mipick="${esc(n)}" ${has.has(n) ? 'disabled' : ''} title="${esc(has.has(n) ? t('miHas') : miIsMode(n) ? t('miModeTip', {v: n}) : ok.has(n) ? t('miPickTip', {v: n}) : t('mxActOther', who))}"><span>${esc(miLabel(n))}</span></button>`;
  const part = (title, list) => list.length ? `<h4>${esc(title)}</h4><div class="migrid">${list.map(tile).join('')}</div>` : '';
  // abilities and magic are never mixed: each list is split in two (a name that is neither, a `$Mode` entry: apart)
  const isJa = n => typeof JA_ACCESS !== 'undefined' && !!JA_ACCESS[n], isMa = n => !isJa(n) && !miIsMode(n) && typeof SPELL_ACCESS !== 'undefined' && (!!SPELL_ACCESS[n] || accessSpellsOf(n).length > 0);   // 'Utsusemi': a family of spells
  const split = (list, ja, ma, other) => part(ja, list.filter(isJa)) + part(ma, list.filter(isMa)) + (other ? part(other, list.filter(n => !isJa(n) && !isMa(n))) : '');
  if (!needle) return split(mxActsUsed(p.file), t('mxUsedJa'), t('mxUsedMa'), t('mxUsedMode')) + part(t('mxActJa', who), mine.ja) + part(t('mxActMa', who), mine.ma.slice(0, 120)) + `<p class="muted small">${esc(t('mxActHint'))}</p>`;
  const all = typeof JA_ACCESS === 'undefined' ? [] : [...new Set([...Object.keys(JA_ACCESS), ...Object.keys(SPELL_ACCESS).filter(mxSpell)])].filter(n => mxNorm(n).includes(needle));
  const first = all.filter(n => ok.has(n)).sort(), rest = all.filter(n => !ok.has(n)).sort().slice(0, 60);
  return first.length || rest.length ? split(first.slice(0, 120), t('mxActJa', who), t('mxActMa', who)) + split(rest, t('mxAllJa'), t('mxAllMa')) : `<p class="muted">${esc(t('miNone'))}</p>`;
}
function openActPick(file, path){
  S._miPick = {file, path, acts: true};
  showDialog('midlg', esc(t('mxActTitle')), `<input id="miq" class="tgq" type="search" placeholder="${esc(t('mxActSearch'))}" autocomplete="off"><div id="mibody" class="mibody">${mxActGrid('')}</div>`, '');
  const q = document.getElementById('miq'); if (q) q.focus();
}

/* ---- the window of weaponskills ---- */
// The weapon a list of weaponskills is for: the last name of its path is a weapon mode (by_weapon.Naegling), whose
// set (sets.Naegling) wears the weapon. {name, kind} (kind: the game's combat skill, "Sword"), or null
function mxWsWeapon(path){
  const mode = path.split('.').pop(), set = ((data() || {}).sets || []).find(s => s.path === 'sets.' + mode || s.path === 'sets["' + mode + '"]');
  const main = set && set.pieces && set.pieces.main, name = main && main.name;
  return name ? {name, kind: itemKind(name)} : null;
}
// The weapons whose description names a weaponskill ("Main hand: "Savage Blade"", a relic's own): {weaponskill: [weapons]}
let MX_WS_GIVEN = null;
function mxWsGiven(){
  const c = typeof catalog === 'function' && catalog();
  if (!c || typeof WS_ACCESS === 'undefined') return {};
  if (!MX_WS_GIVEN || MX_WS_GIVEN.src !== c.src) { const by = {};
    for (const r of c.src.items) if (r[6] && r[6].includes('"')) for (const m of r[6].matchAll(/"([^"]+)"/g)) if (WS_ACCESS[m[1]] && r[10] === WS_ACCESS[m[1]][0]) (by[m[1]] = by[m[1]] || new Set()).add(r[1]);
    MX_WS_GIVEN = {src: c.src, by: Object.fromEntries(Object.entries(by).map(([k, v]) => [k, [...v].sort()]))}; }
  return MX_WS_GIVEN.by;
}
function mxWsGrid(q){
  if (typeof WS_ACCESS === 'undefined') return `<p class="muted">${esc(t('miNone'))}</p>`;
  const p = S._miPick, has = new Set(modValue(p.file, p.path) || []), needle = mxNorm(q.trim()), d = data() || {}, job = S.job, sub = d.sub || '', lv = jaLevels();
  const wpn = mxWsWeapon(p.path), given = mxWsGiven(), all = Object.keys(WS_ACCESS).sort();
  const jobs = n => WS_ACCESS[n][1], main = n => !!(jobs(n) && jobs(n)[job] != null), bySub = n => !!(jobs(n) && !main(n) && jobs(n)[sub] != null && jobs(n)[sub] <= lv.sub);
  const mine = n => !!(wpn && (given[n] || []).includes(wpn.name));
  // what a tile says under the pointer: the weapons that give it, the jobs that have it
  const about = n => [given[n] ? t('mxWsFrom', {w: given[n].slice(0, 4).join(', ') + (given[n].length > 4 ? '…' : '')}) : '',
    jobs(n) ? t('mxWsJobs', {j: Object.keys(jobs(n)).sort().join(' ')}) : t('mxWsNoJobs')].filter(Boolean).join(' ');
  const tile = (n, dim, kind) => `<button class="mitile act ${dim ? 'other' : ''}" data-mipick="${esc(n)}" ${has.has(n) ? 'disabled' : ''} title="${esc(has.has(n) ? t('miHas') : about(n))}">` +
    `<span>${esc(n)}${kind ? `<small> · ${esc(WS_ACCESS[n][0])}</small>` : ''}${given[n] && !mine(n) ? `<small class="wsw"> · ${esc(given[n][0])}${given[n].length > 1 ? '…' : ''}</small>` : ''}</span></button>`;
  const part = (title, list, dim, kind) => list.length ? `<h4>${esc(title)}</h4><div class="migrid">${list.map(n => tile(n, dim, kind)).join('')}</div>` : '';
  const who = {j: job, s: sub, k: wpn && wpn.kind, w: wpn && wpn.name};
  if (needle) { const found = all.filter(n => mxNorm(n).includes(needle)), ok = n => main(n) || bySub(n) || !jobs(n);
    return found.length ? part(t('mxWsFoundOk', who), found.filter(ok), false, true) + part(t('mxWsFoundOther', who), found.filter(n => !ok(n)), true, true) : `<p class="muted">${esc(t('miNone'))}</p>`; }
  // a weapon is known: its own weaponskills first, then those of its kind by who has them
  const kind = wpn && wpn.kind && all.some(n => WS_ACCESS[n][0] === wpn.kind) ? all.filter(n => WS_ACCESS[n][0] === wpn.kind) : null;
  if (!kind) return part(t('mxWsJob', who), all.filter(main), false, true) + (sub ? part(t('mxWsSub', who), all.filter(bySub), false, true) : '') + `<p class="muted small">${esc(t('mxWsHint'))}</p>`;
  const rest = kind.filter(n => !mine(n));
  return part(t('mxWsGiven', who), kind.filter(mine)) + part(t('mxWsKindJob', who), rest.filter(main)) + (sub ? part(t('mxWsKindSub', who), rest.filter(bySub)) : '') +
    part(t('mxWsKindAny', who), rest.filter(n => !jobs(n))) + part(t('mxWsKindOther', who), rest.filter(n => jobs(n) && !main(n) && !bySub(n)), true) + `<p class="muted small">${esc(t('mxWsHint'))}</p>`;
}
function openWsPick(file, path){
  S._miPick = {file, path, ws: true};
  const wpn = mxWsWeapon(path);
  showDialog('midlg', esc(wpn ? t('mxWsTitleFor', {w: wpn.name}) : t('mxWsTitle')), `<input id="miq" class="tgq" type="search" placeholder="${esc(t('mxWsSearch'))}" autocomplete="off"><div id="mibody" class="mibody">${mxWsGrid('')}</div>`, '');
  const q = document.getElementById('miq'); if (q) q.focus();
}
