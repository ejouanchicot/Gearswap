// Loads the catalog's augment part files in Node (as the page would) and
// returns FFXI. Used by the augment checks and tests in this folder.
// @author ejouanchicot
const fs = require('fs');
const path = require('path');
const vm = require('vm');

const FILES = ['augments_ranked.js', 'capes.js', 'augments_parse.js'];

function load() {
    const ctx = vm.createContext({ console, Math, JSON });
    ctx.globalThis = ctx;
    for (const f of FILES) {
        const p = path.join(__dirname, f);
        if (fs.existsSync(p)) vm.runInContext(fs.readFileSync(p, 'utf8'), ctx, { filename: f });
    }
    const FFXI = ctx.FFXI = {};
    for (const part of ctx.FFXI_PARTS || []) part(FFXI);
    return FFXI;
}

module.exports = { load };
