// GearSwap Atelier · the panel of the party member chosen in Buffs & target: a form, a line a setting (its name, a list,
// a button opening a list, or a switch, then what it gives you), in titled sections on two columns at most. You:
// food, aftermath, your own abilities; GEO: the bubbles; BRD: the songs; COR: the rolls; WHM, RDM: their spells and
// what they cast on the target; SCH: the storm; any other job: its abilities that reach you and its debuffs.
// The rules are the old page's pbYouBody, pbBody, pbSel, pbPlus, pbPickBtn, pbFoeRows (party_builder.js), amRowHTML and
// rollChips (buff_panels.js). The controls keep the attributes the old
// handlers read (data-buff, data-buffflag, data-pbpick, data-pbmarcato, data-foeja, data-foeseg, data-ja).
//
// @file    atelier/src/screens/combat/panel.ts
// @author  ejouanchicot
import type {Gives} from './combat';

export interface Option { value: string; label: string; selected: boolean }
export type Control =
  | {k: 'select'; cls: string; attrs: Record<string, string>; title?: string; options: Option[]}
  | {k: 'pick'; key: string; set: boolean; label: string; title: string}
  | {k: 'switch'; attrs: Record<string, string>; on: boolean; title: string}
  | {k: 'note'; text: string}
  | {k: 'chip'; attrs: Record<string, string>; pressed: boolean; disabled: boolean; title: string; label: string};
export type Effect = {k: 'gives'; list: Gives[]} | {k: 'muted'; text: string} | {k: 'html'; html: string} | {k: 'fx'; controls: Control[]};
export interface Row { k: 'row'; label: string; controls: Control[]; effects: Effect[] }
// Warcry's line (its Savagery merits, Agoge Mask, the TP Bonus they give) and the party DNC's menu (main DNC and its
// merits, or a /DNC)
export type ExtraCtl = {kind: 'warcry'; party: boolean; on: boolean; lv: number; agoge: boolean; note: string}
  | {kind: 'samba'; label: string; opts: Array<{v: string; label: string; on: boolean}>};
export type Item = Row | {k: 'extra'; label: string; ctl: ExtraCtl} | {k: 'am'; label: string; controls: Control[]; said: string};
export type Block = {k: 'section'; title: string; items: Item[]} | {k: 'extra'; ctl: ExtraCtl};
export interface PanelView { left: Block[]; right: Block[] }

const GOOD_LOW = ['shell', 'dt', 'pdt', 'mdt', 'bdt'];

// what the source named gives, out of the party's totals (pbEff, pbGives)
function gives(B: LegacyAny, src: (name: string) => boolean): Effect {
  const sum: Record<string, number> = {};
  for (const e of B._by) if (src(e.src) && typeof e.v === 'number') sum[e.k] = (sum[e.k] || 0) + e.v;
  const keys = Object.keys(sum);
  return {k: 'gives', list: keys.filter(k => !PB_FOE.includes(k)).map(k => ({text: fxShort(k, sum[k]!), neg: sum[k]! < 0 && !GOOD_LOW.includes(k)}))
    .concat(keys.filter(k => PB_FOE.includes(k)).map(k => ({text: fxShort(k, sum[k]!), neg: true})))};
}

const row = (label: string, controls: Control[], effects: Effect[] = []): Row => ({k: 'row', label, controls, effects});
const muted = (text: string): Effect => ({k: 'muted', text});
// a section with no line is not drawn (pbFSec)
const section = (title: string, items: Item[]): Block[] => items.length ? [{k: 'section', title, items}] : [];

// a list of values, the buff's own (pbSel): an empty "—" (the placeholder) first unless a default stands for it
function sel(b: LegacyAny, key: string, values: string[], ph = '—', def: string | null = null): Control {
  const now = String(b[key] ?? def ?? '');
  return {k: 'select', cls: `buffsel ${b[key] ? 'set' : ''}`, attrs: {'data-buff': key}, title: t('ttBuffSel', {n: ph}),
    options: (def ? values : ['', ...values]).map(v => ({value: v, label: v === '' ? ph : v, selected: String(v) === now}))};
}
// the gear's "+N" of a kind (Geomancy +10, Songs +9, Rolls +8: pbPlus)
function plus(b: LegacyAny, key: string, label: string, max: number): Control {
  const values = ['', ...Array.from({length: max}, (_, i) => String(i + 1))];
  return {k: 'select', cls: `buffsel plus ${b[key] ? 'set' : ''}`, attrs: {'data-buff': key}, title: label,
    options: values.map(v => ({value: v, label: `${label} +${v || 0}`, selected: v === String(b[key] ?? '')}))};
}
// a list whose values are their names, "—" first, marked when one of them is on (Dia, Haste, Distract)
function named(b: LegacyAny, key: string, values: string[]): Control {
  return {k: 'select', cls: `buffsel ${values.includes(b[key]) ? 'set' : ''}`, attrs: {'data-buff': key},
    options: [{value: '', label: '—', selected: false}].concat(values.map(v => ({value: v, label: v, selected: b[key] === v})))};
}
// a slot whose long list opens in a window (pbPickBtn)
const pick = (b: LegacyAny, key: string): Control => ({k: 'pick', key, set: !!b[key], label: b[key] || t('pbChoose'), title: t('ttPbPick')});
const sw = (attrs: Record<string, string>, on: unknown, title = ''): Control => ({k: 'switch', attrs, on: !!on, title});
const flag = (b: LegacyAny, key: string, tip: string): Control => sw({'data-buffflag': key}, b[key], t(tip));

