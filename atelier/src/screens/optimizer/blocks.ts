// GearSwap Atelier · the blocks both optimizers share (the damage one: optpage.ts, the stats one: statpage.ts): the
// limits as tiles at the top of the left column (seen before anything else), the pieces the try changes.
// The rules are the old page's opLimitHTML, opLimitsHTML and opChangesHTML (opt_page.js). A limit's field keeps the
// attribute its handler reads (data-optopt in the damage optimizer, data-statfloor in the stats one: events.js).
//
// @file    atelier/src/screens/optimizer/blocks.ts
// @author  ejouanchicot

export interface LimitTile { attr: Record<string, string>; name: string; sign: string; value: string; tip: string }
export interface LimitsView { title: string; titleTip: string; many: boolean; tiles: LimitTile[] }
export interface ChangesView { title: string; rows: Array<{slot: string; from: string; to: string}> }

/** A limit as a tile: its name above, its sign and its value below ("DT+PDT ≤" gives DT+PDT, then ≤ and the number);
 * what it does as its tooltip (the damage optimizer's limits have their own sentence) */
export function limitTile(attr: string, key: string, label: string, value: LegacyAny): LimitTile {
  const m = String(label).match(/^(.*?)\s*([≤≥])\s*$/), name = m ? m[1]! : label;
  const tip = attr === 'data-optopt' && (T as LegacyAny)[(S as LegacyAny).lang]['ttLim_' + key] ? t('ttLim_' + key) : t('ttLim');
  return {attr: {[attr]: key}, name, sign: m ? m[2]! : '', value: value == null ? '' : String(value), tip};
}
/** The limits block; more than four tiles (the stats optimizer's minimums) go two across */
export function limitsView(title: string, tiles: Array<LimitTile | null>, titleTip = ''): LimitsView {
  const shown = tiles.filter((x): x is LimitTile => !!x);
  return {title, titleTip, many: shown.length > 4, tiles: shown};
}
/** The pieces the try changes: the slot, your piece, the try's; null when it changes none */
export function changesView(s: LegacyAny): ChangesView | null {
  const S0 = S as LegacyAny, tr = S0.trial[trialKey(s)] || {}, plain = withoutTrial(() => withWeapons(s).pieces);
  const list = SLOTS.filter((slot: string) => tr[slot] && !heldAlready(s, slot, tr[slot]));
  if (!list.length) return null;
  return {title: t('opChanges'), rows: list.map((slot: string) => ({slot: (SLOT_NAMES[S0.lang] || {})[slot] || slot, from: (plain[slot] || {}).name || '—', to: '→ ' + (tr[slot].name || '—')}))};
}
