---  ═══════════════════════════════════════════════════════════════════════════
---   WAR Weapons - Main / Sub Weapon Set Definitions
---  ═══════════════════════════════════════════════════════════════════════════
---   Each entry returns a partial gear set (main, sub, or ammo slot only) so it
---   can be combined with engaged / WS sets via the GearSwap engine.
---
---   Main weapons (two-handed):
---     • Ukonvasara = Relic Great Axe (AM3 TP reduction)
---     • Chango    = Empyrean Great Axe (+500 TP bonus)
---     • Lycurgos  = Mythic Great Axe
---     • Shining   = Polearm (Shining One)
---     • Ikenga    = Ikenga's Axe (Fencer w/ shield)
---     • Naegling  = Sword (Savage Blade Fencer build)
---     • Loxotic   = Mace (Judgment / Fencer w/ shield)
---
---   Sub weapons / utilities:
---     • Blurred Shield +1 = Fencer shield
---     • Telopanos Grip          = Two-handed grip
---     • Alber Strap       = Two-handed grip alt
---     • Kraken Club       = Multi-attack sub
---     • Aurgelmir Orb +1  = Ammo slot
---
---   Usage:
---     local Weapons = require('Tetsouo/sets/war/weapons')
---     for name, weapon_set in pairs(Weapons) do
---         sets[name] = weapon_set
---     end
---
---   @file    Tetsouo/sets/war/weapons.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-11
---  ═══════════════════════════════════════════════════════════════════════════

local Weapons = {}

-- • Great Axes (two-handed)
Weapons['Ukonvasara'] = {main = 'Ukonvasara', sub = 'Telopanos Grip'}  -- Relic (AM3 TP reduction)
Weapons['Chango']     = {main = 'Chango',     sub = 'Telopanos Grip'}  -- Empyrean (+500 TP bonus)
Weapons['Lycurgos']   = {main = 'Lycurgos',   sub = 'Telopanos Grip'}  -- Mythic

-- • Polearms (two-handed)
Weapons['Shining']    = {main = 'Shining One', sub = 'Telopanos Grip'}

-- • Axes (one-handed, Fencer w/ shield)
Weapons['Ikenga']     = {main = "Ikenga's Axe", sub = 'Blurred Shield +1'}

-- • Swords (one-handed, Fencer w/ shield)
Weapons['Naegling']   = {main = 'Naegling', sub = 'Blurred Shield +1'}  -- Savage Blade
Weapons['NaeglingKC'] = {main = 'Naegling', sub = 'Kraken Club'}        -- Multi-attack focus

-- • Maces (one-handed, Fencer w/ shield)
Weapons['Loxotic']    = {main = 'Loxotic Mace +1', sub = 'Blurred Shield +1'}

-- • Sub-slot only utilities
Weapons['Blurred Shield +1'] = {sub = 'Blurred Shield +1'}
Weapons['Telopanos Grip']          = {sub = 'Telopanos Grip'}
Weapons['Alber Strap']       = {sub = 'Alber Strap'}

-- • Ammo slot utilities
Weapons['Aurgelmir Orb +1']  = {ammo = 'Aurgelmir Orb +1'}

return Weapons
