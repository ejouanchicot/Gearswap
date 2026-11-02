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

export interface Gives { text: string; neg: boolean }
export interface PartyTab { key: string; label: string; sub: string; emblemHtml: string; del: boolean; gives: Gives[]; selected: boolean }
export interface SumRow { name: string; value: string; low: boolean; foe: boolean; title: string }
export interface ImpactRow { tier: string; name: string; title: string; pressed: boolean; a: string; aDiff: null | {text: string; up: boolean};
  b: string; bDiff: null | {text: string; up: boolean} }
/** A member's line of the party: its tab, its main settings on the line (quick), all of them under it when it is opened */
export interface PartyRow { tab: PartyTab; quick: Item[]; panel: PanelView | null; open: boolean }
/** A figure of what it all gives you, as a tile (cap: at its most) */
export interface Tile { label: string; value: string; cap: boolean; title: string }
export interface CombatView {
  side: SetListView;
  head: {title: string; why: string; undo: null | {title: string; text: string}; endgame: {title: string; textHtml: string};
    reset: {title: string; textHtml: string; disabled: boolean}};
  profBar: {label: string; picker: Picker};
  sits: {label: string; list: Situation[]};
  party: {title: string; count: string; hint: string; rows: PartyRow[]; add: null | {title: string; label: string; left: string};
    removeTitle: string; nothing: string; moreTitle: string};
  fight: {title: string; hint: string; profile: string; group: string; vs: string; foeMore: string; foeLess: string};
  result: {title: string; tiles: Tile[]};
  target: {title: string; meta: string; card: TargetCardView};
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

// a member's main settings, for its line: the rows of its first column but the gear's "+N" (its songs, rolls,
// bubbles, Protect / Shell / Haste, your food and aftermath); the rest is in its panel, opened under the line
function quickOf(panel: PanelView): Item[] {
  const plus = (it: Item) => it.k === 'row' && it.controls.some(c => c.k === 'select' && /\bplus\b/.test(c.cls));
  return panel.left.flatMap(bl => bl.k === 'section' ? bl.items : []).filter(it => (it.k === 'row' || it.k === 'am') && !plus(it));
}

// the party as the game's list: you, then each member, its main settings on its line; the member opened shows all of
// them under it (S.pbTab; none at first, and a click on the opened one closes it)
function partyOf(d: LegacyExport, b: LegacyAny, B: LegacyAny, shown: string[]): CombatView['party'] {
  const want = st().pbTab, cur = !want ? '' : want === 'you' || shown.includes(want) ? want : '';
  const tabs = [tabOf('you', t('pbYou'), `${st().job}/${d.sub || '—'}`, cur, b, B)].concat(shown.map(j => {
    const trust = buffTier() === 'Trust' && TRUST_NAMES[j];
    return tabOf(j, trust || j, trust ? j : PB_JOBS.find((x: LegacyAny) => x.job === j) ? t('pbJob_' + j) : '', cur, b, B);
  }));
  // (opened, its panel keeps what its line does not show: its main settings are on the line already)
  // (a first column left empty: the second one takes its place, on one column)
  const rest = (panel: PanelView, quick: Item[]): PanelView => {
    const left = panel.left.map(bl => bl.k === 'section' ? {...bl, items: bl.items.filter(it => !quick.includes(it))} : bl)
      .filter(bl => bl.k !== 'section' || bl.items.length);
    return left.length ? {...panel, left} : {left: panel.right, right: []};
  };
  const rows = tabs.map((tb): PartyRow => { const panel = tb.key === 'you' ? youPanel(b) : memberPanel(tb.key, b, shown), quick = quickOf(panel);
    return {tab: tb, quick, panel: cur === tb.key ? rest(panel, quick) : null, open: cur === tb.key}; });
  return {title: t('pbPtTitle'), count: `${shown.length + 1} / ${PB_MAX}`, hint: t('pbPtHint'), rows, removeTitle: t('pbRemove'), nothing: t('pbNothing'),
    moreTitle: t('pbMoreTip'),
    add: shown.length + 1 < PB_MAX ? {title: t('ttPbAdd'), label: t('pbAdd'), left: t('pbAddLeft', {n: PB_MAX - shown.length - 1})} : null};
}

// what it all gives you, as tiles: magic Haste (its 43.75 % cap: 448/1024), Attack, Accuracy, your chance to hit the
// target (its card's)
const HASTE_CAP = 43.75;
function tilesOf(B: LegacyAny, tgt: LegacyAny): Tile[] {
  const mh = B.mhaste || 0, n = (v: number) => (Math.round(v * 10) / 10).toLocaleString(st().lang === 'fr' ? 'fr-FR' : 'en-US');
  const out: Tile[] = [{label: t('pbTileHaste'), value: n(Math.min(mh, HASTE_CAP)) + ' %', cap: mh >= HASTE_CAP - 0.05, title: t('pbTileHasteTip', {v: n(mh)})},
    {label: t('pbTileAtt'), value: '+' + (B.atk || 0), cap: false, title: ''}, {label: t('pbTileAcc'), value: '+' + (B.acc || 0), cap: false, title: ''}];
  if (tgt.hit && 'p' in tgt.hit) out.push({label: t('pbTileHit'), value: tgt.hit.p + ' %', cap: false, title: tgt.hit.title});
  return out;
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
    result: {title: t('pbResultTitle'), tiles: tilesOf(B, P.tgt)},
    target: {title: t('pbTarget'), meta: enemyKey(b.enemy), card: P.tgt},
    impact: impactOf(), total: totalOf(B),
    other: P.foe ? {open: !!st()._pbOtherOpen, title: t('ttPbOther'), label: t('pbOther'), who: t('pbOtherWho'), total: P.foe.total, down: P.foe.down,
      openText: t('pbOtherOpen'), shutText: t('pbOtherShut'), foe: P.foe} : null
  };
}
