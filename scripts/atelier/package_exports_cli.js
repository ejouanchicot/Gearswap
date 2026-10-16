// The Atelier's exports of a package, on the command line (make_package.py add_exports): the package unzipped in a
// folder, Windower's res/ and addons/libs/ read from the real Windower folder, Lua 5.1 in WebAssembly as in the page
// (atelier/app/js/package_exports.js). Writes the exported files and their item icons (read from the Windower folder's
// data/atelier/icons/), as JSON {files: [[rel, text]], icons: [[rel, base64]]}, to <out.json>.
//
//   node scripts/atelier/package_exports_cli.js <unzipped folder, holding addons/GearSwap> <Windower folder> <Name> <out.json>
//
// @author ejouanchicot
// @date   Created: 2026-10-16
const fs = require('fs'), path = require('path');
const DATA = path.resolve(__dirname, '../..');
const PackageExports = require(path.join(DATA, 'atelier/app/js/package_exports.js'));
const OX = require(path.join(DATA, 'atelier/app/js/offline_export.js'));
const [pkgRoot, windower, name, out] = process.argv.slice(2);

// the package's files, rel from the Windower folder
const files = new Map();
const walk = (abs, rel) => { for (const e of fs.readdirSync(abs, {withFileTypes: true})) {
  const a = path.join(abs, e.name), r = rel + '/' + e.name;
  if (e.isDirectory()) walk(a, r); else files.set(r, new Uint8Array(fs.readFileSync(a))); } };
walk(path.join(pkgRoot, 'addons/GearSwap'), 'addons/GearSwap');

// the rest of the Windower folder, read only
const abs = rel => path.join(windower, rel);
const outside = {
  async list(rel){ try { return fs.readdirSync(abs(rel), {withFileTypes: true}).map(e => ({name: e.name, dir: e.isDirectory()})); } catch (e) { return null; } },
  async meta(rel){ try { const s = fs.statSync(abs(rel)); return {size: s.size, mtime: Math.floor(s.mtimeMs)}; } catch (e) { return null; } },
  async bytes(rel){ try { return fs.readFileSync(abs(rel)); } catch (e) { return new Uint8Array(0); } },
  async text(rel){ try { return fs.readFileSync(abs(rel), 'utf8'); } catch (e) { return null; } },
};

// one Lua runner, given every file the loads may read
globalThis.window = globalThis;
require(path.join(DATA, 'atelier/lua/lua51.js'));
const glue = new Function('require', '__filename', '__dirname', ATELIER_LUA.glue + '\nreturn glue;')(require, __filename, __dirname);
let runner = null;
async function lua(env, src, tasks, onDone){
  if (!runner) {
    runner = await OX.luaRunnerFactory()(glue, Buffer.from(ATELIER_LUA.wasm, 'base64'));
    for (const rel of src.metas.keys()) runner.put(rel, await env.bytes(rel));
    runner.dirs(src.dirs);
  }
  return tasks.map(t => { const r = runner.run(t.char, t.job, t.sub); onDone(r); return r; });
}

PackageExports.run(files, outside, lua, name).then(({result, files: written, icons}) => {
  fs.writeFileSync(out, JSON.stringify({files: written, icons: icons.map(([rel, b]) => [rel, Buffer.from(b).toString('base64')])}));
  console.log(JSON.stringify({exported: result.exported, failed: result.failed}));
}).catch(e => { console.error(e && e.stack || e); process.exit(1); });
