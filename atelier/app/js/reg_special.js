// GearSwap Atelier · reg_special.js: the two job files of the Settings that are not a list of values (SPEC
// notes/docs-perso/reglages-jeu-2026-10-30): the HUD order of the job (<job>/display/<JOB>_HUD.lua, read by
// shared/utils/ui/hud_job_config.lua: a list not empty replaces UI_CONFIG.lua's layout order) and the refill list of
// the job (<job>/inventory/<JOB>_REFILL.lua, read by shared/utils/inventory/refill/config_resolver.lua: subjobs[sub],
// else default, else the common list + extra; an empty list counts as none). Their settings ship as comments: the
// page uncomments one (modules.js modAdds) the first time it is changed, so the player never "adds" anything.
// The refill card is drawn by atelier/src/screens/config/modules.ts (refillCard); the HUD order is changed in the
// live preview (hud_preview.js, with hudOrder and hudStage below).
// (loaded after modules.js: see atelier/src/legacy/files.ts)

Object.assign(T.fr, {regOwn: '{j} seulement',
  rfTitle: 'Refill de {j}', rfNow: 'Sur {j}, //gs c rf garde dans ton inventaire :', rfEmpty: 'rien', rfModeCommon: 'Liste commune + mes objets', rfModeOwn: 'Ma propre liste',
  rfModeCommonTip: 'La liste de tous les jobs (Inventaire → Refill), plus les objets ajoutés ici.', rfModeOwnTip: 'Une liste à toi sur {j}, à la place de la liste commune.',
  rfExtra: 'Mes objets en plus', rfOwn: 'Ma liste sur {j}', rfAddExtra: '+ Ajouter des objets', rfSubs: 'Listes par sub', rfSubsTip: 'Avec ce sub, sa liste remplace celle du dessus.',
  rfSub: 'Avec le sub /{s}', rfAddSub: '+ Une liste pour un sub…', rfDelSub: 'Retirer la liste de ce sub',
  rfSubCopy: 'commence avec ta liste actuelle',
  hudColors: 'HUD : couleurs', hudColValues: 'Couleur des valeurs', hudColAuto: 'auto', hudColReset: 'Revenir à la couleur standard',
  hudCol_title: 'Titre', hudCol_section_title: 'Titres de section', hudCol_description: 'Noms des lignes', hudCol_key: 'Touches', hudCol_value: 'Valeurs',
  hudCol_legend: 'Légende', hudCol_separator: 'Lignes ====', hudCol_footer: 'Pied', hudCol_column_key: 'Colonne Key', hudCol_column_function: 'Colonne Function', hudCol_column_current: 'Colonne Current',
  hudVal_true: 'Allumé / On', hudVal_false: 'Éteint / Off', hudVal_PDT: 'PDT', hudVal_MDT: 'MDT', hudVal_Normal: 'Normal',
  hudColorsWhat: 'La couleur de chaque partie du HUD. « auto » : la couleur suit la valeur (un élément dans sa couleur, On en vert…). Le changement se voit tout de suite dans l’aperçu.',
  hudColorsEx: 'Titres de section en or, valeurs Off en orange : clique la pastille et choisis la couleur, l’aperçu suit.',
  hudPick: 'Choisir une couleur…', hudHint: 'Clique une partie pour changer sa couleur. Glisse un titre de section ou une ligne pour changer l’ordre sur {j}.', hudOrderReset: 'Ordre par défaut',
  hudTitle: 'Aperçu en direct', hudNote: 'dessiné par le code du HUD de GearSwap, avec tes réglages (même non enregistrés)', hudDrawing: 'calcul de l’aperçu…',
  hudOff: 'le HUD est désactivé au chargement', hudError: 'L’aperçu n’a pas pu être dessiné : {e}',
  cfgModes: 'Modes', cfgKeysGroup: 'Touches', cfgAllKeys: 'Toutes mes touches', cfgAway: 'Modes d’un autre sub', cfgStart: 'Valeur de départ', cfgInFile: 'Dans ton fichier', cfgKey: 'Touche',
  cfgNoKey: 'aucune', cfgWhenMode: 'au prochain chargement du job ; la touche le change en jeu', cfgResetFile: 'Rétablir la valeur du fichier ({v})', cfgBook: 'Macrobook', cfgStyle: 'Lockstyle',
  cfgLines: '{n} ligne(s)', cfgGeneral: 'Général', cfgSearch: 'Rechercher…', cfgCat_auto: 'Automatismes', cfgCat_gear: 'Équipement auto', cfgCat_cmd: 'Commandes', cfgCat_bags: 'Inventaire',
  cfgCat_display: 'Affichage', cfgCat_multi: 'Plusieurs persos', cfgCat_tools: 'Addons et outils', cfgThisJob: 'Ce job', cfgAllJobs: 'Tous les jobs', cfgEveryJob: 'Tous les jobs', cfgNone: 'aucun', cfgValue: 'Valeur', cfgDefault: 'Par défaut', cfgExample: 'Exemple',
  cfgWhen: 'Pris en jeu', cfgWhenReload: 'après Enregistrer (//gs reload si le jeu est fermé)', cfgReset: 'Rétablir {v}', cfgWaiting: '{n} changement(s) non enregistré(s)', cfgSaved: 'Tout est enregistré',
  rfEx: 'Liste commune + Sublime Sushi ×10 : sur {j}, //gs c rf garde la liste de tous les jobs et 10 Sublime Sushi en plus.'});
