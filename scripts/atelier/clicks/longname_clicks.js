// Atelier click test "longname" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
// what a player would read there, then "errors [...]", the page's errors. PAGE_URL: the page to open (a
// page_parity.js --serve address, to compare two versions); else data/atelier/index.html.
// A piece found by its long name when the game cuts the short one: "cleric" finds Kaories' Clr. Torque +2 in the
// piece window, "pantaloons" finds the sets that hold Ebers Pant. (core.js nameHas, long_names_data.js).
const path = require('path');
const puppeteer = require(process.env.PUPPETEER || path.join(process.env.APPDATA || '', 'npm/node_modules/@modelcontextprotocol/server-puppeteer/node_modules/puppeteer'));
(async () => {
  const browser = await puppeteer.launch({executablePath: process.env.CHROME || 'C:/Program Files/Google/Chrome/Application/chrome.exe', headless: 'new', args: ['--allow-file-access-from-files']});
  const page = await browser.newPage(); const errs = []; await page.setViewport({width: 1600, height: 1000});
  page.on('pageerror', e => errs.push(e.message)); page.on('dialog', d => d.accept());
  await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); try { localStorage.clear(); localStorage.setItem('atelier', JSON.stringify({guide: {mode: 'off', seen: {tour: true}}})); } catch (e) {} });
  await page.goto(process.env.PAGE_URL || 'file:///' + path.resolve(__dirname, '../../../atelier/index.html').split(path.sep).join('/'), {waitUntil: 'load'});
  await page.waitForFunction(() => typeof render === 'function' && typeof openSlot === 'function'); await new Promise(r => setTimeout(r, 5000));
  const out = [], wait = ms => new Promise(r => setTimeout(r, ms));
  const shown = () => page.evaluate(() => { const d = document.querySelector('#overlay .gpdlg'); if (!d || document.querySelector('#overlay').hidden) return 'closed';
    return [...d.querySelectorAll('.gpcard')].filter(c => !c.hidden).map(c => c.querySelector('b').textContent).join(', ') || 'none'; });
  // the Cure set, where the torque is of use; sets.Kiting, where it is among the pieces of no use (drawn hidden)
  for (const set of ['sets.midcast.Cure', 'sets.Kiting']) {
    await page.evaluate(set => { closeOverlay(); S.char = 'Kaories'; S.job = 'WHM'; S.section = 'sets'; S.gpSrc = 'mine'; S._gpFx = ''; S.gpSort = 'rel'; S._showJunk = false; S.q = ''; render();
      S.selPath[S.job] = set; render(); openSlot(S.sel[S.job], 'neck'); }, set); await wait(400);
    out.push(`${set} neck window: ` + await shown());
    for (const q of ['cleric', 'clr. torque', '']) {
      await page.focus('#drawq'); await page.evaluate(() => { document.querySelector('#drawq').value = ''; }); await page.keyboard.type(q || ' '); await wait(300);
      out.push(`  search "${q}": ` + await shown());
    }
  }
  await page.evaluate(() => closeOverlay()); await wait(200);
  // the list of sets: a search by a piece's long name
  for (const q of ['pantaloons', 'ebers pant']) {
    out.push(`set list, search "${q}": ` + await page.evaluate(q => { S.q = q; render(); return (S._vis || []).length + ' sets'; }, q));
  }
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