// the debuffs this job casts on the target (FOE_JA): a switch a name (pbFoeRows)
function foeRows(B: LegacyAny, job: string, b: LegacyAny): Row[] {
  return Object.keys(FOE_JA[job] || {}).map(n => row(n.includes(': ') ? n.split(': ')[1]! : n,
    [sw({'data-foeja': n}, (b.foeJa || []).includes(n), n)], [gives(B, v => v === n)]));
}

function geoPanel(B: LegacyAny, b: LegacyAny): PanelView {
  const PRE: Record<string, string> = {indi: 'Indi-', geo: 'Geo-', entrust: 'Entrust Indi-'};
  const bubble = (key: string, label: string) => row(label, [pick(b, key)], [gives(B, v => v === PRE[key] + b[key])]);
  return {left: section(t('pbBubbles'), [bubble('indi', 'Indi'), bubble('geo', 'Geo'), bubble('entrust', 'Entrust'), row(t('pGear'), [plus(b, 'geoPlus', 'Geomancy', 10)])]),
    right: section(t('bJa'), [row('Blaze of Glory', [flag(b, 'bog', 'bogTip')], [muted('Geo +50 %')]),
      row('Ecliptic Attrition', [flag(b, 'ecliptic', 'eclipticTip')], [muted('Geo +25 %')]), row('Bolster', [flag(b, 'bolster', 'bolsterTip')], [muted('Indi, Geo ×2')])])};
}

function brdPanel(B: LegacyAny, b: LegacyAny): PanelView {
  const slots: number[] = songSlots(b);
  const songs = slots.map(i => row(`${t('bSong')} ${i + 1}`, [pick(b, 'song' + i)], [gives(B, v => v === b['song' + i])]));
  const marcato: Control = {k: 'select', cls: `buffsel ${b.marcato != null ? 'set' : ''}`, attrs: {'data-pbmarcato': ''},
    options: [{value: '', label: '—', selected: false}].concat(slots.map(i => ({value: String(i), label: `${t('bSong')} ${i + 1}`, selected: b.marcato != null && +b.marcato === i})))};
  const aria = slots.some(i => b['song' + i] === 'Aria of Passion')
    ? [row('Loughnashade', [{k: 'select', cls: 'buffsel set', attrs: {'data-buff': 'ariaStage'},
      options: Object.keys(ARIA_HORN).map(s => ({value: s, label: s, selected: (b.ariaStage || 'V') === s}))}])] : [];
  return {left: section(t('pbSongs'), songs),
    right: section(t('pbGear'), [row(t('pGear'), [plus(b, 'songsPlus', 'Songs', 9)]),
      row('Soul Voice', [flag(b, 'soulVoice', 'svTip')], [muted(t('pbSvHint'))]),
      row('Clarion Call', [flag(b, 'clarion', 'clarionTip')], [muted(t('pbClarionHint'))]), row('Marcato', [marcato]), ...aria])
      .concat(section(t('pbOnTarget'), foeRows(B, 'BRD', b)))};
}

function corPanel(B: LegacyAny, b: LegacyAny): PanelView {
  // the roll's list as wide as every list; its number, job bonus and Crooked Cards beside it
  const roll = (i: number) => row(`Roll ${i + 1}`, [pick(b, 'roll' + i)],
    (b['roll' + i] ? [{k: 'fx', controls: [sel(b, 'roll' + i + 'n', ROMAN, '', 'XI'), ...rollChips(b, i)]} as Effect] : [])
      .concat([gives(B, v => !!b['roll' + i] && v.startsWith(b['roll' + i] + ' Roll'))]));
  return {left: section(t('pbRolls'), [roll(0), roll(1), row(t('pGear'), [plus(b, 'rollsPlus', 'Rolls', 8)])]),
    right: section(t('pbOnTarget'), [row('Light Shot', [flag(b, 'lightshot', 'lsTip')], [gives(B, v => v === 'Light Shot')]), ...foeRows(B, 'COR', b)])};
}

