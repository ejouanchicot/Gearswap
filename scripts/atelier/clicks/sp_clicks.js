// Atelier click test "sp" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
// what a player would read there, then "errors [...]", the page's errors. PAGE_URL: the page to open (a
// page_parity.js --serve address, to compare two versions); else data/atelier/index.html.
const path = require('path');
const puppeteer = require(process.env.PUPPETEER || path.join(process.env.APPDATA || '', 'npm/node_modules/@modelcontextprotocol/server-puppeteer/node_modules/puppeteer'));
(async () => {
  const browser = await puppeteer.launch({executablePath: process.env.CHROME || 'C:/Program Files/Google/Chrome/Application/chrome.exe', headless: 'new', args: ['--allow-file-access-from-files']});
  const page = await browser.newPage(); const errs = []; await page.setViewport({width: 1600, height: 700});
  page.on('pageerror', e => errs.push(e.message));
  await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); try { localStorage.clear(); localStorage.setItem('atelier', JSON.stringify({guide: {mode: 'off', seen: {tour: true}}})); } catch (e) {} });
  await page.goto(process.env.PAGE_URL || 'file:///' + path.resolve(__dirname, '../../../atelier/index.html').split(path.sep).join('/'), {waitUntil: 'load'});
  await page.waitForFunction(() => typeof render === 'function'); await new Promise(r => setTimeout(r, 4000));
  const out = [], wait = ms => new Promise(r => setTimeout(r, ms));
  const info = () => page.evaluate(() => { const d = document.querySelector('#overlay .statpickdlg'); if (!d || document.querySelector('#overlay').hidden) return 'closed';
    const b = d.querySelector('.body'); return `label ${d.getAttribute('aria-label')} groups ${d.querySelectorAll('section.pickcol').length} ticked ${d.querySelectorAll('.statpick:checked').length}/${d.querySelectorAll('.statpick').length} metas ${[...d.querySelectorAll('.meta')].map(m => m.textContent.split(' ')[0]).join(',')} hide ${Object.keys(S.statHide).length} scroll ${b.scrollTop} btn ${(document.querySelector('[data-statpick]') || {}).textContent}`; });
  await page.evaluate(() => { S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'sets'; S.statHide = {}; render(); openStatPick(); }); await wait(300);
  out.push('open: ' + await info());
  await page.evaluate(() => { const b = document.querySelector('#overlay .statpickdlg .body'); b.style.maxHeight = '200px'; b.scrollTop = 120; }); await wait(100);
  const sc0 = await page.evaluate(() => document.querySelector('#overlay .statpickdlg .body').scrollTop);
  await page.evaluate(() => { const x = [...document.querySelectorAll('#overlay .statpick')][10]; x.click(); }); await wait(300);
  out.push(`untick one (scroll was ${sc0}): ` + await info());
  await page.evaluate(() => [...document.querySelectorAll('#overlay .statpick')][10].click()); await wait(300);
  out.push('tick it back: ' + await info());
  await page.evaluate(() => document.querySelectorAll('#overlay [data-statgroup]')[1].click()); await wait(300);
  out.push('group none: ' + await info());
  await page.evaluate(() => document.querySelectorAll('#overlay [data-statgroup]')[0].click()); await wait(300);
  out.push('group all: ' + await info());
  await page.evaluate(() => document.querySelector('#overlay [data-statnone]').click()); await wait(300);
  out.push('none: ' + await info());
  await page.evaluate(() => document.querySelector('#overlay [data-statall]').click()); await wait(300);
  out.push('all: ' + await info());
  await page.evaluate(() => document.querySelector('#overlay footer [data-close]').click()); await wait(300);
  out.push('close: ' + await info());
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
