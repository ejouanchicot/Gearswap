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
// What counts when: Geomancy+, the luopan's HP and the Bagua Charm are taken when the Geo- spell is cast (the cast
// set: sets.midcast.Geo); its damage taken and Regen follow the set worn while it is out. So a worn set's box reads the
// cast-time part from the cast set, and the cast set's box shows only that part. The stats optimizer follows the same
// split (stat_opt.js: luDt and luRegen for the worn sets, geomancy, geoSkill and luCharm for the cast set).
// With HP from the gear the loss a tick rises about as much (the guide: "the luopan is bigger, not longer lived"):
// the page scales it by the same share and says so.
// (loaded by atelier/index.html after stat_opt.js: see the list there)

Object.assign(T.fr, {
  luTitle: 'Luopan', luCastTitle: 'Luopan (au cast)', luDt: 'Dégâts subis', luDtGear: 'pièces {g} % sur {n} utiles', luDtShort: 'il manque {n} %', luDtOver: '{n} % en trop',
  luDtTip: 'Le luopan a −50 % de lui-même ; le total est plafonné à −87,5 %, donc 37,5 % au plus viennent des pièces.',
  luHp: 'PV', luHpGear: 'dont +{n} des pièces', luRegen: 'Regen', luRegenTip: 'Retiré de ce qu’il perd à chaque tick (3 s).',
  luCharm: 'Bagua Charm', luCharmTip: 'Luopan Duration +{p} % : {n} PV de moins perdus par tick.',
  luGeo: 'Geomancy+', luGeoFrom: '{p}', luGeoTip: 'La plus haute des pièces portées compte, pas leur somme.', luGeoNone: 'aucune pièce',
  luLife: 'Durée de vie sans dégâts reçus', luCase: 'Situation', luLoss: 'Perte / tick', luTicks: 'Ticks', luTime: 'Durée',
  luBase: 'Sans rien', luLe: 'Lasting Emanation', luEa: 'Ecliptic Attrition', luBogEa: 'Blaze of Glory + Ecliptic', luBog: 'Blaze of Glory',
  luHeals: 'se soigne', luCap: '10:00 (plafond)', luScaled: 'Avec +{n} PV, la perte de base monte à peu près d’autant (compté ici : {l} au lieu de 24).',
  luFrom: 'PV et Bagua Charm : pris au cast, lus sur {s}. Dégâts subis et Regen : ceux de ce set, tant qu’il est porté.',
  luFromNone: 'PV et Bagua Charm sont pris au cast : pas de set de cast Geo- trouvé (sets.midcast.Geo), lus sur ce set.',
  luCastOnly: 'Pris au moment du cast du Geo- : Geomancy+, PV du luopan, Bagua Charm. Ses dégâts subis et son Regen viennent du set porté ensuite (tes sets luopan).',
});
Object.assign(T.en, {
  luTitle: 'Luopan', luCastTitle: 'Luopan (at cast time)', luDt: 'Damage taken', luDtGear: 'gear {g} % of the {n} that count', luDtShort: '{n} % short', luDtOver: '{n} % over cap',
  luDtTip: 'The luopan has −50 % of its own; the total stops at −87.5 %, so 37.5 % at most come from gear.',
  luHp: 'HP', luHpGear: '+{n} of it from gear', luRegen: 'Regen', luRegenTip: 'Subtracted from what it loses each tick (3 s).',
  luCharm: 'Bagua Charm', luCharmTip: 'Luopan Duration +{p} %: {n} less HP lost per tick.',
  luGeo: 'Geomancy+', luGeoFrom: '{p}', luGeoTip: 'The highest of the pieces worn counts, not their sum.', luGeoNone: 'no piece',
  luLife: 'How long it lasts when nothing hits it', luCase: 'Case', luLoss: 'Loss / tick', luTicks: 'Ticks', luTime: 'Lasts',
  luBase: 'Nothing used', luLe: 'Lasting Emanation', luEa: 'Ecliptic Attrition', luBogEa: 'Blaze of Glory + Ecliptic', luBog: 'Blaze of Glory',
  luHeals: 'heals', luCap: '10:00 (the cap)', luScaled: 'With +{n} HP the base loss rises about as much (counted here: {l} in place of 24).',
  luFrom: 'HP and Bagua Charm: taken at cast time, read from {s}. Damage taken and Regen: this set’s, while it is worn.',
  luFromNone: 'HP and Bagua Charm are taken at cast time: no Geo- cast set found (sets.midcast.Geo), read from this set.',
  luCastOnly: 'Taken when the Geo- spell is cast: Geomancy+, the luopan’s HP, Bagua Charm. Its damage taken and Regen come from the set worn afterwards (your luopan sets).',
});

