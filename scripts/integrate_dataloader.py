#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Integrate DataLoader into all job files
"""

import os
import re
from pathlib import Path

def integrate_dataloader_in_file(filepath):
    """Add require('shared/utils/data/data_loader') to a job file"""

    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        # Check if already integrated
        if "require('shared/utils/data/data_loader')" in content:
            return False, "Already integrated"

        # Find the pattern: include('../shared/utils/core/INIT_SYSTEMS.lua')
        # Add DataLoader require after it
        pattern = r"(include\(['\"]\.\.\/shared\/utils\/core\/INIT_SYSTEMS\.lua['\"]\))"

        if not re.search(pattern, content):
            # Try alternate pattern
            pattern = r"(include\('Mote-Include\.lua'\))"

        match = re.search(pattern, content)
        if not match:
            return False, "Could not find insertion point"

        # Insert DataLoader require after the matched line
        insertion_point = match.end()

        # Add the require statement
        dataloader_line = "\n\n    -- ============================================\n"
        dataloader_line += "    -- UNIVERSAL DATA ACCESS (All Spells/Abilities/Weaponskills)\n"
        dataloader_line += "    -- ============================================\n"
        dataloader_line += "    require('shared/utils/data/data_loader')"

        new_content = content[:insertion_point] + dataloader_line + content[insertion_point:]

        # Write back
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)

        return True, "Integrated successfully"

    except Exception as e:
        return False, f"Error: {str(e)}"

def main():
    script_dir = Path(__file__).parent
    base_path = script_dir.parent
    tetsouo_path = base_path / "Tetsouo"

    print("=" * 70)
    print("DATALOADER INTEGRATION - ALL JOBS")
    print("=" * 70)
    print()

    # Find all job files
    job_files = list(tetsouo_path.glob("Tetsouo_*.lua"))

    if not job_files:
        print("No job files found!")
        return

    print(f"Found {len(job_files)} job files:")
    for f in sorted(job_files):
        print(f"  - {f.name}")
    print()

    # Integrate DataLoader
    results = []
    for job_file in sorted(job_files):
        job_name = job_file.stem.replace('Tetsouo_', '')
        success, message = integrate_dataloader_in_file(job_file)

        results.append({
            'job': job_name,
            'success': success,
            'message': message
        })

        status = "[OK]" if success else "[SKIP]"
        print(f"{status} {job_name:12s} - {message}")

    print()
    print("=" * 70)

    success_count = sum(1 for r in results if r['success'])
    print(f"INTEGRATION COMPLETE: {success_count}/{len(results)} jobs updated")

    print("=" * 70)

if __name__ == "__main__":
    main()
