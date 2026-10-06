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
  pbBuffs: 'Sur toi', pbOnTarget: 'Sur la cible', pbJob_GEO: 'Bulles', pbJob_BRD: 'Chansons', pbJob_COR: 'Rolls', pbJob_WHM: 'Protect, Shell, Haste', pbJob_RDM: 'Haste II, Dia, Distract', pbJob_SCH: 'Storm',
});
Object.assign(T.en, {
  pbTitle: 'My party', pbWhy: 'Add your party members: each comes with its usual buffs. What is ticked counts; one click to change.',
  pbYou: 'You', pbAdd: 'Add', pbAddWhy: 'A party member', pbRemove: 'Remove this member', pbGives: 'Gives you', pbNothing: 'nothing yet',
  pbResult: 'What the party gives you', pbTarget: 'Target', pbSaved: 'My parties', pbSave: '+ Save this party', pbSaveAsk: 'Party name (Sortie, Odyssey, Trusts XP…)',
  pbForget: 'Forget this party', pbLoaded: 'Party “{n}” back.', pbNoSaved: 'none: build your party, then save it',
  pbOther: 'Other debuffs on the target (BLM, THF, NIN, BLU, BST…)', pbDefNow: 'Defense {a} → {b}', pbEvaNow: 'Evasion {a} → {b}',
  pbBuffs: 'On you', pbOnTarget: 'On the target', pbJob_GEO: 'Bubbles', pbJob_BRD: 'Songs', pbJob_COR: 'Rolls', pbJob_WHM: 'Protect, Shell, Haste', pbJob_RDM: 'Haste II, Dia, Distract', pbJob_SCH: 'Storm',
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
const pbMembers = b => b.pbMembers || [];
// a member removed stays out even while a buff it shares is still on (Protect V with a RDM in the party)
const pbGone = b => b.pbGone || [];
function pbShown(b){
  const ja = pbJaJobs(), out = j => pbGone(b).includes(j) && !pbMembers(b).includes(j);
  const shown = PB_JOBS.filter(j => !out(j.job) && (j.has(b) || pbMembers(b).includes(j.job))).map(j => j.job);
  for (const [job, list] of ja) if (!out(job) && (list.some(x => jaOn(b, x.name)) || pbMembers(b).includes(job))) shown.push(job);
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
function pbBody(job, b, shown){
  const whm = shown.includes('WHM'), rdm = shown.includes('RDM');
  const tier = (k, tiers) => Object.keys(tiers).map(v => pbChip(`data-foeseg="${k}" data-v="${esc(v)}"`, tierShort(v), b[k] === v, v)).join('');
  if (job === 'GEO') {
    const mode = S._pbGeoMode || 'indi';
    const badge = v => GEO_MODES.filter(([k]) => b[k] === v).map(([, l]) => l[0]).join('');
    const modes = GEO_MODES.map(([k, l]) => `<button class="chip pbmode" data-pbgeomode="${k}" aria-pressed="${mode === k}">${esc(l)}${b[k] ? ` · ${esc(b[k])}` : ''}</button>`).join('');
    const list = Object.keys(BUBBLES).concat(Object.keys(GEO_DEBUFFS));
    return pbChips(modes) + pbChips(list.map(v => pbChip(`data-pbset="${mode}|${esc(v)}"`, v, b[mode] === v, `${GEO_MODES.find(x => x[0] === mode)[1]}-${v}`, badge(v))).join('')) +
      pbChips(pbChip('data-buffflag="bog"', 'Blaze of Glory', b.bog, t('bogTip')) + pbChip('data-buffflag="ecliptic"', 'Ecliptic', b.ecliptic, t('eclipticTip')) +
        pbChip('data-buffflag="bolster"', 'Bolster', b.bolster, t('bolsterTip')) + pbPlus(b, 'geoPlus', 'Geomancy', 10));
  }
  if (job === 'BRD') {
    const slots = songSlots(b), at = v => slots.findIndex(i => b['song' + i] === v);
    return pbChips(Object.keys(SONGS).map(v => pbChip(`data-pbsong="${esc(v)}"`, SONG_SHORT(v), at(v) >= 0, v, at(v) >= 0 ? String(at(v) + 1) : '')).join('')) +
      pbChips(pbChip('data-buffflag="soulVoice"', 'Soul Voice', b.soulVoice, t('svTip')) + pbChip('data-buffflag="clarion"', 'Clarion', b.clarion, t('clarionTip')) +
        pbPlus(b, 'songsPlus', 'Songs', 9));
  }
  if (job === 'COR') {
    const at = v => [0, 1].findIndex(i => b['roll' + i] === v);
    const picked = [0, 1].filter(i => b['roll' + i]).map(i => `<span class="pbroll"><b>${esc(b['roll' + i])}</b>${pbSel(b, 'roll' + i + 'n', ROMAN, '', 'XI')}${rollChips(b, i)}</span>`).join('');
    return pbChips(Object.keys(ROLLS).map(v => pbChip(`data-pbroll="${esc(v)}"`, v, at(v) >= 0, v + ' Roll', at(v) >= 0 ? String(at(v) + 1) : '')).join('')) +
      (picked ? `<div class="pbrolls">${picked}</div>` : '') +
      pbChips(pbChip('data-buffflag="lightshot"', 'Light Shot', b.lightshot, t('lsTip')) + pbPlus(b, 'rollsPlus', 'Rolls', 8));
  }
  const protect = pbMini('Protect', pbChips(tier('protect', PROTECT))) + pbMini('Shell', pbChips(tier('shell', SHELL)));
  if (job === 'WHM') return protect + pbChips((rdm ? '' : pbChip('data-foeseg="haste" data-v="Haste"', 'Haste', b.haste === 'Haste')) +
    pbChip('data-buffflag="auspice"', 'Auspice', b.auspice, t('auspiceTip')) + pbChip('data-foeseg="dia" data-v="Dia II"', 'Dia II', b.dia === 'Dia II'));
  if (job === 'RDM') {
    const nm = isNmTarget(enemyKey(b.enemy)), sabX = nm ? (b.sabGloves ? 1.39 : 1.25) : (b.sabGloves ? 2.14 : 2);
    return (whm ? '' : protect) +
      pbMini(t('pbBuffs'), pbChips(pbChip('data-foeseg="haste" data-v="Haste II"', 'Haste II', b.haste === 'Haste II') + pbChip('data-buffflag="enspell"', 'Enspell I', b.enspell, t('enspellTip')))) +
      pbMini(t('pbOnTarget'), pbChips(pbChip('data-foeseg="dia" data-v="Dia III"', 'Dia III', b.dia === 'Dia III') + pbChip('data-foeseg="dia" data-v="Bio III"', 'Bio III', b.dia === 'Bio III') +
        Object.keys(DISTRACT).map(v => pbChip(`data-foeseg="distract" data-v="${esc(v)}"`, v.replace('Distract', 'Distr.'), b.distract === v, v)).join('') +
        pbChip('data-buffflag="saboteur"', `Saboteur ×${sabX}`, b.saboteur, t('sabTip'))));
  }
  if (job === 'SCH') return pbChips(Object.keys(STORMS).map(v => pbChip(`data-pbset="storm|${esc(v)}"`, v.replace('storm II', ''), b.storm === v, v)).join(''));
  // a job whose abilities reach you
  const list = pbJaJobs().get(job) || [];
  return pbChips(list.map(ja => `<button class="chip pbc ja-party" data-ja="${esc(ja.name)}" aria-pressed="${jaOn(b, ja.name)}" title="${esc(jaTip(ja))}">` +
    `${esc(ja.name.replace(' · party', ''))}</button>`).join('')) +
    (list.some(x => x.name === 'Warcry · party') && jaOn(b, 'Warcry · party') ? warcryHTML(b, true) : '') +
    (list.some(x => x.name === 'Haste Samba') && jaOn(b, 'Haste Samba') ? sambaHTML(b) : '');
}

// What a source gives, each stat once: yours, then what comes off the target in red
function pbGives(B, src){
  const sum = {};
  for (const e of B._by) if (src(e.src) && typeof e.v === 'number') sum[e.k] = (sum[e.k] || 0) + e.v;
  const keys = Object.keys(sum);
  return keys.filter(k => !PB_FOE.includes(k)).map(k => `<span>${esc(fxShort(k, sum[k]))}</span>`)
    .concat(keys.filter(k => PB_FOE.includes(k)).map(k => `<span class="pneg">${esc(fxShort(k, sum[k]))}</span>`)).join('');
}

// The members not in the party yet, one button each, on a line over the cards
function pbAddBar(shown){
  const all = PB_JOBS.map(j => j.job).concat([...pbJaJobs().keys()]).filter(j => !shown.includes(j));
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

function pbCard(job, b, shown, B){
  const def = PB_JOBS.find(j => j.job === job), names = new Set((pbJaJobs().get(job) || []).map(x => x.name));
  const gives = pbGives(B, def ? def.src : v => names.has(v));
  return `<section class="pbcard"><header><span class="pbjob">${emblem(job)}<b>${esc(job)}</b></span>` +
    `<button class="pbx" data-pbdel="${job}" title="${esc(t('pbRemove'))}" aria-label="${esc(t('pbRemove'))}">×</button></header>` +
    `<div class="pbbody">${pbBody(job, b, shown)}</div><footer><div class="pbgv">${gives || `<span class="muted">${esc(t('pbNothing'))}</span>`}</div></footer></section>`;
}

// The Combat tab of the new layout: the party as the game's party window (6 at most, you first), every choice a
// button on its member's card; the total and the target beside it
const PB_MAX = 6;
function renderCombatParty(d){
  const b = buffState(), n = buffCount();
  buffPanelHTML();   // its parts: your own abilities, the target picker, the other debuffs (S._bparts)
  const P = S._bparts || {}, shown = pbShown(b), B = buffTotals();
  const head = `<header class="tabhead"><div><h2>${esc(t('ui2CombatTitle'))}</h2><p class="muted small">${esc(t('pbWhy'))}</p></div>` +
    `<div class="tabacts">${tierBarHTML()}<button class="btn ghost" data-buffendgame>${t('bEndgame')}</button>` +
    `<button class="btn ghost" data-buffreset ${n ? '' : 'disabled'}>${t('buffReset')}</button></div></header>`;
  const you = `<section class="pbcard pbyou"><header><span class="pbjob">${emblem(S.job)}<b>${esc(t('pbYou'))}</b><small>${esc(S.job)}/${esc(d.sub || '—')}</small></span></header>` +
    `<div class="pbbody">${P.own || ''}</div></section>`;
  const full = shown.length + 1 >= PB_MAX;
  const bar = `<div class="pbbar"><b>${esc(t('pbTitle'))}</b><span class="muted small">${shown.length + 1} / ${PB_MAX}</span>${full ? '' : pbAddBar(shown)}${pbSavedBar()}</div>`;
  const cards = `<div class="pbgrid">${you}${shown.map(j => pbCard(j, b, shown, B)).join('')}</div>`;
  const side = `<aside class="pbside">${pbResult(B)}${box('g-off', t('pbTarget'), P.tgt || '', `<span class="meta">${esc(enemyKey(b.enemy))}</span>`)}</aside>`;
  const other = P.foe ? `<details class="lgfold pbother"><summary>${esc(t('pbOther'))} ${P.foe.total || ''}</summary><div class="pbotherb">${P.foe.body}</div></details>` : '';
  return `<div class="ui2tab combattab">${head}${bar}<div class="pblayout"><div>${cards}</div>${side}</div>${other}</div>`;
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
    const j = d.pbadd, def = PB_JOBS.find(x => x.job === j);
    b.pbMembers = [...new Set([...pbMembers(b), j])];
    b.pbGone = pbGone(b).filter(x => x !== j);
    if (def) for (const [k, v] of Object.entries(def.def)) if (b[k] == null || b[k] === '') b[k] = v;
    if (b.off) delete b.off[j];
  } else if (d.pbdel) {
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
