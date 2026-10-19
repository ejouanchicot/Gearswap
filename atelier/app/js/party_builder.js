// GearSwap Atelier · party_builder.js: the new layout's Combat tab as the game's party list (2026-10-06). One card a
// member: you, then each support job in the party (GEO, BRD, COR, WHM, RDM, SCH, and the jobs whose abilities reach
// you: WAR, DNC, SMN...). A card added comes filled with that job's usual buffs; what it casts on the target (Frailty,
// Dia, Distract) is on its card. Under the cards, the target and what the whole party gives you. Saved parties come back
// in one click. The values are the same buff state as before (buffState(): every page figure reads it), only the way
// of choosing changes; the old window stays (the Old layout).
// (loaded by atelier/index.html after layout2.js: see the list there)

Object.assign(T.fr, {
  pbTitle: 'Le groupe et ses buffs', pbWhy: 'Ce que la page compte dans tous ses calculs : ton groupe et ses buffs, ta cible et les debuffs posés dessus. Rien ici ne change ce que tu portes en jeu.',
  pbYou: 'Toi', pbAdd: 'Ajouter', pbAddWhy: 'Un membre du groupe', pbRemove: 'Retirer ce membre', pbGives: 'Te donne', pbNothing: 'rien pour l’instant',
  pbResult: 'Le total', pbOnYou: 'Sur toi (groupe, nourriture, tes abilities)', pbOnFoe: 'Sur la cible', pbFrom: 'Vient de : {l}', pbTarget: 'Cible', pbSaved: 'Buffs enregistrés', pbSave: '+ Enregistrer ces buffs', pbSaveAsk: 'Nom (Sortie, Odyssey, Trusts XP…)', pbSaveTitle: 'Enregistrer ces buffs et débuffs', pbSaveGo: 'Enregistrer', pbSaveHave: 'Déjà enregistrés (un même nom remplace) :', pbSavedAs: 'Buffs « {n} » enregistrés',
  pbAddTitle: 'Ajouter les buffs d’un job ({n} place(s))', pbAddLeft: '{n} place(s)', pbAddSupport: 'Buffs de soutien', pbAddJa: 'Capacités de groupe', pbAddFoe: 'Débuffs sur la cible',
  pbForget: 'Oublier ces buffs', pbLoaded: 'Buffs « {n} » remis.', pbNoSaved: 'aucun : choisis les buffs puis enregistre-les',
  pbOther: 'Autres debuffs sur la cible', pbOtherWho: 'Dia, Distract, Light Shot, et ce que posent les jobs qui ne sont pas dans le groupe (THF, BLM, NIN, BLU, BST…)', pbOtherOpen: 'Déplier', pbOtherShut: 'Replier', pbDefNow: 'Défense {a} → {b}', pbEvaNow: 'Évasion {a} → {b}',
  pbFoodAtk: 'Attaque', pbFoodAcc: 'Précision', pbFoodBoth: 'Attaque et précision', pbFoodWs: 'Double Attack et WS', pbFoodMagic: 'Magie', pbFoodTank: 'Défense (tank)',
  pbChoose: 'Choisir…', pbSearch: 'Chercher…', pbNone: 'Aucune', pbBubbles: 'Bulles', pbYouBase: 'Repas et aftermath', pbGeoHelp: 'Une ligne par bulle : clique dans la colonne Indi, Geo ou Entrust ; un autre clic la retire.', pbBuffs: 'Sur toi', pbOnTarget: 'Sur la cible', pbOffense: 'Combat', pbAttrs: 'Attributs', pbGear: 'Équipement et capacités', pbOther2: 'Autres',
  pbSongs: 'Chansons', pbSongsNote: '{n} / {m} : un clic place la chanson, un autre la retire', pbRolls: 'Rolls', pbRollsNote: '{n} / 2', pbRollValues: 'Valeur de chaque roll',
  pbIndiNote: 'sur le GEO et le groupe proche', pbGeoNote: 'la luopan, sur la cible ou le groupe', pbEntrustNote: 'une Indi donnée à un allié',
  pbSvHint: 'chansons ×2', pbClarionHint: '+1 chanson', pbLsHint: 'renforce Dia', pbEnHint: 'dégâts en plus', pbDefDown: 'Déf cible −', pbAtkDown: 'Att cible −', pbEvaDown: 'Éva cible −', pbJob_GEO: 'Bulles', pbJob_BRD: 'Chansons', pbJob_COR: 'Rolls', pbJob_WHM: 'Protect, Shell, Haste', pbJob_RDM: 'Haste II, Dia, Distract', pbJob_SCH: 'Storm',
});
Object.assign(T.en, {
  pbTitle: 'The party and its buffs', pbWhy: 'What the page counts in all its figures: your party and its buffs, your target and the debuffs on it. Nothing here changes what you wear in game.',
  pbYou: 'You', pbAdd: 'Add', pbAddWhy: 'A party member', pbRemove: 'Remove this member', pbGives: 'Gives you', pbNothing: 'nothing yet',
  pbResult: 'The total', pbOnYou: 'On you (party, food, your abilities)', pbOnFoe: 'On the target', pbFrom: 'Comes from: {l}', pbTarget: 'Target', pbSaved: 'Saved buffs', pbSave: '+ Save these buffs', pbSaveAsk: 'Name (Sortie, Odyssey, Trusts XP…)', pbSaveTitle: 'Save these buffs and debuffs', pbSaveGo: 'Save', pbSaveHave: 'Already saved (the same name replaces it):', pbSavedAs: 'Buffs “{n}” saved',
  pbAddTitle: 'Add a job’s buffs ({n} slot(s) left)', pbAddLeft: '{n} slot(s)', pbAddSupport: 'Support buffs', pbAddJa: 'Party abilities', pbAddFoe: 'Debuffs on the target',
  pbForget: 'Forget these buffs', pbLoaded: 'Buffs “{n}” restored.', pbNoSaved: 'none: pick the buffs, then save them',
  pbOther: 'Other debuffs on the target', pbOtherWho: 'Dia, Distract, Light Shot, and what the jobs that are not in the party lay (THF, BLM, NIN, BLU, BST…)', pbOtherOpen: 'Unfold', pbOtherShut: 'Fold', pbDefNow: 'Defense {a} → {b}', pbEvaNow: 'Evasion {a} → {b}',
  pbFoodAtk: 'Attack', pbFoodAcc: 'Accuracy', pbFoodBoth: 'Attack and accuracy', pbFoodWs: 'Double Attack and WS', pbFoodMagic: 'Magic', pbFoodTank: 'Defense (tank)',
  pbChoose: 'Choose…', pbSearch: 'Search…', pbNone: 'None', pbBubbles: 'Bubbles', pbYouBase: 'Food and aftermath', pbGeoHelp: 'One row per bubble: click in its Indi, Geo or Entrust column; click again to remove it.', pbBuffs: 'On you', pbOnTarget: 'On the target', pbOffense: 'Combat', pbAttrs: 'Attributes', pbGear: 'Gear and abilities', pbOther2: 'Others',
  pbSongs: 'Songs', pbSongsNote: '{n} / {m}: one click places the song, another removes it', pbRolls: 'Rolls', pbRollsNote: '{n} / 2', pbRollValues: 'Each roll’s number',
  pbIndiNote: 'on the GEO and nearby party members', pbGeoNote: 'the luopan, on the target or the party', pbEntrustNote: 'an Indi given to an ally',
  pbSvHint: 'songs ×2', pbClarionHint: '+1 song', pbLsHint: 'strengthens Dia', pbEnHint: 'extra damage', pbDefDown: 'Tgt Def −', pbAtkDown: 'Tgt Atk −', pbEvaDown: 'Tgt Eva −', pbJob_GEO: 'Bubbles', pbJob_BRD: 'Songs', pbJob_COR: 'Rolls', pbJob_WHM: 'Protect, Shell, Haste', pbJob_RDM: 'Haste II, Dia, Distract', pbJob_SCH: 'Storm',
});

