#!/usr/bin/env python3
"""
Count job abilities and weaponskills in all database files
"""

import re
from pathlib import Path

def count_entries_in_file(filepath):
    """Count entries in a Lua file."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        # Count entries: ["Name"] = { or ['Name'] = {
        pattern = r'\[[\'""][^\'"]+[\'""]\]\s*=\s*\{'
        matches = re.findall(pattern, content)
        return len(matches)
    except Exception as e:
        print(f"[ERROR] {filepath}: {e}")
        return 0

def scan_directory(base_path, category_name):
    """Scan a directory and count entries in all Lua files."""
    dir_path = base_path

    if not dir_path.exists():
        print(f"[SKIP] {category_name} (not found)")
        return {}

    results = {}

    # Get all Lua files recursively
    lua_files = list(dir_path.rglob('*.lua'))

    for lua_file in lua_files:
        # Skip internal directories
        if 'internal' in str(lua_file):
            continue

        count = count_entries_in_file(lua_file)
        if count > 0:
            relative_path = lua_file.relative_to(dir_path.parent)
            results[str(relative_path)] = count

    return results

def main():
    print("=" * 70)
    print("FFXI JOB ABILITIES & WEAPONSKILLS COUNTER")
    print("=" * 70)

    categories = {
        'Job Abilities': Path("shared/data/job_abilities"),
        'Weaponskills': Path("shared/data/weaponskills")
    }

    grand_total = 0

    for category_name, base_path in categories.items():
        print(f"\n{'=' * 70}")
        print(f"{category_name.upper()}")
        print("=" * 70)

        results = scan_directory(base_path, category_name)

        if results:
            subtotal = 0

            # Group by subdirectory
            by_subdir = {}
            for file_path, count in results.items():
                parts = Path(file_path).parts
                if len(parts) > 2:  # Has subdirectory
                    subdir = parts[2]  # e.g., 'war', 'pld'
                    if subdir not in by_subdir:
                        by_subdir[subdir] = []
                    by_subdir[subdir].append((file_path, count))
                else:
                    # Root level database file
                    if 'root' not in by_subdir:
                        by_subdir['root'] = []
                    by_subdir['root'].append((file_path, count))

            # Print organized by subdirectory
            for subdir in sorted(by_subdir.keys()):
                if subdir != 'root':
                    print(f"\n  [{subdir.upper()}]")

                subdir_total = 0
                for file_path, count in sorted(by_subdir[subdir]):
                    filename = Path(file_path).name
                    print(f"    {filename}: {count} entries")
                    subdir_total += count

                if len(by_subdir[subdir]) > 1:
                    print(f"    Subtotal: {subdir_total} entries")

                subtotal += subdir_total

            print(f"\n  TOTAL {category_name.upper()}: {subtotal} entries")
            grand_total += subtotal
        else:
            print(f"  No files found")

    print("\n" + "=" * 70)
    print("GRAND TOTAL")
    print("=" * 70)
    print(f"  TOTAL ENTRIES: {grand_total}")
    print("=" * 70)

if __name__ == '__main__':
    main()
