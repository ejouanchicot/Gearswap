// Atelier click test "bstreward" (scripts/atelier/clicks/README.md): a BST's Reward set (atelier/app/js/bst_pet.js
// isRewardSet): its objectives (Reward potency to its +50 % cap, MND, HP), the pet food kept in the ammo slot, each
// Jackcoat's potency, then a stats search run to its end with the pet food still there. Prints "errors [...]", the
// page's errors. PAGE_URL: the page to open; else data/atelier/index.html.
const path = require('path');
const puppeteer = require(path.join(__dirname, '../lib/browser.js')).puppeteer;
(async () => {
  const browser = await puppeteer.launch({executablePath: require(path.join(__dirname, '../lib/browser.js')).CHROME, headless: 'new', args: ['--allow-file-access-from-files']});
  const page = await browser.newPage(); const errs = []; await page.setViewport({width: 1600, height: 1000});
  page.on('pageerror', e => errs.push(e.message)); page.on('dialog', d => d.accept());
  await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); try { localStorage.clear(); localStorage.setItem('atelier', JSON.stringify({guide: {mode: 'off', seen: {tour: true}}})); } catch (e) {} });
  await page.goto(process.env.PAGE_URL || 'file:///' + path.resolve(__dirname, '../../../atelier/index.html').split(path.sep).join('/'), {waitUntil: 'load'});
  await page.waitForFunction(() => window.__atelier && window.__atelier.loaded); await new Promise(r => setTimeout(r, 4000));
  const out = [], wait = ms => new Promise(r => setTimeout(r, ms));
  out.push(await page.evaluate(() => {
    S.motion = false; S.char = 'Tetsouo'; S.job = 'BST'; S.section = 'sets'; render();
    const s = data().sets.find(x => x.path === 'sets.precast.JA.Reward');
    if (!s) return 'the set: absent';
    const pot = n => withVec({name: n}, 'body', s).st.reward || 0;
    return 'the set: reward set ' + isRewardSet(s) + ', objectives ' + statOpts(s).objs.join(' > ') + ', kept ' + keptSlots(s).join(',') + ', ammo ' + (s.pieces.ammo || {}).name
      + '\npotency: Tot. Jackcoat +3 ' + pot('Tot. Jackcoat +3') + ', An. Jackcoat +3 ' + pot('An. Jackcoat +3') + ', Ankusa Gaiters +3 ' + (withVec({name: 'Ankusa Gaiters +3'}, 'feet', s).st.reward || 0)
      + ', Ogre Gloves (BG Wiki) ' + (withVec({name: 'Ogre Gloves'}, 'hands', s).st.reward || 0)
      + '\nrecast: Khimaira Bonnet ' + (withVec({name: 'Khimaira Bonnet'}, 'head', s).st.rewardrec || 0) + ' s, Ankusa Trousers +3 ' + (withVec({name: 'Ankusa Trousers +3'}, 'legs', s).st.rewardrec || 0)
      + ' s, Tot. Trousers +3 ' + (withVec({name: 'Tot. Trousers +3'}, 'legs', s).st.rewardrec || 0) + ' s'
      + '\nfigures: potency ' + statFigures(s).rewardPot + ' % (cap 50), recast -' + statFigures(s).rewardRecast + ' s (cap 23), MND ' + statFigures(s).mnd;
  }));
  await page.evaluate(() => { const s = data().sets.find(x => x.path === 'sets.precast.JA.Reward'); S.selPath[S.job] = s.path; render(); S._optScratch = false; optimizeStats(shownSet(S._cards[S.sel[S.job]], S.sel[S.job])); });
  await wait(800);
  for (let i = 0; i < 240 && await page.evaluate(() => !!S._optBusy); i++) await wait(500);
  await wait(1500);
  out.push(await page.evaluate(() => {
    const s = data().sets.find(x => x.path === 'sets.precast.JA.Reward'), now = withWeapons(s).pieces, f = statFigures(s);
    return 'search done: busy ' + !!S._optBusy + ', ammo ' + (now.ammo || {}).name + ', potency ' + f.rewardPot + ' %, recast -' + f.rewardRecast + ' s, ailments ' + f.rewardCure + ' (floor ' + JSON.stringify(statOpts(s).floor.min) + '), MND ' + f.mnd
      + '\nproposed: ' + ['ammo', 'head', 'body', 'hands', 'legs', 'feet', 'back'].map(k => k + '=' + ((now[k] || {}).name || '-')).join(', ')
      + '\ntoast ' + String(S.toast || '').replace(/\s+/g, ' ').slice(0, 220);
  }));
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
