// GearSwap Atelier · the Modules' pickers (Modules > a list): the game items (the ones the settings name first, then a
// search over every usable item), the abilities and spells (the ones the file's lists name, then what the job and its
// subjob can use, a search over all), the weaponskills (the weapon's own and its kind's when the list is for a weapon
// mode, else the job's and the subjob's). A tile a name; one the list holds already is greyed.
// The rules are the old page's miGridHTML (module_items.js), mxActGrid and mxWsGrid (module_ux.js), which keep the
// lists, the clicks (data-mipick) and what is staged. Typing in the search draws the window again in place.
//
// @file    atelier/src/screens/dialogs/modpick.ts
// @author  ejouanchicot

export interface MiTile { n: string; label: string; other: boolean; act: boolean; disabled: boolean; title: string; icoHtml: string; kind: string; wsw: string }
export type MiBlock = {h: string; tiles: MiTile[]} | {p: string; small: boolean};
export interface ModPickView { title: string; ph: string; blocks: MiBlock[] }

const none = (): MiBlock => ({p: t('miNone'), small: false});
const hint = (k: string): MiBlock => ({p: t(k), small: true});
const part = (h: string, tiles: MiTile[]): MiBlock[] => tiles.length ? [{h, tiles}] : [];
const tileOf = (n: string, o: Partial<MiTile>): MiTile => Object.assign({n, label: n, other: false, act: true, disabled: false, title: '', icoHtml: '', kind: '', wsw: ''}, o);

// The game items: the ones the settings name, or the search's first 72
function itemBlocks(q: string): MiBlock[] {
  const p = (S as LegacyAny)._miPick, has = new Set(mrNames(modValue(p.file, p.path))), needle = q.trim().toLowerCase();
  const tile = (n: string) => tileOf(n, {act: false, disabled: has.has(n), title: has.has(n) ? t('miHas') : t('miPickTip', {v: n}), icoHtml: itemIco(n)});
  if (!needle) return [{h: t('miUsed'), tiles: miUsed().map(tile)}, hint('miMore')];
  const found = USABLE_ITEMS.filter(([, n]: [LegacyAny, string]) => n.toLowerCase().includes(needle))
    .sort((a: [LegacyAny, string], b: [LegacyAny, string]) => a[1].toLowerCase().indexOf(needle) - b[1].toLowerCase().indexOf(needle)).slice(0, 72);
  return found.length ? [{h: t('miFound'), tiles: [...new Set(found.map((x: [LegacyAny, string]) => x[1]))].map(n => tile(n as string))}] : [none()];
}

// The abilities and spells; abilities and magic are never mixed (a name that is neither, a `$Mode` entry: apart)
function actBlocks(q: string): MiBlock[] {
  const p = (S as LegacyAny)._miPick, d = (data() || {}) as LegacyAny, has = new Set((modValue(p.file, p.path) || []) as LegacyAny[]), needle = mxNorm(q.trim()), mine = mxActs();
  const ok = new Set([...mine.ja, ...mine.ma]), who = {j: S.job + (d.sub ? '/' + d.sub : '')}, used = new Set(needle ? [] : mxActsUsed(p.file));
  const tile = (n: string) => tileOf(n, {label: miLabel(n), other: !(ok.has(n) || used.has(n)), disabled: has.has(n),
    title: has.has(n) ? t('miHas') : miIsMode(n) ? t('miModeTip', {v: n}) : ok.has(n) ? t('miPickTip', {v: n}) : t('mxActOther', who)});
  const sec = (h: string, list: string[]) => part(h, list.map(tile));
  const isJa = (n: string) => typeof JA_ACCESS !== 'undefined' && !!JA_ACCESS[n];
  // 'Utsusemi': a family of spells
  const isMa = (n: string) => !isJa(n) && !miIsMode(n) && typeof SPELL_ACCESS !== 'undefined' && (!!SPELL_ACCESS[n] || accessSpellsOf(n).length > 0);
  const split = (list: string[], ja: string, ma: string, other?: string) => [...sec(ja, list.filter(isJa)), ...sec(ma, list.filter(isMa)), ...(other ? sec(other, list.filter(n => !isJa(n) && !isMa(n))) : [])];
  if (!needle) return [...split(mxActsUsed(p.file), t('mxUsedJa'), t('mxUsedMa'), t('mxUsedMode')), ...sec(t('mxActJa', who), mine.ja), ...sec(t('mxActMa', who), mine.ma.slice(0, 120)), hint('mxActHint')];
  const all: string[] = typeof JA_ACCESS === 'undefined' ? [] : [...new Set([...Object.keys(JA_ACCESS), ...Object.keys(SPELL_ACCESS).filter(mxSpell)])].filter(n => mxNorm(n).includes(needle));
  const first = all.filter(n => ok.has(n)).sort(), rest = all.filter(n => !ok.has(n)).sort().slice(0, 60);
  return first.length || rest.length ? [...split(first.slice(0, 120), t('mxActJa', who), t('mxActMa', who)), ...split(rest, t('mxAllJa'), t('mxAllMa'))] : [none()];
}

