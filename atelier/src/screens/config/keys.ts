// GearSwap Atelier · the Modes & keys part of the job's settings: first every mode, its start value (a click chooses it:
// <Char>/atelier/overrides/mode_overrides.lua, keys.js modeOverrides) and its key; then the other keys by where they
// are written (the job's file, its CUSTOM file, the combat and treasure keys, the keys every job has), Mote's own keys
// and the keys bound for the game session, each with what it does; the bar that says what was changed and saves both.
// (The Modes and Functions parts showed these modes until 2026-10-29, without letting them be chosen.)
// The rules are the old page's renderKeys (atelier/app/js/keys.js): the keys' helpers stay there (keyOf, keyClash...).
// A field ending in Html is the old page's HTML (a key's caps: keyLabel) or one of its texts it wrote unescaped.
//
// @file    atelier/src/screens/config/keys.ts
// @author  ejouanchicot

export interface KeyRow {
  keyHtml: string; desc: string; help: string; sub: string; edit: number | null; changed: boolean; code?: string;
  /** its state (ok, clash, yield, taken, other, hidden, none), said in a chip with its tooltip; the key, to group the conflicts */
  st: string; stText: string; stTip: string; keyId: string;
}
export interface KeyBox { key: string; cls: string; title: string; meta: string; rows: KeyRow[] }
/** "Other keys" as one list: the conflicts first, the filter (all, conflicts, one box), the boxes shown */
export interface KeyList {
  /** Mote's keys, folded at the bottom (the page cannot change them), open when their filter is chosen */
  mote: {box: KeyBox; why: string; open: boolean} | null;
  filters: Array<{id: string; label: string; on: boolean; bad: boolean}>;
  conflicts: {title: string; why: string; chip: string; items: Array<{keyHtml: string; names: string[]; edit: number | null}>} | null;
  none: string;
  boxes: KeyBox[];
}
/** A mode: its values (the start one, the file's), its key and the button that changes it */
export interface ModeRow {
  name: string; title: string; help: string; changed: boolean;
  values: Array<{value: string; start: boolean; file: boolean; tip: string}>; keyHtml: string; edit: number | null;
  /** as a game's option: its icon, its name as the game shows it (Cure Mode), what it is in a player's words
   *  underneath (player_words.js), its control (the values as the game shows them: Potency, SIRD) */
  iconHtml: string; label: string; hint: string; sel: boolean;
  /** a switch (On / Off), every value as a button (a few), or a list (many: Fast Cast 0..80) */
  ctl: {k: 'switch'; on: boolean; attr: string; tip: string}
    | {k: 'seg'; opts: Array<{label: string; attr: string; on: boolean; file: boolean; tip: string}>}
    | {k: 'select'; name: string; opts: Array<{value: string; label: string; on: boolean}>};
  /** the value now, in a player's words (the sentence below) */
  valueText: string;
}
import type {ProNav, ProDetail, ProFoot} from './pro';
import {iconCredit} from './pro';

/** The part in the frame of the three parts (ProFrame.svelte): its categories, its title, the detail, the bar */
export interface KeysPro { nav: ProNav; head: {iconHtml: string; title: string; sub: string}; detail: ProDetail | null; foot: ProFoot; keys: boolean }
/** The modes of the part shown (the theme opened, another subjob's, the more technical ones) */
export interface GameView {
  head: {iconHtml: string; title: string; sub: string};
  part: 'modes' | 'more' | 'keys' | 'away';
  rows: ModeRow[];
  /** the themes of the modes shown, the one opened, how many more technical modes */
  themes: string[]; theme: string; more: number;
}
export interface ModesBox { rows: ModeRow[]; away: null | {title: string; rows: ModeRow[]} }
export interface KeysView {
  /** the button that shows (or hides) the keys of the other subjobs */
  bar: {others: null | {title: string; textHtml: string}};
  game: GameView;
  pro: KeysPro;
  list: KeyList;
  /** the key as a button: "Change" beside its caps, its tooltip, the word for a mode without a key */
  change: {text: string; tip: string; none: string};
  /** the icons' authors, under the categories (pro.ts iconCredit) */
  credit: string;
}

const GROUPS = ['job', 'custom', 'combat', 'treasure', 'common'];
const COLORS: Record<string, string> = {job: 'g-def', custom: 'g-attr', combat: 'g-off', treasure: 'g-res', common: 'g-other'};

