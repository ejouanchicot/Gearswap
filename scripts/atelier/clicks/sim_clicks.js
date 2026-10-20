// Atelier click test "sim" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  const info = () => page.evaluate(() => { const st = simState();
    return `st ${JSON.stringify(st)} busy ${!!S._simBusy} open ${JSON.stringify(S.simOpen)} groups ${[...document.querySelectorAll('[data-simgroup]')].map(b => b.textContent + (b.getAttribute('aria-expanded') === 'true' ? '+' : '')).join(',')} rows ${document.querySelectorAll('[data-simpick]').length} cur ${(document.querySelector('[data-simpick][aria-current="true"]') || {}).textContent} pressed ${[...document.querySelectorAll('#view [aria-pressed="true"]')].map(b => b.textContent).join(',')} focus ${document.activeElement.id || document.activeElement.className} caret ${document.activeElement.selectionStart} tpin ${(document.querySelector('.tpin') || {}).value} modesopen ${(document.querySelector('.simmodes') || {}).open}`; });
  await page.evaluate(() => {
    S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'sim'; S.simOpen = {}; S.sim = {};
    S._live = Object.assign({}, S._live, {Tetsouo: Object.assign({}, S._live.Tetsouo, {ok: true, job: 'WAR', version: 7})});
    S._simActions = {key: 'Tetsouo|7', list: {magic: {'Healing Magic': ['Cure', 'Cure II'], 'Enhancing Magic': ['Protect', 'Shell']}, ja: ['Berserk', 'Provoke'], ws: ['Upheaval', 'Savage Blade'], ra: true, aim: {Cure: 'me ally', Provoke: 'enemy', Upheaval: 'enemy'}}, at: Date.now()};
    S._simBuffs = {key: 'Tetsouo|7', opts: {buffs: ['Berserk', 'Haste']}, at: Date.now()}; render(); }); await wait(300);
  out.push('open: ' + await info());
  await page.evaluate(() => document.querySelectorAll('[data-simgroup]')[0].click()); await wait(200);
  out.push('group: ' + await info());
  await page.click('#simq'); await page.type('#simq', 'up', {delay: 30}); await wait(300);
  out.push('typed: ' + await info());
  await page.evaluate(() => document.querySelector('[data-simpick]').click()); await wait(300);
  out.push('picked: ' + await info());
  for (const sel of ['[data-simopt="target|enemy"]', '[data-simopt="status|Idle"]', '[data-simbuff="Haste"]', '[data-simopt="tp|1000"]']) {
    const ok = await page.evaluate(s => { const b = document.querySelector(s); if (b) b.click(); return !!b; }, sel); await wait(250); out.push(sel + ' ' + ok + ': ' + await info()); }
  await page.evaluate(() => document.querySelector('.simrecasts').click()); await wait(250); out.push('recasts: ' + await info());
  await page.evaluate(() => { document.querySelector('.simmodes').open = true; const s = document.querySelector('[data-simstate]'); s.value = s.options[s.options.length - 1].value; s.dispatchEvent(new Event('input', {bubbles: true})); s.dispatchEvent(new Event('change', {bubbles: true})); }); await wait(300);
  out.push('mode: ' + await info());
  await page.evaluate(() => { const t = document.querySelector('.tpin'); if (t) { t.value = '1550'; t.dispatchEvent(new Event('change', {bubbles: true})); t.dispatchEvent(new Event('input', {bubbles: true})); } }); await wait(300);
  out.push('tp typed: ' + await info());
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
