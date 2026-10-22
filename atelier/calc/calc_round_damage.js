// Atelier calculation engine, stage 3: the damage of one auto-attack swing.
//
//   CALC.roundCritRate(stats, enemy)      critical hit rate of an auto-attack
//   CALC.handToHandBaseDamage(skill)      damage the Hand-to-Hand skill is worth
//   CALC.roundAttacker(ctx, which)        numbers of the main hand, off-hand ("sub") or "kick"
//   CALC.SWING_RULES                      what each kind of swing changes (attack, damage, accuracy)
//   CALC.roundBaseDamage(dmg, fstr)       base damage of a swing
//   CALC.roundSwing(ctx, attacker, rule, multiplier)   {landed, base, pdif, damage} of one swing
//   CALC.aftermathMultipliers(options)    mean damage multipliers an aftermath or a relic gives
//
// The damage of a swing that is thrown is  chance to land x base damage x mean pDIF x bonuses,
// as for a weapon skill hit (calc_ws_average.js) with fTP 1 and no attribute bonus.
//
// @file    atelier/calc/calc_round_damage.js
// @author  ejouanchicot
(globalThis.CALC_PARTS = globalThis.CALC_PARTS || []).push(function (CALC) {
    function percent(stats, name) { return (stats[name] || 0) / 100; }

    // https://www.bg-wiki.com/ffxi/Critical_Hit_Rate
    //   "Every time players swing at a monster, they have a chance to critical hit."
    //   "critical hit rate is the sum of the base rate (5%), gear/atma (0-100%), merit points
    //   (0-5%), Buffs, Weapon Skill modifiers, and player Dexterity relative to target Agility";
    //   "As there is no cap to critical hit rate, it can be taken all the way to 100%".
    // "Crit Rate" of the sheet already holds the base rate, merits, traits, gear and buffs.
    CALC.roundCritRate = function (stats, enemy) {
        var rate = (stats["Crit Rate"] || 0) + CALC.critRateFromDex(stats.DEX, enemy.AGI);
        return Math.max(0, Math.min(1, rate / 100));
    };

    // https://www.bg-wiki.com/ffxi/Hand-to-Hand
    //   "Base Hand-to-Hand damage is calculated simply by multiplying Hand-to-Hand skill by 0.11
    //   and adding 3"; "The natural base delay of of Hand-to-Hand is 480."
    // The page gives no rounding: the product is kept, the floor comes with the base damage.
    CALC.handToHandBaseDamage = function (skill) {
        return skill * 0.11 + 3;
    };

    function handToHandSkill(stats) {
        return (stats["Hand-to-Hand Skill"] || 0) + (stats["main Hand-to-Hand Skill"] || 0);
    }

    // https://www.bg-wiki.com/ffxi/Kick_Attacks
    //   "Kick Attack damage is equal to base Hand-to-Hand damage."; "The damage can only be
    //   improved by wearing specific pieces of armor." ("Kick DMG" of the sheet);
    //   "fSTR does apply to kick attacks (R0 weapon if you don't have kick damage modifying gear
    //   on)". ASSUMED: with such gear the rank is the hand-to-hand rank of "Kick DMG", the page
    //   only gives the case without (DIFFERENCES.md, T9).
    function kick(ctx) {
        var s = ctx.stats, h = CALC.handNumbers(s, ctx.enemy, ctx.hold, false), gear = s["Kick DMG"] || 0;
        h.dmg = CALC.handToHandBaseDamage(handToHandSkill(s)) + gear;
        h.fstr = CALC.fSTR(s.STR, ctx.enemy.VIT, gear, true);
        return h;
    }

    // One attacker of the round: the main hand (or a fist), the off-hand, or the kick.
    // Hand-to-hand: the weapon's damage is added to the skill's (the page of
    // CALC.handToHandBaseDamage; https://www.bg-wiki.com/ffxi/Base_Damage : "Base Damage = D +
    // (aD) + fSTR").
    CALC.roundAttacker = function (ctx, which) {
        if (which === "kick") return kick(ctx);
        var h = CALC.handNumbers(ctx.stats, ctx.enemy, ctx.hold, which === "sub");
        if (ctx.hold === "handToHand") h.dmg += CALC.handToHandBaseDamage(handToHandSkill(ctx.stats));
        return h;
    };

    // https://www.bg-wiki.com/ffxi/Zanshin   "Zanshin hits receive a 34 Accuracy bonus."
    CALC.ZANSHIN_ACCURACY = 34;

    // What a kind of swing changes. `attack`: a stat of the sheet added to the swing's attack;
    // `damage`: a stat in percent that multiplies its damage; `accuracy`: added to its accuracy;
    // `zanshin`: the swing gives the TP of a Zanshin swing.
    //   da  https://www.bg-wiki.com/ffxi/Warrior , job point category "Double Attack Effect":
    //       "Increases physical attack from double attacks." "Increase physical attack by 1."
    //       ("DA Attack"); "DA Damage%": CALC.doubleAttackDamageBonus (measured in game).
    //   ta  https://www.bg-wiki.com/ffxi/Thief , "Triple Attack Effect": "Increases the physical
    //       attack of Triple Attack" "Increase physical attack by 1" ("TA Attack");
    //       https://www.bg-wiki.com/ffxi/Triple_Attack lists "Triple Attack damage" gear and gives
    //       no rule ("TA Damage%").
    //   zanshin, hasso  https://www.bg-wiki.com/ffxi/Samurai , "Zanshin Effect": "Increases the
    //       physical attack of Zanshin. Increases physical attack by 2." ("Zanshin Attack")
    // `first` holds what the FIRST swing of a round of that kind gets.
    // measured in game 2026-10-09: "Double Attack" damage is on both swings of the round (first
    //   and second swing have the same distribution, 169 hits with Ikenga's Axe).
    // ASSUMED (DIFFERENCES.md, T5): "DA Attack", "TA Attack" and "TA Damage%" follow the same
    // pattern, every swing of the round of that hand, the first included; an attack bonus is
    // added to the finished attack, not multiplied by the percentage bonuses; the swing Hasso
    // adds is a Zanshin hit for accuracy, attack and TP.
    var DOUBLE = {attack: "DA Attack", damage: "DA Damage%", doubleAttack: true};
    var TRIPLE = {attack: "TA Attack", damage: "TA Damage%"};
    var ZANSHIN = {attack: "Zanshin Attack", accuracy: CALC.ZANSHIN_ACCURACY, zanshin: true};
    CALC.SWING_RULES = {qa: {}, oa: {}, none: {}, da: DOUBLE, ta: TRIPLE, hasso: ZANSHIN, zanshin: ZANSHIN,
        first: {da: DOUBLE, ta: TRIPLE}};

    // damage multiplier of a swing in a round of kind `rule`: "Double Attack" damage through the
    // measured rule (a round of two swings made by Double Attack), "TA Damage%" likewise
    function damageBonus(stats, rule) {
        if (rule.doubleAttack) return CALC.doubleAttackDamageBonus(stats[rule.damage], 2, true);
        return rule.damage ? 1 + percent(stats, rule.damage) : 1;
    }

    // https://www.bg-wiki.com/ffxi/Base_Damage   melee: "Base Damage = D + (aD) + fSTR"; the page
    //   writes the floor in the Sneak Attack line, "Base Damage = floor(D + fSTR) + Total DEX".
    // ASSUMED: the base of a plain swing is floored the same way (DIFFERENCES.md, T6); the game's
    // damage at pDIF 1 is a whole number (measured in game 2026-10-09: the hits at pDIF 1 fill
    // [S, 1.05 S] with S whole), which a base in quarters would not give.
    CALC.roundBaseDamage = function (dmg, fstr) {
        return Math.floor(dmg + fstr);
    };

    // Mean result of one swing that is thrown.
    // https://www.bg-wiki.com/ffxi/Physical_Damage   "Physical Damage = [Base Damage] * [pDIF]"
    // The mean pDIF, critical hits included, is the weapon skill's (CALC.wsMeanPdif): ratio + 1,
    // same limits, no spike and "Crit Damage" on the critical hits only, measured in game
    // 2026-10-09 on auto-attack swings (359 critical hits).
    CALC.roundSwing = function (ctx, attacker, rule, multiplier) {
        var s = ctx.stats;
        var attack = attacker.attack + (rule.attack ? s[rule.attack] || 0 : 0);
        var landed = CALC.hitRate(attacker.accuracy + (rule.accuracy || 0), ctx.enemy.Evasion, attacker.cap);
        var base = CALC.roundBaseDamage(attacker.dmg, attacker.fstr);
        var pdif = CALC.wsMeanPdif(attack / ctx.enemy.Defense, ctx.pdifCap, ctx.crit, percent(s, "Crit Damage"));
        var bonus = damageBonus(s, rule) * (multiplier || 1);
        return {landed: landed, base: base, pdif: pdif, bonus: bonus, damage: landed * base * pdif * bonus};
    };

    // https://www.bg-wiki.com/ffxi/Empyrean_Aftermath
    //   "Every Empyrean gets an 'Occasionally Doubles Damage' aftermath(or 'Occasionally Triples
    //   Damage' at ilv119 III)"; rates by aftermath level "30%", "40%", "50%" (1000~1999,
    //   2000~2999, 3000 TP), the same in both tables; "Empyrean Aftermath cannot proc on Weapon
    //   Skills."; "Unlike Relics, Empyrean double/triple damage can proc on any additional hits
    //   (Double Attack, Triple Attack, Zanshin) initiated by the weapon."
    // measured in game 2026-10-09 (to compare, not fitted): Ukonvasara, Aftermath: Lv.1, 16 of
    //   58 landed swings (28%, [17, 41]) deal three times the damage.
    CALC.EMPYREAN_AFTERMATH_RATE = [0.3, 0.4, 0.5];

    // https://www.bg-wiki.com/ffxi/Apocalypse_(Level_119_III)
    //   "Hidden Effect: Does Double Damage on the first swing of an attack round 20% of the time."
    //   "Will never activate on hits from Double Attack, Triple Attack, etc."
    //   "Unlike its predecessors, Aftermath on this version of the weapon gives 10% Job Ability
    //   Haste and 15 Accuracy."
    // Only the relics whose page was read are here; `haste` is taken as 10 / 100 of the delay
    // (the page gives a percentage, not 1024ths).
    var APOCALYPSE = {firstSwing: {rate: 0.2, multiplier: 2}, aftermath: {haste: 0.1, accuracy: 15}};
    // Laphria (a prime weapon, stage IV): no page gives this (the weapon's pages carry no hidden effect and the
    // Disaster page says "Information Needed" for the aftermath). Measured in game on 2026-10-10 and 11 (Tetsouo WAR,
    // 767 first swings of a round, each set against the later swings of the same fight, which never double: 0 of
    // 918): the first swing deals twice the damage 33.4 % of the time (256 of 767, +-3.3; x2.04 a plain swing),
    // critical or not, whatever the aftermath level (none 38 %, Lv.1 31 %, Lv.2 36 %, Lv.3 28 %), and never on a
    // weaponskill (no Disaster of 190 near twice its size). Stage IV only: another stage is not measured, and the
    // other prime weapons are not either
    var LAPHRIA = {firstSwing: {rate: 0.33, multiplier: 2}};
    // Mpu Gandring (a prime weapon, stage IV: DMG 130, "Triple Attack"+4%): its pages carry no hidden effect either.
    // Measured in game on 2026-10-13 (Tetsouo DNC, main hand, Locus Ghost Crabs): 156 of 424 plain first swings of a
    // round (36.8 %, 33 to 46 % by fight) are above the largest later swing of the same fight, at twice the damage;
    // no later swing does it. The same stage and the same effect as Laphria's, within the two measures' errors
    var MPU_GANDRING = {firstSwing: {rate: 0.37, multiplier: 2}};
    // Read on 2026-10-22, each "Hidden Effect" followed on its page by "Will never activate on hits from Double
    // Attack, Triple Attack, etc.":
    // https://www.bg-wiki.com/ffxi/Mandau_(Level_119_III)
    //   "Does Triple Damage on the first swing of an attack round 13% of the time."
    // https://www.bg-wiki.com/ffxi/Bravura_(Level_119_III)
    //   "Does Double Damage on the first swing of an attack round 20% of the time."
    // https://www.bg-wiki.com/ffxi/Ragnarok_(Level_119_III)
    //   "Does 2.5x Damage on the first swing of an attack round 16% of the time."
    // Not measured by us. Their aftermaths are not here (the case goes to the engine before, as without an entry)
    var MANDAU = {firstSwing: {rate: 0.13, multiplier: 3}};
    var BRAVURA = {firstSwing: {rate: 0.2, multiplier: 2}};
    var RAGNAROK = {firstSwing: {rate: 0.16, multiplier: 2.5}};
    // the stage is in the name the gear gives the weapon ("Laphria IV"): the other stages have no entry
    CALC.RELIC_WEAPON = {"Apocalypse": APOCALYPSE, "Apocalypse R15": APOCALYPSE, "Laphria IV": LAPHRIA,
        "Mpu Gandring IV": MPU_GANDRING, "Mandau": MANDAU, "Mandau R15": MANDAU, "Bravura": BRAVURA,
        "Bravura R15": BRAVURA, "Ragnarok": RAGNAROK, "Ragnarok R15": RAGNAROK};

    // Mean damage multipliers from `options` = {aftermath: {type: "empyrean", level: 1..3,
    // multiplier: 2 or 3}, main: "Apocalypse R15"} (the main hand weapon as the gear names it).
    // Returns {mainHand: every swing of the main hand weapon, firstSwing: its first swing only}.
    CALC.aftermathMultipliers = function (options) {
        var am = options.aftermath || {}, hidden = (CALC.RELIC_WEAPON[options.main] || {}).firstSwing;
        var result = {mainHand: 1, firstSwing: 1};
        if (am.type === "empyrean" && CALC.EMPYREAN_AFTERMATH_RATE[am.level - 1]) {
            result.mainHand = 1 + CALC.EMPYREAN_AFTERMATH_RATE[am.level - 1] * ((am.multiplier || 2) - 1);
        }
        if (hidden) result.firstSwing = 1 + hidden.rate * (hidden.multiplier - 1);
        return result;
    };
});
