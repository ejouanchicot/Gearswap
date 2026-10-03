// GearSwap Atelier · live.js: saving into the GearSwap folder, the live link, AtelierLink, Simulate
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
const pageFolder = () => decodeURIComponent(location.pathname).replace(/^\/([A-Za-z]:)/, '$1').replace(/\/[^/]*$/, '').replace(/\//g, '\\');
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
async function writeSaved(dir, char, file, text){
  const mine = await dir.getDirectoryHandle(char), saved = await mine.getDirectoryHandle('saved', {create: true});
  const fh = await saved.getFileHandle(file, {create: true}), w = await fh.createWritable();
  await w.write(text); await w.close();
}
function download(file, text){
  const a = document.createElement('a'); a.href = URL.createObjectURL(new Blob([text], {type: 'text/plain'})); a.download = file; a.click();
  setTimeout(() => URL.revokeObjectURL(a.href), 1000);
}
// Write a file of <Char>/saved/; true when written in the folder (else downloaded, or cancelled)
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
  if (!window.showDirectoryPicker) { download(file, text); S.toast = t('savedDownload', {p: `${c}/saved/${file}`}); return false; }
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
  if (done) S.toast = done === 'live' ? t('savedLive') : t('savedKeys', {p: `${c}/saved/${file}`});
  render();
}
/* ---- sets: the tried pieces saved into <Char>/saved/set_overrides.lua ---- */
// S.setOv[char] = {at, map: {<JOB>: {path: {slot: piece}}}}: the whole file, from the latest export, a later save wins
function setOverrides(){
  const c = S.char, mine = S.setOv[c];
  const latest = Object.values(DATA[c] || {}).flatMap(j => Object.values(j)).filter(x => x.set_overrides !== undefined)
    .sort((a, b) => (b.at || '').localeCompare(a.at || ''))[0];
  if (!mine || (latest && (latest.at || '') > (mine.at || ''))) S.setOv[c] = {at: latest ? latest.at : '', map: JSON.parse(JSON.stringify((latest && latest.set_overrides) || {}))};
  return S.setOv[c].map;
}
// A piece as the file holds it: a name, {name, augments}, or 'empty'
const filePiece = p => !p ? 'empty' : p.augs && p.augs.length ? {name: p.name, augments: p.augs} : p.name;
const samePiece = (a, b) => (!a || a.name === 'empty') ? (!b || b.name === 'empty') : !!b && a.name === b.name && (a.augs || []).join('|') === (b.augs || []).join('|')
  && (a.rank ?? null) === (b.rank ?? null);
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
  if (done) S.toast = done === 'live' ? t('savedLive') : t('savedSet', {p: `${S.char}/saved/set_overrides.lua`});
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
  if (done) S.toast = done === 'live' ? t('savedLive') : t('revertedSet', {p: `${S.char}/saved/set_overrides.lua`});
  render();
}
// A tried piece the set file already holds (the export after a save); emptying counts only
// when the set itself empties the slot (a weapon mode may fill it otherwise)
const heldAlready = (s, slot, p) => p ? samePiece(p, s.pieces[slot]) : isEmpty(s.pieces[slot]);
// The tried pieces of a set are the ones saved for it (waiting for a reload in game)
function trialSaved(s){
  const tr = S.trial[trialKey(s)] || {}, saved = ((setOverrides()[S.job] || {})[s.path]) || {};
  const asPiece = v => v === 'empty' ? null : typeof v === 'string' ? {name: v} : {name: v.name, augs: v.augments};
  return Object.keys(tr).length > 0 && Object.entries(tr).every(([slot, p]) => slot in saved && samePiece(p, asPiece(saved[slot])));
}
/* ---- the live link: GearSwap in game answers on 127.0.0.1 (shared/utils/atelier/atelier_live.lua) ---- */
// data/atelier/live_<Character>.js (written by the game) gives the port and the token
const liveConf = c => (window.ATELIER_LIVE || {})[c];
const liveOk = (c = S.char) => !!(S._live[c] && S._live[c].ok);
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
        m[d.sub || 'NONE'] = d; DATA_GEN++;
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
/* ---- Simulate: the game's own GearSwap runs an action without doing it (shared/utils/atelier/atelier_sim.lua) ---- */
// The magic skills in the order a player thinks of them, and their French names
const MAGIC_ORDER = ['Healing Magic', 'Enhancing Magic', 'Enfeebling Magic', 'Elemental Magic', 'Dark Magic', 'Divine Magic',
  'Blue Magic', 'Ninjutsu', 'Singing', 'Geomancy', 'Summoning Magic'];
