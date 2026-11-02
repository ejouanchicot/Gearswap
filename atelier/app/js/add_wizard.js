// GearSwap Atelier · add_wizard.js: the "+ Set" window as questions (notes/docs-perso/creation-set-2026-11-01/SPEC.md,
// maquette.png). The export's catalog (add_set.js catalogEntries: every set name the job's code reads, filled with the
// character's spells, weaponskills, abilities and modes) is read once into situations: what a set is for (a spell, a
// family of spells, every spell of a school, a weaponskill, an ability, a stance...) and what narrows it (on whom, which
// tier, which mode, which profile, Saboteur...). The window then asks 1. when, 2. what, 3. only the questions whose
// answers change the set worn, 4. a summary in words, with one name for the file (the clearest of those the game reads
// alike) and the set that is there already under another name opened rather than a second made.
// The names, the bases and the writing stay add_set.js's (addFrom, createPreview). The window: atelier/src/screens/
// dialogs/addset.ts.
// (loaded after add_set.js: see atelier/src/legacy/files.ts)

Object.assign(T.fr, {
  awTitle: 'Ajouter un set', awStepWhen: 'Quand', awStepWhat: 'Quoi', awStepAsk: 'Précisions', awStepSum: 'Résumé',
  awWhenQ: 'Quand veux-tu porter ce set ?', awWhatQ: 'Pour quoi ?', awSearch: 'Chercher…', awExpert: 'Voir tous les noms possibles (experts)',
  awBackToWizard: '← Retour à l’assistant', awHas: 'tu as déjà un set pour ça', awHasShort: 'set', awNext: 'Suivant →', awAll: 'Tous', awOpen: 'Ouvrir ce set',
  awSchoolAll: 'Tous les sorts : {s}', awSchoolAllD: 'Pour chaque sort qui n’a pas de set à lui', awFamily: 'Famille', awGeneral: 'Général',
  awFamName: {duration: 'Durée', potency: 'Puissance', macc: 'Précision magique', int_potency: 'Puissance (INT)', mnd_potency: 'Puissance (MND)', skill_potency: 'Puissance (skill)', skill_mnd_potency: 'Puissance (skill et MND)', StatusRemoval: 'Soins d’altération'},
  awSets: 'Sets', awSpells: 'Sorts', awNone: 'Rien ne correspond. Essaie le début du nom du sort.', awFamilies: 'Familles de sorts', awPackBar: 'Bar-éléments et bar-statuts', awPackGain: 'Gain / Boost', awPackEn: 'Enspells', awPackSpikes: 'Spikes', awPackTele: 'Téléportation', awPackStorm: 'Tempêtes', awPackNa: 'Soins d’altération (-na)', awAbilities: 'Abilities', awOtherWs: 'Toutes les WS',
  awQTarget: 'Sur qui ?', awSelf: 'Sur toi', awSelfD: 'Le sort lancé sur toi-même.', awOthers: 'Sur un allié', awOthersComp: 'sous Composure',
  awOthersD: 'Composure actif : la durée sur un allié profite du bonus Lethargy.', awOthersCure: 'Sur un autre', awOthersCureD: 'Le sort lancé sur quelqu’un d’autre.', awAnyone: 'Sur n’importe qui', awAnyoneD: 'Quelle que soit la cible.',
  awQScope: 'Quel tier ?', awAllTiers: 'Tous les tiers', awAllTiersD: '{l}', awOnly: 'Seulement {s}', awOnlyD: 'Les autres tiers gardent le set d’aujourd’hui.',
  awQMode: '{m} ?', awAnyMode: 'Tous les modes', awAnyModeD: 'Porté quel que soit {m}.', awInMode: 'En {v}', awInModeD: 'Seulement quand {m} est sur {v}.',
  awQProfile: 'Quel profil de groupe ?', awFull: 'Full (le set lui-même)', awFullD: 'Porté avec tous les profils qui n’ont pas de version à eux.',
  awProf: '{p}', awProfD: 'Seulement sous le profil {p}.',
  awQBuff: 'Avec {b} ?', awWithout: 'Sans {b}', awWithoutD: 'Le set habituel.', awWith: 'Avec {b} actif', awWithD: 'Posé seulement quand {b} est actif.',
  awQVariant: 'Quelle version ?', awPlain: 'La version normale', awRec: 'conseillé',
  awSay: 'Porté {w}.', awSaySpell: 'quand tu lances {s}', awSayUse: 'quand tu utilises {s}', awSayFc: 'au début de {s}', awTiersOf: '{a} ou {b}', awTiersRange: '{a} à {b}',
  awSayOthers: 'sur un allié, avec Composure actif', awSayOthersCure: 'sur quelqu’un d’autre', awSaySelf: 'sur toi', awSayMode: 'avec {m} sur {v}',
  awSayProf: 'sous le profil {p}', awSayBuff: 'avec {b} actif', awSchoolSay: 'un sort de {s} qui n’a pas de set à lui', awFamSay: 'un sort de la famille {s}',
  awHasSay: 'Tu as déjà ce set : {w}.', awHasGame: 'C’est lui que GearSwap porte. Un second set ne servirait à rien.',
  awToday: 'Aujourd’hui tu portes', awTodayNone: 'rien de plus que ton set de base', awStart: 'Il démarre avec', awName: 'Nom dans ton fichier',
  awFile: 'Il se range dans la liste avec les autres sets de {s}. Création : aperçu, sauvegarde et historique comme un push.',
  awCopy: 'Une copie de ce set', awCopyD: 'puis tu changes ce que tu veux', awEmpty: 'Rien', awEmptyD: 'tu remplis chaque emplacement',
  awWorn: 'Ce que tu portes en jeu', awWornD: 'lu dans le jeu au moment de créer', awAlso: 'aussi possible : {n} autre(s) écriture(s)',
  awAlsoFirst: 'GearSwap lit en premier : {p}', awCreate: 'créer', awExists: 'existe · ouvrir', awExpertTitle: 'Tous les noms possibles',
  awNoWay: 'Il faut le jeu connecté pour créer un set.', awParent: 'Crée d’abord {p} : ce set va dedans.',
  awSchool: {'Enhancing Magic': 'Renfort', 'Enfeebling Magic': 'Affaiblissement', 'Elemental Magic': 'Élémentaire', 'Healing Magic': 'Soin',
    'Divine Magic': 'Divin', 'Dark Magic': 'Magie noire', Ninjutsu: 'Ninjutsu', Singing: 'Chant', 'Blue Magic': 'Magie bleue', Geomancy: 'Géomancie',
    'Summoning Magic': 'Invocation', Handbell: 'Cloche (Handbell)', 'Stringed Instrument': 'Instrument à cordes', 'Wind Instrument': 'Instrument à vent'}});
