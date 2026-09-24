---  ═══════════════════════════════════════════════════════════════════════════
---   SMN Pet Midcast Module
---  ═══════════════════════════════════════════════════════════════════════════
---   Called when the avatar (pet) readies an action. The master's
---   job_post_midcast already equipped the classified Blood Pact set; this
---   hook equips the same set again when the avatar acts, whatever the
---   master's aftercast did in between.
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
