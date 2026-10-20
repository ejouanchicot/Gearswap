// Atelier click test "wsam2" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  const info = () => page.evaluate(() => { const b = buffState(), x = [...document.querySelectorAll('.pbbody .pbfextra')];
    return `pSav ${b.pSavagery} pNoAgoge ${b.pNoAgoge} pSamba ${b.pSamba} extras ${x.length} ${x.map(e => e.textContent.replace(/\s+/g, ' ') + ' [' + [...e.querySelectorAll('[aria-pressed="true"]')].map(c => c.textContent).join(',') + '] sel ' + ((e.querySelector('select') || {}).value)).join(' / ')}`; });
  for (const job of ['WAR', 'DNC']) {
    await page.evaluate(j => { S.char = 'Tetsouo'; S.job = 'BLM'; S.section = 'combat'; S.pbTab = j; { const b = buffState(); for (const k of Object.keys(b)) delete b[k]; } const b = buffState(); b.pbMembers = [j]; for (const ja of (pbJaJobs().get(j) || [])) { const r = jaRole(ja.name); b[r] = b[r] || {}; b[r][ja.name] = true; } render(); }, job); await wait(300);
    out.push(job + ': ' + await info());
    await page.evaluate(() => { const b = document.querySelector('.pbbody [data-savagery="3"][data-wparty]'); if (b) b.click(); }); await wait(300);
    await page.evaluate(() => { const b = document.querySelector('.pbbody [data-agoge][data-wparty]'); if (b) b.click(); }); await wait(300);
    await page.evaluate(() => { const s = document.querySelector('.pbbody [data-buff="pSamba"]'); if (s) { s.value = 'sub'; s.dispatchEvent(new Event('input', {bubbles: true})); s.dispatchEvent(new Event('change', {bubbles: true})); } }); await wait(300);
    out.push('  changed: ' + await info());
  }
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