const helpOf = (state: string | undefined): string => state ? stateHelp(state) : '';

function jobRow(d: LegacyExport, k: LegacyKey, i: number): KeyRow {
  const key = keyOf(k), file = fileKey(k), changed = !!k.id && key !== file;
  const beaten = keyBeatenBy(d, k), clashes = keyClash(d, k, key);
  const st = !key ? 'none' : k.visible_now === false ? 'hidden' : !keyActive(k, d.sub) ? 'other' : clashes.length ? 'clash' : beaten ? 'yield' : 'ok';
  return {keyHtml: keyLabel(key), desc: keyDescText(k.desc), help: helpOf(k.state),
    sub: k.subjob ? '/' + k.subjob : '', edit: k.id ? i : null, changed,
    ...state(st, clashes.map(c => keyDescText(c.desc)).join(', ') || (beaten ? beaten.desc : '')), keyId: (key || '').toLowerCase()};
}

const ST_TEXT: Record<string, string> = {ok: 'stOk', clash: 'stClash', yield: 'stYield', taken: 'stTaken', other: 'stOther', hidden: 'stHidden', none: 'stNone'};
function state(st: string, who: string): {st: string; stText: string; stTip: string} {
  return {st, stText: t(ST_TEXT[st]!), stTip: st === 'none' ? '' : t(ST_TEXT[st]! + 'Tip', {d: who})};
}

// Mote's keys: a key that changes a mode is said by the mode's name as the game shows it, with what the mode does
function moteRows(d: LegacyExport): KeyRow[] {
  const modeName = (st: string) => (d.modes.find(m => m.name === st) || {desc: ''}).desc || st;
  return MOTE_BINDS.map(([key, st, what]) => {
    const by = moteTakenBy(d, key);
    return {keyHtml: keyLabel(key), desc: st ? t('keyMoteCycle', {m: modeName(st)}) : (S.lang !== 'en' && MOTE_DESC_FR[what]) || what,
      help: helpOf(st), sub: '', edit: null, changed: false,
      ...state(by ? 'taken' : 'ok', by ? by.desc : ''), keyId: key};
  });
}

// a mode's name as the HUD shows it: the mode's own description, else the one of the key that cycles it
// (WHM_KEYBINDS.lua desc = "Cure Mode"), else its code name
function gameName(d: LegacyExport, m: LegacyMode): string {
  const k = d.keys.find(k => k.state === m.name && k.desc);
  return m.desc || (k && k.desc) || m.name;
}

// a mode's row: its values with the start one and the file's marked, its key (the job's row that cycles it, editable)
function modeRow(d: LegacyExport, m: LegacyMode, keyOfSt: Record<string, string>): ModeRow {
  const start = String(modeStart(d, m)).toLowerCase(), file = String(modeFileStart(d, m)).toLowerCase();
  const i = d.keys.findIndex(k => k.state === m.name && !!k.id && keyActive(k, d.sub));
  // the values keep the game's words (the HUD's, the chat's); a player's words are the tooltip
  const w = playerMode(m.name, S.job);
  const meant = (v: string) => (w && w.vals[v] && w.vals[v] !== v ? w.vals[v] : '');
  const vals = m.values, at = Math.max(0, vals.findIndex(v => v.toLowerCase() === start)), cur = vals[at] || String(modeStart(d, m));
  const lows = vals.map(v => v.toLowerCase()), toggle = vals.length === 2 && lows.includes('on') && lows.includes('off');
  const pick = (v: string) => m.name + '|' + v;
  // a few values, short enough: each a button; many, or long ones: a list
  const many = vals.length > 4 || vals.reduce((n, v) => n + v.length, 0) > 44;
  const ctl: ModeRow['ctl'] = toggle
    ? {k: 'switch', on: start === 'on', attr: pick(vals[lows.indexOf(start === 'on' ? 'off' : 'on')]!), tip: t('modePickTip')}
    : many ? {k: 'select', name: m.name, opts: vals.map(v => ({value: v, label: v, on: v.toLowerCase() === start}))}
    : {k: 'seg', opts: vals.map(v => ({label: v, attr: pick(v), on: v.toLowerCase() === start, file: v.toLowerCase() === file && start !== file,
        tip: [meant(v), v.toLowerCase() === start ? t('modeStartTip') : v.toLowerCase() === file ? t('modeFileTip') : t('modePickTip')].filter(Boolean).join(' · ')}))};
  // its icon: the item the value names (a weapon), the one of the value chosen, or the mode's own
  const wi = w ? w.icon : null;
  const icon = wi === 'value' ? (iconIds()[cur] || (catalog() || {id: {}} as LegacyAny).id[cur]) : wi && typeof wi === 'object' ? (wi as Record<string, LegacyAny>)[cur] : wi;
  return {name: m.name, title: m.desc || m.name, help: stateHelp(m.name), changed: start !== file,
    values: m.values.map(v => ({value: v, start: v.toLowerCase() === start, file: v.toLowerCase() === file && start !== file,
      tip: v.toLowerCase() === start ? t('modeStartTip') : v.toLowerCase() === file ? t('modeFileTip') : t('modePickTip')})),
    keyHtml: keyLabel(keyOfSt[m.name]), edit: i >= 0 ? i : null,
    iconHtml: playerIcon(icon as LegacyAny), label: gameName(d, m), hint: [w ? w.name : '', COMMON_MODES.has(m.name) ? t('modeCommon') : ''].filter(Boolean).join(' · '), sel: S._modeSel === m.name, ctl,
    valueText: toggle ? (start === 'on' ? 'ON' : 'OFF') : cur + (meant(cur) ? ' (' + meant(cur) + ')' : '')};
}

