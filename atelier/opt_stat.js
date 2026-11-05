// Atelier optimizer: the sets judged by their stats (idle, enmity, Phalanx, Fast Cast, Cure, enhancing magic, a pet...).
// One part of the engine (FFXI_PARTS, after atelier/opt.js, whose value of a set calls O.statValue in a stats search;
// before atelier/opt_enf.js, which adds its figures to O.statFigures): no DOM, no page state, so it also runs in the
// search's workers.
//   O.statFigures(stat, pieces)  every figure of a set from the stats the page laid on its pieces
//   O.cure, O.cureIV, O.phalanxPotency, O.enhancingFigures   the spells' formulas
//   O.STAT_OBJS                  the objectives; O.statValue a set's value for them (opt.js valueOf)
// It reads O.tieBreak of atelier/opt.js
//
// @file    atelier/opt_stat.js
// @author  ejouanchicot
(globalThis.FFXI_PARTS = globalThis.FFXI_PARTS || []).push(function (FFXI) {
    var O = FFXI.opt;
    if (!O) return;
    // ------------------------------------------------------------ sets judged by their stats (idle, enmity, Phalanx, Fast Cast...)
    // No damage engine here: the page lays on each piece the stats it reads from it (piece.st: hp, hp%, def, vit, dt, pdt,
    // mdt, pdt2, mdt2, enmity, phalanx, enh (enhancing skill), sird, fc, meva, mdb, ecrit, cure, refresh, regen) and gives
    // the character without gear (ctx.stat.base). The figures (Guide_Paladin solver_common.py, BG Wiki):
    //   HP = (base + gear HP) x (1 + HP %); DEF = base + gear DEF + VIT x 1.5, + the shield's DEF when a PLD's Protect
    //   takes it (Shield Barrier); Phalanx = the spell's potency from the enhancing skill + Phalanx received; Enmity up to
    //   its cap (+200, buffs counted); Fast Cast up to 80; damage taken with the -50 % cap, then the II stats (-87.5 %)
    var STAT_KEYS = ["hp", "hp%", "def", "vit", "mnd", "dt", "pdt", "mdt", "pdt2", "mdt2", "bdt", "enmity", "phalanx", "enh", "heal", "sird",
        "fc", "meva", "mdb", "ecrit", "cure", "cure2", "curerecv", "refresh", "regen", "enhdur", "cmp", "ss", "div", "enl", "shield", "block", "statusRes", "eleRes", "lossRed", "move", "ja", "hw", "crecv", "absorb",
        "res_fire", "res_ice", "res_wind", "res_earth", "res_lightning", "res_water", "res_light", "res_dark",
        "petdt", "petregen", "charm", "geoskill",
        // a BST's pet (the page's bst_pet.js): Accuracy, Attack, Haste, Store TP, Double Attack, levels (a weapon's apart)
        "petacc", "petatk", "pethaste", "petstp", "petda", "petlv", "petlvw", "petpdt", "petmdt", "petstout",
        "petmab", "petmacc", "petint", "petmelee", "pettpb",
        // a BST's Charm set (the page's bst_pet.js): CHR and "Charm"+N
        "chr", "charmplus",
        // enhancing magic (the page's stat_opt.js statVec): duration written on the piece / in its augments, a Lethargy
        // set piece, Refresh potency and seconds received, Regen potency (% then flat) and seconds, Gain, Aquaveil
        "enhdurL", "enhdurA", "leth", "refpot", "refsec", "regenpct", "regenflat", "regensec", "gain", "aquaveil", "barplus",
        // Perpetuance's figure of the Bracers (the page's enh_jobs.js enhPerpOf); the elemental debuffs' effect,
        // elemental magic skill and Tonban (the page's ele_debuff.js edVec)
        "perp", "edeff", "edskill", "edtonban",
        // dark magic (the page's dark_magic.js darkVec): skill, Drain / Aspir potency, the Absorbs' potency and duration, the
        // dark magic duration, Absorb-TP, Dread Spikes, Endark, the dark magic attack
        "darkskill", "drainpot", "absorbpot", "absorbdur", "darkdur", "abstp", "dreadpot", "endark", "darkmab",
        // a healer's spell pieces read by name (the page's stat_opt.js HEALER_PLUS), Magic Attack Bonus, magic accuracy
        "cursna", "auspice", "sneaksec", "invissec", "barstat", "esuna", "erase", "naveil", "mab", "macc",
        // the casting time cuts of one kind of spell (the page's stat_opt.js castVec): cc_<kind>
        "cc_cure", "cc_healing", "cc_enhancing", "cc_stoneskin", "cc_enfeebling", "cc_elemental", "cc_dark", "cc_black", "cc_blue",
        "cc_song", "cc_utsusemi", "cc_summoning", "cc_arts", "cc_grimoire",
        // a Bard's songs (the page's brd_song.js songVec, the figures atelier/opt_song.js): All songs, each family's
        // Song+, duration %, recast, extra songs, Singing / Wind / String skill, CHR, the instrument's kind
        "songall", "song_minuet", "song_march", "song_madrigal", "song_ballad", "song_paeon", "song_minne", "song_mambo",
        "song_etude", "song_carol", "song_prelude", "song_scherzo", "song_threnody", "song_lullaby", "songdur", "songrecast",
        "songextra", "sing", "wind", "string", "songchr", "instwind", "inststring"];
    // A single target Cure (BG Wiki Cure_Formula, last edited 2026-02-09): Power = MND/2 + VIT/4 + Healing Magic skill;
    // the base by power steps [power floor, rate, HP floor], highest first, up to the spell's hard cap; + jp (the Cure
    // potency of job points and gifts: a PLD's gift Cure Potency Bonus +50 from 1200 JP, BG Wiki Paladin, checked in game
    // 2026-10-05, Cure IV 1332, 1245 and 1114; a mastered WHM's 23, 63 under Afflatus Solace); then x (1 + Cure Potency
    // (50 % cap) + Cure Potency II (30 %)), then x (1 + Cure Potency Received (30 %)). Day and weather left out
    var CURES = {
        1: {cap: 65, steps: [[200, 20, 45], [125, 15, 40], [40, 8.5, 30], [20, 1.33, 15], [0, 4, 10]]},
        2: {cap: 145, steps: [[400, 20, 130], [200, 10, 110], [125, 7.5, 100], [70, 5.5, 90], [40, 1, 60]]},
        3: {cap: 340, steps: [[300, 5, 260], [200, 2.5, 220], [125, 1.15, 155], [70, 2.2, 130]]},
        4: {cap: 640, steps: [[400, 2.5, 520], [300, 1.43, 450], [200, 2, 400], [70, 1, 270]]},
        5: {cap: 780, steps: [[500, 3.33, 720], [300, 2.5, 640], [260, 2, 620], [190, 1.84, 582], [150, 1.25, 550], [80, 0.7, 450]]},
        6: {cap: 1010, steps: [[500, 1.67, 890], [400, 2.5, 850], [300, 1.43, 780], [210, 0.9, 680], [90, 1.5, 600]]}};
    O.cure = function (tier, mnd, vit, skill, cp, cp2, recv, jp) {
        var c = CURES[tier] || CURES[4], power = Math.floor(mnd / 2) + Math.floor(vit / 4) + skill, base = c.steps[c.steps.length - 1][2];
        for (var i = 0; i < c.steps.length; i++) if (power >= c.steps[i][0]) { base = Math.floor((power - c.steps[i][0]) / c.steps[i][1]) + c.steps[i][2]; break; }
        base = Math.min(c.cap, base) + (jp || 0);
        var pot = 1 + Math.min(50, cp) / 100 + Math.min(30, cp2) / 100;
        return Math.floor(Math.floor(base * pot) * (1 + Math.min(30, recv) / 100));
    };
    O.cureIV = function (mnd, vit, skill, cp, cp2, recv, jp) { return O.cure(4, mnd, vit, skill, cp, cp2, recv, jp); };
    O.phalanxPotency = function (skill) {
        return skill <= 300 ? Math.max(0, Math.floor(skill / 10) - 2) : Math.min(35, 28 + Math.floor((skill - 300.5) / 28.5));
    };
    // Enhancing magic of a set named for it (b.enhKind, the page's stat_opt.js enhContext). Measured in game on
    // 2026-10-14, 130 casts (Kaories RDM, //gs c enhtest, shared/utils/debug/enh_test.lua), each within 2 s of BG Wiki
    // (Enhancing_Magic_Duration):
    //   length = (base + seconds) x Composure x (1 + % written on the pieces) x (1 + % in augments)
    //   seconds: the job points' (in b.enhBase), "Regen effect duration", "Duration of Refresh received" (on oneself);
    //   Composure: x3 on oneself, 30 minutes at most; on the others the Lethargy set's 2 / 3 / 4 / 5 pieces = +10 / +20 /
    //   +35 / +50 %, nothing without Composure.
    // What a spell gives:
    //   Refresh  MP a tick = the spell's (3 / 6 / 9) + "Refresh potency"                          measured
    //   Regen    HP a tick = ceil(the spell's (5 / 12) x (1 + "Regen potency" %)) + the augments' flat  measured
    //   Gain     floor((skill - 300) / 10) + 5, 25 at most (500 of skill), + "Gain magic effect"   measured
    //   Temper   floor((skill - 300) / 10) %, 5 under 360 of skill; Temper II 40 at most           BG Wiki Temper, Temper_II
    //   Enspell  floor((skill - 180) / 8) + 25; floor(skill / 9) + 5 under 180                     BG Wiki Category:Enspell
    //            + the job point gifts (b.enGifts), x3 while Composure is up (at the hit, not the cast)  measured
    //            (tier I on oneself, 2026-10-14: 87 / 90 / 105 at 496 / 520 / 636 of skill; with Composure 315 = 105 x 3,
    //            its halves 135 / 138 / 157 and 1/4 to 1/32 resisted procs; Umuthi Hat's "+8" added nothing, so the
    //            damage gear of BG's list is not counted)
    //   Bar-element  25 + floor(skill / 4), 150 at most; 40 + floor(skill / 5) to 300 of skill     BG Wiki Category:Barspell
    //            + the pieces' bonus over the cap (t.barplus)    measured 2026-10-14: 149 / 150 / 165 with Shedir
    //   Aquaveil 1 interruption, 2 from 301 of skill, 3 from 501, + the "Aquaveil" pieces          BG Wiki Aquaveil
    // The other jobs (the page's enh_jobs.js, BG Wiki read 2026-10-22, not measured in game): no Composure (b.comp
    // "none"); the length x b.durMul (a RUN's gifts, Embolden's -50 %) and x Perpetuance (2, or the Bracers' 2.25 to
    // 2.65: t.perp); the spell's own potency x b.potMul (Embolden +50 %) before the pieces' flat bonus; Bar-element + b.barAdd
    // (a WHM's merits)
    O.enhancingFigures = function (f, t, b, skill) {
        if (!b.enhKind) return;
        var kind = b.enhKind;
        var comp = b.comp === "self" ? 3 : b.comp === "others" ? 1 + [0, 0, 10, 20, 35, 50][Math.min(5, t.leth || 0)] / 100 : 1;
        // Sneak / Invisible: the Dream +1 pieces and Skulker's Cape add their seconds to the spell's 600 s top (BG Wiki Sneak,
        // Invisible); whether the enhancing duration then multiplies them is not on the pages (assumed, as every spell)
        var seconds = (b.enhBase || 0) + (kind === "refresh" && b.comp !== "others" ? t.refsec : kind === "regen" ? t.regensec
            : kind === "sneak" ? t.sneaksec : kind === "invis" ? t.invissec : 0);
        var mult = comp * (1 + t.enhdurL / 100) * (1 + t.enhdurA / 100) * (b.durMul || 1) * (b.perp ? Math.max(2, t.perp || 0) : 1);
        var pm = b.potMul || 1;
        var time = Math.floor(seconds * mult + 1e-9);
        f.enhMult = Math.round(mult * 1000) / 1000;
        f.enhTime = b.comp === "self" ? Math.min(1800, time) : time;
        var ticks = Math.floor(f.enhTime / 3);
        if (kind === "refresh") { f.refreshTick = Math.floor((b.refBase || 0) * pm) + t.refpot; f.refreshMp = f.refreshTick * ticks; }
        if (kind === "regen") {
            f.regenTick = Math.ceil((b.regenBase || 0) * pm * (100 + t.regenpct) / 100 - 1e-9) + t.regenflat;
            f.regenHp = f.regenTick * ticks;
        }
        if (kind === "gain") f.gainPot = (skill < 300 ? 5 : Math.min(25, Math.floor((skill - 300) / 10) + 5)) + t.gain;
        if (kind === "temper") f.temper = skill < 360 ? 5 : Math.min(b.temperCap || 1e9, Math.floor((skill - 300) / 10));
        if (kind === "enspell") {
            var en = (skill < 180 ? Math.floor(skill / 9) + 5 : Math.floor((skill - 180) / 8) + 25) + (b.enGifts || 0);
            f.enspell = b.comp === "self" ? en * 3 : en;
        }
        if (kind === "barele") f.barEle = Math.floor(Math.min(150, skill <= 300 ? 40 + Math.floor(skill / 5) : 25 + Math.floor(skill / 4)) * pm) + t.barplus + (b.barAdd || 0);
        if (kind === "aquaveil") f.aquaveil = (skill > 500 ? 3 : skill > 300 ? 2 : 1) + t.aquaveil;
        // Bar-status: fixed, +30 on oneself, +20 for the -ra (b.barailBase), the skill changes nothing; + Sroda Necklace
        // (BG Wiki Category:Barspell)
        if (kind === "barail") f.barStatus = (b.barailBase || 30) + t.barstat;
    };
    // Set bonuses the stats sets count, by the pieces worn (their game names): [pieces, stat key, bonus by count]
    //   Kaykaus Attire +1: "Cure" potency II +4 / 6 / 8 / 10 % for 2 / 3 / 4 / 5 pieces, the +1 only (BG Wiki
    //   Kaykaus_Attire_Set); taken as Cure potency II like any, under its 30 % cap (the page does not say)
    var STAT_SETS = [
        {name: "Kaykaus", pieces: ["Kaykaus Mitra +1", "Kaykaus Bliaut +1", "Kaykaus Cuffs +1", "Kaykaus Tights +1", "Kaykaus Boots +1"],
            key: "cure2", byCount: {2: 4, 3: 6, 4: 8, 5: 10}},
        //   Chevalier's (PLD Empyrean +2, Reforged NQ to +3): "Occasionally absorbs damage taken", +2 / 3 / 4 / 5 % for
        //   2 / 3 / 4 / 5 pieces (BG Wiki Chevalier's_Armor_Set: "Each separate piece provides an additional +1% chance
        //   of activation (minimum +2% from wearing two pieces), up to a maximum of +5%"); the absorbed hit heals its
        //   damage before damage taken cuts, a whole hit when the shield did not block it (block, then absorb, then DT)
        {name: "Chevalier's", pieces: ["Chev. Armet", "Chevalier's Armet", "Chev. Armet +1", "Chev. Armet +2", "Chev. Armet +3", "Creed Armet +2", "Chev. Cuirass", "Chevalier's Cuirass", "Chev. Cuirass +1", "Chev. Cuirass +2", "Chev. Cuirass +3", "Creed Cuirass +2", "Chev. Gauntlets", "Chevalier's Gauntlets", "Chev. Gauntlets +1", "Chev. Gauntlets +2", "Chev. Gauntlets +3", "Creed Gauntlets +2", "Chev. Cuisses", "Chevalier's Cuisses", "Chev. Cuisses +1", "Chev. Cuisses +2", "Chev. Cuisses +3", "Creed Cuisses +2", "Chev. Sabatons", "Chevalier's Sabatons", "Chev. Sabatons +1", "Chev. Sabatons +2", "Chev. Sabatons +3", "Creed Sabatons +2"],
            key: "absorb", byCount: {2: 2, 3: 3, 4: 4, 5: 5}}
    ];
    // {name: {count, bonus}} of the sets worn, their bonus added to the totals t
    function statSetBonuses(t, pieces) {
        var out = {};
        STAT_SETS.forEach(function (S) {
            var n = 0;
            for (var sl in pieces) if (pieces[sl] && S.pieces.indexOf(pieces[sl].name) !== -1) n++;
            var bonus = S.byCount[Math.min(n, 5)] || 0;
            if (bonus) { t[S.key] = (t[S.key] || 0) + bonus; out[S.name] = {count: n, bonus: bonus}; }
        });
        return out;
    }
    function castCut(t, b) { return (b.castKinds || []).reduce(function (n, k) { return n + (t["cc_" + k] || 0); }, 0); }
    function gearMove(pieces) {
        var m = 0;
        for (var sl in pieces) { var st = pieces[sl] && pieces[sl].st; if (st && st.move > m) m = st.move; }
        return m;
    }
    // The pieces worn: none in a slot another piece blocks (O.blocks: an Onca Suit's hands, legs and feet). Counted
    // in the stats too, they gave the suit's +252 Magic Evasion on top of the three pieces it takes off (2026-10-31)
    function wornPieces(pieces) {
        var blocked = null;
        for (var s in pieces) {
            var p = pieces[s];
            if (!p) continue;
            if (!p._blk) p._blk = O.blocks(p);
            for (var i = 0; i < p._blk.length; i++) (blocked = blocked || {})[p._blk[i]] = true;
        }
        if (!blocked) return pieces;
        var out = {};
        for (var k in pieces) if (!blocked[k]) out[k] = pieces[k];
        return out;
    }
    O.statFigures = function (stat, pieces) {
        pieces = wornPieces(pieces);
        var t = {}, b = stat.base || {};
        STAT_KEYS.forEach(function (k) { t[k] = 0; });
        for (var sl in pieces) { var st = pieces[sl] && pieces[sl].st; if (st) for (var k in st) t[k] = (t[k] || 0) + st[k]; }
        var setBonuses = statSetBonuses(t, pieces);
        var shield = b.shieldBarrier && pieces.sub && pieces.sub.st && pieces.sub.shield ? Math.floor((pieces.sub.st.def || 0) * (b.shieldMul || 1)) : 0;
        var cap = function (v) { return Math.max(v, -50); }, two = function (v) { return Math.max(v, -87.5); };
        var shell = b.shell ? -b.shell / 256 * 100 : 0;
        var f = {
            hp: Math.round(((b.hp || 0) + t.hp) * (1 + t["hp%"] / 100)),
            def: Math.floor((b.def || 0) + t.def + 1.5 * t.vit + shield), shield: shield,
            // the gear's and the spells' (Crusade) up to +200, a job ability's on top (Sentinel: b.enmityJa, the page's
            // buffs.js; BG Wiki Enmity: "not subject to these caps"; added to them here, how they combine not on the page)
            enmity: Math.min(200, t.enmity + (b.enmity || 0)) + (b.enmityJa || 0),
            // ("Phalanx received" is the receiver's: nothing on a set cast on the others)
            phalanx: Math.floor(O.phalanxPotency((b.enh || 0) + t.enh) * (b.potMul || 1)) + (b.comp === "others" ? 0 : t.phalanx), enh: (b.enh || 0) + t.enh, phalanxGear: t.phalanx,
            // Fast Cast with the casting time cuts of the set's spells (b.castKinds: a Cure's "Cure" spellcasting time and
            // Healing magic's), under one cap: BG Wiki Fast_Cast "Casting Time reduction cap is 80%" (how they add: not
            // on the page; added, as the player's WHM guide says of Cure: 80 % combined)
            fc: Math.min(80, t.fc + (b.fc || 0) + castCut(t, b)), fcGear: t.fc, fcSpell: castCut(t, b), sird: Math.min(102, t.sird + (b.sird || 0)), meva: (b.meva || 0) + t.meva, mdb: t.mdb + (b.mdb || 0),
            ecrit: t.ecrit, cure: Math.min(50, t.cure), refresh: t.refresh, regen: t.regen, enhdur: t.enhdur,
            // Conserve MP (BG Wiki Conserve_MP): the gear's + the job's trait (b.cmp), a proc rate "capped" at 100 %
            cmp: Math.min(100, t.cmp + (b.cmp || 0)), cmpGear: t.cmp,
            pdtAll: two(cap(t.dt + t.pdt) + t.pdt2), mdtAll: two(cap(t.dt + t.mdt + shell) + t.mdt2), bdtAll: cap(t.dt + t.bdt),
            pdt: t.dt + t.pdt, mdt: t.dt + t.mdt,
            // Movement speed: the highest piece only (BG Wiki Movement_Speed: "Only the highest value from equipment counts")
            move: gearMove(pieces),
            // a job ability's set: the pieces worn that boost that ability (the page's stat_opt.js boostsAbility)
            jaPlus: t.ja
        };
        // Stoneskin (BG Wiki): x = enhancing skill / 3 + MND; under 80 x, to 130 2 x skill / 3 + 2 x MND - 60, past it skill +
        // 3 x MND - 190; 350 at most, the "Stoneskin" gear over the cap, 475 at most. Enlight II (BG Wiki): 2 x floor((divine
        // skill + 85) / 13) + floor((skill + 85) / 26) up to 500 skill, 2 x floor((skill + 400) / 20) + floor((skill + 400) / 40) past it
        // a GEO's luopan (the page's luopan.js): the gear's cut of its damage taken, counted up to the 37.5 % that fit
        // under its -87.5 % cap; its Regen; and, taken at the cast: the HP a tick a Bagua Charm saves it, Geomancy+ (the
        // highest piece, never their sum) and the Geomancy + Handbell skills
        var geo = 0;
        for (var gs in pieces) { var gv = pieces[gs] && pieces[gs].st && pieces[gs].st.geo; if (gv > geo) geo = gv; }
        f.luDt = Math.min(37.5, -t.petdt); f.luRegen = t.petregen; f.luCharm = t.charm; f.geomancy = geo;
        f.geoSkill = (b.geoSkill || 0) + t.geoskill;
        // a BST's pet in a fight (the page's bst_pet.js, players' readings): its Accuracy without gear + the pieces + a
        // level's worth for each level over 119 (only the best weapon's), counted up to what hits the target; Attack the
        // same; Haste capped at 25 % from gear; damage taken at -87.5 %
        var petW = 0;
        ["main", "sub"].forEach(function (ws) { var w = pieces[ws] && pieces[ws].st && pieces[ws].st.petlvw; if (w > petW) petW = w; });
        var petLv = t.petlv + petW, petAcc = (b.petAccBase || 0) + t.petacc + petLv * (b.lvAcc || 0);
        f.petLv = petLv; f.petAccAll = petAcc; f.petAcc = b.petNeed ? Math.min(petAcc, b.petNeed) : petAcc;
        f.petAtk = t.petatk + petLv * (b.lvAtk || 0); f.petHaste = Math.min(25, t.pethaste); f.petStp = t.petstp; f.petDa = t.petda;
        // its damage taken, physical and magic, as positive %: the Stout Servant trait (b.petTrait), the gear's "Stout
        // Servant"+N, its Pet: DT and PDT / MDT (BG Wiki Stout_Servant, Damage_Taken: -87.5 % for pets)
        f.petDt = Math.min(87.5, (b.petTrait || 0) + t.petstout - t.petdt - t.petpdt);
        f.petMdt = Math.min(87.5, (b.petTrait || 0) + t.petstout - t.petdt - t.petmdt);
        // the Ready move sets (the page's bst_pet.js) : MAB, Magic Accuracy (+1 a pet level over 119), INT, Melee DMG,
        // the "Ready" TP Bonus
        f.petMab = t.petmab; f.petMacc = t.petmacc + petLv * (b.lvMacc || 0); f.petInt = t.petint; f.petMelee = t.petmelee; f.petTpb = t.pettpb;
        // a BST's Charm set: CHR, the gear's Magic Accuracy, Charm+ (no published formula for the success), and the
        // length at an even level (BG Wiki Charm Duration: floor(1.25 x CHR + 150) s, x (1 + 0.05 x Charm+))
        f.chr = (b.chr || 0) + t.chr; f.charmPlus = t.charmplus; f.macc = t.macc;
        f.charmDur = Math.floor(Math.floor(1.25 * f.chr + 150) * (1 + 0.05 * t.charmplus));
        f.petRegen = t.petregen;   // its Regen from gear (Pet: Regen ; the same key as a luopan's, never both)
        var enhAll = (b.enh || 0) + t.enh, mndAll = (b.mnd || 0) + t.mnd, x = Math.floor(enhAll / 3) + mndAll;
        var ss = x < 80 ? x : x <= 130 ? Math.floor(2 * enhAll / 3) + 2 * mndAll - 60 : enhAll + 3 * mndAll - 190;
        f.stoneskin = Math.min(475, Math.min(350, ss) + t.ss);
        var div = (b.div || 0) + t.div;
        f.enhSkill = enhAll; f.divSkill = div;
        // a healer's spells (the page's stat_opt.js SPELL_OBJS, BG Wiki 2026-10-25): Cursna+ and the Healing skill its chance
        // rests on; the Subtle Blow Auspice gives (+10, + the feet's "Auspice"); the effects Esuna (under Afflatus Misery)
        // and Erase remove on top; the -na spread pieces; Divine landing as skill + magic accuracy + MND (assumed: BG Wiki
        // gives no formula for Repose, Flash, Banish), Magic Attack Bonus (assumed for Holy and Banish's damage)
        f.cursna = t.cursna; f.healSkill = (b.heal || 0) + t.heal; f.auspice = 10 + t.auspice;
        f.esunaPlus = t.esuna; f.erasePlus = t.erase; f.naVeil = t.naveil;
        f.divAcc = div + t.macc + (b.mnd || 0) + t.mnd; f.mab = t.mab;
        O.enhancingFigures(f, t, b, enhAll);
        // enfeebling magic (atelier/opt_enf.js, the page's app/js/enfeeble.js): a set cast for enfeebling spells
        if (O.enfeeblingFigures) O.enfeeblingFigures(f, t, b);
        // Burn, Frost and the other elemental debuffs (atelier/opt_enf.js)
        if (O.eleDebuffFigures) O.eleDebuffFigures(f, t, b);
        // dark magic (atelier/opt_enf.js): after the HP, Dread Spikes reading them
        if (O.darkFigures) O.darkFigures(f, t, b);
        // a Bard's song set (atelier/opt_song.js): only on a set the page gave a song (b.songKind)
        if (O.songFigures && b.songKind) O.songFigures(f, t, b);
        // the block the gear adds (Guide_Paladin: block rate = the shield's base + (shield skill - attacker's) x 0.2325,
        // and the pieces' "Chance of successful block"), the status and elemental resistances (the 8 elements' mean)
        f.blockGear = Math.round((t.shield * 0.2325 + t.block) * 10) / 10;
        // Doom removal (the page's stats.js DOOM_GEAR): Holy Water's 33 % with the pieces' bonus, 100 % at most;
        // the Cursna received the pieces add
        f.holyWater = Math.min(100, 33 + t.hw); f.cursnaRecv = t.crecv;
        // the chance the Chevalier's set adds to absorb a hit (STAT_SETS)
        f.absorb = t.absorb || 0;
        f.statusRes = t.statusRes; f.eleRes = Math.round(t.eleRes / 8 * 10) / 10;
        // the elements whose resistance is positive (Guide_Paladin, Magical Damage Mitigation: a positive resistance is
        // what lets magic evasion reach the full resist, 1/8; a negative one forces 1/2 at least): 0 to 8
        f.eleCover = ELEMENTS.filter(function (e) { return (t["res_" + e] || 0) > 0; }).length;
        // the cut of the enmity lost on each hit taken (Guide_Paladin, CE Loss Reduction): two buckets that multiply, each
        // 50 % at most: the Enmity (1 % a +2, Crusade in) and the "Reduces Enmity loss" pieces (Burtgang 20, Chev. Cuisses
        // +3 14, Creed Collar 5); 75 % in all (what the idle set wears when the hits land)
        var b1 = Math.max(0, Math.min(100, t.enmity + (b.enmity || 0))) / 200, b2 = Math.min(50, t.lossRed || 0) / 100;
        f.ceLoss = Math.round((1 - (1 - b1) * (1 - b2)) * 1000) / 10;
        f.enlight = div <= 500 ? 2 * Math.floor((div + 85) / 13) + Math.floor((div + 85) / 26) : 2 * Math.floor((div + 400) / 20) + Math.floor((div + 400) / 40);
        // the weapon's own Enlight bonus (BG Wiki: Brilliance +15, Honorbound +7, their melee hits only)
        f.enlight += t.enl || 0;
        // a self Cure IV: what it would heal, and what it heals (Guide_Paladin CURE SELF: the Fast Cast of the Cure lowers
        // the max HP, so the current HP with it; the Cure set raises the max HP; the Cure heals up to the gap)
        f.cureIV = O.cure(b.cureTier || 4, (b.mnd || 0) + t.mnd, (b.vit || 0) + t.vit, (b.heal || 0) + t.heal, t.cure, t.cure2 + (b.cure2 || 0), t.curerecv, b.cureJp);
        // the same Cure IV cast on someone else: the caster's "Cure potency received" is the receiver's, not counted;
        // past the 50 % cap of Cure Potency it still parts two sets by MND, VIT and Healing skill (the Cure's power)
        f.cureOther = O.cure(b.cureTier || 4, (b.mnd || 0) + t.mnd, (b.vit || 0) + t.vit, (b.heal || 0) + t.heal, t.cure, t.cure2 + (b.cure2 || 0), 0, b.cureJp);
        // what the Cure is worked out with, for the page's Cure box: Cure Potency as the gear gives it (its cap
        // 50 %) and II (30 %), MND, VIT and Healing skill, the power they make
        f.cureRaw = t.cure; f.cure2 = Math.min(30, t.cure2 + (b.cure2 || 0)); f.cure2Raw = t.cure2 + (b.cure2 || 0);
        f.cureMnd = (b.mnd || 0) + t.mnd; f.cureVit = (b.vit || 0) + t.vit; f.cureSkill = (b.heal || 0) + t.heal;
        f.curePower = Math.floor(f.cureMnd / 2) + Math.floor(f.cureVit / 4) + f.cureSkill;
        f.setBonuses = setBonuses;
        f.cureSelf = b.preHp != null ? Math.max(0, Math.min(f.cureIV, f.hp - b.preHp)) : f.cureIV;
        // the enmity of that heal (Guide_Paladin, Enmity Generated by Healing): CE = HP healed x 0.231 (one mob), VE = 6 x CE,
        // both x (1 + Enmity / 100) (Enmity counted to its +200 cap); CE + VE
        f.cureEnm = Math.floor(f.cureSelf * 0.231 * (1 + f.enmity / 100)) * 7;
        // the reductions as positive figures (more is better, like every objective); hpLow: HP where less is better (a
        // PLD's Fast Cast for a self Cure, low so the Cure set's HP opens a gap the Cure fills: Guide_Paladin CURE SELF)
        f.pdtRed = -f.pdtAll; f.mdtRed = -f.mdtAll; f.hpLow = f.hp;
        // Enmity a healer keeps as low as it can: the higher figure, the lower the Enmity
        f.enmityLow = -f.enmity;
        // the enemy's critical hits: 10 % at most, 1 % at least (BG Wiki), so the gear counts up to 9 less the merits
        f.ecritRed = Math.min(-f.ecrit, b.ecritRoom != null ? b.ecritRoom : 9);
        return f;
    };
    var ELEMENTS = ["fire", "ice", "wind", "earth", "lightning", "water", "light", "dark"];
    // the step a figure is compared by when other objectives follow it (DEF: 25, about 1 % of an end-game DEF)
    var STAT_STEP = {def: 25, meva: 25};
    // the objectives: every one a figure where more is better
    O.STAT_OBJS = ["def", "hp", "hpLow", "cureSelf", "enmity", "phalanx", "fc", "sird", "meva", "mdb", "pdtRed", "mdtRed", "ecritRed", "cure", "cmp", "refresh", "regen", "enhdur", "stoneskin", "enlight", "enhSkill", "divSkill", "enhTime", "refreshTick", "refreshMp", "regenTick", "regenHp", "gainPot", "temper", "enspell", "barEle", "aquaveil", "cureEnm", "blockGear", "statusRes", "eleRes", "ceLoss", "eleCover", "luDt", "luRegen", "luCharm", "geomancy", "geoSkill", "enfPot", "enfTime", "enfAcc", "enfEff", "enfSkill", "cursna", "healSkill", "auspice", "barStatus", "esunaPlus", "erasePlus", "naVeil", "divAcc", "mab",
        "darkSkill", "darkAcc", "drainPot", "aspirPot", "absorbPot", "darkTime", "absorbTp", "bioDot", "dreadSpikes", "endark",
        "petAcc", "petAtk", "petHaste", "petStp", "petDa", "petDt", "petMdt", "petRegen", "petMab", "petMacc", "petInt", "petMelee", "petTpb", "chr", "macc", "charmPlus", "charmDur", "move", "jaPlus", "holyWater", "cursnaRecv", "absorb",
        // a Bard's songs (atelier/opt_song.js)
        "songPlus", "songPot", "songDurPct", "songTime", "songTimeShort", "songSkill", "songAcc"];
    function statShort(f, fl) {
        if (!fl) return 0;
        var n = 0, num = function (k) { return fl[k] != null && fl[k] !== "" && isFinite(+fl[k]) && +fl[k] !== 0; };
        if (num("pdt")) n += Math.max(0, f.pdt - fl.pdt);
        if (num("mdt")) n += Math.max(0, f.mdt - fl.mdt);
        if (num("hp")) n += Math.max(0, fl.hp - f.hp) / 10;
        if (num("hpMax")) n += Math.max(0, f.hp - fl.hpMax) / 10;
        if (num("sird")) n += Math.max(0, fl.sird - f.sird);
        if (num("fc")) n += Math.max(0, fl.fc - f.fc);
        if (num("ecrit")) n += Math.max(0, f.ecrit - fl.ecrit);
        if (num("enmity")) n += Math.max(0, fl.enmity - f.enmity);
        if (num("phalanx")) n += Math.max(0, fl.phalanx - f.phalanx);
        if (num("ceLoss")) n += Math.max(0, fl.ceLoss - f.ceLoss);
        if (num("luDt")) n += Math.max(0, fl.luDt - f.luDt);
        // any figure asked to stay at a value or over (fl.min: {figure: value}): the potency a first search reached,
        // kept while a second one looks for the longest spell (stat_opt.js optimizeStats, enhancing magic)
        if (fl.min) for (var mk in fl.min) n += Math.max(0, fl.min[mk] - (f[mk] || 0));
        return n;
    }
    // A set's value: the objectives in their order (opts.objective, then opts.then), each well under a step of the one
    // before it; the floors as for the other sets (1e6 a point short)
    function statValue(ctx, pieces, opts) {
        var f = O.statFigures(ctx.stat, pieces), list = [opts.objective].concat(opts.then || []).filter(function (k) { return k && f[k] != null; });
        var v = 0, w = 1;
        // DEF and magic evasion part sets by steps of 25 (about 1 % of DEF, 3 % of MEva): a few points of them never
        // outweigh what the next objectives give
        // (Sworn Brais' 13 DEF over Chev. Cuisses +3's 8 % of enmity kept on an idle)
        list.forEach(function (k) { var x = k === "hpLow" ? -f[k] : STAT_STEP[k] && opts.then && opts.then.length ? Math.floor(f[k] / STAT_STEP[k]) : f[k]; v += w * x; w *= 1e-4; });
        var raw = list.length ? f[list[0]] : 0, miss = statShort(f, opts.floor);
        var def = {pdt: f.pdt, mdt: f.mdt, sb: 0};
        return {v: v - 1e6 * miss + O.tieBreak(pieces, def, opts, v), raw: raw, def: def, miss: miss, stats: f};
    }
    O.statValue = statValue;
});
