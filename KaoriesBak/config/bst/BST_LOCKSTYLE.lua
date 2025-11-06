---============================================================================
--- BST Lockstyle Configuration
---============================================================================
--- Lockstyle configuration for Beastmaster job (per subjob).
--- Used by LockstyleManager factory.
---
--- @file config/bst/BST_LOCKSTYLE.lua
--- @author Kaories
--- @version 1.0
--- @date Created: 2025-10-17
---============================================================================

local BSTLockstyleConfig = {}

---============================================================================
--- LOCKSTYLE CONFIGURATION
---============================================================================

--- Default lockstyle (used if no subjob-specific config)
BSTLockstyleConfig.default = 6

--- Lockstyle per subjob (optional)
--- Format: ['SUBJOB_CODE'] = lockstyle_number
BSTLockstyleConfig.by_subjob = {
    ['SAM'] = 6,
    ['NIN'] = 6,
    ['DNC'] = 6,
    ['WHM'] = 6,
    ['RDM'] = 6,
    ['PLD'] = 6,
    ['DRK'] = 6,
    ['BST'] = 6,
    ['MNK'] = 6,
    ['WAR'] = 6,
    ['THF'] = 6,
    ['BRD'] = 6,
    ['COR'] = 6,
    ['PUP'] = 6,
    ['SCH'] = 6,
    ['GEO'] = 6,
    ['RUN'] = 6,
    ['SMN'] = 6,
    ['BLU'] = 6
}

---============================================================================
--- HELPER FUNCTION
---============================================================================

--- Get lockstyle for current subjob
--- Returns subjob-specific lockstyle if configured, otherwise returns default.
--- @param subjob string Current subjob code
--- @return number Lockstyle number (1-200)
function BSTLockstyleConfig.get_style(subjob)
    if BSTLockstyleConfig.by_subjob and BSTLockstyleConfig.by_subjob[subjob] then
        return BSTLockstyleConfig.by_subjob[subjob]
    end
    return BSTLockstyleConfig.default
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return BSTLockstyleConfig
