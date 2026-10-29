// GearSwap Atelier · modules.js: the "Modules" part of the Configuration tab: every settings file of the character
// (<Char>/_common/<theme>/) and of the job shown (<Char>/<job>/<theme>/), read from its text (export `configs`:
// shared/utils/atelier/atelier_configs.lua). A file is read the way a player reads it: each setting with the comment
// written over it, so the page explains what the file explains, in the file's own words.
// A setting changed here waits (S._modEdits) until "Save": the page then puts the new value in the file's text, at the
// place the old one was, and the game writes the file (a copy first, the change in the history: /config_write).
// (loaded after layout2.js: see atelier/src/legacy/files.ts)

Object.assign(T.fr, {sectionsModules: 'Réglages', ttTab_modules: 'Les réglages de chaque module de GearSwap (Auto Medicine, Refill, Dual-box, HUD…) : ceux du perso et ceux de ce job.',
  modHint: 'Vue avancée : chaque fichier de réglages en entier. Pour les options courantes, reviens sur « Options ».',
  modSave: 'Enregistrer',
  modSaved: 'Écrit dans {f}. Une copie est gardée : l’historique (en haut) peut annuler. GearSwap se recharge.',
  modNone: 'Cet export ne contient pas encore les fichiers de réglages : clique « Relire » en haut de la page, ou charge ce job en jeu.',
  modInFile: 'Ce réglage est du code : il se change dans le fichier', modAuto: 'Auto (lu en jeu)', modForce: 'ou forcer…', modAdd: '+ ajouter', modDel: 'Retirer {v}',
  modEmpty: 'Aucun réglage simple dans ce fichier : il se change à la main.', modBad: 'Valeur refusée : {v}', modOn: 'Allumé', modOff: 'Éteint',
  modErr_changed: 'Le fichier a changé depuis la lecture : clique « Relire », puis recommence.', modErr_syntax: 'Le fichier ne se lirait plus avec cette valeur : rien n’a été écrit.', modErr_code: 'Le jeu n’accepte de changer que des valeurs (texte, nombre, oui/non, liste) : ce changement touchait au code du fichier, rien n’a été écrit.',
  modErr_file: 'Ce fichier ne peut pas être écrit depuis la page.', modErr_live: 'Le jeu n’a pas répondu : rien n’a été écrit.', modErr_other: 'Rien n’a été écrit ({e}).',
  ttGrpOpen: 'Déplier ce groupe.', ttGrpFold: 'Replier ce groupe.',
  histKind_config: 'réglage', modSettings: '{n} réglage(s)',
  mcSimple: 'Options', mcSimpleTip: 'Les options qu’on a envie de régler, rangées par module et expliquées.', mcFiles: 'Avancé', mcFilesTip: 'Pour aller plus loin : chaque fichier de réglages en entier, avec tout ce qu’il contient.',
  modManual: 'Le mode d’emploi écrit dans le fichier (en anglais)', modPartKnown: 'Les options courantes', modPartRest: 'Le reste du fichier', modPartAll: 'Les réglages du fichier',
  modPartRestWhy: '', modNamed: 'Des entrées nommées : elles s’ajoutent dans le fichier', modPartAdv: 'Réglages écrits comme du code ({n}) : ils se changent dans le fichier, pas ici',
  modPathTip: 'Où est ce fichier, dans le dossier data de GearSwap : pour l’ouvrir dans un éditeur.',
  mcHint: 'Choisis un module à gauche. Chaque option dit ce qu’elle change et pour qui. Rien n’est écrit avant « Enregistrer ».',
  mcScopeAll: 'Tout le perso · tous les jobs', mcScopeJob: 'Ce job seulement · {j}', mcScopeWhenJob: 'Seulement quand tu es {j}', mcScopeWhenSub: 'Seulement avec le sub /{s}', mcScopeOnly: 'Tout le perso · sert en {j}',
  ttModRead: 'Lecture seule : le jeu n’est pas connecté. Lance GearSwap sur ce perso pour changer cette option ici.',
  ttModTurnOn: 'Clique pour l’allumer. Rien n’est écrit avant « Enregistrer ».', ttModTurnOff: 'Clique pour l’éteindre. Rien n’est écrit avant « Enregistrer ».',
  ttModChoose: 'Choisir « {v} ». Rien n’est écrit avant « Enregistrer ».', ttModChosen: '« {v} » est le choix actuel.',
  ttModAuto: 'Laisser GearSwap lire cette valeur en jeu : rien à tenir à jour toi-même.', ttModForce: 'Pour imposer une valeur à la place de celle lue en jeu : tape-la, puis Entrée. Vide : retour à Auto.',
  ttModNum: 'Tape le nouveau nombre, puis Entrée.', ttModText: 'Tape la nouvelle valeur, puis Entrée. Les noms s’écrivent comme dans le jeu.',
  ttModAdd: 'Tape un nom comme dans le jeu, puis Entrée : il s’ajoute à la fin de la liste.',
  ttModSave: 'Écrit les changements dans tes fichiers de réglages. Une copie de chaque fichier est gardée, l’Historique (en haut) peut annuler, et GearSwap se recharge pour les prendre.',
  ttModUndo: 'Oublie les changements en attente. Tes fichiers n’ont pas été touchés.',
  ttScopeAll: 'Vaut pour tous les jobs de {c}. Tes autres persos ont chacun leur propre réglage.',
  ttScopeJob: 'Ne change que {j} sur {c}. Tes autres jobs et tes autres persos ne bougent pas.',
  ttScopeWhenJob: 'Cette liste ne sert que quand {c} est {j}. Chaque job a la sienne.',
  ttScopeWhenSub: 'Cette liste ne sert qu’avec le sub /{s}, quel que soit le job principal de {c}.',
  ttScopeOnly: 'Réglage de {c}, mais il n’a d’effet que quand tu joues {o}.',
  mcIntro: 'Présentation', mcIntroSub: 'ce que GearSwap fait en {j}', mcIntroTitle: 'GearSwap en {j} : ce qu’il fait pour toi', mcIntroJob: 'Sur ce job ({j})',
  mcIntroWhere: 'Pour t’en servir :', mcIntroOwn: 'les options de {j} ({n})', mcIntroAll: 'Sur tous tes jobs', mcIntroAllWhy: 'Ces modules marchent quel que soit le job, rangés par ce à quoi ils servent. Clique sur l’un d’eux pour voir ce qu’il fait et le régler.',
  mcInGame: 'En jeu : ', ttIntro: 'Ce que ce GearSwap fait tout seul en {j}, et les modules communs à tous les jobs. À lire en premier.', ttIntroGo: 'Voir ce que fait « {f} » et ses options.'});
