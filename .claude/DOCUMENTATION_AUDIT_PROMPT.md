# Documentation Audit - Prompt de Mission

**Objectif:** Auditer TOUTE la documentation du projet GearSwap Tetsouo et vérifier qu'elle correspond à l'état réel du code.

---

## 🎯 Mission Principale

Analyser chaque fichier de documentation dans `docs/` et déterminer:

1. **Est-ce que le contenu est ACCURATE?** (correspond au code actuel)
2. **Est-ce que c'est UTILE?** (documentation nécessaire pour comprendre/utiliser le projet)
3. **Est-ce que c'est REDONDANT?** (information dupliquée ailleurs)
4. **Est-ce que c'est OBSOLÈTE?** (décrit un système qui n'existe plus ou a changé)

---

## 📂 Fichiers à Auditer (Liste Complète)

```
docs/
├── archives/                           [DOSSIER - Déjà vérifié comme obsolète]
├── assets/                             [DOSSIER - Images/screenshots]
├── fixes/                              [DOSSIER - Fixes documentés]
├── migration_reports/                  [DOSSIER - Rapports migration]
├── templates/                          [DOSSIER - Templates docs]
├── user/                               [DOSSIER - Docs utilisateur]
├── BACKUP_FILES_AUDIT.md               [FICHIER - Nouveau 2025-11-01]
├── FINAL_TESTING_CHECKLIST.md          [FICHIER - À vérifier]
├── HEALING_MAGIC_DATABASE_AUDIT.md     [FICHIER - À vérifier]
├── INIT_SYSTEMS_AUDIT.md               [FICHIER - À vérifier]
├── JOB_ABILITIES_DATABASE.md           [FICHIER - À vérifier]
├── README.md                           [FICHIER - Master index]
├── SESSION_2025_11_01_UNIFIED_MESSAGES.md [FICHIER - Nouveau session]
├── SESSION_COMPLETE_SUMMARY.md         [FICHIER - À vérifier]
├── SPELL_DESCRIPTIONS_VERIFICATION.md  [FICHIER - À vérifier]
├── WEAPONSKILLS_DATABASE.md            [FICHIER - À vérifier]
└── WS_DATABASE_SYSTEM.md               [FICHIER - À vérifier]
```

---

## 🔍 Méthodologie d'Audit

### Pour Chaque Fichier:

1. **Lire le fichier** complètement
2. **Identifier le sujet principal** (quel système/feature il documente)
3. **Vérifier dans le code** si ce système existe et fonctionne comme décrit
4. **Comparer les détails techniques:**
   - Chemins de fichiers mentionnés existent?
   - Fonctions mentionnées existent?
   - Structures de données correspondent?
   - Exemples de code sont valides?
5. **Évaluer l'utilité:**
   - Est-ce que ça aide à comprendre le projet?
   - Est-ce que ça aide à utiliser le système?
   - Est-ce que ça aide à développer/maintenir?
6. **Chercher les redondances:**
   - Est-ce que cette info existe dans un autre fichier?
   - Lequel est plus complet/accurate?

---

## 📊 Catégories d'Audit

### Catégorie A: KEEP (Garder tel quel)

- Documentation accurate et utile
- Pas de redondance
- Correspond au code actuel
- Nécessaire pour comprendre/utiliser le projet

### Catégorie B: UPDATE (Mettre à jour)

- Documentation utile mais avec infos obsolètes
- Structure bonne mais détails incorrects
- Exemples à corriger

### Catégorie C: MERGE (Fusionner)

- Documentation redondante avec un autre fichier
- Peut être intégré dans un doc plus complet
- Éviter la duplication

### Catégorie D: ARCHIVE (Archiver)

- Documentation obsolète mais historiquement utile
- Décrit un système qui a changé radicalement
- Garder pour référence mais pas dans docs/ principal

### Catégorie E: DELETE (Supprimer)

- Documentation complètement obsolète
- Aucune valeur historique
- Information incorrecte et trompeuse

---

## 🎯 Zones Critiques à Vérifier

