// GearSwap Atelier · the Sets screen: the line over it (the situation, the profiles, a subjob's warning), the list of
// the job's sets on the left (setlist.ts), the set shown, the figures of the set beside it.
// The rules are the old page's renderSets (sets_view.js). Still the old page's HTML: the line over it (ui2CtxBar,
// subWarnHTML), the set's card's parts (card.ts), the column of its figures (setPanelHTML / globalsHTML: step 5c).
// A field ending in Html is one of the old page's texts it wrote unescaped.
//
// @file    atelier/src/screens/sets/sets.ts
// @author  ejouanchicot
import {setList, type SetListView} from './setlist';
import {cardView, type CardOrPage} from './card';

export interface SetsView { ctxHtml: string; ui2: boolean; listW: number | null; list: SetListView; card: CardOrPage | null; globalsHtml: string | null }

const st = (): LegacyAny => S;

/** The Sets screen for the old page's state now, or null when it is not shown */
export function setsView(): SetsView | null {
  const S0 = st();
  if (S0.section !== 'sets' || S0._cfg || (S0._pkg && typeof renderPackages === 'function') || !S0.job) return null;
  const d = data();
  if (!d) return null;
  const {view, cards, sel, bypath, vis, q} = setList(d);
  // in the old page's order: the list, then the line over it, the set, its figures
  const ctxHtml = ui2() ? ui2CtxBar(subWarnHTML()) : subWarnHTML();
  const card = vis.length ? cardView(cards[sel], sel, bypath, q) : null;
  let globalsHtml: string | null = null;
  if (vis.length) { const sv = shownSet(cards[sel], sel);
    globalsHtml = S0._globals && S0._globals.s === sv ? S0._globals.html : ui2() ? setPanelHTML(sv) : globalsHTML(sv); }
  return {ctxHtml, ui2: ui2(), listW: S0.listW ? +S0.listW : null, list: view, card, globalsHtml};
}
