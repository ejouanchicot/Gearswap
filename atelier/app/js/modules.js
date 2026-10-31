// GearSwap Atelier · modules.js: the "Modules" part of the Configuration tab: every settings file of the character
// (<Char>/_common/<theme>/) and of the job shown (<Char>/<job>/<theme>/), read from its text (export `configs`:
// shared/utils/atelier/atelier_configs.lua). A file is read the way a player reads it: each setting with the comment
// written over it, so the page explains what the file explains, in the file's own words.
// A setting changed here waits (S._modEdits) until "Save": the page then puts the new value in the file's text, at the
// place the old one was, and the game writes the file (a copy first, the change in the history: /config_write). With
// the game not connected (or an example uncommented that the game's door refuses: a statement), the page writes the
// file itself in the data folder, a copy kept in <Char>/atelier/backups/ (live.js writeCharFile; since 2026-10-29).
// A setting the file only gives as an example in a comment is offered as "not set" with "Add" (modExamples): the
// example is uncommented in the text kept aside (S._modAdds), then set like the others.
// (loaded after layout2.js: see atelier/src/legacy/files.ts)

Object.assign(T.fr, {sectionsModules: 'Réglages', ttTab_modules: 'Les réglages de chaque module de GearSwap (Auto Medicine, Refill, Dual-box, HUD…) : ceux du perso et ceux de ce job.',
  modSave: 'Enregistrer',
  modSaved: 'Écrit dans {f}. Une copie est gardée : l’historique (en haut) peut annuler. GearSwap se recharge.',
  modSavedLocal: 'Écrit dans {f} (une copie de l’ancien est dans atelier/backups). En jeu : //gs reload ou change de job.',
  modSavedDownload: '{f} téléchargé : mets-le à la place de l’ancien dans {p}, puis //gs reload en jeu.',
  modInFileLine: 'Écrit en code : à changer dans le fichier {f}, ligne {l}',
  modNone: 'Cet export ne contient pas encore les fichiers de réglages : clique « Relire » en haut de la page, ou charge ce job en jeu.',
  modAuto: 'Auto (lu en jeu)', modForce: 'ou forcer…', modAdd: '+ ajouter', modDel: 'Retirer {v}',
  modBad: 'Valeur refusée : {v}', modOn: 'Allumé', modOff: 'Éteint',
  modErr_nofile: '{f} n’est pas dans l’export affiché (autre job ou sub ?) : rien n’a été écrit, tes changements attendent.', modErr_changed: 'Le fichier a changé depuis la lecture : clique « Relire », puis recommence.', modErr_syntax: 'Le fichier ne se lirait plus avec cette valeur : rien n’a été écrit.', modErr_code: 'Le jeu n’accepte de changer que des valeurs (texte, nombre, oui/non, liste) : ce changement touchait au code du fichier, rien n’a été écrit.',
  modErr_file: 'Ce fichier ne peut pas être écrit depuis la page.', modErr_live: 'Le jeu n’a pas répondu : rien n’a été écrit.', modErr_other: 'Rien n’a été écrit ({e}).',
  histKind_config: 'réglage',
  ttModRead: 'Ce fichier ne se lit pas correctement (un caractère illisible) : il se change à la main.',
  ttModTurnOn: 'Clique pour l’allumer. Rien n’est écrit avant « Enregistrer ».', ttModTurnOff: 'Clique pour l’éteindre. Rien n’est écrit avant « Enregistrer ».',
  ttModChoose: 'Choisir « {v} ». Rien n’est écrit avant « Enregistrer ».', ttModChosen: '« {v} » est le choix actuel.',
  ttModAuto: 'Laisser GearSwap lire cette valeur en jeu : rien à tenir à jour toi-même.', ttModForce: 'Pour imposer une valeur à la place de celle lue en jeu : tape-la, puis Entrée. Vide : retour à Auto.',
  ttModNum: 'Tape le nouveau nombre, puis Entrée.', ttModText: 'Tape la nouvelle valeur, puis Entrée. Les noms s’écrivent comme dans le jeu.',
  ttModAdd: 'Tape un nom comme dans le jeu, puis Entrée : il s’ajoute à la fin de la liste.'});
Object.assign(T.en, {sectionsModules: 'Settings', ttTab_modules: 'The settings of each GearSwap module (Auto Medicine, Refill, Dual-box, HUD…): the character’s and this job’s.',
  modSave: 'Save',
  modSaved: 'Written in {f}. A copy is kept: the history (top bar) can undo it. GearSwap reloads.',
  modSavedLocal: 'Written in {f} (a copy of the old one is in atelier/backups). In game: //gs reload or change job.',
  modSavedDownload: '{f} downloaded: put it in place of the old one in {p}, then //gs reload in game.',
  modInFileLine: 'Written as code: changed in the file {f}, line {l}',
  modNone: 'This export does not hold the settings files yet: click "Reread" at the top of the page, or load this job in game.',
  modAuto: 'Auto (read in game)', modForce: 'or force…', modAdd: '+ add', modDel: 'Remove {v}',
  modBad: 'Value refused: {v}', modOn: 'On', modOff: 'Off',
  modErr_nofile: '{f} is not in the export shown (another job or subjob?): nothing was written, your changes wait.', modErr_changed: 'The file changed since it was read: click "Reread", then do it again.', modErr_syntax: 'The file would no longer read with this value: nothing was written.', modErr_code: 'The game only accepts values being changed (text, number, yes/no, list): this change touched the file’s code, nothing was written.',
  modErr_file: 'This file cannot be written from the page.', modErr_live: 'The game did not answer: nothing was written.', modErr_other: 'Nothing was written ({e}).',
  histKind_config: 'setting',
  ttModRead: 'This file does not read correctly (a broken character): it is changed by hand.',
  ttModTurnOn: 'Click to turn it on. Nothing is written before "Save".', ttModTurnOff: 'Click to turn it off. Nothing is written before "Save".',
  ttModChoose: 'Choose "{v}". Nothing is written before "Save".', ttModChosen: '"{v}" is the current choice.',
  ttModAuto: 'Let GearSwap read this value in game: nothing to keep up to date yourself.', ttModForce: 'To force a value in place of the one read in game: type it, then Enter. Empty: back to Auto.',
  ttModNum: 'Type the new number, then Enter.', ttModText: 'Type the new value, then Enter. Names are written as in the game.',
  ttModAdd: 'Type a name as in the game, then Enter: it is added at the end of the list.'});

