// Atelier click test "panel" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
// what a player would read there, then "errors [...]", the page's errors. PAGE_URL: the page to open (a
// page_parity.js --serve address, to compare two versions); else data/atelier/index.html.
const path = require('path');
const puppeteer = require(process.env.PUPPETEER || path.join(process.env.APPDATA || '', 'npm/node_modules/@modelcontextprotocol/server-puppeteer/node_modules/puppeteer'));
(async () => {
  const browser = await puppeteer.launch({executablePath: process.env.CHROME || 'C:/Program Files/Google/Chrome/Application/chrome.exe', headless: 'new', args: ['--allow-file-access-from-files']});
  const page = await browser.newPage(); const errs = []; await page.setViewport({width: 1600, height: 1000});
  page.on('pageerror', e => errs.push(e.message)); page.on('dialog', d => d.accept());
  await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); try { localStorage.clear(); } catch (e) {} });
  await page.goto(process.env.PAGE_URL || 'file:///' + path.resolve(__dirname, '../../../atelier/index.html').split(path.sep).join('/'), {waitUntil: 'load'});
  await page.waitForFunction(() => window.__atelier && window.__atelier.loaded); await new Promise(r => setTimeout(r, 2000));
  const out = [], wait = ms => new Promise(r => setTimeout(r, ms));
  const step = async (label, fn, check) => { try { await page.evaluate(fn); await wait(250); out.push(label + ': ' + await page.evaluate(check)); } catch (e) { out.push(label + ': FAILED ' + String(e.message).slice(0, 120)); } };
  const tab = j => () => { const b = buffState(); for (const k of Object.keys(b)) delete b[k]; b.pbMembers = ['GEO', 'BRD', 'COR', 'WHM', 'RDM']; S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'combat'; S.pbTab = 'you'; render(); document.querySelector(`.pbtabs [data-pbtab="${j}"]`).click(); };
  const chg = (sel, v) => { const s = document.querySelector(sel); s.value = v; s.dispatchEvent(new Event('change', {bubbles: true})); };
  await page.exposeFunction('nop', () => 0);
  await page.evaluate(() => { window.CHG = (sel, v) => { const s = document.querySelector(sel); s.value = v; s.dispatchEvent(new Event('change', {bubbles: true})); }; });
  await page.evaluate(() => { window.TAB = j => { const b = buffState(); for (const k of Object.keys(b)) delete b[k]; b.pbMembers = ['GEO', 'BRD', 'COR', 'WHM', 'RDM']; S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'combat'; S.pbTab = 'you'; render(); document.querySelector(`.pbtabs [data-pbtab="${j}"]`).click(); }; });
  await step('GEO tab', () => TAB('GEO'), () => 'pbTab ' + S.pbTab + ', rows ' + document.querySelectorAll('.pbbody .pbf').length);
  await step('Indi pick opens', () => document.querySelector('.pbbody [data-pbpick="indi"]').click(), () => 'dialog ' + !!document.querySelector('.pbdlg') + ', choices ' + document.querySelectorAll('.pbdlg [data-pbchoose]').length);
  await step('choose Fury', () => document.querySelector('.pbdlg [data-pbchoose="indi|Fury"]').click(), () => 'indi ' + buffState().indi + ', button ' + document.querySelector('.pbbody [data-pbpick="indi"]').textContent + ', set ' + document.querySelector('.pbbody [data-pbpick="indi"]').classList.contains('set') + ', gives ' + document.querySelectorAll('.pbbody .pbfe span').length + ', tab gives ' + document.querySelector('.pbtabs [data-pbtab="GEO"] .pbtabg').textContent.slice(0, 40));
  await step('Geomancy +7', () => CHG('.pbbody select[data-buff="geoPlus"]', '7'), () => 'geoPlus ' + buffState().geoPlus + ', select ' + document.querySelector('.pbbody select[data-buff="geoPlus"]').value + ', class ' + document.querySelector('.pbbody select[data-buff="geoPlus"]').className);
  await step('Bolster on', () => document.querySelector('.pbbody [data-buffflag="bolster"]').click(), () => 'bolster ' + buffState().bolster + ', pressed ' + document.querySelector('.pbbody [data-buffflag="bolster"]').getAttribute('aria-pressed'));
  await step('BRD tab, Clarion', () => { document.querySelector('.pbtabs [data-pbtab="BRD"]').click(); setTimeout(() => document.querySelector('.pbbody [data-buffflag="clarion"]').click(), 50); }, () => 'clarion ' + buffState().clarion + ', song slots ' + document.querySelectorAll('.pbbody [data-pbpick^="song"]').length);
  await step('song 1 pick, Honor March', () => { document.querySelector('.pbbody [data-pbpick="song0"]').click(); setTimeout(() => document.querySelector('.pbdlg [data-pbchoose="song0|Honor March"]').click(), 50); }, () => 'song0 ' + buffState().song0 + ', marcato options ' + document.querySelectorAll('.pbbody select[data-pbmarcato] option').length);
  await step('Marcato song 1', () => CHG('.pbbody select[data-pbmarcato]', '0'), () => 'marcato ' + buffState().marcato + ', select ' + document.querySelector('.pbbody select[data-pbmarcato]').value);
  await step('COR tab, roll', () => { document.querySelector('.pbtabs [data-pbtab="COR"]').click(); setTimeout(() => { document.querySelector('.pbbody [data-pbpick="roll0"]').click(); setTimeout(() => document.querySelector('.pbdlg [data-pbchoose="roll0|Chaos"]').click(), 50); }, 50); },
    () => 'roll0 ' + buffState().roll0 + ' ' + buffState().roll0n + ', number select ' + (document.querySelector('.pbbody select[data-buff="roll0n"]') || {}).value + ', chips ' + document.querySelectorAll('.pbbody .pbfx .chip').length);
  await step('roll number IX', () => CHG('.pbbody select[data-buff="roll0n"]', 'IX'), () => 'roll0n ' + buffState().roll0n + ', select ' + document.querySelector('.pbbody select[data-buff="roll0n"]').value);
  await step('Crooked Cards chip', () => document.querySelector('.pbbody [data-rollcc="0"]').click(), () => 'rollCC ' + buffState().rollCC + ', pressed ' + document.querySelector('.pbbody [data-rollcc="0"]').getAttribute('aria-pressed'));
  await step('Light Shot', () => document.querySelector('.pbbody [data-buffflag="lightshot"]').click(), () => 'lightshot ' + buffState().lightshot);
  await step('WHM tab, Protect V', () => { document.querySelector('.pbtabs [data-pbtab="WHM"]').click(); setTimeout(() => CHG('.pbbody select[data-buff="protect"]', 'Protect V'), 50); }, () => 'protect ' + buffState().protect + ', select ' + document.querySelector('.pbbody select[data-buff="protect"]').value);
  await step('Auspice on, feet', () => { document.querySelector('.pbbody [data-buffflag="auspice"]').click(); setTimeout(() => CHG('.pbbody select[data-buff="auspiceFeet"]', 'Ebers Duckbills +1'), 50); }, () => 'auspice ' + buffState().auspice + ' ' + buffState().auspiceFeet);
  await step('RDM tab, Dia III, Saboteur', () => { document.querySelector('.pbtabs [data-pbtab="RDM"]').click(); setTimeout(() => { CHG('.pbbody select[data-buff="dia"]', 'Dia III'); setTimeout(() => document.querySelector('.pbbody [data-buffflag="saboteur"]').click(), 50); }, 50); },
    () => 'dia ' + buffState().dia + ', saboteur ' + buffState().saboteur + ', gloves switch ' + !!document.querySelector('.pbbody [data-buffflag="sabGloves"]') + ', ×: ' + [...document.querySelectorAll('.pbbody .pbfe .muted')].map(x => x.textContent).join(','));
  await step('foe debuff switch (BRD)', () => { document.querySelector('.pbtabs [data-pbtab="BRD"]').click(); setTimeout(() => { const s = document.querySelector('.pbbody [data-foeja]'); window.__f = s && s.dataset.foeja; s && s.click(); }, 50); }, () => 'foe ' + window.__f + ' on ' + (buffState().foeJa || []).includes(window.__f));
  await step('you tab, food pick', () => { document.querySelector('.pbtabs [data-pbtab="you"]').click(); setTimeout(() => { document.querySelector('.pbbody [data-pbpick="food"]').click(); setTimeout(() => document.querySelector('.pbdlg [data-pbchoose^="food|"]').click(), 50); }, 50); }, () => 'food ' + buffState().food);
  await step('aftermath Lv3', () => CHG('.pbbody select[data-buff="am"]', '3'), () => 'am ' + buffState().am);
  await step('your Berserk', () => document.querySelector('.pbbody [data-ja="Berserk"]').click(), () => 'on ' + jaOn(buffState(), 'Berserk') + ', pressed ' + document.querySelector('.pbbody [data-ja="Berserk"]').getAttribute('aria-pressed'));
  await step('your Warcry -> its line', () => document.querySelector('.pbbody [data-ja="Warcry"]').click(), () => 'on ' + jaOn(buffState(), 'Warcry') + ', extra ' + document.querySelectorAll('.pbbody .pbfextra').length);
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
