// GearSwap Atelier · module_rows.js: the settings of the Modules part (modules.js) that are a table of lines, each line a
// few named values: the TP Bonus pieces of a job ({slot, name, bonus}), a refill list ({name, target}), the Cure tiers
// ({min, max, spell}). Shown as a table: a cell is typed or picked, a line is added, moved, removed.
// In the file, a line that was there keeps its own text (only the cells changed are rewritten, its comments stay);
// the table itself is laid out again only when a line is added, moved or removed.
// (loaded by atelier/index.html after module_items.js, before modules.js)

Object.assign(T.fr, {mrAdd: '+ Ajouter une ligne', mrAddItem: '+ Ajouter un objet', mrAddGear: '+ Ajouter une pièce', mrAddTip: 'Ajoute une ligne à la fin. Rien n’est écrit avant « Enregistrer ».',
  mrUp: 'Monter cette ligne', mrDown: 'Descendre cette ligne', mrDel: 'Retirer cette ligne', mrFill: 'à remplir', mrFillTip: 'Une ligne sans nom n’est pas écrite : tape son nom.',
  mrCellNum: 'Tape le nombre, puis Entrée.', mrCellText: 'Tape le nom comme dans le jeu, puis Entrée.', mrCellMany: 'Tape le nom comme dans le jeu, puis Entrée. Plusieurs variantes : sépare-les par une virgule, la préférée d’abord.',
  mrCellSlot: 'L’emplacement où cette pièce se porte.', mrCellAll: 'Un nombre, ou « all » pour tout sortir.',
  mrC_name: 'Nom', mrC_slot: 'Emplacement', mrC_bonus: 'TP Bonus', mrC_target: 'À garder', mrC_min: 'À partir de', mrC_max: 'Jusqu’à', mrC_spell: 'Sort', mrC_enmity: 'Enmity',
  mrC_recast: 'Recast (s)', mrC_priority: 'Enmity par seconde', mrC_cmd: 'Commande', mrC_on: 'Cible', mrC_action: 'Type (ja / ma)', mrC_item: 'Objet', mrC_gear: 'Pièce', mrC_weapon: 'Arme',
  mrS_main: 'Arme principale', mrS_sub: 'Arme secondaire / bouclier', mrS_range: 'Distance', mrS_ammo: 'Munition', mrS_head: 'Tête', mrS_neck: 'Cou', mrS_ear1: 'Oreille 1', mrS_ear2: 'Oreille 2',
  mrS_body: 'Corps', mrS_hands: 'Mains', mrS_ring1: 'Anneau 1', mrS_ring2: 'Anneau 2', mrS_back: 'Dos', mrS_waist: 'Taille', mrS_legs: 'Jambes', mrS_feet: 'Pieds'});
Object.assign(T.en, {mrAdd: '+ Add a line', mrAddItem: '+ Add an item', mrAddGear: '+ Add a piece', mrAddTip: 'Adds a line at the end. Nothing is written before "Save".',
  mrUp: 'Move this line up', mrDown: 'Move this line down', mrDel: 'Remove this line', mrFill: 'to fill in', mrFillTip: 'A line with no name is not written: type its name.',
  mrCellNum: 'Type the number, then Enter.', mrCellText: 'Type the name as in the game, then Enter.', mrCellMany: 'Type the name as in the game, then Enter. Several variants: separate them with a comma, the preferred one first.',
  mrCellSlot: 'The slot this piece is worn in.', mrCellAll: 'A number, or "all" to take them all out.',
  mrC_name: 'Name', mrC_slot: 'Slot', mrC_bonus: 'TP Bonus', mrC_target: 'To keep', mrC_min: 'From', mrC_max: 'Up to', mrC_spell: 'Spell', mrC_enmity: 'Enmity',
  mrC_recast: 'Recast (s)', mrC_priority: 'Enmity per second', mrC_cmd: 'Command', mrC_on: 'Target', mrC_action: 'Kind (ja / ma)', mrC_item: 'Item', mrC_gear: 'Piece', mrC_weapon: 'Weapon',
  mrS_main: 'Main weapon', mrS_sub: 'Off-hand / shield', mrS_range: 'Ranged', mrS_ammo: 'Ammo', mrS_head: 'Head', mrS_neck: 'Neck', mrS_ear1: 'Ear 1', mrS_ear2: 'Ear 2',
  mrS_body: 'Body', mrS_hands: 'Hands', mrS_ring1: 'Ring 1', mrS_ring2: 'Ring 2', mrS_back: 'Back', mrS_waist: 'Waist', mrS_legs: 'Legs', mrS_feet: 'Feet'});