const PB_FOE = ['edefp', 'eeva', 'emdb', 'emeva', 'eres', 'estatp', 'ecrit', 'eatkp', 'egambit', 'eresu', 'eallstat', 'eslow', 'edot', 'estr', 'edex', 'evit', 'eagi', 'eint', 'emnd', 'echr'];
const pbGeo = v => v.replace(/^(Entrust )?(Indi|Geo)-/, '');
// The support jobs: the buff keys their card holds, whether the party has them, their usual buffs, what of the
// effects list is theirs (by source name)
const PB_JOBS = [
  {job: 'GEO', keys: ['indi', 'geo', 'entrust', 'geoPlus', 'bolster', 'bog', 'ecliptic', 'geoScale'], has: b => !!(b.indi || b.geo || b.entrust),
    def: {indi: 'Fury', geo: 'Frailty', geoPlus: '10'}, src: v => /^(Entrust )?(Indi|Geo)-/.test(v) && !!(BUBBLES[pbGeo(v)] || GEO_DEBUFFS[pbGeo(v)])},
  {job: 'BRD', keys: ['song0', 'song1', 'song2', 'song3', 'song4', 'songsPlus', 'soulVoice', 'marcato', 'clarion', 'ariaStage'], has: b => [0, 1, 2, 3, 4].some(i => b['song' + i]),
    def: {song0: 'Honor March', song1: 'Minuet V', song2: 'Minuet IV', song3: 'Aria of Passion', songsPlus: '9'}, src: v => v in SONGS},
  {job: 'COR', keys: ['roll0', 'roll0n', 'roll1', 'roll1n', 'rollsPlus', 'roll0job', 'roll1job', 'rollCC', 'lightshot', 'corShots'], has: b => !!(b.roll0 || b.roll1),
    def: {roll0: 'Chaos', roll1: 'Samurai', rollsPlus: '8', lightshot: true}, src: v => / Roll [IVX]+/.test(v) || v === 'Light Shot'},
  {job: 'WHM', keys: ['protect', 'shell', 'auspice', 'auspiceFeet'], has: b => !!(b.protect || b.shell || b.auspice),
    def: {protect: 'Protect V', shell: 'Shell V'}, src: v => v in PROTECT || v in SHELL || v === 'Haste' || v === 'Auspice'},
  {job: 'RDM', keys: ['haste', 'dia', 'distract', 'saboteur', 'sabGloves', 'enspell', 'enSkill'], has: b => b.haste === 'Haste II' || !!(b.dia === 'Dia III' || b.distract || b.enspell),
    def: {haste: 'Haste II', dia: 'Dia III'}, src: v => v === 'Haste II' || v === 'Dia III' || v === 'Bio III' || /^Distract/.test(v) || v === 'Enspell I'},
  {job: 'SCH', keys: ['storm'], has: b => !!b.storm, def: {}, src: v => v in STORMS},
];
// The jobs whose abilities reach you (a party WAR's Warcry, a DNC's sambas, a SMN's pacts): one card a job
function pbJaJobs(){
  const out = new Map();
  for (const ja of jasOf().filter(j => j.as === 'party')) {
    const job = ja.a.from || [].concat(ja.a.job)[0];
    if (!out.has(job)) out.set(job, []);
    out.get(job).push(ja);
  }
  return out;
}
// What a job casts on the target (FOE_JA, buffs.js), as its card's buttons; RDM, WHM and COR have theirs on their cards
// already (Dia, Distract, Light Shot), WS is no job (the weaponskills' debuffs stay under "other debuffs")
const pbFoeJobs = () => Object.keys(FOE_JA).filter(j => !['WS'].includes(j));
const pbFoeOn = (b, job) => Object.keys(FOE_JA[job] || {}).some(n => (b.foeJa || []).includes(n));
const pbMembers = b => b.pbMembers || [];
// a member removed stays out even while a buff it shares is still on (Protect V with a RDM in the party)
const pbGone = b => b.pbGone || [];
function pbShown(b){
  const ja = pbJaJobs(), out = j => pbGone(b).includes(j) && !pbMembers(b).includes(j);
  const shown = PB_JOBS.filter(j => !out(j.job) && (j.has(b) || pbMembers(b).includes(j.job))).map(j => j.job);
  for (const [job, list] of ja) if (!out(job) && (list.some(x => jaOn(b, x.name)) || pbMembers(b).includes(job))) shown.push(job);
  for (const job of pbFoeJobs()) if (!shown.includes(job) && !out(job) && (pbFoeOn(b, job) || pbMembers(b).includes(job))) shown.push(job);
  return shown;
}

