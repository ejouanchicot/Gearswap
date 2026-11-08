// GearSwap Atelier · the card of the set shown in the Sets screen: its head (what it is, its versions, the weapons it
// is shown with, a weaponskill's controls), the trial's bar, the equipment as sixteen slots, the line under them (what
// it inherits, what is shared, what is missing), the legend, the notes, and the figures (shown beside on a wide
// window). A set whose optimizer page is open shows that page instead (optimizer/optpage.ts).
// The rules are the old page's cardHTML, slotHTML, setVersionsHTML, versionGridHTML (sets_view.js), with what it
// keeps in the page's state as it goes (S._curSet, S._globals). The weapons it is shown with are weapons.ts, a
// weaponskill's head wshead.ts, the trial's bar trial.ts, the figures figures.ts. A field ending in Html is one of the
// old page's texts it wrote unescaped.
//
// @file    atelier/src/screens/sets/card.ts
// @author  ejouanchicot
import {figuresView, type FiguresView} from './figures';
import {wsHeadView, type WsHeadView} from './wshead';
import {weaponMenusView, weaponResults, weaponTip, type WeaponMenu, type WeaponResult} from './weapons';
import {optPageView, type OptPageView} from '../optimizer/optpage';

import {trialBarView, type TrialBar} from './trial';
export interface SlotView { slot: string; ci: number; label: string; empty: boolean; cls: string; aria: string; reset: null | {title: string}; lock: null | {title: string};
  iconHtml: string; aug: boolean; rank: number | null; name: string; tried: boolean }
// the set's figures under its title: its objectives' figures, then its floors held or not (statOpts, statFigures)
export interface Chips { objs: Array<{label: string; value: string; of: string}>; floors: Array<{label: string; value: string; of: string; ok: boolean; tip: string}>; objsHead: string; floorsHead: string; floorsTip: string }
export interface VerButton { i: number; pressed: boolean; title: string; label: string }
export type Versions =
  | {k: 'none'}
  | {k: 'row'; label: string; buttons: VerButton[]}
  | {k: 'grid'; label: string; cols: string[]; rows: Array<{label: string; cells: Array<VerButton | null>}>};
export interface CardView {
  k: 'card';
  ci: number;
  ws: boolean;
  title: TitleView;
  versions: Versions;
  ctl: null | {k: 'picks'; menus: Array<{menu: WeaponMenu; tip: string}>; results: WeaponResult[]} | {k: 'ws'; view: WsHeadView};
  trial: TrialBar;
  slots: SlotView[];
  equip: {on: boolean; why: string; label: string};
  footHtml: string[];
  wantsHtml: string;
  legend: {items: Array<{markHtml: string; label: string; tip: string; off: boolean}>; hintHtml: string; btn: string};
  notes: {fam: null | {textHtml: string; none: boolean}; base: string};
  figures: FiguresView;
  chips: Chips | null;
  // the stats optimizer, open in the column beside the card (OptColumn.svelte), or null
  opt: OptPageView | null;
  // the pane's head band: "Set · Idle" (its family)
  pane: string;
  // the weapons' menus folded in one line (data-fold="wfold"): what they hold now, open or not
  weapons: {line: string; label: string; open: boolean; parts: Array<{cap: string; val: string; iconHtml: string}>; change: string};
  // the set as its file writes it, beside the equipment (setLuaOf)
  lua: SetLua;
  // the Simple view (sets_simple.js): the pieces' names beside the equipment, the code folded behind codeLabel, each
  // note on one line (its whole text in noteTip)
  simple: boolean; codeLabel: string; noteTip: string;
  // the info panel beside the gear (SPEC card-v2): its tabs (the set, its weapons, its code, the legend), the one shown
  // (S.boxOpen.cardtab, events.js data-cardtab)
  tabs: Array<{key: string; label: string}>; tab: string;
}
// The set as GearSwap's file writes it: its head (built on another set or not), one line a slot of its own (the tried
// pieces in, marked), its tail; a value too long for the line keeps its whole text in `full`
export interface SetLua { head: string; lines: Array<{slot: string; value: string; full: string; tried: boolean}>; tail: string; note: string }
export type CardOrPage = CardView | {k: 'page'; view: OptPageView};

