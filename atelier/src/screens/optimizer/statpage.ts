// GearSwap Atelier · the stats optimizer's page (a set searched for its own figures: a tank's damage taken and HP, a
// Fast Cast, a Cure, an enhancing spell...): on the left the minimums, the objectives by kind (the ones that mean
// something for the set, or all of them), what comes next when two results tie, the set's own pieces kept, the notes,
// the search; on the right the result's figures against the file's set, the pieces the try changes, the trial's bar.
// The rules are the old page's statWhatHTML and statResultHTML (stat_opt.js), which keep the options (statOpts), the
// lines of the result (statRows) and the figures (statFigures). The minimums' tiles and the pieces changed: blocks.ts. Still
// the old page's HTML: the search (opSearchHTML), the enfeebles' note (enfNoteHTML), the trial's bar (trialRow). The buttons keep the attributes the old handlers read (data-statobj, data-statobjall,
// data-statthen, data-statkeep, data-statreset).
//
// @file    atelier/src/screens/optimizer/statpage.ts
// @author  ejouanchicot

import {limitTile, limitsView, changesView, type LimitsView, type ChangesView} from './blocks';

export interface StatWhatView {
  floors: LimitsView; floorsAfterHtml: string; titleHtml: string; help: string;
  groups: Array<{label: string; objs: Array<{k: string; on: boolean; name: string; desc: string}>}>; toggle: string;
  then: {label: string; selects: Array<{i: number; options: Array<{value: string; label: string; selected: boolean}>}>};
  own: null | {tip: string; checked: boolean; label: string}; notes: string[]; enfHtml: string; searchHtml: string; weaponsNote: string;
}
export interface StatResultView {
  titleHtml: string; labelHtml: string; value: string; delta: null | {up: boolean; text: string}; wasHtml: string; shield: string;
  heads: string[]; rows: Array<{obj: boolean; label: string; tip: string; cells: Array<{better: boolean; bad: boolean; text: string}>}>;
  changes: ChangesView | null; trialHtml: string; noTry: string;
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
  if (ref) notes.push(t('statRefLine', {h: ref.hp, f: shortPath(ref.path), a: ref.hp, b: ref.hp + HP_SPREAD}));
  if (enh) notes.push(t('statEnhNote', {s: enh.name, b: enh.base, c: t(enh.comp === 'others' ? 'statEnhOthers' : 'statEnhSelf')}));
  else if (['PLD', 'RUN'].includes(S0.job)) notes.push(t('statAssumed', {m: S0.job === 'PLD' ? t('statAssumedMaj') : ''}));
  return {floors, floorsAfterHtml, titleHtml: t('opWhat') + ' ' + helpBtn('optpage'), help: S0._help === 'optpage' ? t('statWhy') + ' ' + t('opHelp') : '', groups,
    toggle: all || hidden ? (all ? t('statFewer') : t('statAll', {n: hidden})) : '',
    then: {label: t('statThen'), selects: [1, 2].map(i => ({i, options: ['', ...STAT_OBJS].filter(k => k !== cur).map(k => ({value: k, label: k ? t('statObj_' + k) : t('statNone'), selected: (so.objs[i] || '') === k}))}))},
    own: jaList.length ? {tip: t('statKeepOwnTip', {b: segs(s.path).pop()}), checked: keptSlots(s).length > 0,
      label: t('statKeepOwn', {p: jaList.map((sl: string) => (withWeapons(s).pieces[sl] || {}).name || sl).join(', ')})} : null,
    notes, enfHtml: enfNoteHTML(s), searchHtml: opSearchHTML(o, false), weaponsNote: o.freeWeapons ? t('statWeaponsNote') : ''};
}

/** The right column of a stats search: the first objective big, every line against the file's set (statResultHTML) */
export function statResultView(s: LegacyAny): StatResultView {
  const now = statFigures(s), was = trialCount(s) ? statFigures(s, true) : null, rows = statRows(s), main = rows[0];
  const v = main.get(now), w = was ? main.get(was) : null, d = was ? v - w : null;
  const cell = (r: LegacyAny, x: LegacyAny, y: LegacyAny) => { const a = r.get(x), b = y ? r.get(y) : null;
    return {better: b != null && (r.low ? a < b - 1e-9 : a > b + 1e-9), bad: !!r.floor && !r.floor(a), text: r.fmt(a)}; };
  const shown = rows.filter((r: LegacyAny, i: number) => i < 3 || r.get(now) || (was && r.get(was)) || r.floor), trial = trialRow(s);
  return {titleHtml: t('opResult'), labelHtml: esc(main.label) + (was ? ' · ' + t('rdvTry') : ''), value: main.fmt(v),
    delta: d ? {up: d >= 0, text: (d >= 0 ? '+' : '−') + main.fmt(Math.abs(d))} : null, wasHtml: was ? `${t('opNow')} : ${main.fmt(w)}` : '',
    shield: now.shield && main.id === 'def' ? ' · DEF ' + t('statShield', {n: now.shield}) : '',
    heads: was ? [t('rdvMine'), t('rdvTry')] : [t('rdvMine')],
    rows: shown.map((r: LegacyAny, i: number) => ({obj: !i, label: r.label + (i ? '' : ' ★'), tip: r.tip || '', cells: was ? [cell(r, was, now), cell(r, now, was)] : [cell(r, now, was)]})),
    changes: changesView(s), trialHtml: trial || '', noTry: trial ? '' : t('opNoTry')};
}
