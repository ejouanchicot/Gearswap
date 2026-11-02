// GearSwap Atelier · Buffs & target, the member opened and the results by effect
// (notes/docs-perso/buffs-cible-2026-11-02/SPEC.md, v3 "A + B"): the member's slots as large cases, the slot opened
// showing the slot window's choices as tiles under them (dialogs/partypick.ts pickView: the same families, hints and
// None), the rest of its panel; the party's mini icons; what it all gives you, a card an effect with who gives it.
// The tiles keep the attribute pbChoose reads (data-pbchoose); a slot opens with data-pbslot (party_builder.js pbClick).
//
// @file    atelier/src/screens/combat/member.ts
// @author  ejouanchicot
import type {PanelView, Item, Effect} from './panel';
import type {PartyTab} from './combat';
import {pickView} from '../dialogs/partypick';

/** A slot of the member opened: one whose choice opens the tiles (pick), or a setting drawn as it is (a list, a switch) */
export type Slot = {k: 'pick'; key: string; label: string; value: string; set: boolean; gives: Effect[]; open: boolean} | {k: 'item'; item: Item};
export interface Tile { value: string; label: string; hint: string; on: boolean; used: boolean }
export interface Grid { title: string; qPh: string; none: null | {value: string; label: string}; groups: Array<{title: string; tiles: Tile[]}> }
export interface Editor { tab: PartyTab; removeTitle: string; slots: Slot[]; grid: Grid | null; rest: PanelView | null; hint: string }
/** A member's buffs as mini icons in the party's list (gi: game-icons), lit when set */
export interface MiniIcon { html: string; on: boolean }
export interface FxSource { name: string; value: string; emblemHtml: string }
export interface FxCard { label: string; value: string; cap: boolean; p: number | null; foe: boolean; sources: FxSource[]; title: string }

const st = (): LegacyAny => S;

// the pick slot of a line (its one control a button opening a window: a song, a roll, a bubble, a food), or null
function pickOf(it: Item): null | {key: string; label: string; set: boolean} {
  if (it.k !== 'row' || it.controls.length !== 1) return null;
  const c = it.controls[0]!;
  return c.k === 'pick' ? {key: c.key, label: c.label, set: c.set} : null;
}

// the icon of a slot, by what it holds (its key, else its list's buff)
const ICON: Array<[RegExp, string]> = [[/^song/, 'musical-notes'], [/^roll/, 'rolling-dices'], [/^(indi|geo|entrust)$/, 'crystal-ball'], [/^food$/, 'standing-potion'],
  [/^storm$/, 'tornado'], [/^am/, 'sword-clash'], [/^(protect|shell)/, 'magic-shield'], [/haste/i, 'sprint'], [/^(dia|distract|frazzle)/, 'poison-bottle']];
function iconKey(it: Item): string {
  const p = pickOf(it);
  if (p) return p.key;
  const c = (it.k === 'row' || it.k === 'am') ? it.controls.find(x => x.k === 'select' || x.k === 'switch') : null;
  return c && 'attrs' in c ? Object.values(c.attrs)[0] || '' : '';
}
function setOf(it: Item): boolean {
  const p = pickOf(it);
  if (p) return p.set;
  if (it.k !== 'row' && it.k !== 'am') return false;
  return it.controls.some(c => (c.k === 'select' && c.options.some(o => o.selected && o.value !== '')) || (c.k === 'switch' && c.on));
}
/** A member's buffs as mini icons (its main settings, the ones on its slots) */
export function iconsOf(quick: Item[]): MiniIcon[] {
  return quick.map(it => { const k = iconKey(it), hit = ICON.find(([re]) => re.test(k));
    return {html: playerIcon('gi:' + (hit ? hit[1] : 'upgrade')), on: setOf(it)}; });
}

// the tiles of a slot: the window's choices (pickView), the one held ticked, the ones another slot of the same kind
// holds greyed (a song already sung in slot 2)
function gridOf(key: string): Grid | null {
  const v = pickView(key);
  if (!v) return null;
  const kind = key.replace(/\d+$/, ''), b = buffState();
  const others = new Set(Object.keys(b).filter(k => k !== key && k.replace(/\d+$/, '') === kind && /\d$/.test(k)).map(k => b[k]));
  return {title: v.title, qPh: v.view.qPh, none: v.none, groups: v.view.groups.map(g => ({title: g.title,
    tiles: g.items.map(i => ({value: i.value, label: i.label, hint: i.hint, on: i.on, used: !i.on && others.has(i.label)}))}))};
}