const st = (): LegacyAny => S;
const TIERS3 = ['Group', 'Solo', 'Trust'];

export interface TitleActs { opt: null | {title: string; labelHtml: string}; del: null | {off: boolean; title: string; labelHtml: string}; prev: null | {label: string; title: string};
  // the Simple / Detailed view switch, in the set's menu (sets_simple.js data-setsview-set)
  view: {to: string; label: string; title: string} }
export interface TitleView extends TitleActs { kicker: string; name: string; version: string; tag: string; when: string; facts: string[]; factsTip: string; path: string; pathTip: string }

// Undoing the optimizer's last run (events.js data-tryprev: the trial it found replaced by the one before it), in the
// set's menu; only while that brings something back (an empty trial before it: undoing = "Tout annuler")
function prevOf(s: LegacyAny): TitleActs['prev'] {
  const dr = (S as LegacyAny).drafts[trialKey(s)] || {};
  if (!dr.info || !dr.prev || !Object.keys(dr.prev).length) return null;
  return {label: t('tryPrev'), title: t('tryOptBy', {t: dr.info.tier, at: dr.info.at})};
}

// Deleting the set from its file (push.js: the window that asks first): a set the job's code needs is never deleted
// (deletable, set_push.lua PROTECTED); only with the game, which writes the file
function delOf(s: LegacyAny): TitleActs['del'] {
  if (!deletable(s.path)) return null;
  const live = liveWrite();
  return {off: !live, title: t('ttDel') + (live ? '' : ' ' + t('pushNeedsGame')), labelHtml: t('delBtn')};
}

// The title of a weaponskill set: its weapon, its name and version, what it uses (type, attributes, hits, fTP by TP,
// critical hits, fTP on every hit: the weaponskill database, exported as ws_info), the set's path. The common set is
// one of the job's base sets: never deleted from the page (set_push.lua PROTECTED)
function wsTitle(s: LegacyAny, acts: TitleActs): TitleView {
  const ws = wsOfSet(s) as string, base = {...acts, version: '', tag: '', when: '', facts: [] as string[], factsTip: '', path: s.path, pathTip: t('ttPath')};
  if (!ws) return {...base, kicker: t('wsKick'), name: t('wsCommon')};
  const info = wsInfoOf(ws), sg = segs(s.path), version = sg.slice(sg.lastIndexOf(ws) + 1).join(' · ');
  const n = (v: LegacyAny) => (+v).toLocaleString((S as LegacyAny).lang === 'fr' ? 'fr-FR' : 'en-US', {minimumFractionDigits: 1, maximumFractionDigits: 3});
  const mods = typeof info.mods === 'string' ? [info.mods] : Object.entries(info.mods || {}).map(([k, v]) => `${v} % ${k}`);
  const ftp = info.ftp && info.ftp['1000'] != null ? 'fTP ' + ['1000', '2000', '3000'].map(k => info.ftp[k] != null ? n(info.ftp[k]) : '—').join(' / ') : '';
  const facts: string[] = [info.type ? t('wsType_' + info.type) : '', mods.join(' + '), info.hits ? t(info.hits > 1 ? 'wsHitN' : 'wsHit1', {n: info.hits}) : '', ftp,
    info.crit ? t('wsCritTag') : '', info.replicating ? t('wsReplTag') : '', info.element ? info.element : ''].filter(Boolean);
  return {...base, kicker: (wsSkills()[ws] || '') + ' · ' + t('wsKickOne'), name: ws, version, facts, factsTip: facts.join(' · ')};
}

