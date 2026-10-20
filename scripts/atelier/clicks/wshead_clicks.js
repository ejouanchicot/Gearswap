// Atelier click test "wshead" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  await page.evaluate(() => { S.motion = false; });
  const out = [], wait = ms => new Promise(r => setTimeout(r, ms));
  // the head as read by a player: each line's label, controls (values, chosen option, pressed chips), texts
  const head = () => page.evaluate(() => { const h = document.querySelector('.setctl'); if (!h) return 'none';
    const el = x => x.tagName === 'SELECT' ? `sel.${x.className}[${Object.entries(x.dataset).map(e => e.join('=')).join(',')}] ${x.title.slice(0, 30)} =${x.value} (${[...x.options].map(o => (o.selected ? '*' : '') + (o.disabled ? '!' : '') + o.value + ':' + o.textContent).join(' | ')})`
      : x.tagName === 'INPUT' ? `in.${x.className} =${x.value} ph ${x.placeholder}` : x.tagName === 'BUTTON' ? `btn[${Object.entries(x.dataset).map(e => e.join('=')).join(',')}] ${x.getAttribute('aria-pressed') || x.getAttribute('aria-expanded') || ''} ${x.title.slice(0, 40)} ${x.textContent}` : '';
    return [...h.querySelectorAll('.wsline, .wshelp, .kwarn, .wsbase')].map(l => l.className + ': ' + l.textContent.replace(/\s+/g, ' ') + ' {' + [...l.querySelectorAll('select, input, button')].map(el).join(' ; ') + '}').join('\n   '); });
  const sets = [['Tetsouo', 'WAR'], ['Tetsouo', 'PLD'], ['Tetsouo', 'THF'], ['Tetsouo', 'DNC'], ['Kaories', 'RDM'], ['Tetsouo', 'SAM']];
  for (const [c, j] of sets) {
    const idx = await page.evaluate((c, j) => { S.char = c; S.job = j; S.section = 'sets'; render();
      return S._cards.map((k, i) => [k, i]).filter(([k]) => k.fam === 'ws').flatMap(([k, i]) => k.variants.map((_, v) => [i, v])); }, c, j); await wait(200);
    for (const [i, v] of idx.filter((_, n) => (n > 0 && n < 4) || n === idx.length - 1)) {
      await page.evaluate((i, v) => { S.sel[S.job] = i; S.variant[S.job + '|' + i] = v; S._help = null; S.wsTp = null; S.held = {}; S.heldSub = {}; render(); }, i, v); await wait(400);
      out.push(`${c} ${j} ${i}/${v}:\n   ` + await head());
      const steps = [
        ['help weapon', () => { const b = document.querySelector('.setctl [data-help="weapon"]'); if (b) b.click(); return !!b; }],
        ['help tp', () => { const b = document.querySelector('.setctl [data-help="tp"]'); if (b) b.click(); return !!b; }],
        ['tp chip', () => { const b = [...document.querySelectorAll('.setctl [data-wstp]')][2]; if (b) b.click(); return !!b; }],
        ['tp input', () => { const x = document.querySelector('.setctl .tpin'); if (!x) return false; x.value = '1777'; x.dispatchEvent(new Event('input', {bubbles: true})); x.dispatchEvent(new Event('change', {bubbles: true})); return true; }],
        ['held', () => { const x = document.querySelector('.setctl .heldsel'); if (!x || x.options.length < 2) return false; x.value = x.options[x.options.length - 1].value; x.dispatchEvent(new Event('change', {bubbles: true})); return true; }],
        ['sub', () => { const x = document.querySelector('.setctl .heldsubsel'); const o = x && [...x.options].filter(o => !o.disabled && o.value)[0]; if (!o) return false; x.value = o.value; x.dispatchEvent(new Event('change', {bubbles: true})); return true; }],
        ['main auto', () => { const x = document.querySelector('.setctl .heldsel'); if (!x) return false; x.value = ''; x.dispatchEvent(new Event('change', {bubbles: true})); return true; }],
        ['sub auto', () => { const x = document.querySelector('.setctl .heldsubsel'); if (!x) return false; x.value = ''; x.dispatchEvent(new Event('change', {bubbles: true})); return true; }],
        ['tp off', () => { const b = document.querySelector('.setctl [data-wstp=""]'); if (b) b.click(); return !!b; }]];
      for (const [name, fn] of steps) { const ok = await page.evaluate(fn); await wait(500); if (ok) out.push(`  ${name}:\n   ` + await head()); }
    }
  }
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
