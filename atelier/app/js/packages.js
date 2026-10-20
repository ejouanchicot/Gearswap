// GearSwap Atelier · packages.js: the Packages page (the 📦 button of the top bar): a whole GearSwap for one player,
// in one zip, built in the page. The zip is what data/make_package.py writes (the GearSwap addon, Mote's libraries,
// shared/, the character cloned from _master/ by clone_character.py, the Atelier): that same Python file runs here,
// in Pyodide (Python compiled to WebAssembly, loaded from cdn.jsdelivr.net the first time), in a worker so the page
// stays alive. Only what make_package.sources() names is read from the Windower folder; nothing is written in it.

Object.assign(T.fr, {pkgOpen: 'Paquets', ttPkg: 'Préparer un GearSwap complet pour un joueur, dans un zip',
  pkgTitle: 'Paquet pour un joueur', pkgBack: 'Retour',
  pkgLede: 'Un zip qui contient tout : GearSwap, notre code, le personnage prêt à jouer et l’Atelier. Le joueur le dézippe dans Windower/addons, c’est tout.',
  pkgWho: 'Personnage', pkgWhoWhy: 'Son nom exact dans le jeu. Un personnage déjà préparé (converti depuis ses fichiers) reprend son équipement ; un nouveau part des modèles de base.',
  pkgName: 'Nom du personnage', pkgKnown: 'Préparé : ses sets et réglages à lui', pkgNew: 'Nouveau : les modèles de base, sets à remplir',
  pkgNoList: 'La liste des personnages préparés apparaît une fois le dossier Windower montré à la page.', pkgFolder: 'Montrer le dossier Windower',
  pkgJobs: 'Jobs', pkgJobsWhy: 'Les jobs mis dans son dossier. Il pourra en ajouter plus tard.', pkgAll: 'Tous', pkgNone: 'Aucun',
  pkgBox: 'Deux personnages à la fois', pkgBoxWhy: 'Si le joueur joue deux personnages en même temps, chacun voit le job de l’autre.',
  pkgSolo: 'Un seul', pkgMain: 'Principal, avec un alt', pkgAlt: 'Alt d’un principal', pkgPartner: 'Nom de l’autre personnage',
  pkgRegion: 'Région PlayOnline', pkgRegionWhy: 'Change seulement les commandes de macros envoyées au jeu.',
  pkgMake: 'Créer le paquet', pkgBusy: 'Création…', pkgNeedChrome: 'Il faut Chrome ou Edge : ils seuls laissent une page lire un dossier.',
  pkgBadName: 'Un nom de personnage : des lettres seulement, 3 à 15.', pkgNoJobs: 'Choisis au moins un job.', pkgNoPartner: 'Le nom de l’autre personnage manque.',
  pkgStep_python: 'Chargement de Python (la première fois, environ 10 Mo)…', pkgStep_read: 'Lecture des fichiers : {n} / {m}',
  pkgStep_clone: 'Préparation du personnage…', pkgStep_zip: 'Compression : {n} / {m}',
  pkgStep_export: 'Ses sets pour l’Atelier : job {n} / {m}…',
  pkgNoExports: 'Ses sets n’ont pas pu être préparés pour l’Atelier ({e}) : il les verra après son premier //gs c atelier en jeu.',
  pkgDone: '{f} téléchargé : {n} fichiers, {s} Mo.', pkgDoneHow: 'Envoie ce zip au joueur : INSTALLATION.txt, dedans, lui dit quoi faire.',
  pkgFail: 'Le paquet n’a pas pu être créé : {e}', pkgNoNet: 'Python n’a pas pu être chargé : il faut Internet la première fois.',
  pkgHolds: 'Dans le paquet', pkgHold1: 'GearSwap et les bibliothèques de Mote', pkgHold2: 'Notre code commun (shared)',
  pkgHold3: 'Le dossier du personnage, prêt à charger, ses sets déjà visibles dans l’Atelier', pkgHold4: 'L’Atelier, son moteur et l’addon AtelierLink', pkgHold5: 'INSTALLATION.txt, en français',
  pkgNever: 'Jamais dedans : tes personnages, tes clés de liaison, tes notes.',
  pkgFolderWhy: 'Pour préparer un paquet, la page lit GearSwap et les modèles de personnage dans ton dossier Windower. Montre-le-lui une fois :'});
