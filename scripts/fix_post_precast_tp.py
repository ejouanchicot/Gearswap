#!/usr/bin/env python3
"""
Fix job_post_precast to remove duplicate TP display
Replace TPBonusHandler.apply_and_display() with calculate_tp_gear() only
"""

import os
import re
from pathlib import Path

# Base directory
BASE_DIR = Path(r"D:\Windower Tetsouo\addons\GearSwap\data\shared\jobs")

# Find all PRECAST files (exclude BST_PET_PRECAST and WAR which is already done)
precast_files = list(BASE_DIR.glob("*/functions/*_PRECAST.lua"))
precast_files = [f for f in precast_files if "PET_PRECAST" not in f.name and "WAR_PRECAST" not in f.name]

print(f"Found {len(precast_files)} PRECAST files to check\n")

# Pattern to find and replace
OLD_PATTERN_1 = re.compile(
    r"function job_post_precast\(spell, action, spellMap, eventArgs\)\s*\n"
    r"    if TPBonusHandler then\s*\n"
    r"        TPBonusHandler\.apply_and_display\(spell, (\w+)TPConfig\)\s*\n"
    r"    end",
    re.MULTILINE
)

OLD_PATTERN_2 = re.compile(
    r"function job_post_precast\(spell, action, spellMap, eventArgs\)\s*\n"
    r"    -- Display TP for weaponskills\s*\n"
    r"    if TPBonusHandler then\s*\n"
        r"        TPBonusHandler\.apply_and_display\(spell, (\w+)TPConfig\)\s*\n"
    r"    end",
    re.MULTILINE
)

def replace_post_precast(content, job_name):
    """Replace old post_precast with new version"""

    # Try pattern 1 (simple version)
    match = OLD_PATTERN_1.search(content)
    if match:
        config_name = match.group(1)
        new_code = f"""function job_post_precast(spell, action, spellMap, eventArgs)
    if TPBonusHandler and spell.type == 'WeaponSkill' then
        -- Apply TP bonus gear only (no display - already shown in precast message)
        TPBonusHandler.calculate_tp_gear(spell, {config_name}TPConfig)
    end"""
        content = OLD_PATTERN_1.sub(new_code, content)
        return content, True

    # Try pattern 2 (with comment)
    match = OLD_PATTERN_2.search(content)
    if match:
        config_name = match.group(1)
        new_code = f"""function job_post_precast(spell, action, spellMap, eventArgs)
    if TPBonusHandler and spell.type == 'WeaponSkill' then
        -- Apply TP bonus gear only (no display - already shown in precast message)
        TPBonusHandler.calculate_tp_gear(spell, {config_name}TPConfig)
    end"""
        content = OLD_PATTERN_2.sub(new_code, content)
        return content, True

    return content, False

# Process each file
updated_count = 0
skipped_count = 0

for precast_file in precast_files:
    job_name = precast_file.parent.parent.name.upper()
    print(f"Processing {job_name}_PRECAST.lua...")

    try:
        # Read file
        with open(precast_file, 'r', encoding='utf-8') as f:
            content = f.read()

        # Check if needs update
        if "apply_and_display" not in content:
            print(f"  [OK] Already fixed or no post_precast, skipping\n")
            skipped_count += 1
            continue

        # Replace post_precast
        content, success = replace_post_precast(content, job_name)

        if success:
            # Write updated content
            with open(precast_file, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"  [OK] Fixed post_precast (removed duplicate TP display)\n")
            updated_count += 1
        else:
            print(f"  [WARN] Could not find pattern to replace\n")
            skipped_count += 1

    except Exception as e:
        print(f"  [ERROR] {e}\n")

print("="*60)
print(f"Summary:")
print(f"  Updated: {updated_count}")
print(f"  Skipped: {skipped_count}")
print(f"  Total: {len(precast_files)}")
print("="*60)
