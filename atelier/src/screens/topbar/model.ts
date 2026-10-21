// GearSwap Atelier · what the top bar shows, worked out from the old page's state (globals of atelier/app/js/, typed
// in legacy/globals.d.ts): the character's banner with its job and subjob menus, the characters, the job's macro
// book, lockstyle and export, the files' and the game's commands, the page's. TopBar.svelte draws it.
// Until the old page's actions move to Svelte, the bar's buttons and menus keep the attributes and classes its click
// and change handlers read (events.js, packages.js): `attr` below is that attribute.
//
// @file    atelier/src/screens/topbar/model.ts
// @author  ejouanchicot

export interface Option { value: string; label: string; selected: boolean }
export interface OptionGroup { label: string | null; options: Option[] }
/** A command of the bar: its data-* attribute (the old handlers'), icon, word, tooltip, lit, off */
export interface Command { attr: string; icon: string; label: string; title: string; mid?: boolean; busy?: boolean; disabled?: boolean }
export interface Readout { label: string; text: string; html?: boolean; offline?: string; old?: {title: string; text: string} }

export interface TopBarModel {
  hero: null | {
    char: string;
    role: string | null;
    crest: string | null;
    job: {aria: string; title: string; overview: string; groups: OptionGroup[]; none: boolean};
    sub: null | {title: string; label: string; groups: OptionGroup[]};
  };
  chars: {label: string; list: Array<{name: string; pressed: boolean; title: string}>};
  facts: Readout[];
  files: {label: string; list: Command[]};
  live: null | {label: string; lamp: null | {text: string; title: string; disabled: boolean}; state: null | {text: string; title: string; linked: boolean}; list: Command[]};
  page: {label: string; list: Command[]};
}

// ---- the job and the subjob ----
function jobGroupsOf(): OptionGroup[] {
  const groups = jobGroups(), opt = ([c, name]: [string, string, string], ml: boolean): Option => {
    const m = ml ? masterOf(c) : null;
    return {value: c, label: `${c} · ${name}${m ? ' · ML' + m : ''}`, selected: S.job === c};
  };
  if (groups[0] && groups[0].label !== null) return groups.map(g => ({label: g.label, options: g.jobs.map(j => opt(j, true))}));
  return ROLES.map(r => ({label: t('roles.' + r), options: JOBS.filter(j => j[2] === r && plays(j[0])).map(j => opt(j, false))}))
    .filter(g => g.options.length);
}

function subGroupsOf(): OptionGroup[] {
  const c = S.char, j = S.job, subs = subsOf(c, j), cur = subOf(c, j), mine = exportsOf(c, j), main = defaultSub(c, j);
  const twins = sameAsOf(c, j), own = (s: string) => s !== main && (!!mine[s] || (!!twins[s] && twins[s] !== main));
  const opt = (s: string): Option => ({value: s, label: (s === 'NONE' ? '—' : s) + (own(s) ? ' •' : ''), selected: s === cur});
  const others = allSubs(c, j).filter(s => !subs.includes(s));
  return [{label: t('subMine'), options: subs.map(opt)}].concat(others.length ? [{label: t('subOther'), options: others.map(opt)}] : []);
}

function heroOf(d: LegacyExport | null | undefined): TopBarModel['hero'] {
  if (!S.char) return null;
  const job = S.job ? JOBS.find(x => x[0] === S.job) : undefined;
  return {
    char: S.char,
    role: job ? ROLE_COLOR[job[2]] ?? null : null,
    crest: job ? emblem(job[0]) : null,
    job: {aria: t('colJob'), title: t('ttJob'), overview: t('overview'), groups: jobGroupsOf(), none: !S.job},
    sub: d ? {title: t('ttSub'), label: t('colSub'), groups: subGroupsOf()} : null
  };
}

// ---- the job's macro book, lockstyle and export ----
function factsOf(d: LegacyExport | null | undefined): Readout[] {
  if (!d) return [];
  const out: Readout[] = [{label: t('macro'), text: bookOf(d)}, {label: t('lockstyle'), text: styleOf(d), html: true}];
  if (!d.live) out.push({label: t('colExport'), text: d.at || '—', offline: d.offline ? t('offline') : undefined,
    old: (d.export_version || 1) < EXPORT_VERSION ? {title: t('oldExportHow'), text: t('oldExport')} : undefined});
  return out;
}

