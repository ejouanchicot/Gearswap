// GearSwap Atelier · the frame of the job's settings, its parts' shapes (ProFrame.svelte; SPEC
// notes/docs-perso/config-pro-2026-10-30): the categories on the left, the detail on the right, the bar of the changes.
//
// @file    atelier/src/screens/config/pro.ts
// @author  ejouanchicot

export interface ProNavItem { id: string; iconHtml: string; name: string; count: string; dot: boolean; current: boolean; attr: Record<string, string> }
export interface ProNav { search: null | {value: string; placeholder: string; id: string; clear: string}; groups: Array<{label: string; items: ProNavItem[]}> }
export interface ProDetail { iconHtml: string; title: string; tag: string; what: string; example: string; exampleTitle: string; kv: Array<[string, string]>;
  reset: null | {label: string; attrs: Record<string, string>}; foot: string }
export interface ProFoot { msg?: string; n: number; text: string; ok: string; undo: null | {label: string; attrs: Record<string, string>}; save: null | {label: string; attrs: Record<string, string>};
  lines: Array<{title: string; was: string; now: string; revert: Record<string, string>}>; revertTip: string }

/** The icons' authors, shown under the categories of the three parts: the game-icons.net icons are CC BY 3.0, which
 *  asks for it (game_icons.js GAME_ICONS.credit; the words: keys.js gCredit) */
export const iconCredit = (): string => t('gCredit', {c: GAME_ICONS.credit});