// the head of a set other than a weaponskill's: what it is (its family, name and version, when it is worn, its path),
// and the weapons it is shown with (setHeadHTML)
function setHeadParts(card: LegacyAny, vi: number, s: LegacyAny, acts: TitleActs): {title: TitleView; picks: Extract<CardView['ctl'], {k: 'picks'}>} {
  // when the code wears it: its catalog line (add_set.js catalogWhen), else its family's
  const when = catalogWhen(s.path) || t('famWhen.' + card.fam), label = card.variants[vi].label;
  const fam = t('fam.' + card.fam), name = niceName(card);
  // an enhancing set: on whom it is cast, beside its name and as the line under it (stat_opt.js enhTarget)
  const on = enhTarget(s);
  const title: TitleView = {...acts, kicker: fam !== name ? fam : '', name, version: label && label !== 'Base' ? label : '', tag: on ? t('enhTag' + on) : '',
    when: on ? t('enhWhen' + on) : when || '', facts: [], factsTip: '', path: s.path, pathTip: t('ttPath')};
  // the weapons' menus side by side, a label over each; then what the job's GearSwap puts with them (off hand, ammo)
  const picks = {k: 'picks' as const, menus: weaponMenusView(s).map(menu => ({menu, tip: weaponTip(menu.desc)})), results: weaponResults(s)};
  return {title, picks};
}

// a slot of the equipment: its piece's icon, whether it is the set's own, inherited, a weapon's, on trial, locked, held
// or missing, augmented, its rank (slotHTML)
function slotOf(s: LegacyAny, ci: number, slot: string, own: Set<string>, q: string, eff: LegacyAny): SlotView {
  const p = eff.pieces[slot], label = (SLOT_NAMES[st().lang] || {})[slot] || slot, tried = eff.tried[slot];
  const lock = isLocked(s, slot) && LOCKABLE(slot) ? {title: t('lockTip')} : null;
  const reset = tried ? {title: t('tryReset')} : null;
  if (!p) return {slot, ci, label, empty: true, cls: `slot empty ${tried ? 'tried' : ''} ${lock ? 'locked' : ''}`, aria: `${label} : —`, reset, lock, iconHtml: '', aug: false, rank: null, name: '', tried: !!tried};
  const weap = eff.from[slot], inh = !weap && s.base && !own.has(slot), hit = q && nameHas(p.name, q);
  const r = pieceStats(p, slot), hold = holdState(slot, p);
  return {slot, ci, label, empty: false, cls: `slot ${inh ? 'inh' : ''} ${weap ? 'weap' : ''} ${hit ? 'hit' : ''} ${tried ? 'tried' : ''} ${lock ? 'locked' : ''} ${hold ? 'own-' + hold : ''}`,
    aria: `${label} : ${p.name}${hold ? ' · ' + t('lg_' + hold) : ''}`, reset, lock, iconHtml: icon(p.name), aug: !!(r && Object.keys(r.aug).length), rank: r && r.rank != null ? r.rank : null,
    name: p.name, tried: !!tried};
}

// The floors a set's figures are held to, as the chips under its title read them: the figure, how it compares, its unit
const FLOOR_CHIPS: Array<[string, string, (f: LegacyAny) => number, boolean, string]> = [
  ['pdt', 'floorPdt', f => f.pdt, true, ' %'], ['mdt', 'floorMdt', f => f.mdt, true, ' %'], ['sird', 'SIRD', f => f.sird, false, ' %'],
  ['fc', 'Fast Cast', f => f.fc, false, ' %'], ['ecrit', 'statObj_ecritRed', f => f.ecrit, true, ' %'], ['enmity', 'Enmity', f => f.enmity, false, ''],
  ['phalanx', 'Phalanx', f => f.phalanx, false, ''], ['ceLoss', 'statObj_ceLoss', f => f.ceLoss, false, ' %']];