Object.assign(T.en, {sectionsModules: 'Settings', ttTab_modules: 'The settings of each GearSwap module (Auto Medicine, Refill, Dual-box, HUD…): the character’s and this job’s.',
  modHint: 'Advanced view: each settings file whole. For the usual options, go back to "Options".',
  modSave: 'Save',
  modSaved: 'Written in {f}. A copy is kept: the history (top bar) can undo it. GearSwap reloads.',
  modNone: 'This export does not hold the settings files yet: click "Reread" at the top of the page, or load this job in game.',
  modInFile: 'This setting is code: it is changed in the file', modAuto: 'Auto (read in game)', modForce: 'or force…', modAdd: '+ add', modDel: 'Remove {v}',
  modEmpty: 'No simple setting in this file: it is changed by hand.', modBad: 'Value refused: {v}', modOn: 'On', modOff: 'Off',
  modErr_changed: 'The file changed since it was read: click "Reread", then do it again.', modErr_syntax: 'The file would no longer read with this value: nothing was written.', modErr_code: 'The game only accepts values being changed (text, number, yes/no, list): this change touched the file’s code, nothing was written.',
  modErr_file: 'This file cannot be written from the page.', modErr_live: 'The game did not answer: nothing was written.', modErr_other: 'Nothing was written ({e}).',
  ttGrpOpen: 'Unfold this group.', ttGrpFold: 'Fold this group.',
  histKind_config: 'setting', modSettings: '{n} setting(s)',
  mcSimple: 'Options', mcSimpleTip: 'The options one wants to set, by module, explained.', mcFiles: 'Advanced', mcFilesTip: 'To go further: each settings file whole, with everything it holds.',
  modManual: 'The manual written in the file', modPartKnown: 'The usual options', modPartRest: 'The rest of the file', modPartAll: 'The file’s settings',
  modPartRestWhy: '', modNamed: 'Named entries: added in the file', modPartAdv: 'Settings written as code ({n}): changed in the file, not here',
  modPathTip: 'Where this file is, in GearSwap’s data folder: to open it in an editor.',
  mcHint: 'Pick a module on the left. Each option says what it changes and for whom. Nothing is written before "Save".',
  mcScopeAll: 'The whole character · every job', mcScopeJob: 'This job only · {j}', mcScopeWhenJob: 'Only when you are {j}', mcScopeWhenSub: 'Only with the /{s} subjob', mcScopeOnly: 'The whole character · used on {j}',
  ttModRead: 'Read only: the game is not connected. Start GearSwap on this character to change this option here.',
  ttModTurnOn: 'Click to turn it on. Nothing is written before "Save".', ttModTurnOff: 'Click to turn it off. Nothing is written before "Save".',
  ttModChoose: 'Choose "{v}". Nothing is written before "Save".', ttModChosen: '"{v}" is the current choice.',
  ttModAuto: 'Let GearSwap read this value in game: nothing to keep up to date yourself.', ttModForce: 'To force a value in place of the one read in game: type it, then Enter. Empty: back to Auto.',
  ttModNum: 'Type the new number, then Enter.', ttModText: 'Type the new value, then Enter. Names are written as in the game.',
  ttModAdd: 'Type a name as in the game, then Enter: it is added at the end of the list.',
  ttModSave: 'Writes the changes into your settings files. A copy of each file is kept, the History (top bar) can undo, and GearSwap reloads to take them.',
  ttModUndo: 'Forgets the waiting changes. Your files were not touched.',
  ttScopeAll: 'Holds for every job of {c}. Each of your other characters has its own setting.',
  ttScopeJob: 'Changes {j} only, on {c}. Your other jobs and characters do not move.',
  ttScopeWhenJob: 'This list is used only when {c} is {j}. Each job has its own.',
  ttScopeWhenSub: 'This list is used only with the /{s} subjob, whatever the main job of {c}.',
  ttScopeOnly: 'A setting of {c}, but it only has an effect when you play {o}.',
  mcIntro: 'Presentation', mcIntroSub: 'what GearSwap does on {j}', mcIntroTitle: 'GearSwap on {j}: what it does for you', mcIntroJob: 'On this job ({j})',
  mcIntroWhere: 'To use it:', mcIntroOwn: 'the options of {j} ({n})', mcIntroAll: 'On all your jobs', mcIntroAllWhy: 'These modules work whatever the job, ranged by what they are for. Click one to see what it does and set it.',
  mcInGame: 'In game: ', ttIntro: 'What this GearSwap does by itself on {j}, and the modules shared by every job. Read this first.', ttIntroGo: 'See what "{f}" does and its options.'});

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

