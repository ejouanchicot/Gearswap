// GearSwap Atelier · "By party": what each version of a set (the set itself, .Group, .Solo, .Trust, the trial) is worth
// in each situation, the version GearSwap wears there marked, the best in bold, how much the worn one loses.
// The rules are the old page's tierCostHTML (optimizer.js): the versions and their figures stay openTierCost's
// (tierVersions, tierCosts, tierMetric). A field ending in Html is one of the old page's texts it wrote unescaped.
//
// @file    atelier/src/screens/dialogs/tiercost.ts
// @author  ejouanchicot

export interface TierCostView {
  whyHtml: string; setHtml: string; tiers: string[];
  rows: Array<{label: string; cells: Array<null | {text: string; best: boolean; worn: boolean; loss: string}>}>;
  lines: Array<{warn: boolean; html: string}>; howHtml: string;
}

/** The table and its lines (tierCostHTML) */
export function tierCostView(rows: LegacyAny[], worn: Record<string, string>, dmg: LegacyAny, m: LegacyAny): TierCostView {
  const best: Record<string, number | null> = {}, label = (r: LegacyAny) => r.label || (r.name === 'Full' ? t('tcSetItself') : '.' + r.name);
  for (const tier of TIERS) { const vals = rows.map(r => dmg[r.name][tier]).filter(v => v != null && v > 0);
    best[tier] = vals.length ? (m.low ? Math.min(...vals) : Math.max(...vals)) : null; }
  // how much worse than the tier's best, in %: slower for a time, less for the rest
  const lossOf = (v: number, b: number | null) => !v || !b ? 0 : m.low ? (v / b - 1) * 100 : (1 - v / b) * 100;
  const cell = (r: LegacyAny, tier: string) => { const v = dmg[r.name][tier];
    if (v == null) return null;
    const loss = lossOf(v, best[tier]!), on = !r.draft && worn[tier] === r.name;
    return {text: (on ? '● ' : '') + m.fmt(v), best: v === best[tier], worn: on, loss: loss > 0.05 ? `${m.low ? '+' : '−'}${loss.toFixed(1)} %` : ''}; };
  const lines = TIERS.map(tier => {
    const w = rows.find(r => r.name === worn[tier]), top = rows.filter(r => dmg[r.name][tier] === best[tier])[0];
    const loss = lossOf(dmg[w.name][tier], best[tier]!);
    return loss < 0.05 || !top ? {warn: false, html: t('tcOk', {t: tier, s: esc(label(w))})}
      : {warn: true, html: t(m.obj ? 'tcLoseEng' : 'tcLose', {t: tier, s: esc(label(w)), b: esc(label(top)), p: loss.toFixed(1)})}; });
  return {whyHtml: m.obj ? t('tcWhyEng', {o: esc(t('engObj_' + m.obj))}) : t('tcWhy', {tp: (S as LegacyAny).wsTp || 3000}), setHtml: t('tcSet'), tiers: TIERS,
    rows: rows.map(r => ({label: label(r), cells: TIERS.map(x => cell(r, x))})), lines, howHtml: t(m.obj ? 'tcHowEng' : 'tcHow')};
}