### 1. Database Documentation

- `JOB_ABILITIES_DATABASE.md`
- `WEAPONSKILLS_DATABASE.md`
- `WS_DATABASE_SYSTEM.md`
- `HEALING_MAGIC_DATABASE_AUDIT.md`
- `SPELL_DESCRIPTIONS_VERIFICATION.md`

**Questions:**

- Est-ce que les 3 UNIVERSAL databases sont documentés? (UNIVERSAL_JA_DATABASE, UNIVERSAL_SPELL_DATABASE, UNIVERSAL_WS_DATABASE)
- Est-ce que UNIVERSAL_SPELL_DATABASE.lua (créé 2025-11-01) est documenté?
- Est-ce que les chemins de fichiers sont corrects?
- Est-ce que les structures correspondent au code?

### 2. Systems Documentation

- `INIT_SYSTEMS_AUDIT.md`
- `SESSION_COMPLETE_SUMMARY.md`
- `SESSION_2025_11_01_UNIFIED_MESSAGES.md`

**Questions:**

- Est-ce que le système de messages unifié est bien documenté?
- Est-ce que les fixes récents (2025-11-01) sont à jour?
- Est-ce que les systèmes centralisés sont documentés? (CooldownChecker, MessageFormatter, MidcastManager, etc.)

### 3. Testing & Checklists

- `FINAL_TESTING_CHECKLIST.md`

**Questions:**

- Est-ce que les tests correspondent aux systèmes actuels?
- Est-ce que de nouveaux tests sont nécessaires?
- Est-ce que c'est à jour avec les changements récents?

### 4. Fixes Documentation

- `docs/fixes/` (7 fichiers)

**Questions:**

- Est-ce que tous les fixes documentés sont toujours pertinents?
- Est-ce qu'il manque des fixes récents?
- Est-ce que les statistiques sont à jour?

### 5. User Documentation

- `docs/user/` (si existe)
- `docs/README.md` (master index)

**Questions:**

- Est-ce que c'est accessible aux utilisateurs?
- Est-ce que ça couvre tous les jobs?
- Est-ce que les commandes documentées existent?

---

## 📝 Format du Rapport d'Audit

Pour chaque fichier, créer une entrée:

```markdown
### [FILENAME].md

**Catégorie:** A/B/C/D/E
**Sujet:** [Description du contenu]
**Date Création/Modification:** [Date si connue]

**Vérifications:**
- [ ] Chemins de fichiers corrects
- [ ] Fonctions mentionnées existent
- [ ] Exemples de code valides
- [ ] Pas de redondance
- [ ] Information utile

**Problèmes Trouvés:**
1. [Problème 1]
2. [Problème 2]

**Recommandation:** KEEP / UPDATE / MERGE / ARCHIVE / DELETE

**Action Requise:** [Description si UPDATE/MERGE]
```

---

## 🔥 Priorités d'Audit

### P0 - Critique (Auditer en premier):

1. `README.md` (master index)
2. `SESSION_2025_11_01_UNIFIED_MESSAGES.md` (nouveau)
3. `BACKUP_FILES_AUDIT.md` (nouveau)
4. Database docs (5 fichiers)

### P1 - Important:

5. `INIT_SYSTEMS_AUDIT.md`
6. `SESSION_COMPLETE_SUMMARY.md`
7. `FINAL_TESTING_CHECKLIST.md`
8. `docs/fixes/` (7 fichiers)

### P2 - Nice to Have:

9. `docs/templates/`
10. `docs/migration_reports/`
11. `docs/archives/` (déjà archivé, vérif rapide)

---

## 🎯 Livrables Attendus

### 1. Rapport d'Audit Complet

- Fichier: `DOCUMENTATION_AUDIT_REPORT.md`
- Contenu: Analyse détaillée de chaque fichier
- Format: Tableau avec catégories A/B/C/D/E

### 2. Liste des Actions

- Fichier: `DOCUMENTATION_ACTIONS.md`
- Contenu: Liste prioritée des modifications à faire
- Format: Checklist avec deadlines

