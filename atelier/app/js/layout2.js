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
  ui2Combat: 'Buffs & cible', ui2Perso: 'Mon perso', ui2JobCfg: 'Configuration',
  fnHint: 'Les interrupteurs on / off du job : leur état au moment de l’export ({at}), ou en direct quand le jeu est connecté. À droite, la touche qui les bascule. Leurs noms sont ceux affichés en jeu.',
  keyMoteCycle: 'Changer {m}',
  macroHint: 'Le livre de macros et le lockstyle pris avec le sub affiché, puis ce que tes fichiers disent pour chaque sub.',
  ui2OldTip: 'Revenir à la page d’avant (tout dans la colonne de droite)', ui2NewTip: 'La page réorganisée : le set au centre, ses stats à droite, Combat et Mon perso dans leurs onglets',
  ui2Ctx: 'Calculé avec', ui2CtxEdit: 'Changer', ui2SetTitle: 'Stats de ce set', ui2All: 'Toutes les stats (perso, attributs, plafonds)',
  ui2CombatWhy: 'Les buffs, la cible et le groupe avec lesquels la page calcule tout (dégâts, temps jusqu’à la WS, optimiseur). Ils valent pour tous tes sets.',
  ui2PersoWhy: 'Ce qui est propre à ton perso : tes stats mesurées en jeu, tes mérites et Job Points, ta liste PorterPacker.',
  ui2CombatTitle: 'Buffs & cible', mtShort_mgCombat: 'Combat', mtShort_mgMagic: 'Magie', ui2Job: 'Job', ui2Measured: 'Mesuré en jeu', ui2NotMeasured: 'pas encore (//gs c atelier)',
});
Object.assign(T.en, {
  ui2Combat: 'Buffs & target', ui2Perso: 'My character', ui2JobCfg: 'Configuration',
  fnHint: 'The job’s on / off switches: their state when exported ({at}), or live when the game is connected. On the right, the key that flips them.',
  keyMoteCycle: 'Cycle {m}',
  macroHint: 'The macro book and the lockstyle taken with the subjob shown, then what your files say for each subjob.',
  ui2OldTip: 'Back to the page as before (everything in the right column)', ui2NewTip: 'The redesigned page: the set in the middle, its stats on the right, Combat and My character in their tabs',
  ui2Ctx: 'Calculated with', ui2CtxEdit: 'Change', ui2SetTitle: 'This set’s stats', ui2All: 'Every stat (character, attributes, caps)',
  ui2CombatWhy: 'The buffs, target and party the page uses for every calculation (damage, time to WS, optimizer). They apply to all your sets.',
  ui2PersoWhy: 'What belongs to your character: your stats measured in game, your merits and Job Points, your PorterPacker list.',
  ui2CombatTitle: 'Buffs & target', mtShort_mgCombat: 'Combat', mtShort_mgMagic: 'Magic', ui2Job: 'Job', ui2Measured: 'Measured in game', ui2NotMeasured: 'not yet (//gs c atelier)',
});

// The page has one layout since 2026-10-11 (the one before it, everything in the right column, is no longer
// offered); what still asks ui2() gets yes
const ui2 = () => true;

// The parts of the job's settings (its keys, modes, switches, macro book and lockstyle, modules: four small tabs until
// 2026-10-11, one tab with its parts since). The job's tabs themselves are the Svelte application's
// (atelier/src/screens/topbar/sections.ts)
const JOB_CFG = ['keys', 'modes', 'functions', 'macro', 'modules'];
// The part of the job's settings shown (S.jobTab, kept): the tab opened by one of the four old names lands on its part
const jobCfgTab = () => JOB_CFG.includes(S.jobTab) ? S.jobTab : 'keys';

// The set shown in the Sets tab (the Combat and My character tabs work out their figures with it)
function ui2CurrentSet(d){
  if (S._curSet && d.sets.includes(S._curSet)) return S._curSet;
  const {cards} = buildCards(d), i = Math.min(S.sel[S.job] || 0, cards.length - 1);
  return cards[i] ? shownSet(cards[i], i) : null;
}

// The bar over the sets: what every figure is worked out with, one click to the Combat tab
// `warn`: the subjob warning, on the same line (a line of its own pushed the whole page down when it came)
function ui2CtxBar(warn = ''){
  const b = buffState();
  return `<div class="ctxbar"><span class="ctxwhat" title="${esc(t('ttCtx'))}"><span class="muted small">${esc(t('ui2Ctx'))}</span></span>${profCompact()}` +
    `<span class="ctxwhat" title="${esc(t('ttCtx'))}">· ${esc(enemyKey(b.enemy))}</span>` +
    ` <button class="linkbtn" data-section="combat" title="${esc(t('ttCtxEdit'))}">${esc(t('ui2CtxEdit'))}</button>${warn}</div>`;
}

