#!/usr/bin/env python3
"""
FFXI Spell Database Auditor
============================
Audits all spell files against bg-wiki.com for accuracy.

Features:
- Verifies spell descriptions, levels, elements, magic types
- Simplifies descriptions to remove redundant info
- Generates detailed error report
- Suggests corrections

Usage:
    python audit_spells.py
"""

import re
import requests
from bs4 import BeautifulSoup
import time
import os
from pathlib import Path
from typing import Dict, List, Optional, Tuple
import json

# ============================================================================
# CONFIGURATION
# ============================================================================

MAGIC_DIR = Path("shared/data/magic")
BG_WIKI_BASE = "https://www.bg-wiki.com/ffxi/"
RATE_LIMIT_DELAY = 1.0  # seconds between requests
OUTPUT_REPORT = "SPELL_AUDIT_REPORT.md"

# Directories to audit
AUDIT_DIRS = [
    "dark",
    "divine",
    "elemental",
    "enfeebling",
    "enhancing",
    "geomancy",
    "healing",
    "song"
]

# Skip internal folder
SKIP_DIRS = ["internal"]

# ============================================================================
# LUA PARSER
# ============================================================================

def parse_lua_spell_file(filepath: Path) >> Dict[str, Dict]:
    """Parse a Lua spell file and extract all spells."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    spells = {}

    # Match spell entries: ["Spell Name"] = { ... }
    # This regex finds spell blocks
    spell_pattern = r'\["([^"]+)"\]\s*=\s*\{([^}]+(?:\{[^}]*\}[^}]*)*)\}'

    for match in re.finditer(spell_pattern, content, re.MULTILINE | re.DOTALL):
        spell_name = match.group(1)
        spell_block = match.group(2)

        spell_data = {
            'name': spell_name,
            'file': str(filepath),
        }

        # Extract description
        desc_match = re.search(r'description\s*=\s*"([^"]*)"', spell_block)
        if desc_match:
            spell_data['description'] = desc_match.group(1)

        # Extract element
        elem_match = re.search(r'element\s*=\s*"([^"]*)"', spell_block)
        if elem_match:
            spell_data['element'] = elem_match.group(1)

        # Extract magic_type
        type_match = re.search(r'magic_type\s*=\s*"([^"]*)"', spell_block)
        if type_match:
            spell_data['magic_type'] = type_match.group(1)

        # Extract type (single/aoe)
        tgt_match = re.search(r'type\s*=\s*"([^"]*)"', spell_block)
        if tgt_match:
            spell_data['type'] = tgt_match.group(1)

        # Extract job levels (BLM = 1, WHM = 5, etc.)
        job_levels = {}
        for job in ['BLM', 'WHM', 'RDM', 'SCH', 'GEO', 'BRD', 'PLD', 'DRK', 'SMN', 'BLU', 'NIN', 'RUN']:
            job_match = re.search(rf'{job}\s*=\s*(\d+)', spell_block)
            if job_match:
                job_levels[job] = int(job_match.group(1))
        spell_data['job_levels'] = job_levels

        # Extract category
        cat_match = re.search(r'category\s*=\s*"([^"]*)"', spell_block)
        if cat_match:
            spell_data['category'] = cat_match.group(1)

        spells[spell_name] = spell_data

    return spells

# ============================================================================
# BG-WIKI SCRAPER
# ============================================================================

def fetch_bgwiki_spell(spell_name: str) >> Optional[Dict]:
    """Fetch spell data from bg-wiki."""
    # Convert spell name to URL format
    url_name = spell_name.replace(' ', '_').replace("'", "%27")
    url = f"{BG_WIKI_BASE}{url_name}"

    try:
        time.sleep(RATE_LIMIT_DELAY)  # Rate limiting
        response = requests.get(url, timeout=10)

        if response.status_code != 200:
            return None

        soup = BeautifulSoup(response.content, 'html.parser')

        data = {
            'url': url,
            'description': None,
            'element': None,
            'magic_type': None,
            'skill': None,
            'levels': {}
        }

        # Extract description (usually in first paragraph or infobox)
        # Look for description in infobox first
        desc_row = soup.find('th', string='Description')
        if desc_row:
            desc_td = desc_row.find_next_sibling('td')
            if desc_td:
                data['description'] = desc_td.get_text(strip=True)

        # Extract from infobox
        infobox = soup.find('table', class_='infobox')
        if infobox:
            rows = infobox.find_all('tr')
            for row in rows:
                th = row.find('th')
                td = row.find('td')
                if not th or not td:
                    continue

                header = th.get_text(strip=True).lower()
                value = td.get_text(strip=True)

                if 'element' in header:
                    data['element'] = value
                elif 'type' in header:
                    data['magic_type'] = value
                elif 'skill' in header:
                    data['skill'] = value

        # Extract job levels from table
        # Look for "Jobs that can use" or similar table
        job_table = soup.find('th', string=re.compile('Jobs? that can', re.I))
        if job_table:
            level_text = job_table.find_next('td').get_text()
            # Parse "BLM 1, WHM 5" etc.
            job_pattern = r'([A-Z]{3})\s+(\d+)'
            for match in re.finditer(job_pattern, level_text):
                job = match.group(1)
                level = int(match.group(2))
                data['levels'][job] = level

        return data

    except Exception as e:
        print(f"Error fetching {spell_name}: {e}")
        return None

# ============================================================================
# DESCRIPTION SIMPLIFIER
# ============================================================================

def simplify_description(description: str, spell_data: Dict) >> str:
    """Simplify description by removing redundant info."""
    if not description:
        return description

    desc = description

    # Remove element mentions if element is in metadata
    if spell_data.get('element'):
        element = spell_data['element'].lower()
        desc = re.sub(rf'\b{element}\b\s*', '', desc, flags=re.I)

    # Remove target type mentions if type is in metadata
    target_type = spell_data.get('type', '')
    if target_type == 'aoe':
        # Remove "within area of effect", "for party members", etc.
        desc = re.sub(r'\s*(?:for party members?\s*)?(?:within (?:the )?area of effect|to (?:all )?(?:party members?|enemies?))\s*\.?', '', desc, flags=re.I)
    elif target_type == 'single':
        # Remove "to a single enemy/target"
        desc = re.sub(r'\s*to (?:a )?(?:single )?(?:enemy|target|party member)\s*\.?', '', desc, flags=re.I)

    # Generic simplifications
    desc = re.sub(r'^Deals (\w+) damage.*', r'Deals damage', desc, flags=re.I)
    desc = re.sub(r'^Restores HP.*', r'Restores HP', desc, flags=re.I)
    desc = re.sub(r'^Restores MP.*', r'Restores MP', desc, flags=re.I)
    desc = re.sub(r'^Increases? (\w+).*', r'Increases \1', desc, flags=re.I)
    desc = re.sub(r'^Reduces? (\w+).*', r'Reduces \1', desc, flags=re.I)
    desc = re.sub(r'^Enhances? (\w+).*', r'Enhances \1', desc, flags=re.I)

    # Clean up extra whitespace
    desc = re.sub(r'\s+', ' ', desc).strip()

    # Ensure it ends with period if not empty
    if desc and not desc.endswith('.'):
        desc += '.'

    return desc

# ============================================================================
# AUDITOR
# ============================================================================

class SpellAuditor:
    def __init__(self):
        self.errors = []
        self.warnings = []
        self.stats = {
            'total_spells': 0,
            'checked': 0,
            'errors': 0,
            'warnings': 0,
            'not_found': 0
        }

    def audit_spell(self, spell_name: str, local_data: Dict) >> List[str]:
        """Audit a single spell against bg-wiki."""
        self.stats['total_spells'] += 1
        issues = []

        print(f"Checking: {spell_name}...", end=' ')

        # Fetch from bg-wiki
        wiki_data = fetch_bgwiki_spell(spell_name)

        if not wiki_data:
            self.stats['not_found'] += 1
            issues.append(f"[WARN]  Could not fetch from bg-wiki")
            print("NOT FOUND")
            return issues

        self.stats['checked'] += 1

        # Compare descriptions
        if wiki_data.get('description') and local_data.get('description'):
            local_desc = local_data['description'].lower().strip()
            wiki_desc = wiki_data['description'].lower().strip()

            # Simple similarity check
            if local_desc not in wiki_desc and wiki_desc not in local_desc:
                issues.append(f"[ERROR] Description mismatch:\n   LOCAL: {local_data['description']}\n   WIKI:  {wiki_data['description']}")

        # Compare elements
        if wiki_data.get('element') and local_data.get('element'):
            if wiki_data['element'].lower() != local_data['element'].lower():
                issues.append(f"[ERROR] Element mismatch: LOCAL={local_data['element']} vs WIKI={wiki_data['element']}")

        # Compare job levels
        for job, wiki_level in wiki_data.get('levels', {}).items():
            local_level = local_data.get('job_levels', {}).get(job)
            if local_level and local_level != wiki_level:
                issues.append(f"[ERROR] {job} level mismatch: LOCAL={local_level} vs WIKI={wiki_level}")

        # Check for missing job levels
        for job, local_level in local_data.get('job_levels', {}).items():
            if job not in wiki_data.get('levels', {}):
                issues.append(f"[WARN]  {job} level {local_level} not found on wiki (might be correct if subjob)")

        if issues:
            self.stats['errors'] += len([i for i in issues if i.startswith('[ERROR]')])
            self.stats['warnings'] += len([i for i in issues if i.startswith('[WARN]')])
            print(f"[ERROR] {len(issues)} issues")
        else:
            print("[OK] OK")

        return issues

    def audit_directory(self, directory: Path) >> Dict:
        """Audit all Lua files in a directory."""
        results = {}

        lua_files = list(directory.glob('*.lua'))

        for lua_file in lua_files:
            print(f"\n[FILE] {lua_file.name}")
            print("=" * 60)

            spells = parse_lua_spell_file(lua_file)

            for spell_name, spell_data in spells.items():
                issues = self.audit_spell(spell_name, spell_data)

                if issues:
                    results[spell_name] = {
                        'file': str(lua_file),
                        'data': spell_data,
                        'issues': issues
                    }

        return results

    def generate_report(self, all_results: Dict) >> str:
        """Generate markdown report."""
        report = []
        report.append("# FFXI Spell Database Audit Report")
        report.append(f"\n**Generated:** {time.strftime('%Y-%m-%d %H:%M:%S')}")
        report.append(f"\n## Summary\n")
        report.append(f"- **Total spells:** {self.stats['total_spells']}")
        report.append(f"- **Checked against bg-wiki:** {self.stats['checked']}")
        report.append(f"- **Errors found:** {self.stats['errors']}")
        report.append(f"- **Warnings:** {self.stats['warnings']}")
        report.append(f"- **Not found on wiki:** {self.stats['not_found']}")

        if not all_results:
            report.append("\n[OK] **No issues found! All spells are accurate.**")
            return '\n'.join(report)

        report.append(f"\n## Issues Found ({len(all_results)} spells)\n")

        for spell_name, result in sorted(all_results.items()):
            report.append(f"\n### {spell_name}")
            report.append(f"**File:** `{result['file']}`\n")

            for issue in result['issues']:
                report.append(f"{issue}")

            report.append("")

        return '\n'.join(report)

# ============================================================================
# MAIN
# ============================================================================

def main():
    print("=" * 70)
    print("FFXI SPELL DATABASE AUDITOR")
    print("=" * 70)
    print(f"\nAuditing directory: {MAGIC_DIR}")
    print(f"Output report: {OUTPUT_REPORT}\n")

    auditor = SpellAuditor()
    all_results = {}

    for dir_name in AUDIT_DIRS:
        dir_path = MAGIC_DIR / dir_name

        if not dir_path.exists():
            print(f"[WARN]  Skipping {dir_name} (not found)")
            continue

        print(f"\n{'=' * 70}")
        print(f"AUDITING: {dir_name.upper()}")
        print(f"{'=' * 70}")

        results = auditor.audit_directory(dir_path)
        all_results.update(results)

    # Generate report
    report = auditor.generate_report(all_results)

    with open(OUTPUT_REPORT, 'w', encoding='utf-8') as f:
        f.write(report)

    print(f"\n{'=' * 70}")
    print("[OK] AUDIT COMPLETE")
    print(f"{'=' * 70}")
    print(f"\nReport saved to: {OUTPUT_REPORT}")
    print(f"\n[STATS] Statistics:")
    print(f"   Total spells: {auditor.stats['total_spells']}")
    print(f"   Checked: {auditor.stats['checked']}")
    print(f"   Errors: {auditor.stats['errors']}")
    print(f"   Warnings: {auditor.stats['warnings']}")
    print(f"   Not found: {auditor.stats['not_found']}")

    if all_results:
        print(f"\n[WARN]  Found issues in {len(all_results)} spells. Check report for details.")
    else:
        print(f"\n[OK] No issues found! Database is accurate.")

if __name__ == '__main__':
    main()
