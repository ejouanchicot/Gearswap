// GearSwap Atelier · Buffs & target: what the page counts in all its figures, the party as the game's list (you, then
// each member, each tab saying what it gives), the chosen member's buttons under them, the target, what all of it
// changes for the set opened on the left (one figure a situation) and the total of every buff; the member's panel is
// panel.ts.
// The rules are the old page's renderCombatParty, pbGives, pbImpact, pbResult (party_builder.js). Still the old page's
// HTML: the target
// card (targetcard.ts) and the other debuffs (foe.ts). A
// field ending in Html is one of the old page's texts it wrote unescaped. The buttons keep the attributes the old
// handlers read (data-pbtab, data-pbdel, data-pbaddopen, data-buffundo, data-buffendgame, data-buffreset,
// data-bufftier, data-pbother).
//
// @file    atelier/src/screens/combat/combat.ts
// @author  ejouanchicot
import {foeView, type FoeView} from './foe';
import {targetCardView, type TargetCardView} from './targetcard';
import {memberPanel, youPanel, type PanelView, type Item} from './panel';
import {setList, type SetListView} from '../sets/setlist';
import {situations, picker, type Situation, type Picker} from '../profiles/profiles';
import {editorOf, iconsOf, effectsOf, type Editor, type MiniIcon, type FxCard} from './member';

export interface Gives { text: string; neg: boolean }
export interface PartyTab { key: string; label: string; sub: string; emblemHtml: string; del: boolean; gives: Gives[]; selected: boolean }
export interface ImpactRow { tier: string; name: string; title: string; pressed: boolean; a: string; aDiff: null | {text: string; up: boolean};
  b: string; bDiff: null | {text: string; up: boolean} }
/** A member in the party's list: its tab and its buffs as mini icons */
export interface PartyRow { tab: PartyTab; icons: MiniIcon[] }
export interface CombatView {
  side: SetListView;
  head: {title: string; why: string; undo: null | {title: string; text: string}; endgame: {title: string; textHtml: string};
    reset: {title: string; textHtml: string; disabled: boolean}};
  profBar: {label: string; picker: Picker};
  sits: {label: string; list: Situation[]};
  party: {title: string; count: string; rows: PartyRow[]; add: null | {title: string; label: string; left: string}; editor: Editor};
  fight: {title: string; hint: string; profile: string; group: string; vs: string; foeMore: string; foeLess: string};
  result: {title: string; hint: string; mine: FxCard[]; foes: FxCard[]; onFoe: string; nothing: string};
  target: {title: string; meta: string; card: TargetCardView};
  impact: {title: string; note: string; set: string; what: string; ws: boolean; rows: ImpactRow[]};
  other: null | {open: boolean; title: string; label: string; who: string; total: string; down: boolean; openText: string; shutText: string; foe: FoeView};
}

// the old page's state, its fields loosely typed (read when the screen is drawn: the old page loads after this module)
const st = (): LegacyAny => S;

// a lower damage taken (Shell) is good: not a cut
const GOOD_LOW = ['shell', 'dt', 'pdt', 'mdt', 'bdt'];

// what a source gives, one stat a chip: yours first (a cut of your own in red), then what comes off the target (pbGives)
function givesOf(B: LegacyAny, src: (name: string) => boolean): Gives[] {
  const sum: Record<string, number> = {};
  for (const e of B._by) if (src(e.src) && typeof e.v === 'number') sum[e.k] = (sum[e.k] || 0) + e.v;
  const keys = Object.keys(sum);
  return keys.filter(k => !PB_FOE.includes(k)).map(k => ({text: fxShort(k, sum[k]!), neg: sum[k]! < 0 && !GOOD_LOW.includes(k)}))
    .concat(keys.filter(k => PB_FOE.includes(k)).map(k => ({text: fxShort(k, sum[k]!), neg: true})));
}

