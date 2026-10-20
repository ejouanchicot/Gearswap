// Atelier click test "bd" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  const info = () => page.evaluate(() => { const ov = document.querySelector('#overlay'); const d = ov.querySelector('.dialog'); if (!d || ov.hidden) return 'closed';
    return `cls ${d.className} rows ${d.querySelectorAll('tr').length} details ${d.querySelectorAll('details').length} btns ${[...d.querySelectorAll('footer button')].map(b => b.textContent + (b.disabled ? '(off)' : '')).join('|')} text ${d.textContent.replace(/\s+/g, ' ').length}`; });
  await page.evaluate(() => { S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'perso'; S.persoView = 'bags'; S.bagSel = 'plan'; S._live = Object.assign({}, S._live, {Tetsouo: Object.assign({}, S._live.Tetsouo, {ok: true, write: true})}); render(); }); await wait(400);
  for (const sel of ['[data-plwhere]', '[data-plrun]', '[data-bpopen]', '[data-bpmule]']) {
    const there = await page.evaluate(s => { const b = document.querySelector(s); if (b) b.click(); return !!b; }, sel); await wait(300);
    out.push(`${sel} ${there}: ` + await info());
    await page.evaluate(() => { const c = document.querySelector('#overlay footer [data-close]'); if (c) c.click(); }); await wait(200);
  }
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
