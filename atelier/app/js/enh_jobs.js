// GearSwap Atelier · enh_jobs.js: an enhancing set's spell for any job, main or subjob (stat_opt.js enhContext).
// A set named for an enhancing spell (sets.midcast.Aquaveil, .Regen, .BarElement...) is judged on the highest tier the
// shown job can cast: the main job at its level (and the job point spells: Refresh III at 1200 spent), the subjob at
// its level (49, up to 59 with master levels: buffs.js jaLevels), never a spell its job casts as main job only
// (SPELL_MAIN_ONLY, from shared/data/magic). The job's own bonuses ride with it; the figures are opt.js
// O.enhancingFigures. Spells, levels and formulas: BG Wiki, read 2026-10-22
// (notes/docs-perso/renfort-tous-jobs-2026-10-22/SPEC.md).

Object.assign(T.fr, {enhPerpBox: 'Sous Perpetuance (×2 la durée ; ×2,25 à ×2,65 avec les Bracers)',
  enhEmbBox: 'Sous Embolden (puissance +50 %, durée −50 %)',
  enhLight: 'Light Arts compté (skill de renfort au plafond B+)', enhLightRegen: ', Regen +{p} HP par tick et +{s} s',
  enhWhmRegen: 'Regen +{p} HP par tick (merits et gift du WHM)', enhWhmBar: 'Bar-element +{p} (merits du WHM)', enhRunDur: 'durée +{p} % (gifts du RUN)',
  enhSkillOther: 'Skill de renfort lu dans l’export /{x} : fais un export avec /{s} pour celui de ce sub.'});
Object.assign(T.en, {enhPerpBox: 'Under Perpetuance (length ×2; ×2.25 to ×2.65 with the Bracers)',
  enhEmbBox: 'Under Embolden (potency +50 %, length −50 %)',
  enhLight: 'Light Arts counted (enhancing skill at the B+ cap)', enhLightRegen: ', Regen +{p} HP a tick and +{s} s',
  enhWhmRegen: 'Regen +{p} HP a tick (the WHM’s merits and gift)', enhWhmBar: 'Bar-element +{p} (the WHM’s merits)', enhRunDur: 'length +{p} % (the RUN’s gifts)',
  enhSkillOther: 'Enhancing skill read in the /{x} export: export with /{s} for this subjob’s.'});

// The spells a set's name stands for, the first that fits: [name, kind, the spells' names (the game's), their
// potency by tier, their base seconds on oneself by tier]. Tiers are listed lowest first; a kind of many spells of one
// tier (Bar-element) has one row for all
const ENH_SPELLS = [
  [/refresh/i, 'refresh', [['Refresh', 3, 150], ['Refresh II', 6, 150], ['Refresh III', 9, 150]]],
  // Regen I lasts 75 s, the others 60 (BG Wiki Category:Regen_Spell)
  [/regen/i, 'regen', [['Regen', 5, 75], ['Regen II', 12, 60], ['Regen III', 20, 60], ['Regen IV', 30, 60], ['Regen V', 40, 60]]],
  [/phalanx/i, 'phalanx', [['Phalanx', 0, 180]]],
  [/stoneskin/i, 'stoneskin', [['Stoneskin', 0, 300]]],
  [/aquaveil/i, 'aquaveil', [['Aquaveil', 0, 600]]],
  // Gain-STAT (RDM) and Boost-STAT (WHM): one formula (BG Wiki Category:Gain_Spell, Category:Boost_Spell)
  [/gain|boost/i, 'gain', [[/^(Gain|Boost)-/, 0, 300]]],
  [/temper/i, 'temper', [['Temper', 0, 180], ['Temper II', 0, 180]]],
  [/enspell/i, 'enspell', [[/^En(fire|blizzard|aero|stone|thunder|water)$/, 0, 180]]],
  [/barelement/i, 'barele', [[/^Bar(fire|blizzard|aero|stone|thunder|water)a?$/, 0, 480]]],
  [/barailment|barstatus/i, 'barail', [[/^Bar(sleep|poison|paralyze|blind|silence|petrify|virus|amnesia)a?$/, 0, 480]]],
  [/spikes/i, 'spikes', [[/^(Blaze|Ice|Shock) Spikes$/, 0, 180]]],
  [/blink/i, 'blink', [['Blink', 0, 300]]],
  [/haste|flurry/i, 'haste', [[/^(Haste|Flurry)( II)?$/, 0, 180]]],
  [/protect|shell/i, 'protect', [[/^(Protect|Shell)(ra)?( II| III| IV| V)?$/, 0, 1800]]]];
