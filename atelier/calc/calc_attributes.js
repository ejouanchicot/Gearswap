// Atelier calculation engine, stage 1: the seven attributes of the character before gear.
//
//   CALC.baseAttributes(job, sub, ml)   {STR, DEX, VIT, AGI, INT, MND, CHR} without gear, or
//                                       null when the job pair is not in the table below
//
// BG-Wiki gives no formula for the attributes of a race and job at a level (the race pages only
// list the level 1 values, Category:Base_Stats likewise), so this part cannot be computed from
// documentation yet. What is documented is added on top of the table:
//   master levels  "+1 STR, DEX, VIT, AGI, INT, MND, and CHR per level"
//                  https://www.bg-wiki.com/ffxi/Master_Levels
//   merit points   "+1 base stat per level", 15 levels an attribute, all bought
//                  https://www.bg-wiki.com/ffxi/Merit_Points
//
// @file    atelier/calc/calc_attributes.js
// @author  ejouanchicot
(globalThis.CALC_PARTS = globalThis.CALC_PARTS || []).push(function (CALC) {
    CALC.ATTRIBUTES = ["STR", "DEX", "VIT", "AGI", "INT", "MND", "CHR"];

    // from the reference results, not documented: attributes of the race at level 99 plus the main
    // job at level 99 plus the support job at level 53 (master level 20 to 24), in the order
    // STR DEX VIT AGI INT MND CHR. Each line is the reference total minus the gear, minus the 20
    // master levels and minus the 15 merit points. Only the job pairs of the reference cases are
    // known, and the race behind them is not stated.
    var OBSERVED_AT_SUB_53 = {
        "cor/dnc": [82, 90, 81, 93, 85, 79, 85],
        "geo/drk": [84, 87, 87, 82, 92, 86, 78],
        "pld/drk": [95, 84, 94, 76, 78, 84, 84],
        "rdm/dnc": [85, 87, 81, 85, 85, 85, 88],
        "blm/sch": [76, 87, 77, 87, 95, 81, 86],
        "brd/dnc": [85, 87, 84, 82, 82, 82, 93],
        "bst/drg": [88, 92, 87, 90, 85, 75, 78],
        "dnc/drg": [88, 88, 84, 90, 76, 78, 92],
        "drk/sam": [94, 90, 90, 85, 87, 75, 76],
        "geo/whm": [79, 82, 85, 81, 89, 95, 84],
        "pld/blm": [87, 84, 89, 78, 81, 87, 88],
        "run/blu": [87, 84, 81, 89, 84, 84, 78],
        "sam/whm": [88, 85, 88, 84, 81, 87, 87],
        "smn/whm": [79, 79, 79, 84, 89, 95, 92],
        "thf/dnc": [85, 94, 84, 93, 85, 73, 79],
        "war/dnc": [92, 90, 84, 91, 76, 76, 85],
        "whm/blm": [82, 81, 82, 84, 87, 91, 88]
    };

    CALC.baseAttributes = function (job, sub, ml) {
        var row = OBSERVED_AT_SUB_53[job + "/" + sub];
        if (!row || CALC.subJobLevel(ml) !== 53) return null;
        var extra = (ml || 0) * CALC.MASTER_LEVEL.attributePerLevel + CALC.COMMON_MERITS.attribute;
        var out = {};
        CALC.ATTRIBUTES.forEach(function (name, i) { out[name] = row[i] + extra; });
        return out;
    };
});
