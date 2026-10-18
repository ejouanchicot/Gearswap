// GearSwap Atelier · the card of the set shown in the Sets screen: its head (what it is, its versions, the weapons it
// is shown with, a weaponskill's controls), the trial's bar, the equipment as sixteen slots, the line under them (what
// it inherits, what is shared, what is missing), the legend, the notes, and the figures (shown beside on a wide
// window). A set whose optimizer page is open shows that page instead (step 6).
// The rules are the old page's cardHTML, slotHTML, setVersionsHTML, versionGridHTML (sets_view.js), with what it
// keeps in the page's state as it goes (S._curSet, S._globals). Still the old page's HTML: the title box and the
// weapons' menus (setTitleBox, weaponMenus), a weaponskill's head (ws_page.js wsHeadHTML), the trial's bar
// (trial.js), the equip button (live.js), the line of what the set is after, the legend and notes; the figures are figures.ts. A field ending in Html is one of the old page's texts it wrote unescaped.
//
// @file    atelier/src/screens/sets/card.ts
// @author  ejouanchicot
import {figuresView, type FiguresView} from './figures';

export interface SlotView { slot: string; ci: number; label: string; empty: boolean; cls: string; aria: string; reset: null | {title: string}; lock: null | {title: string};
  iconHtml: string; aug: boolean; rank: number | null }
export interface VerButton { i: number; pressed: boolean; title: string; label: string }
export type Versions =
  | {k: 'none'}
  | {k: 'row'; label: string; buttons: VerButton[]}
  | {k: 'grid'; label: string; cols: string[]; rows: Array<{label: string; cells: Array<VerButton | null>}>};
export interface CardView {
  k: 'card';
  ci: number;
  ws: boolean;
  titleHtml: string;
  versions: Versions;
  ctl: null | {picks: boolean; html: string};
  trialHtml: string;
  slots: SlotView[];
  equipHtml: string;
  footHtml: string[];
  wantsHtml: string;
  legendHtml: string;
  notesHtml: string;
  figures: FiguresView;
}
export type CardOrPage = CardView | {k: 'page'; html: string};

const st = (): LegacyAny => S;
const TIERS3 = ['Group', 'Solo', 'Trust'];

// the head of a set other than a weaponskill's: what it is (its family, name and version, when it is worn, its path),
// and the weapons it is shown with (setHeadHTML)
function setHeadParts(card: LegacyAny, vi: number, s: LegacyAny, acts: string): {title: string; picks: string} {
  const when = t('famWhen.' + card.fam), label = card.variants[vi].label;
  const fam = t('fam.' + card.fam), name = niceName(card);
  // an enhancing set: on whom it is cast, beside its name and as the line under it (stat_opt.js enhTarget)
  const on = enhTarget(s), tag = on ? ` <span class="wsver">· ${esc(t('enhTag' + on))}</span>` : '';
  const title = setTitleBox(fam !== name ? fam : '', esc(name) + (label && label !== 'Base' ? ` <span class="wsver">· ${esc(label)}</span>` : '') + tag,
    on ? `<span class="muted small setwhen">${esc(t('enhWhen' + on))}</span>` : when ? `<span class="muted small setwhen">${esc(when)}</span>` : '', '', s.path, acts);
  // the weapons' menus side by side, a label over each; then what the job's GearSwap puts with them (off hand, ammo)
  const pick = (lbl: string, body: string) => `<div class="wpick"><span class="wslbl">${esc(lbl)}</span><div class="wsval">${body}</div></div>`;
  const menus = weaponMenus(s), tipOf = (desc: string) => desc && desc.replace(/\s+/g, '').toLowerCase() !== 'mainweapon' ? desc + ' · ' + t('ttWeapon') : t('ttWeapon');
  const picks = (menus ? menus.map(([nm, sel, desc]: [string, string, string]) => pick(nm, sel).replace('<span class="wslbl">', `<span class="wslbl" title="${esc(tipOf(desc))}">`)
    .replace('<select class="wmenu', `<select title="${esc(tipOf(desc))}" class="wmenu`)).join('') : '') + (family(s.path, s.pieces) !== 'weapons' ? weaponResultLines(s, pick) : '');
  return {title, picks};
}