Object.assign(T.en, {pkgOpen: 'Packages', ttPkg: 'Make a whole GearSwap for a player, in one zip',
  pkgTitle: 'Package for a player', pkgBack: 'Back',
  pkgLede: 'One zip that holds everything: GearSwap, our code, the character ready to play and the Atelier. The player unzips it into Windower/addons, that is all.',
  pkgWho: 'Character', pkgWhoWhy: 'Their exact name in game. A character already prepared (converted from their files) keeps their gear; a new one starts from the base templates.',
  pkgName: 'Character name', pkgKnown: 'Prepared: their own sets and settings', pkgNew: 'New: the base templates, sets to fill',
  pkgNoList: 'The prepared characters show once the page has been shown the Windower folder.', pkgFolder: 'Show the Windower folder',
  pkgJobs: 'Jobs', pkgJobsWhy: 'The jobs put in their folder. More can be added later.', pkgAll: 'All', pkgNone: 'None',
  pkgBox: 'Two characters at once', pkgBoxWhy: 'When the player plays two characters together, each sees the other’s job.',
  pkgSolo: 'One only', pkgMain: 'Main, with an alt', pkgAlt: 'Alt of a main', pkgPartner: 'The other character’s name',
  pkgRegion: 'PlayOnline region', pkgRegionWhy: 'Only changes the macro commands sent to the game.',
  pkgMake: 'Make the package', pkgBusy: 'Making…', pkgNeedChrome: 'Chrome or Edge is needed: only they let a page read a folder.',
  pkgBadName: 'A character name: letters only, 3 to 15.', pkgNoJobs: 'Pick one job at least.', pkgNoPartner: 'The other character’s name is missing.',
  pkgStep_python: 'Loading Python (about 10 MB, the first time)…', pkgStep_read: 'Reading the files: {n} / {m}',
  pkgStep_clone: 'Preparing the character…', pkgStep_zip: 'Compressing: {n} / {m}',
  pkgStep_export: 'Their sets for the Atelier: job {n} / {m}…',
  pkgNoExports: 'Their sets could not be prepared for the Atelier ({e}): they will see them after their first //gs c atelier in game.',
  pkgDone: '{f} downloaded: {n} files, {s} MB.', pkgDoneHow: 'Send this zip to the player: INSTALLATION.txt, inside, tells them what to do.',
  pkgFail: 'The package could not be made: {e}', pkgNoNet: 'Python could not be loaded: Internet is needed the first time.',
  pkgHolds: 'In the package', pkgHold1: 'GearSwap and Mote’s libraries', pkgHold2: 'Our shared code',
  pkgHold3: 'The character’s folder, ready to load, their sets already shown in the Atelier', pkgHold4: 'The Atelier, its engine and the AtelierLink addon', pkgHold5: 'INSTALLATION.txt, in French',
  pkgNever: 'Never inside: your characters, your link keys, your notes.',
  pkgFolderWhy: 'To make a package, the page reads GearSwap and the character templates in your Windower folder. Show it the folder once:'});

const PKG_JOBS = ['BLM', 'BLU', 'BRD', 'BST', 'COR', 'DNC', 'DRG', 'DRK', 'GEO', 'MNK', 'NIN', 'PLD', 'PUP', 'RDM', 'RNG', 'RUN',
  'SAM', 'SCH', 'SMN', 'THF', 'WAR', 'WHM'];
const PYODIDE_URL = 'https://cdn.jsdelivr.net/pyodide/v0.26.4/full/pyodide.js';
// The page's form, kept while the page is open (not in the browser: a package is made once, for one player)
const PKG = {name: '', jobs: [], box: 'solo', partner: '', region: 'US', known: null, state: '', msg: ''};
const pkgName = s => s.trim().replace(/^(.)(.*)$/, (_, a, b) => a.toUpperCase() + b.toLowerCase());
const pkgKnownOf = n => PKG.known && PKG.known.find(c => c.name.toLowerCase() === n.trim().toLowerCase());

