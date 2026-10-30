// GearSwap Atelier · the Settings part of the job's settings, in the frame of the three parts (ProFrame.svelte; SPEC
// notes/docs-perso/config-pro-2026-10-30): the categories on the left (this job, then the themes of every job:
// module_catalog.js MOD_GROUPS), the options of the one chosen in the middle (a section a subject of the catalog, a
// line an option: its name, a plain sentence, its control), the detail of the option chosen on the right (what it
// does, its value, its default to set back), the changes that wait at the bottom, saved in one go (the game writes,
// or the page itself when it is not connected: modules.js modSave). Only what the page can set is shown: the settings
// the catalog does not explain stay in their files.
// The rules are the old page's renderModules, renderModulesSimple, mcIntroHTML, mcCardHTML, modRowHTML, modListHTML,
// modGroupHTML (modules.js), modTop, modSaveBar, modSearch (module_ux.js), modControl, mcControl (modules.js: a setting's
// control, ModCtl below), modNum, modColorMap, modPresets (module_ux.js), modChips (module_items.js), modRows (module_rows.js).
//
// @file    atelier/src/screens/config/modules.ts
// @author  ejouanchicot

export interface SaveLine { title: string; was: string; now: string; file: string; path: string; ex: string }
/** An option on one line: its icon, its name, a plain sentence, its control (lists, tables, the gauge under it); what
 *  the detail on the right says of it */
export interface RegRow { key: string; iconHtml: string; label: string; sub: string; sel: boolean; changed: boolean; tall: boolean; ctl: ModCtl; gauge: Gauge | null; info: RowInfo }
export interface RowInfo { what: string; example: string; value: string; std: string; reset: null | Record<string, string>; tag: string; path: string }
export interface HudColors { k: 'colors'; parts: Array<{label: string; hex: string; auto: string; attr: string; reset: string; resetTip: string}>; values: Array<{label: string; hex: string; attr: string}>; valuesTitle: string }
export interface RefillSpecial {
  k: 'refill'; now: string; items: Array<{label: string; count: number; icoHtml: string}>; empty: string;
  modes: Array<{label: string; tip: string; attr: string; on: boolean}>;
  list: null | RegRow; addExtra: null | {label: string; attr: string};
  subs: {title: string; tip: string; wait: string; rows: Array<{label: string; row: {ctl: ModCtl} | null; summary: string; del: string; delTip: string}>; add: null | {label: string; attr: string; options: string[]}};
}
/** A table of tiers {min, max, spell} (the Cure tiers) as an HP gauge: a part a tier, a handle between two to drag */
export interface Gauge { attr: string; off: boolean; parts: Array<{label: string; from: number; flex: number; tip: string}>; end: string; fix: string }
/** A section: a subject of the catalog in one file (or a card of its own: the job's refill, the HUD's colours) */
export interface RegCard { id: string; title: string; iconHtml: string; small: string; rows: RegRow[]; own?: string; special?: RefillSpecial | HudColors; info?: RowInfo }
export interface ModulesView {
  none: string | null;
  nav: ProNav;
  head: {iconHtml: string; title: string; sub: string};
  sections: RegCard[];
  empty: string;
  detail: ProDetail | null;
  foot: ProFoot;
  /** the Display's live preview of the HUD (hud_preview.js): its HTML, the style of its box; null while drawn */
  hud: null | {html: string; style: string; error: string; note: string; title: string; hint: string; reset: null | {label: string; attrs: Record<string, string>}};
  /** the icons' authors, under the categories (pro.ts iconCredit) */
  credit: string;
}

import type {ProNav, ProDetail, ProFoot} from './pro';
import {iconCredit} from './pro';

const famName = (fam: LegacyFamily) => (S.lang === 'en' ? fam.en : fam.fr).split('{JOB}').join(S.job || '');
const lang = () => S.lang === 'en' ? 1 : 0;
// a job's name in full (core.js JOBS): "White Mage"
const jobName = (j: string) => ((JOBS as unknown as Array<[string, string, string]>).find(x => x[0] === j) || [j, j])[1];

// ---- a setting's control (the old page's modControl, mcControl: modules.js) ----
export type ModCtl = {k: 'seg'; id: Record<string, string>; off: boolean; btns: Array<{attrs: Record<string, string>; label: string; pressed: boolean; tip: string}>; input: null | {value: string; ph: string; tip: string}}
  | {k: 'switch'; id: Record<string, string>; off: boolean; on: boolean; tip: string; labelHtml: string}
  | {k: 'text'; id: Record<string, string>; off: boolean; value: string; tip: string}
  | {k: 'code'; summary: string; code: string}
  | {k: 'num'; id: Record<string, string>; off: boolean; value: string; lim: Record<string, string>; tip: string; unit: string;
      slide: null | {min: number; max: number; step: number; tip: string}; steps: Array<{step: number; sign: string; tip: string; aria: string}>;
      std: null | {is: true; text: string} | {is: false; v: LegacyAny; text: string; tip: string}}
  | {k: 'color'; attrs: Record<string, string>; off: boolean; hex: string; tip: string; of: string}
  | {k: 'presets'; label: string; off: boolean; tiles: Array<{attrs: Record<string, string>; pressed: boolean; tip: string; style: string; name: string}>}
  | {k: 'multi'; parts: ModCtl[]}
  | {k: 'chips'; id: Record<string, string>; off: boolean; pic: boolean; dragTip: string; gear: boolean;
      tiles: Array<{label: string; modeTip: string; icoHtml: string; del: string}>; add: ChipAdd}
  | {k: 'rows'; id: Record<string, string>; off: boolean; cols: Array<{k: string; kind: string; title: string}>; gear: boolean;
      rows: Array<{fresh: boolean; unfilled: boolean; cells: RowCell[]}>; fillTip: string; fill: string; acts: Array<{what: string; sign: string; tip: string; aria: string}>;
      add: {pick: boolean; tip: string; label: string}};
