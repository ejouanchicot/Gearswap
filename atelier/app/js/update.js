// GearSwap Atelier · update.js: the update screen (the ⬆ button of the top bar, or //gs c upgrade in game, which opens
// the page with #update and writes atelier/update_ask.js). It shows the version installed and the latest release on
// GitHub, what the update changes, and installs it. The page downloads (the browser checks GitHub's certificate) and
// AtelierLink reads and writes the files of the data folder (its /info, /read, /file, /remove doors): a file the
// browser wrote itself would carry the Mark of the Web, and Windows Defender took our own update.js for a trojan that
// way (2026-10-21). So the game has to run, with AtelierLink. What an update does is update_core.js; this file holds
// its state (UPD), its clicks (data-updopen, data-updcheck, data-updapply, data-updundo) and its words. Drawn by
// screens/update (Svelte), as a page of the Settings (S._cfg with S._upd), so every other screen already steps aside.

Object.assign(T.fr, {updOpen: 'Mise à jour', ttUpd: 'Chercher une nouvelle version de GearSwap et l’installer',
  ttUpdNew: 'Nouvelle version disponible : {v}',
  updTitle: 'Mise à jour', updBack: 'Retour',
  updLede: 'Remplace le code (shared, l’Atelier, AtelierLink) par la dernière version publiée sur GitHub. Tes personnages, tes sets, tes touches et tes réglages ne sont jamais touchés.',
  updHave: 'Installée', updLatest: 'Dernière version', updNone: 'aucune', updUnknown: 'pas encore lue',
  updCheck: 'Chercher', updChecking: 'Recherche…', updApply: 'Installer la version {v}', updApplying: 'Installation…',
  updUndo: 'Revenir à la version {v}', updUndoWhy: 'La dernière mise à jour ({from} → {to}, {at}) peut être annulée : les fichiers remplacés ont été gardés.',
  updStep_scan: 'Lecture de tes fichiers : {n} / {m}', updStep_get: 'Téléchargement : {n} / {m}', updStep_write: 'Écriture : {n} / {m}',
  updUpToDate: 'Tu as la dernière version.', updNoRelease: 'Aucune version n’est encore publiée.',
  updReady: '{n} fichiers à changer : nouveaux {a}, remplacés {u}, retirés {r}.',
  updChanged: 'Fichiers de code que tu as modifiés, remplacés quand même (ta copie est gardée) : {l}',
  updKept: 'Fichiers retirés de la nouvelle version mais modifiés chez toi, laissés en place : {l}',
  updNotes: 'Ce qui change', updMore: 'Voir sur GitHub',
  updDone: 'Version {v} installée.', updDoneReload: 'GearSwap redémarre.',
  updDoneRelink: 'AtelierLink et GearSwap redémarrent.',
  updUndone: 'Version {v} remise en place.',
  updGit: 'Ce dossier est suivi par git (dossier de développement) : la mise à jour ne s’y fait pas, utilise git.',
  updNet: 'GitHub n’a pas répondu : vérifie ta connexion. ({e})',
  updFail: 'La mise à jour n’a pas pu se faire : {e}. Rien n’a été remplacé.',
  updFailHalf: 'La mise à jour s’est arrêtée en cours : {e}. Utilise « Revenir » pour remettre tes fichiers comme avant.',
  updNoLink: 'La mise à jour passe par le jeu : lance-le, tape une fois //gs c atelier link (l’addon AtelierLink), puis Chercher.',
  updOldLink: 'AtelierLink est trop ancien pour la mise à jour : dans le jeu, tape //gs c atelier link, puis Chercher.',
  updSafe: 'Avant d’écrire, tout est téléchargé et vérifié ; les fichiers remplacés sont gardés dans data/update/backup.'});
