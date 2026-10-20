// Atelier click test "pb" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  await page.waitForFunction(() => typeof render === 'function' && typeof pbOpenPick === 'function'); await new Promise(r => setTimeout(r, 4000));
  const out = [], wait = ms => new Promise(r => setTimeout(r, ms));
  const step = async (label, fn, check, ms = 300) => { try { await page.evaluate(fn); await wait(ms); out.push(label + ': ' + await page.evaluate(check)); } catch (e) { out.push(label + ': FAILED ' + String(e.message).slice(0, 120)); } };
  await page.evaluate(() => { window.INFO = () => { const d = document.querySelector('#overlay .pbdlg'); if (!d || document.querySelector('#overlay').hidden) return 'closed';
    const items = [...d.querySelectorAll('.pbpi')]; return `title "${d.querySelector('h3').textContent}" items ${items.filter(x => !x.hidden).length}/${items.length} groups ${[...d.querySelectorAll('.pbpg')].filter(x => !x.hidden).length} on ${d.querySelectorAll('.pbpi.on').length} none ${!!d.querySelector('footer [data-pbchoose]')} focus ${document.activeElement.className}`; }; });
  await step('open song 1', () => { S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'combat'; const b = buffState(); for (const k of Object.keys(b)) delete b[k]; b.pbMembers = ['BRD', 'COR', 'GEO']; S.pbTab = 'BRD'; render(); document.querySelector('.pbbody [data-pbpick="song0"]').click(); }, () => INFO());
  await page.keyboard.type('mar'); await wait(300);
  out.push('search "mar": ' + await page.evaluate(() => INFO()));
  await page.keyboard.type('xq'); await wait(300);
  out.push('search "marxq": ' + await page.evaluate(() => INFO()));
  for (let i = 0; i < 5; i++) await page.keyboard.press('Backspace'); await wait(200);
  out.push('cleared: ' + await page.evaluate(() => INFO()));
  await step('choose Honor March', () => document.querySelector('#overlay [data-pbchoose="song0|Honor March"]').click(), () => 'song0 ' + buffState().song0 + ', ' + INFO());
  await step('open it again: chosen one marked', () => document.querySelector('.pbbody [data-pbpick="song0"]').click(), () => INFO());
  await step('None', () => document.querySelector('#overlay footer [data-pbchoose]').click(), () => 'song0 ' + buffState().song0 + ', ' + INFO());
  await step('COR roll', () => { S.pbTab = 'COR'; render(); document.querySelector('.pbbody [data-pbpick="roll0"]').click(); }, () => INFO());
  await step('choose Chaos', () => document.querySelector('#overlay [data-pbchoose="roll0|Chaos"]').click(), () => 'roll0 ' + buffState().roll0 + ' ' + buffState().roll0n);
  await step('GEO indi', () => { S.pbTab = 'GEO'; render(); document.querySelector('.pbbody [data-pbpick="indi"]').click(); }, () => INFO());
  await page.keyboard.type('fu'); await wait(200);
  out.push('indi search "fu": ' + await page.evaluate(() => INFO()));
  await step('choose Fury', () => document.querySelector('#overlay .pbpi:not([hidden])').click(), () => 'indi ' + buffState().indi);
  await step('food', () => { S.pbTab = 'you'; render(); document.querySelector('.pbbody [data-pbpick="food"]').click(); }, () => INFO());
  await step('Escape', () => document.dispatchEvent(new KeyboardEvent('keydown', {key: 'Escape', bubbles: true})), () => INFO());
  await step('add a member', () => document.querySelector('[data-pbaddopen]').click(), () => INFO());
  await page.keyboard.type('dnc'); await wait(200);
  out.push('add search "dnc": ' + await page.evaluate(() => INFO()));
  await step('add DNC', () => document.querySelector('#overlay [data-pbadd="DNC"]').click(), () => 'members ' + JSON.stringify(buffState().pbMembers) + ', tab ' + S.pbTab + ', ' + INFO());
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