export type ChipAdd = {k: 'pick'; attrs: Record<string, string>; tip: string; label: string} | {k: 'bags'; list: Array<{b: string; tip: string}>}
  | {k: 'input'; ph: string; gear: boolean; tip: string};
export type RowCell = {k: 'slot'; empty: boolean; tip: string; options: Array<{value: string; label: string; selected: boolean}>}
  | {k: 'num'; value: string; tip: string} | {k: 'text'; icoHtml: string; value: string; gear: boolean; tip: string};
const idAttrs = (file: string, path: string) => ({'data-modfile': file, 'data-modpath': path});
// what a control says under the pointer: what a click or a typed value does; read only, why
const tipOf = (off: string, key: string, v?: LegacyAny) => off ? t('ttModRead') : t(key, v);

// A number (module_ux.js mxNumOpts): - and + by its step, a slider when it has bounds, its unit, its standard value
function numOf(x: LegacyField, val: LegacyAny, id: Record<string, string>, off: string, lopts?: LegacyAny): ModCtl {
  const o = mxNumOpts(x, lopts), lim: Record<string, string> = o.range ? {'data-min': String(o.range[0]), 'data-max': String(o.range[1])} : {};
  const step = (dir: number, sign: string, key: string) => ({step: dir * o.step, sign, tip: off ? t('ttModRead') : t(key, {s: o.step}), aria: t(key, {s: o.step})});
  return {k: 'num', id, off: !!off, value: String(val), lim, unit: o.unit || '', tip: tipOf(off, o.range ? 'mxRange' : 'ttModNum', o.range ? {a: o.range[0], b: o.range[1]} : {}),
    slide: o.range ? {min: o.range[0], max: o.range[1], step: o.step, tip: tipOf(off, 'mxSlide', {a: o.range[0], b: o.range[1]})} : null,
    steps: [step(-1, '−', 'mxLess'), step(1, '+', 'mxMore1')],
    std: o.std == null ? null : val === o.std ? {is: true, text: t('mxIsStd')} : {is: false, v: o.std, text: t('mxStd', {v: o.std}), tip: tipOf(off, 'mxStdTip', {v: o.std})}};
}
// A colour: its picker, its code, its three numbers
const swatch = (rgb: number[], attrs: Record<string, string>, off: string): ModCtl => ({k: 'color', attrs, off: !!off, hex: mxHex(rgb[0], rgb[1], rgb[2]),
  tip: tipOf(off, 'mxColor'), of: t('mxColorOf', {r: rgb[0], g: rgb[1], b: rgb[2]})});
// A table that holds a colour as three named numbers (r g b): the colour itself
function colorMapOf(f: LegacyConfigFile, x: LegacyField, off: string): ModCtl {
  const keys = mxColorMap(x) as string[];
  return swatch(keys.map(k => modValue(f.file, x.path + '.' + k) as number), {'data-modcolor': keys.join(','), 'data-modfile': f.file, 'data-modpath': x.path}, off);
}
// The colours a file offers ready made (its table `from`), the one in use lit
function presetsOf(f: LegacyConfigFile, x: LegacyField, from: string, off: string): ModCtl | null {
  const all = modParsed(f).byPath[from]; if (!all || all.kind !== 'map') return null;
  const rgba = (p: string) => ['r', 'g', 'b', 'a'].map(k => modValue(f.file, p + '.' + k) as LegacyAny), cur = rgba(x.path).join(',');
  const tiles = all.fields.filter((p: LegacyField) => mxColorMap(p)).map((p: LegacyField) => { const v = rgba(p.path), name = String(p.key).replace(/_/g, ' ');
    return {attrs: {'data-modpreset': p.path, 'data-modfile': f.file, 'data-modpath': x.path}, pressed: v.join(',') === cur, tip: tipOf(off, 'mxPresetTip', {n: name, a: v[3]}),
      style: `background:${mxHex(v[0], v[1], v[2])};opacity:${Math.max(.25, (v[3] == null ? 255 : v[3]) / 255)}`, name}; });
  return tiles.length ? {k: 'presets', label: t('mxPresets'), off: !!off, tiles} : null;
}

