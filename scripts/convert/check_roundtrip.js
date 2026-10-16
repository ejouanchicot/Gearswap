// ============================================================================
// Round trip check - the written sets file builds what the foreign file built
// ============================================================================
// Compares the pieces write_sets.js expects under each path (its report's
// `expected`) with what roundtrip.lua read from the written file: a missing
// set, a slot missing, extra or different is a failure. Paths are compared as
// keys, so sets.a.b and sets["a"]["b"] are the same set.
//
//   node check_roundtrip.js <report.json> <roundtrip.json>
//
// @file    scripts/convert/check_roundtrip.js
// @author  ejouanchicot
// @version 1.0
// @date    Created: 2026-10-16
// ============================================================================
'use strict';
const fs = require('fs');
const [reportPath, rtPath] = process.argv.slice(2);
const report = JSON.parse(fs.readFileSync(reportPath, 'utf8'));
const rt = JSON.parse(fs.readFileSync(rtPath, 'utf8'));

function keys(p) {
  const out = [];
  let i = 4;
  while (i < p.length) {
    if (p[i] === '.') { const m = /^\.([A-Za-z_]\w*)/.exec(p.slice(i)); out.push(m[1]); i += m[0].length; }
    else { const q = p[i + 1]; let j = i + 2, s = ''; while (p[j] !== q) { if (p[j] === '\\') j++; s += p[j]; j++; } out.push(s); i = j + 2; }
  }
  return JSON.stringify(out);
}
const got = new Map();
for (const s of rt.sets) got.set(keys(s.path), s);
const resolve = s => { while (s && s.same_as) s = got.get(keys(s.same_as)); return s; };

// set_dump.lua writes an empty list as {}
const list = x => Array.isArray(x) ? x : [];
const fails = list(rt.errors).map(e => 'load: ' + e);
for (const [path, want] of Object.entries(report.expected)) {
  const s = resolve(got.get(keys(path)));
  if (!s) { fails.push(`${path}: not built`); continue; }
  const have = s.pieces || {};
  for (const slot of new Set([...Object.keys(want || {}), ...Object.keys(have)])) {
    const a = JSON.stringify((want || {})[slot]), b = JSON.stringify(have[slot]);
    if (a !== b) fails.push(`${path}.${slot}: wanted ${a}, built ${b}`);
  }
}
for (const f of fails) console.log('FAIL ' + f);
console.log(fails.length ? `${fails.length} differences` : `round trip ok: ${Object.keys(report.expected).length} sets, same pieces`);
process.exit(fails.length ? 1 : 0);
