// GearSwap Atelier · party_builder.js: the new layout's Combat tab as the game's party list (2026-10-06). One card a
// member: you, then each support job in the party (GEO, BRD, COR, WHM, RDM, SCH, and the jobs whose abilities reach
// you: WAR, DNC, SMN...). A card added comes filled with that job's usual buffs; what it casts on the target (Frailty,
// Dia, Distract) is on its card. Under the cards, the target and what the whole party gives you. Saved parties come back
// in one click. The values are the same buff state as before (buffState(): every page figure reads it), only the way
// of choosing changes; the old window stays (the Old layout).
// (loaded by atelier/index.html after layout2.js: see the list there)

Object.assign(T.fr, {
  pbTitle: 'Mon groupe', pbWhy: 'Ajoute les membres de ton groupe : chacun arrive avec ses buffs habituels. Ce qui est coché compte ; un clic pour changer.',
  pbYou: 'Toi', pbAdd: 'Ajouter', pbAddWhy: 'Un membre du groupe', pbRemove: 'Retirer ce membre', pbGives: 'Te donne', pbNothing: 'rien pour l’instant',
  pbResult: 'Ce que le groupe te donne', pbTarget: 'Cible', pbSaved: 'Mes groupes', pbSave: '+ Enregistrer ce groupe', pbSaveAsk: 'Nom du groupe (Sortie, Odyssey, Trusts XP…)',
  pbForget: 'Oublier ce groupe', pbLoaded: 'Groupe « {n} » remis.', pbNoSaved: 'aucun : compose ton groupe puis enregistre-le',
  pbOther: 'Autres debuffs sur la cible (BLM, THF, NIN, BLU, BST…)', pbDefNow: 'Défense {a} → {b}', pbEvaNow: 'Évasion {a} → {b}',
  pbGeoHelp: 'Une ligne par bulle : clique dans la colonne Indi, Geo ou Entrust ; un autre clic la retire.', pbBuffs: 'Sur toi', pbOnTarget: 'Sur la cible', pbOffense: 'Combat', pbAttrs: 'Attributs', pbGear: 'Équipement et capacités', pbOther2: 'Autres',
  pbSongs: 'Chansons', pbSongsNote: '{n} / {m} : un clic place la chanson, un autre la retire', pbRolls: 'Rolls', pbRollsNote: '{n} / 2', pbRollValues: 'Valeur de chaque roll',
  pbIndiNote: 'sur le GEO et le groupe proche', pbGeoNote: 'la luopan, sur la cible ou le groupe', pbEntrustNote: 'une Indi donnée à un allié',
  pbSvHint: 'chansons ×2', pbClarionHint: '+1 chanson', pbLsHint: 'renforce Dia', pbEnHint: 'dégâts en plus', pbDefDown: 'Déf cible −', pbAtkDown: 'Att cible −', pbEvaDown: 'Éva cible −', pbJob_GEO: 'Bulles', pbJob_BRD: 'Chansons', pbJob_COR: 'Rolls', pbJob_WHM: 'Protect, Shell, Haste', pbJob_RDM: 'Haste II, Dia, Distract', pbJob_SCH: 'Storm',
});
Object.assign(T.en, {
  pbTitle: 'My party', pbWhy: 'Add your party members: each comes with its usual buffs. What is ticked counts; one click to change.',
  pbYou: 'You', pbAdd: 'Add', pbAddWhy: 'A party member', pbRemove: 'Remove this member', pbGives: 'Gives you', pbNothing: 'nothing yet',
  pbResult: 'What the party gives you', pbTarget: 'Target', pbSaved: 'My parties', pbSave: '+ Save this party', pbSaveAsk: 'Party name (Sortie, Odyssey, Trusts XP…)',
  pbForget: 'Forget this party', pbLoaded: 'Party “{n}” back.', pbNoSaved: 'none: build your party, then save it',
  pbOther: 'Other debuffs on the target (BLM, THF, NIN, BLU, BST…)', pbDefNow: 'Defense {a} → {b}', pbEvaNow: 'Evasion {a} → {b}',
  pbGeoHelp: 'A row a bubble: click in its Indi, Geo or Entrust column; again to take it off.', pbBuffs: 'On you', pbOnTarget: 'On the target', pbOffense: 'Combat', pbAttrs: 'Attributes', pbGear: 'Gear and abilities', pbOther2: 'Others',
  pbSongs: 'Songs', pbSongsNote: '{n} / {m}: a click places the song, another takes it off', pbRolls: 'Rolls', pbRollsNote: '{n} / 2', pbRollValues: 'Each roll’s number',
  pbIndiNote: 'on the GEO and the party near', pbGeoNote: 'the luopan, on the target or the party', pbEntrustNote: 'an Indi given to an ally',
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
function pbBody(job, b, shown){
  const inner = pbBodyOwn(job, b, shown), foe = ['WHM', 'RDM', 'BRD', 'COR', 'GEO'].includes(job) ? '' : pbFoeChips(job, b);
  return inner + foe;
}
// What a choice gives, as the small line under its name: the stats of its table (a song, a roll, a bubble)
const pbStat = k => ((FX_SHORT[k] || FX_LABEL[k] || [k.toUpperCase(), k.toUpperCase()])[S.lang === 'fr' ? 0 : 1]);
// only the stats (a table's own fields, lim, shot, elem..., are left out)
const PB_ATTRS = ['str', 'dex', 'vit', 'agi', 'int', 'mnd', 'chr'];
const pbHint = def => [...new Set(Object.keys(def || {}).filter(k => FX_SHORT[k] || FX_LABEL[k] || PB_ATTRS.includes(k)).map(pbStat))].join(' · ');
// A button with its effect under its name; a badge for its place (a song's slot, a roll's number)
const pbOpt = (attrs, label, on, hint = '', badge = '', tip = '') => `<button class="chip pbc pbopt" ${attrs} aria-pressed="${!!on}" title="${esc(tip || label)}">` +
  `<span class="pbon">${esc(label)}</span>${hint && hint.toLowerCase() !== String(label).toLowerCase() && !String(label).toUpperCase().startsWith(hint) ? `<span class="pbhint">${esc(hint)}</span>` : ''}${badge ? `<i class="pbbadge">${esc(badge)}</i>` : ''}</button>`;
const pbGrid = html => `<div class="pbchips pbopts">${html}</div>`;
const pbSec = (title, html, note = '') => `<section class="pbsec"><h4>${esc(title)}${note ? `<small>${esc(note)}</small>` : ''}</h4>${html}</section>`;
const pbCols = (left, right) => `<div class="pbcols"><div>${left}</div><div>${right}</div></div>`;
const pbGroup = (label, html) => `<div class="pbgrp"><span class="pbgrpl">${esc(label)}</span>${html}</div>`;
const SONG_GROUPS = [['March', /March/], ['Minuet', /Minuet/], ['Madrigal', /Madrigal/], ['Aria', /Aria/], ['Etude', /Etude/]];
const BUBBLE_GROUPS = [[() => t('pbOffense'), ['Fury', 'Haste', 'Precision', 'Acumen', 'Focus']], [() => t('pbAttrs'), ['STR', 'DEX', 'VIT', 'AGI', 'INT', 'MND', 'CHR']],
  [() => t('pbOnTarget'), ['Frailty', 'Torpor', 'Malaise', 'Languor']]];
function pbBodyOwn(job, b, shown){
  const whm = shown.includes('WHM'), rdm = shown.includes('RDM');
  const tier = (k, tiers) => `<div class="pbchips pbtier">${Object.keys(tiers).map(v => pbChip(`data-foeseg="${k}" data-v="${esc(v)}"`, tierShort(v), b[k] === v, v)).join('')}</div>`;
  if (job === 'GEO') {
    const cell = (key, v) => `<td><button class="pbdot" data-pbset="${key}|${esc(v)}" aria-pressed="${b[key] === v}" title="${esc(GEO_MODES.find(x => x[0] === key)[1] + '-' + v)}"></button></td>`;
    // the same widths in both tables (a name column, three place columns of one size): the dots line up
    const table = groups => `<table class="pbgeo"><colgroup><col><col class="pbgeoc"><col class="pbgeoc"><col class="pbgeoc"></colgroup><thead><tr><th></th>${GEO_MODES.map(([, l]) => `<th>${l}</th>`).join('')}</tr></thead><tbody>` +
      groups.map(([g, list]) => `<tr class="pbgeog"><td colspan="4">${esc(g())}</td></tr>` + list.map(v => { const h = pbHint(BUBBLES[v] || GEO_DEBUFFS[v]);
        return `<tr><th><b>${esc(v)}</b>${h && h !== v ? `<small>${esc(h)}</small>` : ''}</th>${GEO_MODES.map(([k]) => cell(k, v)).join('')}</tr>`; }).join('')).join('') + `</tbody></table>`;
    const extras = pbSec(t('pbGear'), pbGrid(pbOpt('data-buffflag="bog"', 'Blaze of Glory', b.bog, 'Geo +50 %', '', t('bogTip')) +
      pbOpt('data-buffflag="ecliptic"', 'Ecliptic', b.ecliptic, 'Geo +25 %', '', t('eclipticTip')) + pbOpt('data-buffflag="bolster"', 'Bolster', b.bolster, 'Indi, Geo ×2', '', t('bolsterTip'))) +
      pbGroup(t('pGear'), pbPlus(b, 'geoPlus', 'Geomancy', 10))) + `<p class="pbnote">${esc(t('pbGeoHelp'))}</p>`;
    return `<div class="pbcols pb3"><div>${table([BUBBLE_GROUPS[0], BUBBLE_GROUPS[2]])}</div><div>${table([BUBBLE_GROUPS[1]])}</div><div>${extras}</div></div>`;
  }
  if (job === 'BRD') {
    const slots = songSlots(b), at = v => slots.findIndex(i => b['song' + i] === v), songs = Object.keys(SONGS);
    const used = slots.filter(i => b['song' + i]).length;
    const groups = SONG_GROUPS.map(([g, re]) => pbGroup(g, pbGrid(songs.filter(v => re.test(v)).map(v =>
      pbOpt(`data-pbsong="${esc(v)}"`, SONG_SHORT(v), at(v) >= 0, pbHint(SONGS[v]), at(v) >= 0 ? String(at(v) + 1) : '', v)).join('')))).join('');
    return pbCols(pbSec(t('pbSongs'), groups, t('pbSongsNote', {n: used, m: slots.length})),
      pbSec(t('pbGear'), pbGroup(t('pGear'), pbPlus(b, 'songsPlus', 'Songs', 9)) +
        pbGroup(t('bJa'), pbGrid(pbOpt('data-buffflag="soulVoice"', 'Soul Voice', b.soulVoice, t('pbSvHint'), '', t('svTip')) +
          pbOpt('data-buffflag="clarion"', 'Clarion Call', b.clarion, t('pbClarionHint'), '', t('clarionTip')))) +
        pbGroup('Marcato', `<div class="pbchips pbtier">${slots.map(i => pbChip(`data-marcato="${i}"`, String(i + 1), b.marcato != null && !b.soulVoice && +b.marcato === i, t('marcatoOn', {n: i + 1}))).join('')}</div>`) +
        (slots.some(i => b['song' + i] === 'Aria of Passion') ? pbGroup('Loughnashade', `<div class="pbchips pbtier">${Object.keys(ARIA_HORN).map(st =>
          pbChip(`data-foeseg="ariaStage" data-v="${st}"`, st, (b.ariaStage || 'V') === st, t('ariaTip', {n: ARIA_HORN[st]}))).join('')}</div>`) : '')) + pbFoeChips(job, b));
  }
  if (job === 'COR') {
    const at = v => [0, 1].findIndex(i => b['roll' + i] === v);
    const picked = [0, 1].filter(i => b['roll' + i]).map(i => pbGroup(b['roll' + i], `<div class="pbrollctl">${pbSel(b, 'roll' + i + 'n', ROMAN, '', 'XI')}${rollChips(b, i)}</div>`)).join('');
    return pbCols(pbSec(t('pbRolls'), pbGrid(Object.keys(ROLLS).map(v => pbOpt(`data-pbroll="${esc(v)}"`, v, at(v) >= 0, pbHint(ROLLS[v]), at(v) >= 0 ? String(at(v) + 1) : '', v + ' Roll')).join('')),
      t('pbRollsNote', {n: [0, 1].filter(i => b['roll' + i]).length})) +
      pbFoeChips(job, b),
      (picked ? pbSec(t('pbRollValues'), picked) : '') +
      pbSec(t('pbGear'), pbGroup(t('pGear'), pbPlus(b, 'rollsPlus', 'Rolls', 8)) + pbGroup('Light Shot', pbGrid(pbOpt('data-buffflag="lightshot"', 'Light Shot', b.lightshot, t('pbLsHint'), '', t('lsTip'))))));
  }
  const protect = pbGroup('Protect', tier('protect', PROTECT)) + pbGroup('Shell', tier('shell', SHELL));
  if (job === 'WHM') return pbCols(pbSec(t('pbBuffs'), protect + pbGroup(t('pbOther2'), pbGrid((rdm ? '' : pbOpt('data-foeseg="haste" data-v="Haste"', 'Haste', b.haste === 'Haste', 'Haste')) +
    pbOpt('data-buffflag="auspice"', 'Auspice', b.auspice, 'Subtle Blow', '', t('auspiceTip'))))) +
    pbSec(t('pbOnTarget'), pbGrid(pbOpt('data-foeseg="dia" data-v="Dia II"', 'Dia II', b.dia === 'Dia II', t('pbDefDown')))));
  if (job === 'RDM') {
    const nm = isNmTarget(enemyKey(b.enemy)), sabX = nm ? (b.sabGloves ? 1.39 : 1.25) : (b.sabGloves ? 2.14 : 2);
    return pbCols(pbSec(t('pbBuffs'), (whm ? '' : protect) + pbGroup(t('pbOther2'), pbGrid(pbOpt('data-foeseg="haste" data-v="Haste II"', 'Haste II', b.haste === 'Haste II', 'Haste') +
      pbOpt('data-buffflag="enspell"', 'Enspell I', b.enspell, t('pbEnHint'), '', t('enspellTip'))))),
      pbSec(t('pbOnTarget'), pbGroup('Dia · Bio', pbGrid(pbOpt('data-foeseg="dia" data-v="Dia III"', 'Dia III', b.dia === 'Dia III', t('pbDefDown')) +
        pbOpt('data-foeseg="dia" data-v="Bio III"', 'Bio III', b.dia === 'Bio III', t('pbAtkDown')))) +
        pbGroup('Distract', pbGrid(Object.keys(DISTRACT).map(v => pbOpt(`data-foeseg="distract" data-v="${esc(v)}"`, v, b.distract === v, t('pbEvaDown'))).join('') +
          pbOpt('data-buffflag="saboteur"', 'Saboteur', b.saboteur, `×${sabX}`, '', t('sabTip'))))));
  }
  if (job === 'SCH') return pbSec('Storm', pbGrid(Object.keys(STORMS).map(v => pbOpt(`data-pbset="storm|${esc(v)}"`, v.replace(' II', ''), b.storm === v, pbHint(STORMS[v]), '', v)).join('')));
  // a job whose abilities reach you (none: its tab is what it casts on the target, added by pbBody)
  const list = pbJaJobs().get(job) || [];
  if (!list.length) return '';
  return pbSec(t('pbBuffs'), pbGrid(list.map(ja => `<button class="chip pbc pbopt ja-party" data-ja="${esc(ja.name)}" aria-pressed="${jaOn(b, ja.name)}" title="${esc(jaTip(ja))}">` +
    `<span class="pbon">${esc(ja.name.replace(' · party', ''))}</span></button>`).join('')) +
    (list.some(x => x.name === 'Warcry · party') && jaOn(b, 'Warcry · party') ? warcryHTML(b, true) : '') +
    (list.some(x => x.name === 'Haste Samba') && jaOn(b, 'Haste Samba') ? sambaHTML(b) : ''));
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
function pbAddBar(shown){
  const all = [...new Set(PB_JOBS.map(j => j.job).concat([...pbJaJobs().keys()], pbFoeJobs()))].filter(j => !shown.includes(j));
  if (!all.length) return '';
  return `<div class="pbaddbar"><span class="pblbl">${esc(t('pbAddWhy'))}</span>` +
    all.map(j => `<button class="pbaddbtn" data-pbadd="${j}" title="${esc(t('pbAddWhy'))}">${emblem(j)}<span>+ ${esc(j)}</span></button>`).join('') + `</div>`;
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
    `<p class="pbtgt"><b>${esc(T0.name)}</b> · ${esc(t('pbDefNow', {a: T0.def, b: T0.defAfter}))} · ${esc(t('pbEvaNow', {a: T0.eva, b: T0.evaAfter}))}</p></div></section>`;
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
  const cur = S._pbTab === 'you' || shown.includes(S._pbTab) ? S._pbTab || 'you' : 'you';
  const head = `<header class="tabhead"><div><h2>${esc(t('ui2CombatTitle'))}</h2><p class="muted small">${esc(t('pbWhy'))}</p></div>` +
    `<div class="tabacts">${tierBarHTML()}<button class="btn ghost" data-buffendgame>${t('bEndgame')}</button>` +
    `<button class="btn ghost" data-buffreset ${n ? '' : 'disabled'}>${t('buffReset')}</button></div></header>`;
  const tab = (key, label, sub) => { const g = pbGivesOf(key, b, B);
    return `<div class="pbtab" role="tab" tabindex="0" data-pbtab="${esc(key)}" aria-selected="${cur === key}">` +
      `<span class="pbtabh">${emblem(key === 'you' ? S.job : key)}<b>${esc(label)}</b>${sub ? `<small>${esc(sub)}</small>` : ''}` +
      `${key === 'you' ? '' : `<button class="pbx" data-pbdel="${esc(key)}" title="${esc(t('pbRemove'))}" aria-label="${esc(t('pbRemove'))}">×</button>`}</span>` +
      `<span class="pbtabg">${g || `<span class="muted">${esc(t('pbNothing'))}</span>`}</span></div>`; };
  const tabs = `<div class="pbtabs" role="tablist">${tab('you', t('pbYou'), `${S.job}/${d.sub || '—'}`)}` +
    `${shown.map(j => tab(j, j, PB_JOBS.find(x => x.job === j) ? t('pbJob_' + j) : '')).join('')}</div>`;
  const full = shown.length + 1 >= PB_MAX;
  const bar = `<div class="pbbar"><b>${esc(t('pbTitle'))}</b><span class="muted small">${shown.length + 1} / ${PB_MAX}</span>${full ? '' : pbAddBar(shown)}${pbSavedBar()}</div>`;
  const body = cur === 'you' ? (P.own || '') : pbBody(cur, b, shown);
  const panel = `<section class="pbpanel"><div class="pbbody ${cur === 'you' ? 'pbyou' : ''}">${body}</div></section>`;
  const side = `<aside class="pbside">${pbResult(B)}${box('g-off', t('pbTarget'), P.tgt || '', `<span class="meta">${esc(enemyKey(b.enemy))}</span>`)}</aside>`;
  const other = P.foe ? `<details class="lgfold pbother"><summary>${esc(t('pbOther'))} ${P.foe.total || ''}</summary><div class="pbotherb">${P.foe.body}</div></details>` : '';
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
  if (d.pbtab) { S._pbTab = d.pbtab; render(); return; }
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
  else if (d.pbadd) {
    if (pbShown(b).length + 1 >= PB_MAX) return;
    S._pbTab = d.pbadd;
    const j = d.pbadd, def = PB_JOBS.find(x => x.job === j);
    b.pbMembers = [...new Set([...pbMembers(b), j])];
    b.pbGone = pbGone(b).filter(x => x !== j);
    if (def) for (const [k, v] of Object.entries(def.def)) if (b[k] == null || b[k] === '') b[k] = v;
    if (b.off) delete b.off[j];
  } else if (d.pbdel) {
    S._pbTab = 'you';
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
  } else if ('pbsave' in d) {
    const name = (prompt(t('pbSaveAsk')) || '').trim();
    if (!name) return;
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
