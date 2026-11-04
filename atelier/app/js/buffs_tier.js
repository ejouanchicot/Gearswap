// GearSwap Atelier · buffs_tier.js: the support profiles (Full, Group, Solo, Trust) as GearSwap picks the weaponskill
// and engaged sets, each its own party buffs, and what follows the set opened (the profile, the subjob, the
// objective). Out of buffs.js, whose buffs it keeps (loaded right after it: see atelier/src/legacy/files.ts)

// The sets GearSwap wears a .Group / .Solo version of, by the party's support (support_tier.lua)
const TIERED = /^sets\.(precast\.WS|engaged|luopan\.engaged)\b/;
// Support profiles, as GearSwap picks the weaponskill and engaged sets (shared/utils/party/support_tier.lua): Full (a GEO
// and a BRD or a COR), Group (one of them), Solo (none), Trust (all the support from trusts). Each keeps its own party
// buffs; what is yours or the target's (PERSONAL) follows you from one profile to the next. Full is the character's
// original profile.
const TIERS = ['Full', 'Group', 'Solo', 'Trust'];
// The Trust profile: Sylvie (UC), Ulmia, Joachim, Qultada and an alt RDM (Kaories), from BG Wiki
// (BGWiki:Trusts, 2026-10-05); what it does not give is taken at its lowest
// - Sylvie: Indi-Fury +37.5 % (Geomancy +1 here: 37.4 %; Indi-Precision when your hit rate is low), Entrust
//   Indi-Frailty -12.5 % Defense (the page's 14.8 % x .845), her Haste replaced by the RDM's Haste II
// - Joachim and Ulmia: March and Madrigal each, no instrument or gear bonus (Joachim's said, Ulmia's taken so):
//   Victory and Advancing March (with Haste II over the Magic Haste cap either way), Blade and Sword Madrigal
// - Qultada: Chaos and Fighter's Roll, no Rolls+; he Double-Ups any 1 to 6 short of the lucky number: his
//   average without Snake Eye is Chaos 17.2 % (IX: 17.18 %) and Fighter's 6.8 (X: 7), Light Shot on Dia
// - the RDM: Protect V and Shell V (a RDM's at 77 and 87, res/spells.lua), Haste II, Dia III, Distract III
//   (Gravity: no damage)
const TRUST_BUFFS = {protect: 'Protect V', shell: 'Shell V', haste: 'Haste II',
  song0: 'Victory March', song1: 'Advancing March', song2: 'Blade Madrigal', song3: 'Sword Madrigal', songsPlus: '0',
  roll0: 'Chaos', roll0n: 'IX', roll1: "Fighter's", roll1n: 'X', rollsPlus: '0', lightshot: true,
  indi: 'Fury', entrust: 'Frailty', geoPlus: '1', geoScale: {entrust: .125 / .148},
  dia: 'Dia III', distract: 'Distract III', autoSamba: true};
const PERSONAL = ['food', 'am', 'amStage', 'amTp', 'enemy', 'ja', 'jaOff', 'autoSamba'];
// What each situation starts with (and what "Typical buffs" puts back), as the player describes his parties
// (2026-10-11); the support's gear at its best, as ENDGAME_BUFFS has it:
//   Full   COR + BRD + GEO, a RDM and a WHM: the end-game party. The RDM lands Distract III under Saboteur with
//          Lethargy Gantherots +3, Dia III, Haste II; the WHM Protect V and Shell V
//   Group  BRD + COR + RDM, no GEO: the same songs and rolls, the RDM's Haste II, Dia III and Distract III
//          WITHOUT Saboteur
//   Solo   you and a RDM: Haste II, Dia III, Distract III without Saboteur (the alt's leveling profile); a WHM in
//          its place is one click in the party
//   Trust  you and the trusts (TRUST_BUFFS, by job)
const GEO_KEYS = ['indi', 'geo', 'entrust', 'geoPlus', 'bolster', 'bog', 'ecliptic'];
const TIER_START = {
  Full: b => Object.assign(b, {distract: 'Distract III', saboteur: true, sabGloves: true}),
  Group: b => { for (const k of GEO_KEYS.concat(['protect', 'shell'])) delete b[k]; return Object.assign(b, {distract: 'Distract III'}); },
  Solo: () => ({haste: 'Haste II', dia: 'Dia III', distract: 'Distract III', autoSamba: true})};
