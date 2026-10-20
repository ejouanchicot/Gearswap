// Atelier click test "fight" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  await page.evaluate(() => { S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'sets'; render(); }); await wait(300);
  await page.evaluate(() => new Promise(r => loadRanked(r))); await wait(500);
  const box = () => page.evaluate(() => { const b = document.querySelector('.ui2own .box.g-mag'); if (!b) return 'none';
    return b.textContent.replace(/\s+/g, ' ').slice(0, 400) + ' | lis ' + b.querySelectorAll('li').length + ' tips ' + [...b.querySelectorAll('li[title]')].map(l => l.title.slice(0, 30)).join(' / ') + ' | open ' + b.querySelector('[data-fold]').getAttribute('aria-expanded'); });
  for (const [c, j] of [['Tetsouo', 'BLM'], ['Tetsouo', 'GEO'], ['Kaories', 'RDM'], ['Tetsouo', 'SCH']]) {
    const paths = await page.evaluate((c, j) => { S.char = c; S.job = j; S.section = 'sets'; render(); return ((data() || {}).sets || []).filter(x => isNukeSet(x.path)).map(x => x.path).slice(0, 4); }, c, j);
    for (const p of paths) {
      await page.evaluate(p => { S.selPath = Object.assign({}, S.selPath, {[S.job]: p}); const i = S._cards.findIndex(cd => cd.variants.some(v => v.set.path === p)); if (i >= 0) S.sel[S.job] = i; render(); }, p); await wait(300);
      out.push(`${c} ${j} ${p}: ` + await box());
    }
  }
  await page.evaluate(() => { const b = document.querySelector('.ui2own .box.g-mag [data-fold]'); if (b) b.click(); }); await wait(300);
  out.push('folded: ' + await box());
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
