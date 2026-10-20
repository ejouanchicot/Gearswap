// Atelier click test "enfround" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
// what a player would read there, then "errors [...]", the page's errors. PAGE_URL: the page to open (a
// page_parity.js --serve address, to compare two versions); else data/atelier/index.html.
const path = require('path');
const puppeteer = require(process.env.PUPPETEER || path.join(process.env.APPDATA || '', 'npm/node_modules/@modelcontextprotocol/server-puppeteer/node_modules/puppeteer'));
(async () => {
  const browser = await puppeteer.launch({executablePath: process.env.CHROME || 'C:/Program Files/Google/Chrome/Application/chrome.exe', headless: 'new', args: ['--allow-file-access-from-files']});
  const page = await browser.newPage(); const errs = []; await page.setViewport({width: 1600, height: 900});
  page.on('pageerror', e => errs.push(e.message));
  await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); try { localStorage.clear(); localStorage.setItem('atelier', JSON.stringify({guide: {mode: 'off', seen: {tour: true}}})); } catch (e) {} });
  await page.goto(process.env.PAGE_URL || 'file:///' + path.resolve(__dirname, '../../../atelier/index.html').split(path.sep).join('/'), {waitUntil: 'load'});
  await page.waitForFunction(() => typeof render === 'function'); await new Promise(r => setTimeout(r, 4000));
  const out = {push: x => console.log(x)}, wait = ms => new Promise(r => setTimeout(r, ms));
  await page.evaluate(() => { S.motion = false; S.char = 'Kaories'; S.job = 'RDM'; S.section = 'sets'; render(); }); await page.evaluate(() => new Promise(r => loadRanked(r))); await wait(400);
  const open = pred => page.evaluate(pred => { const f = new Function('x', 'return ' + pred); const s = (data().sets || []).find(x => f(x)); if (!s) return null; S.selPath = Object.assign({}, S.selPath, {[S.job]: s.path}); S.optView = optViewKey(s); render(); return s.path; }, pred);
  const enf = () => page.evaluate(() => { const p = document.querySelector('.oppage'); if (!p) return 'none'; const b = p.querySelector('[data-enfsab]'); return [...p.querySelectorAll('p.small')].map(x => x.textContent).join(' / ').slice(0, 300) + ' | sab ' + (b ? b.checked + ' ' + b.parentElement.textContent : 'none'); });
  for (const pr of ["/Enfeebl|MndEnf|IntEnf|Dispel|Frazzle|Distract|Paralyze|Slow|Silence/.test(x.path) && statSet(x)", "family(x.path, x.pieces) === 'midcast' && /Enfeeb/.test(x.path)"]) {
    out.push('enf ' + await open(pr)); await wait(500); out.push('  ' + await enf());
    await page.evaluate(() => { const b = document.querySelector('.oppage [data-enfsab]'); if (b) b.click(); }); await wait(400); out.push('  sab: ' + await enf());
  }
  const calc = () => page.evaluate(() => { const d = document.querySelector('.oppage .rdcalc'); return d ? d.open + ' | ' + [...d.querySelectorAll('li')].map(l => l.textContent.slice(0, 60)).join(' / ') + ' | ' + d.querySelector('p').textContent.slice(0, 40) : 'none'; });
  for (const [c, j] of [['Tetsouo', 'WAR'], ['Tetsouo', 'DNC']]) {
    await page.evaluate((c, j) => { S.char = c; S.job = j; render(); }, c, j); await wait(300);
    out.push(j + ' ' + await open("family(x.path, x.pieces) === 'engaged'")); await wait(800); out.push('  ' + await calc());
    await page.evaluate(() => { const d = document.querySelector('.oppage .rdcalc summary'); if (d) d.click(); }); await wait(400); out.push('  opened: ' + await calc());
  }
  console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