// A list (module_items.js): its entries as tiles to drag, items with their icons, a `$Mode` entry marked; then what adds
// one (a picker of weaponskills, of abilities and spells, of items, a bag's name, or a field to type in)
function chipsOf(val: LegacyAny[], id: Record<string, string>, off: string, opts: LegacyAny): ModCtl {
  const pic = !!(opts.items || opts.gear);
  const add: ChipAdd = opts.ws ? {k: 'pick', attrs: {'data-modpick': '', 'data-wspick': ''}, tip: tipOf(off, 'mxWsTip'), label: t('mxWsAdd')}
    : opts.acts ? {k: 'pick', attrs: {'data-modpick': '', 'data-actpick': ''}, tip: tipOf(off, 'mxActTip'), label: t('mxActAdd')}
    : opts.items ? {k: 'pick', attrs: {'data-modpick': ''}, tip: tipOf(off, 'miAddTip'), label: t('miAdd')}
    : opts.bags ? {k: 'bags', list: opts.bags.filter((b: string) => !val.includes(b)).map((b: string) => ({b, tip: tipOf(off, 'miBagTip', {v: b})}))}
    : {k: 'input', ph: t('modAdd'), gear: !!opts.gear, tip: tipOf(off, 'ttModAdd')};
  return {k: 'chips', id, off: !!off, pic, dragTip: tipOf(off, 'miDragTip'), gear: !!opts.gear, add,
    tiles: val.map(v => ({label: miLabel(v), modeTip: miIsMode(v) ? t('miModeTip', {v}) : '', icoHtml: pic ? itemIco(v) : '', del: t('modDel', {v})}))};
}
// A table of lines (module_rows.js): a column per field (a slot, a number, a name with its icon), each line moved or
// taken off, then what adds one
function rowsCtl(x: LegacyField, val: LegacyAny[], id: Record<string, string>, off: string, opts: LegacyAny): ModCtl {
  const cols = mrCols(x).map((k: string) => mrCol(x, k, opts)), kinds = cols.map((c: LegacyAny) => c.kind);
  const cell = (col: LegacyAny, r: LegacyAny): RowCell => {
    const v = r[col.k], first = Array.isArray(v) ? v[0] : v;
    if (col.kind === 'slot') { const list: string[] = MR_SLOTS.includes(v) || mrEmpty(v) ? MR_SLOTS : [v, ...MR_SLOTS];
      return {k: 'slot', empty: mrEmpty(v), tip: tipOf(off, 'mrCellSlot'), options: list.map(s => ({value: s, label: t('mrS_' + s) !== 'mrS_' + s ? t('mrS_' + s) : s, selected: s === v}))}; }
    if (col.kind === 'num') return {k: 'num', value: mrCellShow(v), tip: tipOf(off, col.loose ? 'mrCellAll' : 'mrCellNum')};
    return {k: 'text', icoHtml: col.kind === 'item' || col.kind === 'gear' ? itemIco(first || '') : '', value: Array.isArray(v) ? v.join(', ') : v === undefined ? '' : String(v),
      gear: col.kind === 'gear', tip: tipOf(off, col.many || col.kind === 'item' ? 'mrCellMany' : 'mrCellText')};
  };
  const act = (what: string, sign: string, label: string) => ({what, sign, tip: off ? t('ttModRead') : t(label), aria: t(label)});
  return {k: 'rows', id, off: !!off, gear: kinds.includes('gear'), cols: cols.map((c: LegacyAny) => ({k: c.k, kind: c.kind, title: c.title})),
    rows: val.map(r => ({fresh: r._o == null, unfilled: mrUnfilled(x, r), cells: cols.map((c: LegacyAny) => cell(c, r))})), fillTip: t('mrFillTip'), fill: t('mrFill'),
    acts: [act('up', '↑', 'mrUp'), act('down', '↓', 'mrDown'), act('del', '×', 'mrDel')],
    add: kinds.includes('item') ? {pick: true, tip: tipOf(off, 'miAddTip'), label: t('mrAddItem')} : {pick: false, tip: tipOf(off, 'mrAddTip'), label: t(kinds.includes('gear') ? 'mrAddGear' : 'mrAdd')}};
}

// A setting's control by its kind: a value its comment names in quotes (buttons), 'auto' or a forced value, a switch,
// a number, a colour, a text, a list of tiles, a table of lines; anything else is shown as written
function ctlOf(f: LegacyConfigFile, x: LegacyField, val: LegacyAny, file: string, path: string, off: string, lopts?: LegacyAny): ModCtl {
  const id = idAttrs(file, path), opts = modOptions(x);
  const seg = (list: string[], cur: LegacyAny, label?: (o: string) => string, tip?: string) => list.map(o =>
    ({attrs: {'data-modopt': o}, label: label ? label(o) : o, pressed: o === cur, tip: tipOf(off, o === cur ? 'ttModChosen' : tip || 'ttModChoose', {v: label ? label(o) : o})}));
  if (modAuto(x)) return {k: 'seg', id, off: !!off, btns: seg(['auto'], val, () => t('modAuto'), 'ttModAuto'), input: {value: val === 'auto' ? '' : modShow(val), ph: t('modForce'), tip: tipOf(off, 'ttModForce')}};
  if (typeof val === 'boolean') return {k: 'switch', id, off: !!off, on: val, tip: tipOf(off, val ? 'ttModTurnOff' : 'ttModTurnOn'), labelHtml: t(val ? 'modOn' : 'modOff')};
  if (opts) return {k: 'seg', id, off: !!off, btns: seg(opts, val), input: null};
  if (x.kind === 'num') return numOf(x, val, id, off, lopts);
  if (mxColorList(f, x)) return swatch(val, {'data-modcolor': 'list', ...id}, off);
  if (x.kind === 'str') return {k: 'text', id, off: !!off, value: String(val), tip: tipOf(off, 'ttModText')};
  if (x.kind === 'list') return chipsOf(val, id, off, lopts || {});
  if (x.kind === 'rows') return rowsCtl(x, val, id, off, lopts || {});
  return {k: 'code', summary: t('modInFileLine', {f: f.file, l: f.text.slice(0, x.a).split('\n').length}), code: f.text.slice(x.a, x.b)};
}
// An option of the Options view: the catalog's own choices as buttons, a colour as its picker and presets, else the
// setting's own control
function mcCtl(r: LegacyCatalogRow, val: LegacyAny, off: string): ModCtl {
  const col = S.lang === 'en' ? 2 : 1;
  if (r.it.choices) return {k: 'seg', id: idAttrs(r.f.file, r.x.path), off: !!off, input: null, btns: r.it.choices.map((c: LegacyAny, i: number) =>
    ({attrs: {'data-mcchoice': r.id + ':' + i}, label: c[col], pressed: c[0] === val, tip: tipOf(off, c[0] === val ? 'ttModChosen' : c[0] === 'auto' ? 'ttModAuto' : 'ttModChoose', {v: c[col]})}))};
  if (r.it.rgb) { const pre = r.it.presets ? presetsOf(r.f, r.x, r.it.presets as string, off) : null; return {k: 'multi', parts: [colorMapOf(r.f, r.x, off)].concat(pre ? [pre] : [])}; }
  return ctlOf(r.f, r.x, val, r.f.file, r.x.path, off, r.it);
}