// A stats set's figures under its title (the page's set, its trial in): each objective's figure, then each floor, held
// (✓) or not (✗); the HP between its two bounds as one chip. Null on a set the stats optimizer does not take
function chipsOf(s: LegacyAny): Chips | null {
  if (!statSet(s) || !engineReady()) return null;
  const so = statOpts(s), f = statFigures(s), fl = so.floor, set = (v: LegacyAny) => v != null && v !== '' && isFinite(+v) && +v !== 0;
  // the damage taken, all categories in: under the game's whole cap, -87.5 %
  const objs = so.objs.map((k: string) => ({label: t('statObj_' + k), value: statFmt(k)(f[k]), of: k === 'pdtRed' || k === 'mdtRed' ? t('capTotal') : ''}));
  const floors: Chips['floors'] = [];
  // (a floor on an objective's own figure, Fast Cast on a Fast Cast set: its chip already says it)
  const same: Record<string, string> = {fc: 'fc', sird: 'sird', ecrit: 'ecritRed', enmity: 'enmity', phalanx: 'phalanx', ceLoss: 'ceLoss'};
  for (const [k, label, get, low, unit] of FLOOR_CHIPS) if (set(fl[k]) && !so.objs.includes(same[k])) {
    const v = get(f), ok = low ? v <= +fl[k] : v >= +fl[k];
    // DT + PDT I (MDT I) held at its cap, -50 %: said as the cap, and what the pieces give past it (lost)
    const atCap = (k === 'pdt' || k === 'mdt') && +fl[k] === -50, over = Math.round((-50 - v) * 10) / 10;
    const of = atCap ? t('floorCap', {v: '−50 %'}) : t(low ? 'floorMax' : 'floorMin', {v: fl[k] + unit}), name = /^(statObj_|floor)/.test(label) ? t(label) : label;
    const value = Math.round(v * 10) / 10 + unit;
    floors.push({label: name, value, of, ok, tip: `${name} : ${value} (${of})` + (atCap && over > 0 ? ' · ' + t('floorOver', {n: over}) : '')});
  }
  if (set(fl.hp) || set(fl.hpMax)) {
    const lo = set(fl.hp) ? +fl.hp : null, hi = set(fl.hpMax) ? +fl.hpMax : null;
    const of = lo != null && hi != null ? t('floorRange', {a: lo, b: hi}) : t(lo != null ? 'floorMin' : 'floorMax', {v: lo != null ? lo : hi});
    floors.push({label: 'HP', value: String(f.hp), of, ok: (lo == null || f.hp >= lo) && (hi == null || f.hp <= hi), tip: `HP : ${f.hp} (${of})`});
  }
  return {objs, floors, objsHead: t('headObjs'), floorsHead: t('headFloors'), floorsTip: t('headFloorsTip')};
}

