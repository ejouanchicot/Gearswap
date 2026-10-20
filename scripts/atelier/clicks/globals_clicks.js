// Atelier click test "globals" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  const read = sel => page.evaluate(sel => { const g = document.querySelector(sel); if (!g) return 'none';
    return [...g.querySelectorAll('section.box')].map(b => b.querySelector('h3').textContent + '[' + ((b.querySelector('.meta') || {}).textContent || '') + ']: ' + [...b.querySelectorAll('li')].map(l => l.textContent + (l.title ? '{' + l.title.slice(0, 15) + '}' : '') + (l.querySelector('u') ? '~' + l.querySelector('u').getAttribute('style').replace(/\s/g, '') : '')).join(' | ')).join(' // ') + ' NOTE ' + ((g.querySelector('.note-m') || {}).textContent || ''); }, sel);
  await page.evaluate(() => { S.motion = false; S._ui2AllOpen = true; S.boxOpen = Object.assign({}, S.boxOpen, {you: true, attr: true, caps: true}); }); 
  for (const [c, j] of [['Tetsouo', 'WAR'], ['Tetsouo', 'PLD'], ['Kaories', 'COR'], ['Tetsouo', 'BLM'], ['Hysoka', 'RUN']]) {
    await page.evaluate((c, j) => { S.char = c; S.job = j; S.section = 'sets'; render(); }, c, j); await wait(400);
    out.push(`${c} ${j} sets: ` + await read('.ui2all .globals'));
    await page.evaluate(() => { S.section = 'perso'; S.persoView = 'stats'; render(); }); await wait(400);
    out.push(`${c} ${j} perso: ` + await read('.persogrid'));
  }
  await page.evaluate(() => { S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'sets'; render(); document.querySelector('.ui2all [data-fold="attr"]').click(); }); await wait(300);
  out.push('folded attr: ' + await read('.ui2all .globals'));
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
