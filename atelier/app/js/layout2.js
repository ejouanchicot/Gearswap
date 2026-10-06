// GearSwap Atelier · layout2.js: the page laid out again (2026-10-06, a trial: S.ui2, one link brings the old one back)
//   Sets       the set in the middle (its pieces, what it is after); on the right the figures of THAT set only, chosen
//              by its kind (a weaponskill: its damage; engaged: time to the WS, damage; a tank or idle set: what it
//              takes; then the gear's stats), every other figure folded at the bottom; a bar on top says what the
//              figures are worked out with (the buffs' profile, the target) and opens the Combat tab
//   Combat     the buffs and conditions, the target (were the top of the right column)
//   My char    the stats measured in game, the merits, PorterPacker's list (were spread over the right column and
//              the Merits tab)
// The old layout's code is left as it was: with S.ui2 off, nothing here is used.
// (loaded by atelier/index.html after push.js: see the list there)

Object.assign(T.fr, {
  ui2Combat: 'Combat', ui2Perso: 'Mon perso', ui2Old: 'Ancienne disposition', ui2New: 'Nouvelle disposition (essai)',
  ui2OldTip: 'Revenir à la page d’avant (tout dans la colonne de droite)', ui2NewTip: 'La page réorganisée : le set au centre, ses stats à droite, Combat et Mon perso dans leurs onglets',
  ui2Ctx: 'Calculé avec', ui2CtxEdit: 'Changer', ui2SetTitle: 'Stats de ce set', ui2All: 'Toutes les stats (perso, attributs, plafonds)',
  ui2CombatWhy: 'Les buffs, la cible et le groupe avec lesquels la page calcule tout (dégâts, temps jusqu’à la WS, optimiseur). Ils valent pour tous tes sets.',
  ui2PersoWhy: 'Ce qui est propre à ton perso : tes stats mesurées en jeu, tes mérites et Job Points, ta liste PorterPacker.',
  ui2CombatTitle: 'Conditions de combat', ui2Job: 'Job', ui2Measured: 'Mesuré en jeu', ui2NotMeasured: 'pas encore (//gs c atelier)',
});
Object.assign(T.en, {
  ui2Combat: 'Combat', ui2Perso: 'My character', ui2Old: 'Old layout', ui2New: 'New layout (trial)',
  ui2OldTip: 'Back to the page as before (everything in the right column)', ui2NewTip: 'The page laid out again: the set in the middle, its stats on the right, Combat and My character in their tabs',
  ui2Ctx: 'Worked out with', ui2CtxEdit: 'Change', ui2SetTitle: 'This set’s stats', ui2All: 'Every stat (character, attributes, caps)',
  ui2CombatWhy: 'The buffs, target and party the page works everything out with (damage, time to the WS, optimizer). They hold for all your sets.',
  ui2PersoWhy: 'What is your character’s own: your stats measured in game, your merits and Job Points, your PorterPacker list.',
  ui2CombatTitle: 'Combat conditions', ui2Job: 'Job', ui2Measured: 'Measured in game', ui2NotMeasured: 'not yet (//gs c atelier)',
});

const ui2 = () => S.ui2 !== false;

// The tabs of a job: Sets, Combat, My character, Simulate, then the job's settings
function ui2Sections(d){
  return [['sets', t('sectionsSets'), d.sets.length], ['combat', t('ui2Combat'), ''], ['perso', t('ui2Perso'), ''], ['sim', t('sectionsSim'), ''],
    ['keys', t('sectionsKeys'), keysShown(d).length], ['modes', t('sectionsModes'), ''], ['macro', t('sectionsMacro'), ''], ['functions', t('sectionsFunctions'), '']];
}
function ui2Toggle(){
  return `<button class="linkbtn ui2toggle" data-ui2="${ui2() ? 'off' : 'on'}" title="${esc(t(ui2() ? 'ui2OldTip' : 'ui2NewTip'))}">${esc(t(ui2() ? 'ui2Old' : 'ui2New'))}</button>`;
}

