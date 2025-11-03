#!/usr/bin/env python3
"""
Update all PRECAST files to include WS_DB integration
Adds:
1. WS_DB require after JA_DB
2. WS message display in job_precast (with TP)
"""

import os
import re
from pathlib import Path

# Base directory
BASE_DIR = Path(r"D:\Windower Tetsouo\addons\GearSwap\data\shared\jobs")

# Find all PRECAST files (exclude BST_PET_PRECAST)
precast_files = list(BASE_DIR.glob("*/functions/*_PRECAST.lua"))
precast_files = [f for f in precast_files if "PET_PRECAST" not in f.name]

print(f"Found {len(precast_files)} PRECAST files to update\n")

# Code snippets to add
WS_DB_REQUIRE = """-- Universal Weapon Skills Database (weaponskill descriptions)
local WS_DB = require('shared/data/weaponskills/UNIVERSAL_WS_DATABASE')
"""

WS_MESSAGE_CODE = """
    -- ==========================================================================
    -- WEAPONSKILL MESSAGES (universal - all weapon types)
    -- ==========================================================================
    if spell.type == 'WeaponSkill' and WS_DB[spell.english] then
        -- Get current TP for display
        local current_tp = player and player.vitals and player.vitals.tp or 0
        MessageFormatter.show_ws_activated(spell.english, WS_DB[spell.english].description, current_tp)
    end
"""

def has_ws_db_require(content):
    """Check if file already has WS_DB require"""
    return "UNIVERSAL_WS_DATABASE" in content or "local WS_DB" in content

def has_ws_message(content):
    """Check if file already has WS message display"""
    return "show_ws_activated" in content

def add_ws_db_require(content):
    """Add WS_DB require after JA_DB"""
    # Find JA_DB require line
    ja_pattern = r"(local JA_DB = require\('shared/data/job_abilities/UNIVERSAL_JA_DATABASE'\))"

    if re.search(ja_pattern, content):
        # Add WS_DB require right after JA_DB
        content = re.sub(
            ja_pattern,
            r"\1\n\n" + WS_DB_REQUIRE.strip(),
            content
        )
        return content, True

    # Fallback: Add after MessageFormatter or CooldownChecker
    fallback_pattern = r"(local MessageFormatter = require\('shared/utils/messages/message_formatter'\))"
    if re.search(fallback_pattern, content):
        content = re.sub(
            fallback_pattern,
            r"\1\n\n" + WS_DB_REQUIRE.strip(),
            content
        )
        return content, True

    return content, False

def add_ws_message(content):
    """Add WS message display in job_precast"""
    # Pattern 1: Add after JA messages block
    ja_messages_pattern = r"(-- =+\n    -- JOB ABILITIES MESSAGES.*?\n    -- =+\n    if spell\.type == 'JobAbility'.*?\n        .*?\n    end)"

    if re.search(ja_messages_pattern, content, re.DOTALL):
        content = re.sub(
            ja_messages_pattern,
            r"\1" + WS_MESSAGE_CODE,
            content,
            flags=re.DOTALL
        )
        return content, True

    # Pattern 2: Add before WeaponSkill validation
    ws_validation_pattern = r"(    -- WeaponSkill validation\n    if spell\.type == 'WeaponSkill')"

    if re.search(ws_validation_pattern, content):
        content = re.sub(
            ws_validation_pattern,
            WS_MESSAGE_CODE.strip() + "\n\n" + r"\1",
            content
        )
        return content, True

    # Pattern 3: Add before LAYER 3: WEAPONSKILL VALIDATION
    ws_layer_pattern = r"(    -- =+\n    -- LAYER 3: WEAPONSKILL VALIDATION)"

    if re.search(ws_layer_pattern, content):
        content = re.sub(
            ws_layer_pattern,
            WS_MESSAGE_CODE.strip() + "\n\n" + r"\1",
            content
        )
        return content, True

    return content, False

# Process each file
updated_count = 0
skipped_count = 0
failed_count = 0

for precast_file in precast_files:
    job_name = precast_file.parent.parent.name.upper()
    print(f"Processing {job_name}_PRECAST.lua...")

    try:
        # Read file
        with open(precast_file, 'r', encoding='utf-8') as f:
            content = f.read()

        # Check if already updated
        has_require = has_ws_db_require(content)
        has_message = has_ws_message(content)

        if has_require and has_message:
            print(f"  [OK] Already updated, skipping\n")
            skipped_count += 1
            continue

        # Add WS_DB require if missing
        if not has_require:
            content, success = add_ws_db_require(content)
            if success:
                print(f"  [OK] Added WS_DB require")
            else:
                print(f"  [WARN] Could not find insertion point for WS_DB require")

        # Add WS message if missing
        if not has_message:
            content, success = add_ws_message(content)
            if success:
                print(f"  [OK] Added WS message display")
            else:
                print(f"  [WARN] Could not find insertion point for WS message")

        # Write updated content
        with open(precast_file, 'w', encoding='utf-8') as f:
            f.write(content)

        print(f"  [OK] File updated successfully\n")
        updated_count += 1

    except Exception as e:
        print(f"  [ERROR] {e}\n")
        failed_count += 1

print("="*60)
print(f"Summary:")
print(f"  Updated: {updated_count}")
print(f"  Skipped (already updated): {skipped_count}")
print(f"  Failed: {failed_count}")
print(f"  Total: {len(precast_files)}")
print("="*60)
