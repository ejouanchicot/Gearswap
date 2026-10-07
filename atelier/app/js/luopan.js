// GearSwap Atelier · luopan.js: a GEO's luopan with the set shown (2026-10-07): the damage it takes, how long it
// lasts, and the Geomancy+ of the set's gear. Figures from BG Wiki (Luopan, Geomancer, Lasting Emanation, Ecliptic
// Attrition, Blaze of Glory), as the player's guide sums them up:
//   - 1 665 HP at level 99, + the "Luopan: HP" of the gear (Bagua Galero +2 / +3);
//   - damage taken: -50 % of its own, + the gear's "Pet: / Luopan: Damage taken", capped at -87.5 % (so 37.5 from gear);
//   - it loses 24 HP every 3 s (17 under Lasting Emanation, 30 under Ecliptic Attrition), less its Regen and what a
//     Bagua Charm's "Luopan Duration +N %" takes off (N % of 24, rounded: 4 / 5 / 6); it leaves at 10:00 whatever its HP;
//   - Blaze of Glory: it is born at half its HP;
//   - Geomancy+: the highest of the pieces worn, not their sum (BG Wiki's columns are +5 Dunna, +6 / +7 Bagua Charm
//     +1 / +2, +10 Idris).
// With HP from the gear the loss a tick rises about as much (the guide: "the luopan is bigger, not longer lived"):
// the page scales it by the same share and says so.
// (loaded by atelier/index.html after stat_opt.js: see the list there)

Object.assign(T.fr, {
  luTitle: 'Luopan', luDt: 'Dégâts subis', luDtGear: 'pièces {g} % sur {n} utiles', luDtShort: 'il manque {n} %', luDtOver: '{n} % en trop',
  luDtTip: 'Le luopan a −50 % de lui-même ; le total est plafonné à −87,5 %, donc 37,5 % au plus viennent des pièces.',
  luHp: 'PV', luHpGear: 'dont +{n} des pièces', luRegen: 'Regen', luRegenTip: 'Retiré de ce qu’il perd à chaque tick (3 s).',
  luCharm: 'Bagua Charm', luCharmTip: 'Luopan Duration +{p} % : {n} PV de moins perdus par tick.',
  luGeo: 'Geomancy+', luGeoFrom: '{p}', luGeoTip: 'La plus haute des pièces portées compte, pas leur somme.', luGeoNone: 'aucune pièce',
  luLife: 'Durée de vie sans dégâts reçus', luCase: 'Situation', luLoss: 'Perte / tick', luTicks: 'Ticks', luTime: 'Durée',
  luBase: 'Sans rien', luLe: 'Lasting Emanation', luEa: 'Ecliptic Attrition', luBogEa: 'Blaze of Glory + Ecliptic', luBog: 'Blaze of Glory',
  luHeals: 'se soigne', luCap: '10:00 (plafond)', luScaled: 'Avec +{n} PV, la perte de base monte à peu près d’autant (compté ici : {l} au lieu de 24).',
  luCast: 'Geomancy+ et les PV du Bagua Galero comptent au moment du cast ; les dégâts subis et le Regen, tant que la pièce est portée.',
});
Object.assign(T.en, {
  luTitle: 'Luopan', luDt: 'Damage taken', luDtGear: 'gear {g} % of the {n} that count', luDtShort: '{n} % short', luDtOver: '{n} % too many',
  luDtTip: 'The luopan has −50 % of its own; the total stops at −87.5 %, so 37.5 % at most come from gear.',
  luHp: 'HP', luHpGear: '+{n} of it from gear', luRegen: 'Regen', luRegenTip: 'Taken off what it loses each tick (3 s).',
  luCharm: 'Bagua Charm', luCharmTip: 'Luopan Duration +{p} %: {n} HP less lost a tick.',
  luGeo: 'Geomancy+', luGeoFrom: '{p}', luGeoTip: 'The highest of the pieces worn counts, not their sum.', luGeoNone: 'no piece',
  luLife: 'How long it lasts when nothing hits it', luCase: 'Case', luLoss: 'Loss / tick', luTicks: 'Ticks', luTime: 'Lasts',
  luBase: 'Nothing used', luLe: 'Lasting Emanation', luEa: 'Ecliptic Attrition', luBogEa: 'Blaze of Glory + Ecliptic', luBog: 'Blaze of Glory',
  luHeals: 'heals', luCap: '10:00 (the cap)', luScaled: 'With +{n} HP the base loss rises about as much (counted here: {l} in place of 24).',
  luCast: 'Geomancy+ and the Bagua Galero’s HP count when the spell is cast; damage taken and Regen, while the piece is worn.',
});

const LUOPAN = {hp: 1665, loss: 24, le: 17, ea: 30, tick: 3, max: 600, own: -50, cap: -87.5};