Object.assign(T.en, {
  awTitle: 'Add a set', awStepWhen: 'When', awStepWhat: 'What', awStepAsk: 'Details', awStepSum: 'Summary',
  awWhenQ: 'When do you want to wear this set?', awWhatQ: 'For what?', awSearch: 'Search…', awExpert: 'See every possible name (experts)',
  awBackToWizard: '← Back to the assistant', awHas: 'you have a set for it already', awHasShort: 'set', awNext: 'Next →', awAll: 'All', awOpen: 'Open this set',
  awSchoolAll: 'Every spell: {s}', awSchoolAllD: 'For each spell with no set of its own', awFamily: 'Family', awGeneral: 'General',
  awFamName: {duration: 'Duration', potency: 'Potency', macc: 'Magic accuracy', int_potency: 'Potency (INT)', mnd_potency: 'Potency (MND)', skill_potency: 'Potency (skill)', skill_mnd_potency: 'Potency (skill and MND)', StatusRemoval: 'Status removal'},
  awSets: 'Sets', awSpells: 'Spells', awNone: 'Nothing matches. Try the start of the spell’s name.', awFamilies: 'Spell families', awPackBar: 'Bar-elements and bar-statuses', awPackGain: 'Gain / Boost', awPackEn: 'Enspells', awPackSpikes: 'Spikes', awPackTele: 'Teleport', awPackStorm: 'Storms', awPackNa: 'Status cures (-na)', awAbilities: 'Abilities', awOtherWs: 'Every WS',
  awQTarget: 'On whom?', awSelf: 'On you', awSelfD: 'The spell cast on yourself.', awOthers: 'On an ally', awOthersComp: 'under Composure',
  awOthersD: 'Composure up: the duration on an ally gets the Lethargy bonus.', awOthersCure: 'On someone else', awOthersCureD: 'The spell cast on someone else.', awAnyone: 'On anyone', awAnyoneD: 'Whoever the target is.',
  awQScope: 'Which tier?', awAllTiers: 'Every tier', awAllTiersD: '{l}', awOnly: 'Only {s}', awOnlyD: 'The other tiers keep today\'s set.',
  awQMode: '{m}?', awAnyMode: 'Every mode', awAnyModeD: 'Worn whatever {m} is.', awInMode: 'In {v}', awInModeD: 'Only while {m} is {v}.',
  awQProfile: 'Which party profile?', awFull: 'Full (the set itself)', awFullD: 'Worn under every profile with no version of its own.',
  awProf: '{p}', awProfD: 'Only under the {p} profile.',
  awQBuff: 'With {b}?', awWithout: 'Without {b}', awWithoutD: 'The usual set.', awWith: 'With {b} up', awWithD: 'Laid only while {b} is up.',
  awQVariant: 'Which version?', awPlain: 'The usual version', awRec: 'advised',
  awSay: 'Worn {w}.', awSaySpell: 'when you cast {s}', awSayUse: 'when you use {s}', awSayFc: 'at the start of {s}', awTiersOf: '{a} or {b}', awTiersRange: '{a} to {b}',
  awSayOthers: 'on an ally, with Composure up', awSayOthersCure: 'on someone else', awSaySelf: 'on you', awSayMode: 'with {m} on {v}',
  awSayProf: 'under the {p} profile', awSayBuff: 'with {b} up', awSchoolSay: 'a {s} spell with no set of its own', awFamSay: 'a spell of the {s} family',
  awHasSay: 'You have this set already: {w}.', awHasGame: 'It is the one GearSwap wears. A second set would do nothing.',
  awToday: 'Worn today', awTodayNone: 'nothing more than your base set', awStart: 'It starts with', awName: 'Name in your file',
  awFile: 'It sits in the list with the other {s} sets. Creating: preview, backup and history as a push.',
  awCopy: 'A copy of that set', awCopyD: 'then change what you like', awEmpty: 'Nothing', awEmptyD: 'you fill every slot',
  awWorn: 'What you wear in game', awWornD: 'read from the game when creating', awAlso: 'also possible: {n} other spelling(s)',
  awAlsoFirst: 'GearSwap reads first: {p}', awCreate: 'create', awExists: 'there · open', awExpertTitle: 'Every possible name',
  awNoWay: 'The game must be linked to create a set.', awParent: 'Create {p} first: this set goes in it.'});

