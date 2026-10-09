// Atelier calculation engine, stage 1: what the equipped pieces add up to.
//
//   CALC.SLOTS                    the sixteen slots of a gearset
//   CALC.wielding(gearset)        how the weapons are held: {skill, subSkill, dualWield, twoHanded,
//                                 handToHand, oneHandedAlone, canShoot}
//   CALC.gearTotals(gearset)      every numeric stat of the pieces added up; a weapon in the main
//                                 or sub slot keeps its own skill and multi-attack apart, as
//                                 "main <stat>" / "sub <stat>", because they only serve that hand
//
// No game formula here: sums of the numbers the input already carries.
//
// @file    atelier/calc/calc_gear.js
// @author  ejouanchicot
(globalThis.CALC_PARTS = globalThis.CALC_PARTS || []).push(function (CALC) {
    CALC.SLOTS = ["main", "sub", "ranged", "ammo", "head", "neck", "ear1", "ear2", "body", "hands", "ring1", "ring2",
        "back", "waist", "legs", "feet"];

    // read apart by calc_derived.js: one value a weapon, never added between slots
    var PER_WEAPON = {"DMG": true, "Delay": true};

    function piece(gearset, slot) {
        return (gearset && gearset[slot]) || {};
    }

    function isWeapon(item) {
        return item.Type === "Weapon";
    }

    // a weapon's own skill, its magic accuracy skill and its "occasionally attacks N times"
    function onlyThatHand(item, key) {
        return key === item["Skill Type"] + " Skill" || key === "Magic Accuracy Skill" || /^OA\d$/.test(key);
    }

    CALC.wielding = function (gearset) {
        var main = piece(gearset, "main"), sub = piece(gearset, "sub");
        var ranged = piece(gearset, "ranged"), ammo = piece(gearset, "ammo");
        var skill = isWeapon(main) ? main["Skill Type"] : "Hand-to-Hand";
        var dual = isWeapon(main) && isWeapon(sub);
        var twoHanded = CALC.TWO_HANDED.indexOf(skill) >= 0;
        var handToHand = skill === "Hand-to-Hand";
        // a bow, gun or thrown weapon in the ranged slot, or ammunition that is itself thrown;
        // a bullet or an arrow alone cannot be fired
        var canShoot = CALC.RANGED_SKILLS.indexOf(ranged["Skill Type"]) >= 0 || ammo["Skill Type"] === "Throwing";
        return {skill: skill, subSkill: dual ? sub["Skill Type"] : null, dualWield: dual, twoHanded: twoHanded,
            handToHand: handToHand, oneHandedAlone: !dual && !twoHanded && !handToHand, canShoot: canShoot};
    };

    function addPiece(totals, slot, item) {
        var hand = (slot === "main" || slot === "sub") && isWeapon(item) ? slot + " " : null;
        Object.keys(item).forEach(function (key) {
            var value = item[key];
            if (typeof value !== "number" || PER_WEAPON[key]) return;
            var name = hand && onlyThatHand(item, key) ? (/^OA\d$/.test(key) ? key + " " + slot : hand + key) : key;
            totals[name] = (totals[name] || 0) + value;
        });
    }

    CALC.gearTotals = function (gearset) {
        var totals = {};
        CALC.SLOTS.forEach(function (slot) { addPiece(totals, slot, piece(gearset, slot)); });
        return totals;
    };

    // damage and delay of the four weapon slots, as written on the pieces
    CALC.weaponNumbers = function (gearset) {
        function n(slot, key) { return piece(gearset, slot)[key] || 0; }
        return {
            main: {dmg: n("main", "DMG"), delay: n("main", "Delay")},
            sub: {dmg: n("sub", "DMG"), delay: n("sub", "Delay")},
            ranged: {dmg: n("ranged", "DMG"), delay: n("ranged", "Delay")},
            ammo: {dmg: n("ammo", "DMG"), delay: n("ammo", "Delay")}
        };
    };

    // buffs arrive as numbers grouped by who gives them: added up stat by stat
    CALC.buffTotals = function (buffs) {
        var totals = {};
        Object.keys(buffs || {}).forEach(function (source) {
            var group = buffs[source] || {};
            Object.keys(group).forEach(function (key) {
                if (typeof group[key] === "number") totals[key] = (totals[key] || 0) + group[key];
            });
        });
        return totals;
    };
});
