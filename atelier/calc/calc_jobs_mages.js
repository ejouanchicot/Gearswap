// Atelier calculation engine, stage 1: what each job brings (casting and support jobs).
// Same layout as calc_jobs_fighters.js; read on the BG-Wiki page of the job, named above each entry.
//
// @file    atelier/calc/calc_jobs_mages.js
// @author  ejouanchicot
(globalThis.CALC_PARTS = globalThis.CALC_PARTS || []).push(function (CALC) {
    var J = CALC.JOBS = CALC.JOBS || {};

    // https://www.bg-wiki.com/ffxi/White_Mage
    J.whm = {
        skills: {"Club": "B+", "Staff": "C+", "Throwing": "E", "Evasion": "E", "Shield": "D",
            "Divine Magic": "A", "Healing Magic": "A+", "Enhancing Magic": "C+", "Enfeebling Magic": "C"},
        traits: {"Magic Defense Bonus": [10, 30, 50, 70, 81, 91]},
        // magic defense 7+11+14+18, magic attack 3+5+6+8, magic evasion and accuracy 7+11+14+18,
        // accuracy 2+3+4+5, healing and divine magic skill 5+8+10+13
        gifts: {"Magic Defense": 50, "Magic Attack": 22, "Magic Evasion": 50, "Magic Accuracy": 50,
            "Accuracy": 14, "Healing Magic Skill": 36, "Divine Magic Skill": 36},
        // "Magic Accuracy Bonus": +1 a point
        points: {"Magic Accuracy": 20},
        merits: {}
    };

    // https://www.bg-wiki.com/ffxi/Black_Mage
    J.blm = {
        skills: {"Dagger": "D", "Scythe": "E", "Club": "C+", "Staff": "B-", "Throwing": "D", "Evasion": "E",
            "Enhancing Magic": "E", "Enfeebling Magic": "C+", "Elemental Magic": "A+", "Dark Magic": "A"},
        traits: {"Magic Attack Bonus": [10, 30, 50, 70, 81, 91], "Mag. Burst Bonus": [45, 58, 71, 84, 97],
            "Occult Acumen": [85, 95]},
        // magic defense 2+3+4+5, magic attack 7+11+14+18, magic evasion and accuracy 6+9+12+15,
        // elemental and dark magic skill 5+8+10+13, magic burst damage 5+5+6+7, magic damage 5+5+6+7
        gifts: {"Magic Defense": 14, "Magic Attack": 50, "Magic Evasion": 42, "Magic Accuracy": 42,
            "Elemental Magic Skill": 36, "Dark Magic Skill": 36, "Magic Burst Damage Trait": 23,
            "Magic Damage": 23},
        // "Magic Burst Damage Bonus" +1% a point, "Magic Accuracy Bonus" +1, "Magic Damage Bonus" +1
        points: {"Magic Burst Damage Trait": 20, "Magic Accuracy": 20, "Magic Damage": 20},
        merits: {}
    };

    // https://www.bg-wiki.com/ffxi/Red_Mage
    J.rdm = {
        skills: {"Dagger": "B", "Sword": "B", "Club": "D", "Archery": "D", "Throwing": "F", "Evasion": "D",
            "Parrying": "E", "Shield": "F", "Divine Magic": "E", "Healing Magic": "C-", "Enhancing Magic": "B+",
            "Enfeebling Magic": "A+", "Elemental Magic": "C+", "Dark Magic": "E"},
        traits: {"Fast Cast": [15, 35, 55, 76, 89], "Magic Attack Bonus": [20, 40, 86],
            "Magic Defense Bonus": [25, 45, 96], "Damage Limit+": [60], "Mag. Burst Bonus": [85, 95]},
        // magic defense and attack 4+6+8+10, magic evasion 8+12+16+20, magic accuracy 10+15+20+25,
        // accuracy 3+5+6+8, enfeebling and enhancing magic skill 5+8+10+13, enspell damage 5+5+6+7,
        // Fast Cast 2+2+2+2
        gifts: {"Magic Defense": 28, "Magic Attack": 28, "Magic Evasion": 56, "Magic Accuracy": 70, "Accuracy": 22,
            "Enfeebling Magic Skill": 36, "Enhancing Magic Skill": 36, "EnSpell Damage": 23, "Fast Cast": 8},
        // "Magic Accuracy Bonus" +1 a point, "Magic Atk. Bonus" +1 a point
        points: {"Magic Accuracy": 20, "Magic Attack": 20},
        // group 2 "Magic Accuracy" +5 a level and "En-spell Damage" +3 a level, 5 levels each
        // (10 levels for the group: https://www.bg-wiki.com/ffxi/Merit_Points)
        merits: {"Magic Accuracy": 25, "EnSpell Damage": 15}
    };

    // https://www.bg-wiki.com/ffxi/Bard
    J.brd = {
        skills: {"Dagger": "B-", "Sword": "C-", "Club": "D", "Staff": "C+", "Throwing": "E", "Evasion": "D",
            "Parrying": "E", "Singing": "C", "String Instrument": "C", "Wind Instrument": "C"},
        traits: {"Fencer": [85, 95]},
        // evasion 3+5+6+8, accuracy 2+5+6+8, magic defense 3+3+4+5, magic evasion and accuracy
        // 5+8+10+13, singing, string and wind instrument skill 5+8+10+13
        gifts: {"Evasion": 22, "Accuracy": 21, "Magic Defense": 15, "Magic Evasion": 36, "Magic Accuracy": 36,
            "Singing Skill": 36, "String Instrument Skill": 36, "Wind Instrument Skill": 36},
        points: {}, merits: {}
    };

    // https://www.bg-wiki.com/ffxi/Summoner
    J.smn = {
        skills: {"Dagger": "E", "Club": "C+", "Staff": "B", "Evasion": "E", "Summoning Magic": "A"},
        traits: {},
        // magic defense, magic evasion and evasion 3+5+6+8, summoning magic skill 5+8+10+13
        gifts: {"Magic Defense": 22, "Magic Evasion": 22, "Evasion": 22, "Summoning Magic Skill": 36},
        points: {}, merits: {}
    };

    // https://www.bg-wiki.com/ffxi/Geomancer
    J.geo = {
        skills: {"Club": "B+", "Staff": "C+", "Dagger": "C-", "Evasion": "D", "Parrying": "E",
            "Elemental Magic": "B+", "Enfeebling Magic": "C+", "Dark Magic": "C", "Geomancy": "C", "Handbell": "C"},
        traits: {},
        // magic defense 4+6+8+10, magic attack 6+9+12+15, magic evasion and accuracy 7+11+14+18,
        // geomancy, handbell, elemental and dark magic skill 5+8+10+13, magic damage 3+3+3+4
        gifts: {"Magic Defense": 28, "Magic Attack": 42, "Magic Evasion": 50, "Magic Accuracy": 50,
            "Geomancy Skill": 36, "Handbell Skill": 36, "Elemental Magic Skill": 36, "Dark Magic Skill": 36,
            "Magic Damage": 13},
        // "Magic Atk. Bonus" +1 a point, "Magic Accuracy Bonus" +1 a point
        points: {"Magic Attack": 20, "Magic Accuracy": 20},
        merits: {}
    };

    // https://www.bg-wiki.com/ffxi/Scholar (only a support job in the reference cases: its traits;
    // none of the traits counted here is learned before level 78)
    J.sch = {
        skills: {},
        traits: {"Occult Acumen": [78, 88, 98], "Mag. Burst Bonus": [79, 89, 99]},
        gifts: {}, points: {}, merits: {}, supportOnly: true
    };

    // https://www.bg-wiki.com/ffxi/Blue_Mage : "Blue Mage must select which spells and job traits
    // to go into battle with": no trait without set spells, and the input carries none.
    J.blu = {skills: {}, traits: {}, gifts: {}, points: {}, merits: {}, supportOnly: true};
});
