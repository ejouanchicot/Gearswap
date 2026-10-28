// GearSwap Atelier · how the page is built: src/ (TypeScript + Svelte 5) into ONE file, atelier/index.html, that a
// browser opens from the disk (file://, no server: the page's scripts and styles are inside it). The files the page
// reads at run time stay outside it, as before: the exports, the live link, the engines, what is left of the old page,
// app/ (its state, data and clicks; src/README.md).
//   npm run build     after any change in src/ (scripts/atelier/atelier_build_check.js says when it was forgotten)
// The built page carries the hash of its sources (meta atelier-build), which that check compares.
//
// @file    atelier/vite.config.mts
// @author  ejouanchicot
import {defineConfig, type Plugin} from 'vite';
import {svelte} from '@sveltejs/vite-plugin-svelte';
import {viteSingleFile} from 'vite-plugin-singlefile';
import {sourcesHash} from './build/hash.mjs';

// the hash of the sources, written into the built page
function buildHash(): Plugin {
  return {
    name: 'atelier-build-hash',
    transformIndexHtml(html) {
      return html.replace('</head>', `<meta name="atelier-build" content="${sourcesHash()}">\n</head>`);
    }
  };
}

export default defineConfig({
  root: 'src',
  publicDir: false,
  // svelte.config.mjs gives the plugin its settings
  plugins: [svelte(), viteSingleFile(), buildHash()],
  build: {
    // the built page is atelier/index.html, beside the files it reads (never empty the folder: it holds them)
    outDir: '..',
    emptyOutDir: false,
    target: 'es2022',
    // one file with no other module to preload: the polyfill for it is not needed
    modulePreload: {polyfill: false},
    reportCompressedSize: false
  }
});
