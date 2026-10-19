// GearSwap Atelier · the optimizer's page, opened from a set ("Optimize this set"): a line on top (back, the set, the
// situation and target, the search buttons), then two columns: what is looked for (the limits, the objective, its
// settings, the search's settings) and the result (the objective's figure and verdict, its picture, every figure of
// the family against your set, the pieces changed, the trial).
// The rules are the old page's optPageHTML, opWhatHTML, opParamsHTML, opResultHTML and its pictures (opt_page.js):
// what the figures are (opFigures, opRows, opObj...) stays theirs. Still the old page's HTML: the search buttons
// (optimizer.js optGoButtons), the search's tabs (the search, the limits and the pieces
// changed: blocks.ts, shared with the stats optimizer), the trial's row, a round's calculation (ws_page.js roundCalcHTML). A field ending in Html is one
// of the old page's texts it wrote unescaped. The controls keep the attributes the old handlers read (data-optback,
// data-optobj, data-optopt, data-nukespells, data-cycws, data-help, the .tpin TP field).
//
// @file    atelier/src/screens/optimizer/optpage.ts
// @author  ejouanchicot

import {trialRowView, type TrialRow} from '../sets/trial';
import {limitTile, limitsView, changesView, searchView, type LimitsView, type ChangesView, type SearchView} from './blocks';
import {statWhatView, statResultView, type StatWhatView, type StatResultView} from './statpage';
export interface Objective { key: string; v: string; on: boolean; tip: string; label: string; desc: string; disabled: boolean }
export type Param =
  | {k: 'spells'; label: string; key: string; options: Array<{value: string; selected: boolean}>}
  | {k: 'tp'; label: string; value: string}
  | {k: 'number'; label: string; opt: string; value: string; step: string; tail: string}
  | {k: 'select'; label: string; attr: string; attrValue: string; options: Array<{value: string; label: string; selected: boolean}>}
  | {k: 'check'; label: string; opt: string; checked: boolean}
  | {k: 'warn'; text: string};
export type Bar = {k: 'parts'; label: string; parts: Array<{cls: string; width: number; title?: string; text?: string}>; num: string; tall: boolean; round?: number};
export type Visual =
  | {k: 'rows'; rows: Bar[]; legend: Array<{cls: string; text: string}>; note: string}
  | {k: 'factors'; was: boolean; rows: Array<{label: string; a: string; b: string; up: boolean; width: number; pct: string}>}
  | {k: 'curve'; W: number; H: number; label: string; band: null | {x: number; w: number}; mark: null | {x: number}; was: string | null; now: string;
      ticks: Array<{x: number; v: number}>; legend: Array<{cls: string; text: string}>};
export interface ResultRow { label: string; obj: boolean; cells: Array<{text: string; better: boolean; short: boolean} | null> }
export interface OptPageView {
  head: {backTitle: string; back: string; title: string; set: string; ctx: string; goHtml: string};
  noEngine: string | null;
  statWhat: StatWhatView | null;
  statResult: StatResultView | null;
  what: null | {top: NukeTop | {k: 'limits'; limits: LimitsView}; title: string; helpBtnHtml: string; help: string; objs: Objective[]; params: Param[]; search: SearchView};
  result: null | {title: string; none: string | null; big: null | {label: string; value: string; diff: null | {text: string; up: boolean}; was: string; verdict: null | {cls: string; text: string}};
    visual: Visual | null; was: boolean; heads: string[]; rows: ResultRow[]; changes: ChangesView | null; trial: TrialRow | null; noTry: string; notes: string; calcHtml: string};
}

const st = (): LegacyAny => S;
const pctText = (d: number) => `${d >= 0 ? '+' : '−'}${opNum(Math.abs(d), 1)} %`;

