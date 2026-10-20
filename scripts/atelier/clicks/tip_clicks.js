// Atelier click test "tip" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  await page.evaluate(() => { S.motion = false; });
  const out = [], wait = ms => new Promise(r => setTimeout(r, ms));
  // the card as drawn: shown or not, wide or not, where, and its HTML (Svelte's empty comments left out)
  const tip = () => page.evaluate(() => { const t = document.querySelector('#tip');
    return t.hidden ? 'hidden' : `${t.className} @${t.style.left},${t.style.top} ${t.innerHTML.replace(/<!--[^>]*-->/g, '')}`; });
  const hover = async sel => { const el = await page.$(sel); if (!el) return false; await page.mouse.move(5, 5); await wait(80); await el.hover(); await wait(250); return true; };
  const jobs = [['Tetsouo', 'WAR'], ['Tetsouo', 'PLD'], ['Tetsouo', 'BLM'], ['Tetsouo', 'COR'], ['Kaories', 'GEO'], ['Tetsouo', 'THF']];
  for (const [c, j] of jobs) {
    const n = await page.evaluate((c, j) => { S.char = c; S.job = j; S.section = 'sets'; render(); return S._cards.length; }, c, j); await wait(200);
    for (let i = 0; i < n; i += Math.max(1, Math.floor(n / 4))) {
      await page.evaluate(i => { S.sel[S.job] = i; render(); }, i); await wait(300);
      const slots = await page.evaluate(() => [...document.querySelectorAll('.slot[data-slot]')].map(e => e.dataset.slot));
      for (const sl of slots) {
        if (!await hover(`.slot[data-slot="${sl}"]`)) continue;
        out.push(`${c} ${j} ${i} ${sl}: ` + await tip());
        await page.keyboard.down('Shift'); await wait(150); out.push('  shift: ' + await tip()); await page.keyboard.up('Shift'); await wait(150);
        out.push('  up: ' + await tip());
      }
      await page.mouse.move(5, 5); await wait(150); out.push('  out: ' + await tip());
    }
    // the drawer of a slot: its choices
    const open = await page.evaluate(() => { const b = document.querySelector('.slot[data-slot="body"]'); if (!b) return false; S.sel[S.job] = 0; render();
      const el = document.querySelector('.slot[data-slot="body"]'); openSlot(+el.dataset.card, 'body'); return true; }); await wait(1200);
    if (open) for (let k = 0; k < 6; k++) { if (!await hover(`.choice [data-try="${k}"]`)) break; out.push(`${c} ${j} drawer ${k}: ` + await tip());
      await page.keyboard.down('Shift'); await wait(150); out.push('  shift: ' + await tip()); await page.keyboard.up('Shift'); await wait(150); }
    await page.keyboard.press('Escape'); await wait(200);
  }
  // an optimizer's objectives (the stats one, the damage one)
  await page.evaluate(() => new Promise(r => loadRanked(r)));
  for (const [c, j, fam] of [['Tetsouo', 'PLD', 'idle'], ['Tetsouo', 'WAR', 'ws'], ['Kaories', 'RDM', 'midcast']]) {
    const p = await page.evaluate((c, j, fam) => { S.char = c; S.job = j; S.section = 'sets'; render(); const d = data() || {sets: []};
      const s = (d.sets || []).find(x => family(x.path, x.pieces) === fam && (fam !== 'ws' || wsOfSet(x))); if (!s) return null; S.selPath = Object.assign({}, S.selPath, {[S.job]: s.path}); S.optView = optViewKey(s); render(); return s.path; }, c, j, fam); await wait(600);
    const k = await page.evaluate(() => document.querySelectorAll('.opobj[data-objtip]').length);
    out.push(`${c} ${j} ${fam} ${p}: ${k} objectives`);
    for (let i = 0; i < Math.min(k, 8); i++) { await page.mouse.move(5, 5); await wait(80); const el = (await page.$$('.opobj[data-objtip]'))[i]; await el.hover(); await wait(250); out.push(`  obj ${i}: ` + await tip()); }
  }
  // the simulation's pieces
  await page.evaluate(() => { S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'sim'; S.simOpen = {}; S.optView = null; render(); }); await wait(500);
  await page.evaluate(() => { const b = document.querySelector('[data-simpick]'); if (b) b.click(); }); await wait(1500);
  const sims = await page.$$('.slot[data-simp]'); out.push('sim pieces ' + sims.length);
  for (const el of sims.slice(0, 10)) { await page.mouse.move(5, 5); await wait(80); await el.hover(); await wait(250); out.push('  simp: ' + await tip()); }
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
