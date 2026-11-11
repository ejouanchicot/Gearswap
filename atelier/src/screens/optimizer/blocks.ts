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
// more: in the Simple view (sets_simple.js), the link that shows or folds the limits left at 0 (data-limopen)
export interface LimitsView { title: string; titleTip: string; many: boolean; tiles: LimitTile[]; more: null | {label: string} }
export interface ChangesView { title: string; rows: Array<{slot: string; from: string; to: string}> }

/** A limit as a tile: its name above, its sign and its value below ("DT+PDT ≤" gives DT+PDT, then ≤ and the number);
 * what it does as its tooltip (the damage optimizer's limits have their own sentence) */
export function limitTile(attr: string, key: string, label: string, value: LegacyAny): LimitTile {
  const m = String(label).match(/^(.*?)\s*([≤≥])\s*$/), name = m ? m[1]! : label;
  const tip = attr === 'data-optopt' && (T as LegacyAny)[(S as LegacyAny).lang]['ttLim_' + key] ? t('ttLim_' + key) : t('ttLim');
  return {attr: {[attr]: key}, name, sign: m ? m[2]! : '', value: value == null ? '' : String(value), tip};
}
/** The limits block; more than four tiles (the stats optimizer's minimums) go two across. In the Simple view only the
 * limits given a value show (0 = none), the others one click away, and the two HP ones say min and max */
export function limitsView(title: string, tiles: Array<LimitTile | null>, titleTip = ''): LimitsView {
  let shown = tiles.filter((x): x is LimitTile => !!x), more: LimitsView['more'] = null;
  if (setsSimple()) {
    const unset = (x: LimitTile) => !+x.value, n = shown.filter(unset).length;
    if (n && !(S as LegacyAny)._limOpen) shown = shown.filter(x => !unset(x));
    if (n) more = {label: (S as LegacyAny)._limOpen ? t('ssLimFold') + ' ▾' : t(shown.length ? 'ssLimMore' : 'ssLimNone', {n}) + ' ▸'};
    shown = shown.map(x => x.name === 'HP' && x.sign ? {...x, name: t(x.sign === '≥' ? 'ssHpMin' : 'ssHpMax'), sign: ''} : x);
  }
  return {title, titleTip, many: shown.length > 4, tiles: shown, more};
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
  locks: null | {text: string; clear: string}; excl: null | {label: string; count: number; clear: string; back: string;
    groups: Array<{slot: string; label: string; count: number; items: Array<{n: string; tip: string; iconHtml: string; why: string}>; more: null | {label: string}}>};
  ranks: null | {title: string; tip: string; allMax: string; allOff: string;
    kinds: Array<{label: string; rows: Array<{fam: string; label: string; count: string; iconHtml: string; mine: string; mineTip: string;
      chips: Array<{value: string; label: string; on: boolean; title: string}>;
      paths: null | Array<{value: string; label: string; on: boolean; title: string}>}>}>};
}

