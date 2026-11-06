// Atelier click test "sheet" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
// what a player would read there, then "errors [...]", the page's errors. PAGE_URL: the page to open (a
// page_parity.js --serve address, to compare two versions); else data/atelier/index.html.
const path = require('path');
const puppeteer = require(path.join(__dirname, '../lib/browser.js')).puppeteer;
(async () => {
  const browser = await puppeteer.launch({executablePath: require(path.join(__dirname, '../lib/browser.js')).CHROME, headless: 'new', args: ['--allow-file-access-from-files']});
  const page = await browser.newPage(); const errs = []; await page.setViewport({width: 1600, height: 900});
  page.on('pageerror', e => errs.push(e.message));
  await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); try { localStorage.clear(); localStorage.setItem('atelier', JSON.stringify({guide: {mode: 'off', seen: {tour: true}}, boxOpen: {figtab: 'sheetall'}})); } catch (e) {} });
  await page.goto(process.env.PAGE_URL || 'file:///' + path.resolve(__dirname, '../../../atelier/index.html').split(path.sep).join('/'), {waitUntil: 'load'});
  await page.waitForFunction(() => typeof render === 'function'); await new Promise(r => setTimeout(r, 4000));
  const out = [], wait = ms => new Promise(r => setTimeout(r, ms));
  // every group of stats in a box of its own (Sheet.svelte): its title and tooltip, its lines; the notes under them
  const read = () => page.evaluate(() => { const g = document.querySelector('.setstats'); if (!g) return 'none';
    return [...g.querySelectorAll('.sgroup')].map(b => { const h = b.querySelector('.boxh'); return h.querySelector('h3').textContent + '{' + (h.title || '').slice(0, 10) + '} :: ' +
      [...b.querySelectorAll('li')].map(l => l.textContent + (l.title ? '{' + l.title.slice(0, 12) + '}' : '')).join(' | '); }).join(' // ') + ' NOTES ' + [...g.querySelectorAll(':scope > p')].map(p => p.textContent.slice(0, 40)).join(' / '); });
  await page.evaluate(() => { S.motion = false; S.statHide = {}; S.statOnlyWant = false; });
  for (const [c, j] of [['Tetsouo', 'WAR'], ['Tetsouo', 'PLD'], ['Kaories', 'COR'], ['Tetsouo', 'BLM']]) {
    const n = await page.evaluate((c, j) => { S.char = c; S.job = j; S.section = 'sets'; render(); return S._cards.length; }, c, j); await wait(300);
    for (let i = 0; i < n; i += Math.max(1, Math.floor(n / 6))) { await page.evaluate(i => { S.sel[S.job] = i; render(); }, i); await wait(200); out.push(`${c} ${j} ${i}: ` + await read()); }
  }
  await page.evaluate(() => { S.statHide = {acc: 1, att: 1}; S.statOnlyWant = true; render(); }); await wait(300); out.push('filtered: ' + await read());
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
