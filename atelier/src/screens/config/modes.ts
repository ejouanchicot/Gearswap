// GearSwap Atelier · the Modes and Functions parts of the job's settings: every mode of the job with its values (the
// one at the export marked) and its key, split into the modes with a key, the others and those of other subjobs;
// the on / off switches in two columns. The rules are the old page's renderModes (atelier/app/js/keys.js) and
// renderFunctions (sets_view.js). A field ending in Html is one of the old page's texts it wrote unescaped.
//
// @file    atelier/src/screens/config/modes.ts
// @author  ejouanchicot

export interface ModeRow { name: string; title: string; help: string; values: Array<{value: string; current: boolean}>; keyHtml: string; on?: boolean }
export interface ModeBox { key: string; cls: string; title: string; meta: string; rows: ModeRow[] }
export interface ModesView { barHtml: string; boxes: ModeBox[] }
export interface FunctionsView { barHtml: string; title: string; meta: string; columns: ModeRow[][]; onHtml: string; offHtml: string }

function rowOf(m: LegacyMode, keyOf: Record<string, string>): ModeRow {
  return {name: m.name, title: m.desc || m.name, help: stateHelp(m.name), values: m.values.map(v => ({value: v, current: v === m.current})), keyHtml: keyLabel(keyOf[m.name])};
}

/** The Modes part for the export shown */
export function modesView(d: LegacyExport): ModesView {
  const keyOf = keyOfState(d);
  const all = d.modes.filter(m => !modeHidden(m) && !/^[A-Z]{3}Song\d$/.test(m.name));
  const away = all.filter(m => stateElsewhere(d, m.name)), shown = all.filter(m => !away.includes(m));
  const keyed = shown.filter(m => keyOf[m.name]), other = shown.filter(m => !keyOf[m.name]);
  const box = (key: string, cls: string, title: string, list: LegacyMode[], keys: Record<string, string>): ModeBox =>
    ({key, cls, title, meta: String(list.length), rows: list.map(m => rowOf(m, keys))});
  return {
    barHtml: t('atLoad', {at: esc(d.at || '—')}),
    boxes: [box('keyed', 'g-attr', t('modesKeyed'), keyed, keyOf)]
      .concat(other.length ? [box('other', 'g-other', t('modesOther'), other, keyOf)] : [])
      .concat(away.length ? [box('away', 'g-caps', t('modesElsewhere', {s: esc(d.sub)}), away, {})] : [])
  };
}

const isSwitch = (m: LegacyMode) => m.values.length === 2 &&
  ((m.values.includes('on') && m.values.includes('off')) || (m.values.includes('On') && m.values.includes('Off')));

/** The Functions part for the export shown: the switches fill the left column first */
export function functionsView(d: LegacyExport): FunctionsView {
  const keyOf = keyOfState(d);
  const rows = d.modes.filter(m => isSwitch(m) && !modeHidden(m) && !stateElsewhere(d, m.name))
    .map(m => ({...rowOf(m, keyOf), on: m.current.toLowerCase() === 'on'}));
  const half = Math.ceil(rows.length / 2);
  return {barHtml: t('fnHint', {at: esc(d.at || '—')}), title: t('sectionsFunctions'), meta: String(rows.length),
    columns: [rows.slice(0, half), rows.slice(half)], onHtml: t('on'), offHtml: t('off')};
}
