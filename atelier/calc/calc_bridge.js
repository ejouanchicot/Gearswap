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
    var NAMES = ["create_player", "average_ws", "average_attack_round", "weaponskill_info", "get_hit_rate"];
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

    own.create_player = function (job, sub, ml, gearset, buffs, abilities) {
        var sheet = CALC.page.player({job: job, sub: sub, ml: ml, gearset: gearset, buffs: buffs, abilities: abilities});
        if (sheet.unsupported) {
            fall(sheet.unsupported);
            return old.create_player.apply(null, arguments);
        }
        return {stats: sheet, gearset: gearset, abilities: abilities, main_job: job, sub_job: sub, own: true,
            args: Array.prototype.slice.call(arguments)};
    };

    own.average_ws = function (player, enemy, ws, tp, type, metric) {
        if (player.own) {
            var got = CALC.page.weaponskill(player.stats, enemy.stats, ws, tp, type, metric, player.gearset);
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
