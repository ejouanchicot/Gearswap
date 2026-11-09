// Checks oseem.js: every Oseem augment read at its cap (aug_lines_check.js), and FFXI.oseem_max bringing a piece's
// augments to their cap. Run by oseem_build.py (node oseem_check.js).
// @author ejouanchicot
const { load } = require('./augments_load');
const { unreadLines } = require('./aug_lines_check');

const FFXI = load();
const { rows, bad } = unreadLines(FFXI, 'oseem');
let fails = bad.length;
const eq = (what, got, want) => { if (JSON.stringify(got) !== JSON.stringify(want)) { fails++; console.log(`FAILED ${what}: ${JSON.stringify(got)}`); } };
// pieces of the players' sets (a lone Mag. Acc. is read as slot 1's, the higher cap)
eq('Merlinic Hood', FFXI.oseem_max('Merlinic Hood', ['Mag. Acc.+1', '"Fast Cast"+7', 'CHR+2', '"Mag.Atk.Bns."+1']),
    {path: 'Magic', augs: ['Mag. Acc.+30', '"Fast Cast"+7', 'CHR+15', '"Mag.Atk.Bns."+15'], changed: true, missing: ['acc2']});
eq('Herculean Helm (Dark Matter TH)', FFXI.oseem_max('Herculean Helm', ['MND+1', 'Attack+23', '"Treasure Hunter"+2']).augs,
    ['MND+15', 'Attack+30', '"Treasure Hunter"+2']);
eq('Odyssean Greaves', FFXI.oseem_max('Odyssean Greaves', ['"Fast Cast"+2', 'STR+7', 'Phalanx +5', 'Accuracy+14 Attack+14', 'Mag. Acc.+10 "Mag.Atk.Bns."+10']).augs,
    ['"Fast Cast"+6', 'STR+15', 'Phalanx +5', 'Accuracy+25 Attack+25', 'Mag. Acc.+10 "Mag.Atk.Bns."+10']);
eq('a WSD is the special slot', FFXI.oseem_max('Herculean Boots', ['Weapon skill damage +4%']).augs, ['Weapon skill damage +5%']);
const herc = FFXI.OSEEM_BY_NAME['Herculean Boots'].paths.Melee.excl;
eq('Dark Matter WSD beside the special WSD ruled out', herc.some(x => x[0] === 'Weapon skill damage +5%' && x[1] === 'Weapon skill damage +10%'), true);
eq('not an Oseem piece', FFXI.oseem_max('Nyame Helm', []), null);
for (const b of bad) console.log('UNREAD ' + b);
console.log(`${rows} augments, ${bad.length} unread; ${fails} failed in all`);
process.exit(fails ? 1 : 0);
