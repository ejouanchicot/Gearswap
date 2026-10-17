// GearSwap Atelier · the bridge between the page and the outside: the tests (scripts/atelier/*.js under Puppeteer) read
// which build the page is and wait for it to be drawn; the old page calls redraw() after each of its redraws. While
// the old page runs inside the application its globals (S, render, optimizeWs...) stay what the tests drive; a screen
// moved to Svelte gives the tests its commands here.
//
// @file    atelier/src/bridge.ts
// @author  ejouanchicot
import {legacyRedrawn} from './stores/legacy.svelte';

export interface AtelierBridge {
  /** the hash of the sources the page was built from (meta atelier-build, atelier/build/hash.mjs) */
  build: string;
  /** true once the old page's scripts have run */
  loaded: boolean;
  /** kept once the old page's scripts have run */
  ready: Promise<void>;
  /** called by the old page after each redraw (atelier/app/js/sets_view.js render): the Svelte screens follow */
  redraw: () => void;
}

declare global {
  interface Window { __atelier: AtelierBridge }
}

let resolveReady: () => void = () => {};

/** Put the bridge on window, before anything else of the page runs */
export function openBridge(): void {
  const meta = document.querySelector('meta[name="atelier-build"]');
  window.__atelier = {
    build: meta ? meta.getAttribute('content') || '' : 'dev',
    loaded: false,
    ready: new Promise<void>(done => { resolveReady = done; }),
    redraw: legacyRedrawn
  };
}

/** The old page has run: the tests may start */
export function markLoaded(): void {
  window.__atelier.loaded = true;
  resolveReady();
}
