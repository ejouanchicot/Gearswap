// GearSwap Atelier · the party's pickers in Buffs & target: a song, a roll, a bubble, a storm or a food for a slot (each
// choice by family with what it gives, None to take it off), and the jobs to add to the party (by what they bring).
// The rules are the old page's pbOpenPick and pbOpenAdd (party_builder.js): their lists stay PB_PICK's and
// pbAddGroups'. The search on top hides the choices and the families that do not match (pbDlgSearch), here in the
// window itself. The buttons keep the attributes the old handlers read (data-pbchoose, data-pbadd).
//
// @file    atelier/src/screens/dialogs/partypick.ts
// @author  ejouanchicot

export interface PickItem { attr: 'data-pbchoose' | 'data-pbadd'; value: string; q: string; on: boolean; label: string; hint: string }
export interface PartyPickView { qPh: string; groups: Array<{title: string; items: PickItem[]}> }


/** A slot's picker (pbOpenPick): its title, its choices, None when it holds one */
export function pickView(key: string): null | {title: string; view: PartyPickView; none: null | {value: string; label: string}} {
  const kind = key.replace(/\d+$/, ''), P = PB_PICK[kind], cur = buffState()[key];
  if (!P) return null;
  const item = (v: string): PickItem => { const h = P.hint(v);
    return {attr: 'data-pbchoose', value: `${key}|${v}`, q: v.toLowerCase(), on: v === cur, label: v, hint: h && h.toLowerCase() !== v.toLowerCase() ? h : ''}; };
  const groups = P.groups().filter(([, list]: [string, string[]]) => list.length).map(([g, list]: [string, string[]]) => ({title: g, items: list.map(item)}));
  return {title: P.title(key.match(/\d+$/) ? key.match(/\d+$/)![0] : ''), view: {qPh: t('pbSearch'), groups}, none: cur ? {value: `${key}|`, label: t('pbNone')} : null};
}

/** The jobs to add to the party (pbOpenAdd), or null when it is full */
export function addView(): null | {title: string; view: PartyPickView} {
  const shown = pbShown(buffState()), left = PB_MAX - shown.length - 1;
  if (left <= 0) return null;
  const groups = pbAddGroups(shown).map(([g, l, hint]: [string, string[], (j: string) => string]) => ({title: g,
    items: l.map(j => ({attr: 'data-pbadd' as const, value: j, q: (j + ' ' + hint(j)).toLowerCase(), on: false, label: j, hint: hint(j)}))}));
  return {title: t('pbAddTitle', {n: left}), view: {qPh: t('pbSearch'), groups}};
}
