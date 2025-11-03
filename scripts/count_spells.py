#!/usr/bin/env python3
"""
Count spells in all database files
"""

import re
from pathlib import Path

def count_spells_in_file(filepath):
    """Count spell entries in a Lua file."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        # Count spell entries: ["Spell Name"] = {
        spell_pattern = r'\["[^"]+"\]\s*=\s*\{'
        matches = re.findall(spell_pattern, content)
        return len(matches)
    except Exception as e:
        print(f"[ERROR] {filepath}: {e}")
        return 0

def scan_directory(base_path, directory_name):
    """Scan a directory and count spells in all Lua files."""
    dir_path = base_path / directory_name

    if not dir_path.exists():
        print(f"[SKIP] {directory_name} (not found)")
        return {}

    results = {}

    # Get all Lua files recursively
    lua_files = list(dir_path.rglob('*.lua'))

    for lua_file in lua_files:
        count = count_spells_in_file(lua_file)
        if count > 0:
            relative_path = lua_file.relative_to(base_path)
            results[str(relative_path)] = count

    return results

def main():
    print("=" * 70)
    print("FFXI SPELL COUNTER")
    print("=" * 70)

    base_path = Path("shared/data/magic")

    # Directories to scan
    directories = [
        "dark",
        "divine",
        "elemental",
        "enfeebling",
        "enhancing",
        "geomancy",
        "healing",
        "song",
        "blu",
        "summoning"
    ]

    grand_total = 0
    all_results = {}

    for dir_name in directories:
        print(f"\n[SCAN] {dir_name.upper()}")
        print("-" * 70)

        results = scan_directory(base_path, dir_name)

        if results:
            subtotal = 0
            for file_path, count in sorted(results.items()):
                print(f"  {file_path}: {count} spells")
                subtotal += count

            print(f"  SUBTOTAL: {subtotal} spells")
            grand_total += subtotal
            all_results[dir_name] = subtotal
        else:
            print(f"  No spell files found")

    print("\n" + "=" * 70)
    print("SUMMARY")
    print("=" * 70)

    for dir_name, count in sorted(all_results.items()):
        print(f"  {dir_name.upper():15s} {count:4d} spells")

    print("-" * 70)
    print(f"  TOTAL:          {grand_total:4d} spells")
    print("=" * 70)

    # Expected totals
    expected = {
        'dark': 26,
        'divine': 12,
        'elemental': 115,
        'enfeebling': 35,
        'enhancing': 139,
        'geomancy': 60,
        'healing': 32,
        'song': 107,
        'blu': 196,
        'summoning': 136
    }

    expected_total = sum(expected.values())

    print(f"\nEXPECTED: {expected_total} spells")
    print(f"FOUND:    {grand_total} spells")

    if grand_total == expected_total:
        print("\n[OK] All spells accounted for!")
    else:
        print(f"\n[WARN] Missing {expected_total - grand_total} spells")

        # Show differences
        print("\nDIFFERENCES:")
        for category, exp_count in expected.items():
            actual_count = all_results.get(category, 0)
            if actual_count != exp_count:
                diff = actual_count - exp_count
                sign = "+" if diff > 0 else ""
                print(f"  {category.upper():15s} Expected: {exp_count:3d}, Found: {actual_count:3d} ({sign}{diff})")

if __name__ == '__main__':
    main()
