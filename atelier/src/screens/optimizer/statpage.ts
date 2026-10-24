// GearSwap Atelier · the stats optimizer's page (a set searched for its own figures: a tank's damage taken and HP, a
// Fast Cast, a Cure, an enhancing spell...): on the left the minimums, the objectives by kind (the ones that mean
// something for the set, or all of them), what comes next when two results tie, the set's own pieces kept, the notes,
// the search; on the right the result's figures against the file's set, the pieces the try changes, the trial's bar.
// The rules are the old page's statWhatHTML and statResultHTML (stat_opt.js), which keep the options (statOpts), the
// lines of the result (statRows) and the figures (statFigures). The minimums' tiles and the pieces changed: blocks.ts. The search too. The trial's bar: sets/trial.ts.
// The enfeebles' note: enfNoteHTML (enfeeble.js). The buttons keep the attributes the old handlers read (data-statobj, data-statobjall,
// data-statthen, data-statkeep, data-statreset).
//
// @file    atelier/src/screens/optimizer/statpage.ts
// @author  ejouanchicot

import {trialRowView, type TrialRow} from '../sets/trial';
import {limitTile, limitsView, changesView, searchView, type LimitsView, type ChangesView, type SearchView} from './blocks';

export interface StatWhatView {
  floors: LimitsView; floorsAfterHtml: string; titleHtml: string; help: string;
  groups: Array<{label: string; objs: Array<{k: string; on: boolean; name: string; desc: string}>}>; toggle: string;
  then: {label: string; selects: Array<{i: number; value: string; none: {value: string; label: string; selected: boolean}; groups: Array<{label: string; options: Array<{value: string; label: string; selected: boolean}>}>}>};
  own: null | {tip: string; checked: boolean; label: string}; notes: string[]; boxes: Array<{key: string; checked: boolean; label: string}>; enf: EnfNote | null; search: SearchView; weaponsNote: string;
}
export interface StatResultView {
  titleHtml: string; labelHtml: string; value: string; delta: null | {up: boolean; text: string}; wasHtml: string; shield: string;
  heads: string[]; rows: Array<{obj: boolean; label: string; tip: string; cells: Array<{better: boolean; bad: boolean; text: string}>}>;
  changes: ChangesView | null; trial: TrialRow | null; noTry: string;
}

export interface EnfNote { kind: string; spells: string; note: string; sab: null | {checked: boolean; label: string} }
// An enfeebling set: the spells it is judged on, what the figures take for granted (the target's MND / INT, Saboteur,
// Composure), and a RDM's Saboteur box (enfeeble.js enfContext)
function enfNote(s: LegacyAny): EnfNote | null {
  const e = enfContext(s), lang = (S as LegacyAny).lang;
  if (!e) return null;
  const kind = e.type === 'mode' ? t('enfKindMode', {m: e.mode}) : e.type === 'base' ? t('enfKindBase') : e.type === 'spell' ? t('enfKindSpell')
    : e.type === 'map' ? t('enfKindMap', {m: shortPath(s.path), w: t(e.map === 'Mnd' ? 'enfWhite' : 'enfBlack')}) : t('enfKindType', {k: e.type});
  return {kind, spells: e.spells.join(', '), sab: S.job === 'RDM' ? {checked: !!e.sab, label: t('enfSabBox')} : null,
    note: (e.via ? t('enfVia', {j: (S as LegacyAny).job, s: (data() || {}).sub, v: e.via}) + ' ' : '') + t('enfNote', {s: e.spells.slice(0, 3).join(', '), m: e.tMnd, i: e.tInt, tg: e.target,
      sab: e.sab ? 'Saboteur ' + (e.nm ? (lang === 'fr' ? '×1,25' : '×1.25') + ' (NM)' : '×2') : t('enfNoSab'), c: e.comp ? t('enfComp') : t('enfNoComp')})};
}

// A "then, as tiebreakers" menu: by kind like the objectives above (STAT_OBJ_GROUPS), only the ones that mean
// something for this set (shown), the one already chosen kept wherever it is
function thenSelect(i: number, objs: string[], cur: string, shown: Set<string>) {
  const sel = objs[i] || '', opt = (k: string) => ({value: k, label: t('statObj_' + k), selected: sel === k});
  const keep = (k: string) => k !== cur && (shown.has(k) || k === sel);
  const grouped = new Set<string>(STAT_OBJ_GROUPS.flatMap(([, keys]: [string, string[]]) => keys));
  const groups = STAT_OBJ_GROUPS.map(([g, keys]: [string, string[]]) => ({label: t('statGrp_' + g), options: keys.filter(keep).map(opt)}))
    .concat([{label: '…', options: STAT_OBJS.filter((k: string) => !grouped.has(k) && keep(k)).map(opt)}]).filter((g: LegacyAny) => g.options.length);
  return {i, value: sel, none: {value: '', label: t('statNone'), selected: sel === ''}, groups};
}

