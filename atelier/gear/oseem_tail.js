    // Body of the oseem.js part (DATA is set just above by oseem_build.py).
    FFXI.OSEEM_BY_NAME = Object.assign({}, DATA.pieces);
    // the long name too ("Odyssean Chestplate" for "Odyss. Chestplate")
    Object.keys(DATA.alias).forEach(function (n) { FFXI.OSEEM_BY_NAME[n] = DATA.pieces[DATA.alias[n]]; });
    FFXI.OSEEM_DARK = DATA.dark;

    // An augment's first value ('Accuracy+18 Attack+18' -> 18)
    var num = function (a) { var m = String(a).match(/[+-]\s?(\d+)/); return m ? +m[1] : 0; };
    // The slot of one augment in a path: the group not taken yet whose augment has its shape, the higher cap first
    // ('Accuracy+18' is slot 1's 30, not slot 4's 15). A Dark Matter stat ('Weapon skill damage +10%') only when no
    // other slot has the shape, or when the piece is past that slot's cap: a WSD +4 is the special slot's
    function slotOf(P, a, used) {
        var sh = FFXI.augShape(a), plain = null, dark = null;
        P.groups.forEach(function (g) {
            if (used[g]) return;
            P.augs[g].forEach(function (t) {
                if (FFXI.augShape(t) !== sh) return;
                var c = {g: g, t: t};
                if (DATA.dark.indexOf(t) !== -1) { if (!dark || num(t) > num(dark.t)) dark = c; }
                else if (!plain || num(t) > num(plain.t)) plain = c;
            });
        });
        return plain && (num(a) <= num(plain.t) || !dark) ? plain : dark || plain;
    }

    // A piece you hold with each of its augments at its cap: {path, augs, changed, missing: [the slot groups it has
    // nothing in]}, or null for another piece. Its path is the one most of its augments fit; an augment no slot of it
    // has is kept as it is, and one already past its slot's cap is never lowered
    FFXI.oseem_max = function (name, augs) {
        var o = FFXI.OSEEM_BY_NAME[name];
        if (!o) return null;
        augs = augs || [];
        var best = null;
        Object.keys(o.paths).forEach(function (path) {
            var P = o.paths[path], used = {}, out = augs.slice(), hits = 0, changed = false;
            augs.map(function (a, i) { return i; }).sort(function (x, y) { return num(augs[y]) - num(augs[x]); }).forEach(function (i) {
                var c = slotOf(P, augs[i], used);
                if (!c) return;
                used[c.g] = true; hits++;
                if (num(c.t) > num(augs[i])) { out[i] = c.t; changed = true; }
            });
            // slot 1 + slot 4 / 5 never past 40 of one stat: the +15 stays as it was
            P.excl.forEach(function (x) {
                var j = out.indexOf(x[1]);
                if (out.indexOf(x[0]) !== -1 && j !== -1 && augs[j] !== x[1]) out[j] = augs[j];
            });
            if (!best || hits > best.hits) best = {path: path, hits: hits, augs: out, changed: changed, missing: P.groups.filter(function (g) { return !used[g]; })};
        });
        if (!best || !best.hits) return null;
        return {path: best.path, augs: best.augs, changed: best.changed, missing: best.missing};
    };
