// What the Atelier page's Macro book & lockstyle part writes back into a job's <JOB>_MACROBOOK.lua / <JOB>_LOCKSTYLE.lua
// (atelier/app/js/macro_edit.js), checked on every such file of the characters and of the templates:
//   for each change the page can make (the default changed, a subjob's numbers changed, a subjob added, one removed),
//   1. a real Lua 5.1 runs the new file and reads exactly the numbers the page meant (default, then solo / by_subjob);
//   2. the page reads its own writing back to the same numbers;
//   3. the page's own writer accepts it (modules.js modWriteOne: no setting lost but the subjob removed);
//   4. the game's door accepts it as data only (shared/utils/core/lua_data.lua only_data_changed).
// Nothing is written into a character's folder: the trials go to the temp folder.
//
//   node scripts/atelier/macro_edit_test.js
//
// Needs lua5.1 on the PATH. Exit code 1 when a check fails.
//
// @author ejouanchicot
// @date   Created: 2026-10-30
const fs = require('fs'), path = require('path'), os = require('os'), cp = require('child_process');
const DATA = path.resolve(__dirname, '../..'), JS = path.join(DATA, 'atelier/app/js');
const read = f => fs.readFileSync(path.join(JS, f), 'utf8');

const T = {fr: {}, en: {}}, S = {char: 'Test', lang: 'fr', job: ''};
let DATA_NOW = null;
const api = new Function('T', 'S', 'document', 't', 'esc', 'data', 'render', 'liveOk', 'writeCharFile',
  ['module_catalog.js', 'module_rows.js', 'module_rest_fr.js', 'module_ux.js', 'modules.js', 'macro_edit.js'].map(read).join('\n') +
  ';return {macroFiles, macroModel, macroStage, modNewText, modEdits, modParsed, modWriteOne};')(
  T, S, {addEventListener() {}}, k => k, s => s, () => DATA_NOW, () => {}, () => false, async () => true);

// every macro book / lockstyle file: the characters' (<Char>/<job>/display/) and the templates' (_master/config/<job>/)
const files = [];
for (const top of fs.readdirSync(DATA)) {
  const dir = path.join(DATA, top);
  if (!fs.statSync(dir).isDirectory() || top.startsWith('.') || top === 'node_modules') continue;
  const walk = (d, depth) => { for (const n of fs.readdirSync(d)) { const p = path.join(d, n);
    if (fs.statSync(p).isDirectory()) { if (depth < 3) walk(p, depth + 1); }
    else if (/^[A-Z]{3}_(MACROBOOK|LOCKSTYLE)\.lua$/.test(n)) files.push(p); } };
  if (top === '_master' || fs.existsSync(path.join(dir, 'atelier')) || fs.existsSync(path.join(dir, '_common'))) walk(dir, 0);
}

const fails = [], fail = (what, where) => { if (fails.length < 60) console.log('FAIL ' + what + '  ' + where); fails.push(what); };
const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'macro_edit_'));
const canon = (kind, m) => JSON.stringify({def: m.def, subs: Object.keys(m.subs).sort().reduce((o, k) => (o[k] = m.subs[k], o), {})});
const cases = [];
const JOBS = ['WAR', 'MNK', 'WHM', 'BLM', 'RDM', 'THF', 'PLD', 'DRK', 'BST', 'BRD', 'RNG', 'SAM', 'NIN', 'DRG', 'SMN', 'BLU', 'COR', 'PUP', 'DNC', 'SCH', 'GEO', 'RUN'];

