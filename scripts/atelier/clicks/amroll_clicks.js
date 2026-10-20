// Atelier click test "amroll" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  const am = () => page.evaluate(() => { const r = document.querySelector('.pbfam'); const b = buffState();
    return `am ${b.am} stage ${b.amStage} tp ${b.amTp} selects ${r ? [...r.querySelectorAll('select')].map(s => s.dataset.buff + '=' + s.value + '(' + [...s.options].map(o => o.textContent).join(',') + ')').join(' ') : 'none'} said ${(document.querySelector('.amwho') || {}).textContent}`; });
  for (const [c, j] of [['Tetsouo', 'WAR'], ['Tetsouo', 'BLM'], ['Kaories', 'COR'], ['Tetsouo', 'DNC']]) {
    await page.evaluate((c, j) => { S.char = c; S.job = j; S.section = 'combat'; S.pbTab = 'you'; const b = buffState(); for (const k of Object.keys(b)) delete b[k]; render(); }, c, j); await wait(300);
    out.push(`${c} ${j}: ` + await am());
    await pick('.pbfam [data-buff="am"]', '3'); await wait(300); out.push('  Lv3: ' + await am());
    await pick('.pbfam [data-buff="amTp"]', '2000'); await pick('.pbfam [data-buff="amStage"]', 'IV'); await wait(300); out.push('  tp/stage: ' + await am());
  }
  const rolls = () => page.evaluate(() => { const b = buffState(); return `roll1 ${b.roll1} n ${b.roll1n} job ${JSON.stringify(b.rollJob)} cc ${b.rollCC} chips ${[...document.querySelectorAll('.pbbody [data-rolljob], .pbbody [data-rollcc]')].map(x => x.textContent + (x.getAttribute('aria-pressed') === 'true' ? '*' : '') + (x.disabled ? '-' : '') + '{' + x.title.slice(0, 20) + '}').join(' ')}`; });
  await page.evaluate(() => { S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'combat'; const b = buffState(); for (const k of Object.keys(b)) delete b[k]; Object.assign(b, {roll0: 'Chaos', roll0n: 'XI', roll1: 'Samurai', roll1n: 'IX', rollsPlus: '8', rollCC: '0'}); b.pbMembers = ['COR']; S.pbTab = 'COR'; render(); }); await wait(300);
  out.push('COR: ' + await rolls());
  const r1 = await page.evaluate(() => { const s = document.querySelector('.pbbody [data-buff="roll1"]'); return s ? [...s.options].map(o => o.value).filter(Boolean).slice(0, 3) : []; });
  for (const v of r1) { await pick('.pbbody [data-buff="roll1"]', v); await wait(300); out.push(`roll ${v}: ` + await rolls()); }
  await page.evaluate(() => { const b = document.querySelector('.pbbody [data-rolljob="1"]:not([disabled]), .pbbody [data-rolljob="0"]:not([disabled])'); if (b) b.click(); }); await wait(300); out.push('job: ' + await rolls());
  await page.evaluate(() => { const b = document.querySelector('.pbbody [data-rollcc="1"]'); if (b) b.click(); }); await wait(300); out.push('cc: ' + await rolls());
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