// The controls (the same data-* as the old window: events.js handles them)
const pbSel = (b, key, values, ph = '—', def = null) => `<select class="buffsel ${b[key] ? 'set' : ''}" data-buff="${key}" title="${esc(t('ttBuffSel', {n: ph}))}">` +
  (def ? values : ['', ...values]).map(v => `<option value="${esc(v)}" ${String(v) === String(b[key] ?? def ?? '') ? 'selected' : ''}>${v === '' ? esc(ph) : esc(v)}</option>`).join('') + `</select>`;

// What a choice gives, as the small line beside its name: the stats of its table (a song, a roll, a bubble)
const pbStat = k => ((FX_SHORT[k] || FX_LABEL[k] || [k.toUpperCase(), k.toUpperCase()])[S.lang === 'fr' ? 0 : 1]);
// only the stats (a table's own fields, lim, shot, elem..., are left out)
const PB_ATTRS = ['str', 'dex', 'vit', 'agi', 'int', 'mnd', 'chr'];
const pbHint = def => [...new Set(Object.keys(def || {}).filter(k => FX_SHORT[k] || FX_LABEL[k] || PB_ATTRS.includes(k)).map(pbStat))].join(' · ');
// the families the windows list their choices by
const SONG_GROUPS = [['March', /March/], ['Minuet', /Minuet/], ['Madrigal', /Madrigal/], ['Aria', /Aria/], ['Etude', /Etude/]];
const BUBBLE_GROUPS = [[() => t('pbOffense'), ['Fury', 'Haste', 'Precision', 'Acumen', 'Focus']], [() => t('pbAttrs'), ['STR', 'DEX', 'VIT', 'AGI', 'INT', 'MND', 'CHR']],
  [() => t('pbOnTarget'), ['Frailty', 'Torpor', 'Malaise', 'Languor']]];

