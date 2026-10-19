// GearSwap Atelier · the bags' small windows (My character > Bags): where the game's moogles stand (one line a zone,
// one column a kind of moogle, the zone the character stands in marked), what the Porter Moogle run does before it is
// asked, and the moves of the bags plan before they are sent (one folding group a bag to bag).
// The rules are the old page's openMooglePlaces, openPorterRun (bags_place.js) and openBagPlanSend (bags_plan.js),
// which keep the clicks and what the game is sent; their buttons (data-plrungo, data-bpsend) stay the old HTML.
//
// @file    atelier/src/screens/dialogs/bagdlg.ts
// @author  ejouanchicot

export type BagDialogView =
  | {kind: 'places'; why: string; zoneCol: string; kinds: string[]; you: string; gives: string; givesRows: Array<[string, string]>; src: string;
      rows: Array<{z: string; here: boolean; cells: Array<{yes: boolean; pos: string}>}>}
  | {kind: 'porter'; why: string; steps: string[]; naked: string; cmd: string}
  | {kind: 'send'; why: string; safe: string[]; count: string; none: string; noRoom: string; groups: Array<{k: string; n: number; names: string}>};

/** Every place of the game's moogles (openMooglePlaces) */
export function placesView(): BagDialogView {
  const kinds = Object.keys(MOOGLE_PLACES), zones: string[] = [...new Set(kinds.flatMap(k => (MOOGLE_PLACES[k] || []).map(([z]) => z)))], p = bvPlace();
  const rows = zones.map(z => ({z, here: !!p && p.zone === z, cells: kinds.map(k => { const at = (MOOGLE_PLACES[k] || []).find(([n]) => n === z);
    return {yes: !!at, pos: at ? at[1] || '' : ''}; })}));
  return {kind: 'places', why: t('plDlgWhy'), zoneCol: t('plColZone'), kinds, you: t('plYouAre'), rows, gives: t('plGives'), src: t('plSrc'),
    givesRows: [['Porter Moogle', t('plGivesPorter')], ['Nomad Moogle', t('plGivesNomad')], ['Mog House', t('plGivesHouse')]]};
}

/** What the Porter Moogle run does (openPorterRun) */
export function porterView(): BagDialogView {
  return {kind: 'porter', why: t('plRunWhy'), steps: ['plRun1', 'plRun2', 'plRun3'].map(k => t(k)), naked: t('plRunNaked'), cmd: t('plRunCmd')};
}

/** The bags plan's moves before they are sent (openBagPlanSend), the biggest bag to bag first */
export function bagSendView(mule: boolean): BagDialogView {
  const B = bvBags(), p = mule ? bpMuleMoves(B) : bpMoves(B), by: LegacyAny = {};
  for (const m of p.moves) (by[m.fromName + ' → ' + m.toName] = by[m.fromName + ' → ' + m.toName] || []).push(m.name);
  const groups = (Object.entries(by) as Array<[string, string[]]>).sort((a, b) => b[1].length - a[1].length).map(([k, names]) => ({k, n: names.length, names: names.join(', ')}));
  return {kind: 'send', why: t(mule ? 'bpMuleWhy' : 'bpSendWhy'), safe: ['bpSafe1', 'bpSafe2', 'bpSafe3', 'bpSafe4'].map(k => t(k)), groups,
    count: t('bpSendN', {n: p.moves.length}), none: t('bpSendNone'),
    noRoom: p.noRoom.length ? t(mule ? 'bpMuleNoRoom' : 'bpSendNoRoom', {n: p.noRoom.length, l: [...new Set(p.noRoom)].slice(0, 12).join(', ')}) : ''};
}
