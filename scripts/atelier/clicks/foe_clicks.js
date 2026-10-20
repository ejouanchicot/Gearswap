// Atelier click test "foe" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  const info = () => page.evaluate(() => { const p = document.querySelector('.pbotherb'); if (!p) return 'none';
    return `tab ${(p.querySelector('[aria-selected="true"]') || {}).textContent} lit ${[...p.querySelectorAll('.foetab.on')].map(x => x.textContent).join(',')} grid ${p.querySelector('.ftabgrid').className} cells ${[...p.querySelectorAll('.fcell')].map(c => c.textContent.replace(/\s+/g, ' ') + '[' + [...c.querySelectorAll('[aria-pressed="true"]')].map(x => x.textContent).join(',') + ']').join(' | ')} on ${p.querySelectorAll('.foeon li').length} sum ${document.querySelector('.pbosum').textContent}`; });
  await page.evaluate(() => { S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'combat'; S._pbOtherOpen = true; S._foeTab = null; const b = buffState(); for (const k of Object.keys(b)) delete b[k]; render(); }); await wait(300);
  const tabs = await page.evaluate(() => [...document.querySelectorAll('.pbotherb [data-foetab]')].map(x => x.dataset.foetab));
  out.push('tabs ' + tabs.join(','));
  for (const tb of tabs) {
    await page.evaluate(tb => document.querySelector(`.pbotherb [data-foetab="${tb}"]`).click(), tb); await wait(250);
    // the first two chips of the tab, then a select if any
    for (let i = 0; i < 2; i++) { await page.evaluate(i => { const c = [...document.querySelectorAll('.pbotherb .ftabgrid .chip:not([disabled])')][i]; if (c) c.click(); }, i); await wait(250); }
    await page.evaluate(() => { const s = document.querySelector('.pbotherb .ftabgrid select'); if (s) { s.value = s.options[s.options.length - 1].value; s.dispatchEvent(new Event('input', {bubbles: true})); s.dispatchEvent(new Event('change', {bubbles: true})); } }); await wait(250);
    out.push(tb + ': ' + await info());
  }
  await page.evaluate(() => { const s = document.querySelector('.pbotherb .foetabsw button, .pbotherb .foetabsw input'); if (s) s.click(); }); await wait(300);
  out.push('switch: ' + await info());
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
