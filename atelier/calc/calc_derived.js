// Atelier calculation engine, stage 1: the stats worked out from the others.
// Accuracy, attack and evasion from attributes and skill; haste and attack delay.
//
//   CALC.accuracyFromSkill(skill)        accuracy a combat skill is worth
//   CALC.evasionFromSkill(skill)         evasion the evasion skill is worth
//   CALC.meleeAccuracy(dex, skill, acc)  accuracy of one hand
//   CALC.meleeAttack(...)                attack of one hand
//   CALC.evasion(agi, skill, bonus)      evasion
//   CALC.gearHaste(percent)              equipment haste as a fraction, as the game stores it
//   CALC.delayReduction(...)             share of the attack delay removed by Dual Wield and haste
//
// @file    atelier/calc/calc_derived.js
// @author  ejouanchicot
(globalThis.CALC_PARTS = globalThis.CALC_PARTS || []).push(function (CALC) {
    // https://www.bg-wiki.com/ffxi/Accuracy
    //   Skill <= 200: Accuracy = Skill
    //   201 to 400:   floor((Skill - 200) x 0.9) + 200
    //   401 to 600:   floor((Skill - 400) x 0.8) + 380
    //   601 and up:   floor((Skill - 600) x 0.9) + 540
    CALC.accuracyFromSkill = function (skill) {
        if (skill <= 200) return skill;
        if (skill <= 400) return Math.floor((skill - 200) * 0.9) + 200;
        if (skill <= 600) return Math.floor((skill - 400) * 0.8) + 380;
        return Math.floor((skill - 600) * 0.9) + 540;
    };

    // https://www.bg-wiki.com/ffxi/Accuracy
    //   Total Accuracy = floor(DEX x 0.75) + Accuracy from Skill + Accuracy from traits, gear...
    CALC.meleeAccuracy = function (dex, skill, bonus) {
        return Math.floor(dex * 0.75) + CALC.accuracyFromSkill(skill) + bonus;
    };

    // STR to attack by the way the weapon is held, since December 2018:
    // two-handed 1.0, one-handed main 1.0, one-handed off-hand 0.5, hand-to-hand 0.75
    // https://www.bg-wiki.com/ffxi/Strength (table "History of STR to Attack and Ranged Attack Ratio")
    CALC.STR_TO_ATTACK = {main: 1, twoHanded: 1, offHand: 0.5, handToHand: 0.75};

    // https://www.bg-wiki.com/ffxi/Attack
    //   Attack = 8 + Combat Skill + STR            (main hand)
    //   Attack (1H sub) = 8 + Combat Skill + floor(STR / 2)
    // The page gives no rounding for the hand-to-hand ratio, nor for the percentage bonuses
    // (Smite, Chaos Roll, Fury...): they are applied to the whole and left unrounded.
    CALC.meleeAttack = function (str, skill, flat, percent, hold) {
        var ratio = CALC.STR_TO_ATTACK[hold];
        var fromStr = hold === "offHand" ? Math.floor(str * ratio) : str * ratio;
        return (8 + skill + fromStr + flat) * (1 + percent);
    };

    // https://www.bg-wiki.com/ffxi/Evasion
    //   Skill <= 200: Evasion = Skill ; Skill >= 201: floor((Skill - 200) x 0.9) + 200
    // measured in game 2026-10-10 (/checkparam, every other part of the evasion read on the
    // character): skill 316 gives 304 as the page says, skill 428 gives 402 and skill 468 gives 434
    // where the page's line gives 405 and 441. A third step, 0.8 a point above 400, gives the three
    // (DIFFERENCES.md, Z); the page was not written with skills above 400 in view.
    CALC.EVASION_SKILL_STEPS = {second: 200, third: 400, secondRate: 0.9, thirdRate: 0.8};

    CALC.evasionFromSkill = function (skill) {
        var k = CALC.EVASION_SKILL_STEPS;
        if (skill <= k.second) return skill;
        var middle = Math.floor((Math.min(skill, k.third) - k.second) * k.secondRate);
        return k.second + middle + Math.floor(Math.max(0, skill - k.third) * k.thirdRate);
    };

    // https://www.bg-wiki.com/ffxi/Evasion
    //   Evasion = floor(AGI / 2) + Evasion from Skill + Evasion from traits, abilities, gear
    CALC.evasion = function (agi, skill, bonus) {
        return Math.floor(agi / 2) + CALC.evasionFromSkill(skill) + bonus;
    };

    // Haste is stored in 1024ths. Equipment: 1% on a piece is 10/1024 ("15% Haste" is 150/1024,
    // "you need 26% gear Haste to hit the 25% Haste cap").
    // Caps: equipment 256/1024, magic 448/1024, job abilities 256/1024.
    // https://www.bg-wiki.com/ffxi/Attack_Speed
    CALC.HASTE_CAP = {gear: 256 / 1024, magic: 448 / 1024, ability: 256 / 1024};
    CALC.DELAY_REDUCTION_CAP = 0.8;

    CALC.gearHaste = function (percent) {
        return percent * 10 / 1024;
    };

    // https://www.bg-wiki.com/ffxi/Attack_Speed
    //   (1 - Dual Wield) x (1024 - Equipment Haste - Magic Haste - Job Ability Haste) / 1024
    //   of the delay remains, and "80% Delay reduction cap" on the whole.
    CALC.delayReduction = function (dualWield, gear, magic, ability) {
        var haste = Math.min(gear, CALC.HASTE_CAP.gear) + Math.min(magic, CALC.HASTE_CAP.magic) +
            Math.min(ability, CALC.HASTE_CAP.ability);
        var reduction = 1 - (1 - dualWield / 100) * (1 - haste);
        return Math.min(reduction, CALC.DELAY_REDUCTION_CAP);
    };
});
