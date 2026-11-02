// GearSwap Atelier · My character, and Bags (a tab of its own since 2026-11-02): who (the job, the master level, the
// job points, when the game measured the character), then its stats or its bags, the stats measured in game as cards, PorterPacker's list, the
// merits as tabs. The sets stay on the left of the stats (the set picked there is the one the figures are for), the
// played jobs on the left of the bags.
// The rules are the old page's renderJob / renderPerso (sets_view.js, layout2.js), porterHTML (porter.js),
// renderMeritTabs / meritRows / meritBar (layout2.js, engine.js). Still the old page's HTML: the
// stats cards (the Sets screen's, step 5); the Bags view is bags.ts. A field ending in Html is one of the old page's
// texts it wrote unescaped.
//
// @file    atelier/src/screens/perso/perso.ts
// @author  ejouanchicot
import {bagsView, type BagsView} from './bags';
import {setList, type SetListView} from '../sets/setlist';

import {globalsView, type GlobalsView} from '../sets/globals';
/** PorterPacker's card: three figures (the pieces your sets need, the ones missing, the ones taken out for nothing),
 *  a warning when the job's list is a whole storage list, the two lists folded (a few names, then "and N more") */
export interface PorterView { title: string; meta: string; ok: boolean; introHtml: string; newHtml: string;
  figures: Array<{n: number; label: string; tone: string}>; plain: string;
  add: null | {labelHtml: string; names: string[]}; remove: null | {labelHtml: string; names: string[]}; more: string;
  doneHtml: string; write: null | {title: string; textHtml: string}; needHtml: string }
export interface MeritRow { key: string; name: string; desc: string; level: number; cap: number; changed: boolean; was: string; total: string; inputTitle: string }
export interface MeritsView {
  noneHtml: string;
  bar: {noteHtml: string; reset: null | {textHtml: string}};
  tabs: Array<{key: string; cls: string; label: string; spent: number; edited: boolean; selected: boolean; title: string}>;
  panel: {cls: string; rows: MeritRow[]};
}
export interface PersoView {
  side: SetListView | null;
  head: {char: string; why: string; facts: Array<[string, string]>};
  bags: BagsView | null;
  stats: null | {cards: GlobalsView | null; noCharHtml: string; porter: PorterView | null; meritsTitle: string; merits: MeritsView};
}

function porterOf(d: LegacyExport): PorterView | null {
  const p = d.porterpacker;
  if (!p || !p.wanted) return null;
  const todo = p.add.length + p.remove.length;
  // a whole storage list (one plain list, the old way: what to pack and what to take out alike) far bigger than what
  // the sets use: every piece of it comes out when this job is played
  const wanted = p.wanted || [], plain = (p as LegacyAny).form === 'plain' && p.remove.length > Math.max(30, wanted.length * 4);
  return {
    title: t('porterTitle'), meta: todo ? t('porterToDo', {n: todo}) : t('porterOk'), ok: !todo,
    introHtml: t('porterIntro2', {j: esc(S.job)}), newHtml: p.exists ? '' : t('porterNew2'),
    figures: [{n: wanted.length, label: t('porterFigNeed'), tone: ''}, {n: p.add.length, label: t('porterFigAdd'), tone: p.add.length ? 'bad' : 'good'},
      {n: p.remove.length, label: t('porterFigRm'), tone: p.remove.length ? 'warn' : 'good'}],
    plain: plain ? t('porterPlain', {n: p.remove.length + wanted.length, j: S.job, w: wanted.length}) : '', more: t('porterMore'),
    add: p.add.length ? {labelHtml: t('porterAdd'), names: p.add} : null, remove: p.remove.length ? {labelHtml: t('porterRemove'), names: p.remove} : null,
    doneHtml: todo ? '' : p.wanted.length ? t('porterAllOk', {n: p.wanted.length}) : t('porterNone'),
    write: todo && shownJobLoaded() ? {title: t('porterWriteTip', {f: p.file}), textHtml: t('porterWrite')} : null,
    needHtml: todo && !shownJobLoaded() ? t('porterNeedJob', {j: esc(S.job)}) : ''
  };
}

