// GearSwap Atelier · macro_edit.js: the macro book and the lockstyle changed in the page (Configuration, Macro book &
// lockstyle). The two files of the job (<Char>/<job>/display/<JOB>_MACROBOOK.lua, <JOB>_LOCKSTYLE.lua) come with the
// other settings files, marked part = 'macro' (shared/utils/atelier/atelier_configs.lua); what is changed waits with
// the settings' changes (modules.js modEdits) and goes with their "Save" (modSave: by the game when it is connected,
// else by the page itself, a copy kept first). How the game reads them: shared/utils/macrobook/macrobook_manager.lua
// (default, then solo[subjob]) and shared/utils/lockstyle/lockstyle_manager.lua (default, then by_subjob[subjob]).
// A table changed is written whole, one line a subjob (the comments of its lines go with it); the default alone.
// (loaded after modules.js: see atelier/src/legacy/files.ts)

// the game's bounds: 40 macro books of 10 pages, 200 lockstyle sets
const MACRO_MAX = {book: 40, page: 10, style: 200};
const MACRO_JOBS = ['WAR', 'MNK', 'WHM', 'BLM', 'RDM', 'THF', 'PLD', 'DRK', 'BST', 'BRD', 'RNG', 'SAM', 'NIN', 'DRG', 'SMN', 'BLU', 'COR', 'PUP', 'DNC', 'SCH', 'GEO', 'RUN'];

Object.assign(T.fr, {meNow: 'en cours', meDefault: 'Par défaut', meDefaultTip: 'Pour un sub qui n’a pas sa ligne.', meBook: 'Livre', mePage: 'Page', meStyle: 'Set',
  meAdd: '+ Ajouter un sub…', meDel: 'Retirer cette ligne : ce sub prendra la valeur par défaut.', meSave: 'Enregistrer', meUndo: 'Annuler',
  meDirty: 'Changé, pas encore enregistré. En jeu : au prochain changement de job ou de sub, ou après //gs reload.',
  meBad: '{v} : hors des bornes du jeu ({a} à {b}).', meNoFile: 'Pas de fichier pour ce job : la valeur vient de GearSwap lui-même.',
  meNoText: 'Relis les fichiers (bouton Relire) ou connecte le jeu pour pouvoir changer ces numéros.', meNoTable: 'Ce fichier n’a pas de liste par sub : seule la valeur par défaut se change ici.',
  meBroken: 'Ce fichier a un caractère illisible : la page ne l’écrit pas.'});
Object.assign(T.en, {meNow: 'in force', meDefault: 'Default', meDefaultTip: 'For a subjob without its own line.', meBook: 'Book', mePage: 'Page', meStyle: 'Set',
  meAdd: '+ Add a subjob…', meDel: 'Remove this line: this subjob takes the default.', meSave: 'Save', meUndo: 'Undo',
  meDirty: 'Changed, not saved yet. In game: at the next job or subjob change, or after //gs reload.',
  meBad: '{v}: out of the game’s bounds ({a} to {b}).', meNoFile: 'No file for this job: the value comes from GearSwap itself.',
  meNoText: 'Read the files again (Reload button) or connect the game to change these numbers.', meNoTable: 'This file has no list by subjob: only the default changes here.',
  meBroken: 'This file has an unreadable character: the page does not write it.'});

// The job's two files among the settings files: {book, style}, each {f, paths: [default, table]} or null
function macroFiles(d){
  const all = modAllFiles(d).filter(f => f.part === 'macro'), find = re => all.find(f => re.test(f.file)) || null;
  return {book: find(/_MACROBOOK\.lua$/), style: find(/_LOCKSTYLE\.lua$/)};
}
const MACRO_PATHS = {book: ['default', 'solo'], style: ['default', 'by_subjob']};