// The weaponskills: a weapon known, its own first, then those of its kind by who has them
function wsBlocks(q: string): MiBlock[] {
  if (typeof WS_ACCESS === 'undefined') return [none()];
  const p = (S as LegacyAny)._miPick, has = new Set((modValue(p.file, p.path) || []) as LegacyAny[]), needle = mxNorm(q.trim()), d = (data() || {}) as LegacyAny, job = S.job as string, sub = d.sub || '', lv = jaLevels() as LegacyAny;
  const wpn = mxWsWeapon(p.path), given = mxWsGiven(), all = Object.keys(WS_ACCESS).sort();
  const jobs = (n: string) => WS_ACCESS[n][1], main = (n: string) => !!(jobs(n) && jobs(n)[job] != null), bySub = (n: string) => !!(jobs(n) && !main(n) && jobs(n)[sub] != null && jobs(n)[sub] <= lv.sub);
  const mine = (n: string) => !!(wpn && (given[n] || []).includes(wpn.name));
  // what a tile says under the pointer: the weapons that give it, the jobs that have it
  const about = (n: string) => [given[n] ? t('mxWsFrom', {w: given[n].slice(0, 4).join(', ') + (given[n].length > 4 ? '…' : '')}) : '',
    jobs(n) ? t('mxWsJobs', {j: Object.keys(jobs(n)).sort().join(' ')}) : t('mxWsNoJobs')].filter(Boolean).join(' ');
  const tile = (n: string, dim: boolean, kind: boolean) => tileOf(n, {other: dim, disabled: has.has(n), title: has.has(n) ? t('miHas') : about(n), kind: kind ? WS_ACCESS[n][0] : '',
    wsw: given[n] && !mine(n) ? given[n][0] + (given[n].length > 1 ? '…' : '') : ''});
  const sec = (h: string, list: string[], dim = false, kind = false) => part(h, list.map(n => tile(n, dim, kind)));
  const who = {j: job, s: sub, k: wpn && wpn.kind, w: wpn && wpn.name};
  if (needle) { const found = all.filter(n => mxNorm(n).includes(needle)), ok = (n: string) => main(n) || bySub(n) || !jobs(n);
    return found.length ? [...sec(t('mxWsFoundOk', who), found.filter(ok), false, true), ...sec(t('mxWsFoundOther', who), found.filter(n => !ok(n)), true, true)] : [none()]; }
  const kind = wpn && wpn.kind && all.some(n => WS_ACCESS[n][0] === wpn.kind) ? all.filter(n => WS_ACCESS[n][0] === wpn.kind) : null;
  if (!kind) return [...sec(t('mxWsJob', who), all.filter(main), false, true), ...(sub ? sec(t('mxWsSub', who), all.filter(bySub), false, true) : []), hint('mxWsHint')];
  const rest = kind.filter(n => !mine(n));
  return [...sec(t('mxWsGiven', who), kind.filter(mine)), ...sec(t('mxWsKindJob', who), rest.filter(main)), ...(sub ? sec(t('mxWsKindSub', who), rest.filter(bySub)) : []),
    ...sec(t('mxWsKindAny', who), rest.filter(n => !jobs(n))), ...sec(t('mxWsKindOther', who), rest.filter(n => jobs(n) && !main(n) && !bySub(n)), true), hint('mxWsHint')];
}

/** The picker open (S._miPick: the list it adds to, and which kind of names), for the search typed */
export function modPickView(q: string): ModPickView {
  const p = (S as LegacyAny)._miPick;
  if (p.ws) { const wpn = mxWsWeapon(p.path); return {title: wpn ? t('mxWsTitleFor', {w: wpn.name}) : t('mxWsTitle'), ph: t('mxWsSearch'), blocks: wsBlocks(q)}; }
  if (p.acts) return {title: t('mxActTitle'), ph: t('mxActSearch'), blocks: actBlocks(q)};
  return {title: t('miTitle'), ph: t('miSearch', {n: USABLE_ITEMS.length}), blocks: itemBlocks(q)};
}
