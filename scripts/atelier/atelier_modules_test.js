// What the Atelier page's Modules part writes back into a settings file, checked on every setting of every character:
// a value changed in the page must come out as Lua the game reads, holding what the page showed, and nothing else of
// the file may move.
//
//   node scripts/atelier/atelier_modules_test.js [Character ...]     (default: every character with exports)
//
// For every setting the page can change (exports' `configs`, read by atelier/app/js/modules.js):
//   1. left as it is, it is written back to the letter;
//   2. changed (a switch flipped, a number raised, a text with quotes in it, an entry added to a list; for a table of
//      lines: a cell changed, a line added, removed, moved), the new text is run by a real Lua 5.1 and must hold
//      exactly the value the page meant; the page's own reader must read the same back;
//   3. the whole file with the change in place still compiles (luac -p), and its text outside the setting is untouched.
// Nothing is written into a character's folder: the files are read from the exports, the trials go to the temp folder.
// Needs lua5.1 and luac5.1 on the PATH. Exit code 1 when a check fails.
//
// @author ejouanchicot
// @date   Created: 2026-10-11
const fs = require('fs'), path = require('path'), os = require('os'), cp = require('child_process');
const DATA = path.resolve(__dirname, '../..'), JS = path.join(DATA, 'atelier/app/js');
const OX = require(path.join(JS, 'offline_export.js'));
const read = f => fs.readFileSync(path.join(JS, f), 'utf8');

const T = {fr: {}, en: {}}, S = {char: '', lang: 'fr', job: ''};
const api = new Function('T', 'S', 'document', 't', 'esc', ['module_catalog.js', 'module_rows.js', 'module_rest_fr.js', 'module_ux.js', 'modules.js'].map(read).join('\n') +
  ';return {MOD_CATALOG, mcRows, modParsed, modSource, modEditable, mrSource, mrCols, mrNameCol, luaSettings};')(T, S, {addEventListener() {}}, k => k, s => s);

const isChar = n => fs.existsSync(path.join(DATA, n, 'atelier/exports'));
const chars = process.argv.slice(2).length ? process.argv.slice(2) : fs.readdirSync(DATA).filter(isChar);
const fails = [], fail = (what, where) => { if (fails.length < 60) console.log('FAIL ' + what + '  ' + where); fails.push(what); };

// A value as one line both sides can write: the page's (expected) and Lua's (read back)
const canon = v => Array.isArray(v) ? '[' + v.map(canon).join('|') + ']'
  : v && typeof v === 'object' ? '{' + Object.keys(v).filter(k => k !== '_o' && v[k] !== undefined).sort().map(k => k + '=' + canon(v[k])).join(',') + '}'
  : typeof v === 'string' ? 's:' + v : typeof v === 'number' ? 'n:' + Number(v.toPrecision(12)) : 'b:' + v;
const LUA_CANON = `
local function canon(v)
  if type(v) == 'table' then
    if #v > 0 or next(v) == nil then local o = {} for i = 1, #v do o[i] = canon(v[i]) end return '[' .. table.concat(o, '|') .. ']' end
    local keys = {} for k in pairs(v) do keys[#keys + 1] = tostring(k) end table.sort(keys)
    local o = {} for i, k in ipairs(keys) do o[i] = k .. '=' .. canon(v[k]) end return '{' .. table.concat(o, ',') .. '}'
  elseif type(v) == 'string' then return 's:' .. v
  elseif type(v) == 'number' then return 'n:' .. tostring(tonumber(string.format('%.12g', v)))
  else return 'b:' .. tostring(v) end
end
for i, c in ipairs(CASES) do io.write(i, '\\t', (canon(c):gsub('[\\r\\n]', ' ')), '\\n') end
`;

// The trials of one setting: [what, the new value]
function trials(x){
  const v = x.value;
  if (x.kind === 'bool') return [['flipped', !v]];
  if (x.kind === 'num') return [['raised', v + 1], ['a fraction', 0.25]];
  if (x.kind === 'str') return [['a text with quotes', 'It\'s "x" \\ y'], ['emptied', '']];
  if (x.kind === 'list') { const nums = v.length > 0 && v.every(i => typeof i === 'number'), extra = nums ? 7 : 'Test\'s "Item"';
    return [['an entry added', [...v, extra]], ...(v.length ? [['the first entry removed', v.slice(1)], ['turned round', [...v].reverse()]] : [])]; }
  const cols = api.mrCols(x), name = api.mrNameCol(x), blank = {}; cols.forEach(k => { blank[k] = k === name ? 'New\'s Line' : k === 'slot' ? 'legs' : 5; });
  const cell = (r, i) => { const n = Object.assign({}, r), k = cols.find(c => typeof r[c] === 'number'); if (k) n[k] = r[k] + 1 + i; else n[name] = 'Renamed ' + i; return n; };
  const out = [['a line added', [...v, blank]]];
  if (v.length) out.push(['a cell changed on every line', v.map(cell)], ['a name made a list of variants', v.map((r, i) => i ? r : Object.assign({}, r, {[name]: ['A +1', 'A']}))],
    ['the first line removed', v.slice(1)], ['turned round', [...v].reverse()], ['a cell changed, a line added, turned round', [...v.map(cell), blank].reverse()], ['emptied', []]);
  return out;
}

