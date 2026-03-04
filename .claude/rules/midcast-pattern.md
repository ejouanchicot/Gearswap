---
paths:
  - "**/functions/*_MIDCAST.lua"
---

# MIDCAST Module - Mandatory Pattern

## MidcastManager is OBLIGATOIRE

Every MIDCAST module MUST use `MidcastManager.select_set()` for spell gear selection.

```lua
function job_midcast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()

    -- Job-specific overrides FIRST (e.g., PLD Cure gear, BLM elemental)
    -- Only for spells that need custom handling

    -- Then delegate to MidcastManager for everything else
    if MidcastManager then
        MidcastManager.select_set({
            skill = spell.skill,
            spell = spell,
            mode_state = state.CastingMode  -- or specific mode state
        })
        eventArgs.handled = true
    end
end
```

## MidcastManager.select_set() Parameters

```lua
MidcastManager.select_set({
    skill = 'Enfeebling Magic',     -- spell skill category
    spell = spell,                   -- the spell object
    mode_state = state.EnfeebleMode, -- optional: mode state for cycling
    element = spell.element,         -- optional: for elemental matching
})
```

## 7-Level Fallback Chain
MidcastManager automatically tries: spell name > spell map > skill + mode > skill > type > default midcast > idle

## Debug
`//gs c debugmidcast` to see which set level was selected.
Full reference: @.claude/MIDCAST_STANDARD.md

## Anti-patterns
- Nested if/elseif chains for spell gear (use MidcastManager)
- Hardcoded set names without fallback (MidcastManager handles this)
- Missing `eventArgs.handled = true` after MidcastManager call
