#!/usr/bin/env python3
"""
Simplify Spell Descriptions
============================
Automatically simplifies all spell descriptions by removing redundant information.

Rules:
- Remove element name (already in element field)
- Remove target type (already in type field)
- Remove "for party members within area of effect"
- Shorten generic patterns: "Deals fire damage" >> "Deals damage"

Usage:
    python simplify_descriptions.py [--dry-run]
"""

import re
import sys
from pathlib import Path
from typing import Tuple

MAGIC_DIR = Path("shared/data/magic")

SIMPLIFICATION_RULES = [
    # Shorten common phrases FIRST (before removing possessives)
    (r'\bspellcasting time\b', 'cast time'),
    (r'\battack speed\b', 'attack speed'),
    (r'\bmovement speed\b', 'movement speed'),

    # Replace "and" with comma in multi-effect descriptions
    (r'\s+and\s+', ', '),

    # Remove possessive phrases BEFORE verb replacement (an enemy's, target's, its, their, etc.)
    (r"(?:an?|the) (?:enemy|party member|target|ally)(?:'s|s') ", ''),
    (r"\btarget'?s?\s+", ''),
    (r'\b(?:its|their|his|her)\s+', ''),

    # Shorten verbs: Decreases/Reduces >> Lowers, Increases >> Raises
    (r'\b(Decreases?|Reduces?)\b', 'Lowers'),
    (r'\b(Increases?)\b', 'Raises'),
    (r'\b(Enhances?)\b', 'Enhances'),

    # Remove redundant target phrases at END of sentence
    (r'\s+(?:for party members?|to (?:an? )?(?:party members?|enemies?|targets?|allies))\.?$', '.'),
    (r'\s+within (?:the )?area of effect\.?$', '.'),
    (r'\s+to (?:a|an) single (?:enemy|target|party member)\.?$', '.'),

    # Ultra-aggressive simplifications
    (r'^Deals damage that ', ''),  # Remove "Deals damage that" prefix entirely
    (r'^Deals \w+ damage\.?$', 'Deals damage.'),  # "Deals fire damage" >> "Deals damage"
    (r'\bgradually Lowers HP', 'drains HP'),  # "gradually Lowers HP" >> "drains HP"
    (r'\bgradually Lowers MP', 'drains MP'),  # "gradually Lowers MP" >> "drains MP"
    (r'^Restores HP', 'Restores HP'),
    (r'^Restores MP', 'Restores MP'),
    (r'^Gradually restores HP', 'Restores HP'),  # Remove "gradually"
    (r'^Gradually restores MP', 'Restores MP'),  # Remove "gradually"

    # Smart patterns - capture object including multi-word phrases
    # Match: "Raises/Lowers/Enhances [object] for/to/within..."
    # Keep: "Raises/Lowers/Enhances [object]"
    (r'^(Raises|Lowers|Enhances) ([^.]+?)(?:\s+(?:for|to|within|of)\s+.+)?\.?$', r'\1 \2.'),

    # Clean up extra whitespace
    (r'\s+', ' '),

    # Fix double periods
    (r'\.+', '.'),
]

def simplify_description(description: str, element: str = None, target_type: str = None) >> str:
    """Simplify a spell description."""
    if not description:
        return description

    desc = description.strip()

    # Remove element name if present in metadata
    if element:
        desc = re.sub(rf'\b{element.lower()}\b\s*', '', desc, flags=re.I)

    # Apply all simplification rules
    for pattern, replacement in SIMPLIFICATION_RULES:
        desc = re.sub(pattern, replacement, desc, flags=re.I)

    # Clean up whitespace
    desc = re.sub(r'\s+', ' ', desc).strip()

    # Capitalize first letter
    if desc:
        desc = desc[0].upper() + desc[1:] if len(desc) > 1 else desc.upper()

    # Ensure ends with period
    if desc and not desc.endswith('.'):
        desc += '.'

    return desc

def process_lua_file(filepath: Path, dry_run: bool = False) >> Tuple[int, int]:
    """Process a single Lua file and simplify descriptions."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    changes_made = 0
    total_spells = 0

    # Find all spell blocks
    spell_pattern = r'(\["[^"]+"\]\s*=\s*\{[^}]+description\s*=\s*)"([^"]+)"'

    def replace_description(match):
        nonlocal changes_made, total_spells
        total_spells += 1

        prefix = match.group(1)
        old_desc = match.group(2)

        # Try to extract element and type from the same spell block
        spell_block_start = match.start()
        spell_block_end = content.find('},', spell_block_start)
        spell_block = content[spell_block_start:spell_block_end]

        element = None
        elem_match = re.search(r'element\s*=\s*"([^"]*)"', spell_block)
        if elem_match:
            element = elem_match.group(1)

        target_type = None
        type_match = re.search(r'type\s*=\s*"([^"]*)"', spell_block)
        if type_match:
            target_type = type_match.group(1)

        new_desc = simplify_description(old_desc, element, target_type)

        if new_desc != old_desc:
            changes_made += 1
            if dry_run:
                print(f"  [{filepath.name}]")
                print(f"    OLD: {old_desc}")
                print(f"    NEW: {new_desc}")
                print()

        return f'{prefix}"{new_desc}"'

    content = re.sub(spell_pattern, replace_description, content)

    if not dry_run and content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)

    return total_spells, changes_made

def main():
    dry_run = '--dry-run' in sys.argv or '-n' in sys.argv

    print("=" * 70)
    print("SPELL DESCRIPTION SIMPLIFIER")
    print("=" * 70)
    if dry_run:
        print("MODE: DRY RUN (no files will be modified)")
    else:
        print("MODE: LIVE (files will be modified)")
    print()

    total_spells = 0
    total_changes = 0
    total_files = 0

    audit_dirs = ["dark", "divine", "elemental", "enfeebling", "enhancing", "geomancy", "healing", "song"]

    for dir_name in audit_dirs:
        dir_path = MAGIC_DIR / dir_name

        if not dir_path.exists():
            continue

        print(f"Processing: {dir_name}/")

        for lua_file in sorted(dir_path.glob('*.lua')):
            spells, changes = process_lua_file(lua_file, dry_run)

            if changes > 0:
                total_files += 1
                total_spells += spells
                total_changes += changes
                status = "[PREVIEW]" if dry_run else "[MODIFIED]"
                print(f"  {status} {lua_file.name}: {changes}/{spells} descriptions simplified")

    print()
    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print(f"Files processed: {total_files}")
    print(f"Spells checked: {total_spells}")
    print(f"Descriptions simplified: {total_changes}")

    if dry_run:
        print()
        print("Run without --dry-run to apply changes.")
    else:
        print()
        print("[OK] All changes applied successfully!")

if __name__ == '__main__':
    main()
