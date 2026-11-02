// GearSwap Atelier · a weapon cycle edited in the job's settings (Modes & keys, the weapon mode chosen: MainWeapon,
// SubWeapon...): its weapons in the order its key goes through them, the one worn on load, the ones to add. The rules
// and the writes are the old page's (app/js/weapon_cycles.js); CycleEdit.svelte draws it and drags the tiles.
//
// @file    atelier/src/screens/config/cycle.ts
// @author  ejouanchicot

export interface CycleTile { value: string; item: string; iconHtml: string; tag: string; warn: boolean; start: boolean; first: boolean; last: boolean }
export interface CyclePick { name: string; iconHtml: string; back: boolean; tip: string }
export interface CycleView {
  mode: string; title: string; count: string; loop: string; note: string;
  /** "File order": only when the Atelier changed the order */
  reset: null | {label: string; tip: string};
  tiles: CycleTile[]; picks: CyclePick[];
  add: string; addPh: string; none: string; backTag: string;
  tips: {up: string; down: string; out: string};
}

/** The cycle of a weapon mode (null for another mode); key: the mode's key as text ('' when it has none) */
export function cycleView(d: LegacyExport, mode: string, key: string): CycleView | null {
  if (typeof wcCycle !== 'function') return null;
  const c = wcCycle(mode);
  if (!c) return null;
  const m = d.modes.find(x => x.name === mode), start = m ? String(modeStart(d, m)) : c.values[0];
  const tiles = c.values.map((v, i): CycleTile => {
    const item = wcItemOf(c, v), path = wcPath(v), set = wcSetAt(path), empty = !!set && !Object.keys(set.pieces || {}).length;
    const on = v === start;
    return {value: v, item, iconHtml: itemIco(item), start: on, first: i === 0, last: i === c.values.length - 1,
      tag: on ? t('wcyStart') : !set ? t('wcyNoSet') : empty ? t('wcyEmpty') : '', warn: !on && (!set || empty)};
  });
  const picks = wcChoices(mode).map((p): CyclePick => ({name: p.name, iconHtml: itemIco(p.name), back: p.back,
    tip: p.back ? t('wcyBackTip') : wcSetAt(wcPath(p.value)) ? '' : t('wcyNewSet')}));
  return {mode, title: t('wcyTitle', {m: c.desc}), count: key ? t('wcyCount', {n: c.values.length, k: key}) : t('wcyCountNoKey', {n: c.values.length}),
    loop: t('wcyLoop'), note: t('wcyNote'), reset: wcOrder(mode).length ? {label: t('wcyReset'), tip: t('wcyResetTip')} : null,
    tiles, picks, add: t('wcyAdd'), addPh: t('wcyAddPh'), none: t('wcyNone'), backTag: t('wcyBack'),
    tips: {up: t('wcyUp'), down: t('wcyDown'), out: c.values.length < 2 ? t('wcyLast') : t('wcyOut')}};
}
