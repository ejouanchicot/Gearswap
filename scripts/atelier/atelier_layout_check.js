// GearSwap Atelier · the layout check (for the project, never shipped to players): atelier/index.html opened in
// Chrome at several widths, every character / job, the sections and the main windows, and each place where a text or
// a block goes past its box: a box whose content is wider than it (and that does not scroll or end in "…"), a block
// that spills out of its parent, the page scrolling sideways.
//   node scripts/atelier/atelier_layout_check.js [--widths 1920,1280,390] [--char Tetsouo] [--shots DIR]
// Same needs as atelier_test.js (Puppeteer, Chrome). The game is never asked: the page's fetch is stubbed.
// Prints each problem once (where it is, its text, the widths and views it was seen in), most frequent first.
//
// @file    scripts/atelier/atelier_layout_check.js
// @author  ejouanchicot
const path = require('path'), fs = require('fs');
const puppeteer = require(process.env.PUPPETEER || path.join(process.env.APPDATA || '', 'npm/node_modules/@modelcontextprotocol/server-puppeteer/node_modules/puppeteer'));
const CHROME = process.env.CHROME || 'C:/Program Files/Google/Chrome/Application/chrome.exe';
// PAGE_URL: another page to check (page_parity.js --serve old: the page of the last commit)
const PAGE = process.env.PAGE_URL || 'file:///' + path.resolve(__dirname, '../../atelier/index.html').split(path.sep).join('/');
const arg = (k, d) => { const i = process.argv.indexOf(k); return i > 0 ? process.argv[i + 1] : d; };
const WIDTHS = arg('--widths', '1920,1440,1280,1024,768,390').split(',').map(Number);
const ONLY_CHAR = arg('--char', null), SHOTS = arg('--shots', null);

// in the page: every visible element of the regions given whose content goes past its box
function scan(view, regions){
  const out = [], W = document.documentElement.clientWidth;
  const sel = el => { const p = []; for (let e = el; e && e !== document.body && p.length < 4; e = e.parentElement)
    p.unshift(e.tagName.toLowerCase() + (e.id ? '#' + e.id : '') + (typeof e.className === 'string' && e.className.trim() ? '.' + e.className.trim().split(/\s+/).slice(0, 2).join('.') : ''));
    return p.join(' > '); };
  const text = el => (el.innerText || el.value || '').replace(/\s+/g, ' ').trim().slice(0, 70);
  // inside a box that scrolls sideways (or cuts): what goes past the window there is reached by scrolling that box
  const inScroller = el => { for (let e = el.parentElement; e && e !== document.body; e = e.parentElement) { const o = getComputedStyle(e).overflowX; if (o !== 'visible') return true; } return false; };
  if (document.documentElement.scrollWidth > W + 1) out.push({kind: 'page scrolls sideways', where: 'html', text: `${document.documentElement.scrollWidth} > ${W}`});
  for (const root of regions.map(r => document.querySelector(r)).filter(Boolean)) {
    for (const el of root.querySelectorAll('*')) {
      const r = el.getBoundingClientRect();
      if (!r.width || !r.height) continue;
      const cs = getComputedStyle(el);
      if (cs.visibility === 'hidden' || cs.display === 'contents' || ['svg', 'path', 'option', 'br'].includes(el.tagName.toLowerCase())) continue;
      if (el.closest('svg')) continue;
      const scrolls = /(auto|scroll)/.test(cs.overflowX), ellipsis = cs.textOverflow === 'ellipsis';
      // content wider than the box: past it (visible), or cut (hidden without "…")
      if (!scrolls && !ellipsis && el.scrollWidth > el.clientWidth + 2 && el.clientWidth > 0 && !['inline'].includes(cs.display))
        out.push({kind: cs.overflowX === 'hidden' || cs.overflowX === 'clip' ? 'text cut' : 'content wider than its box', where: sel(el), text: text(el) + ` (${el.scrollWidth} > ${el.clientWidth})`});
      // content taller than a box held to its height: cut (hidden) or spilling over what follows (visible)
      const scrollsY = /(auto|scroll)/.test(cs.overflowY);
      if (!scrollsY && el.scrollHeight > el.clientHeight + 3 && el.clientHeight > 0 && !['inline', 'inline-block', 'table-row', 'table-cell'].includes(cs.display) && !cs.webkitLineClamp?.match?.(/\d/))
        out.push({kind: cs.overflowY === 'hidden' || cs.overflowY === 'clip' ? 'text cut (height)' : 'content taller than its box', where: sel(el), text: text(el) + ` (${el.scrollHeight} > ${el.clientHeight})`});
      // a text, a button or a menu cut by a parent that hides what goes past it (not one that scrolls)
      const own = [...el.childNodes].some(n => n.nodeType === 3 && n.textContent.trim()) || /^(button|select|input|a)$/i.test(el.tagName);
      if (own) for (let e = el.parentElement; e && e !== document.body; e = e.parentElement) {
        const ps = getComputedStyle(e);
        if (/(auto|scroll)/.test(ps.overflowX)) break;
        // a frame ending its line in "…" says that it is cut
        if (/(hidden|clip)/.test(ps.overflowX) && ps.textOverflow === 'ellipsis') break;
        if (/(hidden|clip)/.test(ps.overflowX)) {
          const pr = e.getBoundingClientRect();
          if (r.right > pr.right + 2 || r.left < pr.left - 2) out.push({kind: 'cut by its frame', where: sel(el), text: text(el) + ` (${Math.round(r.left)}-${Math.round(r.right)} outside ${Math.round(pr.left)}-${Math.round(pr.right)})`});
          break;
        }
      }
      // a box past the window's right edge
      if (r.right > W + 1 && cs.position !== 'fixed' && !inScroller(el)) out.push({kind: 'past the window', where: sel(el), text: text(el) + ` (right ${Math.round(r.right)} > ${W})`});
    }
  }
  // keep only the outermost of a chain (a box past the window drags its children with it)
  const seen = new Set();
  return out.filter(x => { const k = x.kind + x.where; if (seen.has(k)) return false; seen.add(k); return true; }).map(x => Object.assign(x, {view}));
}