// The set shown in the Sets tab (the Combat and My character tabs work out their figures with it)
function ui2CurrentSet(d){
  if (S._curSet && d.sets.includes(S._curSet)) return S._curSet;
  const {cards} = buildCards(d), i = Math.min(S.sel[S.job] || 0, cards.length - 1);
  return cards[i] ? shownSet(cards[i], i) : null;
}

// The bar over the sets: what every figure is worked out with, one click to the Combat tab
function ui2CtxBar(){
  const b = buffState();
  return `<div class="ctxbar"><span class="muted small">${esc(t('ui2Ctx'))}</span> <b>${esc(buffTier())}</b> · ${esc(enemyKey(b.enemy))}` +
    ` <button class="linkbtn" data-section="combat">${esc(t('ui2CtxEdit'))}</button></div>`;
}

// The right column: this set's figures, by its kind; then the gear's stats; the rest folded
function setPanelHTML(s){
  S._curSet = s;
  const r = charStats(s), fam = family(s.path, s.pieces);
  const offense = r && (fam === 'ws' || fam === 'engaged') ? offenseHTML(r, s) : '';
  const defense = r && !offense ? tankHTML(r) : '';
  const all = `<details class="lgfold ui2all"><summary>${esc(t('ui2All'))}</summary>${globalsHTML(s, 'stats')}</details>`;
  return `<div class="globals"><h3 class="ui2title">${esc(t('ui2SetTitle'))}</h3>${offense}${defense}${hpCycleHTML(s)}${setStatsHTML(s)}${all}</div>`;
}

// Combat: a heading with the support profile and the quick actions; the buffs' editor in the page (it was a window),
// in two columns
function renderCombat(d){
  const s = ui2CurrentSet(d), n = buffCount();
  const head = `<header class="tabhead"><div><h2>${esc(t('ui2CombatTitle'))}</h2><p class="muted small">${esc(t('ui2CombatWhy'))}</p></div>` +
    `<div class="tabacts">${tierBarHTML()}<button class="btn ghost" data-buffendgame>${t('bEndgame')}</button>` +
    `<button class="btn ghost" data-buffreset ${n ? '' : 'disabled'}>${t('buffReset')}</button></div></header>`;
  // two columns: you and the party's support on the left, the target and its debuffs on the right, then what is
  // active (buffPanelHTML ends with its two columns: the effects go at the bottom of the right one)
  const panel = buffPanelHTML().replace(/<\/div><\/div>$/, `${buffEffectsHTML()}</div></div>`);
  return `<div class="ui2tab combattab">${head}${panel}</div>`;
}

// My character: who (job, levels, when measured), the stats measured in game, PorterPacker, then the merits
function renderPerso(d){
  const s = ui2CurrentSet(d), c = measuredChar && measuredChar(), lv = jaLevels();
  const facts = [[t('ui2Job'), `${S.job}/${d.sub || '—'}`], ['Master Level', lv.ml || '—'], ['Job Points', (c && c.jp_spent) || '—'],
    [t('ui2Measured'), c && c.at ? `${c.at} · /${c.sub || '—'}` : t('ui2NotMeasured')]];
  const head = `<header class="tabhead"><div><h2>${esc(S.char)}</h2><p class="muted small">${esc(t('ui2PersoWhy'))}</p></div>` +
    `<dl class="herofacts">${facts.map(([k, v]) => `<div><dt>${esc(k)}</dt><dd>${esc(String(v))}</dd></div>`).join('')}</dl></header>`;
  const cards = s && charStats(s) ? globalsHTML(s, 'cards') : `<p class="muted">${t('noChar')}</p>`;
  return `<div class="ui2tab persotab">${head}<div class="persogrid">${cards}${porterHTML(true)}</div>` +
    `<h3 class="tabsec">${esc(t('sectionsMerits'))}</h3>${renderMerits(d)}</div>`;
}

// What the set is after, one line under its pieces (the stats themselves are on the right)
function ui2Wants(s){
  const w = wantsLine(s);
  return w ? `<p class="ui2wants small">${w}</p>` : '';
}
