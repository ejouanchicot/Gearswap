    // Body of the reive.js part (DATA is set just above by reive_build.py).
    FFXI.REIVE_BY_NAME = DATA;

    // A cape you hold with each of its augments at its max: {augs, changed, missing: [the augments at their max it does
    // not carry]}, or null for another piece. An augment the source does not list is kept as it is. An augment of
    // another value has the same shape (FFXI.augShape, skirmish.js)
    FFXI.reive_max = function (name, augs) {
        var c = DATA[name];
        if (!c) return null;
        var out = [], had = {}, changed = false;
        (augs || []).forEach(function (a) {
            var g = c.groups.filter(function (s) { return FFXI.augShape(c.augs[s][0]) === FFXI.augShape(a); })[0];
            if (!g) { out.push(a); return; }
            had[g] = true;
            if (c.augs[g][0] !== a) changed = true;
            out.push(c.augs[g][0]);
        });
        return {augs: out, changed: changed, missing: c.groups.filter(function (s) { return !had[s]; }).map(function (s) { return c.augs[s][0]; })};
    };
