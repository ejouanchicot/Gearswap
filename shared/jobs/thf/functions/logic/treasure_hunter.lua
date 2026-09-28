---  ═══════════════════════════════════════════════════════════════════════════
---   Treasure Hunter (THF) - the SA/TA versions on top of the shared module
---  ═══════════════════════════════════════════════════════════════════════════
---   Tag tracking, the Tag / Full modes and the engaged overlay live in
---   shared/utils/equipment/treasure_hunter.lua (every job). THF adds its own
---   mode SATA (THF_STATES.lua: Tag, SATA, Full) and the SA/TA engaged
---   overlays, and builds its engaged TH itself in its set builder, so the
---   shared engaged wrapper steps aside on THF (init).
---
---   @file    shared/jobs/thf/functions/logic/treasure_hunter.lua
---   @author  ejouanchicot
---   @version 2.0
---   @date    Created: 2026-09-19 | Updated: 2026-09-28 (shared module)
---  ═══════════════════════════════════════════════════════════════════════════

local Shared = require('shared/utils/equipment/treasure_hunter')

-- Everything the shared module has (mode, is_tagged, wants_engaged_th,
-- apply_engaged...), plus the THF parts below.
local TreasureHunter = setmetatable({}, {__index = Shared})

--- TreasureHunter version of the SA/TA engaged overlay, in SATA and Full.
--- @param has_sa boolean Sneak Attack up or pending
--- @param has_ta boolean Trick Attack up or pending
--- @return table|nil Set to overlay, or nil to keep the sets.buff overlay
function TreasureHunter.sata_overlay(has_sa, has_ta)
    local current_mode = Shared.mode()
    if (current_mode ~= 'SATA' and current_mode ~= 'Full') or not sets then
        return nil
    end
    if has_sa and has_ta then
        return sets.TreasureHunterSATA
    elseif has_sa then
        return sets.TreasureHunterSA
    elseif has_ta then
        return sets.TreasureHunterTA
    end
    return nil
end

--- THF builds its engaged TH itself (set_builder.lua, with SATA): tell the
--- shared engaged wrapper to step aside, and start the tag tracking.
function TreasureHunter.init()
    _G._treasure_engaged_by_job = true
    Shared.init()
end

return TreasureHunter