(async () => {
  for (const abs of files) {
    const name = path.basename(abs), kind = /MACROBOOK/.test(name) ? 'book' : 'style', job = name.slice(0, 3);
    const where = path.relative(DATA, abs).split(path.sep).join('/');
    const f = {file: job.toLowerCase() + '/display/' + name, text: fs.readFileSync(abs, 'utf8'), hash: where, scope: 'job', part: 'macro'};
    S.job = job; S._modEdits = {};
    DATA_NOW = {configs: [f], sub: 'WAR'};
    const m0 = api.macroModel(kind, f);
    if (m0.def == null) { fail('no default the page can read', where); continue; }
    const bump = (v, k) => kind === 'style' ? (v % 200) + 1 : Object.assign({}, v, {[k]: (v[k] % (k === 'book' ? 40 : 10)) + 1});
    const subs = Object.keys(m0.subs), missing = JOBS.find(j => j !== job && m0.subs[j] == null);
    const ops = [['the default changed', 'def', kind === 'style' ? bump(m0.def) : bump(m0.def, 'book')]];
    if (m0.table) {
      if (subs.length) ops.push(['a subjob\'s numbers changed', 'subs', Object.assign({}, m0.subs, {[subs[0]]: kind === 'style' ? bump(m0.subs[subs[0]]) : bump(m0.subs[subs[0]], 'page')})]);
      if (missing) ops.push(['a subjob added', 'subs', Object.assign({}, m0.subs, {[missing]: kind === 'style' ? 7 : {book: 3, page: 4}})]);
      if (subs.length) { const less = Object.assign({}, m0.subs); delete less[subs[subs.length - 1]]; ops.push(['a subjob removed', 'subs', less]); }
      if (subs.length) ops.push(['every subjob removed', 'subs', {}]);
    }
    for (const [what, part, v] of ops) {
      S._modEdits = {};
      api.macroStage(kind, part, v);
      const edits = api.modEdits(f.file), text = api.modNewText(f, edits);
      const want = canon(kind, Object.assign({}, m0, part === 'def' ? {def: v} : {subs: v}));
      // 2. read back by the page
      const back = api.macroModel(kind, {file: f.file + '#' + cases.length, text, part: 'macro'}, true);
      if (canon(kind, back) !== want) fail(what + ': the page reads back ' + canon(kind, back) + ' for ' + want, where);
      // 3. the page's own writer
      const r = await api.modWriteOne(f, f, text, edits, Object.keys(edits));
      if (!r.ok) fail(what + ': the page\'s writer refuses it (' + r.error + ')', where);
      const after = path.join(tmp, 'c' + cases.length + '.lua'), before = after.replace(/\.lua$/, '.before.lua');
      fs.writeFileSync(after, text); fs.writeFileSync(before, f.text);
      cases.push({what, where, kind, want, after, before});
    }
  }
  // 1. and 4.: one Lua run for all
  const lp = f => JSON.stringify(f.split(path.sep).join('/')), root = DATA.split(path.sep).join('/');
  const script = path.join(tmp, 'check.lua');
  fs.writeFileSync(script, `package.path = ${JSON.stringify(root + '/?.lua;')} .. package.path
local D = require('shared/utils/core/lua_data')
local function read(f) local h = io.open(f, 'rb') local t = h:read('*a') h:close() return t end
local function keys(t) local o = {} for k in pairs(t or {}) do o[#o + 1] = k end table.sort(o) return o end
local function num(v) return string.format('%d', v) end
local function val(kind, v)
  if v == nil then return 'null' end
  if kind == 'style' then return num(v) end
  return '{"book":' .. num(v.book) .. ',"page":' .. num(v.page) .. '}'
end
local function canon(kind, cfg)
  local t = kind == 'style' and cfg.by_subjob or cfg.solo
  local o = {}
  for _, k in ipairs(keys(t)) do o[#o + 1] = '"' .. k .. '":' .. val(kind, t[k]) end
  return '{"def":' .. val(kind, cfg.default) .. ',"subs":{' .. table.concat(o, ',') .. '}}'
end
` + cases.map((c, i) => `do local ok, cfg = pcall(dofile, ${lp(c.after)})
  print(${i + 1}, ok and canon(${JSON.stringify(c.kind)}, cfg) or ('error ' .. tostring(cfg)), tostring(D.only_data_changed(read(${lp(c.before)}), read(${lp(c.after)})))) end`).join('\n') + '\n');
  const r = cp.spawnSync('lua5.1', [script], {encoding: 'utf8'});
  if (r.error || r.status !== 0) fail('Lua could not run', r.error ? r.error.message : r.stderr.slice(0, 400));
  else r.stdout.split(/\r?\n/).filter(Boolean).forEach(l => { const [i, got, door] = l.split('\t'), c = cases[+i - 1];
    if (got !== c.want) fail(c.what + ': Lua reads ' + got + ' for ' + c.want, c.where);
    if (door !== 'true') fail(c.what + ': the game\'s door would refuse it', c.where); });
  console.log(files.length + ' files, ' + cases.length + ' changes tried, ' + fails.length + ' failure(s)');
  process.exit(fails.length ? 1 : 0);
})();
