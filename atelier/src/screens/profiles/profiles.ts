// GearSwap Atelier · the situations and the player's profiles (profiles.js): the four situations (Full, Group, Solo,
// Trust) as buttons, large in Buffs & target (who is in each, what it holds), small in the line over the sets; the
// button that says the profile in use and opens the picker (its search, the situations as a filter, the favourites,
// this job's, the others), what to do when the profile was changed, a new one, the favourites as quick buttons.
// The rules are the old page's profSituationsHTML, profRowHTML, profPanelHTML, profPickerHTML and profFilter
// (profiles.js): the rows the search and the filter leave out are hidden here, from the page's state (S._profQ,
// S._profTier). The buttons keep the attributes the old handlers read (data-bufftier, data-profopen,
// data-profupdate, data-profedit, data-profload, data-proffav, data-profdel, data-proftier; #profq, data-profname).
//
// @file    atelier/src/screens/profiles/profiles.ts
// @author  ejouanchicot

export interface Situation { tier: string; pressed: boolean; title: string; party: Array<{job: string; color: string; emblemHtml: string}>; what: string; sum: string }
export interface ProfRow { name: string; editing: boolean; on: boolean; q: string; tier: string; hidden: boolean; fav: boolean; favTitle: string;
  loadTitle: string; sub: string; sum: string; renameTitle: string; deleteTitle: string; namePh: string }
export interface ProfPanel { q: string; qPh: string; tiers: Array<{value: string; label: string; pressed: boolean}>;
  sections: Array<{label: string; count: number; hidden: boolean; rows: ProfRow[]}>; noMatch: {text: string; hidden: boolean}; count: string }
export interface Picker {
  compact: boolean;
  btn: {set: boolean; mod: boolean; open: boolean; which: string; title: string; label: string; modText: string};
  panel: ProfPanel | null;
  update: null | {name: string; title: string; text: string};
  add: null | {editing: boolean; ph: string; ghost: boolean; title: string; text: string};
  favs: Array<{name: string; on: boolean; title: string}>;
  none: string;
}

const st = (): LegacyAny => S;

/** The four situations, large (who is in each, what it holds) or small */
export function situations(big: boolean): Situation[] {
  const cur = buffTier();
  return TIERS.map(x => {
    let sum = '', party: Situation['party'] = [];
    try { const s = x === cur ? buffState() : tierBuffsOf(x); sum = profSummary(s);
      // who is in it: you, then the members its buffs come from; an emblem takes the colour of its job's role
      const role = (j: string) => ROLE_COLOR[(JOBS.find((y: LegacyAny) => y[0] === j) || [])[2] as string] || 'var(--accent)';
      party = [st().job].concat(pbShown(s)).map((j: string) => ({job: j, color: role(j), emblemHtml: emblem(j)})); } catch (e) { /* a situation never set */ }
    return {tier: x, pressed: x === cur, title: t('tier' + x + 'Tip'), party: big ? party : [], what: big ? t('prWhat_' + x) : '', sum: big ? sum : ''};
  });
}

// the profiles by most recent use, newest first (profSorted)
const sorted = (names: string[]) => { const all = profAll();
  return names.slice().sort((a, b) => String(all[b]._used || all[b]._at || '').localeCompare(String(all[a]._used || all[a]._at || '')) || a.localeCompare(b)); };

function rowOf(n: string, q: string, tier: string): ProfRow {
  const p = profAll()[n], key = (n + ' ' + (p._job || '') + ' ' + (p._tier || '')).toLowerCase();
  return {name: n, editing: st()._profEdit === 'rename:' + n, on: n === profActive(), q: key, tier: p._tier || '',
    hidden: !((!q || key.includes(q)) && (!tier || (p._tier || '') === tier)), fav: !!p._fav, favTitle: t(p._fav ? 'prUnfav' : 'prFav'),
    loadTitle: t('prLoad', {n, d: (p._tier ? p._tier + ' · ' : '') + profSummary(p)}), sub: [p._job, p._tier].filter(Boolean).join(' · '),
    sum: profSummary(p), renameTitle: t('prRename'), deleteTitle: t('prDelete'), namePh: t('prName')};
}

// the picker: favourites first, then this job's, then the others, then the ones of no job; the search and the
// situation filter hide rows (profPanelHTML, profFilter)
function panelOf(): ProfPanel {
  const all = profAll(), names = Object.keys(all), job = st().job;
  const q = (st()._profQ || '').trim().toLowerCase(), tier = st()._profTier || '';
  const favs = sorted(names.filter(n => all[n]._fav)), rest = names.filter(n => !all[n]._fav);
  const groups: Array<[string, string[]]> = [[t('prFavs'), favs], [t('prThisJob', {j: job}), sorted(rest.filter(n => all[n]._job === job))],
    [t('prOthers'), sorted(rest.filter(n => all[n]._job && all[n]._job !== job))], [t('prOld'), sorted(rest.filter(n => !all[n]._job))]];
  const sections = groups.filter(([, l]) => l.length).map(([label, l]) => { const rows = l.map(n => rowOf(n, q, tier));
    // a row being renamed has no search key: it never hides its section
    return {label, count: l.length, hidden: !rows.some(r => r.editing || !r.hidden), rows}; });
  const left = sections.reduce((n, s) => n + s.rows.filter(r => !r.editing && !r.hidden).length, 0);
  return {q: st()._profQ || '', qPh: t('prSearch'), tiers: ['', ...TIERS].map(x => ({value: x, label: x || t('prAllTiers'), pressed: tier === x})),
    sections, noMatch: {text: t('prNoMatch'), hidden: left > 0}, count: t('prCount', {n: names.length})};
}

/** The button of the profile in use, its picker, what to do with it (profPickerHTML) */
export function picker(compact: boolean): Picker {
  const all = profAll(), names = Object.keys(all), on = profActive(), mod = on ? profChanged(on) : false;
  const which = compact ? 'compact' : 'full', open = st()._profOpen === which;
  const update = on && mod ? {name: on, title: t('prUpdate', {n: on}), text: '⟳' + (compact ? '' : ' ' + t('prUpdate', {n: on}))} : null;
  return {compact,
    btn: {set: !!on, mod: !!mod, open, which, title: t('prOpenTip', {n: names.length}), label: on || t(compact ? 'prShort' : 'prChoose'), modText: on && mod ? t('prMod') : ''},
    panel: open ? panelOf() : null, update,
    add: compact ? null : {editing: st()._profEdit === 'new', ph: t('prName'), ghost: !!(on && mod), title: t('prNewTip'), text: t(on ? 'prNewAs' : 'prNew')},
    favs: compact ? [] : sorted(names.filter(n => all[n]._fav)).slice(0, PROF_FAVS).map(n => ({name: n, on: n === on,
      title: t('prLoad', {n, d: (all[n]._tier ? all[n]._tier + ' · ' : '') + profSummary(all[n])})})),
    none: compact || names.length ? '' : t('prNone')};
}
