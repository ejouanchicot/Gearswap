// GearSwap Atelier · the Modules part of the job's settings: the character's config files, shown two ways. Options:
// the catalog's options by family, in the player's words (module_catalog.js), with a presentation of the job first.
// Files: one file at a time, the options the catalog explains then the rest in the file's own words. A search over
// both, and the bar of the changes that wait, to save in one go.
// The rules are the old page's renderModules, renderModulesSimple, mcIntroHTML, mcCardHTML, modRowHTML, modListHTML,
// modGroupHTML (modules.js), modTop, modSaveBar, modSearch (module_ux.js). A setting's control (a switch, choices, a
// number, items, a table of lines, a colour) is still the old page's HTML, with the attributes its handlers read
// (modules.js modControl / mcControl and module_ux.js, module_items.js, module_rows.js): `ctlHtml` below.
//
// @file    atelier/src/screens/config/modules.ts
// @author  ejouanchicot

export interface ModKey { name: string; code: string | null; doc: string }
/** A line of the Files view: a table's heading (grp), or a setting with its control */
export interface ModRow { grp: boolean; depth: number; key: ModKey; tintHtml: string; ctlHtml: string; changed: boolean; tall: boolean }
/** An option of the Options view */
export interface ModCard { title: string; desc: string; scope: {cls: string; text: string; tip: string}; ctlHtml: string; changed: boolean; tall: boolean }
export type ModItem = {kind: 'part'; title: string; why: string} | {kind: 'card'; card: ModCard} | {kind: 'row'; row: ModRow};
export interface NavEntry { attr: 'data-modfam' | 'data-modopen'; value: string; current: boolean; title: string; name: string; small: string; dot: number }
export interface NavGroup { id: string; name: string; open: boolean; title: string; changed: number; count: number; entries: NavEntry[] }
export interface Nav { intro: NavEntry | null; groups: NavGroup[] }
export interface Intro {
  title: string; job: string; lead: string; points: Array<{b: string; text: string}>; where: string; links: Array<{tab: string; label: string}>;
  own: null | {label: string}; allTitle: string; allWhy: string;
  groups: Array<{name: string; mods: Array<{fam: string; title: string; name: string; tip: string; count: string}>}>;
}
export interface SaveLine { title: string; was: string; now: string; file: string; path: string }
export type ModBody =
  | {kind: 'search'; title: string; items: ModItem[]; more: string; none: string}
  | {kind: 'intro'; nav: Nav; intro: Intro}
  | {kind: 'family'; nav: Nav; title: string; meta: string; tip: string; use: null | {label: string; text: string}; cards: ModCard[]}
  | {kind: 'file'; nav: Nav; title: string; meta: string; metaTitle: string; what: string; scope: {cls: string; text: string; tip: string};
      manual: null | {summary: string; text: string}; items: ModItem[]; adv: null | {summary: string; rows: ModRow[]}; empty: string};
export interface ModulesView {
  none: string | null;
  top: {q: string; placeholder: string; title: string; clear: null | {title: string; text: string}; hint: string;
    views: Array<{value: string; label: string; title: string; pressed: boolean}>; lock: null | {title: string; text: string}};
  toast: string;
  body: ModBody | null;
  save: null | {title: string; tip: string; undo: {title: string; text: string}; save: {title: string; text: string}; revert: string; lines: SaveLine[]};
}

const famName = (fam: LegacyFamily) => (S.lang === 'en' ? fam.en : fam.fr).split('{JOB}').join(S.job || '');
const lang = () => S.lang === 'en' ? 1 : 0;
const idOf = (file: string, path: string) => `data-modfile="${esc(file)}" data-modpath="${esc(path)}"`;

// ---- a setting of the Files view, and the tables above it (modules.js modRowHTML) ----
// `skip`: the paths the Options part shows above (a table whose every setting is there is left out)
function skipped(x: LegacyField, skip: Record<string, unknown>): boolean {
  return x.kind === 'map' ? x.fields.length > 0 && x.fields.every(c => skipped(c, skip)) : !!skip[x.path];
}