/* ---- reading a Lua settings file: its tokens, then its values with the comments around them ---- */
// A token: {t: 'com'|'str'|'num'|'name'|'op', v, a, b (its place in the text), nl (line breaks before it)}
function luaTokens(src){
  const out = [], n = src.length, at = (re, i) => { re.lastIndex = i; return re.exec(src); };
  const LONG = /\[(=*)\[/y, NUM = /0[xX][0-9a-fA-F]+|\d+\.?\d*(?:[eE][+-]?\d+)?|\.\d+(?:[eE][+-]?\d+)?/y, NAME = /[A-Za-z_][A-Za-z0-9_]*/y, OP = /\.\.\.|\.\.|==|~=|<=|>=|[^]/y;
  let i = 0, nl = 0;
  const push = (t, v, a, b, more) => { out.push(Object.assign({t, v, a, b, nl}, more)); nl = 0; i = b; };
  const long = (from, m) => { const end = src.indexOf(']' + m[1] + ']', from); return {text: src.slice(from + m[0].length, end < 0 ? n : end), b: end < 0 ? n : end + m[1].length + 2}; };
  while (i < n) {
    const c = src[i];
    if (c === '\n') { nl++; i++; continue; }
    if (c === ' ' || c === '\t' || c === '\r') { i++; continue; }
    if (c === '-' && src[i + 1] === '-') {
      const m = at(LONG, i + 2);
      if (m) { const l = long(i + 2, m); push('com', l.text, i, l.b); continue; }
      let b = src.indexOf('\n', i); if (b < 0) b = n;
      push('com', src.slice(i, b).replace(/\r$/, '').replace(/^-+ ?/, ''), i, b); continue;
    }
    if (c === '"' || c === "'") {
      let j = i + 1, v = '';
      while (j < n && src[j] !== c && src[j] !== '\n') { if (src[j] === '\\') { v += ({n: '\n', t: '\t'})[src[j + 1]] || src[j + 1] || ''; j += 2; } else v += src[j++]; }
      push('str', v, i, j + 1, {q: c}); continue;
    }
    let m = c === '[' && at(LONG, i);
    if (m) { const l = long(i, m); push('str', l.text, i, l.b, {q: "'"}); continue; }
    if ((m = at(NUM, i))) { push('num', Number(m[0]), i, i + m[0].length); continue; }
    if ((m = at(NAME, i))) { push('name', m[0], i, i + m[0].length); continue; }
    m = at(OP, i); push('op', m[0], i, i + m[0].length);
  }
  return out;
}
const LUA_OPEN = {function: 1, do: 1, if: 1, repeat: 1}, LUA_CLOSE = {end: 1, until: 1};
const luaIs = (x, t, v) => !!x && x.t === t && (v === undefined || x.v === v);
// The token after the block opened at i (function, if, for, while, do, repeat ... end)
function luaBlockEnd(tk, i){
  for (let depth = 0; i < tk.length; i++) { const x = tk[i]; if (x.t !== 'name') continue;
    if (LUA_OPEN[x.v]) depth++; else if (LUA_CLOSE[x.v] && --depth <= 0) return i + 1; }
  return tk.length;
}
// What is not a plain value (a call, a name, a sum): its text as it is, up to the next comma, closing brace or, in a
// statement (line: true), the next line
function luaCode(tk, start, line){
  let k = start, depth = 0;
  for (; k < tk.length; k++) { const y = tk[k];
    if (line && !depth && k > start && y.nl > 0) break;
    if (y.t === 'name' && y.v === 'function') { k = luaBlockEnd(tk, k) - 1; continue; }
    if (y.t !== 'op') continue;
    if (y.v === '(' || y.v === '{' || y.v === '[') depth++;
    else if (y.v === ')' || y.v === '}' || y.v === ']') { if (!depth) break; depth--; }
    else if ((y.v === ',' || y.v === ';') && !depth) break; }
  let last = k - 1; while (last > start && tk[last].t === 'com') last--;
  return last < start || !tk[start] ? null : {kind: 'code', a: tk[start].a, b: tk[last].b, next: last + 1};
}
// A value at token i: {kind: 'str'|'num'|'bool'|'list'|'map'|'code', value | fields, a, b, next}
function luaValue(tk, i){
  const x = tk[i]; if (!x) return null;
  if (x.t === 'str') return {kind: 'str', value: x.v, q: x.q, a: x.a, b: x.b, next: i + 1};
  if (x.t === 'num') return {kind: 'num', value: x.v, a: x.a, b: x.b, next: i + 1};
  if (luaIs(x, 'op', '-') && luaIs(tk[i + 1], 'num')) return {kind: 'num', value: -tk[i + 1].v, a: x.a, b: tk[i + 1].b, next: i + 2};
  if (x.t === 'name' && (x.v === 'true' || x.v === 'false')) return {kind: 'bool', value: x.v === 'true', a: x.a, b: x.b, next: i + 1};
  if (luaIs(x, 'op', '{')) return luaTable(tk, i);
  return null;
}
// The comment on the same line after a value (and its comma): the field's note
function luaAfter(tk, j, f){
  if (luaIs(tk[j], 'op', ',') || luaIs(tk[j], 'op', ';')) j++;
  if (luaIs(tk[j], 'com') && tk[j].nl === 0) { f.note = tk[j].v; j++; }
  return j;
}
// A table constructor: each field with the comment lines right over it (doc) and the one at its end (note)
function luaTable(tk, i){
  const fields = []; let j = i + 1, doc = [], pos = 0;
  const done = v => !tk[v.next] || tk[v.next].t === 'com' || (tk[v.next].t === 'op' && ',;}'.includes(tk[v.next].v));
  for (;;) {
    const x = tk[j]; if (!x) return null;
    if (x.t === 'com') { if (x.nl >= 2) doc = []; doc.push(x.v); j++; continue; }
    if (luaIs(x, 'op', '}')) break;
    const f = {doc: x.nl >= 2 ? [] : doc}; doc = [];
    if (x.t === 'name' && luaIs(tk[j + 1], 'op', '=')) { f.key = x.v; j += 2; }
    else if (luaIs(x, 'op', '[') && tk[j + 1] && (tk[j + 1].t === 'str' || tk[j + 1].t === 'num') && luaIs(tk[j + 2], 'op', ']') && luaIs(tk[j + 3], 'op', '=')) { f.key = String(tk[j + 1].v); j += 4; }
    else f.index = ++pos;
    let v = luaValue(tk, j);
    if (!v || !done(v)) v = luaCode(tk, j, false);
    if (!v) return null;
    j = luaAfter(tk, v.next, Object.assign(f, v, {next: undefined}));
    fields.push(f);
  }
  const plain = f => f.kind === 'str' || f.kind === 'num' || f.kind === 'bool';
  // 'rows': a table of lines, each a few named values (module_rows.js)
  const kind = fields.every(f => f.index && plain(f)) ? 'list' : mrIsRows(fields) ? 'rows' : fields.every(f => f.key != null) ? 'map' : 'code';
  return {kind, fields, value: kind === 'list' ? fields.map(f => f.value) : kind === 'rows' ? mrValue(fields) : undefined, a: tk[i].a, b: tk[j].b, next: j + 1};
}
// A file's settings: the fields of the table it returns (`return {`, `local X = {`), and the `X.key = value` lines
function luaSettings(src){
  const tk = luaTokens(src), fields = [], roots = {}; let i = 0, doc = [];
  while (i < tk.length) {
    const x = tk[i];
    if (x.t === 'com') { if (x.nl >= 2) doc = []; doc.push(x.v); i++; continue; }
    const mine = x.nl >= 2 ? [] : doc; doc = [];
    if (x.t !== 'name') { i++; continue; }
    if (x.v === 'local' && luaIs(tk[i + 1], 'name', 'function')) { i = luaBlockEnd(tk, i + 1); continue; }
    if (LUA_OPEN[x.v] || x.v === 'for' || x.v === 'while') { i = luaBlockEnd(tk, i); continue; }
    const j = x.v === 'local' ? i + 1 : i, open = x.v === 'return' ? i + 1 : luaIs(tk[j], 'name') && luaIs(tk[j + 1], 'op', '=') ? j + 2 : -1;
    if (open > 0 && luaIs(tk[open], 'op', '{')) {
      const tb = luaTable(tk, open);
      if (!tb) { i++; continue; }
      if (x.v !== 'return') roots[tk[j].v] = true;
      if (tb.kind === 'map' && (x.v === 'return' || x.v === 'local')) fields.push(...tb.fields);
      i = tb.next; continue;
    }
    if (roots[x.v] && luaIs(tk[i + 1], 'op', '.')) {
      const path = []; let k = i + 1;
      while (luaIs(tk[k], 'op', '.') && luaIs(tk[k + 1], 'name')) { path.push(tk[k + 1].v); k += 2; }
      if (luaIs(tk[k], 'op', '=') && !luaIs(tk[k + 1], 'name', 'function')) {
        let v = luaValue(tk, k + 1);
        if (!v || (tk[v.next] && tk[v.next].t !== 'com' && tk[v.next].nl === 0)) v = luaCode(tk, k + 1, true);
        if (v) { const f = Object.assign({doc: mine, key: path.join('.')}, v, {next: undefined}); i = luaAfter(tk, v.next, f); fields.push(f); continue; }
      }
    }
    i++;
  }
  return fields;
}
// The file's own header: its title (the first words) and what it says of itself, up to the @file line
function luaHeader(src){
  const lines = []; let m; const re = /---?(.*)\r?\n/y;
  while ((m = re.exec(src))) lines.push(m[1].replace(/^ {0,3}/, ''));
  const rule = l => /^[\s═─=\-*#]*$/.test(l), text = lines.filter(l => !/^[═─=\-]{6,}/.test(l.trim()));
  const first = text.findIndex(l => !rule(l)), stop = text.findIndex(l => /^\s*@\w+/.test(l));
  const body = first < 0 ? [] : text.slice(first + 1, stop < 0 ? text.length : stop);
  while (body.length && rule(body[0])) body.shift();
  while (body.length && rule(body[body.length - 1])) body.pop();
  const [name, ...rest] = first < 0 ? [''] : text[first].trim().split(/\s+[-–—]\s+/);
  return {name, tag: rest.join(' - '), about: body.join('\n')};
}

/* ---- the examples a file gives in comments: a setting it can hold, offered as "not set" ---- */
// A commented assignment whose text, uncommented, is a plain value: inside the table the file returns (`-- key = v,`,
// one line or a block whose braces close), or a statement on a table the file declares (`-- M.extra = {`...`-- }`).
// The page uncomments it on "Add" (a statement: written by the page itself, the game's door refuses one).
// Each: {id (its first character), key, stmt, a, b (the lines), code (uncommented)}. Read once per text (the same
// file is asked again on each change and save): the cache is emptied past 50 texts
const MOD_EXAMPLES = new Map();
function modExamples(text){
  if (MOD_EXAMPLES.has(text)) return MOD_EXAMPLES.get(text);
  if (MOD_EXAMPLES.size > 50) MOD_EXAMPLES.clear();
  const out = modExamplesOf(text);
  MOD_EXAMPLES.set(text, out);
  return out;
}
function modExamplesOf(text){
  const out = [], lines = [], re = /[^\n]*(?:\n|$)/g; let m, at = 0;
  while ((m = re.exec(text)) && m[0] !== '') { lines.push({a: at, s: m[0]}); at += m[0].length; }
  const tk = luaTokens(text);
  // the returned table's place, and the tables the file declares (local M = {})
  let table = null; const roots = {};
  for (let i = 0; i < tk.length; i++) {
    if (luaIs(tk[i], 'name', 'return') && luaIs(tk[i + 1], 'op', '{')) { const tb = luaTable(tk, i + 1); if (tb) table = {a: tb.a, b: tb.b}; }
    if (luaIs(tk[i], 'name', 'local') && luaIs(tk[i + 1], 'name') && luaIs(tk[i + 2], 'op', '=') && luaIs(tk[i + 3], 'op', '{')) roots[tk[i + 1].v] = tk[i].a;
  }
  const have = new Set(luaSettings(text).map(f => f.key));
  const uncomment = s => s.replace(/^(\s*)--[ ]?/, '$1');
  const braces = s => (s.replace(/(["'])(?:\\.|(?!\1).)*\1/g, '').match(/[{}]/g) || []).reduce((n, c) => n + (c === '{' ? 1 : -1), 0);
  for (let i = 0; i < lines.length; i++) {
    const c = lines[i].s.match(/^\s*--[ ]?(\s*)([A-Za-z_]\w*(?:\.[A-Za-z_]\w*)?)\s*=\s*(.*?)\s*$/);
    if (!c || /^-/.test(c[3])) continue;
    const key = c[2], dot = key.indexOf('.'), stmt = dot > 0;
    let j = i, depth = braces(uncomment(lines[i].s)), ok = true;
    while (depth > 0 && ok) { j++; if (j >= lines.length || !/^\s*--/.test(lines[j].s)) ok = false; else depth += braces(uncomment(lines[j].s)); }
    if (!ok || depth < 0) continue;
    const a = lines[i].a, b = lines[j].a + lines[j].s.length, code = lines.slice(i, j + 1).map(l => uncomment(l.s)).join('');
    const name = stmt ? key.slice(dot + 1) : key;
    if (have.has(name) || (stmt ? !(key.slice(0, dot) in roots) || a < roots[key.slice(0, dot)] : !table || a < table.a || b > table.b)) continue;
    // its text, uncommented, must read as a value of the kind the page sets
    const probe = luaSettings(stmt ? 'local ' + key.slice(0, dot) + ' = {}\n' + code : 'return {\n' + code + '\n}').find(f => f.key === name);
    if (!probe || probe.kind === 'code') continue;
    out.push({id: String(a), key: name, stmt, a, b, code});
    i = j;
  }
  return out;
}
// The examples added and not saved yet: {file: {id: true}}
const modAdds = () => ((S._modAdds = S._modAdds || {})[S.char] = S._modAdds[S.char] || {});
// A file with its examples added uncommented (the same object while nothing changes): `orig` is the export's
const MOD_DRAFT = new WeakMap();
function modDrafted(f){
  const ids = Object.keys(modAdds()[f.file] || {});
  if (!ids.length) return f;
  const key = ids.sort().join(',') + '|' + f.text.length + '|' + (f.hash || ''), had = MOD_DRAFT.get(f);
  if (had && had.key === key) return had.copy;
  let text = f.text;
  modExamples(f.text).filter(e => ids.includes(e.id)).sort((x, y) => y.a - x.a).forEach(e => { text = text.slice(0, e.a) + e.code + text.slice(e.b); });
  const copy = Object.assign({}, f, {text, orig: f});
  MOD_DRAFT.set(f, {key, copy});
  return copy;
}

/* ---- the part of the tab ---- */
const MOD_CACHE = new Map();
// A file parsed once per text: {head, fields, byPath}
function modParsed(f){
  const k = f.file + '|' + (f.hash || '') + '|' + f.text.length + (f.orig ? '|draft' : '');
  if (!MOD_CACHE.has(k)) {
    let fields = []; try { fields = luaSettings(f.text); } catch (e) { fields = []; }
    const byPath = {}, walk = (list, pre) => list.forEach(x => { x.path = pre + (x.key != null ? x.key : '[' + x.index + ']'); byPath[x.path] = x; if (x.kind === 'map') walk(x.fields, x.path + '.'); });
    walk(fields, '');
    MOD_CACHE.set(k, {head: luaHeader(f.text), fields, byPath});
  }
  return MOD_CACHE.get(k);
}
// the files as the page shows them: with the examples added (modDrafted); the measuring tools only on demand; the macro
// book and lockstyle files are the Macro book part's (macro_edit.js)
const MOD_TOOL_FILE = /\/ENHTEST_[A-Z_]+\.lua$/;
const modAllFiles = d => ((d && d.configs) || []).map(modDrafted);
// (nothing sets S.modTools since the Settings' redesign of 2026-10-30: the ENHTEST files stay hidden, they hold no
// value to set — a function returning the test plans, and sets written by a script)
const modFiles = d => modAllFiles(d).filter(f => f.part !== 'macro' && (S.modTools || !MOD_TOOL_FILE.test(f.file)));
const modEdits = file => (((S._modEdits = S._modEdits || {})[S.char] = S._modEdits[S.char] || {})[file] = S._modEdits[S.char][file] || {});
const modEditable = x => x.kind === 'bool' || x.kind === 'num' || x.kind === 'str' || x.kind === 'list' || x.kind === 'rows';
// A setting of a file of the export shown, by its path
const modField = (file, path) => { const f = modFiles(data()).find(x => x.file === file); return rfStagedSub(file, path) || (f && modParsed(f).byPath[path]); };
// The catalog's entry for a setting (its columns, its kind of list), when it has one
function mcItem(file, path){
  for (const fam of MOD_CATALOG) for (const r of mcRows(data(), fam)) if (r.f.file === file && r.x.path === path) return r.it;
  return {};
}
// the game writes it when connected, else the page itself (live.js writeCharFile); never a file read with a broken character
const modCanWrite = f => !f.text.includes('�');
const luaQuote = (s, q) => q + String(s).replace(/\\/g, '\\\\').split(q).join('\\' + q).replace(/\n/g, '\\n') + q;
// A value as Lua text, written the way the file wrote the old one (its quotes)
function modSource(x, v){
  if (typeof v === 'boolean') return v ? 'true' : 'false';
  if (typeof v === 'number') return String(v);
  if (typeof v === 'string') return luaQuote(v, x.q || "'");
  const q = (x.fields.find(i => i.kind === 'str') || {}).q || "'";
  return '{' + v.map(i => typeof i === 'string' ? luaQuote(i, q) : String(i)).join(', ') + '}';
}
const modShow = v => Array.isArray(v) ? v.join(', ') : typeof v === 'boolean' ? (v ? 'true' : 'false') : String(v);
// A new value for a setting: kept aside until "Save" (back to the file's own value: nothing kept)
function modStage(file, path, v){
  const sub = rfStagedSub(file, path); if (sub) { const subs = refillSubs(file); subs[sub.sub] = v; refillStageSubs(file, subs); return; }
  const f = modFiles(data()).find(x => x.file === file), x = f && modParsed(f).byPath[path], edits = modEdits(file);
  if (!x || !modEditable(x)) return;
  const rows = x.kind === 'rows';
  if (JSON.stringify(v) === JSON.stringify(x.value)) delete edits[path];
  else edits[path] = {v, src: rows ? mrSource(f.text, x, v) : modSource(x, v), before: rows ? mrShow(x.value) : modShow(x.value), after: rows ? mrShow(v) : modShow(v)};
  S.toast = ''; render();
}
// What the player typed, as the setting's kind (null: refused)
function modTyped(x, text){
  const s = text.trim(), num = s !== '' && !isNaN(Number(s));
  // a setting the game can fill ('auto' in its comment): a number or true / false typed forces a value of that kind
  if (modAuto(x)) return s === '' || s.toLowerCase() === 'auto' ? 'auto' : num ? Number(s) : s === 'true' || s === 'false' ? s === 'true' : s;
  if (x.kind === 'num') return num ? Number(s) : null;
  if (x.kind === 'str') return text;
  const nums = x.fields.length > 0 && x.fields.every(i => i.kind === 'num'), items = text.split(',').map(s => s.trim()).filter(Boolean);
  return nums ? (items.every(s => !isNaN(Number(s))) ? items.map(Number) : null) : items;
}
// The comment over a setting, as running text: the file breaks its lines at 80 columns, the page has its own width.
// An indented line (an example, a list of values) keeps its line
function modDoc(lines){
  const out = [];
  for (const l of lines || []) {
    if (/^[\s═─=\-]*$/.test(l)) continue;
    const own = /^\s{2,}/.test(l), last = out[out.length - 1];
    if (last && !own && !last.own) last.text += ' ' + l.trim(); else out.push({own, text: l.trim()});
  }
  return out.map(o => o.text).join('\n');
}
const modAllDoc = x => (x.doc || []).join(' ') + ' ' + (x.note || '');
// A setting the game can fill by itself: its comment offers 'auto'
const modAuto = x => (x.kind === 'str' || x.kind === 'num' || x.kind === 'bool') && /'auto'/.test(modAllDoc(x));
// The values a text setting may take, when its comment names them in quotes ('On' or 'Off'; 'mine', 'all', 'usable')
// and the value in the file is one of them: buttons, nothing to type
function modOptions(x){
  if (x.kind !== 'str' || modAuto(x)) return null;
  const list = [...new Set([...modAllDoc(x).matchAll(/'([^']{1,24})'/g)].map(m => m[1]))];
  return list.length >= 2 && list.length <= 6 && list.includes(x.value) ? list : null;
}
// A setting's name as words: auto_cure_silence -> Auto cure silence (the file's own name stays beside it, small)
const modName = x => x.key == null ? '#' + x.index : /[_a-z]/.test(x.key) && !/\s/.test(x.key) ? x.key.replace(/[_.]+/g, ' ').replace(/^./, c => c.toUpperCase()) : x.key;
// What a file is, for the player: its French name and purpose (module_catalog.js MOD_FILE_FR), else the file's own header
function modFileInfo(f){
  const p = modParsed(f), base = f.file.split('/').pop(), job = (base.match(/^([A-Z]{3})_/) || [])[1] || '';
  const fr = S.lang === 'en' ? null : MOD_FILE_FR[base] || (job && MOD_FILE_FR[base.replace(/^[A-Z]{3}_/, '{JOB}_')]);
  return fr ? {name: fr[0].split('{JOB}').join(job), what: fr[1].split('{JOB}').join(job)} : {name: p.head.name || base, what: p.head.tag || ''};
}
// The settings of a file that the Options view explains: path -> its row there
function modKnown(d, f){
  const known = {};
  for (const fam of MOD_CATALOG) for (const r of mcRows(d, fam)) if (r.f === f) known[r.x.path] = r;
  return known;
}
// A group's name (module_catalog.js MOD_GROUPS), and the files of the advanced view ranged in the same groups
const modGroupName = g => (S.lang === 'en' ? g.en : g.fr).split('{JOB}').join(S.job || '');
const MOD_FILE_JOB_THEMED = ['{JOB}_HUD.lua', '{JOB}_REFILL.lua'];
function modFileGroup(f){
  const base = f.file.split('/').pop(), pat = base.replace(/^[A-Z]{3}_/, '{JOB}_');
  // a job's own file goes to "This job", unless it has a subject of its own (its HUD order, its refill list)
  if (f.scope === 'job') return (MOD_FILE_JOB_THEMED.includes(pat) && MOD_FILE_GROUP[pat]) || 'job';
  return MOD_FILE_GROUP[base] || MOD_FILE_GROUP[pat] || 'tools';
}
/* ---- the simple view: the catalog's options (module_catalog.js), by family, in the player's words ---- */
// (the Modules part is drawn by the Svelte application: atelier/src/screens/config/modules.ts reads what follows)
// The options of one family that this character's files hold, each with its file, its setting and its texts
function mcRows(d, fam){
  const files = modFiles(d), job = S.job || '', sub = d.sub || '', lang = S.lang === 'en' ? 'en' : 'fr', rows = [], seen = new Set();
  const fill = s => String(s).split('{JOB}').join(job).split('{SUB}').join(sub);
  fam.items.forEach((it, i) => {
    const f = files.find(x => x.file.split('/').pop() === fill(it.file));
    // `table.*`: one option for each name the table holds (a weapon, a job), its name said back as {1}
    if (f && it.key.endsWith('.*')) { const up = modParsed(f).byPath[fill(it.key.slice(0, -2))];
      for (const c of (up && up.kind === 'map' ? up.fields : [])) if (modEditable(c) && !seen.has(f.file + '|' + c.path)) { seen.add(f.file + '|' + c.path);
        rows.push({it, f, x: c, id: fam.id + '.' + i, title: fill(it[lang][0]).split('{1}').join(c.key), desc: fill(it[lang][1]).split('{1}').join(c.key)}); }
      return; }
    const x = f && modParsed(f).byPath[fill(it.key)];
    if (!x || !(modEditable(x) || (it.rgb && mxColorMap(x))) || (fam.id === 'job' && f.scope !== 'job')) return;
    // an empty table the catalog knows as a table of lines ({} in the file): its columns are the catalog's
    if (it.cols && x.kind === 'list' && !x.fields.length) Object.assign(x, {kind: 'rows', cols: Object.keys(it.cols), value: []});
    if (it.cols && x.kind !== 'rows') return;
    seen.add(f.file + '|' + x.path);
    rows.push({it, f, x, id: fam.id + '.' + i, title: fill(it[lang][0]), desc: fill(it[lang][1])});
  });
  // a job's own switch the catalog does not know yet (a new one): shown with the file's own words rather than hidden
  if (fam.id === 'job') for (const f of files.filter(x => x.scope === 'job' && x.file.endsWith('/' + job + '_CONFIG.lua')))
    for (const x of modParsed(f).fields) if (modEditable(x) && !seen.has(f.file + '|' + x.path)) rows.push({it: {}, f, x, id: '', title: modName(x), desc: modDoc(x.doc)});
  return rows;
}
// The file's text with every waiting value put where the old one was (from the end, so the places stay right)
function modNewText(f, edits){
  const p = modParsed(f); let text = f.text;
  Object.keys(edits).map(k => ({x: p.byPath[k], e: edits[k]})).filter(o => o.x).sort((a, b) => b.x.a - a.x.a).forEach(o => { text = text.slice(0, o.x.a) + o.e.src + text.slice(o.x.b); });
  return text;
}
// What a save says when it fails: the game's reason, or the page's own
const modErr = e => t('modErr_' + e) === 'modErr_' + e ? t('modErr_other', {e}) : t('modErr_' + e);
// One file written: by the game when it is connected and the change is only values (its door checks it), else by the
// page itself. {ok, how: 'live' | 'folder' | 'download', hash} or {error}
// each trial read of a new text its own cache entry (the cache knows a file by its name, hash and length: two texts of
// one length would share one)
let MOD_TRIAL = 0;
async function modWriteOne(f, orig, text, edits, keys){
  const stmt = Object.keys(modAdds()[f.file] || {}).some(id => (modExamples(orig.text).find(e => e.id === id) || {}).stmt);
  if (liveOk() && !stmt) {
    const q = new URLSearchParams({job: S.job || '', file: f.file, hash: orig.hash || '', key: keys.join(', '),
      before: keys.map(k => (edits[k] || {}).before || '').join(' | '), after: keys.map(k => (edits[k] || {}).after || '+').join(' | ')});
    let r; try { r = await liveOrder(S.char, '/config_write?' + q, {method: 'POST', body: text, timeout: 5000}); } catch (e) { r = {error: 'live'}; }
    return r && r.ok ? {ok: true, how: 'live', hash: r.entry.hash_after} : {error: (r && r.error) || 'live'};
  }
  // the page writes it: the new text must still read with every setting it held (the game's own check is not there);
  // a table written whole may lose lines (macro_edit.js: a subjob removed)
  const whole = Object.keys(edits).filter(k => edits[k].table), gone = p => whole.some(k => p.startsWith(k + '.'));
  const was = new Set(Object.keys(modParsed(f).byPath)), now = new Set(Object.keys(modParsed({file: f.file + '#new', text, hash: 'w' + (++MOD_TRIAL)}).byPath));
  if ([...was].some(p => !now.has(p) && !gone(p))) return {error: 'syntax'};
  let w; try { w = await writeCharFile(S.char, f.file, orig.text, text); } catch (e) { return {error: (e && e.message) || 'folder'}; }
  if (w === null) return {error: 'cancel'};
  if (w === 'changed') return {error: 'changed'};
  return {ok: true, how: w ? 'folder' : 'download', hash: ''};
}
async function modSave(){
  const d = data(), all = ((S._modEdits = S._modEdits || {})[S.char] = S._modEdits[S.char] || {}), adds = modAdds(), done = [];
  let how = 'live';
  for (const file of [...new Set([...Object.keys(all), ...Object.keys(adds)])]) {
    const f = modAllFiles(d).find(x => x.file === file), edits = all[file] || {}, orig = f && (f.orig || f);
    // reading a file's edits leaves an empty entry (modEdits): nothing waits there, whatever job it belongs to
    if (!Object.keys(edits).length && !Object.values(adds[file] || {}).some(Boolean)) { delete all[file]; delete adds[file]; continue; }
    // a file the export shown no longer holds: said, never dropped in silence (the changes stay, to save on its job)
    if (!f) { S.toast = t('modErr_nofile', {f: file}); render(); return; }
    const text = modNewText(f, edits);
    if (text === orig.text) { delete all[file]; delete adds[file]; continue; }   // a line added and left empty: nothing to write
    const keys = Object.keys(edits).concat(modExamples(orig.text).filter(e => (adds[file] || {})[e.id]).map(e => e.key));
    const r = await modWriteOne(f, orig, text, edits, keys);
    if (!r.ok) { if (r.error !== 'cancel') S.toast = modErr(r.error); render(); return; }
    orig.text = text; orig.hash = r.hash || ''; delete all[file]; delete adds[file]; done.push(file.split('/').pop());
    if (r.how !== 'live') how = r.how;
  }
  if (done.length) {
    if (how === 'live') { S.toast = t('modSaved', {f: done.join(', ')}); try { await liveOrder(S.char, '/reload', {method: 'POST'}); } catch (e) {} }
    else S.toast = t(how === 'folder' ? 'modSavedLocal' : 'modSavedDownload', {f: done.join(', '), p: S.char + '/'});
  }
  render();
}
document.addEventListener('click', e => {
  const b = e.target.closest('[data-modbool],[data-modsave],[data-modundo],[data-modopt],[data-moddel],[data-mcchoice]'); if (!b) return; const d = b.dataset;
  // a closed choice of the catalog: the value itself (a text, or false) is the catalog's, by its place
  if (d.mcchoice) { const [fam, i, c] = d.mcchoice.split(/[.:]/), it = (MOD_CATALOG.find(x => x.id === fam) || {items: []}).items[+i];
    if (it && it.choices && it.choices[+c]) modStage(d.modfile, d.modpath, it.choices[+c][0]); return; }
  if (d.modopt != null) { modStage(d.modfile, d.modpath, d.modopt); return; }
  if (d.moddel != null) { modStage(d.modfile, d.modpath, modValue(d.modfile, d.modpath).filter((v, i) => i !== +d.moddel)); return; }
  if ('modsave' in d) { modSave(); return; }
  if ('modundo' in d) { if (S._modEdits) delete S._modEdits[S.char]; if (S._modAdds) delete S._modAdds[S.char]; S.toast = ''; render(); return; }
  if ('modbool' in d) modStage(d.modfile, d.modpath, b.getAttribute('aria-checked') !== 'true');
});
// The settings in the frame of the three parts (atelier/src/screens/config/modules.ts): a category opened (S.modTheme,
// kept), an option chosen (S._regSel: its detail on the right)
Object.assign(T.fr, {regGaugeTip: '{s} : de {a} à {b} HP manquants', regGaugeFix: 'Taper les chiffres',
  regHudShow: 'HUD : ce qui est affiché', regHudLook: 'HUD : apparence',
  regSub_job: 'Ce que GearSwap fait de plus en {j}.', regSub_auto: 'Ce qui part tout seul pendant le combat.', regSub_gear: 'L’équipement que GearSwap choisit pour toi.',
  regSub_cmd: 'Ce que font tes macros //gs c buff, cleanse, sneak, warp…', regSub_bags: 'Remplir l’inventaire, ranger les wardrobes.',
  regSub_display: 'Le HUD, le chat, les couleurs.', regSub_multi: 'Jouer plusieurs persos ensemble.', regSub_tools: 'Les addons et les outils de suivi.'});
Object.assign(T.en, {regGaugeTip: '{s}: from {a} to {b} HP missing', regGaugeFix: 'Type the numbers',
  regHudShow: 'HUD: what is shown', regHudLook: 'HUD: how it looks',
  regSub_job: 'What GearSwap does on top in {j}.', regSub_auto: 'What goes by itself in a fight.', regSub_gear: 'The gear GearSwap picks for you.',
  regSub_cmd: 'What your //gs c buff, cleanse, sneak, warp… macros do.', regSub_bags: 'Filling the inventory, tidying the wardrobes.',
  regSub_display: 'The HUD, the chat, the colours.', regSub_multi: 'Playing several characters together.', regSub_tools: 'The addons and the tracking tools.'});
document.addEventListener('click', e => {
  const th = e.target.closest('[data-modtheme]');
  if (th) { S.modTheme = th.dataset.modtheme; S.modFile = ''; S.modFam = null; S._regSel = ''; S.modQ = ''; S.toast = ''; save(); render(); return; }
  const row = e.target.closest('[data-regsel]');
  // a click on the line chooses it (its detail on the right); a click in its control chooses it too, shown at the
  // control's own redraw (no redraw here: a field being typed in keeps its focus)
  if (row) { const was = S._regSel; S._regSel = row.dataset.regsel; if (was !== S._regSel && !e.target.closest('button, input, select, label, a, summary, .cfg-c')) render(); }
});
// the HP gauge of a table of tiers (modules.ts gaugeOf): a handle dragged moves the end of a tier and the start of the
// next together, by steps of 10 HP, never past the tiers around it; let go, the new table waits with the other changes
document.addEventListener('pointerdown', e => {
  const h = e.target.closest('.rghandle'); if (!h) return;
  const box = h.closest('[data-gauge]'), bar = box.querySelector('.rgbar'), [file, path] = box.dataset.gauge.split('|'), i = +h.dataset.gaugeat;
  const rows = (modValue(file, path) || []).map(r => Object.assign({}, r)), parts = [...bar.children];
  if (!rows[i + 1]) return;
  e.preventDefault(); h.setPointerCapture(e.pointerId);
  const total = parts.reduce((n, p) => n + parseFloat(p.style.flex), 0), width = bar.getBoundingClientRect().width;
  const lo = rows[i].min + 10, hi = rows[i + 1].max >= 99999 ? rows[i + 1].min + 2000 : rows[i + 1].max - 10, start = rows[i].max, x0 = e.clientX;
  let v = start;
  // what is being chosen, shown while dragging: a bubble over the handle, the number under the bar follows
  const ticks = box.querySelectorAll('.rgticks span'), bubble = document.createElement('div');
  bubble.className = 'rgbubble'; box.appendChild(bubble);
  const show = () => { const bx = box.getBoundingClientRect(), hx = h.getBoundingClientRect();
    bubble.innerHTML = `<b>${rows[i].spell}</b> ${rows[i].min} → <em>${v}</em> HP · <b>${rows[i + 1].spell}</b> ${v} →`;
    bubble.style.left = (hx.left + hx.width / 2 - bx.left) + 'px'; if (ticks[i + 1]) ticks[i + 1].textContent = v; };
  const move = ev => {
    v = Math.min(hi, Math.max(lo, Math.round((start + (ev.clientX - x0) / width * total) / 10) * 10));
    parts[i].style.flex = String(v - rows[i].min);
    if (rows[i + 1].max < 99999) parts[i + 1].style.flex = String(rows[i + 1].max - v);
    if (ticks[i]) ticks[i].style.flex = parts[i].style.flex;
    if (ticks[i + 1] && rows[i + 1].max < 99999) ticks[i + 1].style.flex = parts[i + 1].style.flex;
    show();
  };
  show();
  const up = () => { h.removeEventListener('pointermove', move); h.removeEventListener('pointerup', up); bubble.remove();
    if (v === start) return;
    rows[i].max = v; rows[i + 1].min = v; modStage(file, path, rows); };
  h.addEventListener('pointermove', move); h.addEventListener('pointerup', up);
});
// The value shown for a setting: the one waiting, else the file's
function modValue(file, path){
  const sub = rfStagedSub(file, path); if (sub) return sub.value;
  const f = modFiles(data()).find(x => x.file === file), x = f && modParsed(f).byPath[path], ed = modEdits(file)[path];
  return ed ? ed.v : x && x.value;
}
document.addEventListener('change', e => {
  const add = e.target.closest('[data-modadd]');
  if (add) { const cur = modValue(add.dataset.modfile, add.dataset.modpath) || [], s = add.value.trim(), nums = cur.length > 0 && cur.every(v => typeof v === 'number');
    if (!s || (nums && isNaN(Number(s)))) return;
    modStage(add.dataset.modfile, add.dataset.modpath, [...cur, nums ? Number(s) : s]); return; }
  const b = e.target.closest('[data-modin]'); if (!b) return;
  const f = modFiles(data()).find(x => x.file === b.dataset.modfile), x = f && modParsed(f).byPath[b.dataset.modpath], v = x && modTyped(x, b.value);
  if (!x) return;
  if (v === null || !mxInRange(b, v)) { S.toast = t('modBad', {v: b.value}); render(); return; }
  modStage(f.file, x.path, v);
});
