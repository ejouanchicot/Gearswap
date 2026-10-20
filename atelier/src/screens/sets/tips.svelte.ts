// GearSwap Atelier · the hover card (#tip, App.svelte): a piece's card over a slot of a set, of the drawer, of the
// simulation, or an optimizer's objective (its name and what it is). A piece's card: its icon, name, slot, weapon
// figures, rank, bag and priority, its badges, then its stats (attributes in a row, the others one a line, the
// augment's part apart), its effects and conditions. Shift held turns it to the piece at its best (what is left to
// do, then that piece's card). The rules are the old page's tipHTML, pieceTip and maxTip (events.js); showTip
// (events.js) still decides when it opens and places it beside the element hovered.
//
// @file    atelier/src/screens/sets/tips.svelte.ts
// @author  ejouanchicot
import {flushSync} from 'svelte';

export interface StatCell { label: string; aug: string; value: string; title: string }
export type PieceCard =
  | {k: 'none'; iconHtml: string; label: string; none: string}
  | {k: 'piece'; iconHtml: string; name: string; label: string; weapon: string; rank: null | {text: string}; where: string; badgesHtml: string;
      known: boolean; attrs: StatCell[]; rows: StatCell[]; free: string[]; cond: string[]; effects: string; condTitle: string; noDesc: string};
export type TipView =
  | {k: 'obj'; name: string; desc: string}
  | {k: 'piece'; max: string; card: PieceCard; hint: string};

export const tipState = $state<{view: TipView | null}>({view: null});
const S0 = (): LegacyAny => S;

/** The card of one piece (a set's, the drawer's, the simulation's); none: an empty slot (pieceTip) */
export function pieceCard(p: LegacyAny, slot: string, emptied?: boolean): PieceCard {
  const label = (SLOT_NAMES[S0().lang] as Record<string, string>)[slot]!;
  // a slot the set empties (sets.naked, //gs c naked) stays empty whatever the weapon modes say
  if (!p) return {k: 'none', iconHtml: icon(null), label, none: emptied ? t('emptied') : slot === 'main' || slot === 'sub' ? t('emptyWeapon') : t('empty')};
  const r = pieceStats(p, slot), known = !!(r && r.known);
  let attrs: StatCell[] = [], rows: StatCell[] = [];
  if (known) {
    const keys = Object.keys(r.stats).filter(k => r.stats[k].v);
    const order = STAT_GROUPS.flatMap(([g]) => keys.filter(k => statGroup(k) === g).sort(statOrder));
    // the augment's part in front of the total: the base is what remains
    const cell = (k: string): StatCell => { const lb = statLabel(k, r.stats[k]);
      return {label: lb, aug: r.aug[k] && r.aug[k].v ? '◆' + fmtStat(r.aug[k]) : '', value: fmtStat(r.stats[k]), title: statHelp(esc(lb), '')}; };
    attrs = order.filter(k => statGroup(k) === 'attr').map(cell);
    rows = order.filter(k => statGroup(k) !== 'attr').map(cell);
  }
  const weapon = r && r.weapon ? ' · ' + Object.entries(r.weapon).map(([k, n]) => `${k} ${n}`).join(' · ') : '';
  const rank = r && r.rank != null ? {text: (r.path ? `Path ${r.path} · ` : '') + t('rankShort', {r: r.rank}) + (r.rankAssumed ? ' · ' + t('rankAssumed') : '')} : null;
  // where GearSwap takes it from (bag = 'wardrobe 3') and its order in a swap (priority)
  const where = [p.bag ? t('tipBag', {b: p.bag}) : '', p.priority != null ? t('tipPriority', {n: p.priority}) : ''].filter(Boolean).join(' · ');
  return {k: 'piece', iconHtml: icon(p.name), name: p.name, label, weapon, rank, where, badgesHtml: rareExHTML(p.name, r && Object.keys(r.aug).length),
    known, attrs, rows, free: known ? r.free : [], cond: known ? r.cond : [], effects: t('effects'), condTitle: t('condTitle'), noDesc: t('noDesc')};
}
// the piece at its best: what is left to do, then its card (maxTip)
function maxOf(up: LegacyAny, slot: string): TipView {
  const todo = up.to ? (up.from != null ? t('upRank', {f: up.from, t: up.to}) : t('upRankUnknown', {t: up.to}))
    : t('upCape') + (up.missing && up.missing.length ? ' · ' + t('upMissing', {m: up.missing.join(', ')}) : '');
  return {k: 'piece', max: todo, card: pieceCard(up.piece, slot), hint: ''};
}

/** What the card over an element shows, or null (nothing to show: the old page then leaves the card as it is) */
export function tipView(el: HTMLElement): TipView | null {
  const d = el.dataset, S1 = S0();
  // an objective of the optimizer: its name, then what it is (opt_page.js objTip_*, stat_opt.js statD_*)
  if (d.objtip != null) return {k: 'obj', name: (el.querySelector('b') || el).textContent || '', desc: d.objtip};
  if (d.simp != null) {
    const [i, slot] = d.simp.split('|') as [string, string], p = ((S1._simWorn || {})[i] || {})[slot];
    return {k: 'piece', max: '', card: pieceCard(p && p.name !== 'empty' ? p : null, slot), hint: ''};
  }
  if (d.try != null) {
    const o = (S1._drawOpts || [])[+d.try];
    if (!o || !o.piece) return null;
    return S1._shift && o.upgrade ? maxOf(o.upgrade, S1._drawer.slot) : {k: 'piece', max: '', card: pieceCard(o.piece, S1._drawer.slot), hint: o.upgrade ? t('maxHint') : ''};
  }
  const ci = +(d.card as string), card = S1._cards && S1._cards[ci], slot = d.slot as string;
  if (!card) return null;
  const s = shownSet(card, ci), piece = withWeapons(s).pieces[slot], up = piece && upgradeOf(piece);
  return S1._shift && up ? maxOf(up, slot) : {k: 'piece', max: '', card: pieceCard(piece, slot, isEmpty(s.pieces[slot])), hint: up ? t('maxHint') : ''};
}

/** The card shown with this view, drawn now (its size places it); returns whether there was one */
export function tipShow(el: HTMLElement): boolean {
  const v = tipView(el);
  if (!v) return false;
  tipState.view = v;
  flushSync();
  return true;
}