// The spells a piece gives (shared/utils/atelier/set_catalog.lua GEAR_SPELLS): offered only to a character holding one
const AW_GEAR_SPELLS = {Dispelga: ['Daybreak'], Impact: ['Twilight Cloak', 'Crepuscular Cloak'], 'Honor March': ['Marsyas'], 'Aria of Passion': ['Loughnashade']};
const awHolds = names => { const o = ownedOf() || {}; return Object.values(o).some(list => (list || []).some(x => names.includes(x.name))); };
// The keys of a set's path that only say where it is (the family's root)
const AW_ROOT = new Set(['midcast', 'precast', 'FC', 'WS', 'JA', 'RA']);
const AW_PROFILES = new Set(['Group', 'Solo', 'Trust']);
const AW_SPELL_FAMS = new Set(['midcast', 'fc', 'cure']);
// A placeholder of the catalog that is not a mode (shared/utils/atelier/set_catalog.lua)
const AW_NOT_MODE = new Set(['spell', 'spellbase', 'spellplain', 'spellmap', 'spelltype', 'skill', 'type', 'ws', 'wsskill', 'ja', 'ability', 'abilitytype', 'set']);
// What a literal key says (CureSelf is the Cure on oneself, Composure the spell on an ally, Saboteur a buff over it)
const AW_LITERAL = {Composure: {target: 'others'}, CureSelf: {subject: 'Cure', target: 'self'}, CureOther: {subject: 'Cure', target: 'others'}, Saboteur: {buff: 'Saboteur'}};
const awTier = /\s+(II|III|IV|V|VI)$/;
const awBase = name => name.replace(awTier, '');
// a catalog line's parts, split on its dots outside braces
function awParts(g){ const out = []; let cur = '', depth = 0;
  for (const ch of g) { if (ch === '{') depth++; if (ch === '}') depth--; if (ch === '.' && !depth) { out.push(cur); cur = ''; } else cur += ch; }
  out.push(cur); return out; }