// what is looked for: the limits first, the objective, its settings, the search (opWhatHTML)
function whatOf(s: LegacyAny, kind: string): NonNullable<OptPageView['what']> {
  const S0 = st(), o = S0.optOpts = Object.assign({obj: 'damage', pdt: -50, mdt: -21, sb: 0, hit: 0, engObj: 'tp_real', engAt: 1000}, S0.optOpts || {});
  const cur = opObj(kind), key = kind === 'ws' ? 'obj' : 'engObj', [a, b] = avgRange(o);
  const objs = opObjList(kind).map((k: string) => ({key, v: k, on: k === cur, tip: t('objTip_' + k, {tp: S0.wsTp || 3000, a, b}), label: opObjLabel(kind, k), desc: t('objD_' + k), disabled: kind === 'jump'}));
  S0._optSet = s;
  const help = S0._help === 'optpage' ? `${t(kind === 'ws' ? 'optWhy' : kind === 'nuke' ? 'nukeWhy' : kind === 'jump' ? 'jumpWhy' : 'engWhy', {tp: S0.wsTp || 3000})} ${optSettingsHelp(kind === 'ws')} ${t('opHelp')}` : '';
  // the limits first: what a result may never go past is read before what it maximises
  const lim = (k: string, label: string) => limitTile('data-optopt', k, label, o[k]);
  const top = kind === 'nuke' ? nukeTop(s)
    : {k: 'limits' as const, limits: limitsView(t('opLimits'), [lim('pdt', pdtLabel() + ' ≤'), lim('mdt', 'DT+MDT ≤'), lim('sb', 'Subtle Blow ≥')].concat(kind === 'ws' ? [lim('hit', t('optHitLbl'))] : []))};
  return {top, title: t('opWhat'), helpBtnHtml: helpBtn('optpage'), help, objs, params: paramsOf(s, kind, cur), search: searchView(o, kind === 'ws')};
}

// The block on a nuke set (nuke_layers.js): the situation, the belt and the job's layers in plain words, the slots
// not searched
export interface NukeTop { k: 'nuke'; title: string; sit: {label: string; options: Array<{value: string; label: string; selected: boolean}>};
  lines: Array<{k: 'p'; text: string} | {k: 'mpLow'; checked: boolean; label: string}> }
function nukeTop(s: LegacyAny): NukeTop {
  const o = (S as LegacyAny).optOpts || {}, sit = nukeSituation(s), belt = autoBelt(), owned = new Set(((ownedOf() || {}).waist || []).map((x: LegacyAny) => x.name));
  const lines: NukeTop['lines'] = [], p = (text: string) => lines.push({k: 'p', text});
  if (belt.on) {
    p(t('nlBelt', {o: ORPHEUS, h: OBI, m: belt.min}));
    p(sit.belt ? t('nlBeltOn', {b: sit.belt.name, v: sit.belt.bonus}) : t('nlBeltOff'));
    const miss = [OBI, ORPHEUS].filter(n => !owned.has(n));
    if (miss.length) p(t('nlBeltMiss', {l: miss.join(', ')}));
  } else p(t('nlBeltDisabled'));
  if (/\.acc$/.test(s.path)) p(t('nlAcc'));
  if (nukeLayersApply(s)) for (const L of NUKE_LAYERS[S.job as string] || []) {
    const pieces = setPieces(L.path);
    if (!pieces || (L.onlyNoAutoBelt && belt.on)) continue;
    for (const [slot, piece] of Object.entries(pieces) as Array<[string, LegacyAny]>) {
      const args = {slot: SLOT_NAMES[(S as LegacyAny).lang]![slot] || slot, p: piece.name, set: shortSet(L.path), mp: mpThreshold(), l: (L.spells || []).slice(0, 3).join(', ') + (L.spells && L.spells.length > 3 ? '…' : '')};
      p(t(L.spells ? 'nlLayer_spells' : 'nlLayer_' + L.when, args));
    }
    if (L.when === 'mpLow') lines.push({k: 'mpLow', checked: !!o.nukeMpLow, label: t('nlMpLow', {mp: mpThreshold()})});
  }
  if (sit.fixed.length) p(t('nlFixed', {l: sit.fixed.map((x: string) => SLOT_NAMES[(S as LegacyAny).lang]![x] || x).join(', ')}));
  return {k: 'nuke', title: t('nlTitle'), sit: {label: t('nlSit'), options: Object.keys(NUKE_SITS).map(k => ({value: k, label: t('nlSit_' + k), selected: (o.nukeSit || 'far') === k}))}, lines};
}

