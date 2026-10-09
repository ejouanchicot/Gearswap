// Atelier calculation engine, stage 1: bonuses a gear set gives when several of its pieces are worn.
//
//   CALC.SET_BONUSES             the sets known so far
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
        return totals;
    };
});
