// GearSwap Atelier · the "In combat" box of a nuke set (the right column's first block): the totals the spell is
// worked out with
//
// The set's stats below add up its pieces. This box gives what the damage is computed from: the pieces, the job's
// skill, traits, job points, gifts and merits, the buffs chosen, and what the GearSwap lays over the set in the
// situation chosen (nuke_layers.js). They come from our engine's character sheet (atelier/calc, through atelier/opt.js
// O.nuke: `sheet`); the magic accuracy and the hit rate are those of the first spell judged, against the target
// chosen. Each line's tip says where its value comes from. None with the old engine: it keeps no such sheet.
//
//   (the box itself: atelier/src/screens/sets/figures.ts fightBox, which reads fightFigures below)
//
// @file    atelier/app/js/fight_stats.js
// @author  ejouanchicot

Object.assign(T.fr, {fightTab: 'En combat : dégâts du sort et totaux',
  fightHead: 'Pour {sp} contre {foe}', fightMab: 'Bonus d’attaque magique', fightMacc: 'Précision magique', fightHit: 'Taux de toucher',
  fightMdmg: 'Dégâts magiques (Magic Damage)', fightMbd: 'Dégâts magic burst', fightMbd2: 'Dégâts magic burst II', fightCrit: 'Critique magique',
  fightCrit2: 'Critique magique II', fightInt: 'INT',
  fightFrom: 'Pièces du set : {g} · le reste (job, traits, job points, gifts, merits, buffs{l}) : {r}',
  fightLayers: ', pièces que ton GearSwap met en plus',
  fightMaccFrom: 'Skill {sk} {a} + skill de précision magique de l’arme {w} + précision magique {m} + écart d’INT avec la cible ({d} INT) {i}{x}',
  fightMaccMb: ' + Magic Burst {b}', fightMaccRest: ' + autre {o}',
  fightHitCap: 'Plafond du jeu : 95 %. La cible a {e} en évasion magique.', fightMbdCap: 'Tes pièces font {v} % : le jeu en compte {c} au plus.',
  fightMbdAll: 'Bonus magic burst total', fightMbdAllFrom: 'Magic burst damage {a} % (plafonné à {c}) + magic burst damage II {b} % + trait, gifts et job points du job {t} %',
  fightNone: 'Le détail en combat vient de notre moteur : choisis-le en haut de la page.',
  fightFell: 'Notre moteur ne sait pas encore compter ce cas, l’ancien a fait le calcul (sans ce détail). La raison : {w}.',
  fightWhyAbil: '{a} est activé dans Buffs & cible et notre moteur ne le connaît pas encore : coupe-le pour voir le détail',
  fightWhyBase: 'les stats de base de {j} ne sont pas dans ton export : refais //gs c atelier sur ce job'});
Object.assign(T.en, {fightTab: 'In combat: the spell’s damage and totals',
  fightHead: 'For {sp} against {foe}', fightMab: 'Magic attack bonus', fightMacc: 'Magic accuracy', fightHit: 'Hit rate',
  fightMdmg: 'Magic Damage', fightMbd: 'Magic burst damage', fightMbd2: 'Magic burst damage II', fightCrit: 'Magic critical hit',
  fightCrit2: 'Magic critical hit II', fightInt: 'INT',
  fightFrom: 'Set’s pieces: {g} · the rest (job, traits, job points, gifts, merits, buffs{l}): {r}',
  fightLayers: ', pieces your GearSwap adds',
  fightMaccFrom: '{sk} skill {a} + weapon’s magic accuracy skill {w} + magic accuracy {m} + INT difference with the target ({d} INT) {i}{x}',
  fightMaccMb: ' + Magic Burst {b}', fightMaccRest: ' + other {o}',
  fightHitCap: 'The game’s cap: 95 %. The target has {e} magic evasion.', fightMbdCap: 'Your pieces make {v} %: the game counts {c} at most.',
  fightMbdAll: 'Total magic burst bonus', fightMbdAllFrom: 'Magic burst damage {a} % (capped at {c}) + magic burst damage II {b} % + the job’s trait, gifts and job points {t} %',
  fightNone: 'The combat detail comes from our engine: choose it at the top of the page.',
  fightFell: 'Our engine does not count this case yet, the old one worked it out (without this detail). The reason: {w}.',
  fightWhyAbil: '{a} is on in Buffs & target and our engine does not know it yet: turn it off to see the detail',
  fightWhyBase: '{j}’s base stats are not in your export: run //gs c atelier again on this job'});

