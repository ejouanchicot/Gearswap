---============================================================================
--- RDM Keybinds - Gabvanstronger
---============================================================================
--- Gab's own RDM layout, not the template's numpad one: the state keys of
--- his old RDM_KEYBINDS.lua (the same keys BindManager bound, under
--- jobs.main_jobs.RDM) plus the rest of that BindManager section (spells,
--- abilities, enfeebles). Data only: KeybindManager binds, filters,
--- refreshes and unbinds them.
---
--- Converted from BindManager:
---   * 'gs c cycle <State>'  -> cyclestate <State> (the HUD shows the value)
---   * 'gs c <command>'      -> <command>
---   * 'input /ma ...'       -> /ma ... (sent with input)
---   * the 'input /recast "X";' sent first is dropped: a spell or ability
---     on recast is already reported by CooldownChecker
---   * 'sneak stpc' / 'invi stpc' were Shortcuts shorthands: the real
---     spells, Sneak and Invisible, are sent here
--- F9-F12 keys (f9, ^f11, !f11, ^!f11, ^f12) take over Mote-Include's own
--- binds of those keys, as BindManager did.
--- AutoMedicine is not here: it comes from config/COMMON_KEYBINDS.lua.
---
--- @file    config/rdm/RDM_KEYBINDS.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-25
---============================================================================

local RDMKeybinds = {}

