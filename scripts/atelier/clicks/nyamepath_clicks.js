// Atelier click test "nyamepath" (scripts/atelier/clicks/README.md): searching every item of the game, a rank family's
// path (opt_page.js rankPathOf: by default the path your copies are on, Tetsouo's Nyame Path B) and your copies below
// the family's rank searched at that rank (rankRaised). Prints "errors [...]", the page's errors.
const path = require('path');
const puppeteer = require(path.join(__dirname, '../lib/browser.js')).puppeteer;
(async () => {
  const browser = await puppeteer.launch({executablePath: require(path.join(__dirname, '../lib/browser.js')).CHROME, headless: 'new', args: ['--allow-file-access-from-files']});
  const page = await browser.newPage(); const errs = []; await page.setViewport({width: 1600, height: 1000});
  page.on('pageerror', e => errs.push(e.message)); page.on('dialog', d => d.accept());
  await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); try { localStorage.clear(); localStorage.setItem('atelier', JSON.stringify({guide: {mode: 'off', seen: {tour: true}}})); } catch (e) {} });
  await page.goto(process.env.PAGE_URL || 'file:///' + path.resolve(__dirname, '../../../atelier/index.html').split(path.sep).join('/'), {waitUntil: 'load'});
  await page.waitForFunction(() => window.__atelier && window.__atelier.loaded); await new Promise(r => setTimeout(r, 4000));
  const step = async (label, fn) => console.log(label + ': ' + await page.evaluate(fn));
  await page.evaluate(() => { S.motion = false; S.char = 'Tetsouo'; S.job = 'BST'; S.section = 'sets'; S.optOpts = Object.assign({}, S.optOpts, {where: 'all'}); render(); });
  await new Promise(r => setTimeout(r, 3000));
  const look = () => {
    const ny = s => (optChoices(new Set())[s] || []).filter(x => /^Nyame/.test(x.name)).map(x => (x.missing ? 'get ' : x.maxed ? 'raised ' : 'mine ') + (x.augs || []).join('/') + ' R' + x.rank + (x.maxed ? ' (from R' + x.from.rank + ')' : '')).join(', ');
    const fam = rankFamilies().find(f => f.fam === 'Nyame') || {};
    return 'path ' + JSON.stringify(rankPathOf('Nyame')) + ' paths ' + JSON.stringify(fam.paths) + ' | head: ' + ny('head') + ' | body: ' + ny('body');
  };
  await step('default', look);
  await page.evaluate(() => setRankPath({Nyame: 'all'})); await step('all paths', look);
  await page.evaluate(() => setRankPath({Nyame: 'A'})); await step('path A', look);
  await page.evaluate(() => { setRankPath({Nyame: ''}); setRankFam({Nyame: '25'}); }); await step('R25', look);
  await page.evaluate(() => setRankFam({Nyame: '23'})); await step('R23 (lowered: the filter)', look);
  await page.evaluate(() => setRankFam({Nyame: '0'})); await step('R0', look);
  await page.evaluate(() => setRankFam({Nyame: 'off'})); await step('not unlocked (yours kept)', look);
  // the screen: the search's "Pieces" tab of a weaponskill set, the path chips by the rank chips; a click on "A"
  await page.evaluate(() => { setRankFam({Nyame: ''}); const s = data().sets.find(x => family(x.path, x.pieces) === 'ws' && !!wsOfSet(x));
    S.selPath = Object.assign({}, S.selPath, {[S.job]: s.path}); S.optView = optViewKey(s); render(); });
  await new Promise(r => setTimeout(r, 800));
  await page.evaluate(() => { const b = document.querySelector('[data-rtab="pieces"]'); if (b) b.click(); });
  await new Promise(r => setTimeout(r, 800));
  const chips = () => [...document.querySelectorAll('[data-optpath="Nyame"]')].map(b => b.textContent + (b.classList.contains('on') ? '*' : '') + ' (' + b.title + ')').join(' ') || 'none on this screen';
  await step('chips', chips);
  await page.evaluate(() => { const b = document.querySelector('[data-optpath="Nyame"][data-v="A"]'); if (b) b.click(); }); await new Promise(r => setTimeout(r, 500));
  await step('rank menu', () => { const m = document.querySelector('[data-optranksel="Nyame"]'); return m ? m.value + ' of ' + [...m.options].map(o => o.textContent).join(',') : 'none'; });
  await page.evaluate(() => { const m = document.querySelector('[data-optranksel="Nyame"]'); m.value = '17'; m.dispatchEvent(new Event('change', {bubbles: true})); }); await new Promise(r => setTimeout(r, 500));
  await step('after picking R17', () => document.querySelector('[data-optranksel="Nyame"]').value + ' saved ' + JSON.stringify(rankFamSet()));
  await step('after a click on A', () => [...document.querySelectorAll('[data-optpath="Nyame"]')].map(b => b.textContent + (b.classList.contains('on') ? '*' : '')).join(' ') + ' saved ' + JSON.stringify(rankPathSet()));
  console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
