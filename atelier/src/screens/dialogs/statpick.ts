// GearSwap Atelier · the stats picker (the sets' stats sheet, Compare): every stat by group, a box a group with how
// many are shown and All / None, a box to tick a stat; on top what it is for and the tools (the order, the stats the
// set is after only, the presets).
// The rules are the old page's openStatPick (stats.js): the tools stay its HTML (statPickTools). Drawn again in place
// when it is open already (a stat ticked keeps the list where it was scrolled). The boxes keep the attributes the old
// handlers read (.statpick data-stat, data-statgroup, data-statall, data-statnone).
//
// @file    atelier/src/screens/dialogs/statpick.ts
// @author  ejouanchicot

export interface StatPickView {
  title: string; whyHtml: string; toolsHtml: string;
  groups: Array<{g: string; title: string; on: number; n: number; all: string; none: string; rows: Array<{k: string; checked: boolean; label: string}>}>;
  allHtml: string; noneHtml: string; closeHtml: string;
}

/** The stats picker (openStatPick) */
export function statPickView(): StatPickView {
  const fr = (S as LegacyAny).lang === 'fr', keys = ['dtEff'].concat(Object.keys(STAT_DEF).filter(k => !['dt', 'pdt', 'mdt', 'pdt2', 'mdt2', 'bdt'].includes(k)));
  const groups = STAT_GROUPS.map(([g, frName, enName]: [string, string, string]) => {
    const list = keys.filter(k => (k === 'dtEff' ? 'def' : statGroup(k)) === g);
    return {g, title: fr ? frName : enName, on: list.filter(statShown).length, n: list.length, all: t('statAll'), none: t('statNone'),
      rows: list.map(k => ({k, checked: statShown(k), label: k === 'dtEff' ? t('dtEff') : statLabel(k, {})}))};
  }).filter((x: LegacyAny) => x.n);
  return {title: t('statPick'), whyHtml: t('statPickWhy'), toolsHtml: statPickTools(), groups, allHtml: t('statAll'), noneHtml: t('statNone'), closeHtml: t('close')};
}
