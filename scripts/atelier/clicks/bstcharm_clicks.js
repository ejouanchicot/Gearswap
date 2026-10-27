// Atelier click test "bstcharm" (scripts/atelier/clicks/README.md): a BST's Charm set (sets.precast.JA.Charm,
// atelier/app/js/bst_pet.js isCharmSet): laid in the page when the export has none yet, its objectives (CHR, then
// Charm+), its figures, then a stats search run to its end. Prints "errors [...]", the page's errors. PAGE_URL: the
// page to open; else data/atelier/index.html.
const path = require('path');
const puppeteer = require(process.env.PUPPETEER || path.join(process.env.APPDATA || '', 'npm/node_modules/@modelcontextprotocol/server-puppeteer/node_modules/puppeteer'));
(async () => {
  const browser = await puppeteer.launch({executablePath: process.env.CHROME || 'C:/Program Files/Google/Chrome/Application/chrome.exe', headless: 'new', args: ['--allow-file-access-from-files']});
  const page = await browser.newPage(); const errs = []; await page.setViewport({width: 1600, height: 1000});
  page.on('pageerror', e => errs.push(e.message)); page.on('dialog', d => d.accept());
  await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); try { localStorage.clear(); localStorage.setItem('atelier', JSON.stringify({guide: {mode: 'off', seen: {tour: true}}})); } catch (e) {} });
  await page.goto(process.env.PAGE_URL || 'file:///' + path.resolve(__dirname, '../../../atelier/index.html').split(path.sep).join('/'), {waitUntil: 'load'});
  await page.waitForFunction(() => window.__atelier && window.__atelier.loaded); await new Promise(r => setTimeout(r, 4000));
  const out = [], wait = ms => new Promise(r => setTimeout(r, ms));
  const step = async (label, fn, arg, check, ms = 300) => { try { await page.evaluate(fn, arg); await wait(ms); out.push(label + ': ' + await page.evaluate(check, arg)); } catch (e) { out.push(label + ': FAILED ' + String(e.message).slice(0, 160)); } };
  await page.evaluate(() => { S.motion = false; S.char = 'Tetsouo'; S.job = 'BST'; S.section = 'sets'; render(); });
  const P = 'sets.precast.JA.Charm';
  await step('the set', p => {
    const d = data();
    if (!d.sets.find(x => x.path === p)) { const ref = d.sets.find(x => x.path === 'sets.precast.JA.Spur'); d.sets.push(Object.assign({}, ref, {path: p, pieces: {}, aliases: []})); }
    render();
  }, P, p => { const s = data().sets.find(x => x.path === p); return (s ? 'present' : 'absent') + ', family ' + cardFamily(s.path, s.pieces) + ', stats set ' + statSet(s); });
  await step('objectives', () => {}, P, p => { const s = data().sets.find(x => x.path === p);
    return 'default ' + statDefault(s).join(' > ') + ', shown ' + [...statRelevant(s, [])].join(' ') + ', kept slots ' + JSON.stringify(keptSlots(s)); });
  await step('figures, empty set', () => {}, P, p => { const s = data().sets.find(x => x.path === p), f = statFigures(s);
    return 'CHR ' + f.chr + ', M.Acc ' + f.macc + ', Charm+ ' + f.charmPlus + ', length ' + f.charmDur + ' s, floor ' + JSON.stringify(statOpts(s).floor); });
  // free weapons on, as a player may have left it: the Charm set's weapons must not move
  const weapons = await page.evaluate(p => { S.optOpts = Object.assign({}, S.optOpts, {freeWeapons: true}); const w = withWeapons(data().sets.find(x => x.path === p)).pieces; return (w.main || {}).name + ' / ' + (w.sub || {}).name; }, P);
  out.push('weapons before: ' + weapons);
  const open = p => { S.selPath[S.job] = p; render(); const b = document.querySelector('.detail [data-optview]'); if (b) b.click(); };
  await step('optimizer page', open, P, () => 'page ' + !!document.querySelector('.oppage') + ', objectives shown ' + document.querySelectorAll('.oppage [data-statobj]').length, 600);
  await step('stats search', p => { S.selPath[S.job] = p; render(); S._optScratch = false; optimizeStats(shownSet(S._cards[S.sel[S.job]], S.sel[S.job])); }, P, () => 'busy ' + !!S._optBusy, 500);
  for (let i = 0; i < 240 && await page.evaluate(() => !!S._optBusy); i++) await wait(500);
  await wait(1500);
  out.push('search done: busy ' + await page.evaluate(() => !!S._optBusy) + ', toast ' + await page.evaluate(() => String(S.toast || '').replace(/\s+/g, ' ').slice(0, 260)));
  out.push('result: ' + await page.evaluate(p => { const s = shownSet(S._cards[S.sel[S.job]], S.sel[S.job]), f = statFigures(s);
    return 'CHR ' + f.chr + ', M.Acc ' + f.macc + ', Charm+ ' + f.charmPlus + ', length ' + f.charmDur + ' s, DT+PDT ' + f.pdtAll + ' | ' + Object.entries(withWeapons(s).pieces).filter(([, x]) => x && !isEmpty(x)).map(([k, x]) => k + '=' + x.name).join(', '); }, P));
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
