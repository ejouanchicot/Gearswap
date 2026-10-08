// The export without the game, run in the real page (Chrome, opened from the disk as a player does): the worker,
// Lua in WebAssembly and the folder access, against the same run under Node (offline_export_test.js compares that
// one to the Python script).
//
//   node scripts/atelier/offline_export_page_test.js [Character]     (default: Kaories)
//
// A page cannot be handed a real folder without a click in the browser's own picker: the page gets a stand-in
// folder handle whose every call is answered by this script from the disk. The export folder is put back at the end.
//
// @author ejouanchicot
// @date   Created: 2026-10-08
const fs = require('fs'), path = require('path');
const DATA_ABS = path.resolve(__dirname, '../..'), ROOT = path.resolve(DATA_ABS, '../../..');
const puppeteer = require(process.env.PUPPETEER || path.join(process.env.APPDATA || '', 'npm/node_modules/@modelcontextprotocol/server-puppeteer/node_modules/puppeteer'));
const CHROME = process.env.CHROME || 'C:/Program Files/Google/Chrome/Application/chrome.exe';
const OX = require(path.join(DATA_ABS, 'atelier/app/js/offline_export.js'));
const CHAR = process.argv[2] || 'Kaories';
const abs = rel => path.join(ROOT, rel), dir = path.join(DATA_ABS, CHAR, 'atelier/exports'), index = path.join(DATA_ABS, 'atelier/index.js');
const snapshot = () => { const out = {}; for (const n of fs.readdirSync(dir)) out[n] = fs.readFileSync(path.join(dir, n), 'utf8'); return out; };
const restore = snap => { fs.rmSync(dir, {recursive: true, force: true}); fs.mkdirSync(dir, {recursive: true}); for (const [n, t] of Object.entries(snap)) fs.writeFileSync(path.join(dir, n), t); };
const strip = d => { const o = Object.assign({}, d); delete o.at; delete o.src; return JSON.stringify(o); };

