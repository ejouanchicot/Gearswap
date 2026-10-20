// Atelier click test "create" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  const read = () => page.evaluate(() => { const d = document.querySelector('#overlay .dialog'); return d && !document.querySelector('#overlay').hidden ? d.className + ' | ' + d.querySelector('h3').textContent + ' | ' + [...d.querySelectorAll('.body p, .diff > div')].map(x => (x.className ? x.className + ':' : '') + x.textContent).join(' / ') + ' | btn ' + [...d.querySelectorAll('footer button')].map(b => b.textContent).join(',') + ' | fold ' + !!d.querySelector('.pushtech') : 'closed'; });
  await page.evaluate(() => { S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'sets'; S._live = Object.assign({}, S._live, {Tetsouo: Object.assign({}, S._live.Tetsouo, {ok: true, write: true})}); render();
    liveFetch = async () => ({file: 'Tetsouo/war/sets/war_sets.lua', hash: 'abc', before: 'sets.precast.WS = {\n  head = "A",\n}', after: 'sets.precast.WS = {\n  head = "A",\n}\nsets.precast.WS["Aeolian Edge"] = set_combine(sets.precast.WS, {\n})'}); }); await wait(200);
  for (const kind of ['empty', 'copy']) {
    await page.evaluate(k => { const e = catalogEntries().find(x => !isThere(x) && parentThere(x) && x.base && setThere(x.base)); addStep = 2; addFam = catFamily(e); addPath = e.path; addFrom(k); }, kind); await wait(600);
    out.push(kind + ': ' + await read());
  }
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
