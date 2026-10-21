// GearSwap Atelier · update.js: the update screen (the ⬆ button of the top bar, or //gs c upgrade in game, which opens
// the page with #update and writes atelier/update_ask.js). It shows the version installed and the latest release on
// GitHub, what the update changes, and installs it into the Windower folder the player showed the page once; then it
// asks AtelierLink to restart GearSwap. What an update does is update_core.js; this file holds its state (UPD), its
// clicks (data-updopen, data-updcheck, data-updapply, data-updundo) and its words. Drawn by screens/update (Svelte),
// as a page of the Settings (S._cfg with S._upd), so every other screen already steps aside.

Object.assign(T.fr, {updOpen: 'Mise à jour', ttUpd: 'Chercher une nouvelle version de GearSwap et l’installer',
  ttUpdNew: 'Nouvelle version disponible : {v}',
  updTitle: 'Mise à jour', updBack: 'Retour',
  updLede: 'Remplace le code (shared, l’Atelier, AtelierLink) par la dernière version publiée sur GitHub. Tes personnages, tes sets, tes touches et tes réglages ne sont jamais touchés.',
  updHave: 'Installée', updLatest: 'Dernière version', updNone: 'aucune', updUnknown: 'pas encore lue',
  updCheck: 'Chercher', updChecking: 'Recherche…', updApply: 'Installer la version {v}', updApplying: 'Installation…',
  updUndo: 'Revenir à la version {v}', updUndoWhy: 'La dernière mise à jour ({from} → {to}, {at}) peut être annulée : les fichiers remplacés ont été gardés.',
  updStep_scan: 'Comparaison de tes fichiers : {n} / {m}', updStep_get: 'Téléchargement : {n} / {m}', updStep_write: 'Écriture : {n} / {m}',
  updUpToDate: 'Tu as la dernière version.', updNoRelease: 'Aucune version n’est encore publiée.',
  updReady: '{n} fichiers à changer : nouveaux {a}, remplacés {u}, retirés {r}.',
  updChanged: 'Fichiers de code que tu as modifiés, remplacés quand même (ta copie est gardée) : {l}',
  updKept: 'Fichiers retirés de la nouvelle version mais modifiés chez toi, laissés en place : {l}',
  updNotes: 'Ce qui change', updMore: 'Voir sur GitHub',
  updDone: 'Version {v} installée.', updDoneReload: 'GearSwap redémarre.', updDoneHow: 'Dans le jeu, tape //lua reload gearswap pour que GearSwap charge ces fichiers.',
  updLinkNew: 'AtelierLink a changé : tape //gs c atelier link dans le jeu pour l’installer.',
  updUndone: 'Version {v} remise en place.',
  updGit: 'Ce dossier est suivi par git (dossier de développement) : la mise à jour ne s’y fait pas, utilise git.',
  updNet: 'GitHub n’a pas répondu : vérifie ta connexion. ({e})',
  updFail: 'La mise à jour n’a pas pu se faire : {e}. Rien n’a été remplacé.',
  updFailHalf: 'La mise à jour s’est arrêtée en cours : {e}. Utilise « Revenir » pour remettre tes fichiers comme avant.',
  updFolder: 'Pour mettre à jour, la page doit écrire dans ton dossier Windower.', updFolderBtn: 'Montrer le dossier Windower',
  updFolderWhy: 'La mise à jour écrit les nouveaux fichiers dans ton dossier Windower (addons/GearSwap/data). Montre-le-lui une fois :',
  updNeedChrome: 'Il faut Chrome ou Edge : ils seuls laissent une page écrire dans un dossier.',
  updSafe: 'Avant d’écrire, tout est téléchargé et vérifié ; les fichiers remplacés sont gardés dans data/update/backup.'});
Object.assign(T.en, {updOpen: 'Update', ttUpd: 'Look for a new GearSwap version and install it',
  ttUpdNew: 'New version available: {v}',
  updTitle: 'Update', updBack: 'Back',
  updLede: 'Replaces the code (shared, the Atelier, AtelierLink) with the latest version published on GitHub. Your characters, sets, keys and settings are never touched.',
  updHave: 'Installed', updLatest: 'Latest version', updNone: 'none', updUnknown: 'not read yet',
  updCheck: 'Look', updChecking: 'Looking…', updApply: 'Install version {v}', updApplying: 'Installing…',
  updUndo: 'Go back to version {v}', updUndoWhy: 'The last update ({from} → {to}, {at}) can be undone: the files it replaced were kept.',
  updStep_scan: 'Comparing your files: {n} / {m}', updStep_get: 'Downloading: {n} / {m}', updStep_write: 'Writing: {n} / {m}',
  updUpToDate: 'You have the latest version.', updNoRelease: 'No version is published yet.',
  updReady: '{n} files to change: new {a}, replaced {u}, removed {r}.',
  updChanged: 'Code files you changed, replaced all the same (your copy is kept): {l}',
  updKept: 'Files the new version drops but you changed, left in place: {l}',
  updNotes: 'What changes', updMore: 'See on GitHub',
  updDone: 'Version {v} installed.', updDoneReload: 'GearSwap restarts.', updDoneHow: 'In game, type //lua reload gearswap so GearSwap loads these files.',
  updLinkNew: 'AtelierLink changed: type //gs c atelier link in game to install it.',
  updUndone: 'Version {v} put back.',
  updGit: 'This folder is under git (a development folder): no update here, use git.',
  updNet: 'GitHub did not answer: check your connection. ({e})',
  updFail: 'The update could not be done: {e}. Nothing was replaced.',
  updFailHalf: 'The update stopped halfway: {e}. Use “Go back” to put your files back as they were.',
  updFolder: 'To update, the page has to write into your Windower folder.', updFolderBtn: 'Show the Windower folder',
  updFolderWhy: 'The update writes the new files into your Windower folder (addons/GearSwap/data). Show it the folder once:',
  updNeedChrome: 'Chrome or Edge is needed: only they let a page write into a folder.',
  updSafe: 'Before writing, everything is downloaded and checked; the files replaced are kept in data/update/backup.'});