/* ---- the part of the tab ---- */
const MOD_CACHE = new Map();
// A file parsed once per text: {head, fields, byPath}
function modParsed(f){
  const k = f.file + '|' + (f.hash || f.text.length);
  if (!MOD_CACHE.has(k)) {
    let fields = []; try { fields = luaSettings(f.text); } catch (e) { fields = []; }
    const byPath = {}, walk = (list, pre) => list.forEach(x => { x.path = pre + (x.key != null ? x.key : '[' + x.index + ']'); byPath[x.path] = x; if (x.kind === 'map') walk(x.fields, x.path + '.'); });
    walk(fields, '');
    MOD_CACHE.set(k, {head: luaHeader(f.text), fields, byPath});
  }
  return MOD_CACHE.get(k);
}
const modFiles = d => (d && d.configs) || [];
const modShown = d => { const list = modFiles(d); return list.find(f => f.file === S.modFile) || list.find(f => f.scope === 'job') || list[0]; };
const modEdits = file => (((S._modEdits = S._modEdits || {})[S.char] = S._modEdits[S.char] || {})[file] = S._modEdits[S.char][file] || {});
const modEditable = x => x.kind === 'bool' || x.kind === 'num' || x.kind === 'str' || x.kind === 'list' || x.kind === 'rows';
// A setting of a file of the export shown, by its path
const modField = (file, path) => { const f = modFiles(data()).find(x => x.file === file); return f && modParsed(f).byPath[path]; };
// The catalog's entry for a setting (its columns, its kind of list), when it has one
function mcItem(file, path){
  for (const fam of MOD_CATALOG) for (const r of mcRows(data(), fam)) if (r.f.file === file && r.x.path === path) return r.it;
  return {};
}
const modCanWrite = f => liveOk() && !f.text.includes('�');
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
function modFileGroup(f){
  if (f.scope === 'job') return 'job';
  const base = f.file.split('/').pop();
  return MOD_FILE_GROUP[base] || MOD_FILE_GROUP[base.replace(/^[A-Z]{3}_/, '{JOB}_')] || 'tools';
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
// What a change reaches: said on every option, since a player must know it before touching it
function mcScope(d, r){
  const v = {c: S.char, j: S.job, s: d.sub, o: r.it.only};
  if (r.f.scope === 'job') return {cls: 'job', text: t('mcScopeJob', v), tip: t('ttScopeJob', v)};
  if (r.it.when === 'job') return {cls: 'job', text: t('mcScopeWhenJob', v), tip: t('ttScopeWhenJob', v)};
  if (r.it.when === 'sub') return {cls: 'job', text: t('mcScopeWhenSub', v), tip: t('ttScopeWhenSub', v)};
  if (r.it.only) return {cls: 'all', text: t('mcScopeOnly', {j: r.it.only}), tip: t('ttScopeOnly', v)};
  return {cls: 'all', text: t('mcScopeAll'), tip: t('ttScopeAll', v)};
}
// The file's text with every waiting value put where the old one was (from the end, so the places stay right)
function modNewText(f, edits){
  const p = modParsed(f); let text = f.text;
  Object.keys(edits).map(k => ({x: p.byPath[k], e: edits[k]})).filter(o => o.x).sort((a, b) => b.x.a - a.x.a).forEach(o => { text = text.slice(0, o.x.a) + o.e.src + text.slice(o.x.b); });
  return text;
}
async function modSave(){
  const d = data(), all = (S._modEdits || {})[S.char] || {}, done = [];
  for (const file of Object.keys(all)) {
    const f = modFiles(d).find(x => x.file === file), edits = all[file], keys = Object.keys(edits);
    if (!f || !keys.length) { delete all[file]; continue; }
    const text = modNewText(f, edits);
    if (text === f.text) { delete all[file]; continue; }   // a line added and left empty: nothing to write
    const q = new URLSearchParams({job: S.job || '', file, hash: f.hash || '', key: keys.join(', '),
      before: keys.map(k => edits[k].before).join(' | '), after: keys.map(k => edits[k].after).join(' | ')});
    let r; try { r = await liveOrder(S.char, '/config_write?' + q, {method: 'POST', body: text, timeout: 5000}); } catch (e) { r = {error: 'live'}; }
    if (!r || !r.ok) { const e = (r && r.error) || 'live'; S.toast = t('modErr_' + e) === 'modErr_' + e ? t('modErr_other', {e}) : t('modErr_' + e); render(); return; }
    f.text = text; f.hash = r.entry.hash_after; delete all[file]; done.push(file.split('/').pop());
  }
  if (done.length) { S.toast = t('modSaved', {f: done.join(', ')}); try { await liveFetch(S.char, '/reload', {method: 'POST'}); } catch (e) {} }
  render();
}
document.addEventListener('click', e => {
  const b = e.target.closest('[data-modgrp],[data-modopen],[data-modbool],[data-modsave],[data-modundo],[data-modopt],[data-moddel],[data-modview],[data-modfam],[data-mcchoice]'); if (!b) return; const d = b.dataset;
  if (d.modgrp) { S.modGrp = Object.assign({}, S.modGrp, {[d.modgrp]: d.open !== 'true'}); render(); return; }
  if (d.modview) { S.modView = d.modview; S.toast = ''; render(); return; }
  if (d.modfam) { S.modFam = d.modfam; S.toast = ''; render(); return; }
  // a closed choice of the catalog: the value itself (a text, or false) is the catalog's, by its place
  if (d.mcchoice) { const [fam, i, c] = d.mcchoice.split(/[.:]/), it = (MOD_CATALOG.find(x => x.id === fam) || {items: []}).items[+i];
    if (it && it.choices && it.choices[+c]) modStage(d.modfile, d.modpath, it.choices[+c][0]); return; }
  if (d.modopt != null) { modStage(d.modfile, d.modpath, d.modopt); return; }
  if (d.moddel != null) { modStage(d.modfile, d.modpath, modValue(d.modfile, d.modpath).filter((v, i) => i !== +d.moddel)); return; }
  if (d.modopen) { S.modFile = d.modopen; S.toast = ''; render(); return; }
  if ('modsave' in d) { modSave(); return; }
  if ('modundo' in d) { if (S._modEdits) delete S._modEdits[S.char]; S.toast = ''; render(); return; }
  if ('modbool' in d) modStage(d.modfile, d.modpath, b.getAttribute('aria-checked') !== 'true');
});
// The value shown for a setting: the one waiting, else the file's
function modValue(file, path){
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
