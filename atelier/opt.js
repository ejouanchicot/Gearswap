// Atelier optimizer: the page's sets, buffs and target turned into our engine's player and enemy (atelier/calc), a
// weaponskill's average damage and a set's value. One part of the engine (FFXI_PARTS): no DOM, no page state, so it
// also runs in a Web Worker (app/js/engine.js optWorker). Its other parts, loaded after it in this order
// (app/js/engine.js ENGINE_FILES): opt_round.js (an engaged set's round), opt_stat.js (the sets judged by their
// stats), opt_enf.js (enfeebling, elemental debuffs, dark magic), opt_ambu.js (the Ambuscade capes, a prime weapon's
// stage), opt_search.js (the search for the best set).
//
//   FFXI.opt.gear(piece, slot, ctx)   one piece as the engine reads it (catalogue + its augments)
//   FFXI.opt.selection(b)             the page's buff state as the buff total takes it (aggregate below)
//   FFXI.opt.context(...)             player, buffs, target and weaponskill of one evaluation
//   FFXI.opt.ws(ctx, pieces, tp)      the weaponskill's average damage with those pieces
//   FFXI.opt.tpPieces(rule, pieces, tp)  the TP pieces the job's rule adds (tp_bonus_calculator.lua)
//   FFXI.opt.nuke(ctx, pieces)        a nuke set's average damage over its spells
//   FFXI.opt.value(ctx, pieces, opts)  a set's value for an objective, with the defense floors
//
// @file    atelier/opt.js
// @author  ejouanchicot
(globalThis.FFXI_PARTS = globalThis.FFXI_PARTS || []).push(function (FFXI) {
    var O = FFXI.opt = {};
    var ALL_JOBS = ["war", "mnk", "whm", "blm", "rdm", "thf", "pld", "drk", "bst", "brd", "rng", "smn", "sam", "nin", "drg",
        "blu", "cor", "pup", "dnc", "sch", "geo", "run"];
    // the page's slot names -> the engine's
    O.SLOT = {main: "main", sub: "sub", range: "ranged", ammo: "ammo", head: "head", neck: "neck", ear1: "ear1", ear2: "ear2",
        body: "body", hands: "hands", ring1: "ring1", ring2: "ring2", back: "back", waist: "waist", legs: "legs", feet: "feet"};
    var PAGE_SLOTS = Object.keys(O.SLOT);
    // The party's buffs added up (atelier/calc/calc_buffs.js, BG Wiki)
    function aggregate(sel) { return CALC.aggregateBuffs(sel); }

    // ------------------------------------------------------------ catalogue
    var byId = null, byName = null;
    function index() {
        if (byId || !FFXI.CATALOG) return;
        byId = {}; byName = {};
        // by its short name and its long one, whatever the case: a set file writes either
        // ("Macu. Earring +1" / "Maculele Earring +1", "Supershear Ring" / "SuperShear Ring")
        FFXI.CATALOG.items.forEach(function (it) {
            byId[it.id] = it;
            [it.name, it.enl].forEach(function (n, i) {
                var k = n && n.toLowerCase();
                if (!k || (i === 1 && k === it.name.toLowerCase())) return;
                (byName[k] = byName[k] || []).push(it);
            });
        });
    }
    // The catalogue entry of a piece: its own item id when known, else the name's entry with the
    // highest item level (several ids share a name: a stage, an NQ and HQ copy...)
    var bestOf = {};
    O.item = function (name, id) {
        index();
        if (!byId) return null;
        if (id && byId[id]) return byId[id];
        if (name in bestOf) return bestOf[name];
        var list = byName[String(name).toLowerCase()] || [];
        return (bestOf[name] = list.slice().sort(function (a, b) { return (b.ilvl || 0) - (a.ilvl || 0) || b.id - a.id; })[0] || null);
    };

    O.empty = function () { return {"Name": "Empty", "Name2": "Empty", "Type": "None", "Skill Type": "None", "Jobs": ALL_JOBS.slice()}; };

    // The prime weapons (atelier/calc/calc_aftermath.js, BG Wiki)
    function primeWeapons() { return CALC.PRIME_WEAPONS; }
    O.primeWeapons = primeWeapons;
    // A weapon's second name, which the engine reads: a prime weapon's stage (aftermath),
    // a relic / mythic / empyrean / ergon / aeonic at R15 (weapon skill bonus)
    function name2(item, ctx) {
        if (primeWeapons().indexOf(item.name) !== -1) return item.name + " " + (ctx.primeStage || "V");
        var r = FFXI.ranked_entry ? FFXI.ranked_entry(item.name) : null;
        if (r && r.kind === "ultimate_weapon") return item.name + " R15";
        return item.name;
    }

    // One piece as the engine reads it: the catalogue's stats plus its augments (or its rank's).
    // ------------------------------------------------------------ fast search (opts.fast, the page's default)
    // A search that tries the same pieces thousands of times keeps what it already worked out: each piece's engine
    // item by slot, each set's player, each set's value (keyed by the pieces' identity). Off (the classic search),
    // nothing is kept and every try is worked out from scratch, as before.
    var IDS = typeof WeakMap !== "undefined" ? new WeakMap() : null, NEXT_ID = 1;
    function idOf(p) {
        if (!p || typeof p !== "object" || !IDS) return 0;
        var i = IDS.get(p);
        if (!i) { i = NEXT_ID++; IDS.set(p, i); }
        return i;
    }
    function setKey(pieces) { var k = ""; for (var i = 0; i < PAGE_SLOTS.length; i++) k += idOf(pieces[PAGE_SLOTS[i]]) + ","; return k; }
    var MEMO_MAX = 400000;
    O.gear = function (piece, slot, ctx) {
        if (!(ctx && ctx._fast && IDS && piece && typeof piece === "object")) return gearOf(piece, slot, ctx);
        var memo = ctx._gearMemo || (ctx._gearMemo = new WeakMap()), e = memo.get(piece);
        if (!e) { e = {}; memo.set(piece, e); }
        return slot in e ? e[slot] : (e[slot] = gearOf(piece, slot, ctx));
    };
    function gearOf(piece, slot, ctx) {
        if (!piece || !piece.name || piece.name === "empty") return O.empty();
        var item = O.item(piece.name, piece.id || (O.primeId ? O.primeId(piece.name, ctx) : null));
        if (!item) return null;
        var g = {"Name": item.name, "Name2": name2(item, ctx || {}), "Type": item.Type, "Jobs": item.jobs.slice()};
        if (item["Skill Type"]) g["Skill Type"] = item["Skill Type"];
        if (item.DMG) { g.DMG = item.DMG; g.Delay = item.Delay; }
        var add = function (src) { for (var k in src) if (typeof src[k] === "number") g[k] = (g[k] || 0) + src[k]; };
        add(item.stats || {});
        // what the game's description gives that the catalogue lacks (the page's fill: a stat it has none of)
        add(piece.fill || {});
        // a bonus that works in one ear only (the Empyrean earrings' "Right ear:"), in that ear (ear2 = right_ear)
        if (item.slot_stats && item.slot_stats[slot]) add(item.slot_stats[slot]);
        if (FFXI.parse_augments && (piece.augs && piece.augs.length || piece.rank != null)) {
            var parsed = FFXI.parse_augments(item.name, piece.augs || [], piece.rank), aug = parsed.stats;
            // an innate TP Bonus the game shows as an augment (Centovente: +1000 once, not twice)
            if (aug["TP Bonus"] && aug["TP Bonus"] === (item.stats || {})["TP Bonus"]) { aug = Object.assign({}, aug); delete aug["TP Bonus"]; }
            add(aug);
            // what the damage formulas do not read (HP, MP, Enmity, Fast Cast...): counted too, for the tanking and
            // magic figures (the parser keeps them apart: atelier/gear/augments_parse.js `extra`)
            add(parsed.extra || {});
        }
        // a path's rank stats only gearscan read (the page's extraAugs: no rank table here for that piece)
        if (FFXI.parse_augments && piece.extraAugs && piece.extraAugs.length) {
            var more = FFXI.parse_augments(item.name, piece.extraAugs);
            add(more.stats); add(more.extra || {});
        }
        // the parser's ranks and augments write Defense, the catalogue and the engine DEF
        if (g.Defense) { g.DEF = (g.DEF || 0) + g.Defense; delete g.Defense; }
        // a piece worn for one augment only, whatever its other one (Moonshade Earring: its TP Bonus +250)
        var only = ONLY_STATS[item.name];
        if (only) { for (var k in g) if (typeof g[k] === "number" && k !== "DMG" && k !== "Delay") delete g[k]; add(only); }
        return g;
    }
    var ONLY_STATS = {"Moonshade Earring": {"TP Bonus": 250}};

    // ------------------------------------------------------------ buffs
    // The page's buff state (atelier.html buffState) as the buff total takes it (aggregate)
    var FOOD_KEYS = {str: "STR", dex: "DEX", vit: "VIT", agi: "AGI", int: "INT", mnd: "MND", chr: "CHR", acc: "Accuracy",
        atkf: "Attack", racc: "Ranged Accuracy", ratkf: "Ranged Attack", mab: "Magic Attack", macc: "Magic Accuracy",
        hp: "HP", mp: "MP", sb: "Subtle Blow", stp: "Store TP", da: "DA", wsd: "Weapon Skill Damage"};
    // The songs as the engine reads them: Song1..Song4, Song5 under Clarion Call; the song under Marcato first,
    // the engine laying Marcato on Song1 (the page's b.marcato is that song's place)
    function songsOf(b) {
        // Aria of Passion is left to the page (its Loughnashade stage: the context's ariaPdl)
        var list = [b.song0, b.song1, b.song2, b.song3].concat(b.clarion ? [b.song4] : []).map(function (x) { return x && x !== "Aria of Passion" ? x : "None"; });
        if (b.marcato != null && !b.soulVoice && list[b.marcato]) list.unshift(list.splice(b.marcato, 1)[0]);
        var out = {};
        list.forEach(function (x, i) { out["Song" + (i + 1)] = x; });
        return out;
    }
    var HASTE_AS = {"Hastega": "Haste", "Hastega II": "Haste II"};
    O.selection = function (b, food) {
        var f = null;
        if (food) { f = {}; for (var k in food) if (FOOD_KEYS[k]) f[FOOD_KEYS[k]] = food[k]; }
        var bubble = function (kind, v) { return v ? kind + v : "None"; };
        return {
            brd: true, songs: songsOf(b), song_bonus: +(b.songsPlus || 0), soul_voice: !!b.soulVoice,
            marcato: b.marcato != null && !b.soulVoice,
            cor: true, rolls: {Roll1: {name: b.roll0 || "None", potency: b.roll0n || "XI"}, Roll2: {name: b.roll1 || "None", potency: b.roll1n || "XI"}},
            roll_bonus: +(b.rollsPlus || 0), crooked: false, job_bonus: false, light_shot: !!(b.lightshot && /^Dia/.test(b.dia || "")),
            geo: true, bubbles: {"Indi-": bubble("Indi-", b.indi), "Geo-": bubble("Geo-", b.geo), "Entrust-": bubble("Entrust-", b.entrust)},
            // the page scales each bubble itself (context's geoMul: Bolster, Blaze of Glory...)
            bubble_bonus: +(b.geoPlus || 0), bubble_potency: 100,
            // Garuda's Hastega / Hastega II read as Haste / Haste II (the same effect), Hastega's 3/1024 more added in context
            whm: true, whm_spells: {Dia: /^Dia/.test(b.dia || "") ? b.dia : "None", Haste: HASTE_AS[b.haste] || b.haste || "None", Boost: "None", Storm: b.storm || "None"},
            haste_extra: b.haste === "Hastega" ? 3 / 1024 : 0,
            shell5: b.shell === "Shell V", food: f, toggles: {}
        };
    };

    // ------------------------------------------------------------ evaluation
    // ctx: {job, sub, ml, buffs, abilities, enemy (create_enemy), ws, wsType ("melee" | "ranged"),
    //       metric ("Damage dealt"), primeStage}
    // Whether our engine knows a weaponskill (atelier/calc: our database, the magical and ranged weaponskills'
    // tables); the page asks before a search (app/js/optimizer.js, opt_all.js). Known is not always computed: a
    // number its pages leave out says so then (calc_bridge.js)
    O.knowsWs = function (name) {
        return !!(CALC.weaponskillInfo(name) || CALC.RANGED_WS[name] || CALC.MAGIC_WS[name]);
    };
    // The buffs with each bubble at the page's multiplier (Bolster, Blaze of Glory, Ecliptic Attrition, and an
    // NM's resistance to the debuffs: the page's geoMul): everything but the bubbles, then each bubble alone, scaled
    var GEO_SLOTS = {"Indi-": "indi", "Geo-": "geo", "Entrust-": "entrust"};
    function geoScaled(sel, mul) {
        var agg = aggregate(Object.assign({}, sel, {geo: false}));
        agg[0].geo = agg[0].geo || {};
        // each bubble alone, scaled; the same effect twice (Indi- and Geo- Fury) does not stack: the strongest counts
        var best = {};
        Object.keys(GEO_SLOTS).forEach(function (slot) {
            var bubbles = {"Indi-": "None", "Geo-": "None", "Entrust-": "None"}, name = (sel.bubbles || {})[slot] || "None";
            bubbles[slot] = name;
            if (name === "None") return;
            var one = aggregate({geo: true, bubbles: bubbles, bubble_bonus: sel.bubble_bonus, bolster: false, bog: false,
                bubble_potency: sel.bubble_potency, food: null, toggles: {}});
            var m = mul[GEO_SLOTS[slot]] || 1, size = 0, k, effect = name.split("-").pop();
            for (k in one[0].geo || {}) size += Math.abs(m * one[0].geo[k]);
            for (k in one[1]) size += Math.abs(m * one[1][k]);
            if (!best[effect] || size > best[effect].size) best[effect] = {one: one, m: m, size: size};
        });
        Object.keys(best).forEach(function (effect) {
            var one = best[effect].one, m = best[effect].m, k;
            for (k in one[0].geo || {}) agg[0].geo[k] = (agg[0].geo[k] || 0) + m * one[0].geo[k];
            // an offensive bubble on an NM: what its resistance leaves (the page's geoMul.foe)
            for (k in one[1]) agg[1][k] = (agg[1][k] || 0) + m * (mul.foe == null ? 1 : mul.foe) * one[1][k];
        });
        return agg;
    }
    O.context = function (c) {
        if (c.mode === "stats") return {mode: "stats", stat: c.stat, job: c.job};
        var agg = c.geoMul ? geoScaled(c.selection, c.geoMul) : aggregate(c.selection);
        // Distract's Evasion down, worked out by the page (its tier, Saboteur on a monster or an NM)
        if (c.evaDown) agg[1].Evasion = (agg[1].Evasion || 0) + c.evaDown;
        if (c.ariaPdl) agg[0].brd.PDL = (agg[0].brd.PDL || 0) + c.ariaPdl;
        if (c.selection.haste_extra) agg[0].whm["Magic Haste"] = (agg[0].whm["Magic Haste"] || 0) + c.selection.haste_extra;
        // the rolls again, each alone with its own job bonus and Crooked Cards (the engine has one switch for both rolls)
        if (c.rollOpts && c.selection.cor) {
            agg[0].cor = {};
            [1, 2].forEach(function (n, i) {
                var roll = (c.selection.rolls || {})["Roll" + n], opt = c.rollOpts[i] || {};
                if (!roll || roll.name === "None") return;
                var one = aggregate({cor: true, rolls: {Roll1: roll}, roll_bonus: c.selection.roll_bonus, job_bonus: !!opt.job,
                    crooked: !!opt.cc, light_shot: false, food: null, toggles: {}});
                for (var k in one[0].cor) agg[0].cor[k] = (agg[0].cor[k] || 0) + one[0].cor[k];
            });
        }
        // the abilities on the target, worked out by the page (one Defense Down effect, the strongest, and Box Step)
        if (c.foeDown && c.foeDown.def) agg[1].Defense = (agg[1].Defense || 0) + c.foeDown.def;
        if (c.foeDown && c.foeDown.mdb) agg[1]["Magic Defense"] = (agg[1]["Magic Defense"] || 0) + c.foeDown.mdb;
        // the elemental debuffs and Impact on its stats, Feather Step on your critical hits
        if (c.foeDown && c.foeDown.stats) Object.keys(c.foeDown.stats).forEach(function (st) { agg[1][st] = (agg[1][st] || 0) + c.foeDown.stats[st]; });
        if (c.foeDown && c.foeDown.crit) agg[0].feather_step = {"Crit Rate": c.foeDown.crit};
        // a RUN's Gambit: the magic damage of its runes' element taken +10 % a rune, for a weaponskill of that element
        var probe = wsProbe(c);
        if (c.foeDown && c.foeDown.gambit && probe && (probe.magical || probe.hybrid) && probe.elements.indexOf(c.foeDown.gambit.elem) !== -1)
            agg[1]["Magic DT%"] = (agg[1]["Magic DT%"] || 0) + c.foeDown.gambit.pct;
        // a party WAR's Warcry: its attack and the TP Bonus of its Savagery merits and Agoge Mask, worked out by
        // the page (the engine's own "Warcry" is a WAR's: 700 TP Bonus and +60 attack)
        if (c.partyWarcry != null) agg[0].party_warcry = {"Attack%": Math.trunc(99 / 4 + 4.75) / 256, "TP Bonus": c.partyWarcry};
        // a WAR main's own Warcry: the engine counts 700 TP Bonus (Savagery 5/5 with Agoge Mask); the page's choice moves it
        if (c.warcryTpDelta) agg[0].own_warcry = {"TP Bonus": c.warcryTpDelta};
        // a party SMN's Avatar's Favor at BG Wiki's top values (the page's partyStats; the engine's own are lower or higher)
        if (c.partyStats && Object.keys(c.partyStats).length) agg[0].party_favor = c.partyStats;
        var out = {job: c.job.toLowerCase(), sub: (c.sub || "war").toLowerCase(), ml: c.ml || 0, buffs: agg[0], abilities: withNakedHp(withBase(c), c),
            enemy: CALC.makeEnemy(FFXI.ENEMIES, c.enemy, agg[1]), ws: c.ws, wsType: c.wsType || "melee", metric: c.metric || "Damage dealt",
            primeStage: c.primeStage, dmgMul: physMul(c), mode: c.mode || "ws", sbBuff: c.sbBuff || 0,
            physResBy: c.physResBy || null, banish: c.banish, tomahawk: c.tomahawk, fanDance: c.fanDance || null,
            spells: c.spells || null, spellType: c.spellType || "Elemental Magic", nuke: c.nuke || null,
            layers: c.layers || null, belt: c.belt || null};
        // a Magic Burst set (O.nuke): the old engine reads the burst as an ability, ours as the spell's option (calc_bridge.js)
        if (out.mode === "nuke" && c.magicBurst) out.abilities = Object.assign({}, out.abilities, {"Magic Burst": true});
        return out;
    };
    // The abilities with the character's own base attributes ("Base Stats"), from the game's status packet: c.base
    // ({main, sub, merits, str: 153, dex: 141...}), else the page's measuredBase(job). Measured with another subjob: that
    // subjob's attribute bonus swapped for this one's (create_player's tables). Same main job only.
    var ATTRS = ["STR", "DEX", "VIT", "AGI", "INT", "MND", "CHR"];
    // The HP without gear the page worked out (atelier/app/js/engine.js optContextInput): Lycurgos's TP Bonus
    // (atelier/calc/calc_page.js); the engine before does not read it
    function withNakedHp(ab, c) {
        return typeof c.nakedHp === "number" ? Object.assign({}, ab, {"Naked HP": c.nakedHp}) : ab;
    }
    function withBase(c) {
        var ab = c.abilities || {}, job = c.job.toLowerCase(), sub = (c.sub || "war").toLowerCase();
        var m = c.base !== undefined ? c.base : (typeof measuredBase === "function" ? measuredBase(job) : null);
        if (!m || ab["Base Stats"] || (m.main && m.main.toLowerCase() !== job)) return ab;
        // what changing support job moves (atelier/calc/calc_attributes.js, LandSandBoat's grades)
        var shift = CALC.subJobShift((m.sub || sub).toLowerCase(), sub, c.ml), real = {};
        ATTRS.forEach(function (k) {
            var v = m[k.toLowerCase()];
            if (typeof v === "number") real[k] = v + (shift[k] || 0);
        });
        var out = {"Base Stats": real};
        // the "Critical Hit Rate" merits the export read (none listed = none placed)
        if (m.merits) out["Crit Rate Merits"] = m.merits.critical_hit_rate || 0;
        // every merit level read, by the export's names (exenterator: 3): a merit weaponskill's modifier follows
        // the ones bought (atelier/calc/calc_page.js); the engine before does not read it
        if (m.merits) out["WS Merits"] = m.merits;
        return Object.assign({}, ab, out);
    }
    // The target's resistance to the weaponskill's damage type (the page's physRes, percent: +25 takes more, -25
    // resists), Tomahawk cutting a resistance by a quarter (BG Wiki: 50 % -> 37 %), Banish II by 70 % on an undead;
    // for a physical weaponskill only,
    // the engine already counts a magical one's (Magic DT%)
    // A weaponskill's own flags (magical, hybrid, element: "Light/Dark" is either) from our tables; null when they do
    // not hold it
    function wsProbe(c) {
        var own = CALC.weaponskillInfo(c.ws) || CALC.RANGED_WS[c.ws] || CALC.MAGIC_WS[c.ws];
        if (!own) return null;
        return {magical: own.type === "Magical", hybrid: own.type === "Hybrid", elements: String(own.element || "").split("/")};
    }
    function physMul(c) {
        // an engaged set's auto-attacks are physical, of the main weapon's type (the page's physRes)
        var r = c.physRes || 0, v = !r ? null : c.mode === "engaged" ? {} : wsProbe(c);
        if (!v || v.magical || v.hybrid) return 1;
        // a resistance cut: Banish II's 70 % (an undead) or Tomahawk's 25 %, the stronger
        return 1 + (r < 0 && c.banish ? r * 0.3 : r < 0 && c.tomahawk ? r * 0.75 : r) / 100;
    }
    // A result of FFXI.average_ws with its damage scaled by ctx.dmgMul (the TP return untouched)
    function scaled(ctx, r, metric) {
        var m = ctx.dmgMul || 1;
        if (!r || m === 1) return r;
        return [metric === "TP return" ? r[0] : r[0] * m, [r[1][0] * m, r[1][1], r[1][2]]];
    }
    // The slots a piece leaves empty: "Cannot equip headgear", "Cannot Equip Hand, Leg, or Footgear", "Cannot Equip
    // Headgear or Handgear": every slot the sentence names
    var BLOCK = {head: "head", hand: "hands", leg: "legs", foot: "feet"}, SUIT = ["hands", "legs", "feet"];
    // The game's English text names too few slots on these (its Japanese text and the game itself: an Onca Suit comes
    // off as soon as a hand or foot piece goes on, its text says leggear only)
    var BLOCK_FIX = {"Onca Suit": SUIT, "Behemoth Suit": SUIT, "Behemoth Suit +1": SUIT, "Wyrmking Suit": SUIT,
        "Wyrmking Suit +1": SUIT, "Mandra. Suit": SUIT, "Mandra. Suit +1": SUIT, "Korrigan Suit": SUIT, "Kupo Suit": SUIT,
        "Goblin Suit": SUIT, "G. Moogle Suit": SUIT, "Chocobo Suit": SUIT, "Chocobo Suit +1": SUIT, "Bl. Chocobo Suit": SUIT,
        "Botulus Suit": ["head", "hands"], "Botulus Suit +1": ["head", "hands"],
        "Poroggo Cassock": ["head"], "Poroggo Cass. +1": ["head"]};
    O.blocks = function (piece) {
        var item = piece && piece.name && O.item(piece.name, piece.id), out = (BLOCK_FIX[piece && piece.name] || []).slice();
        ((item && item.unparsed) || []).forEach(function (t) {
            var m = String(t).match(/Cannot equip ((?:\w+,? )*?\w*gear(?: or \w+gear)*)/i);
            (m ? m[1].match(/head|hand|leg|foot/gi) : []).forEach(function (w) {
                if (out.indexOf(BLOCK[w.toLowerCase()]) < 0) out.push(BLOCK[w.toLowerCase()]);
            });
        });
        // an instrument in the ranged slot (a GEO's bell, a BRD's horn or harp) leaves no room for ammo
        if (item && item.Type === "Instrument") out.push("ammo");
        return out;
    };
    // Every slot a set's pieces leave empty
    O.blocked = function (pieces) {
        var out = {};
        PAGE_SLOTS.forEach(function (slot) { O.blocks(pieces[slot]).forEach(function (b) { out[b] = true; }); });
        return out;
    };
    // The engine's gear set from the page's pieces ({page slot: piece}); null when a piece is unknown.
    // A slot another piece blocks is empty.
    O.gearset = function (ctx, pieces) {
        var set = {}, blocked = O.blocked(pieces);
        for (var i = 0; i < PAGE_SLOTS.length; i++) {
            var slot = PAGE_SLOTS[i], g = blocked[slot] ? O.empty() : O.gear(pieces[slot], slot, ctx);
            if (!g) return null;
            set[O.SLOT[slot]] = g;
        }
        return set;
    };
    // The weaponskill's average with those pieces at that TP: [metric value, [damage, TP return, ...]]
    O.ws = function (ctx, pieces, tp) {
        var set = O.gearset(ctx, pieces);
        if (!set) return null;
        var player = FFXI.create_player(ctx.job, ctx.sub, ctx.ml, set, ctx.buffs, ctx.abilities);
        return scaled(ctx, FFXI.average_ws(player, ctx.enemy, ctx.ws, tp, ctx.wsType, ctx.metric), ctx.metric);
    };

    // ------------------------------------------------------------ TP bonus
    // The pieces the job's rule adds before a weaponskill (shared/utils/weaponskill/tp_bonus_calculator.lua):
    // rule = {bonus (weapon, buffs, Fencer), pieces [{slot, name, bonus}]}; the set's own TP pieces count;
    // one piece that closes the gap is the smallest that does, else the biggest first.
    // rule.weaponTp ({name: TP Bonus}, the game's word for your weapons): `bonus` then leaves the weapons out and
    // the main, sub and ranged weapon of the set tried count their own (a search trying another gun than
    // Anarchy +2 loses its +1000); a weapon the game was not asked about: what the engine reads on it.
    function weaponTp(rule, pieces) {
        if (!rule.weaponTp) return 0;
        var total = 0, seen = {};
        ["main", "sub", "range"].forEach(function (slot) {
            var p = pieces[slot];
            if (!p || !p.name || p.name === "empty" || seen[p.name]) return;
            seen[p.name] = true;
            if (!(p.name in rule.weaponTp)) { var g = null; try { g = gearOf(p, slot, {}); } catch (e) {} rule.weaponTp[p.name] = (g && g["TP Bonus"]) || 0; }
            total += rule.weaponTp[p.name];
        });
        return total;
    }
    O.tpPieces = function (rule, pieces, tp) {
        if (!rule || !rule.pieces) return {};
        var worn = 0, left = [];
        var twin = {ring1: "ring2", ring2: "ring1", ear1: "ear2", ear2: "ear1"};
        rule.pieces.forEach(function (p) {
            var on = pieces[p.slot], other = pieces[twin[p.slot]];
            if ((on && on.name === p.name) || (other && other.name === p.name)) worn += p.bonus; else left.push(p);
        });
        var eff = tp + (rule.bonus || 0) + weaponTp(rule, pieces) + worn, th = eff < 2000 ? 2000 : eff < 3000 ? 3000 : 0;
        if (!th) return {};
        var gap = th - eff, total = left.reduce(function (n, p) { return n + p.bonus; }, 0);
        if (gap > total) return {};
        var asc = left.slice().sort(function (a, b) { return a.bonus - b.bonus; });
        for (var i = 0; i < asc.length; i++) if (asc[i].bonus >= gap) { var one = {}; one[asc[i].slot] = {name: asc[i].name}; return one; }
        var out = {}, got = 0;
        asc.reverse().forEach(function (p) { if (got < gap) { out[p.slot] = {name: p.name}; got += p.bonus; } });
        return out;
    };

    // ------------------------------------------------------------ search
    // The defensive totals of a set's gear: DT + PDT, DT + MDT (Shell not counted), Subtle Blow as the game caps it
    // (BG Wiki: I and II 50 each, 75 together; sbBuff, a party's Auspice, counts in I)
    O.defense = function (set, sbBuff) {
        var sum = function (k) { var n = 0; for (var sl in set) n += set[sl][k] || 0; return n; };
        var sb = Math.min(75, Math.min(50, sum("Subtle Blow") + (sbBuff || 0)) + Math.min(50, sum("Subtle Blow II")));
        return {pdt: sum("DT") + sum("PDT"), mdt: sum("DT") + sum("MDT"), sb: sb};
    };
    // Fan Dance up (ctx.fanDance = {merit}): the physical damage taken is the gear's DT + PDT, capped at -50 %, times the
    // dance's cut, which is no part of that cap (BG Wiki, Fan Dance: "does not count towards the Physical Damage Taken cap
    // of 50%, but is multiplied with it"). The cut is counted at its floor, 20 %, the one that lasts (90 % at first, 10 %
    // less a hit taken), and 1 % more a "Fan Dance" merit level with Horos Bangles or Etoile Bangles +2 on the hands: so
    // the search weighs them against any other hands. def.pdt is then that total (the floor asked is read against it),
    // def.gearPdt the gear's own, def.fan the cut
    var FAN_HANDS = /^(Horos Bangles|Etoile Bangles \+2)/;
    O.fanCut = function (merit, hands) { return 20 + (hands && FAN_HANDS.test(hands) ? merit || 0 : 0); };
    function defOf(ctx, set, pieces) {
        var def = O.defense(set, ctx.sbBuff);
        if (!ctx.fanDance) return def;
        var hands = !O.blocked(pieces).hands && pieces.hands && pieces.hands.name;
        def.fan = O.fanCut(ctx.fanDance.merit, hands);
        def.gearPdt = def.pdt;
        def.pdt = Math.round(((1 + Math.max(def.pdt, -50) / 100) * (1 - def.fan / 100) - 1) * 1000) / 10;
        return def;
    }
    // How far a set is from the floors (0 when it meets them): opts.floor = {pdt: -50, mdt: -21, sb: 0, hit: 0},
    // hit the weaponskill's hit rate in % (O.hit)
    function shortfall(def, floor, hit) {
        if (!floor) return 0;
        return Math.max(0, def.pdt - (floor.pdt == null ? 0 : floor.pdt)) + Math.max(0, def.mdt - (floor.mdt == null ? 0 : floor.mdt))
            + Math.max(0, (floor.sb || 0) - def.sb) + (floor.hit && hit != null ? Math.max(0, floor.hit - hit) : 0);
    }
    // The hit rates (%) of a weaponskill, as FFXI.average_ws counts them (actions.js): [its first hit
    // (+100 accuracy), the hits after it and the extra hits of a double / triple attack], the main hand's
    // accuracy for that weaponskill at that TP against the target's Evasion, capped at 99 % one-handed,
    // 95 % two-handed; null for a ranged one
    var ONE_HANDED = ["Axe", "Club", "Dagger", "Sword", "Katana", "Hand-to-Hand"];
    function hitAt(ctx, player, tp) {
        if (ctx.wsType === "ranged") return null;
        var s = player.stats, g = player.gearset, skill = (g.main || {})["Skill Type"];
        var dual = (g.sub || {}).Type === "Weapon" || skill === "Hand-to-Hand";
        var at = Math.max(1000, Math.min(3000, tp + (s["TP Bonus"] || 0)));
        var info = FFXI.weaponskill_info(ctx.ws, at, player, ctx.enemy, s.WSC || [], dual);
        var cap = ONE_HANDED.indexOf(skill) !== -1 ? 0.99 : 0.95;
        var acc = info.player_accuracy1 + (s["Weapon Skill Accuracy"] || 0), eva = ctx.enemy.stats.Evasion;
        return [100 * FFXI.get_hit_rate(acc + 100, eva, cap), 100 * FFXI.get_hit_rate(acc, eva, cap)];
    }
    // A set's hit rates at the weaponskill, {first, rest}: the lowest over the TP looked at (a
    // weaponskill's accuracy bonus grows with TP); the floor reads `rest`
    O.hits = function (ctx, pieces, opts) {
        if (ctx.mode === "engaged" || ctx.mode === "stats" || ctx.mode === "nuke") return null;
        var tps = opts.objective === "damage_avg" ? (opts.tps || [opts.tp]) : [opts.tp], low = null;
        for (var i = 0; i < tps.length; i++) {
            var pl = playerOf(ctx, wornAt(pieces, opts, tps[i]));
            var h = pl ? hitAt(ctx, pl.player, tps[i]) : null;
            if (h && (!low || h[1] < low.rest)) low = {first: h[0], rest: h[1]};
        }
        return low;
    };
    O.hit = function (ctx, pieces, opts) { var h = O.hits(ctx, pieces, opts); return h ? h.rest : null; };
    // The set worn at the weaponskill: the pieces, then the TP pieces the job's rule lays at that TP
    function wornAt(pieces, opts, tp) {
        var worn = Object.assign({}, pieces), add = O.tpPieces(opts.tpRule, pieces, tp), blocked = O.blocked(pieces);
        // no TP piece on a slot another piece blocks (no Boii Cuisses under Onca Suit)
        for (var s in add) if (!blocked[s]) worn[s] = add[s];
        return worn;
    }
    // Whether the TP pieces changed a slot of the set
    function covers(worn, pieces) {
        for (var s in worn) if (worn[s] !== pieces[s]) return true;
        return false;
    }
    // The player of a set, kept (per context) while a search tries the same set at several TP:
    // creating it is most of the cost of an evaluation
    function playerOf(ctx, worn) {
        if (ctx._noMemo) { var s0 = O.gearset(ctx, worn); return s0 ? {player: FFXI.create_player(ctx.job, ctx.sub, ctx.ml, s0, ctx.buffs, ctx.abilities), def: defOf(ctx, s0, worn)} : null; }
        var key = ctx._fast && IDS ? setKey(worn) : PAGE_SLOTS.map(function (sl) { var p = worn[sl]; return p ? p.name + "|" + (p.augs || []).join("|") + "|" + (p.rank == null ? "" : p.rank) : ""; }).join("#");
        var cache = ctx._players = ctx._players || {map: {}, size: 0};
        if (cache.map[key]) return cache.map[key];
        var set = O.gearset(ctx, worn);
        if (!set) return null;
        if (cache.size > 20000) { cache.map = {}; cache.size = 0; }
        cache.size++;
        return (cache.map[key] = {player: FFXI.create_player(ctx.job, ctx.sub, ctx.ml, set, ctx.buffs, ctx.abilities), def: defOf(ctx, set, worn)});
    }
    // One weaponskill: the engine's [value, [damage, TP return]] for the objective
    // ------------------------------------------------------------ damaging spells (nukes)
    // A set of elemental magic or elemental ninjutsu (ctx.mode "nuke"): its average damage over the spells it is judged on
    // (ctx.spells), a Magic Burst when the set is the job's burst set (O.context: ctx.abilities["Magic Burst"]). The damage
    // is the engine's: ours (atelier/calc/calc_magic.js, through FFXI.cast_spell of calc_bridge.js) or the old one's.
    // Returns {damage, unresisted, hitRate, macc} (the last three from our engine only), null when nothing is computed
    // The pieces worn in game for one spell: the set, the job's sets laid over it (ctx.layers, the page's
    // nuke_layers.js: BLM's MPConservation under its MP threshold, QuanpurStone on a Stone spell), then the belt the
    // shared Elemental Belt puts on in the situation chosen (ctx.belt); the key tells the spells worn the same apart
    function wornFor(ctx, pieces, spell) {
        var out = pieces, key = "";
        (ctx.layers || []).forEach(function (L, i) {
            if (L.spells && L.spells.indexOf(spell) === -1) return;
            out = Object.assign({}, out, L.pieces);
            key += i + ",";
        });
        if (ctx.belt && ctx.belt.name) out = Object.assign({}, out, {waist: {name: ctx.belt.name}});
        return {pieces: out, key: key};
    }
    // The spell's options in that situation: Orpheus's Sash adds its bonus at the distance chosen (+1 away, +15 next
    // to the target: shared/utils/equipment/elemental_bonus.lua), which the catalogue's flat "Elemental Bonus" is not
    function nukeOptions(ctx, worn) {
        var o = ctx.nuke || {}, waist = worn.waist && worn.waist.name;
        return waist === "Orpheus's Sash" ? Object.assign({}, o, {affinity: (o.affinity || 0) + (o.orpheus == null ? 1 : o.orpheus)}) : o;
    }
    O.nuke = function (ctx, pieces) {
        if (!FFXI.cast_spell) return null;
        var list = ctx.spells && ctx.spells.length ? ctx.spells : ["Thunder"], sum = 0, unres = 0, hit = 0, macc = 0, n = 0, own = 0;
        var players = {}, pl = null;
        for (var i = 0; i < list.length; i++) {
            var w = wornFor(ctx, pieces, list[i]);
            if (!players[w.key]) players[w.key] = {pl: playerOf(ctx, w.pieces), pieces: w.pieces};
            var at = players[w.key];
            if (!at.pl) return null;
            pl = pl || at.pl;
            var r = FFXI.cast_spell(at.pl.player, ctx.enemy, list[i], ctx.spellType, "Damage dealt", nukeOptions(ctx, at.pieces));
            if (!r || !r[1]) continue;
            n++; sum += r[1][0];
            if (r[2]) { own++; unres += r[2].unresisted; hit += r[2].hitRate; macc += r[2].magicAccuracy; }
        }
        if (!n) return null;
        // sheet: our engine's character sheet for the first spell (the totals the page's "In combat" tab shows)
        return {damage: sum / n, unresisted: own ? unres / own : null, hitRate: own ? hit / own : null, macc: own ? macc / own : null, def: pl.def,
            sheet: pl.player && pl.player.own ? pl.player.stats : null};
    };
    function once(ctx, worn, tp, metric) {
        var pl = playerOf(ctx, worn);
        if (!pl) return null;
        return {r: scaled(ctx, FFXI.average_ws(pl.player, ctx.enemy, ctx.ws, tp, ctx.wsType, metric), metric), def: pl.def};
    }
    // A set's value for opts.objective: "damage" at opts.tp, "damage_avg" over opts.tps, "tp_return"
    // (damage breaks ties); a set short of the floors loses 1e6 per point, so the search meets them first
    // Between sets of the same value, the one that takes less damage, then the one that keeps more of the set's own
    // pieces (opts.base): a slot where nothing matters keeps its piece, rather than the first one tried (Baetyl Pendant,
    // first by name, for an engaged set whose accuracy is capped)
    function tieBreak(pieces, def, opts, v) {
        var keep = 0, base = opts.base || {};
        for (var k in base) if (pieces[k] && base[k] && pieces[k].name === base[k].name) keep++;
        // relative to the value: a fixed 1e-12 is lost to rounding on a 50 000 damage value
        var sc = Math.max(1, Math.abs(v || 0));
        // a set laid over another one (the page's stat_opt.js moveSet): the fewest pieces part the sets as good, every
        // slot left out is the set's under it (the damage taken added Defending Ring and co to sets.MoveSpeed)
        if (opts.bare) { var n = 0; for (var sl in pieces) if (pieces[sl]) n++; return sc * (-n * 1e-13 + keep * 1e-15); }
        return sc * (-((def && def.pdt) || 0) * 1e-13 - ((def && def.mdt) || 0) * 1e-13 + keep * 1e-15);
    }
    O.value = function (ctx, pieces, opts) {
        if (!ctx._fast || ctx._noMemo || !IDS) return valueOf(ctx, pieces, opts);
        var memo = ctx._valueMemo || (ctx._valueMemo = {by: new WeakMap(), size: 0});
        var map = memo.by.get(opts);
        if (!map) { map = new Map(); memo.by.set(opts, map); }
        var key = setKey(pieces), hit = map.get(key);
        if (hit) return hit;
        if (memo.size > MEMO_MAX) { memo.by = new WeakMap(); memo.size = 0; map = new Map(); memo.by.set(opts, map); }
        var r = valueOf(ctx, pieces, opts);
        map.set(key, r); memo.size++;
        return r;
    };
    function valueOf(ctx, pieces, opts) {
        if (ctx.mode === "stats") return O.statValue(ctx, pieces, opts);
        if (ctx.mode === "nuke") {
            var nk = O.nuke(ctx, pieces);
            if (!nk) return {v: -Infinity};
            var missN = shortfall(nk.def, opts.floor, null);
            return {v: nk.damage - 1e6 * missN + tieBreak(pieces, nk.def, opts, nk.damage), raw: nk.damage, def: nk.def, miss: missN, nuke: nk};
        }
        if (ctx.mode === "engaged") {
            var e0 = O.roundValue(ctx, pieces, opts);
            if (!e0) return {v: -Infinity};
            var miss0 = shortfall(e0.def, opts.floor, null);
            return {v: e0.v - 1e6 * miss0 + tieBreak(pieces, e0.def, opts, e0.v), raw: e0.raw, def: e0.def, miss: miss0, round: e0.round};
        }
        var tps = opts.objective === "damage_avg" ? (opts.tps || [1000, 1500, 2000, 2500, 3000]) : [opts.tp];
        var metric = opts.objective === "tp_return" ? "TP return" : "Damage dealt", total = 0, under = 0, def = null;
        var worth = function (e) { return opts.objective === "tp_return" ? e.r[1][1] + e.r[1][0] / 1e6 : e.r[1][0]; };
        for (var i = 0; i < tps.length; i++) {
            var worn = wornAt(pieces, opts, tps[i]), e = once(ctx, worn, tps[i], metric);
            if (!e) return {v: -Infinity};
            def = def || e.def;
            total += worth(e);
            // the set under the TP pieces (the earring a Moonshade covers at 1000 TP): worked out too, so it is
            // still the best one for when the rule lays nothing (a higher TP); it only parts sets of the same value
            var u = covers(worn, pieces) ? once(ctx, pieces, tps[i], metric) : e;
            under += u ? worth(u) : 0;
        }
        var hit = opts.floor && opts.floor.hit ? O.hit(ctx, pieces, opts) : null;
        var v = total / tps.length, miss = shortfall(def, opts.floor, hit);
        return {v: v - 1e6 * miss + 1e-7 * under / tps.length + tieBreak(pieces, def, opts, v), raw: v, def: def, miss: miss};
    }

    // shared with the other parts: an engaged set's round (opt_round.js) and a stats set's value (opt_stat.js)
    O.playerOf = playerOf; O.physMul = physMul; O.tieBreak = tieBreak;
});
