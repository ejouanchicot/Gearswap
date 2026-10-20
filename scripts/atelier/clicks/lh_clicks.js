// Atelier click test "lh" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  const info = () => page.evaluate(() => `q "${S.q}" focus ${document.activeElement.id} caret ${document.activeElement.selectionStart} menu ${!!S._listMenu} items ${[...document.querySelectorAll('.listmenu .lmitem')].map(b => b.textContent + (b.getAttribute('aria-pressed') === 'true' ? '*' : '')).join('|')} paths ${!!S.listPaths} all ${!!S._listAll} open ${JSON.stringify(S.famOpen).length} rows ${document.querySelectorAll('.setlist .setrow').length} equip ${(document.querySelector('[data-equipset]') || {}).disabled}/${(document.querySelector('[data-equipset]') || {}).title} legend ${document.querySelectorAll('.lgline span.off').length}/${document.querySelectorAll('.lgline span').length} notes ${[...document.querySelectorAll('.famnote')].map(p => p.className + ':' + p.textContent.slice(0, 30)).join('|')} overlay ${!document.querySelector('#overlay').hidden}`);
  await page.evaluate(() => { S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'sets'; S.q = ''; S._listMenu = false; render(); }); await wait(300);
  out.push('start: ' + await info());
  await page.click('#setq'); await page.type('#setq', 'eng', {delay: 30}); await wait(300); out.push('typed: ' + await info());
  await page.evaluate(() => { const q = document.querySelector('#setq'); q.value = ''; q.dispatchEvent(new Event('input', {bubbles: true})); }); await wait(300);
  await page.evaluate(() => document.querySelector('[data-famall="1"]').click()); await wait(300); out.push('open all: ' + await info());
  await page.evaluate(() => document.querySelector('.foldall [data-famall="0"]').click()); await wait(300); out.push('close all: ' + await info());
  await page.evaluate(() => document.querySelector('[data-listmenu]').click()); await wait(300); out.push('menu: ' + await info());
  await page.evaluate(() => document.querySelector('.listmenu [data-listpaths]').click()); await wait(300); out.push('paths: ' + await info());
  await page.evaluate(() => { const b = document.querySelector('.listmenu [data-listall]'); if (b) b.click(); }); await wait(300); out.push('all: ' + await info());
  await page.evaluate(() => { const m = document.querySelector('[data-listmenu]'); m.click(); }); await wait(300); out.push('menu again: ' + await info());
  await page.evaluate(() => document.querySelector('[data-action="add"]').click()); await wait(300); out.push('add: ' + await info());
  await page.evaluate(() => { closeOverlay(); S.job = 'BRD'; render(); }); await wait(300); out.push('BRD: ' + await info());
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