// ---- the categories and their subjects ----
// One idea, one icon, everywhere (game-icons.net, game_icons.js): a category's, its subjects' (an option takes its
// subject's), and the Modes themes' (player_words.js PLAYER_GROUPS) agree; "This job" is the job's own emblem
const THEME_ICON: Record<string, string> = {auto: 'gi:gears', gear: 'gi:armor-vest', cmd: 'gi:tied-scroll', bags: 'gi:backpack',
  display: 'gi:tv', multi: 'gi:two-shadows', tools: 'gi:plug'};
const FAM_ICON: Record<string, string> = {automed: 'gi:standing-potion', recast: 'gi:hourglass', subjob: 'gi:two-shadows', dw: 'gi:crossed-swords',
  belt: 'gi:belt', hporder: 'gi:heart-plus', weapon: 'gi:crossed-swords', buff: 'gi:sunbeams', cleanse: 'gi:standing-potion', stealth: 'gi:invisible',
  warp: 'gi:magic-portal', refill: 'gi:backpack', wardrobe: 'gi:chest-armor', craft: 'gi:gear-hammer', hud: 'gi:tv', chat: 'gi:chat-bubble',
  lockstyle: 'gi:chest-armor', dualbox: 'gi:two-shadows', addons: 'gi:plug'};
// a subject of this job by what it sets (the catalog's job family holds several)
const JOB_ICON: Array<[RegExp, string]> = [[/cure|curaga|soin/i, 'gi:heart-bottle'], [/refresh|mp/i, 'gi:magic-potion'], [/tp bonus|weaponskill|fencer/i, 'gi:sword-brandish']];
const themeIcon = (id: string) => id === 'job' ? emblem(S.job || '') : playerIcon(THEME_ICON[id] || 'gi:cog');
// An option's icon: its subject's (one idea, one icon), except the three universal ones: a time, a share of MP, HP
function famIcon(r: LegacyCatalogRow): string {
  const fam = r.id.split('.')[0] || '';
  if (fam === 'job') { const hit = JOB_ICON.find(([re]) => re.test(r.title)); return hit ? hit[1] : 'gi:cog'; }
  return FAM_ICON[fam] || 'gi:cog';
}
function rowIcon(r: LegacyCatalogRow, unit: string): string {
  const u = unit.toLowerCase();
  return playerIcon(u === 's' ? 'gi:hourglass' : /mp/.test(u) ? 'gi:magic-potion' : /hp/.test(u) ? 'gi:heart-plus' : famIcon(r));
}

// Which card shows a file's other settings: the first card of the first theme that reaches the file (a file is folded
// once). The files no subject reaches get a card of their own, in their file's theme
interface Plan { cards: Map<string, Array<{fam: LegacyFamily | null; f: LegacyConfigFile; rows: LegacyCatalogRow[]}>>; special: LegacyConfigFile[] }
function planOf(d: LegacyExport): Plan {
  const files = modFiles(d) as LegacyConfigFile[], cards = new Map<string, Array<{fam: LegacyFamily | null; f: LegacyConfigFile; rows: LegacyCatalogRow[]}>>();
  const folded = new Set<string>(), special = files.filter(f => f.scope === 'job' && REG_SPECIAL.test(f.file));
  special.forEach(f => folded.add(f.file));
  for (const g of MOD_GROUPS) cards.set(g.id, []);
  for (const g of MOD_GROUPS) for (const fam of MOD_CATALOG.filter(x => x.group === g.id)) {
    const byFile = new Map<string, LegacyCatalogRow[]>();
    for (const r of mcRows(d, fam)) { if (!byFile.has(r.f.file)) byFile.set(r.f.file, []); byFile.get(r.f.file)!.push(r); }
    for (const [file, rows] of byFile) {
      const f = files.find(x => x.file === file); if (!f || special.includes(f)) continue;
      cards.get(g.id)!.push({fam, f, rows}); folded.add(file);
    }
  }
  for (const f of files) if (!folded.has(f.file)) { const g = cards.has(modFileGroup(f)) ? modFileGroup(f) : 'tools'; cards.get(g)!.push({fam: null, f, rows: []}); folded.add(f.file); }
  return {cards, special};
}

