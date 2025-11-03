#!/usr/bin/env python3
"""
Add spell and ability message hooks to all job files
"""

import re
from pathlib import Path

def add_message_hooks_to_file(filepath):
    """Add both spell and ability message hooks to a job file."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        # Check if already has both hooks
        has_spell_hook = "init_spell_messages.lua" in content
        has_ability_hook = "init_ability_messages.lua" in content

        if has_spell_hook and has_ability_hook:
            return False, "Already has both hooks"

        # Find the DataLoader line
        pattern = r"(require\(['\"]shared\/utils\/data\/data_loader['\"]\))"

        if not re.search(pattern, content):
            return False, "Could not find data_loader require"

        # Prepare hooks block
        hooks_block = ""

        if not has_spell_hook:
            hooks_block += "\n\n    -- ============================================\n"
            hooks_block += "    -- UNIVERSAL SPELL MESSAGES (All Jobs/Subjobs)\n"
            hooks_block += "    -- ============================================\n"
            hooks_block += "    include('../shared/hooks/init_spell_messages.lua')"

        if not has_ability_hook:
            hooks_block += "\n\n    -- ============================================\n"
            hooks_block += "    -- UNIVERSAL ABILITY MESSAGES (All Jobs/Subjobs)\n"
            hooks_block += "    -- ============================================\n"
            hooks_block += "    include('../shared/hooks/init_ability_messages.lua')"

        # Insert hooks after DataLoader
        new_content = re.sub(
            pattern,
            r"\1" + hooks_block,
            content
        )

        # Write back
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)

        added = []
        if not has_spell_hook:
            added.append("spell")
        if not has_ability_hook:
            added.append("ability")

        return True, f"Added {' + '.join(added)} hooks"

    except Exception as e:
        return False, f"Error: {e}"

def main():
    print("=" * 70)
    print("MESSAGE HOOKS INTEGRATION")
    print("=" * 70)

    # All job files to update
    jobs = ['BLM', 'BRD', 'BST', 'COR', 'DNC', 'DRK', 'GEO', 'PLD', 'RDM', 'SAM', 'THF', 'WAR', 'WHM']

    base_path = Path("Tetsouo")
    results = []

    for job in jobs:
        filepath = base_path / f"Tetsouo_{job}.lua"

        if not filepath.exists():
            results.append((job, "[SKIP]", "File not found"))
            continue

        success, message = add_message_hooks_to_file(filepath)
        status = "[OK]" if success else "[SKIP]"
        results.append((job, status, message))

    # Print results
    print("\nRESULTS:")
    print("-" * 70)

    success_count = 0
    for job, status, message in results:
        print(f"  {job:4s} {status:7s} {message}")
        if status == "[OK]":
            success_count += 1

    print("-" * 70)
    print(f"  TOTAL: {success_count}/{len(jobs)} jobs updated")
    print("=" * 70)

if __name__ == '__main__':
    main()
