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
    // a click on a slot opens its menu (trial.js): lock it, then choose a piece from it
    await tryIt('slot menu: lock, then the picker', async () => { open('sets.engaged.Naegling');
      const s = shownSet(S._cards[S.sel.WAR], S.sel.WAR), slot = () => document.querySelector('.slot[data-slot="head"]');
      slot().click(); await wait(30);
      const menu = document.querySelector('#slotmenu');
      if (!menu || menu.hidden) throw new Error('no menu on a slot click');
      menu.querySelector('[data-slotact="lock"]').click(); await wait(30);
      if (!isLocked(s, 'head') || !slot().classList.contains('locked')) throw new Error('the slot is not locked');
      if (!document.querySelector('#slotmenu').hidden) throw new Error('the menu stayed open');
      slot().click(); await wait(30); document.querySelector('#slotmenu [data-slotact="pick"]').click(); await wait(200);
      if (document.querySelector('#overlay').hidden) throw new Error('the picker did not open');
      closeOverlay(); toggleLock(s, 'head');
      if (lockedSlots(s).length) throw new Error('still locked'); });
    // a locked slot keeps what it shows through a search: a tried piece, and a slot left as the set has it
    await tryIt('locked slots survive the optimizer', async () => { open('sets.engaged.Naegling');
      const s = shownSet(S._cards[S.sel.WAR], S.sel.WAR), k = trialKey(s), name = sl => (withWeapons(s).pieces[sl] || {}).name;
      delete S.trial[k]; unlockAll(s);
      const other = ((ownedOf() || {}).head || []).find(x => x.name !== name('head') && !FFXI.opt.blocks({name: x.name}).length);
      if (!other) throw new Error('no other head piece to try');
      setTrial(s, 'head', {name: other.name, augs: other.augs}); toggleLock(s, 'head'); toggleLock(s, 'waist');
      const waist = name('waist');
      S._optScratch = false; optimizeEngaged(s);
      for (let i = 0; i < 300 && S._optBusy; i++) await wait(200);
      if (S._optBusy) { optStop(); throw new Error('still busy after 60 s'); }
      closeOverlay(); render();
      const got = [name('head'), name('waist')];
      delete S.trial[k]; unlockAll(s); render();
      if (got[0] !== other.name) throw new Error('locked head changed: ' + got[0] + ' in place of ' + other.name);
      if (got[1] !== waist) throw new Error('locked waist changed: ' + got[1] + ' in place of ' + waist); });
    // a piece left out of the searches (trial.js): not among the choices, not started from, and back with one click
    await tryIt('a piece excluded from the searches', async () => { open('sets.engaged.Naegling');
      const s = shownSet(S._cards[S.sel.WAR], S.sel.WAR), slotOf = sl => document.querySelector('.slot[data-slot="' + sl + '"]');
      const name = (withWeapons(s).pieces.neck || {}).name;
      if (!name) throw new Error('no neck piece in the set');
      const has = () => (optChoices(new Set()).neck || []).some(x => x.name === name), started = () => !!(startOf(withWeapons(s).pieces).neck);
      if (!has() || !started()) throw new Error('the neck piece is not a choice to begin with');
      slotOf('neck').click(); await wait(30); document.querySelector('#slotmenu [data-slotact="exclude"]').click(); await wait(30);
      if (!isExcluded(name) || has() || started()) throw new Error('still offered after excluding it');
      slotOf('neck').click(); await wait(30); document.querySelector('#slotmenu [data-slotact="exclude"]').click(); await wait(30);
      if (isExcluded(name) || !has()) throw new Error('not back after allowing it again');
      // left out while not held, then in the bags: allowed again by itself; left out while held: stays out
      const far = 'A piece nobody holds';
      setExcluded(far, true); if (excludedOf()[far] !== 'missing') throw new Error('a piece not held is not marked missing');
      S.excluded[S.char] = {[name]: 'missing'}; if (isExcluded(name)) throw new Error('a piece in the bags is still excluded');
      setExcluded(name, true); if (!isExcluded(name) || excludedOf()[name] !== 'owned') throw new Error('a held piece excluded on purpose came back');
      S.excluded[S.char] = {}; save(); });
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
