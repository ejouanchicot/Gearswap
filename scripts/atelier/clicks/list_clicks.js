// Atelier click test "list" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
// what a player would read there, then "errors [...]", the page's errors. PAGE_URL: the page to open (a
// page_parity.js --serve address, to compare two versions); else data/atelier/index.html.
const path = require('path');
const puppeteer = require(process.env.PUPPETEER || path.join(process.env.APPDATA || '', 'npm/node_modules/@modelcontextprotocol/server-puppeteer/node_modules/puppeteer'));
(async () => {
  const browser = await puppeteer.launch({executablePath: process.env.CHROME || 'C:/Program Files/Google/Chrome/Application/chrome.exe', headless: 'new', args: ['--allow-file-access-from-files']});
  const page = await browser.newPage(); const errs = []; await page.setViewport({width: 1600, height: 1000});
  page.on('pageerror', e => errs.push(e.message)); page.on('dialog', d => d.accept());
  await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); try { localStorage.clear(); } catch (e) {} });
  await page.goto(process.env.PAGE_URL || 'file:///' + path.resolve(__dirname, '../../../atelier/index.html').split(path.sep).join('/'), {waitUntil: 'load'});
  await page.waitForFunction(() => window.__atelier && window.__atelier.loaded); await new Promise(r => setTimeout(r, 2000));
  const out = [], wait = ms => new Promise(r => setTimeout(r, ms));
  const step = async (label, fn, check) => { try { await page.evaluate(fn); await wait(250); out.push(label + ': ' + await page.evaluate(check)); } catch (e) { out.push(label + ': FAILED ' + String(e.message).slice(0, 120)); } };
  await page.evaluate(() => { window.CUR = () => { const r = document.querySelector('.setlist .setrow[aria-current="true"] b'); return (r ? r.textContent : '-') + ' [' + S.selPath[S.job] + ']'; };
    window.ROWS = () => document.querySelectorAll('.setlist .setrow').length; });
  await step('open Sets', () => { S.guide = {done: true, off: true}; S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'sets'; render(); }, () => 'rows ' + ROWS() + ', cur ' + CUR() + ', detail ' + !!document.querySelector('.detail') + ', globalcol ' + !!document.querySelector('.globalcol') + ', legacy empty ' + !document.getElementById('legacyview').innerHTML);
  await step('pick the 4th row', () => document.querySelectorAll('.setlist .setrow .tname')[3].click(), () => 'cur ' + CUR() + ', detail title ' + ((document.querySelector('.detail h2, .detail .dhead b') || {}).textContent || '').slice(0, 30));
  await step('arrow down', () => document.dispatchEvent(new KeyboardEvent('keydown', {key: 'ArrowDown', bubbles: true})), () => 'cur ' + CUR());
  await step('arrow up', () => document.dispatchEvent(new KeyboardEvent('keydown', {key: 'ArrowUp', bubbles: true})), () => 'cur ' + CUR());
  await step('close a category', () => { const f = document.querySelector('.setlist [data-famtoggle][aria-expanded="true"]'); window.__fam = f.dataset.famtoggle; f.click(); }, () => 'fam ' + window.__fam + ' open ' + document.querySelector(`.setlist [data-famtoggle="${window.__fam}"]`).getAttribute('aria-expanded') + ', rows ' + ROWS());
  await step('open it again', () => document.querySelector(`.setlist [data-famtoggle="${window.__fam}"]`).click(), () => 'open ' + document.querySelector(`.setlist [data-famtoggle="${window.__fam}"]`).getAttribute('aria-expanded') + ', rows ' + ROWS());
  await step('open all', () => document.querySelector('[data-famall="1"]').click(), () => 'rows ' + ROWS() + ', closed ' + document.querySelectorAll('.setlist [data-famtoggle][aria-expanded="false"]').length);
  await step('a weapon group', () => { const w = document.querySelector('.setlist [data-wskill]'); window.__w = w.dataset.wskill + ' ' + w.getAttribute('aria-expanded'); w.click(); }, () => 'before ' + window.__w + ', now ' + document.querySelector(`.setlist [data-wskill="${window.__w.split(' ')[0]}"]`)?.getAttribute('aria-expanded') + ', rows ' + ROWS());
  await step('pick a weaponskill row', () => { const r = [...document.querySelectorAll('.setlist .setrow.var .tname')].pop(); r.click(); }, () => 'cur ' + CUR());
  await step('alias fold', () => { const a = document.querySelector('.setlist [data-aliasfold]'); window.__a = !!a; if (a) a.click(); }, () => 'had ' + window.__a + ', alias rows ' + document.querySelectorAll('.setlist .alias').length);
  await step('pin the shown set', () => document.querySelector('.setlist .setrow[aria-current="true"] [data-listpin]').click(), () => 'own rows ' + document.querySelectorAll('.setlist .setrow.own').length + ', pinned ' + JSON.stringify(listPrefs().pins).slice(0, 80));
  await step('group picker', () => document.querySelector('.setlist .setrow:not(.own) [data-listgrp]').click(), () => 'picker ' + !!document.querySelector('.setlist .grppick') + ', S ' + S._listGrpFor);
  await page.focus('.grppick input[data-listname]').catch(() => {}); await page.keyboard.type('Mes sets'); await page.keyboard.press('Enter'); await wait(300);
  out.push('new group: ' + await page.evaluate(() => 'groups ' + listPrefs().groups.map(g => g.name + ':' + g.sets.length).join(',') + ', own heads ' + document.querySelectorAll('.setlist [data-owngrp]').length));
  await page.focus('#setq'); await page.keyboard.type('upheav'); await wait(400);
  out.push('search typed: ' + await page.evaluate(() => 'q ' + S.q + ', field ' + document.getElementById('setq').value + ', caret ' + document.getElementById('setq').selectionStart + ', focus ' + document.activeElement.id + ', rows ' + ROWS() + ', cur ' + CUR()));
  await page.keyboard.press('Escape'); await wait(300);
  out.push('Escape clears: ' + await page.evaluate(() => 'q "' + S.q + '", rows ' + ROWS()));
  await step('list menu', () => document.querySelector('[data-listmenu]').click(), () => 'menu ' + !!document.querySelector('.listmenu'));
  await step('paths on', () => document.querySelector('.listmenu [data-listpaths]').click(), () => 'listPaths ' + S.listPaths + ', codes ' + document.querySelectorAll('.setlist .setrow code').length);
  await step('paths off + all', () => { S.listPaths = false; S._listMenu = false; render(); const b = document.querySelector('[data-listall]'); window.__la = !!b; if (b) b.click(); }, () => 'had ' + window.__la + ', listAll ' + S._listAll + ', rows ' + ROWS());
  await step('hide a category', () => { const h = document.querySelector('.setlist [data-listhide]'); window.__h = h.dataset.listhide; h.click(); }, () => 'hidden ' + JSON.stringify(listPrefs().hide) + ', head gone ' + !document.querySelector(`.setlist [data-famtoggle="${window.__h}"]`));
  await step('drag a row onto another', () => { const rows = [...document.querySelectorAll('.setlist .setrow.own')]; const from = document.querySelectorAll('.setlist .setrow:not(.own)')[2], to = rows[0] || document.querySelectorAll('.setlist .setrow')[0];
      const dt = new DataTransfer(); from.dispatchEvent(new DragEvent('dragstart', {bubbles: true, dataTransfer: dt})); to.dispatchEvent(new DragEvent('dragover', {bubbles: true, cancelable: true, dataTransfer: dt})); to.dispatchEvent(new DragEvent('drop', {bubbles: true, cancelable: true, dataTransfer: dt})); from.dispatchEvent(new DragEvent('dragend', {bubbles: true, dataTransfer: dt})); },
    () => 'pins ' + listPrefs().pins.length + ', groups ' + listPrefs().groups.map(g => g.sets.length).join(','));
  await step('resize the list', () => { const g = document.querySelector('.setlist .listgrip'), r = g.getBoundingClientRect(); g.dispatchEvent(new PointerEvent('pointerdown', {bubbles: true, clientX: r.left, clientY: r.top + 5}));
      window.dispatchEvent(new PointerEvent('pointermove', {clientX: r.left + 60, clientY: r.top + 5})); window.dispatchEvent(new PointerEvent('pointerup', {})); }, () => 'listW ' + S.listW + ', style ' + document.querySelector('.setsx').style.getPropertyValue('--listw'));
  await step('redraw keeps the width', () => render(), () => 'style ' + document.querySelector('.setsx').getAttribute('style'));
  await step('other job keeps no scroll', () => { document.querySelector('.setlist .scroll').scrollTop = 400; S.job = 'BLM'; render(); }, () => 'scroll ' + document.querySelector('.setlist .scroll').scrollTop + ', cur ' + CUR());
  await step('Buffs & cible list', () => { S.section = 'combat'; render(); document.querySelectorAll('.setlist .setrow .tname')[2].click(); }, () => 'cur ' + CUR() + ', curSet ' + (S._curSet || {}).path);
  await step('back to sets', () => { S.section = 'sets'; render(); }, () => 'cur ' + CUR() + ', rows ' + ROWS());
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