// the versions of the set shown, under its title: one row of buttons, or a table for a set with versions of two kinds
// (a DNC weaponskill: a dance, Climactic Flourish, each with its support versions); a set with none keeps the row's
// place (setVersionsHTML, versionGridHTML)
function versionsOf(card: LegacyAny, ci: number, vi: number): Versions {
  const groups: LegacyAny[] = [...variantGroups(card).groups.values()];
  const cur = groups.find(g => g.main === vi || g.subs.some((x: LegacyAny) => x.i === vi)) || (card.fam === 'ws' ? groups[0] : null);
  if (!cur || !cur.subs.length) return {k: 'none'};
  const tiers = cur.subs.some((x: LegacyAny) => /^(Group|Solo|Trust)$/.test(x.label));
  // an enhancing set's versions read as their target ("Composure" is the one cast on the others)
  const shown = (i: number, txt: string) => { const v = card.variants[i], on = enhTarget(v.set);
    return on && (v.label === 'Base' || /composure/i.test(v.label)) ? t('enhBtn' + on) : txt; };
  const btn = (i: number, txt: string): VerButton => ({i, pressed: i === vi, title: T[S.lang]['ttVer' + txt] ? t('ttVer' + txt) : t('ttVer'), label: shown(i, txt)});
  if (tiers) {
    const cell = (i: number, label: string) => { const parts = label.split(' · '), tier = TIERS3.includes(parts[parts.length - 1]!) ? parts.pop()! : 'Full'; return {i, tier, row: parts.join(' · ')}; };
    const cells = (cur.main != null ? [{i: cur.main, tier: 'Full', row: ''}] : []).concat(cur.subs.map((x: LegacyAny) => cell(x.i, x.label)));
    const rows = [...new Set(cells.map((c: LegacyAny) => c.row as string))];
    if (rows.length >= 2) {
      const rank = (r: string) => !r ? '' : (r.split(' · ')[0] === 'Clim' ? '0' : '1') + r;
      rows.sort((a, b) => rank(a).localeCompare(rank(b)));
      const cols = ['Full'].concat(TIERS3.filter(x => cells.some((c: LegacyAny) => c.tier === x)));
      const at = (r: string, tier: string) => cells.find((c: LegacyAny) => c.row === r && c.tier === tier);
      return {k: 'grid', label: t('verLbl'), cols, rows: rows.map(r => ({label: r || t('verSet'), cells: cols.map(c => { const x = at(r, c); return x ? btn(x.i, c) : null; })}))};
    }
  }
  return {k: 'row', label: t('verLbl'), buttons: (cur.main != null ? [btn(cur.main, tiers ? 'Full' : t('verSet'))] : []).concat(cur.subs.map((x: LegacyAny) => btn(x.i, x.label)))};
}

// The button that wears the set in game (live.js equipShownSet): only with the game on the job shown
function equipOf(): CardView['equip'] {
  const on = liveOk() && shownJobLoaded();
  return {on, label: t('equipBtn'), why: !liveOk() ? t('equipNoLive') : !shownJobLoaded() ? t('equipOtherJob', {j: ((S as LegacyAny)._live[S.char as string] || {}).job || '—'}) : t('equipTip')};
}
// What the marks of the grid mean; the ones about your bags dimmed when no piece of the set has them
function legendOf(holds: LegacyAny): CardView['legend'] {
  const item = (markHtml: string, label: string, tip: string, off = false) => ({markHtml, label: t(label), tip: t(tip), off});
  return {hintHtml: t('lgHint'), btn: t('legendBtn'), items: [item('<i></i>', 'lgOwn', 'lgT_own'), item('<i class="inh"></i>', 'lgInh', 'lgT_inh'), item('<i class="weap"></i>', 'lgWeap', 'lgT_weap'),
    item('<i class="try"></i>', 'lgTry', 'lgT_try'), item('<i class="empty"></i>', 'lgEmpty', 'lgT_empty'), item('<i class="lock"></i>', 'lgLock', 'lgT_lock'),
    item('<b class="mk">◆</b>', 'lgAug', 'lgT_aug'), item('<b class="rk">R15</b>', 'lgRank', 'lgT_rank'), item('<i class="miss"></i>', 'lg_missing', 'lgT_missing', !holds.missing.length),
    item('<i class="short"></i>', 'lg_short', 'lgT_short', !holds.short.length), item('<i class="porter"></i>', 'lg_porter', 'lgT_porter', !holds.porter.length)]};
}

// The weapons' menus in one line, folded: what each holds now ("PDT · Burtgang · Duban · Burtgang"), the menus one click
// away (SPEC page-sets-2026-11-01: they are rarely changed and took two lines)
function weaponLineOf(ctl: CardView['ctl']): CardView['weapons'] {
  const parts = !ctl || ctl.k !== 'picks' ? [] : ctl.menus.map(m => ({cap: m.menu.name, val: ((m.menu.options.find(o => o.selected) || {label: ''}).label || '').replace(/^Auto\s*·\s*/, '')}))
    .concat(ctl.results.map(r => ({cap: r.label, val: r.name}))).filter((x, i, all) => x.val && all.findIndex(y => y.val === x.val) === i);
  // (Combat Mode On: an action's set wears the hands held, said under the weapons: weapons.js combatLocked)
  const locked = combatLocked() ? [{cap: t('wLockedTip'), val: t('wLocked')}] : [];
  // (the Simple view shows a weapon as its icon, its name on hover: sets_simple.js simpleIcon)
  const simple = setsSimple(), withIcon = (x: {cap: string; val: string}) => ({...x, iconHtml: simple ? simpleIcon(x.val) : ''});
  return {line: [...new Set(parts.map(x => x.val))].join(' · '), label: t('wLine'), open: !!st().boxOpen.wfold, parts: parts.concat(locked).map(withIcon), change: t('wChange')};
}