// The catalog read into situations: [{e, fam, subject: {kind, name, school}, q: {target, scope, mode, profile, buff, variant}}]
let AW_CACHE = null;
function awSituations(){
  const cat = catalogEntries();
  if (!cat) return null;
  if (AW_CACHE && AW_CACHE.cat === cat) return AW_CACHE.list;
  // the school of a spell, a family of spells (the catalog's lines that name the skill beside them)
  const school = {};
  for (const e of cat) { const gp = awParts(e.group), k = segs(e.path);
    gp.forEach((g, i) => { const m = /^\{(spellbase|spellplain|spellmap)\.skill\}$/.exec(g); if (m && k[i + 1]) school[k[i + 1]] = k[i];
      const ty = /^\{type:([^}]+)\}$/.exec(g); if (ty && k[i]) school[k[i]] = ty[1]; }); }
  const skills = new Set(Object.values(school));
  // the paths of the all-tiers sets (midcast.{spellbase}...): a {spell} line on the same path is that set, every tier
  const allTiers = new Set(cat.filter(e => /\{(spellbase|spellplain)\}$/.test(e.group)).map(e => e.path));
  const list = [];
  for (const e of cat) {
    const gp = awParts(e.group);
    let keys = segs(e.path);
    // a {set:...} part names a set of several keys (engaged.{set:engaged}: engaged.Acc.DW.Solo): its keys joined in one
    const si = gp.findIndex(g => g.startsWith('{set:'));
    if (si >= 0 && keys.length > gp.length) keys = keys.slice(0, si).concat([keys.slice(si, si + keys.length - gp.length + 1).join(' · ')], keys.slice(si + keys.length - gp.length + 1));
    if (gp.length !== keys.length) continue;
    const q = {}, lit = []; let subj = null, sch = null, tier = null, weaponLine = WEAPON_LINE.test(e.group);
    gp.forEach((g, i) => {
      const k = keys[i];
      if (!g.startsWith('{')) {
        const L = AW_LITERAL[k];
        if (L) { if (L.target) q.target = L.target; if (L.buff) q.buff = L.buff; if (L.subject) subj = {kind: 'spell', name: L.subject}; return; }
        if (skills.has(k) || /Magic$/.test(k)) { sch = k; return; }
        if (AW_ROOT.has(k)) return;
        lit.push(k); return;
      }
      const inner = g.slice(1, -1), p = inner.split(/[:~]/)[0];
      if (/^[^:~]*\|/.test(inner)) { if (AW_PROFILES.has(k)) q.profile = k; else subj = {kind: 'spell', name: k}; return; }
      if (p === 'spell') { subj = {kind: 'spell', name: awBase(k)}; tier = k; if (!allTiers.has(e.path)) q.scope = k; return; }
      if (p === 'spellbase' || p === 'spellplain') { subj = {kind: 'spell', name: k}; return; }
      if (/\.skill$/.test(p) || p === 'skill') { sch = k; return; }
      if (['type', 'spellmap', 'spelltype', 'abilitytype', 'ability.type', 'wsskill'].includes(p) || p === 'ability' && inner.includes('.type')) { if (!subj) subj = {kind: 'family', name: k}; return; }
      if (p === 'ws') { subj = {kind: 'ws', name: k}; return; }
      if (p === 'ja' || p === 'ability') { subj = {kind: 'ability', name: k}; return; }
      if (p === 'set' && (wsSkills()[k] || e.group.startsWith('precast.WS.'))) { subj = {kind: 'ws', name: k}; return; }
      if (p === 'set' || weaponLine) { lit.push(k); return; }
      if (!AW_NOT_MODE.has(p)) { q.mode = {state: p, value: k}; return; }
      lit.push(k);
    });
    // a key the job file names on its own (sets.midcast.Flash, a family named as its only spell: Phalanx, Stoneskin,
    // Aquaveil, Raise): the spell it is, with the other sets of that spell (the game's skill of it: job_access_data.js)
    const isSpell = n => typeof SPELL_SKILL === 'object' && SPELL_SKILL[n] && SPELL_SKILL[n] !== '(N/A)';
    if (!subj && lit.length === 1 && AW_SPELL_FAMS.has(catFamily(e)) && isSpell(lit[0])) { subj = {kind: 'spell', name: lit[0]}; lit.length = 0; }
    if (subj && subj.kind === 'family' && isSpell(subj.name)) subj = {kind: 'spell', name: subj.name};
    if (!subj && sch) subj = {kind: 'school', name: sch};
    // the keys left over: the set's own name when nothing else names it (engaged.DPS, idleXp), else a version
    if (!subj) subj = {kind: 'set', name: lit.length ? lit.join(' · ') : ''};
    else if (lit.length) q.variant = lit.join(' · ');
    if (subj.kind !== 'school' && subj.kind !== 'set') subj.school = sch || school[subj.name] || (subj.kind === 'spell' ? school[awBase(subj.name)] : null) || null;
    if (subj.kind === 'school') subj.school = subj.name;
    // a spell no line ties to a school (Cure, in the Cures' own kind): the game's skill of the spell (job_access_data.js)
    if (subj.kind === 'spell' && !subj.school && typeof SPELL_SKILL === 'object') {
      const sk = SPELL_SKILL[subj.name] || SPELL_SKILL[subj.name + ' II'] || SPELL_SKILL[tier || ''];
      if (sk && sk !== '(N/A)') subj.school = sk; }
    if (subj.kind === 'spell' && AW_GEAR_SPELLS[subj.name] && !isThere(e) && !awHolds(AW_GEAR_SPELLS[subj.name])) continue;
    list.push({e, fam: catFamily(e), subject: subj, q, tier});
  }
  AW_CACHE = {cat, list};
  return list;
}
const awSubjKey = s => s.kind + ':' + s.name;
const awFamName = s => (T[S.lang].awFamName || {})[s] || s;
const awSchoolName = s => s ? ((T[S.lang].awSchool || {})[s] || s) : '';

/* ---- the window's state: S._aw = {step, fam, subj, ans: {}, expert, path} ---- */
function awOpen(){ S._aw = {step: 0, fam: null, subj: null, ans: {}, expert: false, q: ''}; awRender(); }
function awRender(){ const spec = {cls: 'awdlg', titleHtml: '', addSet: ATELIER_DIALOG.addStepView()};
  if ($('#overlay .awdlg') && !$('#overlay').hidden) ATELIER_DIALOG.update(spec); else ATELIER_DIALOG.show(spec); const q = $('#awq'); if (q) { q.focus(); q.value = S._aw.q || ''; } }