// The long lists (songs, rolls, bubbles, storms, food) open in a window: a slot is a button with its choice, the
// window lists every choice by family with what it gives, a search on top; a click picks and closes
const PB_PICK = {
  song: {title: i => `${t('bSong')} ${+i + 1}`, groups: () => SONG_GROUPS.map(([g, re]) => [g, Object.keys(SONGS).filter(v => re.test(v))]), hint: v => pbHint(SONGS[v])},
  roll: {title: i => `Roll ${+i + 1}`, groups: () => [['Rolls', Object.keys(ROLLS)]], hint: v => pbHint(ROLLS[v])},
  indi: {title: () => 'Indi', groups: () => BUBBLE_GROUPS.map(([g, l]) => [g(), l]), hint: v => pbHint(BUBBLES[v] || GEO_DEBUFFS[v])},
  geo: {title: () => 'Geo', groups: () => BUBBLE_GROUPS.map(([g, l]) => [g(), l]), hint: v => pbHint(BUBBLES[v] || GEO_DEBUFFS[v])},
  entrust: {title: () => 'Entrust', groups: () => BUBBLE_GROUPS.map(([g, l]) => [g(), l]), hint: v => pbHint(BUBBLES[v] || GEO_DEBUFFS[v])},
  storm: {title: () => 'Storm', groups: () => [['Storm', Object.keys(STORMS)]], hint: v => pbHint(STORMS[v])},
  food: {title: () => t('bFood'), groups: () => pbFoodGroups(), hint: v => Object.entries(FOODS[v] || {}).map(([k, x]) => fxShort(k, x)).join(' · ')},
};
// The foods by what they are eaten for: a tank's (HP, Defense, Magic Evasion), a WS's (Double Attack, WS damage),
// a mage's (magic attack or accuracy), then attack, accuracy, both
function pbFoodKind(f){
  if (f.hp || f.deff || f.mevaf || f.mdb && !f.mab) return 'pbFoodTank';
  if (f.da || f.wsd) return 'pbFoodWs';
  if ((f.mab || f.macc) && !f.atkf) return 'pbFoodMagic';
  if (f.atkf && f.acc) return 'pbFoodBoth';
  if (f.atkf) return 'pbFoodAtk';
  if (f.acc) return 'pbFoodAcc';
  return 'pbOther2';
}
function pbFoodGroups(){
  const order = ['pbFoodAtk', 'pbFoodAcc', 'pbFoodBoth', 'pbFoodWs', 'pbFoodMagic', 'pbFoodTank', 'pbOther2'], by = {};
  for (const name of Object.keys(FOODS)) (by[pbFoodKind(FOODS[name])] = by[pbFoodKind(FOODS[name])] || []).push(name);
  return order.filter(k => by[k]).map(k => [t(k), by[k]]);
}
// The pickers: drawn by the Svelte application (atelier/src/screens/dialogs/partypick.ts), their search in the window
function pbOpenPick(key){
  const v = ATELIER_DIALOG.pickView(key);
  if (!v) return;
  ATELIER_DIALOG.show({cls: 'pbdlg', titleHtml: esc(v.title), partyPick: v.view,
    buttonsHtml: v.none ? `<button class="btn ghost" data-pbchoose="${esc(v.none.value)}">${esc(v.none.label)}</button>` : ''});
  pbDlgFocus();
}
function pbChoose(spec){
  const at = spec.indexOf('|'), key = spec.slice(0, at), v = spec.slice(at + 1), b = buffState();
  if (v) b[key] = v; else delete b[key];
  // a roll picked starts at XI; taken off, its number goes with it
  if (/^roll\d$/.test(key)) { if (v && !b[key + 'n']) b[key + 'n'] = 'XI'; if (!v) delete b[key + 'n']; }
  closeOverlay(); S._globals = null; save(); render();
}