// The set as its file writes it (the trial's pieces in, as "Copy as Lua" gives them: trial.js trialLua): built on its
// base, only its own slots inside set_combine(base, {...}); else every slot. Shown beside the equipment, where the
// pieces' names were (they stay in the slots' tooltips: SPEC page-sets-2026-11-01)
function setLuaOf(s: LegacyAny): SetLua {
  // (in double quotes when the name has an apostrophe, as the files write "Sakpata's Gauntlets")
  // a quoted text never breaks inside (non-breaking spaces): a long line wraps only between a piece's fields or augments
  const q = (v: string) => (String(v).includes("'") ? '"' + String(v).replace(/"/g, '\\"') + '"' : "'" + String(v) + "'").replace(/ /g, ' ');
  const tr = st().trial[trialKey(s)] || {}, own = new Set<string>(s.own || Object.keys(s.pieces));
  const valueOf = (p: LegacyAny) => { if (!p || isEmpty(p)) return 'empty';
    const f = [`name = ${q(p.name)}`];
    if (p.augs && p.augs.length) f.push(`augments = {${p.augs.map(q).join(', ')}}`);
    if (p.bag) f.push(`bag = ${q(p.bag)}`);
    if (p.priority != null) f.push(`priority = ${p.priority}`);
    return f.length > 1 ? `{${f.join(', ')}}` : q(p.name); };
  const slots = SLOTS.filter((slot: string) => slot in tr || (s.base ? own.has(slot) : !!s.pieces[slot]));
  const lines = slots.map((slot: string) => { const p = slot in tr ? (tr[slot] || {name: 'empty'}) : s.pieces[slot], v = valueOf(p);
    return {slot, value: v, full: `${slot} = ${v}`, tried: slot in tr}; });
  const base = s.base ? shortPath(s.base) : '';
  return {head: s.base ? `${s.path} = set_combine(${s.base}, {` : `${s.path} = {`, lines, tail: s.base ? '})' : '}',
    note: s.base && !lines.length ? t('luaAllInherited', {b: base}) : ''};
}

// A base set's note: which of its slots each set built on it wears ("CureOther : dos, pieds · CureSelf : oreille 2"),
// or that none reaches the game
function baseNote(s: LegacyAny): string {
  const names = SLOT_NAMES[st().lang] || {}, reach = baseReach(s);
  if (!reach.length) return t('baseNone');
  return t('baseReachNote', {l: reach.map(r => `${shortPath(r.path)} : ${r.slots.map(x => names[x] || x).join(', ')}`).join(' · ')});
}

/** The card of a set, or its optimizer page when that is open */
export function cardView(card: LegacyAny, ci: number, bypath: LegacyAny, q: string): CardOrPage {
  const S0 = st(), vi = Math.min(S0.variant[S0.job + '|' + ci] ?? 0, card.variants.length - 1);
  const s = card.variants[vi].set, base = s.base ? bypath[s.base] : null;
  // the set every figure of the card reads (aftermath, the abilities a family of sets offers): this one
  S0._curSet = s;
  const own = new Set<string>(s.own || Object.keys(s.pieces)), eff = withWeapons(s);
  const slots = SLOTS.map((slot: string) => slotOf(s, ci, slot, base ? own : new Set(SLOTS), q, eff));
  // a base set: the slots no set built on it wears from it, dimmed (baseReach)
  if (baseOnly(s)) { const reached = new Set(baseReach(s).flatMap(r => r.slots));
    slots.forEach(x => { if (!x.empty && !reached.has(x.slot)) { x.cls += ' unreached'; x.aria += ' · ' + t('baseUnreached'); } }); }
  const foot: string[] = [];
  if (base) { const n = [...own].filter(x => s.pieces[x]).length; foot.push(`${t('inherits', {b: '<b>' + esc(shortPath(s.base)) + '</b>'})} · ${n ? t('changed', {n}) : t('nothingChanged')}`); }
  else foot.push(`<span title="${esc(t('ttDefined'))}">${Object.keys(s.pieces).length ? t('defined', {n: '<b>' + Object.keys(s.pieces).length + '</b>'}) : t('emptySet')}</span>`);
  // a set just created: the page's copy until the game's export of it comes (push.js createdKeep)
  if (createdPending(s.path)) foot.push(`<span class="keymiss" title="${esc(t('createdWait'))}">${esc(t('createdTag'))}</span>`);
  if (s.aliases && s.aliases.length) foot.push(`<details><summary>${t('sharedCount', {n: s.aliases.length})}</summary><p>${s.aliases.map((a: string) => esc(shortPath(a))).join(' · ')}</p></details>`);
  const holds: Record<string, string[]> = {missing: [], short: [], porter: []};
  for (const slot of SLOTS) { const h = holdState(slot, eff.pieces[slot]); if (h && !holds[h]!.includes(eff.pieces[slot].name)) holds[h]!.push(eff.pieces[slot].name); }
  // at the Porter Moogle: which slip, to take it out
  const slipOf = (n: string) => [...new Set(Object.values(ownedOf()).flat().filter((x: LegacyAny) => x.name === n).flatMap((x: LegacyAny) => x.where || []))].map((w: LegacyAny) => w.replace(/^Slip/, 'slip')).join(', ');
  const simple = setsSimple();
  if (simple) {
    if (holds.porter!.length) foot.push(simpleHoldHtml('holdporter', 'ssPorter', holds.porter!.map(n => n + ' (' + slipOf(n) + ')')));
    if (holds.missing!.length) foot.push(simpleHoldHtml('holdmiss', 'ssMissing', holds.missing!));
    if (holds.short!.length) foot.push(simpleHoldHtml('holdshort', 'ssShort', holds.short!));
  } else {
    if (holds.porter!.length) foot.push(`<span class="holdporter">${t('holdPorter', {l: esc(holds.porter!.map(n => n + ' (' + slipOf(n) + ')').join(', '))})}</span>`);
    if (holds.missing!.length) foot.push(`<span class="holdmiss">${t('holdMissing', {l: esc(holds.missing!.join(', '))})}</span>`);
    if (holds.short!.length) foot.push(`<span class="holdshort">${t('holdShort', {l: esc(holds.short!.join(', '))})}</span>`);
  }
  // a piece that gives the set its effect, missing while you own it (catalog `key`, add_set.js keyMissing)
  for (const k of keyMissing(s.path, eff.pieces))
    foot.push(`<span class="keymiss">${t('keyMissing', {p: esc(k.names[0]), e: esc(k.effect),
      h: `<button type="button" class="linkbtn" data-keyput="${esc(k.slot + '|' + k.name)}" title="${esc(t('keyTip'))}">${esc(k.name)}</button>`, w: k.where ? ' (' + esc(k.where) + ')' : ''})}</span>`);
  const legend = legendOf(holds);
  const ws = card.fam === 'ws' && family(s.path, s.pieces) === 'ws';
  // a set for weaponskills in general is worked out on one of its weapon's (ws_page.js genericWsOf)
  const wsName = ws && (wsOfSet(s) || genericWsOf(s));
  // a base set (sets.Cure) is optimized as any set; only never deleted, the sets built on it would lose their base
  const locked = baseOnly(s), optable = wsName || isNukeSet(s.path) || roundSet(s) || statSet(s);
  const statOnly = !!optable && !wsName && !isNukeSet(s.path) && !roundSet(s) && statSet(s);
  // every optimizer opens beside the card, the damage ones too (the player, 2026-11-02: the card stays, the right
  // column switches)
  const opt = optable && optPageOpen(s) ? optPageView(s, statOnly ? null : wsName) : null;
  // its actions on the title line: the optimizer, then deleting it
  const acts: TitleActs = {opt: optable && engineReady() ? {title: t('ttOptOpen'), labelHtml: t('optOpenBtn')} : null, del: (ws && !wsOfSet(s)) || locked ? null : delOf(s), prev: prevOf(s),
    view: {to: simple ? 'full' : 'simple', label: t(simple ? 'ssToFull' : 'ssToSimple'), title: t('ssViewTip')}};
  // a job ability's set on sets.precast.JA that no piece of the game can boost: nothing to optimize here, the gear it
  // wears is sets.precast.JA's (stat_opt.js jaOverlayBase, jaBoostable)
  if (acts.opt && jaOverlayBase(s) && !jaBoostable(s)) {
    acts.opt = null;
    foot.push(`<span class="keymiss">${t('jaNoPiece', {a: esc(segs(s.path).pop() as string), b: `<button type="button" class="linkbtn" data-addopen="sets.precast.JA">sets.precast.JA</button>`})}</span>`);
  }
  let title: TitleView, versions: Versions, ctl: CardView['ctl'];
  if (ws) {
    title = wsTitle(s, acts);
    versions = wsOfSet(s) ? versionsOf(card, ci, vi) : {k: 'none'};
    ctl = wsName ? {k: 'ws', view: wsHeadView(s)} : null;
  } else {
    const head = setHeadParts(card, vi, s, acts);
    title = head.title; versions = versionsOf(card, ci, vi); ctl = head.picks;
  }
  // a family's note and a base set's go under the gear, where nothing is left to push down
  const notes = {fam: card.variants.some((v: LegacyAny) => familyNote(v.set)) ? {textHtml: familyNote(s), none: !familyNote(s)} : null,
    base: locked && !ws ? baseNote(s) : ''};
  // goals and limits only on a set the optimizer takes: a base others are built from (sets.Cure) is never worn alone,
  // its figures would be judged against limits it is never held to
  const trial = trialBarView(s), equip = equipOf(), chips = ws || !optable ? null : chipsOf(s);
  // what the set is after, on one line in the Simple view (its whole text as the tooltip)
  const wants = chips ? '' : wantsLine(s), wantsHtml = chips ? '' : !simple ? ui2Wants(s) : wants ? `<p class="ui2wants small one" title="${esc(plainText(wants))}">${wants}</p>` : '';
  S0._globals = {s, view: figuresView(s)};
  const tabs = [{key: 'set', label: t('cvTabSet')}, ...(ctl && ctl.k === 'picks' ? [{key: 'weap', label: t('wLine')}] : []), {key: 'lua', label: 'Lua'}, {key: 'legend', label: t('legendBtn')}];
  const tab = (tabs.find(x => x.key === (S0.boxOpen || {}).cardtab) || tabs[0]!).key;
  return {k: 'card', tabs, tab, ci, ws, title, versions, ctl, trial, slots, equip, footHtml: foot, wantsHtml, legend, notes, figures: S0._globals.view, chips, opt, pane: t('paneSet') + ' · ' + listFamLabel(card.fam), weapons: weaponLineOf(ctl), lua: setLuaOf(s),
    simple, codeLabel: t('ssCode'), noteTip: simple ? [notes.fam && !notes.fam.none ? plainText(notes.fam.textHtml) : '', notes.base].filter(Boolean).join(' · ') : ''};
}
