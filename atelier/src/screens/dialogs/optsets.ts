// GearSwap Atelier · "Tout optimiser" (opt_sets.js): its start window (notes/docs-perso/theme-ffxi-2026-11-07/SPEC.md
// § 10: the families on the left, the sets of the one shown on the right by their game name, their versions in whole
// words; the shortcuts, starting from scratch, the time it should take) and, once run, its summary (each set's goal before and after, the gain, its limits, the slots
// changed, ticked when worth writing), in the search window's dress. The buttons keep the attributes the old page's
// handlers read (events.js data-osset, data-osrow, data-osfam, data-osfamopen, data-osfamall, data-osonly, data-osscratch, data-osgo, data-ossel, data-oswrite,
// data-osundo, data-close). SPEC: notes/docs-perso/tout-optimiser-2026-11-01/SPEC.md
//
// @file    atelier/src/screens/dialogs/optsets.ts
// @author  ejouanchicot

// a tick: on, off, or a dash when in part
export type OsTick = 'on' | 'off' | 'part';
export interface OsFamily { fam: string; label: string; tick: OsTick; n: number; total: number; open: boolean }
export interface OsRow { path: string; label: string; cls: string; tick: null | boolean; obj: string; vs: string; gain: string; n: string; note: string }
// a set of the family shown: its game name, its tick, its versions in whole words (Full, Group, Solo, Trust)
export interface OsSetRow { key: string; name: string; tick: OsTick; vers: Array<{path: string; label: string; on: boolean}> }
export interface OptSetsView {
  finished: boolean; title: string; sub: string;
  // the start window: its head (the job, its count of sets, the time), the bar "Choose" (the shortcuts, from scratch),
  // the families on the left, the sets of the one shown on the right, the foot
  head: {kicker: string; title: string; about: string; time: string};
  choose: string; shortcuts: Array<{key: string; label: string; on: boolean}>; scratch: {label: string; why: string; on: boolean};
  fams: OsFamily[]; open: {label: string; all: string; none: string; rows: OsSetRow[]; rowTip: string; verTip: string} | null;
  foot: string; mine: string; go: string;
  // the summary
  heads: string[]; rows: OsRow[]; writing: string; noLive: string; write: string; undo: string; close: string;
}

const st = (): LegacyAny => S;
const pct = (n: number) => (n >= 0 ? '+' : '−') + Math.abs(n).toFixed(1) + ' %';

function rowOf(R: LegacyAny, x: LegacyAny, i: number): OsRow {
  const rec = R.by[x.s.path], label = shortPath(x.s.path);
  if (!rec) return {path: x.s.path, label, cls: 'osoff', tick: null, obj: '', vs: '', gain: '', n: '', note: R.stopped != null && i >= R.stopped ? t('osStopped', {i: R.stopped + 1, n: R.todo.length}) : ''};
  if (rec.error) return {path: x.s.path, label, cls: 'osoff', tick: null, obj: '', vs: '', gain: '', n: '', note: t('osSkip', {e: rec.error})};
  return {path: x.s.path, label, cls: rec.sel ? 'oson' : 'osoff', tick: rec.n ? !!rec.sel : null, obj: rec.label, vs: `${rec.from} → ${rec.to}`,
    gain: rec.n ? pct(rec.gain) : t('osSame'), n: rec.n ? String(rec.n) : '', note: [rec.n && rec.miss ? t('osMiss') : '', ...(rec.warn || [])].filter(Boolean).join(' · ')};
}

