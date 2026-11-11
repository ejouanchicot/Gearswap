// GearSwap Atelier · the tabs on top of the Sets screen's right column, for a set the optimizer can search: the set's
// stats (figures.ts), then the optimizer's views, the search's detail and its settings (pieces, calculation, special
// pieces: opt_page.js OP_TABS), reached in one click without opening the optimizer first (the player, 2026-11-11).
// A click (events.js data-rtab) opens the optimizer on that view, or closes it for the stats.
//
// @file    atelier/src/screens/sets/rtabs.ts
// @author  ejouanchicot
export interface RightTab { id: string; label: string; sub: string; tip: string; on: number; selected: boolean }
export interface RightTabs { tabs: RightTab[] }

export const OPT_VIEWS = ['detail', 'pieces', 'calc', 'special'];

/** The right column's tabs; open: the optimizer shown, detailSub: what the detail tab says under its name */
export function rightTabsView(open: boolean, detailSub: string): RightTabs {
  const S0 = S as LegacyAny, o = S0.optOpts || {}, cur = !open ? 'stats' : OPT_VIEWS.includes(S0._opView) ? S0._opView : 'detail';
  const special = ['hoxne', 'vim'].filter(k => o[k]).map(k => t(k === 'hoxne' ? 'opV_hoxne' : 'opV_vim'));
  const subs: Record<string, string> = {stats: '', detail: detailSub,
    pieces: t('opV_where_' + (o.where || 'mine')), calc: t('opV_search_' + (o.search || 'fast')), special: special.length ? special.join(', ') : t('opV_none')};
  const tabs: RightTab[] = [{id: 'stats', label: t('rtStats'), sub: subs.stats || '', tip: t('rtStatsTip'), on: 0, selected: cur === 'stats'},
    {id: 'detail', label: t('opV_detail'), sub: subs.detail || '', tip: t('opV_detailTip'), on: 0, selected: cur === 'detail'}];
  for (const x of OP_TABS as LegacyAny[])
    tabs.push({id: x.id, label: t(x.title), sub: subs[x.id] || '', tip: t('ttOpTab_' + x.id), on: x.count ? x.keys.filter((k: string) => o[k]).length : 0, selected: cur === x.id});
  return {tabs};
}
