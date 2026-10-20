// Atelier click test "prof" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  await page.waitForFunction(() => window.__atelier && window.__atelier.loaded); await new Promise(r => setTimeout(r, 2000));
  const out = [], wait = ms => new Promise(r => setTimeout(r, ms));
  const step = async (label, fn, check) => { try { await page.evaluate(fn); await wait(300); out.push(label + ': ' + await page.evaluate(check)); } catch (e) { out.push(label + ': FAILED ' + String(e.message).slice(0, 120)); } };
  await page.evaluate(() => { window.ROWS = () => [...document.querySelectorAll('.prpanel .prrow2[data-q]')].filter(r => !r.hidden).map(r => r.querySelector('b').textContent).join(','); });
  await step('Buffs & cible', () => { S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'combat'; S.pbPresets = {}; S.pbActive = {}; render(); }, () => 'bar ' + !!document.querySelector('.profbar') + ', sits ' + document.querySelectorAll('.sittabs .prsit').length + ', none text ' + !!document.querySelector('.profbar .prnone'));
  await step('new profile button', () => document.querySelector('.profbar [data-profedit="new"]').click(), () => 'input ' + !!document.querySelector('.profbar input[data-profname="new"]') + ', focus ' + (document.activeElement || {}).dataset?.profname);
  await page.keyboard.type('Sortie'); await page.keyboard.press('Enter'); await wait(300);
  out.push('saved: ' + await page.evaluate(() => 'profiles ' + Object.keys(profAll()).join(',') + ', active ' + profActive() + ', button ' + document.querySelector('.profbar .prpickbtn span').textContent));
  await step('second profile', () => { buffState().indi = 'Haste'; S._profEdit = 'new'; render(); }, () => 'input ' + !!document.querySelector('input[data-profname="new"]') + ', modified mark ' + !!document.querySelector('.profbar .prpickbtn em') + ', update btn ' + !!document.querySelector('.profbar [data-profupdate]'));
  await page.focus('input[data-profname="new"]'); await page.keyboard.type('Odyssey'); await page.keyboard.press('Enter'); await wait(300);
  out.push('saved 2: ' + await page.evaluate(() => 'profiles ' + Object.keys(profAll()).join(',') + ', active ' + profActive()));
  await step('modify then update', () => { buffState().indi = 'Fury'; render(); document.querySelector('.profbar [data-profupdate]').click(); }, () => 'Odyssey indi ' + profAll().Odyssey.indi + ', still modified ' + !!document.querySelector('.profbar .prpickbtn em'));
  await step('open the picker', () => document.querySelector('.profbar [data-profopen]').click(), () => 'panel ' + !!document.querySelector('.prpanel') + ', rows ' + ROWS() + ', focus ' + document.activeElement.id);
  await page.focus('#profq'); await page.keyboard.type('ody'); await wait(400);
  out.push('search: ' + await page.evaluate(() => 'q ' + S._profQ + ', rows ' + ROWS() + ', focus ' + document.activeElement.id + ', caret ' + document.activeElement.selectionStart + ', nomatch hidden ' + document.querySelector('.prnomatch').hidden));
  await page.keyboard.type('zz'); await wait(300);
  out.push('search none: ' + await page.evaluate(() => 'rows "' + ROWS() + '", nomatch hidden ' + document.querySelector('.prnomatch').hidden + ', sections shown ' + [...document.querySelectorAll('.prsec')].filter(s => !s.hidden).length));
  for (let i = 0; i < 5; i++) await page.keyboard.press('Backspace'); await wait(300);
  await step('situation filter Full', () => document.querySelector('.prtiers [data-proftier="Full"]').click(), () => 'tier ' + S._profTier + ', pressed ' + document.querySelector('.prtiers [aria-pressed="true"]').textContent + ', rows ' + ROWS());
  await step('filter all', () => document.querySelector('.prtiers [data-proftier=""]').click(), () => 'rows ' + ROWS());
  await step('star Sortie', () => [...document.querySelectorAll('.prpanel .prrow2')].find(r => r.querySelector('b').textContent === 'Sortie').querySelector('[data-proffav]').click(), () => 'fav ' + !!profAll().Sortie._fav + ', fav chips ' + document.querySelectorAll('.profbar .prfav').length + ', sections ' + [...document.querySelectorAll('.prsec h5')].map(h => h.firstChild.textContent).join('/'));
  await step('rename Odyssey', () => [...document.querySelectorAll('.prpanel .prrow2')].find(r => r.querySelector('b') && r.querySelector('b').textContent === 'Odyssey').querySelector('[data-profedit]').click(), () => 'rename input ' + !!document.querySelector('input[data-profname="rename:Odyssey"]') + ', focus ' + (document.activeElement.dataset || {}).profname);
  await page.keyboard.press('End'); await page.keyboard.type(' 2'); await page.keyboard.press('Enter'); await wait(300);
  out.push('renamed: ' + await page.evaluate(() => 'profiles ' + Object.keys(profAll()).join(',') + ', active ' + profActive()));
  await step('load Sortie', () => { S._profOpen = 'full'; render(); [...document.querySelectorAll('.prpanel [data-profload]')].find(b => b.querySelector('b').textContent === 'Sortie').click(); }, () => 'active ' + profActive() + ', picker closed ' + !document.querySelector('.prpanel') + ', toast ' + (S.toast || '').slice(0, 30));
  await step('delete Odyssey 2', () => { S._profOpen = 'full'; render(); [...document.querySelectorAll('.prpanel .prrow2')].find(r => r.querySelector('b') && r.querySelector('b').textContent === 'Odyssey 2').querySelector('[data-profdel]').click(); }, () => 'profiles ' + Object.keys(profAll()).join(','));
  await step('click outside closes', () => document.querySelector('.tabhead h2').click(), () => 'open ' + S._profOpen);
  await step('situation Solo (big)', () => document.querySelector('.sittabs [data-bufftier="Solo"]').click(), () => 'tier ' + buffTier() + ', pressed ' + document.querySelector('.sittabs [aria-pressed="true"] b').textContent);
  await step('Sets line', () => { S.section = 'sets'; render(); }, () => 'ctxbar ' + !!document.querySelector('.ctxbar') + ', sits ' + document.querySelectorAll('.ctxbar .prsit').length + ', pressed ' + document.querySelector('.ctxbar .prsit[aria-pressed="true"] b').textContent + ', picker ' + document.querySelector('.ctxbar .prpickbtn span').textContent);
  await step('compact situation Full', () => document.querySelector('.ctxbar [data-bufftier="Full"]').click(), () => 'tier ' + buffTier());
  await step('compact picker', () => document.querySelector('.ctxbar [data-profopen]').click(), () => 'open ' + S._profOpen + ', panel rows ' + ROWS());
  await step('compact load', () => document.querySelector('.ctxbar .prpanel [data-profload]').click(), () => 'active ' + profActive() + ', closed ' + !document.querySelector('.ctxbar .prpanel'));
  await step('Modifier link', () => document.querySelector('.ctxbar [data-section="combat"]').click(), () => 'section ' + S.section);
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
