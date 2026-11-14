// Atelier click test "amroll" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
// what a player would read there, then "errors [...]", the page's errors. PAGE_URL: the page to open (a
// page_parity.js --serve address, to compare two versions); else data/atelier/index.html.
const path = require('path');
const puppeteer = require(path.join(__dirname, '../lib/browser.js')).puppeteer;
(async () => {
  const browser = await puppeteer.launch({executablePath: require(path.join(__dirname, '../lib/browser.js')).CHROME, headless: 'new', args: ['--allow-file-access-from-files']});
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
  // (2026-11-02, 4fd38384 "Buffs & target v3": a roll is a slot of the member opened, .kedit .ksl[data-pbpick], its
  // number, job and Crooked Cards chips beside it; the roll itself chosen in the slot's window, data-pbchoose)
  const rolls = () => page.evaluate(() => { const b = buffState(); return `roll1 ${b.roll1} n ${b.roll1n} job ${JSON.stringify([b.roll0job, b.roll1job])} cc ${b.rollCC} chips ${[...document.querySelectorAll('.kedit [data-rolljob], .kedit [data-rollcc]')].map(x => x.textContent + (x.getAttribute('aria-pressed') === 'true' ? '*' : '') + (x.disabled ? '-' : '') + '{' + x.title.slice(0, 20) + '}').join(' ')}`; });
  const must = sel => page.evaluate(sel => { const b = document.querySelector(sel); if (b) b.click(); else setTimeout(() => { throw new Error('missing button ' + sel); }); }, sel);
  await page.evaluate(() => { S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'combat'; const b = buffState(); for (const k of Object.keys(b)) delete b[k]; Object.assign(b, {roll0: 'Chaos', roll0n: 'XI', roll1: 'Samurai', roll1n: 'IX', rollsPlus: '8', rollCC: '0'}); b.pbMembers = ['COR']; S.pbTab = 'COR'; render(); }); await wait(300);
  out.push('COR: ' + await rolls());
  // three other rolls in the second slot's window (not the one it holds, not the first slot's), a different one each time
  for (let k = 0; k < 3; k++) {
    await must('.kedit [data-pbpick="roll1"]'); await wait(400);
    const v = await page.evaluate(k => { const b = document.querySelectorAll('[data-pbchoose^="roll1|"]:not(.on):not(.held)')[k]; if (b) b.click(); else setTimeout(() => { throw new Error('missing roll ' + k + ' in the window'); }); return b ? b.dataset.pbchoose.split('|')[1] : null; }, k); await wait(300); out.push(`roll ${v}: ` + await rolls() + ' window ' + await page.evaluate(() => !document.querySelector('#overlay').hidden));
  }
  await must('.kedit [data-rolljob="1"]:not([disabled]), .kedit [data-rolljob="0"]:not([disabled])'); await wait(300); out.push('job: ' + await rolls());
  await must('.kedit [data-rollcc="1"]'); await wait(300); out.push('cc: ' + await rolls());
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