// The situations of the subject chosen
// The situations a kind shows: its own; "when the spell lands" also holds the Cures' (their own kind in the list of
// sets): every school has all its spells, Cure and Curaga under Healing (the player, 2026-11-01)
const awInFam = (x, fam) => x.fam === fam || (fam === 'midcast' && x.fam === 'cure');
const awOfSubject = () => (awSituations() || []).filter(x => awInFam(x, S._aw.fam) && awSubjKey(x.subject) === S._aw.subj);
// The questions whose answers change the set: each with its options (the situations' values, "none" for those without)
function awQuestions(list){
  const out = [], vals = k => [...new Set(list.map(x => k === 'mode' ? (x.q.mode ? x.q.mode.state + '=' + x.q.mode.value : '') : (x.q[k] || '')))];
  for (const k of ['target', 'buff', 'scope', 'mode', 'profile', 'variant']) {
    const v = vals(k);
    if (v.length > 1 || (v.length === 1 && v[0] !== '' && k === 'target' && list.length > 1)) out.push({k, values: v.sort((a, b) => (a === '') === (b === '') ? a.localeCompare(b) : a === '' ? -1 : 1)});
  }
  return out;
}
// The situations left by the answers given so far
function awMatching(list, ans){
  return list.filter(x => Object.entries(ans).every(([k, v]) => (k === 'mode' ? (x.q.mode ? x.q.mode.state + '=' + x.q.mode.value : '') : (x.q[k] || '')) === v));
}
// The one name of a situation (its spellings that GearSwap reads alike): the one in the file, else the shortest without
// a school's key, else the shortest
function awPreferred(list){
  const there = list.filter(x => isThere(x.e));
  if (there.length) return there[0];
  const score = x => segs(x.e.path).length * 10 + (segs(x.e.path).some(k => /Magic$/.test(k)) ? 5 : 0);
  return [...list].sort((a, b) => score(a) - score(b))[0];
}
// The clicks of the window (events.js): false when the click is not one of its own
function awClick(d){
  const A = S._aw;
  if (!A) return false;
  if (d.awfam) { Object.assign(A, {fam: d.awfam, step: 1, subj: null, ans: {}, expert: false, q: '', tab: null, sub: null, addw: null, cyc: null});
    // the weapons to add need the game's item list (which job wears what): loaded first when the page has not yet
    if (d.awfam === 'weapons' && !window.ATELIER_CATALOG && !S._catMissing) { loadCatalog(awRender); return true; }
    awRender(); return true; }
  if (d.awtab != null) { Object.assign(A, {tab: d.awtab, sub: null}); awRender(); return true; }
  if (d.awsub != null) { A.sub = d.awsub; awRender(); return true; }
  if (d.awsubj && d.awsubj.startsWith('cyc:')) { const [, mode, ...n] = d.awsubj.split(':'), name = n.join(':');
    A.cyc = awCycleItems().find(x => x.mode === mode && x.name === name) || null; A.addw = null; A.step = 3; awRender(); return true; }
  // a weapon: its summary, on the cycle it was added to here, else the first it can join (data-awaddcyc picks another)
  if (d.awsubj && d.awsubj.startsWith('addw:')) { const name = d.awsubj.slice(5), all = awWeaponChoices().filter(x => x.name === name);
    A.addw = all.find(x => x.added) || all[0] || null; A.step = 3; awRender(); return true; }
  if (d.awaddcyc != null && A.addw) { A.addw = awWeaponChoices().find(x => x.name === A.addw.name && x.mode === d.awaddcyc) || A.addw; awRender(); return true; }
  if (d.awsubj) { Object.assign(A, {subj: d.awsubj, ans: {}, addw: null}); A.step = awQuestions(awOfSubject()).length ? 2 : 3; awRender(); return true; }
  if (d.awans) { const [k, ...v] = d.awans.split(':'); A.ans[k] = v.join(':'); awRender(); return true; }
  if ('awnext' in d) { A.step = 3; awRender(); return true; }
  if ('awexpert' in d) { A.expert = !A.expert; awRender(); return true; }
  if (d.awpick) { const x = (awSituations() || []).find(y => y.e.path === d.awpick); if (x) { Object.assign(A, {subj: awSubjKey(x.subject), ans: Object.fromEntries(['target', 'buff', 'scope', 'profile', 'variant'].map(k => [k, x.q[k] || '']).concat([['mode', x.q.mode ? x.q.mode.state + '=' + x.q.mode.value : '']])), step: 3, expert: false, pick: x.e.path}); awRender(); } return true; }
  if (d.awfrom) { addPath = A.path; addFrom(d.awfrom, A.base); return true; }
  if ('awaddw' in d) { awAddWeapon(); return true; }
  if ('awcycout' in d) { awCycleGo(true); return true; }
  if ('awcycin' in d) { awCycleGo(false); return true; }
  if ('awdelw' in d) { awDelWeapon(); return true; }
  if ('back' in d && $('#overlay .awdlg')) {
    if (A.expert) A.expert = false;
    else if (A.step === 3 && (A.addw || A.cyc)) { A.addw = null; A.cyc = null; A.step = 1; }
    else if (A.step === 3) A.step = awQuestions(awOfSubject()).length ? 2 : 1;
    else A.step = Math.max(0, A.step - 1);
    A.pick = null; awRender(); return true; }
  return false;
}
// The search box of steps 2 and the experts' list: rows hidden in place
function awFilter(q){
  // the subjects: drawn again from the search (every school at once); the experts' list: rows hidden in place
  if (!S._aw.expert) { S._aw.q = q; awRender(); return; }
  S._aw.q = q; q = q.trim().toLowerCase();
  for (const r of document.querySelectorAll('.awdlg [data-awq]')) r.hidden = !!q && !r.dataset.awq.includes(q);
  for (const g of document.querySelectorAll('.awdlg .awgroup')) g.hidden = ![...g.querySelectorAll('[data-awq]')].some(r => !r.hidden);
}

