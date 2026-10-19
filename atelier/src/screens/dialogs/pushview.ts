// GearSwap Atelier · the windows that write to GearSwap's files once the game said what would change: pushing a set's
// pieces (what goes into which set, a row a slot, the warnings), deleting a set, adding an empty one; each with what
// protects the file and, folded, the file and its lines before and after.
// The rules are the old page's pushViewHTML, pushRowsHTML, delViewHTML, addViewHTML and pushTechHTML (push_view.js):
// the plan, the warnings and the game's answer stay push.js's. A field ending in Html is one of the old page's texts
// it wrote unescaped. The fold keeps the attribute its handler reads (data-pushtech).
//
// @file    atelier/src/screens/dialogs/pushview.ts
// @author  ejouanchicot

export interface PushRow { title: string; iconHtml: string; slot: string; from: string; to: {piece: boolean; text: string} }
export interface PushView {
  kind: 'push' | 'del' | 'add';
  carryHtml: string; introHtml: string; rows: PushRow[]; warnsHtml: string[]; alsoHtml: string; safeHtml: string;
  tech: {open: boolean; summary: string; fileHtml: string; diffHtml: string};
}

const st = (): LegacyAny => S;

// the fold with the file and its lines, before and after (pushTechHTML)
const techOf = (r: LegacyAny, after: string): PushView['tech'] => ({open: !!st().pushTech, summary: t('pvTech'), fileHtml: t('pvFile', {f: `<code>${esc(r.file)}</code>`}), diffHtml: diffHTML(r.before, after)});
const blank = {carryHtml: '', introHtml: '', rows: [], warnsHtml: [], alsoHtml: '', safeHtml: ''};

/** The push window: the pieces it writes, a row a slot, the piece the file holds now and the one it takes */
export function pushView(s: LegacyAny, tg: LegacyAny, plan: LegacyAny[], r: LegacyAny, warn: string[], any: unknown): PushView {
  const S0 = st(), was = s.was || {}, base = s.base ? shortPath(s.base) : '', p = `<b>${esc(shortPath(s.path))}</b>`;
  const now = (slot: string) => { const x = slot in was ? was[slot] : s.pieces[slot]; return x && !isEmpty(x) && x.name !== 'empty' ? x.name : ''; };
  // the icon of a row: the piece written, or the base set's piece the slot takes again (an emptied slot has none)
  const basePiece = (slot: string) => { const b = s.base && S0._bypath ? S0._bypath[s.base] : null, x = b && b.pieces[slot]; return x && !isEmpty(x) ? x.name : ''; };
  const shown = (e: LegacyAny) => e.piece ? e.piece.name : e.kind === 'inherit' ? basePiece(e.slot) : '';
  return {...blank, kind: 'push', carryHtml: mogCarryHTML(tg.create ? t('pvPushNew', {v: `<b>${esc(tg.tier)}</b>`, p}) : t('pvPush', {p})),
    rows: plan.map(e => ({title: e.piece && e.piece.augs ? e.piece.augs.join(' · ') : '', iconHtml: icon(shown(e)), slot: (SLOT_NAMES[S0.lang] || {})[e.slot] || e.slot, from: now(e.slot),
      to: e.piece ? {piece: true, text: e.piece.name} : {piece: false, text: e.kind === 'empty' ? t('pvEmptied') : base ? t('pvInherit', {b: base}) : t('pvInheritAny')}})),
    warnsHtml: warn, safeHtml: any ? t('pvSafe') : t('pushErr_nothing'), tech: techOf(r, r.after)};
}
/** The delete window: the set, the names going with it, what protects the file */
export function delView(s: LegacyAny, r: LegacyAny, also: string[]): PushView {
  return {...blank, kind: 'del', introHtml: t('pvDel', {p: `<b>${esc(shortPath(s.path))}</b>`}),
    alsoHtml: also.length ? t('pvDelAlso', {l: esc(also.map(shortPath).join(' · '))}) : '', safeHtml: t('pvDelSafe'), tech: techOf(r, '')};
}
/** The window that adds an empty set */
export function addSetView(path: string, r: LegacyAny): PushView {
  return {...blank, kind: 'add', carryHtml: mogCarryHTML(t('pvAdd', {p: `<b>${esc(shortPath(path))}</b>`})), safeHtml: t('pvSafe'), tech: techOf(r, r.after)};
}