// The stats optimizer's labels (stat_opt.js: objectives, their group, the floor)
Object.assign(T.fr, {
  statGrp_luopan: 'Luopan', statLuDt: 'Luopan : dégâts subis ≥',
  statObj_luDt: 'Luopan : dégâts subis', statD_luDt: 'part des pièces, comptée jusqu’aux 37,5 % utiles (−87,5 % au plus avec ses −50 %) ; set porté',
  statObj_luRegen: 'Luopan : Regen', statD_luRegen: 'PV par tick retirés de ce qu’il perd ; set porté',
  statObj_luCharm: 'Luopan : Bagua Charm', statD_luCharm: 'PV de moins perdus par tick (Luopan Duration) ; pris au cast',
  statObj_geomancy: 'Geomancy+', statD_geomancy: 'la plus haute pièce, pas la somme ; pris au cast du Geo- ou de l’Indi-',
  statObj_geoSkill: 'Skill Geomancy + Handbell', statD_geoSkill: 'les tiens + le gear ; pris au cast',
});
Object.assign(T.en, {
  statGrp_luopan: 'Luopan', statLuDt: 'Luopan damage taken ≥',
  statObj_luDt: 'Luopan: damage taken', statD_luDt: 'the gear’s share, counted up to the 37.5 % that fit (−87.5 % at most with its own −50); worn set',
  statObj_luRegen: 'Luopan: Regen', statD_luRegen: 'HP per tick, subtracted from what it loses; worn set',
  statObj_luCharm: 'Luopan: Bagua Charm', statD_luCharm: 'less HP lost per tick (Luopan Duration); taken at cast time',
  statObj_geomancy: 'Geomancy+', statD_geomancy: 'the highest piece, not the sum; taken when the Geo- or Indi- is cast',
  statObj_geoSkill: 'Geomancy + Handbell skill', statD_geoSkill: 'yours + the gear; taken at cast time',
});

const LUOPAN = {hp: 1665, loss: 24, le: 17, ea: 30, tick: 3, max: 600, own: -50, cap: -87.5};