/* ---- "Add a weapon" (notes/docs-perso/ajouter-arme-2026-11-01/SPEC.md): a weapon you hold, not in any of the job's
   weapon cycles, added at the end of one through the Atelier's own layer over the states files
   (<Char>/atelier/overrides/mode_overrides.lua '+Mode', shared/utils/core/mode_overrides.lua), then its set created ---- */
Object.assign(T.fr, {awAlready: 'déjà dans ce cycle', awWhere: 'Dans quel cycle ?', awInCycle: 'déjà ajoutée ici', awSetThereShort: 'son set existe déjà', awAddSayOnly: '{w} sera ajoutée à ton cycle {m}, après {a} :', awAddW: 'Ajouter une arme', awAddSay: '{w} sera ajoutée à ton cycle {m}, après {a}, et son set créé :', awAddSayFirst: '{w} sera ajoutée à ton cycle {m}, et son set créé :',
  awAddWhy: 'Le cycle est changé dans atelier/overrides/mode_overrides.lua, par-dessus ton fichier de modes (jamais réécrit) : retirer l’arme le rend tel quel.',
  awAddGo: 'Ajouter', awAddedSay: '{w} a été ajoutée à ton cycle {m} depuis l’Atelier.', awDelGo: 'Retirer du cycle', awDelWhy: 'Son set reste (supprimable par le menu « ⋯ » du set).',
  awAdding: 'Ajout au cycle {m}, GearSwap recharge…', awAddLater: '{w} ajoutée au cycle {m} dans ton fichier : elle sera là au prochain chargement du job (//gs reload). Son set n’a pas été créé : refais-le avec le jeu connecté.', awAddedOnly: '{w} ajoutée à ton cycle {m} (son set existait déjà). GearSwap recharge.', awSetThere: 'Son set existe déjà : seul le cycle change.', awAddFail: 'Le jeu n’a pas pris l’ajout au cycle : rien n’a été créé.', awRemoved: '{w} retirée du cycle {m}.'});
Object.assign(T.en, {awAlready: 'in this cycle already', awWhere: 'In which cycle?', awInCycle: 'added here already', awSetThereShort: 'its set is there already', awAddSayOnly: '{w} will join your {m} cycle, after {a}:', awAddW: 'Add a weapon', awAddSay: '{w} will join your {m} cycle, after {a}, and its set be created:', awAddSayFirst: '{w} will join your {m} cycle, and its set be created:',
  awAddWhy: 'The cycle changes in atelier/overrides/mode_overrides.lua, over your modes file (never rewritten): removing the weapon puts it back as it was.',
  awAddGo: 'Add', awAddedSay: '{w} was added to your {m} cycle from the Atelier.', awDelGo: 'Remove from the cycle', awDelWhy: 'Its set stays (deleted from the set’s “⋯” menu).',
  awAdding: 'Adding to the {m} cycle, GearSwap reloads…', awAddLater: '{w} added to the {m} cycle in your file: it is there at the job\u2019s next load (//gs reload). Its set was not created: do it again with the game linked.', awAddedOnly: '{w} added to your {m} cycle (its set was there already). GearSwap reloads.', awSetThere: 'Its set is there already: only the cycle changes.', awAddFail: 'The game did not take the cycle change: nothing was created.', awRemoved: '{w} removed from the {m} cycle.'});
