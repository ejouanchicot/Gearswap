// GearSwap Atelier · the home page, before a job is picked: the character's played jobs in a table (role, subjob, how
// many sets and keys, macro book, lockstyle, when it was exported; the jobs with no master level greyed once some have
// one), or, with nothing exported yet, how to fill the page (by the game, or from the files).
// The rules are the old page's renderHome (sets_view.js) and welcomeHTML (welcome.js), which keep the reading of the
// files (welcomeRead) and the clicks (a row: data-job, data-wcread).
//
// @file    atelier/src/screens/home/home.ts
// @author  ejouanchicot

export interface HomeRow { c: string; name: string; dim: boolean; role: string; roleColor: string; emblemHtml: string; badgeHtml: string; sub: string; sets: number; keys: number; bookHtml: string; styleHtml: string; atHtml: string }
export interface HomeView {
  welcome: null | {title: string; lede: string; gameT: string; steps: string[][]; gameWhy: string; filesT: string; files1: string; filesWhy: string; busy: boolean; btn: string; msg: string; fail: boolean};
  table: null | {kicker: string; char: string; summary: string; heads: string[]; rows: HomeRow[]; foot: string};
}

// The page shown when nothing is exported yet: the steps in game, the commands set in them
function welcomeView(): HomeView['welcome'] {
  const busy = WELCOME.state === 'busy';
  // a step is cut around its commands: [text, command, text, ...]
  const cut = (s: string) => s.split(/(\u0001|\u0002)/).map(x => x === '\u0001' ? '//gs c atelier' : x === '\u0002' ? '//gs c atelier on' : x);
  return {title: t('wcTitle'), lede: t('wcLede'), gameT: t('wcGameT'), steps: [t('wcGame1'), t('wcGame2', {c: '\u0001', o: '\u0002'}), t('wcGame3')].map(cut),
    gameWhy: t('wcGameWhy'), filesT: t('wcFilesT'), files1: t('wcFiles1'), filesWhy: t('wcFilesWhy'), busy, btn: t(busy ? 'wcBusy' : 'wcFilesBtn'),
    msg: WELCOME.msg || '', fail: WELCOME.state === 'fail'};
}

/** The home page, or null when a job, the page's settings or the packages are shown */
export function homeView(): HomeView | null {
  if ((S._pkg && typeof renderPackages === 'function') || S._cfg || S.job) return null;
  if (!CHARS[S.char]) return {welcome: welcomeView(), table: null};
  const groups = jobGroups(), jobs = groups.flatMap((g: LegacyAny) => g.jobs);
  const dim = new Set(groups.filter((g: LegacyAny) => g.label !== null && !g.master).flatMap((g: LegacyAny) => g.jobs.map((j: LegacyAny) => j[0])));
  let totS = 0, totK = 0;
  const rows = jobs.map(([c, name, r]: [string, string, string]) => { const d = recordOf(S.char, c), n = counts(c);
    totS += n.sets; totK += n.keys;
    return {c, name, dim: dim.has(c), role: t('roles.' + r), roleColor: ROLE_COLOR[r] || '', emblemHtml: emblem(c), badgeHtml: jobBadge(c), sub: d.sub || '—',
      sets: n.sets, keys: n.keys, bookHtml: bookOf(d), styleHtml: styleOf(d), atHtml: esc(d.at || '—') + (d.offline ? ' · ' + t('offline') : '')}; });
  return {welcome: null, table: {kicker: t('overview'), char: S.char, summary: t('summary', {j: jobs.length, s: totS, k: totK}), rows, foot: t('mock'),
    heads: [t('colJob'), t('colRole'), t('colSub'), t('colSets'), t('colKeys'), t('macro'), t('lockstyle'), t('colExport')]}};
}