// What one piece gives the luopan (r: its pieceStats): damage taken, Regen, HP, the Bagua Charm's duration, Geomancy+
function luopanOf(r){
  const pet = k => ((r.pet || {})[k] || {}).v || 0;
  const out = {dt: pet('dt'), regen: pet('regen'), hp: pet('hp'), duration: 0, geo: ((r.stats || {})['x:geomancy'] || {}).v || 0};
  for (const line of (r.free || []).concat(r.cond || [])) { const m = /Luopan Duration\s*\+(\d+)/i.exec(String(line)); if (m) out.duration += +m[1]; }
  return out;
}
// The HP a tick a Bagua Charm's "Luopan Duration +N %" takes off the loss
const luopanCharm = duration => Math.round(LUOPAN.loss * duration / 100);
// What a set's pieces give the luopan: the sums, and the highest Geomancy+
function luopanGear(pieces){
  const out = {dt: 0, regen: 0, hp: 0, duration: 0, geo: 0, geoFrom: ''};
  for (const [slot, p] of Object.entries(pieces || {})) {
    const r = p && !isEmpty(p) ? pieceStats(p, slot) : null;
    if (!r) continue;
    const one = luopanOf(r);
    out.dt += one.dt; out.regen += one.regen; out.hp += one.hp; out.duration += one.duration;
    if (one.geo > out.geo) { out.geo = one.geo; out.geoFrom = p.name; }
  }
  return out;
}
// Whether a set is one a Geo- spell is cast in, and the one the worn sets read the cast-time part from
// (sets.midcast.Geo, else sets.midcast.Geomancy)
const isLuopanCast = s => !!s && /^sets\.midcast\.Geo(mancy)?$/.test(s.path);
function luopanCastSet(){
  const sets = ((data() || {}).sets || []).filter(x => !x.empty && isLuopanCast(x));
  return sets.find(x => x.path === 'sets.midcast.Geo') || sets[0] || null;
}
/* ---- the stats optimizer (stat_opt.js) ---- */
// A set a Geo- or Indi- spell is cast in (Geomancy+ and the skills are taken there), and one worn with the luopan out
const isGeoCast = s => S.job === 'GEO' && !!s && /^sets\.midcast\.(Geo|Geomancy|Indi)\b/.test(s.path);
const isLuopanWorn = s => S.job === 'GEO' && !!s && /luopan|\.Pet\b/i.test(s.path) && !isGeoCast(s);
// What such a set is for when nothing was chosen (null: not one of them). The potency (Geomancy+, skills, the charm)
// only on the cast sets: worn afterwards it does nothing; the luopan's damage taken and Regen only on the worn ones
function luopanObjectives(s){
  if (isLuopanCast(s)) return ['geomancy', 'geoSkill', 'luCharm'];
  if (isGeoCast(s)) return ['geomancy', 'geoSkill', 'pdtRed'];
  return isLuopanWorn(s) ? ['luDt', 'luRegen', 'pdtRed'] : null;
}
// The luopan objectives a set is shown: the cast ones on a cast set, the worn ones on a GEO's idle and luopan sets
function luopanRelevant(s){
  if (S.job !== 'GEO') return [];
  if (isGeoCast(s)) return isLuopanCast(s) ? ['geomancy', 'geoSkill', 'luCharm'] : ['geomancy', 'geoSkill'];
  return isLuopanWorn(s) || ['idle', 'special'].includes(family(s.path, s.pieces)) ? ['luDt', 'luRegen'] : [];
}
// A piece's luopan stats for the optimizer (r: its pieceStats, all: its "All magic skills", counted once, as Geomancy)
function luopanVec(r, all){
  const one = luopanOf(r), v = k => r.stats[k] ? r.stats[k].v || 0 : 0, out = {};
  const skill = v('skill:geomancy skill') + v('skill:handbell skill') + all;
  if (one.dt) out.petdt = one.dt;
  if (one.regen) out.petregen = one.regen;
  if (one.duration) out.charm = luopanCharm(one.duration);
  if (one.geo) out.geo = one.geo;
  if (skill) out.geoskill = skill;
  return out;
}

