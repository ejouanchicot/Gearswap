// GearSwap Atelier · the old page's redraws, seen by the Svelte screens. The old page keeps its state in its globals
// (S, DATA...) and draws everything again after each change (atelier/app/js/sets_view.js render); it then calls
// window.__atelier.redraw() (bridge.ts), which moves `version` on: a screen that reads the old state inside a
// $derived of `legacy.version` is drawn again with it, at once (flushSync): the old page puts back the focus, the
// folded blocks and the scroll right after, the Svelte screens' included.
//
// @file    atelier/src/stores/legacy.svelte.ts
// @author  ejouanchicot
import {flushSync} from 'svelte';

export const legacy = $state({version: 0});

/** The old page drew itself again: the screens that read its state follow */
export function legacyRedrawn(): void {
  legacy.version++;
  flushSync();
}
