# Debuff Auto-Cure System - Configuration Guide

**File:** `shared/config/DEBUFF_AUTOCURE_CONFIG.lua`

Automatic debuff curing system that uses items (Echo Drops, Remedy, etc.) when you're affected by debuffs.

---

## Quick Start

### Enable Test Mode (Use Berserk to Test)

```lua
-- In shared/config/DEBUFF_AUTOCURE_CONFIG.lua:
DebuffAutoCureConfig.test_mode = true   -- Enable test mode
DebuffAutoCureConfig.debug = true       -- Show debug messages
```

### Test In-Game

```
1. Put Echo Drops in inventory
2. Change job to have WAR subjob (PLD/WAR, DNC/WAR, etc.)
3. Use Berserk: /ja "Berserk" <me>
4. Try to cast a spell: /ma "Cure IV" <me>
5. System should auto-use Echo Drops
6. Message displayed: "[TEST MODE] Using Berserk to simulate Silence"
```

### Disable Test Mode (Production)

```lua
-- In shared/config/DEBUFF_AUTOCURE_CONFIG.lua:
DebuffAutoCureConfig.test_mode = false  -- Disable test mode
```

Now system only works on real Silence.

---

## Configuration Options

### Test Mode

```lua
-- Enable test mode (use Berserk to simulate Silence)
DebuffAutoCureConfig.test_mode = false

-- Test debuff to use (when test_mode = true)
DebuffAutoCureConfig.test_debuff = "Berserk"
```

**Use case:** Test auto-cure system without needing to get silenced by mobs.

**How it works:**

- When `test_mode = true` and you have the test debuff (e.g., Berserk)
- Trying to cast any spell triggers auto-cure system
- Uses Echo Drops/Remedy just like real Silence

---

### Auto-Cure Settings

#### Silence (Blocks Magic Casting)

```lua
-- Enable auto-cure for Silence
DebuffAutoCureConfig.auto_cure_silence = true

-- Silence cure items (in priority order)
DebuffAutoCureConfig.silence_cure_items = {
    { name = "Echo Drops", id = 4151 },  -- Priority 1
    { name = "Remedy", id = 4155 }       -- Priority 2
}
```

#### Paralysis (Blocks Job Abilities/Weapon Skills)

```lua
-- Enable auto-cure for Paralysis
DebuffAutoCureConfig.auto_cure_paralysis = true

-- Paralysis cure items (in priority order)
DebuffAutoCureConfig.paralysis_cure_items = {
    { name = "Remedy", id = 4155 }       -- Cures Paralysis (ID 4) + Paralyzed (ID 566)
}
```

**Priority system:**

- System tries items in order
- If first item found >> use it
- If not found >> try next item
- If none found >> display error message

---

### Debug Mode

```lua
-- Show debug messages
DebuffAutoCureConfig.debug = false
```

When `true`, displays detailed messages:

- `[TEST MODE] Using Berserk to simulate Silence`
- Item checks, cure attempts, etc.

---

## How It Works

### Normal Mode (test_mode = false)

#### Silence Example

```
1. You get Silenced by mob
2. You try to cast spell: /ma "Stone" <t>
3. System detects Silence
4. Auto-uses Echo Drops (if available)
5. Spell cancelled (you can retry after cure)
6. Message: "[CURE] Using Echo Drops - Stone blocked by Silence"
```

#### Paralysis Example

```
1. You get Paralyzed by mob
2. You try to use weapon skill: /ws "Rudra's Storm" <t>
3. System detects Paralysis
4. Auto-uses Remedy (if available)
5. WS cancelled (you can retry after cure)
6. Message: "[CURE] Using Remedy - Rudra's Storm blocked by Paralysis"
```

### Test Mode (test_mode = true)

```
1. You use Berserk: /ja "Berserk" <me>
2. You try to cast spell: /ma "Cure IV" <me>
3. System detects Berserk (simulating Silence)
4. Auto-uses Echo Drops (if available)
5. Spell cancelled
6. Message: "[TEST MODE] Using Berserk to simulate Silence"
7. Message: "[CURE] Using Echo Drops - Cure IV blocked by Berserk"
```

---

## Adding More Cure Items

### Example: Add Catholicon (cures all status)

```lua
DebuffAutoCureConfig.silence_cure_items = {
    { name = "Echo Drops", id = 4151 },   -- Priority 1
    { name = "Remedy", id = 4155 },       -- Priority 2
    { name = "Catholicon", id = 5449 }    -- Priority 3
}
```

System will try in order: Echo Drops >> Remedy >> Catholicon

---

## Troubleshooting

### "System doesn't trigger with Berserk"

**Check:**

1. `test_mode = true` in config
2. `auto_cure_silence = true` in config
3. Reload GearSwap: `//gs c reload`

### "No cure items" message

**Cause:** Echo Drops and Remedy not in inventory

**Solution:** Put Echo Drops or Remedy in inventory

### "System triggers in production when I use Berserk"

**Cause:** Test mode still enabled

**Solution:** Set `test_mode = false` and reload: `//gs c reload`

---

## Future Expansions (Not Yet Implemented)

```lua
-- Placeholder for future debuff auto-cures
DebuffAutoCureConfig.auto_cure_poison = false     -- Not yet implemented
DebuffAutoCureConfig.auto_cure_blind = false      -- Not yet implemented
```

These will be added in future versions.

**Currently Implemented:**

- ✅ Silence (blocks magic casting)
- ✅ Paralysis (blocks job abilities/weapon skills)

---

## File Location

**Config file:**

```
shared/config/DEBUFF_AUTOCURE_CONFIG.lua
```

**Implementation:**

```
shared/utils/debuff/precast_guard.lua
```

---

## Related Documentation

- **[FAQ.md](../../docs/FAQ.md)** - Troubleshooting guide
- **[COMMANDS.md](../../docs/COMMANDS.md)** - Command reference

---

**Last Updated:** 2025-11-06
**Version:** 1.1
**Author:** Tetsouo GearSwap Project
