// The lines of a built table (skirmish_check.js, reive_check.js): every augment, written as the game shows it, must be
// read by the optimizer's augment reader (augments_parse.js) as all its stats at its max, nothing left unread.
// @author ejouanchicot
const fs = require('fs');
const path = require('path');

// The rows of cache/<name>_check.json that are not read right, as one line each
function unreadLines(FFXI, name) {
    const rows = JSON.parse(fs.readFileSync(path.join(__dirname, 'cache', name + '_check.json'), 'utf8'));
    const bad = [];
    for (const r of rows) {
        const p = FFXI.parse_augments('Telchine Cap', [r.text]);
        const vals = Object.values(p.stats).concat(Object.values(p.extra));
        // "Elemental Siphon"+35 and the like are read as their value; a pair ("Accuracy+15 Attack+15") as two stats
        const ok = !p.unknown.length && vals.length === r.parts && vals.every(v => Math.abs(v) === r.value);
        if (!ok) bad.push(`${r.stat}: "${r.text}" -> ${JSON.stringify({stats: p.stats, extra: p.extra, unknown: p.unknown})}`);
    }
    return {rows: rows.length, bad};
}

module.exports = { unreadLines };
