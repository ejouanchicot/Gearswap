// Atelier calculation engine, stage 3: how long an auto-attack round lasts, and the time needed
// to reach a weapon skill's TP.
//
//   CALC.roundDelay(stats, dualWield)         delay of one round before any reduction
//   CALC.roundTime(stats, dualWield, haste)   {delay, reduction, remaining, seconds} of one round
//   CALC.regainPerSecond(regain)              TP a second from "Regain"
//   CALC.timeToWeaponskill(round, startTP, targetTP)   seconds from one TP to another
//
// @file    atelier/calc/calc_round_time.js
// @author  ejouanchicot
(globalThis.CALC_PARTS = globalThis.CALC_PARTS || []).push(function (CALC) {
    // https://www.bg-wiki.com/ffxi/Attack_Speed
    //   "Using a 480-delay weapon (8 seconds per round) with the effect of Haste would change the
    //   attack speed to 85% of 480, or 408 (6.8 seconds per round)."  480 / 8 = 408 / 6.8 = 60.
    CALC.DELAY_PER_SECOND = 60;

    // https://www.bg-wiki.com/ffxi/Regain
    //   "Regain restores TP over time in 3 second intervals (Ticks)."
    CALC.REGAIN_TICK_SECONDS = 3;

    // https://www.bg-wiki.com/ffxi/Dual_Wield
    //   "Reduces the combined delay of these weapons by the Dual Wield % listed above, increasing
    //   the frequency of attack rounds."
    //   "(Delay1 + Delay2) x (1 - Dual Wield %) / 2 = New Delay per Hand"
    // The round swings both hands, so its delay is the two hands' together: Delay1 + Delay2 before
    // the reductions. ASSUMED: the page gives the delay "per Hand" and never the round's in so many
    // words (DIFFERENCES.md, T1). With one weapon, or hand-to-hand, "Delay1" of the sheet is the
    // round's delay (hand-to-hand: 480 + weapon - Martial Arts, stage 1).
    CALC.roundDelay = function (stats, dualWield) {
        return dualWield ? stats["Delay1"] + stats["Delay2"] : stats["Delay1"];
    };

    // https://www.bg-wiki.com/ffxi/Attack_Speed
    //   "(1 - 30% Dual Wield)x(1024 - 256 Equipment Haste - 150 Magic Haste - 101 Job Ability
    //   Haste)/1024 = 35.3% Delay remaining"; "there is a general 80% Delay reduction cap";
    //   "All types of Delay Reduction fall under this cap, from Sword Strap to Martial Arts to
    //   Dual Wield."; hand-to-hand: "The minimum delay possible for a Spharai (Level 99) would be
    //   (480 Base Delay + 86 Weapon Delay)*.2 Delay cap = 113.2 minimum possible delay."
    // So the delay left is never under 20% of the delay before Martial Arts. (The Martial_Arts
    // page says "the minimum H2H delay is 96 delay per round", 20% of 480 without the weapon: the
    // Attack_Speed example, which counts the weapon, is followed. DIFFERENCES.md, T2.)
    // `jobAbilityHaste` (optional) is added to the sheet's "JA Haste" (an aftermath, an ability
    // the sheet does not carry), as a fraction.
    CALC.roundTime = function (stats, dualWield, jobAbilityHaste) {
        var delay = CALC.roundDelay(stats, dualWield);
        var reduction = CALC.delayReduction(stats["Dual Wield"] || 0, stats["Gear Haste"] || 0,
            stats["Magic Haste"] || 0, (stats["JA Haste"] || 0) + (jobAbilityHaste || 0));
        var floor = (delay + (stats["Martial Arts"] || 0)) * (1 - CALC.DELAY_REDUCTION_CAP);
        var remaining = Math.max(delay * (1 - reduction), floor);
        return {delay: delay, reduction: reduction, remaining: remaining, seconds: remaining / CALC.DELAY_PER_SECOND};
    };

    // "Regain" +N of the sheet is taken as N TP every tick. ASSUMED: the Regain page lists
    // "Regain +10" (Vim Torque) and "10 TP/tick" (Adloquium) side by side and never equates the
    // two notations (DIFFERENCES.md, T3).
    CALC.regainPerSecond = function (regain) {
        return (regain || 0) / CALC.REGAIN_TICK_SECONDS;
    };

    // Seconds needed to go from `startTP` to `targetTP` with the rounds of `round` (the result of
    // CALC.attackRoundAverage) and its Regain. Our own arithmetic, not a game formula: the mean
    // TP of a round is spread evenly over the round's time, so the answer is a mean rate, not a
    // whole number of rounds (the round that crosses the target is counted for the share needed).
    CALC.timeToWeaponskill = function (round, startTP, targetTP) {
        var needed = Math.max(0, targetTP - (startTP || 0));
        var perSecond = round.tp / round.time + CALC.regainPerSecond(round.regain);
        return perSecond > 0 ? needed / perSecond : Infinity;
    };
});
