#!/usr/bin/env python3
"""
Complete Test Generator - Auto-generate job tests with JA + ALL spells
Reads JA databases AND magic databases to create comprehensive job tests
"""

import os
import re
from pathlib import Path
from collections import defaultdict

# Job list with their 3-letter codes
JOBS = [
    ('war', 'Warrior'), ('mnk', 'Monk'), ('whm', 'White Mage'), ('blm', 'Black Mage'),
    ('rdm', 'Red Mage'), ('thf', 'Thief'), ('pld', 'Paladin'), ('drk', 'Dark Knight'),
    ('bst', 'Beastmaster'), ('brd', 'Bard'), ('rng', 'Ranger'), ('sam', 'Samurai'),
    ('nin', 'Ninja'), ('drg', 'Dragoon'), ('smn', 'Summoner'), ('blu', 'Blue Mage'),
    ('cor', 'Corsair'), ('pup', 'Puppetmaster'), ('dnc', 'Dancer'), ('sch', 'Scholar'),
    ('geo', 'Geomancer'), ('run', 'Runemaster')
]

# Magic categories to scan
MAGIC_CATEGORIES = {
    'Elemental': 'elemental',
    'Healing': 'healing',
    'Enhancing': 'enhancing',
    'Enfeebling': 'enfeebling',
    'Divine': 'divine',
    'Dark': 'dark',
    'Blue': 'blu',
    'Songs': 'song',
    'Geomancy': 'geomancy',
    'Summoning': 'summoning'
}

def parse_ja_file(filepath):
    """Parse a Lua JA database file and extract abilities"""
    abilities = {}
    if not os.path.exists(filepath):
        return abilities

    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

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

def parse_spell_file(filepath):
    """Parse a Lua spell database file and extract spells with their jobs"""
    spells = []
    if not os.path.exists(filepath):
        return spells

    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find all spell definitions: ["Spell Name"] = { ... }
    # This regex captures multi-line spell blocks
    pattern = r'\["([^"]+)"\]\s*=\s*\{([^}]+)\}'
    matches = re.findall(pattern, content, re.DOTALL)

    for spell_name, spell_block in matches:
        spell_data = {'name': spell_name, 'jobs': {}}

        # Extract description
        desc_match = re.search(r'description\s*=\s*["\']([^"\']+)["\']', spell_block)
        if desc_match:
            spell_data['description'] = desc_match.group(1)

        # Extract category/magic_type
        category_match = re.search(r'(?:category|magic_type)\s*=\s*["\']([^"\']+)["\']', spell_block)
        if category_match:
            spell_data['category'] = category_match.group(1)

        # Extract element
        element_match = re.search(r'element\s*=\s*["\']([^"\']+)["\']', spell_block)
        if element_match:
            spell_data['element'] = element_match.group(1)

        # Extract jobs (look for uppercase 3-letter codes = number)
        job_pattern = r'([A-Z]{3})\s*=\s*(\d+)'
        job_matches = re.findall(job_pattern, spell_block)

        for job, level in job_matches:
            spell_data['jobs'][job] = int(level)

        if spell_data['jobs']:  # Only add if it has jobs
            spells.append(spell_data)

    return spells

def load_job_abilities(job_code, base_path):
    """Load all JA files for a job"""
    job_dir = base_path / 'shared' / 'data' / 'job_abilities' / job_code
    abilities = {}

    if not job_dir.exists():
        return abilities

    for suffix in ['mainjob', 'subjob', 'sp']:
        filepath = job_dir / f'{job_code}_{suffix}.lua'
        job_abilities = parse_ja_file(filepath)
        abilities.update(job_abilities)

    return abilities

def load_all_spells(base_path):
    """Load all spells from all magic categories"""
    magic_dir = base_path / 'shared' / 'data' / 'magic'
    all_spells = defaultdict(list)  # category >> [spells]

    if not magic_dir.exists():
        return all_spells

    # Recursively find all .lua files in magic directory
    for lua_file in magic_dir.rglob('*.lua'):
        # Skip database aggregator files
        if lua_file.name.startswith('_') or 'DATABASE' in lua_file.name.upper():
            continue

        spells = parse_spell_file(lua_file)

        # Determine category from path
        relative_path = lua_file.relative_to(magic_dir)
        category = relative_path.parts[0] if relative_path.parts else 'unknown'

        all_spells[category].extend(spells)

    return all_spells

def get_element_color(element):
    """Map element name to FFXI color code"""
    element_colors = {
        'Fire': 2,
        'Ice': 210,      # Cyan - more visible than 30
        'Wind': 14,
        'Earth': 37,
        'Thunder': 16,
        'Lightning': 16,
        'Water': 219,
        'Light': 187,
        'Dark': 200,
    }
    return element_colors.get(element)

def group_spells_by_job(all_spells):
    """Group all spells by job"""
    job_spells = defaultdict(lambda: defaultdict(list))  # job >> category >> [spells]

    for category, spells in all_spells.items():
        for spell in spells:
            for job_code in spell['jobs'].keys():
                job_spells[job_code][category].append(spell)

    return job_spells

