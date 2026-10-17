// GearSwap Atelier · the job's sections (Sets, Buffs & target, My character, the job's settings, Simulate), as the
// row of tabs over the page. Shown on a job with an export, never on the settings, the packages or the overview.
// The tabs keep the attribute the old page's click handler reads (events.js data-section) until its screens move.
//
// @file    atelier/src/screens/topbar/sections.ts
// @author  ejouanchicot

export interface SectionTab { key: string; label: string; count: number | ''; title: string; selected: boolean }

/** The five sections and the text key of their names; Sets counts the job's sets */
const SECTIONS: Array<[string, string]> = [['sets', 'sectionsSets'], ['combat', 'ui2Combat'], ['perso', 'ui2Perso'],
  ['jobcfg', 'ui2JobCfg'], ['sim', 'sectionsSim']];

/** The tabs for the old page's state now, or null when the page shows no job */
export function sectionTabs(): SectionTab[] | null {
  if ((S._pkg && typeof renderPackages === 'function') || S._cfg || !S.job) return null;
  const d = data();
  if (!d) return null;
  return SECTIONS.map(([key, label]) => {
    const count = key === 'sets' ? d.sets.length : '';
    return {key, label: t(label), count, selected: S.section === key,
      title: T[S.lang]['ttTab_' + key] ? t('ttTab_' + key, {n: count}) : ''};
  });
}