const MAGIC_FR = {'Healing Magic': 'Soins', 'Enhancing Magic': 'Renfort', 'Enfeebling Magic': 'Affaiblissement', 'Elemental Magic': 'Élémentaire',
  'Dark Magic': 'Ténèbres', 'Divine Magic': 'Divine', 'Blue Magic': 'Magie bleue', 'Ninjutsu': 'Ninjutsu', 'Singing': 'Chant',
  'Geomancy': 'Géomancie', 'Summoning Magic': 'Invocation', Magic: 'Magie', Other: 'Autres'};
// Whether an action accepts a target: aim is 'me ally enemy' (the ones it accepts), 'auto' takes all
const aimHas = (aim, target) => target === 'auto' || !aim || aim === 'both' || aim.split(' ').includes(target);
const magicLabel = sk => S.lang === 'fr' ? (MAGIC_FR[sk] || sk) : sk;
const simKey = () => S.char + '|' + S.job;
function simState(){ return (S.sim[simKey()] = S.sim[simKey()] || {target: 'auto', status: 'Engaged', recasts: false, states: {}}); }
// The job's actions, asked once per GearSwap load
// A list the game is asked for once per GearSwap load: "too old" only when its GearSwap does not have the request
// (HTTP 404); a timeout or a dropped answer is asked again 10 s later. The answer goes to the slot it was asked for
// (another character or job meanwhile has its own)
const simAskAgain = slot => slot && slot.retry && Date.now() - slot.at > 10000;
async function simAsk(name, path, empty, field){
  const c = S.char, L = S._live[c] || {}, key = c + '|' + L.version, had = S[name];
  if (had && had.key === key && !simAskAgain(had)) return;
  const slot = S[name] = {key, [field]: null, at: Date.now()};
  try { slot[field] = await liveFetch(c, path, {timeout: 4000}); }
  catch (e) { slot[field] = empty; if (/HTTP 404/.test(e.message || '')) slot.old = true; else slot.retry = true; }
  render();
}
const simActions = () => simAsk('_simActions', '/actions', {ma: [], ja: [], ws: []}, 'list');
let SIM_SEQ = 0;
// The request of the chosen action; its character and job lead, so a result never shows under another job
function simQuery(st){
  const q = new URLSearchParams({kind: st.kind, name: st.name, target: st.target, status: st.status, recasts: st.recasts ? '1' : '0'});
  if (st.kind === 'ws') q.set('tp', st.tp || 3000);
  q.set('buffs', (st.buffs || []).join(','));
  for (const [k, v] of Object.entries(st.states || {})) q.set('s.' + k, v);
  return q;
}
async function simRun(){
  const st = simState(), c = S.char;
  if (!st.name || !liveOk(c)) return;
  if (st.kind === 'ws' && !st.tp) st.tp = 3000;
  const q = simQuery(st), key = simKey() + '?' + q.toString();
  const seq = ++SIM_SEQ;
  S._simBusy = true; render();
  // pieces saved from the page and not pushed yet: the action runs a second time as the set files wrote it
  const testing = Object.keys((setOverrides() || {})[S.job] || {}).length > 0;
  try {
    const r = await liveFetch(c, '/simulate?' + q.toString(), {method: 'POST', timeout: 6000});
    let rFile = null;
    if (testing) { const qf = new URLSearchParams(q); qf.set('file', '1');
      try { rFile = await liveFetch(c, '/simulate?' + qf.toString(), {method: 'POST', timeout: 6000}); } catch (e) {} }
    // ver: the GearSwap load that answered; a reload runs the action again (its code may have changed)
    if (seq === SIM_SEQ) S._simResult = {req: key, r, rFile, ver: (S._live[c] || {}).version};
  } catch (e) { if (seq === SIM_SEQ) S._simResult = {req: key, r: {ok: false, error: t('liveLost')}, ver: (S._live[c] || {}).version}; }
  S._simBusy = false; render();
}
// The set a phase's gear comes from: the set whose pieces are in the list
// (most of its pieces: the TP bonus piece, a weapon mode or an overlay may change a few), the set
// named after the action first (sets.precast.WS.Disaster for Disaster). _hit / _of: how many matched
function simSetOf(list, hint){
  const d = data(); let best = null, bestScore = 0;
  for (const s of d.sets) {
    const slots = Object.keys(s.pieces).filter(k => !isEmpty(s.pieces[k]));
    if (slots.length < 3) continue;
    const hit = slots.filter(k => list[k] && list[k].name === s.pieces[k].name).length;
    if (hit / slots.length < 0.75) continue;
    const named = hint && segs(s.path).pop().toLowerCase() === String(hint).toLowerCase();
    const score = (named ? 1000 : 0) + hit + hit / slots.length;
    if (score > bestScore) { bestScore = score; best = Object.assign(Object.create(s), {_hit: hit, _of: slots.length}); }
  }
  return best;
}
// FFXI chat colour codes out of the captured lines
const chatText = m => String(m).replace(/[\x1e\x1f][\s\S]/g, '').replace(/[\x00-\x08\x0b-\x1f\x7f]/g, '').trim();
// The buffs the job's code reads (Simulate offers them), asked once per GearSwap load
// Buffs that cancel each other in the game: one at a time (Defender ends Berserk, Seigan ends Hasso...)
const BUFF_EXCLUSIVE = [['Berserk', 'Defender'], ['Hasso', 'Seigan'], ['Light Arts', 'Dark Arts'],
  ['Addendum: White', 'Addendum: Black'], ['Warcry', 'Blood Rage']];
