// Atelier calculation engine, stage 1: bonuses a gear set gives when several of its pieces are worn.
//
//   CALC.SET_BONUSES             the sets known so far
//   CALC.ARTIFACT_PIECES         the reforged artifact armor of the 22 jobs, without its "+2" / "+3" / "+4"
//   CALC.setBonusTotals(gearset) stat -> amount for the pieces equipped
//
// Piece names are the short names of Windower's res/items.lua, which is what the input carries.
// Only the sets met in the reference cases are listed: add the others here with their page.
//
// @file    atelier/calc/calc_sets.js
// @author  ejouanchicot
(globalThis.CALC_PARTS = globalThis.CALC_PARTS || []).push(function (CALC) {
    CALC.SET_BONUSES = [
        // "2 pieces: Critical Hit Rate +4%", 3: +6%, 4: +8%, 5: +10% (the +1 version only)
        // https://www.bg-wiki.com/ffxi/Adhemar_Attire_Set_%2B1
        {
            pieces: ["Adhemar Bonnet +1", "Adhemar Jacket +1", "Adhemar Wrist. +1", "Adhemar Kecks +1",
                "Adhe. Gamashes +1"],
            stat: "Crit Rate",
            byCount: {2: 4, 3: 6, 4: 8, 5: 10}
        }
    ];

    // Reforged artifact armor +2, +3 and +4: "2 pieces = +15 to Accuracy, Ranged Accuracy, and Magic Accuracy",
    // 3: +30, 4: +45, 5: +60; "The set bonus is also activated by Regal Accessories"
    // https://www.bg-wiki.com/ffxi/Maxixi_Attire_Set_%2B3
    // "The set bonus activates with Reforged Artifact Armor +2, +3 and +4 for an additional +15", "not activated
    // with 5/5 AF" https://www.bg-wiki.com/ffxi/Regal_Ring (and Regal_Earring): a Regal accessory counts as one
    // more piece, five at most. Measured in game on 2026-10-13: Regal Ring + Maxixi Bangles +4 = Accuracy +15.
    // Not on those pages, taken as no bonus: Regal accessories with no artifact piece.
    // The names are the short ones of res/items.lua (a piece's "+4" is not always shortened as its "+3").
    CALC.ARTIFACT_PIECES = [
        "Acad. Bracers", "Acad. Gown", "Acad. Loafers", "Acad. Mortar.", "Acad. Pants", "Anch. Crown",
        "Anch. Cyclas", "Anch. Gaiters", "Anch. Gloves", "Anch. Hose", "Anchor. Crown", "Anchor. Gloves",
        "Assim. Bazu.", "Assim. Charuqs", "Assim. Jubbah", "Assim. Keffiyeh", "Assim. Shalwar", "Atro. Boots",
        "Atro. Chapeau", "Atro. Gloves", "Atro. Tights", "Atrophy Chapeau", "Atrophy Gloves", "Atrophy Tabard",
        "Atrophy Tights", "Brios. Cann.", "Brioso Cannions", "Brioso Cuffs", "Brioso Just.", "Brioso Justau.",
        "Brioso Roundlet", "Brioso Slippers", "Con. Bracers", "Con. Doublet", "Con. Horn", "Con. Pigaches",
        "Con. Spats", "Convo. Bracers", "Convo. Pigaches", "Convo. Spats", "Convoker's Horn", "Foire Babouches",
        "Foire Churidars", "Foire Dastanas", "Foire Taj", "Foire Tobe", "Geo. Galero", "Geo. Mitaines", "Geo. Pants",
        "Geo. Sandals", "Geo. Tunic", "Geomancy Pants", "Geomancy Tunic", "Hachi. Chain.", "Hachi. Hatsu.",
        "Hachiya Chain.", "Hachiya Hakama", "Hachiya Hatsu.", "Hachiya Kyahan", "Hachiya Tekko", "Ig. Burgeonet",
        "Ig. Cuirass", "Ig. Fin. Gaunt.", "Ig. Flanchard", "Ig. Gauntlets", "Ig. Sollerets", "Ignominy Cuirass",
        "Lak. Gants", "Laksa. Bottes", "Laksa. Frac", "Laksa. Gants", "Laksa. Trews", "Laksa. Tricorne",
        "Maxixi Bangles", "Maxixi Casaque", "Maxixi Tiara", "Maxixi Tights", "Maxixi Toe Sh.", "Maxixi Toe Shoes",
        "Orion Beret", "Orion Braccae", "Orion Bracers", "Orion Jerkin", "Orion Socks", "Pill. Armlets",
        "Pill. Bonnet", "Pill. Culottes", "Pill. Poulaines", "Pill. Vest", "Pillager's Vest", "Pumm. Calligae",
        "Pumm. Cuisses", "Pumm. Lorica", "Pumm. Mask", "Pumm. Mufflers", "Pummeler's Mask", "Rev. Breeches",
        "Rev. Coronet", "Rev. Gauntlets", "Rev. Leggings", "Rev. Surcoat", "Rune. Bandeau", "Rune. Mitons",
        "Rune. Trousers", "Runeist Bandeau", "Runeist Boots", "Runeist Bottes", "Runeist Coat", "Runeist Mitons",
        "Spae. Coat", "Spae. Gloves", "Spae. Petasos", "Spae. Sabots", "Spae. Tonban", "Spaekona's Coat",
        "Th. Pant.", "Th. Pantaloons", "Theo. Bliaut", "Theo. Cap", "Theo. Duckbills", "Theo. Mitts", "Theo. Pant.",
        "Theophany Cap", "Theophany Mitts", "Tot. Gaiters", "Tot. Gloves", "Tot. Jackcoat", "Tot. Trousers",
        "Totemic Gloves", "Totemic Helm", "Vis. Fng. Gaunt.", "Vish. Fin.", "Vishap Armet", "Vishap Brais",
        "Vishap Greaves", "Vishap Mail", "Wakido Domaru", "Wakido Haidate", "Wakido Kabuto", "Wakido Kote",
        "Wakido Sune."
    ];
    var REGAL = ["Regal Ring", "Regal Earring"];
    var ARTIFACT_STATS = ["Accuracy", "Ranged Accuracy", "Magic Accuracy"];

    function artifactBonus(gearset) {
        var artifact = 0, regal = 0;
        Object.keys(gearset || {}).forEach(function (slot) {
            var name = String((gearset[slot] || {}).Name || "");
            var plus = name.match(/^(.*) \+[234]$/);
            if (plus && CALC.ARTIFACT_PIECES.indexOf(plus[1]) >= 0) artifact += 1;
            else if (REGAL.indexOf(name) >= 0) regal += 1;
        });
        return artifact ? 15 * (Math.min(5, artifact + regal) - 1) : 0;
    }

    function wornCount(gearset, pieces) {
        var count = 0;
        Object.keys(gearset || {}).forEach(function (slot) {
            var item = gearset[slot] || {};
            if (pieces.indexOf(item.Name) >= 0 || pieces.indexOf(item.Name2) >= 0) count += 1;
        });
        return count;
    }

    CALC.setBonusTotals = function (gearset) {
        var totals = {};
        CALC.SET_BONUSES.forEach(function (set) {
            var amount = set.byCount[wornCount(gearset, set.pieces)];
            if (amount) totals[set.stat] = (totals[set.stat] || 0) + amount;
        });
        var artifact = artifactBonus(gearset);
        if (artifact) ARTIFACT_STATS.forEach(function (stat) { totals[stat] = (totals[stat] || 0) + artifact; });
        return totals;
    };
});
