// The Packages page (atelier/app/js/packages.js) run in Chrome as the page runs it: its worker (Pyodide from the CDN,
// make_package.py on what sources() names, read through a real folder handle: the browser's private folder, laid
// out as a Windower folder), then the Atelier's exports made in the page (package_exports.js with offline_export.js's
// Lua workers), then the zip finished by the worker. It must be the zip `python make_package.py <Name>` writes: every
// file byte for byte, but the exports, whose time and mark of the files' state (at, src) are each run's own.
//
//   node scripts/atelier/make_package_page_test.js [Name]      (Morphetrix by default; needs Internet for Pyodide)
//
// @author ejouanchicot
// @date   Created: 2026-10-16
const fs = require('fs'), path = require('path'), http = require('http'), os = require('os'), {execFileSync} = require('child_process');
const puppeteer = require(process.env.PUPPETEER || path.join(process.env.APPDATA || '', 'npm/node_modules/@modelcontextprotocol/server-puppeteer/node_modules/puppeteer'));

const DATA = path.resolve(__dirname, '..', '..'), GS = path.dirname(DATA), ROOT = path.resolve(GS, '..', '..');
const NAME = process.argv[2] || 'Morphetrix';
const py = (code) => execFileSync('python', ['-c', code], {cwd: DATA, encoding: 'utf-8'});

// what the private folder holds, rel from the Windower folder: what the worker reads, and Windower's res/ and
// addons/libs/ (read by the exports)
const src = JSON.parse(py('import json, make_package; print(json.dumps(make_package.sources()))'));
const list = [];
const walk = (rel, skip = [], ext = []) => { for (const e of fs.readdirSync(path.join(ROOT, rel), {withFileTypes: true})) {
  if (skip.includes(e.name)) continue;
  if (e.isDirectory()) walk(rel + '/' + e.name, skip, ext); else if (!ext.some(x => e.name.endsWith(x))) list.push(rel + '/' + e.name); } };
for (const f of src.files) if (fs.existsSync(path.join(GS, f))) list.push('addons/GearSwap/' + f);
for (const t of src.trees) if (fs.existsSync(path.join(GS, t))) walk('addons/GearSwap/' + t, src.skip, src.skip_ext);
walk('res'); walk('addons/libs');
// the command line's zip first: the item icons it holds are the ones the page reads (data/atelier/icons/ has thousands)
const TMP = fs.mkdtempSync(path.join(os.tmpdir(), 'gs_pkg_')), CLI = path.join(TMP, 'cli.zip');
execFileSync('python', ['make_package.py', NAME, '--out', CLI], {cwd: DATA});
const ICONS = JSON.parse(py(`import zipfile, json\nprint(json.dumps([n for n in zipfile.ZipFile(r'${CLI}').namelist() if '/data/atelier/icons/' in n]))`));
for (const n of ICONS) list.push('addons/' + n);

// the worker's source, as the page builds it
const pageSrc = fs.readFileSync(path.join(DATA, 'atelier/app/js/packages.js'), 'utf8');
const WORKER = new Function('T', 'document', pageSrc + '\nreturn PKG_WORKER;')({fr: {}, en: {}}, {addEventListener(){}});
// the page's scripts the exports need
const SCRIPTS = ['atelier/lua/lua51.js', 'atelier/app/js/offline_export.js', 'atelier/app/js/package_exports.js'];

