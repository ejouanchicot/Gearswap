// Atelier click test "sm" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  const info = () => page.evaluate(() => { const m = document.querySelector('#slotmenu'); if (!m || m.hidden) return 'closed';
    return `${m.textContent.replace(/\s+/g, ' ')} | at ${m.style.left},${m.style.top} focus ${document.activeElement.dataset.slotact} | locks ${JSON.stringify(S.locks)} trial ${Object.keys(S.trial || {}).length} drawer ${!!S._drawer}`; });
  const open = async slot => { await page.evaluate(s => document.querySelector('.slot[data-slot="' + s + '"][data-card]').click(), slot); await wait(250); };
  await page.evaluate(() => { S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'sets'; S.locks = {}; S.trial = {}; render(); }); await wait(300);
  for (const slot of ['head', 'main', 'ring2']) { await open(slot); out.push(slot + ': ' + await info()); }
  await page.keyboard.press('Escape'); await wait(200); out.push('escape: ' + await info());
  await open('body'); await page.evaluate(() => document.querySelector('#slotmenu [data-slotact="lock"]').click()); await wait(300);
  out.push('locked body: ' + await info()); await open('body'); out.push('body again: ' + await info());
  await page.evaluate(() => document.querySelector('#slotmenu [data-slotact="empty"]').click()); await wait(300);
  await open('body'); out.push('emptied body: ' + await info());
  await page.evaluate(() => document.querySelector('#slotmenu [data-slotact="reset"]').click()); await wait(300);
  await open('feet'); await page.evaluate(() => document.querySelector('#slotmenu [data-slotact="pick"]').click()); await wait(300);
  out.push('pick feet: ' + await info());
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