// a table of tiers: every line a {min, max, spell}, back to back (the Cure / Curaga tiers of WHM_CURE_CONFIG.lua)
function gaugeOf(r: LegacyCatalogRow, val: LegacyAny, off: string): Gauge | null {
  const rows = Array.isArray(val) ? val as Array<Record<string, LegacyAny>> : [];
  if (r.x.kind !== 'rows' || rows.length < 2 || !rows.every(x => typeof x.min === 'number' && typeof x.max === 'number' && typeof x.spell === 'string')) return null;
  // the last tier is open ended (99999): drawn as wide as the tier before it
  const last = rows[rows.length - 1]!, prev = rows[rows.length - 2]!, cap = last.min + Math.max(200, prev.max - prev.min);
  return {attr: r.f.file + '|' + r.x.path, off: !!off, end: last.max >= 99999 ? cap + '+' : String(last.max), fix: t('regGaugeFix'),
    // a tier too narrow for its name keeps it in its tooltip
    parts: rows.map((x, i) => ({label: (Math.min(x.max, cap) - x.min) / cap < 0.07 ? '' : i && /\s[IVX]+$/.test(x.spell) ? x.spell.split(' ').pop()! : x.spell, from: x.min, flex: Math.max(1, Math.min(x.max, cap) - x.min), tip: t('regGaugeTip', {s: x.spell, a: x.min, b: x.max >= 99999 ? '∞' : x.max})}))};
}
// a name that repeats its card's ("HUD : titre" in the HUD card): the card says it once
const bare = (title: string, card: string) => { const m = /^([^:]{2,14}) : (.+)$/.exec(title); return m && card.toLowerCase().includes(m[1]!.toLowerCase()) ? m[2]!.replace(/^./, c => c.toUpperCase()) : title; };
// an option's plain sentence: the catalog's own (`short`), else the first sentence of what it does
function shortOf(r: LegacyCatalogRow): string {
  const own = (r.it as LegacyAny).short as [string, string] | undefined;
  if (own) return own[lang()] || '';
  const first = String(r.desc || '').split(/(?<=[.!?])\s/)[0] || '';
  return first.length > 96 ? first.slice(0, 94).replace(/\s+\S*$/, '') + '…' : first.replace(/[.:]$/, '');
}
const scopeTag = (f: LegacyConfigFile) => f.scope === 'job' ? t('regOwn', {j: jobName(S.job || '')}) : t('cfgEveryJob');
function infoOf(r: LegacyCatalogRow, ctl: ModCtl, val: LegacyAny): RowInfo {
  const unit = ctl.k === 'num' && ctl.unit ? ' ' + ctl.unit : '', show = (v: LegacyAny) => typeof v === 'boolean' ? t(v ? 'modOn' : 'modOff').replace(/<[^>]+>/g, '') : mxCut(mxValText(v)) + unit;
  const std = ctl.k === 'num' && ctl.std ? (ctl.std.is ? val : ctl.std.v) : (r.it as LegacyAny).std;
  const ex = (r.it as LegacyAny).ex as [string, string] | undefined;
  // a list: its entries; a table of lines: how many (the lines are in the middle)
  const value = Array.isArray(val) && !val.length ? t('cfgNone') : r.x.kind === 'rows' ? t('cfgLines', {n: (val as unknown[]).length})
    : Array.isArray(val) ? mxCut(val.map(v => typeof v === 'object' ? JSON.stringify(v) : String(v)).join(', ')) : show(val);
  return {what: r.desc || '', example: ex ? ex[lang()] || '' : '', value, std: std == null ? '' : show(std),
    reset: ctl.k === 'num' && ctl.std && !ctl.std.is ? {'data-modstd': String(ctl.std.v), ...idAttrs(r.f.file, r.x.path)} : null,
    tag: scopeTag(r.f), path: S.char + '/' + r.f.file};
}
function regRow(d: LegacyExport, r: LegacyCatalogRow, card: string): RegRow {
  const edits = modEdits(r.f.file), ed = edits[r.x.path], val = ed ? ed.v : r.x.value, off = modCanWrite(r.f) ? '' : 'disabled';
  const ctl = mcCtl(r, val, off), key = r.f.file + '|' + r.x.path;
  // a short list stays on its line; a long one, a table, a colour and its presets go under the name
  const tall = ctl.k === 'chips' ? ctl.tiles.length > 2 || ctl.add.k === 'bags' : ctl.k === 'seg' ? ctl.btns.length > 4 : ['rows', 'multi', 'presets', 'code'].includes(ctl.k);
  return {key, iconHtml: rowIcon(r, ctl.k === 'num' ? ctl.unit : ''), label: bare(r.title, card), sub: shortOf(r), sel: S._regSel === key,
    changed: !!ed || (!!r.it.rgb && r.x.fields.some(c => edits[c.path])), tall, ctl, gauge: gaugeOf(r, val, off), info: infoOf(r, ctl, val)};
}
type CardSrc = {fam: LegacyFamily | null; f: LegacyConfigFile; rows: LegacyCatalogRow[]; part?: string};
// a subject too long for one card, cut by what its options set: [test on the setting's path, the card's name]
const SPLIT: Record<string, Array<[RegExp, string]>> = {hud: [[/^(enabled|show_|sections\.)/, 'regHudShow'], [/./, 'regHudLook']]};
function splitOf(c: CardSrc): CardSrc[] {
  const cuts = c.fam && SPLIT[c.fam.id]; if (!cuts) return [c];
  const out: CardSrc[] = [], left = [...c.rows];
  cuts.forEach(([re, name]) => { const mine = left.filter(r => re.test(r.x.path)); mine.forEach(r => left.splice(left.indexOf(r), 1));
    if (mine.length) out.push({...c, rows: mine, part: name}); });
  return out.length ? out : [c];
}
function regCard(d: LegacyExport, c: CardSrc, many: boolean): RegCard {
  const id = (c.fam ? c.fam.id : 'file') + '|' + c.f.file + (c.part ? '|' + c.part : '');
  const title = c.part ? t(c.part) : c.fam && !many ? famName(c.fam) : fileTitle(d, c.f).name;
  return {id, title, small: c.fam && c.fam.use ? (/\/\/gs c \w+/.exec(c.fam.use[lang()] || '') || [''])[0] : '',
    iconHtml: playerIcon(c.fam ? (c.fam.id === 'job' && c.rows[0] ? famIcon(c.rows[0]) : FAM_ICON[c.fam.id] || THEME_ICON[c.fam.group] || 'gi:cog') : THEME_ICON[modFileGroup(c.f)] || 'gi:cog'),
    rows: c.rows.map(r => regRow(d, r, c.fam ? famName(c.fam) + ' ' + title : title))};
}
// ---- the job's refill list (reg_special.js) ----
function refillCard(d: LegacyExport, f: LegacyConfigFile): RegCard {
  const j = S.job || '', file = f.file, now = refillNow(d, file), fam = MOD_CATALOG.find(x => x.id === 'refill')!;
  const rowOf = (key: string) => { const r = mcRows(d, fam).find(x => x.f.file === file && x.x.path === key); return r ? regRow(d, r, '') : null; };
  const label = (n: string | string[]) => Array.isArray(n) ? n[0]! : n;
  const p = modParsed((modFiles(d) as LegacyConfigFile[]).find(x => x.file === file) || f), extra = rowOf('extra');
  const subs = refillSubs(file), waiting = !!modEdits(file).subjobs, opts = (fam.items.find(it => it.key === 'default') || {}) as LegacyAny;
  const subRows = Object.keys(subs).sort().map(s => {
    const x = p.byPath['subjobs.' + s], ed = modEdits(file)['subjobs.' + s], off = modCanWrite(f) ? '' : 'disabled';
    const row = !waiting && x ? {ctl: ctlOf(f, x, ed ? ed.v : x.value, file, x.path, off, opts)} : null;
    return {label: t('rfSub', {s}), row, summary: row ? '' : subs[s]!.map(e => label(e.name) + ' ×' + e.target).join(', ') || t('rfEmpty'), del: file + '|' + s, delTip: t('rfDelSub')};
  });
  const missing = MACRO_JOBS.filter(s => s !== j && !subs[s]);
  return {id: 'refill|' + file, title: t('rfTitle', {j}), small: '//gs c rf', own: t('regOwn', {j}), iconHtml: playerIcon('gi:backpack'), rows: [],
    info: {what: t('rfModeCommonTip') + ' ' + t('rfModeOwnTip', {j}), example: t('rfEx', {j}), value: t(now.mode === 'own' ? 'rfModeOwn' : 'rfModeCommon'), std: t('rfModeCommon'),
      reset: null, tag: t('regOwn', {j}), path: S.char + '/' + file},
    special: {k: 'refill', now: t('rfNow', {j}), empty: t('rfEmpty'),
      items: now.list.map(e => ({label: label(e.name), count: e.target, icoHtml: itemIco(label(e.name))})),
      modes: [{label: t('rfModeCommon'), tip: t('rfModeCommonTip'), attr: file + '|common', on: now.mode === 'common'}, {label: t('rfModeOwn'), tip: t('rfModeOwnTip', {j}), attr: file + '|own', on: now.mode === 'own'}],
      list: now.mode === 'own' ? rowOf('default') : extra, addExtra: now.mode === 'common' && !extra ? {label: t('rfAddExtra'), attr: file + '|extra'} : null,
      subs: {title: t('rfSubs'), tip: t('rfSubsTip'), wait: waiting ? t('rfSubWait') : '', rows: subRows, add: modCanWrite(f) ? {label: t('rfAddSub'), attr: file, options: missing} : null}}};
}

