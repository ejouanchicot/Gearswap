// GearSwap Atelier · loads the old page (atelier/app/) into the Svelte application: its styles first (the page is
// drawn styled), then its scripts in their order. Each file is asked with ?v=<time>: a browser keeps an older copy
// of a file opened from the disk otherwise. A file that fails (atelier/index.js before the first //gs c atelier)
// does not stop the others, as with the old page's <script> tags.
//
// @file    atelier/src/legacy/load.ts
// @author  ejouanchicot
import {LEGACY_DATA, LEGACY_SCRIPTS, LEGACY_STYLES} from './files';

const stamp = (): string => '?v=' + Date.now();

function loadStyle(href: string): Promise<void> {
  return new Promise(done => {
    const el = document.createElement('link');
    el.rel = 'stylesheet';
    el.href = href;
    el.onload = el.onerror = () => done();
    document.head.appendChild(el);
  });
}

// added together, run one after the other in this order (async off), each fetched as soon as it is added
function loadScriptsInOrder(srcs: readonly string[]): Promise<void> {
  return new Promise(done => {
    if (!srcs.length) { done(); return; }
    let left = srcs.length;
    for (const src of srcs) {
      const el = document.createElement('script');
      el.src = src;
      el.charset = 'utf-8';
      el.async = false;
      el.onload = el.onerror = () => { if (--left === 0) done(); };
      document.head.appendChild(el);
    }
  });
}

/** The old page, styled then running; resolves once its last script (events.js) has run */
export async function loadLegacy(): Promise<void> {
  const v = stamp();
  await Promise.all(LEGACY_STYLES.map(name => loadStyle(`atelier/app/css/${name}.css${v}`)));
  await loadScriptsInOrder(LEGACY_DATA.map(src => src + v).concat(LEGACY_SCRIPTS.map(name => `atelier/app/js/${name}.js${v}`)));
}