// The characters of character_db.lua (the same reading as clone_character.parse_character_db) and whether each has
// its overlay _master/<Name>/; null while the Windower folder is not open to the page
async function pkgReadKnown(){
  const root = await oxWindowerFolder(false);
  if (!root) return null;
  const env = oxEnv(root), text = await env.text('addons/GearSwap/data/character_db.lua');
  if (!text) return null;
  const masters = new Set(((await env.list('addons/GearSwap/data/_master')) || []).filter(e => e.dir).map(e => e.name));
  const out = [];
  for (const m of text.matchAll(/(\w+)\s*=\s*\{\s*jobs\s*=\s*\{([^}]*)\}\s*,\s*role\s*=\s*'(\w+)'/g))
    out.push({name: m[1], jobs: [...m[2].matchAll(/'(\w+)'/g)].map(x => x[1]), role: m[3], overlay: masters.has(m[1])});
  return out;
}
function pkgOpenPage(){
  S._pkg = !S._pkg; if (S._pkg) S._cfg = false;
  render(); scrollTo({top: 0});
  if (S._pkg && PKG.known === null) pkgLoadKnown();
}
// A name typed: a prepared character fills in its jobs and its role
function pkgSetName(v){
  PKG.name = v;
  const k = pkgKnownOf(v);
  if (k) { PKG.jobs = k.jobs.slice(); if (k.role === 'alt' && PKG.box === 'solo') PKG.box = 'alt'; }
}

// The page is the Svelte application's (atelier/src/screens/packages); this function only says the Packages page is
// there (the screens and the top bar test it: typeof renderPackages)
function renderPackages(){ return ''; }

// The worker: Pyodide loaded once and kept, make_package.py run on a copy (in its memory) of what sources() names
const PKG_WORKER = `importScripts(${JSON.stringify(PYODIDE_URL)});
let py = null;
const say = m => postMessage(m);
async function dirAt(d, parts){ for (const p of parts) d = await d.getDirectoryHandle(p); return d; }
async function walk(d, rel, skip, ext, out){
  for await (const [name, h] of d.entries()) {
    if (skip.includes(name)) continue;
    if (h.kind === 'directory') await walk(h, rel + '/' + name, skip, ext, out);
    else if (!ext.some(x => name.endsWith(x))) out.push([rel + '/' + name, h]);
  }
}
async function copy(gs, list){
  let n = 0;
  for (let i = 0; i < list.length; i += 48) {
    await Promise.all(list.slice(i, i + 48).map(async ([rel, h]) => {
      const f = await h.getFile(), path = '/gs/' + rel;
      py.FS.mkdirTree(path.slice(0, path.lastIndexOf('/')));
      py.FS.writeFile(path, new Uint8Array(await f.arrayBuffer()));
      py.FS.utime(path, f.lastModified, f.lastModified);
    }));
    n = Math.min(list.length, i + 48); say({step: 'read', n, m: list.length});
  }
}
// the package's files, rel from the Windower folder (addons/GearSwap/...), for the Atelier's exports made in the page
function collect(dir, rel, out){
  for (const n of py.FS.readdir(dir)) {
    if (n === '.' || n === '..') continue;
    const p = dir + '/' + n;
    if (py.FS.isDir(py.FS.stat(p).mode)) collect(p, rel + '/' + n, out); else out.push([rel + '/' + n, py.FS.readFile(p)]);
  }
}
onmessage = async e => {
  const m = e.data;
  try {
    // second step: the exports the page made, added to the zip kept from the first
    if (m.add) {
      py.globals.set('pkg_add', py.toPy(m.add));
      py.runPython("make_package.add_files('/out.zip', [tuple(x) for x in pkg_add])");
      const bytes = py.FS.readFile('/out.zip');
      py.runPython("import os\\nos.remove('/out.zip')");
      return postMessage({done: true, bytes}, [bytes.buffer]);
    }
    if (!py) { say({step: 'python'}); py = await loadPyodide(); }
    py.runPython("import shutil, os\\nshutil.rmtree('/gs', ignore_errors=True)\\nos.makedirs('/gs/data')");
    const gs = await dirAt(m.root, ['addons', 'GearSwap']), data = await dirAt(gs, ['data']);
    const own = await (await data.getFileHandle('make_package.py')).getFile();
    py.FS.writeFile('/gs/data/make_package.py', new Uint8Array(await own.arrayBuffer()));
    py.runPython("import sys\\nsys.path.insert(0, '/gs/data') if '/gs/data' not in sys.path else None\\nsys.modules.pop('make_package', None)\\nimport make_package");
    const src = JSON.parse(py.runPython("import json\\njson.dumps(make_package.sources())"));
    const list = [];
    for (const f of src.files) { const parts = f.split('/');
      try { list.push([f, await (await dirAt(gs, parts.slice(0, -1))).getFileHandle(parts[parts.length - 1])]); } catch (x) {} }
    for (const tree of src.trees) { try { await walk(await dirAt(gs, tree.split('/')), tree, src.skip, src.skip_ext, list); } catch (x) {} }
    await copy(gs, list);
    say({step: 'clone'});
    py.globals.set('pkg_args', py.toPy(m.args));
    py.globals.set('pkg_progress', (n, total) => say({step: 'zip', n, m: total}));
    const sum = py.runPython("import json\\na = pkg_args\\njson.dumps(make_package.build(a['name'], data_dir='/gs/data', jobs=a['jobs'], role=a['role'], partner=a['partner'], region=a['region'], out='/out.zip', progress=pkg_progress))");
    py.runPython("import shutil, zipfile\\nshutil.rmtree('/gs', ignore_errors=True)\\nshutil.rmtree('/pkg', ignore_errors=True)\\nzipfile.ZipFile('/out.zip').extractall('/pkg')");
    const files = [];
    collect('/pkg/GearSwap', 'addons/GearSwap', files);
    py.runPython("import shutil\\nshutil.rmtree('/pkg', ignore_errors=True)");
    postMessage({built: JSON.parse(sum), files}, files.map(f => f[1].buffer));
  } catch (x) { say({error: String(x && x.message || x).split('\\n').filter(Boolean).slice(-1)[0] || 'error', net: !py}); }
};`;
let PKG_W = null;
function pkgWorker(){ return PKG_W || (PKG_W = new Worker(URL.createObjectURL(new Blob([PKG_WORKER], {type: 'text/javascript'})))); }