// A buff on or off; turning one on turns off those it cancels
function toggleBuff(list, name){
  if (list.includes(name)) return list.filter(b => b !== name);
  const gone = BUFF_EXCLUSIVE.filter(g => g.includes(name)).flat();
  return list.filter(b => !gone.includes(b)).concat([name]).sort();
}
const simBuffOptions = () => simAsk('_simBuffs', '/sim_buffs', {buffs: []}, 'opts');
function renderSim(d){
  const c = S.char;
  if (!liveOk(c) || (S._live[c] || {}).job !== S.job) return `<div class="placeholder"><p>${t('simNeedLive', {j: S.job})}</p></div>`;
  simActions();
  const st = simState();
  // the action chosen before a page reload (or under another job) runs again on its own
  if (st.name && !S._simBusy && !S._simQueued && (!S._simResult || S._simResult.req !== simKey() + "?" + simQuery(st).toString()
      || S._simResult.ver !== (S._live[c] || {}).version)) {
    S._simQueued = true; setTimeout(() => { S._simQueued = false; simRun(); }); }
  const acts = (S._simActions && S._simActions.list) || null, q = (st.q || '').toLowerCase();
  // groups: each magic skill of the main and sub (Healing, Enhancing...), one Trust row, abilities, weaponskills
  const row = (k, n, label) => `<button class="setrow" data-simpick="${k}|${esc(n)}" aria-current="${st.kind === k && st.name === n}"><b>${esc(label || n)}</b></button>`;
  // closed until opened (a search opens them all); the group of the chosen action is marked
  const group = (label, rows, names) => { if (!rows.length) return '';
    const key = S.job + '|' + label, open = !!q || !!S.simOpen[key], here = st.name && (names || []).includes(st.name);
    return `<button class="fam ${here ? 'here' : ''}" data-simgroup="${esc(key)}" aria-expanded="${open}"><span>${esc(label)}</span><span>${rows.length}</span></button>` + (open ? rows.join('') : ''); };
  // the target chosen narrows the list: on me, what can aim at oneself; on the enemy, what can aim at one
  const aimOk = n => aimHas((acts && acts.aim || {})[n], st.target);
  const match = n => (!q || n.toLowerCase().includes(q)) && aimOk(n);
  let pick = `<p class="muted small" style="padding:12px">${t('simLoading')}</p>`;
  if (acts) {
    const magic = acts.magic || (acts.ma && acts.ma.length ? {Magic: acts.ma} : {});
    const order = Object.keys(magic).sort((a, b) => (MAGIC_ORDER.indexOf(a) + 1 || 99) - (MAGIC_ORDER.indexOf(b) + 1 || 99) || a.localeCompare(b));
    pick = order.map(sk => group(magicLabel(sk), magic[sk].filter(match).map(n => row('ma', n)), magic[sk])).join('') +
      (acts.trust && (!q || 'trust'.includes(q)) && (st.target === 'auto' || st.target === 'me') ? group('Trust', [row('ma', acts.trust, t('simTrust'))], [acts.trust]) : '') +
      group(t('simAbilities'), (acts.ja || []).filter(match).map(n => row('ja', n)), acts.ja) +
      group(t('simWs'), (acts.ws || []).filter(match).map(n => row('ws', n)), acts.ws) +
      (acts.ra && (!q || t('simRanged').toLowerCase().includes(q)) && (st.target === 'auto' || st.target === 'enemy') ? group(t('simRangedGroup'), [row('ra', 'Ranged', t('simRanged'))], ['Ranged']) : '');
  }
  const chip = (key, v, label) => `<button data-simopt="${key}|${v}" aria-pressed="${String(st[key]) === String(v)}">${label}</button>`;
  simBuffOptions();
  const simBuffs = ((S._simBuffs && S._simBuffs.opts) || {}).buffs || [];
  const modes = d.modes.filter(m => m.values.length > 1 && m.values.length <= 12 && !modeHidden(m) && !/^[A-Z]{3}Song\d$/.test(m.name));
  const modeSel = modes.map(m => { const cur = (st.states || {})[m.name] ?? m.current;
    return `<label class="simmode ${cur !== m.current ? 'set' : ''}"><span>${esc(m.desc || m.name)}</span><select class="buffsel" data-simstate="${esc(m.name)}">` +
      m.values.map(v => `<option ${v === cur ? 'selected' : ''}>${esc(v)}</option>`).join('') + `</select></label>`; }).join('');
  const opts = `<div class="simopts"><div class="variants">${chip('target', 'auto', t('simAuto'))}${chip('target', 'me', t('simMe'))}${chip('target', 'ally', t('simAlly'))}${chip('target', 'enemy', t('simEnemy'))}</div>` +
    `<div class="variants">${chip('status', 'Engaged', t('simEngaged'))}${chip('status', 'Idle', t('simIdle'))}</div>` +
    `<label class="chip"><input type="checkbox" class="simrecasts" ${st.recasts ? 'checked' : ''}> ${t('simRecasts')}</label>` +
    (st.kind === 'ws' ? `<div class="variants"><span class="simtplbl">TP</span>${simTpSteps(st.name).map(v => chip('tp', v, v)).join('')}` +
      `<input class="tpin" data-sim="1" type="number" min="0" max="3000" step="10" value="${st.tp && !simTpSteps(st.name).includes(+st.tp) ? st.tp : ''}" placeholder="${t('tpOther')}" aria-label="TP"></div>` : '') + `</div>` +
    // the buffs the job's code reads (GET /sim_buffs): only these count, never the ones on you now
    (simBuffs.length ? `<div class="simopts"><span class="simtplbl">${t('wornBuffs')}</span><div class="variants">` +
      simBuffs.map(b => `<button data-simbuff="${esc(b)}" aria-pressed="${(st.buffs || []).includes(b)}">${esc(b)}</button>`).join('') + `</div></div>` : '');
  // the game runs a GearSwap from before the simulation: it answers 404 to /actions
  if (S._simActions && S._simActions.old) return `<div class="placeholder"><p>${t('simOld')}</p><button class="btn" data-liverestart>${t('liveRestart')}</button></div>`;
  return `<div class="simx"><aside class="setlist"><div class="search"><input id="simq" type="search" placeholder="${t('simSearch')}" value="${esc(st.q || '')}" autocomplete="off" spellcheck="false"></div>` +
    `<div class="scroll">${pick}</div></aside><div class="simmain">` +
    box('g-you', t('simTitle'), `${opts}<details class="simmodes"><summary>${t('simModes')}</summary><div class="simmodegrid">${modeSel}</div></details>`,
      `<span class="meta">${S._simBusy ? t('simRunning') + ' · ' : ''}${statPickBtn()}</span>`) + simResultHTML(d) + `</div></div>`;
}
// The numbers that change between the steps of an action: HP / MP first (a tank's HP must not
// drop between precast and midcast), then what the steps are for
const SIM_STATS = [['enmity', 'Enmity'], ['fc', 'Fast Cast', '%'], ['sird', 'SIRD', '%'], ['cure', 'Cure', '%'], ['phalanx', 'Phalanx'],
  ['haste', 'Haste', '%'], ['acc', null], ['atk', null], ['wsd', null, '%'], ['da', 'DA', '%'], ['ta', 'TA', '%'], ['stp', 'Store TP'],
  ['macc', null], ['mab', null], ['def', null]];