// the rows of one merit group: its name, its level (an input), what it gives (engine.js meritRows)
function meritRows(list: LegacyMerit[], lo: number, hi: number, edits: Record<string, number>): MeritRow[] {
  return list.filter(m => m.id >= lo && m.id < hi && m.key !== 'maximum_merit_points').map(m => {
    const e = meritEffect(m), lv = meritLevel(m), n = e ? e.per * lv : 0;
    return {key: m.key, name: m.en, desc: m.desc, level: lv, cap: meritCap(m), changed: m.key in edits, was: m.key in edits ? `${t('inGame')} ${m.level} · ` : '',
      total: e ? `${n > 0 ? '+' : n < 0 ? '−' : ''}${Math.abs(n)}${e.unit}` : '', inputTitle: t('ttMeritIn')};
  });
}

// the merits as tabs, a group a tab, the chosen group's rows in one panel (layout2.js renderMeritTabs)
function meritsOf(): MeritsView {
  const list = meritList(), edits = S.meritEdits[meritKey()] || {};
  const empty = {noneHtml: t('noMerits'), bar: {noteHtml: '', reset: null}, tabs: [], panel: {cls: '', rows: []}};
  if (!list) return empty;
  const groups = MERIT_GROUPS.filter(([lo, hi]) => meritRows(list, lo, hi, edits).length);
  const cur = groups.find(g => g[2] === S.meritTab) || groups[0];
  // the skill groups' tab says only Combat / Magic: the full name runs out of a tab
  const SHORT = new Set(['mgCombat', 'mgMagic']);
  const inGroup = ([lo, hi]: [number, number, string]) => list.filter(m => m.id >= lo && m.id < hi && m.key !== 'maximum_merit_points');
  const c = measuredChar() || {}, n = Object.keys(edits).length;
  return {
    noneHtml: '',
    bar: {noteHtml: t('meritsNote', {at: esc(c.at), s: esc(c.sub || '—')}), reset: n ? {textHtml: t('meritsReset', {n})} : null},
    tabs: groups.map(g => ({key: g[2], cls: MERIT_COLORS[g[2]] || '', label: t(SHORT.has(g[2]) ? 'mtShort_' + g[2] : g[2]),
      spent: inGroup(g).reduce((s, m) => s + meritLevel(m), 0), edited: list.some(m => m.id >= g[0] && m.id < g[1] && m.key in edits),
      selected: g === cur, title: t('ttMeritTab')})),
    panel: cur ? {cls: MERIT_COLORS[cur[2]] || '', rows: meritRows(list, cur[0], cur[1], edits)} : {cls: '', rows: []}
  };
}

/** My character for the old page's state now, or null when it is not shown */
export function persoView(): PersoView | null {
  if ((S.section !== 'perso' && S.section !== 'bags') || S._cfg || (S._pkg && typeof renderPackages === 'function') || !S.job) return null;
  const d = data();
  if (!d) return null;
  const bags = S.section === 'bags';
  // the sets on the left of the stats: the set picked there is the one the figures are for (the bags are no set's)
  let side: SetListView | null = null;
  if (!bags) {
    const L = setList(d);
    if (L.vis.length) S._curSet = shownSet(L.cards[L.sel], L.sel);
    side = L.view;
  }
  const s = ui2CurrentSet(d), c = measuredChar(), lv = jaLevels();
  const head = {char: S.char, why: t(bags ? 'bvBagsTip' : 'ui2PersoWhy'),
    facts: [[t('ui2Job'), `${S.job}/${d.sub || '—'}`], ['Master Level', String(lv.ml || '—')], ['Job Points', String((c && c.jp_spent) || '—')],
      [t('ui2Measured'), c && c.at ? `${c.at} · /${c.sub || '—'}` : t('ui2NotMeasured')]] as Array<[string, string]>};
  if (bags) return {side, head, bags: bagsView(), stats: null};
  return {side, head, bags: null, stats: {cards: s && charStats(s) ? globalsView(s, 'cards') : null, noCharHtml: t('noChar'),
    porter: porterOf(d), meritsTitle: t('sectionsMerits'), merits: meritsOf()}};
}
