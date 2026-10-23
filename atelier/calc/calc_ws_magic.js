// Atelier calculation engine, stage 2 (magic): the average damage and TP return of a magical weapon skill.
//
//   CALC.MAGIC_WS                          what each magical weapon skill's BG-Wiki page adds to our database
//   CALC.hybridWeaponskillAverage(stats, enemy, name, tp, wield, ranged)
//       a hybrid one: its physical part (calc_ws_average.js, or calc_ws_ranged.js when `ranged`) and its magical one
//   CALC.magicWeaponskillAverage(stats, enemy, name, tp, wield)
//       stats   the character sheet; enemy {INT, MND, AGI, "Magic Evasion", "Magic Defense", "Magic Damage Taken"}
//       wield   {main: the main hand's name as calc_ws_average.js reads it, weaponLevel: its item level (its level
//               when it has none), gearset: for the obi}
//       returns {damage, tpReturn, unresisted, hitRate, magicAccuracy} or {unsupported: "why"}
//
// https://www.bg-wiki.com/ffxi/Weapon_Skill_Damage ("Calculating Magical Weapon Skill Damage", last edited
// 2026-05-24):
//   "Base Magical WS Damage = floor(((152 + floor((WeaponLevel - 99) × 2.45) + WSC) × fTP) + dSTAT + MDMG Stat)"
//   "If WeaponLevel < 100 → Base Magical WS Damage = floor(((5 + floor((Level - 1) × 1.5) + WSC) × fTP) + dSTAT
//   + MDMG Stat)"; "Every step is floored before moving onto the step below."
//   "Magical WS Damage = Base Magical WS Damage × Affinity × Staff × Resist × Resistance Rank Reduction ×
//   Weather+Day Bonus × (MAB ÷ MDB) × TMDA × Magic Critical Hit II Factor × WSD × Potency Multipliers × WSD Boost JT
//   × Weapon Skill Potency Bonus × Augmented Weapon Skill Potency Bonus"
//   Weapon Skill Damage on gear, gifts and food: "applied to all of a magic weapon skill".
// https://wiki.ffo.jp/html/1083.html gives the same base: "アイテムレベル武器: (IL-100)x2.5+154" (201 at 119, as
// above), "アイテムレベルなし: (Lv-1)x1.5+5". A user test page (BG-Wiki User:Darvamos/Test, 2022) puts dSTAT and
// Magic Damage inside the fTP: not taken, the main page is newer.
// https://www.bg-wiki.com/ffxi/Category:Elemental_Weapon_Skill : "Magical Weapon Skills never miss, but are subject
// to magical resist states."
//
// ASSUMED (no page gives them; DIFFERENCES.md AK):
//   magic accuracy: the weapon skill's combat skill, the main hand's Magic Accuracy Skill, Magic Accuracy, the dINT
//     of spells (calc_magic.js), and +100 ("it is assumed that Elemental Weapon Skills receive a similar Magic
//     Accuracy bonus" to the "~+100" of a physical one's first swing, the same page);
//   TP return: one full hit of the main hand (calc_ws_tp.js), as a one-hit weapon skill that always lands;
//   no day, weather or resistance rank given: none, as the damaging spells (calc_magic.js CALC.MAGIC_ASSUME).
//
// @file    atelier/calc/calc_ws_magic.js
// @author  ejouanchicot
(globalThis.CALC_PARTS = globalThis.CALC_PARTS || []).push(function (CALC) {
    var U = "https://www.bg-wiki.com/ffxi/";
    function same(v) { return [v, v, v]; }
    // dSTAT: (player's p - enemy's m) x mul + add, at most cap; read 2026-10-23 on each page's box
    function d(p, m, mul, add, cap) { return {p: p, m: m, mul: mul, add: add || 0, cap: cap === undefined ? null : cap}; }
    var INT_HALF = d("INT", "INT", 0.5, 8, 32);

    // name -> {url, dstat (null: "0", "None" or "N/A" on the page), and what our database lacks: ftp, element}.
    // weapons: as in calc_ws_details.js, the main hands that raise its damage: the mythic's "(Level 119 III)" page,
    // Hidden Effect "Primal Rend damage +30%." and rank 15 augment "Primal Rend: Damage +15%", "total damage bonus is
    // +49.5% because they are different terms in the equation that get multiplied together" (Tupsimati and
    // Laevateinn likewise, read 2026-10-23).
    // base: "level" for the two that keep "your level + 2" (Starburst, Sunburst).
    CALC.MAGIC_WS = {
        "Aeolian Edge": {url: U + "Aeolian_Edge", dstat: INT_HALF, ftp: [2, 3, 4.5], element: "Wind"},
        "Cyclone": {url: U + "Cyclone", dstat: INT_HALF, ftp: [1, 2.375, 3.75], element: "Wind",
            unverified: "fTP at 3000 TP"},
        "Gust Slash": {url: U + "Gust_Slash", dstat: INT_HALF, ftp: [1, 2, 3], element: "Wind",
            unverified: "fTP at 3000 TP"},
        "Blade: Ei": {url: U + "Blade:_Ei", dstat: INT_HALF},
        "Blade: Yu": {url: U + "Blade:_Yu", dstat: null},
        "Burning Blade": {url: U + "Burning_Blade", dstat: INT_HALF},
        "Cataclysm": {url: U + "Cataclysm", dstat: INT_HALF},
        "Cloudsplitter": {url: U + "Cloudsplitter", dstat: null},
        "Dark Harvest": {url: U + "Dark_Harvest", dstat: INT_HALF, unverified: "fTP at 2000 and 3000 TP"},
        // the page as read gives "(pINT-mINT)" with no divisor, cap 32
        "Earth Crusher": {url: U + "Earth_Crusher", dstat: d("INT", "INT", 1, 0, 32)},
        "Flash Nova": {url: U + "Flash_Nova", dstat: INT_HALF},
        "Freezebite": {url: U + "Freezebite", dstat: INT_HALF},
        "Frostbite": {url: U + "Frostbite", dstat: INT_HALF, unverified: "fTP"},
        "Garland of Bliss": {url: U + "Garland_of_Bliss", dstat: d("MND", "MND", 2)},
        "Herculean Slash": {url: U + "Herculean_Slash", dstat: null},
        "Infernal Scythe": {url: U + "Infernal_Scythe", dstat: null},
        "Omniscience": {url: U + "Omniscience", dstat: d("MND", "MND", 2), weapons: {"Tupsimati": [1.3], "Tupsimati R15": [1.3, 1.15]}},
        "Primal Rend": {url: U + "Primal_Rend", dstat: d("CHR", "INT", 1.5, 0, 651), weapons: {"Aymur": [1.3], "Aymur R15": [1.3, 1.15]}},
        "Raiden Thrust": {url: U + "Raiden_Thrust", dstat: INT_HALF, unverified: "fTP at 2000 and 3000 TP"},
        "Red Lotus Blade": {url: U + "Red_Lotus_Blade", dstat: INT_HALF},
        "Rock Crusher": {url: U + "Rock_Crusher", dstat: INT_HALF},
        "Sanguine Blade": {url: U + "Sanguine_Blade", dstat: d("INT", "INT", 2)},
        "Seraph Blade": {url: U + "Seraph_Blade", dstat: null},
        "Seraph Strike": {url: U + "Seraph_Strike", dstat: null},
        "Shadow of Death": {url: U + "Shadow_of_Death", dstat: INT_HALF},
        "Shining Blade": {url: U + "Shining_Blade", dstat: null},
        "Shining Strike": {url: U + "Shining_Strike", dstat: null},
        // "a base damage of your level + 2", "doesn't use your weapon's item level"; "Blunt Damage Taken % instead
        // of Magic Damage Taken %": the target here carries no blunt share, its magic one is kept (DIFFERENCES.md AK)
        "Starburst": {url: U + "Starburst", dstat: INT_HALF, base: "level"},
        "Sunburst": {url: U + "Sunburst", dstat: INT_HALF, base: "level"},
        "Thunder Thrust": {url: U + "Thunder_Thrust", dstat: INT_HALF, unverified: "fTP at 2000 and 3000 TP"},
        "Vidohunir": {url: U + "Vidohunir", dstat: d("INT", "INT", 2), weapons: {"Laevateinn": [1.3], "Laevateinn R15": [1.3, 1.15]}},
        // ranged ones (our database has no Marksmanship file): the ranged weapon's item level, "メインウェポン（遠隔の
        // 場合はレンジウェポン）" (https://wiki.ffo.jp/html/806.html); Death Penalty and Gastraphetes "(Level 119 III)":
        // "damage +30%", "+49.5%" at rank 15. Leaden Salute's and Trueflight's dSTAT caps: "Information Needed", none here
        "Leaden Salute": {url: U + "Leaden_Salute", skill: "Marksmanship", type: "Magical", mods: {AGI: 100}, ftp: [4, 6.7, 10],
            element: "Dark", dstat: d("AGI", "INT", 2), weapons: {"Death Penalty": [1.3], "Death Penalty R15": [1.3, 1.15]}},
        "Wildfire": {url: U + "Wildfire", skill: "Marksmanship", type: "Magical", mods: {AGI: 60}, ftp: same(5.5), element: "Fire",
            dstat: d("AGI", "INT", 2, 0, 1276)},
        "Trueflight": {url: U + "Trueflight", skill: "Marksmanship", type: "Magical", mods: {AGI: 100},
            ftp: [3.890625, 6.4921875, 9.671875], element: "Light", dstat: d("AGI", "INT", 2),
            weapons: {"Gastraphetes": [1.3], "Gastraphetes R15": [1.3, 1.15]}}
    };
    // "Does not do damage" (Energy Drain, Energy Steal); only in a Campaign battle (Tartarus Torpor, Uriel Blade)
    var NO_DAMAGE = {"Energy Drain": "it does no damage", "Energy Steal": "it does no damage",
        "Tartarus Torpor": "Campaign only", "Uriel Blade": "Campaign only"};

    CALC.MAGIC_WS_ACCURACY_BONUS = 100;
    var LEVEL = 99, LEVEL_BASE_PLUS = 2;

    function infoOf(name) {
        var base = CALC.weaponskillInfo(name) || {}, page = CALC.MAGIC_WS[name] || {}, out = {name: name};
        [base, page].forEach(function (src) { Object.keys(src).forEach(function (k) { if (src[k] !== null && src[k] !== undefined) out[k] = src[k]; }); });
        out.dstat = page.dstat || null;
        return out;
    }

    function dstatOf(stats, enemy, rule) {
        if (!rule) return 0;
        var v = Math.floor(((stats[rule.p] || 0) - (enemy[rule.m] || 0)) * rule.mul + rule.add);
        return rule.cap === null ? v : Math.min(v, rule.cap);
    }

    // the 152 / 5 term: by the weapon's item level, else its level; "your level + 2" for the two that keep it
    function levelTerm(info, weaponLevel) {
        if (info.base === "level") return LEVEL + LEVEL_BASE_PLUS;
        var wl = weaponLevel || LEVEL;
        return wl < 100 ? 5 + Math.floor((wl - 1) * 1.5) : 152 + Math.floor((wl - 99) * 2.45);
    }

    // the element's affinity on the gear, and "Elemental Bonus" of every element: Orpheus's Sash, "1 to 15, by distance"
    // (calc_magic.js); a weapon skill is given no distance: ASSUMED at its closest, the catalogue's 15
    function affinityOf(stats, element) {
        return 1 + ((stats[element + " Elemental Bonus"] || 0) + (stats["Elemental Bonus"] || 0)) / 100;
    }

    function magicAccuracy(stats, enemy, info) {
        return (stats[info.skill + " Skill"] || 0) + (stats["main Magic Accuracy Skill"] || 0) + (stats["Magic Accuracy"] || 0) +
            CALC.dIntMagicAccuracy((stats.INT || 0) - (enemy.INT || 0)) + CALC.MAGIC_WS_ACCURACY_BONUS;
    }

    // the multipliers after the base, in the page's order, each product floored; one element (Starburst's two:
    // the average of both)
    function chain(base, stats, enemy, info, element, resist, critTwo, dayWeather, wield) {
        var mdb = Math.max(0.5, 1 + (enemy["Magic Defense"] || 0) / 100);
        var steps = [affinityOf(stats, element), resist, dayWeather,
            (1 + (stats["Magic Attack"] || 0) / 100) / mdb, Math.max(0.5, 1 - (enemy["Magic Damage Taken"] || 0) / 100)];
        if (critTwo) steps.push(CALC.MAGIC_CRIT.twoMultiplier);
        steps.push(1 + (stats["Weapon Skill Damage"] || 0) / 100, 1 + (stats["Weapon Skill Damage Trait"] || 0) / 100);
        steps = steps.concat((info.weapons || {})[wield.main] || []);
        return steps.reduce(function (value, factor) { return Math.floor(value * factor); }, base);
    }

    function whyNot(info, name) {
        if (NO_DAMAGE[name]) return "magical weapon skill: " + NO_DAMAGE[name];
        if (!info.ftp || !info.mods || !info.element) return "magical weapon skill without fTP, modifiers or element";
        if (!CALC.MAGIC_WS[name]) return "magical weapon skill not read on its page yet";
        return null;
    }

    // Hybrid weapon skills. https://www.bg-wiki.com/ffxi/Weapon_Skill_Damage : "Base damage for these weaponskills is
    // calculated exactly the same as for Physical Weapon Skills", the magical part "affected by modifiers of magic damage".
    // How, measured (FFXIAH): Bahadir, Blade: To, "TotalDmg = PhysDmg + (PhysDmg*fTP+mDmg)*MAB/MDB", "fTP is only applied
    // to magical dmg, NOT physical one", 492 / 851 / 1203 measured against 486 / 847 / 1208 at 1000 / 2000 / 3000 TP
    // (https://www.ffxiah.com/forum/topic/49614/blade-chi-damage-formula/2/ #3171538, 2016-10-07); Snapster, "Magical Hit =
    // ((Magic Base + mDMG) * MAB * (1/MDB)* Affinity * Day/Weather * SDT * TMDA * WSD + Physical Hit * Modifier", the
    // Modifier being the gorget's and belt's fTP, "not multiplied by fTP/MAB/WSD", Blade: Chi 6777 against 6763 at 3000 TP
    // (https://www.ffxiah.com/forum/topic/33470/the-sealed-dagger-a-ninja-guide/151/ #3420722, #3420836, 152/ #3423103,
    // 2019). The physical part is a physical weapon skill at fTP 1.0 (wiki.ffo.jp 720 / 1261: "倍率 1.0"), all its hits; the
    // magical one the whole of it times the page's "+0.5 / +1.375 / +2.25" ("TP:ダメージ修正": the share added as magic),
    // only when it lands. Blade: Chi's and Teki's +1.375 at 2000 TP is Snapster's line, "I didn't test the 2000 TP scaling
    // values for Chi and Teki" (wiki.ffo.jp writes +1.5).
    // ASSUMED: its magic accuracy is a magical weapon skill's (above); the Magic Damage stat comes in as often as the first
    // hit lands; the floors of the game are not averaged (the mean of the physical part is multiplied).
    CALC.hybridWeaponskillAverage = function (stats, enemy, name, tp, wield, ranged) {
        var base = ranged ? CALC.RANGED_WS[name] : CALC.weaponskillInfo(name);
        if (!base || base.type !== "Hybrid" || !base.ftp || !base.element) return {unsupported: "hybrid weapon skill without its numbers"};
        var physicalInfo = Object.assign({name: name}, base, {type: "Physical", ftp: same(1), replicating: false});
        var w = Object.assign({}, wield || {}, {info: physicalInfo});
        var physical = ranged ? CALC.rangedWeaponskillAverage(stats, enemy, name, tp, w) : CALC.weaponskillAverage(stats, enemy, name, tp, w);
        if (physical.unsupported) return physical;
        var used = Math.min(3000, tp + (stats["TP Bonus"] || 0));
        var landed = ranged ? physical.hitRate : physical.kinds[0].landed;
        var macc = magicAccuracy(stats, enemy, base), chances = CALC.resistChances(CALC.magicHitRate(macc, enemy["Magic Evasion"] || 0));
        var resist = chances.reduce(function (s, c, i) { return s + c * CALC.RESIST_STATES[i]; }, 0);
        var mdb = Math.max(0.5, 1 + (enemy["Magic Defense"] || 0) / 100);
        var magic = (physical.damage * CALC.valueAtTP(base.ftp, used) + landed * (stats["Magic Damage"] || 0)) *
            (1 + (stats["Weapon Skill Damage"] || 0) / 100) * affinityOf(stats, base.element) *
            (1 + (stats["Magic Attack"] || 0) / 100) / mdb + physical.damage * (stats["ftp"] || 0);
        magic *= resist * Math.max(0.5, 1 - (enemy["Magic Damage Taken"] || 0) / 100);
        return {damage: physical.damage + magic, tpReturn: physical.tpReturn, physical: physical.damage, magic: magic};
    };

    CALC.magicWeaponskillAverage = function (stats, enemy, name, tp, wield) {
        var info = infoOf(name), w = wield || {}, why = whyNot(info, name);
        if (why) return {unsupported: why};
        var used = Math.min(3000, tp + (stats["TP Bonus"] || 0));
        // the elemental gorget and belt: "ftp" on the sheet, as for a physical weapon skill (calc_ws_average.js);
        // https://wiki.ffo.jp/html/806.html: they raise an elemental weaponskill's power, not its accuracy
        var ftp = CALC.valueAtTP(info.ftp, used) + (stats["ftp"] || 0);
        var base = Math.floor((levelTerm(info, w.weaponLevel) + CALC.wsAttributeBonus(stats, info.mods)) * ftp) +
            dstatOf(stats, enemy, info.dstat) + (stats["Magic Damage"] || 0);
        var macc = magicAccuracy(stats, enemy, info), rate = CALC.magicHitRate(macc, enemy["Magic Evasion"] || 0);
        var chances = CALC.resistChances(rate), two = Math.min((stats["Magic Crit Rate II"] || 0) / 100, 1);
        var elements = String(info.element).split("/"), obi = CALC.wearsObi(w.gearset) ? 1 : CALC.MAGIC_ASSUME.dayWeatherProc;
        var dw = CALC.magicDayWeather({}), total = 0;
        elements.forEach(function (element) {
            CALC.RESIST_STATES.forEach(function (resist, i) {
                [[true, two], [false, 1 - two]].forEach(function (c) {
                    [[dw, obi], [1, 1 - obi]].forEach(function (x) {
                        var weight = chances[i] * c[1] * x[1] / elements.length;
                        if (weight > 0) total += weight * chain(base, stats, enemy, info, element, resist, c[0], x[0], w);
                    });
                });
            });
        });
        // a ranged one: one full shot, the ranged weapon's delay and the ammunition's (https://www.bg-wiki.com/ffxi/Tactical_Points)
        var hold = CALC.TWO_HANDED.indexOf(info.skill) !== -1 ? "twoHanded" : info.skill === "Hand-to-Hand" ? "handToHand" : "oneHanded";
        var delay = CALC.RANGED_SKILLS.indexOf(info.skill) !== -1 ? (stats["Ranged Delay"] || 0) + (stats["Ammo Delay"] || 0)
            : CALC.wsDelayForTP(stats, hold, hold === "oneHanded" && (stats["DMG2"] || 0) > 0);
        var full = CALC.tpPerHit(delay, stats["Store TP"] || 0);
        return {damage: total, tpReturn: full + CALC.conserveTPAverage(stats["Conserve TP"] || 0),
            unresisted: chain(base, stats, enemy, info, elements[0], 1, false, 1, w), hitRate: rate, magicAccuracy: macc, base: base};
    };
});
