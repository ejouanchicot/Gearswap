// GearSwap Atelier · what the GearSwap puts over a nuke set in game, so a nuke set is judged as it is worn
//
// A nuke is never cast in its set alone: the job lays its own sets over it, then the shared Elemental Belt puts on
// Hachirin-no-Obi or Orpheus's Sash when one of them adds enough. The page says it in plain words above the search,
// lets the player choose the fight's situation (distance, day, weather, MP), and the search (atelier/opt.js O.nuke,
// ctx.layers and ctx.nuke) counts those pieces; a slot they take in that situation is not searched.
//
//   NUKE_LAYERS[job]   the job's own sets over its nuke set, each with where the game lays it
//   nukeSituation(s)   {layers, belt, nuke, fixed, lines}: the layers that apply, the belt chosen, the spell's
//                      options (day, weather, Orpheus's bonus), the slots they take, the page's lines
//   (the block shown on a nuke set: atelier/src/screens/optimizer/optpage.ts nukeTop)
//
// @file    atelier/app/js/nuke_layers.js
// @author  ejouanchicot

// BLM: shared/jobs/blm/functions/logic/midcast_router.lua handle_elemental (not Impact: handle_impact lays its set
// alone). An .acc set is laid last over them (mb_mode 'Acc'): it covers every slot, so none of them shows under it.
const QUANPUR_SPELLS = ['Stone', 'Stone II', 'Stone III', 'Stone IV', 'Stone V', 'Stone VI', 'Stoneja', 'Stonera', 'Stonera II', 'Stonera III'];
const NUKE_LAYERS = {
  BLM: [
    {path: 'sets.midcast.MPConservation', when: 'mpLow', src: 'apply_mp_conservation'},
    {path: 'sets.midcast.ElementalMatch', when: 'obi', onlyNoAutoBelt: true, src: 'apply_elemental_match'},
    {path: 'sets.midcast.QuanpurStone', spells: QUANPUR_SPELLS, src: 'apply_quanpur'}]};
const nukeLayersApply = s => !/^sets\.midcast\.Impact/.test(s.path) && !/\.acc$/.test(s.path);
// Impact is cast only while a cloak that grants it is worn (shared/utils/equipment/impact_lock.lua, every job): body,
// covering the head; the lock puts the best one held on every set, Crepuscular first. The optimizers never search
// those two slots of an Impact set (trial.js lockChoices); a nuke is judged with the cloak on (nukeSituation)
const IMPACT_CLOAKS = ['Crepuscular Cloak', 'Twilight Cloak'];
const isImpactSet = s => !!s && /^sets\.(midcast|precast\.FC)(\.Impact\b|\["Impact"\])/.test(s.path);
function impactCloak(){
  const bodies = new Set(((ownedOf() || {}).body || []).map(x => x.name));
  return IMPACT_CLOAKS.find(n => bodies.has(n)) || null;
}

// The fight's situations the Elemental Belt reads (shared/utils/equipment/elemental_bonus.lua): Orpheus's Sash +15
// up to 1.93 yalms, +1 from 13; the obi +10 a matching day, +10 / +25 a single / double weather (a SCH storm too)
const NUKE_SITS = {
  far: {orpheus: 1, day: 0, weather: 0},
  close: {orpheus: 15, day: 0, weather: 0},
  day: {orpheus: 1, day: 1, weather: 0},
  weather: {orpheus: 1, day: 0, weather: 1},
  storm: {orpheus: 1, day: 0, weather: 2},
  daystorm: {orpheus: 1, day: 1, weather: 2}};
const OBI = 'Hachirin-no-Obi', ORPHEUS = "Orpheus's Sash";
const obiBonus = sit => 10 * sit.day + (sit.weather === 2 ? 25 : sit.weather === 1 ? 10 : 0);

Object.assign(T.fr, {nlTitle: 'En jeu, ton GearSwap change aussi', nlSit: 'Situation du combat',
  nlSit_far: 'Loin de la cible, rien d’assorti', nlSit_close: 'Collé à la cible', nlSit_day: 'Jour de l’élément du sort',
  nlSit_weather: 'Météo de l’élément', nlSit_storm: 'Tempête SCH ou double météo', nlSit_daystorm: 'Jour + tempête',
  nlBelt: 'Ceinture : {o} ou {h} se met toute seule quand elle rapporte au moins {m} %.',
  nlBeltOn: '→ Ici : {b} (+{v} %), la ceinture du set n’est pas portée.', nlBeltOff: '→ Ici : aucune ne rapporte assez, la ceinture du set reste.',
  nlBeltMiss: 'Tu n’as pas : {l}.', nlBeltDisabled: 'Ceinture automatique coupée (_common/gear/ELEMENTAL_BELT_CONFIG.lua) : la ceinture du set reste toujours.',
  nlLayer_mpLow: '{slot} : {p} (set {set}) quand il te reste moins de {mp} MP.', nlMpLow: 'Juger sous {mp} MP',
  nlLayer_obi: '{slot} : {p} (set {set}) quand le jour ou la météo vont avec le sort.',
  nlLayer_spells: '{slot} : {p} (set {set}) sur {l}.',
  nlFixed: 'Ces pièces ne sont pas cherchées : en jeu, elles remplacent celles du set ({l}).',
  nlAcc: 'Ce set est posé en dernier (mode Magic Burst Acc) : il passe par-dessus tout, sauf la ceinture automatique.',
  nlCloak: 'Corps : {c}, tête vide. Impact ne se lance qu’avec ce manteau, qui couvre aussi la tête : ces deux emplacements ne sont jamais cherchés.',
  nlCloakSet: 'Ton set a {b} au corps : en jeu, ton GearSwap met le manteau à la place.', nlCloakMiss: 'Tu n’as ni Crepuscular Cloak ni Twilight Cloak : calculé avec le Twilight Cloak.'});
