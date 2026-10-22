// Atelier calculation engine: the switch between this engine and the one the page had before.
//
// One part of the page's engine (FFXI_PARTS), run after the others and again in each worker: it
// keeps the functions it finds and puts its own in their place when asked.
//
//   FFXI.engine.use("own" | "old")   which engine answers; returns the one now in use
//   FFXI.engine.name                 "own" or "old"
//   FFXI.engine.fell                 {reason: times} the cases this engine does not compute yet,
//                                    answered by the old one (calc_page.js names the reasons)
//
// With "own", a character is this engine's sheet ({stats, gearset, abilities, own: true}); the
// old engine's character is built from the same arguments only when a case falls back to it.
// A whole search falls back or not: the reasons depend on the abilities, the weapon skill and
// the job, not on the pieces tried.
//
// @file    atelier/calc/calc_bridge.js
// @author  ejouanchicot
(globalThis.FFXI_PARTS = globalThis.FFXI_PARTS || []).push(function (FFXI) {
    var CALC = globalThis.CALC;
    if (!CALC || !CALC.page) return;
    var NAMES = ["create_player", "average_ws", "average_attack_round", "weaponskill_info", "get_hit_rate", "cast_spell"];
    var old = {}, own = {};
    NAMES.forEach(function (name) { old[name] = FFXI[name]; });
    var E = FFXI.engine = {name: "old", fell: {}, old: old};

    function fall(why) { E.fell[why] = (E.fell[why] || 0) + 1; }

    // the old engine's character for one of ours, built once
    function oldPlayer(player) {
        if (!player || !player.own) return player;
        if (!player.oldPlayer) player.oldPlayer = old.create_player.apply(null, player.args);
        return player.oldPlayer;
    }

    // Whether a weapon has an aftermath: a prime weapon, or a relic, mythic, empyrean, ergon or aeonic one
    function hasAftermath(name) {
        var r = name && FFXI.ranked_entry ? FFXI.ranked_entry(name) : null;
        return !!name && (CALC.PRIME_WEAPONS.indexOf(name) !== -1 || !!(r && r.kind === "ultimate_weapon"));
    }

    own.create_player = function (job, sub, ml, gearset, buffs, abilities) {
        // a Magic Burst is the old engine's ability switch; here it is an option of the spell (cast_spell below),
        // and the sheet does not know it as an ability. The aftermath chosen in the page with a weapon that has none
        // (a search trying the weapons) gives nothing: left out, rather than handing the case to the old engine
        var burst = !!(abilities && abilities["Magic Burst"]), noAm = !!(abilities && abilities.Aftermath) && !hasAftermath(((gearset || {}).main || {}).Name);
        var sheetAbilities = abilities;
        if (burst || noAm) { sheetAbilities = {}; for (var k in abilities) if (k !== "Magic Burst" && !(noAm && /^Aftermath/.test(k))) sheetAbilities[k] = abilities[k]; }
        var sheet = CALC.page.player({job: job, sub: sub, ml: ml, gearset: gearset, buffs: buffs, abilities: sheetAbilities});
        if (sheet.unsupported) {
            fall(sheet.unsupported);
            return old.create_player.apply(null, arguments);
        }
        return {stats: sheet, gearset: gearset, abilities: sheetAbilities, main_job: job, sub_job: sub, own: true, magicBurst: burst,
            args: Array.prototype.slice.call(arguments)};
    };

    // a damaging spell (calc_magic.js), in the old engine's shape [metric, [damage, tp_return, 1]]; options: CALC.spellDamage's
    own.cast_spell = function (player, enemy, spell, type, metric, options) {
        if (player.own) {
            var o = Object.assign({}, options || {}, {magicBurst: player.magicBurst || !!(options && options.magicBurst)});
            var got = CALC.spellDamage(player.stats, enemy.stats, spell, o, {job: player.main_job, gearset: player.gearset});
            if (!got.error) return [got.damage, [got.damage, 0, 1], got];
            fall("spell: " + got.error);
        }
        if (!old.cast_spell) return null;
        return old.cast_spell(oldPlayer(player), enemy, spell, type, metric);
    };

    own.average_ws = function (player, enemy, ws, tp, type, metric) {
        if (player.own) {
            var got = CALC.page.weaponskill(player.stats, enemy.stats, ws, tp, type, metric, player.gearset, player.abilities);
            if (!got.unsupported) return got;
            fall(got.unsupported);
        }
        return old.average_ws(oldPlayer(player), enemy, ws, tp, type, metric);
    };

    own.average_attack_round = function (player, enemy, start, at, metric) {
        if (player.own) {
            var got = CALC.page.round(player.stats, enemy.stats, start, at, metric, player.gearset, player.main_job);
            if (!got.unsupported) {
                FFXI.lastRound = got.detail;
                return got.result;
            }
            fall(got.unsupported);
        }
        return old.average_attack_round(oldPlayer(player), enemy, start, at, metric);
    };

    // the page reads the main hand's accuracy from it, for the hit rate it shows with a weapon skill
    own.weaponskill_info = function (ws, tp, player) {
        if (player.own) return {player_accuracy1: player.stats["Accuracy1"]};
        return old.weaponskill_info.apply(null, arguments);
    };

    own.get_hit_rate = function (accuracy, evasion, cap) { return CALC.hitRate(accuracy, evasion, cap); };

    E.use = function (name) {
        E.name = name === "own" ? "own" : "old";
        E.fell = {};
        NAMES.forEach(function (key) { FFXI[key] = E.name === "own" ? own[key] : old[key]; });
        return E.name;
    };
});
