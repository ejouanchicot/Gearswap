// Atelier calculation engine, stage 1: what each job brings (melee and ranged jobs).
// For a job: its skill ranks, the level each tier of its job traits is learned at, the total of
// its job point gifts (2100 job points spent), its job point categories (20 points each) and its
// job merits. Read on the BG-Wiki page of the job, named above each entry.
//
//   CALC.JOBS[job] = {skills, traits, gifts, points, merits, behind}
//     skills   skill name -> rank
//     traits   trait name -> level of tier I, II, III...
//     gifts    stat -> total of the gifts
//     points   stat -> total of a job point category at 20 points
//     merits   stat -> total of the job merit points taken as bought
//     behind   stat -> bonus that only counts from behind the target
//
// @file    atelier/calc/calc_jobs_fighters.js
// @author  ejouanchicot
(globalThis.CALC_PARTS = globalThis.CALC_PARTS || []).push(function (CALC) {
    var J = CALC.JOBS = CALC.JOBS || {};

    // https://www.bg-wiki.com/ffxi/Warrior
    J.war = {
        skills: {"Great Axe": "A+", "Axe": "A", "Great Sword": "B+", "Scythe": "B+", "Staff": "B", "Sword": "B",
            "Club": "B-", "Dagger": "B-", "Polearm": "B-", "Hand-to-Hand": "D", "Archery": "D",
            "Marksmanship": "D", "Throwing": "D", "Shield": "C+", "Evasion": "C", "Parrying": "C-"},
        traits: {"Double Attack": [25, 50, 75, 85, 99], "Attack Bonus": [30, 65, 91], "Smite": [35, 65, 95],
            "Damage Limit+": [40, 80], "Fencer": [45, 58, 71, 84, 97], "Crit. Atk. Bonus": [78, 86]},
        // attack 10+15+20+25, evasion and accuracy 5+8+10+13, Fencer 50+50+60+70 TP Bonus,
        // critical hit 5+5, Double Attack 2+2+3+3, critical damage 2+2+3+3, weapon skill damage 3
        gifts: {"Attack": 70, "Evasion": 36, "Accuracy": 36, "Magic Evasion": 36, "Magic Accuracy": 36,
            "Fencer TP Bonus": 230, "Crit Rate": 10, "DA": 10, "Crit Damage": 10, "Weapon Skill Damage": 3},
        // "Double Attack Effect": +1 physical attack a point
        points: {"DA Attack": 20},
        // group 1 "Double Attack Rate": +1% a level, 5 levels
        merits: {"DA": 5}
    };

    // https://www.bg-wiki.com/ffxi/Thief
    J.thf = {
        skills: {"Hand-to-Hand": "E", "Dagger": "A+", "Sword": "D", "Club": "E", "Archery": "C-",
            "Marksmanship": "C+", "Throwing": "D", "Evasion": "A+", "Parrying": "A", "Shield": "F"},
        traits: {"Evasion Bonus": [10, 30, 50, 70, 76, 88], "Triple Attack": [55, 95], "Damage Limit+": [50],
            "Crit. Atk. Bonus": [78, 84, 91, 97], "Dual Wield": [83, 90, 98]},
        // attack 7+11+14+18, evasion 10+15+20+25, accuracy 5+8+10+13, Triple Attack 2+2+2+2,
        // critical damage 2+2+2+2, Dual Wield 5
        gifts: {"Attack": 50, "Evasion": 70, "Accuracy": 36, "Magic Evasion": 36, "Magic Accuracy": 36,
            "TA": 8, "Crit Damage": 8, "Dual Wield": 5},
        // "Sneak Attack Effect" +1% DEX, "Trick Attack Effect" +1% AGI, "Triple Attack Effect" +1 attack
        points: {"Sneak Attack Bonus": 20, "Trick Attack Bonus": 20, "TA Attack": 20},
        // group 1 "Triple Attack Rate": +1% a level, 5 levels
        merits: {"TA": 5},
        // group 2 "Ambush": +3 accuracy a level from behind the target, 5 levels
        behind: {"Accuracy": 15}
    };

    // https://www.bg-wiki.com/ffxi/Paladin
    J.pld = {
        skills: {"Sword": "A+", "Club": "A", "Staff": "A", "Great Sword": "B", "Dagger": "C-", "Polearm": "E",
            "Evasion": "C", "Parrying": "C", "Shield": "A+",
            "Divine Magic": "B+", "Healing Magic": "C", "Enhancing Magic": "D"},
        traits: {},
        // attack 4+6+8+10, evasion 3+5+6+8, accuracy 4+6+8+10, magic evasion and accuracy 6+9+12+15,
        // divine magic skill 5+8+10+13
        gifts: {"Attack": 28, "Evasion": 22, "Accuracy": 28, "Magic Evasion": 42, "Magic Accuracy": 42,
            "Divine Magic Skill": 36},
        points: {}, merits: {}
    };

    // https://www.bg-wiki.com/ffxi/Dark_Knight
    J.drk = {
        skills: {"Dagger": "C", "Sword": "B-", "Great Sword": "A", "Axe": "B-", "Great Axe": "B-", "Scythe": "A+",
            "Club": "C-", "Marksmanship": "E", "Evasion": "C", "Parrying": "E",
            "Enfeebling Magic": "C", "Elemental Magic": "B+", "Dark Magic": "A"},
        traits: {"Attack Bonus": [10, 30, 50, 70, 76, 83, 91, 99], "Smite": [15, 35, 55, 75, 95],
            "Damage Limit+": [20, 40, 55, 70, 80], "Occult Acumen": [45, 58, 71, 84, 97],
            "Crit. Atk. Bonus": [85, 95]},
        // attack 15+23+30+38, evasion and accuracy 3+5+6+8, magic accuracy 6+9+12+15,
        // dark magic skill 5+8+10+13, critical damage and weapon skill damage 2+2+2+2.
        // Magic evasion: the gift table was read as 6+9+6+15 (DIFFERENCES.md, "uncertain readings").
        gifts: {"Attack": 106, "Evasion": 22, "Accuracy": 22, "Magic Evasion": 36, "Magic Accuracy": 42,
            "Dark Magic Skill": 36, "Crit Damage": 8, "Weapon Skill Damage": 8},
        points: {}, merits: {}
    };

    // https://www.bg-wiki.com/ffxi/Beastmaster
    J.bst = {
        skills: {"Dagger": "C+", "Sword": "E", "Axe": "A+", "Scythe": "B-", "Club": "D", "Evasion": "C",
            "Parrying": "C", "Shield": "E"},
        traits: {"Tandem Strike": [30, 45, 60, 75, 90], "Damage Limit+": [45, 90], "Fencer": [80, 87, 94]},
        // attack 10+15+20+25, evasion and accuracy 5+8+10+13, Fencer 50+50+60+70 TP Bonus
        gifts: {"Attack": 70, "Evasion": 36, "Accuracy": 36, "Magic Evasion": 36, "Magic Accuracy": 36,
            "Fencer TP Bonus": 230},
        points: {}, merits: {}
    };

    // https://www.bg-wiki.com/ffxi/Samurai
    J.sam = {
        skills: {"Dagger": "E", "Sword": "C+", "Polearm": "B-", "Great Katana": "A+", "Club": "E", "Archery": "C+",
            "Throwing": "C+", "Evasion": "B+", "Parrying": "A"},
        traits: {"Store TP": [10, 30, 50, 70, 90], "Zanshin": [20, 35, 50, 75, 95], "Damage Limit+": [40, 80],
            "Skillchain Bonus": [78, 88, 98]},
        // attack 10+15+20+25, evasion and accuracy 5+8+10+13, Zanshin 2+2+3+3, Store TP 2+2+2+2,
        // skillchain bonus 2+2+2+2
        gifts: {"Attack": 70, "Evasion": 36, "Accuracy": 36, "Magic Evasion": 36, "Magic Accuracy": 36,
            "Zanshin": 10, "Store TP": 8, "Skillchain Bonus": 8},
        // "Zanshin Effect": +2 physical attack a point
        points: {"Zanshin Attack": 40},
        // group 1 "Store TP Effect" +2 a level, "Zanshin Attack Rate" +1% a level, 5 levels each
        merits: {"Store TP": 10, "Zanshin": 5}
    };

    // https://www.bg-wiki.com/ffxi/Corsair
    J.cor = {
        skills: {"Dagger": "B+", "Sword": "B-", "Marksmanship": "B", "Throwing": "C+", "Evasion": "D",
            "Parrying": "A"},
        traits: {"Recycle": [35, 65, 95]},
        // attack and accuracy 5+8+10+13, evasion 3+5+6+8, magic attack 2+3+4+5, Snapshot 5+5,
        // Recycle ("reduced ammunition consumption") 2+2+2+2
        gifts: {"Attack": 36, "Evasion": 22, "Accuracy": 36, "Magic Attack": 14, "Magic Evasion": 36,
            "Magic Accuracy": 36, "Snapshot": 10, "Recycle": 8},
        // "Quick Draw Effect" +2 magic damage a point, "Ranged Accuracy Bonus" +1 a point
        points: {"Quick Draw Damage": 40, "Ranged Accuracy": 20},
        merits: {}
    };

    // https://www.bg-wiki.com/ffxi/Dancer
    J.dnc = {
        skills: {"Dagger": "A+", "Hand-to-Hand": "D", "Sword": "D", "Throwing": "C+", "Evasion": "B+",
            "Parrying": "B"},
        traits: {"Evasion Bonus": [15, 45, 75, 86], "Dual Wield": [20, 40, 60, 80], "Subtle Blow": [25, 45, 65, 86],
            "Accuracy Bonus": [30, 60, 76], "Skillchain Bonus": [45, 58, 71, 84, 97], "Damage Limit+": [45, 90],
            "Conserve TP": [77, 87, 97], "Crit. Atk. Bonus": [80, 88, 99]},
        // attack 6+9+12+15, evasion and accuracy 9+14+18+23, Subtle Blow 3+3+3+4,
        // critical damage and skillchain bonus 2+2+2+2, Dual Wield 5
        gifts: {"Attack": 42, "Evasion": 64, "Accuracy": 64, "Magic Evasion": 36, "Magic Accuracy": 36,
            "Subtle Blow": 13, "Crit Damage": 8, "Skillchain Bonus": 8, "Dual Wield": 5},
        // "Flourishes III Effect" +1% charisma bonus a point; "Flourish II Effect": Building Flourish
        // +1% weapon skill damage a point
        points: {"Flourish CHR%": 20, "Building Flourish WSD": 20},
        merits: {}
    };

    // https://www.bg-wiki.com/ffxi/Rune_Fencer
    J.run = {
        skills: {"Great Sword": "A+", "Sword": "A", "Great Axe": "B", "Axe": "B-", "Club": "C-", "Parrying": "A+",
            "Evasion": "B+", "Divine Magic": "B", "Enhancing Magic": "B-"},
        traits: {"Magic Defense Bonus": [10, 30, 50, 70, 76, 91, 99], "Accuracy Bonus": [50, 70, 90]},
        // attack 7+11+14+18, evasion and accuracy 8+12+16+20, magic defense 8+12+16+20,
        // magic evasion 10+15+20+25, magic accuracy 5+8+10+13, enhancing magic skill 5+8+10+13
        gifts: {"Attack": 50, "Evasion": 56, "Accuracy": 56, "Magic Defense": 56, "Magic Evasion": 70,
            "Magic Accuracy": 36, "Enhancing Magic Skill": 36},
        // "Swipe Effect": damage of Swipe and Lunge, +1% a point
        points: {"Lunge Bonus": 20},
        merits: {}
    };

    // https://www.bg-wiki.com/ffxi/Dragoon (only a support job in the reference cases: its traits)
    J.drg = {
        skills: {},
        traits: {"Attack Bonus": [10, 91], "Accuracy Bonus": [30, 60, 76], "Damage Limit+": [30, 60, 90],
            "Smite": [40, 80], "Conserve TP": [45, 58, 71, 84, 97], "WS Damage Boost": [45, 55, 65, 75, 85, 95]},
        gifts: {}, points: {}, merits: {}, supportOnly: true
    };
});
