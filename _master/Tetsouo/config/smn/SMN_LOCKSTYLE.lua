---============================================================================
--- SMN Lockstyle Configuration
---============================================================================
--- Lockstyle ID per subjob for Summoner. Override via in-game lockstyle set #.
--- Used by LockstyleManager factory.
---
--- @file config/smn/SMN_LOCKSTYLE.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-05-28
---============================================================================

local SMNLockstyleConfig = {}

--- Default lockstyle (used if no subjob-specific entry)
SMNLockstyleConfig.default = 1

--- Lockstyle per subjob - placeholder values (user to fill with actual IDs)
SMNLockstyleConfig.by_subjob = {
    ['WHM'] = 1,
    ['SCH'] = 1,
    ['RDM'] = 1,
    ['BLM'] = 1,
}

--- Get lockstyle for current subjob
--- @param subjob string Current subjob code
--- @return number Lockstyle number (1-200)
function SMNLockstyleConfig.get_style(subjob)
    if SMNLockstyleConfig.by_subjob and SMNLockstyleConfig.by_subjob[subjob] then
        return SMNLockstyleConfig.by_subjob[subjob]
    end
    return SMNLockstyleConfig.default
end

return SMNLockstyleConfig
