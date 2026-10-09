// Atelier calculation engine, stage 2: what each weapon skill's BG-Wiki page says.
// Read on 2026-10-09, one page per weapon skill (address in `url`). An entry only holds what
// the page states; anything absent falls back on our database (calc_ws_table.js). Where the
// page and our database disagree the page wins, and DIFFERENCES.md lists the disagreement.
//
//   mods         attribute modifiers in percent. Merit weapon skills read "73~85%": 85 is
//                the value "at 5/5" merits, the assumption of stage 1 (every merit bought)
//   ftp          [at 1000 TP, at 2000, at 3000]; one number on the page = the same at every TP
//   hits         number of hits of the weapon skill itself
//   replicating  true when the page says "This is an fTP replicating weaponskill"
//   crit         critical hit rate added at 1000 / 2000 / 3000 TP, in percent
//   attack       attack multiplier at 1000 / 2000 / 3000 TP ("Attack Modifier: 1.5" = 1.5 at
//                every TP; "+100%" = 2; "-20%" = 0.8)
//   weapons      main hand weapons that raise this weapon skill's damage on every hit: the
//                multipliers, in the order they apply ("Savage Blade" damage +15% = [1.15]).
//                The weapon is named as our gear names it; "R15" = augment at rank 15
//   ignoreDefense share of the enemy's defense ignored at 1000 / 2000 / 3000 TP
//   unverified   what the page itself marks "Verification Needed" or gives with a question mark
//   missing      what the page does not give and the engine needs: such a weapon skill is
//                computed with our database's value, and the checker says so
//
// @file    atelier/calc/calc_ws_details.js
// @author  ejouanchicot
(globalThis.CALC_PARTS = globalThis.CALC_PARTS || []).push(function (CALC) {
    var U = "https://www.bg-wiki.com/ffxi/";
    function same(v) { return [v, v, v]; }

    CALC.WS_DETAILS = {
        // Sword
        "Circle Blade": {url: U + "Circle_Blade", mods: {STR: 100}, ftp: same(1)},
        "Fast Blade": {url: U + "Fast_Blade", mods: {STR: 40, DEX: 40}, ftp: [1, 3, 5], hits: 2},
        "Fast Blade II": {url: U + "Fast_Blade_II", mods: {DEX: 80}, ftp: [1.8, 3.5, 5], hits: 2, replicating: true},
        "Requiescat": {url: U + "Requiescat", mods: {MND: 85}, ftp: same(1), hits: 5, replicating: true,
            attack: [0.8, 0.9, 1]},
        "Savage Blade": {url: U + "Savage_Blade", mods: {STR: 50, MND: 50}, ftp: [4, 10.25, 13.75], hits: 2,
            weapons: {"Naegling": [1.15], "Kaja Sword": [1.15]}},
        "Swift Blade": {url: U + "Swift_Blade", mods: {STR: 50, MND: 50}, ftp: same(1.5), hits: 3, replicating: true,
            missing: "accuracy by TP"},
        "Chant du Cygne": {url: U + "Chant_du_Cygne", mods: {DEX: 80}, ftp: same(1.6328125), hits: 3,
            replicating: true, crit: [15, 25, 40]},
        "Knights of Round": {url: U + "Knights_of_Round", mods: {STR: 40, MND: 40}, ftp: same(5)},
        "Death Blossom": {url: U + "Death_Blossom", mods: {MND: 50, STR: 30}, ftp: same(4), hits: 3},
        // Club
        "Black Halo": {url: U + "Black_Halo", mods: {MND: 70, STR: 30}, ftp: [3, 7.25, 9.75], hits: 2,
            weapons: {"Maxentius": [1.5], "Kaja Rod": [1.5]}},
        "Dagda": {url: U + "Dagda", hits: 2, missing: "attribute modifiers and fTP (\"Information Needed\")"},
        // https://www.bg-wiki.com/ffxi/Idris_(Level_119_III) : rank 15 augment "Exudation: Damage +15%"
        "Exudation": {url: U + "Exudation", mods: {INT: 50, MND: 50}, ftp: same(2.8), attack: [1.5, 3.625, 4.75],
            weapons: {"Idris R15": [1.15]}},
        "Hexa Strike": {url: U + "Hexa_Strike", mods: {STR: 30, MND: 30}, ftp: same(1.125), hits: 6, replicating: true,
            crit: [10, null, 25], unverified: "critical hit rate: nothing at 2000 TP, \">= 25%\" at 3000 TP"},
        "Judgment": {url: U + "Judgment", mods: {STR: 50, MND: 50}, ftp: [3.5, 8.75, 12], hits: 1},
        "Randgrith": {url: U + "Randgrith", mods: {STR: 40, MND: 40}, ftp: same(4.25)},
        "Realmrazer": {url: U + "Realmrazer", mods: {MND: 85}, ftp: same(0.9), hits: 7, replicating: true,
            missing: "accuracy by TP"},
        "Skullbreaker": {url: U + "Skullbreaker", mods: {STR: 100}, ftp: same(1)},
        "True Strike": {url: U + "True_Strike", mods: {STR: 100}, ftp: same(1), crit: same(100), attack: same(2),
            missing: "accuracy penalty (\"Large Penalty\", no number)"},
        "Mystic Boon": {url: U + "Mystic_Boon", mods: {MND: 70, STR: 30}, ftp: [2.5, 4, 7]},
        // Staff
        "Full Swing": {url: U + "Full_Swing", mods: {STR: 50}, ftp: [1, 3, 9], hits: 1},
        "Gate of Tartarus": {url: U + "Gate_of_Tartarus", mods: {INT: 80}, ftp: same(3)},
        "Heavy Swing": {url: U + "Heavy_Swing", mods: {STR: 100}, ftp: [1, 2, 3], hits: 1},
        "Oshala": {url: U + "Oshala", mods: {MND: 45, INT: 45}, ftp: [3.95, 7.89, 11.84]},
        "Retribution": {url: U + "Retribution", mods: {MND: 50, STR: 30}, ftp: [2, 3, 5], hits: 1, attack: same(1.5)},
        "Shattersoul": {url: U + "Shattersoul", mods: {INT: 85}, ftp: same(1.375), hits: 3},
        "Shell Crusher": {url: U + "Shell_Crusher", mods: {STR: 100}, ftp: same(1)},
        // Axe
        "Blitz": {url: U + "Blitz", mods: {STR: 32, DEX: 32}, ftp: [1.5, 7, 12.5], hits: 5},
        "Bora Axe": {url: U + "Bora_Axe", mods: {DEX: 100}, ftp: same(4.5)},
        "Calamity": {url: U + "Calamity", mods: {STR: 50, VIT: 50}, ftp: [2.5, 6.5, 10.375], hits: 1},
        "Decimation": {url: U + "Decimation", mods: {STR: 50}, ftp: same(1.75), hits: 3, replicating: true,
            missing: "accuracy by TP"},
        "Mistral Axe": {url: U + "Mistral_Axe", mods: {STR: 50}, ftp: [4, 10.5, 13.625], hits: 1},
        "Onslaught": {url: U + "Onslaught", mods: {DEX: 80}, ftp: same(4.275),
            unverified: "fTP given as a range, \"4.275~4.37\": the lower bound is used"},
        "Raging Axe": {url: U + "Raging_Axe", mods: {STR: 60}, ftp: [1, 3, 6], hits: 2,
            unverified: "fTP at 2000 and 3000 TP"},
        "Rampage": {url: U + "Rampage", mods: {STR: 50}, ftp: same(1), hits: 5, replicating: true,
            crit: [0, 20, 40], unverified: "critical hit rate (\"tests with N<30\")"},
        "Ruinator": {url: U + "Ruinator", mods: {STR: 85}, ftp: same(1.08), hits: 4, replicating: true,
            attack: same(1.1), missing: "accuracy by TP"},
        "Spinning Axe": {url: U + "Spinning_Axe", mods: {STR: 60}, ftp: [2, 4, 6.5], hits: 1,
            unverified: "fTP at 2000 and 3000 TP"},
        // Scythe
        // https://www.bg-wiki.com/ffxi/Apocalypse_(Level_119_III) : hidden "Catastrophe damage +40%";
        // rank 15 augment "Catastrophe: Damage +20%", "different terms in the equation that get
        // multiplied together" (+68%)
        "Catastrophe": {url: U + "Catastrophe", mods: {STR: 40, INT: 40}, ftp: same(2.75),
            weapons: {"Apocalypse": [1.4], "Apocalypse R15": [1.4, 1.2]}},
        "Cross Reaper": {url: U + "Cross_Reaper", mods: {STR: 60, MND: 60}, ftp: [2, 4, 7], hits: 2},
        "Entropy": {url: U + "Entropy", mods: {INT: 85}, ftp: [0.75, 1.25, 2], hits: 4, replicating: true},
        "Guillotine": {url: U + "Guillotine", mods: {MND: 50, STR: 30}, ftp: same(0.875), hits: 4},
        "Insurgency": {url: U + "Insurgency", mods: {STR: 20, INT: 20}, ftp: [0.5, 3.25, 6], hits: 4},
        "Nightmare Scythe": {url: U + "Nightmare_Scythe", mods: {STR: 60, MND: 60}, ftp: same(1)},
        "Origin": {url: U + "Origin", mods: {STR: 60, INT: 60}, ftp: [3, 6, 9]},
        "Quietus": {url: U + "Quietus", mods: {STR: 60, MND: 60}, ftp: same(3), hits: 1,
            ignoreDefense: [0.125, 0.375, 0.625], unverified: "defense ignored, at every TP"},
        "Slice": {url: U + "Slice", mods: {STR: 100}, ftp: [1, 2.5, 4.125], hits: 1, unverified: "fTP, at every TP"},
        "Spinning Scythe": {url: U + "Spinning_Scythe", mods: {STR: 100}, ftp: same(1)},
        "Spiral Hell": {url: U + "Spiral_Hell", mods: {STR: 50, INT: 50}, ftp: [1.375, 2.75, 4.75]},
        // Great Sword
        // https://www.bg-wiki.com/ffxi/Epeolatry_(Level_119_III) : rank 15 augment "Dimidiation: Damage +15%"
        "Dimidiation": {url: U + "Dimidiation", mods: {DEX: 80}, ftp: [2.25, 4.5, 6.75], hits: 2, attack: same(1.25),
            weapons: {"Epeolatry R15": [1.15]}},
        "Fimbulvetr": {url: U + "Fimbulvetr", mods: {STR: 60, VIT: 60}, ftp: [3.3, 6.6, 9.9]},
        "Ground Strike": {url: U + "Ground_Strike", mods: {STR: 50, INT: 50}, ftp: [1.5, 3, 5], attack: same(1.75)},
        "Hard Slash": {url: U + "Hard_Slash", mods: {STR: 100}, ftp: [1.5, 2.5, 3.5], hits: 1,
            unverified: "fTP at 2000 and 3000 TP"},
        "Resolution": {url: U + "Resolution", mods: {STR: 85}, ftp: [0.71875, 1.5, 2.25], hits: 5, replicating: true,
            attack: same(0.85)},
        "Shockwave": {url: U + "Shockwave", mods: {STR: 30, MND: 30}, ftp: same(1)},
        "Sickle Moon": {url: U + "Sickle_Moon", mods: {STR: 40, AGI: 40}, ftp: [1.5, 3.5, 6.5], hits: 2,
            unverified: "fTP, at every TP"},
        "Spinning Slash": {url: U + "Spinning_Slash", mods: {STR: 30, INT: 30}, ftp: [2.5, 5, 7.5], attack: same(1.5)},
        // Great Katana
        "Tachi: Ageha": {url: U + "Tachi:_Ageha", mods: {CHR: 60, STR: 40}, ftp: same(2.625)},
        "Tachi: Enpi": {url: U + "Tachi:_Enpi", mods: {STR: 60}, ftp: [1, 2, 4], hits: 2},
        "Tachi: Fudo": {url: U + "Tachi:_Fudo", mods: {STR: 80}, ftp: [3.75, 5.75, 8]},
        "Tachi: Gekko": {url: U + "Tachi:_Gekko", mods: {STR: 75}, ftp: [1.5625, 2.6875, 4.125], attack: same(2)},
        "Tachi: Kaiten": {url: U + "Tachi:_Kaiten", mods: {STR: 80}, ftp: same(3)},
        "Tachi: Kasha": {url: U + "Tachi:_Kasha", mods: {STR: 75}, ftp: [1.5625, 2.6875, 4.125], attack: same(1.65)},
        "Tachi: Mumei": {url: U + "Tachi:_Mumei", mods: {STR: 50, DEX: 50}, ftp: [3.66, 7.33, 11],
            unverified: "attribute modifiers"},
        "Tachi: Rana": {url: U + "Tachi:_Rana", mods: {STR: 50}, ftp: same(1), hits: 3, missing: "accuracy by TP"},
        // https://www.bg-wiki.com/ffxi/Dojikiri_Yasutsuna : rank 15 augment "Tachi: Shoha: Damage +10%"
        "Tachi: Shoha": {url: U + "Tachi:_Shoha", mods: {STR: 85}, ftp: [1.375, 3.25, 4.625], hits: 2,
            attack: same(1.375), unverified: "attack modifier, \"1.35~1.45 (1.375)\"",
            weapons: {"Dojikiri Yasutsuna R15": [1.1]}},
        "Tachi: Yukikaze": {url: U + "Tachi:_Yukikaze", mods: {STR: 75}, ftp: [1.5625, 2.6875, 4.125],
            attack: same(1.5)},
        // Great Axe
        "Armor Break": {url: U + "Armor_Break", mods: {STR: 60, VIT: 60}, ftp: same(1)},
        "Disaster": {url: U + "Disaster", mods: {STR: 60, VIT: 60}, ftp: [3.05, 9.15, null],
            unverified: "fTP at 1000 and 2000 TP", missing: "fTP at 3000 TP, number of hits"},
        "Fell Cleave": {url: U + "Fell_Cleave", mods: {STR: 60}, ftp: same(2.75)},
        "Full Break": {url: U + "Full_Break", mods: {STR: 50, VIT: 50}, ftp: same(1)},
        "Iron Tempest": {url: U + "Iron_Tempest", mods: {STR: 60}, ftp: same(1), hits: 1, attack: [1, 2, 3.5],
            unverified: "attack bonus at 2000 and 3000 TP"},
        "King's Justice": {url: U + "King%27s_Justice", mods: {STR: 50}, ftp: [1, 3, 5], hits: 3},
        "Metatron Torment": {url: U + "Metatron_Torment", mods: {STR: 80}, ftp: same(2.75), hits: 1},
        "Raging Rush": {url: U + "Raging_Rush", mods: {STR: 50}, ftp: same(1), hits: 3, crit: [15, 30, 50],
            unverified: "critical hit rate at 2000 and 3000 TP; page marked outdated"},
        "Shield Break": {url: U + "Shield_Break", mods: {STR: 60, VIT: 60}, ftp: same(1)},
        "Steel Cyclone": {url: U + "Steel_Cyclone", mods: {STR: 60, VIT: 60}, ftp: [1.5, 2.5, 4], hits: 1,
            attack: same(1.5)},
        "Ukko's Fury": {url: U + "Ukko%27s_Fury", mods: {STR: 80}, ftp: same(2), hits: 2, crit: [20, 35, 65]},
        // https://www.bg-wiki.com/ffxi/Chango : rank 15 augment "Upheaval: DMG:+10%"
        "Upheaval": {url: U + "Upheaval", mods: {VIT: 85}, ftp: [1, 3.5, 6.5], hits: 4,
            weapons: {"Chango R15": [1.1]}},
        "Weapon Break": {url: U + "Weapon_Break", mods: {STR: 60, VIT: 60}, ftp: same(1)},
        // Dagger: our database has no type, hits or fTP for this skill; "Class: Physical" on each page
        "Evisceration": {url: U + "Evisceration", type: "Physical", mods: {DEX: 50}, ftp: same(1.25), hits: 5,
            replicating: true, crit: [10, 25, 50], unverified: "critical hit rate at 2000 and 3000 TP"},
        "Exenterator": {url: U + "Exenterator", type: "Physical", mods: {AGI: 85}, ftp: same(1.1875), hits: 4,
            replicating: true},
        "Mercy Stroke": {url: U + "Mercy_Stroke", type: "Physical", mods: {STR: 80}, ftp: same(5)},
        // https://www.bg-wiki.com/ffxi/Carnwenhan_(Level_119_III) : hidden "Mordant Rime damage +30%";
        // rank 15 augment "Mordant Rime: Damage +15%", multiplied together (+49.5%)
        "Mordant Rime": {url: U + "Mordant_Rime", type: "Physical", mods: {CHR: 70, DEX: 30}, ftp: same(5), hits: 2,
            missing: "its TP row (question marks)", weapons: {"Carnwenhan": [1.3], "Carnwenhan R15": [1.3, 1.15]}},
        "Ruthless Stroke": {url: U + "Ruthless_Stroke", type: "Physical", mods: {DEX: 25, AGI: 25},
            ftp: [5.375, 14, 23], hits: 4},
        "Viper Bite": {url: U + "Viper_Bite", type: "Physical", mods: {DEX: 100}, ftp: same(1),
            attack: same(2)},
        "Dancing Edge": {url: U + "Dancing_Edge", type: "Physical", mods: {DEX: 40, CHR: 40}, ftp: same(1.1875),
            hits: 5, replicating: true, missing: "accuracy by TP"},
        "Mandalic Stab": {url: U + "Mandalic_Stab", type: "Physical", mods: {DEX: 60}, ftp: [4, 6.09, 8.5],
            attack: same(1.75)},
        "Shark Bite": {url: U + "Shark_Bite", type: "Physical", mods: {DEX: 40, AGI: 40}, ftp: [4.5, 6.8, 8.5],
            hits: 2},
        "Rudra's Storm": {url: U + "Rudra%27s_Storm", type: "Physical", mods: {DEX: 80}, ftp: [5, 10.19, 13]}
    };

    // One weapon skill as the engine reads it: our database, then what its BG-Wiki page states.
    CALC.weaponskillInfo = function (name) {
        var base = CALC.WS_TABLE[name], page = CALC.WS_DETAILS[name];
        if (!base && !page) return null;
        var info = {name: name};
        [base || {}, page || {}].forEach(function (source) {
            Object.keys(source).forEach(function (key) { if (source[key] !== null) info[key] = source[key]; });
        });
        return info;
    };
});
