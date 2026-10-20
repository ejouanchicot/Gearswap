// Atelier click test "modctl" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  const edits = () => page.evaluate(() => { const e = (S._modEdits || {})[S.char] || {}; return Object.entries(e).map(([f, x]) => f.split('/').pop() + ':' + Object.entries(x).map(([k, v]) => k + '=' + JSON.stringify(v.v)).join(',')).filter(s => !s.endsWith(':')).join(' | '); });
  const counts = () => page.evaluate(() => `sw ${document.querySelectorAll('#view .modsw').length} seg ${document.querySelectorAll('#view .modseg button').length} in ${document.querySelectorAll('#view .modin').length} adv ${document.querySelectorAll('#view .modadv').length} pressed ${[...document.querySelectorAll('#view .modseg [aria-pressed="true"]')].length} on ${document.querySelectorAll('#view .modsw[aria-checked="true"]').length} off ${document.querySelectorAll('#view .modsw[disabled], #view .modseg [disabled], #view .modin[disabled]').length}`);
  for (const [view, fam] of [['simple', 'job'], ['simple', 'automed'], ['simple', 'hud'], ['files', null]]) {
    await page.evaluate((view, fam) => { S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'jobcfg'; S.jobTab = 'modules'; S.modView = view; S.modFam = fam; S.modFile = null; S._modEdits = {};
      S._live = Object.assign({}, S._live, {Tetsouo: Object.assign({}, S._live.Tetsouo, {ok: true, write: true})}); render(); }, view, fam); await wait(300);
    out.push(`${view} ${fam}: ` + await counts());
    await page.evaluate(() => { const b = document.querySelector('#view .modsw:not([disabled])'); if (b) b.click(); }); await wait(250);
    await page.evaluate(() => { const b = [...document.querySelectorAll('#view .modseg button:not([disabled])')].find(x => x.getAttribute('aria-pressed') !== 'true'); if (b) b.click(); }); await wait(250);
    const typed = await page.evaluate(() => { const i = document.querySelector('#view .modin:not(.add):not([disabled])'); if (!i) return ''; i.focus(); return i.className; });
    if (typed) { await page.keyboard.type('7', {delay: 30}); await page.keyboard.press('Tab'); await wait(300); }
    out.push(`  edits (${typed}): ` + await edits() + ' | ' + await counts());
  }
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
