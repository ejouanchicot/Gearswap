// GearSwap Atelier · the bridge the tests read (scripts/atelier/*.js under Puppeteer): which build the page is, and a
// promise kept once the page is drawn. While the old page runs inside the application its globals (S, render,
// optimizeWs...) stay what the tests drive; a screen moved to Svelte gives the tests its commands here.
//
// @file    atelier/src/bridge.ts
// @author  ejouanchicot

export interface AtelierBridge {
  /** the hash of the sources the page was built from (meta atelier-build, atelier/build/hash.js) */
  build: string;
  /** true once the old page's scripts have run */
  loaded: boolean;
  /** kept once the old page's scripts have run */
  ready: Promise<void>;
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
    ready: new Promise<void>(done => { resolveReady = done; })
  };
}

/** The old page has run: the tests may start */
export function markLoaded(): void {
  window.__atelier.loaded = true;
  resolveReady();
}
