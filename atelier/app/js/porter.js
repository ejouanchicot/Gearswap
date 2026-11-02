// GearSwap Atelier · porter.js: the job's pieces in PorterPacker's unpack list (addons/PorterPacker,
// data/<Char>/Active/<JOB>.lua). PorterPacker packs every job's list on a swap but the unpack list of the job swapped
// to: a piece the sets use and that list misses is packed away (or left at the Porter Moogle), a piece no set uses is
// pulled out for nothing. The export compares them (shared/utils/atelier/porter_lists.lua: the sets in memory, the
// states' options, <JOB>_WEAPONS.lua, kept when a storage slip holds them); the button writes the unpack list
// (POST /porter_write, the job loaded in game only; the pack list is left as it is, the file before kept as .bak)
// (loaded after stat_opt.js: see atelier/src/legacy/files.ts)

Object.assign(T.fr, {
  baseOnly: 'Jamais porté : GearSwap ne met jamais ce set, il sert seulement de base à {l}. Changer une pièce ici changerait ces sets-là : modifie-les eux.',
baseReachNote: 'Set de base, jamais porté seul. Seuls ces emplacements arrivent en jeu — {l}. Les autres (grisés) sont remplacés par les sets qui en héritent.',
baseNone: 'Set de base, jamais porté seul : chaque set qui en hérite remplace tous ses emplacements, aucune de ses pièces n’arrive en jeu.',
baseUnreached: 'jamais porté (remplacé par les sets qui en héritent)',
  baseOnlyToast: 'Set de base, jamais porté : modifie plutôt les sets qui en héritent.',
  porterTitle: 'PorterPacker', porterOk: 'à jour', porterToDo: '{n} à revoir',
  porterIntro2: 'Ce que PorterPacker sort du Porter Moogle quand tu passes {j}, comparé à tes sets.', porterNew2: 'Pas encore de liste pour ce job : elle sera créée.',
  porterFigNeed: 'pièces de tes sets', porterFigAdd: 'manquent dans la liste', porterFigRm: 'sorties pour rien',
  porterPlain: 'Ta liste {j} est une liste de rangement complète ({n} objets) : passer {j} sort tout du Porter Moogle, alors que tes sets n’en utilisent que {w}. « Mettre à jour » garde ce rangement et ne fait plus sortir que tes pièces.',
  porterMore: 'voir',
  porterIntro: 'Sa liste « unpack » ({f}) : ce que PorterPacker sort pour ce job, et ne range pas quand tu changes de job.',
  porterAdd: 'Manquent dans la liste (restent chez le Porter Moogle)',
  porterRemove: 'Sorties pour rien (dans aucun set)',
  porterAllOk: 'Les {n} pièces de tes sets qu’un slip peut garder sont toutes dans la liste.',
  porterNone: 'Aucune pièce de tes sets ne se range sur un slip.',
  porterNew: 'Pas encore de liste pour ce job : elle sera créée ({f}).',
  porterWrite: 'Mettre à jour la liste', porterWriteTip: 'Ne fait plus sortir que les pièces de tes sets ; ce que PorterPacker range ne change pas. L’ancienne liste est gardée.',
  porterNeedJob: 'Charge le {j} en jeu pour mettre la liste à jour (les sets lus sont ceux du job chargé).',
  porterDone: 'Liste PorterPacker mise à jour : {a} ajoutée(s), {r} retirée(s). //po pour l’appliquer.',
  porterFail: 'Liste PorterPacker non écrite : {e}',
});
Object.assign(T.en, {
  baseOnly: 'Never worn: GearSwap never puts this set on, it is only the base of {l}. A piece changed here would change those sets: change them instead.',
baseReachNote: 'A base set, never worn alone. Only these slots reach the game — {l}. The others (dimmed) are replaced by the sets built on it.',
baseNone: 'A base set, never worn alone: every set built on it replaces all its slots, none of its pieces reaches the game.',
baseUnreached: 'never worn (replaced by the sets built on it)',
  baseOnlyToast: 'A base set, never worn: change the sets built on it instead.',
  porterTitle: 'PorterPacker', porterOk: 'up to date', porterToDo: '{n} to review',
  porterIntro2: 'What PorterPacker takes out of the Porter Moogle when you switch to {j}, against your sets.', porterNew2: 'No list for this job yet: it will be made.',
  porterFigNeed: 'pieces of your sets', porterFigAdd: 'missing from the list', porterFigRm: 'taken out for nothing',
  porterPlain: 'Your {j} list is a whole storage list ({n} items): switching to {j} takes everything out of the Porter Moogle, while your sets use {w} of them. “Update” keeps that storage and takes out your pieces only.',
  porterMore: 'see',
  porterIntro: 'Its unpack list ({f}): what PorterPacker takes out for this job, and keeps out when you change jobs.',
  porterAdd: 'Missing from the list (left at the Porter Moogle)',
  porterRemove: 'Taken out for nothing (in no set)',
  porterAllOk: 'The {n} pieces of your sets a slip can hold are all in the list.',
  porterNone: 'No piece of your sets goes on a storage slip.',
  porterNew: 'No list for this job yet: it will be made ({f}).',
  porterWrite: 'Update the list', porterWriteTip: 'Takes out only your sets’ pieces; what PorterPacker stores stays as it is. The old list is kept.',
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