// what a member gives you, for its tab (pbGivesOf)
function givesOfMember(job: string, b: LegacyAny, B: LegacyAny): Gives[] {
  if (job === 'you') {
    const ownJa = new Set(jasOf().filter((j: LegacyAny) => j.as !== 'party').map((j: LegacyAny) => j.name));
    return givesOf(withAftermath(B, shownMain()), v => v === b.food || ownJa.has(v) || /Aftermath/.test(v));
  }
  const def = PB_JOBS.find((j: LegacyAny) => j.job === job);
  const names = new Set<string>((pbJaJobs().get(job) || []).map((x: LegacyAny) => x.name).concat(Object.keys(FOE_JA[job] || {})));
  return givesOf(B, def ? (v => def.src(v) || names.has(v)) : v => names.has(v));
}

function tabOf(key: string, label: string, sub: string, cur: string, b: LegacyAny, B: LegacyAny): PartyTab {
  return {key, label, sub, emblemHtml: emblem(key === 'you' ? st().job : key), del: key !== 'you', gives: givesOfMember(key, b, B), selected: cur === key};
}

// a member's main settings, its slots: the rows of its first column but the gear's "+N" (its songs, rolls, bubbles,
// Protect / Shell / Haste, your food and aftermath); the rest stays in its panel, under its slots
function quickOf(panel: PanelView): Item[] {
  const plus = (it: Item) => it.k === 'row' && it.controls.some(c => c.k === 'select' && /\bplus\b/.test(c.cls));
  return panel.left.flatMap(bl => bl.k === 'section' ? bl.items : []).filter(it => (it.k === 'row' || it.k === 'am') && !plus(it));
}
// its panel less its slots (a first column left empty: the second one on one column), or null when nothing is left
function restOf(panel: PanelView, quick: Item[]): PanelView | null {
  const left = panel.left.map(bl => bl.k === 'section' ? {...bl, items: bl.items.filter(it => !quick.includes(it))} : bl)
    .filter(bl => bl.k !== 'section' || bl.items.length);
  const out = left.length ? {...panel, left} : {left: panel.right, right: []};
  return out.left.length || out.right.length ? out : null;
}

// the party as the game's list, each member with its buffs in mini icons; the member chosen (S.pbTab, the first
// member when none is) opened in the middle
function partyOf(d: LegacyExport, b: LegacyAny, B: LegacyAny, shown: string[]): CombatView['party'] {
  const want = st().pbTab, cur = want === 'you' || shown.includes(want) ? want : shown[0] || 'you';
  const tabs = [tabOf('you', t('pbYou'), `${st().job}/${d.sub || '—'}`, cur, b, B)].concat(shown.map(j => {
    const trust = buffTier() === 'Trust' && TRUST_NAMES[j];
    return tabOf(j, trust || j, trust ? j : PB_JOBS.find((x: LegacyAny) => x.job === j) ? t('pbJob_' + j) : '', cur, b, B);
  }));
  const panels = new Map(tabs.map(tb => [tb.key, tb.key === 'you' ? youPanel(b) : memberPanel(tb.key, b, shown)]));
  const rows = tabs.map((tb): PartyRow => ({tab: tb, icons: iconsOf(quickOf(panels.get(tb.key)!))}));
  const sel = tabs.find(tb => tb.key === cur)!, panel = panels.get(cur)!, quick = quickOf(panel);
  return {title: t('pbPtTitle'), count: `${shown.length + 1} / ${PB_MAX}`, rows,
    add: shown.length + 1 < PB_MAX ? {title: t('ttPbAdd'), label: t('pbAdd'), left: t('pbAddLeft', {n: PB_MAX - shown.length - 1})} : null,
    editor: editorOf(sel, quick, restOf(panel, quick))};
}

// the figure of a situation against the one in use, as a percentage (lower is better for a time)
function diffOf(v: number | null, ref: number | null, low: boolean): null | {text: string; up: boolean} {
  if (v == null || !ref || v === ref) return null;
  const p = (v / ref - 1) * 100;
  return {text: `${p > 0 ? '+' : '−'}${Math.abs(p).toFixed(1)} %`, up: low ? p < 0 : p > 0};
}