### 3. Nouveau README.md (si nécessaire)

- Fichier: `docs/README_NEW.md`
- Contenu: Index restructuré et accurate
- Format: Markdown avec liens corrects

### 4. Fichiers Obsolètes Identifiés

- Liste: Fichiers à supprimer/archiver
- Justification: Pourquoi obsolète

---

## ⚙️ Process d'Audit Suggéré

### Étape 1: Scan Rapide (30 min)

- Lire tous les headers/titres
- Identifier les sujets principaux
- Créer liste des fichiers par catégorie

### Étape 2: Audit Détaillé P0 (2-3h)

- README.md complet
- Nouveaux docs session 2025-11-01
- Database docs critiques

### Étape 3: Audit P1 (2-3h)

- Systems documentation
- Testing checklists
- Fixes documentation

### Étape 4: Audit P2 (1-2h)

- Templates
- Migration reports
- Archives

### Étape 5: Rapport Final (1h)

- Compiler résultats
- Créer DOCUMENTATION_AUDIT_REPORT.md
- Créer DOCUMENTATION_ACTIONS.md

**Temps Total Estimé:** 6-9 heures

---

## 🚨 Red Flags à Chercher

1. **Chemins de fichiers qui n'existent plus**
   - Exemple: `Tetsouo/jobs/war/` au lieu de `shared/jobs/war/`

2. **Fonctions qui n'existent plus**
   - Exemple: Documentation d'une fonction refactorisée

3. **Systèmes qui ont changé**
   - Exemple: Documentation du vieux système de messages (avant unification)

4. **Statistiques obsolètes**
   - Exemple: "21 jobs" si maintenant c'est plus/moins

5. **Exemples de code qui ne fonctionnent plus**
   - Exemple: Syntaxe changée, API modifiée

6. **Duplication exacte**
   - Exemple: Même information dans 2+ fichiers

7. **Information trompeuse**
   - Exemple: "System X is broken" si maintenant c'est fixé

---

## 🎓 Questions Clés pour Chaque Doc

1. **Pourquoi ce doc existe?** (Quel problème résout-il?)
2. **Qui utilise ce doc?** (Développeur, utilisateur, mainteneur?)
3. **Quand a-t-il été créé?** (Context historique)
4. **Est-ce encore vrai aujourd'hui?** (Vérification code)
5. **Peut-on le simplifier?** (Trop verbeux?)
6. **Peut-on le fusionner?** (Redondance?)
7. **Peut-on le supprimer?** (Obsolète?)

---

## ✅ Critères de Succès

Un audit réussi produit:

1. ✅ Liste complète de TOUS les fichiers docs auditées
2. ✅ Catégorie claire (A/B/C/D/E) pour chaque fichier
3. ✅ Justification pour chaque catégorie
4. ✅ Actions concrètes pour catégorie B (UPDATE)
5. ✅ Plan de merge pour catégorie C (MERGE)
6. ✅ Nouveau README.md si nécessaire
7. ✅ Zéro documentation obsolète dans docs/ (seulement dans archives/)
8. ✅ Zéro duplication d'information
9. ✅ 100% des docs correspondent au code réel

---

## 🔧 Outils pour Audit

### Vérification Fichiers:

```bash
# Vérifier si un fichier existe
test -f "path/to/file.lua" && echo "EXISTS" || echo "MISSING"

# Chercher une fonction dans le code
grep -r "function_name" shared/

# Compter occurrences (redondance)
grep -r "specific_text" docs/ | wc -l
```

### Vérification Structure:

```bash
# Lister tous les jobs
ls shared/jobs/

# Lister toutes les databases
ls shared/data/job_abilities/
ls shared/data/magic/
ls shared/data/weaponskills/
```

---

**Date de Création:** 2025-11-01
**Auteur:** Claude (Anthropic)
**Objectif:** Audit complet documentation projet GearSwap Tetsouo
**Priorité:** HIGH - Documentation doit correspondre au code réel
