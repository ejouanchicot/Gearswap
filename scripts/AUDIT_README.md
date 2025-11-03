# Spell Database Auditor

Script Python pour auditer automatiquement **tous les sorts** contre bg-wiki.com.

## 🎯 Fonctionnalités

- ✅ Vérifie **descriptions** exactes contre bg-wiki
- ✅ Vérifie **levels** pour tous les jobs
- ✅ Vérifie **elements** (Fire, Ice, etc.)
- ✅ Vérifie **magic types** (White, Black, etc.)
- ✅ Génère rapport détaillé des erreurs
- ✅ Rate limiting automatique (1s entre chaque requête)

## 📦 Installation

```bash
# Installer les dépendances
pip install -r requirements.txt
```

**Dépendances:**

- `requests` - Pour fetch bg-wiki
- `beautifulsoup4` - Pour parser HTML

## 🚀 Usage

```bash
# Depuis le dossier GearSwap/data/
python scripts/audit_spells.py
```

**Le script va:**

1. Parser tous les fichiers `.lua` dans `shared/data/magic/`
2. Pour chaque sort, fetch la page bg-wiki correspondante
3. Comparer les données (description, level, element, etc.)
4. Générer un rapport `SPELL_AUDIT_REPORT.md`

## 📊 Exemple de Sortie

```
======================================================================
FFXI SPELL DATABASE AUDITOR
======================================================================

Auditing directory: shared/data/magic
Output report: SPELL_AUDIT_REPORT.md

======================================================================
🔍 AUDITING: ELEMENTAL
======================================================================

📁 elemental_single.lua
============================================================
Checking: Fire... ✅ OK
Checking: Blizzard... ❌ 1 issues
Checking: Thunder... ✅ OK

...

======================================================================
✅ AUDIT COMPLETE
======================================================================

Report saved to: SPELL_AUDIT_REPORT.md

📊 Statistics:
   Total spells: 342
   Checked: 340
   Errors: 15
   Warnings: 8
   Not found: 2
```

## 📝 Rapport Généré

Le rapport `SPELL_AUDIT_REPORT.md` contient:

```markdown
# FFXI Spell Database Audit Report

**Generated:** 2025-10-31 12:34:56

## Summary

- **Total spells:** 342
- **Checked against bg-wiki:** 340
- **Errors found:** 15
- **Warnings:** 8
- **Not found on wiki:** 2

## Issues Found (23 spells)

### Fire III
**File:** `shared/data/magic/elemental/elemental_single.lua`

❌ BLM level mismatch: LOCAL=34 vs WIKI=35
❌ Description mismatch:
   LOCAL: Deals severe fire damage to a single enemy.
   WIKI:  Deals fire damage to a single enemy.

### Cure IV
**File:** `shared/data/magic/healing/healing_cure.lua`

❌ WHM level mismatch: LOCAL=48 vs WIKI=49
⚠️  RDM level 58 not found on wiki (might be correct if subjob)
```

## 🔧 Configuration

Dans `audit_spells.py`, tu peux modifier:

```python
# Délai entre requêtes (éviter ban)
RATE_LIMIT_DELAY = 1.0  # secondes

# Dossiers à auditer
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

# Fichier de sortie
OUTPUT_REPORT = "SPELL_AUDIT_REPORT.md"
```

## ⚠️ Notes

1. **Rate Limiting:** Le script attend 1s entre chaque requête pour ne pas spam bg-wiki
2. **Temps d'exécution:** ~5-10 minutes pour 300+ sorts (à cause du rate limiting)
3. **Connexion internet:** Requise pour accéder à bg-wiki.com
4. **Parsing Lua:** Simple regex parsing, peut nécessiter ajustements si structure change

## 🐛 Limitations

- Ne détecte pas tous les types d'erreurs (ex: skill vs category)
- Parsing Lua basique (peut rater des formats complexes)
- Dépend de la structure HTML de bg-wiki (peut casser si site change)
- Quelques faux positifs possibles (descriptions similaires mais pas identiques)

## 🔄 Prochaines Améliorations

- [ ] Auto-correction des erreurs trouvées
- [ ] Cache local pour éviter re-fetch à chaque run
- [ ] Parsing Lua plus robuste
- [ ] Vérification des skills (Healing Magic, Elemental Magic, etc.)
- [ ] Export JSON des résultats
- [ ] Mode "fix" qui applique automatiquement les corrections

## 📚 Références

- **bg-wiki.com** - Source officielle FFXI
- **Format Lua** - Structure des fichiers spell database
