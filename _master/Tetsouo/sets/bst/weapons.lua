---  ═══════════════════════════════════════════════════════════════════════════
---   BST Weapons - Main / Sub Weapon Set Definitions
---  ═══════════════════════════════════════════════════════════════════════════
---   Each entry returns a partial gear set (main or sub slot only) so it can
---   be combined with engaged / WS sets via set_combine.
---
---   Usage:
---     local Weapons = require('Tetsouo/sets/bst/weapons')
---     for name, weapon_set in pairs(Weapons) do
---         sets[name] = weapon_set
---     end
---
---   @file    Tetsouo/sets/bst/weapons.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-11
---  ═══════════════════════════════════════════════════════════════════════════

local Weapons = {}

-- • Axes (main)
Weapons['Aymur']        = {main = 'Aymur'}              -- Relic axe (Primal Rend)
Weapons['Tauret']       = {main = 'Tauret'}             -- Dagger main

-- • Sub weapons
Weapons["Agwu's Axe"]   = {sub  = "Agwu's Axe"}         -- MAB sub
Weapons['Blur Knife']   = {sub  = 'Blurred Knife +1'}   -- Dual wield sub
Weapons['Adapa Shield'] = {sub  = 'Adapa Shield'}       -- Refresh shield
Weapons['Diamond Aspis']= {sub  = 'Diamond Aspis'}      -- Killer Instinct
Weapons['Kraken Club']  = {sub  = 'Kraken Club'}        -- Multi-hit sub

return Weapons
