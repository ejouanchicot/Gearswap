// GearSwap Atelier · live.js: saving into the GearSwap folder, tried pieces saved, the live link, AtelierLink
// (cut from atelier.html, loaded by it in order: see the list there)
/* ---- saving: the page writes into the GearSwap data folder the player picks once ---- */
const luaStr = v => "'" + String(v).replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/\n/g, '\\n') + "'";
function overridesLua(map){
  const block = scope => `    ${/^[A-Za-z_]\w*$/.test(scope) ? scope : '[' + luaStr(scope) + ']'} = {\n` +
    Object.keys(map[scope]).sort().map(id => `        [${luaStr(id)}] = ${luaStr(map[scope][id])},`).join('\n') + `\n    },`;
  return `-- Keys changed in the Atelier page (data/atelier.html, Keys tab), laid over the key files\n` +
    `-- (shared/utils/keybinds/key_overrides.lua). Delete this file to go back to the files' keys.\n` +
    `-- '' = no key. Written ${stamp()}.\nreturn {\n${Object.keys(map).sort().map(block).join('\n')}\n}\n`;
}
// The data folder handle, kept in the browser (IndexedDB) once the player has picked it
function idb(mode, fn){
  return new Promise((ok, ko) => { const r = indexedDB.open('atelier', 1);
    r.onupgradeneeded = () => r.result.createObjectStore('handles');
    r.onsuccess = () => { const tx = r.result.transaction('handles', mode), q = fn(tx.objectStore('handles')); q.onsuccess = () => ok(q.result); q.onerror = () => ko(q.error); };
    r.onerror = () => ko(r.error); });
}
// The page's own folder (D:\...\GearSwap\data): the one to pick, shown to the player
// GearSwap's data folder: the page is data/atelier/index.html (data/atelier.html before 2026-10-05, now a link to it)
const pageFolder = () => decodeURIComponent(location.pathname).replace(/^\/([A-Za-z]:)/, '$1').replace(/\/[^/]*$/, '').replace(/\/atelier$/, '').replace(/\//g, '\\');
// The data folder inside what was picked: data itself, or GearSwap, addons, Windower above it
async function findData(dir){
  const has = async (d, n) => { try { await d.getFileHandle(n); return true; } catch (e) { return false; } };
  const sub = async (d, n) => { try { return await d.getDirectoryHandle(n); } catch (e) { return null; } };
  for (const path of [[], ['data'], ['GearSwap', 'data'], ['addons', 'GearSwap', 'data']]) {
    let d = dir;
    for (const n of path) d = d && await sub(d, n);
    if (d && await has(d, 'atelier.html')) return d;
  }
  return null;
}
// The data folder kept from the first time, when the browser still lets the page write in it
async function dataFolder(){
  let dir = null;
  try { dir = await idb('readonly', st => st.get('data')); } catch (e) {}
  if (!dir) return null;
  let perm = await dir.queryPermission({mode: 'readwrite'});
  if (perm !== 'granted') perm = await dir.requestPermission({mode: 'readwrite'});
  return perm === 'granted' ? dir : null;
}
async function pickFolder(){
  const dir = await findData(await window.showDirectoryPicker({id: 'atelier-data', mode: 'readwrite'}));
  if (!dir) throw new Error(t('saveWrongDir'));
  try { await idb('readwrite', st => st.put(dir, 'data')); } catch (e) {}
  return dir;
}
// <Char>/atelier/overrides/<file> (shared/utils/core/char_paths.lua), then the copy of before 2026-10-05 in
// <Char>/saved/ taken out, so GearSwap never reads an older one
async function writeSaved(dir, char, file, text){
  const mine = await dir.getDirectoryHandle(char), at = await mine.getDirectoryHandle('atelier', {create: true});
  const into = await at.getDirectoryHandle('overrides', {create: true});
  const fh = await into.getFileHandle(file, {create: true}), w = await fh.createWritable();
  await w.write(text); await w.close();
  try { await (await mine.getDirectoryHandle('saved')).removeEntry(file); } catch (e) {}
}
function download(file, text){
  const a = document.createElement('a'); a.href = URL.createObjectURL(new Blob([text], {type: 'text/plain'})); a.download = file; a.click();
  setTimeout(() => URL.revokeObjectURL(a.href), 1000);
}
// Write a file of <Char>/atelier/overrides/; true when written in the folder (else downloaded, or cancelled)
async function saveFile(file, text){
  const c = S.char;
  if (liveOk(c)) {
    try {
      await liveFetch(c, '/save?file=' + encodeURIComponent(file), {method: 'POST', body: text});
      try { await liveFetch(c, '/reload', {method: 'POST'}); } catch (e) {}
      return 'live';
    } catch (e) {}
  }
  // a browser without folder access (Firefox): the file is downloaded, the page says where it goes
  if (!window.showDirectoryPicker) { download(file, text); S.toast = t('savedDownload', {p: `${c}/atelier/overrides/${file}`}); return false; }
  try {
    const dir = await dataFolder();
    if (dir) { await writeSaved(dir, c, file, text); return true; }
  } catch (e) {}
  // the first time (or the folder moved): the page says which folder, then the player picks it
  return new Promise(done => openFolderDialog(async () => {
    const dir = await pickFolder();
    await writeSaved(dir, c, file, text);
    done(true);
  }, () => done(null)));
}
// The one-time window: which folder, why, then the browser's own picker
function openFolderDialog(pick, cancel){
  const show = err => {
    $('#overlay').innerHTML = `<div class="scrim" data-folderno></div><div class="dialog folderdlg" role="dialog" aria-label="${t('folderTitle')}">
      <header><h3>${t('folderTitle')}</h3></header>
      <div class="body"><p>${t('folderWhy')}</p><code class="folderpath">${esc(pageFolder())}</code><p class="muted small">${t('folderOnce')}</p>
      ${err ? `<p class="kwarn">${esc(err)}</p>` : ''}</div>
      <footer><button class="btn ghost" data-folderno>${t('cancel')}</button><button class="btn" data-folderpick>${t('folderPick')}</button></footer></div>`;
    $('#overlay').hidden = false;
  };
  S._folder = {pick: async () => { try { await pick(); closeOverlay(); S._folder = null; } catch (e) { if (!(e && e.name === 'AbortError')) show(e && e.message || String(e)); } },
    cancel: () => { closeOverlay(); S._folder = null; cancel(); }};
  show('');
}
async function saveKeys(){
  const c = S.char, file = 'keybind_overrides.lua', done = await saveFile(file, overridesLua(keyOverrides()));
  if (done === null) return;
  S.keyDirty[c] = false; S.keyOv[c].at = stamp();
  if (done) S.toast = done === 'live' ? t('savedLive') : t('savedKeys', {p: `${c}/atelier/overrides/${file}`});
  render();
}
/* ---- sets: the tried pieces saved into <Char>/atelier/overrides/set_overrides.lua ---- */
// S.setOv[char] = {at, map: {<JOB>: {path: {slot: piece}}}}: the whole file, from the latest export, a later save wins
function setOverrides(){
  const c = S.char, mine = S.setOv[c];
  const latest = latestExport(c, 'set_overrides');
  if (!mine || (latest && (latest.at || '') > (mine.at || ''))) S.setOv[c] = {at: latest ? latest.at : '', map: JSON.parse(JSON.stringify((latest && latest.set_overrides) || {}))};
  return S.setOv[c].map;
}
// A piece as the file holds it: a name, {name, augments}, or 'empty'
const filePiece = p => !p ? 'empty' : p.augs && p.augs.length ? {name: p.name, augments: p.augs} : p.name;
function setsLua(map){
  const val = v => typeof v === 'string' ? luaStr(v) : `{ name = ${luaStr(v.name)}, augments = { ${(v.augments || []).map(luaStr).join(', ')} } }`;
  const set = (path, slots) => `        [${luaStr(path)}] = {\n` + SLOTS.filter(x => x in slots).map(x => `            ${x} = ${val(slots[x])},`).join('\n') + `\n        },`;
  const job = j => `    ${j} = {\n` + Object.keys(map[j]).sort().map(path => set(path, map[j][path])).join('\n') + `\n    },`;
  return `-- Pieces changed in the Atelier page (data/atelier.html, Sets tab), laid over the set files\n` +
    `-- (shared/utils/atelier/set_overrides.lua). Delete this file to go back to your set files.\n` +
    `-- 'empty' = nothing in the slot. Written ${stamp()}.\nreturn {\n${Object.keys(map).sort().map(job).join('\n')}\n}\n`;
}
// Save the set's tried pieces into the file (other sets and jobs kept)
async function saveSet(s){
  const c = S.char, map = JSON.parse(JSON.stringify(setOverrides())), job = map[S.job] = map[S.job] || {}, slots = job[s.path] = job[s.path] || {};
  for (const [slot, p] of Object.entries(S.trial[trialKey(s)] || {})) slots[slot] = filePiece(p);
  const done = await saveFile('set_overrides.lua', setsLua(map));
  if (done === null) return;
  S.setOv[c] = {at: stamp(), map};
  if (done) S.toast = done === 'live' ? t('savedLive') : t('savedSet', {p: `${S.char}/atelier/overrides/set_overrides.lua`});
  render();
}
// Back to the set file: the set's entry leaves the file, the page shows the file's pieces until the next export
async function revertSet(s){
  const c = S.char, job = S.job, k = trialKey(s), map = JSON.parse(JSON.stringify(setOverrides()));
  if (map[job]) { delete map[job][s.path]; if (!Object.keys(map[job]).length) delete map[job]; }
  const done = await saveFile('set_overrides.lua', setsLua(map));
  if (done === null) return;
  S.setOv[c] = {at: stamp(), map};
  S.trial[k] = {};
  for (const [slot, was] of Object.entries(s.was || {})) S.trial[k][slot] = was.name === 'empty' ? null : was;
  if (done) S.toast = done === 'live' ? t('savedLive') : t('revertedSet', {p: `${S.char}/atelier/overrides/set_overrides.lua`});
  render();
}
// A tried piece the set file already holds (the export after a save); emptying counts only
// when the set itself empties the slot (a weapon mode may fill it otherwise)
const heldAlready = (s, slot, p) => p ? samePiece(p, s.pieces[slot]) : isEmpty(s.pieces[slot]);
/* ---- the live link: GearSwap in game answers on 127.0.0.1 (shared/utils/atelier/atelier_live.lua) ---- */
// data/atelier/live_<Character>.js (written by the game) gives the port and the token
const liveConf = c => (window.ATELIER_LIVE || {})[c];
const liveOk = (c = S.char) => !!(S._live[c] && S._live[c].ok);
// A set file can be written while the character's GearSwap answers, whatever job it has loaded: the request names the
// job shown (a job theory-crafted while another is played); GearSwap reloads only for the job it has loaded
const liveWrite = () => liveOk();
const jobQuery = () => '&job=' + encodeURIComponent(S.job || '');
const shownJobLoaded = () => (S._live[S.char] || {}).job === S.job;
// The message of a write: GearSwap reloads (the job it has loaded), or the file waits for that job to be loaded
const doneText = (key, f) => shownJobLoaded() ? t(key, {f}) : t(key + 'Later', {f, j: S.job});
async function reloadIfLoaded(){ if (shownJobLoaded()) try { await liveFetch(S.char, '/reload', {method: 'POST'}); } catch (e) {} }
async function liveFetch(c, path, opts = {}){
  const L = opts.link ? linkConf(c) : liveConf(c), ctl = new AbortController(), timer = setTimeout(() => ctl.abort(), opts.timeout || 2500);
  try {
    const r = await fetch(`http://127.0.0.1:${L.port}${path}`, {method: opts.method || 'GET', body: opts.body,
      headers: {'X-Atelier-Token': L.token}, signal: ctl.signal, cache: 'no-store'});
    if (!r.ok) throw new Error('HTTP ' + r.status);
    return await r.json();
  } finally { clearTimeout(timer); }
}
// AtelierLink (addons/AtelierLink, installed by //gs c atelier link): an addon of its own that loads,
// unloads and reloads GearSwap, so it answers while GearSwap is unloaded
const linkConf = c => (window.ATELIER_LINK || {})[c];
const linkOk = (c = S.char) => !!(S._link[c] && S._link[c].ok);
let LINK_BUSY = false;
async function linkTick(){
  const c = S.char;
  if (!c) return;
  // no door yet (the addon never started, or the page opened before it): looked for again now and then
  if (!linkConf(c)) return liveReread(c, 'link', 10000);
  if (LINK_BUSY) return;
  LINK_BUSY = true;
  const was = !!(S._link[c] && S._link[c].ok);
  try { const p = await liveFetch(c, '/ping', {link: true, timeout: 1500}); S._link[c] = {ok: p.player === c}; }
  catch (e) { S._link[c] = {ok: false}; liveReread(c, 'link'); }
  finally { LINK_BUSY = false; }
  if (was !== S._link[c].ok) render();
}
async function linkGearSwap(what){
  try { await liveFetch(S.char, '/gearswap?do=' + what, {link: true, method: 'POST'}); S.toast = t('gs_' + what); }
  catch (e) { S.toast = t('liveLost'); }
  render();
}
// Every 2 s: is the game there, and did it load something new (job, subjob, a reload)?
// A new version brings the loaded job's data straight from the game, in place of its export file
let LIVE_BUSY = false;
async function liveTick(){
  const c = S.char;
  if (!c) return;
  // no door yet (//gs c atelier live off then on, or a page opened before the game): looked for again now and then
  if (!liveConf(c)) return liveReread(c, 'live', 10000);
  if (LIVE_BUSY) return;
  LIVE_BUSY = true;
  const was = S._live[c] || {};
  try {
    const ping = await liveFetch(c, '/ping', {timeout: 1500});
    const now = {ok: ping.player === c, job: ping.job, sub: ping.sub || 'NONE', version: ping.version, at: was.at};
    if (ping.player === c && ping.job && (ping.version !== was.version || !was.ok)) {
      const d = await liveFetch(c, '/export', {timeout: 8000});
      if (d && d.sets) {
        const m = ((DATA[c] = DATA[c] || {})[d.job] = DATA[c][d.job] || {});
        canonNames(d); m[d.sub || 'NONE'] = d; DATA_GEN++;
        CHARS[c] = {jobs: Object.keys(DATA[c])};
        now.at = d.at;
      }
    }
    S._live[c] = now;
    if (!was.ok || now.version !== was.version) render();
  } catch (e) {
    S._live[c] = {ok: false};
    if (was.ok) render();
    // a relaunched GearSwap opens a new door (port, token): read its file again
    liveReread(c);
  } finally { LIVE_BUSY = false; }
}
// The door's file read again (live_<char>.js for GearSwap, link_<char>.js for AtelierLink): each load of the game makes a
// new port and token, so a page opened before keeps knocking at the old door; every `wait` ms at most, per file
const REREAD_AT = {};
function liveReread(c, kind = 'live', wait = 4000){
  const k = kind + '|' + c;
  if (Date.now() - (REREAD_AT[k] || 0) < wait) return;
  REREAD_AT[k] = Date.now();
  const el = document.createElement('script');
  el.src = `atelier/${kind}_${c}.js?t=${Date.now()}`; el.onload = el.onerror = () => el.remove();
  document.head.appendChild(el);
}
// The buttons of the top bar while the game answers: reload the files, or the whole addon
async function liveReload(full){
  const c = S.char;
  // a whole restart goes through the addon when it is there: it survives the unload
  if (full && linkOk(c)) return linkGearSwap('reload');
  try { await liveFetch(c, '/reload' + (full ? '?full=1' : ''), {method: 'POST'}); S.toast = t(full ? 'liveRestarting' : 'liveReloading'); }
  catch (e) { S.toast = t('liveLost'); }
  render();
}
function liveBadge(){
  const c = S.char, L = S._live[c] || {}, link = linkOk(c);
  if (!liveConf(c) && !linkConf(c)) return '';
  // the label goes on medium screens (the icon stays, the label is in the tooltip)
  const btn = (attr, icon, label, title) => `<button class="live act" ${attr} title="${esc(label + ' · ' + title)}">${icon}<span class="lbl"> ${label}</span></button>`;
  // GearSwap answers: its job, then reload / restart (through the addon when it is there) / unload
  if (L.ok) return `<button class="live on" data-livejump title="${esc(t('liveJump'))}">● ${t('liveOn')} · ${esc(L.job)}/${esc(L.sub)}</button>` +
    btn('data-livereload', '⟳', t('liveReload'), '//gs reload') + btn('data-liverestart', '↺', t('liveRestart'), '//lua r gearswap') +
    (link ? btn('data-gsunload', '⏏', t('gsUnload'), '//lua u gearswap') : '');
  // only the addon answers: GearSwap is unloaded (or its link is off), it can be loaded
  if (link) return `<span class="live mid" title="${esc(t('linkOnlyHow'))}">● ${t('linkOnly')}</span>` + btn('data-gsload', '▶', t('gsLoad'), '//lua l gearswap');
  return `<span class="live" title="${esc(t('liveHow'))}">○ ${t('liveOff')}</span>`;
}