def generate_complete_test_file(job_code, job_name, abilities, job_spells):
    """Generate a complete test file for a job (JA + all spells)"""
    job_upper = job_code.upper()

    lines = [
        "---============================================================================",
        f"--- {job_upper} Test Suite - {job_name} Complete Tests",
        "---============================================================================",
        f"--- Tests all {job_upper} job abilities and spells",
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
    ]

    # SECTION 1: Job Abilities
    if abilities:
        lines.extend([
            "    ---========================================================================",
            f"    --- {job_upper} JOB ABILITIES",
            "    ---========================================================================",
            "",
            '    add_to_chat(121, " ")',
            f'    add_to_chat(121, cyan .. "{job_upper} Job Abilities ({len(abilities)}):")',
            "",
        ])

        for name, description in sorted(abilities.items()):
            name_escaped = name.replace("'", "\\'")
            desc_escaped = description.replace("'", "\\'")
            lines.append(f"    test(function() M.send('JA_BUFFS', 'activated_full', {{job_tag = '{job_upper}', ability_name = '{name_escaped}', description = '{desc_escaped}'}}) end)")

        lines.extend([
            f"    total = total + {len(abilities)}",
            "",
        ])

    # SECTION 2-N: Spells by category
    category_map = {
        'elemental': ('ELEMENTAL MAGIC', 'MAGIC', 'spell_activated_full'),
        'healing': ('HEALING MAGIC', 'MAGIC', 'healing_spell_activated_full'),
        'enhancing': ('ENHANCING MAGIC', 'MAGIC', 'enhancing_spell_activated_full'),
        'enfeebling': ('ENFEEBLING MAGIC', 'MAGIC', 'enfeebling_spell_activated_full_target'),
        'divine': ('DIVINE MAGIC', 'MAGIC', 'divine_spell_activated_full_target'),
        'dark': ('DARK MAGIC', 'MAGIC', 'dark_spell_activated_full_target'),
        'blu': ('BLUE MAGIC', 'MAGIC', 'blue_spell_activated_full'),
        'song': ('SONGS', 'MAGIC', 'spell_activated_full'),
        'geomancy': ('GEOMANCY', 'GEO', 'indi_cast'),
    }

    for category, spells in sorted(job_spells.items()):
        if not spells:
            continue

        category_info = category_map.get(category, (category.upper(), 'MAGIC', 'spell_activated_full'))
        section_title, namespace, template = category_info

        lines.extend([
            "",
            "    ---========================================================================",
            f"    --- {job_upper} {section_title}",
            "    ---========================================================================",
            "",
            '    add_to_chat(121, " ")',
            f'    add_to_chat(121, cyan .. "{job_upper} {section_title.title()} ({len(spells)}):")',
            "",
        ])

        for spell in sorted(spells, key=lambda s: s['name']):
            spell_name = spell['name'].replace("'", "\\'")
            spell_desc = spell.get('description', 'Unknown effect').replace("'", "\\'")

            # Apply color to spell name based on element
            colored_spell_name = None

            if 'element' in spell:
                # All magic uses element color
                element = spell['element']
                color_code = get_element_color(element)
                if color_code:
                    colored_spell_name = f'string.char(0x1F, {color_code}) .. "{spell_name}" .. gray_code'

            # Build the test call
            if colored_spell_name:
                # Has element color
                if 'target' in template:
                    lines.append(f"    test(function() M.send('{namespace}', '{template}', {{job = '{job_upper}', spell = {colored_spell_name}, description = '{spell_desc}', target = '<t>'}}) end)")
                else:
                    lines.append(f"    test(function() M.send('{namespace}', '{template}', {{job = '{job_upper}', spell = {colored_spell_name}, description = '{spell_desc}'}}) end)")
            else:
                # No color
                if 'target' in template:
                    lines.append(f"    test(function() M.send('{namespace}', '{template}', {{job = '{job_upper}', spell = '{spell_name}', description = '{spell_desc}', target = '<t>'}}) end)")
                else:
                    lines.append(f"    test(function() M.send('{namespace}', '{template}', {{job = '{job_upper}', spell = '{spell_name}', description = '{spell_desc}'}}) end)")

        lines.extend([
            f"    total = total + {len(spells)}",
            "",
        ])

    lines.extend([
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
    print("Generating COMPLETE Test Suites (JA + Spells) from Databases")
    print("=" * 74)
    print()
    print("Phase 1: Loading all spells from magic databases...")

    all_spells = load_all_spells(base_path)
    print(f"  Loaded {sum(len(s) for s in all_spells.values())} total spells from {len(all_spells)} categories")

    print("\nPhase 2: Grouping spells by job...")
    job_spells_map = group_spells_by_job(all_spells)

    print("\nPhase 3: Generating test files...")
    print()

    total_jobs = 0
    total_abilities = 0
    total_spells = 0

    for job_code, job_name in JOBS:
        # Load JA
        abilities = load_job_abilities(job_code, base_path)

        # Get spells for this job
        job_spells = job_spells_map.get(job_code.upper(), {})

        spell_count = sum(len(spells) for spells in job_spells.values())

        if not abilities and not job_spells:
            print(f"[SKIP] {job_name.upper():20s} No abilities or spells found")
            continue

        content = generate_complete_test_file(job_code, job_name, abilities, job_spells)

        if content:
            output_file = output_dir / f'test_{job_code}.lua'
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(content)

            ja_count = len(abilities)
            print(f"[OK] {job_name.upper():20s} {ja_count:3d} JA + {spell_count:3d} spells = {ja_count + spell_count:3d} total >> test_{job_code}.lua")
            total_jobs += 1
            total_abilities += ja_count
            total_spells += spell_count

    print()
    print("=" * 74)
    print(f"Generated {total_jobs} complete test suites")
    print(f"  {total_abilities} Job Abilities")
    print(f"  {total_spells} Spells")
    print(f"  {total_abilities + total_spells} TOTAL TESTS")
    print("=" * 74)

if __name__ == '__main__':
    main()
