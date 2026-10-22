// Atelier calculation engine: the target as the engine reads it.
//
//   CALC.makeEnemy(list, name, down)   {stats} of the target `name` of `list`, less what the party takes off it
//
// list: the page's targets ({Name, Defense, Evasion, VIT, AGI, MND, INT, CHR, "Magic Evasion", "Magic Defense",
// "Magic DT%"}, atelier/app/js/buffs.js targetsPart, which puts them on FFXI.ENEMIES). down: CALC.aggregateBuffs's
// second half plus the page's own debuffs ({Defense: share, Evasion: points...}).
//   https://www.bg-wiki.com/ffxi/Defense_Down : "Dia, Box Step, Defense Down, and Geo-Frailty all stack together
//     additively to a minimum of 1 defense." "Defense = Base_Defense * (1 - (Dia + Box Step + Defense Down +
//     Frailty)) >= 1"
//   https://www.bg-wiki.com/ffxi/Magic_Damage : "Note that the target's MDB is always floored at 0.5." (a Magic
//     Defense of -50 at most taken off)
// The other stats lose what the effects take off, point for point. "Magic DT%" is read as "Magic Damage Taken".
//
// @file    atelier/calc/calc_enemy.js
// @author  ejouanchicot
(globalThis.CALC_PARTS = globalThis.CALC_PARTS || []).push(function (CALC) {
    var LEFT_OUT = ["Name", "Level", "Location", "Resist Rank", "Magic DT%"];
    CALC.MDB_FLOOR = -50;

    CALC.makeEnemy = function (list, name, down) {
        var base = (list || []).filter(function (e) { return e.Name === name; })[0];
        if (!base) throw new Error("unknown target " + name);
        var s = {};
        Object.keys(base).forEach(function (k) { if (LEFT_OUT.indexOf(k) === -1) s[k] = base[k]; });
        s["Magic Damage Taken"] = base["Magic DT%"] || 0;
        Object.keys(down || {}).forEach(function (stat) {
            if (stat === "Defense") return;
            var key = stat === "Magic DT%" ? "Magic Damage Taken" : stat;
            s[key] = (s[key] || 0) - down[stat];
        });
        s["Base Defense"] = base.Defense;
        s.Defense = Math.max(1, (base.Defense || 0) * (1 - ((down || {}).Defense || 0)));
        s["Magic Defense"] = Math.max(CALC.MDB_FLOOR, s["Magic Defense"] || 0);
        return {stats: s};
    };
});
