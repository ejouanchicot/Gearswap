// GearSwap Atelier · the search window's state: the search shown (the old page's S._optRun, kept here after the search
// ends, for its result) and a counter its window redraws on. The optimizer (optimizer.js, opt_all.js, moogle.js) tells
// it when the search changed through window.ATELIER_RUN; the window is one Svelte component mounted once in a box of
// its own, moved by the old page between #overlay and the box of hidden searches (core.js searchPark).
//
// @file    atelier/src/screens/optimizer/run.svelte.ts
// @author  ejouanchicot
import {flushSync} from 'svelte';

export const runState = $state({version: 0});
let current: LegacyAny = null;

/** The search shown (S._optRun when it was opened) */
export const currentRun = (): LegacyAny => current;

/** The search changed: its window drawn again now (what the old page does next reads the window: the moogle) */
export function runChanged(): void {
  runState.version++;
  flushSync();
}

/** A search opened: its window, in place of whatever the overlay held */
export function runOpen(R: LegacyAny, box: HTMLElement): void {
  current = R;
  runChanged();
  const ov = document.getElementById('overlay');
  if (ov) { ov.replaceChildren(box); ov.hidden = false; }
}