function pkgCheck(){
  const name = pkgName(PKG.name);
  if (!/^[A-Za-z]{3,15}$/.test(name)) return t('pkgBadName');
  if (!PKG.jobs.length) return t('pkgNoJobs');
  if (PKG.box !== 'solo' && !/^[A-Za-z]{3,15}$/.test(PKG.partner.trim())) return t('pkgNoPartner');
  return null;
}
function pkgMake(){
  if (PKG.state === 'busy') return;
  if (!window.showDirectoryPicker) { PKG.state = 'fail'; PKG.msg = t('pkgNeedChrome'); return render(); }
  const bad = pkgCheck();
  if (bad) { PKG.state = 'fail'; PKG.msg = bad; return render(); }
  const go = root => {
    const name = pkgName(PKG.name);
    const args = {name, jobs: PKG.jobs.slice(), region: PKG.region,
      role: PKG.box === 'solo' ? null : PKG.box, partner: PKG.box === 'solo' ? null : pkgName(PKG.partner)};
    const show = (msg, state = 'busy') => { PKG.state = state; PKG.msg = msg; if (S._pkg) render(); };
    show(t('pkgStep_python'));
    const w = pkgWorker();
    let built = null, exported = null;
    w.onmessage = async e => { const m = e.data;
      if (m.step) return show(t('pkgStep_' + m.step, {n: m.n, m: m.m}));
      if (m.error) return show(m.net ? t('pkgNoNet') : t('pkgFail', {e: m.error}), 'fail');
      // the zip is made: the Atelier's exports, made here with the page's Lua, go into it before it is handed over
      if (m.built) { built = m.built; exported = await pkgExports(root, m.files, name, show); return w.postMessage({add: exported.files}); }
      const file = `GearSwap_${name}.zip`, a = document.createElement('a');
      a.href = URL.createObjectURL(new Blob([m.bytes], {type: 'application/zip'})); a.download = file;
      document.body.appendChild(a); a.click(); a.remove(); setTimeout(() => URL.revokeObjectURL(a.href), 60000);
      show(t('pkgDone', {f: file, n: built.files + exported.files.length, s: (m.bytes.byteLength / 1048576).toFixed(1)}) +
        (exported.error ? ' ' + t('pkgNoExports', {e: exported.error}) : ''), 'done');
      if (PKG.known === null) pkgLoadKnown();
    };
    // a worker that fails to start (Pyodide not reachable): told as a network fault, and a new one next time
    w.onerror = e => { PKG_W = null; w.terminate(); show(t('pkgNoNet'), 'fail'); };
    w.postMessage({root, args});
  };
  pkgFolder(go);
}
// The Atelier's exports of the package (package_exports.js, with the page's Lua: offline_export.js oxLua), as
// [[path in the zip, text]]; a package without them still works (the game's //gs c atelier makes them): a failure
// is said, not fatal
async function pkgExports(root, list, name, show){
  try {
    const load = f => new Promise(done => loadScripts([f + '?v=' + Date.now()], done));
    if (!window.ATELIER_LUA) await load('atelier/lua/lua51.js');
    if (typeof PackageExports === 'undefined') await load('atelier/app/js/package_exports.js');
    if (!window.ATELIER_LUA || typeof PackageExports === 'undefined') throw new Error(t('refreshNoLua'));
    show(t('pkgStep_export', {n: 0, m: PKG.jobs.length}));
    const {result, files, icons} = await PackageExports.run(new Map(list), oxEnv(root), oxLua, name,
      (step, n, m) => { if (step === 'jobs') show(t('pkgStep_export', {n, m})); });
    const failed = result.failed.map(f => f[0] + '/' + f[1]).join(', ');
    return {files: files.concat(icons).map(([rel, data]) => ['GearSwap/' + rel.slice('addons/GearSwap/'.length), data]), error: failed || null};
  } catch (e) { return {files: [], error: String(e && e.message || e)}; }
}
// The Windower folder (asked for on a click: the one kept, or the folder picker), then `then(root)`
function pkgFolder(then){
  const fail = e => { PKG.state = 'fail'; PKG.msg = t('pkgFail', {e: String(e && e.message || e)}); render(); };
  oxWindowerFolder(true).then(root => root ? then(root)
    : openFolderDialog(async () => { then(await oxPickWindower()); }, () => {}, {title: t('wfolderTitle'), why: t('pkgFolderWhy'), path: pageFolder().replace(/\\addons\\GearSwap\\data$/i, '')}))
    .catch(fail);
}
const pkgLoadKnown = () => pkgReadKnown().then(k => { PKG.known = k; if (S._pkg) render(); }).catch(() => {});

