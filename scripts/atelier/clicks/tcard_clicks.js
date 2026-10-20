// Atelier click test "tcard" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  const card = () => page.evaluate(() => { const c = document.querySelector('.tgcard'); if (!c) return 'none';
    return c.textContent.replace(/\s+/g, ' ') + ' | ' + [...c.querySelectorAll('[title]')].map(x => x.title.slice(0, 40)).join(' / ') + ' | ' + [...c.querySelectorAll('u')].map(u => u.getAttribute('style')).join(',') + ' | ' + c.querySelector('.tghit').className; });
  const keys = await page.evaluate(() => Object.keys(TARGETS).filter((k, i) => i % 40 === 0).slice(0, 8));
  for (const k of keys) {
    await page.evaluate(k => { S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'combat'; S._pbOtherOpen = true; const b = buffState(); for (const x of Object.keys(b)) delete b[x]; b.enemy = k; b.dia = 'Dia II'; b.foeJa = ['Armor Break']; render(); }, k); await wait(250);
    out.push(k + ': ' + await card());
  }
  await page.evaluate(() => document.querySelector('.pbotherb [data-poff]').click()); await wait(300);
  out.push('switch off: ' + await card() + ' sw ' + await page.evaluate(() => { const s = document.querySelector('.pbotherb [data-poff]'); return s.getAttribute('aria-pressed') + ' ' + s.getAttribute('aria-label') + ' ' + JSON.stringify(buffState().off); }));
  await page.evaluate(() => document.querySelector('.tgcard [data-tgtpick]').click()); await wait(300);
  out.push('pick: ' + await page.evaluate(() => !document.querySelector('#overlay').hidden && !!document.querySelector('#overlay .tgdlg')));
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
