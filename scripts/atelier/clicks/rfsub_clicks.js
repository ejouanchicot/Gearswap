// Atelier click test "rfsub" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
// what a player would read there, then "errors [...]", the page's errors. PAGE_URL: the page to open (a
// page_parity.js --serve address, to compare two versions); else data/atelier/index.html.
// The refill card's lists by subjob: a list added is edited before any save (reg_special.js rfStagedSub), a ninja
// tool (Shihei, category General) is found in the window of items, and the table written holds what was changed.
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
  await page.evaluate(() => { closeOverlay(); S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'jobcfg'; S.jobTab = 'modules'; S.modFam = 'refill'; S.modFile = null;
    S._live = Object.assign({}, S._live, {Tetsouo: Object.assign({}, S._live.Tetsouo, {ok: true, write: true})}); render(); }); await wait(400);
  // each subjob list: its title, then its items (an editor) or its summary (read only)
  const subs = () => page.evaluate(() => [...document.querySelectorAll('.rfsub')].map(r => r.querySelector('.rfsubh span').textContent + ': '
    + (r.querySelector('.rctl') ? 'edit [' + [...r.querySelectorAll('.rctl [data-rowcell$=":name"]')].map(c => c.value).join(', ') + ']'
      + ' add ' + !!r.querySelector('.rctl [data-modpick]') : 'read ' + (r.querySelector('small') || {}).textContent)).join('\n  '));
  const staged = () => page.evaluate(() => { const f = modFiles(data()).find(x => /WAR_REFILL\.lua$/.test(x.file)), e = f && modEdits(f.file);
    return e ? Object.keys(e).map(k => k + ' -> ' + e[k].after).join(' | ') + (e.subjobs ? '\n  src ' + e.subjobs.src.replace(/\s+/g, ' ') : '') : 'none'; });
  out.push('start:\n  ' + await subs() + '\n staged ' + await staged());
  // a list for /BLU: it starts as the job's list, and is edited at once
  const added = await page.evaluate(() => { const s = document.querySelector('select[data-refilladdsub]'); if (!s) return 'no select';
    s.value = 'BLU'; s.dispatchEvent(new Event('change', {bubbles: true})); return 'ok'; }); await wait(400);
  out.push('add /BLU ' + added + ':\n  ' + await subs() + '\n staged ' + await staged());
  // the window of items on /BLU's list: Shihei is there
  const blu = await page.evaluate(() => { const r = [...document.querySelectorAll('.rfsub')].find(x => /BLU/.test(x.querySelector('.rfsubh span').textContent));
    const b = r && r.querySelector('.rctl [data-modpick]'); if (!b) return 'no add button'; b.click(); return 'open'; }); await wait(300);
  out.push('pick on /BLU: ' + blu);
  if (blu === 'open') {
    await page.type('#miq', 'shihei'); await wait(300);
    out.push('  found: ' + await page.evaluate(() => [...document.querySelectorAll('#overlay .mitile')].map(b => b.dataset.mipick).join(', ')));
    const n = await page.evaluate(() => { const b = [...document.querySelectorAll('#overlay .mitile:not([disabled])')].find(x => x.dataset.mipick === 'Shihei'); if (!b) return 'none'; b.click(); return b.dataset.mipick; }); await wait(400);
    out.push('  picked ' + n + ':\n  ' + await subs() + '\n staged ' + await staged());
  }
  // a line taken out of /BLU's list (the first), then /BLU removed: nothing waits any more
  await page.evaluate(() => { const r = [...document.querySelectorAll('.rfsub')].find(x => /BLU/.test(x.querySelector('.rfsubh span').textContent)), b = r && r.querySelector('[data-rowdel]'); if (b) b.click(); }); await wait(400);
  out.push('first line of /BLU out:\n  ' + await subs() + '\n staged ' + await staged());
  await page.evaluate(() => { const r = [...document.querySelectorAll('.rfsub')].find(x => /BLU/.test(x.querySelector('.rfsubh span').textContent)), b = r && r.querySelector('[data-refilldelsub]'); if (b) b.click(); }); await wait(400);
  out.push('/BLU removed:\n  ' + await subs() + '\n staged ' + await staged());
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