const cases = [], seen = new Set();
let settings = 0, files = 0;
for (const c of chars) {
  const dir = path.join(DATA, c, 'atelier/exports');
  for (const name of fs.readdirSync(dir).filter(n => n.endsWith('.js'))) {
    const d = OX.parseExport(fs.readFileSync(path.join(dir, name), 'utf8'));
    if (!d || !d.configs) continue;
    S.char = c; S.job = d.job;
    for (const fam of api.MOD_CATALOG) api.mcRows(d, fam);            // the catalog names the tables of lines left empty in a file
    for (const f of d.configs) {
      const key = c + '/' + f.file + '|' + (f.hash || f.text.length); if (seen.has(key)) continue; seen.add(key); files++;
      const p = api.modParsed(f);
      for (const x of Object.values(p.byPath)) {
        if (!api.modEditable(x)) continue;
        settings++;
        const where = c + '/' + f.file + ' ' + x.path, src = v => x.kind === 'rows' ? api.mrSource(f.text, x, v) : api.modSource(x, v);
        if (x.kind === 'rows' && src(x.value) !== f.text.slice(x.a, x.b)) fail('a table left as it is does not come back to the letter', where);
        for (const [what, v] of trials(x)) cases.push({where, what, v, s: src(v), f, x});
      }
    }
  }
}

// every trial through a real Lua: the value it reads; then through the page's own reader
const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'atelier-mod-'));
const run = (exe, args) => cp.spawnSync(exe, args, {encoding: 'utf8', maxBuffer: 1 << 28});
const lua = path.join(tmp, 'cases.lua');
fs.writeFileSync(lua, 'local CASES = {}\n' + cases.map((k, i) => `CASES[${i + 1}] = ${k.s}`).join('\n') + '\n' + LUA_CANON);
const r = run('lua5.1', [lua]);
if (r.error || r.status !== 0) { console.log('FAIL lua5.1 could not run the trials: ' + (r.error ? r.error.message : r.stderr.slice(0, 600))); fails.push('lua'); }
else {
  const got = r.stdout.split(/\r?\n/).filter(Boolean).map(l => l.slice(l.indexOf('\t') + 1));
  cases.forEach((k, i) => { if (got[i] !== canon(k.v).replace(/[\r\n]/g, ' ')) fail(k.what + ': Lua reads another value', k.where + '\n       wanted ' + canon(k.v).slice(0, 200) + '\n       got    ' + String(got[i]).slice(0, 200)); });
}
let compiled = 0;
const tried = new Set(); let trial = 0;
// 4. the game takes the change: it only accepts values changed in a settings file (shared/utils/core/lua_data.lua
// only_data_changed, asked by atelier_configs.lua before writing), checked below on every file compiled
const pairs = [];
for (const k of cases) {
  const text = k.f.text.slice(0, k.x.a) + k.s + k.f.text.slice(k.x.b);
  // the page reads its own writing back (a file whose root the reader finds by name)
  const back = api.modParsed({file: k.f.file, text, hash: 'trial' + (trial++)}).byPath[k.x.path];
  const empty = Array.isArray(k.v) && !k.v.length;          // {} reads back as an empty list, whatever it was
  if (!back || (!empty && canon(back.value) !== canon(k.v))) fail(k.what + ': the page does not read its own writing back', k.where);
  // the whole file still compiles (one trial a setting is enough for the file around it: the first and the last)
  if (!tried.has(k.x) || k.what.startsWith('a cell changed, a line added')) {
    tried.add(k.x);
    const file = path.join(tmp, 'f' + (compiled++) + '.lua'); fs.writeFileSync(file, text);
    const c = run('luac5.1', ['-p', file]);
    if (c.error || c.status !== 0) fail(k.what + ': the file no longer compiles', k.where + '\n       ' + (c.error ? c.error.message : c.stderr.trim().slice(0, 200)));
    const before = file.replace(/\.lua$/, '.before.lua'); fs.writeFileSync(before, k.f.text);
    pairs.push({before, after: file, what: k.what, where: k.where});
  }
}
if (pairs.length) {
  const list = path.join(tmp, 'pairs.lua'), luaPath = f => JSON.stringify(f.split(path.sep).join('/'));
  const root = path.resolve(__dirname, '../..').split(path.sep).join('/');
  fs.writeFileSync(list, `package.path = ${JSON.stringify(root + '/?.lua;')} .. package.path\n` +
    `local D = require('shared/utils/core/lua_data')\nlocal function read(f) local h = io.open(f, 'rb') local t = h:read('*a') h:close() return t end\n` +
    pairs.map((x, i) => `print(${i + 1}, D.only_data_changed(read(${luaPath(x.before)}), read(${luaPath(x.after)})))`).join('\n') + '\n');
  const r = run('lua5.1', [list]);
  if (r.error || r.status !== 0) fail('the game\'s check could not run', r.error ? r.error.message : r.stderr.slice(0, 400));
  else r.stdout.split(/\r?\n/).filter(Boolean).forEach(l => { const [i, okv, why] = l.split('\t'); const x = pairs[+i - 1];
    if (okv !== 'true') fail(x.what + ': the game would refuse it as code (' + why + ')', x.where); });
  console.log(pairs.length + ' changed files asked to the game\'s check');
}
fs.rmSync(tmp, {recursive: true, force: true});
const rows = cases.filter(k => k.x.kind === 'rows').length;
console.log(chars.join(', ') + ': ' + files + ' settings files, ' + settings + ' settings the page can change, ' + cases.length + ' trials (' + rows + ' on tables of lines), ' + compiled + ' files compiled');
console.log(fails.length ? '\n' + fails.length + ' check(s) failed' : '\nevery change comes out as Lua the game reads');
process.exit(fails.length ? 1 : 0);
