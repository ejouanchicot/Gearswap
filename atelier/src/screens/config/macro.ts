// GearSwap Atelier · the Macro book & lockstyle part of the job's settings: the book and the style in force for the
// subjob shown (and the alt chosen for the dual-box), why, and the tables by subjob and by alt. The rules are the old
// page's renderMacro (atelier/app/js/sets_view.js); bookFor, macroAlt, bookOf and styleOf stay there (core.js...).
// A field ending in Html is the old page's HTML: its texts, written unescaped, with the names escaped.
//
// @file    atelier/src/screens/config/macro.ts
// @author  ejouanchicot

export interface MacroTable { title: string; rows: Array<{key: string; cellHtml: string}> }
/** the numbers changed in the page (macro_edit.js): the default, one line a subjob, a subjob to add; or why not */
export interface MacroEdit {
  note: string; ro: boolean;
  rows: Array<{who: string; label: string; tip: string; current: boolean; del: string; delTip: string; iconHtml: string;
    vals: Array<{field: string; label: string; value: number | ''; max: number}>}>;
  add: null | {label: string; attr: string; options: string[]};
}
export interface MacroHead { bigHtml: string; lineHtml: string }
export interface MacroView {
  book: {alts: null | {labelHtml: string; title: string; options: Array<{value: string; label: string; pressed: boolean}>}; head: MacroHead; tables: MacroTable[]; edit: MacroEdit | null};
  style: {head: MacroHead; tables: MacroTable[]; edit: MacroEdit | null};
  /** the icons' authors, under the categories (pro.ts iconCredit) */
  credit: string;
  /** the badge of the line in force for the subjob shown */
  nowText: string;
  /** the cards' big icons (game-icons.net): an open book, an armour */
  heroBook: string; heroStyle: string;
  /** in the frame of the three parts (ProFrame.svelte): the part chosen (S.macroPart), its categories, the detail, the bar */
  pro: {part: 'book' | 'style'; nav: ProNav; head: {iconHtml: string; title: string; sub: string}; detail: ProDetail | null; foot: ProFoot};
}
import type {ProNav, ProDetail, ProFoot} from './pro';
import {iconCredit} from './pro';