// Its own clicks and fields, caught before the page's (events.js knows nothing of them)
document.addEventListener('click', e => {
  const b = e.target.closest('[data-pkgopen],[data-pkgset],[data-pkgjob],[data-pkgjobs],[data-pkgchar],[data-pkgmake],[data-pkgfolder]');
  if (!b) return;
  e.stopImmediatePropagation();
  const d = b.dataset;
  if ('pkgopen' in d) return pkgOpenPage();
  if ('pkgmake' in d) return pkgMake();
  if ('pkgfolder' in d) return pkgFolder(pkgLoadKnown);
  if (d.pkgset) PKG[d.pkgset] = d.v;
  if (d.pkgjob) PKG.jobs = PKG.jobs.includes(d.pkgjob) ? PKG.jobs.filter(j => j !== d.pkgjob) : PKG_JOBS.filter(j => j === d.pkgjob || PKG.jobs.includes(j));
  if (d.pkgjobs) PKG.jobs = d.pkgjobs === 'all' ? PKG_JOBS.slice() : [];
  if (d.pkgchar) pkgSetName(d.pkgchar);
  if (PKG.state !== 'busy') { PKG.state = ''; PKG.msg = ''; }
  render();
}, true);
document.addEventListener('input', e => {
  if (e.target.id === 'pkgname') { pkgSetName(e.target.value); render(); }
  if (e.target.id === 'pkgpartner') PKG.partner = e.target.value;
});