Object.assign(T.en, {regOwn: '{j} only',
  rfTitle: '{j} refill', rfNow: 'On {j}, //gs c rf keeps in your inventory:', rfEmpty: 'nothing', rfModeCommon: 'Common list + my items', rfModeOwn: 'My own list',
  rfModeCommonTip: 'The list of every job (Inventory → Refill), plus the items added here.', rfModeOwnTip: 'A list of your own on {j}, in place of the common one.',
  rfExtra: 'My extra items', rfOwn: 'My list on {j}', rfAddExtra: '+ Add items', rfSubs: 'Lists by subjob', rfSubsTip: 'With this subjob, its list replaces the one above.',
  rfSub: 'With /{s}', rfAddSub: '+ A list for a subjob…', rfDelSub: 'Remove this subjob’s list',
  rfSubCopy: 'starts with your current list',
  hudColors: 'HUD: colours', hudColValues: 'Colour of the values', hudColAuto: 'auto', hudColReset: 'Back to the standard colour',
  hudCol_title: 'Title', hudCol_section_title: 'Section titles', hudCol_description: 'Row names', hudCol_key: 'Keys', hudCol_value: 'Values',
  hudCol_legend: 'Legend', hudCol_separator: '==== lines', hudCol_footer: 'Footer', hudCol_column_key: 'Key column', hudCol_column_function: 'Function column', hudCol_column_current: 'Current column',
  hudVal_true: 'On', hudVal_false: 'Off', hudVal_PDT: 'PDT', hudVal_MDT: 'MDT', hudVal_Normal: 'Normal',
  hudColorsWhat: 'The colour of each part of the HUD. “auto”: the colour follows the value (an element in its colour, On in green…). The change shows at once in the preview.',
  hudColorsEx: 'Section titles in gold, Off values in orange: click the swatch and pick the colour, the preview follows.',
  hudPick: 'Pick a colour…', hudHint: 'Click a part to change its colour. Drag a section title or a row to change the order on {j}.', hudOrderReset: 'Default order',
  hudTitle: 'Live preview', hudNote: 'drawn by GearSwap’s HUD code, with your settings (even unsaved)', hudDrawing: 'drawing the preview…',
  hudOff: 'the HUD is off at load', hudError: 'The preview could not be drawn: {e}',
  cfgModes: 'Modes', cfgKeysGroup: 'Keys', cfgAllKeys: 'All my keys', cfgAway: 'Another subjob’s modes', cfgStart: 'Start value', cfgInFile: 'In your file', cfgKey: 'Key',
  cfgNoKey: 'none', cfgWhenMode: 'at the next load of the job; the key changes it in game', cfgResetFile: 'Set back the file’s value ({v})', cfgBook: 'Macro book', cfgStyle: 'Lockstyle',
  cfgLines: '{n} line(s)', cfgGeneral: 'General', cfgSearch: 'Search…', cfgCat_auto: 'Automation', cfgCat_gear: 'Automatic gear', cfgCat_cmd: 'Commands', cfgCat_bags: 'Inventory',
  cfgCat_display: 'Display', cfgCat_multi: 'Several characters', cfgCat_tools: 'Addons and tools', cfgThisJob: 'This job', cfgAllJobs: 'Every job', cfgEveryJob: 'Every job', cfgNone: 'none', cfgValue: 'Value', cfgDefault: 'Default', cfgExample: 'Example',
  cfgWhen: 'Taken in game', cfgWhenReload: 'after Save (//gs reload if the game is closed)', cfgReset: 'Set back {v}', cfgWaiting: '{n} unsaved change(s)', cfgSaved: 'Everything is saved',
  rfEx: 'Common list + Sublime Sushi ×10: on {j}, //gs c rf keeps every job’s list and 10 Sublime Sushi on top.'});

