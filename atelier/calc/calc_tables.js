// Atelier calculation engine, stage 1 (character stats): the tables every job shares.
// Skill caps by rank, the value of each tier of a job trait, the merit points that
// every job can buy. Every number below was read on the BG-Wiki page named beside it.
//
//   CALC.SKILL_CAP_99      skill cap at level 99 for a rank ("A+" ... "F")
//   CALC.TRAIT_TIERS       value of each tier of a job trait, tier I first
//   CALC.COMMON_MERITS     merit points shared by every job, all bought
//   CALC.subJobLevel(ml)   level of the support job for a master level
//
// @file    atelier/calc/calc_tables.js
// @author  ejouanchicot
(globalThis.CALC_PARTS = globalThis.CALC_PARTS || []).push(function (CALC) {
    // Skill cap at level 99 by rank.
    // https://www.bg-wiki.com/ffxi/Combat_Skills (progression table, level 99 row)
    // The job pages give the same caps for magic skills (PLD Divine B+ 404, WHM Healing A+ 424...).
    CALC.SKILL_CAP_99 = {
        "A+": 424, "A": 417, "B+": 404, "B": 398, "B-": 388, "C+": 378, "C": 373, "C-": 368,
        "D": 334, "E": 300, "F": 265
    };

    // "Every Master Level earned grants 1 skill level above the listed caps for all weapons that
    // a job has ranking in" (Combat_Skills); "+1 to the cap of Combat Skills and Magic Skills per
    // level", "+1 STR, DEX, VIT, AGI, INT, MND, and CHR per level" (Master_Levels).
    // https://www.bg-wiki.com/ffxi/Master_Levels
    CALC.MASTER_LEVEL = {skillPerLevel: 1, attributePerLevel: 1};

    // "Support Job = 49 + floor(Master Level/5)"
    // https://www.bg-wiki.com/ffxi/Support_Job
    CALC.subJobLevel = function (ml) {
        return 49 + Math.floor((ml || 0) / 5);
    };

    // Merit points every job can buy, taken as all bought (the character is mastered).
    // https://www.bg-wiki.com/ffxi/Merit_Points
    //   Attributes: +1 per level, 15 levels an attribute, 105 for the category = 7 x 15
    //   Combat Skills: +2 per level, 8 levels a skill, 152 for the category = 19 x 8
    //   Magic Skills: +2 per level, 8 levels a skill, 112 for the category = 14 x 8
    //   Critical Hit Rate: +1% per level, 5 levels
    CALC.COMMON_MERITS = {attribute: 15, skill: 16, critRate: 5};

    // Base critical hit rate: "the base rate (5%)".
    // https://www.bg-wiki.com/ffxi/Critical_Hit_Rate
    CALC.BASE_CRIT_RATE = 5;

    // Value of each tier of a job trait, tier I first.
    CALC.TRAIT_TIERS = {
        // https://www.bg-wiki.com/ffxi/Attack_Bonus
        "Attack Bonus": [10, 22, 35, 48, 60, 72, 84, 96],
        // https://www.bg-wiki.com/ffxi/Accuracy_Bonus ("includes both accuracy and ranged accuracy")
        "Accuracy Bonus": [10, 22, 35, 48, 60, 73],
        // https://www.bg-wiki.com/ffxi/Evasion_Bonus
        "Evasion Bonus": [10, 22, 35, 48, 60, 72],
        // https://www.bg-wiki.com/ffxi/Magic_Attack_Bonus
        "Magic Attack Bonus": [20, 24, 28, 32, 36, 40],
        // https://www.bg-wiki.com/ffxi/Magic_Defense_Bonus
        "Magic Defense Bonus": [10, 12, 14, 16, 18, 20, 22],
        // https://www.bg-wiki.com/ffxi/Double_Attack (tiers VI and up are the Warrior gifts)
        "Double Attack": [10, 12, 14, 16, 18],
        // https://www.bg-wiki.com/ffxi/Triple_Attack
        "Triple Attack": [5, 6],
        // https://www.bg-wiki.com/ffxi/Dual_Wield (tier V of DNC and IV of THF are their gifts)
        "Dual Wield": [10, 15, 25, 30, 35, 40],
        // https://www.bg-wiki.com/ffxi/Subtle_Blow (tiers I to IV; the later ones are gifts)
        "Subtle Blow": [5, 10, 15, 20, 25],
        // https://www.bg-wiki.com/ffxi/Skillchain_Bonus
        "Skillchain Bonus": [8, 12, 16, 20, 23],
        // https://www.bg-wiki.com/ffxi/Critical_Attack_Bonus
        "Crit. Atk. Bonus": [5, 8, 11, 14],
        // https://www.bg-wiki.com/ffxi/Smite : 25/256, 38/256, 51/256, 64/256, 76/256
        "Smite": [25 / 256, 38 / 256, 51 / 256, 64 / 256, 76 / 256],
        // https://www.bg-wiki.com/ffxi/Store_TP
        "Store TP": [10, 15, 20, 25, 30],
        // https://www.bg-wiki.com/ffxi/Zanshin (tier VI is the Samurai gifts)
        "Zanshin": [15, 25, 35, 45, 50],
        // https://www.bg-wiki.com/ffxi/Occult_Acumen (TP per 100 MP)
        "Occult Acumen": [25, 50, 75, 100, 125],
        // https://www.bg-wiki.com/ffxi/Magic_Burst_Bonus
        "Mag. Burst Bonus": [5, 7, 9, 11, 13],
        // https://www.bg-wiki.com/ffxi/Conserve_TP
        "Conserve TP": [15, 18, 21, 24, 26],
        // https://www.bg-wiki.com/ffxi/Recycle (tiers IV to VII are the Corsair gifts)
        "Recycle": [10, 20, 30],
        // https://www.bg-wiki.com/ffxi/Damage_Limit%2B : +26/256, +51/256, +77/256, +102/256,
        // +128/256 of pDIF cap, kept here in percent like the gear's "PDL"
        "Damage Limit+": [26 / 256 * 100, 51 / 256 * 100, 77 / 256 * 100, 102 / 256 * 100, 128 / 256 * 100],
        // https://www.bg-wiki.com/ffxi/WS_Damage_Boost
        "WS Damage Boost": [7, 10, 13, 16, 19, 21],
        // https://www.bg-wiki.com/ffxi/Tandem_Strike (accuracy and magic accuracy, master and pet
        // on the same enemy)
        "Tandem Strike": [10, 20, 30, 40, 50],
        // https://www.bg-wiki.com/ffxi/Fast_Cast (tiers VI to IX are the Red Mage gifts)
        "Fast Cast": [10, 15, 20, 25, 30]
    };

    // Fencer by rank (job trait tiers plus the ranks gear adds, 8 at most): TP Bonus and
    // critical hit rate, "when wielding with the main hand only".
    // https://www.bg-wiki.com/ffxi/Fencer
    CALC.FENCER = {
        tpBonus: [200, 300, 400, 450, 500, 550, 600, 630],
        critRate: [3, 5, 7, 9, 10, 11, 12, 13]
    };

    // Tier of a trait at a level: `levels` holds the level each tier is learned at.
    CALC.traitTier = function (levels, level) {
        var tier = 0;
        (levels || []).forEach(function (at) { if (level >= at) tier += 1; });
        return tier;
    };
});