-- Format: { key = "key", command = "gs_command", desc = "description", state = "state_name", subjob = "required_subjob" }
RDMKeybinds.binds = {
    ---========================================================================
    --- STATES (his old RDM_KEYBINDS order: sets the order within HUD sections)
    ---========================================================================

    -- Weapons
    { key = "^`",    command = "cyclestate MainWeapon",     desc = "Main Weapon",     state = "MainWeapon" },
    { key = "^~`",   command = "cyclestate SubWeapon",      desc = "Sub Weapon",      state = "SubWeapon" },
    { key = "~f9",   command = "cyclestate CombatMode",     desc = "Weapon Lock",     state = "CombatMode" },
    -- Modes
    { key = "^f12",  command = "cyclestate IdleMode",       desc = "Idle Mode",       state = "IdleMode" },
    { key = "f9",    command = "cyclestate EngagedMode",    desc = "Engaged Mode",    state = "EngagedMode" },
    { key = "!f11",  command = "cyclestate EnfeebleMode",   desc = "Enfeebling Mode", state = "EnfeebleMode" },
    { key = "^~f1",  command = "cyclestate SaboteurMode",   desc = "Auto Saboteur",   state = "SaboteurMode" },
    { key = "^f11",  command = "cyclestate NukeMode",       desc = "Nuke Mode",       state = "NukeMode" },
    -- Spells (Shift+F to cycle)
    { key = "~f1",   command = "cyclestate GainSpell",      desc = "Gain-STAT",       state = "GainSpell" },
    { key = "~f2",   command = "cyclestate EnSpell",        desc = "Enspell",         state = "EnSpell" },
    { key = "~f5",   command = "cyclestate Barspell",       desc = "Barelement",      state = "Barspell" },
    { key = "~f6",   command = "cyclestate BarAilment",     desc = "Barailment",      state = "BarAilment" },
    { key = "~f7",   command = "cyclestate Spike",          desc = "Spikes",          state = "Spike" },
    { key = "~f8",   command = "cyclestate Storm",          desc = "Storms",          state = "Storm",    subjob = "SCH" },
    { key = "^!f11", command = "cyclestate NukeTier",       desc = "Nuke Tier",       state = "NukeTier" },
    { key = "^f5",   command = "cyclestate MainLightSpell", desc = "Main Light",      state = "MainLightSpell" },
    { key = "^f6",   command = "cyclestate SubLightSpell",  desc = "Sub Light",       state = "SubLightSpell" },
    { key = "^f7",   command = "cyclestate MainDarkSpell",  desc = "Main Dark",       state = "MainDarkSpell" },
    { key = "^f8",   command = "cyclestate SubDarkSpell",   desc = "Sub Dark",        state = "SubDarkSpell" },

    ---========================================================================
    --- HIS BINDMANAGER KEYS (jobs.main_jobs.RDM)
    ---========================================================================

    -- Sneak / Invisible
    { key = "!z", command = [[/ma "Sneak" <stpc>]],     desc = "Sneak" },
    { key = "!x", command = [[/ma "Invisible" <stpc>]], desc = "Invisible" },

    -- Elemental nukes (state spell + NukeTier)
    { key = "~numpad7", command = "castlight",    desc = "Cast Main Light" },
    { key = "~numpad8", command = "castdark",     desc = "Cast Main Dark" },
    { key = "~numpad4", command = "castsublight", desc = "Cast Sub Light" },
    { key = "~numpad5", command = "castsubdark",  desc = "Cast Sub Dark" },

    -- Ctrl / Alt + F1-F8
    { key = "^f1", command = [[/ja "Saboteur" <me>]],    desc = "Saboteur" },
    { key = "^f2", command = [[/ja "Spontaneity" <me>]], desc = "Spontaneity" },
    { key = "!f1", command = [[/ja "Composure" <me>]],   desc = "Composure" },
    { key = "!f2", command = [[/ma "Protect V" <stpc>]], desc = "Protect V" },
    { key = "!f3", command = [[/ma "Shell V" <stpc>]],   desc = "Shell V" },
    { key = "!f4", command = [[/ma "Regen II" <stpc>]],  desc = "Regen II" },
    { key = "!f5", command = "castbar",                  desc = "Cast Barelement" },
    { key = "!f6", command = "castbarailment",           desc = "Cast Barailment" },
    { key = "!f7", command = "castspike",                desc = "Cast Spikes" },
    { key = "!f8", command = "caststorm",                desc = "Cast Storm",  subjob = "SCH" },

    -- Alt + number
    { key = "!1", command = [[/ma "Haste II" <stpc>]],    desc = "Haste II" },
    { key = "!2", command = [[/ma "Refresh III" <stpc>]], desc = "Refresh III" },
    { key = "!3", command = [[/ma "Phalanx II" <stpc>]],  desc = "Phalanx II" },
    { key = "!4", command = [[/ma "Stoneskin" <me>]],     desc = "Stoneskin" },
    { key = "!5", command = [[/ma "Blink" <me>]],         desc = "Blink" },
    { key = "!6", command = [[/ma "Aquaveil" <me>]],      desc = "Aquaveil" },

    -- Windows + number
    { key = "@1", command = "castgain",                   desc = "Cast Gain" },
    { key = "@2", command = "castenspell",                desc = "Cast Enspell" },
    { key = "@3", command = [[/ma "Temper II" <me>]],     desc = "Temper II" },
    { key = "@6", command = [[/ma "Flurry II" <stpc>]],   desc = "Flurry II" },

    -- Windows + letters (enfeebles)
    { key = "@q",  command = [[/ma "Sleep" <stnpc>]],        desc = "Sleep" },
    { key = "^@q", command = [[/ma "Sleepga" <stnpc>]],      desc = "Sleepga" },
    { key = "@w",  command = [[/ma "Sleep II" <stnpc>]],     desc = "Sleep II" },
    { key = "^@w", command = [[/ma "Sleepga II" <stnpc>]],   desc = "Sleepga II" },
    { key = "@e",  command = [[/ma "Slow II" <stnpc>]],      desc = "Slow II" },
    { key = "@r",  command = [[/ma "Paralyze II" <stnpc>]],  desc = "Paralyze II" },
    { key = "@t",  command = [[/ma "Blind II" <stnpc>]],     desc = "Blind II" },
    { key = "@a",  command = [[/ma "Addle II" <stnpc>]],     desc = "Addle II" },
    { key = "@s",  command = [[/ma "Silence" <stnpc>]],      desc = "Silence" },
    { key = "@d",  command = [[/ma "Distract III" <stnpc>]], desc = "Distract III" },
    { key = "^@d", command = [[/ma "Dia III" <stnpc>]],      desc = "Dia III" },
    { key = "@f",  command = [[/ma "Frazzle III" <stnpc>]],  desc = "Frazzle III" },
    { key = "@z",  command = [[/ma "Gravity II" <stnpc>]],   desc = "Gravity II" },
    { key = "^@z", command = [[/ma "Gravity" <stnpc>]],      desc = "Gravity" },
    { key = "@x",  command = [[/ma "Dispel" <stnpc>]],       desc = "Dispel" },
    { key = "^@x", command = [[/ma "Dispelga" <stnpc>]],     desc = "Dispelga" },
    { key = "@c",  command = [[/ma "Inundation" <stnpc>]],   desc = "Inundation" },
    { key = "@v",  command = [[/ma "Break" <stnpc>]],        desc = "Break" },
    { key = "@b",  command = [[/ma "Bind" <stnpc>]],         desc = "Bind" },
}

return require('shared/utils/keybinds/keybind_manager').create('RDM', RDMKeybinds)