Object.assign(T.en, {updOpen: 'Update', ttUpd: 'Look for a new GearSwap version and install it',
  ttUpdNew: 'New version available: {v}',
  updTitle: 'Update', updBack: 'Back',
  updLede: 'Replaces the code (shared, the Atelier, AtelierLink) with the latest version published on GitHub. Your characters, sets, keys and settings are never touched.',
  updHave: 'Installed', updLatest: 'Latest version', updNone: 'none', updUnknown: 'not read yet',
  updCheck: 'Look', updChecking: 'Looking…', updApply: 'Install version {v}', updApplying: 'Installing…',
  updUndo: 'Go back to version {v}', updUndoWhy: 'The last update ({from} → {to}, {at}) can be undone: the files it replaced were kept.',
  updStep_scan: 'Reading your files: {n} / {m}', updStep_get: 'Downloading: {n} / {m}', updStep_write: 'Writing: {n} / {m}',
  updUpToDate: 'You have the latest version.', updNoRelease: 'No version is published yet.',
  updReady: '{n} files to change: new {a}, replaced {u}, removed {r}.',
  updChanged: 'Code files you changed, replaced all the same (your copy is kept): {l}',
  updKept: 'Files the new version drops but you changed, left in place: {l}',
  updNotes: 'What changes', updMore: 'See on GitHub',
  updDone: 'Version {v} installed.', updDoneReload: 'GearSwap restarts.',
  updDoneRelink: 'AtelierLink and GearSwap restart.',
  updUndone: 'Version {v} put back.',
  updGit: 'This folder is under git (a development folder): no update here, use git.',
  updNet: 'GitHub did not answer: check your connection. ({e})',
  updFail: 'The update could not be done: {e}. Nothing was replaced.',
  updFailHalf: 'The update stopped halfway: {e}. Use “Go back” to put your files back as they were.',
  updNoLink: 'The update goes through the game: start it, type //gs c atelier link once (the AtelierLink addon), then Look.',
  updOldLink: 'AtelierLink is too old for the update: in game, type //gs c atelier link, then Look.',
  updSafe: 'Before writing, everything is downloaded and checked; the files replaced are kept in data/update/backup.'});

// state: '' (not looked), busy, nolink, git, none (no release), uptodate, ready, done, fail
const UPD = {state: '', step: null, msg: '', msgCls: '', inst: null, rel: null, remote: null, plan: null, last: null, env: null, link: null};
const UPD_LINK = 'scripts/atelier/AtelierLink/AtelierLink.lua';
const UPD_SEEN = 'atelierUpdSeen';
const UPD_BATCH = 150;

// One request to AtelierLink's door: JSON back, or bytes
async function updCall(conf, path, opts = {}){
  const r = await fetch(`http://127.0.0.1:${conf.port}${path}`, {method: opts.method || 'GET', body: opts.body,
    headers: {'X-Atelier-Token': conf.token}, cache: 'no-store'});
  if (!r.ok) { const e = new Error('AtelierLink: HTTP ' + r.status); e.status = r.status; throw e; }
  return opts.bytes ? new Uint8Array(await r.arrayBuffer()) : r.json();
}
// /read's answer: per path "<size>\n<bytes>", "-1\n" when missing
function updSplit(paths, bytes){
  const out = new Map();
  let i = 0;
  for (const p of paths) {
    const nl = bytes.indexOf(10, i), n = parseInt(new TextDecoder().decode(bytes.subarray(i, nl)), 10);
    if (n < 0) { out.set(p, null); i = nl + 1; continue; }
    out.set(p, bytes.slice(nl + 1, nl + 1 + n));
    i = nl + 1 + n;
  }
  return out;
}
// The data folder, as AtelierLink serves it, as an env for update_core.js (paths relative to data/)
function updEnv(conf, git){
  const seen = new Map(), q = rel => '?path=' + encodeURIComponent(rel);
  async function readMany(paths, progress){
    for (let i = 0; i < paths.length; i += UPD_BATCH) {
      const part = paths.slice(i, i + UPD_BATCH);
      updSplit(part, await updCall(conf, '/read', {method: 'POST', body: part.join('\n'), bytes: true})).forEach((b, p) => seen.set(p, b));
      if (progress) progress('scan', Math.min(i + UPD_BATCH, paths.length), paths.length);
    }
  }
  return {
    preload: readMany,
    async bytes(rel){ if (!seen.has(rel)) await readMany([rel]); return seen.get(rel); },
    async write(rel, bytes){ await updCall(conf, '/file' + q(rel), {method: 'POST', body: bytes}); seen.set(rel, bytes); },
    async remove(rel){ await updCall(conf, '/remove' + q(rel), {method: 'POST'}); seen.set(rel, null); },
    async exists(rel){ return rel === '.git' ? git : (await this.bytes(rel)) !== null; }
  };
}

