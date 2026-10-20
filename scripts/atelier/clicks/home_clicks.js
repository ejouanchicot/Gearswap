// Atelier click test "home" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  const info = () => page.evaluate(() => `job ${S.job} section ${S.section} rows ${document.querySelectorAll('#view tr[data-job]').length} text ${document.getElementById('view').textContent.replace(/\s+/g, ' ').slice(0, 160)}`);
  for (const c of ['Tetsouo', 'Kaories', 'Hysoka']) {
    await page.evaluate(c => { S.char = c; S.job = null; S.section = 'sets'; render(); }, c); await wait(300);
    out.push(c + ': ' + await info());
  }
  await page.evaluate(() => document.querySelectorAll('#view tr[data-job]')[1].click()); await wait(400);
  out.push('row clicked: ' + await info());
  await page.evaluate(() => { S.job = null; window.__chars = Object.assign({}, CHARS); delete CHARS[S.char]; render(); }); await wait(300);
  out.push('welcome: ' + await info());
  await page.evaluate(() => { window.showDirectoryPicker = undefined; document.querySelector('[data-wcread]').click(); }); await wait(300);
  out.push('read (no browser support): ' + await info() + ' state ' + await page.evaluate(() => WELCOME.state + ' ' + document.querySelector('#view .kwarn, #view .muted:last-child').textContent.slice(0, 60)));
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
