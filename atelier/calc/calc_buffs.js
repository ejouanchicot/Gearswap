// Atelier calculation engine: the party's buffs added up, from what the page chose.
//
//   CALC.aggregateBuffs(sel)   [buffs, enemyDown]
//       sel: the page's choice (atelier/opt.js FFXI.opt.selection): brd, songs {Song1..Song5}, song_bonus,
//            soul_voice, marcato (on Song1), cor, rolls {Roll1, Roll2: {name, potency}}, roll_bonus,
//            job_bonus, crooked, light_shot, geo, bubbles {"Indi-", "Geo-", "Entrust-"}, bubble_bonus,
//            bubble_potency (percent), whm, whm_spells {Dia, Haste, Storm}, shell5, food
//       buffs: {brd, cor, geo, whm, food}, each {stat: value} in the catalogue's stat names (both engines
//            read it); enemyDown: what the target loses {Defense (a share), Evasion, Magic Defense, Magic Evasion}
//
// What the page works out itself is not here: Aria of Passion (its Loughnashade stage), Bolster, Blaze of
// Glory and Ecliptic Attrition (it scales each bubble: opt.js geoScaled), each roll's own job bonus and
// Crooked Cards (it calls this once a roll), Hastega's extra, the abilities on the target.
//
// Sources, read on 2026-10-22 (BG Wiki wikitext):
//   Songs, https://www.bg-wiki.com/ffxi/BGWiki:SongPotency "Potency per equipment bonus" tables (+0 to +8 or
//     +9; the tables below copy them). March, Minuet, Madrigal: "Every March +1 given through equipment
//     increases song duration and potency by 10%", "The maximum March bonus available from equipment is +8.
//     In the case of Honor March, the maximum bonus is +4"; Minuet +8, Madrigal +9; Etude "+9", "potency by 1".
//   Minuet, https://www.bg-wiki.com/ffxi/Minuet: merits "+5 Attack per Minuet applied after the percentage
//     bonus from +song", job points "+20 Attack per Minuet applied after the percentage bonus"; "Soul Voice
//     doubles the potency of this type of song after Merit Point and Job Point bonuses", Marcato "+50% after
//     Merit Point and Job Point bonuses". Counted at 5/5 merits and 20/20 job points (the end-game BRD).
//   Soul Voice x2 and Marcato x1.5 on every song kind here, https://www.bg-wiki.com/ffxi/Soul_Voice,
//     https://www.bg-wiki.com/ffxi/Marcato ("Does NOT stack with Soul Voice": the page leaves Marcato out).
//   Rolls, https://www.bg-wiki.com/ffxi/Chaos_Roll and the eight others: mod1..mod11, rollplus, bonus (the
//     roll's job in the party). https://www.bg-wiki.com/ffxi/Crooked_Cards "Phantom roll effect +20%",
//     "applies after Roll+ gear and job bonus".
//   Bubbles, https://www.bg-wiki.com/ffxi/Indi-Fury and the others: "With 900 skill (maximum potency)", and
//     "Idris grants an additional" (Geomancy +10): a tenth of it a Geomancy+ point.
//     https://www.bg-wiki.com/ffxi/Geomancy_Skill "Geomancy+ items do not affect Entrusted spells."
//   Haste 150/1024, Haste II 307/1024 (https://www.bg-wiki.com/ffxi/Haste, Haste_II); Dia, Dia II, Dia III
//     Defense -104/1024, -156/1024, -208/1024 and Light Shot "+2.73% (28/1024)" after a Dia
//     (https://www.bg-wiki.com/ffxi/Dia_III); storms II at 5/5 Stormsurge +7 (Voidstorm II +3 each)
//     (https://www.bg-wiki.com/ffxi/Storm); Shell V "-75/256 (-29%)" (https://www.bg-wiki.com/ffxi/Shell_V).
// What differs from the engine before: DIFFERENCES.md, section AF.
//
// @file    atelier/calc/calc_buffs.js
// @author  ejouanchicot
(globalThis.CALC_PARTS = globalThis.CALC_PARTS || []).push(function (CALC) {
    var ATTRIBUTES = ["STR", "DEX", "VIT", "AGI", "INT", "MND", "CHR"];
    var range = function (from, n) { var out = []; for (var i = 0; i <= n; i++) out.push(from + i); return out; };

    // Each song: its value at +0, +1... Songs+ (the last one its cap); Magic Haste in 1024ths
    var SONGS = {
        "Honor March": {"Magic Haste": [126, 138, 150, 162, 174], "Attack": [168, 184, 200, 216, 232],
            "Accuracy": [42, 46, 50, 54, 58]},
        "Victory March": {"Magic Haste": [163, 179, 195, 211, 228, 244, 260, 277, 293]},
        "Advancing March": {"Magic Haste": [108, 118, 129, 140, 151, 162, 172, 183, 194]},
        "Minuet V": {"Attack": [124, 136, 148, 161, 173, 186, 198, 210, 223]},
        "Minuet IV": {"Attack": [112, 123, 134, 145, 156, 168, 179, 190, 201]},
        "Minuet III": {"Attack": [96, 105, 115, 124, 134, 144, 153, 163, 172]},
        // Madrigal: melee accuracy only ("Enhances melee attack accuracy")
        "Blade Madrigal": {"Accuracy": [60, 66, 72, 78, 84, 90, 96, 102, 108, 114]},
        "Sword Madrigal": {"Accuracy": [45, 49, 54, 58, 63, 67, 72, 76, 81, 85]}
    };
    ATTRIBUTES.forEach(function (st, i) {
        var o = {}; o[st] = range(15, 9);
        SONGS[["Herculean", "Uncanny", "Vital", "Swift", "Sage", "Logical", "Bewitching"][i] + " Etude"] = o;
    });
    // Honor March and the Minuets raise the ranged stat by as much ("Att. & R. Att.", "Acc. & R. Acc.")
    ["Honor March", "Minuet V", "Minuet IV", "Minuet III"].forEach(function (name) {
        var song = SONGS[name];
        if (song.Attack) song["Ranged Attack"] = song.Attack;
        if (song.Accuracy) song["Ranged Accuracy"] = song.Accuracy;
    });
    var MINUET_MERITS = 5 + 20;

    // Each roll: its stats, the value of each number I..XI, a Rolls+ point, the roll's job in the party
    var ROLL_NUMBERS = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI"];
    var x1024 = function (list) { return list.map(function (v) { return v / 1024; }); };
    var ROLLS = {
        "Chaos": {stats: ["Attack%", "Ranged Attack%"], values: x1024([64, 80, 96, 256, 112, 128, 160, 32, 176, 192, 320]),
            plus: 32 / 1024, job: 100 / 1024},
        "Samurai": {stats: ["Store TP"], values: [8, 32, 10, 12, 14, 4, 16, 20, 22, 24, 40], plus: 4, job: 10},
        "Rogue's": {stats: ["Crit Rate"], values: [1, 2, 3, 4, 10, 5, 6, 7, 1, 8, 14], plus: 1, job: 5},
        "Monk's": {stats: ["Subtle Blow"], values: [8, 10, 32, 12, 14, 16, 4, 20, 22, 24, 40], plus: 4, job: 10},
        "Fighter's": {stats: ["DA"], values: [1, 2, 3, 4, 10, 5, 6, 6, 1, 7, 15], plus: 1, job: 5},
        "Hunter's": {stats: ["Accuracy", "Ranged Accuracy"], values: [10, 13, 15, 40, 18, 20, 25, 5, 28, 30, 50], plus: 5, job: 15},
        "Wizard's": {stats: ["Magic Attack"], values: [4, 6, 8, 10, 25, 12, 14, 17, 2, 20, 30], plus: 2, job: 10},
        "Warlock's": {stats: ["Magic Accuracy"], values: [10, 13, 15, 40, 18, 20, 25, 5, 28, 30, 50], plus: 5, job: 15},
        "Tactician's": {stats: ["Regain"], values: [10, 10, 10, 10, 30, 10, 10, 0, 20, 20, 40], plus: 2, job: 10}
    };

    // Each bubble at 900 skill and a Geomancy+ point: on the party, or on the target
    var BUBBLES = {
        "Fury": {"Attack%": [0.347, 0.027], "Ranged Attack%": [0.347, 0.027]},
        "Haste": {"Magic Haste": [0.299, 0.011]},
        "Precision": {"Accuracy": [50, 5], "Ranged Accuracy": [50, 5]},
        "Focus": {"Magic Accuracy": [50, 5]},
        "Acumen": {"Magic Attack": [15, 3]}
    };
    ATTRIBUTES.forEach(function (st) { BUBBLES[st] = {}; BUBBLES[st][st] = [25, 2]; });
    var FOE_BUBBLES = {
        "Frailty": {"Defense": [0.148, 0.027]},
        "Torpor": {"Evasion": [50, 5]},
        "Malaise": {"Magic Defense": [15, 3]},
        "Languor": {"Magic Evasion": [50, 5]}
    };

    var SPELLS = {"Haste": {"Magic Haste": 150 / 1024}, "Haste II": {"Magic Haste": 307 / 1024}};
    ["Fire:STR", "Thunder:DEX", "Sand:VIT", "Wind:AGI", "Hail:INT", "Rain:MND", "Aurora:CHR"].forEach(function (p) {
        var kv = p.split(":"), o = {}; o[kv[1]] = 7;
        SPELLS[kv[0] + "storm II"] = o;
    });
    SPELLS["Voidstorm II"] = {};
    ATTRIBUTES.forEach(function (st) { SPELLS["Voidstorm II"][st] = 3; });
    var SHELL_V = {"MDT": -29};
    var DIA = {"Dia": 104 / 1024, "Dia II": 156 / 1024, "Dia III": 208 / 1024};
    var LIGHT_SHOT = 28 / 1024;
    // food Attack counts after the Attack % (its own name in both engines)
    var FOOD_NAMES = {"Attack": "Food Attack", "Ranged Attack": "Food Ranged Attack"};

    function add(group, stat, value) { group[stat] = (group[stat] || 0) + value; }

    function songs(sel, out) {
        var list = sel.songs || {}, mul = sel.soul_voice ? 2 : 1;
        Object.keys(list).forEach(function (slot) {
            var name = list[slot], song = SONGS[name];
            if (!song) return;
            var marcato = slot === "Song1" && sel.marcato ? 1.5 : 1;
            Object.keys(song).forEach(function (stat) {
                var steps = song[stat], plus = Math.min(steps.length - 1, Math.max(0, Math.trunc(+sel.song_bonus || 0)));
                var v = steps[plus] + (/^Minuet/.test(name) && /Attack$/.test(stat) ? MINUET_MERITS : 0);
                if (stat === "Magic Haste") v /= 1024;
                add(out, stat, mul * marcato * v);
            });
        });
        ["Attack", "Ranged Attack"].forEach(function (k) { out[k] = Math.trunc(out[k] || 0); });
    }

    // every roll given gets the job bonus and Crooked Cards asked (the page calls this once a roll)
    function rolls(sel, out) {
        var list = sel.rolls || {}, plus = Math.trunc(+sel.roll_bonus || 0), cc = sel.crooked ? 1.2 : 1;
        Object.keys(list).forEach(function (slot) {
            var roll = ROLLS[String(list[slot].name).trim().split(/\s+/)[0]], n = ROLL_NUMBERS.indexOf(list[slot].potency);
            if (!roll || n < 0) return;
            var v = cc * (roll.values[n] + plus * roll.plus + (sel.job_bonus ? roll.job : 0));
            roll.stats.forEach(function (stat) { add(out, stat, v); });
        });
    }

    function bubbles(sel, out, foe) {
        var list = sel.bubbles || {}, potency = Math.max(0, (sel.bubble_potency == null ? 100 : sel.bubble_potency) / 100);
        Object.keys(list).forEach(function (slot) {
            var name = String(list[slot]).split("-").pop(), plus = slot === "Entrust-" ? 0 : Math.trunc(+sel.bubble_bonus || 0);
            var fx = BUBBLES[name] || FOE_BUBBLES[name], onFoe = !BUBBLES[name];
            if (!fx) return;
            Object.keys(fx).forEach(function (stat) {
                var v = fx[stat][0] + plus * fx[stat][1];
                if (onFoe) add(foe, stat, v * potency); else add(out, stat, v);
            });
        });
    }

    function spells(sel, out, foe) {
        var list = sel.whm_spells || {};
        Object.keys(list).forEach(function (slot) {
            var fx = SPELLS[list[slot]] || {};
            Object.keys(fx).forEach(function (stat) { add(out, stat, fx[stat]); });
        });
        if (DIA[list.Dia]) {
            add(foe, "Defense", DIA[list.Dia]);
            if (sel.light_shot) add(foe, "Defense", LIGHT_SHOT);
        }
    }

    function food(sel, out) {
        Object.keys(sel.food || {}).forEach(function (stat) {
            if (stat !== "Name" && stat !== "Name2" && stat !== "Type") add(out, FOOD_NAMES[stat] || stat, sel.food[stat]);
        });
    }

    CALC.aggregateBuffs = function (sel) {
        var buffs = {brd: {}, cor: {}, geo: {}, whm: {}, food: {}}, foe = {};
        if (sel.brd) songs(sel, buffs.brd);
        else buffs.brd = {"Attack": 0, "Ranged Attack": 0};
        if (sel.cor) rolls(sel, buffs.cor);
        if (sel.geo) bubbles(sel, buffs.geo, foe);
        if (sel.whm) spells(sel, buffs.whm, foe);
        if (sel.shell5) add(buffs.whm, "MDT", SHELL_V.MDT);
        if (sel.food) food(sel, buffs.food);
        return [buffs, foe];
    };
    CALC.BUFF_TABLES = {SONGS: SONGS, ROLLS: ROLLS, BUBBLES: BUBBLES, FOE_BUBBLES: FOE_BUBBLES, SPELLS: SPELLS, DIA: DIA};
});
