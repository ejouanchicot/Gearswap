// Atelier click test "pkg" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  const info = () => page.evaluate(() => `pkg ${S._pkg} name "${PKG.name}" (${(document.querySelector('#pkgname') || {}).value}) focus ${document.activeElement.id} caret ${document.activeElement.selectionStart} jobs ${PKG.jobs.join('')} box ${PKG.box} partner "${PKG.partner}" (${(document.querySelector('#pkgpartner') || {}).value}) region ${PKG.region} pressed ${document.querySelectorAll('#view [aria-pressed="true"]').length} kind ${(document.querySelector('.pkg p.small') || {}).textContent} text ${document.getElementById('view').textContent.replace(/\s+/g, ' ').length}`);
  await page.evaluate(() => { S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'sets'; render(); }); await wait(300);
  await page.evaluate(() => document.querySelector('[data-pkgopen]').click()); await wait(400);
  out.push('open: ' + await info());
  await page.evaluate(() => { PKG.known = [{name: 'Kaories', jobs: ['COR', 'GEO', 'PLD', 'RDM'], role: 'alt', overlay: true}, {name: 'Nouveau', jobs: ['WAR'], role: 'main', overlay: false}]; render(); }); await wait(200);
  await page.click('#pkgname'); await page.type('#pkgname', 'Kao', {delay: 30}); await wait(300);
  out.push('typed Kao: ' + await info());
  await page.type('#pkgname', 'ries', {delay: 30}); await wait(300);
  out.push('typed Kaories: ' + await info());
  await page.evaluate(() => document.querySelector('#view [data-pkgchar="Nouveau"]').click()); await wait(300);
  out.push('char Nouveau: ' + await info());
  await page.evaluate(() => document.querySelector('#view [data-pkgjob="BLM"]').click()); await wait(200);
  await page.evaluate(() => document.querySelector('#view [data-pkgjobs="all"]').click()); await wait(200);
  out.push('jobs all: ' + await info());
  await page.evaluate(() => document.querySelector('#view [data-pkgjobs="none"]').click()); await wait(200);
  await page.evaluate(() => document.querySelector('#view [data-pkgset="box"][data-v="main"]').click()); await wait(300);
  await page.click('#pkgpartner'); await page.type('#pkgpartner', 'Tets', {delay: 30}); await wait(300);
  out.push('partner: ' + await info());
  await page.evaluate(() => document.querySelector('#view [data-pkgset="region"][data-v="JP"]').click()); await wait(300);
  out.push('region: ' + await info());
  await page.evaluate(() => document.querySelector('#view [data-pkgmake]').click()); await wait(500);
  out.push('make (no jobs): ' + await info() + ' msg ' + await page.evaluate(() => PKG.state + ' ' + PKG.msg));
  await page.evaluate(() => document.querySelector('#view [data-pkgopen]').click()); await wait(300);
  out.push('back: ' + await info());
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