const tickOf = (ons: boolean[]): OsTick => ons.every(Boolean) ? 'on' : ons.some(Boolean) ? 'part' : 'off';
// The shortcut the ticks are (Tout, Sets de stats, Engaged, Rien), none when ticked by hand
function shortcutOn(R: LegacyAny): string {
  const is = (f: (x: LegacyAny) => boolean) => R.list.every((x: LegacyAny) => !!R.on[x.s.path] === f(x));
  return is(() => true) ? 'all' : is(() => false) ? 'none' : is((x: LegacyAny) => x.kind === 'stat') ? 'stat' : is(osEngaged) ? 'eng' : '';
}
// The families on the left, each with its tick and "ticked / total"; the sets of the one shown, a line a set
function startView(R: LegacyAny): Pick<OptSetsView, 'fams' | 'open'> {
  const fams: OsFamily[] = (R.fams as string[]).map(fam => { const xs = R.list.filter((x: LegacyAny) => x.fam === fam), ons = xs.map((x: LegacyAny) => !!R.on[x.s.path]);
    return {fam, label: listFamLabel(fam), tick: tickOf(ons), n: ons.filter(Boolean).length, total: xs.length, open: fam === R.open}; });
  const rows: OsSetRow[] = [];
  // (in the list's order, not the run's: the run puts a base before the sets built on it)
  for (const card of st()._cards || []) if (card.fam === R.open) for (const v of card.variants) {
    const xs = R.list.filter((x: LegacyAny) => x.row === v.set.path);
    if (!xs.length || rows.some(r => r.key === v.set.path)) continue;
    const vers = xs.sort((a: LegacyAny, b: LegacyAny) => VER_ORDER.indexOf(a.ver) - VER_ORDER.indexOf(b.ver)).map((x: LegacyAny) => ({path: x.s.path, label: x.ver, on: !!R.on[x.s.path]}));
    rows.push({key: v.set.path, name: xs[0].name, tick: tickOf(vers.map((x: {on: boolean}) => x.on)), vers});
  }
  return {fams, open: R.open ? {label: listFamLabel(R.open), all: t('osFamAll'), none: t('osFamNone'), rows, rowTip: t('osRowTip'), verTip: t('osVerTip')} : null};
}
const VER_ORDER = ['Full', 'Group', 'Solo', 'Trust'];

/** The window of "Tout optimiser": its start, or its summary once the run is over */
export function optSetsView(R: LegacyAny): OptSetsView {
  const ticked = R.list.filter((x: LegacyAny) => R.on[x.s.path]);
  const done = R.finished ? Object.values(R.by || {}) as LegacyAny[] : [], u = done.filter(x => x.sel).length;
  const secs = osDur(R.finished ? R.secs || 0 : osEstimate(R)), on = shortcutOn(R), job = (JOBS.find((j: LegacyAny) => j[0] === st().job) || [])[1] || st().job;
  return {finished: !!R.finished, title: t(R.finished ? 'osSumTitle' : 'osTitle'), sub: R.finished ? t('osSum', {u, n: done.length, s: secs}) : '',
    head: {kicker: t('osTitle'), title: t('osHead', {j: job, n: R.list.length}), about: t('osAbout'), time: secs},
    choose: t('osChoose'), shortcuts: [{key: 'all', label: t('osAll')}, {key: 'stat', label: t('osOnlyStatShort')}, {key: 'eng', label: t('osOnlyEngShort')}, {key: 'none', label: t('osNone')}].map(c => ({...c, on: c.key === on})),
    scratch: {label: t('osScratchShort'), why: t('osScratchWhy'), on: !!R.scratch}, ...(R.finished ? {fams: [], open: null} : startView(R)),
    foot: t('osFoot', {n: ticked.length, d: secs}), mine: t('osMine'), go: ticked.length ? t('osLaunch') : '',
    heads: [t('osHeadSet'), t('osHeadObj'), t('osHeadVs'), t('osHeadGain'), t('osHeadN')], rows: R.finished ? R.todo.map((x: LegacyAny, i: number) => rowOf(R, x, i)) : [],
    writing: R.writing || '', noLive: R.finished && !liveWrite() ? t('osNoLive') : '', write: R.finished && u && liveWrite() && !R.writing ? t('osWrite', {n: u}) : '',
    undo: R.finished && !R.writing ? t('osUndo') : '', close: t('close')};
}
