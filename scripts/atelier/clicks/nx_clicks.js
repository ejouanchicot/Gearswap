// Atelier click test "nx" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  const info = () => page.evaluate(() => `char ${S.char} job ${S.job} section ${S.section} text ${document.getElementById('view').textContent.replace(/\s+/g, ' ').slice(0, 120)}`);
  for (const [c, j, sec] of [['Kaories', 'WAR', 'sets'], ['Hysoka', 'BLM', 'sim'], ['Tetsouo', 'WAR', 'merits'], ['Tetsouo', 'WAR', 'sim']]) {
    await page.evaluate((c, j, sec) => { S.char = c; S.job = j; S.section = sec; render(); }, c, j, sec); await wait(300);
    out.push(`${c} ${j} ${sec}: ` + await info());
  }
  await page.evaluate(() => { S.char = 'Kaories'; S.job = 'WAR'; S.section = 'sets'; render(); document.querySelector('#view [data-char]').click(); }); await wait(400);
  out.push('other char: ' + await info());
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