function modesBox(d: LegacyExport): ModesBox {
  const keyOfSt = keyOfState(d);
  const all = d.modes.filter(m => !modeHidden(m) && !/^[A-Z]{3}Song\d$/.test(m.name));
  const away = all.filter(m => stateElsewhere(d, m.name)), shown = all.filter(m => !away.includes(m));
  return {rows: shown.map(m => modeRow(d, m, keyOfSt)),
    away: away.length ? {title: t('modesAway', {s: d.sub}), rows: away.map(m => modeRow(d, m, {}))} : null};
}

// The part's options screen: the modes (or those of another subjob) as a game's options, the other keys as they are
// the job's own modes first, then those every job has (player_words.js), in the words' order; the modes without words
// yet (Mote's own, the technical ones) wait under "More modes"
function wordsRank(name: string): number {
  const own = Object.keys((PLAYER_WORDS.modes as LegacyAny)[S.job || ''] || {}), all = Object.keys(PLAYER_WORDS.modes['*'] || {});
  return own.includes(name) ? own.indexOf(name) : all.includes(name) ? 100 + all.indexOf(name) : -1;
}
// the modes a player leaves alone (Mote's targeting, the test tool, what GearSwap follows by itself): under "More modes",
// with the modes of a single value (nothing to choose)
const TECH_MODES = new Set(['EquipStop', 'Moving', 'PCTargetMode', 'SelectNPCTargets', 'RestingMode', 'PhysicalDefenseMode', 'MagicalDefenseMode']);
function gameOf(modes: ModesBox): GameView {
  // a weapon stays with my modes even with a single one (the place to add the next weapon)
  const isMore = (r: ModeRow) => TECH_MODES.has(r.name) || (r.values.length <= 1 && !/Weapon$/.test(r.name));
  const rank = (r: ModeRow) => { const n = wordsRank(r.name); return n < 0 ? 999 : n; };
  const worded = modes.rows.filter(r => !isMore(r)).sort((a, b) => rank(a) - rank(b)), more = modes.rows.filter(isMore);
  const asked = String(S.keysPart || '');
  const part = (asked === 'keys' || (asked === 'away' && modes.away) || (asked === 'more' && more.length) ? asked : 'modes') as GameView['part'];
  const groupOf = (r: ModeRow) => (playerMode(r.name, S.job) || {group: 'other'}).group;
  const themes = PLAYER_GROUPS.filter(([id]) => worded.some(r => groupOf(r) === id)).map(([id]) => id);
  // a theme of the modes (m:<group>, kept), else the first
  const theme = part === 'modes' ? (asked.startsWith('m:') && themes.includes(asked.slice(2)) ? asked.slice(2) : themes[0] || '') : '';
  const rows = part === 'away' ? modes.away!.rows : part === 'modes' ? worded.filter(r => groupOf(r) === theme) : part === 'more' ? more : [];
  // the parts' icons (game-icons.net, game_icons.js)
  const ICON: Record<string, string> = {modes: 'gi:gamepad', keys: 'gi:keyboard', away: 'gi:cycle', more: 'gi:cog'};
  const TITLE: Record<string, string> = {modes: 'gModes', away: 'gAway', more: 'gMore'};
  const head = part === 'keys' ? {iconHtml: playerIcon(ICON.keys!), title: t('gKeys'), sub: t('gKeysHead')}
    : {iconHtml: playerIcon(ICON[part]!), title: t(TITLE[part]!), sub: t(part === 'more' ? 'gMoreHead' : 'gModesHead')};
  return {head, part, rows, themes, theme, more: more.length};
}

