// GearSwap Atelier · the settings of a weaponskill set, under its title: the weapon held (the weapon mode's by default,
// or one of yours of the weaponskill's kind, best first, with the off hand that goes with it), then the TP it goes at
// (the steps, a TP of your own, what the TP comes to with its bonus); the explanation of a line opens under it on a
// click of its ⓘ (only a set with a weaponskill has it: the base set, sets.precast.WS, has none).
// The rules are the old page's wsHeadHTML, wsWeaponLine, heldSubMenu, fitOptions and wsTpLine (ws_page.js). A job with
// a stance or a gated weapon state (PLD, THF) keeps its weapon states' menus (weapons.ts). The controls keep the attributes the old handlers read (data-heldws, data-wstp, .tpin, data-help: events.js).
//
// @file    atelier/src/screens/sets/wshead.ts
// @author  ejouanchicot

import {weaponMenusView, type WeaponMenu} from './weapons';

export interface WsOption { value: string; label: string; selected: boolean; disabled?: boolean }
export interface WsLine { label: string; tip: string; help: string; open: boolean; helpTip: string }
export type WsWeapon = {k: 'menus'; menus: WeaponMenu[]}
  | {k: 'held'; line: WsLine; ws: string; held: {set: boolean; title: string; options: WsOption[]}; sub: {set: boolean; title: string; options: WsOption[]}};
export interface WsTp {
  line: WsLine; chips: Array<{v: string; label: string; pressed: boolean; title: string}>; input: {value: string; ph: string; title: string};
  res: null | {total: number; over: string}; fallback: string; tb: {total: number; bits: string}; old: string;
}
export interface WsHeadView { weapon: WsWeapon | null; tp: WsTp }

const S0 = (): LegacyAny => S;
// a line of the head: its label, its ⓘ and its explanation, open under it on a click
const lineOf = (label: string, tip: string, key: string): WsLine => ({label, tip, help: key, open: !!tip && S0()._help === key, helpTip: t('ttHelp')});