const protectRows = (B: LegacyAny, b: LegacyAny): Row[] => [
  row('Protect', [sel(b, 'protect', Object.keys(PROTECT))], [gives(B, v => v.startsWith(b.protect || '§'))]),
  row('Shell', [sel(b, 'shell', Object.keys(SHELL))], [gives(B, v => v === b.shell)])];

function whmPanel(B: LegacyAny, b: LegacyAny, rdm: boolean): PanelView {
  const haste = rdm ? [] : [row('Haste', [sw({'data-foeseg': 'haste', 'data-v': 'Haste'}, b.haste === 'Haste')], [gives(B, v => v === 'Haste')])];
  const auspice = row('Auspice', [flag(b, 'auspice', 'auspiceTip') as Control].concat(b.auspice ? [sel(b, 'auspiceFeet', Object.keys(AUSPICE_FEET), t('auspiceFeet'))] : []),
    [gives(B, v => v === 'Auspice')]);
  return {left: section(t('pbBuffs'), [...protectRows(B, b), ...haste, auspice]),
    right: section(t('pbOnTarget'), [row('Dia', [named(b, 'dia', ['Dia', 'Dia II'])], [gives(B, v => v === b.dia)]), ...foeRows(B, 'WHM', b)])};
}

function rdmPanel(B: LegacyAny, b: LegacyAny, whm: boolean): PanelView {
  const nm = isNmTarget(enemyKey(b.enemy)), sabX = nm ? (b.sabGloves ? 1.39 : 1.25) : (b.sabGloves ? 2.14 : 2);
  const enspell = row('Enspell I', [flag(b, 'enspell', 'enspellTip') as Control].concat(b.enspell ? [sel(b, 'enSkill', EN_SKILLS.map(String), t('enSkillPh'), '600')] : []),
    [gives(B, v => v === 'Enspell I')]);
  const sab = row('Saboteur', [flag(b, 'saboteur', 'sabTip') as Control].concat(b.saboteur
    ? [sw({'data-buffflag': 'sabGloves'}, b.sabGloves, 'Lethargy Gantherots +3'), {k: 'note', text: 'Lethargy +3'}] : []), b.saboteur ? [muted(`×${sabX}`)] : []);
  return {left: section(t('pbBuffs'), [...(whm ? [] : protectRows(B, b)), row('Haste', [named(b, 'haste', ['Haste', 'Haste II'])], [gives(B, v => v === b.haste)]), enspell]),
    right: section(t('pbOnTarget'), [row('Dia · Bio', [named(b, 'dia', ['Dia III', 'Bio III'])], [gives(B, v => v === b.dia)]),
      row('Distract', [named(b, 'distract', Object.keys(DISTRACT))], [gives(B, v => !!b.distract && v.startsWith(b.distract))]), sab])};
}

// a job whose abilities reach you, and what it casts on the target: a switch each
function jaPanel(B: LegacyAny, b: LegacyAny, job: string): PanelView {
  const list: LegacyAny[] = pbJaJobs().get(job) || [];
  const mine = list.map(ja => row(ja.name.replace(' · party', ''), [sw({'data-ja': ja.name}, jaOn(b, ja.name), jaTip(ja))], [gives(B, v => v === ja.name)]));
  const extra: Block[] = (list.some(x => x.name === 'Warcry · party') && jaOn(b, 'Warcry · party') ? [{k: 'extra', ctl: warcryOf(b, true)} as Block] : [])
    .concat(list.some(x => x.name === 'Haste Samba') && jaOn(b, 'Haste Samba') ? [{k: 'extra', ctl: sambaOf(b)}] : []);
  const foe = foeRows(B, job, b);
  if (mine.length && foe.length) return {left: section(t('pbBuffs'), mine).concat(extra), right: section(t('pbOnTarget'), foe)};
  return {left: section(mine.length ? t('pbBuffs') : t('pbOnTarget'), mine.length ? mine : foe).concat(extra), right: []};
}