function simStats(pieces){
  const r = charStats(null, pieces), g = r ? r.set : gearTotal(pieces), v = k => (g[k] || {}).v || 0;
  const out = {hp: r ? r.cur.hp : v('hp'), mp: r ? r.cur.mp : v('mp'), gearOnly: !r,
    pdt: Math.max(Math.max(v('dt') + v('pdt'), -50) + v('pdt2'), -87.5), mdt: Math.max(Math.max(v('dt') + v('mdt'), -50) + v('mdt2'), -87.5)};
  for (const [k] of SIM_STATS) out[k] = v(k);
  return out;
}
function simTableHTML(phases, stats){
  const num = (v, unit) => `${signed(Math.round(v * 10) / 10)}${unit ? ' ' + unit : ''}`;
  // a change from the step before; for damage taken, down is the good way
  const change = (cur, prev, unit, lowerBetter) => { if (prev == null) return '<td class="d"></td>';
    const dv = Math.round((cur - prev) * 10) / 10;
    if (!dv) return '<td class="d"></td>';
    const good = lowerBetter ? dv < 0 : dv > 0;
    return `<td class="d ${good ? 'up' : 'down'}">${dv > 0 ? '+' : '−'}${Math.abs(dv)}${unit ? ' ' + unit : ''}</td>`; };
  const row = (label, key, unit, opts = {}) => {
    if (!opts.always && !stats.some(st => st[key])) return '';
    return `<tr class="${opts.cls || ''}"><th>${esc(label)}</th>` + stats.map((st, i) =>
      `<td class="v">${opts.plain ? st[key] : num(st[key], unit)}</td>${change(st[key], i ? stats[i - 1][key] : null, unit, opts.lowerBetter)}`).join('') + `</tr>`; };
  const head = `<tr><th></th>${phases.map(ph => `<th colspan="2" class="ph">${t('ph.' + ph.phase)}</th>`).join('')}</tr>`;
  const rows = [row('HP', 'hp', '', {always: true, plain: true, cls: 'big'}), row('MP', 'mp', '', {always: true, plain: true, cls: 'big'})]
    .concat(statShown('dtEff') ? [row(t('simPdt'), 'pdt', '%', {always: true, lowerBetter: true}), row(t('simMdt'), 'mdt', '%', {always: true, lowerBetter: true})] : [])
    .concat(SIM_STATS.filter(([k]) => statShown(k)).map(([k, label, unit]) => row(label || statLabel(k, {}), k, unit || '')));
  return `<table class="simtable"><thead>${head}</thead><tbody>${rows.join('')}</tbody></table>` +
    (stats[0] && stats[0].gearOnly ? `<p class="muted small">${t('simGearOnly')}</p>` : '');
}
function simResultHTML(d){
  const st = simState(), res = S._simResult && S._simResult.req === simKey() + '?' + simQuery(st).toString() ? S._simResult : null;
  if (!st.name) return `<p class="muted" style="margin:14px 2px">${t('simHint')}</p>`;
  if (!res) return '';
  const r = res.r;
  if (!r.ok && r.error) return box('g-off', t('simError'), `<p class="kwarn">${esc(r.error)}</p>`);
  S._simWorn = {};
  const rf = res.rFile && res.rFile.ok !== false ? res.rFile : null;
  const gear = x => JSON.stringify((x.phases || []).map(ph => ph.list || {}));
  if (!rf) return simBlock(r, '');
  if (!rf.as_file) return `<p class="kwarn">${t('simOldCode')}</p>` + simBlock(r, '');
  if (gear(rf) === gear(r)) return `<p class="simtest same">${t('simTestSame')}</p>` + simBlock(r, '');
  // what differs, step by step
  const diff = (r.phases || []).map((ph, i) => { const a = ph.list || {}, b = ((rf.phases || [])[i] || {}).list || {};
    const slots = SLOTS.filter(sl => ((a[sl] || {}).name || '') !== ((b[sl] || {}).name || '') || ((a[sl] || {}).augs || []).join('|') !== ((b[sl] || {}).augs || []).join('|'));
    return slots.length ? `<b>${t('ph.' + ph.phase)}</b> : ${slots.map(sl => SLOT_NAMES[S.lang][sl]).join(', ')}` : ''; }).filter(Boolean);
  return `<p class="simtest">${t('simTestDiff', {d: diff.join(' · ')})}</p>` +
    `<h3 class="simhead test">${t('simTestHead')}</h3>` + simBlock(r, '') +
    `<h3 class="simhead file">${t('simFileHead')}</h3>` + simBlock(rf, 'f');
}
// One simulation's steps and table; key prefixes the hover cards' ids (two blocks on one page)
function simBlock(r, key){
  const st = simState();
  // gear worn step by step: what the game wore at the last measure, then each phase on top
  let worn = Object.assign({}, (measuredChar() || {}).worn || {});
  // a job ability or a weaponskill has no midcast of its own: its empty step is left out
  const phases = (r.phases || []).filter(ph => !(ph.phase === 'midcast' && st.kind !== 'ma' && st.kind !== 'ra' && !Object.keys(ph.list || {}).length));
  const stats = [];
  const cards = phases.map((ph, i) => {
    worn = Object.assign({}, worn, ph.list || {});
    stats.push(simStats(worn));
    const changed = new Set(Object.keys(ph.list || {})), set = simSetOf(ph.list || {}, ph.phase === 'aftercast' ? null : st.name);
    const cells = SLOTS.map(slot => { const p = worn[slot], ch = changed.has(slot), none = !p || p.name === 'empty';
      return `<button class="slot ${none ? 'empty' : ''} ${ch ? '' : 'inh'}" data-simp="${key}${i}|${slot}" aria-label="${SLOT_NAMES[S.lang][slot]}">` +
        (none ? `<span class="elbl">${SLOT_NAMES[S.lang][slot]}</span>` : icon(p.name)) + `</button>`; }).join('');
    S._simWorn[key + i] = Object.assign({}, worn);
    return box(['g-mag', 'g-def', 'g-attr'][i] || 'g-other', t('ph.' + ph.phase),
      `<div class="slots">${cells}</div><div class="simset"><code title="${esc(set ? set.path : '')}">${set ? '≈ ' + esc(set.path) + (set._hit < set._of ? ` · ${set._hit}/${set._of}` : '') : t('simNoSet')}</code>` +
      `<span>${t('simChanged', {n: changed.size})}</span></div>`); }).join('');
  const msgs = (r.messages || []).map(chatText).filter(Boolean);
  const notes = (r.before ? `<p class="simbefore">${t('simBefore', {a: esc(r.before), s: esc(st.name)})}</p>` : '') +
    (r.redirect ? `<p class="simbefore">${t('simRedirect', {a: esc(r.redirect), s: esc(st.name)})}</p>` : '') +
    (r.cancelled ? `<p class="kwarn">${t('simCancelled')}</p>` : '') +
    (msgs.length ? `<details class="simmsgs"><summary>${t('simMsgs', {n: msgs.length})}</summary><ul class="plain">${msgs.map(m => `<li>${esc(m)}</li>`).join('')}</ul></details>` : '') +
    (r.scheduled ? `<p class="muted small">${t('simScheduled', {n: r.scheduled})}</p>` : '');
  // the cards and the table side by side on a wide screen: the table keeps the whole height
  return `${notes ? `<div class="simnotes">${notes}</div>` : ''}<div class="simbody"><div class="simcards" style="--n:${phases.length}">${cards}</div>` +
    box('g-you', t('simCompare'), simTableHTML(phases, stats)) + `</div>`;
}