// a slot of the equipment: its piece's icon, whether it is the set's own, inherited, a weapon's, on trial, locked, held
// or missing, augmented, its rank (slotHTML)
function slotOf(s: LegacyAny, ci: number, slot: string, own: Set<string>, q: string, eff: LegacyAny): SlotView {
  const p = eff.pieces[slot], label = (SLOT_NAMES[st().lang] || {})[slot] || slot, tried = eff.tried[slot];
  const lock = isLocked(s, slot) && LOCKABLE(slot) ? {title: t('lockTip')} : null;
  const reset = tried ? {title: t('tryReset')} : null;
  if (!p) return {slot, ci, label, empty: true, cls: `slot empty ${tried ? 'tried' : ''} ${lock ? 'locked' : ''}`, aria: `${label} : —`, reset, lock, iconHtml: '', aug: false, rank: null};
  const weap = eff.from[slot], inh = !weap && s.base && !own.has(slot), hit = q && p.name.toLowerCase().includes(q);
  const r = pieceStats(p, slot), hold = holdState(slot, p);
  return {slot, ci, label, empty: false, cls: `slot ${inh ? 'inh' : ''} ${weap ? 'weap' : ''} ${hit ? 'hit' : ''} ${tried ? 'tried' : ''} ${lock ? 'locked' : ''} ${hold ? 'own-' + hold : ''}`,
    aria: `${label} : ${p.name}${hold ? ' · ' + t('lg_' + hold) : ''}`, reset, lock, iconHtml: icon(p.name), aug: !!(r && Object.keys(r.aug).length), rank: r && r.rank != null ? r.rank : null};
}

// the versions of the set shown, under its title: one row of buttons, or a table for a set with versions of two kinds
// (a DNC weaponskill: a dance, Climactic Flourish, each with its support versions); a set with none keeps the row's
// place (setVersionsHTML, versionGridHTML)
function versionsOf(card: LegacyAny, ci: number, vi: number): Versions {
  const groups: LegacyAny[] = [...variantGroups(card).groups.values()];
  const cur = groups.find(g => g.main === vi || g.subs.some((x: LegacyAny) => x.i === vi)) || (card.fam === 'ws' ? groups[0] : null);
  if (!cur || !cur.subs.length) return {k: 'none'};
  const tiers = cur.subs.some((x: LegacyAny) => /^(Group|Solo|Trust)$/.test(x.label));
  // an enhancing set's versions read as their target ("Composure" is the one cast on the others)
  const shown = (i: number, txt: string) => { const v = card.variants[i], on = enhTarget(v.set);
    return on && (v.label === 'Base' || /composure/i.test(v.label)) ? t('enhBtn' + on) : txt; };
  const btn = (i: number, txt: string): VerButton => ({i, pressed: i === vi, title: T[S.lang]['ttVer' + txt] ? t('ttVer' + txt) : t('ttVer'), label: shown(i, txt)});
  if (tiers) {
    const cell = (i: number, label: string) => { const parts = label.split(' · '), tier = TIERS3.includes(parts[parts.length - 1]!) ? parts.pop()! : 'Full'; return {i, tier, row: parts.join(' · ')}; };
    const cells = (cur.main != null ? [{i: cur.main, tier: 'Full', row: ''}] : []).concat(cur.subs.map((x: LegacyAny) => cell(x.i, x.label)));
    const rows = [...new Set(cells.map((c: LegacyAny) => c.row as string))];
    if (rows.length >= 2) {
      const rank = (r: string) => !r ? '' : (r.split(' · ')[0] === 'Clim' ? '0' : '1') + r;
      rows.sort((a, b) => rank(a).localeCompare(rank(b)));
      const cols = ['Full'].concat(TIERS3.filter(x => cells.some((c: LegacyAny) => c.tier === x)));
      const at = (r: string, tier: string) => cells.find((c: LegacyAny) => c.row === r && c.tier === tier);
      return {k: 'grid', label: t('verLbl'), cols, rows: rows.map(r => ({label: r || t('verSet'), cells: cols.map(c => { const x = at(r, c); return x ? btn(x.i, c) : null; })}))};
    }
  }
  return {k: 'row', label: t('verLbl'), buttons: (cur.main != null ? [btn(cur.main, tiers ? 'Full' : t('verSet'))] : []).concat(cur.subs.map((x: LegacyAny) => btn(x.i, x.label)))};
}

