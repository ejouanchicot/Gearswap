// GearSwap Atelier · the blocks both optimizers share (the damage one: optpage.ts, the stats one: statpage.ts): the
// limits as tiles at the top of the left column (seen before anything else), the search (its tabs, menu and
// switches, the pieces locked or left out), the pieces the try changes.
// The rules are the old page's opLimitHTML, opLimitsHTML, opChangesHTML, opSearchHTML, opMenuHTML, opSwitchHTML and
// opLocksHTML (opt_page.js, which keeps the tabs and switches: OP_TABS, OP_SWITCH). A limit's field keeps the
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

export interface SearchView {
  title: string; tabs: Array<{id: string; pressed: boolean; tip: string; label: string; on: number}>;
  menu: null | {key: string; label: string; tip: string; options: Array<{value: string; label: string; selected: boolean}>};
  switches: Array<{k: string; off: boolean; tip: string; label: string; checked: boolean}>; special: string;
  locks: null | {text: string; clear: string}; excl: null | {label: string; items: Array<{n: string; tip: string}>; clear: string};
}

/** The search block: its tabs (opt_page.js OP_TABS, a count on a tab whose switches are on), then the open tab's menu
 * and switches (OP_SWITCH), and on the pieces' tab the slots locked and the pieces left out (one click allows one
 * again); noWeapons: free weapons offered off, with why */
export function searchView(o: LegacyAny, ws: boolean, noWeapons?: string): SearchView {
  const S0 = S as LegacyAny, cur = OP_TABS.find((x: LegacyAny) => x.id === S0._opTab) || OP_TABS[0], m = cur.menu;
  const sw = (k: string) => { const d = OP_SWITCH[k], off = k === 'freeWeapons' && !!noWeapons;
    return {k, off, tip: off ? noWeapons! : d.tip ? d.tip(ws) : '', label: t(d.label), checked: !!o[k]}; };
  let locks: SearchView['locks'] = null, excl: SearchView['excl'] = null;
  if (cur.id === 'pieces') {
    const s = ui2CurrentSet(data() as LegacyAny), list: string[] = s ? lockedSlots(s) : [];
    if (list.length) locks = {text: t('locksLine', {n: list.length, l: list.map(x => (SLOT_NAMES[S0.lang] || {})[x] || x).join(', ')}), clear: t('locksClear')};
    const out = Object.keys(excludedOf()).sort();
    if (out.length) excl = {label: t('exclLine'), items: out.map(n => ({n, tip: t('exclBack', {p: n})})), clear: out.length > 1 ? t('exclClear') : ''};
  }
  return {title: t('opSearch'), special: cur.id === 'special' ? t('opSpecialWhy') : '', locks, excl, switches: cur.keys.map(sw),
    tabs: OP_TABS.map((x: LegacyAny) => ({id: x.id, pressed: x === cur, tip: t('ttOpTab_' + x.id), label: t(x.title), on: x.count ? x.keys.filter((k: string) => o[k]).length : 0})),
    menu: m ? {key: m.key, label: t(m.label), tip: m.tip ? t(m.tip) : '', options: m.values.map((v: string) => ({value: v, label: t(m.text + v), selected: (o[m.key] || m.dflt) === v}))} : null};
}
