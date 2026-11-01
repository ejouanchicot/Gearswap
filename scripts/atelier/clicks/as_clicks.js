// Atelier click test "as" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  // the "+ Set" assistant (atelier/app/js/add_wizard.js): its step, its title, what it offers
  const info = () => page.evaluate(() => { const ov = document.querySelector('#overlay'); const d = ov.querySelector('.awdlg'); if (!d || ov.hidden) return 'closed';
    const shown = sel => [...d.querySelectorAll(sel)].filter(x => !x.hidden && !(x.closest('.awgroup') || {}).hidden).length;
    return `title ${d.querySelector('h3').textContent} step ${(d.querySelector('.steps .on') || {}).textContent} tiles ${shown('[data-awfam]')} subjects ${shown('[data-awsubj]')} questions ${d.querySelectorAll('.awask').length} answers ${[...d.querySelectorAll('.awopt.on')].map(b => b.dataset.awans).join(',')} say "${(d.querySelector('.say') || {}).textContent || ''}" name ${(d.querySelector('.awrecap code') || {}).textContent || ''} from ${[...d.querySelectorAll('[data-awfrom]')].map(b => b.dataset.awfrom).join(',')} lines ${shown('.awline')}`; });
  await page.evaluate(() => { S.char = 'Kaories'; S.job = 'RDM'; S.section = 'sets'; S._live = Object.assign({}, S._live, {Kaories: Object.assign({}, S._live.Kaories, {ok: true, write: true})}); render(); }); await wait(300);
  const click = sel => page.evaluate(sel => { const b = document.querySelector('#overlay ' + sel); if (b) b.click(); return !!b; }, sel);
  await page.evaluate(() => document.querySelector('[data-action="add"]').click()); await wait(300);
  out.push('open: ' + await info());
  await click('[data-awfam="ws"]'); await wait(300);
  out.push('ws: ' + await info());
  await page.type('#awq', 'sav'); await wait(300);
  out.push('typed: ' + await info());
  await page.evaluate(() => { const q = document.querySelector('#awq'); q.value = ''; q.dispatchEvent(new Event('input', {bubbles: true})); }); await wait(300);
  await click('[data-awsubj="ws:Savage Blade"]'); await wait(300);
  out.push('Savage Blade: ' + await info());
  await click('[data-awans^="profile:Solo"]'); await wait(300);
  out.push('Solo: ' + await info());
  await click('[data-awnext]'); await wait(300);
  out.push('summary: ' + await info());
  await click('[data-back]'); await wait(300); await click('[data-back]'); await wait(300);
  out.push('back twice: ' + await info());
  await click('[data-awexpert]'); await wait(300);
  out.push('experts: ' + await info());
  await click('[data-back]'); await wait(300);
  out.push('back: ' + await info());
  await click('[data-back]'); await wait(300);
  await click('[data-awfam="idle"]'); await wait(300);
  const o = await page.evaluate(() => { const b = document.querySelector('#overlay .awchip.has'); if (!b) return 'none'; b.click(); return b.dataset.awsubj; }); await wait(300);
  out.push(`idle ${o}: ` + await info());
  const op = await page.evaluate(() => { const b = document.querySelector('#overlay [data-addopen]'); if (!b) return 'none'; b.click(); return b.dataset.addopen; }); await wait(300);
  out.push(`open ${op}: ` + await info() + ' sel ' + await page.evaluate(() => S.selPath[S.job]));
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