// the objective's own settings: the spells a nuke is judged on, the TP the weaponskill goes at or its range, how a
// whole fight is played (opParamsHTML)
function paramsOf(s: LegacyAny, kind: string, cur: string): Param[] {
  const S0 = st(), o = S0.optOpts || {}, f: Param[] = [];
  if (kind === 'nuke') { const mine = new Set(nukeSpells(s));
    f.push({k: 'spells', label: t('nukeSpellsLbl'), key: nukeKey(s), options: nukeSpellList(s).map((x: string) => ({value: x, selected: mine.has(x)}))}); }
  if (kind === 'ws' && cur !== 'damage_avg') f.push({k: 'tp', label: t('opWsTp'), value: String(S0.wsTp || 3000)});
  if (kind === 'ws' && cur === 'damage_avg') { const [a, b] = avgRange(o);
    f.push({k: 'number', label: `${t('opWsTp')} ${t('optFrom')}`, opt: 'tpFrom', value: String(a), step: '250', tail: ''}, {k: 'number', label: t('optTo'), opt: 'tpTo', value: String(b), step: '250', tail: ''}); }
  if (kind === 'eng' && ['tp_real', 'tp_time', 'cycle'].includes(cur)) f.push({k: 'number', label: t('engAtLbl'), opt: 'engAt', value: String(o.engAt), step: '100', tail: ' TP'});
  if (kind === 'eng' && cur === 'cycle') {
    const list = cycleWsSets(s), w = cycleWsSet(s);
    f.push(list.length ? {k: 'select', label: t('cycWsLbl'), attr: 'data-cycws', attrValue: s.path,
      options: list.map((x: LegacyAny) => ({value: x.path, label: shortPath(x.path).replace(/^precast\.WS\.?/, ''), selected: !!w && w.path === x.path}))} : {k: 'warn', text: t('cycNoWs')});
    f.push({k: 'select', label: t('cycHitsLbl'), attr: 'data-optopt', attrValue: 'cycHits',
      options: ['me', 'tank'].map(k => ({value: k, label: t(k === 'me' ? 'cycHitsMe' : 'cycHitsTank'), selected: (o.cycHits || 'me') === k}))});
    f.push({k: 'check', label: t('cycAmLbl'), opt: 'cycAm', checked: !!(o.cycAm ?? true)}, {k: 'check', label: t('cycTimedLbl'), opt: 'cycTimed', checked: !!(o.cycTimed ?? true)});
  }
  return f;
}

// your set and the try as two rows of the same picture (one row alone without a try)
const pair = <X>(now: X, was: X | null | undefined, one: (x: X, label: string, other: X | null) => Bar): Bar[] =>
  (was ? [one(was, t('rdvMine'), now)] : []).concat([one(now, was ? t('rdvTry') : t('rdvMine'), was ?? null)]);

