---============================================================================
--- BLU Keybinds - Gabvanstronger
---============================================================================
--- His BindManager BLU keys (data/binds.lua, jobs.main_jobs.all.BLU), sent
--- exactly as BindManager did (raw = true), plus the state rows.
---
--- From his setup:
---   * 18 keys: !` Temporal Shift, !1-!6 buffs, @q @w @a @f @x @v spells,
---     @1-@5 job abilities (commands as he wrote them)
---   * his weapon layers BLU.Sword / BLU.Club: numpad1/3/7/9 weaponskills,
---     only while HIS main hand is a sword / a club (weapon field,
---     keybind_manager.lua), refreshed when the main hand changes type
---   * ^` / ^~`  WeaponSet / SubSet (BindManager login.all) -> MainWeapon /
---     SubWeapon
---   * f9 OffenseMode, @f9 WeaponskillMode, ^f11 CastingMode, ^f12 IdleMode:
---     Mote's keys, bound here to show in the HUD
--- His subjob keys (!` Stun on /BLM and /DRK...) are in his common keys
--- (config/COMMON_KEYBINDS.lua, override = true): they win over the job key
--- under that subjob, as in BindManager. ~f9 (his WeaponLock) is Combat Mode
--- (config/combat_mode.lua). His RangedSet key @` is in BLU_CUSTOM.lua.
---
--- @file    config/blu/BLU_KEYBINDS.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-26 (Gabvanstronger)
---============================================================================

local BLUKeybinds = {}

BLUKeybinds.binds = {
    -- Weapons (BindManager login.all)
    { key = "^`",  command = "cyclestate MainWeapon",      desc = "Main Weapon",  state = "MainWeapon" },
    { key = "^~`", command = "cyclestate SubWeapon",       desc = "Sub Weapon",   state = "SubWeapon" },

    -- Modes (Mote's keys)
    { key = "f9",   command = "cyclestate OffenseMode",     desc = "Offense Mode", state = "OffenseMode" },
    { key = "@f9",  command = "cyclestate WeaponskillMode", desc = "WS Mode",      state = "WeaponskillMode" },
    { key = "^f11", command = "cyclestate CastingMode",     desc = "Casting Mode", state = "CastingMode" },
    { key = "^f12", command = "cyclestate IdleMode",        desc = "Idle Mode",    state = "IdleMode" },

    -- BindManager jobs.main_jobs.all.BLU
    { key = "!`", command = 'input /recast "Temporal Shift"; input /ma "Temporal Shift" <stnpc>', raw = true, desc = "Temporal Shift <stnpc>" },

    { key = "!1", command = 'input /recast "Erratic Flutter"; input /ma "Erratic Flutter" <me>', raw = true, desc = "Erratic Flutter" },
    { key = "!2", command = 'input /recast "Battery Charge"; input /ma "Battery Charge" <me>',   raw = true, desc = "Battery Charge" },
    { key = "!3", command = 'input /recast "Cocoon"; input /ma "Cocoon" <me>',                   raw = true, desc = "Cocoon" },
    { key = "!4", command = 'input /recast "Diamondhide"; input /ma "Diamondhide" <me>',         raw = true, desc = "Diamondhide" },
    { key = "!5", command = 'input /recast "Occultation"; input /ma "Occultation" <me>',         raw = true, desc = "Occultation" },
    { key = "!6", command = 'input /recast "Aquaveil"; input /ma "Aquaveil" <me>',               raw = true, desc = "Aquaveil" },

    { key = "@q", command = 'input /recast "Sheep Song"; input /ma "Sheep Song" <stnpc>',       raw = true, desc = "Sheep Song <stnpc>" },
    { key = "@w", command = 'input /recast "Dream Flower"; input /ma "Dream Flower" <stnpc>',   raw = true, desc = "Dream Flower <stnpc>" },
    { key = "@a", command = 'input /recast "Actinic Burst"; input /ma "Actinic Burst" <stnpc>', raw = true, desc = "Actinic Burst <stnpc>" },
    { key = "@f", command = 'input /echo <recast="Fantod"> "Boost"; input /ma "Fantod" <me>',   raw = true, desc = "Fantod" },
    { key = "@x", command = 'input /recast "Osmosis"; input /ma "Osmosis" <stnpc>',             raw = true, desc = "Osmosis <stnpc>" },
    { key = "@v", command = 'input /recast "Entomb"; input /ma "Entomb" <stnpc>',               raw = true, desc = "Entomb <stnpc>" },

    { key = "@1", command = 'input /recast "Chain Affinity"; input /ja "Chain Affinity" <me>',         raw = true, desc = "Chain Affinity" },
    { key = "@2", command = 'input /recast "Burst Affinity"; input /ja "Burst Affinity" <me>',         raw = true, desc = "Burst Affinity" },
    { key = "@3", command = 'input /recast "Efflux"; input /ja "Efflux" <me>',                         raw = true, desc = "Efflux" },
    { key = "@4", command = 'input /recast "Diffusion"; input /ja "Diffusion" <me>',                   raw = true, desc = "Diffusion" },
    { key = "@5", command = 'input /recast "Unbridled Learning"; input /ja "Unbridled Learning" <me>', raw = true, desc = "Unbridled Learning" },

    -- BindManager BLU.Sword: only with a sword in the main hand
    { key = "numpad1", command = 'input /ws "Requiescat" <t>',     raw = true, desc = "Requiescat",     weapon = "Sword" },
    { key = "numpad3", command = 'input /ws "Expiacion" <t>',      raw = true, desc = "Expiacion",      weapon = "Sword" },
    { key = "numpad7", command = 'input /ws "Chant du Cygne" <t>', raw = true, desc = "Chant du Cygne", weapon = "Sword" },
    { key = "numpad9", command = 'input /ws "Savage Blade" <t>',   raw = true, desc = "Savage Blade",   weapon = "Sword" },

    -- BindManager BLU.Club: only with a club in the main hand
    { key = "numpad1", command = 'input /ws "True Strike" <t>',    raw = true, desc = "True Strike",    weapon = "Club" },
    { key = "numpad3", command = 'input /ws "Black Halo" <t>',     raw = true, desc = "Black Halo",     weapon = "Club" },
    { key = "numpad9", command = 'input /ws "Judgment" <t>',       raw = true, desc = "Judgment",       weapon = "Club" },
}

return require('shared/utils/keybinds/keybind_manager').create('BLU', BLUKeybinds)
