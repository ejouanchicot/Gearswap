// The page's export without the game (atelier/app/js/offline_export.js) against the Python one
// (scripts/atelier/atelier_all.py): both run on the same files, from the same exports, and must leave the same files.
//
//   node scripts/atelier/offline_export_test.js [Character ...] [--all-subs] [--lua-only]
//
// Two checks:
//   1. --lua-only, or first: each job loaded by the WebAssembly Lua and by lua5.1 gives the same export;
//   2. the whole run (which jobs and subjobs, the bags carried, the twins grouped, the index) against the Python
//      script's, forced (--force) so both redo every job.
// The export folders are copied aside first and put back at the end: nothing is left changed.
//
// @author ejouanchicot
// @date   Created: 2026-10-08
const fs = require('fs'), path = require('path'), cp = require('child_process');
const DATA_ABS = path.resolve(__dirname, '../..'), ROOT = path.resolve(DATA_ABS, '../../..');
const OX = require(path.join(DATA_ABS, 'atelier/app/js/offline_export.js'));
const args = process.argv.slice(2), only = args.filter(a => !a.startsWith('--')), allSubs = args.includes('--all-subs');

/* ---- env over the real disk ---- */
const abs = rel => path.join(ROOT, rel);
function makeEnv(){
  globalThis.window = globalThis;
  require(path.join(DATA_ABS, 'atelier/lua/lua51.js'));
  const glueFactory = new Function('require', '__filename', '__dirname', ATELIER_LUA.glue + '\nreturn glue;')(require, __filename, __dirname);
  let runner = null;
  return {
    async list(rel){ try { return fs.readdirSync(abs(rel), {withFileTypes: true}).map(e => ({name: e.name, dir: e.isDirectory()})); } catch (e) { return null; } },
    async meta(rel){ try { const s = fs.statSync(abs(rel)); return {size: s.size, mtime: Math.floor(s.mtimeMs)}; } catch (e) { return null; } },
    async bytes(rel){ return fs.readFileSync(abs(rel)); },
    async text(rel){ try { return fs.readFileSync(abs(rel), 'utf8'); } catch (e) { return null; } },
    async write(rel, text){ fs.mkdirSync(path.dirname(abs(rel)), {recursive: true}); fs.writeFileSync(abs(rel), text); },
    async remove(rel){ try { fs.unlinkSync(abs(rel)); } catch (e) {} },
    async lua(src, tasks, onDone){
      if (!runner) {
        runner = await OX.luaRunnerFactory()(glueFactory, Buffer.from(ATELIER_LUA.wasm, 'base64'));
        for (const rel of src.metas.keys()) runner.put(rel, fs.readFileSync(abs(rel)));
        runner.dirs(src.dirs);
      }
      return tasks.map(t => { const r = runner.run(t.char, t.job, t.sub); onDone(r); return r; });
    },
  };
}

/* ---- comparing ---- */
const IGNORED = new Set(['at', 'src']);   // the time of the export, and each side's own mark of the files' state
function diff(x, y, p, out){
  if (out.length > 5) return;
  if (typeof x !== typeof y || Array.isArray(x) !== Array.isArray(y) || (x === null) !== (y === null)) return out.push(`type ${p}: ${JSON.stringify(x)?.slice(0, 40)} | ${JSON.stringify(y)?.slice(0, 40)}`);
  if (x && typeof x === 'object') {
    for (const k of new Set([...Object.keys(x), ...Object.keys(y)])) {
      if (!p && IGNORED.has(k)) continue;
      if (!(k in x)) out.push(`only python ${p}.${k}`); else if (!(k in y)) out.push(`only page ${p}.${k}`); else diff(x[k], y[k], p + '.' + k, out);
    }
  } else if (x !== y) out.push(`${p}: ${JSON.stringify(x)?.slice(0, 50)} | ${JSON.stringify(y)?.slice(0, 50)}`);
}
const exportsDir = c => path.join(DATA_ABS, c, 'atelier/exports');
const snapshot = dir => { const out = {};
  for (const n of fs.existsSync(dir) ? fs.readdirSync(dir) : []) out[n] = fs.readFileSync(path.join(dir, n), 'utf8'); return out; };
const restore = (dir, snap) => { fs.rmSync(dir, {recursive: true, force: true}); fs.mkdirSync(dir, {recursive: true});
  for (const [n, t] of Object.entries(snap)) fs.writeFileSync(path.join(dir, n), t); };