// a page at http://localhost (the private folder needs an origin), serving these files
const allowed = new Set(list);
const server = http.createServer((req, res) => {
  const rel = decodeURIComponent(req.url.split('?')[0]).replace(/^\//, '');
  if (rel === '') { res.end('<!doctype html><meta charset="utf-8"><title>t</title><script>window.T = {fr: {}, en: {}};</script>' +
    SCRIPTS.map(s => `<script src="/__page/${s}"></script>`).join('')); return; }
  const file = rel.startsWith('__page/') && SCRIPTS.includes(rel.slice(7)) ? path.join(DATA, rel.slice(7)) : allowed.has(rel) ? path.join(ROOT, rel) : null;
  if (!file) { res.statusCode = 404; res.end(); return; }
  if (file.endsWith('.js')) res.setHeader('content-type', 'text/javascript; charset=utf-8');
  fs.createReadStream(file).pipe(res);
});

(async () => {
  await new Promise(ok => server.listen(0, '127.0.0.1', ok));
  const url = `http://127.0.0.1:${server.address().port}/`;
  const browser = await puppeteer.launch({headless: true});
  let fails = 0;
  try {
    const page = await browser.newPage();
    await page.goto(url, {waitUntil: 'load'});
    const t0 = Date.now();
    const res = await page.evaluate(async (list, worker, args) => {
      const root = await navigator.storage.getDirectory();
      for (const top of ['addons', 'res']) try { await root.removeEntry(top, {recursive: true}); } catch (e) {}
      const dirs = new Map();
      const dirOf = async rel => { if (dirs.has(rel)) return dirs.get(rel);
        let d = root; for (const p of rel.split('/')) d = await d.getDirectoryHandle(p, {create: true}); dirs.set(rel, d); return d; };
      for (let i = 0; i < list.length; i += 32) await Promise.all(list.slice(i, i + 32).map(async rel => {
        const r = await fetch('/' + rel), k = rel.lastIndexOf('/');
        const h = await (await dirOf(rel.slice(0, k))).getFileHandle(rel.slice(k + 1), {create: true}), w = await h.createWritable();
        await w.write(await r.arrayBuffer()); await w.close(); }));
      const w = new Worker(URL.createObjectURL(new Blob([worker], {type: 'text/javascript'}))), steps = [];
      let exported = null;
      return await new Promise(ok => { w.onmessage = async e => { const m = e.data;
        if (m.step) { if (!steps.includes(m.step)) steps.push(m.step); return; }
        if (m.error) return ok({error: m.error, steps});
        // as packages.js pkgExports
        if (m.built) {
          try { const r = await PackageExports.run(new Map(m.files), oxEnv(root), oxLua, args.name);
            exported = {n: r.result.exported, failed: r.result.failed};
            w.postMessage({add: r.files.concat(r.icons).map(([rel, data]) => ['GearSwap/' + rel.slice('addons/GearSwap/'.length), data])}); }
          catch (x) { ok({error: 'exports: ' + (x && x.stack || x), steps}); }
          return;
        }
        let s = ''; const b = new Uint8Array(m.bytes); for (let i = 0; i < b.length; i += 32768) s += String.fromCharCode.apply(null, b.subarray(i, i + 32768));
        ok({b64: btoa(s), exported, steps}); };
        w.onerror = e => ok({error: 'worker: ' + e.message, steps});
        w.postMessage({root, args}); });
    }, list, WORKER, {name: NAME, jobs: null, role: null, partner: null, region: 'US'});
    const took = ((Date.now() - t0) / 1000).toFixed(1);
    if (res.error) { console.log('FAIL ' + res.error + ' (steps ' + res.steps.join(', ') + ')'); fails++; }
    else {
      if (res.exported.failed.length || !res.exported.n) { console.log(`FAIL the page's exports: ${res.exported.n} made, failed ${JSON.stringify(res.exported.failed).slice(0, 200)}`); fails++; }
      const web = path.join(TMP, 'web.zip'), cli = CLI;
      fs.writeFileSync(web, Buffer.from(res.b64, 'base64'));
      const out = py(`import zipfile, json\na, b = zipfile.ZipFile(r'${web}'), zipfile.ZipFile(r'${cli}')\n` +
        `def body(t):\n    d = json.loads(t[t.index('] = {') + 4:].strip().rstrip(';'))\n    d.pop('at', None); d.pop('src', None)\n    return d\n` +
        `same = lambda n: body(a.read(n).decode()) == body(b.read(n).decode()) if '/atelier/exports/' in n else a.read(n) == b.read(n)\n` +
        `na, nb = set(a.namelist()), set(b.namelist())\nd = sorted(n for n in na & nb if not same(n))\n` +
        `print(len(na), len(na ^ nb), len(d), sum('/atelier/exports/' in n for n in na), ', '.join(sorted(na ^ nb)[:3] + d[:3]))`).trim().split(' ');
      if (out[1] !== '0' || out[2] !== '0') { console.log(`FAIL the page's zip is not the command line's: ${out[1]} names, ${out[2]} files differ (${out.slice(4).join(' ')})`); fails++; }
      if (!ICONS.length) { console.log('FAIL the package holds no item icon'); fails++; }
      for (const s of ['python', 'read', 'clone', 'zip'])
        if (!res.steps.includes(s)) { console.log('FAIL the page is never told the step ' + s); fails++; }
      if (!fails) console.log(`${NAME}: the page's zip is the command line's (${out[0]} files, ${out[3]} exports, ${ICONS.length} icons, ${took} s in Chrome)`);
    }
    await page.evaluate(async () => { const root = await navigator.storage.getDirectory();
      for (const top of ['addons', 'res']) try { await root.removeEntry(top, {recursive: true}); } catch (e) {} });
  } finally { await browser.close(); server.close(); fs.rmSync(TMP, {recursive: true, force: true}); }
  process.exit(fails ? 1 : 0);
})().catch(e => { console.log('FAIL ' + (e && e.stack || e)); server.close(); process.exit(1); });