// state: '' (not looked), busy, folder (no access yet), git, none (no release), uptodate, ready, done, fail
const UPD = {state: '', step: null, msg: '', msgCls: '', inst: null, rel: null, remote: null, plan: null, last: null, env: null, root: null};
const UPD_LINK = 'scripts/atelier/AtelierLink/AtelierLink.lua';
const UPD_SEEN = 'atelierUpdSeen';

// The data folder as an env for update_core.js (paths relative to data/, '/' between folders)
async function updDataDir(root){
  let d = root;
  for (const n of ['addons', 'GearSwap', 'data']) d = await d.getDirectoryHandle(n);
  return d;
}
function updEnv(data){
  const dirs = new Map([['', data]]);
  const split = rel => { const i = rel.lastIndexOf('/'); return [i < 0 ? '' : rel.slice(0, i), rel.slice(i + 1)]; };
  async function dirOf(rel, create){
    if (dirs.has(rel)) return dirs.get(rel);
    const [up, name] = split(rel), parent = await dirOf(up, create);
    const h = await parent.getDirectoryHandle(name, {create: !!create});
    dirs.set(rel, h);
    return h;
  }
  return {
    async bytes(rel){
      try { const [up, n] = split(rel), f = await (await (await dirOf(up)).getFileHandle(n)).getFile(); return new Uint8Array(await f.arrayBuffer()); }
      catch (e) { return null; } },
    async write(rel, bytes){
      const [up, n] = split(rel), h = await (await dirOf(up, true)).getFileHandle(n, {create: true}), w = await h.createWritable();
      await w.write(bytes); await w.close(); },
    async remove(rel){ try { const [up, n] = split(rel); await (await dirOf(up)).removeEntry(n); } catch (e) {} },
    async exists(rel){
      const [up, n] = split(rel);
      let d;
      try { d = await dirOf(up); } catch (e) { return false; }
      try { await d.getDirectoryHandle(n); return true; } catch (e) {}
      try { await d.getFileHandle(n); return true; } catch (e) { return false; } }
  };
}

const updStep = (what, n, m) => { UPD.step = {what, n, m}; render(); };
const updErr = e => String(e && e.message || e);

// The folder, the version installed, the latest release and what installing it changes. ask: may ask the browser for
// the folder (only from a click: a permission is never asked without one)
async function updCheck(ask){
  if (!window.showDirectoryPicker) { UPD.state = 'fail'; UPD.msg = t('updNeedChrome'); return render(); }
  Object.assign(UPD, {state: 'busy', step: null, msg: '', msgCls: ''});
  render();
  try {
    const root = await oxWindowerFolder(ask);
    if (!root) { UPD.state = 'folder'; return render(); }
    UPD.root = root;
    UPD.env = updEnv(await updDataDir(root));
    UPD.inst = await UpdCore.installed(UPD.env);
    UPD.last = await UpdCore.lastUpdate(UPD.env);
    if (await UPD.env.exists('.git')) { UPD.state = 'git'; return render(); }
    try { UPD.rel = await UpdCore.latest(fetch); }
    catch (e) { if (updErr(e) === 'none') { UPD.state = 'none'; return render(); } throw new Error(t('updNet', {e: updErr(e)})); }
    UPD.remote = await UpdCore.manifestOf(fetch, UPD.rel.tag);
    UPD.plan = await UpdCore.plan(UPD.env, UPD.remote.m, UPD.inst, updStep);
    const p = UPD.plan, n = p.add.length + p.update.length + p.remove.length;
    UPD.state = n ? 'ready' : 'uptodate';
    S._updNew = n && UpdCore.newer(UPD.rel.version, UPD.inst.version) ? UPD.rel.version : null;
  } catch (e) { UPD.state = 'fail'; UPD.msg = updErr(e); UPD.msgCls = 'kwarn'; }
  UPD.step = null;
  render();
}

