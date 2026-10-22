    // Body of the augments_ranked.js part (DATA is set just above by the builder).
    var keys = {};
    DATA.stat_keys.forEach(function (k) { keys[k] = true; });
    FFXI.AUG_STAT_KEYS = keys;
    FFXI.RANKED_BUNDLES = DATA.bundles;
    FFXI.RANKED_ALIASES = DATA.aliases;
    FFXI.RANKED = {};
    Object.keys(DATA.items).forEach(function (name) {
        var it = DATA.items[name], paths = {};
        Object.keys(it.paths).forEach(function (p) {
            paths[p] = { bundle: it.paths[p], effects: DATA.bundles[it.paths[p]] };
        });
        FFXI.RANKED[name] = { id: it.id, kind: it.kind, max_rank: it.max_rank, wiki: it.wiki, paths: paths };
    });

    // Item name (Windower short name, or full name) -> its FFXI.RANKED entry.
    FFXI.ranked_entry = function (name) {
        return FFXI.RANKED[name] || FFXI.RANKED[FFXI.RANKED_ALIASES[name]] || null;
    };

    // {stat key: value} of an item's augments at a path and rank. Rank is
    // clamped to 0..30; an unknown item or path gives {}.
    FFXI.ranked_stats = function (name, path, rank) {
        var it = FFXI.ranked_entry(name), out = {};
        var p = it && it.paths[path];
        if (!p) { return out; }
        p.effects.forEach(function (e) {
            var r = Math.max(0, Math.min(e.values.length - 1, rank | 0));
            var v = e.values[r];
            if (!v) { return; }
            Object.keys(e.keys).forEach(function (k) {
                out[k] = (out[k] || 0) + e.keys[k] * v;
            });
        });
        return out;
    };