// The job's weapon cycles and the slot each fills (its values' sets), the values from the states file
function awWeaponCycles(){
  const d = data();
  if (!d) return [];
  return weaponModes(d).filter(m => !/^slot:/.test(m.name) && !m.onlyEmpty).map(m => {
    const slots = new Set(m.values.flatMap(v => Object.keys((m.sets[v] || {}).pieces || {})));
    const slot = ['main', 'sub', 'range', 'ammo'].find(s => slots.has(s));
    // the values as the layer leaves them now (the export's, read after the last load, with what was added or taken
    // out since): the list right at once, before the game's next export
    const minus = awRemovedOf(m.name), seen = (d.modes.find(x => x.name === m.name) || {}).values || m.values;
    const full = [...new Set(seen.concat(awAdded(m.name)))].filter(v => !minus.includes(v));
    return slot ? {name: m.name, desc: m.desc || m.name, slot, values: full, sets: m.sets} : null;
  }).filter(Boolean);
}
// The values the Atelier added to a cycle (the layer as the page holds it)
const awAdded = mode => ((modeOverrides()[S.job] || {})['+' + mode] || []).slice();
// A cycle's slot as a set name's tag: sets["Colada Sub"] puts Colada in the off hand, sets.Colada being its main hand's
const AW_SLOT_TAG = {main: 'Main', sub: 'Sub', range: 'Range', ammo: 'Ammo'};
const awSetAt = path => ((data() || {}).sets || []).find(x => x.path === path);
// The value a weapon takes in a cycle: its own name, unless a set of that name holds it in another slot. GearSwap
// equips sets[value] as it is (shared/utils/equipment/weapon_resolver.lua): sets.Colada chosen as the sub would move
// the main hand
function awValueFor(c, item){
  const s = awSetAt(awWeaponPath(item)), p = s && s.pieces[c.slot];
  return !s || (p && p.name === item) ? item : item + ' ' + AW_SLOT_TAG[c.slot];
}
// The weapon a value of a cycle puts on: its set's piece in the cycle's slot, else the value less its slot tag
function awItemOf(c, value){
  const s = awSetAt(awWeaponPath(value)), p = s && s.pieces[c.slot];
  return p && p.name ? p.name : value.endsWith(' ' + AW_SLOT_TAG[c.slot]) ? value.slice(0, -AW_SLOT_TAG[c.slot].length - 1) : value;
}
// The weapons you hold that the job wears in a cycle's slot and that cycle does not hold yet (one in another cycle
// too: Colada in the main hand's and the off hand's), the Atelier's own additions first:
// [{mode, desc, slot, name (the weapon), value (the cycle's value, its set's name), added}]
function awWeaponChoices(){
  const cycles = awWeaponCycles(), owned = ownedOf() || {}, rows = (catalog() || {}).row || {}, out = [];
  const wears = (name, slot) => { const r = rows[name]; return !!r && r[2].split(' ').includes(slot) && r[3].split(' ').includes(S.job); };
  for (const c of cycles) {
    const row = (name, value, added) => ({mode: c.name, desc: c.desc, slot: c.slot, name, value, added});
    const added = awAdded(c.name), held = new Set(c.values.flatMap(v => [v, awItemOf(c, v)]));
    for (const v of added) out.push(row(awItemOf(c, v), v, true));
    for (const name of [...new Set((owned[c.slot] || []).map(x => x.name))].sort())
      if (!held.has(name) && wears(name, c.slot)) out.push(row(name, awValueFor(c, name), false));
  }
  return out;
}
const awWeaponPath = name => /^[A-Za-z_]\w*$/.test(name) ? 'sets.' + name : 'sets["' + name + '"]';
// After a change that creates no set (a weapon taken out, put back, or added with its set there): the window stays
// open on the same tab, its lists as the layer now is; only a set created closes it, to open that set
function awStay(toast){
  const A = S._aw;
  if (A) Object.assign(A, {addw: null, cyc: null, step: 1, busy: false});
  S.toast = toast; render();
  if (A) awRender();
}
// Add: the layer saved (no reload yet), GearSwap reloaded and waited for (opt_sets.js osReloadWait), then the set's
// creation as any (push.js createPreview: preview, backup, history): the game's catalog holds the new value by then
async function awAddWeapon(){
  const A = S._aw, w = A && A.addw;
  if (!w || A.busy || !liveWrite()) return;
  A.busy = true; S.toast = t('awAdding', {m: w.desc}); render();
  const map = modeOverrides(), scope = S.job, key = '+' + w.mode;
  map[scope] = map[scope] || {};
  map[scope][key] = awAdded(w.mode).concat([w.value]);
  const done = await saveFile('mode_overrides.lua', modesLua(map), true);
  if (done === null) { A.busy = false; S.toast = t('awAddFail'); render(); return; }
  S.modeDirty[S.char] = false; S.modeOv[S.char].at = stamp();
  // written through the folder (the game's door did not answer): applied at the next load, no set created now
  if (done !== 'live') { awStay(t('awAddLater', {w: w.name, m: w.desc})); return; }
  const path = awWeaponPath(w.value), owned = ownedOf() || {};
  // its set there already (Kaories' sets['Daybreak']): only the cycle changes, GearSwap reloaded to take it
  if (setThere(path)) { await reloadIfLoaded(); awStay(t('awAddedOnly', {w: w.name, m: w.desc})); return; }
  await osReloadWait();
  A.busy = false;
  createPreview(path, [path, '#create', pushLine(pushEntry(w.slot, {name: w.name}, owned))].join('\n') + '\n', null);
}
// Remove: the weapon leaves the layer, GearSwap reloads; its set stays
async function awDelWeapon(){
  const A = S._aw, w = A && A.addw;
  if (!w || A.busy) return;
  const map = modeOverrides(), scope = S.job, key = '+' + w.mode, left = awAdded(w.mode).filter(n => n !== w.value);
  if (map[scope]) { if (left.length) map[scope][key] = left; else delete map[scope][key]; if (!Object.keys(map[scope]).length) delete map[scope]; }
  const done = await saveFile('mode_overrides.lua', modesLua(map), false);
  if (done === null) return;
  S.modeDirty[S.char] = false; S.modeOv[S.char].at = stamp();
  awStay(t('awRemoved', {w: w.name, m: w.desc}));
}