(async () => {
  const before = snapshot(), indexBefore = fs.readFileSync(index, 'utf8');
  let bad = 0;
  const browser = await puppeteer.launch({executablePath: CHROME, headless: 'new', args: ['--allow-file-access-from-files']});
  try {
    // the reference: the same run under Node
    globalThis.window = globalThis; require(path.join(DATA_ABS, 'atelier/lua/lua51.js'));
    const glue = new Function('require', '__filename', '__dirname', ATELIER_LUA.glue + '\nreturn glue;')(require, __filename, __dirname);
    let runner = null;
    await OX.run({
      async list(rel){ try { return fs.readdirSync(abs(rel), {withFileTypes: true}).map(e => ({name: e.name, dir: e.isDirectory()})); } catch (e) { return null; } },
      async meta(rel){ try { const s = fs.statSync(abs(rel)); return {size: s.size, mtime: Math.floor(s.mtimeMs)}; } catch (e) { return null; } },
      async text(rel){ try { return fs.readFileSync(abs(rel), 'utf8'); } catch (e) { return null; } },
      async write(rel, text){ fs.writeFileSync(abs(rel), text); }, async remove(rel){ try { fs.unlinkSync(abs(rel)); } catch (e) {} },
      async lua(src, tasks, onDone){
        if (!runner) { runner = await OX.luaRunnerFactory()(glue, Buffer.from(ATELIER_LUA.wasm, 'base64')); for (const rel of src.metas.keys()) runner.put(rel, fs.readFileSync(abs(rel))); runner.dirs(src.dirs); }
        return tasks.map(t => { const r = runner.run(t.char, t.job, t.sub); onDone(r); return r; }); },
    }, CHAR, {force: true});
    const want = snapshot();
    restore(before); fs.writeFileSync(index, indexBefore);

    const page = await browser.newPage(), errors = [];
    page.on('pageerror', e => errors.push(e.message));
    await page.exposeFunction('nodeList', rel => { try { return fs.readdirSync(abs(rel), {withFileTypes: true}).map(e => ({name: e.name, dir: e.isDirectory()})); } catch (e) { return null; } });
    await page.exposeFunction('nodeStat', rel => { try { const s = fs.statSync(abs(rel)); return {size: s.size, mtime: Math.floor(s.mtimeMs), dir: s.isDirectory()}; } catch (e) { return null; } });
    await page.exposeFunction('nodeRead', rel => fs.readFileSync(abs(rel)).toString('base64'));
    await page.exposeFunction('nodeText', rel => fs.readFileSync(abs(rel), 'utf8'));
    await page.exposeFunction('nodeWrite', (rel, text) => { fs.mkdirSync(path.dirname(abs(rel)), {recursive: true}); fs.writeFileSync(abs(rel), text); });
    await page.exposeFunction('nodeRemove', rel => { try { fs.unlinkSync(abs(rel)); } catch (e) {} });
    await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); });
    await page.goto('file:///' + path.join(DATA_ABS, 'atelier/index.html').split(path.sep).join('/'), {waitUntil: 'load'});
    await new Promise(r => setTimeout(r, 3000));
    const t0 = Date.now();
    const res = await page.evaluate(async char => {
      const join = (a, b) => a ? a + '/' + b : b, missing = () => { const e = new Error('not found'); e.name = 'NotFoundError'; return e; };
      const file = rel => ({kind: 'file',
        async getFile(){ const st = await nodeStat(rel); if (!st) throw missing();
          return {size: st.size, lastModified: st.mtime, text: () => nodeText(rel),
            async arrayBuffer(){ const raw = atob(await nodeRead(rel)), u = new Uint8Array(raw.length); for (let i = 0; i < raw.length; i++) u[i] = raw.charCodeAt(i); return u.buffer; }}; },
        async createWritable(){ let buf = ''; return {async write(t){ buf += t; }, async close(){ await nodeWrite(rel, buf); }}; }});
      const folder = rel => ({kind: 'directory',
        async *entries(){ for (const e of (await nodeList(rel)) || []) yield [e.name, e.dir ? folder(join(rel, e.name)) : file(join(rel, e.name))]; },
        async getDirectoryHandle(n){ const st = await nodeStat(join(rel, n)); if (!st || !st.dir) throw missing(); return folder(join(rel, n)); },
        async getFileHandle(n, o){ const st = await nodeStat(join(rel, n)); if (!st && !(o && o.create)) throw missing(); return file(join(rel, n)); },
        async removeEntry(n){ await nodeRemove(join(rel, n)); }});
      await new Promise(done => loadScripts(['atelier/lua/lua51.js'], done));
      const steps = [];
      const out = await OfflineExport.run(oxEnv(folder('')), char, {force: true, onProgress: (k, n, m, w) => { if (steps[steps.length - 1] !== k) steps.push(k); }});
      return Object.assign(out, {steps, workers: OX_POOL.length});
    }, CHAR);
    const got = snapshot(), secs = ((Date.now() - t0) / 1000).toFixed(1);
    for (const n of [...new Set(Object.keys(want).concat(Object.keys(got)))].sort()) {
      const same = n in want && n in got && strip(OX.parseExport(want[n])) === strip(OX.parseExport(got[n]));
      if (!same) { bad++; console.log('  DIFFERENT', n, n in want ? '' : '(only the page wrote it)', n in got ? '' : '(only Node wrote it)'); }
    }
    console.log(`${CHAR}: in the page ${secs} s · exported ${res.exported}, failed ${res.failed.length}, unchanged ${res.unchanged} · steps ${res.steps.join(' > ')} · ${res.workers} worker(s)`);
    for (const f of res.failed) console.log('  failed', f.join(' ').slice(0, 200));
    if (errors.length) { bad += errors.length; console.log('  page errors:', errors.join(' | ').slice(0, 400)); }
    console.log(bad ? `${bad} difference(s)` : `${Object.keys(got).length} files, the same as under Node`);
  } finally { await browser.close(); restore(before); fs.writeFileSync(index, indexBefore); }
  process.exit(bad ? 1 : 0);
})();