// The aftermath line: its lists in the control column, what the weapon in hand gives beside them, like every other line
function pbAmRow(sel){
  const html = amRowHTML(sel), at = html.indexOf('<span class="muted small amwho">');
  return pbF(t('bAm'), `<div class="pbfam">${html.slice(0, at)}</div>`, html.slice(at));
}

// A line of a member's panel (the panel itself: atelier/src/screens/combat/panel.ts): the aftermath's, drawn here
const pbF = (label, control, eff = '') => `<div class="pbf"><span class="pbfl">${esc(label)}</span><div class="pbfc">${control}</div><div class="pbfe">${eff}</div></div>`;



// The members not in the party yet, one button each, on a line over the cards
// Adding a member: a "+" tab opens a window listing the jobs not in the party, by what they bring (support buffs,
// party abilities, debuffs on the target), each saying what it gives; a click adds it and opens its tab
function pbAddGroups(shown){
  const seen = new Set(shown), out = [];
  const group = (title, jobs, hint) => { const l = jobs.filter(j => !seen.has(j)); l.forEach(j => seen.add(j)); if (l.length) out.push([title, l, hint]); };
  group(t('pbAddSupport'), PB_JOBS.map(j => j.job), j => t('pbJob_' + j));
  group(t('pbAddJa'), [...pbJaJobs().keys()], j => (pbJaJobs().get(j) || []).map(x => x.name.replace(' · party', '')).join(' · '));
  group(t('pbAddFoe'), pbFoeJobs(), j => Object.keys(FOE_JA[j] || {}).join(' · '));
  return out;
}
function pbOpenAdd(){
  const v = ATELIER_DIALOG.addView();
  if (!v) return;
  ATELIER_DIALOG.show({cls: 'pbdlg pbadddlg', titleHtml: esc(v.title), partyPick: v.view});
  pbDlgFocus();
}
// the search on top of a picker window, focused when it opens
function pbDlgFocus(){
  const q = $('.pbdlg .pbpq');
  if (q) q.focus();
}

// What all of this changes for the set opened: its figure in each situation, with the version of the set GearSwap
// wears there (tierVersions) and that situation's own buffs. A weaponskill set: its average damage at the TP chosen;
// an engaged set: the time to the weaponskill and its DPS. Worked out once for a state (four runs of the engine a
// redraw would be felt while the game redraws the page every two seconds)
Object.assign(T.fr, {pbImpact: 'Ce que ça change pour ton set', pbImpWs: 'dégâts moyens à {tp} TP', pbImpEng: 'temps jusqu’à la WS · DPS', pbImpSet: 'set porté',
  pbImpNone: 'Ouvre un set Engaged ou de weaponskill dans la liste : je te dirai ce qu’il vaut dans chaque situation.', pbImpNoEng: 'Le moteur n’est pas encore chargé.',
  pbImpItself: 'le set', pbImpTip: 'En {t}, GearSwap porte {s} : son chiffre avec les buffs de cette situation.', pbUndo: '↶ Annuler', pbUndoTip: 'Remet les buffs de cette situation comme ils étaient avant « {w} ».'});
Object.assign(T.en, {pbImpact: 'What it changes for your set', pbImpWs: 'average damage at {tp} TP', pbImpEng: 'time to the weaponskill · DPS', pbImpSet: 'set worn',
  pbImpNone: 'Open an Engaged or a weaponskill set in the list: I will tell you what it is worth in each situation.', pbImpNoEng: 'The engine is not loaded yet.',
  pbImpItself: 'the set', pbImpTip: 'In {t}, GearSwap wears {s}: its figure with that situation’s buffs.', pbUndo: '↶ Undo', pbUndoTip: 'Puts this situation’s buffs back as they were before "{w}".'});
