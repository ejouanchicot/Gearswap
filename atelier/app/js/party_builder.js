// GearSwap Atelier · party_builder.js: the new layout's Combat tab as the game's party list (2026-10-06). One card a
// member: you, then each support job in the party (GEO, BRD, COR, WHM, RDM, SCH, and the jobs whose abilities reach
// you: WAR, DNC, SMN...). A card added comes filled with that job's usual buffs; what it casts on the target (Frailty,
// Dia, Distract) is on its card. Under the cards, the target and what the whole party gives you. Saved parties come back
// in one click. The values are the same buff state as before (buffState(): every page figure reads it), only the way
// of choosing changes; the old window stays (the Old layout).
// (loaded by atelier/index.html after layout2.js: see the list there)

Object.assign(T.fr, {
  pbTitle: 'Buffs et débuffs du groupe', pbWhy: 'Choisis les buffs que tu reçois et les débuffs posés sur la cible : chaque job ajouté arrive avec ses buffs habituels. Ça sert seulement aux calculs des sets ; un clic pour changer.',
  pbYou: 'Toi', pbAdd: 'Ajouter', pbAddWhy: 'Un membre du groupe', pbRemove: 'Retirer ce membre', pbGives: 'Te donne', pbNothing: 'rien pour l’instant',
  pbResult: 'Ce que le groupe te donne', pbTarget: 'Cible', pbSaved: 'Buffs enregistrés', pbSave: '+ Enregistrer ces buffs', pbSaveAsk: 'Nom (Sortie, Odyssey, Trusts XP…)', pbSaveTitle: 'Enregistrer ces buffs et débuffs', pbSaveGo: 'Enregistrer', pbSaveHave: 'Déjà enregistrés (un même nom remplace) :', pbSavedAs: 'Buffs « {n} » enregistrés',
  pbAddTitle: 'Ajouter les buffs d’un job ({n} place(s))', pbAddLeft: '{n} place(s)', pbAddSupport: 'Buffs de soutien', pbAddJa: 'Capacités de groupe', pbAddFoe: 'Débuffs sur la cible',
  pbForget: 'Oublier ces buffs', pbLoaded: 'Buffs « {n} » remis.', pbNoSaved: 'aucun : choisis les buffs puis enregistre-les',
  pbOther: 'Autres debuffs sur la cible (BLM, THF, NIN, BLU, BST…)', pbDefNow: 'Défense {a} → {b}', pbEvaNow: 'Évasion {a} → {b}',
  pbFoodAtk: 'Attaque', pbFoodAcc: 'Précision', pbFoodBoth: 'Attaque et précision', pbFoodWs: 'Double Attack et WS', pbFoodMagic: 'Magie', pbFoodTank: 'Défense (tank)',
  pbChoose: 'Choisir…', pbSearch: 'Chercher…', pbNone: 'Aucune', pbBubbles: 'Bulles', pbYouBase: 'Repas et aftermath', pbGeoHelp: 'Une ligne par bulle : clique dans la colonne Indi, Geo ou Entrust ; un autre clic la retire.', pbBuffs: 'Sur toi', pbOnTarget: 'Sur la cible', pbOffense: 'Combat', pbAttrs: 'Attributs', pbGear: 'Équipement et capacités', pbOther2: 'Autres',
  pbSongs: 'Chansons', pbSongsNote: '{n} / {m} : un clic place la chanson, un autre la retire', pbRolls: 'Rolls', pbRollsNote: '{n} / 2', pbRollValues: 'Valeur de chaque roll',
  pbIndiNote: 'sur le GEO et le groupe proche', pbGeoNote: 'la luopan, sur la cible ou le groupe', pbEntrustNote: 'une Indi donnée à un allié',
  pbSvHint: 'chansons ×2', pbClarionHint: '+1 chanson', pbLsHint: 'renforce Dia', pbEnHint: 'dégâts en plus', pbDefDown: 'Déf cible −', pbAtkDown: 'Att cible −', pbEvaDown: 'Éva cible −', pbJob_GEO: 'Bulles', pbJob_BRD: 'Chansons', pbJob_COR: 'Rolls', pbJob_WHM: 'Protect, Shell, Haste', pbJob_RDM: 'Haste II, Dia, Distract', pbJob_SCH: 'Storm',
});
Object.assign(T.en, {
  pbTitle: 'Party buffs and debuffs', pbWhy: 'Pick the buffs you get and the debuffs on the target: each job added comes with its usual buffs. Only used for the set calculations; one click to change.',
  pbYou: 'You', pbAdd: 'Add', pbAddWhy: 'A party member', pbRemove: 'Remove this member', pbGives: 'Gives you', pbNothing: 'nothing yet',
  pbResult: 'What the party gives you', pbTarget: 'Target', pbSaved: 'Saved buffs', pbSave: '+ Save these buffs', pbSaveAsk: 'Name (Sortie, Odyssey, Trusts XP…)', pbSaveTitle: 'Save these buffs and debuffs', pbSaveGo: 'Save', pbSaveHave: 'Already saved (the same name replaces it):', pbSavedAs: 'Buffs “{n}” saved',
  pbAddTitle: 'Add a job’s buffs ({n} slot(s) left)', pbAddLeft: '{n} slot(s)', pbAddSupport: 'Support buffs', pbAddJa: 'Party abilities', pbAddFoe: 'Debuffs on the target',
  pbForget: 'Forget these buffs', pbLoaded: 'Buffs “{n}” restored.', pbNoSaved: 'none: pick the buffs, then save them',
  pbOther: 'Other debuffs on the target (BLM, THF, NIN, BLU, BST…)', pbDefNow: 'Defense {a} → {b}', pbEvaNow: 'Evasion {a} → {b}',
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
const pbSel = (b, key, values, ph = '—', def = null) => `<select class="buffsel ${b[key] ? 'set' : ''}" data-buff="${key}" title="${esc(ph)}">` +
  (def ? values : ['', ...values]).map(v => `<option value="${esc(v)}" ${String(v) === String(b[key] ?? def ?? '') ? 'selected' : ''}>${v === '' ? esc(ph) : esc(v)}</option>`).join('') + `</select>`;
const pbGeoSel = (b, key, ph) => `<select class="buffsel ${b[key] ? 'set' : ''}" data-buff="${key}" title="${ph}"><option value="">${ph}</option>` +
  `<optgroup label="${t('geoOnYou')}">${Object.keys(BUBBLES).map(v => `<option ${v === b[key] ? 'selected' : ''}>${esc(v)}</option>`).join('')}</optgroup>` +
  `<optgroup label="${t('geoOnEnemy')}">${Object.keys(GEO_DEBUFFS).map(v => `<option ${v === b[key] ? 'selected' : ''}>${esc(v)}</option>`).join('')}</optgroup></select>`;
const pbPlus = (b, key, label, max) => `<select class="buffsel plus ${b[key] ? 'set' : ''}" data-buff="${key}" title="${label}">` +
  ['', ...Array.from({length: max}, (_, i) => i + 1)].map(v => `<option value="${v}" ${String(v) === String(b[key] ?? '') ? 'selected' : ''}>${label} +${v || 0}</option>`).join('') + `</select>`;
const pbSeg = (b, k, tiers, short) => `<span class="fseg">${Object.keys(tiers).map(v => `<button class="chip" data-foeseg="${k}" data-v="${esc(v)}" ` +
  `aria-pressed="${b[k] === v}">${esc(short ? short(v) : v)}</button>`).join('')}</span>`;
const pbFlag = (b, k, label, tip = '', off = false) => `<button class="chip" data-buffflag="${k}" aria-pressed="${!!b[k]}" ${off ? 'disabled' : ''} title="${esc(tip)}">${esc(label)}</button>`;
const pbRow = (label, body) => `<div class="pbrow"><span class="pblbl">${esc(label)}</span><div class="pbctl">${body}</div></div>`;
const tierShort = v => v.replace(/^\S+\s?/, '') || 'I';

// A card's controls, by job, as buttons (the same buff keys as before): a click picks, again takes off.
// Protect / Shell sit with the WHM (with the RDM when there is no WHM), Haste with the RDM
const pbChip = (attrs, label, on, tip = '', badge = '') => `<button class="chip pbc" ${attrs} aria-pressed="${!!on}" title="${esc(tip || label)}">` +
  `${esc(label)}${badge ? `<i class="pbbadge">${esc(badge)}</i>` : ''}</button>`;
const pbChips = html => `<div class="pbchips">${html}</div>`;
const pbMini = (label, html) => `<div class="pbmini"><span class="pbminil">${esc(label)}</span>${html}</div>`;
const GEO_MODES = [['indi', 'Indi'], ['geo', 'Geo'], ['entrust', 'Entrust']];
const SONG_SHORT = v => v.replace(' March', '').replace(' Madrigal', ' Madr.').replace(' Etude', ' Ét.').replace('Aria of Passion', 'Aria');
// The buttons of what a job casts on the target (FOE_JA): its names, a pet's move without its "Pet:"
function pbFoeChips(job, b){
  const names = Object.keys(FOE_JA[job] || {});
  return names.length ? pbSec(t('pbOnTarget'), pbGrid(names.map(n => pbOpt(`data-foeja="${esc(n)}"`, n.includes(': ') ? n.split(': ')[1] : n,
    (b.foeJa || []).includes(n), pbHint(FOE_JA[job][n]), '', n)).join(''))) : '';
}
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
// the kind of a buff key (song2 -> song, roll1 -> roll)
const pbPickKind = key => key.replace(/\d+$/, '');
function pbPickBtn(b, key){
  const v = b[key];
  return `<button class="pbpick ${v ? 'set' : ''}" data-pbpick="${esc(key)}"><span>${esc(v || t('pbChoose'))}</span><i>▾</i></button>`;
}
function pbOpenPick(key){
  const kind = pbPickKind(key), P = PB_PICK[kind], b = buffState(), cur = b[key];
  if (!P) return;
  const item = v => `<button class="pbpi ${v === cur ? 'on' : ''}" data-pbchoose="${esc(key)}|${esc(v)}" data-q="${esc(v.toLowerCase())}">` +
    `<b>${esc(v)}</b><small>${esc((h => h && h.toLowerCase() !== v.toLowerCase() ? h : '')(P.hint(v)))}</small></button>`;
  const body = `<input class="pbpq" type="search" placeholder="${esc(t('pbSearch'))}" autocomplete="off">` +
    P.groups().map(([g, list]) => list.length ? `<section class="pbpg"><h4>${esc(g)}</h4><div class="pbpl">${list.map(item).join('')}</div></section>` : '').join('');
  showDialog('pbdlg', esc(P.title(key.match(/\d+$/) ? key.match(/\d+$/)[0] : '')), body,
    cur ? `<button class="btn ghost" data-pbchoose="${esc(key)}|">${esc(t('pbNone'))}</button>` : '');
  pbDlgSearch();
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

// A member's tab as a form: a line a setting (its name, a list or a switch, what it gives you), titled sections in two
// columns at most. Lists hold any number of choices on one line: more buffs later will not make it longer.
const pbSw = (attrs, on, tip = '') => `<button class="tgl pbsw" ${attrs} aria-pressed="${!!on}" title="${esc(tip)}"></button>`;
let PB_B = null;   // the party's totals while a tab is drawn (what each line gives)
const pbEff = src => PB_B ? pbGives(PB_B, src) : '';
const pbF = (label, control, eff = '') => `<div class="pbf"><span class="pbfl">${esc(label)}</span><div class="pbfc">${control}</div><div class="pbfe">${eff}</div></div>`;
const pbFSec = (title, rows) => rows ? `<section class="pbfsec"><h4>${esc(title)}</h4>${rows}</section>` : '';
const pbForm = (left, right = '') => `<div class="pbform ${right ? '' : 'one'}"><div>${left}</div>${right ? `<div>${right}</div>` : ''}</div>`;
const pbList = (b, key, values, ph, def = null) => pbSel(b, key, values, ph, def);
// a tier list (Protect I..V): its values, an empty "—" first
const pbTiers = (b, key, tiers) => pbSel(b, key, Object.keys(tiers), '—');
// a debuff on the target cast by this job (FOE_JA): a switch a name
function pbFoeRows(job, b){
  return Object.keys(FOE_JA[job] || {}).map(n => pbF(n.includes(': ') ? n.split(': ')[1] : n,
    pbSw(`data-foeja="${esc(n)}"`, (b.foeJa || []).includes(n), n), pbEff(v => v === n))).join('');
}
function pbBody(job, b, shown){
  PB_B = buffTotals();
  const whm = shown.includes('WHM'), rdm = shown.includes('RDM');
  if (job === 'GEO') {
    const geo = (key, label) => pbF(label, pbPickBtn(b, key), pbEff(v => v === ({indi: 'Indi-', geo: 'Geo-', entrust: 'Entrust Indi-'})[key] + b[key]));
    return pbForm(pbFSec(t('pbBubbles'), geo('indi', 'Indi') + geo('geo', 'Geo') + geo('entrust', 'Entrust') + pbF(t('pGear'), pbPlus(b, 'geoPlus', 'Geomancy', 10))),
      pbFSec(t('bJa'), pbF('Blaze of Glory', pbSw('data-buffflag="bog"', b.bog, t('bogTip')), `<span class="muted">Geo +50 %</span>`) +
        pbF('Ecliptic Attrition', pbSw('data-buffflag="ecliptic"', b.ecliptic, t('eclipticTip')), `<span class="muted">Geo +25 %</span>`) +
        pbF('Bolster', pbSw('data-buffflag="bolster"', b.bolster, t('bolsterTip')), `<span class="muted">Indi, Geo ×2</span>`)));
  }
  if (job === 'BRD') {
    const slots = songSlots(b);
    const songs = slots.map(i => pbF(`${t('bSong')} ${i + 1}`, pbPickBtn(b, 'song' + i), pbEff(v => v === b['song' + i]))).join('');
    const marcato = `<select class="buffsel ${b.marcato != null ? 'set' : ''}" data-pbmarcato><option value="">—</option>` +
      slots.map(i => `<option value="${i}" ${b.marcato != null && +b.marcato === i ? 'selected' : ''}>${esc(t('bSong'))} ${i + 1}</option>`).join('') + `</select>`;
    const aria = slots.some(i => b['song' + i] === 'Aria of Passion')
      ? pbF('Loughnashade', `<select class="buffsel set" data-buff="ariaStage">${Object.keys(ARIA_HORN).map(st => `<option ${(b.ariaStage || 'V') === st ? 'selected' : ''}>${st}</option>`).join('')}</select>`) : '';
    return pbForm(pbFSec(t('pbSongs'), songs),
      pbFSec(t('pbGear'), pbF(t('pGear'), pbPlus(b, 'songsPlus', 'Songs', 9)) + pbF('Soul Voice', pbSw('data-buffflag="soulVoice"', b.soulVoice, t('svTip')), `<span class="muted">${esc(t('pbSvHint'))}</span>`) +
        pbF('Clarion Call', pbSw('data-buffflag="clarion"', b.clarion, t('clarionTip')), `<span class="muted">${esc(t('pbClarionHint'))}</span>`) + pbF('Marcato', marcato) + aria) +
      pbFSec(t('pbOnTarget'), pbFoeRows('BRD', b)));
  }
  if (job === 'COR') {
    // the roll's list as wide as every list; its number, job bonus and Crooked Cards beside it
    const roll = i => pbF(`Roll ${i + 1}`, pbPickBtn(b, 'roll' + i),
      (b['roll' + i] ? `<span class="pbfx">${pbSel(b, 'roll' + i + 'n', ROMAN, '', 'XI')}${rollChips(b, i)}</span>` : '') + pbEff(v => b['roll' + i] && v.startsWith(b['roll' + i] + ' Roll')));
    return pbForm(pbFSec(t('pbRolls'), roll(0) + roll(1) + pbF(t('pGear'), pbPlus(b, 'rollsPlus', 'Rolls', 8))),
      pbFSec(t('pbOnTarget'), pbF('Light Shot', pbSw('data-buffflag="lightshot"', b.lightshot, t('lsTip')), pbEff(v => v === 'Light Shot')) + pbFoeRows('COR', b)));
  }
  const protect = pbF('Protect', pbTiers(b, 'protect', PROTECT), pbEff(v => v.startsWith(b.protect || '§'))) + pbF('Shell', pbTiers(b, 'shell', SHELL), pbEff(v => v === b.shell));
  if (job === 'WHM') return pbForm(pbFSec(t('pbBuffs'), protect + (rdm ? '' : pbF('Haste', pbSw('data-foeseg="haste" data-v="Haste"', b.haste === 'Haste'), pbEff(v => v === 'Haste'))) +
      pbF('Auspice', pbSw('data-buffflag="auspice"', b.auspice, t('auspiceTip')) + (b.auspice ? pbSel(b, 'auspiceFeet', Object.keys(AUSPICE_FEET), t('auspiceFeet')) : ''), pbEff(v => v === 'Auspice'))),
    pbFSec(t('pbOnTarget'), pbF('Dia', `<select class="buffsel ${['Dia', 'Dia II'].includes(b.dia) ? 'set' : ''}" data-buff="dia"><option value="">—</option>` +
      ['Dia', 'Dia II'].map(v => `<option ${b.dia === v ? 'selected' : ''}>${v}</option>`).join('') + `</select>`, pbEff(v => v === b.dia)) + pbFoeRows('WHM', b)));
  if (job === 'RDM') {
    const nm = isNmTarget(enemyKey(b.enemy)), sabX = nm ? (b.sabGloves ? 1.39 : 1.25) : (b.sabGloves ? 2.14 : 2);
    const list = (key, values) => `<select class="buffsel ${values.includes(b[key]) ? 'set' : ''}" data-buff="${key}"><option value="">—</option>` +
      values.map(v => `<option ${b[key] === v ? 'selected' : ''}>${v}</option>`).join('') + `</select>`;
    return pbForm(pbFSec(t('pbBuffs'), (whm ? '' : protect) + pbF('Haste', list('haste', ['Haste', 'Haste II']), pbEff(v => v === b.haste)) +
        pbF('Enspell I', pbSw('data-buffflag="enspell"', b.enspell, t('enspellTip')) + (b.enspell ? pbSel(b, 'enSkill', EN_SKILLS.map(String), t('enSkillPh'), '600') : ''), pbEff(v => v === 'Enspell I'))),
      pbFSec(t('pbOnTarget'), pbF('Dia · Bio', list('dia', ['Dia III', 'Bio III']), pbEff(v => v === b.dia)) +
        pbF('Distract', list('distract', Object.keys(DISTRACT)), pbEff(v => !!b.distract && v.startsWith(b.distract))) +
        pbF('Saboteur', pbSw('data-buffflag="saboteur"', b.saboteur, t('sabTip')) + (b.saboteur ? pbSw('data-buffflag="sabGloves"', b.sabGloves, 'Lethargy Gantherots +3') + '<span class="muted small">Lethargy +3</span>' : ''),
          b.saboteur ? `<span class="muted">×${sabX}</span>` : '')));
  }
  if (job === 'SCH') return pbForm(pbFSec('Storm', pbF('Storm', pbPickBtn(b, 'storm'), pbEff(v => v === b.storm))));
  // a job whose abilities reach you, and what it casts on the target: a switch each
  const list = pbJaJobs().get(job) || [];
  const mine = list.map(ja => pbF(ja.name.replace(' · party', ''), pbSw(`data-ja="${esc(ja.name)}"`, jaOn(b, ja.name), jaTip(ja)), pbEff(v => v === ja.name))).join('');
  const extra = (list.some(x => x.name === 'Warcry · party') && jaOn(b, 'Warcry · party') ? `<div class="pbfextra">${warcryHTML(b, true)}</div>` : '') +
    (list.some(x => x.name === 'Haste Samba') && jaOn(b, 'Haste Samba') ? `<div class="pbfextra">${sambaHTML(b)}</div>` : '');
  const foe = pbFoeRows(job, b);
  return mine && foe ? pbForm(pbFSec(t('pbBuffs'), mine) + extra, pbFSec(t('pbOnTarget'), foe)) : pbForm(pbFSec(mine ? t('pbBuffs') : t('pbOnTarget'), mine || foe) + extra);
}

// Your own tab, the same form: food, aftermath, your abilities (switches), your own Warcry's merits
function pbYouBody(b){
  PB_B = buffTotals();
  const sel = (key, values, ph, def) => pbSel(b, key, values, ph, def);
  const jas = jasOf().filter(j => j.as !== 'party');
  const ownWarcry = j => j.name === 'Warcry' && j.as === 'main';
  const rows = jas.map(j => pbF(j.name + (j.as === 'sub' ? ' /' + ((data() || {}).sub || '') : ''), pbSw(`data-ja="${esc(j.name)}"`, jaOn(b, j.name), jaTip(j)),
    pbEff(v => v === j.name))).join('');
  const half = Math.ceil(jas.length / 2);
  const left = pbFSec(t('pbYouBase'), pbF(t('bFood'), pbPickBtn(b, 'food'), pbEff(v => v === b.food)) +
    pbAmRow(sel)) + (jas.some(ownWarcry) && jaOn(b, 'Warcry') ? `<div class="pbfextra">${warcryHTML(b)}</div>` : '');
  return pbForm(left, pbFSec(t('bJa'), rows));
}

// What a source gives, each stat once: yours, then what comes off the target in red
function pbGives(B, src){
  const sum = {};
  for (const e of B._by) if (src(e.src) && typeof e.v === 'number') sum[e.k] = (sum[e.k] || 0) + e.v;
  const keys = Object.keys(sum);
  // a cut of your own (Berserk's Defense, Aggressor's Evasion) in red; a lower damage taken (Shell) is good
  const GOOD_LOW = ['shell', 'dt', 'pdt', 'mdt', 'bdt'];
  return keys.filter(k => !PB_FOE.includes(k)).map(k => `<span ${sum[k] < 0 && !GOOD_LOW.includes(k) ? 'class="pneg"' : ''}>${esc(fxShort(k, sum[k]))}</span>`)
    .concat(keys.filter(k => PB_FOE.includes(k)).map(k => `<span class="pneg">${esc(fxShort(k, sum[k]))}</span>`)).join('');
}

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
  const b = buffState(), shown = pbShown(b), left = PB_MAX - shown.length - 1;
  if (left <= 0) return;
  const item = hint => j => `<button class="pbpi" data-pbadd="${esc(j)}" data-q="${esc((j + ' ' + hint(j)).toLowerCase())}">` +
    `<b>${esc(j)}</b><small>${esc(hint(j))}</small></button>`;
  const body = `<input class="pbpq" type="search" placeholder="${esc(t('pbSearch'))}" autocomplete="off">` +
    pbAddGroups(shown).map(([g, l, hint]) => `<section class="pbpg"><h4>${esc(g)}</h4><div class="pbpl">${l.map(item(hint)).join('')}</div></section>`).join('');
  showDialog('pbdlg pbadddlg', esc(t('pbAddTitle', {n: left})), body, '');
  pbDlgSearch();
}
// the search on top of a picker window: hides the choices and the families that do not match
function pbDlgSearch(){
  const q = $('.pbdlg .pbpq');
  if (!q) return;
  q.focus();
  q.addEventListener('input', () => { const w = q.value.trim().toLowerCase();
    document.querySelectorAll('.pbdlg .pbpi').forEach(el => { el.hidden = !!w && !el.dataset.q.includes(w); });
    document.querySelectorAll('.pbdlg .pbpg').forEach(sec => { sec.hidden = !sec.querySelector('.pbpi:not([hidden])'); }); });
}
// Saving the party: a window of the page asks its name (the saved ones listed, a same name replaces it)
function pbOpenSave(){
  const names = Object.keys(((S.pbPresets || {})[S.char]) || {});
  const body = `<label class="pbsavel">${esc(t('pbSaveAsk'))}<input class="pbsavein" type="text" maxlength="40" autocomplete="off"></label>` +
    (names.length ? `<p class="muted small">${esc(t('pbSaveHave'))} ${names.map(esc).join(' · ')}</p>` : '');
  showDialog('pbdlg pbsavedlg', esc(t('pbSaveTitle')), body, `<button class="btn" data-pbsavego>${esc(t('pbSaveGo'))}</button>`);
  const inp = $('.pbsavein');
  if (inp) { inp.focus(); inp.addEventListener('keydown', e => { if (e.key === 'Enter') { e.preventDefault(); pbClick({pbsavego: '1'}); } }); }
}

function pbSavedBar(){
  const saved = ((S.pbPresets || {})[S.char]) || {}, names = Object.keys(saved);
  return `<div class="pbsaved"><span class="pblbl">${esc(t('pbSaved'))}</span>` +
    (names.length ? names.map(n => `<span class="pbpreset"><button class="chip" data-pbload="${esc(n)}">${esc(n)}</button>` +
      `<button class="pbx" data-pbforget="${esc(n)}" title="${esc(t('pbForget'))}">×</button></span>`).join('') : `<span class="muted small">${esc(t('pbNoSaved'))}</span>`) +
    `<button class="linkbtn" data-pbsave>${esc(t('pbSave'))}</button></div>`;
}

function pbResult(B){
  const s = S._curSet, T0 = targetInfo(s);
  const mine = Object.keys(B).filter(k => !k.startsWith('_') && !PB_FOE.includes(k) && typeof B[k] === 'number' && B[k]);
  return `<section class="box g-def"><header class="boxh"><h3>${esc(t('pbResult'))}</h3></header><div class="boxb">` +
    `<div class="pbgv big">${mine.map(k => `<span>${esc(fxShort(k, B[k]))}</span>`).join('') || `<span class="muted">${esc(t('pbNothing'))}</span>`}</div>` +
    `<p class="pbtgt"><b>${esc(T0.name)}</b> · <span class="nw">${esc(t('pbDefNow', {a: T0.def, b: T0.defAfter}))}</span> · <span class="nw">${esc(t('pbEvaNow', {a: T0.eva, b: T0.evaAfter}))}</span></p></div></section>`;
}

// What a member gives you, for its tab and its panel's foot
function pbGivesOf(job, b, B){
  if (job === 'you') {
    const ownJa = new Set(jasOf().filter(j => j.as !== 'party').map(j => j.name));
    return pbGives(withAftermath(B, shownMain()), v => v === b.food || ownJa.has(v) || /Aftermath/.test(v));
  }
  const def = PB_JOBS.find(j => j.job === job), names = new Set((pbJaJobs().get(job) || []).map(x => x.name).concat(Object.keys(FOE_JA[job] || {})));
  return pbGives(B, def ? (v => def.src(v) || names.has(v)) : v => names.has(v));
}

// The Combat tab of the new layout: the party as tabs (you first, 6 at most, each saying what it gives), the chosen
// member's buttons in one panel under them; the total and the target beside it
const PB_MAX = 6;
function renderCombatParty(d){
  const b = buffState(), n = buffCount();
  buffPanelHTML();   // its parts: your own abilities, the target picker, the other debuffs (S._bparts)
  const P = S._bparts || {}, shown = pbShown(b), B = buffTotals();
  const cur = S.pbTab === 'you' || shown.includes(S.pbTab) ? S.pbTab || 'you' : 'you';
  const head = `<header class="tabhead"><div><h2>${esc(t('ui2CombatTitle'))}</h2><p class="muted small">${esc(t('pbWhy'))}</p></div>` +
    `<div class="tabacts">${tierBarHTML()}<button class="btn ghost" data-buffendgame>${t('bEndgame')}</button>` +
    `<button class="btn ghost" data-buffreset ${n ? '' : 'disabled'}>${t('buffReset')}</button></div></header>`;
  const tab = (key, label, sub) => { const g = pbGivesOf(key, b, B);
    return `<div class="pbtab" role="tab" tabindex="0" data-pbtab="${esc(key)}" aria-selected="${cur === key}">` +
      `<span class="pbtabh">${emblem(key === 'you' ? S.job : key)}<b>${esc(label)}</b>${sub ? `<small>${esc(sub)}</small>` : ''}` +
      `${key === 'you' ? '' : `<button class="pbx" data-pbdel="${esc(key)}" title="${esc(t('pbRemove'))}" aria-label="${esc(t('pbRemove'))}">×</button>`}</span>` +
      `<span class="pbtabg">${g || `<span class="muted">${esc(t('pbNothing'))}</span>`}</span></div>`; };
  const tabs = `<div class="pbtabs" role="tablist">${tab('you', t('pbYou'), `${S.job}/${d.sub || '—'}`)}` +
    `${shown.map(j => tab(j, j, PB_JOBS.find(x => x.job === j) ? t('pbJob_' + j) : '')).join('')}` +
    (shown.length + 1 < PB_MAX ? `<button class="pbtab pbtabadd" data-pbaddopen><b>+ ${esc(t('pbAdd'))}</b><small>${esc(t('pbAddLeft', {n: PB_MAX - shown.length - 1}))}</small></button>` : '') + `</div>`;
  const full = shown.length + 1 >= PB_MAX;
  const bar = `<div class="pbbar"><b>${esc(t('pbTitle'))}</b><span class="muted small">${shown.length + 1} / ${PB_MAX}</span>${pbSavedBar()}</div>`;
  const body = cur === 'you' ? pbYouBody(b) : pbBody(cur, b, shown);
  const panel = `<section class="pbpanel"><div class="pbbody ${cur === 'you' ? 'pbyou' : ''}">${body}</div></section>`;
  const side = `<aside class="pbside">${pbResult(B)}${box('g-off', t('pbTarget'), P.tgt || '', `<span class="meta">${esc(enemyKey(b.enemy))}</span>`)}</aside>`;
  const other = P.foe ? `<details class="lgfold pbother" data-pbother ${S._pbOtherOpen ? 'open' : ''}><summary>${esc(t('pbOther'))} ${P.foe.total || ''}</summary><div class="pbotherb">${P.foe.body}</div></details>` : '';
  return `<div class="ui2tab combattab">${head}${bar}<div class="pblayout"><div class="pbmain">${tabs}${panel}</div>${side}</div>${other}</div>`;
}

// The party keys a saved party holds (yours and the target's stay out)
function pbKeys(){
  const keys = new Set(['pbMembers', 'pbGone', 'pja', 'foeJa', 'off']);
  for (const j of PB_JOBS) for (const k of j.keys) keys.add(k);
  return [...keys];
}
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
  } else if ('pbsave' in d) { pbOpenSave(); return;
  } else if ('pbsavego' in d) {
    const inp = $('.pbsavein'), name = ((inp && inp.value) || '').trim();
    if (!name) { if (inp) inp.focus(); return; }
    closeOverlay();
    S.toast = t('pbSavedAs', {n: name});
    const all = S.pbPresets = S.pbPresets || {}, mine = all[S.char] = all[S.char] || {}, keep = {};
    for (const k of pbKeys()) if (b[k] != null) keep[k] = JSON.parse(JSON.stringify(b[k]));
    mine[name] = keep;
  } else if (d.pbload) {
    const p = (((S.pbPresets || {})[S.char]) || {})[d.pbload];
    if (!p) return;
    for (const k of pbKeys()) { if (k in p) b[k] = JSON.parse(JSON.stringify(p[k])); else delete b[k]; }
    S.toast = t('pbLoaded', {n: d.pbload});
  } else if (d.pbforget) {
    const mine = ((S.pbPresets || {})[S.char]) || {};
    delete mine[d.pbforget];
  }
  S._globals = null; save(); render();
}
