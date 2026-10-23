// Atelier calculation engine: the aftermath of a mage's weapon, as stats on the sheet.
//
//   CALC.AFTERMATH                       weapon -> its aftermath, by level (the 119 III versions)
//   CALC.aftermathStats(weapon, level, tp, stage)
//       the stats the aftermath adds ({"Magic Attack": 30, ...}); {} for a level that changes no stat
//       of the sheet (a mythic's Lv3: attacks twice or thrice, melee only); null for a weapon this
//       table does not hold (the page then hands the case to the engine before, as it did)
//   CALC.AFTERMATH_TP                    the TP taken when the page gives none, by level
//   CALC.PRIME_WEAPONS                   the prime weapons' names
//   CALC.meleeAftermath(weapon, level, tp, stage)
//       a melee weapon's aftermath: {stats: what it adds to the sheet, round: what it does to the auto-attack round
//       (calc_round_average.js options.aftermath) or null}; null for a weapon this table does not hold
//
// The aftermath's level comes from the TP of the weapon skill that made it: 1000~1999 Lv1, 2000~2999 Lv2,
// 3000 Lv3, one effect a level (https://wiki.ffo.jp/html/15869.html "TP 1000～1999 Lv1 / 2000～2999 Lv2 /
// 3000 Lv3", "レベルに応じて3つの効果のうちどれか1つが発動する"). Within a level the value grows with the TP.
//
// Sources, read on 2026-10-17:
//   Mythic (Laevateinn, Tupsimati, Idris, Murgleis), https://www.bg-wiki.com/ffxi/Laevateinn_(Level_119_III)
//     and the same pages of the others: Lv1 Magic Accuracy "Information Needed"; Lv2 "floor( TP÷50 - 10 )
//     Magic Attack Bonus"; Lv3 "Occasionally Attacks twice (40%) or thrice (20%)".
//     https://wiki.ffo.jp/html/15178.html (Laevateinn IL119): "Lv1アフターマスの魔命上昇値は+30~49、Lv2の
//     魔攻上昇値は+30~49": Lv1 taken as floor(TP÷50 + 10) (30 at 1000, 49 at 1999), TO CHECK IN GAME; the
//     other three only list the effects (wiki.ffo.jp 15191, 31326, 15184), the same values taken.
//   Opashoro, https://wiki.ffo.jp/html/38965.html: stage 4 "LV1で魔攻+10 魔法ダメージ+20 以降TP200で魔攻+1
//     魔法ダメージ+2 / LV2で魔攻+15 魔法ダメージ+30 以降TP66～67で魔攻+1 魔法ダメージ+2 / LV3で魔攻+30
//     魔法ダメージ+60"; stage 5 "LV1で魔攻+15 魔法ダメージ+30 以降TP100で魔攻+1… / LV2で魔攻+25 魔法ダメージ+50
//     以降TP66～67… / LV3で魔攻+40 魔法ダメージ+80". https://www.bg-wiki.com/ffxi/Opashoro_(Level_119_III):
//     Lv3 "Magic Atk. Bonus +40, Magic Damage +80" (stage 5), Lv1 and Lv2 "Information Needed";
//     https://www.bg-wiki.com/ffxi/Aftermath: stage 4 at 3000 TP "+30 MAB, +50 Magic Damage" against
//     wiki.ffo.jp's +60 (taken: +60, wiki.ffo.jp's own steps give it), TO CHECK IN GAME. No aftermath given
//     below stage 4.
//   Lorg Mor, https://wiki.ffo.jp/html/38963.html "LV1で魔法ダメージ+30 ケアル回復量+30 / LV2で…+50 / LV3で…+80"
//     (no stage said); https://www.bg-wiki.com/ffxi/Aftermath gives them to stage 4, "Stage 5: values
//     unknown": the same taken at every stage, TO CHECK IN GAME. No step by TP given.
//   Khatvanga (Aeonic), https://www.bg-wiki.com/ffxi/Aeonic_Aftermath: skillchain and magic burst bonus
//     Lv1 3 % (1000-1499 TP) / 4 % (1500-1999), Lv2 5 % +1 % each 200 TP (9 % at 2800-2999), Lv3 10 %,
//     "only applies to the Aeonic Aftermath player"; https://wiki.ffo.jp/html/15869.html: the burst part
//     "「マジックバーストダメージII+」に含まれる" (counted as Magic Burst Damage II).
//
// @file    atelier/calc/calc_aftermath.js
// @author  ejouanchicot
(globalThis.CALC_PARTS = globalThis.CALC_PARTS || []).push(function (CALC) {
    // The prime weapons, as the catalogue names them: the weapons whose stage the page reads ("Laphria IV").
    // https://www.bg-wiki.com/ffxi/Prime_Weapons, the table of the last stage ("(Level 119 III)"), read on 2026-10-22
    CALC.PRIME_WEAPONS = ["Caliburnus", "Dokoku", "Duban", "Earp", "Foenaria", "Gae Buide", "Helheim", "Kusanagi",
        "Laphria", "Lorg Mor", "Loughnashade", "Mpu Gandring", "Opashoro", "Pinaka", "Spalirisos", "Varga Purnikawa"];

    // no TP given: 85 % of the way through the level, as the engine before takes a mythic's (Lv3 is 3000)
    CALC.AFTERMATH_TP = [1850, 2850, 3000];

    function mythicMagic(level, tp) {
        if (level === 1) return {"Magic Accuracy": Math.floor(tp / 50 + 10)};
        if (level === 2) return {"Magic Attack": Math.floor(tp / 50 - 10)};
        return {};
    }

    // stage -> [Lv1 base, TP for +1 at Lv1], Lv2 base, Lv3; Magic Damage twice the Magic Attack Bonus
    var OPASHORO = {IV: {lv1: [10, 200], lv2: 15, lv3: 30}, V: {lv1: [15, 100], lv2: 25, lv3: 40}};
    function opashoro(level, tp, stage) {
        var s = OPASHORO[stage];
        if (!s) return {};
        // Lv2: +1 every 66 to 67 TP, 15 steps over 2000~2999
        var mab = level === 1 ? s.lv1[0] + Math.floor((tp - 1000) / s.lv1[1])
            : level === 2 ? s.lv2 + Math.floor((tp - 2000) * 3 / 200) : s.lv3;
        return {"Magic Attack": mab, "Magic Damage": 2 * mab};
    }

    function lorgMor(level) {
        var v = [30, 50, 80][level - 1];
        return {"Magic Damage": v, "Cure Potency": v};
    }

    function khatvanga(level, tp) {
        var v = level === 1 ? (tp < 1500 ? 3 : 4) : level === 2 ? 5 + Math.floor((tp - 2000) / 200) : 10;
        return {"Magic Burst Damage II": v};
    }

    CALC.AFTERMATH = {Laevateinn: mythicMagic, Tupsimati: mythicMagic, Idris: mythicMagic, Murgleis: mythicMagic,
        Opashoro: opashoro, "Lorg Mor": lorgMor, Khatvanga: khatvanga};

    // Melee aftermaths, read on 2026-10-23 (DIFFERENCES.md AL):
    // https://www.bg-wiki.com/ffxi/Relic_Aftermath (last edited 2021-01-14), the "119 III" table, "Potency is constant
    //   regardless of TP": Spharai "Subtle Blow+10 / Kick Attacks+15%", Mandau "Critical Hit Rate+5% / Critical Hit
    //   Damage+5%", Ragnarok "Critical Hit Rate+10% / Accuracy+15", Guttler "Attack+10%", Apocalypse "Haste+10%" (Job
    //   Ability) "/ Accuracy+15", Gungnir "Attack+5% / Double Attack+5%", Kikoku "Subtle Blow+10 / Attack+10%",
    //   Amanomurakumo "Store TP+10 / Zanshin+10%", Mjollnir "Accuracy+20 / Magic Accuracy+20"; Excalibur, Bravura and
    //   Claustrum give regen, refresh or damage taken only: nothing on this sheet
    var RELIC = {Spharai: {"Kick Attacks": 15, "Subtle Blow": 10}, Mandau: {"Crit Rate": 5, "Crit Damage": 5},
        Ragnarok: {"Crit Rate": 10, Accuracy: 15}, Guttler: {"Attack%": 0.1}, Apocalypse: {"JA Haste": 0.1, Accuracy: 15},
        Gungnir: {"Attack%": 0.05, DA: 5}, Kikoku: {"Attack%": 0.1, "Subtle Blow": 10}, Amanomurakumo: {"Store TP": 10, Zanshin: 10},
        Mjollnir: {Accuracy: 20, "Magic Accuracy": 20}, Excalibur: {}, Bravura: {}, Claustrum: {}};
    // https://www.bg-wiki.com/ffxi/Mythic_Aftermath "(95~119/III)": Accuracy 30~49, Attack 40~99, "Occasionally attacks
    //   twice or thrice | 40% 2x 20% 3x"; each weapon's (Level 119 III) page: Lv1 "floor( TP÷50 + 10 ) Accuracy", Lv2
    //   "floor( TP×0.06 - 80 ) Attack". Nirvana's page writes ÷10 + 20 and ×0.6, out of the table's own 30~49 and
    //   40~99: the table's formulas taken. Kenkonken's Lv3 is "(Offhand Only)": its second fist's (calc_round_swings.js).
    //   The levels BG Wiki marks "?" (Tizona Lv2, Carnwenhan and Yagrush Lv1, Gastraphetes Lv1 / Lv2): the
    //   Mythic_Aftermath table's 30~49 / 40~99 with the formulas of the same table's other weapons, as LandSandBoat's
    //   scripts/globals/aftermath.lua writes them (Tizona Lv2 "MACC math.floor(tp / 50 - 10)", Carnwenhan / Yagrush Lv1
    //   "MACC math.floor(tp / 50 + 10)" and Lv2 "ACC math.floor(tp / 50 - 10)", where BG's Lv2 "TP÷10 + 10" would give
    //   210, "Verification Needed"); a ranged mythic's Lv3 doubles or triples its shots' damage: nothing for a melee round
    var ACC1 = function (tp) { return Math.floor(tp / 50 + 10); }, LV2 = function (tp) { return Math.floor(tp / 50 - 10); };
    var ATT2 = function (tp) { return Math.floor(tp * 0.06 - 80); };
    var MYTHIC = {Tizona: [["Accuracy", ACC1], ["Magic Accuracy", LV2]], Carnwenhan: [["Magic Accuracy", ACC1], ["Accuracy", LV2]],
        Yagrush: [["Magic Accuracy", ACC1], ["Accuracy", LV2]], "Death Penalty": [["Ranged Accuracy", ACC1], ["Ranged Attack", ATT2]],
        Gastraphetes: [["Ranged Accuracy", ACC1], ["Ranged Attack", ATT2]]};
    ["Conqueror", "Glanzfaust", "Vajra", "Burtgang", "Liberator", "Aymur", "Kogarasumaru", "Nagi", "Nirvana", "Ryunohige",
        "Terpsichore", "Epeolatry", "Kenkonken"].forEach(function (w) { MYTHIC[w] = [["Accuracy", ACC1], ["Attack", ATT2]]; });
    var RANGED_MYTHIC = ["Death Penalty", "Gastraphetes"];
    function mythicMelee(weapon, level, tp) {
        if (level < 3) {
            var stats = {}, e = MYTHIC[weapon][level - 1];
            stats[e[0]] = e[1](tp);
            return {stats: stats, round: null};
        }
        if (RANGED_MYTHIC.indexOf(weapon) !== -1) return {stats: {}, round: null};
        return {stats: {}, round: {type: "mythic", level: 3, offhandOnly: weapon === "Kenkonken"}};
    }
    // https://www.bg-wiki.com/ffxi/Empyrean_Aftermath (last edited 2026-05-24) "Occ. Triples Damage (Level 119 III)":
    //   30 / 40 / 50 % by level, the rate in calc_round_damage.js; Verethragna's (Level 119 III) "30%/40%/50% Triple
    //   Damage on offhand (first hit only)", "it can only trigger on the first offhand hit of every attack round"
    //   (FFXIclopedia, Verethragna 119-3): its second fist's first swing (calc_round_average.js)
    var EMPYREAN = ["Twashtar", "Almace", "Caladbolg", "Farsha", "Ukonvasara", "Redemption", "Kannagi", "Rhongomiant",
        "Gambanteinn", "Masamune", "Hvergelmir"];
    // https://www.bg-wiki.com/ffxi/Aftermath (last edited 2026-08-23): prime melee and ranged weapons "scale the PDL+
    //   amount from 1000 to 3000 TP in a linear fashion"; "Stage 3 = 2% to 8%", "Stage 4 = 4% to 10%", "Stage 5 = 6%
    //   to 12%" (stage 5 = "(Level 119 III)", Category:Prime Weapons), from an FFXIAH test
    var PRIME_PDL = {III: [2, 8], IV: [4, 10], V: [6, 12]};
    var PRIME_MAGIC = ["Lorg Mor", "Opashoro", "Duban", "Loughnashade"];
    // https://www.bg-wiki.com/ffxi/Aeonic_Aftermath : skillchain and magic burst bonus, Ultimate Skillchain, "180 Seconds";
    //   wiki.ffo.jp 34909 the same: nothing for a melee round or a weapon skill alone (Khatvanga's burst part:
    //   CALC.AFTERMATH). The weapons: BG Category:Aeonic_Weapons
    var AEONIC = ["Godhands", "Aeneas", "Sequence", "Lionheart", "Tri-edge", "Chango", "Anguta", "Trishula", "Heishi Shorinken",
        "Dojikiri Yasutsuna", "Tishtrya", "Khatvanga", "Fail-Not", "Fomalhaut"];

    CALC.meleeAftermath = function (weapon, level, tp, stage) {
        level = Math.max(1, Math.min(3, Math.round(level || 0)));
        var lo = [1000, 2000, 3000][level - 1], hi = [1999, 2999, 3000][level - 1];
        var at = tp >= lo && tp <= hi ? tp : CALC.AFTERMATH_TP[level - 1];
        if (RELIC[weapon]) return {stats: RELIC[weapon], round: null};
        if (MYTHIC[weapon]) return mythicMelee(weapon, level, at);
        if (EMPYREAN.indexOf(weapon) !== -1) return {stats: {}, round: {type: "empyrean", level: level, multiplier: 3}};
        if (weapon === "Verethragna") return {stats: {}, round: {type: "empyrean", level: level, multiplier: 3, offhandFirst: true}};
        if (AEONIC.indexOf(weapon) !== -1) return {stats: {}, round: null};
        if (CALC.PRIME_WEAPONS.indexOf(weapon) !== -1 && PRIME_MAGIC.indexOf(weapon) === -1) {
            var range = PRIME_PDL[stage || "V"];
            if (!range) return null;
            return {stats: {PDL: range[0] + (range[1] - range[0]) * (at - 1000) / 2000}, round: null};
        }
        return null;
    };

    CALC.aftermathStats = function (weapon, level, tp, stage) {
        var f = CALC.AFTERMATH[weapon];
        if (!f) return null;
        level = Math.max(1, Math.min(3, Math.round(level || 0)));
        // the TP inside the level's range (a TP chosen for another level is not this one's)
        var lo = [1000, 2000, 3000][level - 1], hi = [1999, 2999, 3000][level - 1];
        var at = tp >= lo && tp <= hi ? tp : CALC.AFTERMATH_TP[level - 1];
        return f(level, at, stage || "V");
    };
});
