// Atelier click test "wsam" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  const info = () => page.evaluate(() => { const b = buffState(), x = [...document.querySelectorAll('.pbbody .pbfextra')];
    return `sav ${b.savagery} noAgoge ${b.noAgoge} pSav ${b.pSavagery} pNoAgoge ${b.pNoAgoge} pSamba ${b.pSamba} extras ${x.length} ${x.map(e => e.textContent.replace(/\s+/g, ' ') + ' [' + [...e.querySelectorAll('[aria-pressed="true"]')].map(c => c.textContent).join(',') + '] off ' + e.querySelectorAll('[disabled]').length).join(' / ')}`; });
  const tab = async (members, t) => { await page.evaluate((m, t) => { const b = buffState(); for (const k of Object.keys(b)) delete b[k]; b.pbMembers = m; S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'combat'; S.pbTab = 'you'; render();
    const el = document.querySelector(`.pbtabs [data-pbtab="${t}"]`) || [...document.querySelectorAll('[data-pbtab]')].find(e => e.dataset.pbtab === t); if (el) el.click(); }, members, t); await wait(300); };
  await tab(['WAR', 'DNC'], 'you');
  await page.evaluate(() => document.querySelector('.pbbody [data-ja="Warcry"]').click()); await wait(300);
  out.push('own warcry: ' + await info());
  await page.evaluate(() => document.querySelector('.pbbody [data-savagery="2"]').click()); await wait(300);
  await page.evaluate(() => document.querySelector('.pbbody [data-agoge]').click()); await wait(300);
  out.push('sav 2, no agoge: ' + await info());
  out.push('tabs: ' + await page.evaluate(() => [...document.querySelectorAll('[data-pbtab]')].map(e => e.dataset.pbtab).join(',')));
  for (const t of [...await page.evaluate(() => [...document.querySelectorAll('[data-pbtab]')].map(e => e.dataset.pbtab))].filter(t => t !== 'you')) {
    await page.evaluate(t => document.querySelector(`[data-pbtab="${t}"]`).click(), t); await wait(300);
    const jas = await page.evaluate(() => [...document.querySelectorAll('.pbbody [data-ja]')].map(e => e.dataset.ja));
    for (const j of jas.filter(j => /Warcry|Samba/.test(j))) { await page.evaluate(j => document.querySelector(`.pbbody [data-ja="${j}"]`).click(), j); await wait(300); }
    out.push(`tab ${t} (${jas.join(',')}): ` + await info());
    const sv = await page.evaluate(() => { const b = document.querySelector('.pbbody [data-savagery="3"][data-wparty]'); if (b) b.click(); return !!b; }); await wait(300);
    const sel = await page.evaluate(() => { const s = document.querySelector('.pbbody [data-buff="pSamba"]'); if (s) { s.value = 'm2'; s.dispatchEvent(new Event('input', {bubbles: true})); s.dispatchEvent(new Event('change', {bubbles: true})); } return !!s; }); await wait(300);
    out.push(`  changed (sav ${sv}, samba ${sel}): ` + await info());
  }
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
