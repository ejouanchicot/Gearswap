// GearSwap Atelier · a set's stats sheet (under its figures): the sum of its pieces, one tab a group of stats (what the
// set is after first, by weight; damage taken on top), the stats only true sometimes (Set:, latent, Unity...) in a tab
// of their own, the paths and names the page cannot read in notes. One group shown at a time, its tab kept from set
// to set; the filter of the stats shown in the head.
// The rules are the old page's setStatsHTML (stats.js). The buttons keep data-stattab (events.js) and the filter's
// data-statpick (statPickBtn, its HTML).
//
// @file    atelier/src/screens/sets/sheet.ts
// @author  ejouanchicot
import {row} from './figures';
import {capLine, damageTaken, type Line} from './statlines';

export interface SheetView {
  kickerHtml: string; pickHtml: string; tabs: Array<{key: string; label: string; n: number; title: string; selected: boolean}>;
  body: null | {k: 'lines'; lines: Line[]} | {k: 'cond'; items: Array<{piece: string; text: string}>}; notesHtml: string[];
}

/** The stats sheet of the set s, or null when it has nothing to show (and no filter to undo) */
export function sheetView(s: LegacyAny): SheetView | null {
  const S0 = S as LegacyAny, {total, paths, unknown, cond} = setStats(s);
  const v = (k: string) => (total[k] || {}).v || 0, dtOn = (v('dt') || v('pdt') || v('mdt')) && statShown('dtEff');
  const sorter = statSorter(s, total) as LegacyAny, lineOf = (k: string): Line => { const cap = STAT_DEF[k] && STAT_DEF[k][3];
    return cap ? capLine(esc(statLabel(k, total[k])), total[k].v, cap, t('gearOnly')) : row(esc(statLabel(k, total[k])), fmtStat(total[k])); };
  // what the set is after: a tab of its own, first and open by default, by weight (damage taken on top); the groups
  // keep the rest
  const wantFirst = setWants(s).want;
  const isWanted = (k: string) => wantFirst && !DT_KEYS.includes(baseKey(k)) && wantOf(wantFirst, k) >= 0.3;
  const wantedKeys = wantFirst ? Object.keys(total).filter(k => total[k].v && isWanted(k) && statVisible(k, s)).sort(sorter) : [];
  type Group = {key: string; label: string; n: number; body: NonNullable<SheetView['body']>};
  const groups: Group[] = (STAT_GROUPS.map(([g, fr, en]: [string, string, string]) => {
    const keys = Object.keys(total).filter(k => total[k].v && statGroup(k) === g && !isWanted(k) && statVisible(k, s)).sort(sorter);
    // Damage taken: DT counts in both, physical and magic, up to -50 % together
    const lines = (g === 'def' && dtOn ? damageTaken(v) : []).concat(keys.map(lineOf));
    return lines.length ? {key: g, label: S0.lang === 'fr' ? fr : en, n: lines.length, body: {k: 'lines', lines}} : null;
  }) as Array<Group | null>).filter((x): x is Group => !!x);
  if (wantedKeys.length) { const lines = (dtOn ? damageTaken(v) : []).concat(wantedKeys.map(lineOf));
    groups.unshift({key: 'want', label: t('cmpWanted'), n: lines.length, body: {k: 'lines', lines}}); }
  const notesHtml: string[] = [];
  if (paths.length) notesHtml.push(`${t('pathNote')} ${paths.map(esc).join(', ')}`);
  if (unknown.length) notesHtml.push(`${t('unknownNote')} ${unknown.map(esc).join(', ')}`);
  // what only applies sometimes (Set:, latent, Unity, Aftermath...): a tab of its own, one line per effect, its piece first
  if (cond.length) groups.push({key: 'cond', label: t('condTab'), n: cond.length, body: {k: 'cond', items: cond.map((c: string) => { const [piece, ...txt] = c.split(' — ');
    return {piece: piece || '', text: txt.join(' — ')}; })}});
  if (!(groups.length || Object.keys(S0.statHide).length || S0.statOnlyWant)) return null;
  // one group at a time, its tab kept from set to set (the first when that group is not there)
  const cur = groups.find(g => g.key === S0._statTab) || groups[0];
  return {kickerHtml: t('setStats'), pickHtml: statPickBtn(), notesHtml, body: cur ? cur.body : null,
    tabs: groups.map(g => ({key: g.key, label: g.label, n: g.n, selected: g === cur, title: (T as LegacyAny)[S0.lang]['ttStatTab_' + g.key] ? t('ttStatTab_' + g.key) : ''}))};
}
