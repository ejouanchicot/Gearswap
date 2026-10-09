// Atelier calculation engine, stage 2: the average damage and TP return of a physical melee
// weapon skill. One entry point.
//
//   CALC.weaponskillAverage(stats, enemy, name, tp, wield)
//       stats  the character sheet (CALC.characterStats, or any object with the same names)
//       enemy  {Defense, Evasion, VIT, AGI}
//       name   the weapon skill, tp the TP it is used at (TP Bonus is added here)
//       wield  optional, what the sheet does not say: {main: name of the main hand weapon as
//              the gear calls it ("Apocalypse R15"), buffs: number of status effects on the
//              character}. Without it no weapon gives its own bonus.
//       returns {damage, tpReturn, swings, ...} or {unsupported: "why"}
//   CALC.wsMeanPdif(ratio, cap, critRate, critDamage)   mean pDIF of a swing that lands
//   CALC.wsProcChances(stats, offHand)   chance of 0 to 3 extra swings on a swing of one hand
//   CALC.wsSwingKinds(ctx)               the swings of the weapon skill, by kind
//   CALC.handNumbers(stats, enemy, hold, offHand)   damage, attack, accuracy, fSTR of one hand
//
// The result is an expected value: each kind of swing (first hit, the weapon skill's other
// hits, the off-hand hit, the extra swings of multi-attack) is worth
//   chance to land x floored base damage x mean pDIF
// and the kinds are added, weighted by how many of them there are on average.
//
// @file    atelier/calc/calc_ws_average.js
// @author  ejouanchicot
(globalThis.CALC_PARTS = globalThis.CALC_PARTS || []).push(function (CALC) {
    var TWO_HANDED = {"Great Sword": 1, "Great Axe": 1, "Great Katana": 1, Polearm: 1, Scythe: 1, Staff: 1};
    var MAX_TP = 3000;

    function percent(stats, name) { return (stats[name] || 0) / 100; }

    function holdOf(skill) {
        return skill === "Hand-to-Hand" ? "handToHand" : TWO_HANDED[skill] ? "twoHanded" : "oneHanded";
    }

    function whyUnsupported(info) {
        if (!info) return "unknown weapon skill";
        if (info.type !== "Physical") return "not a physical weapon skill (" + (info.type || "no type") + ")";
        if (info.skill === "Archery" || info.skill === "Marksmanship") return "ranged weapon skill";
        if (!info.ftp || !info.mods) return "fTP or attribute modifiers unknown";
        return null;
    }

    // Critical hits: only the weapon skills whose page gives a critical hit rate can land them
    // ("Other weapon skills cannot critically hit unless their descriptions indicate they can").
    // https://www.bg-wiki.com/ffxi/Critical_Hit_Rate : the rate is the sum of the base rate, gear,
    // merits, buffs, "Weapon Skill modifiers" and dDEX.
    function critRate(stats, enemy, info, tp) {
        var bonus = CALC.valueAtTP(info.crit, tp);
        if (bonus === null) return info.crit ? NaN : 0;
        var rate = (stats["Crit Rate"] || 0) + CALC.critRateFromDex(stats.DEX, enemy.AGI) + bonus;
        return Math.max(0, Math.min(1, rate / 100));
    }

    // https://www.bg-wiki.com/ffxi/Naegling : "Weapon Skill: Attack Bonus based on the number of
    // upgrades", read on the page as "+1% per buff effect", for every weapon skill.
    CALC.WS_ATTACK_PER_BUFF = {"Naegling": 0.01};

    function describe(stats, enemy, info, tp, wield) {
        var hold = holdOf(info.skill), used = Math.min(MAX_TP, tp + (stats["TP Bonus"] || 0));
        var attack = CALC.valueAtTP(info.attack, used), ignored = CALC.valueAtTP(info.ignoreDefense, used);
        var perBuff = CALC.WS_ATTACK_PER_BUFF[wield.main] || 0;
        attack = (attack === null ? 1 : attack) * (1 + perBuff * (wield.buffs || 0));
        return {
            stats: stats, enemy: enemy, info: info, hold: hold, tp: used,
            // the weapon's own bonus to this weapon skill: steps multiplied one after the other
            weaponBonus: (info.weapons || {})[wield.main] || [],
            dualWield: hold === "oneHanded" && (stats["DMG2"] || 0) > 0,
            // https://www.bg-wiki.com/ffxi/Fotia_Gorget : the gorget and belt add "exactly 25/256"
            // to the weapon skill's fTP ("ftp" on the sheet)
            ftp: CALC.valueAtTP(info.ftp, used) + (stats["ftp"] || 0),
            attackBonus: attack,
            defense: enemy.Defense * (1 - (ignored || 0)),
            wsc: CALC.wsAttributeBonus(stats, info.mods),
            crit: critRate(stats, enemy, info, used),
            cap: CALC.pdifCap(hold, info.skill, percent(stats, "PDL Trait"), percent(stats, "PDL"))
        };
    }

    // One hand of the character as the sheet gives it: weapon damage, attack, accuracy, the
    // highest hit rate and fSTR. Shared with the auto-attack round (calc_round_damage.js).
    CALC.handNumbers = function (stats, enemy, hold, offHand) {
        var n = offHand ? "2" : "1";
        return {
            dmg: stats["DMG" + n], attack: stats["Attack" + n], accuracy: stats["Accuracy" + n],
            cap: CALC.HIT_RATE_CAP[offHand ? "offHand" : hold],
            fstr: CALC.fSTR(stats.STR, enemy.VIT, stats["DMG" + n], hold === "handToHand")
        };
    };

    // the same hand during the weapon skill: its attack bonus and "Weapon Skill Accuracy"
    function hand(ctx, offHand) {
        var h = CALC.handNumbers(ctx.stats, ctx.enemy, ctx.hold, offHand);
        h.attack *= ctx.attackBonus;
        h.accuracy += ctx.stats["Weapon Skill Accuracy"] || 0;
        return h;
    }

    // Mean pDIF of a swing that lands, critical hits included.
    // https://www.bg-wiki.com/ffxi/Critical_Hit_Rate
    //   Critical Hit Damage = (Base Damage + fSTR) x Critical pDIF x (Sum of Direct Modifiers),
    //   the bonus "capped at +100% maximum total": only the critical hits are multiplied.
    // measured in game 2026-10-09: +18.0% [17.3, 19.0] on the critical hits of a WAR whose sheet
    // says "Crit Damage" 18 (359 critical hits); the hits that are not critical keep their base.
    CALC.wsMeanPdif = function (ratio, cap, critRate, critDamage) {
        var normal = CALC.pdifAverage(ratio, cap, false);
        var critical = CALC.pdifAverage(ratio, cap, true) * (1 + Math.min(1, critDamage));
        return (1 - critRate) * normal + critRate * critical;
    };

    // mean damage of one swing that is thrown: chance to land x base damage x mean pDIF
    function swingDamage(ctx, h, ftp, bonus, accuracyBonus) {
        // https://www.bg-wiki.com/ffxi/WS_Damage_Boost : the trait "Applies to all hits of a weapon
        // skill" and is "Multiplicative with other sources of Weapon Skill Damage listed on gear"
        var base = CALC.wsBaseDamage(h.dmg, h.fstr, ctx.wsc, ftp,
            [1 + bonus, 1 + percent(ctx.stats, "Weapon Skill Damage Trait")].concat(ctx.weaponBonus));
        var pdif = CALC.wsMeanPdif(h.attack / ctx.defense, ctx.cap, ctx.crit, percent(ctx.stats, "Crit Damage"));
        var landed = CALC.hitRate(h.accuracy + accuracyBonus, ctx.enemy.Evasion, h.cap);
        return {landed: landed, base: base, pdif: pdif, damage: landed * base * pdif};
    }

    // Chance of 0 to 3 extra swings on a swing of one hand.
    // https://www.bg-wiki.com/ffxi/Multi-Attack : Occasionally Attacks X Times "May proc on Weapon
    // Skills only when provided by Mythic AM3". "OA2 main" / "OA2 sub" of the sheet come from the
    // weapons themselves (no aftermath is on the sheet yet): they do not proc here.
    CALC.wsProcChances = function (stats, offHand) {
        return CALC.multiAttackChances(percent(stats, "QA"), percent(stats, "TA"), percent(stats, "DA"), 0);
    };

    // The swings of the weapon skill, by kind: {count, hand, offHand, ftp, bonus, accuracy, fullTP}.
    // Double Attack "Can Proc a maximum of 2 times per Weapon Skill" and "on [...] each weapon when
    // Dual Wielding": the two swings that can proc are the first main hand swing and the off-hand
    // swing, or the first two swings of a weapon skill of several hits without an off-hand.
    CALC.wsSwingKinds = function (ctx) {
        var s = ctx.stats, hits = ctx.info.hits || 1;
        // https://www.bg-wiki.com/ffxi/Weapon_Skill_Damage : "FTP replicating WSs share their fTP
        // with each additional attack"; the other hits of the others use an fTP of 1
        var later = ctx.info.replicating ? ctx.ftp : 1;
        var planned = hits + (ctx.dualWield ? 1 : 0);
        var second = ctx.dualWield ? CALC.wsProcChances(s, true) : hits > 1 ? CALC.wsProcChances(s, false) : null;
        var room = Math.max(0, CALC.WS_MAX_SWINGS - planned);
        var extra = CALC.wsExtraSwings(CALC.wsProcChances(s, false), second, room);
        var main = hand(ctx, false), off = ctx.dualWield ? hand(ctx, true) : null;
        // https://www.bg-wiki.com/ffxi/Weapon_Skill_Damage : Weapon Skill Damage on gear and from
        // job point gifts is additive and "affect[s] 1st hit Only".
        // https://www.bg-wiki.com/ffxi/Category:Weapon_Skills : "The first swing [...] receives a
        // substantial (~+100) accuracy bonus, while additional swings receive no bonus": the first
        // off-hand swing is an additional swing.
        var kinds = [{count: 1, hand: main, ftp: ctx.ftp, bonus: percent(s, "Weapon Skill Damage"),
            accuracy: CALC.WS_FIRST_SWING_ACCURACY, fullTP: true}];
        kinds.push({count: hits - 1 + extra[0] + (off ? 0 : extra[1]), hand: main, ftp: later});
        if (off) kinds.push({count: 1, hand: off, offHand: true, ftp: later, fullTP: true});
        if (off) kinds.push({count: extra[1], hand: off, offHand: true, ftp: later});
        return kinds;
    };

    CALC.weaponskillAverage = function (stats, enemy, name, tp, wield) {
        var info = CALC.weaponskillInfo(name), why = whyUnsupported(info);
        if (why) return {unsupported: why};
        var ctx = describe(stats, enemy, info, tp, wield || {});
        if (CALC.valueAtTP(info.ftp, ctx.tp) === null) return {unsupported: "fTP unknown at this TP"};
        if (Number.isNaN(ctx.crit)) return {unsupported: "critical hit rate unknown at this TP"};
        var full = CALC.tpPerHit(CALC.wsDelayForTP(stats, ctx.hold, ctx.dualWield), stats["Store TP"] || 0);
        var other = CALC.wsExtraSwingTP(stats["Store TP"] || 0);
        var result = {damage: 0, tpReturn: 0, swings: 0, tp: ctx.tp, ftp: ctx.ftp, critRate: ctx.crit, kinds: []};
        CALC.wsSwingKinds(ctx).forEach(function (kind) {
            if (!(kind.count > 0)) return;
            var one = swingDamage(ctx, kind.hand, kind.ftp, kind.bonus || 0, kind.accuracy || 0);
            result.damage += kind.count * one.damage;
            result.tpReturn += kind.count * one.landed * (kind.fullTP ? full : other);
            result.swings += kind.count;
            result.kinds.push({count: kind.count, landed: one.landed, base: one.base, pdif: one.pdif});
        });
        result.tpReturn += CALC.conserveTPAverage(stats["Conserve TP"] || 0);
        return result;
    };
});