// what all of this changes for the set opened: its figure in each situation, with the version GearSwap wears there
function impactOf(): CombatView['impact'] {
  const s = st()._curSet, kind = s && family(s.path, s.pieces);
  const out = {title: t('pbImpact'), note: '', set: '', what: '', ws: false, rows: [] as ImpactRow[]};
  if (!s || !((kind === 'ws' && wsOfSet(s)) || roundSet(s))) return {...out, note: t('pbImpNone')};
  if (!engineReady()) return {...out, note: t('pbImpNoEng')};
  const ws = !roundSet(s), rows: LegacyAny[] = pbImpactRows(s), cur = rows.find(r => r.tier === buffTier()) || rows[0];
  return {...out, ws, set: shortPath(s.path.replace(/\.(Group|Solo|Trust)$/, '')), what: ws ? t('pbImpWs', {tp: st().wsTp || 3000}) : t('pbImpEng'),
    rows: rows.map(r => { const name = r.version === 'Full' ? t('pbImpItself') : '.' + r.version;
      return {tier: r.tier, name, title: t('pbImpTip', {t: r.tier, s: name}), pressed: r === cur,
        a: r.a == null ? '—' : ws ? fmtDmg(r.a) : r.a.toFixed(2) + ' s', aDiff: diffOf(r.a, cur.a, !ws),
        b: r.b == null ? '—' : fmtDmg(r.b) + ' DPS', bDiff: diffOf(r.b, cur.b, false)}; })};
}

/** Buffs & target for the old page's state now, or null when it is not shown */
export function combatView(): CombatView | null {
  if (st().section !== 'combat' || st()._cfg || (st()._pkg && typeof renderPackages === 'function') || !st().job) return null;
  const d = data();
  if (!d) return null;
  // the sets on the left: the set picked there is the one the figures are for
  const L = setList(d);
  if (L.vis.length) st()._curSet = shownSet(L.cards[L.sel], L.sel);
  const b = buffState(), n = buffCount();
  // the target's card (targetcard.ts) and the other debuffs (foe.ts)
  const P = {tgt: targetCardView(b), foe: foeView(b)}, shown: string[] = pbShown(b), B = buffTotals();
  const undo = st()._buffUndo && st()._buffUndo.key === buffKey() ? {title: t('pbUndoTip', {w: st()._buffUndo.what}), text: t('pbUndo')} : null;
  return {
    side: L.view,
    head: {title: t('ui2CombatTitle'), why: t('pbWhy'), undo, endgame: {title: t('ttBuffEndgame'), textHtml: t('bEndgame')},
      reset: {title: t('ttBuffReset'), textHtml: t('buffReset'), disabled: !n}},
    profBar: {label: t('prMine'), picker: picker(false)}, sits: {label: t('prSit'), list: situations(true)},
    party: partyOf(d, b, B, shown),
    fight: {title: t('pbFight'), hint: t('pbFightHint'), profile: t('pbProfile'), group: t('pbGroup'), vs: t('pbVs'), foeMore: t('pbFoeMore'), foeLess: t('pbFoeLess')},
    result: {title: t('pbResultTitle'), hint: t('pbResultHint'), ...effectsOf(B, P.tgt.hit), onFoe: t('pbOnFoe'), nothing: t('pbNothing')},
    target: {title: t('pbTarget'), meta: enemyKey(b.enemy), card: P.tgt},
    impact: impactOf(),
    other: P.foe ? {open: !!st()._pbOtherOpen, title: t('ttPbOther'), label: t('pbOther'), who: t('pbOtherWho'), total: P.foe.total, down: P.foe.down,
      openText: t('pbOtherOpen'), shutText: t('pbOtherShut'), foe: P.foe} : null
  };
}
