---
paths:
  - "**/functions/*_PRECAST.lua"
---

# PRECAST Module - Mandatory Pattern

## Execution Order (NEVER reorder)

```lua
function job_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()

    -- 1. PrecastGuard (FIRST - blocks if debuffed/dead)
    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then return end

    -- 2. CooldownChecker (cancel if on cooldown)
    if CooldownChecker then
        CooldownChecker.check_ability_cooldown(spell, eventArgs)
    end
    if eventArgs.cancel then return end

    -- 3. AbilityHelper (optional - auto-trigger before WS)
    -- AbilityHelper.try_ability_ws(spell, eventArgs, 'Ability Name', cost)

    -- 4. WSPrecastHandler (unified WS handling)
    if spell.type == 'WeaponSkill' then
        if WSPrecastHandler and not WSPrecastHandler.handle(spell, eventArgs, Config) then return end
    end

    -- 5. Job-specific gear logic (last)
end
```

## Required Exports

```lua
_G.job_precast = job_precast
_G.job_post_precast = job_post_precast  -- if exists

return {
    job_precast = job_precast,
    job_post_precast = job_post_precast
}
```

## Cooldown Exclusions
Some jobs exclude spells from cooldown check (e.g., Scholar Stratagems, Utsusemi). Use:
```lua
local exclusions = S{'Utsusemi: Ichi', 'Utsusemi: Ni'}
CooldownChecker.check_ability_cooldown(spell, eventArgs, exclusions)
```

## Anti-patterns
- Putting MidcastManager in PRECAST (belongs in MIDCAST)
- Checking WS range manually (use WSPrecastHandler)
- Forgetting `eventArgs.cancel` check after CooldownChecker
- Skipping PrecastGuard or putting it after other checks
