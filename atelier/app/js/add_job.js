// GearSwap Atelier · add_job.js: "Add a job" under the list of the played jobs (atelier/src/screens/config/JobList.svelte).
// A window offers the jobs the character does not play yet; the one picked is made by GearSwap itself from the
// templates, through the live link (shared/utils/atelier/job_adder.lua, POST /addjob): its entry, its settings, its
// sets without pieces and character_db.lua, nothing written over. The player then changes to it in game, and it
// comes here with its first export.
// (loaded by atelier/index.html after packages.js: see atelier/src/legacy/files.ts)

Object.assign(T.fr, {ajAdd: '+ Ajouter un job', ajAddTip: 'Crée un job de plus pour {c} à partir des modèles : ses réglages et ses sets (vides, à remplir ici). Rien d’existant n’est touché.',
  ajNoLive: 'Le jeu doit tourner sur {c} : c’est GearSwap qui crée les fichiers.', ajTitle: 'Ajouter un job à {c}',
  ajWhy: 'GearSwap crée le job à partir des modèles : son entrée, ses réglages (touches, HUD, macros, lockstyle…) et ses sets, avec tous leurs noms mais sans pièces : tu les remplis ici (Optimiser ce set). Aucun fichier existant n’est remplacé, aucun autre job n’est touché.',
  ajDone: '{j} ajouté à {c} ({n} fichier(s) créé(s){k}). Passe {c} en {j} en jeu : GearSwap le charge, et il arrive ici avec son premier export.',
  ajKept: ', {n} déjà là gardé(s)', ajExists: '{c} a déjà un {j} ({c}_{j}.lua existe) : rien n’a été créé.', ajNoTemplate: 'Pas de modèle pour {j} : rien n’a été créé.',
  ajFail: 'Le jeu n’a pas répondu : rien n’a été créé.'});
Object.assign(T.en, {ajAdd: '+ Add a job', ajAddTip: 'Makes one more job for {c} from the templates: its settings and its sets (empty, to fill here). Nothing that exists is touched.',
  ajNoLive: 'The game must run on {c}: GearSwap makes the files.', ajTitle: 'Add a job to {c}',
  ajWhy: 'GearSwap makes the job from the templates: its entry, its settings (keys, HUD, macros, lockstyle...) and its sets, every name but no piece: you fill them here (Optimize this set). No file that exists is replaced, no other job is touched.',
  ajDone: '{j} added to {c} ({n} file(s) made{k}). Change {c} to {j} in game: GearSwap loads it, and it comes here with its first export.',
  ajKept: ', {n} already there kept', ajExists: '{c} has a {j} already ({c}_{j}.lua exists): nothing was made.', ajNoTemplate: 'No template for {j}: nothing was made.',
  ajFail: 'The game did not answer: nothing was made.'});

// The jobs the character does not play yet (core.js JOBS, sets_view.js plays)
const ajMissing = () => JOBS.filter(j => !plays(j[0]));

function openAddJob(){
  const c = S.char, list = ajMissing();
  const body = `<p class="muted small">${esc(t('ajWhy'))}</p><div class="ajgrid">` +
    list.map(([j, name]) => `<button class="btn ghost" data-addjobpick="${j}">${emblem(j)}<b>${j}</b><small>${esc(name)}</small></button>`).join('') + '</div>';
  ATELIER_DIALOG.show({cls: 'midlg ajdlg', titleHtml: esc(t('ajTitle', {c})), bodyHtml: body});
}
async function addJob(job){
  const c = S.char;
  let r;
  try { r = await liveOrder(c, '/addjob?job=' + encodeURIComponent(job), {method: 'POST', body: '', timeout: 8000}); } catch (e) { r = null; }
  // the answer in the same window (the list of the jobs has no message line of its own)
  const msg = !r ? t('ajFail') : r.ok ? t('ajDone', {j: job, c, n: (r.files || []).length, k: (r.kept || []).length ? t('ajKept', {n: r.kept.length}) : ''})
    : r.error === 'exists' ? t('ajExists', {j: job, c}) : r.error === 'template' ? t('ajNoTemplate', {j: job}) : t('ajFail');
  ATELIER_DIALOG.show({cls: 'midlg ajdlg', titleHtml: esc(t('ajTitle', {c})), bodyHtml: `<p class="toast">${esc(msg)}</p>`});
}
document.addEventListener('click', e => {
  const b = e.target.closest && e.target.closest('[data-addjob],[data-addjobpick]');
  if (!b) return;
  if (b.dataset.addjobpick) addJob(b.dataset.addjobpick); else openAddJob();
});
