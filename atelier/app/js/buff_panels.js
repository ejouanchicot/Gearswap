// GearSwap Atelier · buff_panels.js: aftermath, effect labels, the buffs / party / target panels and windows
// (cut from atelier.html, loaded by it in order: see the list there)
/* ---- aftermath of the weapon in hand (atelier/engine/player.js) ---- */
// Prime weapons: PDL by stage and level (Lv1 / Lv2 at 60 % between two steps, as the engine), Lorg Mor and Opashoro magic
const PRIME_AM_PDL = {III: [2, 5, 8], IV: [4, 7, 10], V: [6, 9, 12]}, PRIME_AM_MDMG = {III: 0, IV: 20, V: 30}, PRIME_POT = .6;
const PRIME_PDL = new Set(['Caliburnus', 'Dokoku', 'Earp', 'Foenaria', 'Gae Buide', 'Helheim', 'Kusanagi-no-Tsurugi', 'Laphria',
  'Mpu Gandring', 'Pinaka', 'Spalirisos', 'Varga Purnikawa']);
const PRIME_MAGIC = {'Lorg Mor': ['mdmg'], 'Opashoro': ['mdmg', 'mab']};
// Mythic weapons: Lv1 / Lv2 (at 85 %, as the engine), Lv3 occasionally attacks twice or thrice (not counted)
const M49 = (49 - 30) * .85 + 30, M99 = (99 - 40) * .85 + 40;
const MYTHIC_AM = {Conqueror: ['acc', 'atk'], Glanzfaust: ['acc', 'atk'], Vajra: ['acc', 'atk'], Burtgang: ['acc', 'atk'], Liberator: ['acc', 'atk'],
  Aymur: ['acc', 'atk'], Kogarasumaru: ['acc', 'atk'], Nagi: ['acc', 'atk'], Nirvana: ['acc', 'atk'], Ryunohige: ['acc', 'atk'], Kenkonken: ['acc', 'atk'],
  Terpsichore: ['acc', 'atk'], Epeolatry: ['acc', 'atk'], Tizona: ['acc', 'macc'], Carnwenhan: ['macc', 'acc'], Yagrush: ['macc', 'acc'],
  Laevateinn: ['macc', 'mab'], Tupsimati: ['macc', 'mab'], Idris: ['macc', 'mab'], Murgleis: ['macc', 'mab'],
  Gastraphetes: ['racc', 'ratk'], 'Death Penalty': ['racc', 'ratk']};
// Relic weapons (one aftermath whatever the level) and empyrean ones (Lv1-3: occasionally attacks twice or thrice,
// 30 / 40 / 50 %), as the damage engine counts them
const RELIC_AM = {Mandau: {crit: 5, critdmg: 5}, Ragnarok: {crit: 10, acc: 15}, Guttler: {atkp: 100 / 1024}, Bravura: {dt: -20},
  Apocalypse: {jahaste: 10, acc: 15}, Gungnir: {atkp: 50 / 1024, da: 5}, Kikoku: {atkp: 100 / 1024, sb: 10}, Amanomurakumo: {stp: 10},
  Mjollnir: {acc: 20, macc: 20}, Claustrum: {dt: -20}, Yoichinoyumi: {racc: 30}, Spharai: {sb: 10}};
// the ranged mythics' Lv3 deals double or triple damage instead of attacking again (BG Wiki Death Penalty 119 III)
const MYTHIC_DMG3 = ['Death Penalty', 'Gastraphetes'];
const EMPYREAN_AM = ['Verethragna', 'Twashtar', 'Almace', 'Caladbolg', 'Farsha', 'Ukonvasara', 'Redemption', 'Kannagi', 'Rhongomiant',
  'Gambanteinn', 'Masamune', 'Hvergelmir'];
// The kind of aftermath a weapon has: prime, mythic, relic, empyrean, or none
const amKind = w => !w ? 'none' : PRIME_PDL.has(w) || PRIME_MAGIC[w] ? 'prime' : MYTHIC_AM[w] ? 'mythic' : RELIC_AM[w] ? 'relic' : EMPYREAN_AM.includes(w) ? 'empyrean' : 'none';
// A mythic's Lv1 / Lv2 from the TP the aftermath was made with, where BG Wiki gives the formula (119 III pages): Lv1
// Accuracy floor(TP/50 + 10), Lv2 Attack floor(TP x 0.06 - 80), Lv2 Magic Attack floor(TP/50 - 10); else the
// engine's 85 % estimate (Magic Accuracy, Yagrush / Carnwenhan's Lv2 Accuracy BG marks unsure)
function mythicAmValue(m, lv){
  const tp = +(buffState().amTp || 0), k = m[lv - 1], est = lv === 1 || k !== 'atk' && k !== 'ratk' ? M49 : M99;
  if (!tp) return est;
  if (lv === 1 && (k === 'acc' || k === 'racc')) return Math.floor(Math.min(1999, tp) / 50 + 10);
  if (lv === 2 && (k === 'atk' || k === 'ratk')) return Math.floor(Math.max(2000, tp) * 0.06 - 80);
  if (lv === 2 && k === 'mab') return Math.floor(Math.max(2000, tp) / 50 - 10);
  return est;
}
// What the aftermath chosen in the page (level, prime stage) gives with this weapon: [{k, v}], and a note
function aftermathOf(weapon){
  const b = buffState(), lv = amLevel();
  if (!lv || !weapon) return {fx: [], note: ''};
  if (RELIC_AM[weapon]) return {fx: Object.entries(RELIC_AM[weapon]).map(([k, v]) => ({k, v})), note: weapon};
  if (EMPYREAN_AM.includes(weapon)) return {fx: [], note: weapon, text: t(weapon === 'Verethragna' ? 'amEmpVere' : 'amEmp', {n: lv, p: [30, 40, 50][lv - 1]})};
  if (PRIME_PDL.has(weapon) || PRIME_MAGIC[weapon]) {
    const own = ownedPrimeStage(weapon), st = ['III', 'IV', 'V'].includes(b.amStage) ? b.amStage : ['III', 'IV', 'V'].includes(own) ? own : 'V', st2 = PRIME_AM_PDL[st];
    const pdl = lv === 3 ? st2[2] : lv === 2 ? (st2[2] - st2[1]) * PRIME_POT + st2[1] : (st2[1] - st2[0]) * PRIME_POT + st2[0];
    // Opashoro V at Lv3: Magic Atk. Bonus +40, Magic Damage +80 (BG Wiki 119 III); the other levels as the engine has them
    const opaV3 = weapon === 'Opashoro' && st === 'V' && lv === 3;
    if (PRIME_MAGIC[weapon]) return {fx: PRIME_MAGIC[weapon].map(k => ({k, v: opaV3 ? (k === 'mab' ? 40 : 80) : PRIME_AM_MDMG[st]})), note: `${weapon} ${st}`};
    return {fx: [{k: 'pdl', v: pdl}], note: `${weapon} ${st}`};
  }
  const m = MYTHIC_AM[weapon];
  if (m) return lv === 3 ? {fx: [], note: weapon, text: t(MYTHIC_DMG3.includes(weapon) ? 'amDmg3' : weapon === 'Kenkonken' ? 'amOaxOff' : 'amOax')}
    : {fx: [{k: m[lv - 1], v: mythicAmValue(m, lv)}], note: weapon};
  return {fx: [], note: weapon, text: t('amNone')};
}
// The Aftermath line: the level, the prime stage for a prime weapon, then the weapon in hand and what its aftermath is
function amRowHTML(sel){
  const w = shownMain(), kind = amKind(w), am = aftermathOf(w);
  const said = (isAfm3((S._curSet || {}).path) ? t('amAfm3') + ' · ' : '') + (!w ? t('amNoWeapon') : `${w} · ${t('amKind_' + kind)}` + (am.text ? ` · ${am.text}` : ''));
  return sel('am', ['1', '2', '3'], t('bAmPh')).replace(/>([123])</g, '>Lv$1<') + (kind === 'prime' ? sel('amStage', ['III', 'IV', 'V'], t('bAmStage')) : '') +
    (kind === 'mythic' ? sel('amTp', ['1000', '1250', '1500', '1750', '1999', '2000', '2250', '2500', '2750', '3000'], t('amTpPh')) : '') +
    `<span class="muted small amwho">${esc(said)}</span>`;
}
// The buff totals with the aftermath of a weapon added (charStats, the target window, the effects list)
function withAftermath(B, weapon){
  const am = aftermathOf(weapon), lv = amLevel();
  if (!lv) return B;
  const out = Object.assign({}, B, {_by: B._by.slice()}), src = `Aftermath Lv${lv}${am.note ? ' · ' + am.note : ''}`;
  for (const e of am.fx) { out[e.k] = (out[e.k] || 0) + e.v; out._by.push({src, k: e.k, v: e.v}); }
  if (am.text) out._by.push({src, k: '_text', v: am.text});
  return out;
}
const shownMain = () => { const sset = S._curSet; return sset ? ((withWeapons(sset).pieces.main || {}).name || null) : null; };
// What a buff key means, and how its value reads (fractions as %, the enemy's stats marked)
const FX_LABEL = {atkp: ['Attaque', 'Attack', '%f'], defp: ['Défense', 'Defense', '%f'], edefp: ['Défense de la cible', 'Target Defense', '-%f'],
  eeva: ['Évasion de la cible', 'Target Evasion', '-'], emdb: ['Déf. magique de la cible', 'Target Magic Def.', '-'], emeva: ['Évasion magique de la cible', 'Target Magic Evasion', '-'], eres: ['Résistance de la cible', 'Target resistance', '-%f'],
  mhaste: ['Haste magique', 'Magic Haste', '%'], jahaste: ['Haste JA', 'JA Haste', '%'], shell: ['Shell (dégâts magiques reçus)', 'Shell (magic damage taken)', 'shell'],
  dmgmul: ['Dégâts reçus', 'Damage taken', 'mul'], pdmgmul: ['Dégâts physiques reçus', 'Physical damage taken', 'mul'], deff: ['Défense (nourriture)', 'Defense (food)', 'pair'], mevaf: ['Évasion magique (nourriture)', 'Magic Evasion (food)', 'pair'],
  atkf: ['Attaque (nourriture)', 'Attack (food)', ''], atk: ['Attaque', 'Attack', ''], acc: ['Précision', 'Accuracy', ''], racc: ['Précision à distance', 'Ranged Acc.', ''],
  ratk: ['Attaque à distance', 'Ranged Atk.', ''], macc: ['Précision magique', 'Magic Accuracy', ''], mab: ['Bonus att. magique', 'Magic Atk. Bonus', ''],
  def: ['Défense', 'Defense', ''], eva: ['Évasion', 'Evasion', ''], meva: ['Évasion magique', 'Magic Evasion', ''], mdb: ['Déf. magique', 'Magic Def. Bonus', ''],
  stp: ['Store TP', 'Store TP', ''], da: ['Double Attack', 'Double Attack', '%'], crit: ['Critiques', 'Critical hit rate', '%'], enmity: ['Enmity', 'Enmity', ''],
  hp: ['HP', 'HP', ''], mp: ['MP', 'MP', ''], regen: ['Regen', 'Regen', ''], refresh: ['Refresh', 'Refresh', ''],
  block: ['Chance de blocage', 'Block rate', '%'], cure2: ['Cure potency II', 'Cure potency II', '%'], blockmul: ['Chance de blocage', 'Block rate', 'mul'],
  pdl: ['Limite dégâts physiques', 'Physical damage limit', '%'], tpb: ['TP Bonus', 'TP Bonus', ''], sb: ['Subtle Blow', 'Subtle Blow', ''], critdmg: ['Dégâts critiques', 'Critical damage', '%'], dt: ['Dégâts reçus (DT)', 'Damage taken (DT)', '%'], enspell: ['Enspell (dégâts par coup)', 'Enspell (damage a hit)', ''], mdmg: ['Dégâts magiques', 'Magic damage', '']};
