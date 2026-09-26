---============================================================================
--- Common Keybinds - Gabvanstronger
---============================================================================
--- Every key of his BindManager (data/binds.lua, data/alt-binds.lua) that is
--- not tied to one main job, converted: the job files hold the main-job keys.
--- Same entry format as a job's config/<job>/<JOB>_KEYBINDS.lua.
---
--- Order follows BindManager's priority, lowest first: startup, login.all,
--- login.characters, sub_jobs, alt-binds. Several entries may share a key
--- (one per subjob, per partner job or weapon): the last one that applies
--- wins. A key the job file uses stays the job's.
---
--- raw = true sends the command exactly as BindManager did (his Windower
--- aliases: blody, gab, sa, they, sneak, invi, curaga3...). Not carried over:
--- F9-F12 (Mote-Include binds the same commands itself), ~F9 (Combat Mode,
--- config/combat_mode.lua), numpad0 `gs c info` (the HUD shows the modes),
--- ^scrolllock `bindmanager apply`, Thyrsa and Sephiroph (his answer).
---
--- Keys: ^ = Ctrl, ! = Alt, @ = Win, # = Apps, ~ = Shift.
---
--- @file config/COMMON_KEYBINDS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-09-26
---============================================================================

local CommonKeybinds = {}

--- Row only for jobs that have this state (weapon keys of login.all).
local function has(name)
    return function() return state ~= nil and state[name] ~= nil end
end

