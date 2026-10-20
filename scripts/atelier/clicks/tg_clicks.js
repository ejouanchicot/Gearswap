// Atelier click test "tg" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  await page.waitForFunction(() => typeof render === 'function' && typeof openTargetPick === 'function'); await new Promise(r => setTimeout(r, 5000));
  const out = [], wait = ms => new Promise(r => setTimeout(r, ms));
  const step = async (label, fn, check, ms = 300) => { try { await page.evaluate(fn); await wait(ms); out.push(label + ': ' + await page.evaluate(check)); } catch (e) { out.push(label + ': FAILED ' + String(e.message).slice(0, 120)); } };
  await page.evaluate(() => { window.INFO = () => { const d = document.querySelector('#overlay .tgdlg'); if (!d || document.querySelector('#overlay').hidden) return 'closed';
    const cards = [...d.querySelectorAll('.tgall .tgm')]; return `shown ${cards.filter(c => !c.hidden).length}/${cards.length} first "${(cards.find(c => !c.hidden) || {querySelector: () => ({textContent: '-'})}).querySelector('b').textContent}" strips ${[...d.querySelectorAll('.tgstrip')].filter(s => !s.hidden).length} none ${!d.querySelector('.tgnone').hidden} zone "${(d.querySelector('[data-tgtzone][aria-pressed="true"]') || {}).textContent}"`; }; });
  await step('open', () => { S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'combat'; S._tgtQ = ''; S._tgtZone = ''; S._tgtSort = 'zone'; render(); document.querySelector('[data-tgtpick]').click(); }, () => INFO() + ', focus ' + document.activeElement.id);
  await page.keyboard.type('ap'); await wait(300);
  out.push('typed "ap": ' + await page.evaluate(() => INFO() + ', focus ' + document.activeElement.id + ', caret ' + document.activeElement.selectionStart + ', q ' + S._tgtQ));
  await page.keyboard.type('zzz'); await wait(300);
  out.push('typed "apzzz": ' + await page.evaluate(() => INFO()));
  for (let i = 0; i < 5; i++) await page.keyboard.press('Backspace'); await wait(300);
  out.push('cleared: ' + await page.evaluate(() => INFO() + ', focus ' + document.activeElement.id));
  await step('a zone', () => document.querySelectorAll('#overlay [data-tgtzone]')[2].click(), () => INFO());
  await step('all zones', () => document.querySelector('#overlay [data-tgtzone=""]').click(), () => INFO());
  await step('order by level', () => { const s = document.querySelector('#overlay [data-tgtsort]'); s.value = 'lv'; s.dispatchEvent(new Event('input', {bubbles: true})); s.dispatchEvent(new Event('change', {bubbles: true})); }, () => 'sort ' + S._tgtSort + ', ' + INFO());
  await step('star the 2nd monster', () => document.querySelectorAll('#overlay .tgall [data-tgtfav]')[1].click(), () => 'favs ' + (S.tgtFav[S.char] || []).length + ', ' + INFO());
  await step('pick a level', () => { const b = document.querySelectorAll('#overlay .tgall [data-tgtgo]')[3]; window.__k = b.dataset.tgtgo; b.click(); }, () => 'enemy ' + (buffState().enemy === window.__k) + ', recent ' + (S.tgtRecent[S.char] || []).length + ', ' + INFO());
  await step('open again: favourites and recent', () => document.querySelector('[data-tgtpick]').click(), () => INFO());
  await step('reference target', () => document.querySelector('#overlay .tgref').click(), () => 'enemy ' + buffState().enemy + ', ' + INFO());
  await step('back button', () => { document.querySelector('[data-tgtpick]').click(); setTimeout(() => document.querySelector('#overlay [data-tgtback]').click(), 80); }, () => INFO() + ', tgtPick ' + S._tgtPick);
  await step('Escape', () => { document.querySelector('[data-tgtpick]').click(); setTimeout(() => document.dispatchEvent(new KeyboardEvent('keydown', {key: 'Escape', bubbles: true})), 80); }, () => INFO() + ', tgtPick ' + S._tgtPick);
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
