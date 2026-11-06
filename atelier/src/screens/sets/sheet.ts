// GearSwap Atelier · a set's stats sheet (the figures' column, Figures.svelte): the sum of its pieces, every group of
// stats at once, each in a box of its own (damage taken on top of Defense), the stats only true sometimes (Set:, latent,
// Unity...) last, the paths and names the page cannot read in notes; and the Summary's caps (damage taken, the capped
// stats the set is after). The pet's stats only for a job with a pet. The rules are
// the old page's setStatsHTML (stats.js); the filter of the stats shown in the head (data-statpick, statPickBtn).
//
// @file    atelier/src/screens/sets/sheet.ts
// @author  ejouanchicot
import {row} from './figures';
import {capLine, damageTaken, type Line} from './statlines';

export interface SheetGroup { key: string; label: string; title: string; body: {k: 'lines'; lines: Line[]} | {k: 'cond'; items: Array<{piece: string; text: string}>} }
export interface SheetView {
  kickerHtml: string; pickHtml: string; groups: SheetGroup[]; cond: SheetGroup | null; notesHtml: string[];
  // the Summary tab's caps (Figures.svelte): damage taken and the capped stats the set is after, each as its gauge
  caps: Line[];
}

// the jobs whose pet the gear's "Pet:" stats are for (a Luopan for GEO)
const PET_JOBS = ['BST', 'SMN', 'PUP', 'DRG', 'GEO'];

/** The stats sheet of the set s, or null when it has nothing to show (and no filter to undo) */
export function sheetView(s: LegacyAny): SheetView | null {
  const S0 = S as LegacyAny, {total, pet, paths, unknown, cond} = setStats(s);
  const v = (k: string) => (total[k] || {}).v || 0, dtOn = (v('dt') || v('pdt') || v('mdt')) && statShown('dtEff');
  const sorter = statSorter(s, total) as LegacyAny, lineOf = (k: string): Line => { const cap = STAT_DEF[k] && STAT_DEF[k][3];
    return cap ? capLine(esc(statLabel(k, total[k])), total[k].v, cap, t('gearOnly')) : row(esc(statLabel(k, total[k])), fmtStat(total[k])); };
  const fr = S0.lang === 'fr', tip = (g: string) => (T as LegacyAny)[S0.lang]['ttStatTab_' + g] ? t('ttStatTab_' + g) : '';
  const shown = Object.keys(total).filter(k => total[k].v && statVisible(k, s));
  // every group, its stats by weight; Damage taken: DT counts in both, physical and magic, up to -50 % together
  const groups: SheetGroup[] = (STAT_GROUPS.map(([g, gfr, gen]: [string, string, string]) => {
    const lines = (g === 'def' && dtOn ? damageTaken(v) : []).concat(shown.filter(k => statGroup(k) === g).sort(sorter).map(lineOf));
    return lines.length ? {key: g, label: fr ? gfr : gen, title: tip(g), body: {k: 'lines', lines}} : null;
  }) as Array<SheetGroup | null>).filter((x): x is SheetGroup => !!x);
  // the Summary's caps: damage taken, then each capped stat the set is after (Haste, Subtle Blow, Fast Cast...)
  const want = setWants(s).want;
  const caps = (dtOn ? damageTaken(v) : []).concat(want ? shown.filter(k => !DT_KEYS.includes(baseKey(k)) && STAT_DEF[k] && STAT_DEF[k][3]
    && wantOf(want, k) >= 0.3).sort(sorter).map(lineOf) : []);
  // the pet's stats added up (Pet: Accuracy, Attack, Haste...), on a job with a pet: its damage taken first, as the
  // player's own: physical and magic, the Stout Servant trait and gear in (bst_pet.js petDefense), -87.5 % for pets;
  // Pet: DT, PDT and MDT then not again on lines of their own
  const petKeys = Object.keys(pet).filter(k => pet[k].v && !['dt', 'pdt', 'mdt'].includes(k)).sort(statOrder);
  const pd = petDefense(pet, total), stout = (total['x:stout servant'] || {}).v || 0;
  if (PET_JOBS.includes(S0.job) && (petKeys.length || stout || pd.on && Object.keys(pet).length)) {
    const lines: Line[] = [capLine(esc(t('petPdtLine')), pd.pdt, -87.5, pd.pDetail), capLine(esc(t('petMdtLine')), pd.mdt, -87.5, pd.mDetail),
      ...petKeys.map(k => row(esc(statLabel(k, pet[k])), fmtStat(pet[k])))];
    groups.push({key: 'pet', label: t('petTab'), title: tip('pet'), body: {k: 'lines', lines}}); }
  const notesHtml: string[] = [];
  if (paths.length) notesHtml.push(`${t('pathNote')} ${paths.map(esc).join(', ')}`);
  if (unknown.length) notesHtml.push(`${t('unknownNote')} ${unknown.map(esc).join(', ')}`);
  // what only applies sometimes (Set:, latent, Unity, Aftermath...): a box of its own, last, one line per effect, its piece first
  const condGroup: SheetGroup | null = cond.length ? {key: 'cond', label: t('condTab'), title: tip('cond'), body: {k: 'cond', items: cond.map((c: string) => {
    const [piece, ...txt] = c.split(' — '); return {piece: piece || '', text: txt.join(' — ')}; })}} : null;
  if (!(groups.length || condGroup || Object.keys(S0.statHide).length || S0.statOnlyWant)) return null;
  return {kickerHtml: t('setStats'), pickHtml: statPickBtn(), notesHtml, groups, cond: condGroup, caps};
}