const MR_SLOTS = ['main', 'sub', 'range', 'ammo', 'head', 'neck', 'ear1', 'ear2', 'body', 'hands', 'ring1', 'ring2', 'back', 'waist', 'legs', 'feet'];
// What a column holds, by its name in the file, when the catalog does not say: 'num', 'slot', 'item' (a usable item,
// with its icon), 'gear' (a piece of equipment, with its icon), 'text'
const MR_KIND = {slot: 'slot', bonus: 'num', target: 'num', min: 'num', max: 'num', enmity: 'num', recast: 'num', priority: 'num'};

// A table of lines among a Lua table's fields: every field a line `{key = value, ...}` whose values are plain or a list
const mrPlain = f => f.kind === 'str' || f.kind === 'num' || f.kind === 'bool';
const mrIsRows = fields => fields.length > 0 && fields.every(f => f.index && f.kind === 'map' && f.fields.length > 0 && f.fields.every(c => c.key != null && (mrPlain(c) || c.kind === 'list')));
// Its value for the page: one object a line, `_o` the place the line had in the file (none: a line added here)
const mrValue = fields => fields.map((f, i) => Object.assign({_o: i}, ...f.fields.map(c => ({[c.key]: c.value}))));
// The columns: every key the lines of the file hold, in the order they first come
const mrCols = x => x.cols || [...new Set(x.fields.flatMap(f => f.fields.map(c => c.key)))];
const mrSame = (a, b) => JSON.stringify(a) === JSON.stringify(b);
const mrEmpty = v => v === undefined || v === '' || (Array.isArray(v) && !v.length);
// The column that names a line: `name`, else the first one that holds text (not the slot), else the first
function mrNameCol(x){
  const cols = mrCols(x), text = k => x.fields.some(f => f.fields.some(c => c.key === k && (c.kind === 'str' || c.kind === 'list')));
  return cols.includes('name') ? 'name' : cols.find(k => k !== 'slot' && text(k)) || cols[0];
}
// A line the file cannot take yet: its name is empty
const mrUnfilled = (x, r) => mrEmpty(r[mrNameCol(x)]);

/* ---- back to Lua ---- */
const mrCellSrc = (v, q) => Array.isArray(v) ? '{' + v.map(i => mrCellSrc(i, q)).join(', ') + '}' : typeof v === 'string' ? luaQuote(v, q) : String(v);
// A line that was in the file, as its own text with the cells that changed put in place (from the end: the places hold)
function mrOldLine(text, x, r, q){
  const o = x.fields[r._o]; let s = text.slice(o.a, o.b);
  for (const c of [...o.fields].sort((a, b) => b.a - a.a))
    if (!mrSame(r[c.key], c.value) && !mrEmpty(r[c.key])) s = s.slice(0, c.a - o.a) + mrCellSrc(r[c.key], c.q || q) + s.slice(c.b - o.a);
  const have = new Set(o.fields.map(c => c.key));
  for (const k of mrCols(x)) if (!have.has(k) && !mrEmpty(r[k])) s = s.replace(/,?\s*\}$/, ', ' + k + ' = ' + mrCellSrc(r[k], q) + '}');
  return s;
}
const mrNewLine = (x, r, q, keys) => '{' + [...new Set([...(keys || []), ...mrCols(x)])].filter(k => !mrEmpty(r[k])).map(k => k + ' = ' + mrCellSrc(r[k], q)).join(', ') + '}';
// A line of the file written over several lines, with no comment of its own: laid out again on one line when the table is
const mrLong = (text, o) => { const s = text.slice(o.a, o.b); return s.includes('\n') && !s.includes('--'); };
// The whole table as Lua text
function mrSource(text, x, v){
  const str = x.fields.flatMap(f => f.fields).find(c => c.kind === 'str'), q = (str && str.q) || "'";
  const rows = v.filter(r => !mrUnfilled(x, r));
  // the same lines at the same places: only the cells move, the table keeps its layout and every comment
  if (rows.length === x.fields.length && rows.every((r, i) => r._o === i)) {
    let s = text.slice(x.a, x.b);
    for (const r of [...rows].reverse()) { const o = x.fields[r._o]; s = s.slice(0, o.a - x.a) + mrOldLine(text, x, r, q) + s.slice(o.b - x.a); }
    return s;
  }
  const from = text.lastIndexOf('\n', x.a) + 1, pad = (text.slice(from).match(/^[ \t]*/) || [''])[0], inner = pad + '    ', out = [];
  rows.forEach((r, i) => { const o = r._o != null ? x.fields[r._o] : null;
    for (const l of (o && o.doc) || []) out.push(inner + '-- ' + l);
    out.push(inner + (!o ? mrNewLine(x, r, q) : mrLong(text, o) ? mrNewLine(x, r, q, o.fields.map(c => c.key)) : mrOldLine(text, x, r, q)) + (i < rows.length - 1 ? ',' : '') + (o && o.note ? ' -- ' + o.note : '')); });
  return '{\n' + out.join('\n') + '\n' + pad + '}';
}
const mrCellShow = v => Array.isArray(v) ? v.join(' / ') : String(v === undefined ? '' : v);
// The table in a few words, for the history
const mrShow = v => v.map(r => Object.keys(r).filter(k => k !== '_o').map(k => mrCellShow(r[k])).join(' ')).join(' ; ');

