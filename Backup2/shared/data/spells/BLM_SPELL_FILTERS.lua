---============================================================================
--- BLM Spell Filters - Spell Categorization for Refinement System
---============================================================================
--- Defines spell categories used by BLM precast refinement logic:
---   • REFINEMENT_SPELLS - Spells that use tier downgrading system
---   • ELEMENTAL_NO_TIERS - Elemental Magic spells without tier system
---   • CHARGE_ABILITIES - Abilities with multiple charges (bypass cooldown)
---
--- These filters determine how spells are handled in BLM_PRECAST:
---   - Refinement spells: Use spell_refiner for tier downgrading
---   - No-tier elemental: Use standard cooldown check (no refinement)
---   - Charge abilities: Bypass cooldown check (FFXI handles blocking)
---
--- @file    BLM_SPELL_FILTERS.lua
--- @author  Tetsouo
--- @version 1.0 - Extracted from BLM_PRECAST for performance
--- @date    Created: 2025-11-19
---============================================================================

local BLM_SPELL_FILTERS = {}

---============================================================================
--- REFINEMENT SPELLS - Spells with tier downgrading system
---============================================================================
--- Spells in this list will use the refinement system instead of cooldown check
--- Refinement automatically downgrades tiers when higher tiers are on cooldown
--- Example: Fire VI >> V >> IV >> III >> II >> I
---============================================================================

BLM_SPELL_FILTERS.REFINEMENT_SPELLS = {
    -- Elemental Magic skill (all spells except storms/klimaform)
    ['Elemental Magic'] = true,

    -- Sleep spells (III >> II >> I)
    ['Sleep'] = true,
    ['Sleep II'] = true,
    ['Sleep III'] = true,

    -- Sleepga spells (II >> I)
    ['Sleepga'] = true,
    ['Sleepga II'] = true,

    -- Break spells
    ['Break'] = true,
    ['Breakga'] = true,

    -- Bind spells (II >> I)
    ['Bind'] = true,
    ['Bind II'] = true,

    -- Bio spells (V >> IV >> III >> II >> I)
    ['Bio'] = true,
    ['Bio II'] = true,
    ['Bio III'] = true,
    ['Bio IV'] = true,
    ['Bio V'] = true,

    -- Poison spells (V >> IV >> III >> II >> I)
    ['Poison'] = true,
    ['Poison II'] = true,
    ['Poison III'] = true,
    ['Poison IV'] = true,
    ['Poison V'] = true,

    -- Drain spells (III >> II >> I)
    ['Drain'] = true,
    ['Drain II'] = true,
    ['Drain III'] = true,

    -- Aspir spells (III >> II >> I)
    ['Aspir'] = true,
    ['Aspir II'] = true,
    ['Aspir III'] = true,

    -- Elemental enfeebles (no tiers, but included for completeness)
    ['Burn'] = true,
    ['Frost'] = true,
    ['Choke'] = true,
    ['Rasp'] = true,
    ['Shock'] = true,
    ['Drown'] = true
}

---============================================================================
--- ELEMENTAL NO TIERS - Elemental Magic spells without tier system
---============================================================================
--- These spells are Elemental Magic skill but have no tier downgrading
--- They use standard cooldown check instead of refinement
---============================================================================

BLM_SPELL_FILTERS.ELEMENTAL_NO_TIERS = {
    -- Weather effect enhancement
    ['Klimaform'] = true,

    -- Storm spells (subjob Scholar)
    ['Firestorm'] = true,
    ['Sandstorm'] = true,
    ['Rainstorm'] = true,
    ['Windstorm'] = true,
    ['Hailstorm'] = true,
    ['Thunderstorm'] = true,
    ['Voidstorm'] = true,
    ['Aurorastorm'] = true
}

---============================================================================
--- CHARGE ABILITIES - Abilities with multiple charges
---============================================================================
--- These abilities have multiple charges (Stratagems for Scholar subjob)
--- They bypass cooldown check because FFXI handles blocking automatically
---============================================================================

BLM_SPELL_FILTERS.CHARGE_ABILITIES = {
    -- Scholar stratagems (8 charges shared between all)
    ['Addendum: White'] = true,
    ['Addendum: Black'] = true,
    ['Accession'] = true,
    ['Manifestation'] = true,
    ['Stratagem'] = true  -- Generic entry if needed
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLM_SPELL_FILTERS