// ---- the part in the frame of the three parts ----
function proOf(g: GameView, modes: ModesBox, dirty: boolean, keyCount: number, clash: number): KeysPro {
  const grp = (id: string) => PLAYER_GROUPS.find(x => x[0] === id) || [id, 'gi:cog', id, id];
  const item = (id: string, icon: string, name: string, count: number | string, on: boolean, dot = false) =>
    ({id, iconHtml: playerIcon(icon), name, count: String(count), dot, current: on, attr: {'data-keyspart': id}});
  const groupOf = (r: ModeRow) => (playerMode(r.name, S.job) || {group: 'other'}).group;
  const modeItems = g.themes.map(id => { const x = grp(id), rs = modes.rows.filter(r => groupOf(r) === id);
    return item('m:' + id, x[1], S.lang === 'en' ? x[3] : x[2], rs.filter(r => r.values.length > 1 || /Weapon$/.test(r.name)).length, g.part === 'modes' && g.theme === id, rs.some(r => r.changed)); });
  if (g.more) modeItems.push(item('more', 'gi:cog', t('gMore'), g.more, g.part === 'more'));
  const keyItems = [item('keys', 'gi:keyboard', t('cfgAllKeys'), keyCount, g.part === 'keys', clash > 0)];
  if (modes.away) keyItems.push(item('away', 'gi:cycle', t('cfgAway'), modes.away.rows.length, g.part === 'away'));
  const sec = g.part === 'modes' ? grp(g.theme) : null;
  const head = g.part === 'keys' ? {iconHtml: playerIcon('gi:keyboard'), title: t('cfgAllKeys'), sub: t('gKeysHead')}
    : sec ? {iconHtml: playerIcon(sec[1]), title: S.lang === 'en' ? sec[3] : sec[2], sub: t('gModesHead')} : g.head;
  // the detail: the mode chosen (else the first): what it does, its start value, the file's, its key
  const sel = g.part === 'keys' ? null : g.rows.find(r => r.sel) || g.rows[0];
  const w = sel ? playerMode(sel.name, S.job) : null, file = sel ? (sel.values.find(v => v.file) || sel.values.find(v => v.start)) : null;
  const detail: ProDetail | null = sel ? {iconHtml: sel.iconHtml, title: sel.label, tag: w ? w.name : '', what: (w && w.desc) || sel.help || t('gNoDesc'), example: '', exampleTitle: t('cfgExample'),
    kv: ([[t('cfgStart'), sel.valueText], [t('cfgInFile'), file ? file.value : ''], [t('cfgKey'), sel.keyHtml.replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim() || t('cfgNoKey')], [t('cfgWhen'), t('cfgWhenMode')]] as Array<[string, string]>).filter(([, v]) => v),
    reset: sel.changed && file ? {label: t('cfgResetFile', {v: file.value}), attrs: {'data-modestart': sel.name + '|' + file.value}} : null, foot: ''} : null;
  const foot: ProFoot = {msg: S.toast || '', n: dirty ? 1 : 0, text: t('gDirty'), ok: t('cfgSaved'), undo: dirty ? {label: t('keysUndo').replace(/<[^>]+>/g, ''), attrs: {'data-keysundo': ''}} : null,
    save: dirty ? {label: t('keysSave').replace(/<[^>]+>/g, ''), attrs: {'data-keyssave': ''}} : null, lines: [], revertTip: ''};
  return {nav: {search: null, groups: [{label: t('cfgModes'), items: modeItems}, {label: t('cfgKeysGroup'), items: keyItems}]}, head, detail, foot, keys: g.part === 'keys'};
}

