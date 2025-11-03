#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Data Usage Auditor - Vérifie quels data sont utilisés vs orphelins
"""

import os
import re
from pathlib import Path
from collections import defaultdict

def find_file_references(base_path, search_pattern):
    """Find all references to a file pattern in codebase"""
    references = []

    # Search in all Lua files
    for root, dirs, files in os.walk(base_path):
        # Skip internal and certain dirs
        if 'internal' in root or '.git' in root:
            continue

        for file in files:
            if not file.endswith('.lua'):
                continue

            filepath = Path(root) / file
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()

                    # Check for require() or dofile()
                    if search_pattern in content:
                        # Find the line
                        for i, line in enumerate(content.split('\n'), 1):
                            if search_pattern in line:
                                references.append({
                                    'file': str(filepath.relative_to(base_path)),
                                    'line': i,
                                    'content': line.strip()
                                })
            except Exception as e:
                pass

    return references

def audit_data_files(base_path):
    """Audit all data files for usage"""

    results = {
        'monolithic': {},  # Old architecture
        'modular': {},     # New architecture
        'orphans': [],
        'used': []
    }

    data_path = base_path / "shared" / "data"

    # Check monolithic files (root level .lua in magic/)
    magic_path = data_path / "magic"
    for lua_file in magic_path.glob("*.lua"):
        filename = lua_file.name
        file_stem = lua_file.stem

        # Search for references
        refs = find_file_references(base_path, file_stem)

        results['monolithic'][filename] = {
            'path': str(lua_file.relative_to(base_path)),
            'references': len(refs),
            'used_by': refs
        }

        if len(refs) > 0:
            results['used'].append(filename)
        else:
            results['orphans'].append(filename)

    # Check modular files (subdirectories)
    modular_categories = ['dark', 'divine', 'elemental', 'enfeebling', 'enhancing',
                          'geomancy', 'healing', 'song', 'summoning', 'blu']

    for category in modular_categories:
        category_path = magic_path / category
        if not category_path.exists():
            continue

        # Recursively find all .lua files
        for lua_file in category_path.rglob("*.lua"):
            if lua_file.suffix != '.lua':
                continue

            relative_path = lua_file.relative_to(magic_path)
            file_stem = lua_file.stem

            # Search for references (check stem and relative path)
            refs1 = find_file_references(base_path, file_stem)
            refs2 = find_file_references(base_path, str(relative_path).replace('\\', '/'))
            refs = refs1 + refs2

            # Remove duplicates
            unique_refs = []
            seen = set()
            for ref in refs:
                key = (ref['file'], ref['line'])
                if key not in seen:
                    seen.add(key)
                    unique_refs.append(ref)

            results['modular'][str(relative_path)] = {
                'category': category,
                'references': len(unique_refs),
                'used_by': unique_refs
            }

            if len(unique_refs) == 0:
                results['orphans'].append(str(relative_path))

    return results

def generate_usage_report(results):
    """Generate detailed usage report"""

    report = []
    report.append("# DATA USAGE AUDIT - DIAGNOSTIC COMPLET")
    report.append("=" * 70)
    report.append("")

    # Summary
    total_monolithic = len(results['monolithic'])
    total_modular = len(results['modular'])
    total_orphans = len(results['orphans'])

    monolithic_used = sum(1 for f, data in results['monolithic'].items() if data['references'] > 0)
    modular_used = sum(1 for f, data in results['modular'].items() if data['references'] > 0)

    report.append("## 📊 RÉSUMÉ EXÉCUTIF")
    report.append("")
    report.append(f"**Fichiers Monolithiques (Ancien):** {total_monolithic}")
    report.append(f"  - Utilisés: {monolithic_used}")
    report.append(f"  - Orphelins: {total_monolithic - monolithic_used}")
    report.append("")
    report.append(f"**Fichiers Modulaires (Nouveau):** {total_modular}")
    report.append(f"  - Utilisés: {modular_used}")
    report.append(f"  - Orphelins: {total_modular - modular_used}")
    report.append("")
    report.append(f"**🚨 TOTAL ORPHELINS: {total_orphans}**")
    report.append("")

    # Monolithic files details
    report.append("## 📁 FICHIERS MONOLITHIQUES (Ancien Système)")
    report.append("")

    for filename in sorted(results['monolithic'].keys()):
        data = results['monolithic'][filename]
        refs = data['references']

        if refs > 0:
            report.append(f"### ✅ {filename} ({refs} références)")
            for ref in data['used_by'][:5]:  # Show first 5
                report.append(f"  - `{ref['file']}:{ref['line']}`")
            if len(data['used_by']) > 5:
                report.append(f"  - ... et {len(data['used_by']) - 5} autres")
        else:
            report.append(f"### ❌ {filename} (ORPHELIN - 0 références)")

        report.append("")

    # Modular files summary
    report.append("## 🗂️ FICHIERS MODULAIRES (Nouveau Système)")
    report.append("")

    # Group by category
    by_category = defaultdict(list)
    for filepath, data in results['modular'].items():
        by_category[data['category']].append((filepath, data))

    for category in sorted(by_category.keys()):
        files = by_category[category]
        used_count = sum(1 for _, data in files if data['references'] > 0)
        total_count = len(files)

        report.append(f"### {category.upper()} ({used_count}/{total_count} utilisés)")
        report.append("")

        for filepath, data in sorted(files, key=lambda x: x[1]['references'], reverse=True):
            refs = data['references']
            if refs > 0:
                report.append(f"  ✅ `{filepath}` ({refs} références)")
            else:
                report.append(f"  ❌ `{filepath}` (ORPHELIN)")

        report.append("")

    # Critical findings
    report.append("## 🚨 PROBLÈMES CRITIQUES DÉTECTÉS")
    report.append("")

    if total_orphans > 50:
        report.append(f"❌ **{total_orphans} fichiers orphelins** - Aucune référence trouvée!")
        report.append("")
        report.append("**Impact:**")
        report.append("- Les nouveaux data modulaires ne sont PAS utilisés")
        report.append("- Les jobs utilisent encore les anciens fichiers monolithiques")
        report.append("- Le travail de modernisation (858 spells) est INUTILISÉ")
        report.append("")

    if modular_used == 0:
        report.append("❌ **AUCUN fichier modulaire n'est chargé!**")
        report.append("")
        report.append("**Problème d'architecture:**")
        report.append("- Le nouveau système modulaire existe mais n'est jamais importé")
        report.append("- `spell_message_handler.lua` charge uniquement les anciens fichiers")
        report.append("- Aucun job n'accède aux nouveaux data")
        report.append("")

    # Recommendations
    report.append("## ✅ RECOMMANDATIONS")
    report.append("")
    report.append("### 1. Créer un Data Loader Universel")
    report.append("")
    report.append("```lua")
    report.append("-- shared/utils/data/data_loader.lua")
    report.append("local DataLoader = {}")
    report.append("DataLoader.spells = {}  -- All spells from all categories")
    report.append("DataLoader.abilities = {}  -- All job abilities")
    report.append("DataLoader.weaponskills = {}  -- All weaponskills")
    report.append("")
    report.append("function DataLoader.load_all()")
    report.append("  -- Load modular spell files")
    report.append("  -- Load job abilities")
    report.append("  -- Load weaponskills")
    report.append("  -- Make accessible globally via _G")
    report.append("end")
    report.append("```")
    report.append("")
    report.append("### 2. Migrer spell_message_handler.lua")
    report.append("")
    report.append("Remplacer les `require('BLM_SPELL_DATABASE')` par:")
    report.append("```lua")
    report.append("local DataLoader = require('shared/utils/data/data_loader')")
    report.append("local spell_data = DataLoader.spells[spell_name]")
    report.append("```")
    report.append("")
    report.append("### 3. Accès Universel")
    report.append("")
    report.append("N'importe quel job pourra accéder à n'importe quelle donnée:")
    report.append("```lua")
    report.append("-- WAR/BLU peut voir les descriptions BLU")
    report.append("local blu_spell = _G.FFXI_DATA.spells['Foot Kick']")
    report.append("print(blu_spell.description)  -- 'Deals slashing dmg.'")
    report.append("```")
    report.append("")

    report.append("## 📈 SCORE ACTUEL")
    report.append("")
    usage_percent = ((modular_used / total_modular * 100) if total_modular > 0 else 0)
    report.append(f"**Utilisation des Data Modulaires:** {usage_percent:.1f}%")
    report.append(f"**Fichiers Orphelins:** {total_orphans}")
    report.append("")

    if usage_percent < 10:
        report.append("**Score:** ❌ 2/10 - Architecture non utilisée")
    elif usage_percent < 50:
        report.append("**Score:** ⚠️ 5/10 - Utilisation partielle")
    else:
        report.append("**Score:** ✅ 9/10 - Bonne utilisation")

    report.append("")

    return "\n".join(report)

def main():
    script_dir = Path(__file__).parent
    base_path = script_dir.parent

    print("=" * 70)
    print("DATA USAGE AUDITOR - ANALYSE D'UTILISATION")
    print("=" * 70)
    print()
    print("Analyzing data file references...")
    print()

    results = audit_data_files(base_path)

    print("Generating report...")
    report = generate_usage_report(results)

    # Save report
    output_path = base_path / "DATA_USAGE_AUDIT.md"
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(report)

    print(f"\nReport saved to: {output_path}")
    print()
    print("=" * 70)
    print("AUDIT COMPLETE!")
    print("=" * 70)

if __name__ == "__main__":
    main()