// The Trust profile for a job: Sylvie's bubbles follow your job (BG Wiki: Fury + Entrust Frailty for a melee job,
// Haste + Entrust Refresh or Regen for PLD / RUN / NIN, magic bubbles for a mage or a BRD: none of those on the
// damage), and a BRD sings its own songs (the trusts' left for it to set)
const SYLVIE_FURY = ['WAR', 'MNK', 'THF', 'BST', 'DRK', 'DRG', 'SAM', 'BLU', 'PUP', 'DNC', 'RNG', 'COR'];
function trustBuffsFor(job){
  const b = JSON.parse(JSON.stringify(TRUST_BUFFS));
  if (!SYLVIE_FURY.includes(job)) {
    delete b.indi; delete b.entrust; delete b.geoScale;
    if (['PLD', 'RUN', 'NIN'].includes(job)) b.indi = 'Haste';
  }
  if (job === 'BRD') for (const k of ['song0', 'song1', 'song2', 'song3']) delete b[k];
  return b;
}
function tierBuffs(tier){ return tier === 'Trust' ? trustBuffsFor(S.job) : (TIER_START[tier] || TIER_START.Full)(endgameBuffs()); }
const buffTier = () => (S.buffTier || {})[S.char] || 'Full';
// the Trust profile's buffs are a job's own (the trusts act by your job: trustBuffsFor)
const buffKey = (tier = buffTier()) => tier === 'Full' ? S.char : tier === 'Trust' ? S.char + '|' + S.job + '|Trust' : S.char + '|' + tier;
// the Trust profile was the character's before it became a job's (2026-10-05): the WAR's takes it back
function trustCarried(k){
  const old = S.char + '|Trust';
  if (!S.buffs[k] && S.buffs[old] && S.job === 'WAR' && k === S.char + '|WAR|Trust') { S.buffs[k] = S.buffs[old]; delete S.buffs[old]; }
}
const buffState = () => { if (S._buffOverride) return S._buffOverride;
  const k = buffKey(); trustCarried(k); return (S.buffs[k] = S.buffs[k] || tierBuffs(buffTier())); };
// A profile's buffs: its own, or (never opened yet) its usual party buffs with what is yours from the profile shown
function tierBuffsOf(tier){
  if (S.buffs[buffKey(tier)]) return S.buffs[buffKey(tier)];
  const b = tierBuffs(tier), cur = buffState();
  for (const k of PERSONAL) if (cur[k] !== undefined) b[k] = cur[k];
  return b;
}
// fn() worked out with another profile's buffs
function withTierBuffs(tier, fn){
  const keep = S._buffOverride, b = tierBuffsOf(tier);
  S._buffOverride = b;
  try { return fn(); } finally { S._buffOverride = keep; }
}
// The buffs follow the set opened (once, when it changes): a .Group, .Solo or .Trust version opens that profile, a weaponskill
// or engaged set that has such versions opens Full; another set leaves the profile as it is
function tierFollowsSet(path, bypath){
  const at = S.char + '|' + S.job + '|' + path;
  if (!path || at === S._tierPath) return;
  S._tierPath = at;
  const v = (path.match(/\.(Group|Solo|Trust)$/) || [])[1];
  const tier = v || (TIERED.test(path) && (bypath[path + '.Group'] || bypath[path + '.Solo'] || bypath[path + '.Trust']) ? 'Full' : null);
  if (tier && tier !== buffTier()) { setBuffTier(tier); save(); setTimeout(render, 0); }
}
// The subjob a job plays with each way of holding its weapons: a two-handed weapon, a weapon in each hand, one
// weapon (and a shield)
const SUB_FOR_GRIP = {WAR: {two: 'SAM', dual: 'DNC', one: 'DRG'}};
// How a set holds its weapons ('two', 'dual', 'one'), null while the engine is not loaded
function gripOf(pieces){
  const it = itemOf((pieces.main || {}).name), su = itemOf((pieces.sub || {}).name);
  if (!it) return null;
  if (isTwoHanded(it)) return 'two';
  return su && su.Type === 'Weapon' ? 'dual' : 'one';
}
// The subjob follows the engaged or weaponskill set opened (once, when it changes), from its weapons; a Jump set is /DRG
function subFollowsSet(path, bypath){
  const s = bypath[path], rule = SUB_FOR_GRIP[S.job], jump = isJumpSet(path) && S.job !== 'DRG';
  const at = S.char + '|' + S.job + '|' + path;
  if (!s || at === S._subPath || !(jump || (rule && ['engaged', 'ws'].includes(family(s.path, s.pieces))))) return;
  const grip = jump ? 'jump' : gripOf(withWeapons(s).pieces);
  if (!grip) return;
  S._subPath = at;
  const sub = jump ? 'DRG' : rule[grip];
  if (sub && sub !== subOf(S.char, S.job) && allSubs(S.char, S.job).includes(sub)) { S.subs[S.char + '|' + S.job] = sub; save(); setTimeout(render, 0); }
}
// The engaged objective follows the set opened (once, when it changes): an Aftermath Lv.3 set (<Weapon>AFM3) is worn for
// its damage, DPS; another engaged set builds TP, real time to the weaponskill (a set named DPS too: PLD's sets.engaged.DPS
// and GEO's sets.luopan.engaged.DPS are the melee sets, as against the tanky / DT ones, worn to build TP fast)
function objFollowsSet(path, bypath){
  const s = bypath[path];
  const at = S.char + '|' + S.job + '|' + path;
  if (!s || at === S._objPath || family(s.path, s.pieces) !== 'engaged') return;
  S._objPath = at;
  // the whole-fight objective, once chosen, stays for every engaged set
  if ((S.optOpts || {}).engObj === 'cycle') return;
  const obj = isAfm3(path) ? 'dps' : 'tp_real';
  if ((S.optOpts || {}).engObj !== obj) { S.optOpts = Object.assign({}, S.optOpts, {engObj: obj}); save(); }
}
function setBuffTier(tier){
  if (!TIERS.includes(tier) || tier === buffTier()) return;
  const from = buffState();
  S.buffTier = Object.assign({}, S.buffTier, {[S.char]: tier});
  const to = buffState();
  for (const k of PERSONAL) { if (from[k] === undefined) delete to[k]; else to[k] = JSON.parse(JSON.stringify(from[k])); }
}
