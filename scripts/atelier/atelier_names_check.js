// GearSwap Atelier · the page's names declared twice (for the project, never shipped to players).
// The page's files are classic scripts sharing one global scope: a `const` / `let` / `class` declared in two files
// stops the second file from loading (2026-10-14: MIDCAST_KINDS in drawer.js and list_prefs.js broke the page), a
// `function` declared twice replaces the first one without a word (statRows, stats.js and stat_opt.js). This lists
// every top-level name declared in more than one of atelier/app/js/*.js, atelier/*.js and atelier/calc/*.js (not
// atelier/engine/, kept as it came) and fails when there is one.
//   node scripts/atelier/atelier_names_check.js
// atelier_test.js runs it first.
const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '../../atelier');
const DIRS = [path.join(ROOT, 'app/js'), ROOT, path.join(ROOT, 'calc')];
// a declaration at the start of a line, outside any block (the files indent everything inside a block)
const DECL = /^(?:async\s+)?(?:function\*?\s+([A-Za-z_$][\w$]*)|(?:const|let|var|class)\s+([A-Za-z_$][\w$]*))/;
// files that are data written by the game or a script, not page code
const SKIP = /^(live_|link_|index\.js$|catalog\.js$|targets\.js$)/;

function names(file){
  const out = [];
  fs.readFileSync(file, 'utf8').split(/\r?\n/).forEach((line, i) => {
    const m = line.match(DECL);
    if (m) out.push({name: m[1] || m[2], line: i + 1});
  });
  return out;
}

function check(){
  const seen = new Map();
  for (const dir of DIRS) {
    for (const f of fs.readdirSync(dir).filter(f => f.endsWith('.js') && !SKIP.test(f))) {
      const file = path.join(dir, f), rel = path.relative(path.dirname(ROOT), file).split(path.sep).join('/');
      // calc/ and opt.js wrap their code in a function handed to CALC_PARTS / FFXI_PARTS: their names are their own
      if (/CALC_PARTS|FFXI_PARTS/.test(fs.readFileSync(file, 'utf8').slice(0, 2000))) continue;
      for (const {name, line} of names(file)) {
        if (!seen.has(name)) seen.set(name, []);
        seen.get(name).push(`${rel}:${line}`);
      }
    }
  }
  const twice = [...seen].filter(([, at]) => at.length > 1);
  for (const [name, at] of twice) console.log(`declared twice: ${name}  ${at.join('  ')}`);
  console.log(`${seen.size} top-level names, ${twice.length} declared more than once`);
  return twice.length === 0;
}

if (require.main === module) process.exit(check() ? 0 : 1);
module.exports = {check};
