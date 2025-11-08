#!/usr/bin/env python3
"""
Test Generator - Auto-generate all job test suites from JA databases
Reads Lua JA database files and generates comprehensive test suites
"""

import os
import re
from pathlib import Path

# Job list with their 3-letter codes
JOBS = [
    ('war', 'Warrior'), ('mnk', 'Monk'), ('whm', 'White Mage'), ('blm', 'Black Mage'),
    ('rdm', 'Red Mage'), ('thf', 'Thief'), ('pld', 'Paladin'), ('drk', 'Dark Knight'),
    ('bst', 'Beastmaster'), ('brd', 'Bard'), ('rng', 'Ranger'), ('sam', 'Samurai'),
    ('nin', 'Ninja'), ('drg', 'Dragoon'), ('smn', 'Summoner'), ('blu', 'Blue Mage'),
    ('cor', 'Corsair'), ('pup', 'Puppetmaster'), ('dnc', 'Dancer'), ('sch', 'Scholar'),
    ('geo', 'Geomancer'), ('run', 'Runemaster')
]

def parse_ja_file(filepath):
    """Parse a Lua JA database file and extract abilities"""
    abilities = {}

    if not os.path.exists(filepath):
        return abilities

    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find all ability definitions: ['Name'] = { description = '...' } or description = "..."
    # Try single quotes first
    pattern_single = r"\['([^']+)'\]\s*=\s*\{[^}]*description\s*=\s*'([^']+)'"
    matches = re.findall(pattern_single, content)

    # If no matches, try double quotes
    if not matches:
        pattern_double = r'\[\'([^\']+)\'\]\s*=\s*\{[^}]*description\s*=\s*"([^"]+)"'
        matches = re.findall(pattern_double, content)

    for name, desc in matches:
        abilities[name] = desc

    return abilities

def load_job_abilities(job_code, base_path):
    """Load all JA files for a job"""
    job_dir = base_path / 'shared' / 'data' / 'job_abilities' / job_code
    abilities = {}

    if not job_dir.exists():
        return abilities

    # Try loading main job, subjob, and SP abilities
    for suffix in ['mainjob', 'subjob', 'sp']:
        filepath = job_dir / f'{job_code}_{suffix}.lua'
        job_abilities = parse_ja_file(filepath)
        abilities.update(job_abilities)

    return abilities

def generate_test_file(job_code, job_name, abilities):
    """Generate a test file for a job"""
    job_upper = job_code.upper()
    ability_count = len(abilities)

    if ability_count == 0:
        return None

    lines = [
        "---============================================================================",
        f"--- {job_upper} Test Suite - {job_name} Job Messages",
        "---============================================================================",
        f"--- Tests all {job_upper} job abilities",
        "---",
        f"--- @file tests/test_{job_code}.lua",
        "--- @author Tetsouo (Auto-generated)",
        "--- @date Created: 2025-11-08",
        "---============================================================================",
        "",
        "local M = require('shared/utils/messages/api/messages')",
        "",
        f"local Test{job_upper} = {{}}",
        "",
        f"--- Run all {job_upper} tests",
        "--- @param test function Test runner function",
        "--- @return number total_tests Total number of tests",
        f"function Test{job_upper}.run(test)",
        "    local gray_code = string.char(0x1F, 160)",
        "    local cyan = string.char(0x1F, 13)",
        "    local total = 0",
        "",
        "    ---========================================================================",
        f"    --- {job_upper} JOB ABILITIES",
        "    ---========================================================================",
        "",
        '    add_to_chat(121, " ")',
        f'    add_to_chat(121, cyan .. "{job_upper} Job Abilities ({ability_count}):")',
        "",
    ]

    # Add test for each ability
    for name, description in sorted(abilities.items()):
        # Escape single quotes in ability names and descriptions
        name_escaped = name.replace("'", "\\'")
        desc_escaped = description.replace("'", "\\'")
        lines.append(f"    test(function() M.send('JA_BUFFS', 'activated_full', {{job_tag = '{job_upper}', ability_name = '{name_escaped}', description = '{desc_escaped}'}}) end)")

    lines.extend([
        f"    total = total + {ability_count}",
        "",
        "    return total",
        "end",
        "",
        f"return Test{job_upper}",
        ""
    ])

    return '\n'.join(lines)

def main():
    base_path = Path(__file__).parent
    output_dir = base_path / 'shared' / 'utils' / 'messages' / 'api' / 'tests'
    output_dir.mkdir(parents=True, exist_ok=True)

    print("=" * 74)
    print("Generating Test Suites from JA Databases")
    print("=" * 74)
    print()

    total_jobs = 0
    total_abilities = 0

    for job_code, job_name in JOBS:
        abilities = load_job_abilities(job_code, base_path)

        if not abilities:
            print(f"[X] {job_name.upper():20s} No abilities found")
            continue

        content = generate_test_file(job_code, job_name, abilities)

        if content:
            output_file = output_dir / f'test_{job_code}.lua'
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(content)

            print(f"[OK] {job_name.upper():20s} {len(abilities):3d} abilities >> test_{job_code}.lua")
            total_jobs += 1
            total_abilities += len(abilities)

    print()
    print("=" * 74)
    print(f"Generated {total_jobs} test suites with {total_abilities} total abilities")
    print("=" * 74)

if __name__ == '__main__':
    main()
