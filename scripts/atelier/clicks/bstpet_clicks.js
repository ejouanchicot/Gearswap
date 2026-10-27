// Atelier click test "bstpet" (scripts/atelier/clicks/README.md): a BST's pet engaged sets (atelier/app/js/bst_pet.js):
// where they sit, which optimizer each one opens, its objectives and the pet's figures, then a stats search run to its
// end. Prints "errors [...]", the page's errors. PAGE_URL: the page to open; else data/atelier/index.html.
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
  const step = async (label, fn, arg, check, ms = 300) => { try { await page.evaluate(fn, arg); await wait(ms); out.push(label + ': ' + await page.evaluate(check, arg)); } catch (e) { out.push(label + ': FAILED ' + String(e.message).slice(0, 120)); } };
  await page.evaluate(() => { S.motion = false; S.char = 'Tetsouo'; S.job = 'BST'; S.section = 'sets'; render(); });
  await step('where they sit', () => {}, null,
    () => ['sets.pet.engaged', 'sets.pet.engaged.PDT', 'sets.pet.engagedBoth', 'sets.pet.engagedBoth.PDT', 'sets.pet.idle', 'sets.midcast.pet_physical_moves'].map(p => {
      const s = data().sets.find(x => x.path === p);
      return s ? p.replace('sets.', '') + ' ' + cardFamily(s.path, s.pieces) + '/' + (statSet(s) ? 'stats' : roundSet(s) ? 'engaged' : '-') : p + ' absent'; }).join(', '));
  // the optimizer page of a set: the button of its card, then what the page shows
  const open = p => { S.selPath[S.job] = p; render(); const b = document.querySelector('.detail [data-optview]'); if (b) b.click(); };
  for (const p of ['sets.pet.engaged', 'sets.pet.engaged.PDT'])
    await step(p, open, p, p => {
      const s = data().sets.find(x => x.path === p), f = statFigures(s), fl = document.querySelector('.oppage [data-statfloor="petAccBase"]');
      const shown = [...document.querySelectorAll('.oppage [data-statobj]')].length;
      return 'page ' + !!document.querySelector('.oppage') + ', objectives ' + statOpts(s).objs.join(' > ') + ', objectives shown ' + shown + ', base tile ' + (fl ? fl.value : 'none')
        + ', pet lv ' + f.petLv + ' acc ' + f.petAccAll + ' (counted ' + f.petAcc + ') atk ' + f.petAtk + ' haste ' + f.petHaste + ' dt ' + f.petDt; }, 600);
  await step('sets.pet.engagedBoth', open, 'sets.pet.engagedBoth',
    p => 'page ' + !!document.querySelector('.oppage') + ', engaged objectives ' + document.querySelectorAll('.oppage [data-optobj="engObj"]').length + ', pet DT pass ' + isPetBoth(data().sets.find(x => x.path === p)), 600);
  await step('stats search on sets.pet.engaged', p => { S.selPath[S.job] = p; render(); S._optScratch = false; optimizeStats(shownSet(S._cards[S.sel[S.job]], S.sel[S.job])); }, 'sets.pet.engaged', () => 'busy ' + !!S._optBusy, 500);
  for (let i = 0; i < 240 && await page.evaluate(() => !!S._optBusy); i++) await wait(500);
  await wait(1500);
  out.push('search done: busy ' + await page.evaluate(() => !!S._optBusy) + ', toast ' + await page.evaluate(() => String(S.toast || '').replace(/\s+/g, ' ').slice(0, 220)));
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