// The door of the game running this page's install: the character shown first, then the last one logged in
// (atelier/link_last.js, written by AtelierLink: a fresh package has no character in the page yet)
function updLoadScript(src){
  return new Promise(done => { const el = document.createElement('script'); el.src = src + '?t=' + Date.now();
    el.onload = el.onerror = () => { el.remove(); done(); }; document.head.appendChild(el); });
}
async function updFindLink(){
  await updLoadScript('atelier/link_last.js');
  if (S.char) await updLoadScript(`atelier/link_${S.char}.js`);
  const all = window.ATELIER_LINK || {}, names = [S.char, window.ATELIER_LINK_LAST].concat(Object.keys(all));
  let old = false;
  for (const c of names.filter((c, i, a) => c && all[c] && a.indexOf(c) === i)) {
    try { return {c, conf: all[c], info: await updCall(all[c], '/info')}; }
    catch (e) { if (e.status === 404) old = true; }
  }
  return old ? 'old' : null;
}

const updStep = (what, n, m) => { UPD.step = {what, n, m}; render(); };
const updErr = e => String(e && e.message || e);
const updFail = (msg) => { Object.assign(UPD, {state: 'fail', msg, msgCls: 'kwarn', step: null}); render(); };

// The game's door, the version installed, the latest release and what installing it changes
async function updCheck(){
  Object.assign(UPD, {state: 'busy', step: null, msg: '', msgCls: ''});
  render();
  try {
    const link = await updFindLink();
    if (!link || link === 'old') { Object.assign(UPD, {state: 'nolink', msg: t(link ? 'updOldLink' : 'updNoLink'), msgCls: 'kwarn'}); return render(); }
    UPD.link = link;
    UPD.env = updEnv(link.conf, !!link.info.git);
    UPD.inst = await UpdCore.installed(UPD.env);
    UPD.last = await UpdCore.lastUpdate(UPD.env);
    if (link.info.git) { UPD.state = 'git'; return render(); }
    try { UPD.rel = await UpdCore.latest(fetch); }
    catch (e) { if (updErr(e) === 'none') { UPD.state = 'none'; return render(); } throw new Error(t('updNet', {e: updErr(e)})); }
    UPD.remote = await UpdCore.manifestOf(fetch, UPD.rel.tag);
    UPD.plan = await UpdCore.plan(UPD.env, UPD.remote.m, UPD.inst, updStep);
    const p = UPD.plan, n = p.add.length + p.update.length + p.remove.length;
    UPD.state = n ? 'ready' : 'uptodate';
    S._updNew = n && UpdCore.newer(UPD.rel.version, UPD.inst.version) ? UPD.rel.version : null;
  } catch (e) { return updFail(updErr(e)); }
  UPD.step = null;
  render();
}

// Once the files are written: AtelierLink restarts GearSwap, and itself first when the update changed it
async function updAfter(text, relink){
  try {
    await updCall(UPD.link.conf, relink ? '/relink' : '/gearswap?do=reload', {method: 'POST'});
    UPD.msg = text + ' ' + t(relink ? 'updDoneRelink' : 'updDoneReload');
  } catch (e) { UPD.msg = text + ' (' + updErr(e) + ')'; }
  UPD.msgCls = '';
}

