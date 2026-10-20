// Atelier click test "nuke" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
// what a player would read there, then "errors [...]", the page's errors. PAGE_URL: the page to open (a
// page_parity.js --serve address, to compare two versions); else data/atelier/index.html.
const path = require('path'), fs = require('fs');
const puppeteer = require(process.env.PUPPETEER || path.join(process.env.APPDATA || '', 'npm/node_modules/@modelcontextprotocol/server-puppeteer/node_modules/puppeteer'));
const V = JSON.parse(fs.readFileSync(path.resolve(__dirname, '../../..') + '/scripts/atelier/parity/opt.json', 'utf8'));
(async () => {
  const browser = await puppeteer.launch({executablePath: process.env.CHROME || 'C:/Program Files/Google/Chrome/Application/chrome.exe', headless: 'new', args: ['--allow-file-access-from-files']});
  const page = await browser.newPage(); const errs = []; await page.setViewport({width: 1600, height: 900});
  page.on('pageerror', e => errs.push(e.message));
  await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); try { localStorage.clear(); localStorage.setItem('atelier', JSON.stringify({guide: {mode: 'off', seen: {tour: true}}})); } catch (e) {} });
  await page.goto(process.env.PAGE_URL || 'file:///' + path.resolve(__dirname, '../../../atelier/index.html').split(path.sep).join('/'), {waitUntil: 'load'});
  await page.waitForFunction(() => typeof render === 'function'); await new Promise(r => setTimeout(r, 4000));
  const out = [], wait = ms => new Promise(r => setTimeout(r, ms));
  const info = () => page.evaluate(() => `sit ${(S.optOpts || {}).nukeSit} mp ${(S.optOpts || {}).nukeMpLow} sel ${(document.querySelector('[data-optopt="nukeSit"]') || {}).value} lines ${[...document.querySelectorAll('.oppage .oplocks')].map(p => p.textContent.slice(0, 40)).join(' / ')} box ${(document.querySelector('[data-optopt="nukeMpLow"]') || {}).checked}`);
  for (const n of ['nuke', 'nuke_mb']) {
    const v = V.find(([x]) => x === n)[1];
    await page.evaluate(v => { S.char = v.char; S.job = v.job; S.section = v.section; Object.assign(S, v.set || {}); if (v.path) S.selPath = Object.assign({}, S.selPath, {[v.job]: v.path}); if (v.code) (new Function(v.code))(); render(); }, v); await wait(400);
    out.push(n + ': ' + await info());
    const opts = await page.evaluate(() => { const s = document.querySelector('[data-optopt="nukeSit"]'); return s ? [...s.options].map(o => o.value) : []; });
    for (const o of opts) { await page.evaluate(o => { const s = document.querySelector('[data-optopt="nukeSit"]'); s.value = o; s.dispatchEvent(new Event('input', {bubbles: true})); s.dispatchEvent(new Event('change', {bubbles: true})); }, o); await wait(300); out.push('  ' + o + ': ' + await info()); }
    await page.evaluate(() => { const c = document.querySelector('[data-optopt="nukeMpLow"]'); if (c) c.click(); }); await wait(300); out.push('  mpLow: ' + await info());
  }
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
