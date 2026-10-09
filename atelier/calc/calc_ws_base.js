// Atelier calculation engine, stage 2: the base damage of one weapon skill hit.
// Weapon damage + fSTR + the weapon skill's attribute bonus (WSC), times fTP.
//
//   CALC.weaponRank(dmg, handToHand)       rank of a weapon, from its damage
//   CALC.fSTR(str, enemyVit, dmg, h2h)     damage added or removed by STR against the enemy's VIT
//   CALC.wsAttributeBonus(stats, mods)     WSC: the share of the attributes the weapon skill adds
//   CALC.valueAtTP(points, tp)             a value given at 1000 / 2000 / 3000 TP, in between
//   CALC.wsBaseDamage(dmg, fstr, wsc, ftp, bonuses) the floored base damage of one hit
//
// @file    atelier/calc/calc_ws_base.js
// @author  ejouanchicot
(globalThis.CALC_PARTS = globalThis.CALC_PARTS || []).push(function (CALC) {
    // https://www.bg-wiki.com/ffxi/Weapon_Rank
    //   Hand-to-Hand: floor((Weapon Damage + 3) / 9) ; all other weapons: floor(Weapon Damage / 9)
    CALC.weaponRank = function (dmg, handToHand) {
        return Math.floor((handToHand ? dmg + 3 : dmg) / 9);
    };

    // https://www.bg-wiki.com/ffxi/FSTR   dSTR = STR - enemy VIT ; fSTR = (dSTR + k) / 4, k by range:
    //   12 or more: 4 ; 6 to 11: 6 ; 1 to 5: 7 ; -2 to 0: 8 ; -7 to -3: 9 ; -15 to -8: 10 ;
    //   -21 to -16: 12 ; -22 or less: 13
    var FSTR_OFFSET = [[12, 4], [6, 6], [1, 7], [-2, 8], [-7, 9], [-15, 10], [-21, 12]];
    var FSTR_OFFSET_BELOW = 13;

    // https://www.bg-wiki.com/ffxi/FSTR
    //   lower cap: -Weapon Rank ("Rank 0 weapons have a lower cap of -1"); upper cap: Weapon Rank + 8
    // The page gives no rounding: the quarters are kept, the floor comes with the base damage.
    CALC.fSTR = function (str, enemyVit, dmg, handToHand) {
        var delta = str - enemyVit, offset = FSTR_OFFSET_BELOW;
        for (var i = 0; i < FSTR_OFFSET.length; i += 1) {
            if (delta >= FSTR_OFFSET[i][0]) { offset = FSTR_OFFSET[i][1]; break; }
        }
        var rank = CALC.weaponRank(dmg, handToHand);
        return Math.max(Math.min((delta + offset) / 4, rank + 8), rank === 0 ? -1 : -rank);
    };

    // https://www.bg-wiki.com/ffxi/Weapon_Skill_Damage   WSC = floor((A x A%) + (B x B%))
    CALC.wsAttributeBonus = function (stats, mods) {
        var total = 0;
        Object.keys(mods || {}).forEach(function (attribute) {
            total += (stats[attribute] || 0) * mods[attribute] / 100;
        });
        return Math.floor(total);
    };

    // fTP, critical hit rate and attack bonus are given at 1000, 2000 and 3000 TP; in between
    // the value is taken on the straight line between the two neighbours. BG-Wiki gives the
    // three anchors on each weapon skill's page and no curve: the straight line is the usual
    // reading of "varies with TP", not a quoted formula. When a page gives no value at 2000 TP
    // (Hexa Strike's critical hit rate) the line runs from 1000 to 3000; when an end is missing
    // the answer is null above or below the anchors that exist.
    CALC.valueAtTP = function (points, tp) {
        if (!points) return null;
        var known = [];
        points.forEach(function (value, i) {
            if (value !== null && value !== undefined) known.push([1000 * (i + 1), value]);
        });
        var at = Math.max(1000, Math.min(3000, tp));
        for (var i = 0; i < known.length; i += 1) {
            if (at === known[i][0]) return known[i][1];
            if (i > 0 && at > known[i - 1][0] && at < known[i][0]) {
                var from = known[i - 1], to = known[i];
                return from[1] + (to[1] - from[1]) * (at - from[0]) / (to[0] - from[0]);
            }
        }
        return null;
    };

    // https://www.bg-wiki.com/ffxi/Weapon_Skill_Damage
    //   Melee WS Base Damage = floor((Weapon Base Damage + fSTR + WSC) x fTP)
    // `bonuses` are the Weapon Skill Damage multipliers of the hit, in order (1.17 for +17%).
    // The page files them in two groups: gear and gifts, "Additive", first hit only; traits and
    // the weapons' own bonuses, all hits, "Multiplicative with Flooring Between Steps". It does
    // not say whether the first group is floored too: every step is floored here.
    CALC.wsBaseDamage = function (dmg, fstr, wsc, ftp, bonuses) {
        var damage = Math.floor((dmg + fstr + wsc) * ftp);
        (bonuses || []).forEach(function (bonus) { damage = Math.floor(damage * bonus); });
        return damage;
    };
});
