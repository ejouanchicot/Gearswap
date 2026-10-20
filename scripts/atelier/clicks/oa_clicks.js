// Atelier click test "oa" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
// what a player would read there, then "errors [...]", the page's errors. PAGE_URL: the page to open (a
// page_parity.js --serve address, to compare two versions); else data/atelier/index.html.
const path = require('path'), fs = require('fs');
const puppeteer = require(process.env.PUPPETEER || path.join(process.env.APPDATA || '', 'npm/node_modules/@modelcontextprotocol/server-puppeteer/node_modules/puppeteer'));
const V = JSON.parse(fs.readFileSync(path.resolve(__dirname, '../../..') + '/scripts/atelier/parity/dialogs.json', 'utf8'));
(async () => {
  const browser = await puppeteer.launch({executablePath: process.env.CHROME || 'C:/Program Files/Google/Chrome/Application/chrome.exe', headless: 'new', args: ['--allow-file-access-from-files']});
  const page = await browser.newPage(); const errs = []; await page.setViewport({width: 1600, height: 500});
  page.on('pageerror', e => errs.push(e.message));
  await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); try { localStorage.clear(); localStorage.setItem('atelier', JSON.stringify({guide: {mode: 'off', seen: {tour: true}}})); } catch (e) {} });
  await page.goto(process.env.PAGE_URL || 'file:///' + path.resolve(__dirname, '../../../atelier/index.html').split(path.sep).join('/'), {waitUntil: 'load'});
  await page.waitForFunction(() => typeof render === 'function' && typeof oaPaint === 'function'); await new Promise(r => setTimeout(r, 4000));
  const out = [], wait = ms => new Promise(r => setTimeout(r, ms));
  const view = V.find(([n]) => n === 'OA_done')[1];
  await page.evaluate(v => { S.char = v.char; S.job = v.job; S.section = v.section; (new Function(v.code))(); }, view); await wait(300);
  const info = () => page.evaluate(() => { const d = document.querySelector('#overlay .oadlg'); return d ? `big ${d.querySelector('.orbig').textContent} ticks ${[...d.querySelectorAll('[data-oasel]')].map(b => b.textContent).join('')} on rows ${d.querySelectorAll('tr.oaon').length} scroll ${d.querySelector('.oascroll').scrollTop}` : 'closed'; });
  out.push('opened: ' + await info());
  await page.evaluate(() => { const s = document.querySelector('#overlay .oascroll'); s.scrollTop = 40; }); await wait(100);
  await page.evaluate(() => document.querySelectorAll('#overlay [data-oasel]')[0].click()); await wait(300);
  out.push('untick the first: ' + await info());
  await page.evaluate(() => document.querySelectorAll('#overlay [data-oasel]')[0].click()); await wait(300);
  out.push('tick it again: ' + await info());
  await page.evaluate(() => document.querySelector('#overlay footer [data-close]').click()); await wait(300);
  out.push('closed: ' + await info() + ', optAll ' + await page.evaluate(() => !!S._optAll));
  await page.evaluate(() => { S.section = 'sets'; render(); const s = shownSet(S._cards[S.sel[S.job]], S.sel[S.job]); const o = data().sets.find(x => x.pieces.head && x.pieces.head.name !== (s.pieces.head || {}).name); S.trial = {[trialKey(s)]: {head: o.pieces.head}}; openLua(s); }); await wait(300);
  out.push('lua: ' + await page.evaluate(() => { const b = document.querySelector('#luabox'); return 'box ' + !!b + ' lines ' + (b ? b.value.split('\n').length : 0) + ' label ' + document.querySelector('#overlay .dialog').getAttribute('aria-label'); }));
  await page.evaluate(() => document.querySelector('#overlay [data-copylua]').click()); await wait(300);
  out.push('copy: ' + await page.evaluate(() => document.querySelector('#overlay [data-copylua]').textContent));
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