function rowsOf(f: LegacyConfigFile, x: LegacyField, depth: number, skip: Record<string, unknown>): ModRow[] {
  if (skipped(x, skip)) return [];
  const ed = modEdits(f.file)[x.path], val = ed ? ed.v : x.value, off = modCanWrite(f) ? '' : 'disabled';
  // in French, the setting's name and what it does are the page's own (module_rest_fr.js); else the file's comments
  const rest = modRestFr(f.file, x.path), fr = S.lang === 'en' ? null : rest, name = fr ? fr.title : modName(x);
  const key = {name, code: x.key != null && name !== x.key ? x.key : null, doc: fr ? fr.desc : [modDoc(x.doc), x.note].filter(Boolean).join('\n')};
  // a table that holds a colour (r g b): the colour itself on its line, its three numbers under it
  const tintHtml = mxColorMap(x) ? modColorMap(f, x, off) : '';
  if (x.kind === 'map') return [{grp: true, depth, key, tintHtml, ctlHtml: '', changed: false, tall: false}]
    .concat(x.fields.flatMap(c => rowsOf(f, c, depth + 1, skip)));
  // an empty table of named entries looks like an empty list: it is shown, not changed here
  const named = rest && rest.map && x.kind === 'list' && !x.fields.length;
  const ctlHtml = named ? `<details class="modadv"><summary>${esc(t('modNamed'))}</summary><pre class="modcode">${esc(f.text.slice(x.a, x.b))}</pre></details>`
    : modControl(f, x, val, idOf(f.file, x.path), off);
  return [{grp: false, depth, key, tintHtml: '', ctlHtml, changed: !!ed, tall: x.kind === 'code' || (x.kind === 'list' && !mxColorList(f, x)) || x.kind === 'rows'}];
}

// ---- an option of the Options view (modules.js mcCardHTML) ----
function cardOf(d: LegacyExport, r: LegacyCatalogRow): ModCard {
  const edits = modEdits(r.f.file), ed = edits[r.x.path], val = ed ? ed.v : r.x.value, off = modCanWrite(r.f) ? '' : 'disabled';
  const part = !!r.it.rgb && r.x.fields.some(c => edits[c.path]);
  return {title: r.title, desc: r.desc, scope: mcScope(d, r), ctlHtml: mcControl(r, val, idOf(r.f.file, r.x.path), off),
    changed: !!ed || part, tall: r.x.kind === 'list' || r.x.kind === 'rows' || !!r.it.presets};
}

// ---- the left column (modules.js modGroupHTML, modListHTML, renderModulesSimple) ----
// a group is folded until the player opens it (S.modGrp, kept), the one that holds what is shown open by itself
function groupOf(g: LegacyGroup, count: number, has: boolean, changed: number, entries: NavEntry[]): NavGroup {
  const said = ((S.modGrp || {}) as Record<string, boolean | undefined>)[g.id], open = said == null ? has : said;
  return {id: g.id, name: modGroupName(g), open, title: t(open ? 'ttGrpFold' : 'ttGrpOpen'), changed, count, entries};
}

type Fam = {fam: LegacyFamily; rows: LegacyCatalogRow[]};
const changedIn = (x: Fam) => x.rows.filter(r => modEdits(r.f.file)[r.x.path]).length;

function familyNav(fams: Fam[], cur: Fam | null, intro: boolean): Nav {
  const entry = (x: Fam): NavEntry => ({attr: 'data-modfam', value: x.fam.id, current: x === cur, title: x.fam.tip[lang()],
    name: famName(x.fam), small: t('modSettings', {n: x.rows.length}), dot: changedIn(x)});
  return {
    intro: {attr: 'data-modfam', value: 'intro', current: intro, title: t('ttIntro', {j: S.job}), name: t('mcIntro'), small: t('mcIntroSub', {j: S.job}), dot: 0},
    groups: MOD_GROUPS.flatMap(g => { const list = fams.filter(x => x.fam.group === g.id && x.rows.length);
      return list.length ? [groupOf(g, list.length, !!cur && list.includes(cur), list.reduce((n, x) => n + changedIn(x), 0), list.map(entry))] : []; })
  };
}

function fileNav(d: LegacyExport, cur: LegacyConfigFile): Nav {
  const files = modFiles(d) as LegacyConfigFile[];
  return {intro: null, groups: MOD_GROUPS.flatMap(g => {
    const list = files.filter(f => modFileGroup(f) === g.id);
    if (!list.length) return [];
    const changed = list.reduce((n, f) => n + Object.keys(modEdits(f.file)).length, 0);
    return [groupOf(g, list.length, list.includes(cur), changed, list.map(f => { const info = modFileInfo(f);
      return {attr: 'data-modopen' as const, value: f.file, current: f === cur, title: info.what || info.name, name: info.name,
        small: f.file.split('/').pop() || '', dot: Object.keys(modEdits(f.file)).length}; }))];
  })};
}

