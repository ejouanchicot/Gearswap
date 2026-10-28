// GearSwap Atelier · porter.js: the job's pieces in PorterPacker's unpack list (addons/PorterPacker,
// data/<Char>/Active/<JOB>.lua). PorterPacker packs every job's list on a swap but the unpack list of the job swapped
// to: a piece the sets use and that list misses is packed away (or left at the Porter Moogle), a piece no set uses is
// pulled out for nothing. The export compares them (shared/utils/atelier/porter_lists.lua: the sets in memory, the
// states' options, <JOB>_WEAPONS.lua, kept when a storage slip holds them); the button writes the unpack list
// (POST /porter_write, the job loaded in game only; the pack list is left as it is, the file before kept as .bak)
// (loaded after stat_opt.js: see atelier/src/legacy/files.ts)

Object.assign(T.fr, {
  baseOnly: 'Jamais porté : GearSwap ne met jamais ce set, il sert seulement de base à {l}. Changer une pièce ici changerait ces sets-là : modifie-les eux.',
  baseOnlyToast: 'Set de base, jamais porté : modifie plutôt les sets qui en héritent.',
  porterTitle: 'PorterPacker', porterOk: 'à jour', porterToDo: '{n} à revoir',
  porterIntro: 'Sa liste « unpack » ({f}) : ce que PorterPacker sort pour ce job, et ne range pas quand tu changes de job.',
  porterAdd: 'Pièces de tes sets absentes de la liste : PorterPacker les range chez le Porter Moogle ou ne les ressort pas.',
  porterRemove: 'Dans la liste, mais plus dans aucun set : ressorties pour rien.',
  porterAllOk: 'Les {n} pièces de tes sets qu’un slip peut garder sont toutes dans la liste.',
  porterNone: 'Aucune pièce de tes sets ne se range sur un slip.',
  porterNew: 'Pas encore de liste pour ce job : elle sera créée ({f}).',
  porterWrite: 'Mettre à jour la liste', porterWriteTip: 'Réécrit seulement la liste « unpack » à partir de tes sets ; la liste « pack » ne change pas. Copie de l’ancien fichier : {f}.bak',
  porterNeedJob: 'Charge le {j} en jeu pour mettre la liste à jour (les sets lus sont ceux du job chargé).',
  porterDone: 'Liste PorterPacker mise à jour : {a} ajoutée(s), {r} retirée(s). //po pour l’appliquer.',
  porterFail: 'Liste PorterPacker non écrite : {e}',
});
Object.assign(T.en, {
  baseOnly: 'Never worn: GearSwap never puts this set on, it is only the base of {l}. A piece changed here would change those sets: change them instead.',
  baseOnlyToast: 'A base set, never worn: change the sets built on it instead.',
  porterTitle: 'PorterPacker', porterOk: 'up to date', porterToDo: '{n} to review',
  porterIntro: 'Its unpack list ({f}): what PorterPacker takes out for this job, and keeps out when you change jobs.',
  porterAdd: 'Pieces of your sets missing from the list: PorterPacker stores them at the Porter Moogle or leaves them there.',
  porterRemove: 'In the list, but in no set any more: taken out for nothing.',
  porterAllOk: 'The {n} pieces of your sets a slip can hold are all in the list.',
  porterNone: 'No piece of your sets goes on a storage slip.',
  porterNew: 'No list for this job yet: it will be made ({f}).',
  porterWrite: 'Update the list', porterWriteTip: 'Rewrites the unpack list only, from your sets; the pack list stays as it is. The old file is kept as {f}.bak',
  porterNeedJob: 'Load {j} in game to update the list (the sets read are the loaded job\'s).',
  porterDone: 'PorterPacker list updated: {a} added, {r} removed. //po applies it.',
  porterFail: 'PorterPacker list not written: {e}',
});

// The button: GearSwap writes the list from the sets it has loaded, the export's comparison is refreshed with it
async function porterWrite(){
  let r;
  try { r = await liveFetch(S.char, '/porter_write?x=1' + jobQuery(), {method: 'POST', timeout: 8000}); } catch (e) { r = {ok: false, error: e.message}; }
  if (r && r.ok) {
    const d = data();
    if (d && r.porterpacker) d.porterpacker = r.porterpacker;
    S.toast = t('porterDone', {a: r.added, r: r.removed});
  } else S.toast = t('porterFail', {e: (r && r.error) || '?'});
  S._globals = null; render();
}
