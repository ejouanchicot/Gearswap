// GearSwap Atelier · Buffs & target: what the page counts in all its figures, the party as the game's list (you, then
// each member, each tab saying what it gives), the chosen member's buttons under them, the target, what all of it
// changes for the set opened on the left (one figure a situation) and the total of every buff; the member's panel is
// panel.ts.
// The rules are the old page's renderCombatParty, pbGives, pbImpact, pbResult (party_builder.js). Still the old page's
// HTML: the target
// card (target_pick.js targetCardPanel); the other debuffs: foe.ts. A
// field ending in Html is one of the old page's texts it wrote unescaped. The buttons keep the attributes the old
// handlers read (data-pbtab, data-pbdel, data-pbaddopen, data-buffundo, data-buffendgame, data-buffreset,
// data-bufftier, data-pbother).
//
// @file    atelier/src/screens/combat/combat.ts
// @author  ejouanchicot
import {foeView, type FoeView} from './foe';
import {memberPanel, youPanel, type PanelView} from './panel';
import {setList, type SetListView} from '../sets/setlist';
import {situations, picker, type Situation, type Picker} from '../profiles/profiles';

export interface Gives { text: string; neg: boolean }
export interface PartyTab { key: string; label: string; sub: string; emblemHtml: string; del: boolean; gives: Gives[]; selected: boolean }
export interface SumRow { name: string; value: string; low: boolean; foe: boolean; title: string }
export interface ImpactRow { tier: string; name: string; title: string; pressed: boolean; a: string; aDiff: null | {text: string; up: boolean};
  b: string; bDiff: null | {text: string; up: boolean} }
export interface CombatView {
  side: SetListView;
  head: {title: string; why: string; undo: null | {title: string; text: string}; endgame: {title: string; textHtml: string};
    reset: {title: string; textHtml: string; disabled: boolean}};
  profBar: {label: string; picker: Picker};
  sits: {label: string; list: Situation[]};
  party: {title: string; count: string; tabs: PartyTab[]; add: null | {title: string; label: string; left: string}; you: boolean; panel: PanelView;
    removeTitle: string; nothing: string};
  target: {title: string; meta: string; html: string};
  impact: {title: string; note: string; set: string; what: string; ws: boolean; rows: ImpactRow[]};
  total: {title: string; onYou: string; onFoe: string; nothing: string; mine: SumRow[]; foes: SumRow[]};
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

function partyOf(d: LegacyExport, b: LegacyAny, B: LegacyAny, shown: string[]): CombatView['party'] {
  const cur = st().pbTab === 'you' || shown.includes(st().pbTab) ? st().pbTab || 'you' : 'you';
  const tabs = [tabOf('you', t('pbYou'), `${st().job}/${d.sub || '—'}`, cur, b, B)].concat(shown.map(j => {
    const trust = buffTier() === 'Trust' && TRUST_NAMES[j];
    return tabOf(j, trust || j, trust ? j : PB_JOBS.find((x: LegacyAny) => x.job === j) ? t('pbJob_' + j) : '', cur, b, B);
  }));
  return {title: t('pbTitle'), count: `${shown.length + 1} / ${PB_MAX}`, tabs, removeTitle: t('pbRemove'), nothing: t('pbNothing'),
    add: shown.length + 1 < PB_MAX ? {title: t('ttPbAdd'), label: t('pbAdd'), left: t('pbAddLeft', {n: PB_MAX - shown.length - 1})} : null,
    you: cur === 'you', panel: cur === 'you' ? youPanel(b) : memberPanel(cur, b, shown)};
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

// the total of every buff, one line a stat (its name at the left, its figure at the right), where it comes from in
// its tooltip (pbResult)
function totalOf(B: LegacyAny): CombatView['total'] {
  const from = (k: string) => (B._by || []).filter((e: LegacyAny) => e.k === k && typeof e.v === 'number')
    .map((e: LegacyAny) => e.src + ' : ' + fxShort(k, e.v).replace(/^.*?\s+(?=[+−-])/, '')).join(' · ');
  const row = (foe: boolean) => (k: string): SumRow => { const txt = fxShort(k, B[k]), m = txt.match(/^(.*?)\s+([+−-].*)$/);
    return {name: m ? m[1]! : txt, value: m ? m[2]! : '', low: !foe && B[k] < 0 && !GOOD_LOW.includes(k), foe, title: t('pbFrom', {l: from(k)})}; };
  const counted = (k: string) => !k.startsWith('_') && typeof B[k] === 'number' && B[k];
  return {title: t('pbResult'), onYou: t('pbOnYou'), onFoe: t('pbOnFoe'), nothing: t('pbNothing'),
    mine: Object.keys(B).filter(k => counted(k) && !PB_FOE.includes(k)).map(row(false)),
    foes: Object.keys(B).filter(k => counted(k) && PB_FOE.includes(k)).map(row(true))};
}

/** Buffs & target for the old page's state now, or null when it is not shown */
export function combatView(): CombatView | null {
  if (st().section !== 'combat' || st()._cfg || (st()._pkg && typeof renderPackages === 'function') || !st().job || !ui2()) return null;
  const d = data();
  if (!d) return null;
  // the sets on the left: the set picked there is the one the figures are for
  const L = setList(d);
  if (L.vis.length) st()._curSet = shownSet(L.cards[L.sel], L.sel);
  const b = buffState(), n = buffCount();
  // the target's card (target_pick.js targetCardPanel) and the other debuffs (foe.ts)
  const P = {tgt: targetCardPanel(b), foe: foeView(b)}, shown: string[] = pbShown(b), B = buffTotals();
  const undo = st()._buffUndo && st()._buffUndo.key === buffKey() ? {title: t('pbUndoTip', {w: st()._buffUndo.what}), text: t('pbUndo')} : null;
  return {
    side: L.view,
    head: {title: t('ui2CombatTitle'), why: t('pbWhy'), undo, endgame: {title: t('ttBuffEndgame'), textHtml: t('bEndgame')},
      reset: {title: t('ttBuffReset'), textHtml: t('buffReset'), disabled: !n}},
    profBar: {label: t('prMine'), picker: picker(false)}, sits: {label: t('prSit'), list: situations(true)},
    party: partyOf(d, b, B, shown),
    target: {title: t('pbTarget'), meta: enemyKey(b.enemy), html: P.tgt || ''},
    impact: impactOf(), total: totalOf(B),
    other: P.foe ? {open: !!st()._pbOtherOpen, title: t('ttPbOther'), label: t('pbOther'), who: t('pbOtherWho'), total: P.foe.total, down: P.foe.down,
      openText: t('pbOtherOpen'), shutText: t('pbOtherShut'), foe: P.foe} : null
  };
}
