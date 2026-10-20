// ============================================================================
// Foreign GearSwap converter - one character's gear file (his 0_AugGear tables)
// ============================================================================
// From foreign_eval.lua run once per job on a file that only includes his shared
// setup (the "gear" field: every piece of the tables his 0_AugGear* files set,
// with its Lua path), writes the gear file his converted sets include
// (<Character>/_common/sets/0_AugGear_<Character>.lua): pure data, his own table
// names, each piece defined once.
//   - at the top, each piece most jobs set, with the value most of them have
//   - in an `if player.main_job == '<JOB>'` block, what that job sets otherwise
//     or alone (AF / RELIC / EMPY, the JSE capes, a piece his job read from
//     another gear file)
// Every job reads exactly the pieces his own setup gave it; a piece only
// another job sets may also be there, unread.
// write_sets.js then names these pieces by their path in the sets (HERC.Feet.TA),
// so a piece changed here changes in every job.
//
//   node write_gear.js <Character> <out.lua> <eval.json>...      (one eval per job)
//
// @file    scripts/convert/write_gear.js
// @author  ejouanchicot
// @version 1.0
// @date    Created: 2026-10-16
// ============================================================================
'use strict';
const fs = require('fs');

const [player, outPath, ...evals] = process.argv.slice(2);
const byPath = new Map();      // path -> Map(job -> piece json)
const jobs = [];
for (const f of evals) {
  const d = JSON.parse(fs.readFileSync(f, 'utf8'));
  const errors = Array.isArray(d.errors) ? d.errors : Object.values(d.errors || {});
  // a file read leniently failed where it fails in game too: its gear tables are still the ones it built
  if (errors.length && !d.lenient) throw new Error(`${f}: ${errors[0]}`);
  jobs.push(d.job);
  for (const g of d.gear || []) {
    if (!byPath.has(g.path)) byPath.set(g.path, new Map());
    byPath.get(g.path).set(d.job, JSON.stringify(g.piece));
  }
}
jobs.sort();

function luaStr(s) {
  if (!s.includes("'")) return "'" + s.replace(/\\/g, '\\\\') + "'";
  if (!s.includes('"')) return '"' + s.replace(/\\/g, '\\\\') + '"';
  return "'" + s.replace(/\\/g, '\\\\').replace(/'/g, "\\'") + "'";
}
function pieceLua(json) {
  const p = JSON.parse(json);
  if (p === 'empty') return 'empty';
  if (typeof p === 'string') return luaStr(p);
  const parts = [`name = ${luaStr(p.name)}`];
  if (p.augments) parts.push(`augments = {${p.augments.map(luaStr).join(', ')}}`);
  if (p.bag) parts.push(`bag = ${luaStr(p.bag)}`);
  if (p.priority !== undefined) parts.push(`priority = ${p.priority}`);
  return '{ ' + parts.join(', ') + ' }';
}
// 'HERC.Feet["Fast Cast"]' -> ['HERC', '.Feet', '["Fast Cast"]']
function segments(path) {
  const m = path.match(/^[A-Za-z_]\w*/);
  const out = [m[0]];
  const re = /\.[A-Za-z_]\w*|\[(?:"(?:[^"\\]|\\.)*"|\d+)\]/g;
  re.lastIndex = m[0].length;
  let s;
  while ((s = re.exec(path))) out.push(s[0]);
  return out;
}
// the tables a list of leaves needs, then the leaves, in path order
function block(paths, valueOf, indent, guarded) {
  const lines = [], made = new Set();
  for (const path of paths) {
    const segs = segments(path);
    for (let n = 1; n < segs.length; n++) {
      const t = segs.slice(0, n).join('');
      if (made.has(t)) continue;
      made.add(t);
      lines.push(guarded || n > 1 ? `${indent}${t} = ${t} or {}` : `${indent}${t} = {}`);
    }
    lines.push(`${indent}${path} = ${pieceLua(valueOf(path))}`);
  }
  return lines;
}
const order = (a, b) => a.localeCompare(b, 'en');
// a piece's value at the top: the one most of the jobs that set it have (a job that does not set
// it gets it too, unread); AF / RELIC / EMPY and the job's capes, set by a few jobs each, stay in the blocks
const topValue = new Map();
for (const [p, v] of byPath) {
  const counts = new Map();
  for (const j of v.values()) counts.set(j, (counts.get(j) || 0) + 1);
  const [best, n] = [...counts].sort((a, b) => b[1] - a[1])[0];
  if (n * 2 > jobs.length) topValue.set(p, best);
}
const common = [...topValue.keys()].sort(order);
const differs = (p, job) => byPath.get(p).has(job) && byPath.get(p).get(job) !== topValue.get(p);

const today = new Date().toISOString().slice(0, 10);
const out = [
  '---============================================================================',
  `--- AugGear - ${player}: the gear tables his sets name`,
  '---============================================================================',
  `--- His own tables (AF / RELIC / EMPY, capes, HERC, CHIR...), under his names, as his`,
  `--- 0_AugGear files built them for this character (converted by scripts/convert on ${today}).`,
  '--- His sets name these pieces (HERC.Feet.TA, CORCape.TP): a piece changed here',
  '--- changes in every job. Pieces set for one job only (AF / RELIC / EMPY, the',
  "--- job's own capes) are in that job's block below.",
  '---',
  `--- @file    _common/sets/0_AugGear_${player}.lua`,
  '--- @author  ejouanchicot',
  '--- @version 2.0',
  `--- @date    Created: 2026-09-25 | Updated: ${today} (every job, from his 0_AugGear)`,
  '---============================================================================',
  '',
  ...block(common, p => topValue.get(p), '', false),
  '',
];
for (const job of jobs) {
  const own = [...byPath.keys()].filter(p => differs(p, job)).sort(order);
  if (!own.length) continue;
  out.push(`if player and player.main_job == '${job}' then`, ...block(own, p => byPath.get(p).get(job), '    ', true), 'end', '');
}
fs.writeFileSync(outPath, out.join('\n'));
const byJob = jobs.reduce((n, job) => n + [...byPath.keys()].filter(p => differs(p, job)).length, 0);
console.log(`${player}: ${common.length} pieces at the top, ${byJob} set by job, ${jobs.length} jobs`);
