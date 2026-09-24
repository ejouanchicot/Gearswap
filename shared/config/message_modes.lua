---  ═══════════════════════════════════════════════════════════════════════════
---   Message Display Modes - Unused Reference Copy
---  ═══════════════════════════════════════════════════════════════════════════
---   NOT read at runtime: message_settings.lua loads and writes
---   [CharName]/config/message_modes.lua, never this shared copy (no require,
---   include or dofile targets this path). Its ja_mode = 'full' also differs
---   from the runtime default ('on') used when the per-character file is absent.
---
---   Modes:
---     • spell_mode: ALL spell types (Enhancing, Enfeebling, Healing, Elemental)
---     • ja_mode: Job Abilities
---     • ws_mode: Weapon Skills
---
---   Valid Values:
---     • 'full' - Show name + description
---     • 'on'   - Show name only
---     • 'off'  - Silent (no messages)
---
---   @file    shared/config/message_modes.lua
---   @author  Tetsouo
---   @version 2.0 - Per-character persistence
---   @date    Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

return {
    spell_mode = 'on',    -- Spells: name only
    ja_mode = 'full',     -- Job Abilities: name + description
    ws_mode = 'on'        -- Weapon Skills: name + TP only
}