// Once the files are written: AtelierLink restarts GearSwap when the page reaches it, else the player does
function updAfter(text){
  const reload = typeof linkOk === 'function' && S.char && linkOk(S.char);
  UPD.msg = text + ' ' + t(reload ? 'updDoneReload' : 'updDoneHow');
  UPD.msgCls = '';
  if (reload) linkGearSwap('reload');
}

async function updApply(){
  const p = UPD.plan, writes = p.add.concat(p.update);
  Object.assign(UPD, {state: 'busy', step: null, msg: ''});
  render();
  let got;
  try { got = await UpdCore.download(fetch, UPD.rel.tag, UPD.remote.m, writes, updStep); }
  catch (e) { UPD.state = 'fail'; UPD.msg = t('updFail', {e: updErr(e)}); UPD.msgCls = 'kwarn'; UPD.step = null; return render(); }
  try { await UpdCore.apply(UPD.env, p, got, UPD.remote, UPD.inst, updStep); }
  catch (e) {
    UPD.last = await UpdCore.lastUpdate(UPD.env).catch(() => null);
    UPD.state = 'fail'; UPD.msg = t(UPD.last ? 'updFailHalf' : 'updFail', {e: updErr(e)}); UPD.msgCls = 'kwarn'; UPD.step = null; return render();
  }
  UPD.state = 'done'; UPD.step = null; S._updNew = null;
  UPD.inst = await UpdCore.installed(UPD.env);
  UPD.last = await UpdCore.lastUpdate(UPD.env);
  updAfter(t('updDone', {v: UPD.rel.version}) + (writes.includes(UPD_LINK) ? ' ' + t('updLinkNew') : ''));
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
    updAfter(t('updUndone', {v: u.from || '?'}));
  } catch (e) { UPD.state = 'fail'; UPD.msg = updErr(e); UPD.msgCls = 'kwarn'; }
  render();
}

function updOpenPage(){
  const open = !(S._cfg && S._upd);
  S._cfg = open; S._upd = open; S._pkg = false;
  render(); scrollTo({top: 0});
  if (open && (UPD.state === '' || UPD.state === 'folder')) updCheck(false);
}
function updFolder(){
  oxWindowerFolder(true).then(root => root ? updCheck(false)
    : openFolderDialog(async () => { await oxPickWindower(); updCheck(false); }, () => {}, {title: t('wfolderTitle'), why: t('updFolderWhy'), path: pageFolder().replace(/\\addons\\GearSwap\\data$/i, '')}))
    .catch(e => { UPD.state = 'fail'; UPD.msg = updErr(e); UPD.msgCls = 'kwarn'; render(); });
}

// Asked from the game (//gs c upgrade): the page opened with #update, or atelier/update_ask.js written within its time
function updAsked(){
  if (/^#update$/.test(location.hash)) return true;
  const a = window.ATELIER_UPDATE_ASK;
  if (!a || Date.now() / 1000 - a.at > a.within) return false;
  try { if (sessionStorage.getItem(UPD_SEEN) === String(a.at)) return false; sessionStorage.setItem(UPD_SEEN, String(a.at)); } catch (e) {}
  return true;
}
// Twice a day at most, quietly: is there a version newer than the one installed? Lights the top bar's button. Reads the
// folder only when the page may already (no permission asked)
async function updQuietCheck(){
  let seen = null;
  try { seen = JSON.parse(localStorage.getItem('atelierUpdLatest') || 'null'); } catch (e) {}
  if (!seen || Date.now() - seen.at > 12 * 3600e3) {
    try { const r = await UpdCore.latest(fetch); seen = {at: Date.now(), v: r.version}; } catch (e) { seen = {at: Date.now(), v: ''}; }
    try { localStorage.setItem('atelierUpdLatest', JSON.stringify(seen)); } catch (e) {}
  }
  if (!seen.v) return;
  const root = await oxWindowerFolder(false).catch(() => null);
  if (!root) return;
  const env = updEnv(await updDataDir(root)), inst = await UpdCore.installed(env);
  if (await env.exists('.git')) return;
  if (UpdCore.newer(seen.v, inst.version)) { S._updNew = seen.v; render(); }
}
setTimeout(() => {
  if (typeof render !== 'function') return;
  if (updAsked()) updOpenPage();
  updQuietCheck().catch(() => {});
}, 600);

// Its own clicks, caught before the page's (events.js knows nothing of them)
document.addEventListener('click', e => {
  const b = e.target.closest('[data-updopen],[data-updcheck],[data-updapply],[data-updundo],[data-updfolder]');
  if (!b) return;
  e.stopImmediatePropagation();
  const d = b.dataset;
  if ('updopen' in d) return updOpenPage();
  if (UPD.state === 'busy') return;
  if ('updcheck' in d) return updCheck(true);
  if ('updapply' in d) return updApply();
  if ('updundo' in d) return updUndo();
  if ('updfolder' in d) return updFolder();
}, true);
