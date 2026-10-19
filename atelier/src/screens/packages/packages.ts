// GearSwap Atelier · the Packages page (the 📦 button of the top bar): who the package is for (a prepared character
// fills in its jobs), its jobs, two characters at once, the PlayOnline region, what the zip holds and the button that
// makes it, with where the making stands.
// The rules are the old page's renderPackages (packages.js), which keeps PKG, the making (Pyodide in a worker) and the
// clicks and fields (data-pkgset, data-pkgchar, data-pkgfolder, data-pkgjob, data-pkgjobs, data-pkgmake, #pkgname,
// #pkgpartner).
//
// @file    atelier/src/screens/packages/packages.ts
// @author  ejouanchicot

export interface PkgSeg { key: string; opts: Array<{v: string; label: string; on: boolean}> }
export interface PackagesView {
  title: string; back: string; lede: string;
  who: {title: string; why: string; ph: string; name: string; kind: null | {known: boolean; text: string}; chars: null | Array<{name: string; n: number; on: boolean}>; noList: string; folder: string};
  jobs: {title: string; why: string; jobs: Array<{j: string; on: boolean}>; all: string; none: string};
  box: {title: string; why: string; seg: PkgSeg; partner: null | {ph: string; value: string}};
  region: {title: string; why: string; seg: PkgSeg};
  holds: {title: string; lines: string[]; never: string; busy: boolean; make: string; msg: string; msgCls: string; doneHow: string};
}

const seg = (key: string, opts: Array<[string, string]>): PkgSeg => ({key, opts: opts.map(([v, label]) => ({v, label, on: PKG[key] === v}))});

/** The Packages page, or null when it is not the one shown */
export function packagesView(): PackagesView | null {
  if (!S._pkg) return null;
  const k = PKG.name.trim() && pkgKnownOf(PKG.name), busy = PKG.state === 'busy';
  return {title: t('pkgTitle'), back: t('pkgBack'), lede: t('pkgLede'),
    who: {title: t('pkgWho'), why: t('pkgWhoWhy'), ph: t('pkgName'), name: PKG.name,
      // prepared or new: said once the list is read (before it, every name would read as new)
      kind: PKG.name.trim() && PKG.known ? {known: !!(k && k.overlay), text: t(k && k.overlay ? 'pkgKnown' : 'pkgNew')} : null,
      chars: PKG.known ? PKG.known.map((c: LegacyAny) => ({name: c.name, n: c.jobs.length, on: !!k && k.name === c.name})) : null,
      noList: t('pkgNoList'), folder: (window as LegacyAny).showDirectoryPicker ? t('pkgFolder') : ''},
    jobs: {title: t('pkgJobs'), why: t('pkgJobsWhy'), jobs: PKG_JOBS.map((j: string) => ({j, on: PKG.jobs.includes(j)})), all: t('pkgAll'), none: t('pkgNone')},
    box: {title: t('pkgBox'), why: t('pkgBoxWhy'), seg: seg('box', [['solo', t('pkgSolo')], ['main', t('pkgMain')], ['alt', t('pkgAlt')]]),
      partner: PKG.box === 'solo' ? null : {ph: t('pkgPartner'), value: PKG.partner}},
    region: {title: t('pkgRegion'), why: t('pkgRegionWhy'), seg: seg('region', [['US', 'US'], ['EU', 'EU'], ['JP', 'JP']])},
    holds: {title: t('pkgHolds'), lines: [1, 2, 3, 4, 5].map(n => t('pkgHold' + n)), never: t('pkgNever'), busy, make: '📦 ' + t(busy ? 'pkgBusy' : 'pkgMake'),
      msg: PKG.msg || '', msgCls: PKG.state === 'fail' ? 'kwarn' : PKG.state === 'done' ? '' : 'muted', doneHow: PKG.msg && PKG.state === 'done' ? t('pkgDoneHow') : ''}};
}
