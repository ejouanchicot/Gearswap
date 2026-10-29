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
  keyHtml: string; clash: string; desc: string; was: string | null; note: string; help: string;
  sub: string; edit: number | null; other: boolean; changed: boolean; code?: string;
  /** Mote's rows say what a key does, its mode's help, then what took the key (the job's rows: the note first) */
  helpFirst?: boolean;
}
export interface KeyBox { key: string; cls: string; title: string; meta: string; rows: KeyRow[] }
/** A mode: its values (the start one, the file's), its key and the button that changes it */
export interface ModeRow {
  name: string; title: string; help: string; common: boolean; changed: boolean;
  values: Array<{value: string; start: boolean; file: boolean; tip: string}>; keyHtml: string; edit: number | null;
}
export interface ModesBox { title: string; meta: string; hint: string; commonText: string; rows: ModeRow[]; away: null | {title: string; rows: ModeRow[]} }
export interface KeysView {
  bar: {dirty: boolean; textHtml: string; others: null | {title: string; textHtml: string}; undoHtml: string; saveHtml: string};
  toast: string;
  modes: ModesBox;
  boxes: KeyBox[];
  /** "was" before a changed key's file key; the edit button's tooltip (the old page's HTML texts) */
  wasHtml: string;
  editHtml: string;
}

const GROUPS = ['job', 'custom', 'combat', 'treasure', 'common'];
const COLORS: Record<string, string> = {job: 'g-def', custom: 'g-attr', combat: 'g-off', treasure: 'g-res', common: 'g-other'};

const helpOf = (state: string | undefined): string => state ? stateHelp(state) : '';

function jobRow(d: LegacyExport, k: LegacyKey, i: number): KeyRow {
  const key = keyOf(k), file = fileKey(k), changed = !!k.id && key !== file;
  const beaten = keyBeatenBy(d, k), cond = keyCondition(k);
  const note = k.visible_now === false ? t('keyHiddenNow') : beaten ? t('keyYieldsTo', {d: beaten.desc}) : '';
  return {keyHtml: keyLabel(key), clash: keyClash(d, k, key).length ? t('keyClashShort') : '', desc: keyDescText(k.desc),
    was: changed ? keyLabel(file) : null, note: [note, cond].filter(Boolean).join(' · '), help: helpOf(k.state),
    sub: k.subjob ? '/' + k.subjob : '', edit: k.id ? i : null, other: !(keyActive(k, d.sub) && !beaten), changed};
}

// Mote's keys: a key that changes a mode is said by the mode's name as the game shows it, with what the mode does
function moteRows(d: LegacyExport): KeyRow[] {
  const modeName = (st: string) => (d.modes.find(m => m.name === st) || {desc: ''}).desc || st;
  return MOTE_BINDS.map(([key, st, what]) => {
    const by = moteTakenBy(d, key);
    return {keyHtml: keyLabel(key), clash: '', desc: st ? t('keyMoteCycle', {m: modeName(st)}) : (S.lang !== 'en' && MOTE_DESC_FR[what]) || what,
      was: null, note: by ? t('keyTakenBy', {d: by.desc}) : '', help: helpOf(st), sub: '', edit: null, other: !!by, changed: false, helpFirst: true};
  });
}

// a mode's row: its values with the start one and the file's marked, its key (the job's row that cycles it, editable)
function modeRow(d: LegacyExport, m: LegacyMode, keyOfSt: Record<string, string>): ModeRow {
  const start = String(modeStart(d, m)).toLowerCase(), file = String(modeFileStart(d, m)).toLowerCase();
  const i = d.keys.findIndex(k => k.state === m.name && !!k.id && keyActive(k, d.sub));
  return {name: m.name, title: m.desc || m.name, help: stateHelp(m.name), common: COMMON_MODES.has(m.name), changed: start !== file,
    values: m.values.map(v => ({value: v, start: v.toLowerCase() === start, file: v.toLowerCase() === file && start !== file,
      tip: v.toLowerCase() === start ? t('modeStartTip') : v.toLowerCase() === file ? t('modeFileTip') : t('modePickTip')})),
    keyHtml: keyLabel(keyOfSt[m.name]), edit: i >= 0 ? i : null};
}

