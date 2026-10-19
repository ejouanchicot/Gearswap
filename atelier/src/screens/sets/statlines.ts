// GearSwap Atelier · the lines of the stats lists (the set's sheet, every stat, My character's cards): a stat as a
// row (name, value, a note), a stat the game caps as a gauge (how far from the cap, "max" once there, what goes past
// it for nothing), damage taken with its II layer, damage taken once something multiplies it (Fan Dance, Rampart).
// The rules are the old page's statLi, cappedLi, layeredLi, mulLi and damageTakenLines (stats.js).
//
// @file    atelier/src/screens/sets/statlines.ts
// @author  ejouanchicot
import {row, type StatRow} from './figures';

export interface CapLine { k: 'cap'; full: boolean; title: string | undefined; labelHtml: string; value: string; capmax: string; capOf: string; fill: number; overl: string }
export type Line = StatRow | CapLine;

const r1 = (x: number) => Math.round(x * 10) / 10;

/** A stat the game stops at a cap, as a gauge (cappedLi); small: a note under it when nothing goes past the cap */
export function capLine(label: string, sum: number, cap: number, detail: string, small = ''): CapLine {
  const over = Math.abs(sum) > Math.abs(cap), full = Math.abs(sum) >= Math.abs(cap);
  return {k: 'cap', full, title: statHelp(label, detail) || undefined, labelHtml: label, value: signed(r1(over ? cap : sum)) + ' %',
    capmax: full ? t('capMax') : '', capOf: t('capOf', {c: signed(cap)}), fill: Math.max(0, Math.min(100, cap ? Math.round(100 * sum / cap) : 0)),
    overl: over ? t('capWaste', {n: r1(Math.abs(sum - cap))}) : small};
}

/** A damage taken with its II stat on one line: the first layer stops at -50 %, the II one adds past it, -87.5 % in
 * all (the line's total; its small text: the first layer against its cap, what is wasted past it, the II) */
export function layeredLine(label: string, raw: number, two: number, name: string, detail: string): StatRow {
  const first = Math.max(raw, -50), total = Math.max(first + two, -87.5), over = raw < -50 ? r1(-50 - raw) : 0;
  const extra = `${signed(r1(first))} / −50` + (over ? ` (${t('cmpOver', {n: over})})` : '') + ` + ${name} ${signed(two)}`;
  return row(label, signed(r1(total)) + ' %', extra, '', `${detail} = ${r1(raw)}, ${t('dtCapNote')} ; + ${name} ${two} = ${r1(total)} % (−87,5 % max)`);
}

/** A damage taken once what multiplies it past the cap is in (BG Wiki: not capped by the -50 %), or null */
export function mulLine(label: string, gear: number, keys: string[], B: LegacyAny): StatRow | null {
  const by = ((B && B._by) || []).filter((e: LegacyAny) => keys.includes(e.k) && e.v !== 1);
  if (!by.length) return null;
  const total = (by.reduce((m: number, e: LegacyAny) => m * e.v, 1 + gear / 100) - 1) * 100;
  const how = `${t('mulGear')} ${signed(r1(gear))} % ` + by.map((e: LegacyAny) => `× ${e.src} ${signed(r1((e.v - 1) * 100))} %`).join(' ');
  return row(label, signed(r1(total)) + ' %', how, '', how);
}

/** Damage taken (Guide_Paladin, 03_defense): DT + PDT and DT + MDT stop at -50 %; PDT II (Burtgang) and MDT II (Aegis)
 * go on past it, up to -87.5 % in all; Shell lowers magic damage under the same cap */
export function damageTaken(v: (k: string) => number): Line[] {
  const B = buffTotals(), shell = B.shell ? Math.round(-B.shell / 256 * 1000) / 10 : 0;
  const pdtRaw = v('dt') + v('pdt'), mdtRaw = v('dt') + v('mdt') + shell, pdt = Math.max(pdtRaw, -50), mdt = Math.max(mdtRaw, -50);
  const pDetail = `DT ${v('dt')} + PDT ${v('pdt')}`, mDetail = `DT ${v('dt')} + MDT ${v('mdt')}` + (shell ? ` + ${buffState().shell} ${shell}` : '');
  // with what multiplies the damage past the cap (Fan Dance): one line, the total, its gauge against the most the gear's
  // cap and the dance give together (-60 % for 20 %); the gear's own share and the dance's are its small text
  const pMul = ((B && B._by) || []).filter((e: LegacyAny) => (e.k === 'dmgmul' || e.k === 'pdmgmul') && e.v !== 1), pm = pMul.reduce((m: number, e: LegacyAny) => m * e.v, 1);
  const pHow = `${t('mulGear')} ${signed(r1(pdt))} % ` + pMul.map((e: LegacyAny) => `× ${e.src} ${signed(r1((e.v - 1) * 100))} %`).join(' ');
  const out: Array<Line | null> = v('pdt2') ? [layeredLine(t('pdtTotal'), pdtRaw, v('pdt2'), 'PDT II', pDetail), mulLine(t('pdtWithMul'), Math.max(pdt + v('pdt2'), -87.5), ['dmgmul', 'pdmgmul'], B)]
    : pMul.length ? [capLine(t('pdtEff'), r1(((1 + pdt / 100) * pm - 1) * 100), r1((.5 * pm - 1) * 100), `${pDetail} ; ${pHow}`, pHow)]
    : [capLine(t('pdtEff'), pdtRaw, -50, pDetail)];
  out.push(v('mdt2') ? layeredLine(t('mdtTotal'), mdtRaw, v('mdt2'), 'MDT II', mDetail) : capLine(shell ? t('mdtShell') : t('mdtEff'), mdtRaw, -50, mDetail));
  out.push(mulLine(t('mdtWithMul'), Math.max(mdt + v('mdt2'), -87.5), ['dmgmul'], B));
  if (v('bdt')) out.push(capLine(t('bdtEff'), v('dt') + v('bdt'), -50, `DT ${v('dt')} + BDT ${v('bdt')}`));
  return out.filter((x): x is Line => !!x);
}
