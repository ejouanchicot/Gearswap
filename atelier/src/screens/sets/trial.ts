// GearSwap Atelier · the trial's bar of a set (under its card; in both optimizers): how many pieces are tried (or what
// the file changed), who tried them (the optimizer, at which tier), the damage they change on a weaponskill set, then
// what to do with them: write them into the file (or open the version the file has), compare, keep, save for the next
// load in game, see the Lua, go back to the earlier try, undo. Under the card, a line that says what goes there when
// nothing is tried yet.
// The rules are the old page's trialBar, trialRow and draftGainHTML (trial.js); the push button is push.ts (the
// search window's foot has it too). The buttons keep the
// attributes the old handlers read (data-pushopen, data-veropen, data-cmpopen, data-trykeep, data-trysave, data-trylua,
// data-tryprev, data-tryundo, data-setrevert: events.js).
//
// @file    atelier/src/screens/sets/trial.ts
// @author  ejouanchicot

import {pushBtnView, type PushBtn} from './push';

export interface TrialRow {
  saved: boolean; by: string; msgHtml: string; gain: null | {textHtml: string; up: boolean; pct: string};
  push: PushBtn | null; cmp: null | {labelHtml: string; kept: string};
  keep: null | {tip: string; labelHtml: string}; save: string; links: Array<{attr: string; labelHtml: string}>; toast: string;
}
export type TrialBar = {k: 'idle'; text: string} | {k: 'row'; row: TrialRow} | null;

// on a weaponskill set, the damage with the try against your file's set (the engine present)
function gainOf(s: LegacyAny): TrialRow['gain'] {
  if (!wsOfSet(s)) return null;
  const was = withoutTrial(() => wsDamage(s)), now = wsDamage(s);
  if (was == null || now == null || !was) return null;
  const d = (now / was - 1) * 100;
  return {textHtml: t('draftGain', {a: fmtDmg(was), b: `<b>${fmtDmg(now)}</b>`}), up: d >= 0, pct: `(${d >= 0 ? '+' : ''}${d.toFixed(1)} %)`};
}

/** The pieces tried on a set (by hand or by the optimizer): what they change, then what to do with them; null when
 * nothing is tried, changed, kept or said */
export function trialRowView(s: LegacyAny): TrialRow | null {
  const S0 = S as LegacyAny, n = trialCount(s), changed = Object.keys(s.was || {}), dr = S0.drafts[trialKey(s)] || {};
  const toast = S0.toast && S0._toastSet === s.path ? S0.toast : '', kept = (dr.kept || []).length;
  if (!n && !changed.length && !dr.info && !toast && !kept) return null;
  const saved = n > 0 && trialSaved(s), live = liveWrite();
  const links: TrialRow['links'] = [];
  if (n) links.push({attr: 'data-trylua', labelHtml: t('tryLua')});
  if (dr.info && dr.prev) links.push({attr: 'data-tryprev', labelHtml: t('tryPrev')});
  if (n) links.push({attr: 'data-tryundo', labelHtml: t('tryUndo')}); else if (changed.length) links.push({attr: 'data-setrevert', labelHtml: t('setRevert')});
  return {saved: saved || (!n && changed.length > 0), by: dr.info ? t('tryOptBy', {t: dr.info.tier, at: dr.info.at}) + (dr.info.edited ? ' · ' + t('tryEdited') : '') : '',
    msgHtml: n ? (saved ? t('trySaved', {n: `<b>${n}</b>`}) : t('tryBar', {n: `<b>${n}</b>`})) : changed.length ? t('setChanged', {s: changed.map(x => (SLOT_NAMES[S0.lang] || {})[x] || x).join(', ')}) : '',
    gain: n ? gainOf(s) : null, push: n || changed.length ? pushBtnView(s, live) : null,
    cmp: n || changed.length || kept ? {labelHtml: t('cmpBtn'), kept: kept ? t('keptN', {n: kept}) : ''} : null,
    keep: n ? {tip: t('keepTip'), labelHtml: t('keepBtn')} : null, save: n && !saved ? t('trySave') : '', links, toast};
}

/** Under a set's card: the trial's row, or the line that says what comes there (not on a set only others build on) */
export function trialBarView(s: LegacyAny): TrialBar {
  const row = trialRowView(s);
  if (row) return {k: 'row', row};
  return ui2() && !baseOnly(s) ? {k: 'idle', text: t('tryIdle')} : null;
}