// Phalanx II: 240 s, cast on the others (a Red Mage's Composure set)
const ENH_PHALANX_OTHERS = ['Phalanx II', 0, 240];
// The kinds a job's own set ("Enhancing Magic", laid under the others) is judged on the shortest of
const ENH_BASE_KINDS = ['refresh', 'regen', 'phalanx', 'stoneskin', 'aquaveil', 'gain', 'temper', 'enspell', 'barele', 'barail', 'spikes', 'blink', 'haste', 'protect'];

// Can the job (main) or its subjob (at its level) cast the spell? A level over 99 is a main job's job point spell
// (Refresh III: 1200 spent)
function enhCastable(name, job, sub, lv, jp){
  const L = (typeof SPELL_ACCESS === 'object' && SPELL_ACCESS[name]) || {};
  const mainOnly = (typeof SPELL_MAIN_ONLY === 'object' && SPELL_MAIN_ONLY[name]) || [];
  const main = L[job] != null && (L[job] <= 99 ? L[job] <= lv.main : jp >= L[job]);
  return main || (!!sub && L[sub] != null && L[sub] <= 99 && L[sub] <= lv.sub && !mainOnly.includes(sub));
}
// The highest tier of a kind the job can cast: [name, potency, base seconds], or null
function enhTier(tiers, job, sub, lv, jp){
  let best = null;
  for (const [name, pot, base] of tiers) {
    const names = typeof name === 'string' ? [name] : Object.keys(SPELL_ACCESS || {}).filter(n => name.test(n));
    const ok = names.find(n => enhCastable(n, job, sub, lv, jp));
    if (ok) best = [ok, pot, base];
  }
  return best;
}
// The spell of a set's name (its path without "sets.midcast" and "Composure"): {kind, spell, pot, base} or null when
// the job cannot cast it; "Enhancing Magic" is judged on the shortest spell it can cast
function enhSpellOf(name, others){
  const job = S.job, sub = (data() || {}).sub, lv = jaLevels(), jp = (measuredChar() || {}).jp_spent || 0;
  if (others && /phalanx/i.test(name)) {
    const t = enhTier([ENH_PHALANX_OTHERS], job, sub, lv, jp);
    return t && {kind: 'phalanx', spell: t[0], pot: 0, base: t[2]};
  }
  const hit = ENH_SPELLS.find(k => k[0].test(name));
  if (hit) {
    const t = enhTier(hit[2], job, sub, lv, jp);
    return t && {kind: hit[1], spell: t[0], pot: t[1], base: t[2]};
  }
  if (!/enhancing/i.test(name)) return null;
  const bases = ENH_SPELLS.filter(k => ENH_BASE_KINDS.includes(k[1])).map(k => enhTier(k[2], job, sub, lv, jp)).filter(Boolean).map(t => t[2]);
  return bases.length ? {kind: 'enhancing', spell: 'enhancing', pot: 0, base: Math.min(...bases)} : null;
}

// The enhancing skill caps at 99 by job (BG Wiki Enhancing_Magic_Skill): B+ is Light Arts' (BG Wiki Light_Arts: the
// skill rises to the B+ cap of the main job's level, a /SCH too)
const ENH_SKILL_CAP99 = {RDM: 404, RUN: 388, WHM: 378, SCH: 334, PLD: 334, BLM: 300};
const ENH_LIGHT_CAP99 = 404;
// The kinds Light Arts does not touch: black magic (the Spikes)
const ENH_BLACK = new Set(['spikes']);

