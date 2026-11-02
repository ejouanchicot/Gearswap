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
  if (d.awfam) { Object.assign(A, {fam: d.awfam, step: 1, subj: null, ans: {}, expert: false, q: '', tab: null, sub: null});
    awRender(); return true; }
  if (d.awtab != null) { Object.assign(A, {tab: d.awtab, sub: null}); awRender(); return true; }
  if (d.awsub != null) { A.sub = d.awsub; awRender(); return true; }
  if (d.awsubj) { Object.assign(A, {subj: d.awsubj, ans: {}}); A.step = awQuestions(awOfSubject()).length ? 2 : 3; awRender(); return true; }
  if (d.awans) { const [k, ...v] = d.awans.split(':'); A.ans[k] = v.join(':'); awRender(); return true; }
  if ('awnext' in d) { A.step = 3; awRender(); return true; }
  if ('awexpert' in d) { A.expert = !A.expert; awRender(); return true; }
  if (d.awpick) { const x = (awSituations() || []).find(y => y.e.path === d.awpick); if (x) { Object.assign(A, {subj: awSubjKey(x.subject), ans: Object.fromEntries(['target', 'buff', 'scope', 'profile', 'variant'].map(k => [k, x.q[k] || '']).concat([['mode', x.q.mode ? x.q.mode.state + '=' + x.q.mode.value : '']])), step: 3, expert: false, pick: x.e.path}); awRender(); } return true; }
  if (d.awfrom) { addPath = A.path; addFrom(d.awfrom, A.base); return true; }
  if ('back' in d && $('#overlay .awdlg')) {
    if (A.expert) A.expert = false;
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
