// GearSwap Atelier · the windows over the page (the old page's showDialog, trial.js): the one shown, and a counter its
// window redraws on. A window is drawn anew at each opening, as the old page's were (its fields, its scroll start
// again). One component, mounted once in a box of its own put in #overlay at each opening (closeOverlay, core.js,
// empties #overlay: the box leaves with the rest). A window's body is the old page's HTML, or one of the windows moved
// to Svelte (Compare: compare.ts; a slot's pieces: gearpick.ts; the target picker: target.ts; the party's pickers: partypick.ts; pushing, deleting, adding a set: pushview.ts).
//
// @file    atelier/src/screens/dialogs/dialogs.svelte.ts
// @author  ejouanchicot
import {flushSync} from 'svelte';
import type {CompareView} from './compare';
import type {GearPickView} from './gearpick';
import type {TargetView} from './target';
import type {PartyPickView} from './partypick';
import type {PushView} from './pushview';

export interface DialogSpec { cls: string; titleHtml: string; bodyHtml?: string; buttonsHtml?: string; compare?: CompareView; gearPick?: GearPickView; target?: TargetView; partyPick?: PartyPickView; push?: PushView }

export const dialogState = $state({version: 0, opened: 0});
let current: DialogSpec | null = null;

/** The window shown */
export const currentDialog = (): DialogSpec | null => current;

/** A window opened: drawn now (what the old page does next may look into it: a search field focused) */
export function dialogShow(d: DialogSpec, box: HTMLElement): void {
  current = d;
  dialogState.opened++;
  dialogState.version++;
  flushSync();
  const ov = document.getElementById('overlay');
  if (ov) { ov.replaceChildren(box); ov.hidden = false; }
}

/** The window shown changed (typed in its search, a filter): drawn again in place, its fields keep their caret */
export function dialogUpdate(d: DialogSpec): void {
  current = d;
  dialogState.version++;
  flushSync();
}