// The sheet's names and the stats tab's keys (stats.js STAT_DEF) of the lines shown, in order; pct: a percent
const FIGHT_LINES = [
  {sheet: 'Magic Attack', key: 'mab', label: 'fightMab'},
  {sheet: 'Magic Damage', key: 'mdmg', label: 'fightMdmg'},
  {sheet: 'Magic Burst Damage', key: 'mbd', label: 'fightMbd', pct: true, cap: () => CALC.BURST_GEAR_CAP},
  {sheet: 'Magic Burst Damage II', key: 'mbd2', label: 'fightMbd2', pct: true},
  {sheet: 'Magic Crit Rate', label: 'fightCrit', pct: true},
  {sheet: 'Magic Crit Rate II', label: 'fightCrit2', pct: true},
  {sheet: 'INT', key: 'int', label: 'fightInt'}];

// The magic accuracy's parts, as atelier/calc/calc_magic.js magicAccuracy adds them, and its tip
function fightMaccTip(sheet, enemy, name, burst, total){
  const sp = (CALC.SPELLS || {})[name] || {}, skill = sp.skill || 'Elemental Magic', dint = (sheet.INT || 0) - (enemy.INT || 0);
  const parts = {a: sheet[skill + ' Skill'] || 0, w: sheet['main Magic Accuracy Skill'] || 0, m: sheet['Magic Accuracy'] || 0,
    i: skill === 'Ninjutsu' ? 0 : CALC.dIntMagicAccuracy(dint), b: burst ? CALC.MAGIC_ASSUME.burstMagicAccuracy : 0};
  const other = Math.round(total - parts.a - parts.w - parts.m - parts.i - parts.b);
  return t('fightMaccFrom', {sk: skill, a: parts.a, w: parts.w, m: parts.m, d: signed(dint), i: parts.i,
    x: (burst ? t('fightMaccMb', {b: parts.b}) : '') + (other ? t('fightMaccRest', {o: other}) : '')});
}

// Why the totals cannot be shown: the old engine chosen, or the reason our engine handed the case to it
function fightWhyNot(fell){
  if (engineName() !== 'own') return t('fightNone');
  const why = (fell || []).map(x => { let m;
    if ((m = /^ability on: (.+)$/.exec(x))) return t('fightWhyAbil', {a: m[1]});
    if ((m = /^base attributes unknown for (.+)$/.exec(x))) return t('fightWhyBase', {j: m[1].toUpperCase()});
    return x; });
  return t('fightFell', {w: why.join(' ; ') || '?'});
}
// The engine's figures for the set as shown, worked out again only when the set, the situation or the page's inputs change
let FIGHT_MEMO = {key: null, out: null};
function fightFigures(s){
  const input = nukeContextInput(s), pieces = optPieces(withWeapons(s).pieces), key = JSON.stringify([engineName(), input, pieces]);
  if (FIGHT_MEMO.key !== key) {
    let out = null;
    // what made our engine hand the case to the old one (calc_bridge.js FFXI.engine.fell: the counts that went up)
    const E = FFXI.engine || {fell: {}}, before = Object.assign({}, E.fell);
    try { const ctx = FFXI.opt.context(input); out = {ctx, input, r: FFXI.opt.nuke(ctx, pieces)}; } catch (e) { out = null; }
    if (out) out.fell = Object.keys(E.fell || {}).filter(k => E.fell[k] > (before[k] || 0));
    FIGHT_MEMO = {key, out};
  }
  return FIGHT_MEMO.out;
}