// the subjects that reach several files: a section a file, each named by its file
function manyOf(list: Array<{fam: LegacyFamily | null}>): Set<string> {
  const n = new Map<string, number>();
  for (const c of list) if (c.fam) n.set(c.fam.id, (n.get(c.fam.id) || 0) + 1);
  return new Set([...n].filter(([, k]) => k > 1).map(([id]) => id));
}
// A category's sections: its subjects (the job's refill card near its kind), the empty ones left out
function sectionsOf(d: LegacyExport, plan: Plan, g: LegacyGroup): RegCard[] {
  const list = (plan.cards.get(g.id) || []).filter(c => c.rows.length), many = manyOf(list);
  let cards = list.flatMap(splitOf).map(c => regCard(d, c, !!c.fam && many.has(c.fam.id)));
  // a section of one option named like it (a small file named by its option): the options of such sections together,
  // first, under "General"
  const lone = (c: RegCard) => c.rows.length === 1 && c.rows[0]!.label === c.title;
  const solo = cards.filter(lone);
  if (solo.length) cards = [{id: 'general|' + g.id, title: t('cfgGeneral'), iconHtml: '', small: '', rows: solo.flatMap(c => c.rows)} as RegCard].concat(cards.filter(c => !lone(c)));
  // the job's HUD order (<JOB>_HUD.lua) is set by dragging in the live preview (hud_preview.js), not in a card
  for (const f of plan.special.filter(x => modFileGroup(x) === g.id && !/_HUD\.lua$/.test(x.file)))
    cards.splice(cards.map(c => c.id.startsWith('refill|')).lastIndexOf(true) + 1, 0, refillCard(d, f));
  if (g.id === 'display') { const at = cards.map(c => c.id.startsWith('hud|')).lastIndexOf(true); cards.splice(at + 1, 0, colorsCard(d)); }
  return cards;
}
// the HUD's colours (hud_preview.js hudColorModel): a swatch a part of the HUD, then the values ON / OFF, PDT / MDT
function colorsCard(d: LegacyExport): RegCard {
  const m = hudColorModel(d);
  return {id: 'hudcolors', title: t('hudColors'), small: '', iconHtml: playerIcon('gi:tv'), rows: [],
    special: {k: 'colors', valuesTitle: t('hudColValues'),
      parts: m.parts.map(p => ({label: t('hudCol_' + p.id), hex: p.rgb ? hudHex(p.rgb) : '#ffffff', auto: p.auto ? t('hudColAuto') : '', attr: 'part|' + p.id,
        reset: p.set ? p.id : '', resetTip: t('hudColReset')})),
      values: m.values.map(v => ({label: t('hudVal_' + v.id) !== 'hudVal_' + v.id ? t('hudVal_' + v.id) : v.id, hex: hudHex(v.rgb), attr: 'value|' + v.file + '|' + v.path}))},
    info: {what: t('hudColorsWhat'), example: t('hudColorsEx'), value: '', std: '', reset: null, tag: t('cfgEveryJob'), path: S.char + '/_common/display/UI_CONFIG.lua'}};
}
// a category's short name on the left (its long one heads the list)
const catName = (g: LegacyGroup) => t('cfgCat_' + g.id) !== 'cfgCat_' + g.id ? t('cfgCat_' + g.id) : modGroupName(g);
const countIn = (cards: RegCard[]) => cards.reduce((n, c) => n + (c.special ? 1 : c.rows.length), 0);