// ---- the presentation: what the job does with this GearSwap, then each module in a sentence (mcIntroHTML) ----
function introOf(fams: Fam[]): Intro {
  const job = S.job || '', l = lang(), g = (l ? JOB_GUIDE_EN : JOB_GUIDE_FR)[job] || (l ? null : JOB_GUIDE_EN[job]) || ['', []];
  const own = fams.find(x => x.fam.id === 'job');
  return {
    title: t('mcIntroTitle', {j: job}), job: t('mcIntroJob', {j: job}), lead: g[0], points: g[1].map(([b, text]) => ({b, text})),
    where: t('mcIntroWhere'), links: [['keys', 'sectionsKeys'], ['modes', 'sectionsModes'], ['functions', 'sectionsFunctions']].map(([tab, k]) => ({tab: tab!, label: t(k!)})),
    own: own && own.rows.length ? {label: t('mcIntroOwn', {n: own.rows.length, j: job})} : null,
    allTitle: t('mcIntroAll'), allWhy: t('mcIntroAllWhy'),
    // every module that is not the job's own, group by group: what this GearSwap does on any job
    groups: MOD_GROUPS.filter(gr => gr.id !== 'job').map(gr => ({name: modGroupName(gr), mods: fams.filter(x => x.fam.group === gr.id && x.rows.length)
      .map(x => ({fam: x.fam.id, title: t('ttIntroGo', {f: famName(x.fam)}), name: famName(x.fam), tip: x.fam.tip[l], count: t('modSettings', {n: x.rows.length})}))}))
      .filter(gr => gr.mods.length)
  };
}

// ---- the search: every word typed in an option's name, what it does, its module or its value (modSearch) ----
function searchOf(d: LegacyExport): ModBody {
  const q = String(S.modQ || '').trim(), words = mxNorm(q).split(/\s+/).filter(Boolean), items: ModItem[] = [], seen = new Set<string>();
  let n = 0, left = MX_MAX;
  const add = (title: string, list: ModItem[]) => { n += list.length; if (left > 0) items.push({kind: 'part', title, why: ''}, ...list); left -= list.length; };
  for (const fam of MOD_CATALOG) {
    const rows = mcRows(d, fam).filter(r => !seen.has(r.f.file + '|' + r.x.path) && mxHit(words, r.title, r.desc, famName(fam), r.x.key, mxValText(modValue(r.f.file, r.x.path))));
    rows.forEach(r => seen.add(r.f.file + '|' + r.x.path));
    if (rows.length) add(famName(fam), rows.map(r => ({kind: 'card' as const, card: cardOf(d, r)})));
  }
  // the settings only the Files view holds: by file
  for (const f of modFiles(d) as LegacyConfigFile[]) {
    const known = modKnown(d, f), hits = Object.values(modParsed(f).byPath).filter(x => {
      if (known[x.path] || x.kind === 'map' || x.kind === 'code') return false;
      const fr = S.lang === 'en' ? null : modRestFr(f.file, x.path);
      return mxHit(words, fr ? fr.title : modName(x), fr ? fr.desc : modDoc(x.doc), x.key, mxValText(modValue(f.file, x.path)));
    });
    if (hits.length) add(t('mxInAdv', {f: modFileInfo(f).name}), hits.flatMap(x => rowsOf(f, x, 0, {})).map(row => ({kind: 'row' as const, row})));
  }
  return {kind: 'search', title: t('mxFound', {n, q}), items, more: n > MX_MAX ? t('mxMore', {n: MX_MAX}) : '', none: n ? '' : t('mxNone', {q})};
}

