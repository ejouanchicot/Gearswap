// GearSwap Atelier · the Sets screen: what its figures are worked out with (the party, the profile, the target) and a
// subjob's warning, the list of the job's sets on the left (setlist.ts), the set shown, the figures of the set beside it.
// The rules are the old page's renderSets (sets_view.js). Still the old page's HTML: the set's card's parts (card.ts); the column of its figures is figures.ts.
// A field ending in Html is one of the old page's texts it wrote unescaped.
//
// @file    atelier/src/screens/sets/sets.ts
// @author  ejouanchicot
import {setList, type SetListView} from './setlist';
import {cardView, type CardOrPage} from './card';
import {figuresView, type FiguresView} from './figures';

export interface SubWarn { text: string; sub: string; fix: string }
// what every figure is worked out with, recalled at the head of the figures' column (Figures.svelte), a framed window
// of three cells (the player's choice A, 2026-11-08: a thin line was not seen): the party, the profile loaded (else
// "none", the cells keep their place), the target; a way to Buffs & target. The subjob's warning goes under the set's
// title (Card.svelte)
export interface CtxBar { title: string; head: string; cells: Array<{icon: string; label: string; value: string}>; edit: {title: string; label: string}; warn: SubWarn | null }
export interface SetsView { ctx: CtxBar; listW: number | null; list: SetListView; card: CardOrPage | null; figures: FiguresView | null }

const st = (): LegacyAny => S;

/** The Sets screen for the old page's state now, or null when it is not shown */
// The game on this job with another subjob than the page shows (the live link, live.js): every figure is then the
// other subjob's (its base attributes, traits, sets), said with a button to show the game's (data-subfix, events.js)
function subWarn(): SubWarn | null {
  const L = ((S as LegacyAny)._live || {})[S.char as string], d = data() as LegacyAny;
  if (!L || !L.ok || L.job !== S.job || !d || !L.sub || L.sub === 'NONE' || L.sub === d.sub) return null;
  return {text: t('subWarn', {g: L.job + '/' + L.sub, p: S.job + '/' + d.sub}), sub: L.sub, fix: t('subFix', {s: L.sub})};
}

export function setsView(): SetsView | null {
  const S0 = st();
  if (S0.section !== 'sets' || S0._cfg || (S0._pkg && typeof renderPackages === 'function') || !S0.job) return null;
  const d = data();
  if (!d) return null;
  const {view, cards, sel, bypath, vis, q} = setList(d);
  // in the old page's order: the list, then the line over it, the set, its figures
  // what the figures are worked out with (the line "Calculé avec" over the sets until 2026-11-08: its party was the set's
  // version again, its profile and target the Buffs & target tab's; the player chose a reminder in the figures' head)
  const warn = subWarn(), b = buffState();
  const ctx: CtxBar = {title: t('ttCtx'), head: t('ui2CtxHead'), cells: [
    {icon: playerIcon('gi:crossed-swords'), label: t('ui2CtxParty'), value: buffTier()},
    {icon: playerIcon('gi:tied-scroll'), label: t('ui2CtxProf'), value: profActive() || t('ui2CtxNone')},
    {icon: playerIcon('gi:bullseye'), label: t('ui2CtxFoe'), value: enemyKey(b.enemy)}],
    edit: {title: t('ttCtxEdit'), label: t('ui2CtxEdit')}, warn};
  const card = vis.length ? cardView(cards[sel], sel, bypath, q) : null;
  let figures: FiguresView | null = null;
  if (vis.length) { const sv = shownSet(cards[sel], sel);
    figures = S0._globals && S0._globals.s === sv && S0._globals.view ? S0._globals.view : figuresView(sv); }
  return {ctx, listW: S0.listW ? +S0.listW : null, list: view, card, figures};
}