// the lines of one file: the default, then each subjob it names (the one shown first marked), and the subjobs it lacks
function editOf(kind: 'book' | 'style', f: LegacyConfigFile | null, d: LegacyExport, haveText: boolean): MacroEdit {
  if (!f) return {note: t(haveText ? 'meNoFile' : 'meNoText'), ro: true, rows: [], add: null};
  const m = macroModel(kind, f), ro = !m.canWrite;
  const vals = (who: string, v: LegacyAny) => kind === 'style'
    ? [{field: kind + '|' + who, label: t('meStyle'), value: v ?? '', max: MACRO_MAX.style}]
    : [{field: kind + '|' + who + '|book', label: t('meBook'), value: v ? v.book : '', max: MACRO_MAX.book},
       {field: kind + '|' + who + '|page', label: t('mePage'), value: v ? v.page : '', max: MACRO_MAX.page}];
  const rows = [{who: 'def', label: t('meDefault'), tip: t('meDefaultTip'), current: m.subs[d.sub] == null, del: '', delTip: '', iconHtml: playerIcon('gi:bookmark'), vals: vals('def', m.def)}]
    .concat(Object.keys(m.subs).sort().map(s => ({who: s, label: '/' + s, tip: '', current: s === d.sub, del: ro ? '' : kind + '|' + s, delTip: t('meDel'),
      iconHtml: emblem(s), vals: vals(s, m.subs[s])})));
  const missing = MACRO_JOBS.filter(j => j !== S.job && m.subs[j] == null);
  return {note: ro ? t('meBroken') : m.table ? '' : t('meNoTable'), ro, rows,
    add: !ro && m.table && missing.length ? {label: t('meAdd'), attr: kind, options: missing} : null};
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

// the part in the frame: Macro book or Lockstyle on the left, the detail of the subjob shown on the right
function proOf(d: LegacyExport, book: LegacyAny, style: LegacyAny, dirty: boolean, bdirty: boolean, sdirty: boolean): MacroView['pro'] {
  const part = S.macroPart === 'style' ? 'style' : 'book';
  const item = (id: 'book' | 'style', icon: string, name: string, dot: boolean) => ({id, iconHtml: playerIcon(icon), name, count: '', dot, current: part === id, attr: {'data-macropart': id}});
  const nav: ProNav = {search: null, groups: [{label: '', items: [item('book', 'gi:open-book', t('cfgBook'), bdirty), item('style', 'gi:chest-armor', t('cfgStyle'), sdirty)]}]};
  const head = part === 'book' ? {iconHtml: playerIcon('gi:open-book'), title: t('cfgBook'), sub: t('cfgBookSub')} : {iconHtml: playerIcon('gi:chest-armor'), title: t('cfgStyle'), sub: t('cfgStyleSub')};
  const sub = '/' + (d.sub || '');
  const detail: ProDetail = part === 'book'
    ? {iconHtml: playerIcon('gi:open-book'), title: t('cfgBook') + ' ' + sub, tag: t('meNow'), what: t('cfgBookWhat', {j: S.job, s: d.sub}), example: t('cfgBookEx'), exampleTitle: t('cfgExample'),
       kv: book ? [[t('meBook'), String(book.book)], [t('mePage'), String(book.page)], [t('cfgWhen'), t('cfgWhenSub')]] : [], reset: null, foot: ''}
    : {iconHtml: playerIcon('gi:chest-armor'), title: t('cfgStyle') + ' ' + sub, tag: t('meNow'), what: t('cfgStyleWhat', {j: S.job, s: d.sub}), example: t('cfgStyleEx'), exampleTitle: t('cfgExample'),
       kv: style != null ? [[t('meStyle'), String(style)], [t('cfgWhen'), t('cfgWhenSub')]] : [], reset: null, foot: ''};
  const foot: ProFoot = {msg: S.toast || '', n: dirty ? 1 : 0, text: t('meDirty'), ok: t('cfgSaved'), undo: dirty ? {label: t('meUndo'), attrs: {'data-mundo': ''}} : null,
    save: dirty ? {label: t('meSave'), attrs: {'data-modsave': ''}} : null, lines: [], revertTip: ''};
  return {part, nav, head, detail, foot};
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
  // the numbers can be changed when the export carries the files' text (an export from before 2026-10-30 does not:
  // no file marked part = 'macro' at all)
  const files = macroFiles(d), haveText = (modAllFiles(d) as LegacyConfigFile[]).some(f => f.part === 'macro');
  const bm = files.book ? macroModel('book', files.book) : null, sm = files.style ? macroModel('style', files.style) : null;
  const bookNow = bm ? bm.subs[d.sub] || bm.def : null, styleNow = sm ? sm.subs[d.sub] ?? sm.def : null;
  const dirty = !!((bm && bm.dirty) || (sm && sm.dirty));
  return {
    book: {
      alts: alts.length ? {labelHtml: t('bookAltPick'), title: t('ttMacroAlt'),
        options: [['', t('bookNoAlt')] as [string, string]].concat(alts.map(a => [a, a] as [string, string])).map(([value, label]) => ({value, label, pressed: (alt || '') === value}))} : null,
      head: bookNow && !du ? {bigHtml: esc(bookNow.book + ' · ' + bookNow.page), lineHtml: t('bookPage', {b: bookNow.book, p: bookNow.page}) + ' · ' + (bm!.subs[d.sub] ? '/' + esc(d.sub) : t('byDefault'))}
        : {bigHtml: bookOf(d), lineHtml: book ? t('bookPage', {b: book.book, p: book.page}) + ' · ' + why : ''},
      tables: (files.book ? [] : table(t('bySub'), m.solo, bookPage)).concat(table(t('byDual'), m.dualbox, bookPage)),
      edit: editOf('book', files.book, d, haveText)
    },
    style: {
      head: styleNow != null ? {bigHtml: esc(styleNow), lineHtml: t('style', {s: esc(styleNow)}) + ' · ' + (sm!.subs[d.sub] != null ? '/' + esc(d.sub) : t('byDefault'))}
        : {bigHtml: styleOf(d), lineHtml: style != null ? t('style', {s: esc(style)}) + whose((l.by_subjob || {})[d.sub] != null) : ''},
      tables: files.style ? [] : table(t('bySub'), l.by_subjob, (v: string | number) => t('style', {s: v})),
      edit: editOf('style', files.style, d, haveText)
    },
    credit: iconCredit(),
    nowText: t('meNow'),
    heroBook: playerIcon('gi:open-book'), heroStyle: playerIcon('gi:chest-armor'),
    pro: proOf(d, bookNow || book, styleNow ?? style, dirty, !!(bm && bm.dirty), !!(sm && sm.dirty))
  };
}