// A file's numbers as the page shows them: the file's, with the changes waiting. {def, subs: {sub: value}, table: has
// its list by subjob, dirty} (own: the file's alone). A macro value is {book, page}, a lockstyle one a number
function macroModel(kind, f, own){
  const [dp, tp] = MACRO_PATHS[kind], p = modParsed(f), ed = own ? {} : modEdits(f.file);
  const val = x => !x ? null : kind === 'style' ? (x.kind === 'num' ? x.value : null)
    : x.kind === 'map' ? {book: (x.fields.find(c => c.key === 'book') || {}).value, page: (x.fields.find(c => c.key === 'page') || {}).value} : null;
  const tb = p.byPath[tp], subs = {};
  if (tb && tb.kind === 'map') for (const c of tb.fields) { const v = val(c); if (c.key != null && v != null) subs[c.key] = v; }
  return {def: ed[dp] ? ed[dp].v : val(p.byPath[dp]), subs: ed[tp] ? ed[tp].v : subs, table: !!(tb && (tb.kind === 'map' || (tb.kind === 'list' && !tb.fields.length))), dirty: !!(ed[dp] || ed[tp]),
    file: f.file, canWrite: modCanWrite(f)};
}

// a value as the file's Lua: {book = 11, page = 1} or 6; a table one line a subjob, with the file's own line ends
const macroLua = (kind, v) => kind === 'style' ? String(v) : `{book = ${v.book}, page = ${v.page}}`;
function macroTableLua(kind, subs, nl){
  const keys = Object.keys(subs);
  return keys.length ? '{' + nl + keys.map(k => `    [${luaQuote(k, "'")}] = ${macroLua(kind, subs[k])},`).join(nl) + nl + '}' : '{}';
}
const macroShow = (kind, v) => v == null ? '—' : kind === 'style' ? String(v) : `${v.book}·${v.page}`;
const macroShowAll = (kind, subs) => Object.keys(subs).map(k => '/' + k + ' ' + macroShow(kind, subs[k])).join(' ') || '—';

// Keep a new default or table aside (back to the file's own: nothing kept). `table: true` lets the page's own writer
// accept lines that went away (modules.js modWriteOne)
function macroStage(kind, part, v){
  const f = macroFiles(data())[kind]; if (!f) return;
  const path = MACRO_PATHS[kind][part === 'def' ? 0 : 1], x = modParsed(f).byPath[path], ed = modEdits(f.file);
  if (!x) return;
  const fileModel = macroModel(kind, f, true);   // the file's own, without the changes waiting
  const was = part === 'def' ? fileModel.def : fileModel.subs;
  if (JSON.stringify(v) === JSON.stringify(was)) delete ed[path];
  else {
    const nl = f.text.includes('\r\n') ? '\r\n' : '\n';
    ed[path] = part === 'def'
      ? {v, src: macroLua(kind, v), before: macroShow(kind, was), after: macroShow(kind, v)}
      : {v, src: macroTableLua(kind, v, nl), before: macroShowAll(kind, was), after: macroShowAll(kind, v), table: true};
  }
  S.toast = ''; render();
}

// a number typed: inside the game's bounds, else the reason
function macroNumber(input, what){
  const n = Number(input.value), max = MACRO_MAX[what];
  if (!Number.isInteger(n) || n < 1 || n > max) { S.toast = t('meBad', {v: input.value, a: 1, b: max}); render(); return null; }
  return n;
}

