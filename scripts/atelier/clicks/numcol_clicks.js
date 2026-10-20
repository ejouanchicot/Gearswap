// Atelier click test "numcol" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
// what a player would read there, then "errors [...]", the page's errors. PAGE_URL: the page to open (a
// page_parity.js --serve address, to compare two versions); else data/atelier/index.html.
const path = require('path');
const puppeteer = require(process.env.PUPPETEER || path.join(process.env.APPDATA || '', 'npm/node_modules/@modelcontextprotocol/server-puppeteer/node_modules/puppeteer'));
(async () => {
  const browser = await puppeteer.launch({executablePath: process.env.CHROME || 'C:/Program Files/Google/Chrome/Application/chrome.exe', headless: 'new', args: ['--allow-file-access-from-files']});
  const page = await browser.newPage(); const errs = []; await page.setViewport({width: 1600, height: 900});
  page.on('pageerror', e => errs.push(e.message));
  await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); try { localStorage.clear(); localStorage.setItem('atelier', JSON.stringify({guide: {mode: 'off', seen: {tour: true}}})); } catch (e) {} });
  await page.goto(process.env.PAGE_URL || 'file:///' + path.resolve(__dirname, '../../../atelier/index.html').split(path.sep).join('/'), {waitUntil: 'load'});
  await page.waitForFunction(() => typeof render === 'function'); await new Promise(r => setTimeout(r, 4000));
  const out = [], wait = ms => new Promise(r => setTimeout(r, ms));
  const edits = () => page.evaluate(() => { const e = (S._modEdits || {})[S.char] || {}; return Object.entries(e).map(([f, x]) => f.split('/').pop() + ':' + Object.entries(x).map(([k, v]) => k + '=' + JSON.stringify(v.v)).join(',')).filter(s => !s.endsWith(':')).join(' | '); });
  const counts = () => page.evaluate(() => `step ${document.querySelectorAll('#view .mcstep').length} range ${document.querySelectorAll('#view .modrange').length} std ${document.querySelectorAll('#view .mcstd').length}/${document.querySelectorAll('#view .mcstd.is').length} unit ${document.querySelectorAll('#view .mcunit').length} color ${[...document.querySelectorAll('#view .modcolor')].map(c => c.textContent).join(',')} presets ${document.querySelectorAll('#view .modpreset').length}/${document.querySelectorAll('#view .modpreset[aria-pressed="true"]').length} ranges ${[...document.querySelectorAll('#view .modrange')].map(r => r.value + '[' + r.min + '-' + r.max + ']').join(',')}`);
  const fire = (sel, v) => page.evaluate((sel, v) => { const i = document.querySelector(sel); if (!i) return false; i.value = v; i.dispatchEvent(new Event('input', {bubbles: true})); i.dispatchEvent(new Event('change', {bubbles: true})); return true; }, sel, v);
  for (const [view, fam, file] of [['simple', 'job', null], ['simple', 'hud', null], ['files', null, 'UI_CONFIG.lua'], ['files', null, 'UI_COLOR_CONFIG.lua']]) {
    await page.evaluate((view, fam, file) => { S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'jobcfg'; S.jobTab = 'modules'; S.modView = view; S.modFam = fam; S._modEdits = {};
      S.modFile = file ? (modFiles(data()).find(f => f.file.endsWith('/' + file)) || {}).file || null : null;
      S._live = Object.assign({}, S._live, {Tetsouo: Object.assign({}, S._live.Tetsouo, {ok: true, write: true})}); render(); }, view, fam, file); await wait(300);
    out.push(`${view} ${fam || file}: ` + await counts());
    await page.evaluate(() => { const b = document.querySelectorAll('#view .mcstep:not([disabled])'); if (b[1]) b[1].click(); }); await wait(250);
    await page.evaluate(() => { const b = document.querySelectorAll('#view .mcstep:not([disabled])'); if (b[2]) b[2].click(); }); await wait(250);
    await fire('#view .modrange', '50'); await wait(250);
    await page.evaluate(() => { const b = document.querySelector('#view button.mcstd'); if (b) b.click(); }); await wait(250);
    await fire('#view .modcolor input', '#123456'); await wait(250);
    await page.evaluate(() => { const b = [...document.querySelectorAll('#view .modpreset')].find(x => x.getAttribute('aria-pressed') !== 'true'); if (b) b.click(); }); await wait(250);
    out.push('  edits: ' + await edits() + ' | ' + await counts());
  }
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
