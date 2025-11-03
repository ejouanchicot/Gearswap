#!/usr/bin/env python3
"""Organize documentation files"""
import os
import shutil

# Define base path
base_path = r"D:\Windower Tetsouo\addons\GearSwap\data"
os.chdir(base_path)

# Create directories
os.makedirs("docs/fixes", exist_ok=True)
os.makedirs("docs/archives", exist_ok=True)

# Files to move to docs/fixes (important fixes)
to_fixes = [
    "UNIFIED_ABILITY_MESSAGES_COMPLETE.md",
    "DATABASE_FACADES_AUDIT.md",
    "ABILITY_MESSAGES_FINAL_FIX.md",
    "DNC_ABILITIES_FIX.md",
    "BLOOD_PACTS_COMPLETE_SOLUTION.md",
    "BLU_SPELL_MESSAGES_FIX.md",
    "SUMMONING_DATABASE_FIX.md",
]

# Files to move to docs/archives (obsolete/redundant)
to_archives = [
    "ABILITY_MESSAGES_DUPLICATE_FIX.md",
    "BLOOD_PACTS_ACTION_TYPE_FIX.md",
    "BLOOD_PACTS_FIX.md",
    "SUMMONING_SPELL_MESSAGES_FIX.md",
    "ABILITY_MESSAGES_SYSTEM.md",
    "DUPLICATE_DEBUG_GUIDE.md",
    "TEST_BLOOD_PACTS_INGAME.md",
    "TESTING_REQUIRED.md",
]

# Files to move to docs (summaries)
to_docs = [
    "SESSION_COMPLETE_SUMMARY.md",
    "FINAL_TESTING_CHECKLIST.md",
]

# Files to delete (redundant audits)
to_delete = [
    "COMPLETE_DATA_AUDIT.md",
    "DATA_ACCESS_AUDIT_FINAL.md",
    "DATA_AUDIT_REPORT.md",
    "DATA_USAGE_AUDIT.md",
    "DATALOADER_INTEGRATION_COMPLETE.md",
    "test_blood_pacts.lua",
]

# Move to fixes
for file in to_fixes:
    if os.path.exists(file):
        shutil.move(file, f"docs/fixes/{file}")
        print(f"[OK] Moved {file} -> docs/fixes/")

# Move to archives
for file in to_archives:
    if os.path.exists(file):
        shutil.move(file, f"docs/archives/{file}")
        print(f"[ARCHIVE] Moved {file} -> docs/archives/")

# Move to docs
for file in to_docs:
    if os.path.exists(file):
        shutil.move(file, f"docs/{file}")
        print(f"[DOC] Moved {file} -> docs/")

# Delete redundant
for file in to_delete:
    if os.path.exists(file):
        os.remove(file)
        print(f"[DELETE] Deleted {file}")

print("\n[OK] Organization complete!")
print(f"\ndocs/fixes/    -> {len([f for f in to_fixes if os.path.exists(f'docs/fixes/{f}')])} files")
print(f"docs/archives/ -> {len([f for f in to_archives if os.path.exists(f'docs/archives/{f}')])} files")
print(f"docs/          -> {len([f for f in to_docs if os.path.exists(f'docs/{f}')])} files")
print(f"Deleted        -> {len([f for f in to_delete if not os.path.exists(f)])} files")
