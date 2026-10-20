// Atelier click test "dlg" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  await page.waitForFunction(() => window.__atelier && window.__atelier.loaded); await new Promise(r => setTimeout(r, 4000));
  const out = [], wait = ms => new Promise(r => setTimeout(r, ms));
  const step = async (label, fn, check, ms = 300) => { try { await page.evaluate(fn); await wait(ms); out.push(label + ': ' + await page.evaluate(check)); } catch (e) { out.push(label + ': FAILED ' + String(e.message).slice(0, 120)); } };
  await page.evaluate(() => { window.DLG = () => { const d = document.querySelector('#overlay .dialog'); return d && !document.querySelector('#overlay').hidden ? d.className.replace('dialog ', '') : 'none'; }; });
  await step('trial + compare button', () => { S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'sets'; render(); const s = data().sets.find(x => family(x.path, x.pieces) === 'engaged'); S.selPath[S.job] = s.path; render();
      const cur = shownSet(S._cards[S.sel[S.job]], S.sel[S.job]), o = data().sets.find(x => x.pieces.head && x.pieces.head.name !== (cur.pieces.head || {}).name); S.trial = {[trialKey(cur)]: {head: o.pieces.head}}; render();
      document.querySelector('[data-cmpopen]').click(); },
    () => 'dialog ' + DLG() + ', columns ' + document.querySelectorAll('#overlay .cmptbl thead th').length + ', chg cells ' + document.querySelectorAll('#overlay td.chg').length + ', best ' + document.querySelectorAll('#overlay td.best').length);
  await step('fold the other stats open', () => document.querySelector('#overlay [data-cmpmore]').click(), () => 'more ' + S._cmpMore + ', rows ' + document.querySelectorAll('#overlay tr').length + ', label ' + document.querySelector('#overlay [data-cmpmore]').textContent.slice(0, 20));
  await step('fold closed', () => document.querySelector('#overlay [data-cmpmore]').click(), () => 'more ' + S._cmpMore + ', rows ' + document.querySelectorAll('#overlay tr').length);
  await step('keep a draft then compare', () => { const cur = shownSet(S._cards[S.sel[S.job]], S.sel[S.job]); S.drafts = {[trialKey(cur)]: {kept: [{name: 'Brouillon 1', tr: {feet: data().sets.find(x => x.pieces.feet).pieces.feet}}]}}; openCompare(cur); },
    () => 'columns ' + document.querySelectorAll('#overlay .cmptbl:first-of-type thead th').length + ', kept actions ' + document.querySelectorAll('#overlay [data-keptload]').length);
  await step('load the draft', () => document.querySelector('#overlay [data-keptload]').click(), () => 'dialog ' + DLG() + ', trial feet ' + !!(S.trial[trialKey(shownSet(S._cards[S.sel[S.job]], S.sel[S.job]))] || {}).feet);
  await step('compare again, delete the draft', () => { openCompare(shownSet(S._cards[S.sel[S.job]], S.sel[S.job])); setTimeout(() => { const b = document.querySelector('#overlay [data-keptdel]'); if (b) b.click(); }, 50); },
    () => 'kept left ' + ((S.drafts[trialKey(shownSet(S._cards[S.sel[S.job]], S.sel[S.job]))] || {}).kept || []).length + ', dialog ' + DLG());
  await step('stat picker button', () => { const b = document.querySelector('#overlay h3 button'); window.__sp = b && b.outerHTML.slice(0, 60); if (b) b.click(); }, () => 'btn ' + window.__sp + ' | dialog ' + DLG());
  await step('close with the button', () => { openCompare(shownSet(S._cards[S.sel[S.job]], S.sel[S.job])); setTimeout(() => document.querySelector('#overlay footer [data-close]').click(), 50); }, () => 'dialog ' + DLG());
  await step('close with the scrim', () => { openCompare(shownSet(S._cards[S.sel[S.job]], S.sel[S.job])); setTimeout(() => document.querySelector('#overlay .scrim').click(), 50); }, () => 'dialog ' + DLG());
  await step('close with Escape', () => { openCompare(shownSet(S._cards[S.sel[S.job]], S.sel[S.job])); setTimeout(() => document.dispatchEvent(new KeyboardEvent('keydown', {key: 'Escape', bubbles: true})), 50); }, () => 'dialog ' + DLG());
  await step('song picker, focus on its search', () => { S.section = 'combat'; const b = buffState(); b.pbMembers = ['BRD']; S.pbTab = 'BRD'; render(); document.querySelector('.pbbody [data-pbpick="song0"]').click(); },
    () => 'dialog ' + DLG() + ', focus ' + (document.activeElement || {}).className + ', choices ' + document.querySelectorAll('#overlay [data-pbchoose]').length);
  await page.keyboard.type('minuet'); await wait(300);
  out.push('song search: ' + await page.evaluate(() => 'shown ' + [...document.querySelectorAll('#overlay .pbpi')].filter(x => !x.hidden).length + ', groups ' + [...document.querySelectorAll('#overlay .pbpg')].filter(x => !x.hidden).length));
  await step('choose Minuet V', () => document.querySelector('#overlay [data-pbchoose="song0|Minuet V"]').click(), () => 'song0 ' + buffState().song0 + ', dialog ' + DLG());
  await step('a slot\'s pieces window', () => { S.section = 'sets'; render(); document.querySelector('.detail .slot[data-slot="neck"]').click(); setTimeout(() => document.querySelector('#slotmenu [data-slotact="pick"]').click(), 50); },
    () => 'dialog ' + DLG() + ', items ' + document.querySelectorAll('#overlay button').length + ', focus ' + (document.activeElement || {}).tagName);
  await step('its source "the whole game"', () => document.querySelector('#overlay [data-gpsrc="game"]').click(), () => 'src ' + S.gpSrc + ', dialog ' + DLG() + ', items ' + document.querySelectorAll('#overlay button').length);
  await step('empty the slot from it', () => document.querySelector('#overlay [data-tryempty]').click(), () => 'dialog ' + DLG() + ', tried ' + document.querySelectorAll('.detail .slot.tried').length);
  await step('target picker', () => { S.section = 'combat'; render(); document.querySelector('[data-tgtpick]').click(); }, () => 'dialog ' + DLG());
  await step('pick a target', () => { const b = document.querySelector('#overlay [data-tgtset], #overlay [data-tgt], #overlay .tgrow button, #overlay [data-enemy]'); window.__tg = b && b.outerHTML.slice(0, 70); if (b) b.click(); }, () => 'clicked ' + window.__tg + ' | enemy ' + buffState().enemy + ', dialog ' + DLG());
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
