// GearSwap Atelier · the hash of the page's sources: written into the built page by vite.config.mts, compared by
// scripts/atelier/atelier_build_check.js (a change in src/ without `npm run build` leaves the old page in place).
// What counts: every file of src/, the build's configuration and the locked versions of its tools.
//
// @file    atelier/build/hash.mjs
// @author  ejouanchicot
import {createHash} from 'node:crypto';
import {readdirSync, readFileSync, statSync} from 'node:fs';
import {dirname, join, relative} from 'node:path';
import {fileURLToPath} from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const FILES = ['vite.config.mts', 'svelte.config.mjs', 'build/hash.mjs', 'package.json', 'package-lock.json', 'tsconfig.json'];

function walk(dir, out) {
  for (const name of readdirSync(dir).sort()) {
    const path = join(dir, name);
    if (statSync(path).isDirectory()) walk(path, out); else out.push(path);
  }
  return out;
}

/** @returns {string} the first 16 hex digits of the SHA-256 of the sources (paths and contents, line ends ignored) */
export function sourcesHash() {
  const hash = createHash('sha256');
  for (const path of walk(join(ROOT, 'src'), []).concat(FILES.map(f => join(ROOT, f)))) {
    hash.update(relative(ROOT, path).replace(/\\/g, '/') + '\n');
    hash.update(readFileSync(path, 'utf8').replace(/\r\n/g, '\n'));
  }
  return hash.digest('hex').slice(0, 16);
}
