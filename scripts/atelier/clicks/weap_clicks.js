// Atelier click test "weap" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  // the weapons' block as a player reads it: each label (and its title), each menu (title, mode, chosen option), the lines after
  const head = () => page.evaluate(() => { const h = document.querySelector('.setctl'); if (!h) return 'none';
    const sel = x => `sel.${x.className}[${x.dataset.wmode || ''}] t=${(x.getAttribute('title') || '-').slice(0, 40)} a=${x.getAttribute('aria-label')} =${x.value} (${[...x.options].map(o => (o.selected ? '*' : '') + o.value + ':' + o.textContent).join(' | ')})`;
    return [...h.querySelectorAll('.wpick, .wsline')].map(l => { const lb = l.querySelector('.wslbl');
      return l.className + ' [' + (lb ? lb.textContent + ' t=' + (lb.getAttribute('title') || '-').slice(0, 40) : '') + '] ' + [...l.querySelectorAll('.wsval > select.wmenu')].map(sel).join(' ; ') +
        [...l.querySelectorAll('.wauto')].map(w => ' auto: ' + w.textContent + ' small t=' + (w.querySelector('small').getAttribute('title') ?? 'null') + ' unforce=' + [...w.querySelectorAll('[data-unforce]')].map(b => b.dataset.unforce).join(',')).join(''); }).join('\n   '); });
  const jobs = [['Tetsouo', 'WAR'], ['Tetsouo', 'PLD'], ['Tetsouo', 'THF'], ['Tetsouo', 'DNC'], ['Tetsouo', 'COR'], ['Tetsouo', 'BLM'], ['Kaories', 'RDM'], ['Kaories', 'GEO'], ['Tetsouo', 'RUN']];
  for (const [c, j] of jobs) {
    const n = await page.evaluate((c, j) => { S.char = c; S.job = j; S.section = 'sets'; render(); return S._cards.length; }, c, j); await wait(200);
    for (let i = 0; i < n; i += Math.max(1, Math.floor(n / 6))) {
      await page.evaluate(i => { S.sel[S.job] = i; S.variant[S.job + '|' + i] = Math.min(1, S._cards[i].variants.length - 1); S.weapons = {}; S.slotForce = {}; render(); }, i); await wait(300);
      out.push(`${c} ${j} ${i}:\n   ` + await head());
      // each menu to its last value, one at a time (the old page draws its menus anew)
      const k = await page.evaluate(() => document.querySelectorAll('.setctl select.wmenu').length);
      for (let m = 0; m < k; m++) {
        const did = await page.evaluate(m => { const x = document.querySelectorAll('.setctl select.wmenu')[m]; if (!x || x.options.length < 2) return false; x.value = x.options[x.options.length - 1].value; x.dispatchEvent(new Event('change', {bubbles: true})); return true; }, m); await wait(300);
        if (did) out.push(`  menu ${m} last:\n   ` + await head());
      }
      // a piece forced in the off hand, then back to Auto
      const f = await page.evaluate(() => { const p = forceList('sub')[0] || forceList('ammo')[0]; if (!p) return false; setForce(forceList('sub')[0] ? 'sub' : 'ammo', p); render(); return true; }); await wait(300);
      if (f) { out.push('  forced:\n   ' + await head());
        const b = await page.evaluate(() => { const b = document.querySelector('.setctl [data-unforce]'); if (b) b.click(); return !!b; }); await wait(300);
        if (b) out.push('  unforced:\n   ' + await head()); }
      const fm = await page.evaluate(() => { const p = forceList('main')[0]; if (!p) return false; setForce('main', p); render(); return true; }); await wait(300);
      if (fm) out.push('  forced main:\n   ' + await head());
    }
  }
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
