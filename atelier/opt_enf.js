// Atelier optimizer: enfeebling magic. What a set gives the spells cast in it: their length, their potency on the
// target and the magic accuracy they land with. One part of the engine (FFXI_PARTS, after atelier/opt.js): no DOM,
// no page state, so it also runs in the search's workers. The page (app/js/enfeeble.js) says which spells a set is
// cast for, the character and the target (ctx.stat.base); opt.js O.statFigures calls O.enfeeblingFigures.
//
// Length (BG Wiki Enfeebling_Magic, wiki.ffo.jp 弱体魔法; measured on Kaories RDM 2026-10-14, 11 cases within 0.5 s):
//   floor((base x Saboteur + 6 s a merit level + the job points' seconds) x Composure x (1 + % written on the pieces)
//   x (1 + % in augments)). Saboteur x2 on a monster, x1.25 on an NM, + its gear (Lethargy Gantherots +3: +14);
//   Composure: the Lethargy set's 2 / 3 / 4 / 5 pieces = +10 / 20 / 35 / 50 %. The Stymie job points (BG) are left
//   out: measured, Kaories' 2100 job points gave 20 s, not 40.
// Potency (BG Wiki Enfeebling_Magic): floor(floor(base x Saboteur + dSTAT part) x (1 + "Enfeebling magic effect" %)),
//   the effect only on the spells BG lists (eff below). Per spell, from its BG Wiki page:
//   Paralyze / II   rate 5-25 % / 14-34 % over dMND -40..+40 (BG gives the ends only: a straight line between them is
//                   ours); Paralyze II at most 50 % (Japanese measures, sazitouhuu.blogspot 2019-02: 87/160 with
//                   Saboteur). Measured ABOVE this formula, not in support of it (Kaories 2026-10-14, Locus Ghost
//                   Crab): Paralyze II 45 % without Saboteur (39/86), 49 % with it (46/94), Paralyze I 40 % (21/52),
//                   where the formula gives 34 % at most before the gear (atelier/calc/DIFFERENCES.md AR)
//   Slow            (dMND > 0 ? 150 + 2 dMND : 150 + dMND), dMND within +-75, out of 1024. Saboteur on the whole and
//                   not the base only: measured on Kaories (Locus Ghost Crab, its rounds x1.42 / x1.60 / x2.30 under
//                   Slow / Slow II / Slow II + Saboteur, a mob's delay x (1 + Slow): the formula below gives 1.43 /
//                   1.62 / 2.32, Saboteur on the base only 2.04)
//   Slow II         Slow + 100 / 1024: BG's +75 end (39.1 %) and the three measures; its -75 end 17.1 % for BG's 16.5
//   Addle / II      magic accuracy down floor(dMND / 5) + 20 / + 50, dMND 0..100, at most 40 / 70
//   Blind           (dINT + 80) / 4 over -39, (dINT + 120) / 8 under, 5 to 50; Blind II 19-94 over dINT -80..+120
//                   (ends only: a straight line); Saboteur on the whole for both (no base of their own)
//   Gravity / II    movement -26 % / -32 %, no stat (BG Gravity II's measures: 10 effect -34/35 %, Saboteur -62 %,
//                   24 effect and Saboteur -80 %)
//   Distract III / Frazzle III  floor(6/21 x (skill - 190 / - 205)) + floor(dMND / 5) (0 to 10), 130 at most before the
//                   effect gear; tiers I / II 25 / 40 at skill 125 / 350 (their slope is not given), at most 35 / 50
//   Poison / II     HP a tick: (skill - 225) / 5 up to skill 500; II 82 - floor(129/430 x (500 - skill)) to 500,
//                   82 + floor(180/783 x (skill - 500)) past it
//   Dia / II / III  HP a tick 1 / 2 / 3, + 1 for each point of effect (BG Dia III); its Defense down is fixed
// Magic accuracy (BG Wiki Magic_Accuracy): enfeebling skill + Magic Accuracy + Magic Accuracy skill + the dSTAT part
//   (1:1 within +-10, 2:1 to +-30, 4:1 to +-70, +-30 at most) + the spell's own. The stat: MND for white and red magic,
//   INT for black (ours: BG names it per spell, not all). Without the merits, gifts and Saboteur's job points, the same
//   for every set: the target's Magic Evasion is not known, so no hit rate.
//
// @file    atelier/opt_enf.js
// @author  ejouanchicot
(globalThis.FFXI_PARTS = globalThis.FFXI_PARTS || []).push(function (FFXI) {
    var O = FFXI.opt;
    if (!O) return;
    var clamp = function (v, lo, hi) { return Math.max(lo, Math.min(hi, v)); };
    var slowShape = function (d) { d = clamp(d, -75, 75); return d > 0 ? 150 + 2 * d : 150 + d; };
    var distract = function (top, cap) { return function (c) { return {raw: top * c.sab + clamp(Math.floor(c.dmnd / 5), 0, 10), cap: cap}; }; };
    var third = function (from) { return function (c) { return {raw: Math.floor(6 / 21 * (c.skill - from)) * c.sab + clamp(Math.floor(c.dmnd / 5), 0, 10), cap: 130}; }; };
    // dur: base seconds (rnd: random up to it); stat: the one its magic accuracy reads; acc: its own magic accuracy;
    // eff: "Enfeebling magic effect" raises it; pot(c) -> {raw, cap, after, whole, unit}: raw before the effect gear,
    // cap before it (capBefore) or after it, whole: Saboteur on the whole (raw given without it)
    var SPELLS = {
        "Paralyze": {dur: 120, stat: "mnd", acc: -10, eff: true, unit: "%", pot: function (c) { return {raw: 15 * c.sab + clamp(c.dmnd, -40, 40) / 4}; }},
        "Paralyze II": {dur: 120, stat: "mnd", acc: 10, eff: true, unit: "%", pot: function (c) { return {raw: 24 * c.sab + clamp(c.dmnd, -40, 40) / 4, after: 50}; }},
        "Slow": {dur: 180, stat: "mnd", eff: true, unit: "slow", pot: function (c) { return {raw: slowShape(c.dmnd) * c.sab}; }},
        "Slow II": {dur: 180, stat: "mnd", eff: true, unit: "slow", pot: function (c) { return {raw: (slowShape(c.dmnd) + 100) * c.sab}; }},
        "Addle": {dur: 180, stat: "mnd", acc: 20, eff: true, unit: "macc", pot: function (c) { return {raw: 20 * c.sab + Math.floor(clamp(c.dmnd, 0, 100) / 5), after: 40}; }},
        "Addle II": {dur: 180, stat: "mnd", eff: true, unit: "macc", pot: function (c) { return {raw: 50 * c.sab + Math.floor(clamp(c.dmnd, 0, 100) / 5), after: 70}; }},
        "Blind": {dur: 180, stat: "int", eff: true, unit: "acc", pot: function (c) { var d = c.dint; return {raw: clamp(d > -39 ? (d + 80) / 4 : (d + 120) / 8, 5, 50) * c.sab}; }},
        "Blind II": {dur: 180, stat: "int", acc: 10, eff: true, unit: "acc", pot: function (c) { return {raw: (19 + 0.375 * (clamp(c.dint, -80, 120) + 80)) * c.sab}; }},
        "Gravity": {dur: 120, rnd: true, stat: "int", eff: true, unit: "%", pot: function (c) { return {raw: 26 * c.sab}; }},
        "Gravity II": {dur: 120, rnd: true, stat: "int", eff: true, unit: "%", pot: function (c) { return {raw: 32 * c.sab}; }},
        "Distract": {dur: 300, stat: "mnd", acc: 150, eff: true, unit: "eva", pot: distract(25, 35), capBefore: true},
        "Distract II": {dur: 300, stat: "mnd", eff: true, unit: "eva", pot: distract(40, 50), capBefore: true},
        "Distract III": {dur: 300, stat: "mnd", eff: true, unit: "eva", pot: third(190), capBefore: true},
        "Frazzle": {dur: 300, stat: "mnd", eff: true, unit: "meva", pot: distract(25, 35), capBefore: true},
        "Frazzle II": {dur: 300, stat: "mnd", eff: true, unit: "meva", pot: distract(40, 50), capBefore: true},
        "Frazzle III": {dur: 300, stat: "mnd", eff: true, unit: "meva", pot: third(205), capBefore: true},
        "Poison": {dur: 90, stat: "int", eff: true, unit: "tick", pot: function (c) { return {raw: Math.max(1, Math.floor((Math.min(500, c.skill) - 225) / 5)) * c.sab}; }},
        "Poisonga": {dur: 90, stat: "int", eff: true, unit: "tick", pot: function (c) { return {raw: Math.max(1, Math.floor((Math.min(500, c.skill) - 225) / 5)) * c.sab}; }},
        "Poison II": {dur: 120, stat: "int", acc: 30, eff: true, unit: "tick", pot: function (c) {
            var s = c.skill, v = s <= 500 ? 82 - Math.floor(129 / 430 * (500 - s)) : 82 + Math.floor(180 / 783 * (s - 500));
            return {raw: Math.max(4, v) * c.sab}; }},
        // Dia: + 1 HP a tick for each point of effect, not a %; its length its own (BG: Saboteur after the seconds)
        "Dia": {dur: 60, dia: 1, stat: "mnd", unit: "tick"}, "Dia II": {dur: 120, dia: 2, stat: "mnd", unit: "tick"},
        "Dia III": {dur: 180, dia: 3, stat: "mnd", unit: "tick"}, "Diaga": {dur: 60, dia: 1, stat: "mnd", unit: "tick"},
        "Sleep": {dur: 60, stat: "int"}, "Sleep II": {dur: 90, stat: "int"}, "Sleepga": {dur: 60, stat: "int"}, "Sleepga II": {dur: 90, stat: "int"},
        "Bind": {dur: 60, rnd: true, stat: "int"}, "Break": {dur: 30, stat: "int"}, "Breakga": {dur: 30, stat: "int"},
        "Silence": {dur: 120, stat: "mnd"}, "Dispel": {stat: "int", acc: 175}, "Dispelga": {stat: "int"}, "Inundation": {dur: 300, stat: "mnd"}
    };
    O.ENF_SPELLS = SPELLS;
    // dSTAT -> magic accuracy (BG Wiki Magic_Accuracy)
    function dstatAcc(d) {
        var a = Math.abs(d), v = a <= 10 ? a : a <= 30 ? 10 + (a - 10) / 2 : a <= 70 ? 20 + (a - 30) / 4 : 30;
        return Math.floor(d < 0 ? -v : v);
    }
    // One spell's figures with these pieces: {time, pot, capped, acc}
    O.enfeeblingSpell = function (name, t, b) {
        var sp = SPELLS[name];
        if (!sp) return null;
        var g = function (k) { return t[k] || 0; };
        var skill = (b.enfSkill || 0) + g("enfskill");
        var c = {skill: skill, dmnd: (b.mnd || 0) + g("mnd") - (b.tMnd || 0), dint: (b.int || 0) + g("int") - (b.tInt || 0),
            sab: b.sab ? (b.nm ? 1.25 : 2) + g("sabplus") / 100 : 1};
        var comp = b.comp ? 1 + [0, 0, 10, 20, 35, 50][Math.min(5, g("leth"))] / 100 : 1;
        var gear = (1 + g("enfdurL") / 100) * (1 + g("enfdurA") / 100), out = {};
        if (sp.dur) out.time = sp.dia ? Math.floor((sp.dur + (b.enfSec || 0)) * c.sab * comp * gear + 1e-9)
            : Math.floor((sp.dur * c.sab + (b.enfSec || 0)) * comp * gear + 1e-9);
        var eff = g("enfeff");
        if (sp.dia) out.pot = sp.dia + eff;
        else if (sp.pot) {
            var p = sp.pot(c), raw = Math.floor(p.raw + 1e-9);
            if (sp.capBefore && p.cap) raw = Math.min(raw, p.cap);
            var v = Math.floor(raw * (1 + (sp.eff ? eff : 0) / 100) + 1e-9);
            if (sp.unit === "slow") v = Math.round(v / 1024 * 1000) / 10;
            out.capped = p.after != null && v >= p.after;
            out.pot = p.after != null ? Math.min(v, p.after) : v;
        }
        out.unit = sp.unit || "";
        var d = sp.stat === "int" ? c.dint : c.dmnd;
        out.acc = skill + g("macc") + g("maccskill") + dstatAcc(d) + (sp.acc || 0);
        out.skill = skill; out.dstat = d;
        return out;
    };
    // The elemental debuffs (Burn, Frost, Choke, Rasp, Shock, Drown; the page's app/js/ele_debuff.js), BG Wiki
    // Category:Elemental_Debuff read 2026-10-22: by the caster's INT, [over, stat lowered, HP a tick] (">150": 150
    // itself falls in the step under it, the page leaving it out); + 2 / + 1 per effect merit (5 at most); the gear's
    // "Elemental magic status ailment effects" + n / + n/2; an Archmage's / Sorcerer's Tonban + 2 / + 1 per effect merit
    // and + 6 s per duration merit; 90 s + 12 s per duration merit. Checked on the page's own example: -23 / 10 / 150 s,
    // with Sabots +3 -53 / 25, with the Tonban too -63 / 30 / 180 s. Magic attack does not count
    var ED_STEPS = [[150, 13, 5], [99, 11, 4], [69, 9, 3], [39, 7, 2], [-Infinity, 5, 1]];
    O.eleDebuffFigures = function (f, t, b) {
        if (!b.edOn) return;
        var g = function (k) { return t[k] || 0; };
        var int = (b.int || 0) + g("int"), step = ED_STEPS.filter(function (x) { return int > x[0]; })[0];
        var em = b.edEffM || 0, dm = b.edDurM || 0, tonban = g("edtonban") > 0, eff = g("edeff");
        f.edDown = step[1] + 2 * em + (tonban ? 2 * em : 0) + eff;
        f.edDot = step[2] + em + (tonban ? em : 0) + Math.floor(eff / 2);
        f.edTime = 90 + 12 * dm + (tonban ? 6 * dm : 0);
        f.edAcc = (b.edSkill || 0) + g("edskill") + g("macc") + g("maccskill") + dstatAcc(int - (b.tInt || 0));
        f.edInt = int; f.edEff = eff; f.edTonban = tonban ? 1 : 0;
    };
    // The set's figures (b.enfSpells, its spells in order): the magic accuracy of the first, the length of the first
    // that has one, the potency of the first that has one (0 when none does)
    O.enfeeblingFigures = function (f, t, b) {
        if (!b.enfSpells || !b.enfSpells.length) return;
        var by = {}, all = b.enfSpells.map(function (n) { var r = O.enfeeblingSpell(n, t, b); if (r) by[n] = r; return r; }).filter(Boolean);
        if (!all.length) return;
        f.enfBy = by;
        var first = function (k) { for (var i = 0; i < all.length; i++) if (all[i][k] != null) return all[i][k]; return 0; };
        f.enfAcc = all[0].acc; f.enfSkill = all[0].skill; f.enfTime = first("time"); f.enfPot = first("pot");
        f.enfEff = t.enfeff || 0;
    };
});