const isChar = n => /^[A-Z]/.test(n) && fs.statSync(path.join(DATA_ABS, n)).isDirectory() && fs.readdirSync(path.join(DATA_ABS, n)).some(f => new RegExp('^' + n + '_[A-Z]{3}\\.lua$').test(f));

(async () => {
  const chars = fs.readdirSync(DATA_ABS).filter(isChar).filter(n => !only.length || only.includes(n));
  const index = path.join(DATA_ABS, 'atelier/index.js'), indexBefore = fs.readFileSync(index, 'utf8');
  let bad = 0;
  for (const c of chars) {
    const before = snapshot(exportsDir(c));
    try {
      const env = makeEnv();
      if (!args.includes('--lua-only')) {
        // the Python run, forced, from the files as they were
        const py = cp.spawnSync('python', ['scripts/atelier/atelier_all.py', c, '--no-open', '--force'].concat(allSubs ? ['--all-subs'] : []), {cwd: DATA_ABS, encoding: 'utf8'});
        if (py.status !== 0) { console.log(c, 'python failed', (py.stderr || '').slice(-300)); bad++; continue; }
        // the families line aside: the Python run keeps the one its last lua5.1 load wrote, the page the game's
        const noFam = t => t.replace(/^window\.ATELIER_FAMILIES = .*;$/m, '');
        const want = snapshot(exportsDir(c)), wantIndex = noFam(fs.readFileSync(index, 'utf8'));
        restore(exportsDir(c), before); fs.writeFileSync(index, indexBefore);
        const t0 = Date.now(), res = await OX.run(env, c, {force: true, allSubs});
        const got = snapshot(exportsDir(c)), gotIndex = noFam(fs.readFileSync(index, 'utf8'));
        const names = [...new Set(Object.keys(want).concat(Object.keys(got)))].sort(), notes = [];
        for (const n of names) {
          if (!(n in want)) { notes.push(`${n}: only the page wrote it`); continue; }
          if (!(n in got)) { notes.push(`${n}: only python wrote it`); continue; }
          const out = []; diff(OX.parseExport(want[n]), OX.parseExport(got[n]), '', out);
          if (out.length) notes.push(`${n}: ${out.slice(0, 3).join(' ; ')}`);
        }
        if (wantIndex !== gotIndex) { let i = 0; while (wantIndex[i] === gotIndex[i]) i++;
          notes.push(`index.js differs at ${i}: python ${JSON.stringify(wantIndex.slice(Math.max(0, i - 60), i + 80))} | page ${JSON.stringify(gotIndex.slice(Math.max(0, i - 60), i + 80))}`); }
        console.log(`${c}: ${names.length} files, ${notes.length ? notes.length + ' DIFFERENT' : 'all the same'} · page ${((Date.now() - t0) / 1000).toFixed(1)} s · exported ${res.exported}, failed ${res.failed.length}`);
        for (const n of notes.slice(0, 12)) console.log('   ', n.slice(0, 300));
        for (const f of res.failed.slice(0, 5)) console.log('    failed', f.join(' ').slice(0, 200));
        bad += notes.length;
      } else {
        const src = await OX.sources(env, c), jobs = fs.readdirSync(path.join(DATA_ABS, c)).map(f => (f.match(new RegExp('^' + c + '_([A-Z]{3})\\.lua$')) || [])[1]).filter(Boolean);
        for (const j of jobs) {
          const sub = j === 'WAR' ? 'SAM' : 'WAR', [w] = await env.lua(src, [{char: c, job: j, sub}], () => {});
          const file = path.join(exportsDir(c), `${j}_${sub}.js`);
          try { fs.unlinkSync(file); } catch (e) {}
          cp.spawnSync('lua5.1', ['scripts/atelier/load_job.lua', c, j, sub, ''], {cwd: DATA_ABS});
          const nat = fs.existsSync(file) ? fs.readFileSync(file, 'utf8') : null, out = [];
          if (w.text && nat) diff(OX.parseExport(nat), OX.parseExport(w.text), '', out);
          else if (!!w.text !== !!nat) out.push(w.text ? 'only the page exports it' : 'only lua5.1 exports it: ' + w.error);
          if (out.length) { bad++; console.log(`  ${c} ${j}/${sub}: ${out.slice(0, 3).join(' ; ').slice(0, 300)}`); }
        }
        console.log(`${c}: ${jobs.length} jobs loaded both ways`);
      }
    } finally { restore(exportsDir(c), before); fs.writeFileSync(index, indexBefore); }
  }
  console.log(bad ? `${bad} difference(s)` : 'no difference');
  process.exit(bad ? 1 : 0);
})();