// Short labels, for a one-line summary (the party support cards)
const FX_SHORT = {edefp: ['Déf cible', 'Tgt Def'], eeva: ['Éva cible', 'Tgt Eva'], emdb: ['Déf. mag. cible', 'Tgt MDB'], emeva: ['Éva. mag. cible (info)', 'Tgt M.Eva (info)'], atkp: ['Att', 'Atk'], atk: ['Att', 'Atk'], atkf: ['Att', 'Atk'], acc: ['Préc', 'Acc'], racc: ['Préc. dist.', 'R.Acc'], ratk: ['Att. dist.', 'R.Atk'],
  def: ['Déf', 'Def'], defp: ['Déf', 'Def'], eva: ['Éva', 'Eva'], meva: ['Éva. mag.', 'M.Eva'], mdb: ['Déf. mag.', 'MDB'], macc: ['Préc. mag.', 'M.Acc'],
  mab: ['MAB', 'MAB'], mhaste: ['Haste', 'Haste'], jahaste: ['Haste JA', 'JA Haste'], shell: ['Shell', 'Shell'], stp: ['STP', 'STP'], da: ['DA', 'DA'],
  crit: ['Crit', 'Crit'], pdl: ['PDL', 'PDL'], mdmg: ['Dmg mag.', 'M.Dmg'], regen: ['Regen', 'Regen'], refresh: ['Refresh', 'Refresh']};
const fxShort = (k, v) => { const full = fxText(k, v), lbl = (FX_LABEL[k] || [])[S.lang === 'fr' ? 0 : 1], sh = (FX_SHORT[k] || [])[S.lang === 'fr' ? 0 : 1];
  return lbl && sh && full.startsWith(lbl) ? sh + full.slice(lbl.length) : full; };
