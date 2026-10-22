// Atelier calculation engine: the aftermath of a mage's weapon, as stats on the sheet.
//
//   CALC.AFTERMATH                       weapon -> its aftermath, by level (the 119 III versions)
//   CALC.aftermathStats(weapon, level, tp, stage)
//       the stats the aftermath adds ({"Magic Attack": 30, ...}); {} for a level that changes no stat
//       of the sheet (a mythic's Lv3: attacks twice or thrice, melee only); null for a weapon this
//       table does not hold (the page then hands the case to the engine before, as it did)
//   CALC.AFTERMATH_TP                    the TP taken when the page gives none, by level
//   CALC.PRIME_WEAPONS                   the prime weapons' names
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