// What a file is called (a section's title): its catalog name, except a job's small options file, named by the options it holds
// ("Set Refresh latent sous" rather than "Options de WHM")
function fileTitle(d: LegacyExport, f: LegacyConfigFile): {name: string; what: string} {
  const info = modFileInfo(f), base = f.file.split('/').pop() || '';
  if (/^[A-Z]{3}_CONFIG\.lua$/.test(base)) {
    const known = Object.values(modKnown(d, f)) as LegacyCatalogRow[];
    if (known.length >= 1 && known.length <= 2) return {name: known.map(r => r.title).join(' · '), what: ''};
  }
  return info;
}
// the changes waiting in a file: its values, and its examples added
const waiting = (file: string) => Object.keys(modEdits(file)).length + Object.keys(modAdds()[file] || {}).length;
const filesOf = (plan: Plan, g: string) => [...new Set((plan.cards.get(g) || []).map(c => c.f.file).concat(plan.special.filter(f => modFileGroup(f) === g).map(f => f.file)))];

// ---- the search: the options of every category whose words hold what is typed ----
function foundOf(secs: Map<string, RegCard[]>, q: string): RegCard[] {
  const words = mxNorm(q).split(/\s+/).filter(Boolean), out: RegCard[] = [];
  for (const g of MOD_GROUPS) for (const c of secs.get(g.id)!) {
    if (c.special) { if (mxHit(words, c.title, c.info ? c.info.what : '')) out.push(c); continue; }
    const rows = c.rows.filter(r => mxHit(words, r.label, r.sub, r.info.what, c.title, r.info.value));
    if (rows.length) out.push({...c, small: modGroupName(g), rows});
  }
  return out;
}

// ---- the detail on the right: the option chosen (else the category's first) ----
function detailOf(sections: RegCard[]): ProDetail | null {
  const rows = sections.flatMap(c => c.special ? [] : c.rows.map(r => ({c, r})));
  const sel = String(S._regSel || ''), card = sections.find(c => c.special && c.id === sel), hit = rows.find(x => x.r.key === sel) || (card ? null : rows[0]);
  const kv = (i: RowInfo): Array<[string, string]> => ([[t('cfgValue'), i.value], [t('cfgDefault'), i.std]] as Array<[string, string]>).filter(([, v]) => v);
  if (card && card.info) return {iconHtml: card.iconHtml, title: card.title, tag: card.info.tag, what: card.info.what, example: card.info.example, exampleTitle: t('cfgExample'),
    kv: kv(card.info), reset: null, foot: card.info.path};
  if (!hit) return null;
  const i = hit.r.info;
  return {iconHtml: hit.r.iconHtml, title: hit.r.label, tag: i.tag, what: i.what, example: i.example, exampleTitle: t('cfgExample'), kv: kv(i).concat([[t('cfgWhen'), t('cfgWhenReload')]]),
    reset: i.reset ? {label: t('cfgReset', {v: i.std}), attrs: i.reset} : null, foot: i.path};
}

// ---- the bar of the changes that wait ----
function footOf(): ProFoot {
  const all = ((S._modEdits || {}) as Record<string, Record<string, Record<string, LegacyEdit>>>)[S.char] || {}, lines: ProFoot['lines'] = [];
  for (const file of Object.keys(all)) for (const path of Object.keys(all[file]!)) { const e = all[file]![path]!;
    lines.push({title: mxTitle(file, path), was: mxCut(e.before), now: mxCut(e.after), revert: {'data-modrevert': '', 'data-modfile': file, 'data-modpath': path}}); }
  // a setting of a job file written for the first time (its line uncommented: reg_special.js) is part of its change
  const n = lines.length + Object.keys(modAdds()).filter(f => !all[f] || !Object.keys(all[f]!).length).length;
  return {msg: S.toast || '', n, text: t('cfgWaiting', {n}), ok: t('cfgSaved'), undo: n ? {label: t('mxUndoAll'), attrs: {'data-modundo': ''}} : null,
    save: n ? {label: t('modSave'), attrs: {'data-modsave': ''}} : null, lines, revertTip: t('mxRevert')};
}

