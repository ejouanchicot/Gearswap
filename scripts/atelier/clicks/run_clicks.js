// Atelier click test "run" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
// what a player would read there, then "errors [...]", the page's errors. PAGE_URL: the page to open (a
// page_parity.js --serve address, to compare two versions); else data/atelier/index.html.
const path = require('path');
const puppeteer = require(process.env.PUPPETEER || path.join(process.env.APPDATA || '', 'npm/node_modules/@modelcontextprotocol/server-puppeteer/node_modules/puppeteer'));
(async () => {
  const browser = await puppeteer.launch({executablePath: process.env.CHROME || 'C:/Program Files/Google/Chrome/Application/chrome.exe', headless: 'new', args: ['--allow-file-access-from-files']});
  const page = await browser.newPage(); const errs = []; await page.setViewport({width: 1600, height: 1000});
  page.on('pageerror', e => errs.push(e.message)); page.on('dialog', d => d.accept());
  await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); try { localStorage.clear(); localStorage.setItem('atelier', JSON.stringify({guide: {mode: 'off', seen: {tour: true}}, motion: true})); } catch (e) {} });
  await page.goto(process.env.PAGE_URL || 'file:///' + path.resolve(__dirname, '../../../atelier/index.html').split(path.sep).join('/'), {waitUntil: 'load'});
  await page.waitForFunction(() => window.__atelier && window.__atelier.loaded); await new Promise(r => setTimeout(r, 4000));
  const out = [], wait = ms => new Promise(r => setTimeout(r, ms));
  const peek = () => page.evaluate(() => { const d = document.querySelector('#overlay .optrun'); if (!d) return 'no window (overlay hidden ' + document.querySelector('#overlay').hidden + ', parked ' + !!document.querySelector('#orpark .optrun') + ')';
    const q = s => d.querySelector(s); return `kick "${q('.kicker').textContent}" clock ${q('#orclock') ? q('#orclock').textContent : '-'} big ${(q('.orbig') || {}).textContent} gain "${(q('.orgain') || {}).textContent}" walks ${d.querySelectorAll('.orwalk').length} done ${d.querySelectorAll('.orwalk.done').length} feed ${d.querySelectorAll('.orfeed li:not(.orempty)').length} spark ${q('.orspark .line') && q('.orspark .line').getAttribute('d') ? 'yes' : 'no'} mog ${!!q('.mogscene')} finished ${d.classList.contains('finished')} result ${!!q('.orres, .muted')} footer [${[...d.querySelectorAll('footer button')].map(b => Object.keys(b.dataset)[0]).join(',')}] rate "${(q('#orrate') || {}).textContent || ''}"`; });
  await page.evaluate(() => { S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'sets'; S.motion = true; render(); const s = data().sets.find(x => family(x.path, x.pieces) === 'engaged'); S.selPath[S.job] = s.path; S.optView = optViewKey(s); render(); });
  await page.evaluate(() => document.querySelector('.oppage .optgo').click());
  await wait(1500); out.push('after 1.5 s: ' + await peek());
  await wait(2000); out.push('after 3.5 s: ' + await peek());
  await page.evaluate(() => { const b = document.querySelector('[data-moglines]'); if (b) b.click(); }); await wait(200);
  out.push('moogle lines: ' + await page.evaluate(() => { const d = document.querySelector('#overlay .optrun .body'); return d ? d.className + ' / btn ' + (document.querySelector('[data-moglines]') || {}).textContent : '-'; }));
  await page.evaluate(() => document.querySelector('[data-orhide]').click()); await wait(500);
  out.push('hidden: ' + await peek());
  out.push('page shows "show" button: ' + await page.evaluate(() => !!document.querySelector('.oppage [data-orshow]')));
  await wait(1000);
  await page.evaluate(() => document.querySelector('.oppage [data-orshow]').click()); await wait(500);
  out.push('shown again: ' + await peek());
  // wait for the end (or 120 s)
  const t0 = Date.now();
  while (Date.now() - t0 < 120000 && await page.evaluate(() => !!S._optBusy)) await wait(1000);
  await wait(1500);
  out.push('end after ' + Math.round((Date.now() - t0) / 1000) + ' s more: ' + await peek());
  out.push('result rows: ' + await page.evaluate(() => { const d = document.querySelector('#overlay .optrun'); return d ? `changes ${d.querySelectorAll('.orchg li').length} figs ${d.querySelectorAll('.orfig tbody tr').length} lack ${!!d.querySelector('.orlack')} mogwin ${!!d.querySelector('.mogwin')} toast "${(S.toast || '').slice(0, 50)}"` : '-'; }));
  const cmp = await page.evaluate(() => { const b = document.querySelector('#overlay [data-cmpopen]'); if (b) { b.click(); return true; } return false; }); await wait(800);
  out.push('compare: ' + (cmp ? await page.evaluate(() => 'window ' + !!document.querySelector('#overlay .cmpdlg, #overlay .dialog') + ', run window gone ' + !document.querySelector('#overlay .optrun')) : 'no compare button'));
  await page.evaluate(() => { if (!document.querySelector('#overlay').hidden) document.dispatchEvent(new KeyboardEvent('keydown', {key: 'Escape', bubbles: true})); }); await wait(300);
  // a second search, stopped
  await page.evaluate(() => { S.optView = optViewKey(S._curSet || data().sets.find(x => family(x.path, x.pieces) === 'engaged')); render(); const b = document.querySelector('.oppage .optgo'); if (b) b.click(); }); await wait(2000);
  out.push('second search: ' + await peek());
  await page.evaluate(() => document.querySelector('#overlay [data-optstop]').click()); await wait(1500);
  out.push('stopped: busy ' + await page.evaluate(() => !!S._optBusy) + ' | ' + await peek());
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
