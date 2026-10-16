// ============================================================================
// Compare probes - what his file equipped vs what ours equips
// ============================================================================
// For every scenario both probes played: each slot worn after precast (and
// after midcast for spells), his piece against ours. A piece is compared by
// name (case-insensitive) and augments; a slot one side leaves alone is "-".
// A difference the job's map accepts (map.accept: {label, line, why}, both
// regular expressions, line matched against "pre waist: A -> B" or the
// cancel text) is counted under its reason instead. Prints what is left,
// then the accepted reasons, then a count.
//
//   node compare_probes.js <his_probe.json> <our_probe.json> [map.js|-] [--all]
//
// @file    scripts/convert/compare_probes.js
// @author  ejouanchicot
// @version 1.1
// @date    Created: 2026-10-16
// ============================================================================
'use strict';
const fs = require('fs');
const [hisPath, ourPath, mapPath, flag] = process.argv.slice(2);
const his = JSON.parse(fs.readFileSync(hisPath, 'utf8'));
const ours = JSON.parse(fs.readFileSync(ourPath, 'utf8'));
const map = mapPath && mapPath !== '-' && fs.existsSync(mapPath) ? require(require('path').resolve(mapPath)) : {};
// what our shared systems do on every character (maps/accept_common.js), then the job's own
const common = require('./maps/accept_common.js');
const accepts = common.concat(map.accept || []).map(a => ({label: new RegExp(a.label || '.'), line: new RegExp(a.line || '.'), why: a.why}));

const SLOTS = ['main', 'sub', 'range', 'ammo', 'head', 'neck', 'left_ear', 'right_ear', 'body', 'hands', 'left_ring',
  'right_ring', 'back', 'waist', 'legs', 'feet'];
const norm = p => p === undefined ? '-' : typeof p === 'string' ? p.toLowerCase()
  : (p.name || '').toLowerCase() + (p.augments ? ' {' + p.augments.join(', ') + '}' : '');
const show = p => p === undefined ? '-' : typeof p === 'string' ? p : p.name + (p.augments ? ' {' + p.augments.join(', ') + '}' : '');

let same = 0, differ = 0, errors = 0, accepted = 0;
const lines = [], reasons = new Map();
// the lines of a scenario no accept rule covers; the others counted under their reason
function unaccepted(label, diffs) {
  const left = [];
  for (const d of diffs) {
    const a = accepts.find(r => r.label.test(label) && r.line.test(d));
    if (a) reasons.set(a.why, (reasons.get(a.why) || new Set()).add(label));
    else left.push(d);
  }
  return left;
}
for (const label of Object.keys(his).sort()) {
  const a = his[label], b = ours[label];
  if (!b) { lines.push(`MISSING ${label}: not played on our side`); differ++; continue; }
  if (a.error || b.error) {
    errors++;
    lines.push(`ERROR ${label}: his ${a.error || 'ok'} | ours ${b.error || 'ok'}`);
    continue;
  }
  let diffs = [];
  if (a.cancelled !== b.cancelled) {
    const why = r => r.cancelled ? `cancelled at ${r.cancelled}${r.said ? ' ("' + r.said + '")' : ''}` : 'went off';
    diffs = unaccepted(label, [`cancel: his ${why(a)} | ours ${why(b)}`]);
    if (diffs.length) { differ++; lines.push(`CANCEL ${label}: ${diffs[0].slice(8)}`); } else accepted++;
    continue;
  }
  for (const step of ['pre', 'mid']) {
    if (!a[step] && !b[step]) continue;
    for (const s of SLOTS) {
      const x = (a[step] || {})[s], y = (b[step] || {})[s];
      if (norm(x) !== norm(y)) diffs.push(`${step} ${s}: ${show(x)} -> ${show(y)}`);
    }
  }
  const any = diffs.length > 0;
  diffs = unaccepted(label, diffs);
  // a mode our side does not have only matters when the gear differs
  if (diffs.length && b.mode_missing && !a.mode_missing) diffs.push(`our side has no ${b.mode_missing}`);
  if (diffs.length) { differ++; lines.push(`DIFF ${label}\n    ` + diffs.join('\n    ')); }
  else if (any) accepted++;
  else { same++; if (flag === '--all') lines.push(`same ${label}`); }
}
console.log(lines.join('\n'));
if (reasons.size) {
  console.log('\nAccepted differences:');
  for (const [why, labels] of reasons) console.log(`  ${labels.size} scenarios: ${why}`);
}
console.log(`\n${same} same, ${accepted} accepted, ${differ} different, ${errors} errors (of ${Object.keys(his).length})`);
