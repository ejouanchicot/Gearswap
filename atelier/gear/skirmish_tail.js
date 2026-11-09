    // Body of the skirmish.js part (DATA is set just above by skirmish_build.py).
    FFXI.SKIRMISH_SETS = DATA.sets;
    FFXI.SKIRMISH_STONES = DATA.stones;
    FFXI.SKIRMISH_BY_NAME = {};
    Object.keys(DATA.sets).forEach(function (set) {
        DATA.sets[set].pieces.forEach(function (p) {
            FFXI.SKIRMISH_BY_NAME[p.name] = set;
            FFXI.SKIRMISH_BY_NAME[p.long] = set;
        });
    });

    // An augment's label with its value taken out ('Enh. Mag. eff. dur. +8' -> 'Enh. Mag. eff. dur. #'): the same
    // augment at another value has the same shape. Also the Reive capes' (reive.js)
    var shape = FFXI.augShape = function (a) { return String(a).replace(/[+-]\s?\d+/g, '#').replace(/\s+/g, ' ').trim(); };

    // The stone an augment of this set comes from and its max, or null (a bad roll of another category, which the
    // source does not list)
    FFXI.skirmish_aug = function (set, aug) {
        var s = DATA.sets[set], want = shape(aug);
        if (!s) return null;
        for (var i = 0; i < DATA.stones.length; i++) {
            var list = s.augs[DATA.stones[i]];
            for (var j = 0; j < list.length; j++) if (shape(list[j]) === want) return {stone: DATA.stones[i], max: list[j]};
        }
        return null;
    };

    // A copy you hold with each of its augments at its max: {augs, changed, missing: [the stones it has no augment of]}
    // (one augment of each stone at most; re-augmenting a stone only replaces that stone's), or null for another piece.
    // An augment the source does not list is kept as it is.
    FFXI.skirmish_max = function (name, augs) {
        var set = FFXI.SKIRMISH_BY_NAME[name];
        if (!set) return null;
        var out = [], had = {}, changed = false;
        (augs || []).forEach(function (a) {
            var m = FFXI.skirmish_aug(set, a);
            if (!m) { out.push(a); return; }
            had[m.stone] = true;
            if (m.max !== a) changed = true;
            out.push(m.max);
        });
        return {augs: out, changed: changed, missing: DATA.stones.filter(function (s) { return !had[s]; })};
    };