// the off hand for a weaponskill: Auto (what the weapon set or the grip rule gives), then yours; the ones the main hand
// cannot take on one line at the end, how many and why (an option greyed one by one reads as broken)
function subOf(s: LegacyAny, ws: string): Extract<WsWeapon, {k: 'held'}>['sub'] {
  const main = withWeapons(s).pieces.main, auto = withWeapons(s, 'heldsub').pieces.sub, cur = (S0().heldSub || {})[heldKey(ws)];
  const why = (x: LegacyAny) => subWhy(main, x), list = forceList('sub');
  const shown = cur && list.some((x: LegacyAny) => x.name === cur.name && !why(x));
  const off = list.filter((x: LegacyAny) => why(x)), reasons = [...new Set(off.map(why))];
  const options: WsOption[] = [{value: '', label: 'Sub · ' + t('auto') + ' · ' + (auto && !isEmpty(auto) ? auto.name : '—'), selected: !cur}];
  if (cur && !shown) options.push({value: 'cur', label: cur.name + ' · ' + (why(cur) || t('heldGone')), selected: true});
  list.forEach((x: LegacyAny, i: number) => { if (!why(x)) options.push({value: String(i), label: x.name, selected: !!cur && !!shown && cur.name === x.name}); });
  if (off.length) options.push({value: '', label: t('subOff', {n: off.length, w: (main && main.name) || '—', r: reasons.join(' · ')}), selected: false, disabled: true});
  return {set: !!cur, title: t('ttHeldSub'), options};
}
// the weapon line: the weapon mode's weapon by default, or one of yours of the weaponskill's category, best first
function weaponOf(s: LegacyAny): WsWeapon | null {
  const d = data() as LegacyAny, ws = wsOfSet(s) as string;
  // a job with a stance or a gated state on its weapons (PLD, THF): its weapon states' menus, as on any set
  if (hybridMode(d) || weaponModes(d).some((m: LegacyAny) => WEAPON_GATES[m.name])) {
    const menus = weaponMenusView(s);
    return menus.length ? {k: 'menus', menus} : null;
  }
  const auto = withWeapons(s, 'held').pieces.main, held = heldWeapon(ws), list: string[] = heldChoices(ws), rank = heldRanking(s, ws, list);
  const sorted = rank ? list.slice().sort((a, b) => (rank[b] || 0) - (rank[a] || 0)) : list;
  const dmg = (n: string) => rank && rank[n] != null ? ' — ' + fmtDmg(rank[n]) : '';
  // a weapon out of reach (a slip, the Mog House) says where it is: it has to be taken out first
  const where = (n: string) => { const w = [...new Set(((ownedOf() || {}).main || []).filter((x: LegacyAny) => x.name === n).flatMap((x: LegacyAny) => x.where || []))] as string[];
    return w.length && !w.some(x => /^(Inventory|Wardrobe)/.test(x)) ? ' · ' + w.map(whereLabel).join(', ') : ''; };
  const options: WsOption[] = [{value: '', label: t('heldMode', {w: auto && !isEmpty(auto) ? auto.name : '—'}), selected: !held}];
  if (held && !sorted.includes(held)) options.push({value: held, label: held + ' · ' + t('heldGone'), selected: true});
  for (const n of sorted) options.push({value: n, label: n + dmg(n) + where(n), selected: n === held});
  return {k: 'held', line: lineOf(t('weaponLbl'), t('weaponTip'), 'weapon'), ws, held: {set: !!held, title: t('ttHeldWs'), options}, sub: subOf(s, ws)};
}
// the TP steps, then the TP the weaponskill opens with (its make-up in the explanation), the TP Bonus in total
function tpOf(s: LegacyAny): WsTp {
  const wsTp = S0().wsTp, live = liveWrite();
  const r = tpAsk(s, withWeapons(s).pieces, null), steps: number[] = tpSteps(r, s), parts = tpTotalParts(s, r);
  const bonus = r && r.bonus ? ` ${t('tpBonusOf', {n: r.bonus})}` : '';
  const note = !live ? t('tpNeedLive') : r && r.config === false ? t('tpNoConfig') : (wsTp ? t('tpLiveNote') : t('tpOffNote')) + bonus;
  const chip = (v: string, label: string) => ({v, label, pressed: String(wsTp || '') === v, title: +v ? t('ttWsTp', {n: v}) : t('ttWsTpOff')});
  const tb = tpBonusParts(s, r), bits = [tb.base ? t('tpTotBase', {n: tb.base}) : '', tb.party ? t('tpTotParty', {n: tb.party}) : '', tb.gear ? t('tpbGear', {n: tb.gear}) : ''].filter(Boolean).join(' · ');
  return {line: lineOf(t('tpLbl'), (parts ? parts.text + '. ' : '') + note + Object.entries(S0()._tpWhy || {}).map(([v, w]) => ` ${v} : ${w}.`).join(''), 'tp'),
    chips: [chip('', t('tpOff')), ...steps.map(v => chip(String(v), String(v)))],
    input: {value: wsTp && !steps.includes(+wsTp) ? String(wsTp) : '', ph: t('tpOther'), title: t('ttWsTpOther')},
    // past 3000 the game keeps 3000: what is over is TP Bonus spent for nothing
    res: parts ? {total: parts.total, over: parts.raw > 3000 ? t('tpOver', {t: parts.raw, n: parts.raw - 3000}) : ''} : null,
    fallback: !r ? t(live ? 'tpAsking' : 'tpDefault') : '', tb: {total: tb.total, bits}, old: parts && r && !r.worn_aware ? t('tpOldCode') : ''};
}

/** The head of a weaponskill set (wsHeadHTML) */
export function wsHeadView(s: LegacyAny): WsHeadView {
  return {weapon: weaponOf(s), tp: tpOf(s)};
}