// The job's bonuses on an enhancing set, beside what enhContext reads for a Red Mage: {skill (the enhancing skill to
// use, or null), regenAdd, regenSec, barAdd, durMul, potMul, perp, notes[]}. Each from BG Wiki, main job only unless said
function enhJobBonus(kind, c){
  const job = S.job, sub = (data() || {}).sub, lv = jaLevels(), jp = c.jp_spent || 0, merits = c.merits || {}, o = S.optOpts || {};
  const out = {skill: null, regenAdd: 0, regenSec: 0, barAdd: 0, durMul: 1, potMul: 1, perp: false, notes: []};
  // Light Arts held up on a SCH's white magic (the player's rule, 2026-10-22: the Arts of the set clicked), main or
  // subjob: the skill at the B+ cap; a SCH main's Regen +3 HP a tick for each 10 levels past 10, twice that in seconds
  // (BG Wiki Light_Arts: +24 and +48 s at 99). An export measured under Light Arts already has it
  const sch = job === 'SCH' || sub === 'SCH', underArts = (c.buffs || []).some(b => /light arts|addendum: white/i.test(String(b)));
  if (sch && !ENH_BLACK.has(kind) && !underArts) {
    const measured = c.skills ? skillLevel(c, 'enhancing magic') : 0, ml = c.master_level || 0, cap = ENH_SKILL_CAP99[job];
    out.skill = Math.max(measured, cap != null ? measured - cap + ENH_LIGHT_CAP99 : ENH_LIGHT_CAP99 + ml);
    let regen = '';
    if (job === 'SCH' && kind === 'regen') {
      out.regenAdd = 3 * Math.floor((lv.main - 10) / 10); out.regenSec = 2 * out.regenAdd;
      regen = t('enhLightRegen', {p: out.regenAdd, s: out.regenSec});
    }
    out.notes.push(t('enhLight') + regen);
  }
  // Perpetuance (SCH 87, main): the next white enhancing spell x2, the Bracers' own figure instead (opt.js t.perp)
  if (job === 'SCH' && lv.main >= 87 && !ENH_BLACK.has(kind) && o.enhPerp) out.perp = true;
  // WHM: Regen +1 HP a tick a merit (5 at most) and +5 from the 545 job points gift; Bar-element +2 a merit (BG Wiki
  // White_Mage, Category:Barspell). The job points' seconds and Bar-element levels: not in the export, not counted
  if (job === 'WHM' && kind === 'regen') {
    out.regenAdd = Math.min(5, merits.regen_effect || 0) + (jp >= 545 ? 5 : 0);
    if (out.regenAdd) out.notes.push(t('enhWhmRegen', {p: out.regenAdd}));
  }
  if (job === 'WHM' && kind === 'barele') {
    out.barAdd = 2 * Math.min(5, merits.bar_spell_effect || 0);
    if (out.barAdd) out.notes.push(t('enhWhmBar', {p: out.barAdd}));
  }
  // RUN: enhancing spells received last 10 % longer from 100 job points spent, 10 % more from 1200 (BG Wiki
  // Rune_Fencer); Embolden (60): potency +50 % before the pieces' flat bonus, length -50 % (BG Wiki Embolden; where it
  // sits in the length's product: not on the page)
  if (job === 'RUN') {
    const gift = (jp >= 100 ? 10 : 0) + (jp >= 1200 ? 10 : 0);
    out.durMul = 1 + gift / 100;
    if (gift) out.notes.push(t('enhRunDur', {p: gift}));
    if (lv.main >= 60 && o.enhEmbolden) { out.potMul = 1.5; out.durMul *= 0.5; }
  }
  // the skill of another subjob's export: said, not guessed
  if (c.sub && sub && c.sub !== sub && !out.skill) out.notes.push(t('enhSkillOther', {x: c.sub, s: sub}));
  return out;
}
// The checkboxes of a job's enhancing set, for the stats page (statpage.ts): [{key, checked, label}]
function enhBoxes(s){
  const e = enhContext(s), lv = jaLevels(), o = S.optOpts || {};
  if (!e || ENH_BLACK.has(e.kind)) return [];
  if (S.job === 'SCH' && lv.main >= 87) return [{key: 'enhPerp', checked: !!o.enhPerp, label: t('enhPerpBox')}];
  if (S.job === 'RUN' && lv.main >= 60) return [{key: 'enhEmbolden', checked: !!o.enhEmbolden, label: t('enhEmbBox')}];
  return [];
}
// Perpetuance's figure a piece gives (BG Wiki Perpetuance): Savant's Bracers +1 / +2, Arbatel Bracers / +1 / +2 / +3
function enhPerpOf(name){
  const m = /^(Savant's|Arbatel) Bracers(?: \+(\d))?$/.exec(name || '');
  if (!m) return 0;
  const lvl = +(m[2] || 0);
  return m[1] === "Savant's" ? [0, 2.25, 2.5][lvl] || 0 : [2.5, 2.55, 2.6, 2.65][lvl] || 0;
}
