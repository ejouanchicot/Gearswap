// GearSwap Atelier · scripts/atelier/lib/opt_files.js: the optimizer's files in their load order (opt.js, then its
// parts), for the node checks that load the engine outside the page (scripts/audit). Read from the page's own list,
// atelier/app/js/engine.js ENGINE_FILES, so a part added there is loaded here too (make_package.py ships the same
// files: its DATA_FILES).
//   OPT_FILES  ['opt.js', 'opt_round.js', ...], relative to atelier/
//
// @file    scripts/atelier/lib/opt_files.js
// @author  ejouanchicot
'use strict';
const fs = require('fs');
const path = require('path');

const ENGINE = path.join(__dirname, '..', '..', '..', 'atelier', 'app', 'js', 'engine.js');
const list = /\.concat\(\[('opt'[^\]]*)\]\.map\(f => `atelier\/\$\{f\}\.js`\)\)/.exec(fs.readFileSync(ENGINE, 'utf8'));
if (!list) throw new Error('opt_files.js: the optimizer\'s list is no longer where it was in ' + ENGINE);
const OPT_FILES = list[1].split(',').map(s => s.trim().replace(/'/g, '') + '.js');

module.exports = {OPT_FILES};