let PB_IMPACT = {key: null, rows: null};
function pbImpactRows(s){
  const ws = !roundSet(s), {rows, worn} = tierVersions(s);
  const key = JSON.stringify([s.path, DATA_GEN, engineName(), ws ? S.wsTp || 3000 : (S.optOpts || {}).engAt, (data() || {}).sub, S.trial, S.weapons, S.held, TIERS.map(x => tierBuffsOf(x))]);
  if (PB_IMPACT.key === key) return PB_IMPACT.rows;
  const out = TIERS.map(tier => { const v = rows.find(r => r.name === worn[tier]) || rows[0];
    let a = null, b = null;
    try { withTierBuffs(tier, () => { if (ws) a = withoutTrial(() => wsDamage(v.set)); else { const r = engRound(v.set, true); if (r) { a = r.real ? r.real.time : r.time; b = r.dps; } } }); } catch (e) {}
    return {tier, version: v.name, a, b}; });
  PB_IMPACT = {key, rows: out};
  return out;
}

// In the Trust situation the members are trusts: the tab of a job says whose buffs these are (the trusts of
// TRUST_BUFFS: Sylvie's bubbles, Joachim's and Ulmia's songs, Qultada's rolls, the RDM's spells)
const TRUST_NAMES = {GEO: 'Sylvie', BRD: 'Joachim · Ulmia', COR: 'Qultada', WHM: 'Protect · Shell', RDM: 'RDM'};


// The Combat tab of the new layout: the party as tabs (you first, 6 at most, each saying what it gives), the chosen
// member's buttons in one panel under them; the total and the target beside it
const PB_MAX = 6;

// The cards' clicks: add a member (its usual buffs where its keys are empty), remove one (its buffs cleared, a shared
// one only when no other card holds it), save / load / forget a party
function pbClick(d){
  const b = buffState();
  // the member's tab shown is kept with the page's state (core.js KEEP): a reload comes back to it
  if (d.pbtab) { S.pbTab = d.pbtab; save(); render(); return; }
  if (d.pbpick) { pbOpenPick(d.pbpick); return; }
  if (d.pbchoose != null) { pbChoose(d.pbchoose); return; }
  if (d.pbgeomode) { S._pbGeoMode = d.pbgeomode; render(); return; }
  if (d.pbset) { const [k, v] = d.pbset.split('|'); if (b[k] === v) delete b[k]; else b[k] = v; }
  else if (d.pbsong) {
    // a song picked goes to the first free slot (4, 5 with Clarion Call), again takes it off and the next ones move up
    const slots = songSlots(b), list = slots.map(i => b['song' + i]).filter(Boolean), at = list.indexOf(d.pbsong);
    if (at >= 0) list.splice(at, 1); else if (list.length < slots.length) list.push(d.pbsong);
    slots.forEach((i, n) => { if (list[n]) b['song' + i] = list[n]; else delete b['song' + i]; });
  } else if (d.pbroll) {
    const at = [0, 1].find(i => b['roll' + i] === d.pbroll);
    if (at != null) { delete b['roll' + at]; delete b['roll' + at + 'n']; }
    else { const free = [0, 1].find(i => !b['roll' + i]); if (free == null) return; b['roll' + free] = d.pbroll; b['roll' + free + 'n'] = 'XI'; }
  }
  else if (d.pbaddopen != null) { pbOpenAdd(); return; }
  else if (d.pbadd) {
    if (pbShown(b).length + 1 >= PB_MAX) return;
    closeOverlay();
    S.pbTab = d.pbadd;
    const j = d.pbadd, def = PB_JOBS.find(x => x.job === j);
    b.pbMembers = [...new Set([...pbMembers(b), j])];
    b.pbGone = pbGone(b).filter(x => x !== j);
    if (def) for (const [k, v] of Object.entries(def.def)) if (b[k] == null || b[k] === '') b[k] = v;
    if (b.off) delete b.off[j];
  } else if (d.pbdel) {
    S.pbTab = 'you';
    const j = d.pbdel, def = PB_JOBS.find(x => x.job === j), shown = pbShown(b).filter(x => x !== j);
    b.pbMembers = pbMembers(b).filter(x => x !== j);
    b.pbGone = [...new Set([...pbGone(b), j])];
    if (def) for (const k of def.keys) {
      if (['protect', 'shell'].includes(k) && j === 'WHM' && shown.includes('RDM')) continue;
      if (k === 'haste' && j === 'RDM' && shown.includes('WHM') && b.haste === 'Haste') continue;
      delete b[k];
    }
    if (j === 'WHM' && b.haste === 'Haste' && !shown.includes('RDM')) delete b.haste;
    for (const ja of pbJaJobs().get(j) || []) if (b.pja) delete b.pja[ja.name];
    if (!['WHM', 'RDM'].includes(j) && b.foeJa) b.foeJa = b.foeJa.filter(n => !(n in (FOE_JA[j] || {})));
  }
  S._globals = null; save(); render();
}