const HUD_SECTIONS = ['spells', 'enhancing', 'abilities', 'weapons', 'modes'];
const REG_SPECIAL = /^[a-z]{3}\/(display\/[A-Z]{3}_HUD|inventory\/[A-Z]{3}_REFILL)\.lua$/;

// A setting of a job file, uncommented first when the file only has it as an example (its text kept aside until
// "Save", with the value staged right after). true when it can be staged
function regEnsure(file, key){
  const f = modAllFiles(data()).find(x => x.file === file); if (!f) return false;
  if (modParsed(f).byPath[key]) return true;
  const ex = modExamples((f.orig || f).text).find(e => e.key === key); if (!ex) return false;
  const adds = modAdds(); adds[file] = Object.assign({}, adds[file], {[ex.id]: true});
  return !!modParsed(modAllFiles(data()).find(x => x.file === file)).byPath[key];
}

/* ---- the HUD order ---- */
// The job's states in its keys file order (the default row order of GearSwap: hud_job_config.lua job_states)
const hudStates = d => [...new Set((d.keys || []).map(k => k.state).filter(Boolean))];
// The order shown: the job's list (names first), then the rest in the default order
function hudOrder(d, file, field){
  const own = modValue(file, field), list = Array.isArray(own) ? own : [];
  const ui = modAllFiles(d).find(f => /\/UI_CONFIG\.lua$/.test(f.file)), base = field === 'section_order'
    ? (ui && Array.isArray(modValue(ui.file, 'layout.section_order')) ? modValue(ui.file, 'layout.section_order') : HUD_SECTIONS)
    : (ui && Array.isArray(modValue(ui.file, 'layout.row_order')) ? modValue(ui.file, 'layout.row_order') : []);
  const all = field === 'section_order' ? HUD_SECTIONS : hudStates(d), first = list.length ? list : base;
  const low = s => String(s).toLowerCase(), seen = new Set(), out = [];
  // a name of the list that is not one of the job's (a key, a mode of another subjob) keeps its place
  for (const n of first) { const m = all.find(x => low(x) === low(n)) || (field === 'row_order' ? n : null);
    if (m && !seen.has(low(m))) { seen.add(low(m)); out.push(m); } }
  for (const n of all) if (!seen.has(low(n))) { seen.add(low(n)); out.push(n); }
  return {order: out, own: list.length > 0};
}
function hudStage(file, field, order){
  if (!regEnsure(file, field)) return;
  modStage(file, field, order);
}
// (the order is changed by dragging in the live preview: hud_preview.js)
document.addEventListener('click', e => {
  const rm = e.target.closest('[data-refillmode]');
  if (rm) { refillMode(rm.dataset.refillmode); return; }
  const ds = e.target.closest('[data-refilldelsub]');
  if (ds) { const [file, sub] = ds.dataset.refilldelsub.split('|'), subs = refillSubs(file); delete subs[sub]; refillStageSubs(file, subs); }
});