// Searching every item of the game: the rank a family of rank pieces is searched at (opt_page.js rankFamilies), by
// kind; each family its icon, how many pieces the job wears, yours with their rank, the ranks in a menu (not unlocked,
// then every rank from the top one down to R0)
// A family on several paths (Nyame A / B): the path its pieces to get are searched on (opt_page.js rankPathOf), every
// path as a chip after "All"; the one your copies are on said in its tip
function pathChips(f: LegacyAny) {
  const paths = f.paths as string[];
  if (!paths || paths.length < 2) return null;
  const cur = rankPathOf(f.fam), held = new Set((f.mine as Array<{path?: string}>).map(x => x.path).filter(Boolean));
  return [{value: 'all', label: t('opPathAll'), on: !cur, title: t('opPathAllTip')}]
    .concat(paths.map(p => ({value: p, label: p, on: cur === p, title: t(held.has(p) ? 'opPathMine' : 'opPathTip', {p})})));
}
function ranksView(o: LegacyAny): SearchView['ranks'] {
  if (o.where !== 'all') return null;
  const fams: Array<LegacyAny> = rankFamilies(), set = rankFamSet();
  if (!fams.length) return null;
  const row = (f: LegacyAny) => {
    // every rank, the top one first (a Nolan's R15 to R0)
    const steps: string[] = [];
    for (let r = f.max; r >= 0; r--) steps.push(String(r));
    const raw = set[f.fam] == null || set[f.fam] === '' ? String(f.max) : String(set[f.fam]);
    const cur = raw === 'off' || steps.includes(raw) ? raw : String(f.max);
    const short = (n: string) => n.split(' ').slice(1).join(' ') || n, mine = f.mine as Array<{name: string; rank?: number}>;
    const said = mine.map(x => short(x.name) + (x.rank != null ? ' R' + x.rank : ''));
    return {fam: f.fam, label: f.fam.replace(/'s$/, ''), count: t('opRankN', {n: f.n}), iconHtml: icon(f.first),
      mine: said.length ? t('opRankMine', {l: said.slice(0, 3).join(', ') + (said.length > 3 ? ' +' + (said.length - 3) : '')}) : t('opRankNone'),
      mineTip: mine.map(x => x.name + (x.rank != null ? ' R' + x.rank : '')).join('\n'),
      chips: [{value: 'off', label: t('opRankOffS'), on: cur === 'off', title: t('opRankOff')}]
        .concat(steps.map(r => ({value: r, label: 'R' + r, on: cur === r, title: +r === f.max ? t('opRankMax', {n: r}) : 'R' + r}))),
      paths: pathChips(f)};
  };
  const kinds = [...new Set(fams.map(f => f.kind as string))];
  return {title: t('opRanks'), tip: t('opRanksTip'), allMax: t('opRankAllMax'), allOff: t('opRankAllOff'),
    kinds: kinds.map(k => ({label: t('opRankK_' + k), rows: fams.filter(f => f.kind === k).map(row)}))};
}

// The pieces left out of the searches (trial.js excludedOf), by slot in the game's order (both ears, both rings
// together), each a chip (its icon, its name; a piece to get says it comes back once held) that allows it again when
// clicked; a slot with many shows its first EXCL_SHOWN, the others behind one line (S._exclOpen, by slot)
const EXCL_SHOWN = 8;
function excludedView(out: Record<string, LegacyAny>): SearchView['excl'] {
  const S0 = S as LegacyAny, names = (SLOT_NAMES[S0.lang] || {}) as Record<string, string>, by: Record<string, string[]> = {};
  const slotOf = (n: string) => { const sl = ((itemOf(n) || {}).slots || [])[0] || 'other'; return sl === 'ear2' ? 'ear1' : sl === 'ring2' ? 'ring1' : sl === 'range' || sl === 'ranged' ? 'ammo' : sl; };
  for (const n of Object.keys(out).sort()) (by[slotOf(n)] = by[slotOf(n)] || []).push(n);
  const order = [...SLOTS, 'other'] as string[], label = (sl: string) => sl === 'ear1' ? t('exclEars') : sl === 'ring1' ? t('exclRings') : sl === 'other' ? t('exclOther') : names[sl] || sl;
  const open = (S0._exclOpen || {}) as Record<string, boolean>;
  return {label: t('exclLine').replace(/\s*:\s*$/, ''), count: Object.keys(out).length, clear: Object.keys(out).length > 1 ? t('exclClear') : '', back: t('exclHint'),
    groups: order.filter(sl => by[sl]).map(sl => {
      const all = by[sl] || [], shown = open[sl] || all.length <= EXCL_SHOWN + 1 ? all : all.slice(0, EXCL_SHOWN);
      return {slot: sl, label: label(sl), count: all.length, items: shown.map(n => ({n, tip: t('exclBack', {p: n}) + (out[n] === 'missing' ? ' · ' + t('exclMissing') : ''), iconHtml: icon(n),
        why: out[n] === 'missing' ? t('exclMissingS') : ''})),
        more: all.length > EXCL_SHOWN + 1 ? {label: open[sl] ? t('exclLess') : t('exclMore', {n: all.length - EXCL_SHOWN})} : null};
    })};
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
    const out = excludedOf();
    if (Object.keys(out).length) excl = excludedView(out);
  }
  return {title: t('opSearch'), special: cur.id === 'special' ? t('opSpecialWhy') : '', locks, excl, switches: cur.keys.map(sw), ranks: cur.id === 'pieces' ? ranksView(o) : null,
    tabs: OP_TABS.map((x: LegacyAny) => ({id: x.id, pressed: x === cur, tip: t('ttOpTab_' + x.id), label: t(x.title), on: x.count ? x.keys.filter((k: string) => o[k]).length : 0})),
    menu: m ? {key: m.key, label: t(m.label), tip: m.tip ? t(m.tip) : '', options: m.values.map((v: string) => ({value: v, label: t(m.text + v), selected: (o[m.key] || m.dflt) === v}))} : null};
}
