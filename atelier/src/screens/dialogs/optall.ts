// GearSwap Atelier · "Optimize every version" once searched: in the search window's dress, how many versions are worth
// writing, then a row a version (its damage, what it gains on the set as it is or on what is worn without it, the
// slots it changes, whether the file has it), each worth writing ticked, then Save.
// The rules are the old page's oaRowHTML and oaPaint (opt_all.js): the search, the records and the writing stay
// theirs. Drawn again in place while the versions are written (the table keeps its scroll, the moogle its hop). A field
// ending in Html is one of the old page's texts it wrote unescaped. The buttons keep the attributes the old handlers
// read (data-oasel, data-oago, data-close).
//
// @file    atelier/src/screens/dialogs/optall.ts
// @author  ejouanchicot

export type OaRow =
  | {k: 'wait'; cls: string; label: string; text: string}
  | {k: 'note'; cls: string; label: string; tdCls: string; text: string}
  | {k: 'res'; cls: string; tick: null | {path: string; on: boolean}; label: string; best: string; vsHtml: string; changed: number; state: string};
export interface OptAllView {
  kick: string; base: string; secs: string; runs: string; chips: string[];
  label: string; big: string; sum: string; mogWinHtml: string;
  headHtml: string[]; rows: OaRow[]; why: string; noLive: string; close: string; save: string;
}

const st = (): LegacyAny => S;

// one version's row (oaRowHTML)
function rowOf(R: LegacyAny, v: LegacyAny): OaRow {
  const rec = R.by[v.path], pct = (n: number) => (n >= 0 ? '+' : '−') + Math.abs(n).toFixed(1) + ' %';
  if (!rec) return {k: 'wait', cls: R.now === v ? 'oanow' : 'oawait', label: v.label, text: R.now === v ? '…' : ''};
  if (rec.skip) return {k: 'note', cls: 'oaoff', label: v.label, tdCls: 'muted', text: t('oaSkip', {p: shortPath(rec.skip)})};
  if (rec.error) return {k: 'note', cls: 'oaoff', label: v.label, tdCls: 'kwarn', text: t('oaFail', {e: rec.error})};
  const like = rec.useless ? esc(t(rec.exists ? 'oaSpare' : 'oaUseless', {p: oaShort(R, rec.fallback)})) : '';
  // a version the file writes: what the search gains on it as it is; a new one: against its fallback
  const fixes = rec.fixes ? ` <small class="oafix">· ${esc(t('oaFixes'))}</small>` : '';
  const vsHtml = rec.exists ? (rec.changed ? `${pct(rec.vsNow)} <small class="muted">${esc(t('oaVsNow'))}</small>` : esc(t('oaSame'))) + fixes + (like ? ` <small class="muted">· ${like}</small>` : '')
    : like || (rec.vsFallback != null ? pct(rec.vsFallback) : esc(t('oaSame')));
  return {k: 'res', cls: rec.sel ? 'oaon' : 'oaoff', tick: R.finished && rec.changed ? {path: v.path, on: !!rec.sel} : null, label: v.label,
    best: fmtDmg(rec.best), vsHtml, changed: rec.changed, state: rec.exists ? t('oaExists') : t('oaNew')};
}

/** The window of a run over every version (oaPaint) */
export function optAllView(R: LegacyAny): OptAllView {
  const S0 = st(), recs = Object.values(R.by) as LegacyAny[], searched = recs.filter(x => x.res).length, n = recs.filter(x => x.sel).length;
  const o = S0.optOpts || {}, obj = t('optObj_' + (o.obj || 'damage'), {tp: S0.wsTp || 3000, a: o.tpFrom || 1000, b: o.tpTo || 3000});
  return {kick: t('oaTitle'), base: shortPath(R.base), secs: Math.round(R.secs || 0).toLocaleString(S0.lang === 'fr' ? 'fr-FR' : 'en-US') + ' s', runs: t('oaRuns', {n: searched}),
    chips: [obj, t('optWhere_mine')], label: R.writing || t('oaUseful'), big: `${n} / ${searched}`, sum: t('oaSum', {n: searched, u: n, x: searched - n}), mogWinHtml: R.mogWinHtml || '',
    headHtml: [t('oaVer'), t('oaDmg'), t('oaVs'), t('oaCh'), t('oaState')], rows: R.list.map((v: LegacyAny) => rowOf(R, v)), why: t('oaWhy', {e: OA_EPS}),
    noLive: liveWrite() ? '' : t('oaNoLive'), close: t('close'), save: n && liveWrite() && !R.writing ? t('oaGo', {n}) : ''};
}
