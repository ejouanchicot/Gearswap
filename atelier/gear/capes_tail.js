    // Body of the capes.js part (DATA is set just above by capes_build.py).
    FFXI.AMBU_CAPE_OPTIONS = DATA.options;
    FFXI.AMBU_CAPES = DATA.capes;
    FFXI.AMBU_CAPE_BY_NAME = {};
    DATA.capes.forEach(function (c) {
        FFXI.AMBU_CAPE_BY_NAME[c.en] = c;
        FFXI.AMBU_CAPE_BY_NAME[c.name] = c;
    });

    // One option of a material, by its label or one of its keys
    // ('STR', 'Accuracy / Attack', 'Accuracy', 'Weapon Skill Damage', 'PDT'...).
    FFXI.ambu_cape_option = function (material, which) {
        var rows = FFXI.AMBU_CAPE_OPTIONS[material] || [];
        for (var i = 0; i < rows.length; i++) {
            if (rows[i].label === which || rows[i].keys.indexOf(which) === 0) { return rows[i]; }
        }
        return null;
    };

    // Stats of a fully augmented cape: choice = {thread, dust, dye, sap, resin},
    // each the label or first key of an option (or omitted). Every material is
    // taken at its max (thread +20, dust +20, dye +10, sap +10, resin max).
    // Enmity on Sap exists as +10 and -10: pass 'Enmity-' for the minus one.
    FFXI.ambu_cape_stats = function (choice) {
        var out = {};
        ['thread', 'dust', 'dye', 'sap', 'resin'].forEach(function (m) {
            var which = choice && choice[m];
            if (!which) { return; }
            var opt;
            if (which === 'Enmity-') {
                opt = (FFXI.AMBU_CAPE_OPTIONS[m] || []).filter(function (r) { return r.keys[0] === 'Enmity' && r.max < 0; })[0];
            } else {
                opt = FFXI.ambu_cape_option(m, which);
            }
            if (!opt) { throw new Error('ambu_cape_stats: no ' + m + ' option ' + which); }
            opt.keys.forEach(function (k) { out[k] = (out[k] || 0) + opt.max; });
        });
        return out;
    };