// the picture that shows why the objective's figure moves (opVisualHTML and the pictures under it)
function visualOf(obj: string, main: LegacyAny, now: LegacyAny, was: LegacyAny): Visual {
  const r = now.r, w = was && was.r;
  if (obj === 'cycle' && now.c) {
    const one = (x: LegacyAny, label: string): Bar => { const tot = x.melee + x.ws + x.sc || 1;
      return {k: 'parts', label, tall: false, num: opNum(x.dps), parts: [['m', x.melee], ['w', x.ws], ['c', x.sc]].map(([cls, v]) => ({cls: cls as string, width: 100 * (v as number) / tot}))}; };
    const lg = (cls: string, label: string, get: (x: LegacyAny) => number) => ({cls, text: `${label} ${was && was.c ? opNum(get(was.c)) + ' → ' : ''}${opNum(get(now.c))}`});
    return {k: 'rows', rows: pair(now.c, was && was.c, one), legend: [lg('m', t('cycMelee'), x => x.melee), lg('w', t('cycWs'), x => x.ws), lg('c', t('cycSc'), x => x.sc)], note: ''};
  }
  if (obj === 'tp_real' && r && r.real) {
    const rr = r.real, wr = w && w.real, n = Math.max(rr.probs.length, wr ? wr.probs.length : 0);
    const one = (x: LegacyAny, label: string): Bar => ({k: 'parts', label, tall: true, num: t('opMean', {n: opNum(x.rounds, 2)}),
      parts: x.probs.map((p: number, i: number) => p < .01 ? null : {cls: 'r' + Math.min(i, 7), width: 100 * p, title: `${t('opRounds', {n: i + 1})} · ${opNum(100 * p)} %`,
        text: p >= .25 ? `${t('opRounds', {n: i + 1})} · ${opNum(100 * p)} %` : p >= .07 ? String(i + 1) : ''}).filter(Boolean)});
    const used = [...Array(n).keys()].filter(i => rr.probs[i] >= .01 || (wr && wr.probs[i] >= .01));
    return {k: 'rows', rows: pair(rr, wr, one), legend: used.map(i => ({cls: 'r' + Math.min(i, 7), text: String(i + 1)})), note: t('opRoundsLbl')};
  }
  if (obj === 'tp_time' && r && r.detail) {
    const d = r.detail, wd = w && w.detail, need = (x: LegacyAny) => Math.max(0, x.at - x.start) / x.tpRound, top = Math.max(need(d), wd ? need(wd) : 0) || 1;
    const one = (x: LegacyAny, label: string): Bar => ({k: 'parts', label, tall: true, round: 100 / top, num: `${opNum(x.tpRound)} TP`,
      parts: [{cls: 'w', width: 100 * need(x) / top, text: t('opRounds', {n: opNum(need(x), 2)})}]});
    return {k: 'rows', rows: pair(d, wd, one), legend: [], note: t('opGauge', {r: opNum(need(d), 2), tp: opNum(d.tpRound), at: d.at})};
  }
  const factors = (list: Array<{label: string; get: (x: LegacyAny) => number; fmt: (v: number) => string; low?: boolean}>): Visual => ({k: 'factors', was: !!w,
    rows: list.map(f => { const b = f.get(r), a = w ? f.get(w) : null, d = a ? 100 * (b / a - 1) * (f.low ? -1 : 1) : null;
      return {label: f.label, a: a != null ? f.fmt(a) : '', b: f.fmt(b), up: (d ?? 0) >= 0, width: d == null ? 0 : Math.min(50, Math.abs(d) * 2), pct: d == null ? '' : pctText(d)}; })});
  if (obj === 'dps' && r && r.detail && r.attacks) return factors([
    {label: t('opFHits'), get: x => x.attacks.hits, fmt: v => v.toFixed(2)},
    {label: t('opFDmg'), get: x => x.dps * x.detail.timeRound / x.attacks.hits, fmt: v => opNum(v)},
    {label: t('opFRound'), get: x => x.detail.timeRound, fmt: v => v.toFixed(2) + ' s', low: true}]);
  if ((obj === 'tp_round' || obj === 'jump') && r && r.detail && r.attacks) return factors([
    {label: t('opFHits'), get: x => x.attacks.hits, fmt: v => v.toFixed(2)},
    {label: t('opFTpHit'), get: x => x.detail.tpPerHit, fmt: v => opNum(v)}]);
  if ((obj === 'damage' || obj === 'damage_avg') && now.curve) {
    const c = now.curve, wc = was && was.curve, W = 400, H = 90, top = Math.max(...c.map((p: number[]) => p[1]), ...(wc || []).map((p: number[]) => p[1])) || 1;
    const x = (tp: number) => 24 + (W - 48) * (tp - 1000) / 2000, y = (v: number) => H - 16 - (H - 24) * v / top;
    const pts = (list: number[][]) => list.map(p => x(p[0]!).toFixed(1) + ',' + y(p[1]!).toFixed(1)).join(' ');
    const [a, b] = avgRange(st().optOpts || {}), tp = +(st().wsTp || 3000);
    return {k: 'curve', W, H, label: t('opCurve'), band: obj === 'damage_avg' ? {x: x(a), w: Math.max(2, x(b) - x(a))} : null, mark: obj === 'damage_avg' ? null : {x: x(tp)},
      was: wc ? pts(wc) : null, now: pts(c), ticks: [1000, 1500, 2000, 2500, 3000].map(v => ({x: x(v), v})),
      legend: (wc ? [{cls: 'g', text: t('rdvMine')}] : []).concat([{cls: 'w', text: wc ? t('rdvTry') : t('rdvMine')}])};
  }
  // else the figure as a bar a set
  const v = main.get(now), wv = was ? main.get(was) : null, top = Math.max(v || 0, wv || 0) || 1;
  const better = (p: number, q: number | null) => q == null ? true : main.low ? p <= q : p >= q;
  const one = (val: number, label: string, other: number | null): Bar => ({k: 'parts', label, tall: false, num: main.fmt(val), parts: [{cls: better(val, other) ? 'w' : 'g', width: 100 * val / top}]});
  return {k: 'rows', rows: pair(v, was ? wv : null, one), legend: [], note: ''};
}