// What a debuff takes off the target, in words (null for a key that is not the target's)
function foeText(k, v, b = buffState()){
  const pc = x => Math.round(x * 1000) / 10;
  if (STAT_KEYS.includes(k.slice(1).toUpperCase())) return `${k.slice(1).toUpperCase()} −${Math.round(v)}`;
  const text = {edefp: () => `${t('sDef')} −${pc(v)} %`, eeva: () => `${t('sEva')} −${Math.round(v)}`, eres: () => `${t('sRes')} −${pc(v)} %`,
    estatp: () => `${t('sStats')} −${pc(v)} %`, ecrit: () => `${t('sCrit')} +${Math.round(v)} %`, eatkp: () => `${t('sAtk')} −${pc(v)} %`,
    eresu: () => `${t('sRes')} −${pc(v)} % (${t('undeadOnly')})`, eallstat: () => `${t('sStats')} −${Math.round(v)}`, eslow: () => `${t('sSlow')} −${pc(v)} %`,
    edot: () => `${Math.round(v)} HP/tick`, egambit: () => `${t('el_' + RUNES[runeOf(b)])} +${Math.round(v)} %`,
    emdb: () => `${t('sMdb')} −${Math.round(v)}`, emeva: () => `${t('sMeva')} −${Math.round(v)} (${t('infoWord')})`}[k];
  return text ? text() : null;
}
function fxText(k, v){
  if (k === '_text') return v;
  if (!FX_LABEL[k] && k[0] === 'e') { const f = foeText(k, v); if (f != null) return f; }
  const [fr, en, how = ''] = FX_LABEL[k] || [k.toUpperCase(), k.toUpperCase(), ''], label = S.lang === 'fr' ? fr : en, r = n => Math.round(n * 10) / 10;
  if (how === 'pair') return `${label} +${v[0]} % (max ${v[1]})`;
  if (how === 'mul') return `${label} ×${r(v)}`;
  if (how === 'shell') return `${label} −${r(v / 256 * 100)} %`;
  if (how === '%f') return `${label} ${v < 0 ? '−' : '+'}${r(Math.abs(v) * 100)} %`;
  if (how === '-%f') return `${label} −${r(v * 100)} %`;
  if (how === '-') return `${label} −${r(v)}`;
  return `${label} ${v < 0 ? '−' : '+'}${r(Math.abs(v))}${how === '%' ? ' %' : ''}`;
}
// The list under the panel: each active buff, what it gives
function buffEffectsHTML(){
  const by = withAftermath(buffTotals(), shownMain())._by, groups = new Map();
  for (const e of by) { if (!groups.has(e.src)) groups.set(e.src, []); groups.get(e.src).push(fxText(e.k, e.v)); }
  // always there, its list scrolling inside a fixed height: adding or taking a buff off moves nothing
  return fbox('fx', 'g-buff', t('bEffects'), groups.size ? `<ul class="condlist fxlist fxfixed">${[...groups].map(([src, list]) =>
    `<li><b>${esc(src)}</b><span>${list.map(esc).join(' · ')}</span></li>`).join('')}</ul>` : `<p class="muted small fxfixed">${t('bNone')}</p>`);
}
function buffCount(){
  const b = buffState();
  return ['food', 'protect', 'shell', 'haste', 'storm', 'song0', 'song1', 'song2', 'song3', 'song4', 'soulVoice', 'clarion', 'roll0', 'roll1', 'indi', 'geo', 'entrust', 'bolster', 'bog', 'ecliptic', 'dia', 'lightshot', 'distract', 'am'].filter(k => b[k] && (k !== 'song4' || b.clarion)).length + (b.foeJa || []).length +
    jasOf().filter(ja => jaOn(b, ja.name)).length;
}
function buffPanelHTML(){
  const b = buffState(), n = buffCount();
  // a menu; its empty choice names what it is for (Protect, Song 2...); `def` a value used while none is chosen
  const sel = (key, values, ph = '—', def = null, cls = '') => `<select class="buffsel ${cls} ${b[key] ? 'set' : ''}" data-buff="${key}" title="${esc(ph)}">` +
    (def ? values : ['', ...values]).map(v => `<option value="${esc(v)}" ${String(v) === String(b[key] ?? def ?? '') ? 'selected' : ''}>${v === '' ? esc(ph) : esc(v)}</option>`).join('') + `</select>`;
  // a geomancy menu: the buffs on you, then the debuffs on the enemy
  const geoSel = (key, ph) => `<select class="buffsel ${b[key] ? 'set' : ''}" data-buff="${key}" title="${ph}"><option value="">${ph}</option>` +
    `<optgroup label="${t('geoOnYou')}">${Object.keys(BUBBLES).map(v => `<option ${v === b[key] ? 'selected' : ''}>${esc(v)}</option>`).join('')}</optgroup>` +
    `<optgroup label="${t('geoOnEnemy')}">${Object.keys(GEO_DEBUFFS).map(v => `<option ${v === b[key] ? 'selected' : ''}>${esc(v)}</option>`).join('')}</optgroup></select>`;
  // the + of a job's gear (Songs+, Rolls+, Geomancy+): "+0" while none is chosen
  const plus = (key, label, max) => `<select class="buffsel plus ${b[key] ? 'set' : ''}" data-buff="${key}" title="${label}">` +
    ['', ...Array.from({length: max}, (_, i) => i + 1)].map(v => `<option value="${v}" ${String(v) === String(b[key] ?? '') ? 'selected' : ''}>${label} +${v || 0}</option>`).join('') + `</select>`;
  const row = (label, body, cls = '') => `<div class="brow"><span>${label}</span><div class="bctl ${cls}">${body}</div></div>`;
  const jas = jasOf(), ownWarcry = j => j.name === 'Warcry' && j.as === 'main';
  const chipsOf = ja => `<button class="chip ja-${ja.as}" data-ja="${esc(ja.name)}" aria-pressed="${jaOn(b, ja.name)}" title="${esc(jaTip(ja))}">` +
    `${esc(ja.name.replace(' · party', ''))}${ja.as !== 'main' ? `<small>${ja.as === 'sub' ? '/' + esc((data() || {}).sub) : t('jaParty')}</small>` : ''}</button>`;
  // yours: food, aftermath, your abilities (and a party WAR's Warcry, set under them)
  const own = [
    row(t('bFood'), sel('food', Object.keys(FOODS), t('bFood')), 'one'),
    row(t('bAm'), amRowHTML(sel)),
    // a WAR main's Warcry is switched in its own line, with its Savagery / Agoge Mask
    jas.some(j => j.as !== 'party' && !ownWarcry(j)) ? row(t('bJa'), jas.filter(j => j.as !== 'party' && !ownWarcry(j)).map(chipsOf).join(''), 'chips') : '',
    jas.some(ownWarcry) ? row('Warcry', chipsOf(jas.find(ownWarcry)) + warcryHTML(b), 'chips') : '',
  ].join('');
  const party = partyCardsHTML(b, sel, geoSel, plus, jas);
  const tgt = targetCardPanel(b), foe = foePanelHTML(b);
  // the four compartments fold by their band (S.bFold, kept between visits)
  const fold = (key, cls, title, body, meta = '') => { const shut = !!(S.bFold || {})[key];
    return `<section class="box ${cls} bfoldbox ${shut ? 'shut' : ''}"><header class="boxh" data-bfold="${key}" role="button" aria-expanded="${!shut}">` +
      `<h3>${title}</h3>${meta}</header>${shut ? '' : `<div class="boxb">${body}</div>`}</section>`; };
  return `<div class="buffbody"><div class="bcol">${fold('you', 'g-buff', t('bYours'), own)}${fold('party', 'g-def', t('bParty'), party)}</div>` +
    `<div class="bcol">${fold('target', 'g-off', t('bTarget'), tgt, `<span class="meta">${esc(enemyKey(b.enemy))}</span>`)}${fold('foe', 'g-mag', t('bDebuffsTitle'), foe.body, foe.total)}</div></div>`;
}
// A BRD's songs: four, five under Clarion Call; Soul Voice doubles them all, Marcato one of them x1.5, never
// both (BG Wiki: Soul Voice cancels Marcato)
const songSlots = b => b.clarion ? [0, 1, 2, 3, 4] : [0, 1, 2, 3];
// Aria of Passion is sung with Loughnashade only (BG Wiki): the horn's own All songs+ by prime stage (III: Level
// 119 +2, IV: 119 II +3, V: 119 III +4) and +3 from the rest of the gear, up to its +7 cap (22.1 % PDL)
const ARIA_HORN = {III: 2, IV: 3, V: 4};
const ariaPlus = b => Math.min(SONGS['Aria of Passion'].lim, ARIA_HORN[b.ariaStage || 'V'] + 3);
// Aria's PDL as sung, Soul Voice or Marcato on it included (the engine gets it from the page)
function ariaPdl(b){
  const i = songSlots(b).find(j => b['song' + j] === 'Aria of Passion');
  if (i == null) return 0;
  const [base, step] = SONGS['Aria of Passion'].pdl;
  return (base + ariaPlus(b) * step) * songMul(b, i);
}
const songMul = (b, i) => b.soulVoice ? 2 : b.marcato != null && +b.marcato === i ? 1.5 : 1;
function brdJaHTML(b, plusHTML){
  const chip = (attrs, label, on, tip = '', off = false) => `<button class="chip" ${attrs} aria-pressed="${!!on}" ${off ? 'disabled' : ''} title="${esc(tip)}">${esc(label)}</button>`;
  const m = b.marcato != null && !b.soulVoice;
  const row = (label, body, tip = '') => `<div class="prow"><span class="flbl" ${tip ? `title="${esc(tip)}"` : ''}>${esc(label)}</span>${body}</div>`;
  // under the songs, a line a setting: the gear's Songs+, Soul Voice / Clarion Call, Marcato's song (again to take it
  // off; none under Soul Voice), Aria's Loughnashade stage
  return `<div class="brdrows">${row(t('pGear'), plusHTML)}` +
    row(t('bJa'), chip('data-buffflag="soulVoice"', 'Soul Voice', b.soulVoice, t('svTip')) + chip('data-buffflag="clarion"', 'Clarion Call', b.clarion, t('clarionTip'))) +
    row('Marcato', `<span class="fseg">${songSlots(b).map(i => chip(`data-marcato="${i}"`, String(i + 1), m && +b.marcato === i, t('marcatoOn', {n: i + 1}), b.soulVoice)).join('')}</span>`, t('marcatoTip')) +
    (songSlots(b).some(i => b['song' + i] === 'Aria of Passion') ? row('Aria', `<span class="fseg">` +
      Object.keys(ARIA_HORN).map(st => chip(`data-foeseg="ariaStage" data-v="${st}"`, st, (b.ariaStage || 'V') === st, t('ariaTip', {n: ARIA_HORN[st]}))).join('') +
      `</span><span class="muted small">Loughnashade · Songs +${ariaPlus(b)} · PDL +${Math.round(ariaPdl(b) * 10) / 10} %</span>`) : '') + `</div>`;
}
// A roll's two buttons: its job in the party (its bonus; on by itself when it is your job), Crooked Cards (one roll)
function rollChips(b, i){
  const rj = ROLL_JOB[b['roll' + i]], mine = rj && rj[0] === S.job;
  const job = `<button class="chip" data-rolljob="${i}" aria-pressed="${rollJobOn(b, i)}" ${!rj || mine ? 'disabled' : ''} title="${esc(rj ? t(mine ? 'rollJobMine' : 'rollJobTip', {j: rj[0]}) : '')}">${esc(rj ? rj[0] : '—')}</button>`;
  const cc = `<button class="chip" data-rollcc="${i}" aria-pressed="${b.rollCC != null && +b.rollCC === i}" ${b['roll' + i] ? '' : 'disabled'} title="${esc(t('rollCcTip'))}">CC</button>`;
  return job + cc;
}
// The party's support, a card a job: its title, its choices, then what it gives you
// (Protect, Shell and Haste a tier a click, again to take it off; songs, rolls and bubbles as menus)
function partyCardsHTML(b, sel, geoSel, plus, jas){
  const B = buffTotals();
  // what a job's buffs give, each stat once (two Minuets add up), as HTML: yours first, then what comes off the
  // target (Frailty...) in red
  const FOE_KEYS = ['edefp', 'eeva', 'emdb', 'emeva', 'eres', 'estatp', 'ecrit', 'eatkp', 'egambit', 'eresu', 'eallstat', 'eslow', 'edot', 'estr', 'edex', 'evit', 'eagi', 'eint', 'emnd', 'echr'];
  const gives = (src, extra = '') => { const sum = {};
    for (const e of B._by) if (src(e.src) && typeof e.v === 'number') sum[e.k] = (sum[e.k] || 0) + e.v;
    const keys = Object.keys(sum), mine = keys.filter(k => !FOE_KEYS.includes(k)), foe = keys.filter(k => FOE_KEYS.includes(k));
    const parts = mine.map(k => esc(fxShort(k, sum[k]))).concat(foe.map(k => `<span class="pneg">${esc(fxShort(k, sum[k]) + extra)}</span>`));
    return parts.join(' · '); };
  const flag = (k, label, tip) => `<button class="chip" data-buffflag="${k}" aria-pressed="${!!b[k]}" title="${esc(tip)}">${esc(label)}</button>`;
  const seg = (k, tiers, label) => `<div class="pseg"><span class="flbl">${esc(label)}</span><span class="fseg">${Object.keys(tiers).map(v =>
    `<button class="chip" data-foeseg="${k}" data-v="${esc(v)}" aria-pressed="${b[k] === v}">${esc(v.replace(/^\S+\s?/, '') || 'I')}</button>`).join('')}</span></div>`;
  const songs = new Set(Object.keys(SONGS)), geoName = v => v.replace(/^(Entrust )?(Indi|Geo)-/, '');
  // who casts the WHM tab's spells (BG Wiki): Protect V WHM / RDM / SCH / PLD, Shell V WHM / RDM / SCH / RUN, Haste WHM /
  // RDM, Haste II RDM only, Storm II SCH only, Hastega SMN (Garuda); its switch keeps its WHM key
  const tabs = [
    {key: 'WHM', label: 'WHM', body: `<div class="prow">${seg('protect', PROTECT, 'Protect')}<span class="pwho">WHM RDM SCH PLD</span></div>` +
      `<div class="prow">${seg('shell', SHELL, 'Shell')}<span class="pwho">WHM RDM SCH RUN</span></div>` +
      `<div class="prow">${seg('haste', {'Haste': 1, 'Haste II': 1}, 'Haste')}<span class="pwho">I : WHM RDM · II : RDM</span></div>` +
      `<div class="prow">${seg('haste', {'Hastega': 1, 'Hastega II': 1}, 'Hastega')}<span class="pwho">SMN (Garuda)</span></div>` +
      `<div class="prow"><div class="pseg"><span class="flbl">Storm</span>${sel('storm', Object.keys(STORMS), 'Storm')}</div><span class="pwho">SCH</span></div>` +
      `<div class="prow"><div class="pseg"><span class="flbl">Auspice</span>${flag('auspice', 'Auspice', t('auspiceTip'))}` +
      `${sel('auspiceFeet', Object.keys(AUSPICE_FEET), t('auspiceFeet'))}</div><span class="pwho">WHM</span></div>` +
      `<div class="prow"><div class="pseg"><span class="flbl">Enspell</span>${flag('enspell', 'Enspell I', t('enspellTip'))}` +
      `${sel('enSkill', EN_SKILLS.map(String), t('enSkillPh'), '600')}</div><span class="pwho">RDM + Accession (/SCH)</span></div>`,
      fx: gives(v => PROTECT[v] || SHELL[v] || HASTE[v] || STORMS[v] || v === 'Auspice' || v === 'Enspell I')},
    {key: 'BRD', label: 'BRD', body: `<div class="pgrid">${[0, 1, 2, 3, 4].map(i => { const h = sel('song' + i, Object.keys(SONGS), `${t('bSong')} ${i + 1}`);
        return i < 4 || b.clarion ? h : h.replace('<select ', `<select disabled title="${esc(t('clarionTip'))}" `); }).join('')}` +
      `</div>${brdJaHTML(b, plus('songsPlus', 'Songs', 9))}`, fx: gives(v => songs.has(v))},
    {key: 'COR', label: 'COR', body: `<div class="pgrid">${[0, 1].map(i => `<div class="proll">${sel('roll' + i, Object.keys(ROLLS), `Roll ${i + 1}`)}` +
      `${sel('roll' + i + 'n', ROMAN, '', 'XI', 'n')}${rollChips(b, i)}</div>`).join('')}${plus('rollsPlus', 'Rolls', 8)}</div>`, fx: gives(v => / Roll [IVX]+/.test(v))},
    {key: 'GEO', label: 'GEO', body: `<div class="pgrid">${geoSel('indi', 'Indi')}${geoSel('geo', 'Geo')}${geoSel('entrust', 'Entrust')}${plus('geoPlus', 'Geomancy', 10)}</div>${geoJaHTML(b)}`,
      // what the bubbles give you and take off the target (Frailty...), an NM's cut said
      fx: gives(v => /^(Entrust )?(Indi|Geo)-/.test(v) && (BUBBLES[geoName(v)] || GEO_DEBUFFS[geoName(v)]),
        geoKeep(enemyKey(b.enemy)) < 1 ? ` (NM −${Math.round((1 - geoKeep(enemyKey(b.enemy))) * 100)} %)` : '')},
  ];
  // the abilities another party member lays on you (a party WAR's Warcry, a DNC's Haste Samba, a SMN's blood pacts
  // and Favor), a tab their job; a party Warcry on shows its Savagery / Agoge Mask
  const groups = new Map();
  for (const ja of jas.filter(j => j.as === 'party')) {
    const job = ja.a.from || [].concat(ja.a.job)[0];
    if (!groups.has(job)) groups.set(job, []);
    groups.get(job).push(ja);
  }
  for (const [job, list] of groups) {
    const names = new Set(list.map(j => j.name));
    const chips = list.map(ja => `<button class="chip ja-party" data-ja="${esc(ja.name)}" aria-pressed="${jaOn(b, ja.name)}" title="${esc(jaTip(ja))}">` +
      `${esc(ja.name.replace(' · party', ''))}</button>`).join('');
    const extra = (names.has('Warcry · party') && jaOn(b, 'Warcry · party') ? `<div class="prow">${warcryHTML(b, true)}</div>` : '') +
      (names.has('Haste Samba') && jaOn(b, 'Haste Samba') ? `<div class="prow">${sambaHTML(b)}</div>` : '');
    tabs.push({key: 'p' + job, label: job, body: `<div class="bctl chips">${chips}</div>${extra}`, fx: gives(v => names.has(v))});
  }
  const cur = tabs.find(x => x.key === S._pTab) || tabs[0], curOn = !(b.off || {})[cur.key];
  const isOn = x => !(b.off || {})[x.key];
  const bar = `<div class="foetabs" role="tablist">${tabs.map(x => `<button class="foetab ${x.fx && isOn(x) ? 'on' : ''}" role="tab" data-ptab="${x.key}" ` +
    `aria-selected="${x === cur}">${esc(x.label)}</button>`).join('')}<span class="foetabsw">${offSwitch(b, cur.key)}</span></div>`;
  // what the whole party gives, a line a job
  const given = tabs.filter(x => x.fx && isOn(x));
  const recap = given.length ? `<ul class="foeon ponlist">${given.map(x => `<li><span>${esc(x.label)}</span><b>${x.fx}</b></li>`).join('')}</ul>`
    : `<p class="muted small foeonempty">${esc(t('pNoneAll'))}</p>`;
  return `${bar}<div class="ppane ${curOn ? '' : 'off'}">${cur.body}</div><div class="kicker foeonk">${esc(t('pGiven'))}</div>${recap}`;
}
// The GEO's abilities on its bubbles, under its menus: Bolster greys out the two it leaves out
function geoJaHTML(b){
  const btn = (k, label, tip, off) => `<button class="chip" data-buffflag="${k}" aria-pressed="${!!b[k]}" title="${esc(tip)}" ${off ? 'disabled' : ''}>${esc(label)}</button>`;
  const m = geoMul(b), said = [m.indi !== 1 ? 'Indi ×' + m.indi : '', m.geo !== 1 ? 'Geo ×' + m.geo : ''].filter(Boolean).join(' · ');
  return `<div class="bspan">${btn('bolster', 'Bolster', t('bolsterTip'))}${btn('bog', 'Blaze of Glory', t('bogTip'), b.bolster)}` +
    `${btn('ecliptic', 'Ecliptic Attrition', t('eclipticTip'), b.bolster)}${said ? `<span class="muted small">${esc(said)}</span>` : ''}</div>`;
}
// Your own Warcry, a WAR main's: its Savagery merits (0 to 5) and Agoge Mask, and the TP Bonus they give;
// greyed while Warcry is off (a party WAR's is counted at 5/5 with the mask: WARCRY_PARTY_TP)
function warcryHTML(b, party){
  const on = party || jaOn(b, 'Warcry'), sv = party ? b.pSavagery : b.savagery, lv = sv == null ? 5 : +sv, noAgoge = party ? b.pNoAgoge : b.noAgoge;
  const btn = (attrs, label, pressed) => `<button class="chip" ${attrs} aria-pressed="${pressed}" ${on ? '' : 'disabled'}>${esc(label)}</button>`;
  const who = party ? ' data-wparty="1"' : '';
  return `<span class="flbl">Savagery</span><span class="fseg">${[0, 1, 2, 3, 4, 5].map(n => btn(`data-savagery="${n}"${who}`, String(n), n === lv)).join('')}</span>` +
    btn(`data-agoge${who}`, 'Agoge Mask +3/+4', !noAgoge) + `<span class="muted small">${on ? 'TP Bonus +' + warcryTp(b, party) : esc(t('warcryOff'))}</span>`;
}
// The target compartment: the picker's button, its job and zone, its Defense and Evasion before → after
function targetCardPanel(b){
  const key = enemyKey(b.enemy), x = TARGETS[key] || {}, T = targetInfo(null);
  const num = (label, a, z) => `<div class="tnum"><span>${esc(label)}</span><b>${a}</b><i>→</i><b class="${z !== a ? 'down' : ''}">${z}</b></div>`;
  return `<button class="btn ghost tgtpickbtn" data-tgtpick>${esc(key)}${x.est && x.est.length ? ' *' : ''} ▾</button>` +
    `<p class="muted small tmeta">${esc([x.job, x.zone].filter(Boolean).join(' · ') || t('pkDefault'))}</p>` +
    `<div class="tnums">${num(t('tgtDef'), T.def, Math.max(1, T.defAfter))}${num(t('tgtEva'), T.eva, T.evaAfter)}</div>`;
}
// What lowers the target: the usual ones always in view (Dia, Distract with Saboteur, Light Shot), the other
// jobs one tab each (a dot on a tab with something on); a line: its buttons (a tier is one click and again to
// take it off) and what they take off; then every debuff on, with what it takes off; the total in the band.
// GEO's bubbles are chosen with the party's support (their effect in the list of what is on the target)
function foePanelHTML(b){
  const key = enemyKey(b.enemy), T = targetInfo(null);
  const short = (k, v) => foeText(k, v, b) ?? fxText(k, v);

  const btn = (attrs, label, on, tip = '', off = false) =>
    `<button class="chip" ${attrs} aria-pressed="${!!on}" ${off ? 'disabled' : ''} ${tip ? `title="${esc(tip)}"` : ''}>${esc(label)}</button>`;
  const seg = (k, tiers, full) => `<span class="fseg">${Object.keys(tiers).map(v => btn(`data-foeseg="${k}" data-v="${esc(v)}"`,
    full ? v : v.replace(/^(Dia|Distract)\s?/, '') || 'I', b[k] === v)).join('')}</span>`;
  const JA_TIP = {'Lunar Cry': 'lunarTip', 'Banish II': 'banishTip', 'Dark Shot': 'darkShotTip'};
  const ja = (n, over) => btn(`data-foeja="${esc(n)}"`, FOE_JA.BST[n] ? n.split(': ')[1] : n, (b.foeJa || []).includes(n),
    [JA_TIP[n] ? t(JA_TIP[n]) : FOE_JA.COR[n] && FOE_JA.COR[n].shot ? t('shotTip', {d: FOE_JA.COR[n].shot}) : FOE_JA.BST[n] ? n : '', over ? t('ddOver') : ''].filter(Boolean).join(' · ')).replace('class="chip"', `class="chip${over ? ' over' : ''}"`);
  const by = src => T.B._by.filter(e => src(e.src)).map(e => short(e.k, e.v));
  // Saboteur's multiplier on this target, on its own button (x2 a monster, x1.25 an NM, more with the gloves)
  const nm = isNmTarget(key), sabX = nm ? (b.sabGloves ? 1.39 : 1.25) : (b.sabGloves ? 2.14 : 2);
  const geoSrc = v => GEO_DEBUFFS[v.replace(/^(Entrust )?(Indi|Geo)-/, '')];
  const nmGeo = x => geoKeep(key) < 1 ? `${x} (NM −${Math.round((1 - geoKeep(key)) * 100)} %)` : x;
  // BLM: Bio, Bio II (Bio III is a RDM's: its tab) and Impact; the six elemental debuffs, Archmage's Sabots +3 under them
  const blmLines = names => { const el = names.filter(n => FOE_JA_FX[n].elem);
    return [['', seg('dia', {'Bio': 1, 'Bio II': 1}, true), by(v => v === 'Bio' || v === 'Bio II')], ['', ja('Impact'), by(v => v === 'Impact')],
      ['', el.map(ja).join(''), by(v => el.includes(v)), 'wide'],
      ['', btn('data-buffflag="sabots"', 'Archmage’s Sabots +3', b.sabots, t('sabotsTip')), b.sabots ? [t('sabotsOn')] : [], 'wide']]; };
  const runLines = () => [[t('runesLbl'), `<select class="buffsel set" data-buff="rune">${Object.entries(RUNES).map(([r, el]) =>
      `<option value="${r}" ${r === runeOf(b) ? 'selected' : ''}>${r} · ${esc(t('el_' + el))}</option>`).join('')}</select>` +
      `<span class="fseg">${['1', '2', '3'].map(n => btn(`data-foeseg="runes" data-v="${n}"`, n, String(runeCount(b)) === n, t('runesTip'))).join('')}</span>`, null, 'wide'],
    ['', ja('Gambit'), by(v => v === 'Gambit'), 'wide'],
    note('Rayke', 'raykeInfo', {e: t('el_' + RUNES[runeOf(b)]), n: runeCount(b)})];
  // a Magic Evasion down: a grey note (the targets' Magic Evasion is not known, so it changes no damage)
  const note = (label, key, v = {}) => { const txt = `${t(key, v)} · ${t('infoNotCounted')}`;
    return [label, `<span class="fnote" title="${esc(txt)}">${esc(txt)}</span>`, null, 'wide']; };
  // many abilities: their buttons in one block (a weaker one struck through), what they take off in the list under
  const FLOW_TABS = ['BLU', 'BST', 'WS'];
  const flowLines = (names, off) => [['', names.map(n => ja(n, off.includes(n))).join(''), null, 'wide flow']];
  const brdLines = () => [note('Threnody II', 'threnNote'),
    ['', ja('Carnage Elegy'), by(v => v === 'Carnage Elegy')], ['', ja('Foe Requiem VII'), by(v => v === 'Foe Requiem VII')]];
  // a tab a job, each with its switch (sw: the key b.off keeps), its lines [label, controls, what they take off, wide]
  const evdOver = DISTRACT[b.distract] && !foeCounted(b).distractWins ? [t('ddOver')] : [];
  const tabs = [
    {id: 'Dia', label: 'WHM', on: (!!DIA[b.dia] && b.dia !== 'Dia III') || (b.foeJa || []).includes('Banish II'), lines: [['Dia', seg('dia', {'Dia': 1, 'Dia II': 1}),
      b.dia === 'Dia III' ? [] : by(v => DIA[v]), 'wide'], ['', ja('Banish II'), by(v => v === 'Banish II'), 'wide']]},
    {id: 'Distract', label: 'RDM', on: !!DISTRACT[b.distract] || DIA_OWNER[b.dia] === 'Distract',
      lines: [['Dia · Bio', seg('dia', {'Dia III': 1, 'Bio III': 1}, true),
      by(v => (v === 'Dia III' || v === 'Bio III')), 'wide'], ['Distract', seg('distract', DISTRACT) +
      btn('data-buffflag="saboteur"', b.saboteur ? `Saboteur ×${sabX}` : 'Saboteur', b.saboteur, `${t('sabTip')} · ${nm ? 'NM' : t('sabMobShort')} ×${sabX}`) + btn('data-buffflag="sabGloves"', 'Lethargy +3', b.sabGloves, 'Lethargy Gantherots +3', !b.saboteur),
      by(v => /^Distract/.test(v)).concat(evdOver), 'wide'], note('Frazzle III', 'frazzleNote')]},
    {id: 'Light Shot', label: 'COR', on: !!(b.lightshot && DIA[b.dia]) || Object.keys(FOE_JA.COR).some(n => (b.foeJa || []).includes(n)),
      lines: [['', btn('data-buffflag="lightshot"', 'Light Shot', b.lightshot, t('lsTip'), !DIA[b.dia]), by(v => v === 'Light Shot')],
        ['', ja('Dark Shot'), by(v => v === 'Dark Shot')],
        ['', Object.keys(FOE_JA.COR).filter(n => FOE_JA.COR[n].shot).map(n => ja(n)).join('') +
          `<span class="fseg">${['1', '2'].map(v => btn(`data-foeseg="corShots" data-v="${v}"`, t('corShotN', {n: v}), (b.corShots || '2') === v, t('corShotsTip'))).join('')}</span>`, null, 'wide flow']]},
    ...Object.entries(FOE_JA).filter(([job]) => !['RDM', 'WHM', 'COR'].includes(job)).map(([job, list]) => {
      const names = Object.keys(list), off = names.filter(n => (b.foeJa || []).includes(n) && !foeJaActive(b).includes(n));
      // BRD's switch here is Threnody's own: the BRD one is Party support's songs
      return {id: FOE_SW[job] || job, label: job === 'WS' ? t('foeWsTab') : job, on: names.some(n => (b.foeJa || []).includes(n)) || DIA_OWNER[b.dia] === job,
        lines: (job === 'BLM' ? blmLines(names) : job === 'RUN' ? runLines() : job === 'BRD' ? brdLines() : FLOW_TABS.includes(job) ? flowLines(names, off)
          : names.filter(n => !FOE_JA_FX[n].smnImpact).map(n => ['', ja(n), by(v => v === n).concat(off.includes(n) ? [t('ddOver')] : [])]))
          .concat(job === 'SMN' ? [['', ja('Impact (Fenrir)') + `<select class="buffsel set" data-buff="smnSkill" title="${esc(t('smnSkillTip'))}">` +
            SMN_SKILLS.map(v => `<option value="${v}" ${v === smnSkill(b) ? 'selected' : ''}>${esc(t('smnSkillOpt', {n: v}))}</option>`).join('') + `</select>`,
            by(v => v === 'Impact (Fenrir)'), 'wide']] : [])
          .concat(job === 'DNC' ? [['', btn('data-buffflag="dncSub"', t('dncSubLbl'), b.dncSub, t('dncSubTip')), null], note('Stutter Step', 'stutterNote')] : [])
          .concat(job === 'NIN' ? [note('Ninjutsu', 'ninNote')] : [])};
    }),
  ];
  const cur = tabs.find(x => x.id === S._foeTab) || tabs.find(x => x.on) || tabs[0], curOn = !(b.off || {})[cur.id];
  // the jobs in two rows of nine, the tab's switch on their right
  const bar = `<div class="foetabs ftab7"><div class="ftabs7" role="tablist">${tabs.map(x => `<button class="foetab ${x.on && !(b.off || {})[x.id] ? 'on' : ''}" role="tab" data-foetab="${esc(x.id)}" ` +
    `aria-selected="${x === cur}">${esc(x.label)}</button>`).join('')}</div><span class="foetabsw">${offSwitch(b, cur.id)}</span></div>`;
  // the tab as a grid, two abilities a row (a wide one a row), each with what it takes off
  const cell = ([l, ctl, fx, wide]) => `<div class="fcell ${wide || ''}">${l ? `<span class="flbl">${esc(l)}</span>` : ''}<div class="fctl">${ctl}</div>` +
    (fx ? `<span class="ffx ${fx.length && curOn ? 'on' : ''}" title="${esc(fx.join(' · '))}">${esc(!curOn ? '' : fx.join(' · ') || '—')}</span>` : '') + `</div>`;
  const pane = `${bar}<div class="ftabgrid ${curOn ? '' : 'off'}">${cur.lines.map(cell).join('')}</div>`;
  // everything on the target, whatever its tab: what lays it, what it takes off
  const onList = T.B._by.filter(e => ['edefp', 'eeva', 'emdb', 'emeva', 'eres', 'estatp', 'ecrit', 'eatkp', 'egambit', 'eresu', 'eallstat', 'eslow', 'edot', 'estr', 'edex', 'evit', 'eagi', 'eint', 'emnd', 'echr'].includes(e.k));
  // a line a debuff, its effects together (Swooping Frenzy: Defense and Magic Defense)
  const bySrc = new Map();
  for (const e of onList) bySrc.set(e.src, (bySrc.get(e.src) || []).concat(geoSrc(e.src) ? nmGeo(short(e.k, e.v)) : short(e.k, e.v)));
  const recap = onList.length ? `<ul class="foeon">${[...bySrc].map(([src, fx]) => `<li><span>${esc(src)}</span><b>${esc(fx.join(' · '))}</b></li>`).join('')}</ul>`
    : `<p class="muted small foeonempty">${esc(t('foeNoneOn'))}</p>`;
  const total = [T.defDown ? short('edefp', T.defDown) : '', T.B.eeva ? short('eeva', T.B.eeva) : ''].filter(Boolean).join(' · ');
  return {body: pane + `<div class="kicker foeonk">${esc(t('foeOnTitle'))}</div>` + recap,
    total: `<span class="meta ${total ? 'down' : ''}">${esc(total || t('foeNone'))}</span>`};
}
// The target picker, a window over the buffs: the target chosen and the reference on top, a search, then
// one folding compartment a zone (all closed; a search opens the zones it finds), a line a monster with
// its levels (or Vengeance) as buttons; * = some stats estimated. Picking one, Back, a click outside or
// Escape go back to the buffs
function openTargetPick(){
  S._buffDlg = false; S._tgtPick = true;
  const cur = enemyKey(buffState().enemy), zones = new Map();
  for (const x of Object.values(TARGETS)) {
    if (x.key === DEFAULT_ENEMY) continue;
    if (!zones.has(x.zone)) zones.set(x.zone, new Map());
    const m = zones.get(x.zone);
    if (!m.has(x.name)) m.set(x.name, []);
    m.get(x.name).push(x);
  }
  const chip = x => `<button class="chip" data-pickenemy="${esc(x.key)}" aria-pressed="${x.key === cur}">${esc(x.key.split(' · ')[1] || x.key)}</button>`;
  const line = (n, xs) => `<div class="tprow" data-q="${esc((n + ' ' + xs[0].zone).toLowerCase())}"><span class="tpname">${esc(n)}` +
    `${xs[0].est.length ? ' <span class="muted">*</span>' : ''}${xs[0].job ? ` <span class="muted small">${esc(xs[0].job)}</span>` : ''}</span>` +
    `<div class="tplv">${xs.map(chip).join('')}</div></div>`;
  // a zone's band: its name, how many monsters, their levels
  const span = xs => { const lv = xs.map(x => x.lv).filter(Boolean), v = xs.map(x => x.key.match(/· (V\d+)$/)).filter(Boolean);
    return lv.length ? `Lv${Math.min(...lv)}${Math.max(...lv) > Math.min(...lv) ? '–' + Math.max(...lv) : ''}` : v.length ? `${v[0][1]}–${v[v.length - 1][1]}` : ''; };
  const zone = (z, m) => { const all = [...m.values()].flat(), has = all.some(x => x.key === cur);
    return `<details class="tpzone ${has ? 'cur' : ''}"><summary><b>${esc(z)}</b><span class="muted small">${t('pkCount', {n: m.size})} · ${span(all)}</span>` +
      `${has ? `<span class="pkcur">${esc(cur.split(' · ')[0])}</span>` : ''}</summary><div class="tpbody">${[...m].map(([n, xs]) => line(n, xs)).join('')}</div></details>`; };
  const x = TARGETS[cur] || {};
  const head = `<div class="pkhead"><div class="pknow"><span class="muted small">${esc(t('pkNow'))}</span><b>${esc(cur)}${x.est && x.est.length ? ' *' : ''}</b>` +
    `<span class="muted small">${esc([x.job, x.zone].filter(Boolean).join(' · '))}</span></div>` +
    `<button class="chip" data-pickenemy="" aria-pressed="${cur === DEFAULT_ENEMY}" title="${esc(t('pkDefault'))}">${esc(DEFAULT_ENEMY)}</button></div>` +
    `<input id="tgtq" class="tgtq" type="search" placeholder="${esc(t('pkSearch'))}" autocomplete="off">`;
  const body = head + `<div class="pkzones">${[...zones].map(([z, m]) => zone(z, m)).join('')}</div>` +
    `<p class="muted small bnote">${esc(t('pkStar'))}</p>`;
  $('#overlay').innerHTML = `<div class="scrim" data-tgtback></div><div class="dialog tgtpickdlg" role="dialog" aria-label="${esc(t('pkTitle'))}">` +
    `<header><h3>${esc(t('pkTitle'))}</h3></header><div class="body">${body}</div>` +
    `<footer><button class="btn ghost" data-tgtback>← ${esc(t('pkBack'))}</button></footer></div>`;
  $('#overlay').hidden = false;
  const q = $('#tgtq'); if (q) q.focus();
}
// Where a target's stats come from, the ones estimated, and the damage it takes by type
function targetFactsHTML(name){
  const x = TARGETS[name] || {}, res = x.res || {};
  const head = [x.zone, x.job, t('tgtSrc_' + x.src)].filter(Boolean).map(esc).join(' · ');
  const taken = Object.keys(res).filter(k => res[k]).map(k => `${t('tgtRes_' + k)} ${res[k] > 0 ? '+' : '−'}${Math.abs(res[k])} %`);
  return `<p class="muted small">${head}</p>` + (x.est && x.est.length ? `<p class="small kwarn">${esc(t('tgtEst', {l: x.est.join(', ')}))}</p>` : '') +
    (taken.length ? `<p class="small">${esc(t('tgtRes'))} : ${esc(taken.join(' · '))} <span class="muted">(${esc(t('tgtResNote'))})</span></p>` : '');
}
/* ---- the target: its stats (ENEMIES: level, Defense, Evasion), what each debuff takes off, you against it ---- */
// The pDIF cap of a weapon's skill (atelier/engine/helpers.js melee_pdif_base_cap), before the PDL trait and gear
const PDIF_CAP = s => /^(katana|dagger|sword|axe|club)$/i.test(s || '') ? 3.25 : /great katana|hand-to-hand/i.test(s || '') ? 3.5
  : /great sword|staff|great axe|polearm/i.test(s || '') ? 3.75 : /scythe/i.test(s || '') ? 4.0 : /marksmanship|archery/i.test(s || '') ? 3.5 : 3.25;
