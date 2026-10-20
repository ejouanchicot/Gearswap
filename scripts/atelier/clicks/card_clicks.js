// Atelier click test "card" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
// what a player would read there, then "errors [...]", the page's errors. PAGE_URL: the page to open (a
// page_parity.js --serve address, to compare two versions); else data/atelier/index.html.
const path = require('path');
const puppeteer = require(process.env.PUPPETEER || path.join(process.env.APPDATA || '', 'npm/node_modules/@modelcontextprotocol/server-puppeteer/node_modules/puppeteer'));
(async () => {
  const browser = await puppeteer.launch({executablePath: process.env.CHROME || 'C:/Program Files/Google/Chrome/Application/chrome.exe', headless: 'new', args: ['--allow-file-access-from-files']});
  const page = await browser.newPage(); const errs = []; await page.setViewport({width: 1600, height: 1000});
  page.on('pageerror', e => errs.push(e.message)); page.on('dialog', d => d.dismiss());
  await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); try { localStorage.clear(); localStorage.setItem('atelier', JSON.stringify({guide: {mode: 'off', seen: {tour: true}}})); } catch (e) {} });
  await page.goto(process.env.PAGE_URL || 'file:///' + path.resolve(__dirname, '../../../atelier/index.html').split(path.sep).join('/'), {waitUntil: 'load'});
  await page.waitForFunction(() => window.__atelier && window.__atelier.loaded); await new Promise(r => setTimeout(r, 2000));
  const out = [], wait = ms => new Promise(r => setTimeout(r, ms));
  const step = async (label, fn, check) => { try { await page.evaluate(fn); await wait(300); out.push(label + ': ' + await page.evaluate(check)); } catch (e) { out.push(label + ': FAILED ' + String(e.message).slice(0, 120)); } };
  await step('a set with versions', () => { S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'sets'; render(); const c = S._cards.find(c => c.fam !== 'ws' && c.variants.some(v => /Group/.test(v.label))); const g = c.variants.find(v => c.variants.some(o => o.label === v.label + ' · Group')); S.selPath = Object.assign({}, S.selPath, {[S.job]: g.set.path}); render(); },
    () => 'set ' + S.selPath[S.job] + ', slots ' + document.querySelectorAll('.detail .slot').length + ', versions ' + document.querySelectorAll('.detail .setvers button').length);
  await step('version Group', () => [...document.querySelectorAll('.detail .setvers button')].find(b => b.textContent === 'Group').click(), () => 'set ' + S.selPath[S.job] + ', pressed ' + document.querySelector('.detail .setvers button[aria-pressed="true"]').textContent + ', list row ver ' + ((document.querySelector('.setlist .setrow[aria-current="true"] .rowver') || {}).textContent || '-'));
  await step('version Full', () => [...document.querySelectorAll('.detail .setvers button')].find(b => b.textContent === 'Full').click(), () => 'set ' + S.selPath[S.job]);
  await step('slot menu', () => document.querySelector('.detail .slot[data-slot="head"]').click(), () => 'menu ' + !document.querySelector('#slotmenu').hidden + ', items ' + [...document.querySelectorAll('#slotmenu [data-slotact]')].map(b => b.dataset.slotact).join(','));
  await step('lock head', () => document.querySelector('#slotmenu [data-slotact="lock"]').click(), () => 'locked ' + document.querySelectorAll('.detail .slot.locked').length + ', padlock ' + document.querySelectorAll('.detail .slot .lk').length);
  await step('ctrl+click unlocks', () => document.querySelector('.detail .slot[data-slot="head"]').dispatchEvent(new MouseEvent('click', {bubbles: true, ctrlKey: true})), () => 'locked ' + document.querySelectorAll('.detail .slot.locked').length);
  await step('empty the body on trial', () => { document.querySelector('.detail .slot[data-slot="body"]').click(); setTimeout(() => document.querySelector('#slotmenu [data-slotact="empty"]').click(), 50); }, () => 'tried ' + document.querySelectorAll('.detail .slot.tried').length + ', reset marks ' + document.querySelectorAll('.detail .unslot').length + ', trial bar ' + (document.querySelector('.detail header').textContent.length));
  await step('reset it with its mark', () => document.querySelector('.detail .unslot').click(), () => 'tried ' + document.querySelectorAll('.detail .slot.tried').length);
  await step('pick opens the drawer', () => { document.querySelector('.detail .slot[data-slot="neck"]').click(); setTimeout(() => document.querySelector('#slotmenu [data-slotact="pick"]').click(), 50); }, () => 'overlay open ' + !document.querySelector('#overlay').hidden + ', items ' + document.querySelectorAll('#overlay button').length);
  await step('choose a piece', () => { const it = document.querySelector('#overlay [data-tryempty]'); window.__it = it ? it.outerHTML.slice(0, 80) : [...document.querySelectorAll('#overlay button')].slice(0, 4).map(b => b.outerHTML.slice(0, 70)).join(' || '); if (it) it.click(); }, () => 'clicked ' + window.__it + ' | tried ' + document.querySelectorAll('.detail .slot.tried').length + ', overlay open ' + !document.querySelector('#overlay').hidden);
  await step('close overlay', () => { if (!document.querySelector('#overlay').hidden) document.dispatchEvent(new KeyboardEvent('keydown', {key: 'Escape', bubbles: true})); }, () => 'overlay hidden ' + document.querySelector('#overlay').hidden);
  await step('weapon menu', () => { const sel = document.querySelector('.detail select.wmenu'); window.__wm = sel ? sel.value : 'none'; if (sel) { const o = [...sel.options].find(o => o.value !== sel.value); sel.value = o.value; sel.dispatchEvent(new Event('change', {bubbles: true})); } },
    () => 'was ' + window.__wm + ', now ' + (document.querySelector('.detail select.wmenu') || {value: '-'}).value + ', main ' + (document.querySelector('.detail .slot[data-slot="main"]') || {}).getAttribute('aria-label'));
  await step('optimizer opens', () => document.querySelector('.detail [data-optview]').click(), () => 'opt page back button ' + !!document.querySelector('[data-optback]') + ', detail ' + !!document.querySelector('article.detail'));
  await step('optimizer closes', () => { const c = document.querySelector('[data-optclose], [data-optback], [data-optview]'); window.__oc = c && c.outerHTML.slice(0, 60); if (c) c.click(); }, () => 'clicked ' + window.__oc + ', detail ' + !!document.querySelector('article.detail .slots'));
  await step('DNC grid', () => { S.job = 'DNC'; render(); const c = S._cards.find(c => c.fam === 'ws'), v = c.variants.find(v => v.label === 'Ruthless Stroke · Clim · Group'); S.selPath = Object.assign({}, S.selPath, {[S.job]: v.set.path}); render(); },
    () => 'grid ' + document.querySelectorAll('.detail .vergrid button').length + ', pressed ' + document.querySelectorAll('.detail .vergrid button[aria-pressed="true"]').length);
  await step('grid other cell', () => [...document.querySelectorAll('.detail .vergrid button')].find(b => b.getAttribute('aria-pressed') !== 'true').click(), () => 'set ' + S.selPath[S.job]);
  await step('other job card', () => { S.char = 'Kaories'; S.job = 'GEO'; render(); }, () => 'set ' + S.selPath[S.job] + ', slots ' + document.querySelectorAll('.detail .slot').length + ', figures ' + !!document.querySelector('.globalcol'));
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
