#!/usr/bin/env python3
"""
Integrate ability message handler into all job files
"""

import re
from pathlib import Path

def integrate_ability_messages_in_file(filepath):
    """Add ability messages hook to a job file."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        # Check if already integrated
        if "init_ability_messages.lua" in content:
            return False, "Already integrated"

        # Find the spell messages hook line
        pattern = r"(include\(['\"]\.\.\/shared\/hooks\/init_spell_messages\.lua['\"]\))"

        if not re.search(pattern, content):
            return False, "Could not find init_spell_messages.lua include"

        # Insert ability messages hook after spell messages hook
        ability_hook_block = "\n\n    -- ============================================\n"
        ability_hook_block += "    -- UNIVERSAL ABILITY MESSAGES (All Jobs/Subjobs)\n"
        ability_hook_block += "    -- ============================================\n"
        ability_hook_block += "    include('../shared/hooks/init_ability_messages.lua')"

        # Replace: add ability hook after spell hook
        new_content = re.sub(
            pattern,
            r"\1" + ability_hook_block,
            content
        )

        # Write back
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)

        return True, "Integrated"

    except Exception as e:
        return False, f"Error: {e}"

def main():
    print("=" * 70)
    print("ABILITY MESSAGES INTEGRATION")
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

        success, message = integrate_ability_messages_in_file(filepath)
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
    print(f"  TOTAL: {success_count}/{len(jobs)} jobs integrated")
    print("=" * 70)

if __name__ == '__main__':
    main()
