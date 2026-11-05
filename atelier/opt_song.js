// Atelier optimizer: a Bard's song sets judged on their song (notes/docs-perso/chants-brd-2026-11-05/SPEC.md).
// One part of the engine (FFXI_PARTS, after atelier/opt_stat.js, whose O.statFigures calls O.songFigures on a set the
// page gave a song: b.songKind, the page's app/js/brd_song.js songBase): no DOM, no page state, so it also runs in the
// search's workers.
//
// The figures (BG Wiki, read 2026-11-05):
//   Song+ = All songs + the family's ("Minuet"+1...), up to the family's cap from equipment (Category:Minuet "The
//     maximum Minuet bonus available from equipment is +8"; b.songCap). What passes the cap gives nothing.
//   Potency = base + Song+ x step (BGWiki:SongPotency tables, the page's buffs.js SONGS; b.songPot), the skill taken at
//     its cap: the tables assume it, and BG Wiki gives no formula under it. The combined skill (Singing + the worn
//     instrument's: Category:Song "either Wind or String depending on the instrument type equipped") is shown beside
//     the song's skill cap (b.songSkillCap), the page saying when it falls short.
//   Duration = base x (1 + (gear's duration % + 10 % a Song+ + the 5 % gift) / 100), floored (Category:Song: "Song+
//     potency gear increases duration by 10% per 1 Song+", the duration bonuses "additive with each other",
//     "Decimal values are floored (decimal place dropped) after totaling"); x 2 under Troubadour ("Doubles the total
//     duration after all gear and Soul Voice/Marcato duration bonuses are applied"). Base 120 s for a party buff
//     (Category:Song), 30 s for Foe Lullaby (BGWiki:SongPotency). The job points of Clarion Call, Tenuto and Marcato
//     (seconds added after Troubadour) are not counted: the export gives the points spent, not where.
//   A debuff song's landing: CHR + the combined skill + Magic Accuracy, each counted once (Category:Song: "it is
//     generally accepted that it scales with the Bard's Charisma (CHR) and combined skill"; no formula: an assumption,
//     the player's choice of 2026-11-05).
//
// @file    atelier/opt_song.js
// @author  ejouanchicot
(globalThis.FFXI_PARTS = globalThis.FFXI_PARTS || []).push(function (FFXI) {
    var O = FFXI.opt;
    if (!O) return;
    // The combined skill of a set: Singing + the skill of the instrument it wears (none: Singing alone)
    function songSkill(t, b) {
        var inst = t.inststring ? (b.songString || 0) + t.string : t.instwind ? (b.songWind || 0) + t.wind : 0;
        return (b.songSing || 0) + t.sing + inst;
    }
    O.songFigures = function (f, t, b) {
        var raw = t.songall + (b.songFam ? t["song_" + b.songFam] || 0 : 0);
        var plus = b.songCap != null ? Math.min(raw, b.songCap) : raw;
        f.songPlus = plus; f.songPlusRaw = raw; f.songLost = raw - plus;
        f.songPot = b.songPot ? b.songPot[0] + plus * b.songPot[1] : 0;
        var pct = t.songdur + 10 * plus + (b.songGift || 0);
        f.songDurPct = pct;
        f.songTime = b.songDurBase ? Math.floor(b.songDurBase * (1 + pct / 100)) : 0;
        f.songTimeTroub = 2 * f.songTime;
        // a filler song (DummySong): the shorter the better, as a figure where more is better
        f.songTimeShort = -f.songTime;
        f.songSkill = songSkill(t, b);
        f.songAcc = (b.chr || 0) + t.songchr + f.songSkill + t.macc;
    };
});