// What the set's pieces give the luopan: damage taken, Regen, HP, the Bagua Charm's duration, the highest Geomancy+
function luopanGear(pieces){
  const out = {dt: 0, regen: 0, hp: 0, duration: 0, geo: 0, geoFrom: ''};
  for (const [slot, p] of Object.entries(pieces || {})) {
    const r = p && !isEmpty(p) ? pieceStats(p, slot) : null;
    if (!r) continue;
    const pet = k => ((r.pet || {})[k] || {}).v || 0;
    out.dt += pet('dt'); out.regen += pet('regen'); out.hp += pet('hp');
    const geo = ((r.stats || {})['x:geomancy'] || {}).v || 0;
    if (geo > out.geo) { out.geo = geo; out.geoFrom = p.name; }
    for (const line of (r.free || []).concat(r.cond || [])) { const m = /Luopan Duration\s*\+(\d+)/i.exec(String(line)); if (m) out.duration += +m[1]; }
  }
  return out;
}
// One line of the life table: the HP it starts with, what it loses a tick once Regen and the charm are off
function luopanLife(hp, loss, g){
  const net = loss - g.regen - Math.round(LUOPAN.loss * g.duration / 100);
  if (net <= 0) return {net, ticks: null, secs: LUOPAN.max, heals: true};
  const ticks = Math.ceil(hp / net), secs = Math.min(ticks * LUOPAN.tick, LUOPAN.max);
  return {net, ticks, secs, capped: ticks * LUOPAN.tick >= LUOPAN.max};
}
// The luopan's figures for a set's pieces (the page's box and its test read them)
function luopanFigures(pieces){
  const g = luopanGear(pieces), hp = LUOPAN.hp + g.hp, scale = hp / LUOPAN.hp;
  const useful = LUOPAN.own - LUOPAN.cap, total = Math.max(LUOPAN.own + g.dt, LUOPAN.cap);
  const base = Math.round(LUOPAN.loss * scale), le = Math.round(LUOPAN.le * scale), ea = Math.round(LUOPAN.ea * scale);
  return {g, hp, total, useful, base, rows: [
    ['luBase', luopanLife(hp, base, g)], ['luLe', luopanLife(hp, le, g)], ['luEa', luopanLife(hp, ea, g)],
    ['luBog', luopanLife(Math.floor(hp / 2), base, g)], ['luBogEa', luopanLife(Math.floor(hp / 2), ea, g)]]};
}
const luClock = secs => `${Math.floor(secs / 60)}:${String(secs % 60).padStart(2, '0')}`;
// The box, on a GEO's set that holds something for the luopan or is one of its sets (luopan, Pet, Geo-, Indi-)
function luopanHTML(s){
  if (S.job !== 'GEO' || !s) return '';
  const pieces = withWeapons(s).pieces, f = luopanFigures(pieces), g = f.g;
  if (!(g.dt || g.regen || g.hp || g.duration || /luopan|\.Pet\b|Geo|Indi/i.test(s.path))) return '';
  const gearDt = -g.dt, miss = Math.round((f.useful - gearDt) * 10) / 10;
  const dtNote = miss > 0 ? t('luDtShort', {n: miss}) : miss < 0 ? t('luDtOver', {n: -miss}) : '';
  let rows = statLi(t('luDt'), `${signed(f.total)} %`, `${esc(t('luDtGear', {g: gearDt, n: f.useful}))}${dtNote ? ' · ' + esc(dtNote) : ''}`, miss > 0 ? 'short' : '', t('luDtTip')) +
    statLi(t('luHp'), f.hp.toLocaleString(S.lang === 'fr' ? 'fr-FR' : 'en-US'), g.hp ? esc(t('luHpGear', {n: g.hp})) : '') +
    statLi(t('luRegen'), signed(g.regen), '', '', t('luRegenTip'));
  if (g.duration) rows += statLi(t('luCharm'), `−${Math.round(LUOPAN.loss * g.duration / 100)}`, '', '', t('luCharmTip', {p: g.duration, n: Math.round(LUOPAN.loss * g.duration / 100)}));
  rows += statLi(t('luGeo'), g.geo ? `+${g.geo}` : '+0', esc(g.geo ? t('luGeoFrom', {p: g.geoFrom}) : t('luGeoNone')), '', t('luGeoTip'));
  const line = ([k, r]) => `<tr><th>${esc(t(k))}</th><td>${r.heals ? esc(t('luHeals')) : r.net}</td><td>${r.ticks == null ? '—' : r.ticks}</td>` +
    `<td class="${r.heals || r.capped ? 'better' : ''}">${r.heals || r.capped ? esc(t('luCap')) : luClock(r.secs)}</td></tr>`;
  const table = `<p class="note-m">${esc(t('luLife'))}</p><table class="rdvs optable"><thead><tr><th>${esc(t('luCase'))}</th><th>${esc(t('luLoss'))}</th>` +
    `<th>${esc(t('luTicks'))}</th><th>${esc(t('luTime'))}</th></tr></thead><tbody>${f.rows.map(line).join('')}</tbody></table>`;
  const notes = (g.hp ? `<p class="note-m">${esc(t('luScaled', {n: g.hp, l: f.base}))}</p>` : '') + `<p class="note-m">${esc(t('luCast'))}</p>`;
  return box('g-def', t('luTitle'), `<ul class="statlist big">${rows}</ul>${table}${notes}`);
}