async function updApply(){
  const p = UPD.plan, writes = p.add.concat(p.update);
  Object.assign(UPD, {state: 'busy', step: null, msg: ''});
  render();
  let got;
  try { got = await UpdCore.download(fetch, UPD.rel.tag, UPD.remote.m, writes, updStep); }
  catch (e) { return updFail(t('updFail', {e: updErr(e)})); }
  try { await UpdCore.apply(UPD.env, p, got, UPD.remote, UPD.inst, updStep); }
  catch (e) {
    UPD.last = await UpdCore.lastUpdate(UPD.env).catch(() => null);
    return updFail(t(UPD.last ? 'updFailHalf' : 'updFail', {e: updErr(e)}));
  }
  Object.assign(UPD, {state: 'done', step: null});
  S._updNew = null;
  UPD.inst = await UpdCore.installed(UPD.env);
  UPD.last = await UpdCore.lastUpdate(UPD.env);
  await updAfter(t('updDone', {v: UPD.rel.version}), writes.includes(UPD_LINK));
  render();
}

async function updUndo(){
  Object.assign(UPD, {state: 'busy', step: null, msg: ''});
  render();
  try {
    const u = await UpdCore.rollback(UPD.env);
    UPD.inst = await UpdCore.installed(UPD.env);
    UPD.last = await UpdCore.lastUpdate(UPD.env);
    UPD.plan = null;
    UPD.state = 'done';
    await updAfter(t('updUndone', {v: u.from || '?'}), u.replaced.includes(UPD_LINK) || u.added.includes(UPD_LINK));
  } catch (e) { return updFail(updErr(e)); }
  render();
}

function updOpenPage(){
  const open = !(S._cfg && S._upd);
  S._cfg = open; S._upd = open; S._pkg = false;
  render(); scrollTo({top: 0});
  if (open && (UPD.state === '' || UPD.state === 'nolink')) updCheck();
}

// Asked from the game (//gs c upgrade): the page opened with #update, or atelier/update_ask.js written within its time
function updAsked(){
  if (/^#update$/.test(location.hash)) return true;
  const a = window.ATELIER_UPDATE_ASK;
  if (!a || Date.now() / 1000 - a.at > a.within) return false;
  try { if (sessionStorage.getItem(UPD_SEEN) === String(a.at)) return false; sessionStorage.setItem(UPD_SEEN, String(a.at)); } catch (e) {}
  return true;
}
// Twice a day at most, quietly: is there a version newer than the one installed? Lights the top bar's button. Needs the
// game's door (the version installed is read through it)
async function updQuietCheck(){
  let seen = null;
  try { seen = JSON.parse(localStorage.getItem('atelierUpdLatest') || 'null'); } catch (e) {}
  if (!seen || Date.now() - seen.at > 12 * 3600e3) {
    try { const r = await UpdCore.latest(fetch); seen = {at: Date.now(), v: r.version}; } catch (e) { seen = {at: Date.now(), v: ''}; }
    try { localStorage.setItem('atelierUpdLatest', JSON.stringify(seen)); } catch (e) {}
  }
  if (!seen.v) return;
  const link = await updFindLink();
  if (!link || link === 'old' || link.info.git) return;
  if (UpdCore.newer(seen.v, link.info.version)) { S._updNew = seen.v; render(); }
}
setTimeout(() => {
  if (typeof render !== 'function') return;
  if (updAsked()) updOpenPage();
  updQuietCheck().catch(() => {});
}, 600);

// Its own clicks, caught before the page's (events.js knows nothing of them)
document.addEventListener('click', e => {
  const b = e.target.closest('[data-updopen],[data-updcheck],[data-updapply],[data-updundo]');
  if (!b) return;
  e.stopImmediatePropagation();
  const d = b.dataset;
  if ('updopen' in d) return updOpenPage();
  if (UPD.state === 'busy') return;
  if ('updcheck' in d) return updCheck();
  if ('updapply' in d) return updApply();
  if ('updundo' in d) return updUndo();
}, true);