(async () => {
  const browser = await puppeteer.launch({executablePath: CHROME, headless: 'new', args: ['--allow-file-access-from-files']});
  const page = await browser.newPage(), errors = [];
  page.on('pageerror', e => errors.push(e.message));
  await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); try { localStorage.clear(); } catch (e) {} });
  await page.goto(PAGE, {waitUntil: 'load'});
  // the built page (atelier/src/) loads the old page's scripts after the document: drawn once its bridge says so
  await page.waitForFunction(() => window.__atelier && window.__atelier.loaded, {timeout: 60000});
  await new Promise(r => setTimeout(r, 6000));
  await page.evaluate(`window.__scan = ${scan.toString()}`);
  const all = [];
  for (const width of WIDTHS) {
    await page.setViewport({width, height: 1000});
    const found = await page.evaluate(async (onlyChar) => {
      const wait = ms => new Promise(r => setTimeout(r, ms)), out = [];
      // the welcome tour and Mog stay out of the way
      S.guide = Object.assign({}, S.guide, {done: true, off: true}); document.querySelectorAll('.moogle, .mog, #mog').forEach(e => e.remove());
      const regions = ['#top', '#view', '#overlay'];
      const look = async v => { await wait(30); out.push(...window.__scan(v, regions)); };
      for (const c of Object.keys(DATA)) {
        if (onlyChar && c !== onlyChar) continue;
        for (const j of Object.keys(DATA[c])) {
          S.char = c; S.job = j; S.section = 'sets'; render();
          const d = data() || {sets: []}, sets = d.sets.filter(x => !x.empty);
          // a few sets of each kind: the first, a weaponskill's, an engaged one, a nuke's, an idle one
          const pick = [sets[0], sets.find(x => /precast\.WS\[/.test(x.path)), sets.find(x => /^sets\.engaged/.test(x.path)),
            sets.find(x => isNukeSet(x.path)), sets.find(x => /^sets\.idle/.test(x.path)), sets.find(x => /midcast/.test(x.path) && !isNukeSet(x.path))].filter(Boolean);
          for (const s of pick) { S.selPath = Object.assign({}, S.selPath, {[j]: s.path}); S._found = null; render(); await look(`${c} ${j} set ${s.path}`); }
          // the optimizer's page on the weaponskill set and the nuke set
          for (const s of pick.filter(x => /precast\.WS\[/.test(x.path) || isNukeSet(x.path)).slice(0, 2)) {
            S.selPath = Object.assign({}, S.selPath, {[j]: s.path}); S._found = null; render();
            const cur = ui2CurrentSet(data());
            if (cur) { S.optView = optViewKey(cur); render(); await look(`${c} ${j} optimizer ${s.path}`); S.optView = null; render(); }
          }
          for (const sec of ['combat', 'perso', 'sim']) { S.section = sec; render(); await look(`${c} ${j} ${sec}`); }
          for (const tab of ['keys', 'modes', 'functions', 'macro', 'modules']) { S.section = 'jobcfg'; S.jobTab = tab; render(); await look(`${c} ${j} config ${tab}`); }
          S.section = 'sets'; render();
        }
      }
      // the windows, on Tetsouo WAR
      if (DATA.Tetsouo && DATA.Tetsouo.WAR) {
        S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'sets'; S.selPath = Object.assign({}, S.selPath, {WAR: 'sets.precast.WS.Upheaval'}); render();
        const s = shownSet(S._cards[S.sel.WAR], S.sel.WAR);
        const win = async (name, open) => { try { open(); await look('window ' + name); } catch (e) { out.push({kind: 'window failed', where: name, text: e.message, view: name}); } closeOverlay(); };
        await win('target', () => openTargetPick());
        await win('compare', () => openCompare(s));
        await win('slot head', () => openSlot(S.sel.WAR, 'head'));
        await win('slot main', () => openSlot(S.sel.WAR, 'main'));
        // the buffs, Buffs & target's tab (the old window is gone): last, it leaves the page on that tab
        await win('buffs', () => { closeOverlay(); S.section = 'combat'; render(); });
      }
      return out;
    }, ONLY_CHAR);
    for (const f of found) all.push(Object.assign(f, {width}));
    if (SHOTS) { fs.mkdirSync(SHOTS, {recursive: true}); await page.screenshot({path: path.join(SHOTS, `w${width}.png`), fullPage: true}); }
  }
  await browser.close();
  // one line a problem: where, what, how often, at which widths, one view it was seen in
  const by = new Map();
  for (const f of all) {
    const k = f.kind + '|' + f.where;
    const e = by.get(k) || {kind: f.kind, where: f.where, text: f.text, n: 0, widths: new Set(), view: f.view};
    e.n++; e.widths.add(f.width); by.set(k, e);
  }
  const list = [...by.values()].sort((a, b) => b.n - a.n);
  for (const e of list) console.log(`${String(e.n).padStart(4)}  ${e.kind}  [${[...e.widths].join(',')}]\n      ${e.where}\n      "${e.text}"  — ${e.view}`);
  console.log(`${list.length} problem(s), ${all.length} sightings` + (errors.length ? `; page errors: ${errors.join(' / ')}` : '; no page error'));
})();
