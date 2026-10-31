// GearSwap Atelier · the pieces' window of a slot (a click on a slot, "Choose a piece"): filters on the left (where the
// pieces come from, the order, their kind, the stat they are chosen for, the pieces of no use), the pieces as cards on
// the right, each with what it gives the set and, a stat chosen, its value and its gap to the piece worn.
// The rules are the old page's gpOpen and gpCard (gear_pick.js): the pieces stay drawer.js's (pieceChoices), the search
// field hides the cards in place (events.js #drawq). A field ending in Html is one of the old page's texts it wrote
// unescaped. The controls keep the attributes the old handlers read (data-gpsrc, data-gpsel, data-gpjunk,
// data-tryempty, data-try, data-trymax).
//
// @file    atelier/src/screens/dialogs/gearpick.ts
// @author  ejouanchicot

export interface GpOption { k: string; label: string; selected: boolean }
export interface GpItem { i: number; orig: boolean; cur: boolean; junk: boolean; iconHtml: string; name: string; rank: number | null; tagHtml: string;
  up: null | {on: boolean; title: string; text: string}; augs: string; fit: string; why: string; where: string; val: null | {text: string; gap: null | {cls: string; text: string}};
  hide?: boolean }
export interface GearPickView {
  qPh: string;
  fromLabel: string; src: Array<{k: string; label: string; pressed: boolean}>;
  sortLabel: string; sorts: GpOption[];
  kinds: null | {label: string; options: GpOption[]};
  fxLabel: string; fxs: GpOption[];
  junk: null | {checked: boolean; label: string};
  emptyHtml: string | null;
  count: string; wantsHtml: string; items: GpItem[]; none: string;
}

const st = (): LegacyAny => S;

// one piece as a card (gpCard)
function itemOf(o: LegacyAny, i: number, slot: string, v: LegacyAny, worn: LegacyAny): GpItem {
  const r = o.cat ? null : pieceStats(o.piece, slot), augs: string[] = o.piece.augs || [], up = o.upgrade;
  const where = o.cat ? [t('notOwned'), o.ilv ? 'iLv ' + o.ilv : t('lvShort', {n: o.lv})].join(' · ')
    : [o.owned ? (o.count > 1 ? '×' + o.count + ' · ' : '') + (o.where && o.where.length ? o.where.map(whereLabel).join(', ') : t('inBag')) : t('notOwned'), o.seen ? t('inSets', {n: o.seen}) : ''].filter(Boolean).join(' · ');
  const tagHtml = o.orig ? `<em class="tag orig">${t('setPiece')}</em>` : o.cur ? `<em class="tag cur">${t('triedTag')}</em>` : o.curMax ? `<em class="tag cur">${t('triedMax')}</em>` : '';
  const gap = v && worn ? v.good - worn.good : null;
  return {i, orig: !!o.orig, cur: !!(o.cur || o.curMax), junk: o.grp === 5, iconHtml: icon(o.piece.name), name: o.piece.name, rank: r && r.rank != null ? r.rank : null, tagHtml,
    up: up ? {on: !!o.curMax, title: t('maxChipTip'), text: up.to ? `→ R${up.to}` : t('capeMaxTag')} : null,
    augs: augs.length ? augs.filter(a => !/^Path:/.test(a)).join(' · ') || augs.join(' · ') : '',
    fit: o.fit && o.fit.length ? o.fit.join(' · ') : '', why: !(o.fit && o.fit.length) && o.junk && o.why ? o.why : '', where,
    val: v ? {text: fmtStat(v.e), gap: gap != null ? {cls: gap > 0 ? 'up' : gap < 0 ? 'down' : '', text: `${gap > 0 ? '+' : gap < 0 ? '−' : '±'}${Math.abs(Math.round(gap * 10) / 10)} ${t('gpVs')}`} : null} : null};
}

/** The window's body for a slot (gpOpen), the pieces already worked out (pieceChoices) */
export function gearPickView(s: LegacyAny, slot: string, p: LegacyAny, opts: LegacyAny[]): GearPickView {
  const S0 = st();
  const fx = S0._gpFx && gpStats(s).includes(S0._gpFx) ? S0._gpFx : '';
  // the piece worn without the stat counts as 0 of it: every gap is then to the set as it is
  const worn = fx && p ? gpValue(p, slot, fx) || {good: 0} : null;
  const shown = opts.map((o, i) => [o, i] as [LegacyAny, number]).filter(([o]) => gpInSrc(o, S0.gpSrc));
  const junk = shown.filter(([o]) => o.grp === 5).length;
  let rows: LegacyAny[] = shown.filter(([o]) => S0._showJunk || o.grp !== 5);
  // the pieces of no use to the set, when not shown: drawn hidden, so that a search by name still finds them (events.js #drawq)
  const hid: LegacyAny[] = S0._showJunk ? [] : shown.filter(([o]) => o.grp === 5);
  // the hands and the ammo by kind (Sword, Great Axe, Shield, Grip...): the kinds among the pieces listed, with their count
  const kinds: Array<[string, number]> = WEAPON_SLOTS.has(slot) ? gpKinds(rows) : [];
  const kind = (S0._gpKind || {}).slot === slot && kinds.some(([k]) => k === S0._gpKind.k) ? S0._gpKind.k : null;
  if (kind != null) rows = rows.filter(([o]) => itemKind(o.piece.name) === kind);
  if (fx) rows = rows.map(([o, i]) => [o, i, gpValue(o.piece, slot, fx)]).filter(x => x[2] && x[2].good > 0).sort((a, b) => b[2].good - a[2].good);
  const sorts: Array<[string, string]> = gpSorts(fx), sort = sorts.some(([k]) => k === S0.gpSort) ? S0.gpSort : 'rel';
  if (GP_SORT[sort]) rows.sort(GP_SORT[sort]);
  const opt = (list: Array<[string, string]>, cur: string) => list.map(([k, l]) => ({k, label: l, selected: k === cur}));
  const stats: Array<[string, string]> = ([['', t('gpAny')]] as Array<[string, string]>).concat(gpStats(s).map((k: string) => [k, statLabel(k, {label: k.toUpperCase()})] as [string, string]));
  return {qPh: t('gpSearch'), fromLabel: t('gpFrom'), src: GP_SRC.map(([k, l]: [string, string]) => ({k, label: t(l), pressed: S0.gpSrc === k})),
    sortLabel: t('gpSortLbl'), sorts: opt(sorts.map(([k, l]) => [k, t(l)]), sort),
    kinds: kinds.length > 1 ? {label: t('gpKind'), options: opt(([['*', `${t('gpKindAll')} (${kinds.reduce((n, x) => n + x[1], 0)})`]] as Array<[string, string]>)
      .concat(kinds.map(([k, n]) => [k, `${k || t('gpKindOther')} (${n})`] as [string, string])), kind == null ? '*' : kind)} : null,
    fxLabel: t('gpFor'), fxs: opt(stats, fx),
    junk: junk ? {checked: !!S0._showJunk, label: t('gpJunk', {n: junk})} : null,
    emptyHtml: p && !(['main', 'sub'].includes(slot) && family(s.path, s.pieces) !== 'weapons') ? t('tryEmpty') : null,
    count: t('gpCount', {n: rows.length}), wantsHtml: wantsLine(s), items: [...rows.map(([o, i, v]) => itemOf(o, i, slot, v, worn)),
      ...(fx ? [] : hid.filter(([o]) => kind == null || itemKind(o.piece.name) === kind).map(([o, i]) => Object.assign(itemOf(o, i, slot, null, worn), {hide: true})))], none: t('gpNone')};
}
