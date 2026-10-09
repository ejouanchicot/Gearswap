// Atelier calculation engine, stage 2: pDIF, the multiplier a melee hit draws from the ratio
// of the attacker's attack to the enemy's defense.
//
//   CALC.pdifLimits(wRatio)                 {lower, upper}: the bounds of the draw
//   CALC.pdifCap(hold, skill, trait, gear)  the highest pDIF of a non critical hit
//   CALC.pdifSpikeShare(wRatio)             share of the non critical hits whose pDIF is exactly 1
//   CALC.pdifAverage(ratio, cap, critical)  the mean pDIF of one hit, final 1.00-1.05 draw included
//
// Average: the page says "Randomly select a value between LL and UL" and "multiply it by a
// random number between 1 and 1.05", without naming the distributions. Both are taken as
// uniform (measured in game 2026-10-09: 517 plain hits fill the page's limits evenly, and the
// hits at pDIF 1 fill [S, 1.05 S]): the mean of the first is the mean of a uniform draw cut at
// the cap, mixed with the spike at pDIF 1 for the hits that are not critical; the mean of the
// second is 1.025. The floors of the game's integer damage ("flooring each step") are not
// averaged: the mean is that of the unrounded product.
//
// @file    atelier/calc/calc_ws_pdif.js
// @author  ejouanchicot
(globalThis.CALC_PARTS = globalThis.CALC_PARTS || []).push(function (CALC) {
    // https://www.bg-wiki.com/ffxi/PDIF  "multiply it by a random number between 1 and 1.05"
    CALC.PDIF_FINAL_DRAW_MEAN = 1.025;

    // https://www.bg-wiki.com/ffxi/PDIF  melee, upper limit by wRatio
    //   0 <= wRatio < 0.5: wRatio + 0.5 ; < 0.7: 1 ; < 1.2: wRatio + 0.3 ;
    //   < 1.5: wRatio x 0.25 + wRatio ; 1.5 <= wRatio: wRatio + 0.375
    function upperLimit(w) {
        if (w < 0.5) return w + 0.5;
        if (w < 0.7) return 1;
        if (w < 1.2) return w + 0.3;
        if (w < 1.5) return w * 0.25 + w;
        return w + 0.375;
    }

    // https://www.bg-wiki.com/ffxi/PDIF  melee, lower limit by wRatio
    //   < 0.38: 0 ; < 1.25: wRatio x 1176/1024 - 448/1024 ; < 1.51: 1 ;
    //   < 2.44: wRatio x 1176/1024 - 755/1024 ; 2.44 <= wRatio: wRatio - 0.375
    function lowerLimit(w) {
        if (w < 0.38) return 0;
        if (w < 1.25) return w * 1176 / 1024 - 448 / 1024;
        if (w < 1.51) return 1;
        if (w < 2.44) return w * 1176 / 1024 - 755 / 1024;
        return w - 0.375;
    }

    CALC.pdifLimits = function (wRatio) {
        return {lower: lowerLimit(wRatio), upper: upperLimit(wRatio)};
    };

    // https://www.bg-wiki.com/ffxi/PDIF  pDIF caps, non critical / critical:
    //   1-Handed 3.25 / 4.25 ; H2H and Great Katana 3.5 / 4.5 ;
    //   2-Handed (Great Sword, Staff, Great Axe, Polearm) 3.75 / 4.75 ; Scythe 4 / 5
    CALC.PDIF_CAP = {oneHanded: 3.25, handToHand: 3.5, "Great Katana": 3.5, twoHanded: 3.75, Scythe: 4};

    // "The top table lays out the pDIF caps per job / weapon type, including the Damage Limit+
    // Job Trait, but there are other sources of Physical Damage Limit +% [...] that are
    // multiplicative with this limit." https://www.bg-wiki.com/ffxi/PDIF
    // The trait adds to the cap (https://www.bg-wiki.com/ffxi/Damage_Limit%2B), the gear multiplies.
    CALC.pdifCap = function (hold, skill, trait, gear) {
        var base = CALC.PDIF_CAP[skill] || CALC.PDIF_CAP[hold];
        return (base + trait) * (1 + gear);
    };

    // mean of a uniform draw on [lower, upper] cut at `cap`
    function meanBelowCap(lower, upper, cap) {
        if (upper <= cap) return (lower + upper) / 2;
        if (lower >= cap) return cap;
        return ((cap * cap - lower * lower) / 2 + cap * (upper - cap)) / (upper - lower);
    }

    // https://www.bg-wiki.com/ffxi/PDIF , "Average Melee pDIF(qRatio)": a share of the hits has a
    // pDIF of exactly 1, the "spike": "the Spike frequency started at 0.5 wratio and rose linearly
    // to plateau at 33% between 0.75 and 1.25 before finally falling linearly again to 0 at 1.5
    // wRatio";  "sRatio = (0.5 - abs(wRatio - 1)) * 1.2", "if (sRatio < 0) then sRatio = 0",
    // "if (sRatio > .333) then sRatio = 0.333".
    // measured in game 2026-10-09: share of plain hits at pDIF 1: 22.5% at w 1.33 (215 hits),
    // 41% at 1.12 (169), 27.5% at 1.04 (113), none at 1.86 (20); the formula gives 20.6%, 33.3%,
    // 33.3% and 0. No spike on critical hits (359 critical hits).
    CALC.PDIF_SPIKE_MAX = 0.333;

    CALC.pdifSpikeShare = function (wRatio) {
        return Math.max(0, Math.min(CALC.PDIF_SPIKE_MAX, (0.5 - Math.abs(wRatio - 1)) * 1.2));
    };

    // https://www.bg-wiki.com/ffxi/PDIF
    //   "If you critical hit: wRatio = (cRatio + 1)"; the critical cap is the other cap + 1
    //   ("1H qRatio caps at 3.25 for non-crits and 4.25 for crits"). Order on the page: wRatio,
    //   the two limits (their conditions are written on wRatio), "Randomly select a value between
    //   LL and UL", then "If the value is greater than the cap shown for your weapon type [...]
    //   set to the cap value": the cap cuts the value drawn, not the ratio beforehand.
    //   "avgPDIF = sRatio*1.0 + [...] + (1 - sRatio - [...])*(((pDIFmax - pDIFmin) / 2) + pDIFmin)":
    //   a hit that is not critical is the spike with probability sRatio, else the draw.
    //   Level correction is left out: "generally doesn't apply to zones with content added after
    //   2013", and the enemy of the input has no level.
    // measured in game 2026-10-09: the limits (517 plain hits, four ratios) and "ratio + 1, same
    // limits, no spike" for critical hits (359) are the page's; the old reference's extra pDIF
    // on critical hits is excluded.
    CALC.pdifAverage = function (ratio, cap, critical) {
        var wRatio = critical ? ratio + 1 : ratio;
        var limits = CALC.pdifLimits(wRatio);
        var mean = meanBelowCap(limits.lower, limits.upper, critical ? cap + 1 : cap);
        var spike = critical ? 0 : CALC.pdifSpikeShare(wRatio);
        return (spike * Math.min(1, cap) + (1 - spike) * mean) * CALC.PDIF_FINAL_DRAW_MEAN;
    };
});
