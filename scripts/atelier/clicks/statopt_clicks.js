// Atelier click test "statopt" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  const out = [], wait = ms => new Promise(r => setTimeout(r, ms));
  await page.evaluate(() => { S.motion = false; S.char = 'Tetsouo'; S.job = 'PLD'; S.section = 'sets'; render(); }); await page.evaluate(() => new Promise(r => loadRanked(r))); await wait(500);
  const read = () => page.evaluate(() => { const p = document.querySelector('.oppage'); if (!p) return 'none'; const cols = [...p.querySelectorAll('.opcol')];
    return cols.map(c => c.textContent.replace(/\s+/g, ' ').slice(0, 500)).join(' || ') + ' | on ' + [...p.querySelectorAll('.opobj.on')].map(b => b.dataset.statobj).join(',') + ' sel ' + [...p.querySelectorAll('[data-statthen]')].map(s => s.value).join(',') + ' keep ' + (p.querySelector('[data-statkeep]') || {}).checked + ' cells ' + [...p.querySelectorAll('.opres td')].map(td => td.className.trim()).join(','); });
  const open = (c, j, fam) => page.evaluate((c, j, fam) => { S.char = c; S.job = j; S.section = 'sets'; S._help = null; render(); const d = data() || {sets: []};
    const s = (d.sets || []).find(x => family(x.path, x.pieces) === fam && statSet(x)); if (!s) return null; S.selPath = Object.assign({}, S.selPath, {[S.job]: s.path}); S.optView = optViewKey(s); render(); return s.path; }, c, j, fam);
  for (const [c, j, fam] of [['Tetsouo', 'PLD', 'idle'], ['Tetsouo', 'PLD', 'fc'], ['Tetsouo', 'PLD', 'cure'], ['Tetsouo', 'RUN', 'idle'], ['Kaories', 'RDM', 'midcast'], ['Tetsouo', 'WAR', 'idle']]) {
    const p = await open(c, j, fam); await wait(500); out.push(`${c} ${j} ${fam} ${p}: ` + await read());
    if (!p) continue;
    await page.evaluate(() => { const b = [...document.querySelectorAll('.oppage .opobj:not(.on)')][0]; if (b) b.click(); }); await wait(400); out.push('  obj: ' + await read());
    await page.evaluate(() => { const b = document.querySelector('.oppage [data-statobjall]'); if (b) b.click(); }); await wait(400); out.push('  all: ' + await read());
    await page.evaluate(() => { const s = document.querySelector('.oppage [data-statthen="1"]'); if (s) { s.value = s.options[2] ? s.options[2].value : ''; s.dispatchEvent(new Event('change', {bubbles: true})); } }); await wait(400); out.push('  then: ' + await read());
    await page.evaluate(() => { const i = document.querySelector('.oppage [data-statfloor="hp"]'); if (i) { i.value = '3000'; i.dispatchEvent(new Event('change', {bubbles: true})); } }); await wait(400); out.push('  floor: ' + await read());
    await page.evaluate(() => { const b = document.querySelector('.oppage [data-help="optpage"]'); if (b) b.click(); }); await wait(300); out.push('  help: ' + await read());
  }
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
