// Atelier calculation engine, stage 1: combat and magic skills of the job before gear and gifts.
//
//   CALC.SKILLS                   every skill name, as the stat "<name> Skill"
//   CALC.baseSkills(job, ml)      {"Sword Skill": n, ...} for the main job
//
// A skill the job has a rank in: cap of the rank at level 99, plus 1 per master level
// ("for all weapons that a job has ranking in"), plus the merit points (+2 a level, 8 levels,
// every skill bought). A skill without rank only keeps the merit points.
//   https://www.bg-wiki.com/ffxi/Combat_Skills
//   https://www.bg-wiki.com/ffxi/Master_Levels
//   https://www.bg-wiki.com/ffxi/Merit_Points
// The support job gives no skill (https://www.bg-wiki.com/ffxi/Support_Job lists stats, spells,
// traits and abilities only).
//
// @file    atelier/calc/calc_skills.js
// @author  ejouanchicot
(globalThis.CALC_PARTS = globalThis.CALC_PARTS || []).push(function (CALC) {
    CALC.WEAPON_SKILLS = ["Hand-to-Hand", "Dagger", "Sword", "Great Sword", "Axe", "Great Axe", "Scythe", "Polearm",
        "Katana", "Great Katana", "Club", "Staff"];
    CALC.RANGED_SKILLS = ["Archery", "Marksmanship", "Throwing"];
    CALC.TWO_HANDED = ["Great Sword", "Great Axe", "Scythe", "Polearm", "Great Katana", "Staff"];
    CALC.SKILLS = CALC.WEAPON_SKILLS.concat(CALC.RANGED_SKILLS, ["Evasion", "Parrying", "Shield", "Guard",
        "Divine Magic", "Healing Magic", "Enhancing Magic", "Enfeebling Magic", "Elemental Magic", "Dark Magic",
        "Summoning Magic", "Ninjutsu", "Singing", "String Instrument", "Wind Instrument", "Blue Magic",
        "Geomancy", "Handbell"]);

    CALC.baseSkills = function (job, ml) {
        var ranks = (CALC.JOBS[job] || {}).skills || {};
        var out = {};
        CALC.SKILLS.forEach(function (name) {
            var rank = ranks[name];
            var value = CALC.COMMON_MERITS.skill;
            if (rank) value += CALC.SKILL_CAP_99[rank] + (ml || 0) * CALC.MASTER_LEVEL.skillPerLevel;
            out[name + " Skill"] = value;
        });
        return out;
    };
});
