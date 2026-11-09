// Atelier optimizer: the pieces the game offers that a search builds or picks the version of. One part of the engine
// (FFXI_PARTS, after atelier/opt.js, whose gear calls O.primeId, and before opt_search.js, whose runs call O.ambuGen): no DOM, no page
// state, so it also runs in the search's workers.
//   O.ambuGen   the Ambuscade capes of the game (the page's app/js/optimizer.js gameChoices: {name, ambu: true}) built
//               at each material's maximum, a material at a time; the Skirmish armour ({name, skirmish: true}) with an
//               augment of each stone at its max, a stone at a time; the Reive capes ({name, reive: true}) the same way,
//               each of the four augments a group of its own
//   O.primeId   a prime weapon a set names only, at the stage the page chose
//
// @file    atelier/opt_ambu.js
// @author  ejouanchicot
(globalThis.FFXI_PARTS = globalThis.FFXI_PARTS || []).push(function (FFXI) {
    var O = FFXI.opt;

    // A prime weapon a set names only ("Foenaria"): the stage the page chose (ctx.primeStage: the Buffs panel's, else
    // your copy's), the catalogue's items of that name being its stages II to V in id order; null for another piece
    var PRIME_IDS = {items: null, by: {}};
    O.primeId = function (name, ctx) {
        if (!ctx || !ctx.primeStage || O.primeWeapons().indexOf(name) === -1 || !FFXI.CATALOG) return null;
        if (PRIME_IDS.items !== FFXI.CATALOG.items) PRIME_IDS = {items: FFXI.CATALOG.items, by: {}};
        var ids = PRIME_IDS.by[name] || (PRIME_IDS.by[name] = FFXI.CATALOG.items.filter(function (it) { return it.name === name; })
            .map(function (it) { return it.id; }).sort(function (a, b) { return a - b; }));
        return ids[ids.length - 1 - ["V", "IV", "III", "II"].indexOf(ctx.primeStage)] || null;
    };

    // An Ambuscade cape of the game you do not hold, as the page offers it ({name, ambu: true}, app/js/optimizer.js
    // gameChoices): built at each material's maximum (thread, dust, dye, sap, resin: BG Wiki, atelier/gear/capes.js),
    // its augments written as the game shows them. Tens of thousands of builds, so a material at a time: each option
    // tried with the others at their best so far (two rounds), then the two best threads and resins crossed with every
    // sap, the damage taken resins kept for the defense floors. Every sap stays to the end of the search (keep): the
    // materials are rated on the set the search starts from, where Double Attack is worth most, and the set it ends
    // on can cap it (Hoxne Ampulla: Double Attack +100 %, then Store TP is the cape's: DRK engaged PDT, 2026-11-03).
    // Options in their order of preference when they tie (any thread for the time to a weaponskill). The pet's are in
    // (BST, SMN, PUP: Artio's, Campestres's, Visucius's), as the game writes them (the players' own capes; the status
    // ailment resin as Windower's libs/extdata.lua writes it, 0x486: the gear's "Resistance to all status ailments", one
    // Japanese for both, 全状態異常のレジスト). O.AMBU_AUGS: the page reads what each one adds to
    // a cape's stats for a set judged by its stats (app/js/stat_opt.js augVecs)
    var AMBU_AUGS = {
        thread: ["STR+20", "DEX+20", "VIT+20", "AGI+20", "INT+20", "MND+20", "CHR+20", "HP+60", "MP+60",
            "Pet: Acc.+20 Pet: R.Acc.+20 Pet: Atk.+20 Pet: R.Atk.+20", "Pet: M.Acc.+20 Pet: M.Dmg.+20"],
        dust: ["Accuracy+20 Attack+20", "Rng.Acc.+20 Rng.Atk.+20", "Mag. Acc+20 /Mag. Dmg.+20", "Eva.+20 /Mag. Eva.+20"],
        dye: ["Accuracy+10", "Attack+10", "STR+10", "DEX+10", "VIT+10", "AGI+10", "INT+10", "MND+10", "CHR+10", "HP+20", "MP+20",
            "Rng.Acc.+10", "Rng.Atk.+10", "Mag. Acc.+10", "Mag. Dmg.+10", "Evasion+10", "Mag. Evasion+10",
            "Pet: Accuracy+10 Pet: Rng. Acc.+10", "Pet: Attack+10 Pet: Rng.Atk.+10", "Pet: Mag. Acc.+10", "Pet: Magic Damage+10"],
        sap: ["Weapon skill damage +10%", "Crit.hit rate+10", "\"Store TP\"+10", "\"Dbl.Atk.\"+10", "Haste+10", "\"Dual Wield\"+10",
            "Enmity+10", "Enmity-10", "\"Snapshot\"+10", "\"Mag.Atk.Bns.\"+10", "\"Fast Cast\"+10", "\"Cure\" potency +10%", "\"Waltz\" potency +10%",
            "Pet: \"Regen\"+10", "Pet: Haste+10"],
        resin: ["DEF+50", "Evasion+15", "Mag. Evasion+15", "Phys. dmg. taken-10%", "Magic dmg. taken-10%", "Damage taken-5%", "\"Regen\"+5",
            "\"Counter\"+10", "Chance of successful block +5", "Parrying rate+5%", "Spell interruption rate down-10%",
            "Occ. inc. resist. to stat. ailments+10",
            "Pet: Phys. dmg. taken -10%", "Pet: Magic dmg. taken -10%", "Pet: Damage taken -5%", "Pet: \"Regen\"+5"]
    };
    O.AMBU_AUGS = AMBU_AUGS;
    var AMBU_ORDER = ["thread", "dust", "dye", "sap", "resin"], AMBU_DT = ["Phys. dmg. taken-10%", "Damage taken-5%"];
    O.ambuGen = function* (ctx, start, choices, opts) {
        var built = function (p) { return p && (p.ambu || p.skirmish || p.reive); };
        var slots = Object.keys(choices).filter(function (s) { return Array.isArray(choices[s]) && choices[s].some(built); });
        if (!slots.length) return choices;
        var loose = Object.assign({}, opts, {floor: null}), res = Object.assign({}, choices);
        for (var k = 0; k < slots.length; k++) {
            var list = choices[slots[k]], out = [];
            for (var i = 0; i < list.length; i++) {
                var p = list[i];
                out = out.concat(p && p.ambu && slots[k] === "back" ? yield* ambuBuilds(ctx, start, p, loose, opts)
                    : p && (p.skirmish || p.reive) ? yield* skirmishBuilds(ctx, start, slots[k], p, loose, opts) : [p]);
            }
            res[slots[k]] = out;
        }
        return res;
    };
    // A built piece in a set judged by its stats (opt_stat.js reads piece.st only): the bare piece's stats the page gave
    // (tpl.st) plus what each augment chosen adds (tpl.stAugs[material or stone], in the order of `lists`: the page's
    // app/js/stat_opt.js augVecs). Without them a built piece counted for nothing there (an Intarabus's Cape built with
    // "Fast Cast"+10 left a BRD's Fast Cast set at 70, as with no cape: 2026-11-09)
    function withStats(c, tpl, sel, lists) {
        if (tpl.shield) c.shield = true;
        if (!tpl.st) return c;
        var st = Object.assign({}, tpl.st);
        Object.keys(sel).forEach(function (m) {
            var d = sel[m] && tpl.stAugs && tpl.stAugs[m] && tpl.stAugs[m][(lists[m] || []).indexOf(sel[m])];
            if (d) for (var k in d) st[k] = (st[k] || 0) + d[k];
        });
        c.st = st;
        return c;
    }
    // The pet's damage taken of a built piece, for a BST's set worn while both fight (app/js/optimizer.js
    // optimizeEngaged, petDtPass): a positive %, as bst_pet.js petDtOf, and the levels the template had
    function withPet(c, tpl) {
        if (!("petdt" in tpl)) return c;
        var st = FFXI.parse_augments(tpl.name, c.augs).stats;
        c.petdt = -((st["Pet:DT"] || 0) + (st["Pet:PDT"] || 0)); c.petlv = tpl.petlv || 0;
        return c;
    }
    // A Skirmish piece of the game (atelier/gear/skirmish.js): one augment of each stone (Snow, Leaf, Dusk) at its
    // max, whatever the stone's quality. A stone at a time, each of its augments tried with the others at their best so
    // far (two rounds, as the capes), then the best two of each stone crossed: eight builds at most, left to the
    // search's prefilter like any piece. A tie goes to the augment the set's own copy carries, then to none.
    // A Reive cape (atelier/gear/reive.js) is built the same way, each of its four augments a "stone" of one augment:
    // at its max, or left out when it changes nothing (sixteen builds at most)
    function groupsOf(tpl) {
        if (tpl.reive) return FFXI.REIVE_BY_NAME && FFXI.REIVE_BY_NAME[tpl.name] || null;
        var set = FFXI.SKIRMISH_SETS && FFXI.SKIRMISH_SETS[FFXI.SKIRMISH_BY_NAME[tpl.name]];
        return set ? {groups: FFXI.SKIRMISH_STONES, augs: set.augs} : null;
    }
    function* skirmishBuilds(ctx, start, slot, tpl, loose, opts) {
        var set = groupsOf(tpl);
        if (!set) return [];
        var stones = set.groups, own = (opts.base || start)[slot], pick = {}, best = {};
        var mine = own && own.name === tpl.name ? own.augs || [] : [];
        // an augment that changes nothing for the objective takes the one the set's own copy carries, not the list's first
        var order = function (x, y) { var d = y.v - x.v; return Math.abs(d) > Math.abs(x.v) * 1e-9 + 1e-12 ? d : (mine.indexOf(y.a) !== -1) - (mine.indexOf(x.a) !== -1); };
        var pieceOf = function (sel) {
            return withStats({name: tpl.name, augs: stones.map(function (m) { return sel[m]; }).filter(Boolean), missing: true}, tpl, sel, set.augs);
        };
        for (var round = 0; round < 2; round++) for (var m = 0; m < stones.length; m++) {
            // no augment first: a stone none of whose augments changes the set stays empty (never an Accuracy+20 shown
            // on an enhancing piece only because it came first)
            var stone = stones[m], list = [null].concat(set.augs[stone] || []), rated = [];
            for (var j = 0; j < list.length; j++) {
                var sel = Object.assign({}, pick); sel[stone] = list[j];
                var at = Object.assign({}, start); at[slot] = pieceOf(sel);
                rated.push({a: list[j], v: O.value(ctx, at, loose).v});
                if (opts.prog) opts.prog.evals++;
                yield;
            }
            if (!rated.length) continue;
            rated.sort(order);
            // the second kept is the best of another value (a tie is the same piece for the search)
            var alt = rated.filter(function (x) { return Math.abs(x.v - rated[0].v) > Math.abs(rated[0].v) * 1e-9 + 1e-12; })[0];
            pick[stone] = rated[0].a; best[stone] = [rated[0].a].concat(alt ? [alt.a] : []);
        }
        var builds = [{}];
        stones.forEach(function (stone) {
            if (!best[stone]) return;
            var next = [];
            builds.forEach(function (b) { best[stone].forEach(function (a) { var c = Object.assign({}, b); c[stone] = a; next.push(c); }); });
            builds = next;
        });
        return builds.map(function (b) { return withPet(pieceOf(b), tpl); });
    }
    function* ambuBuilds(ctx, start, tpl, loose, opts) {
        // the cape of the set itself (searched from scratch, the walks start bare)
        var own = (opts.base || start).back, pick = {}, best = {}, mine = own && own.name === tpl.name ? own.augs || [] : [];
        // a material that changes nothing for the objective (DEX, STR or HP alike on an engaged set) takes the
        // augment of the cape the set wears, not the list's first
        var order = function (x, y) { var d = y.v - x.v; return Math.abs(d) > Math.abs(x.v) * 1e-9 + 1e-12 ? d : (mine.indexOf(y.a) !== -1) - (mine.indexOf(x.a) !== -1); };
        var capeOf = function (sel) { return withStats({name: tpl.name, augs: AMBU_ORDER.map(function (m) { return sel[m]; }).filter(Boolean), missing: true}, tpl, sel, AMBU_AUGS); };
        for (var round = 0; round < 2; round++) for (var m = 0; m < AMBU_ORDER.length; m++) {
            var mat = AMBU_ORDER[m], rated = [];
            for (var j = 0; j < AMBU_AUGS[mat].length; j++) {
                var sel = Object.assign({}, pick); sel[mat] = AMBU_AUGS[mat][j];
                rated.push({a: sel[mat], v: O.value(ctx, Object.assign({}, start, {back: capeOf(sel)}), loose).v});
                if (opts.prog) opts.prog.evals++;
                yield;
            }
            rated.sort(order);
            pick[mat] = rated[0].a; best[mat] = rated.slice(0, mat === "sap" ? rated.length : mat === "thread" || mat === "resin" ? 2 : 1).map(function (x) { return x.a; });
        }
        best.resin = best.resin.concat(AMBU_DT.filter(function (a) { return best.resin.indexOf(a) === -1; }));
        var builds = [{}];
        AMBU_ORDER.forEach(function (mat) {
            var next = [];
            builds.forEach(function (b) { best[mat].forEach(function (a) { var c = Object.assign({}, b); c[mat] = a; next.push(c); }); });
            builds = next;
        });
        // a BST's set worn while both fight: each cape its Pet damage taken, for the pet's pass (withPet)
        return builds.map(function (b) { return withPet(Object.assign(capeOf(b), {keep: true}), tpl); });
    }
});
