// GearSwap Atelier · what the search window shows while the search runs, drawn like the game's windows: the equipment
// of the best set so far (the game's 4 x 4 menu), the curve of the best value one step a better set (the piece that
// made each step on it, your set's value as a dashed line, the start in red while no set holds the floors), the log
// as the game's chat, and one line that says where the search is. The search's state is the old page's (optimizer.js
// optRunStep: S._optRun.series [s, value, pieces moved, set], pre, startSet, log).
//
// The search finds most of its better sets in its first second, a dozen at once: the window tells them one after the
// other, a step every STEP_S seconds (the curve, its log line and the slot lit together), so each can be read; once
// the search is done, everything at once.
//
// @file    atelier/src/screens/optimizer/runview.ts
// @author  ejouanchicot

/** The game's equipment menu, row by row */
export const EQ_SLOTS = ['main', 'sub', 'range', 'ammo', 'head', 'neck', 'ear1', 'ear2', 'body', 'hands', 'ring1', 'ring2', 'back', 'waist', 'legs', 'feet'];
/** Seconds between two steps told */
const STEP_S = 0.5;

export type Cell = {slot: string; label: string; name: string; html: string; hot: boolean};
export type Jump = {x: number; y: number; src: string; title: string};
export type Chart = {w: number; h: number; line: string; area: string; pre: string; preX: number; base: null | {y: number; label: string; x: number};
  yTicks: Array<{y: number; label: string}>; jumps: Jump[]; end: null | {x: number; y: number; label: string}; left: number; right: number; bottom: number; top: number};
export type LogLine = {k: string; text?: string; changes?: Array<{slot: string; name: string}>; from?: string; to?: string};
export type Told = {pre: number; steps: number; hot: boolean};

const slotName = (slot: string): string => ((SLOT_NAMES as LegacyAny)[(S as LegacyAny).lang] || {})[slot] || slot;
// the image of an item, for the curve (icon(): the page's own, HD when made)
const srcOf = (name: string): string => (icon(name).match(/src="([^"]+)"/) || [])[1] || '';

/** The search's clock: seconds since it started */
export const runSeconds = (R: LegacyAny): number => (performance.now() - R.t0) / 1000;

/** How far the window has told the search: the red steps (pre) and the better sets (steps) shown, and whether the
 *  last one shown just came (its slot lit) */
export function toldOf(R: LegacyAny, now: number): Told {
  const all: number[] = (R.pre || []).map((p: number[]) => p[0]).concat(R.series.map((p: number[]) => p[0]));
  if (R.done) return {pre: (R.pre || []).length, steps: R.series.length, hot: false};
  let at = -Infinity, n = 0, shownAt = 0;
  for (const found of all) { at = Math.max(found, at + STEP_S); if (at > now) break; n++; shownAt = at; }
  const pre = Math.min(n, (R.pre || []).length);
  return {pre, steps: n - pre, hot: n > 0 && now - shownAt < STEP_S * 2.5};
}

/** The best set told so far as the game's equipment menu, the slot that just changed lit */
export function equipOf(R: LegacyAny, told: Told): {cells: Cell[]; last: string; changed: number} {
  const pt = told.steps ? R.series[told.steps - 1] : null, set = (pt && pt[3]) || R.startSet || {}, start = R.startSet || {};
  const moved: LegacyAny[] = pt ? pt[2] || [] : [];
  const hot = new Set(told.hot && pt ? moved.map((c: LegacyAny) => c.slot) : []);
  const cells = EQ_SLOTS.map(slot => { const name = set[slot] && set[slot] !== '—' ? set[slot] : '';
    return {slot, label: slotName(slot), name, html: name ? icon(name) : '', hot: hot.has(slot)}; });
  const c = moved[0];
  const changed = pt ? [...new Set([...Object.keys(set), ...Object.keys(start)])].filter(k => (set[k] || '') !== (start[k] || '')).length : 0;
  return {cells, last: c ? `${slotName(c.slot)} ▸ ${c.to}` : '', changed};
}

/** The value told so far (the last step shown), null before one */
export const toldValue = (R: LegacyAny, told: Told): number | null => told.steps ? R.series[told.steps - 1][1] : null;

/** The curve: one step a better set, all the same width (the search finds most of them in its first second: drawn by
 *  time, they stood in one wall), better upward whatever the objective (a time: lower is better). The scale is the
 *  sets that hold the floors and yours: a first set far worse (a search from nothing) stays at the bottom edge */
