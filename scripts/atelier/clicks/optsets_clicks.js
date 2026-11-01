// Atelier click test "optsets" (scripts/atelier/clicks/README.md): "Tout optimiser" (atelier/app/js/opt_sets.js,
// notes/docs-perso/tout-optimiser-2026-11-01/SPEC.md): its start window (families, ticks, shortcuts, the time it
// should take, its order), a run of two stats sets to the end, its summary, "Tout annuler", a run stopped at its second
// set. Then "errors [...]", the page's errors. PAGE_URL: the page to open (a page_parity.js --serve address, to compare
// two versions); else data/atelier/index.html.
const path = require('path');
const puppeteer = require(process.env.PUPPETEER || path.join(process.env.APPDATA || '', 'npm/node_modules/@modelcontextprotocol/server-puppeteer/node_modules/puppeteer'));
(async () => {
  const browser = await puppeteer.launch({executablePath: process.env.CHROME || 'C:/Program Files/Google/Chrome/Application/chrome.exe', headless: 'new', args: ['--allow-file-access-from-files']});
  const page = await browser.newPage(); const errs = []; await page.setViewport({width: 1600, height: 1000});
  page.on('pageerror', e => errs.push(e.message)); page.on('dialog', d => d.accept());
  await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); try { localStorage.clear(); localStorage.setItem('atelier', JSON.stringify({guide: {mode: 'off', seen: {tour: true}}})); } catch (e) {} });
  await page.goto(process.env.PAGE_URL || 'file:///' + path.resolve(__dirname, '../../../atelier/index.html').split(path.sep).join('/'), {waitUntil: 'load'});
  await page.waitForFunction(() => typeof render === 'function'); await new Promise(r => setTimeout(r, 4000));
  const out = [], wait = ms => new Promise(r => setTimeout(r, ms));
  await page.evaluate(() => { S.motion = false; S.char = 'Kaories'; S.job = 'PLD'; S.section = 'sets'; render(); }); await wait(600);
  const has = await page.evaluate(() => !!document.querySelector('[data-optsets]'));
  out.push('button: ' + (has ? await page.evaluate(() => document.querySelector('[data-optsets]').textContent) : 'none'));
  if (has) {
    const head = () => page.evaluate(() => { const d = document.querySelector('.osdlg'); return d ? d.querySelector('h3').textContent : 'closed'; });
    const fams = () => page.evaluate(() => [...document.querySelectorAll('.osdlg .osfam')].map(f => f.querySelector('.osfamhead').textContent + ' ' + f.querySelectorAll('.osset[aria-pressed=true]').length + '/' + f.querySelectorAll('.osset').length).join(' · '));
    await page.click('[data-optsets]'); await wait(400);
    out.push('open: ' + await head() + ' | ' + await fams());
    out.push('order, first ten: ' + await page.evaluate(() => S._optSets.list.slice(0, 10).map(x => shortPath(x.s.path) + ':' + x.kind).join(', ')));
    for (const k of ['stat', 'none', 'all']) { await page.click(`[data-osonly="${k}"]`); await wait(200); out.push(`shortcut ${k}: ` + await head()); }
    await page.evaluate(() => document.querySelector('.osdlg .osfamhead').click()); await wait(200);
    out.push('first family untick: ' + await head() + ' | ' + await fams());
    await page.click('[data-osscratch]'); await wait(200);
    out.push('from scratch: ' + await head() + ' pressed ' + await page.evaluate(() => document.querySelector('[data-osscratch]').getAttribute('aria-pressed')));
    await page.click('[data-osscratch]'); await wait(200);
    // two stats sets, run to the end
    const pick = n => page.evaluate(n => { const R = S._optSets; let k = 0; R.list.forEach(x => { R.on[x.s.path] = x.kind === 'stat' && k++ < n; }); osPaint(); }, n);
    await pick(2); await wait(200);
    out.push('two ticked: ' + await head());
    await page.click('[data-osgo]');
    for (let i = 0; i < 120; i++) { await wait(1000); if (await page.evaluate(() => S._optSets && S._optSets.finished)) break; }
    await wait(400);
    const rows = () => page.evaluate(() => [...document.querySelectorAll('.osdlg .ostbl tbody tr')].map(r => r.className + ': ' + r.textContent.replace(/\s+/g, ' ').trim()).join(' | '));
    out.push('summary: ' + await head() + ' :: ' + (await rows()).replace(/[\d\s,.]+(?= →)|(?<=→ )[\d\s,.]+|[+−][\d.]+ %/g, '#'));
    out.push('buttons: ' + await page.evaluate(() => [...document.querySelectorAll('.osdlg footer button')].map(b => b.textContent).join(', ')));
    out.push('tried after the run: ' + await page.evaluate(() => S._optSets.todo.filter(x => S.trial[trialKey(x.s)]).length));
    await page.click('[data-osundo]'); await wait(300);
    out.push('undo: window ' + await head() + ', tried ' + await page.evaluate(() => Object.keys(S.trial).filter(k => k.startsWith('Kaories|PLD|')).length) + ', toast ' + await page.evaluate(() => S.toast));
    // a run of three stopped during its second set
    await page.click('[data-optsets]'); await wait(300); await pick(3); await wait(200);
    await page.click('[data-osgo]');
    for (let i = 0; i < 60; i++) { await wait(300); if (await page.evaluate(() => S._optSets && S._optSets.i === 1 && S._optBusy)) break; }
    await page.evaluate(() => { const b = document.querySelector('[data-optstop]'); if (b) b.click(); else optStop(); });
    for (let i = 0; i < 30; i++) { await wait(300); if (await page.evaluate(() => S._optSets && S._optSets.finished)) break; }
    await wait(300);
    out.push('stopped: ' + await head() + ' :: ' + (await rows()).replace(/[\d\s,.]+(?= →)|(?<=→ )[\d\s,.]+|[+−][\d.]+ %/g, '#'));
    await page.click('[data-osundo]'); await wait(300);
  }
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
