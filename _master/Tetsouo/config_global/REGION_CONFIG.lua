---============================================================================
--- Region Configuration - Character Region Mapping
---============================================================================
--- Maps character names to their FFXI region (POL account type).
--- This determines which color codes are available for messaging.
---
--- IMPORTANT: Add your character(s) to this list!
---
--- Available regions:
---   "US" - North America / US PlayOnline accounts (NBCP)
---          - Code 057 = Orange (available)
---   "EU" - Europe PlayOnline accounts (BQJS)
---          - Code 057 = Does NOT exist (use 003 instead)
---   "JP" - Japan PlayOnline accounts
---          - Code 057 = Orange (available)
---
--- How to add your character:
---   1. Find your character name (case-sensitive!)
---   2. Add a new line: ["YourCharName"] = "US" or "EU" or "JP"
---   3. Save the file
---   4. Reload GearSwap: //lua r gearswap
---
--- @file config/REGION_CONFIG.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-12
---============================================================================
local RegionConfig = {}

---============================================================================
--- CHARACTER >> REGION MAPPING
---============================================================================
--- Add your character(s) below!
--- Format: ["CharacterName"] = "US" or "EU" or "JP"

RegionConfig.characters = {
    -- Tetsouo's characters
    ["Tetsouo"] = "US" -- US account (NBCP) - Has orange (057)

    -- Add your characters here:
    -- ["MyCharacter"] = "US",
    -- ["AltCharacter"] = "EU",
}

---============================================================================
--- DEFAULT REGION
---============================================================================
--- If character not found in mapping above, use this region
--- Most players have US accounts, so default to "US"

RegionConfig.default_region = "US"

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Get region for a character name
--- @param char_name string Character name (case-sensitive)
--- @return string region Region code ("US", "EU", "JP")
function RegionConfig.get_region(char_name)
    if not char_name then
        return RegionConfig.default_region
    end

    return RegionConfig.characters[char_name] or RegionConfig.default_region
end

--- Get orange/warning color code for a region
--- @param region string Region code ("US", "EU", "JP")
--- @return number color_code FFXI color code for orange/warning
function RegionConfig.get_orange_code(region)
    if region == "EU" then
        -- EU: Code 057 does NOT exist, use 003 as orange equivalent
        return 003
    else
        -- US/JP: Code 057 = Orange
        return 057
    end
end

--- Get orange/warning color code for current character
--- @param char_name string Character name
--- @return number color_code FFXI color code for orange/warning
function RegionConfig.get_orange_for_character(char_name)
    local region = RegionConfig.get_region(char_name)
    return RegionConfig.get_orange_code(region)
end

---============================================================================
--- REGION INFO (for reference)
---============================================================================

RegionConfig.region_info = {
    US = {
        name = "United States / North America",
        pol_type = "NBCP",
        code_057 = "Orange (exists)",
        warning_color = 057,
        example_chars = {"Tetsouo"}
    },
    EU = {
        name = "Europe",
        pol_type = "BQJS",
        code_057 = "Does NOT exist",
        warning_color = 003, -- Orange equivalent for EU
        example_chars = {"Kaories"}
    },
    JP = {
        name = "Japan",
        pol_type = "JP",
        code_057 = "Orange (exists)",
        warning_color = 057,
        example_chars = {}
    }
}

return RegionConfig