// The right column: this set's figures, by its kind; then the gear's stats; the rest folded
function setPanelHTML(s){
  S._curSet = s;
  const r = charStats(s), fam = family(s.path, s.pieces);
  // a nuke set: its damage and the totals it is worked out with (fight_stats.js), not the tanking figures
  const offense = fightBoxHTML(s) || (r && (fam === 'ws' || fam === 'engaged') ? offenseHTML(r, s) : '');
  const defense = r && !offense ? tankHTML(r) : '';
  const all = `<details class="lgfold ui2all" data-ui2all ${S._ui2AllOpen ? 'open' : ''}><summary title="${esc(t('ttAllStats'))}">${esc(t('ui2All'))}</summary>${globalsHTML(s, 'stats')}</details>`;
  // the set's own figures in a block of fixed height (sets.css .ui2own): what follows stays where it is whatever the set
  return `<div class="globals"><h3 class="ui2title">${esc(t('ui2SetTitle'))}</h3><div class="ui2own">${offense}${defense}${hpCycleHTML(s)}${luopanHTML(s)}</div>${setStatsHTML(s)}${all}</div>`;
}

// Combat: a heading with the support profile and the quick actions; the buffs' editor in the page (it was a window),
// in two columns
function renderCombat(d){
  // the party builder (party_builder.js): a card a member, the target and what the party gives under them
  return renderCombatParty(d);
}

// My character: who (job, levels, when measured), the stats measured in game, PorterPacker, then the merits
function renderPerso(d){
  const s = ui2CurrentSet(d), c = measuredChar && measuredChar(), lv = jaLevels();
  const facts = [[t('ui2Job'), `${S.job}/${d.sub || '—'}`], ['Master Level', lv.ml || '—'], ['Job Points', (c && c.jp_spent) || '—'],
    [t('ui2Measured'), c && c.at ? `${c.at} · /${c.sub || '—'}` : t('ui2NotMeasured')]];
  const head = `<header class="tabhead"><div><h2>${esc(S.char)}</h2><p class="muted small">${esc(t('ui2PersoWhy'))}</p></div>` +
    `<dl class="herofacts">${facts.map(([k, v]) => `<div><dt>${esc(k)}</dt><dd>${esc(String(v))}</dd></div>`).join('')}</dl>${persoViewsHTML()}</header>`;
  // the character's bags (bags_view.js): a view of its own, the whole width
  if (S.persoView === 'bags') return `<div class="ui2tab persotab">${head}${renderBags()}</div>`;
  const cards = s && charStats(s) ? globalsHTML(s, 'cards') : `<p class="muted">${t('noChar')}</p>`;
  return `<div class="ui2tab persotab">${head}<div class="persogrid">${cards}${porterHTML(true)}</div>` +
    `<h3 class="tabsec">${esc(t('sectionsMerits'))}</h3>${renderMeritTabs()}</div>`;
}

// The merits as tabs, a group a tab (its levels spent beside its name, a dot when changed here), the chosen group's
// rows in one panel in two columns: every panel the same width, nothing stacked in uneven columns
function renderMeritTabs(){
  const list = meritList();
  if (!list) return `<div class="placeholder"><p>${t('noMerits')}</p></div>`;
  const edits = S.meritEdits[meritKey()] || {};
  const groups = MERIT_GROUPS.filter(([lo, hi]) => meritRows(list, lo, hi, edits));
  const cur = groups.find(g => g[2] === S.meritTab) || groups[0];
  // the skill groups' tab says only Combat / Magic: the full name runs out of a tab
  const SHORT = new Set(['mgCombat', 'mgMagic']);
  const spent = ([lo, hi]) => list.filter(m => m.id >= lo && m.id < hi && m.key !== 'maximum_merit_points').reduce((n, m) => n + meritLevel(m), 0);
  const edited = ([lo, hi]) => list.some(m => m.id >= lo && m.id < hi && m.key in edits);
  const tabs = groups.map(g => `<button class="mtab ${MERIT_COLORS[g[2]]}" role="tab" data-merittab="${g[2]}" aria-selected="${g === cur}" title="${esc(t('ttMeritTab'))}">` +
    `<b>${esc(t(SHORT.has(g[2]) ? 'mtShort_' + g[2] : g[2]))}</b><small>${spent(g)}</small>${edited(g) ? '<i class="mdot"></i>' : ''}</button>`).join('');
  return meritBar(edits) + `<div class="mwrap"><div class="mtabs" role="tablist">${tabs}</div>` +
    `<section class="mpanel ${MERIT_COLORS[cur[2]]}"><ul class="meritlist two">${meritRows(list, cur[0], cur[1], edits)}</ul></section></div>`;
}

// What the set is after, one line under its pieces (the stats themselves are on the right)
function ui2Wants(s){
  const w = wantsLine(s);
  return w ? `<p class="ui2wants small" title="${esc(t('ttWants'))}">${w}</p>` : '';
}