// data-mfield="book|def|book", "book|RDM|page", "style|def", "style|RDM"; data-madd="book" (a select of subjobs);
// data-mdel="book|RDM"; data-mundo
document.addEventListener('change', e => {
  const inp = e.target.closest('[data-mfield]'), add = e.target.closest('select[data-madd]');
  if (!inp && !add) return;
  const d = data(), kind = (inp || add).dataset.mfield ? inp.dataset.mfield.split('|')[0] : add.dataset.madd, f = macroFiles(d)[kind];
  if (!f) return;
  const m = macroModel(kind, f);
  if (add) {
    const sub = add.value; if (!sub || m.subs[sub] != null) return;
    // a file without a literal default: the new subjob starts at the first book / set (never an undefined in the file)
    const def = m.def || (kind === 'style' ? 1 : {book: 1, page: 1});
    macroStage(kind, 'subs', Object.assign({}, m.subs, {[sub]: kind === 'style' ? def : Object.assign({}, def)})); return;
  }
  const [, who, what] = inp.dataset.mfield.split('|'), n = macroNumber(inp, kind === 'style' ? 'style' : what);
  if (n == null) return;
  if (who === 'def') macroStage(kind, 'def', kind === 'style' ? n : Object.assign({}, m.def, {[what]: n}));
  else macroStage(kind, 'subs', Object.assign({}, m.subs, {[who]: kind === 'style' ? n : Object.assign({}, m.subs[who], {[what]: n})}));
});
// the part shown in the frame (Macro book or Lockstyle), kept
document.addEventListener('click', e => { const b = e.target.closest('[data-macropart]'); if (b) { S.macroPart = b.dataset.macropart; save(); render(); } });
Object.assign(T.fr, {cfgBookSub: 'Le livre et la page de macros qui s’ouvrent selon ton sub.', cfgStyleSub: 'Le set de lockstyle mis selon ton sub.',
  cfgBookWhat: 'Quand tu es {j} avec le sub {s}, GearSwap ouvre ce livre et cette page de macros. Un sub sans sa propre tuile prend « Par défaut ».',
  cfgBookEx: 'Livre 11, page 1 avec /RDM, page 2 avec /SCH : en changeant de sub, la bonne page s’ouvre toute seule.',
  cfgStyleWhat: 'Quand tu es {j} avec le sub {s}, GearSwap met ce set de lockstyle (l’apparence de ton équipement). Un sub sans sa tuile prend « Par défaut ».',
  cfgStyleEx: 'Set 6 : l’apparence enregistrée dans le set de lockstyle n° 6 du jeu.', cfgWhenSub: 'au prochain changement de job ou de sub'});
Object.assign(T.en, {cfgBookSub: 'The macro book and page opened by your subjob.', cfgStyleSub: 'The lockstyle set worn by your subjob.',
  cfgBookWhat: 'On {j} with the {s} subjob, GearSwap opens this macro book and page. A subjob without its own tile takes “Default”.',
  cfgBookEx: 'Book 11, page 1 with /RDM, page 2 with /SCH: changing subjob opens the right page by itself.',
  cfgStyleWhat: 'On {j} with the {s} subjob, GearSwap wears this lockstyle set (your gear’s look). A subjob without its tile takes “Default”.',
  cfgStyleEx: 'Set 6: the look saved in the game’s lockstyle set 6.', cfgWhenSub: 'at the next job or subjob change'});
document.addEventListener('click', e => {
  // data-mstep="book|RDM|page|1" or "style|RDM|-1": a number one step up or down, inside the game's bounds
  const step = e.target.closest('[data-mstep]');
  if (step) { const parts = step.dataset.mstep.split('|'), by = parts.pop(), [kind, who, what] = parts, f = macroFiles(data())[kind]; if (!f) return;
    const m = macroModel(kind, f), cur = who === 'def' ? m.def : m.subs[who], max = MACRO_MAX[kind === 'style' ? 'style' : what];
    if (cur == null) return;
    const n = Math.min(max, Math.max(1, (kind === 'style' ? cur : cur[what]) + Number(by)));
    const v = kind === 'style' ? n : Object.assign({}, cur, {[what]: n});
    if (who === 'def') macroStage(kind, 'def', v); else macroStage(kind, 'subs', Object.assign({}, m.subs, {[who]: v}));
    return; }
  const del = e.target.closest('[data-mdel]'), undo = e.target.closest('[data-mundo]');
  if (del) { const [kind, sub] = del.dataset.mdel.split('|'), f = macroFiles(data())[kind]; if (!f) return;
    const subs = Object.assign({}, macroModel(kind, f).subs); delete subs[sub]; macroStage(kind, 'subs', subs); return; }
  if (undo) { const fs = macroFiles(data()); for (const f of [fs.book, fs.style]) if (f) delete ((S._modEdits || {})[S.char] || {})[f.file];
    S.toast = ''; render(); }
});
