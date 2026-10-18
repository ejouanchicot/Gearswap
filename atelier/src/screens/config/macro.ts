// GearSwap Atelier · the Macro book & lockstyle part of the job's settings: the book and the style in force for the
// subjob shown (and the alt chosen for the dual-box), why, and the tables by subjob and by alt. The rules are the old
// page's renderMacro (atelier/app/js/sets_view.js); bookFor, macroAlt, bookOf and styleOf stay there (core.js...).
// A field ending in Html is the old page's HTML: its texts, written unescaped, with the names escaped.
//
// @file    atelier/src/screens/config/macro.ts
// @author  ejouanchicot

export interface MacroTable { title: string; rows: Array<{key: string; cellHtml: string}> }
export interface MacroHead { bigHtml: string; lineHtml: string }
export interface MacroView {
  hintHtml: string;
  book: {title: string; alts: null | {labelHtml: string; title: string; options: Array<{value: string; label: string; pressed: boolean}>}; head: MacroHead; tables: MacroTable[]};
  style: {title: string; head: MacroHead; tables: MacroTable[]};
}

type Entries = Record<string, unknown> | undefined;

function table(title: string, obj: Entries, fmt: (v: never) => string): MacroTable[] {
  return obj && Object.keys(obj).length ? [{title, rows: Object.entries(obj).map(([key, v]) => ({key, cellHtml: fmt(v as never)}))}] : [];
}

// a book and page, or one entry by subjob (a dual-box alt's)
function bookPage(v: LegacyBook | Record<string, {book: number; page: number}> | undefined): string {
  if (v && typeof v.book === 'number') return t('bookPage', {b: v.book, p: v.page});
  return Object.entries((v || {}) as Record<string, {book: number; page: number}>)
    .map(([s, x]) => `${s === 'default' ? t('byDefault') : '/' + esc(s)} ${x.book}·${x.page}`).join(' &nbsp; ');
}

/** The Macro book & lockstyle part for the export shown */
export function macroView(d: LegacyExport): MacroView {
  const m = d.macro || {}, l = d.lockstyle || {};
  // the values in force for the subjob shown (and the alt chosen): its own entry, else the default
  const alt = macroAlt(d), book = bookFor(d), style = (l.by_subjob || {})[d.sub] ?? l.default ?? d.lockstyle_fallback;
  const du = alt ? (m.dualbox || {})[alt] : undefined;
  const why = du && (du[d.sub] || du.default) ? t('bookAlt', {a: esc(alt)}) + (du[d.sub] ? '' : ' (' + t('byDefault') + ')')
    : (m.solo || {})[d.sub] ? '/' + esc(d.sub) : m.default || (m.solo || {}).default ? t('byDefault') : t('bookFactory');
  const whose = (own: boolean) => ' · ' + (own ? '/' + esc(d.sub) : style === d.lockstyle_fallback && l.default == null ? t('bookFactory') : t('byDefault'));
  const alts = Object.keys(m.dualbox || {}).sort();
  return {
    hintHtml: t('macroHint'),
    book: {
      title: t('macro'),
      alts: alts.length ? {labelHtml: t('bookAltPick'), title: t('ttMacroAlt'),
        options: [['', t('bookNoAlt')] as [string, string]].concat(alts.map(a => [a, a] as [string, string])).map(([value, label]) => ({value, label, pressed: (alt || '') === value}))} : null,
      head: {bigHtml: bookOf(d), lineHtml: book ? t('bookPage', {b: book.book, p: book.page}) + ' · ' + why : ''},
      tables: table(t('bySub'), m.solo, bookPage).concat(table(t('byDual'), m.dualbox, bookPage))
    },
    style: {
      title: t('lockstyle'),
      head: {bigHtml: styleOf(d), lineHtml: style != null ? t('style', {s: esc(style)}) + whose((l.by_subjob || {})[d.sub] != null) : ''},
      tables: table(t('bySub'), l.by_subjob, (v: string | number) => t('style', {s: v}))
    }
  };
}