/** The card of a set, or its optimizer page when that is open */
export function cardView(card: LegacyAny, ci: number, bypath: LegacyAny, q: string): CardOrPage {
  const S0 = st(), vi = Math.min(S0.variant[S0.job + '|' + ci] ?? 0, card.variants.length - 1);
  const s = card.variants[vi].set, base = s.base ? bypath[s.base] : null;
  // the set every figure of the card reads (aftermath, the abilities a family of sets offers): this one
  S0._curSet = s;
  const own = new Set<string>(s.own || Object.keys(s.pieces)), eff = withWeapons(s);
  const slots = SLOTS.map((slot: string) => slotOf(s, ci, slot, base ? own : new Set(SLOTS), q, eff));
  const foot: string[] = [];
  if (base) { const n = [...own].filter(x => s.pieces[x]).length; foot.push(`${t('inherits', {b: '<b>' + esc(shortPath(s.base)) + '</b>'})} · ${n ? t('changed', {n}) : t('nothingChanged')}`); }
  else foot.push(`<span title="${esc(t('ttDefined'))}">${Object.keys(s.pieces).length ? t('defined', {n: '<b>' + Object.keys(s.pieces).length + '</b>'}) : t('emptySet')}</span>`);
  if (s.aliases && s.aliases.length) foot.push(`<details><summary>${t('sharedCount', {n: s.aliases.length})}</summary><p>${s.aliases.map((a: string) => esc(shortPath(a))).join(' · ')}</p></details>`);
  const holds: Record<string, string[]> = {missing: [], short: [], porter: []};
  for (const slot of SLOTS) { const h = holdState(slot, eff.pieces[slot]); if (h && !holds[h]!.includes(eff.pieces[slot].name)) holds[h]!.push(eff.pieces[slot].name); }
  // at the Porter Moogle: which slip, to take it out
  const slipOf = (n: string) => [...new Set(Object.values(ownedOf()).flat().filter((x: LegacyAny) => x.name === n).flatMap((x: LegacyAny) => x.where || []))].map((w: LegacyAny) => w.replace(/^Slip/, 'slip')).join(', ');
  if (holds.porter!.length) foot.push(`<span class="holdporter">${t('holdPorter', {l: esc(holds.porter!.map(n => n + ' (' + slipOf(n) + ')').join(', '))})}</span>`);
  if (holds.missing!.length) foot.push(`<span class="holdmiss">${t('holdMissing', {l: esc(holds.missing!.join(', '))})}</span>`);
  if (holds.short!.length) foot.push(`<span class="holdshort">${t('holdShort', {l: esc(holds.short!.join(', '))})}</span>`);
  const legendHtml = legendHTML(holds);
  const ws = card.fam === 'ws' && family(s.path, s.pieces) === 'ws';
  if (ws) wsTitleHTML(s);   // (worked out first as before: what it reads is kept for the head)
  const locked = baseOnly(s), optable = !locked && ((ws && wsOfSet(s)) || isNukeSet(s.path) || roundSet(s) || statSet(s));
  if (optable && optPageOpen(s)) return {k: 'page', html: optPageHTML(s, ws && wsOfSet(s))};
  // its actions on the title line: the optimizer, then deleting it
  const acts = `<span class="setacts">${optable && engineReady() ? `<button class="btn" data-optview title="${esc(t('ttOptOpen'))}">${t('optOpenBtn')}</button>` : ''}${(ws && !wsOfSet(s)) || locked ? '' : delButton(s)}</span>`;
  let titleHtml: string, versions: Versions, ctl: CardView['ctl'];
  if (ws) {
    titleHtml = wsTitleHTML(s, acts);
    versions = wsOfSet(s) ? versionsOf(card, ci, vi) : {k: 'none'};
    ctl = wsOfSet(s) ? {picks: false, html: wsHeadHTML(card, ci, vi, s)} : null;
  } else {
    const head = setHeadParts(card, vi, s, acts);
    titleHtml = head.title; versions = versionsOf(card, ci, vi); ctl = {picks: true, html: head.picks};
  }
  // a family's note and a base set's go under the gear, where nothing is left to push down
  const notesHtml = familyNoteHTML(card, s) + (locked && !ws ? `<p class="famnote">${esc(t('baseOnly', {l: (data() as LegacyAny).sets.filter((x: LegacyAny) => x.base === s.path).map((x: LegacyAny) => shortPath(x.path)).join(', ')}))}</p>` : '');
  const trialHtml = trialBar(s), equipHtml = equipBtnHTML(), wantsHtml = ui2Wants(s);
  S0._globals = {s, view: figuresView(s)};
  return {k: 'card', ci, ws, titleHtml, versions, ctl, trialHtml, slots, equipHtml, footHtml: foot, wantsHtml, legendHtml, notesHtml, figures: S0._globals.view};
}
