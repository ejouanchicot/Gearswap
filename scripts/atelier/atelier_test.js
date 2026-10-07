// GearSwap Atelier · the page's test (for the project, never shipped to players): atelier.html opened in Chrome,
// every character / job of the exports with each of its sets and tabs, the main windows (buffs, target, the drawer on
// each slot, Compare, "+ Set"), the support profiles, four subjobs, two short searches and a stop; every page error reported.
// Run after any change to atelier.html, atelier/app/ or atelier/opt.js:
//   node scripts/atelier/atelier_test.js
// Needs Node and Puppeteer (PUPPETEER = its folder, else the one installed globally with npm) and Chrome
// (CHROME = chrome.exe, else the usual Windows path). The game is never asked: the page's fetch is stubbed.
const path = require('path');
const puppeteer = require(process.env.PUPPETEER || path.join(process.env.APPDATA || '', 'npm/node_modules/@modelcontextprotocol/server-puppeteer/node_modules/puppeteer'));
const CHROME = process.env.CHROME || 'C:/Program Files/Google/Chrome/Application/chrome.exe';
const PAGE = 'file:///' + path.resolve(__dirname, '../../atelier/index.html').split(path.sep).join('/');
(async () => {
  const browser = await puppeteer.launch({executablePath: CHROME, headless: 'new', args: ['--allow-file-access-from-files']});
  const page = await browser.newPage();
  const errors = [];
  page.on('pageerror', e => errors.push('pageerror: ' + e.message));
  page.on('console', m => { if (m.type() === 'error' && !/Failed to load resource|ERR_FILE_NOT_FOUND|net::/.test(m.text())) errors.push('console: ' + m.text()); });
  await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); });
  await page.goto(PAGE, {waitUntil: 'load'});
  await new Promise(r => setTimeout(r, 6000));
  const report = await page.evaluate(async () => {
    const out = [], wait = ms => new Promise(r => setTimeout(r, ms));
    const tryIt = async (label, fn) => { try { await fn(); out.push('ok   ' + label); } catch (e) { out.push('FAIL ' + label + ': ' + e.message + ' @ ' + (e.stack || '').split('\n')[1]); } };
    for (const c of Object.keys(DATA)) for (const j of Object.keys(DATA[c])) {
      await tryIt(`${c} ${j} every set`, async () => {
        S.char = c; S.job = j; S.section = 'sets'; render();
        const paths = (data() || {sets: []}).sets.filter(x => !x.empty).map(x => x.path);
        for (const p of paths) { S.selPath = Object.assign({}, S.selPath, {[j]: p}); S._found = null; render(); }
        for (const sec of ['keys', 'modes', 'macro', 'functions', 'merits', 'sim']) { S.section = sec; render(); }
        S.section = 'sets'; render();
      });
    }
    S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'sets';
    const open = p => { S.selPath = Object.assign({}, S.selPath, {WAR: p}); S._found = null; render(); };
    await tryIt('buffs window', async () => { open('sets.precast.WS.Upheaval'); openBuffs(); await wait(100); closeOverlay(); });
    await tryIt('target window', async () => { openTarget(); await wait(100); closeOverlay(); });
    await tryIt('drawer each slot (WS)', async () => { open('sets.precast.WS.Upheaval');
      for (const sl of SLOTS) { openSlot(S.sel.WAR, sl); await wait(20); } closeOverlay(); });
    await tryIt('drawer each slot (engaged)', async () => { open('sets.engaged.NaeglingKC');
      for (const sl of SLOTS) { openSlot(S.sel.WAR, sl); await wait(20); } closeOverlay(); });
    await tryIt('compare window', async () => { open('sets.engaged.Naegling'); openCompare(shownSet(S._cards[S.sel.WAR], S.sel.WAR)); await wait(50); closeOverlay(); });
    await tryIt('profiles Solo / Group / Full', async () => { for (const tier of ['Solo', 'Group', 'Full']) { setBuffTier(tier); render(); } });
    await tryIt('subjobs', async () => { for (const sub of ['SAM', 'DNC', 'DRG', 'NIN']) { S.subs['Tetsouo|WAR'] = sub; render(); } });
    await tryIt('optimizer engaged improve (short)', async () => {
      open('sets.engaged.Naegling'); S._optScratch = false; optimizeEngaged(shownSet(S._cards[S.sel.WAR], S.sel.WAR));
      for (let i = 0; i < 300 && S._optBusy; i++) await wait(200);
      if (S._optBusy) { optStop(); throw new Error('still busy after 60 s'); }
      closeOverlay(); render(); });
    await tryIt('optimizer WS improve (short)', async () => {
      open('sets.precast.WS.Upheaval'); S._optScratch = false; await optimizeWs(shownSet(S._cards[S.sel.WAR], S.sel.WAR));
      for (let i = 0; i < 300 && S._optBusy; i++) await wait(200);
      if (S._optBusy) { optStop(); throw new Error('still busy after 60 s'); }
      closeOverlay(); render(); });
    // "+ Set" (add_set.js): every kind of the catalog, its list, the search, the first set to create up to step 3
    await tryIt('add a set window', async () => { S.subs['Tetsouo|WAR'] = 'SAM'; render();
      if (!catalogEntries()) throw new Error('no catalog in the WAR export: run //gs c atelier on WAR');
      addStep = 0; renderAdd();
      const fams = [...document.querySelectorAll('[data-addfam]')].map(x => x.dataset.addfam);
      if (!fams.length) throw new Error('no kind offered');
      for (const f of fams) { addClick({addfam: f}); if (!document.querySelectorAll('.addrow').length) throw new Error('kind ' + f + ' lists nothing'); addStep = 0; }
      addClick({addfam: fams[0]}); addFilter('a'); addFilter('');
      const pick = document.querySelector('.addrow[data-addpick]:not([disabled])');
      if (pick) { addClick({addpick: pick.dataset.addpick}); if (!document.querySelector('[data-addfrom]')) throw new Error('step 3 empty'); }
      closeOverlay(); });
    await tryIt('stop a search at once', async () => { open('sets.engaged.Naegling'); optimizeEngaged(shownSet(S._cards[S.sel.WAR], S.sel.WAR)); await wait(300); optStop(); if (S._optBusy) throw new Error('busy after stop'); });
    return out.join('\n');
  });
  console.log(report);
  console.log(errors.length ? 'ERRORS:\n' + [...new Set(errors)].slice(0, 20).join('\n') : 'no page error');
  await browser.close();
  process.exitCode = errors.length || /^FAIL/m.test(report) ? 1 : 0;
})();