function targetInfo(s){
  const b = buffState(), B = withAftermath(buffTotals(), s ? (withWeapons(s).pieces.main || {}).name : null), name = enemyKey(b.enemy), [lv, def, eva, vit, agi, mnd, int] = ENEMIES[name];
  const by = B._by.filter(e => ['edefp', 'eeva', 'emdb', 'emeva'].includes(e.k));
  const defDown = Math.min(B.edefp || 0, 1), defAfter = Math.max(1, Math.round(def * (1 - defDown))), evaAfter = Math.max(0, eva - (B.eeva || 0));
  const r = s ? charStats(s) : null, d = data(), pieces = s ? withWeapons(s).pieces : {};
  const two = r && r.cur && r.cur.wskill && TWO_HANDED.test(r.cur.wskill), dual = !!(pieceStats(pieces.sub) || {}).weapon;
  // main hand: 95 % with a two-handed weapon, else 99 % even when dual wielding (the off hand alone caps at 95: BG Wiki Hit Rate)
  const cap = two ? 95 : 99;
  const at = k => r && r.out[k] ? r.out[k].set : null, gear = k => r ? ((r.set[k] || {}).v || 0) : 0;
  // pDIF cap: the weapon skill's, plus the job's PDL trait, times the PDL of gear and buffs
  const wskill = r && r.cur ? r.cur.wskill : null, c = r ? r.c : null;
  const pdlTrait = c ? traitOf('pdl', c) / 100 : 0, pdlGear = gear('pdl') + (B.pdl || 0);
  const pdifCap = (PDIF_CAP(wskill) + pdlTrait) * (1 + pdlGear / 100);
  return {name, lv, def, eva, vit, agi, mnd, int, by, defDown, defAfter, evaAfter, B, cap, two, dual, wskill, pdlTrait, pdlGear, pdifCap,
    acc: at('acc'), atk: at('atk'), atkSrc: r && r.out.atk ? r.out.atk.src : null, str: at('str'), dex: at('dex'), pint: at('int'), pmnd: at('mnd')};
}
function targetCardHTML(s){
  S._tgtSet = s;
  const T = targetInfo(s), line = (l, a, b) => statLi(esc(l), b !== a ? `${a} → ${b}` : `${a}`);
  const body = `<ul class="statlist">${line(t('tgtDef'), T.def, T.defAfter)}${line(t('tgtEva'), T.eva, T.evaAfter)}</ul>` +
    `<div class="bcardacts"><button class="btn ghost" data-targetopen>${t('tgtOpen')}</button></div>`;
  return box('g-off', t('tgtTitle'), body, `<span class="meta">${esc(T.name)}${T.lv ? ' · Lv' + T.lv : ''}</span>`);
}
// You against the target, a line a pair: your stat | its stat (no debuff → with) | what it gives | where you stand
function vsTableHTML(T){
  const r1 = n => Math.round(n * 10) / 10, r2 = n => Math.round(n * 100) / 100, sg = n => (n > 0 ? '+' : n < 0 ? '−' : '±') + Math.abs(r1(n));
  // its stat: the base, then with your debuffs (the same twice when none lowers it)
  const pair = (a, b) => `<span class="base">${a}</span></td><td class="it"><b>${b}</b>`;
  const rate = e => Math.floor(Math.max(20, Math.min(T.cap, 75 + 0.5 * (T.acc - e))));
  const needAcc = T.evaAfter + 2 * (T.cap - 75), needAtk = Math.ceil(T.pdifCap * T.defAfter);
  const pill = (good, text) => `<span class="vpill ${good ? 'ok' : 'short'}">${text}</span>`;
  const row = (label, you, it, res, state = '') => `<tr><th>${label}</th><td class="me">${you}</td><td class="vs">vs</td><td class="it">${it}</td>` +
    `<td class="res">${res}</td><td class="st">${state}</td></tr>`;
  let rows = row(`${t('vsAcc')} / ${t('vsEva')}`, T.acc, pair(T.eva, T.evaAfter), `${t('vsHit')} <b>${rate(T.evaAfter)} %</b> <i>cap ${T.cap}</i>`,
    pill(T.acc >= needAcc, T.acc >= needAcc ? t('vsAccSpare', {n: T.acc - needAcc}) : t('vsAccMiss', {n: needAcc - T.acc})));
  const src = T.atkSrc === 'engine' ? `<small class="muted"> ${t('atkEngine')}</small>` : T.atkSrc ? `<small class="kwarnt"> ${esc(t('atkMeasure', {w: T.atkSrc}))}</small>` : '';
  if (T.atk) rows += row(`${t('vsAtk')} / ${t('vsDef')}${src}`, T.atk, pair(T.def, T.defAfter), `${t('vsRatio')} <b>${r2(T.atk / T.defAfter)}</b> <i>${t('vsCap')} ${r2(T.pdifCap)}</i>`,
    pill(T.atk >= needAtk, T.atk >= needAtk ? t('vsAtkSpare', {n: T.atk - needAtk}) : t('vsAtkMiss', {n: needAtk - T.atk})));
  const attr = (lme, me, lit, it, note) => me != null && it != null ? row(`${lme} / ${lit}`, me, pair(it, it), `<b>${sg(me - it)}</b> <i>${note}</i>`) : '';
  rows += attr('STR', T.str, 'VIT', T.vit, t('vsStr')) + attr('DEX', T.dex, 'AGI', T.agi, t('vsDex')) +
    attr('INT', T.pint, 'INT', T.int, t('vsInt')) + attr('MND', T.pmnd, 'MND', T.mnd, t('vsMnd'));
  return `<div class="vswrap"><table class="vstable"><thead><tr><th></th><th class="me">${t('vsYou')}</th><th></th><th class="it">${t('vsItBase')}</th><th class="it">${t('vsItWith')}</th><th>${t('vsResult')}</th><th></th></tr></thead>` +
    `<tbody>${rows}</tbody></table></div>` +
    `<p class="vsnote">${t('vsNote', {w: esc(T.wskill || '—'), c: r2(T.pdifCap), p: Math.round(T.pdlTrait * 100), g: r1(T.pdlGear)})}${T.two ? ' · ' + t('twoHand') : ''}</p>`;
}
function openTarget(){
  S._tgtDlg = true;
  const T = targetInfo(S._tgtSet), r1 = n => Math.round(n * 10) / 10;
  const fx = T.by.length ? `<ul class="condlist fxlist">${T.by.map(e => `<li><b>${esc(e.src)}</b><span>${esc(fxText(e.k, e.v))}</span></li>`).join('')}</ul>` : `<p class="muted small">${t('tgtNoDebuff')}</p>`;
  const row = (l, base, after, note = '') => `<tr><th>${esc(l)}</th><td class="v">${base}</td><td class="v">${after}</td><td class="d ${after !== base ? 'up' : ''}">${note}</td></tr>`;
  const stats = `<table class="simtable"><thead><tr><th></th><th>${t('tgtBase')}</th><th>${t('tgtAfter')}</th><th></th></tr></thead><tbody>` +
    row(t('tgtDef'), T.def, T.defAfter, T.defDown ? `−${r1(T.defDown * 100)} %` : '') +
    row(t('tgtEva'), T.eva, T.evaAfter, T.B.eeva ? `−${r1(T.B.eeva)}` : '') +
    row(t('tgtMdb'), '—', T.B.emdb ? `−${r1(T.B.emdb)}` : '—') + row(t('tgtMeva'), '—', T.B.emeva ? `−${r1(T.B.emeva)}` : '—') + `</tbody></table>`;
  let you = `<p class="muted small">${t('noChar')}</p>`;
  if (T.acc != null) you = vsTableHTML(T);
  $('#overlay').innerHTML = `<div class="scrim" data-close></div><div class="dialog tgtdlg" role="dialog" aria-label="${t('tgtTitle')}">
    <header><h3>${t('tgtTitle')} : ${esc(T.name)}${T.lv ? ' · Lv' + T.lv : ''}</h3><p class="muted small">${t('tgtWhy')}</p>${targetFactsHTML(T.name)}</header>
    <div class="body"><div class="tgtgrid">${box('g-def', t('tgtVsYou'), you)}${box('g-buff', t('tgtDebuffs'), fx)}</div></div>
    <footer><button class="btn ghost" data-buffopen>${t('bChoose')}</button><button class="btn ghost" data-debugcalc>Debug</button><button class="btn" data-close>${t('close')}</button></footer></div>`;
  $('#overlay').hidden = false;
}
// The column's card: the buffs chosen (their names), a button that opens the window, then their effects
function buffCardHTML(){
  const n = buffCount(), names = [...new Set(withAftermath(buffTotals(), shownMain())._by.map(e => e.src))];
  const body = tierBarHTML() + (names.length ? `<div class="bnames">${names.map(x => `<span>${esc(x)}</span>`).join('')}</div>` : `<p class="muted small bnamesempty">${t('bNone')}</p>`) +
    `<div class="bcardacts"><button class="btn" data-buffopen>${t('bChoose')}</button><button class="btn ghost" data-buffendgame>${t('bEndgame')}</button><button class="btn ghost" data-buffreset ${n ? '' : 'disabled'}>${t('buffReset')}</button></div>`;
  return box('g-buff', t('buffsTitle'), body, `<span class="meta ${n ? 'on' : ''}">${buffTier()} · ${n ? t('buffsOn', {n}) : '—'}</span>`) + buffEffectsHTML();
}
// The window over the page: every buff and condition, two columns; it follows the page's changes
function openBuffs(){
  S._buffDlg = true;
  const sc = ($('.buffdlg .body') || {}).scrollTop;
  $('#overlay').innerHTML = `<div class="scrim" data-close></div><div class="dialog buffdlg" role="dialog" aria-label="${t('buffsTitle')}">
    <header class="bhead"><h3>${t('buffsTitle')}</h3>${tierBarHTML()}<span class="muted small" title="${esc(t('tierNote') + ' ' + t('buffNote'))}">ⓘ</span></header>
    <div class="body">${buffPanelHTML()}</div>
    <footer><span><button class="btn ghost" data-buffendgame>${t('bEndgame')}</button> ${buffCount() ? `<button class="btn ghost" data-buffreset>${t('buffReset')}</button>` : ''}</span><button class="btn" data-close>${t('close')}</button></footer></div>`;
  $('#overlay').hidden = false;
  const b = $('.buffdlg .body'); if (b && sc) b.scrollTop = sc;
}

