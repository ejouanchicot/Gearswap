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
---   * every other command is sent exactly as BindManager sent it
---     (raw = true: '/recast' first, his 'sneak stpc' / 'invi stpc' aliases)
--- F9-F12 keys (f9, ^f11, !f11, ^!f11, ^f12) take over Mote-Include's own
--- binds of those keys, as BindManager did. Storm / caststorm are bound
--- whatever the subjob, as he had them.
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
    { key = "^~f8", command = "cyclestate AutoMedicine", desc = "Auto Medicine", state = "AutoMedicine" },
    { key = "^f3", command = "cyclestate EnfeebleTier", desc = "Enfeeble Tier", state = "EnfeebleTier" },
    { key = "^f11",  command = "cyclestate NukeMode",       desc = "Nuke Mode",       state = "NukeMode" },
    -- Spells (Shift+F to cycle)
    { key = "~f1",   command = "cyclestate GainSpell",      desc = "Gain-STAT",       state = "GainSpell" },
    { key = "~f2",   command = "cyclestate EnSpell",        desc = "Enspell",         state = "EnSpell" },
    { key = "~f5",   command = "cyclestate Barspell",       desc = "Barelement",      state = "Barspell" },
    { key = "~f6",   command = "cyclestate BarAilment",     desc = "Barailment",      state = "BarAilment" },
    { key = "~f7",   command = "cyclestate Spike",          desc = "Spikes",          state = "Spike" },
    { key = "~f8",   command = "cyclestate Storm",          desc = "Storms",          state = "Storm" },
    { key = "^!f11", command = "cyclestate NukeTier",       desc = "Nuke Tier",       state = "NukeTier" },
    { key = "^f5",   command = "cyclestate MainLightSpell", desc = "Main Light",      state = "MainLightSpell" },
    { key = "^f6",   command = "cyclestate SubLightSpell",  desc = "Sub Light",       state = "SubLightSpell" },
    { key = "^f7",   command = "cyclestate MainDarkSpell",  desc = "Main Dark",       state = "MainDarkSpell" },
    { key = "^f8",   command = "cyclestate SubDarkSpell",   desc = "Sub Dark",        state = "SubDarkSpell" },

    ---========================================================================
    --- HIS BINDMANAGER KEYS (jobs.main_jobs.RDM)
    ---========================================================================

    -- Sneak / Invisible
    { key = "!z", command = "sneak stpc", raw = true,     desc = "Sneak" },
    { key = "!x", command = "invi stpc", raw = true, desc = "Invisible" },

    -- Elemental nukes (state spell + NukeTier)
    { key = "~numpad7", command = "gs c castlight", raw = true,    desc = "Cast Main Light" },
    { key = "~numpad8", command = "gs c castdark", raw = true,     desc = "Cast Main Dark" },
    { key = "~numpad4", command = "gs c castsublight", raw = true, desc = "Cast Sub Light" },
    { key = "~numpad5", command = "gs c castsubdark", raw = true,  desc = "Cast Sub Dark" },

    -- Ctrl / Alt + F1-F8
    { key = "^f1", command = "input /recast \"Saboteur\"; input /ja \"Saboteur\" <me>", raw = true,    desc = "Saboteur" },
    { key = "^f2", command = "input /recast \"Spontaneity\"; input /ja \"Spontaneity\" <me>", raw = true, desc = "Spontaneity" },
    { key = "!f1", command = "input /recast \"Composure\"; input /ja \"Composure\" <me>", raw = true,   desc = "Composure" },
    { key = "!f2", command = "input /recast \"Protect V\"; input /ma \"Protect V\" <stpc>", raw = true, desc = "Protect V" },
    { key = "!f3", command = "input /recast \"Shell V\"; input /ma \"Shell V\" <stpc>", raw = true,   desc = "Shell V" },
    { key = "!f4", command = "input /recast \"Regen II\"; input /ma \"Regen II\" <stpc>", raw = true,  desc = "Regen II" },
    { key = "!f5", command = "gs c castbar", raw = true,                  desc = "Cast Barelement" },
    { key = "!f6", command = "gs c castbarailment", raw = true,           desc = "Cast Barailment" },
    { key = "!f7", command = "gs c castspike", raw = true,                desc = "Cast Spikes" },
    { key = "!f8", command = "gs c caststorm", raw = true,                desc = "Cast Storm" },

    -- Alt + number
    { key = "!1", command = "input /recast \"Haste II\"; input /ma \"Haste II\" <stpc>", raw = true,    desc = "Haste II" },
    { key = "!2", command = "input /recast \"Refresh III\"; input /ma \"Refresh III\" <stpc>", raw = true, desc = "Refresh III" },
    { key = "!3", command = "input /recast \"Phalanx II\"; input /ma \"Phalanx II\" <stpc>", raw = true,  desc = "Phalanx II" },
    { key = "!4", command = "input /ma \"Stoneskin\" <me>", raw = true,     desc = "Stoneskin" },
    { key = "!5", command = "input /ma \"Blink\" <me>", raw = true,         desc = "Blink" },
    { key = "!6", command = "input /ma \"Aquaveil\" <me>", raw = true,      desc = "Aquaveil" },

    -- Windows + number
    { key = "@1", command = "gs c castgain", raw = true,                   desc = "Cast Gain" },
    { key = "@2", command = "gs c castenspell", raw = true,                desc = "Cast Enspell" },
    { key = "@3", command = "input /ma \"Temper II\" <me>", raw = true,     desc = "Temper II" },
    { key = "@6", command = "input /recast \"Flurry II\"; input /ma \"Flurry II\" <stpc>", raw = true,   desc = "Flurry II" },

    -- Windows + letters (enfeebles)
    { key = "@q",  command = "input /recast \"Sleep\"; input /ma \"Sleep\" <stnpc>", raw = true,        desc = "Sleep" },
    { key = "^@q", command = "input /recast \"Sleepga\"; input /ma \"Sleepga\" <stnpc>", raw = true,      desc = "Sleepga" },
    { key = "@w",  command = "input /recast \"Sleep II\"; input /ma \"Sleep II\" <stnpc>", raw = true,     desc = "Sleep II" },
    { key = "^@w", command = "input /recast \"Sleepga II\"; input /ma \"Sleepga II\" <stnpc>", raw = true,   desc = "Sleepga II" },
    { key = "@e",  command = "input /recast \"Slow II\"; input /ma \"Slow II\" <stnpc>", raw = true,      desc = "Slow II" },
    { key = "@r",  command = "input /recast \"Paralyze II\"; input /ma \"Paralyze II\" <stnpc>", raw = true,  desc = "Paralyze II" },
    { key = "@t",  command = "input /recast \"Blind II\"; input /ma \"Blind II\" <stnpc>", raw = true,     desc = "Blind II" },
    { key = "@a",  command = "input /recast \"Addle II\"; input /ma \"Addle II\" <stnpc>", raw = true,     desc = "Addle II" },
    { key = "@s",  command = "input /recast \"Silence\"; input /ma \"Silence\" <stnpc>", raw = true,      desc = "Silence" },
    { key = "@d",  command = "input /recast \"Distract III\"; input /ma \"Distract III\" <stnpc>", raw = true, desc = "Distract III" },
    { key = "^@d", command = "input /recast \"Dia III\"; input /ma \"Dia III\" <stnpc>", raw = true,      desc = "Dia III" },
    { key = "@f",  command = "input /recast \"Frazzle III\"; input /ma \"Frazzle III\" <stnpc>", raw = true,  desc = "Frazzle III" },
    { key = "@z",  command = "input /recast \"Gravity II\"; input /ma \"Gravity II\" <stnpc>", raw = true,   desc = "Gravity II" },
    { key = "^@z", command = "input /recast \"Gravity\"; input /ma \"Gravity\" <stnpc>", raw = true,      desc = "Gravity" },
    { key = "@x",  command = "input /recast \"Dispel\"; input /ma \"Dispel\" <stnpc>", raw = true,       desc = "Dispel" },
    { key = "^@x", command = "input /recast \"Dispelga\"; input /ma \"Dispelga\" <stnpc>", raw = true,     desc = "Dispelga" },
    { key = "@c",  command = "input /recast \"Inundation\"; input /ma \"Inundation\" <stnpc>", raw = true,   desc = "Inundation" },
    { key = "@v",  command = "input /recast \"Break\"; input /ma \"Break\" <stnpc>", raw = true,        desc = "Break" },
    { key = "@b",  command = "input /recast \"Bind\"; input /ma \"Bind\" <stnpc>", raw = true,         desc = "Bind" },
}

return require('shared/utils/keybinds/keybind_manager').create('RDM', RDMKeybinds)