/* ---- "My cycles": any weapon of a cycle taken out (the states file's too) or put back, through the same layer
   ('-MainWeapon' = {'Colada'}: shared/utils/core/mode_overrides.lua remove_values); the states file never rewritten ---- */
Object.assign(T.fr, {awCycles: 'Mes cycles', awCycSay: '{w} est dans ton cycle {m}.', awCycOutSay: '{w} a été retirée de ton cycle {m} depuis l’Atelier.',
  awCycOut: 'Retirer du cycle', awCycIn: 'Remettre dans le cycle', awCycOutWhy: 'Retirée par-dessus ton fichier de modes (jamais réécrit), dans atelier/overrides/mode_overrides.lua : « Remettre » la rend. Son set reste.',
  awCycLast: 'C’est la seule arme de ce cycle : un cycle en garde une au moins.', awCycOutTag: 'retirée', awCycDone: '{w} retirée du cycle {m}.', awCycBack: '{w} remise dans le cycle {m}.',
  awCycGone: 'plus dans tes sacs', delCycle: ' Et retirée du cycle {m}.'});
Object.assign(T.en, {awCycles: 'My cycles', awCycSay: '{w} is in your {m} cycle.', awCycOutSay: '{w} was taken out of your {m} cycle from the Atelier.',
  awCycOut: 'Take out of the cycle', awCycIn: 'Put back in the cycle', awCycOutWhy: 'Taken out over your modes file (never rewritten), in atelier/overrides/mode_overrides.lua: “Put back” brings it back. Its set stays.',
  awCycLast: 'It is the only weapon of this cycle: a cycle keeps one at least.', awCycOutTag: 'taken out', awCycDone: '{w} taken out of the {m} cycle.', awCycBack: '{w} put back in the {m} cycle.',
  awCycGone: 'no longer in your bags', delCycle: ' And taken out of the {m} cycle.'});
// The values the Atelier took out of a cycle (the layer as the page holds it)
const awRemovedOf = mode => ((modeOverrides()[S.job] || {})['-' + mode] || []).slice();
// Every weapon of every cycle: [{mode, desc, slot, name, out}] (the ones taken out here after the others)
function awCycleItems(){
  return awWeaponCycles().flatMap(c => c.values.map(name => ({mode: c.name, desc: c.desc, slot: c.slot, name, out: false, count: c.values.length}))
    .concat(awRemovedOf(c.name).filter(n => !c.values.includes(n)).map(name => ({mode: c.name, desc: c.desc, slot: c.slot, name, out: true, count: c.values.length}))));
}
// The layer changed for one value of a cycle: out (the Atelier's own addition dropped, else '-'), or back in
function awCycleLayer(mode, name, out){
  const map = modeOverrides(), scope = S.job;
  map[scope] = map[scope] || {};
  const plus = awAdded(mode), minus = awRemovedOf(mode);
  const set = (k, l) => { if (l.length) map[scope][k] = l; else delete map[scope][k]; };
  if (out) { if (plus.includes(name)) set('+' + mode, plus.filter(n => n !== name)); else set('-' + mode, minus.concat(minus.includes(name) ? [] : [name])); }
  else set('-' + mode, minus.filter(n => n !== name));
  if (!Object.keys(map[scope]).length) delete map[scope];
  return map;
}
// Take out / put back: the layer saved, GearSwap reloaded
async function awCycleGo(out){
  const A = S._aw, c = A && A.cyc;
  if (!c || A.busy) return;
  A.busy = true;
  const done = await saveFile('mode_overrides.lua', modesLua(awCycleLayer(c.mode, c.name, out)), false);
  A.busy = false;
  if (done === null) return;
  S.modeDirty[S.char] = false; S.modeOv[S.char].at = stamp();
  awStay(t(out ? 'awCycDone' : 'awCycBack', {w: c.name, m: c.desc}));
}
// A weapon set deleted (push.js delGo): its weapon leaves its cycle too, a value with no set doing nothing; the layer
// saved without a reload (the delete's own reload follows). The words added to the delete's message, or ''
async function awCycleDropSet(path){
  const keys = segs(path);
  if (keys.length !== 1) return '';
  const c = awWeaponCycles().find(x => x.values.includes(keys[0]));
  if (!c || c.values.length < 2) return '';
  const done = await saveFile('mode_overrides.lua', modesLua(awCycleLayer(c.name, keys[0], true)), true);
  if (done === null) return '';
  S.modeDirty[S.char] = false; S.modeOv[S.char].at = stamp();
  return t('delCycle', {m: c.desc});
}