// One line of the life table: the HP it starts with, what it loses a tick once Regen and the charm are off
function luopanLife(hp, loss, g){
  const net = loss - g.regen - luopanCharm(g.duration);
  if (net <= 0) return {net, ticks: null, secs: LUOPAN.max, heals: true};
  const ticks = Math.ceil(hp / net), secs = Math.min(ticks * LUOPAN.tick, LUOPAN.max);
  return {net, ticks, secs, capped: ticks * LUOPAN.tick >= LUOPAN.max};
}
// The luopan's figures for a worn set's pieces, the cast-time part (HP, charm, Geomancy+) from the cast set's pieces
// when given (the page's box and its test read them)
function luopanFigures(pieces, castPieces){
  const worn = luopanGear(pieces), cast = castPieces ? luopanGear(castPieces) : worn;
  const g = {dt: worn.dt, regen: worn.regen, hp: cast.hp, duration: cast.duration, geo: cast.geo, geoFrom: cast.geoFrom};
  const hp = LUOPAN.hp + g.hp, scale = hp / LUOPAN.hp;
  const useful = LUOPAN.own - LUOPAN.cap, total = Math.max(LUOPAN.own + g.dt, LUOPAN.cap);
  const base = Math.round(LUOPAN.loss * scale), le = Math.round(LUOPAN.le * scale), ea = Math.round(LUOPAN.ea * scale);
  return {g, hp, total, useful, base, rows: [
    ['luBase', luopanLife(hp, base, g)], ['luLe', luopanLife(hp, le, g)], ['luEa', luopanLife(hp, ea, g)],
    ['luBog', luopanLife(Math.floor(hp / 2), base, g)], ['luBogEa', luopanLife(Math.floor(hp / 2), ea, g)]]};
}
const luClock = secs => `${Math.floor(secs / 60)}:${String(secs % 60).padStart(2, '0')}`;
const luNumber = n => n.toLocaleString(S.lang === 'fr' ? 'fr-FR' : 'en-US');
// The cast set's box: only what the cast takes
function luopanCastHTML(s){
  const g = luopanGear(withWeapons(s).pieces), n = luopanCharm(g.duration);
  const rows = statLi(t('luGeo'), `+${g.geo}`, esc(g.geo ? t('luGeoFrom', {p: g.geoFrom}) : t('luGeoNone')), '', t('luGeoTip')) +
    statLi(t('luHp'), luNumber(LUOPAN.hp + g.hp), g.hp ? esc(t('luHpGear', {n: g.hp})) : '') +
    (g.duration ? statLi(t('luCharm'), `−${n}`, '', '', t('luCharmTip', {p: g.duration, n})) : '');
  return box('g-def', t('luCastTitle'), `<ul class="statlist big">${rows}</ul><p class="note-m">${esc(t('luCastOnly'))}</p>`);
}
// The life table of a worn set
function luopanTableHTML(f){
  const line = ([k, r]) => `<tr><th>${esc(t(k))}</th><td>${r.heals ? esc(t('luHeals')) : r.net}</td><td>${r.ticks == null ? '—' : r.ticks}</td>` +
    `<td class="${r.heals || r.capped ? 'better' : ''}">${r.heals || r.capped ? esc(t('luCap')) : luClock(r.secs)}</td></tr>`;
  return `<p class="note-m">${esc(t('luLife'))}</p><table class="rdvs optable"><thead><tr><th>${esc(t('luCase'))}</th><th>${esc(t('luLoss'))}</th>` +
    `<th>${esc(t('luTicks'))}</th><th>${esc(t('luTime'))}</th></tr></thead><tbody>${f.rows.map(line).join('')}</tbody></table>`;
}
// The box, on a GEO's set: the cast set (luopanCastHTML), or a set worn with the luopan out: one that holds damage
// taken or Regen for it, or is named for it (luopan, Pet)
function luopanHTML(s){
  if (S.job !== 'GEO' || !s) return '';
  if (isLuopanCast(s)) return luopanCastHTML(s);
  const pieces = withWeapons(s).pieces, worn = luopanGear(pieces), fam = family(s.path, s.pieces);
  // a file with no set named for the luopan: its idle and engaged sets that hold something for it
  const named = ((data() || {}).sets || []).some(x => !x.empty && isLuopanWorn(x));
  if (!(named ? isLuopanWorn(s) : (worn.dt || worn.regen) && ['idle', 'engaged'].includes(fam))) return '';
  const cast = luopanCastSet(), f = luopanFigures(pieces, cast ? withWeapons(cast).pieces : null), g = f.g;
  const gearDt = -g.dt, miss = Math.round((f.useful - gearDt) * 10) / 10, n = luopanCharm(g.duration);
  const dtNote = miss > 0 ? t('luDtShort', {n: miss}) : miss < 0 ? t('luDtOver', {n: -miss}) : '';
  let rows = statLi(t('luDt'), `${signed(f.total)} %`, `${esc(t('luDtGear', {g: gearDt, n: f.useful}))}${dtNote ? ' · ' + esc(dtNote) : ''}`, miss > 0 ? 'short' : '', t('luDtTip')) +
    statLi(t('luRegen'), signed(g.regen), '', '', t('luRegenTip')) + statLi(t('luHp'), luNumber(f.hp), g.hp ? esc(t('luHpGear', {n: g.hp})) : '');
  if (g.duration) rows += statLi(t('luCharm'), `−${n}`, '', '', t('luCharmTip', {p: g.duration, n}));
  const notes = (g.hp ? `<p class="note-m">${esc(t('luScaled', {n: g.hp, l: f.base}))}</p>` : '') +
    `<p class="note-m">${esc(cast ? t('luFrom', {s: shortPath(cast.path)}) : t('luFromNone'))}</p>`;
  return box('g-def', t('luTitle'), `<ul class="statlist big">${rows}</ul>${luopanTableHTML(f)}${notes}`);
}