function modesBox(d: LegacyExport): ModesBox {
  const keyOfSt = keyOfState(d);
  const all = d.modes.filter(m => !modeHidden(m) && !/^[A-Z]{3}Song\d$/.test(m.name));
  const away = all.filter(m => stateElsewhere(d, m.name)), shown = all.filter(m => !away.includes(m));
  return {title: t('modesTitle'), meta: String(shown.length), hint: t('modesHint'), commonText: t('modeCommon'), rows: shown.map(m => modeRow(d, m, keyOfSt)),
    away: away.length ? {title: t('modesAway', {s: d.sub}), rows: away.map(m => modeRow(d, m, {}))} : null};
}

/** The Modes & keys part for the export shown */
export function keysView(d: LegacyExport): KeysView {
  const groups: Record<string, Array<[LegacyKey, number]>> = {};
  const modes = modesBox(d), inModes = new Set(modes.rows.map(m => m.name));
  // a row without a key (HUD only) is shown when the page changed it; the keys of other subjobs only on demand; a mode's
  // key is in the modes box
  let hidden = 0;
  d.keys.forEach((k, i) => {
    if (!keyOf(k) && !fileKey(k) && !hasOverride(k)) return;
    if (k.state && inModes.has(k.state) && keyActive(k, d.sub)) return;
    if (!keyActive(k, d.sub) && !S.keysAll) { hidden++; return; }
    (groups[k.src] = groups[k.src] || []).push([k, i]);
  });
  const boxes: KeyBox[] = GROUPS.filter(g => groups[g]).map(g => ({key: g, cls: COLORS[g]!, title: t('keyGroups.' + g),
    meta: `${groups[g]!.length} · ${t('source.' + g).replace('{J}', S.job || '')}.lua`, rows: groups[g]!.map(([k, i]) => jobRow(d, k, i))}));
  boxes.push({key: 'mote', cls: 'g-caps', title: t('keyGroups.mote'), meta: `${MOTE_BINDS.length} · libs/Mote-Globals.lua`, rows: moteRows(d)});
  // the keys //gs c tb bound for this game session (saved/temp_binds.lua)
  const temp = Object.entries(d.temp_binds || {}).sort();
  if (temp.length) boxes.push({key: 'temp', cls: 'g-res', title: t('keyGroups.temp'), meta: `${temp.length} · saved/temp_binds.lua`,
    rows: temp.map(([key, cmd]) => ({keyHtml: keyLabel(key), clash: '', desc: '', code: cmd, was: null, note: '', help: '', sub: '', edit: null, other: false, changed: false}))});
  const changes = Object.values(keyOverrides()).reduce((n, m) => n + Object.keys(m).length, 0), mchanges = modeChanges();
  const noid = !d.keys.some(k => k.id), kdirty = !!S.keyDirty[S.char], mdirty = !!S.modeDirty[S.char], dirty = kdirty || mdirty;
  const said = [mdirty ? t('modesDirty') : mchanges ? t('modesSaved', {n: mchanges}) : '',
    kdirty ? t('keysDirty') : noid ? t('keysNoId') : changes ? t('keysSaved', {n: changes}) : ''].filter(Boolean).join(' ');
  return {
    bar: {dirty, textHtml: said || t('keysHint'),
      others: hidden || S.keysAll ? {title: t('ttKeysAll'), textHtml: S.keysAll ? t('keysHideOther', {s: d.sub}) : t('keysShowOther', {n: hidden})} : null,
      undoHtml: t('keysUndo'), saveHtml: t('keysSave')},
    toast: S.toast || '',
    modes,
    boxes,
    wasHtml: t('keyWas'),
    editHtml: t('keyEdit')
  };
}
