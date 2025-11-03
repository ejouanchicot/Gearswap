#!/usr/bin/env python3
"""
FFXI Spell Database Auditor - DEMO VERSION
===========================================
Tests first 3 spells from each magic type directory.

Usage:
    python audit_spells_demo.py
"""

import re
import requests
from bs4 import BeautifulSoup
import time
from pathlib import Path

MAGIC_DIR = Path("shared/data/magic")
BG_WIKI_BASE = "https://www.bg-wiki.com/ffxi/"
RATE_LIMIT_DELAY = 1.0

AUDIT_DIRS = ["dark", "divine", "elemental", "enfeebling", "enhancing", "geomancy", "healing", "song"]

def parse_lua_spell(filepath, max_spells=3):
    """Parse first N spells from Lua file."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    spells = {}
    spell_pattern = r'\["([^"]+)"\]\s*=\s*\{([^}]+(?:\{[^}]*\}[^}]*)*)\}'

    count = 0
    for match in re.finditer(spell_pattern, content, re.MULTILINE | re.DOTALL):
        if count >= max_spells:
            break

        spell_name = match.group(1)
        spell_block = match.group(2)

        spell_data = {'name': spell_name}

        desc_match = re.search(r'description\s*=\s*"([^"]*)"', spell_block)
        if desc_match:
            spell_data['description'] = desc_match.group(1)

        elem_match = re.search(r'element\s*=\s*"([^"]*)"', spell_block)
        if elem_match:
            spell_data['element'] = elem_match.group(1)

        spells[spell_name] = spell_data
        count += 1

    return spells

def fetch_bgwiki(spell_name):
    """Fetch spell from bg-wiki."""
    url_name = spell_name.replace(' ', '_').replace("'", "%27")
    url = f"{BG_WIKI_BASE}{url_name}"

    try:
        time.sleep(RATE_LIMIT_DELAY)
        response = requests.get(url, timeout=10)

        if response.status_code != 200:
            return None, url

        soup = BeautifulSoup(response.content, 'html.parser')

        desc_row = soup.find('th', string='Description')
        description = None
        if desc_row:
            desc_td = desc_row.find_next_sibling('td')
            if desc_td:
                description = desc_td.get_text(strip=True)

        return description, url

    except Exception as e:
        return None, url

def main():
    print("=" * 70)
    print("FFXI SPELL AUDITOR - DEMO (3 spells per directory)")
    print("=" * 70)

    total_checked = 0
    total_errors = 0

    for dir_name in AUDIT_DIRS:
        dir_path = MAGIC_DIR / dir_name

        if not dir_path.exists():
            print(f"\n[SKIP] {dir_name} (not found)")
            continue

        print(f"\n{'=' * 70}")
        print(f"AUDITING: {dir_name.upper()}")
        print(f"{'=' * 70}")

        lua_files = list(dir_path.glob('*.lua'))[:1]  # First file only

        for lua_file in lua_files:
            print(f"\n[FILE] {lua_file.name}")

            spells = parse_lua_spell(lua_file, max_spells=3)

            for spell_name, spell_data in spells.items():
                print(f"\n  Checking: {spell_name}...", end=' ', flush=True)

                wiki_desc, url = fetch_bgwiki(spell_name)

                total_checked += 1

                if not wiki_desc:
                    print("[WARN] Not found on wiki")
                    print(f"    URL: {url}")
                    continue

                local_desc = spell_data.get('description', '').lower()
                wiki_desc_lower = wiki_desc.lower()

                if local_desc and local_desc not in wiki_desc_lower and wiki_desc_lower not in local_desc:
                    print("[ERROR] Description mismatch")
                    print(f"    LOCAL: {spell_data.get('description', 'N/A')}")
                    print(f"    WIKI:  {wiki_desc}")
                    total_errors += 1
                else:
                    print("[OK]")

    print(f"\n{'=' * 70}")
    print("DEMO COMPLETE")
    print(f"{'=' * 70}")
    print(f"Checked: {total_checked} spells")
    print(f"Errors: {total_errors}")

if __name__ == '__main__':
    main()