/* ---- the table on the page ---- */
// A column: its kind and its title. opts.cols (the catalog): {key: [kind, fr, en]}
function mrCol(x, k, opts){
  const all = mrCols(x), vals = x.fields.flatMap(f => f.fields.filter(c => c.key === k));
  // with no word from the catalog: {name, target} is a refill list, {spell, target} a chain of actions on a target
  const guess = all.includes('name') && all.includes('target') ? {name: ['item', t('mrC_item'), t('mrC_item')], target: ['count']} : all.includes('spell') ? {target: ['text', t('mrC_on'), t('mrC_on')]} : {};
  const spec = (opts.cols || {})[k] || guess[k] || [];
  const said = spec[0] || MR_KIND[k] || (vals.length && vals.every(c => c.kind === 'num') ? 'num' : 'text'), kind = said === 'count' ? 'num' : said;   // 'count': a number, or 'all'
  const own = spec[S.lang === 'en' ? 2 : 1], known = t('mrC_' + k);
  return {k, kind, title: own || (known !== 'mrC_' + k ? known : k.replace(/_/g, ' ').replace(/^./, c => c.toUpperCase())),
    many: vals.some(c => c.kind === 'list'), loose: said === 'count' || (kind === 'num' && vals.some(c => c.kind === 'str'))};
}

/* ---- changing it ---- */
// A new line: its name (when picked), the other columns as the last line has them (the same slot, the same count)
function mrBlank(x, cur, name){
  const cols = mrCols(x), last = cur[cur.length - 1] || {}, r = {};
  cols.forEach(k => { if (k === mrNameCol(x)) { if (name) r[k] = name; } else if (!mrEmpty(last[k])) r[k] = last[k]; });
  return r;
}
const mrAdd = (file, path, name) => { const x = modField(file, path), cur = modValue(file, path) || []; if (x) modStage(file, path, [...cur, mrBlank(x, cur, name)]); };
// The names a table of lines already holds (its first column), for the window of items
const mrNames = val => (val || []).flatMap(v => v && typeof v === 'object' && !Array.isArray(v) ? [].concat(Object.values(v).find(c => typeof c === 'string' || Array.isArray(c)) || []) : [v]);
// What was typed in a cell, as the column's kind (null: refused)
function mrTyped(col, text){
  const s = text.trim();
  if (col.kind === 'num') return s !== '' && !isNaN(Number(s)) ? Number(s) : col.loose && s ? s : null;
  if (col.kind === 'slot') return s;
  const parts = s.split(',').map(p => p.trim()).filter(Boolean);
  return (col.many || col.kind === 'item') && parts.length > 1 ? parts : s;
}
document.addEventListener('click', e => {
  const b = e.target.closest('[data-rowup],[data-rowdown],[data-rowdel],[data-rowadd]'); if (!b) return;
  const d = b.dataset, cur = [...(modValue(d.modfile, d.modpath) || [])], swap = (i, j) => { [cur[i], cur[j]] = [cur[j], cur[i]]; };
  if ('rowadd' in d) { mrAdd(d.modfile, d.modpath); return; }
  if (d.rowup != null) swap(+d.rowup, +d.rowup - 1); else if (d.rowdown != null) swap(+d.rowdown, +d.rowdown + 1); else cur.splice(+d.rowdel, 1);
  modStage(d.modfile, d.modpath, cur);
});
document.addEventListener('change', e => {
  const b = e.target.closest('[data-rowcell]'); if (!b) return;
  const d = b.dataset, x = modField(d.modfile, d.modpath), [i, k] = [+d.rowcell.split(':')[0], d.rowcell.slice(d.rowcell.indexOf(':') + 1)];
  if (!x) return;
  const v = mrTyped(mrCol(x, k, mcItem(d.modfile, d.modpath)), b.value);
  if (v === null || (mrEmpty(v) && k !== mrNameCol(x))) { S.toast = t('modBad', {v: b.value}); render(); return; }
  const cur = (modValue(d.modfile, d.modpath) || []).map((r, j) => { if (j !== i) return r; const n = Object.assign({}, r); if (mrEmpty(v)) delete n[k]; else n[k] = v; return n; });
  modStage(d.modfile, d.modpath, cur);
});