// ---- the Options view: the presentation, or one family's options (renderModulesSimple) ----
function optionsOf(d: LegacyExport): ModBody {
  const fams: Fam[] = MOD_CATALOG.map(fam => ({fam, rows: mcRows(d, fam)}));
  const intro = !S.modFam || S.modFam === 'intro' || !fams.some(x => x.fam.id === S.modFam && x.rows.length);
  const cur = intro ? null : fams.find(x => x.fam.id === S.modFam) || null;
  const nav = familyNav(fams, cur, intro);
  if (!cur) return {kind: 'intro', nav, intro: introOf(fams)};
  const group = MOD_GROUPS.find(g => g.id === cur.fam.group), l = lang();
  return {kind: 'family', nav, title: famName(cur.fam), meta: (group ? modGroupName(group) + ' · ' : '') + t('modSettings', {n: cur.rows.length}),
    tip: cur.fam.tip[l], use: cur.fam.use ? {label: t('mcInGame'), text: cur.fam.use[l]} : null, cards: cur.rows.map(r => cardOf(d, r))};
}

// ---- the Files view: the file opened, what it is and what a change reaches (renderModules) ----
function fileOf(d: LegacyExport): ModBody {
  const cur = modShown(d), p = modParsed(cur), info = modFileInfo(cur), known = modKnown(d, cur);
  const plain = p.fields.filter(x => x.kind !== 'code'), code = p.fields.filter(x => x.kind === 'code');
  const top = Object.values(known).map(r => ({kind: 'card' as const, card: cardOf(d, r)}));
  const rest = plain.flatMap(x => rowsOf(cur, x, 0, known)).map(row => ({kind: 'row' as const, row}));
  const adv = code.flatMap(x => rowsOf(cur, x, 0, known));
  const items: ModItem[] = [];
  if (top.length) { if (rest.length || adv.length) items.push({kind: 'part', title: t('modPartKnown'), why: ''}); items.push(...top); }
  if (rest.length) items.push({kind: 'part', title: t(top.length ? 'modPartRest' : 'modPartAll'), why: S.lang === 'en' ? '' : t('modPartRestWhy')}, ...rest);
  const job = cur.scope === 'job';
  return {kind: 'file', nav: fileNav(d, cur), title: info.name, meta: S.char + '/' + cur.file, metaTitle: t('modPathTip'), what: info.what,
    scope: job ? {cls: 'job', text: t('mcScopeJob', {j: S.job}), tip: t('ttScopeJob', {c: S.char, j: S.job})} : {cls: 'all', text: t('mcScopeAll'), tip: t('ttScopeAll', {c: S.char})},
    manual: p.head.about ? {summary: t('modManual'), text: p.head.about} : null, items,
    adv: adv.length ? {summary: t('modPartAdv', {n: code.length}), rows: adv} : null, empty: items.length || adv.length ? '' : t('modEmpty')};
}

// ---- the bar of the changes that wait (module_ux.js modSaveBar) ----
function saveOf(): ModulesView['save'] {
  const all = ((S._modEdits || {}) as Record<string, Record<string, Record<string, LegacyEdit>>>)[S.char] || {}, lines: SaveLine[] = [];
  for (const file of Object.keys(all)) for (const path of Object.keys(all[file]!)) { const e = all[file]![path]!;
    lines.push({title: mxTitle(file, path), was: mxCut(e.before), now: mxCut(e.after), file, path}); }
  if (!lines.length) return null;
  return {title: t('mxWait', {n: lines.length}), tip: t('mxWaitTip'), undo: {title: t('ttModUndo'), text: t('mxUndoAll')},
    save: {title: t('ttModSave'), text: t('modSave')}, revert: t('mxRevert'), lines};
}

/** The Modules part for the export shown */
export function modulesView(d: LegacyExport): ModulesView {
  const files = modFiles(d), filesView = S.modView === 'files', q = String(S.modQ || '');
  const top: ModulesView['top'] = {q, placeholder: t('mxSearch'), title: t('mxSearchTip'), clear: q ? {title: t('mxClearTip'), text: t('mxClear')} : null,
    hint: filesView ? t('modHint') : t('mcHint'),
    views: [['simple', 'mcSimple'], ['files', 'mcFiles']].map(([value, k]) => ({value: value!, label: t(k!), title: t(k + 'Tip'), pressed: filesView === (value === 'files')})),
    lock: liveOk() ? null : {title: t('mxLockT'), text: t('mxLock', {c: S.char})}};
  if (!files.length) return {none: t('modNone'), top, toast: '', body: null, save: null};
  const body = q.trim() ? searchOf(d) : filesView ? fileOf(d) : optionsOf(d);
  return {none: null, top, toast: S.toast || '', body, save: saveOf()};
}