// "Other keys" as one list: every conflict once (by its key, with the actions that fight for it), the filter chips
function keyList(all: KeyBox[]): KeyList {
  const byKey = new Map<string, {keyHtml: string; names: string[]; edit: number | null}>();
  for (const b of all) for (const r of b.rows) if (r.st === 'clash') {
    const c = byKey.get(r.keyId) || {keyHtml: r.keyHtml, names: [], edit: r.edit};
    if (!c.names.includes(r.desc)) c.names.push(r.desc);
    if (c.edit === null) c.edit = r.edit;
    byKey.set(r.keyId, c);
  }
  const items = [...byKey.values()], f = (S.keysFilter as string) || 'all';
  const filter = f === 'clash' || f === 'all' || all.some(b => b.key === f) ? f : 'all';
  const filters = [{id: 'all', label: t('kfAll') + ' (' + all.reduce((n, b) => n + b.rows.length, 0) + ')', on: filter === 'all', bad: false},
    {id: 'clash', label: t('kfClash') + ' (' + items.length + ')', on: filter === 'clash', bad: items.length > 0}]
    .concat(all.map(b => ({id: b.key, label: b.title + ' (' + b.rows.length + ')', on: filter === b.key, bad: false})));
  const mote = all.find(b => b.key === 'mote');
  const shown = filter === 'all' ? all : filter === 'clash' ? [] : all.filter(b => b.key === filter);
  return {filters,
    mote: mote && shown.includes(mote) ? {box: mote, why: t('kMoteWhy'), open: filter === 'mote'} : null,
    conflicts: items.length && (filter === 'all' || filter === 'clash') ? {title: t('kcTitle', {n: items.length}), why: t('kcWhy'), chip: t('stClash'), items} : null,
    none: items.length ? '' : t('kcNone'),
    boxes: shown.filter(b => b !== mote)};
}

/** The Modes & keys part for the export shown */
export function keysView(d: LegacyExport): KeysView {
  const groups: Record<string, Array<[LegacyKey, number]>> = {};
  const modes = modesBox(d), inModes = new Set(modes.rows.map(m => m.name));
  // a row without a key (HUD only) is shown when the page changed it; the keys of other subjobs only on demand; a mode's
  // key is in the modes box
  let hidden = 0;
  const modeKeys: KeyRow[] = [];
  d.keys.forEach((k, i) => {
    if (!keyOf(k) && !fileKey(k) && !hasOverride(k)) return;
    if (k.state && inModes.has(k.state) && keyActive(k, d.sub)) { modeKeys.push(jobRow(d, k, i)); return; }
    if (!keyActive(k, d.sub) && !S.keysAll) { hidden++; return; }
    (groups[k.src] = groups[k.src] || []).push([k, i]);
  });
  const boxes: KeyBox[] = GROUPS.filter(g => groups[g]).map(g => ({key: g, cls: COLORS[g]!, title: t('keyGroups.' + g),
    meta: `${groups[g]!.length} · ${t('source.' + g).replace('{J}', S.job || '')}.lua`, rows: groups[g]!.map(([k, i]) => jobRow(d, k, i))}));
  boxes.push({key: 'mote', cls: 'g-caps', title: t('keyGroups.mote'), meta: `${MOTE_BINDS.length} · libs/Mote-Globals.lua`, rows: moteRows(d)});
  // the keys //gs c tb bound for this game session (saved/temp_binds.lua)
  const temp = Object.entries(d.temp_binds || {}).sort();
  if (temp.length) boxes.push({key: 'temp', cls: 'g-res', title: t('keyGroups.temp'), meta: `${temp.length} · saved/temp_binds.lua`,
    rows: temp.map(([key, cmd]) => ({keyHtml: keyLabel(key), desc: '', code: cmd, help: '', sub: '', edit: null, changed: false,
      ...state('ok', ''), keyId: key.toLowerCase()}))});
  const dirty = !!S.keyDirty[S.char] || !!S.modeDirty[S.char];
  const game = gameOf(modes);
  const list = keyList(modeKeys.length ? [{key: 'modes', cls: 'g-def', title: t('kgModes'), meta: String(modeKeys.length), rows: modeKeys} as KeyBox].concat(boxes) : boxes);
  return {
    bar: {others: hidden || S.keysAll ? {title: t('ttKeysAll'), textHtml: S.keysAll ? t('keysHideOther', {s: d.sub}) : t('keysShowOther', {n: hidden})} : null},
    game,
    pro: proOf(game, modes, dirty, keysShown(d).length, list.conflicts ? list.conflicts.items.length : 0),
    list,
    change: {text: t('kChange'), tip: t('kChangeTip'), none: t('kNoKey')},
    credit: iconCredit()
  };
}
