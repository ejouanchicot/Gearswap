// Atelier click test "title" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  const title = () => page.evaluate(() => { const t = document.querySelector('.settitle'); if (!t) return 'none';
    return t.textContent.replace(/\s+/g, ' ') + ' | ' + [...t.querySelectorAll('[title]')].map(x => x.title.slice(0, 50)).join(' / ') + ' | btns ' + [...t.querySelectorAll('button')].map(b => Object.keys(b.dataset).join('+')).join(','); });
  for (const [c, j] of [['Tetsouo', 'WAR'], ['Tetsouo', 'RDM'], ['Kaories', 'GEO'], ['Tetsouo', 'BRD']]) {
    const n = await page.evaluate((c, j) => { S.char = c; S.job = j; S.section = 'sets'; render(); return S._cards.length; }, c, j); await wait(200);
    for (let i = 0; i < n; i += Math.max(1, Math.floor(n / 9))) {
      await page.evaluate(i => { S.sel[S.job] = i; render(); }, i); await wait(120);
      out.push(`${c} ${j} ${i}: ` + await title());
    }
  }
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