// ---- the files: read again without the game (live.js refreshBadge), the page's history (list_prefs.js) ----
function filesOf(): Command[] {
  const out: Command[] = [];
  if (S.char) {
    const busy = S._refresh === 'busy', none = S._refresh === 'none', fail = S._refresh === 'fail';
    let last: {failed: string[]; e: number; u: number} | null = null;
    try { last = JSON.parse(sessionStorage.getItem('atelierRefresh') || 'null'); } catch (e) { last = null; }
    const lastTip = !last ? '' : ' · ' + (last.failed.length ? t('refreshLastFail', {f: last.failed.length, l: last.failed.join(', ')}) : t('refreshLast', {e: last.e, u: last.u}));
    out.push({attr: 'data-refreshfiles', icon: '⟳', disabled: busy, mid: fail || !!(last && last.failed.length),
      title: fail ? S._refreshErr || '' : t(none ? 'refreshNoneTip' : 'refreshTip') + lastTip,
      label: t(busy ? 'refreshBusy' : none ? 'refreshNone' : fail ? 'refreshFail' : 'cmdFiles')});
  }
  if (S.char && S.job) out.push({attr: 'data-pushhist', icon: '⟲', title: t('lpHistoryTip'), label: t('lpHistory')});
  return out;
}

// ---- the game (live.js liveBadge): what GearSwap has loaded and the two ways to read again, or that it is off ----
function liveOf(): TopBarModel['live'] {
  const c = S.char, L = S._live[c] || {}, link = linkOk(c);
  if (!liveConf(c) && !linkConf(c)) return null;
  // an order under way: the bar stays as it was at the press, its buttons off, the one pressed lit
  if (S._liveBusy && Date.now() > S._liveBusy.until) S._liveBusy = null;
  const busy = S._liveBusy || null, was = busy ? busy.was : null;
  const ok = was ? was.ok : L.ok, linked = was ? was.link : link, job = was ? was.job : L.job, sub = was ? was.sub : L.sub;
  const cmd = (attr: string, icon: string, label: string, title: string, what: string): Command =>
    busy && what === busy.what ? {attr: '', icon, label, title: t('busy_' + what), mid: true, busy: true, disabled: true}
      : {attr, icon, label, title, disabled: !!busy};
  const out = {label: 'GearSwap', lamp: null, state: null, list: [] as Command[]};
  if (ok) return Object.assign(out, {lamp: {text: `${t('liveOn')} · ${job}/${sub}`, title: t('liveJump'), disabled: !!busy},
    list: [cmd('data-livereload', '⟳', t('cmdReload'), t('cmdReloadTip'), 'reload'), cmd('data-liverestart', '↺', t('cmdRestart'), t('cmdRestartTip'), 'restart')]});
  if (linked) return Object.assign(out, {state: {text: `● ${t('linkOnly')}`, title: t('linkOnlyHow'), linked: true},
    list: [cmd('data-gsload', '▶', t('gsLoad'), '//lua l gearswap', 'load')]});
  return Object.assign(out, {state: {text: `○ ${t('liveOff')}`, title: t('liveHow'), linked: false}});
}

/** The top bar for the old page's state now */
export function topBarModel(): TopBarModel {
  const d = data();
  return {
    hero: heroOf(d),
    chars: {label: t('grpChar'), list: Object.keys(CHARS).map(c => ({name: c, pressed: c === S.char, title: t(c === S.char ? 'ttCharNow' : 'ttChar', {c})}))},
    facts: factsOf(d),
    files: {label: t('grpFiles'), list: filesOf()},
    live: liveOf(),
    // the Packages page (packages.js) is left out of a player's package (make_package.py): no button there
    page: {label: t('grpPage'), list: [{attr: 'data-config', icon: '⚙', label: t('cfgOpen'), title: t('ttGear'), mid: !!S._cfg && !S._upd},
      {attr: 'data-updopen', icon: '⬆', label: t('updOpen'), title: S._updNew ? t('ttUpdNew', {v: S._updNew}) : t('ttUpd'), mid: !!(S._upd && S._cfg) || !!S._updNew}]
      .concat(typeof renderPackages === 'function' ? [{attr: 'data-pkgopen', icon: '📦', label: t('pkgOpen'), title: t('ttPkg'), mid: !!S._pkg}] : [])}
  };
}
