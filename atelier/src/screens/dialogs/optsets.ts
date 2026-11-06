// GearSwap Atelier · "Tout optimiser" (opt_sets.js): its start window (the job's sets by family, a tick each, the time
// it should take) and, once run, its summary (each set's goal before and after, the gain, its limits, the slots
// changed, ticked when worth writing), in the search window's dress. The buttons keep the attributes the old page's
// handlers read (events.js data-osset, data-osfam, data-osonly, data-osscratch, data-osgo, data-ossel, data-oswrite,
// data-osundo, data-close). SPEC: notes/docs-perso/tout-optimiser-2026-11-01/SPEC.md
//
// @file    atelier/src/screens/dialogs/optsets.ts
// @author  ejouanchicot

export interface OsFamily { fam: string; label: string; all: boolean; sets: Array<{path: string; label: string; on: boolean; kind: string}> }
export interface OsRow { path: string; label: string; cls: string; tick: null | boolean; obj: string; vs: string; gain: string; n: string; note: string }
export interface OptSetsView {
  finished: boolean; title: string; sub: string;
  // the start window
  fams: OsFamily[]; shortcuts: Array<{key: string; label: string}>; scratch: {label: string; on: boolean}; mine: string; go: string;
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

/** The window of "Tout optimiser": its start, or its summary once the run is over */
export function optSetsView(R: LegacyAny): OptSetsView {
  const ticked = R.list.filter((x: LegacyAny) => R.on[x.s.path]);
  const fams: OsFamily[] = [];
  for (const x of R.list) {
    let f = fams.find(y => y.fam === x.fam);
    if (!f) fams.push(f = {fam: x.fam, label: listFamLabel(x.fam), all: true, sets: []});
    f.sets.push({path: x.s.path, label: shortPath(x.s.path), on: !!R.on[x.s.path], kind: x.kind});
    if (!R.on[x.s.path]) f.all = false;
  }
  const done = R.finished ? Object.values(R.by || {}) as LegacyAny[] : [], u = done.filter(x => x.sel).length;
  const secs = osDur(R.finished ? R.secs || 0 : osEstimate(R));
  return {finished: !!R.finished, title: t(R.finished ? 'osSumTitle' : 'osTitle'), sub: R.finished ? t('osSum', {u, n: done.length, s: secs}) : t('osPick', {n: ticked.length, d: secs}),
    fams, shortcuts: [{key: 'stat', label: t('osOnlyStat')}, {key: 'eng', label: t('osOnlyEng')}, {key: 'all', label: t('osAll')}, {key: 'none', label: t('osNone')}],
    scratch: {label: t('osScratch'), on: !!R.scratch}, mine: t('osMine'), go: ticked.length ? t('osGo', {n: ticked.length}) : '',
    heads: [t('osHeadSet'), t('osHeadObj'), t('osHeadVs'), t('osHeadGain'), t('osHeadN')], rows: R.finished ? R.todo.map((x: LegacyAny, i: number) => rowOf(R, x, i)) : [],
    writing: R.writing || '', noLive: R.finished && !liveWrite() ? t('osNoLive') : '', write: R.finished && u && liveWrite() && !R.writing ? t('osWrite', {n: u}) : '',
    undo: R.finished && !R.writing ? t('osUndo') : '', close: t('close')};
}
