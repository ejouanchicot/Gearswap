// GearSwap Atelier · welcome.js: the texts and the reading of the files of the page with nothing to show yet (no
// export of any character: a new install, a package made without its exports), drawn by atelier/src/screens/home. Says
// how to fill it: //gs c atelier in game, or the files read without the game (offline_export.js, the main subjob of
// each job, as a package's exports are made: package_exports.js).
// (loaded by atelier/index.html, in the order of the list there)

Object.assign(T.fr, {wcTitle: 'Bienvenue dans l’Atelier',
  wcLede: 'L’Atelier n’a encore rien à montrer : il affiche ce que ton GearSwap lui envoie. Deux façons de le remplir :',
  wcGameT: 'En jeu', wcGame1: 'Charge ton job dans le jeu.', wcGame2: 'Tape {c} (ou {o} : chaque job à son chargement).', wcGame3: 'Reviens ici et appuie sur F5.',
  wcGameWhy: 'C’est la façon complète : le jeu envoie aussi le contenu de tes sacs.',
  wcFilesT: 'Sans le jeu', wcFiles1: 'La page lit tes fichiers GearSwap dans ton dossier Windower et montre tes jobs et tes sets.',
  wcFilesWhy: 'Le contenu de tes sacs viendra avec ton premier //gs c atelier en jeu. Chrome ou Edge seulement.',
  wcFilesBtn: 'Lire mes fichiers', wcBusy: 'Lecture…', wcP: '{c} : job {n} / {m}', wcNoChar: 'Aucun personnage trouvé dans addons/GearSwap/data (un dossier avec ses fichiers <Nom>_<JOB>.lua).',
  wcFail: 'La lecture a échoué : {e}', wcNoBrowser: 'Ce navigateur ne laisse pas une page lire un dossier : ouvre l’Atelier dans Chrome ou Edge, ou passe par le jeu.'});
Object.assign(T.en, {wcTitle: 'Welcome to the Atelier',
  wcLede: 'The Atelier has nothing to show yet: it shows what your GearSwap sends it. Two ways to fill it:',
  wcGameT: 'In game', wcGame1: 'Load your job in game.', wcGame2: 'Type {c} (or {o}: every job as it loads).', wcGame3: 'Come back here and press F5.',
  wcGameWhy: 'The complete way: the game also sends what your bags hold.',
  wcFilesT: 'Without the game', wcFiles1: 'The page reads your GearSwap files in your Windower folder and shows your jobs and sets.',
  wcFilesWhy: 'What your bags hold comes with your first //gs c atelier in game. Chrome or Edge only.',
  wcFilesBtn: 'Read my files', wcBusy: 'Reading…', wcP: '{c}: job {n} / {m}', wcNoChar: 'No character found in addons/GearSwap/data (a folder with its <Name>_<JOB>.lua files).',
  wcFail: 'Reading failed: {e}', wcNoBrowser: 'This browser does not let a page read a folder: open the Atelier in Chrome or Edge, or go through the game.'});

// The reading's state, while the page is open: '', 'busy', or the message of a failure
const WELCOME = {state: '', msg: ''};
// The characters of the data folder: a folder holding <Name>_<JOB>.lua
async function welcomeChars(env){
  const out = [];
  for (const e of ((await env.list(OfflineExport.DATA)) || []).filter(e => e.dir && /^[A-Z]/.test(e.name)))
    if (((await env.list(OfflineExport.DATA + '/' + e.name)) || []).some(f => new RegExp('^' + e.name + '_[A-Z]{3}\\.lua$').test(f.name))) out.push(e.name);
  return out;
}
function welcomeRead(){
  if (WELCOME.state === 'busy') return;
  const say = (msg, state = 'busy') => { WELCOME.state = state; WELCOME.msg = msg; render(); };
  if (!window.showDirectoryPicker) return say(t('wcNoBrowser'), 'fail');
  const go = async root => {
    say('');
    try {
      await new Promise(done => window.ATELIER_LUA ? done() : loadScripts(['atelier/lua/lua51.js?v=' + Date.now()], done));
      if (!window.ATELIER_LUA) throw new Error(t('refreshNoLua'));
      const env = oxEnv(root), chars = await welcomeChars(env);
      if (!chars.length) return say(t('wcNoChar'), 'fail');
      for (const c of chars) await OfflineExport.run(env, c, {mainOnly: true, onProgress: (k, n, m) => { if (k === 'jobs') say(t('wcP', {c, n, m})); }});
      WELCOME.state = ''; WELCOME.msg = '';
      dataAgain();
    } catch (e) { say(t('wcFail', {e: String(e && e.message || e)}), 'fail'); }
  };
  oxWindowerFolder(true).then(root => root ? go(root)
    : openFolderDialog(async () => { go(await oxPickWindower()); }, () => {}, {title: t('wfolderTitle'), why: t('wfolderWhy'), path: pageFolder().replace(/\\addons\\GearSwap\\data$/i, '')}))
    .catch(e => say(t('wcFail', {e: String(e && e.message || e)}), 'fail'));
}
document.addEventListener('click', e => {
  if (!e.target.closest('[data-wcread]')) return;
  e.stopImmediatePropagation();
  welcomeRead();
}, true);