/** The member opened: its slots (S._pbSlot the one whose tiles show), its tiles, the rest of its panel */
export function editorOf(tab: PartyTab, quick: Item[], rest: PanelView | null): Editor {
  const open = st()._pbSlot || '';
  const slots = quick.map((it): Slot => { const p = pickOf(it);
    return p && it.k === 'row' ? {k: 'pick', key: p.key, label: it.label, value: p.set ? p.label : t('pbChoose'), set: p.set, gives: it.effects, open: open === p.key} : {k: 'item', item: it}; });
  const shown = slots.find(s => s.k === 'pick' && s.open);
  return {tab, removeTitle: t('pbRemove'), slots, grid: shown && shown.k === 'pick' ? gridOf(shown.key) : null, rest, hint: t('pbSlotHint')};
}

// the effects in the order a player reads them (the others after them)
const ORDER = ['mhaste', 'jahaste', 'atk', 'atkp', 'acc', 'stp', 'pdl', 'da', 'ta', 'crit', 'wsd', 'def', 'shell', 'dt', 'pdt', 'mdt', 'regen', 'refresh'];
const HASTE_CAP = 43.75;
const num = (v: number) => (Math.round(v * 10) / 10).toLocaleString(st().lang === 'fr' ? 'fr-FR' : 'en-US');

// who gives a buff: the party job its source belongs to (PB_JOBS), else a job's ability, else you
function ownerOf(src: string): string {
  const j = PB_JOBS.find((x: LegacyAny) => x.src(src));
  if (j) return j.job;
  for (const [job, list] of pbJaJobs()) if ((list as LegacyAny[]).some(x => x.name === src)) return job as string;
  for (const job of Object.keys(FOE_JA)) if ((FOE_JA[job] || {})[src]) return job;
  return st().job;
}

/** What it all gives you, a card an effect (its total, its cap, who gives it), then what the target loses */
export function effectsOf(B: LegacyAny, hit: LegacyAny): {mine: FxCard[]; foes: FxCard[]} {
  const keys = Object.keys(B).filter(k => !k.startsWith('_') && typeof B[k] === 'number' && B[k]);
  const rank = (k: string) => { const i = ORDER.indexOf(k); return i < 0 ? 99 : i; };
  const split = (k: string, v: number): [string, string] => { const txt = fxShort(k, v), m = txt.match(/^(.*?)\s+([+−-].*)$/); return m ? [m[1]!, m[2]!] : [txt, '']; };
  const card = (k: string, foe: boolean): FxCard => {
    const [label, value] = split(k, B[k]);
    const sources = (B._by || []).filter((e: LegacyAny) => e.k === k && typeof e.v === 'number').map((e: LegacyAny) => {
      const job = ownerOf(e.src);
      return {name: e.src.replace(/ \+ Saboteur.*$/, ''), value: split(k, e.v)[1], emblemHtml: emblem(job)}; });
    if (k === 'mhaste') {
      const cap = B[k] >= HASTE_CAP - 0.05;
      return {label: t('pbTileHaste'), value: num(Math.min(B[k], HASTE_CAP)) + ' %', cap, p: Math.min(100, B[k] / HASTE_CAP * 100), foe, sources, title: t('pbTileHasteTip', {v: num(B[k])})};
    }
    const hitTxt = k === 'eeva' && hit && 'p' in hit ? ` · ${t('pbTileHit').toLowerCase()} ${hit.p} %` : '';
    return {label, value: value + hitTxt, cap: false, p: null, foe, sources, title: k === 'eeva' && hit ? hit.title || '' : ''};
  };
  return {mine: keys.filter(k => !PB_FOE.includes(k)).sort((a, b) => rank(a) - rank(b)).map(k => card(k, false)),
    foes: keys.filter(k => PB_FOE.includes(k)).map(k => card(k, true))};
}