/** The panel of a party member other than you */
// Your own Warcry (a WAR main's) or a party WAR's (counted at 5/5 with the mask unless chosen otherwise): greyed while
// Warcry is off
function warcryOf(b: LegacyAny, party: boolean): ExtraCtl {
  const on = party || jaOn(b, 'Warcry'), sv = party ? b.pSavagery : b.savagery;
  return {kind: 'warcry', party, on, lv: sv == null ? 5 : +sv, agoge: !(party ? b.pNoAgoge : b.noAgoge), note: on ? 'TP Bonus +' + warcryTp(b, party) : t('warcryOff')};
}
function sambaOf(b: LegacyAny): ExtraCtl {
  return {kind: 'samba', label: t('sambaWho'), opts: ['', 'm4', 'm3', 'm2', 'm1', 'm0', 'sub'].map(v => ({v, on: (b.pSamba || '') === v,
    label: v === 'sub' ? t('sambaSub') : t('sambaMain', {n: v ? v.slice(1) : 5, p: 5 + (v ? +v.slice(1) : 5)})}))};
}

// A roll's two buttons: its job in the party (its bonus; on by itself when it is your job), Crooked Cards (one roll)
function rollChips(b: LegacyAny, i: number): Control[] {
  const rj = ROLL_JOB[b['roll' + i]], mine = !!rj && rj[0] === S.job;
  return [{k: 'chip', attrs: {'data-rolljob': String(i)}, pressed: !!rollJobOn(b, i), disabled: !rj || mine, title: rj ? t(mine ? 'rollJobMine' : 'rollJobTip', {j: rj[0]}) : '', label: rj ? rj[0] : '—'},
    {k: 'chip', attrs: {'data-rollcc': String(i)}, pressed: b.rollCC != null && +b.rollCC === i, disabled: !b['roll' + i], title: t('rollCcTip'), label: 'CC'}];
}
// The Aftermath line: the level, the prime stage for a prime weapon, the TP for an aftermath that follows it, then the
// weapon in hand and what its aftermath is
function amRow(b: LegacyAny): Item {
  const w = shownMain() as string | null, kind = amKind(w), am = aftermathOf(w);
  const lv = sel(b, 'am', ['1', '2', '3'], t('bAmPh')) as LegacyAny;
  lv.options = lv.options.map((o: LegacyAny) => /^[123]$/.test(o.label) ? Object.assign({}, o, {label: 'Lv' + o.label}) : o);
  const controls: Control[] = [lv];
  if (kind === 'prime') controls.push(sel(b, 'amStage', ['III', 'IV', 'V'], t('bAmStage')));
  if (['mythic', 'prime', 'aeonic'].includes(kind) && !PRIME_PDL.has(w)) controls.push(sel(b, 'amTp', ['1000', '1250', '1500', '1750', '1999', '2000', '2250', '2500', '2750', '3000'], t('amTpPh')));
  const said = (isAfm3(((S as LegacyAny)._curSet || {}).path) ? t('amAfm3') + ' · ' : '') + (!w ? t('amNoWeapon') : `${w} · ${t('amKind_' + kind)}` + (am.text ? ` · ${am.text}` : ''));
  return {k: 'am', label: t('bAm'), controls, said};
}

export function memberPanel(job: string, b: LegacyAny, shown: string[]): PanelView {
  const B = buffTotals(), whm = shown.includes('WHM'), rdm = shown.includes('RDM');
  if (job === 'GEO') return geoPanel(B, b);
  if (job === 'BRD') return brdPanel(B, b);
  if (job === 'COR') return corPanel(B, b);
  if (job === 'WHM') return whmPanel(B, b, rdm);
  if (job === 'RDM') return rdmPanel(B, b, whm);
  if (job === 'SCH') return {left: section('Storm', [row('Storm', [pick(b, 'storm')], [gives(B, v => v === b.storm)])]), right: []};
  return jaPanel(B, b, job);
}

/** Your own panel: food, aftermath, your abilities (switches), your own Warcry's merits */
export function youPanel(b: LegacyAny): PanelView {
  const B = buffTotals();
  const jas = jasOf().filter((j: LegacyAny) => j.as !== 'party');
  const rows: Item[] = jas.map((j: LegacyAny) => row(j.name + (j.as === 'sub' ? ' /' + ((data() || {}).sub || '') : ''),
    [sw({'data-ja': j.name}, jaOn(b, j.name), jaTip(j))], [gives(B, v => v === j.name)]));
  const am = amRow(b);
  if (jas.some((j: LegacyAny) => j.name === 'Warcry' && j.as === 'main') && jaOn(b, 'Warcry')) rows.push({k: 'extra', label: 'Warcry', ctl: warcryOf(b, false)});
  return {left: section(t('pbYouBase'), [row(t('bFood'), [pick(b, 'food')], [gives(B, v => v === b.food)]), am]), right: section(t('bJa'), rows)};
}
