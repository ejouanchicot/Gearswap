// Atelier click test "trialbar" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  const out = {push: x => console.log(x)}, wait = ms => new Promise(r => setTimeout(r, ms));
  await page.evaluate(() => { S.motion = false; S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'sets'; S.trial = {}; S.drafts = {}; render(); }); await page.evaluate(() => new Promise(r => loadRanked(r))); await wait(400);
  const read = () => page.evaluate(() => { const b = document.querySelector('.trybar'); if (!b) return 'none';
    return b.className + ' | ' + b.textContent.replace(/\s+/g, ' ') + ' | btns ' + [...b.querySelectorAll('button')].map(x => Object.keys(x.dataset).join('+') + (x.disabled ? '-' : '') + '{' + (x.title || '').slice(0, 15) + '}').join(',') + ' | overlay ' + !document.querySelector('#overlay').hidden; });
  const pick = (fam, ws) => page.evaluate((fam, ws) => { const d = data(); const s = d.sets.find(x => family(x.path, x.pieces) === fam && (ws ? !!wsOfSet(x) : true)); S.selPath = Object.assign({}, S.selPath, {[S.job]: s.path}); render(); return s.path; }, fam, ws);
  for (const [fam, ws] of [['ws', true], ['idle', false]]) {
    out.push(fam + ' ' + await pick(fam, ws)); await wait(300);
    out.push('  start: ' + await read());
    await page.evaluate(() => { const s = ui2CurrentSet(data()); const o = data().sets.find(x => x.pieces.head && x.pieces.head.name !== (s.pieces.head || {}).name); setTrial(s, 'head', o.pieces.head); render(); }); await wait(500);
    out.push('  tried: ' + await read());
    for (const a of ['trykeep', 'trysave']) { await page.evaluate(a => { const b = document.querySelector('.trybar [data-' + a + ']'); if (b) b.click(); }, a); await wait(400); out.push('  ' + a + ': ' + await read()); }
    await page.evaluate(() => { const b = document.querySelector('.trybar [data-cmpopen]'); if (b) b.click(); }); await wait(400); out.push('  cmp: ' + await read());
    await page.evaluate(() => closeOverlay()); await wait(200);
    await page.evaluate(() => { const b = document.querySelector('.trybar [data-tryundo]'); if (b) b.click(); }); await wait(400); out.push('  undo: ' + await read());
  }
  console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
