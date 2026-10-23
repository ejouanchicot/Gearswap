// Atelier click test "settings" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  const info = () => page.evaluate(() => `cfg ${S._cfg} theme ${S.theme}/${document.documentElement.dataset.theme} lang ${S.lang} motion ${S.motion} guide ${S.guide && S.guide.mode} pressed ${[...document.querySelectorAll('#view [aria-pressed="true"]')].map(b => b.dataset.themeSet || b.dataset.lang || b.dataset.motionSet || b.dataset.guideMode || b.dataset.engine).join(',')} text ${document.getElementById('view').textContent.replace(/\s+/g, ' ').length}`);
  await page.evaluate(() => { S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'sets'; render(); document.querySelector('[data-config]').click(); }); await wait(300);
  out.push('open: ' + await info());
  for (const sel of ['[data-theme-set="grimoire"]', '[data-lang="en"]', '[data-motion-set="off"]', '[data-guide-mode="ask"]', '[data-lang="fr"]', '[data-motion-set="on"]', '[data-theme-set="vanadiel"]', '[data-guide-mode="off"]']) {
    await page.evaluate(s => document.querySelector('#view ' + s).click(), sel); await wait(250); out.push(sel + ': ' + await info()); }
  await page.evaluate(() => new Promise(r => loadRanked(r))); await page.evaluate(() => render()); await wait(300);
  out.push('engine loaded: ' + await info() + ' engine box ' + await page.evaluate(() => [...document.querySelectorAll('#view .box h3')].map(h => h.textContent).join(' / ')));
  await page.evaluate(() => document.querySelector('#view [data-config]').click()); await wait(300); out.push('back: ' + await info());
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
