// GearSwap Atelier · the click tests (scripts/atelier/clicks/*_clicks.js): each clicks through one part of the page
// and prints what a player would read there, then the page's errors.
//
//   node scripts/atelier/atelier_clicks_test.js                 every test on the page as built: passes when no page error
//   node scripts/atelier/atelier_clicks_test.js tip push        only those tests
//   node scripts/atelier/atelier_clicks_test.js --compare       every test on the last commit's page and on the page now
//                                                               (page_parity.js --serve old / now): passes when both print
//                                                               the same, line for line; --ref <commit> for another one
//   -j <n>                                                      tests run together (4 by default)
//
// With --compare, the two outputs of a test that differs are kept in <temp>/atelier_clicks/<name>.old.txt / .now.txt.
// Rerun before calling a difference: the data from the game can change between two runs, and a figure that rolls
// (motion.js) is read before it lands unless the test sets S.motion = false.
// Run from anywhere. Exits 1 when a test fails.
//
// @file    scripts/atelier/atelier_clicks_test.js
// @author  ejouanchicot
// @date    Created: 2026-10-20
const fs = require('fs'), os = require('os'), path = require('path'), {spawn} = require('child_process');

const DATA = path.resolve(__dirname, '../..');
const DIR = path.join(__dirname, 'clicks');
const args = process.argv.slice(2);
const opt = (name, dflt) => { const i = args.indexOf(name); return i < 0 ? dflt : args.splice(i, 2)[1]; };
const jobs = +opt('-j', 4), ref = opt('--ref', null);
const compare = args.includes('--compare') ? (args.splice(args.indexOf('--compare'), 1), true) : false;
const all = fs.readdirSync(DIR).filter(f => f.endsWith('_clicks.js')).map(f => f.replace(/_clicks\.js$/, '')).sort();
const unknown = args.filter(a => !all.includes(a));
if (unknown.length) { console.log('unknown test(s): ' + unknown.join(', ') + '\nknown: ' + all.join(' ')); process.exit(1); }
// the longest first, so they do not end the run alone (minutes on 2026-10-20: tip 6, wshead and weap 2, push 1)
const LONG = ['tip', 'wshead', 'weap', 'push'];
const rank = x => { const i = LONG.indexOf(x); return i < 0 ? 0 : LONG.length - i; };
const names = (args.length ? args : all).slice().sort((a, b) => rank(b) - rank(a));

// One test on one page: its output and whether the page threw
function run(name, url) {
  return new Promise(done => {
    const env = Object.assign({}, process.env, url ? {PAGE_URL: url} : {});
    const p = spawn(process.execPath, [path.join(DIR, name + '_clicks.js')], {cwd: DATA, env});
    let out = '';
    p.stdout.on('data', d => out += d); p.stderr.on('data', d => out += d);
    p.on('close', code => {
      const errs = (out.match(/^errors (\[.*\])\s*$/m) || [])[1];
      done({out, code, clean: code === 0 && errs === '[]', errs: errs || 'no "errors" line'});
    });
  });
}

// A page served by page_parity.js (old: the commit's files, now: the working tree), and its address
function serve(which) {
  return new Promise((done, fail) => {
    const p = spawn(process.execPath, ['scripts/atelier/page_parity.js', '--serve', which].concat(ref ? ['--ref', ref] : []), {cwd: DATA});
    let out = '';
    const t = setTimeout(() => fail(new Error('page_parity --serve ' + which + ' gave no address')), 60000);
    p.stdout.on('data', d => { out += d; const m = out.match(/http:\/\/\S+/); if (m) { clearTimeout(t); done({url: m[0], stop: () => p.kill()}); } });
    p.stderr.on('data', d => out += d);
  });
}

// The first line where two outputs part
function firstDiff(a, b) {
  const x = a.split(/\r?\n/), y = b.split(/\r?\n/);
  for (let i = 0; i < Math.max(x.length, y.length); i++) if (x[i] !== y[i]) return `line ${i + 1}\n    old: ${(x[i] || '').slice(0, 160)}\n    now: ${(y[i] || '').slice(0, 160)}`;
  return '';
}

(async () => {
  const started = Date.now();
  const servers = compare ? await Promise.all([serve('old'), serve('now')]) : null;
  const keep = path.join(os.tmpdir(), 'atelier_clicks');
  const results = [];
  let next = 0;
  async function worker() {
    while (next < names.length) {
      const name = names[next++], t0 = Date.now();
      let r;
      if (compare) {
        const [o, n] = await Promise.all([run(name, servers[0].url), run(name, servers[1].url)]);
        const why = !n.clean ? 'page error now: ' + n.errs : o.out !== n.out ? 'differs, ' + firstDiff(o.out, n.out) : '';
        if (o.out !== n.out) { fs.mkdirSync(keep, {recursive: true}); fs.writeFileSync(path.join(keep, name + '.old.txt'), o.out); fs.writeFileSync(path.join(keep, name + '.now.txt'), n.out); }
        r = {name, ok: !why, why, lines: n.out.split('\n').length};
      } else {
        const n = await run(name, null);
        r = {name, ok: n.clean, why: n.clean ? '' : 'page error: ' + n.errs + (n.code ? ' (exit ' + n.code + ')' : ''), lines: n.out.split('\n').length};
      }
      r.s = ((Date.now() - t0) / 1000).toFixed(0);
      results.push(r);
      console.log(`${r.ok ? 'ok  ' : 'FAIL'} ${r.name.padEnd(10)} ${String(r.lines).padStart(5)} lines ${r.s.padStart(4)} s${r.why ? '  ' + r.why : ''}`);
    }
  }
  try { await Promise.all(Array.from({length: Math.max(1, jobs)}, worker)); }
  finally { if (servers) servers.forEach(s => s.stop()); }
  const bad = results.filter(r => !r.ok);
  console.log(`\n${results.length - bad.length}/${results.length} passed${compare ? ' (last commit vs now' + (ref ? ', ref ' + ref : '') + ')' : ''}, ${((Date.now() - started) / 1000).toFixed(0)} s` +
    (bad.length && compare ? `; outputs kept in ${keep}` : ''));
  process.exit(bad.length ? 1 : 0);
})();
