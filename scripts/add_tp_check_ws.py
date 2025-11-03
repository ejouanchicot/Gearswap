#!/usr/bin/env python3
"""
Add TP check before displaying WS messages in all PRECAST files
If TP < 1000, display error message instead of WS message
"""

import re
from pathlib import Path

# Base directory
BASE_DIR = Path(r"D:\Windower Tetsouo\addons\GearSwap\data\shared\jobs")

# Find all PRECAST files
precast_files = list(BASE_DIR.glob("*/functions/*_PRECAST.lua"))
precast_files = [f for f in precast_files if "PET_PRECAST" not in f.name and "DNC_PRECAST" not in f.name]

print(f"Found {len(precast_files)} PRECAST files to update\n")

# Pattern to find WS message display
OLD_PATTERN = re.compile(
    r"(\s+)-- Get current TP for display\s*\n"
    r"(\s+)local current_tp = player and player\.vitals and player\.vitals\.tp or 0\s*\n"
    r"(\s+)MessageFormatter\.show_ws_activated\(spell\.english, WS_DB\[spell\.english\]\.description, current_tp\)",
    re.MULTILINE
)

NEW_CODE = """            -- Check if enough TP before displaying WS message
            local current_tp = player and player.vitals and player.vitals.tp or 0
            if current_tp >= 1000 then
                -- Display WS message with current TP
                MessageFormatter.show_ws_activated(spell.english, WS_DB[spell.english].description, current_tp)
            else
                -- Not enough TP - display error
                MessageFormatter.show_ws_validation_error(spell.english, "Not enough TP", string.format("%d/1000", current_tp))
            end"""

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

        # Check if already has TP check
        if "if current_tp >= 1000 then" in content:
            print(f"  [OK] Already has TP check, skipping\n")
            skipped_count += 1
            continue

        # Check if has WS message pattern
        if not OLD_PATTERN.search(content):
            print(f"  [SKIP] No WS message pattern found\n")
            skipped_count += 1
            continue

        # Replace pattern
        content = OLD_PATTERN.sub(NEW_CODE, content)

        # Write updated content
        with open(precast_file, 'w', encoding='utf-8') as f:
            f.write(content)

        print(f"  [OK] Added TP check for WS messages\n")
        updated_count += 1

    except Exception as e:
        print(f"  [ERROR] {e}\n")

print("="*60)
print(f"Summary:")
print(f"  Updated: {updated_count}")
print(f"  Skipped: {skipped_count}")
print(f"  Total: {len(precast_files)}")
print("="*60)
