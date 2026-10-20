// Atelier click test "push" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  // the push button(s) of the trial's bar: their attributes and text
  const read = () => page.evaluate(() => [...document.querySelectorAll('.trybar [data-pushopen], .trybar [data-veropen]')]
    .map(b => `${Object.keys(b.dataset).join('+')} disabled=${b.disabled} title=${b.getAttribute('title')} class=${b.className} text=${b.innerHTML}`).join(' ; ') || 'none');
  for (const [c, j] of [['Tetsouo', 'WAR'], ['Tetsouo', 'DNC'], ['Kaories', 'COR']]) {
    const n = await page.evaluate((c, j) => { S.char = c; S.job = j; S.section = 'sets'; render(); return S._cards.length; }, c, j); await wait(200);
    for (let i = 0; i < n; i += Math.max(1, Math.floor(n / 8))) {
      for (const live of [false, true]) for (const tier of ['Full', 'Group', 'Solo']) {
        const ok = await page.evaluate((i, live, tier) => { S.sel[S.job] = i; S.trial = {};
          S._live = Object.assign({}, S._live, {[S.char]: Object.assign({}, (S._live || {})[S.char], {ok: live, write: live})});
          S.buffTier = Object.assign({}, S.buffTier, {[S.char]: tier});
          render(); const card = S._cards[i], s = shownSet(card, i), p = forceList('ring1')[0] || forceList('neck')[0];
          if (!p) return false; setTrial(s, forceList('ring1')[0] ? 'ring1' : 'neck', p); render(); return true; }, i, live, tier); await wait(250);
        if (ok) out.push(`${c} ${j} ${i} live=${live} tier=${tier} (${await page.evaluate(() => buffTier())}): ` + await read());
      }
    }
  }
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