CommonKeybinds.binds = {
    { key = "#numpad0", command = "cyclestate AutoMedicine", desc = "Auto Medicine", state = "AutoMedicine" },
    { key = "!numpad7", command = "alts follow", desc = "Alts: follow me (toggle)" },
    { key = "!numpad8", command = "alts toggle", desc = "Alts: automation on/off" },
    { key = "!numpad9", command = "alts mirror", desc = "Alts: mirror" },

    -- BindManager startup (every character, console commands)
    { key = "!d", command = "type //curr all ", raw = true, desc = "type //curr all " },
    { key = "!f", command = "type //findall ", raw = true, desc = "type //findall " },
    { key = "!s", command = "type //statsearch ", raw = true, desc = "type //statsearch " },
    { key = "^d", command = "type //curr ", raw = true, desc = "type //curr " },
    { key = "^f", command = "type //find ", raw = true, desc = "type //find " },
    { key = "^g", command = "type //get \"", raw = true, desc = "type //get \"" },
    { key = "^h", command = "type //put \"", raw = true, desc = "type //put \"" },
    { key = "numpad*", command = "lua unload fastcs", raw = true, desc = "lua unload fastcs" },
    { key = "numpad/", command = "lua load fastcs", raw = true, desc = "lua load fastcs" },
    { key = "pause", command = "aio config", raw = true, desc = "aio config" },
    { key = "~pause", command = "aio edit", raw = true, desc = "aio edit" },

    -- BindManager login.all: weapon choices (F9-F12 are Mote's own binds, ~F9 is Combat Mode)
    { key = "^`",  command = "cyclestate MainWeapon",  desc = "Main Weapon",  state = "MainWeapon",  visible = has("MainWeapon") },
    { key = "^~`", command = "cyclestate SubWeapon",   desc = "Sub Weapon",   state = "SubWeapon",   visible = has("SubWeapon") },
    { key = "@`",  command = "cyclestate RangeWeapon", desc = "Range Weapon", state = "RangeWeapon", visible = has("RangeWeapon") },

    -- BindManager login.characters.Gabvanstronger (a job key on the same key wins)
    { key = "!e", command = "input /item 'Holy Water' <me>", raw = true, desc = "/item 'Holy Water' <me>" },
    { key = "!q", command = "input /item 'Panacea' <me>", raw = true, desc = "/item 'Panacea' <me>" },
    { key = "!w", command = "input /item 'Remedy' <me>", raw = true, desc = "/item 'Remedy' <me>" },
    { key = "!x", command = "input /item 'Prism Powder' <me>", raw = true, desc = "/item 'Prism Powder' <me>" },
    { key = "!z", command = "input /item 'Silent Oil' <me>", raw = true, desc = "/item 'Silent Oil' <me>" },

    -- BindManager sub_jobs.BLM
    { key = "!`", command = "input /ma Stun <t>", raw = true, desc = "/BLM /ma Stun <t>", subjob = "BLM" },
    { key = "^1", command = "input /recast \"Sleepga\"; input /ma \"Sleepga\" <stnpc>", raw = true, desc = "/BLM /recast \"Sleepga\"; input /ma \"Sleepga\" <", subjob = "BLM" },
    { key = "^2", command = "input /ja \"Elemental Seal\" <me>", raw = true, desc = "/BLM /ja \"Elemental Seal\" <me>", subjob = "BLM" },

    -- BindManager sub_jobs.BRD
    { key = "^1", command = "input /ma \"Raptor Mazurka\" <me>", raw = true, desc = "/BRD /ma \"Raptor Mazurka\" <me>", subjob = "BRD" },
    { key = "^2", command = "input /ma \"Advancing March\" <me>", raw = true, desc = "/BRD /ma \"Advancing March\" <me>", subjob = "BRD" },
    { key = "^3", command = "input /ma \"Sword Madrigal\" <me>", raw = true, desc = "/BRD /ma \"Sword Madrigal\" <me>", subjob = "BRD" },
    { key = "^4", command = "input /ma \"Valor Minuet\" <me>", raw = true, desc = "/BRD /ma \"Valor Minuet\" <me>", subjob = "BRD" },

    -- BindManager sub_jobs.DNC
    { key = "!z", command = "input /ja \"Spectral Jig\" <me>", raw = true, desc = "/DNC /ja \"Spectral Jig\" <me>", subjob = "DNC" },
    { key = "#numpad4", command = "input /recast \"Healing Waltz\"; healing waltz <stpc>", raw = true, desc = "/DNC /recast \"Healing Waltz\"; healing waltz <", subjob = "DNC" },
    { key = "#numpad7", command = "input /recast \"Divine Waltz\"; divine waltz <stpc>", raw = true, desc = "/DNC /recast \"Divine Waltz\"; divine waltz <st", subjob = "DNC" },
    { key = "^1", command = "input /ja \"Haste Samba\" <me>", raw = true, desc = "/DNC /ja \"Haste Samba\" <me>", subjob = "DNC" },
    { key = "^2", command = "input /ja \"Box Step\" <stnpc>", raw = true, desc = "/DNC /ja \"Box Step\" <stnpc>", subjob = "DNC" },
    { key = "^3", command = "input /ja \"Curing Waltz III\" <stpc>", raw = true, desc = "/DNC /ja \"Curing Waltz III\" <stpc>", subjob = "DNC" },
    { key = "^4", command = "input /ja \"Reverse Flourish\" <me>", raw = true, desc = "/DNC /ja \"Reverse Flourish\" <me>", subjob = "DNC" },
    { key = "^5", command = "input /ja \"Spectral Jig\" <me>", raw = true, desc = "/DNC /ja \"Spectral Jig\" <me>", subjob = "DNC" },

    -- BindManager sub_jobs.DRG
    { key = "^1", command = "/jump; /high jump", raw = true, desc = "/DRG /jump; /high jump", subjob = "DRG" },
    { key = "^2", command = "/super jump", raw = true, desc = "/DRG /super jump", subjob = "DRG" },
    { key = "^3", command = "/Ancient Circle", raw = true, desc = "/DRG /Ancient Circle", subjob = "DRG" },

    -- BindManager sub_jobs.DRK
    { key = "!`", command = "input /recast \"Stun\"; input /ma Stun <t>", raw = true, desc = "/DRK /recast \"Stun\"; input /ma Stun <t>", subjob = "DRK" },
    { key = "^1", command = "/Last Resort", raw = true, desc = "/DRK /Last Resort", subjob = "DRK" },
    { key = "^2", command = "input /recast \"Absorb-TP\"; input /ma \"Absorb-TP\" <me>", raw = true, desc = "/DRK /recast \"Absorb-TP\"; input /ma \"Absorb-T", subjob = "DRK" },
    { key = "^3", command = "input /recast \"Absorb-VIT\"; input /ma \"Absorb-VIT\" <me>", raw = true, desc = "/DRK /recast \"Absorb-VIT\"; input /ma \"Absorb-", subjob = "DRK" },
    { key = "^6", command = "/Souleater", raw = true, desc = "/DRK /Souleater", subjob = "DRK" },

    -- BindManager sub_jobs.NIN
    { key = "!x", command = "input /item 'Tonki: Ni' <me>", raw = true, desc = "/NIN /item 'Tonki: Ni' <me>", subjob = "NIN" },
    { key = "!z", command = "input /ma 'Monomi: Ichi' <me>", raw = true, desc = "/NIN /ma 'Monomi: Ichi' <me>", subjob = "NIN" },
    { key = "^1", command = "input /ma \"Utsusemi: Ichi\" <me>", raw = true, desc = "/NIN /ma \"Utsusemi: Ichi\" <me>", subjob = "NIN" },
    { key = "^2", command = "input /ma \"Utsusemi: Ni\" <me>", raw = true, desc = "/NIN /ma \"Utsusemi: Ni\" <me>", subjob = "NIN" },

    -- BindManager sub_jobs.PLD
    { key = "^1", command = "input /ma \"Cure 3\" <stpc>", raw = true, desc = "/PLD /ma \"Cure 3\" <stpc>", subjob = "PLD" },
    { key = "^2", command = "input /ma \"Flash\" <stpc>", raw = true, desc = "/PLD /ma \"Flash\" <stpc>", subjob = "PLD" },
    { key = "^3", command = "input /ja \"Sentinel\" <me>", raw = true, desc = "/PLD /ja \"Sentinel\" <me>", subjob = "PLD" },

    -- BindManager sub_jobs.RDM
    { key = "!x", command = "invi stpc", raw = true, desc = "/RDM invi stpc", subjob = "RDM" },
    { key = "!z", command = "sneak stpc", raw = true, desc = "/RDM sneak stpc", subjob = "RDM" },
    { key = "^1", command = "input /recast \"Haste\"; input /ma \"Haste\" <stpc>", raw = true, desc = "/RDM /recast \"Haste\"; input /ma \"Haste\" <stpc", subjob = "RDM" },
    { key = "^2", command = "input /recast \"Refresh\"; input /ma \"Refresh\" <stpc>", raw = true, desc = "/RDM /recast \"Refresh\"; input /ma \"Refresh\" <", subjob = "RDM" },
    { key = "^3", command = "input /recast \"Phalanx\"; input /ma \"Phalanx\" <me>", raw = true, desc = "/RDM /recast \"Phalanx\"; input /ma \"Phalanx\" <", subjob = "RDM" },
    { key = "^4", command = "input /recast \"Stoneskin\"; input /ma \"Stoneskin\" <me>", raw = true, desc = "/RDM /recast \"Stoneskin\"; input /ma \"Stoneski", subjob = "RDM" },
    { key = "^5", command = "input /recast \"Blink\"; input /ma \"Blink\" <me>", raw = true, desc = "/RDM /recast \"Blink\"; input /ma \"Blink\" <me>", subjob = "RDM" },
    { key = "^6", command = "input /recast \"Aquaveil\"; input /ma \"Aquaveil\" <me>", raw = true, desc = "/RDM /recast \"Aquaveil\"; input /ma \"Aquaveil\"", subjob = "RDM" },

    -- BindManager sub_jobs.SAM
    { key = "^1", command = "input /ja \"Meditate\" <me>", raw = true, desc = "/SAM /ja \"Meditate\" <me>", subjob = "SAM" },
    { key = "^2", command = "input /ja \"Hasso\" <me>", raw = true, desc = "/SAM /ja \"Hasso\" <me>", subjob = "SAM" },
    { key = "^3", command = "input /ja \"Seigan\" <me>", raw = true, desc = "/SAM /ja \"Seigan\" <me>", subjob = "SAM" },
    { key = "^4", command = "input /ja \"Third Eye\" <me>", raw = true, desc = "/SAM /ja \"Third Eye\" <me>", subjob = "SAM" },
    { key = "^5", command = "input /ja \"Sekkanoki\" <me>", raw = true, desc = "/SAM /ja \"Sekkanoki\" <me>", subjob = "SAM" },
    { key = "^6", command = "input /ja \"Warding Circle\" <me>", raw = true, desc = "/SAM /ja \"Warding Circle\" <me>", subjob = "SAM" },

    -- BindManager sub_jobs.SCH
    { key = "!x", command = "invi stpc", raw = true, desc = "/SCH invi stpc", subjob = "SCH" },
    { key = "!z", command = "sneak stpc", raw = true, desc = "/SCH sneak stpc", subjob = "SCH" },
    { key = "#numpad1", command = "input /recast \"Erase\"; erase <stpc>", raw = true, desc = "/SCH /recast \"Erase\"; erase <stpc>", subjob = "SCH" },
    { key = "#numpad2", command = "input /recast \"Paralyna\"; paralyna <stpc>", raw = true, desc = "/SCH /recast \"Paralyna\"; paralyna <stpc>", subjob = "SCH" },
    { key = "#numpad3", command = "input /recast \"Silena\"; silena <stpc>", raw = true, desc = "/SCH /recast \"Silena\"; silena <stpc>", subjob = "SCH" },
    { key = "#numpad4", command = "input /recast \"Stona\"; stona <stpc>", raw = true, desc = "/SCH /recast \"Stona\"; stona <stpc>", subjob = "SCH" },
    { key = "#numpad5", command = "input /recast \"Cursna\"; cursna <stpc>", raw = true, desc = "/SCH /recast \"Cursna\"; cursna <stpc>", subjob = "SCH" },
    { key = "#numpad6", command = "input /recast \"Poisona\"; poisona <stpc>", raw = true, desc = "/SCH /recast \"Poisona\"; poisona <stpc>", subjob = "SCH" },
    { key = "#numpad7", command = "input /recast \"Cure IV\"; cure4 <stpc>", raw = true, desc = "/SCH /recast \"Cure IV\"; cure4 <stpc>", subjob = "SCH" },
    { key = "#numpad8", command = "input /recast \"Blindna\"; blindna <stpc>", raw = true, desc = "/SCH /recast \"Blindna\"; blindna <stpc>", subjob = "SCH" },
    { key = "#numpad9", command = "input /recast \"Viruna\"; viruna <stpc>", raw = true, desc = "/SCH /recast \"Viruna\"; viruna <stpc>", subjob = "SCH" },
    { key = "^1", command = "gs c scholar cost", raw = true, desc = "/SCH gs c scholar cost", subjob = "SCH" },
    { key = "^2", command = "gs c scholar speed", raw = true, desc = "/SCH gs c scholar speed", subjob = "SCH" },
    { key = "^3", command = "gs c scholar aoe", raw = true, desc = "/SCH gs c scholar aoe", subjob = "SCH" },
    { key = "^4", command = "gs c scholar light", raw = true, desc = "/SCH gs c scholar light", subjob = "SCH" },
    { key = "^5", command = "gs c scholar dark", raw = true, desc = "/SCH gs c scholar dark", subjob = "SCH" },

    -- BindManager sub_jobs.THF
    { key = "^1", command = "/sneak attack", raw = true, desc = "/THF /sneak attack", subjob = "THF" },
    { key = "^2", command = "/trick attack", raw = true, desc = "/THF /trick attack", subjob = "THF" },
    { key = "^3", command = "/steal; /mug;", raw = true, desc = "/THF /steal; /mug;", subjob = "THF" },
    { key = "^4", command = "/hide", raw = true, desc = "/THF /hide", subjob = "THF" },
    { key = "^5", command = "/flee", raw = true, desc = "/THF /flee", subjob = "THF" },

    -- BindManager sub_jobs.WAR
    { key = "^1", command = "input /ja \"Provoke\" <stnpc>", raw = true, desc = "/WAR /ja \"Provoke\" <stnpc>", subjob = "WAR" },
    { key = "^2", command = "input /ja \"Berserk\" <me>", raw = true, desc = "/WAR /ja \"Berserk\" <me>", subjob = "WAR" },
    { key = "^3", command = "input /ja \"Aggressor\" <me>", raw = true, desc = "/WAR /ja \"Aggressor\" <me>", subjob = "WAR" },
    { key = "^4", command = "input /ja \"Warcry\" <me>", raw = true, desc = "/WAR /ja \"Warcry\" <me>", subjob = "WAR" },
    { key = "^5", command = "input /ja \"Defender\" <me>", raw = true, desc = "/WAR /ja \"Defender\" <me>", subjob = "WAR" },

    -- BindManager sub_jobs.WHM
    { key = "!x", command = "invi stpc", raw = true, desc = "/WHM invi stpc", subjob = "WHM" },
    { key = "!z", command = "sneak stpc", raw = true, desc = "/WHM sneak stpc", subjob = "WHM" },
    { key = "#numpad1", command = "input /recast \"Erase\"; erase <stpc>", raw = true, desc = "/WHM /recast \"Erase\"; erase <stpc>", subjob = "WHM" },
    { key = "#numpad2", command = "input /recast \"Paralyna\"; paralyna <stpc>", raw = true, desc = "/WHM /recast \"Paralyna\"; paralyna <stpc>", subjob = "WHM" },
    { key = "#numpad3", command = "input /recast \"Silena\"; silena <stpc>", raw = true, desc = "/WHM /recast \"Silena\"; silena <stpc>", subjob = "WHM" },
    { key = "#numpad4", command = "input /recast \"Stona\"; stona <stpc>", raw = true, desc = "/WHM /recast \"Stona\"; stona <stpc>", subjob = "WHM" },
    { key = "#numpad5", command = "input /recast \"Cursna\"; cursna <stpc>", raw = true, desc = "/WHM /recast \"Cursna\"; cursna <stpc>", subjob = "WHM" },
    { key = "#numpad6", command = "input /recast \"Poisona\"; poisona <stpc>", raw = true, desc = "/WHM /recast \"Poisona\"; poisona <stpc>", subjob = "WHM" },
    { key = "#numpad7", command = "input /recast \"Curaga III\"; curaga3 <stpc>", raw = true, desc = "/WHM /recast \"Curaga III\"; curaga3 <stpc>", subjob = "WHM" },
    { key = "#numpad8", command = "input /recast \"Blindna\"; blindna <stpc>", raw = true, desc = "/WHM /recast \"Blindna\"; blindna <stpc>", subjob = "WHM" },
    { key = "#numpad9", command = "input /recast \"Viruna\"; viruna <stpc>", raw = true, desc = "/WHM /recast \"Viruna\"; viruna <stpc>", subjob = "WHM" },
    { key = "^1", command = "input /ma \"Paralyna\" <stpc>", raw = true, desc = "/WHM /ma \"Paralyna\" <stpc>", subjob = "WHM" },
    { key = "^2", command = "input /ma \"Silena\" <stpc>", raw = true, desc = "/WHM /ma \"Silena\" <stpc>", subjob = "WHM" },
    { key = "^3", command = "input /ma \"Stona\" <stpc>", raw = true, desc = "/WHM /ma \"Stona\" <stpc>", subjob = "WHM" },
    { key = "^4", command = "input /ma \"Haste\" <stpc>", raw = true, desc = "/WHM /ma \"Haste\" <stpc>", subjob = "WHM" },
    { key = "^5", command = "input /ma \"Flash\" <Stnpc>", raw = true, desc = "/WHM /ma \"Flash\" <Stnpc>", subjob = "WHM" },

    -- BindManager alt-binds.Gabvanstronger.all (whatever the partner plays)
    { key = "@f1", command = "sa sm follow gabvanstronger", raw = true, desc = "sa sm follow gabvanstronger" },
    { key = "@f2", command = "they sm toggle", raw = true, desc = "they sm toggle" },
    { key = "@f3", command = "sm mirror", raw = true, desc = "sm mirror" },
    { key = "@home", command = "sa warp", raw = true, desc = "sa warp" },

    -- alt-binds: Blodykiller, any job
    { key = "^numpad*", command = "sm follow off; blody sm follow off", raw = true, desc = "Blodykiller: sm follow off; blody sm follow off", alt = {name = "Blodykiller"} },
    { key = "^numpad+", command = "Blody /attackoff", raw = true, desc = "Blodykiller: Blody /attackoff", alt = {name = "Blodykiller"} },
    { key = "^numpad-", command = "sat youattack Blodykiller", raw = true, desc = "Blodykiller: sat youattack Blodykiller", alt = {name = "Blodykiller"} },
    { key = "^numpad/", command = "gab sm follow gabvanstronger; blody sm follow Gabvanstronger", raw = true, desc = "Blodykiller: gab sm follow gabvanstronger; blody sm f", alt = {name = "Blodykiller"} },

    -- alt-binds: Blodykiller with subjob DNC
    { key = "!x", command = "invi gab; blody spectral jig", raw = true, desc = "Blodykiller /DNC: invi gab; blody spectral jig", alt = {name = "Blodykiller", subjob = "DNC"} },
    { key = "!z", command = "sneak gab", raw = true, desc = "Blodykiller /DNC: sneak gab", alt = {name = "Blodykiller", subjob = "DNC"} },
    { key = "^numpad1", command = "blody curingwaltz3 gab", raw = true, desc = "Blodykiller /DNC: blody curingwaltz3 gab", alt = {name = "Blodykiller", subjob = "DNC"} },

    -- alt-binds: Blodykiller with subjob DRK
    { key = "!x", command = "invi gab; blody input /item 'Prism Powder' <me>", raw = true, desc = "Blodykiller /DRK: invi gab; blody input /item 'Prism Powde", alt = {name = "Blodykiller", subjob = "DRK"} },
    { key = "!z", command = "sneak gab; blody input /item 'Silent Oil' <me>", raw = true, desc = "Blodykiller /DRK: sneak gab; blody input /item 'Silent Oil", alt = {name = "Blodykiller", subjob = "DRK"} },
    { key = "^numpad1", command = "blody curaga3 gab", raw = true, desc = "Blodykiller /DRK: blody curaga3 gab", alt = {name = "Blodykiller", subjob = "DRK"} },

    -- alt-binds: Blodykiller with subjob WHM
    { key = "!x", command = "invi gab; blody invi blody", raw = true, desc = "Blodykiller /WHM: invi gab; blody invi blody", alt = {name = "Blodykiller", subjob = "WHM"} },
    { key = "!z", command = "sneak gab; blody sneak blody", raw = true, desc = "Blodykiller /WHM: sneak gab; blody sneak blody", alt = {name = "Blodykiller", subjob = "WHM"} },
    { key = "^numpad1", command = "blody curaga3 gab", raw = true, desc = "Blodykiller /WHM: blody curaga3 gab", alt = {name = "Blodykiller", subjob = "WHM"} },

    -- alt-binds: Blodykiller on BRD with a Club
    { key = "^numpadenter", command = "blody /true strike", raw = true, desc = "Blodykiller BRD: blody /true strike", alt = {name = "Blodykiller", job = "BRD", weapon = "Club"} },

    -- alt-binds: Blodykiller on BRD with a Dagger
    { key = "^numpadenter", command = "blody /mordant rime", raw = true, desc = "Blodykiller BRD: blody /mordant rime", alt = {name = "Blodykiller", job = "BRD", weapon = "Dagger"} },

    -- alt-binds: Blodykiller on BRD with a Sword
    { key = "^numpadenter", command = "blody /savage blade", raw = true, desc = "Blodykiller BRD: blody /savage blade", alt = {name = "Blodykiller", job = "BRD", weapon = "Sword"} },

    -- alt-binds: Blodykiller on BRD
    { key = "^numpad0", command = "blody /chocobo mazurka", raw = true, desc = "Blodykiller BRD: blody /chocobo mazurka", alt = {name = "Blodykiller", job = "BRD"} },
    { key = "^numpad2", command = "sat youcommand Blodykiller \"Dark Threnody II\"", raw = true, desc = "Blodykiller BRD: sat youcommand Blodykiller \"Dark Threnod", alt = {name = "Blodykiller", job = "BRD"} },
    { key = "^numpad4", command = "sat youcommand Blodykiller \"Carnage Elegy\"", raw = true, desc = "Blodykiller BRD: sat youcommand Blodykiller \"Carnage Eleg", alt = {name = "Blodykiller", job = "BRD"} },
    { key = "^numpad5", command = "sat youcommand Blodykiller MagicFinale", raw = true, desc = "Blodykiller BRD: sat youcommand Blodykiller MagicFinale", alt = {name = "Blodykiller", job = "BRD"} },
    { key = "^numpad7", command = "sat youcommand Blodykiller \"Horde Lullaby II\"; wait .2; sat youcommand Blodykiller \"Horde Lullaby\"", raw = true, desc = "Blodykiller BRD: sat youcommand Blodykiller \"Horde Lullab", alt = {name = "Blodykiller", job = "BRD"} },
    { key = "^numpad8", command = "sat youcommand Blodykiller \"Foe Lullaby II\"; wait .2; sat youcommand Blodykiller \"Foe Lullaby\"", raw = true, desc = "Blodykiller BRD: sat youcommand Blodykiller \"Foe Lullaby ", alt = {name = "Blodykiller", job = "BRD"} },
    { key = "^numpad9", command = "blody gs c buffs", raw = true, desc = "Blodykiller BRD: blody gs c buffs", alt = {name = "Blodykiller", job = "BRD"} },

    -- alt-binds: Blodykiller on COR with a Sword
    { key = "^numpadenter", command = "blody /savage blade", raw = true, desc = "Blodykiller COR: blody /savage blade", alt = {name = "Blodykiller", job = "COR", weapon = "Sword"} },

    -- alt-binds: Blodykiller on COR
    { key = "^numpad0", command = "blody /boltersroll", raw = true, desc = "Blodykiller COR: blody /boltersroll", alt = {name = "Blodykiller", job = "COR"} },
    { key = "^numpad1", command = "blody /tacticians roll", raw = true, desc = "Blodykiller COR: blody /tacticians roll", alt = {name = "Blodykiller", job = "COR"} },
    { key = "^numpad2", command = "blody /darkshot <tid>", raw = true, desc = "Blodykiller COR: blody /darkshot <tid>", alt = {name = "Blodykiller", job = "COR"} },
    { key = "^numpad3", command = "blody /random deal", raw = true, desc = "Blodykiller COR: blody /random deal", alt = {name = "Blodykiller", job = "COR"} },
    { key = "^numpad4", command = "blody /warlocks roll", raw = true, desc = "Blodykiller COR: blody /warlocks roll", alt = {name = "Blodykiller", job = "COR"} },
    { key = "^numpad5", command = "blody /wizards roll", raw = true, desc = "Blodykiller COR: blody /wizards roll", alt = {name = "Blodykiller", job = "COR"} },
    { key = "^numpad6", command = "blody /snakeeye", raw = true, desc = "Blodykiller COR: blody /snakeeye", alt = {name = "Blodykiller", job = "COR"} },
    { key = "^numpad7", command = "blody /samurai roll", raw = true, desc = "Blodykiller COR: blody /samurai roll", alt = {name = "Blodykiller", job = "COR"} },
    { key = "^numpad8", command = "blody /chaos roll", raw = true, desc = "Blodykiller COR: blody /chaos roll", alt = {name = "Blodykiller", job = "COR"} },
    { key = "^numpad9", command = "blody /croockedcard", raw = true, desc = "Blodykiller COR: blody /croockedcard", alt = {name = "Blodykiller", job = "COR"} },
}

return CommonKeybinds
