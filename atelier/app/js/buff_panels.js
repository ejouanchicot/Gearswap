// GearSwap Atelier · buff_panels.js: aftermath, effect labels, the buffs / party / target panels and windows
// (loaded by atelier/index.html, in the order of the list there)
/* ---- aftermath of the weapon in hand (atelier/engine/player.js) ---- */
// Prime weapons: PDL by stage and level (Lv1 / Lv2 at 60 % between two steps, as the engine), Lorg Mor and Opashoro magic
const PRIME_AM_PDL = {III: [2, 5, 8], IV: [4, 7, 10], V: [6, 9, 12]}, PRIME_POT = .6;
const PRIME_PDL = new Set(['Caliburnus', 'Dokoku', 'Earp', 'Foenaria', 'Gae Buide', 'Helheim', 'Kusanagi-no-Tsurugi', 'Laphria',
  'Mpu Gandring', 'Pinaka', 'Spalirisos', 'Varga Purnikawa']);
// the magic primes: their aftermath is our engine's (atelier/calc/calc_aftermath.js), as Khatvanga's (Aeonic)
const PRIME_MAGIC = new Set(['Lorg Mor', 'Opashoro']), AEONIC_AM = ['Khatvanga'];
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
const amKind = w => !w ? 'none' : PRIME_PDL.has(w) || PRIME_MAGIC.has(w) ? 'prime' : AEONIC_AM.includes(w) ? 'aeonic' : MYTHIC_AM[w] ? 'mythic' : RELIC_AM[w] ? 'relic' : EMPYREAN_AM.includes(w) ? 'empyrean' : 'none';
// A mythic's Lv1 / Lv2 from the TP the aftermath was made with, where BG Wiki gives the formula (119 III pages): Lv1
// Accuracy floor(TP/50 + 10), Lv2 Attack floor(TP x 0.06 - 80) (the mage weapons' Magic Accuracy and Magic Attack:
// calcAftermath); else the
// engine's 85 % estimate (Magic Accuracy, Yagrush / Carnwenhan's Lv2 Accuracy BG marks unsure)
function mythicAmValue(m, lv){
  const tp = +(buffState().amTp || 0), k = m[lv - 1], est = lv === 1 || k !== 'atk' && k !== 'ratk' ? M49 : M99;
  if (!tp) return est;
  if (lv === 1 && (k === 'acc' || k === 'racc')) return Math.floor(Math.min(1999, tp) / 50 + 10);
  if (lv === 2 && (k === 'atk' || k === 'ratk')) return Math.floor(Math.max(2000, tp) * 0.06 - 80);
  return est;
}
// The engine's names of an aftermath's stats (atelier/calc/calc_aftermath.js) and the page's
const AM_STAT_KEY = {'Magic Accuracy': 'macc', 'Magic Attack': 'mab', 'Magic Damage': 'mdmg', 'Magic Burst Damage II': 'mbd2', 'Cure Potency': 'cure'};
// The aftermath of a weapon our engine counts (mythic Lv1 / Lv2 of the mage weapons, Opashoro and Lorg Mor, Khatvanga),
// at the TP chosen (else the engine's guess) and the prime stage; null for another weapon, or a mythic's Lv3 (melee:
// the mythic lines below say it). `check`: a value only one wiki gives, to check in game
function calcAftermath(weapon, lv, b){
  if (!(window.CALC && CALC.aftermathStats)) return null;
  const st = ['III', 'IV', 'V'].includes(b.amStage) ? b.amStage : ownedPrimeStage(weapon) || 'V';
  const got = CALC.aftermathStats(weapon, lv, +(b.amTp || 0), st);
  if (!got || (!Object.keys(got).length && MYTHIC_AM[weapon])) return null;
  const fx = Object.entries(got).map(([k, v]) => ({k: AM_STAT_KEY[k] || k, v}));
  const check = weapon === 'Lorg Mor' || (MYTHIC_AM[weapon] && lv === 1) || (weapon === 'Opashoro' && st === 'IV' && lv === 3);
  return {fx, note: PRIME_MAGIC.has(weapon) ? `${weapon} ${st}` : weapon, text: !fx.length ? t('amPrimeLow') : check ? t('amCheck') : ''};
}
// What the aftermath chosen in the page (level, prime stage) gives with this weapon: [{k, v}], and a note
function aftermathOf(weapon){
  const b = buffState(), lv = amLevel();
  if (!lv || !weapon) return {fx: [], note: ''};
  const ours = calcAftermath(weapon, lv, b);
  if (ours) return ours;
  if (RELIC_AM[weapon]) return {fx: Object.entries(RELIC_AM[weapon]).map(([k, v]) => ({k, v})), note: weapon};
  if (EMPYREAN_AM.includes(weapon)) return {fx: [], note: weapon, text: t(weapon === 'Verethragna' ? 'amEmpVere' : 'amEmp', {n: lv, p: [30, 40, 50][lv - 1]})};
  if (PRIME_PDL.has(weapon)) {
    const own = ownedPrimeStage(weapon), st = ['III', 'IV', 'V'].includes(b.amStage) ? b.amStage : ['III', 'IV', 'V'].includes(own) ? own : 'V', st2 = PRIME_AM_PDL[st];
    const pdl = lv === 3 ? st2[2] : lv === 2 ? (st2[2] - st2[1]) * PRIME_POT + st2[1] : (st2[1] - st2[0]) * PRIME_POT + st2[0];
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
    (['mythic', 'prime', 'aeonic'].includes(kind) && !PRIME_PDL.has(w) ? sel('amTp', ['1000', '1250', '1500', '1750', '1999', '2000', '2250', '2500', '2750', '3000'], t('amTpPh')) : '') +
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
  mbd2: ['Dégâts magic burst II', 'Magic burst damage II', '%'], cure: ['Cure potency', 'Cure potency', '%'],
  def: ['Défense', 'Defense', ''], eva: ['Évasion', 'Evasion', ''], meva: ['Évasion magique', 'Magic Evasion', ''], mdb: ['Déf. magique', 'Magic Def. Bonus', ''],
  stp: ['Store TP', 'Store TP', ''], da: ['Double Attack', 'Double Attack', '%'], ta: ['Triple Attack', 'Triple Attack', '%'],crit: ['Critiques', 'Critical hit rate', '%'], enmity: ['Enmity', 'Enmity', ''],
  hp: ['HP', 'HP', ''], mp: ['MP', 'MP', ''], regen: ['Regen', 'Regen', ''], refresh: ['Refresh', 'Refresh', ''],
  block: ['Chance de blocage', 'Block rate', '%'], cure2: ['Cure potency II', 'Cure potency II', '%'], blockmul: ['Chance de blocage', 'Block rate', 'mul'],
  pdl: ['Limite dégâts physiques', 'Physical damage limit', '%'], tpb: ['TP Bonus', 'TP Bonus', ''], sb: ['Subtle Blow', 'Subtle Blow', ''], critdmg: ['Dégâts critiques', 'Critical damage', '%'], dt: ['Dégâts reçus (DT)', 'Damage taken (DT)', '%'], enspell: ['Enspell (dégâts par coup)', 'Enspell (damage a hit)', ''], mdmg: ['Dégâts magiques', 'Magic damage', '']};
// Short labels, for a one-line summary (the party support cards)
const FX_SHORT = {edefp: ['Déf cible', 'Tgt Def'], eeva: ['Éva cible', 'Tgt Eva'], emdb: ['Déf. mag. cible', 'Tgt MDB'], emeva: ['Éva. mag. cible (info)', 'Tgt M.Eva (info)'], atkp: ['Att', 'Atk'], atk: ['Att', 'Atk'], atkf: ['Att', 'Atk'], acc: ['Préc', 'Acc'], racc: ['Préc. dist.', 'R.Acc'], ratk: ['Att. dist.', 'R.Atk'],
  def: ['Déf', 'Def'], defp: ['Déf', 'Def'], eva: ['Éva', 'Eva'], meva: ['Éva. mag.', 'M.Eva'], mdb: ['Déf. mag.', 'MDB'], macc: ['Préc. mag.', 'M.Acc'],
  mab: ['MAB', 'MAB'], mhaste: ['Haste', 'Haste'], jahaste: ['Haste JA', 'JA Haste'], shell: ['Shell', 'Shell'], stp: ['STP', 'STP'], da: ['DA', 'DA'], ta: ['TA', 'TA'],
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
function buffCount(){
  const b = buffState();
  return ['food', 'protect', 'shell', 'haste', 'storm', 'song0', 'song1', 'song2', 'song3', 'song4', 'soulVoice', 'clarion', 'roll0', 'roll1', 'indi', 'geo', 'entrust', 'bolster', 'bog', 'ecliptic', 'dia', 'lightshot', 'distract', 'am'].filter(k => b[k] && (k !== 'song4' || b.clarion)).length + (b.foeJa || []).length +
    jasOf().filter(ja => jaOn(b, ja.name)).length;
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
// A roll's two buttons: its job in the party (its bonus; on by itself when it is your job), Crooked Cards (one roll)
function rollChips(b, i){
  const rj = ROLL_JOB[b['roll' + i]], mine = rj && rj[0] === S.job;
  const job = `<button class="chip" data-rolljob="${i}" aria-pressed="${rollJobOn(b, i)}" ${!rj || mine ? 'disabled' : ''} title="${esc(rj ? t(mine ? 'rollJobMine' : 'rollJobTip', {j: rj[0]}) : '')}">${esc(rj ? rj[0] : '—')}</button>`;
  const cc = `<button class="chip" data-rollcc="${i}" aria-pressed="${b.rollCC != null && +b.rollCC === i}" ${b['roll' + i] ? '' : 'disabled'} title="${esc(t('rollCcTip'))}">CC</button>`;
  return job + cc;
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
    `aria-selected="${x === cur}" title="${esc(t('ttFoeTab', {j: x.label}))}">${esc(x.label)}</button>`).join('')}</div><span class="foetabsw">${offSwitch(b, cur.id)}</span></div>`;
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

/* ---- the panels' controls: profile bar, switches, Haste Samba's DNC, ability tips, skill lists ---- */
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