Object.assign(T.en, {nlTitle: 'In game, your GearSwap also changes', nlSit: 'Fight situation',
  nlSit_far: 'Away from the target, nothing matching', nlSit_close: 'Next to the target', nlSit_day: 'Day of the spell’s element',
  nlSit_weather: 'Weather of the element', nlSit_storm: 'SCH storm or double weather', nlSit_daystorm: 'Day + storm',
  nlBelt: 'Belt: {o} or {h} goes on by itself when it adds at least {m} %.',
  nlBeltOn: '→ Here: {b} (+{v} %), the set’s belt is not worn.', nlBeltOff: '→ Here: neither adds enough, the set’s belt stays.',
  nlBeltMiss: 'You do not have: {l}.', nlBeltDisabled: 'Automatic belt off (_common/gear/ELEMENTAL_BELT_CONFIG.lua): the set’s belt always stays.',
  nlLayer_mpLow: '{slot}: {p} ({set} set) when you have less than {mp} MP left.', nlMpLow: 'Judge under {mp} MP',
  nlLayer_obi: '{slot}: {p} ({set} set) when the day or weather match the spell.',
  nlLayer_spells: '{slot}: {p} ({set} set) on {l}.',
  nlFixed: 'These pieces are not searched: in game they replace the set’s ({l}).',
  nlAcc: 'This set goes on last (Magic Burst Acc mode): it covers everything but the automatic belt.',
  nlCloak: 'Body: {c}, head empty. Impact is cast only with this cloak, which covers the head too: these two slots are never searched.',
  nlCloakSet: 'Your set has {b} on the body: in game your GearSwap puts the cloak instead.', nlCloakMiss: 'You have neither Crepuscular Cloak nor Twilight Cloak: worked out with the Twilight Cloak.'});

// A setting of a config file of the export (its text: a line `key = value` outside the comments), or null
function cfgSetting(fileEnd, key){
  const f = ((data() || {}).configs || []).find(c => c.file.endsWith(fileEnd));
  if (!f) return null;
  const code = f.text.split(/\r?\n/).filter(l => !/^\s*--/.test(l)).join('\n');
  const m = new RegExp('\\b' + key + '\\s*=\\s*([\\w.]+)').exec(code);
  return m ? m[1] : null;
}
function autoBelt(){
  const on = cfgSetting('/ELEMENTAL_BELT_CONFIG.lua', 'enabled'), min = +cfgSetting('/ELEMENTAL_BELT_CONFIG.lua', 'min_bonus');
  return {on: on !== 'false', min: min > 0 ? min : 5};
}
const mpThreshold = () => +cfgSetting('_MP_CONFIG.lua', 'mp_threshold') || 1000;
const setPieces = path => (((data() || {}).sets || []).find(x => x.path === path) || {}).pieces || null;
const shortSet = path => path.replace(/^sets\.midcast\./, '');

// What the game lays over this nuke set in the situation chosen (S.optOpts.nukeSit, S.optOpts.nukeMpLow)
function nukeSituation(s){
  const o = S.optOpts || {}, sit = NUKE_SITS[o.nukeSit] || NUKE_SITS.far, belt = autoBelt(), owned = new Set(((ownedOf() || {}).waist || []).map(x => x.name));
  const out = {layers: [], belt: null, nuke: {day: sit.day, weather: sit.weather, orpheus: sit.orpheus}, fixed: [], lines: []};
  if (belt.on) {
    const obi = owned.has(OBI) ? obiBonus(sit) : 0, orp = owned.has(ORPHEUS) ? sit.orpheus : 0;
    if (obi >= belt.min && obi >= orp) out.belt = {name: OBI, bonus: obi};
    else if (orp >= belt.min) out.belt = {name: ORPHEUS, bonus: orp};
    if (out.belt) out.fixed.push('waist');
  }
  if (isImpactSet(s)) {
    out.cloak = impactCloak() || IMPACT_CLOAKS[1];
    out.layers.push({pieces: {body: {name: out.cloak}, head: {name: 'empty'}}, spells: null});
    for (const slot of ['body', 'head']) if (!out.fixed.includes(slot)) out.fixed.push(slot);
  }
  if (!nukeLayersApply(s)) return out;
  for (const L of NUKE_LAYERS[S.job] || []) {
    const pieces = setPieces(L.path);
    if (!pieces || (L.onlyNoAutoBelt && belt.on)) continue;
    const on = L.spells ? true : L.when === 'mpLow' ? !!o.nukeMpLow : L.when === 'obi' ? obiBonus(sit) > 0 : false;
    if (!on) continue;
    out.layers.push({pieces, spells: L.spells || null});
    if (!L.spells) for (const slot of Object.keys(pieces)) if (!out.fixed.includes(slot)) out.fixed.push(slot);
  }
  return out;
}

