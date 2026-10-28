// The Atelier's type check: `tsc --noEmit` on atelier/src (and the old page's globals it declares,
// atelier/src/legacy/globals.d.ts), nothing built or written. Run by scripts/run_tests.py.
// It had been failing since 42e3afc0 (an undeclared `nofile`) with no test running it (audit 2026-10-28 B).
//
//   node scripts/atelier/atelier_types_check.js
//
// @author ejouanchicot
// @date   Created: 2026-10-28
const path = require('path');
const {spawnSync} = require('child_process');

const dir = path.resolve(__dirname, '../../atelier');
const tsc = path.join(dir, 'node_modules', 'typescript', 'bin', 'tsc');
const r = spawnSync(process.execPath, [tsc, '--noEmit', '-p', path.join(dir, 'tsconfig.json')], {cwd: dir, encoding: 'utf-8'});
const out = ((r.stdout || '') + (r.stderr || '')).trim();
if (r.error || r.status !== 0) {
  console.log(out || String(r.error));
  console.log('type check FAILED');
  process.exit(1);
}
console.log('type check: 0 error');
