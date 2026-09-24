---  ═══════════════════════════════════════════════════════════════════════════
---   THF Weapons - Main / Sub Weapon Set Definitions
---  ═══════════════════════════════════════════════════════════════════════════
---   Each entry returns a partial gear set (main/sub/range slot) so it can be
---   combined with engaged / WS sets via set_combine.
---
---   Includes:
---     • Main daggers (Vajra/Twashtar/Mpu Gandring/Tauret/Malevolence/Qutrub)
---     • Main swords (Naegling, Excalipoor for Abyssea proc)
---     • Sub daggers (Centovente, Gleti's Knife, Tanmogayi, Crepuscular, etc.)
---     • Sub clubs (Kraken)
---     • Abyssea proc weapons (Great Sword/Polearm/Staff/Scythe + Alber Strap)
---
---   Usage:
---     local Weapons = require('Tetsouo/sets/thf/weapons')
---     for name, weapon_set in pairs(Weapons) do
---         sets[name] = weapon_set
---     end
---
---   @file    Tetsouo/sets/thf/weapons.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-11
---  ═══════════════════════════════════════════════════════════════════════════

local Weapons = {}

-- ─────────────────────────────────────────────────────────────────────────
-- Main Weapons
-- ─────────────────────────────────────────────────────────────────────────

Weapons['TwashtarM']      = {main = 'Twashtar'}        -- Empyrean dagger (main)
Weapons['Mpu Gandring']   = {main = 'Mpu Gandring'}    -- Magical dagger
Weapons['Vajra']          = {main = 'Vajra'}           -- Mythic dagger (Aftermath Lv.3)
Weapons['Tauret']         = {main = 'Tauret'}          -- Crit dagger
Weapons['Malevolence']    = {main = 'Malevolence'}     -- Magical dagger
Weapons['Dagger']         = {main = 'Qutrub Knife'}    -- Generic dagger
Weapons['Naegling']       = {main = 'Naegling'}        -- Savage Blade sword

-- ─────────────────────────────────────────────────────────────────────────
-- Sub Weapons / Off-hand
-- ─────────────────────────────────────────────────────────────────────────

Weapons['Tanmogayi']      = {sub = 'Tanmogayi +1'}     -- Magical sub dagger
Weapons['TwashtarS']      = {sub = 'Twashtar'}         -- Twashtar as sub
Weapons['Jugo']           = {sub = 'Jugo Kukri +1'}    -- Sub dagger
Weapons['Crepu']          = {sub = 'Crepuscular Knife'}-- Sub dagger
Weapons['Centovente']     = {sub = 'Centovente'}       -- Multi-attack sub
Weapons['Blurred']        = {sub = 'Blurred Knife +1'} -- Sub dagger
Weapons['Gleti']          = {sub = "Gleti's Knife"}    -- Crit sub
Weapons['Kraken']         = {sub = 'Kraken Club'}      -- Multi-attack club sub
Weapons['Telop Knife']    = {sub = 'Telopanos Knife'}  -- Sub dagger

-- ─────────────────────────────────────────────────────────────────────────
-- Abyssea Proc Weapons (1-handed with dagger sub for DW)
-- ─────────────────────────────────────────────────────────────────────────

Weapons['Sword']          = {main = 'Excalipoor',  sub = 'Qutrub Knife'}
Weapons['Club']           = {main = 'Chac-Chacs',  sub = 'Qutrub Knife'}
Weapons['Dagger2']        = {main = 'Qutrub Knife', sub = 'Chac-Chacs'}

-- ─────────────────────────────────────────────────────────────────────────
-- Abyssea Proc Weapons (2-handed with Alber Strap)
-- ─────────────────────────────────────────────────────────────────────────

Weapons['Great Sword']    = {main = 'Lament',      sub = 'Alber Strap'}
Weapons['Polearm']        = {main = 'Iapetus',     sub = 'Alber Strap'}
Weapons['Staff']          = {main = 'Ram Staff',   sub = 'Alber Strap'}
Weapons['Scythe']         = {main = 'Lost Sickle', sub = 'Alber Strap'}
Weapons['Alber']          = {sub = 'Alber Strap'}

return Weapons
