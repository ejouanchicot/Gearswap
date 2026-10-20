// Atelier click test "combat" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
// what a player would read there, then "errors [...]", the page's errors. PAGE_URL: the page to open (a
// page_parity.js --serve address, to compare two versions); else data/atelier/index.html.
const path = require('path');
const puppeteer = require(process.env.PUPPETEER || path.join(process.env.APPDATA || '', 'npm/node_modules/@modelcontextprotocol/server-puppeteer/node_modules/puppeteer'));
(async () => {
  const browser = await puppeteer.launch({executablePath: process.env.CHROME || 'C:/Program Files/Google/Chrome/Application/chrome.exe', headless: 'new', args: ['--allow-file-access-from-files']});
  const page = await browser.newPage(); const errs = []; await page.setViewport({width: 1600, height: 1000});
  page.on('pageerror', e => errs.push(e.message));
  page.on('dialog', d => d.accept());
  await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); try { localStorage.clear(); } catch (e) {} });
  await page.goto(process.env.PAGE_URL || 'file:///' + path.resolve(__dirname, '../../../atelier/index.html').split(path.sep).join('/'), {waitUntil: 'load'});
  await page.waitForFunction(() => window.__atelier && window.__atelier.loaded); await new Promise(r => setTimeout(r, 3000));
  const out = [], wait = ms => new Promise(r => setTimeout(r, ms));
  const step = async (label, fn, check, arg) => { try { await page.evaluate(fn, arg); await wait(300); out.push(label + ': ' + await page.evaluate(check)); } catch (e) { out.push(label + ': FAILED ' + String(e.message).slice(0, 120)); } };
  const tabs = () => [...document.querySelectorAll('.pbtabs [data-pbtab]')].map(x => x.dataset.pbtab + (x.getAttribute('aria-selected') === 'true' ? '*' : '')).join(' ');
  await page.evaluate(() => { window.TABS = () => [...document.querySelectorAll('.pbtabs [data-pbtab]')].map(x => x.dataset.pbtab + (x.getAttribute('aria-selected') === 'true' ? '*' : '')).join(' '); });
  await step('open', () => { S.guide = {done: true, off: true}; S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'sets'; render(); document.querySelector('[data-section="combat"], .sections [data-sec="combat"], button[data-tab="combat"]')?.click(); if (S.section !== 'combat') { S.section = 'combat'; render(); } },
    () => 'section ' + S.section + ', tabs ' + TABS() + ', side setlist ' + !!document.querySelector('.combattab') + '/' + !!document.querySelector('.setlist') + ', legacy empty ' + !document.getElementById('legacyview').innerHTML);
  await step('reset all', () => document.querySelector('[data-buffreset]').click(), () => 'tabs ' + TABS() + ', reset disabled ' + document.querySelector('[data-buffreset]').disabled);
  await step('endgame buffs', () => document.querySelector('[data-buffendgame]').click(), () => 'tabs ' + TABS() + ', total rows ' + document.querySelectorAll('.pbsum li').length + ', undo ' + !!document.querySelector('[data-buffundo]'));
  await step('undo', () => document.querySelector('[data-buffundo]')?.click(), () => 'tabs ' + TABS() + ', undo ' + !!document.querySelector('[data-buffundo]'));
  await step('endgame again', () => document.querySelector('[data-buffendgame]').click(), () => 'tabs ' + TABS());
  await step('tab GEO', () => [...document.querySelectorAll('[data-pbtab]')].find(x => x.dataset.pbtab !== 'you').click(), () => 'pbTab ' + S.pbTab + ', tabs ' + TABS() + ', panel you ' + document.querySelector('.pbbody').classList.contains('pbyou') + ', panel buttons ' + document.querySelectorAll('.pbbody button, .pbbody select').length);
  await step('change a buff in the panel', () => { const s = document.querySelector('.pbbody select[data-buff]'); window.__k = s.dataset.buff; s.value = [...s.options].map(o => o.value).filter(v => v && v !== s.value)[0]; s.dispatchEvent(new Event('change', {bubbles: true})); },
    () => 'key ' + window.__k + ' = ' + buffState()[window.__k] + ', select now ' + document.querySelector(`.pbbody select[data-buff="${window.__k}"]`).value + ', undo ' + !!document.querySelector('[data-buffundo]'));
  await step('panel button', () => { const b = document.querySelector('.pbbody button[data-pbset], .pbbody button[data-pbsong], .pbbody button[data-pbgeo], .pbbody button'); window.__b = b.outerHTML.slice(0, 80); b.click(); }, () => 'clicked ' + window.__b + ' tabs ' + TABS());
  await step('remove member', () => document.querySelector('.pbtabs [data-pbdel]').click(), () => 'tabs ' + TABS() + ', pbTab ' + S.pbTab);
  await step('add open', () => document.querySelector('[data-pbaddopen]').click(), () => 'dialog ' + !!document.querySelector('.pbadddlg') + ', choices ' + document.querySelectorAll('.pbadddlg [data-pbadd]').length);
  await step('add BRD', () => (document.querySelector('.pbadddlg [data-pbadd="BRD"]') || document.querySelector('.pbadddlg [data-pbadd]')).click(), () => 'tabs ' + TABS() + ', dialog ' + !!document.querySelector('.pbadddlg'));
  await step('situation Solo', () => document.querySelector('.sittabs [data-bufftier="Solo"]').click(), () => 'tier ' + buffTier() + ', pressed ' + [...document.querySelectorAll('.sittabs [data-bufftier]')].filter(x => x.getAttribute('aria-pressed') === 'true').map(x => x.dataset.bufftier) + ', tabs ' + TABS());
  await step('situation Full', () => document.querySelector('.sittabs [data-bufftier="Full"]').click(), () => 'tier ' + buffTier() + ', tabs ' + TABS());
  await step('pick an engaged set', () => { const d = data(), x = d.sets.find(s => roundSet(s)); S.selPath = Object.assign({}, S.selPath, {[S.job]: x.path}); render(); },
    () => 'cur set ' + (S._curSet && S._curSet.path) + ', impact rows ' + document.querySelectorAll('.pbimprow').length + ', note ' + ((document.querySelector('.pbimpact .muted') || {}).textContent || '').slice(0, 30));
  await step('impact row Group', () => document.querySelector('.pbimprow[data-bufftier="Group"]')?.click(), () => 'tier ' + buffTier() + ', pressed ' + (document.querySelector('.pbimprow[aria-pressed="true"]') || {}).dataset?.bufftier);
  await step('other debuffs open', () => { const d = document.querySelector('details[data-pbother]'); d.open = true; d.dispatchEvent(new Event('toggle', {bubbles: false})); }, () => 'open ' + document.querySelector('details[data-pbother]').open + ', S ' + S._pbOtherOpen);
  await step('redraw keeps it open', () => render(), () => 'open ' + document.querySelector('details[data-pbother]').open);
  await step('profile picker', () => document.querySelector('[data-profopen]').click(), () => 'open ' + S._profOpen + ', panel ' + !!document.querySelector('.prpickwrap .prpanel, .prpickwrap [class*=prpan]'));
  await page.focus('#profq').catch(() => {}); await page.keyboard.type('so'); await wait(300);
  out.push('profile search: ' + await page.evaluate(() => 'q ' + S._profQ + ', focus ' + (document.activeElement || {}).id + ', still open ' + S._profOpen));
  await step('click outside closes', () => document.querySelector('.tabhead h2').click(), () => 'open ' + S._profOpen);
  await step('target picker', () => document.querySelector('[data-tgtpick]').click(), () => 'dialog ' + !!document.querySelector('#overlay:not([hidden])'));
  await step('close dialog', () => { const o = document.querySelector('#overlay'); const c = o.querySelector('[data-close], .dlgx, button.x'); if (c) c.click(); else document.dispatchEvent(new KeyboardEvent('keydown', {key: 'Escape', bubbles: true})); }, () => 'overlay hidden ' + document.querySelector('#overlay').hidden);
  await step('other job', () => { S.job = 'BLM'; render(); }, () => 'tabs ' + TABS() + ', impact rows ' + document.querySelectorAll('.pbimprow').length);
  await step('to sets', () => { S.section = 'sets'; render(); }, () => 'combat gone ' + !document.querySelector('.combattab') + ', legacy filled ' + !!document.getElementById('legacyview').innerHTML);
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