/** The left column of a stats search (statWhatHTML) */
export function statWhatView(s: LegacyAny): StatWhatView {
  const S0 = S as LegacyAny, o = S0.optOpts || {}, so = statOpts(s), cur = so.objs[0];
  // the objectives by kind, only the ones that mean something for this set (statRelevant) unless all are asked for
  const all = !!o.statAll, shown: Set<string> = all ? new Set(STAT_OBJS) : statRelevant(s, so.objs);
  const groups = STAT_OBJ_GROUPS.map(([g, keys]: [string, string[]]) => ({label: t('statGrp_' + g),
    objs: keys.filter(k => shown.has(k)).map(k => ({k, on: k === cur, name: t('statObj_' + k), desc: t('statD_' + k)}))})).filter((g: LegacyAny) => g.objs.length);
  const hidden = STAT_OBJS.length - shown.size;
  const num = (k: string, label: string) => limitTile('data-statfloor', k, label, so.floor[k]);
  // the floors of the stats this set is after (and any floor given a value), the others hidden with their objectives
  const has = (k: string, obj: string) => all || shown.has(obj) || !!+so.floor[k], opt = (k: string, obj: string, label: string) => has(k, obj) ? num(k, label) : null;
  // the set's own settings kept from an earlier visit: one click back to the defaults (they change as the page learns)
  const kept = (o.statBy || {})[s.path];
  const reset = kept ? `<p class="muted small">${esc(t('statKept'))} <button class="linkbtn" data-statreset>${esc(t('statReset'))}</button></p>` : '';
  // the minimums first, as tiles (blocks.ts); what they are is the title's tooltip, and a line under it while the
  // help is open
  const floors = limitsView(t('statFloors'), [num('pdt', 'DT+PDT ≤'), num('mdt', 'DT+MDT ≤'), num('hp', t('statHpMin')), num('hpMax', t('statHpMax')),
    opt('sird', 'sird', t('statSird')), opt('fc', 'fc', t('statFc')), opt('ecrit', 'ecritRed', t('statEcrit')), opt('enmity', 'enmity', t('statEnm')),
    opt('phalanx', 'phalanx', t('statPhx')), opt('ceLoss', 'ceLoss', t('statCeLoss')), opt('luDt', 'luDt', t('statLuDt'))], t('statFloorsWhy')), floorsAfterHtml =
    (S0._help === 'optpage' ? `<p class="muted small">${esc(t('statFloorsWhy'))}</p>` : '') + reset;
  const jaList = abilityPieces(s), ref = cureGap(s) ? null : hpRef(s), enh = enhContext(s), notes: string[] = [];
  // Burn and the other elemental debuffs: what the figures take (ele_debuff.js)
  if (edNote(s)) notes.push(edNote(s));
  if (ref) notes.push(t('statRefLine', {h: ref.hp, f: shortPath(ref.path), a: ref.hp, b: ref.hp + HP_SPREAD}));
  // an enhancing set: the spell and its base length, with or without Composure, and the job's bonuses counted (enh_jobs.js)
  if (enh) notes.push(t('statEnhNote', {s: enh.spell === 'enhancing' ? enh.name : enh.spell, b: enh.base, c: t(enh.comp === 'others' ? 'statEnhOthers' : enh.comp === 'self' ? 'statEnhSelf' : 'statEnhPlain')}), ...(enh.notes || []));
  if (['PLD', 'RUN'].includes(S0.job)) notes.push(t('statAssumed', {m: S0.job === 'PLD' ? t('statAssumedMaj') : ''}));
  return {floors, floorsAfterHtml, titleHtml: t('opWhat') + ' ' + helpBtn('optpage'), help: S0._help === 'optpage' ? t('statWhy') + ' ' + t('opHelp') : '', groups,
    toggle: all || hidden ? (all ? t('statFewer') : t('statAll', {n: hidden})) : '',
    then: {label: t('statThen'), selects: [1, 2].map(i => thenSelect(i, so.objs, cur, shown))},
    own: jaList.length ? {tip: t('statKeepOwnTip', {b: segs(s.path).pop()}), checked: keptSlots(s).length > 0,
      label: t('statKeepOwn', {p: jaList.map((sl: string) => (withWeapons(s).pieces[sl] || {}).name || sl).join(', ')})} : null,
    notes, boxes: enhBoxes(s), enf: enfNote(s), search: searchView(o, false), weaponsNote: o.freeWeapons ? t('statWeaponsNote') : ''};
}

/** The right column of a stats search: the first objective big, every line against the file's set (statResultHTML) */
export function statResultView(s: LegacyAny): StatResultView {
  const now = statFigures(s), was = trialCount(s) ? statFigures(s, true) : null, rows = statRows(s), main = rows[0];
  const v = main.get(now), w = was ? main.get(was) : null, d = was ? v - w : null;
  const cell = (r: LegacyAny, x: LegacyAny, y: LegacyAny) => { const a = r.get(x), b = y ? r.get(y) : null;
    return {better: b != null && (r.low ? a < b - 1e-9 : a > b + 1e-9), bad: !!r.floor && !r.floor(a), text: r.fmt(a)}; };
  const shown = rows.filter((r: LegacyAny, i: number) => i < 3 || r.get(now) || (was && r.get(was)) || r.floor), trial = trialRowView(s);
  return {titleHtml: t('opResult'), labelHtml: esc(main.label) + (was ? ' · ' + t('rdvTry') : ''), value: main.fmt(v),
    delta: d ? {up: d >= 0, text: (d >= 0 ? '+' : '−') + main.fmt(Math.abs(d))} : null, wasHtml: was ? `${t('opNow')} : ${main.fmt(w)}` : '',
    shield: now.shield && main.id === 'def' ? ' · DEF ' + t('statShield', {n: now.shield}) : '',
    heads: was ? [t('rdvMine'), t('rdvTry')] : [t('rdvMine')],
    rows: shown.map((r: LegacyAny, i: number) => ({obj: !i, label: r.label + (i ? '' : ' ★'), tip: r.tip || '', cells: was ? [cell(r, was, now), cell(r, now, was)] : [cell(r, now, was)]})),
    changes: changesView(s), trial, noTry: trial ? '' : t('opNoTry')};
}