/* ---- the refill of the job ---- */
const rfName = e => Array.isArray(e.name) ? e.name[0] : e.name;
const rfPlain = list => (Array.isArray(list) ? list : []).map(e => ({name: e.name, target: e.target}));
// The common list (REFILL_CONFIG.lua default_list) with the job's extras (config_resolver.lua with_extra)
function refillCommon(d){
  const c = modAllFiles(d).find(f => /\/REFILL_CONFIG\.lua$/.test(f.file));
  return rfPlain(c ? modValue(c.file, 'default_list') : []);
}
function refillNow(d, file){
  const own = rfPlain(modValue(file, 'default'));
  if (own.length) return {mode: 'own', list: own};
  const out = refillCommon(d);
  for (const e of rfPlain(modValue(file, 'extra'))) { const at = out.findIndex(x => JSON.stringify(x.name) === JSON.stringify(e.name)); if (at >= 0) out[at] = e; else out.push(e); }
  return {mode: 'common', list: out};
}
// a refill list as a table of lines (an empty {} reads as an empty list: its columns are the catalog's, modules.js mcRows)
function rfStage(file, key, v){
  if (!regEnsure(file, key)) return;
  const f = modFiles(data()).find(x => x.file === file), x = f && modParsed(f).byPath[key];
  if (x && x.kind === 'list' && !x.fields.length) Object.assign(x, {kind: 'rows', cols: ['name', 'target'], value: []});
  modStage(file, key, v);
}
function refillMode(attr){
  const [file, mode] = attr.split('|'), d = data(), now = refillNow(d, file);
  if (mode === 'own') { if (now.mode !== 'own') rfStage(file, 'default', now.list); return; }
  if (mode === 'common') { if (modField(file, 'default')) rfStage(file, 'default', []); return; }
  if (mode === 'extra') rfStage(file, 'extra', []);
}
// the lists by subjob: the file's, or the whole table waiting (a subjob added or removed rewrites the table)
function refillSubs(file){
  const ed = modEdits(file).subjobs; if (ed) return Object.assign({}, ed.v);
  const f = modAllFiles(data()).find(x => x.file === file), x = f && modParsed(f).byPath.subjobs, out = {};
  if (x && x.kind === 'map') for (const c of x.fields) out[c.key] = rfPlain(modValue(file, c.path));
  return out;
}
// While the table of subjob lists waits to be saved (a subjob added or removed), a subjob's list is a part of it: its
// table of lines reads and changes it there (modules.js modField, modValue, modStage), so a list just added is edited
// before any save
function rfStagedSub(file, path){
  const m = /^subjobs\.([A-Z]{3})$/.exec(path), ed = m && /_REFILL\.lua$/.test(file) ? modEdits(file).subjobs : null;
  if (!ed || !ed.v[m[1]]) return null;
  return {kind: 'rows', cols: ['name', 'target'], fields: [], path, value: ed.v[m[1]], sub: m[1]};
}
function refillLua(subs, nl){
  const item = e => `{name = ${Array.isArray(e.name) ? '{' + e.name.map(n => luaQuote(n, "'")).join(', ') + '}' : luaQuote(e.name, "'")}, target = ${Number(e.target) || 0}}`;
  const keys = Object.keys(subs);
  return keys.length ? '{' + nl + keys.map(k => `    ${/^[A-Z]{3}$/.test(k) ? k : '[' + luaQuote(k, "'") + ']'} = {` + nl + subs[k].filter(e => !mrEmpty(e.name)).map(e => '        ' + item(e)).join(',' + nl) + nl + '    },').join(nl) + nl + '}' : '{}';
}
function refillStageSubs(file, subs){
  if (!regEnsure(file, 'subjobs')) return;
  const f = modAllFiles(data()).find(x => x.file === file), x = modParsed(f).byPath.subjobs, ed = modEdits(file);
  const was = {}; if (x && x.kind === 'map') for (const c of x.fields) was[c.key] = rfPlain(c.value);
  const show = s => Object.keys(s).map(k => '/' + k + ' (' + s[k].length + ')').join(' ') || '—';
  // the subjobs' own changes go into the whole table
  for (const k of Object.keys(ed)) if (k.startsWith('subjobs.')) delete ed[k];
  if (JSON.stringify(subs) === JSON.stringify(was)) delete ed.subjobs;
  else ed.subjobs = {v: subs, src: refillLua(subs, f.text.includes('\r\n') ? '\r\n' : '\n'), before: show(was), after: show(subs), table: true};
  S.toast = ''; render();
}
document.addEventListener('change', e => {
  const s = e.target.closest('select[data-refilladdsub]'); if (!s || !s.value) return;
  const file = s.dataset.refilladdsub, subs = refillSubs(file);
  if (!subs[s.value]) { subs[s.value] = refillNow(data(), file).list; refillStageSubs(file, subs); }
});
