// Atelier click test "selreset" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  const pick = (sel, v) => page.evaluate((sel, v) => { const s = document.querySelector(sel); if (!s) return false; s.value = v; s.dispatchEvent(new Event('input', {bubbles: true})); s.dispatchEvent(new Event('change', {bubbles: true})); return true; }, sel, v);
  await page.evaluate(() => { S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'combat'; S.pbTab = 'you'; const b = buffState(); for (const k of Object.keys(b)) delete b[k]; render(); }); await wait(300);
  await pick('.pbfam [data-buff="am"]', '3'); await wait(300);
  out.push('am picked: state ' + await page.evaluate(() => buffState().am + ' shown ' + document.querySelector('.pbfam [data-buff="am"]').value));
  await page.evaluate(() => { const b = buffState(); delete b.am; render(); }); await wait(300);
  out.push('am cleared elsewhere: state ' + await page.evaluate(() => buffState().am + ' shown "' + document.querySelector('.pbfam [data-buff="am"]').value + '"'));
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
