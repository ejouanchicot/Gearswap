// Augment strings -> the catalogue's stat keys (STAT_KEYS.md).
//
// FFXI.parse_augments(itemName, augs, rankIfKnown) reads what the export gives
// for one owned piece: the item's English short name and the augment strings
// Windower's libs/extdata.lua decodes ('STR+20', 'Accuracy+20 Attack+20',
// '"Dbl.Atk."+3', 'Weapon skill damage +10%', 'Path: A', 'Rank: 15'). Odyssey,
// Dynamis-D, Unity and ultimate weapons only decode to 'Path: X': their stats
// come from FFXI.RANKED (augments_ranked.js) for that path and rank.
//
// Keys are the catalogue's (augments_build.py STAT_KEYS). Other effects land
// in `extra` under a readable key (HP, Enmity, Fast Cast, Pet:..., per-WS
// damage...). Strings that cannot be read go to `unknown`, untouched.
//
// Labels come from extdata.lua augment_values (systems 1 and 2, every label)
// plus the spellings of BG Wiki and of the LSB bundle texts, so the same
// parser reads the three sources. See catalog/AUGMENTS.md.
//
// @author ejouanchicot
(globalThis.FFXI_PARTS = globalThis.FFXI_PARTS || []).push(function (FFXI) {

    // stat key -> labels that mean it (spellings are normalised by norm()).
    var LABELS = {
        'HP': ['HP'], 'MP': ['MP'],
        'STR': ['STR'], 'DEX': ['DEX'], 'VIT': ['VIT'], 'AGI': ['AGI'],
        'INT': ['INT'], 'MND': ['MND'], 'CHR': ['CHR'],
        'Accuracy': ['Accuracy', 'Acc.', 'Acc'],
        'Attack': ['Attack', 'Atk.', 'Atk'],
        'Ranged Accuracy': ['Rng.Acc.', 'Rng. Acc.', 'Ranged Accuracy', 'Ranged Acc.', 'R.Acc.', 'R. Acc.', 'RngAcc'],
        'Ranged Attack': ['Rng.Atk.', 'Rng. Atk.', 'Ranged Attack', 'Ranged Atk.', 'R.Atk.', 'RngAtk'],
        'Magic Accuracy': ['Mag. Acc.', 'Mag. Acc', 'Magic Accuracy', 'Magic Acc.', 'Mag. Accuracy', 'M.Acc.', 'MagAcc'],
        'Magic Attack': ['"Mag.Atk.Bns."', '"Mag. Atk. Bns."', '"Magic Atk. Bonus"', 'Magic Attack Bonus',
            'Mag. Atk. Bns.', 'Mag. Atk. Bonus', 'Magic Atk. Bonus', 'Magic Attack', 'MAB'],
        'Magic Damage': ['Magic Damage', 'Magic damage', 'Mag. Dmg.', 'M.Dmg.', 'MagDmg'],
        'Evasion': ['Evasion', 'Eva.', 'Eva'],
        'Magic Evasion': ['Mag. Evasion', 'Mag. Eva.', 'Magic Evasion', 'Mag. Eva', 'MagEva'],
        'Magic Defense': ['"Mag.Def.Bns."', '"Mag. Def. Bns."', '"Magic Def. Bonus"', 'Magic Defense Bonus',
            'Mag. Def. Bns.'],
        'Defense': ['DEF', 'Defense'],
        'Crit Rate': ['Crit.hit rate', 'Crit. hit rate', 'Critical hit rate', 'Critical Hit Rate', 'Crit Rate'],
        'Crit Damage': ['Crit. hit damage', 'Critical hit damage', 'Critical Hit Damage'],
        'Store TP': ['"Store TP"', 'Store TP'],
        'Subtle Blow': ['"Subtle Blow"', 'Subtle Blow'],
        'Subtle Blow II': ['"Subtle Blow II"', 'Subtle Blow II'],
        'DA': ['"Dbl.Atk."', '"Dbl. Atk."', '"Double Attack"', 'Double Attack'],
        'TA': ['"Triple Atk."', '"Triple Attack"', 'Triple Attack', 'Trip. Atk.'],
        'QA': ['Quadruple Attack', '"Quadruple Attack"'],
        'Dual Wield': ['"Dual Wield"', 'Dual Wield'],
        'Gear Haste': ['Haste'],
        'DMG': ['DMG:', 'DMG'],
        'DT': ['Damage taken', 'Damage Taken'],
        'PDT': ['Phys. dmg. taken', 'Physical damage taken', 'Physical Damage Taken'],
        'MDT': ['Magic dmg. taken', 'Magic damage taken', 'Magic Damage Taken'],
        'Weapon Skill Damage': ['Weapon skill damage', 'Weapon Skill Damage', 'Weaponskill damage'],
        'Weapon Skill Accuracy': ['Weapon Skill Acc.', 'Weapon Skill Accuracy'],
        'Skillchain Bonus': ['Sklchn.dmg.', 'Skillchain dmg.', 'Skillchain Damage', 'Skillchain Bonus', '"Skillchain Bonus"'],
        'Magic Burst Damage': ['Magic burst dmg.', 'Magic burst damage', 'Magic Burst Damage', 'Magic Burst Bonus'],
        'Magic Burst Damage II': ['Magic burst damage II', 'Magic Burst Damage II'],
        'Magic Burst Accuracy': ['Magic burst accuracy', 'Magic Burst Accuracy', 'Magic Burst ACC'],
        'PDL': ['Physical damage limit', 'Physical Damage Limit'],
        'TP Bonus': ['TP Bonus', '"TP Bonus"'],
        'Kick Attacks': ['"Kick Attacks"', 'Kick Attacks'],
        'Martial Arts': ['"Martial Arts"', 'Martial Arts'],
        'Zanshin': ['"Zanshin"', 'Zanshin'],
        'Daken': ['"Daken"', 'Daken'],
        'True Shot': ['"True Shot"', 'True Shot'],
        'Recycle': ['"Recycle"', 'Recycle'],
        'Barrage': ['"Barrage"'],
        'Conserve TP': ['"Conserve TP"', 'Conserve TP'],
        'Occult Acumen': ['"Occult Acumen"', 'Occult Acumen'],
        'Blood Pact Damage': ['Blood Pact Dmg.', '"Blood Pact" damage', 'Blood Pact Damage'],
        'EnSpell Damage': ['Enspell Damage', 'EnSpell Damage'],
        'DA Damage%': ['"Double Attack" damage', 'Double Attack damage'],
        'TA Damage%': ['"Triple Attack" damage', 'Triple Attack damage'],
        'Dark Magic Skill': ['Dark magic skill', 'Dark Magic skill', 'Dark Magic Skill'],
        'Divine Magic Skill': ['Divine magic skill', 'Divine Magic skill', 'Divine Magic Skill'],
        'Elemental Magic Skill': ['Elem. magic skill', 'Elemental magic skill', 'Elemental Magic skill', 'Elemental Magic Skill'],
        'Ninjutsu Skill': ['Ninjutsu skill', 'Ninjutsu Skill'],
        'Hand-to-Hand Skill': ['Hand-to-Hand skill', 'Hand-to-Hand Skill'],
        'Dagger Skill': ['Dagger skill', 'Dagger Skill'],
        'Sword Skill': ['Sword skill', 'Sword Skill'],
        'Great Sword Skill': ['Great Sword skill', 'Great Sword Skill'],
        'Axe Skill': ['Axe skill', 'Axe Skill'],
        'Great Axe Skill': ['Great Axe skill', 'Great Axe Skill'],
        'Scythe Skill': ['Scythe skill', 'Scythe Skill'],
        'Polearm Skill': ['Polearm skill', 'Polearm Skill'],
        'Katana Skill': ['Katana skill', 'Katana Skill'],
        'Great Katana Skill': ['Great Katana skill', 'Great Katana Skill'],
        'Club Skill': ['Club skill', 'Club Skill'],
        'Staff Skill': ['Staff skill', 'Staff Skill'],
        'Archery Skill': ['Archery skill', 'Archery Skill'],
        'Marksmanship Skill': ['Marksmanship skill', 'Marksmanship Skill'],
        'Throwing Skill': ['Throwing skill', 'Throwing Skill'],
        // Not a stat key of the catalogue: kept as 'extra'.
        'Enmity': ['Enmity'],
        'Fast Cast': ['"Fast Cast"', 'Fast Cast'],
        'Refresh': ['"Refresh"', 'Refresh'],
        'Regen': ['"Regen"', 'Regen'],
        'Regain (latent)': ['Latent effect: "Regain"'],
        'Refresh (latent)': ['Latent effect: "Refresh"'],
        'Conserve MP': ['"Conserve MP"', 'Conserve MP'],
        'Counter': ['"Counter"', 'Counter'],
        'Snapshot': ['"Snapshot"', 'Snapshot'],
        'Rapid Shot': ['"Rapid Shot"', 'Rapid Shot'],
        'Treasure Hunter': ['"Treasure Hunter"', 'Treasure Hunter'],
        'Cure Potency': ['"Cure" potency', 'Cure Potency', 'Cure potency'],
        'Cure Potency Received': ['Potency of "Cure" effect received', 'Potency of "Cure" effects received', 'Pot. of "Cure" effect rec.'],
        'Cure Casting Time': ['"Cure" spellcasting time'],
        'Waltz Potency': ['"Waltz" potency'],
        'Phalanx': ['Phalanx'],
        'Phalanx Received': ['"Phalanx" received'],
        // Windower writes 'down -10%', BG Wiki 'down 10%', LSB stores 10: the size is what counts.
        'Spell Interruption Down': { labels: ['Spell interruption rate down', 'Spell Interruption Rate'], sign: 'abs' },
        'Status Resist': ['Occ. inc. resist. to stat. ailments', 'Occasionally Resist Status Ailments'],
        'Enemy Crit Rate': ['Enemy crit. hit rate'],
        'BDT': ['Breath dmg. taken'],
        'Magic Crit Rate': ['Magic crit. hit rate'],
        'Magic Crit Damage': ['Mag. crit. hit dmg.'],
        'Delay%': ['Delay:'],
        'Enhancing Duration': ['Enh. Mag. eff. dur.', 'Enhancing Magic duration', 'Enhancing magic effect duration'],
        'Enfeebling Duration': ['Enfeebling Magic duration', 'Enfeebling magic effect duration', 'Enf. Mag. eff. dur.'],
        'Enhancing Duration Received': ['Enh. Mag. received dur.', 'Enhancing Magic Received Duration'],
        'Block Rate': ['Chance of successful block', 'Shield Block Rate'],
        'Parrying Rate': ['Parrying rate'],
        'Save TP': ['Save TP'],
        'Song Casting Time': ['Song spellcasting time'],
        'Song Recast': ['Song recast delay'],
        'All Songs': ['All Songs', 'All songs'],
        'Avatar Perpetuation Cost': ['"Avatar perpetuation cost"', 'Avatar Perpetuation Cost'],
        'Drain Aspir Potency': ['"Drain" and "Aspir" potency'],
        'Regen Potency': ['"Regen" potency'],
        'Helix Duration': ['Helix eff. dur.', 'Helix eff. Duration', 'Helix effect duration'],
        'Indi Duration': ['Indi. eff. dur.'],
        'EnSpell Damage (sword)': ['Sword enhancement spell damage'],
        'Cap. Point%': ['Cap. Point'],
        'HP while healing': ['HP recovered while healing'],
        'MP while healing': ['MP recovered while healing'],
        'Healing Magic Skill': ['Healing magic skill', 'Healing Magic skill'],
        'Enhancing Magic Skill': ['Enha.mag. skill', 'Enha. mag. skill', 'Enhancing Magic skill', 'Enhancing magic skill'],
        'Enfeebling Magic Skill': ['Enfb.mag. skill', 'Enfb. mag. skill', 'Enf. mag. skill', 'Enfeebling Magic skill', 'Enfeebling magic skill'],
        'Summoning Magic Skill': ['Summoning magic skill'],
        'Blue Magic Skill': ['Blue Magic skill'],
        'Singing Skill': ['Singing skill'],
        'String Skill': ['String instrument skill'],
        'Wind Skill': ['Wind instrument skill'],
        'Geomancy Skill': ['Geomancy Skill'],
        'Handbell Skill': ['Handbell Skill'],
        'Shield Skill': ['Shield skill'],
        'Parrying Skill': ['Parrying skill'],
        'Automaton Melee Skill': ['Melee skill'],
        'Automaton Ranged Skill': ['Ranged skill'],
        'Automaton Magic Skill': ['Magic skill'],
        'Charm': ['"Charm"'], 'Slow': ['"Slow"'], 'Gilfinder': ['"Gilfinder"'],
        'Resist Bind': ['"Resist Bind"', 'Resist Bind'], 'Resist Blind': ['"Resist Blind"'],
        'Resist Charm': ['"Resist Charm"'], 'Resist Curse': ['"Resist Curse"'],
        'Resist Gravity': ['"Resist Gravity"'], 'Resist Paralyze': ['"Resist Paralyze"'],
        'Resist Petrify': ['"Resist Petrify"'], 'Resist Poison': ['"Resist Poison"'],
        'Resist Silence': ['"Resist Silence"', 'Resist Silence'], 'Resist Sleep': ['"Resist Sleep"'],
        'Resist Slow': ['"Resist Slow"'], 'Resist Stun': ['"Resist Stun"'], 'Resist Virus': ['"Resist Virus"'],
        'Shield Mastery': ['"Shield Mastery"'],
        'Ninja Tool Expertise': ['"Ninja tool expertise"'],
        'Blood Boon': ['"Blood Boon"'], 'Elemental Siphon': ['"Elemental Siphon"'], 'Embolden': ['"Embolden"'],
        'Repair Potency': ['"Repair" potency'], 'Waltz TP Cost': ['"Waltz" TP cost'],
        'Rev. Flourish': ['"Rev. Flourish"'],
        // Bundle effects (Odyssey, Dynamis-D, Unity...), same names as augments_effects.py.
        'Damage Dealt%': ['Damage dealt'],
        'Double Damage Chance': ['Chance of double damage'],
        'Double Ranged Damage Chance': ['Chance of double ranged damage'],
        'Follow-up Chance': ['Chance of follow-up attack'],
        'Ranged Follow-up Chance': ['Chance of ranged follow-up attack'],
        'Chakra': ['"Chakra"', 'Chakra'],
        'TP During Evasion': ['TP during evasion'],
        'Song Double Attack': ['Song effects: "Double Attack"', 'Song Effects: Double Attack'],
        'Phantom Roll Duration': ['"Phantom Roll" effect duration'],
        'Phantom Roll': ['"Phantom Roll"'],
        'Phantom Roll 11 Recover': ['"Phantom Roll 11": Recover HP & MP', '"Phantom Roll 11": Recover HP and MP',
            '"Phantom Roll XI": Recover HP and MP', '"Phantom Roll XI": Recover HP & MP'],
        'Flourish Recast': ['"Flourish" recast time'],
        'Step Duration': ['"Step" duration'],
        'Elemental WS Damage (path C)': ['Elemental weapon skill damage'],
        'Afflatus Misery': ['"Afflatus Misery" stored'],
        'Healing Recast': ['Healing magic recast time', 'Healing magic recast delay'],
        'Ninjutsu Recast': ['Ninjutsu recast time'],
        'Ninjutsu Casting Time': ['Ninjutsu casting time'],
        'Sekkanoki Recast': ['"Sekkanoki" recast time'],
        'Sekkanoki WSD': ['"Sekkanoki": Weapon skill damage', '"Sekkanoki": Wpn. Skill Dmg.'],
        'Chain Affinity Recast': ['"Chain Affinity" recast time'],
        'Burst Affinity Recast': ['"Burst Affinity" recast time'],
        'Mana Wall': ['"Mana Wall"'],
        'Blood Pact Double Status': ['Chance of doubling "Blood Pact" status'],
        'Ammo Damage%': ['Additional ammo damage'],
        'Ammo Accuracy': ['Additional ammo accuracy'],
        'Crit TP': ['TP gained when landing critical hits', 'TP gained when landing crit. hits'],
        'Regen Received': ['Potency of "Regen" effect received', 'Potency of "Regen" effects received',
            'Pot. of "Regen" effects received'],
        'Vivacious Pulse Potency': ['"Vivacious Pulse" potency'],
        'Drain Potency': ['"Drain" potency'],
        'Counter Damage%': ['"Counter" damage'],
        'Jump Damage%': ['All Jumps: Damage', 'All Jumps damage'],
        'Atonement Enmity': ['"Atonement" enmity', 'Atonement: Enmity'],
        'Dagan Potency': ['"Dagan" potency'],
        'Myrkr Potency': ['"Myrkr" potency'],
        'Luopan Duration': ['Luopan duration'],
        'Absorb Damage Taken': ['Absorbs damage taken', 'Absorbs DT', 'Absorbs Damage'],
        'Special Attack Damage%': ['Special attack damage', 'Special att. dmg.']
    };
    var ATTRS = ['STR', 'DEX', 'VIT', 'AGI', 'INT', 'MND', 'CHR'];
    var PREFIXES = { 'pet': 'Pet:', 'avatar': 'Avatar:', 'automaton': 'Automaton:', 'wyvern': 'Wyvern:', 'luopan': 'Luopan:' };

    function norm(label) {
        return String(label).toLowerCase().replace(/["'.\s]/g, '').replace(/:+$/, '');
    }

    var TABLE = {};
    Object.keys(LABELS).forEach(function (key) {
        var def = LABELS[key];
        var labels = Array.isArray(def) ? def : def.labels;
        var sign = Array.isArray(def) ? 1 : def.sign;   // 1, -1 or 'abs'
        labels.forEach(function (l) { TABLE[norm(l)] = { key: key, sign: sign }; });
    });

    // The catalogue's stat keys; filled from augments_ranked.js (FFXI.AUG_STAT_KEYS).
    function is_stat_key(key) {
        var keys = FFXI.AUG_STAT_KEYS;
        return !!(keys && keys[key]);
    }

    // One label (prefix already split off) -> [{key, sign}] or null.
    function lookup(label) {
        var l = String(label).trim().replace(/^\//, '').replace(/[\s,]+$/, '').trim();
        var hit = TABLE[norm(l)];
        if (hit) { return [hit]; }
        if (/^(All Attr\.?|All Attributes|All Base Stats)$/i.test(l)) {
            return ATTRS.map(function (k) { return { key: k, sign: 1 }; });
        }
        // 'STR DEX', 'INT MND CHR' (LSB / in-game attribute combos)
        var words = l.split(/\s+/);
        if (words.length > 1 && words.every(function (w) { return ATTRS.indexOf(w.toUpperCase()) >= 0; })) {
            return words.map(function (w) { return { key: w.toUpperCase(), sign: 1 }; });
        }
        // 'Savage Blade:DMG:', 'Final Heaven: DMG:', '"Blade: Shun" damage'
        var ws = /^(.+?):\s*(DMG|Damage):?$/i.exec(l) || /^"(.+)"\s+damage$/i.exec(l);
        if (ws) { return [{ key: 'WS Damage%:' + ws[1].replace(/"/g, '').trim(), sign: 1 }]; }
        // 'Acc/RngAcc/MagAcc', 'STR & DEX', 'Accuracy, Ranged Accuracy, & Magic Accuracy'
        var pieces = l.split(/\s*(?:\/|&|,)\s*|\s+and\s+/).filter(function (x) { return x; });
        if (pieces.length > 1) {
            var parts = pieces.map(lookup);
            if (parts.every(Boolean)) { return [].concat.apply([], parts); }
        }
        return null;
    }

    // 'Pet: Acc.' -> ['Pet:', 'Acc.']; no prefix -> [null, label].
    function split_prefix(label) {
        var m = /^\s*(Pet|Avatar|Automaton|Wyvern|Luopan)\s*:\s*(.*)$/i.exec(label);
        return m ? [PREFIXES[m[1].toLowerCase()], m[2]] : [null, label];
    }

    // 'label+N', 'label -N%', separated by spaces or commas. STRICT needs a sign
    // (in-game and Windower text always has one); LOOSE, tried when STRICT
    // fails, also takes 'Skillchain dmg. 8%' (BG Wiki) but would misread a
    // label holding a number ('"Phantom Roll 11": ...'), hence second.
    var STRICT = /[\s,]*(.+?)\s*([+-])\s*(\d+(?:\.\d+)?)\s*(%?)(?=[\s,]|$)/g;
    var LOOSE = /[\s,]*(.+?)\s*([+-]?)\s*(\d+(?:\.\d+)?)\s*(%?)(?=[\s,]|$)/g;

    function tokenize(str, re, prefix) {
        var pre = prefix || null, pos = 0, effects = [], m;
        re.lastIndex = 0;
        while ((m = re.exec(str)) !== null) {
            if (m.index !== pos) { return null; }
            pos = re.lastIndex;
            var sp = split_prefix(m[1]);
            if (sp[0]) { pre = sp[0]; }
            var hits = lookup(sp[1]);
            if (!hits) { return null; }
            var v = (m[2] === '-' ? -1 : 1) * parseFloat(m[3]);
            var pct = m[4] === '%';
            hits.forEach(function (h) {
                // 'Pet:DMG+11%' is a damage percentage, not weapon DMG
                var key = h.key === 'DMG' && pct ? 'Damage Dealt%' : h.key;
                var value = h.sign === 'abs' ? Math.abs(v) : h.sign * v;
                effects.push({ key: (pre || '') + key, value: value });
            });
        }
        return pos === str.length && effects.length ? effects : null;
    }

    // One string -> {effects: [{key, value}], path, rank, prefix, unknown}.
    // `prefix` is the prefix in force before this string ('Pet:' marker lines
    // carry over to the next strings of the same item, as in game).
    FFXI.parse_augment_string = function (s, prefix) {
        var out = { effects: [], path: null, rank: null, prefix: prefix || null, unknown: false };
        var str = String(s == null ? '' : s).trim();
        var m;
        if (!str || /^(none|-+)$/i.test(str)) { return out; }
        if ((m = /^Path\s*:\s*([A-D])$/i.exec(str))) { out.path = m[1].toUpperCase(); return out; }
        if ((m = /^Rank\s*:\s*(\d+)$/i.exec(str))) { out.rank = +m[1]; return out; }
        if ((m = /^(Pet|Avatar|Automaton|Wyvern|Luopan)\s*:\s*([+-]\d+)?$/i.exec(str))) {   // marker, Windower may append its value
            out.prefix = PREFIXES[m[1].toLowerCase()];
            return out;
        }
        var effects = tokenize(str, STRICT, prefix) || tokenize(str, LOOSE, prefix);
        if (!effects) { out.unknown = true; return out; }
        out.effects = effects;
        return out;
    };

    function add(target, key, value) {
        target[key] = (target[key] || 0) + value;
    }

    // An owned piece -> {stats (the catalogue's keys), extra (other keys), path, rank,
    // unknown: [strings], ranked: true when FFXI.RANKED supplied the stats}.
    // Odyssey/Dynamis-D/Unity/ultimate weapons: their stats come from the
    // path and rank (rankIfKnown, or the 'Rank: N' string, or the item's max
    // rank when neither is known: then `rank_assumed` is true).
    FFXI.parse_augments = function (itemName, augs, rankIfKnown) {
        var res = { stats: {}, extra: {}, path: null, rank: null, rank_assumed: false, ranked: false, unknown: [] };
        var prefix = null, read = 0;
        (augs || []).forEach(function (s) {
            var p = FFXI.parse_augment_string(s, prefix);
            if (p.path) { res.path = p.path; }
            if (p.rank != null) { res.rank = p.rank; }
            prefix = p.prefix;
            if (p.unknown) { res.unknown.push(s); return; }
            p.effects.forEach(function (e) {
                add(is_stat_key(e.key) ? res.stats : res.extra, e.key, e.value);
                read++;
            });
        });
        if (rankIfKnown != null) { res.rank = rankIfKnown; }
        var entry = FFXI.ranked_entry ? FFXI.ranked_entry(itemName) : null;
        // Ranked stats only when the strings carried none (Windower decodes these
        // items to 'Path: X' alone); never both, which would count them twice.
        if (entry && !read) {
            var path = res.path || (Object.keys(entry.paths).length === 1 ? Object.keys(entry.paths)[0] : null);
            if (path && entry.paths[path]) {
                res.path = path;
                if (res.rank == null) { res.rank = entry.max_rank; res.rank_assumed = true; }
                var st = FFXI.ranked_stats(itemName, path, res.rank);
                Object.keys(st).forEach(function (k) {
                    add(is_stat_key(k) ? res.stats : res.extra, k, st[k]);
                });
                res.ranked = true;
            }
        }
        return res;
    };
});