/* ---- the panels' controls: profile bar, switches, Haste Samba's DNC, ability tips, skill lists ---- */
// The profile buttons, on the card and in the window
const tierBarHTML = () => `<div class="tierbar" role="group" aria-label="${t('tierLabel')}"><span class="muted small">${t('tierLabel')}</span>` +
  TIERS.map(x => `<button class="chip" data-bufftier="${x}" aria-pressed="${x === buffTier()}" title="${esc(t('tier' + x + 'Tip'))}">${x}</button>`).join('') + `</div>`;
// A small on / off switch (b.off[key]): the choices stay, the sums leave them out
function offSwitch(b, key){
  const on = !(b.off || {})[key];
  return `<button class="tgl" data-poff="${esc(key)}" aria-pressed="${on}" title="${esc(t('pOffTip'))}" aria-label="${esc(key)} ${on ? 'ON' : 'OFF'}"></button>`;
}
// The party DNC's menu: a main DNC and its merits, or a /DNC
const sambaHTML = b => `<span class="flbl">${esc(t('sambaWho'))}</span><select class="buffsel" data-buff="pSamba">` +
  ['', 'm4', 'm3', 'm2', 'm1', 'm0', 'sub'].map(v => `<option value="${v}" ${(b.pSamba || '') === v ? 'selected' : ''}>` +
    esc(v === 'sub' ? t('sambaSub') : t('sambaMain', {n: v ? v.slice(1) : 5, p: 5 + (v ? +v.slice(1) : 5)})) + `</option>`).join('') + `</select>`;
const jaTip = ja => ja.as === 'party' ? t('jaPartyTip', {j: ja.a.from}) + (ja.a.tpParty ? ' · TP Bonus +' + tpOfParty(ja.a, buffState()) : '')
  : t('jaLvTip', {j: [].concat(ja.a.job).join('/'), l: ja.a.lvl, w: ja.as === 'main' ? t('jaMain') : t('jaSub', {l: ja.lvl})});
// The SMN's Summoning Magic skill for Fenrir's Impact (b.smnSkill, 600 until chosen)
const SMN_SKILLS = [400, 450, 500, 550, 600, 650, 700, 750, 800];
// A RDM's tier I Enspell given to the party with Accession (/SCH): its base damage from the caster's Enhancing Magic
// skill (BG Wiki Enspell), the receiver's Enspell damage gear on top; the damage engine works it out a hit
const EN_SKILLS = [450, 475, 500, 525, 550, 575, 600, 625, 650, 675, 700];

/* ---- the aftermath level counted ---- */
// The aftermath level the page counts: Lv.3 on an AFM3 set, else the one chosen in Buffs
const amLevel = () => isAfm3((S._curSet || {}).path) ? 3 : +(buffState().am || 0);
