# RDM Spell Name Bug Fix

**Date**: 2025-11-07
**Severity**: Medium
**Status**: Fixed

## Problem

Spell names were showing as empty brackets `[]` in RDM spell messages:
```
[RDM/WHM] [] TEST -> Increases attack speed.
```

Instead of:
```
[RDM/WHM] [Haste II] TEST -> Increases attack speed.
```

## Root Cause

**Color tag naming conflict in message_engine.lua**

When we added semantic color aliases for the warp system fix, we accidentally created three color tags that conflicted with common parameter names:
- `{spell}` - color tag (cyan) vs `{spell}` parameter
- `{item}` - color tag (green) vs `{item}` parameter
- `{warning}` - color tag (orange) vs `{warning}` parameter

The template parser checks `if COLOR_CODES[content]` before checking if it's a parameter. When it encountered `{spell}` in the template, it matched the color tag and classified it as a COLOR instead of a PARAM, so the parameter replacement never happened.

## Debug Process

1. Added extensive debug logging to template compilation
2. Traced parsing loop iteration-by-iteration
3. Discovered `{spell}` being classified as COLOR instead of PARAM
4. Found the conflicting color aliases in COLOR_CODES table

## Solution

Renamed the three conflicting color aliases to avoid parameter name collisions:
- `{spell}` → `{spellcolor}`
- `{item}` → `{itemcolor}`
- `{warning}` → `{warningcolor}`

## Files Changed

1. **shared/utils/messages/core/message_engine.lua**
   - Renamed color aliases in COLOR_CODES table (lines 51-53)
   - Added comment about avoiding parameter name conflicts

2. **shared/utils/messages/data/systems/warp_messages.lua**
   - Updated all warp message templates to use new color tag names
   - Changed `{spell}` → `{spellcolor}` (7 templates)
   - Changed `{item}` → `{itemcolor}` (18 templates)
   - Changed `{warning}` → `{warningcolor}` (5 templates)

## Prevention

**Rule**: Color tag names must NOT conflict with commonly used parameter names.

Safe color tags:
- Semantic suffixes: `{spellcolor}`, `{itemcolor}`, `{warningcolor}`
- Compound names: `{jobtag}`, `{separator}`
- Basic colors: `{cyan}`, `{green}`, `{red}`, `{yellow}`, etc.

Unsafe color tags (reserved for parameters):
- `{spell}` - used for spell names
- `{item}` - used for item names
- `{ability}` - used for ability names
- `{job}` - used for job tags
- `{target}` - used for target names
- `{description}` - used for descriptions

## Testing

Test spell messages with `//ma "Haste II" <me>`:
- ✅ Should show: `[RDM/WHM] [Haste II] -> Increases attack speed.`
- ❌ Should NOT show: `[RDM/WHM] [] -> Increases attack speed.`

Test warp commands with `//gs c warp`:
- ✅ Warp messages should display with correct colors
- ✅ No "Missing parameter" errors

## Lesson Learned

Always consider parameter name conflicts when adding new color tags to the template engine. Use distinctive names that won't clash with natural parameter names (spell, item, ability, target, etc.).