// the result: the objective's figure, big, with its difference to your set and its verdict, its picture, every
// figure of the family (opResultHTML)
function resultOf(s: LegacyAny, kind: string): NonNullable<OptPageView['result']> {
  const obj = opObj(kind), now = opFigures(s, kind), was = trialCount(s) ? opFigures(s, kind, true) : null;
  const base = {title: t('opResult'), none: null, big: null, visual: null, was: !!was, heads: [], rows: [], changes: null, trial: null, noTry: '', notes: '', calcHtml: ''};
  if (!now) return {...base, none: kind === 'eng' && obj === 'cycle' ? t('cycNoWs') : noEngineText()};
  const rows: LegacyAny[] = opRows(kind, obj).filter((r: LegacyAny) => r.get(now) != null || (was && r.get(was) != null)), main = rows[0];
  const v = main.get(now), w = was ? main.get(was) : null;
  const d = w ? 100 * (main.low ? w / v - 1 : v / w - 1) : null;
  const verdict = d == null ? '' : Math.abs(d) < 2 ? 'eq' : d <= -2 ? 'worse' : d < 5 ? 'try' : 'better';
  const big = {label: main.label + (was ? ' · ' + t('rdvTry') : ''), value: main.fmt(v), diff: d != null ? {text: pctText(d), up: d >= 0} : null,
    was: was ? `${t('opNow')} : ${main.fmt(w)}` : '', verdict: verdict ? {cls: verdict, text: t('cycV_' + verdict)} : null};
  const visual = visualOf(obj, main, now, was);
  const cell = (r: LegacyAny, x: LegacyAny, y: LegacyAny) => { const a = r.get(x), b = y ? r.get(y) : null;
    if (a == null) return null;
    return {text: r.fmt(a), better: b != null && (r.low ? a < b - 1e-9 : a > b + 1e-9), short: !!(r.floor && !r.floor(a))}; };
  const trial = trialRowView(s);
  return {...base, big, visual, heads: was ? [t('rdvMine'), t('rdvTry')] : [t('rdvMine')],
    rows: rows.map((r, i) => ({label: r.label + (i ? '' : ' ★'), obj: !i, cells: (was ? [cell(r, was, now)] : []).concat([cell(r, now, was)])})),
    changes: changesView(s), trial, noTry: trial ? '' : t('opNoTry'),
    notes: kind === 'eng' && obj === 'cycle' && cycleInput(s) && !cycleInput(s).tpRule ? t('cycNoRule') : '',
    calcHtml: kind !== 'ws' && now.r && now.r.detail ? roundCalcHTML(now.r.detail, now.r.real) : ''};
}

/** The optimizer's page of a set (optPageHTML); ws: the set's weaponskill, when it is a weaponskill set */
export function optPageView(s: LegacyAny, ws: unknown): OptPageView {
  const kind = ws ? 'ws' : isNukeSet(s.path) ? 'nuke' : isJumpSet(s.path) ? 'jump' : roundSet(s) ? 'eng' : 'stat';
  const act = ws ? 'optws' : kind === 'nuke' ? 'optnuke' : kind === 'stat' ? 'optstat' : 'opteng', b = buffState();
  const goHtml = st()._optBusy ? `<span class="optprog">${t('optStart')}</span>${searchParked() ? `<button class="btn" data-orshow>${t('orShow')}</button>` : ''}<button class="btn ghost" data-optstop>${t('optStop')}</button>`
    : optGoButtons(act) + (kind === 'jump' || kind === 'stat' || kind === 'nuke' ? '' : `<button class="btn ghost" data-tiercost title="${esc(t(ws ? 'tcTip' : 'tcTipEng'))}">${t('tcBtn')}</button>` +
      (ws ? `<button class="btn ghost" data-optall title="${esc(t('oaTip'))}">${t('oaBtn')}</button>` : ''));
  const head = {backTitle: t('ttOptBack'), back: t('optBack'), title: t('optPageTitle'), set: shortPath(s.path), ctx: `${buffTier()} · ${enemyKey(b.enemy)}`, goHtml};
  const out: OptPageView = {head, noEngine: null, statWhat: null, statResult: null, what: null, result: null};
  if (!engineReady()) return {...out, noEngine: noEngineText()};
  // a set judged by its stats (idle, Enmity, Phalanx, Fast Cast...): stat_opt.js
  if (kind === 'stat') return {...out, statWhat: statWhatView(s), statResult: statResultView(s)};
  return {...out, what: whatOf(s, kind), result: resultOf(s, kind)};
}
