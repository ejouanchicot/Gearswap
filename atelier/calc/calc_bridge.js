// Atelier calculation engine: the functions the page calls (FFXI.create_player, average_ws...), answered by this engine.
//
// One part of the page's engine (FFXI_PARTS), run after the others and again in each worker.
//
//   FFXI.engine.name                 "own"; "old" only where the engine before is loaded and chosen: the tests on
//                                    this PC (scripts/audit/*.js), never the page (it no longer loads atelier/engine/)
//   FFXI.engine.use("own" | "old")   which engine answers; returns the one now in use
//   FFXI.engine.fell                 {reason: times} the cases this engine did not compute (calc_page.js names them)
//
// A case this engine does not compute throws an Error whose `notComputed` is the reason ("base attributes unknown for
// war/sam", "ranged weapon skill: ..."): the page says it (app/js/fight_stats.js notComputedText) instead of a figure.
// A spell it does not know is left out of a nuke (null), as the other spells of the set still count.
// A character is this engine's sheet ({stats, gearset, abilities, own: true}).
//
// @file    atelier/calc/calc_bridge.js
// @author  ejouanchicot
(globalThis.FFXI_PARTS = globalThis.FFXI_PARTS || []).push(function (FFXI) {
    var CALC = globalThis.CALC;
    if (!CALC || !CALC.page) return;
    var NAMES = ["create_player", "average_ws", "average_attack_round", "weaponskill_info", "get_hit_rate", "cast_spell"];
    var old = {}, own = {};
    NAMES.forEach(function (name) { old[name] = FFXI[name]; });
    var E = FFXI.engine = {name: "own", fell: {}, old: old};

    function notComputed(why) {
        E.fell[why] = (E.fell[why] || 0) + 1;
        var e = new Error(why);
        e.notComputed = why;
        throw e;
    }

    // Whether a weapon has an aftermath: a prime weapon, or a relic, mythic, empyrean, ergon or aeonic one
    function hasAftermath(name) {
        var r = name && FFXI.ranked_entry ? FFXI.ranked_entry(name) : null;
        return !!name && (CALC.PRIME_WEAPONS.indexOf(name) !== -1 || !!(r && r.kind === "ultimate_weapon"));
    }

    own.create_player = function (job, sub, ml, gearset, buffs, abilities) {
        // a Magic Burst is an option of the spell here (cast_spell below), not an ability of the sheet. The aftermath
        // chosen in the page with a weapon that has none (a search trying the weapons) gives nothing: left out
        var burst = !!(abilities && abilities["Magic Burst"]), noAm = !!(abilities && abilities.Aftermath) && !hasAftermath(((gearset || {}).main || {}).Name);
        var sheetAbilities = abilities;
        if (burst || noAm) { sheetAbilities = {}; for (var k in abilities) if (k !== "Magic Burst" && !(noAm && /^Aftermath/.test(k))) sheetAbilities[k] = abilities[k]; }
        var sheet = CALC.page.player({job: job, sub: sub, ml: ml, gearset: gearset, buffs: buffs, abilities: sheetAbilities});
        if (sheet.unsupported) notComputed(sheet.unsupported);
        return {stats: sheet, gearset: gearset, abilities: sheetAbilities, main_job: job, sub_job: sub, own: true, magicBurst: burst};
    };

    // a damaging spell (calc_magic.js), in the page's shape [metric, [damage, tp_return, 1], details]; options:
    // CALC.spellDamage's. null for a spell this engine does not know
    own.cast_spell = function (player, enemy, spell, type, metric, options) {
        var o = Object.assign({}, options || {}, {magicBurst: player.magicBurst || !!(options && options.magicBurst)});
        var got = CALC.spellDamage(player.stats, enemy.stats, spell, o, {job: player.main_job, gearset: player.gearset});
        if (got.error) { E.fell["spell: " + got.error] = (E.fell["spell: " + got.error] || 0) + 1; return null; }
        return [got.damage, [got.damage, 0, 1], got];
    };

    own.average_ws = function (player, enemy, ws, tp, type, metric) {
        // the item level (its level without one) of the weapon that uses it, for a magical weapon skill (calc_ws_magic.js)
        var main = ((player.gearset || {})[type === "ranged" ? "ranged" : "main"] || {}).Name;
        var item = main && FFXI.opt && FFXI.opt.item ? FFXI.opt.item(main) : null;
        var got = CALC.page.weaponskill(player.stats, enemy.stats, ws, tp, type, metric, player.gearset, player.abilities,
            item ? item.ilvl || item.level : null);
        if (got.unsupported) notComputed(got.unsupported);
        return got;
    };

    own.average_attack_round = function (player, enemy, start, at, metric) {
        var got = CALC.page.round(player.stats, enemy.stats, start, at, metric, player.gearset, player.main_job, player.abilities);
        if (got.unsupported) notComputed(got.unsupported);
        FFXI.lastRound = got.detail;
        return got.result;
    };

    // the page reads the main hand's accuracy from it, for the hit rate it shows with a weapon skill
    own.weaponskill_info = function (ws, tp, player) { return {player_accuracy1: player.stats["Accuracy1"]}; };

    own.get_hit_rate = function (accuracy, evasion, cap) { return CALC.hitRate(accuracy, evasion, cap); };

    E.use = function (name) {
        E.name = name === "old" && old.create_player ? "old" : "own";
        E.fell = {};
        NAMES.forEach(function (key) { FFXI[key] = E.name === "own" ? own[key] : old[key]; });
        return E.name;
    };
    E.use("own");
});
