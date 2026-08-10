---  ═══════════════════════════════════════════════════════════════════════════
---   SMN Pet Midcast Module
---  ═══════════════════════════════════════════════════════════════════════════
---   Called when the avatar (pet) is mid-action. For SMN, Blood Pacts are
---   already gear-equipped via the MASTER's job_post_midcast (because BP gear
---   is read off the master at the moment the avatar fires). This hook is a
---   safety net: if a BP somehow reaches pet midcast without gear, re-apply
---   the classified set.
---
---   @file    shared/jobs/smn/functions/SMN_PET_MIDCAST.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-28
---  ═══════════════════════════════════════════════════════════════════════════

local BloodPactClassifier = nil

local function ensure_loaded()
    if BloodPactClassifier then return end
    local bpc_ok, bpc = pcall(require, 'shared/jobs/smn/functions/logic/blood_pact_classifier')
    if not bpc_ok then bpc = nil end
    BloodPactClassifier = bpc
end

--- Called during pet ability midcast
--- @param spell table Spell/ability data (pet's perspective)
function job_pet_midcast(spell)
    ensure_loaded()
    if not BloodPactClassifier then return end

    local bp_set = BloodPactClassifier.resolve(spell.english or spell.name)
    if bp_set then
        equip(bp_set)
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.job_pet_midcast = job_pet_midcast

return {
    job_pet_midcast = job_pet_midcast,
}
