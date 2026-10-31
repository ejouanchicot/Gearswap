// Atelier click test "newplayer" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
// what a player would read there, then "errors [...]", the page's errors. PAGE_URL: the page to open (a
// page_parity.js --serve address, to compare two versions); else data/atelier/index.html.
// A brand-new player: nothing exported, the game's door open on "Newbie" playing a job with no file (data/default.lua,
// /ping says nofile). The page lists Newbie (events.js readExports), reaches the game, says what to do first
// (home.ts first) and sends "+ Add a job" (add_job.js). The game is a small local server answering /ping and /addjob.
const path = require('path'), http = require('http');
const puppeteer = require(process.env.PUPPETEER || path.join(process.env.APPDATA || '', 'npm/node_modules/@modelcontextprotocol/server-puppeteer/node_modules/puppeteer'));
(async () => {
  const hits = [];
  const srv = http.createServer((q, r) => { hits.push(q.method + ' ' + q.url.replace(/\?.*$/, ''));
    r.writeHead(200, {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*', 'Access-Control-Allow-Headers': '*'});
    r.end(q.method === 'OPTIONS' ? '' : /addjob/.test(q.url) ? JSON.stringify({ok: true, job: 'WAR', char: 'Newbie', files: ['a', 'b', 'c'], kept: []})
      : JSON.stringify({player: 'Newbie', job: 'WAR', sub: 'SAM', nofile: true, version: 1, boot: 1})); });
  await new Promise(ok => srv.listen(0, '127.0.0.1', ok));
  const port = srv.address().port;
  const browser = await puppeteer.launch({executablePath: process.env.CHROME || 'C:/Program Files/Google/Chrome/Application/chrome.exe', headless: 'new', args: ['--allow-file-access-from-files']});
  const page = await browser.newPage(); const errs = []; await page.setViewport({width: 1600, height: 1000});
  page.on('pageerror', e => errs.push(e.message)); page.on('dialog', d => d.accept());
  // the files the game writes: an index with no export and Newbie's door only
  await page.setRequestInterception(true);
  page.on('request', q => {
    const u = q.url();
    if (/\/atelier\/index\.js/.test(u)) return q.respond({contentType: 'text/javascript', body: 'window.ATELIER_INDEX = [];\nwindow.ATELIER_LIVE_FILES = ["atelier/live_Newbie.js"];\nwindow.ATELIER_PAGE_FILES = [];\n'});
    if (/\/atelier\/live_Newbie\.js/.test(u)) return q.respond({contentType: 'text/javascript', body: `window.ATELIER_LIVE = window.ATELIER_LIVE || {};\nATELIER_LIVE["Newbie"] = {port: ${port}, token: "t"};\n`});
    if (/\/atelier\/(live|link)_\w+\.js/.test(u)) return q.respond({status: 404, body: ''});
    q.continue();
  });
  await page.evaluateOnNewDocument(() => { try { localStorage.clear(); localStorage.setItem('atelier', JSON.stringify({guide: {mode: 'off', seen: {tour: true}}})); } catch (e) {} });
  await page.goto(process.env.PAGE_URL || 'file:///' + path.resolve(__dirname, '../../../atelier/index.html').split(path.sep).join('/'), {waitUntil: 'load'});
  await page.waitForFunction(() => typeof render === 'function'); await new Promise(r => setTimeout(r, 6000));
  const out = [], wait = ms => new Promise(r => setTimeout(r, ms));
  out.push(await page.evaluate(() => `character: ${S.char}; characters: ${Object.keys(CHARS).join(', ')}`));
  out.push('page asked the game: ' + [...new Set(hits)].join(', '));
  out.push(await page.evaluate(() => { const p = document.querySelector('.pane > .lede'); return 'first: ' + (p ? p.textContent : 'none'); }));
  out.push(await page.evaluate(() => [...document.querySelectorAll('[data-addjob]')].map(b => 'button: ' + b.textContent + (b.disabled ? ' (disabled)' : '')).join('\n') || 'button: none'));
  await page.click('[data-addjob]'); await wait(500);
  out.push(await page.evaluate(() => 'add window: ' + [...document.querySelectorAll('[data-addjobpick]')].map(b => b.dataset.addjobpick).join(' ')));
  await page.click('[data-addjobpick="WAR"]'); await wait(1500);
  out.push(await page.evaluate(() => 'answer: ' + ((document.querySelector('.ajdlg .toast') || {}).textContent || 'none')));
  out.push('add sent: ' + hits.filter(h => /addjob/.test(h)).join(', '));
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close(); srv.close();
})();