/** The Settings part for the export shown */
export function modulesView(d: LegacyExport): ModulesView {
  const files = modFiles(d) as LegacyConfigFile[], q = String(S.modQ || '').trim();
  // every category's sections, built once for this drawing
  const plan = planOf(d), secs = new Map(MOD_GROUPS.map(g => [g.id, sectionsOf(d, plan, g)])), shown = MOD_GROUPS.filter(g => secs.get(g.id)!.length);
  // the category chosen (S.modTheme, kept): a file or a subject opened before 2026-10-30 (S.modFile, S.modFam) opens
  // its own; else this job's, else the first
  const old = S.modFile && S.modFile !== 'intro' ? [...plan.cards].find(([, cs]) => cs.some(c => c.f.file === S.modFile)) : null;
  const oldFam = S.modFam && S.modFam !== 'intro' ? MOD_CATALOG.find(x => x.id === S.modFam) : null;
  const g = shown.find(x => x.id === (S.modTheme || (old ? old[0] : oldFam ? oldFam.group : ''))) || shown[0];
  const item = (x: LegacyGroup) => { const n = countIn(secs.get(x.id)!);
    return {id: x.id, iconHtml: themeIcon(x.id), name: x.id === 'job' ? jobName(S.job || '') : catName(x), count: String(n), dot: filesOf(plan, x.id).some(f => waiting(f) > 0),
      current: !q && !!g && x.id === g.id, attr: {'data-modtheme': x.id}}; };
  const nav: ProNav = {search: {value: String(S.modQ || ''), placeholder: t('cfgSearch'), id: 'modq', clear: t('mxClear')},
    groups: [{label: t('cfgThisJob'), items: shown.filter(x => x.id === 'job').map(item)}, {label: t('cfgAllJobs'), items: shown.filter(x => x.id !== 'job').map(item)}].filter(x => x.items.length)};
  const foot = footOf();
  if (!files.length || !g) return {none: t('modNone'), nav, head: {iconHtml: '', title: '', sub: ''}, sections: [], empty: '', detail: null, foot, hud: null, credit: iconCredit()};
  const sections = q ? foundOf(secs, q) : secs.get(g.id)!;
  const head = q ? {iconHtml: playerIcon('gi:on-target'), title: t('mxFound', {n: countIn(sections), q}), sub: ''}
    : {iconHtml: themeIcon(g.id), title: g.id === 'job' ? jobName(S.job || '') : catName(g), sub: t('regSub_' + g.id, {j: jobName(S.job || '')})};
  return {none: null, nav, head, sections, empty: q && !sections.length ? t('mxNone', {q}) : '', detail: detailOf(sections), foot,
    hud: !q && g.id === 'display' ? hudView(d) : null, credit: iconCredit()};
}

// The HUD as the game draws it: its font and size, its black outline, its background and opacity (UI_CONFIG.lua,
// as ui_settings.lua reads it), around the text GearSwap's code returned
function hudView(d: LegacyExport): ModulesView['hud'] {
  const r = hudPreview(d);
  if (!r) return {html: '', style: '', error: '', note: t('hudDrawing'), title: t('hudTitle'), hint: '', reset: null};
  const m = r.meta || {}, bg = m.bg || [15, 15, 35, 180], sw = Math.max(0, Number(m.stroke_width) || 0);
  const st = m.stroke || [0, 0, 0], sa = (Number(m.stroke_alpha) || 255) / 255, sc = `rgba(${st[0]},${st[1]},${st[2]},${sa})`;
  const shadow = sw ? ([[1, 1], [-1, 1], [1, -1], [-1, -1], [1, 0], [-1, 0], [0, 1], [0, -1]] as Array<[number, number]>).map(([x, y]) => `${x * sw}px ${y * sw}px 0 ${sc}`).join(',') : 'none';
  const style = `font-family:'${String(m.font || 'Consolas').replace(/'/g, '')}',Consolas,monospace;font-size:${(Number(m.size) || 10) * 4 / 3}px;font-weight:${m.bold ? 700 : 400};`
    + `text-shadow:${shadow};background:${m.bg_visible === false ? 'transparent' : `rgba(${bg[0]},${bg[1]},${bg[2]},${(bg[3] ?? 180) / 255})`}`;
  // the job's own order (its <JOB>_HUD.lua), to set back from under the preview
  const hf = (modAllFiles(d) as LegacyConfigFile[]).find(f => /\/[A-Z]{3}_HUD\.lua$/.test(f.file));
  const own = hf ? ['section_order', 'row_order'].filter(k => hudOrder(d, hf.file, k).own) : [];
  return {html: r.html, style, error: r.error ? t('hudError', {e: r.error}) : '', note: m.enabled === false ? t('hudOff') : t('hudNote'), title: t('hudTitle'),
    hint: t('hudHint', {j: S.job}), reset: own.length ? {label: t('hudOrderReset'), attrs: {'data-hudresetall': hf!.file}} : null};
}