export function chartOf(R: LegacyAny, told: Told): Chart | null {
  const pts: LegacyAny[] = R.series.slice(0, told.steps), pre: LegacyAny[] = (R.pre || []).slice(0, told.pre);
  if (!pts.length && !pre.length) return null;
  const w = 760, h = 230, left = 56, right = 20, top = 44, bottom = 14;
  const n = pre.length + pts.length, X = (i: number) => left + i / Math.max(n, 1) * (w - left - right);
  // two parts: above your set's line (55 % of the height from the top) the sets better than yours, to scale; under it the
  // ones worse, squeezed (a first set from nothing can be three times slower: to scale, the gains that matter would be a
  // few pixels)
  const vals = pts.map(p => p[1]).concat(pre.map(p => p[1]));
  const ref = R.start != null ? R.start : (R.low ? Math.max(...vals) : Math.min(...vals));
  const gainOf = (v: number) => R.low ? ref - v : v - ref;
  const gMax = Math.max(1e-9, ...vals.map(gainOf)), dMax = Math.max(1e-9, ...vals.map(v => -gainOf(v))), unit = Math.abs(ref) * .02 || 1;
  const frac = (v: number) => { const g = gainOf(v);
    return g >= 0 ? .55 - .5 * g / gMax : .55 + .42 * Math.log1p(-g / unit) / Math.log1p(dMax / unit); };
  const Y = (v: number) => top + frac(v) * (h - top - bottom);
  const steps = (list: LegacyAny[], from: number) => list.map((p, i) => i ? ` H${X(from + i).toFixed(1)} V${Y(p[1]).toFixed(1)}` : `M${X(from).toFixed(1)},${Y(p[1]).toFixed(1)}`).join('');
  const line = pts.length ? steps(pts, pre.length) + ` H${X(n).toFixed(1)}` : '';
  const area = line ? `${line} V${h - bottom} H${X(pre.length).toFixed(1)} Z` : '';
  const preLine = pre.length ? steps(pre, 0) + ` H${X(pre.length).toFixed(1)}` + (pts.length ? ` V${Y(pts[0][1]).toFixed(1)}` : '') : '';
  // each step with the image of the piece that made it, when there is room for it (a step 28 px wide at least)
  const room = (w - left - right) / Math.max(n, 1) >= 28;
  const jumps = pts.map((p, i) => ({p, i})).filter(x => x.i && (x.p[2] || []).length).map(({p, i}) => { const c = p[2][0];
    return {x: X(pre.length + i), y: Y(p[1]), src: room ? srcOf(c.to) : '', title: `${slotName(c.slot)} ▸ ${c.to}`}; });
  // the scale's marks: the best set and the worst one shown (your set has its own line)
  const ends = vals.length ? [vals.reduce((a, b) => gainOf(b) > gainOf(a) ? b : a), vals.reduce((a, b) => gainOf(b) < gainOf(a) ? b : a)] : [];
  const yTicks: Array<{y: number; label: string}> = [];
  for (const v of ends) if (Math.abs(Y(v) - Y(ref)) > 12 && yTicks.every(k => Math.abs(k.y - Y(v)) > 12)) yTicks.push({y: Y(v), label: R.fmt(v)});
  const lastPt = pts[pts.length - 1];
  return {w, h, line, area, pre: preLine, preX: X(pre.length), left, right, bottom, top,
    base: R.start != null ? {y: Y(R.start), label: t('orYourSet', {v: R.fmt(R.start)}), x: w - right - 4} : null,
    yTicks, jumps, end: lastPt ? {x: X(n), y: Y(lastPt[1]), label: R.fmt(lastPt[1])} : null};
}

/** The log as the game's chat, the oldest first, as far as told */
export function logOf(R: LegacyAny, told: Told): LogLine[] {
  return (R.log || []).filter((l: LegacyAny) => l.si == null || l.si < told.steps).map((l: LegacyAny) => l.k === 'gain'
    ? {k: 'gain', changes: (l.changes || []).map((c: LegacyAny) => ({slot: slotName(c.slot), name: c.to})), from: l.from, to: l.to}
    : {k: l.k, text: l.text});
}

/** The line that says where the search is */
export function statusOf(R: LegacyAny, now: number, told: Told): string {
  if (R.done) return t('orStDone');
  if (!told.steps) return t(R.hasFloor && (R.pre || []).length ? 'orStFloors' : 'orStStart');
  const s = Math.max(0, Math.round(now - (R.lastAt || 0)));
  return s < 1 ? t('orStFindNow') : s < 4 ? t('orStFind', {s}) : t('orStCheck', {s});
}
