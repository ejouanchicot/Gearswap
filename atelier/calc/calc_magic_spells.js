// Atelier calculation engine, stage 4 (magic): the base damage of the damaging spells.
//
//   CALC.SPELLS                    spell name -> {element, family, rows, area, skill}
//   CALC.spellBase(spell, dINT)    V + dINT x M of the spell at that dINT, floored, without Magic Damage
//
// A spell's rows are [dINT where the row starts, V at that dINT, M for each dINT above it]. On
// every table read, the next row's V is this row's V + width x M (Fire VI: 1130 + 50 x 5.5 = 1405,
// 1405 + 50 x 5.7 = 1690...), and the last row has M 0: its V is the cap. scripts/audit/
// calc_magic_check.js checks that every table still adds up that way.
//
// Sources (quotes in SOURCES.md, stage 4):
//   https://www.bg-wiki.com/ffxi/Magic_Damage  tables of tiers I to VI, -ga I to III, -ja, Ancient
//       Magic I and II, Comet, Helix I; "D = mDMG + V + (dINT x M)", "reduce the dINT by the amount
//       factored into the V value"
//   https://wiki.ffo.jp/html/16584.html (INT difference coefficients) the same first-row M for tiers I to V and -ga I
//       to III, the 0 to 100 slope of the -ja (5.5 / 5.17 / 4.85 / 4.52 / 4.2 / 3.87) and of Comet
//       (3.87), Ancient Magic 2.0, helix 1.0: all agree with the BG-Wiki tables
//   https://www.bg-wiki.com/ffxi/Pyrohelix_II  Helix II rows (see HELIX_2 below)
//   https://www.bg-wiki.com/ffxi/Ninjutsu  Ichi / Ni / San V and M
//
// @file    atelier/calc/calc_magic_spells.js
// @author  ejouanchicot
(globalThis.CALC_PARTS = globalThis.CALC_PARTS || []).push(function (CALC) {
    // the six elements in the order of the BG-Wiki tables, with each tier's spell name
    var ELEMENTS = ["Earth", "Water", "Wind", "Fire", "Ice", "Lightning"];
    var NAMES = {
        "1": ["Stone", "Water", "Aero", "Fire", "Blizzard", "Thunder"],
        ga: ["Stonega", "Waterga", "Aeroga", "Firaga", "Blizzaga", "Thundaga"],
        ja: ["Stoneja", "Waterja", "Aeroja", "Firaja", "Blizzaja", "Thundaja"]
    };
    // the dINT where each row starts, by number of rows (Magic_Damage: 0-49, 50-99, 100-199, then
    // steps of 100)
    var STARTS = [0, 50, 100, 200, 300, 400, 500, 600];

    // [V of each row], [M of each row] for the six elements, earth to lightning; the last V is the cap
    // https://www.bg-wiki.com/ffxi/Magic_Damage
    var TIERS = {
        "": [
            [[10, 110, 160], [2, 1, 0]], [[25, 115, 165], [1.8, 1, 0]], [[40, 120, 170], [1.6, 1, 0]],
            [[55, 125, 175], [1.4, 1, 0]], [[70, 130, 180], [1.2, 1, 0]], [[85, 135, 185], [1, 1, 0]]],
        " II": [
            [[100, 250, 350, 450], [3, 2, 1, 0]], [[120, 260, 355, 455], [2.8, 1.9, 1, 0]],
            [[140, 270, 360, 460], [2.6, 1.8, 1, 0]], [[160, 280, 365, 465], [2.4, 1.7, 1, 0]],
            [[180, 290, 370, 470], [2.2, 1.6, 1, 0]], [[200, 300, 375, 475], [2, 1.5, 1, 0]]],
        " III": [
            [[200, 400, 550, 750, 850], [4, 3, 2, 1, 0]], [[230, 415, 560, 755, 855], [3.7, 2.9, 1.95, 1, 0]],
            [[260, 430, 570, 760, 860], [3.4, 2.8, 1.9, 1, 0]], [[290, 445, 580, 765, 865], [3.1, 2.7, 1.85, 1, 0]],
            [[320, 460, 590, 770, 870], [2.8, 2.6, 1.8, 1, 0]], [[350, 475, 600, 775, 875], [2.5, 2.5, 1.75, 1, 0]]],
        " IV": [
            [[400, 650, 850, 1150, 1350, 1450], [5, 4, 3, 2, 1, 0]],
            [[440, 675, 870, 1165, 1364, 1464], [4.7, 3.9, 2.95, 1.99, 1, 0]],
            [[480, 700, 890, 1180, 1378, 1478], [4.4, 3.8, 2.9, 1.98, 1, 0]],
            [[520, 730, 915, 1195, 1397, 1497], [4.2, 3.7, 2.85, 1.97, 1, 0]],
            [[560, 755, 935, 1210, 1411, 1511], [3.9, 3.6, 2.8, 1.96, 1, 0]],
            [[600, 780, 955, 1225, 1425, 1525], [3.6, 3.5, 2.75, 1.95, 1, 0]]],
        " V": [
            [[650, 950, 1200, 1600, 1900, 2100, 2200], [6, 5, 4, 3, 2, 1, 0]],
            [[700, 980, 1217, 1612, 1911, 2110, 2210], [5.6, 4.74, 3.95, 2.99, 1.99, 1, 0]],
            [[750, 1010, 1235, 1625, 1923, 2121, 2221], [5.2, 4.5, 3.9, 2.98, 1.98, 1, 0]],
            [[800, 1040, 1252, 1637, 1934, 2131, 2231], [4.8, 4.24, 3.85, 2.97, 1.97, 1, 0]],
            [[850, 1070, 1270, 1650, 1946, 2142, 2242], [4.4, 4, 3.8, 2.96, 1.96, 1, 0]],
            [[900, 1100, 1287, 1662, 1957, 2152, 2252], [4, 3.74, 3.75, 2.95, 1.95, 1, 0]]],
        " VI": [
            [[950, 1300, 1600, 2100, 2500, 2800, 3000, 3100], [7, 6, 5, 4, 3, 2, 1, 0]],
            [[1010, 1335, 1630, 2120, 2510, 2805, 3004, 3104], [6.5, 5.9, 4.9, 3.9, 2.95, 1.99, 1, 0]],
            [[1070, 1370, 1660, 2140, 2520, 2810, 3008, 3108], [6, 5.8, 4.8, 3.8, 2.9, 1.98, 1, 0]],
            [[1130, 1405, 1690, 2160, 2530, 2815, 3012, 3112], [5.5, 5.7, 4.7, 3.7, 2.85, 1.97, 1, 0]],
            [[1190, 1440, 1720, 2180, 2540, 2820, 3016, 3116], [5, 5.6, 4.6, 3.6, 2.8, 1.96, 1, 0]],
            [[1250, 1475, 1750, 2200, 2550, 2825, 3020, 3120], [4.5, 5.5, 4.5, 3.5, 2.75, 1.95, 1, 0]]]
    };
    var GA = {
        "": [
            [[60, 210, 310, 410], [3, 2, 1, 0]], [[80, 220, 315, 415], [2.8, 1.9, 1, 0]],
            [[100, 230, 320, 420], [2.6, 1.8, 1, 0]], [[120, 240, 325, 425], [2.4, 1.7, 1, 0]],
            [[160, 270, 350, 450], [2.2, 1.6, 1, 0]], [[200, 300, 375, 475], [2, 1.5, 1, 0]]],
        " II": [
            [[250, 450, 600, 800, 900], [4, 3, 2, 1, 0]], [[280, 465, 610, 805, 905], [3.7, 2.9, 1.95, 1, 0]],
            [[310, 480, 620, 810, 910], [3.4, 2.8, 1.9, 1, 0]], [[340, 495, 630, 815, 915], [3.1, 2.7, 1.85, 1, 0]],
            [[370, 510, 640, 820, 920], [2.8, 2.6, 1.8, 1, 0]], [[400, 525, 650, 825, 925], [2.5, 2.5, 1.75, 1, 0]]],
        " III": [
            [[500, 750, 950, 1250, 1450, 1550], [5, 4, 3, 2, 1, 0]],
            [[540, 775, 970, 1265, 1464, 1564], [4.7, 3.9, 2.95, 1.99, 1, 0]],
            [[580, 800, 990, 1280, 1478, 1578], [4.4, 3.8, 2.9, 1.98, 1, 0]],
            [[620, 830, 1015, 1295, 1497, 1597], [4.2, 3.7, 2.85, 1.97, 1, 0]],
            [[660, 855, 1035, 1310, 1511, 1611], [3.9, 3.6, 2.8, 1.96, 1, 0]],
            [[700, 880, 1055, 1325, 1525, 1625], [3.6, 3.5, 2.75, 1.95, 1, 0]]]
    };
    var JA = [
        [[750, 1050, 1300, 1700, 2000, 2200, 2300], [6, 5, 4, 3, 2, 1, 0]],
        [[800, 1080, 1317, 1712, 2010, 2210, 2310], [5.6, 4.75, 3.95, 2.98, 2, 1, 0]],
        [[850, 1110, 1335, 1725, 2021, 2221, 2321], [5.2, 4.5, 3.9, 2.96, 2, 1, 0]],
        [[900, 1140, 1352, 1737, 2031, 2231, 2331], [4.8, 4.25, 3.85, 2.94, 2, 1, 0]],
        [[950, 1170, 1370, 1750, 2042, 2242, 2342], [4.4, 4, 3.8, 2.92, 2, 1, 0]],
        [[1000, 1200, 1387, 1762, 2052, 2252, 2352], [4, 3.75, 3.75, 2.9, 2, 1, 0]]];
    // Ancient Magic: "M 2" on every row; I caps at 1900, II at 2000, both marked "Verification Needed"
    var ANCIENT = {
        "": [[700, 800, 900, 1100, 1300, 1500, 1700, 1900], [2, 2, 2, 2, 2, 2, 2, 0]],
        " II": [[800, 900, 1000, 1200, 1400, 1600, 1800, 2000], [2, 2, 2, 2, 2, 2, 2, 0]]
    };
    // Flare, Flood, Tornado... in the element order above
    var ANCIENT_NAMES = ["Quake", "Flood", "Tornado", "Flare", "Freeze", "Burst"];
    var COMET = [[1000, 1200, 1387, 1737, 2037, 2237, 2337], [4, 3.75, 3.5, 3, 2, 1, 0]];

    // Helix I, https://www.bg-wiki.com/ffxi/Magic_Damage : rows start at dINT 0, 78 and 235
    // ("dINT0-77", "dINT78-234", "dINT235+"), "Verification Needed"; the rows add up (25 + 78 = 103,
    // 103 + 156 x 0.5 = 181). Pyrohelix's own page only gives "Base Value: 25", "Multiplier: 1".
    var HELIX_1 = {starts: [0, 78, 235], v: [25, 103, 181], m: [1, 0.5, 0]};
    // Helix II: the Magic_Damage page gives 75 / 2, 175 / 1, 225 / 0 under the same 0 / 78 / 235
    // header, which does not add up (75 + 78 x 2 = 231, not 175). Pyrohelix II's own page gives the
    // same values with rows at 0, 50 and 100 (75 + 50 x 2 = 175, 175 + 50 = 225): that page is used.
    var HELIX_2 = {starts: [0, 50, 100], v: [75, 175, 225], m: [2, 1, 0]};
    var HELIX_NAMES = {Earth: "Geohelix", Water: "Hydrohelix", Wind: "Anemohelix", Fire: "Pyrohelix",
        Ice: "Cryohelix", Lightning: "Ionohelix", Dark: "Noctohelix", Light: "Luminohelix"};

    // https://www.bg-wiki.com/ffxi/Ninjutsu : "a unified V value based on tier levels" and "a unified M
    // value not based on dINT ranges, but on tier level": Ichi 28 / 0.5, Ni 69 / 1, San 134 / 1.5;
    // no cap given (ASSUMED: none). wiki.ffo.jp 16584 gives 1.0 for Ichi (BG-Wiki 0.5) and 1.5 for San.
    // skillRange: the "Potency Bonus Formula (NIN main only)" ranges, calc_magic.js
    var NINJUTSU = {Ichi: {v: 28, m: 0.5, skillRange: [50, 250]}, Ni: {v: 69, m: 1, skillRange: [125, 325]},
        San: {v: 134, m: 1.5, skillRange: [275, 475]}};
    var NINJUTSU_NAMES = {Doton: "Earth", Suiton: "Water", Huton: "Wind", Katon: "Fire", Hyoton: "Ice",
        Raiton: "Lightning"};

    // https://www.bg-wiki.com/ffxi/Impact : only the infobox, "Base Value" 939 and "Multiplier" 2.335,
    // without a dINT table. ASSUMED: read as V and M of a single row without cap, the way Katon: San's
    // infobox (134 / 1.5) is the Ninjutsu page's San row. Dark element (the spell "Deals dark damage").
    var IMPACT = {starts: [0], v: [939], m: [2.335]};

    var SPELLS = CALC.SPELLS = {};

    function rowsOf(vs, ms, starts) {
        return {starts: (starts || STARTS).slice(0, vs.length), v: vs, m: ms};
    }

    function add(name, element, family, rows, extra) {
        SPELLS[name] = Object.assign({name: name, element: element, family: family, rows: rows,
            skill: "Elemental Magic", area: false}, extra || {});
    }

    ELEMENTS.forEach(function (element, i) {
        Object.keys(TIERS).forEach(function (tier) {
            add(NAMES["1"][i] + tier, element, "tier" + tier.trim(), rowsOf(TIERS[tier][i][0], TIERS[tier][i][1]));
        });
        Object.keys(GA).forEach(function (tier) {
            add(NAMES.ga[i] + tier, element, "ga" + tier.trim(), rowsOf(GA[tier][i][0], GA[tier][i][1]), {area: true});
        });
        add(NAMES.ja[i], element, "ja", rowsOf(JA[i][0], JA[i][1]), {area: true});
        Object.keys(ANCIENT).forEach(function (tier) {
            add(ANCIENT_NAMES[i] + tier, element, "ancient" + tier.trim(), rowsOf(ANCIENT[tier][0], ANCIENT[tier][1]));
        });
    });
    add("Comet", "Dark", "comet", rowsOf(COMET[0], COMET[1]));
    add("Impact", "Dark", "impact", IMPACT);
    Object.keys(HELIX_NAMES).forEach(function (element) {
        add(HELIX_NAMES[element], element, "helix", HELIX_1, {helix: true});
        add(HELIX_NAMES[element] + " II", element, "helix", HELIX_2, {helix: true});
    });
    Object.keys(NINJUTSU_NAMES).forEach(function (stem) {
        Object.keys(NINJUTSU).forEach(function (tier) {
            var t = NINJUTSU[tier];
            add(stem + ": " + tier, NINJUTSU_NAMES[stem], "ninjutsu", {starts: [0], v: [t.v], m: [t.m]},
                {skill: "Ninjutsu", skillRange: t.skillRange});
        });
    });

    // https://www.bg-wiki.com/ffxi/Magic_Damage : "D = mDMG + V + (dINT x M)", the row picked by
    // the full dINT and "reduce the dINT by the amount factored into the V value"; wiki.ffo.jp 674
    // (Elemental Magic): magic D = spell D + int(dINT x coefficient) + Magic Damage, the dINT part
    // floored (Japanese text in SOURCES.md, stage 4).
    // Negative dINT: "reduced M values apply" and "D will be lower than V, potentially even 0", no
    // value given. ASSUMED: the first row's M continues below 0, and the result stops at 0.
    CALC.spellBase = function (spell, dINT) {
        var rows = spell.rows, i = 0;
        while (i + 1 < rows.starts.length && dINT >= rows.starts[i + 1]) i += 1;
        var above = dINT - rows.starts[i];
        return Math.max(0, rows.v[i] + Math.floor(above * rows.m[i]));
    };
});
