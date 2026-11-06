// GearSwap Atelier · sets_simple.js: the Sets page's Simple view, a choice of the Settings (the player, 2026-11-05:
// "too much to read", as an option in case it does not please). Off, the page is the detailed one it always was; on,
// the set's code, its missing pieces and its notes fold to one line each, the optimizer shows no result before a
// search and only the minimums given (notes/docs-perso/page-sets-simple-2026-11-05/SPEC.md). Only the display moves:
// no figure, search, export or GearSwap file changes.
// The views read setsSimple(): sets/card.ts, optimizer/blocks.ts, statpage.ts, optpage.ts, settings/settings.ts.
//
// @file    atelier/app/js/sets_simple.js
// @author  ejouanchicot

/** The Sets page's Simple view is on (S.setsView, kept in the browser: core.js KEEP) */
function setsSimple(){ return S.setsView === 'simple'; }

// The plain text of a note written as HTML, for a tooltip
function plainText(html){ return String(html || '').replace(/<[^>]+>/g, '').replace(/&nbsp;/g, ' ').replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&quot;/g, '"').replace(/&#39;/g, "'"); }

// A weapon's icon for the Simple view's weapons line, or '' for a name that is no item (a weapon mode: "PDT")
function simpleIcon(name){ const id = name && (iconIds()[name] || (catalog() || {id: {}}).id[name]); return id ? icon(name) : ''; }

// The pieces you do not have as one folded line ("15 pièces pas dans tes sacs ▸"), the names inside
function simpleHoldHtml(cls, key, names){
  return `<details class="holdfold"><summary class="${cls}">${esc(t(key, {n: names.length}))}</summary><p class="${cls}">${esc(names.join(', '))}</p></details>`;
}

document.addEventListener('click', e => {
  const b = e.target.closest && e.target.closest('[data-setsview-set]');
  if (b) { S.setsView = b.dataset.setsviewSet === 'simple' ? 'simple' : 'full'; S._limOpen = false; render(); return; }
  // the minimums left at 0, folded in the Simple view: shown or folded again
  const l = e.target.closest && e.target.closest('[data-limopen]');
  if (l) { S._limOpen = !S._limOpen; render(); }
});

Object.assign(T.fr, {cfgSetsView: 'Page des sets', cfgSetsViewWhy: 'Détaillée : tout à la vue (le code du set, chaque note, chaque minimum). Simple : l’essentiel, le reste replié en une ligne qui s’ouvre. Les chiffres et les recherches sont les mêmes.',
  cfgSetsFull: 'Détaillée', cfgSetsSimple: 'Simple', ssToSimple: 'Vue simple', ssToFull: 'Vue détaillée', ssViewTip: 'Change l’affichage de la page des sets (aussi dans les Réglages)',
  ssCode: 'Voir le code', ssMissing: '{n} pièce(s) pas dans tes sacs', ssShort: '{n} pièce(s) à monter ou à finir', ssPorter: '{n} pièce(s) chez le Porter Moogle',
  ssLimNone: 'Aucun minimum · régler', ssLimMore: '{n} autre(s) minimum(s) à 0 · régler', ssLimFold: 'replier les minimums à 0', ssHpMin: 'HP min', ssHpMax: 'HP max'});
Object.assign(T.en, {cfgSetsView: 'Sets page', cfgSetsViewWhy: 'Detailed: everything in sight (the set’s code, every note, every minimum). Simple: the essentials, the rest folded in one line that opens. The figures and the searches are the same.',
  cfgSetsFull: 'Detailed', cfgSetsSimple: 'Simple', ssToSimple: 'Simple view', ssToFull: 'Detailed view', ssViewTip: 'Changes how the sets page shows (also in the Settings)',
  ssCode: 'Show the code', ssMissing: '{n} piece(s) not in your bags', ssShort: '{n} piece(s) to upgrade or finish', ssPorter: '{n} piece(s) at the Porter Moogle',
  ssLimNone: 'No minimum · set', ssLimMore: '{n} more minimum(s) at 0 · set', ssLimFold: 'fold the minimums at 0', ssHpMin: 'HP min', ssHpMax: 'HP max'});
