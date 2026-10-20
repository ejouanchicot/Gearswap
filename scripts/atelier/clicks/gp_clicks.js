// Atelier click test "gp" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
// what a player would read there, then "errors [...]", the page's errors. PAGE_URL: the page to open (a
// page_parity.js --serve address, to compare two versions); else data/atelier/index.html.
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
  const step = async (label, fn, check, ms = 400) => { try { await page.evaluate(fn); await wait(ms); out.push(label + ': ' + await page.evaluate(check)); } catch (e) { out.push(label + ': FAILED ' + String(e.message).slice(0, 120)); } };
  await page.evaluate(() => { window.INFO = () => { const d = document.querySelector('#overlay .gpdlg'); if (!d || document.querySelector('#overlay').hidden) return 'closed';
    const cards = [...d.querySelectorAll('.gpcard')]; return `cards ${cards.length} shown ${cards.filter(c => !c.hidden).length} first "${cards[0] ? cards[0].querySelector('b').textContent : '-'}" vals ${d.querySelectorAll('.gpval').length} gaps ${d.querySelectorAll('.gpval small').length} count "${d.querySelector('.gphead span').textContent}"`; }; });
  await step('open the neck', () => { S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'sets'; S.gpSrc = 'mine'; S._gpFx = ''; S.gpSort = 'rel'; render(); const s = data().sets.find(x => family(x.path, x.pieces) === 'engaged'); S.selPath[S.job] = s.path; render(); openSlot(S.sel[S.job], 'neck'); }, () => INFO() + ', focus ' + document.activeElement.id);
  await page.focus('#drawq'); await page.keyboard.type('gorget'); await wait(300);
  out.push('search "gorget": ' + await page.evaluate(() => INFO()));
  for (let i = 0; i < 6; i++) await page.keyboard.press('Backspace'); await wait(300);
  out.push('search cleared: ' + await page.evaluate(() => INFO()));
  const sel = (name, v) => () => { const s = document.querySelector(`#overlay [data-gpsel="${name}"]`); s.value = v; s.dispatchEvent(new Event('input', {bubbles: true})); s.dispatchEvent(new Event('change', {bubbles: true})); };
  await step('chosen for STP', () => { const s = document.querySelector('#overlay [data-gpsel="fx"]'); s.value = [...s.options].map(o => o.value).find(v => v) ; s.dispatchEvent(new Event('input', {bubbles: true})); s.dispatchEvent(new Event('change', {bubbles: true})); }, () => 'fx ' + S._gpFx + ', ' + INFO());
  await step('sort lowest', () => { const s = document.querySelector('#overlay [data-gpsel="sort"]'); s.value = 'lo'; s.dispatchEvent(new Event('input', {bubbles: true})); s.dispatchEvent(new Event('change', {bubbles: true})); }, () => 'sort ' + S.gpSort + ', ' + INFO());
  await step('back to any stat, A to Z', () => { let s = document.querySelector('#overlay [data-gpsel="fx"]'); s.value = ''; s.dispatchEvent(new Event('input', {bubbles: true})); s.dispatchEvent(new Event('change', {bubbles: true})); setTimeout(() => { s = document.querySelector('#overlay [data-gpsel="sort"]'); s.value = 'az'; s.dispatchEvent(new Event('input', {bubbles: true})); s.dispatchEvent(new Event('change', {bubbles: true})); }, 100); }, () => 'sort ' + S.gpSort + ', ' + INFO());
  await step('in my sets', () => document.querySelector('#overlay [data-gpsrc="sets"]').click(), () => 'src ' + S.gpSrc + ', ' + INFO());
  await step('show the useless ones', () => { const c = document.querySelector('#overlay [data-gpjunk]'); if (c) { c.checked = true; c.dispatchEvent(new Event('input', {bubbles: true})); c.dispatchEvent(new Event('change', {bubbles: true})); } window.__j = !!c; }, () => 'had ' + window.__j + ', ' + INFO());
  await step('try the 2nd card', () => document.querySelectorAll('#overlay .gpcard')[1].click(), () => 'closed ' + INFO() + ', tried ' + document.querySelectorAll('.detail .slot.tried').length);
  await step('main slot kinds', () => { S._showJunk = false; S.gpSort = 'rel'; S.gpSrc = 'mine'; openSlot(S.sel[S.job], 'main'); }, () => INFO() + ', kind menu ' + !!document.querySelector('#overlay [data-gpsel="kind"]'));
  await step('a kind', () => { const s = document.querySelector('#overlay [data-gpsel="kind"]'); if (s) { s.value = [...s.options].map(o => o.value)[1]; s.dispatchEvent(new Event('input', {bubbles: true})); s.dispatchEvent(new Event('change', {bubbles: true})); } }, () => 'kind ' + JSON.stringify(S._gpKind) + ', ' + INFO());
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
