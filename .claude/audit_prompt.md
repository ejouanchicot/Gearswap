# AUDIT COMPLET MULTI-JOBS - GUIDE DE VALIDATION TETSOUO

## 🎯 OBJECTIF

Vérifier que TOUS les jobs (WAR, PLD, DNC, THF, COR, GEO, BRD, RDM) suivent **exactement** la même structure, ont une logique propre, et respectent les standards Tetsouo.

---

## 📋 CHECKLIST PAR JOB (8 jobs × 7 catégories = 56 vérifications)

### **CATÉGORIE 1: STRUCTURE MODULAIRE (12 modules obligatoires)**

Pour chaque job, vérifier la présence de **EXACTEMENT 12 modules**:

**Fichiers à vérifier:**

```bash
jobs/[job]/
├── [job]_functions.lua           # 1. FAÇADE (charge tous les modules)
└── functions/
    ├── [JOB]_PRECAST.lua         # 2. Precast hook
    ├── [JOB]_MIDCAST.lua         # 3. Midcast hook
    ├── [JOB]_AFTERCAST.lua       # 4. Aftercast hook
    ├── [JOB]_IDLE.lua            # 5. Idle hook
    ├── [JOB]_ENGAGED.lua         # 6. Engaged hook
    ├── [JOB]_STATUS.lua          # 7. Status change hook
    ├── [JOB]_BUFFS.lua           # 8. Buff management hook
    ├── [JOB]_COMMANDS.lua        # 9. Command handling hook
    ├── [JOB]_MOVEMENT.lua        # 10. Movement hook
    ├── [JOB]_LOCKSTYLE.lua       # 11. Lockstyle (Factory)
    └── [JOB]_MACROBOOK.lua       # 12. Macrobook (Factory)
```

**Commandes audit:**

```bash
# Pour chaque job:
ls jobs/[job]/functions/ | wc -l  # Devrait retourner 12 (11 hooks + logic/)
ls jobs/[job]/functions/*.lua | wc -l  # Devrait retourner 11 fichiers
```

**✅ Validation:**

- [ ] WAR: 12 modules présents
- [ ] PLD: 12 modules présents
- [ ] DNC: 12 modules présents
- [ ] THF: 12 modules présents
- [ ] COR: 12 modules présents
- [ ] GEO: 12 modules présents
- [ ] BRD: 12 modules présents
- [ ] RDM: 12 modules présents

---

### **CATÉGORIE 2: ARCHITECTURE HOOKS VS LOGIC**

Vérifier la séparation **Hooks (orchestration) vs Logic (business logic)**:

**Règles:**

- **Hooks modules** ([JOB]_*.lua): Chargés via `include()`, exports via `_G`
- **Logic modules** (logic/*.lua): Chargés via `require()`, exports via `return`

**Commandes audit:**

```bash
# Vérifier présence logic/ directory
ls jobs/[job]/functions/logic/ 2>/dev/null | wc -l

# Compter logic modules par job
for job in war pld dnc thf cor geo brd rdm; do
  echo "$job: $(ls jobs/$job/functions/logic/*.lua 2>/dev/null | wc -l) logic modules"
done
```

**Nombre attendu de logic modules:**

- WAR: 2 (smartbuff_manager, set_builder)
- PLD: 4 (aoe_manager, cure_set_builder, rune_manager, set_builder)
- DNC: 6 (climactic_manager, jump_manager, set_builder, smartbuff_manager, step_manager, ws_variant_selector)
- THF: 3 (sa_ta_manager, set_builder, smartbuff_manager)
- COR: 3 (roll_data, roll_tracker, set_builder)
- GEO: 2 (geo_spell_refiner, set_builder)
- BRD: 3 (set_builder, song_refinement, song_rotation_manager)
- RDM: 1 (set_builder)
- BLM: 4 (buff_manager, set_builder, spell_refiner, storm_manager)

**✅ Validation:**

- [ ] WAR: 2 logic modules
- [ ] PLD: 4 logic modules
- [ ] DNC: 6 logic modules
- [ ] THF: 3 logic modules
- [ ] COR: 3 logic modules
- [ ] GEO: 2 logic modules
- [ ] BRD: 3 logic modules
- [ ] RDM: 1 logic module

---

### **CATÉGORIE 3: ORDRE DE CHARGEMENT PRECAST (CRITIQUE)**

Vérifier l'ordre **OBLIGATOIRE** dans job_precast():

**Ordre standard (TOUS les jobs):**

```lua
function job_precast(spell, action, spellMap, eventArgs)
    -- 1. FIRST: Debuff guard (PrecastGuard)
    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        return
    end

    -- 2. SECOND: Cooldown check (CooldownChecker)
    if spell.action_type == 'Ability' then
        CooldownChecker.check_ability_cooldown(spell, eventArgs)
    elseif spell.action_type == 'Magic' then
        CooldownChecker.check_spell_cooldown(spell, eventArgs)
    end

    if eventArgs.cancel then return end

    -- 3. THIRD: WeaponSkill validation (WeaponSkillManager)
    if spell.type == 'WeaponSkill' and WeaponSkillManager then
        if not WeaponSkillManager.check_weaponskill_range(spell) then
            eventArgs.cancel = true
            return
        end
        if not WeaponSkillManager.validate_weaponskill(spell.name) then
            eventArgs.cancel = true
            return
        end
    end

    -- 4. LAST: Job-specific logic
    -- ...
end
```

**Commandes audit:**

```bash
# Pour chaque job, extraire les 30 premières lignes de job_precast
for job in WAR PLD DNC THF COR GEO BRD RDM; do
  echo "=== $job PRECAST order ==="
  grep -A 30 "^function job_precast" jobs/${job,,}/functions/${job}_PRECAST.lua
done
```

**✅ Validation:**

- [ ] WAR: Ordre correct (PrecastGuard >> CooldownChecker >> WeaponSkillManager >> Job logic)
- [ ] PLD: Ordre correct
- [ ] DNC: Ordre correct
- [ ] THF: Ordre correct
- [ ] COR: Ordre correct
- [ ] GEO: Ordre correct
- [ ] BRD: Ordre correct
- [ ] RDM: Ordre correct

---

### **CATÉGORIE 4: INTÉGRATION SYSTÈMES CENTRALISÉS**

Vérifier que TOUS les jobs utilisent les **7 systèmes centralisés obligatoires**:

**Systèmes obligatoires:**

1. **CooldownChecker** (utils/precast/cooldown_checker.lua)
2. **MessageFormatter** (utils/messages/message_formatter.lua)
3. **LockstyleManager** (utils/lockstyle/lockstyle_manager.lua) - Factory
4. **MacrobookManager** (utils/macrobook/macrobook_manager.lua) - Factory
5. **PrecastGuard** (utils/debuff/precast_guard.lua)
6. **WeaponSkillManager** (utils/weaponskill/weaponskill_manager.lua)
7. **CommonCommands** (utils/core/COMMON_COMMANDS.lua)

**Commandes audit:**

```bash
# Pour chaque job, vérifier imports dans PRECAST
for job in WAR PLD DNC THF COR GEO BRD RDM; do
  echo "=== $job centralized systems ==="
  grep "require\|include" jobs/${job,,}/functions/${job}_PRECAST.lua | head -10
done

# Vérifier Factory usage dans LOCKSTYLE
for job in WAR PLD DNC THF COR GEO BRD RDM; do
  echo "$job Lockstyle Factory:"
  grep "LockstyleManager" jobs/${job,,}/functions/${job}_LOCKSTYLE.lua
done

# Vérifier Factory usage dans MACROBOOK
for job in WAR PLD DNC THF COR GEO BRD RDM; do
  echo "$job Macrobook Factory:"
  grep "MacrobookManager" jobs/${job,,}/functions/${job}_MACROBOOK.lua
done
```

**✅ Validation par système:**

**CooldownChecker:**

- [ ] WAR utilise CooldownChecker
- [ ] PLD utilise CooldownChecker
- [ ] DNC utilise CooldownChecker
- [ ] THF utilise CooldownChecker
- [ ] COR utilise CooldownChecker
- [ ] GEO utilise CooldownChecker
- [ ] BRD utilise CooldownChecker
- [ ] RDM utilise CooldownChecker

**MessageFormatter:**

- [ ] WAR utilise MessageFormatter
- [ ] PLD utilise MessageFormatter
- [ ] DNC utilise MessageFormatter
- [ ] THF utilise MessageFormatter
- [ ] COR utilise MessageFormatter
- [ ] GEO utilise MessageFormatter
- [ ] BRD utilise MessageFormatter
- [ ] RDM utilise MessageFormatter

**LockstyleManager (Factory):**

- [ ] WAR utilise LockstyleManager.create()
- [ ] PLD utilise LockstyleManager.create()
- [ ] DNC utilise LockstyleManager.create()
- [ ] THF utilise LockstyleManager.create()
- [ ] COR utilise LockstyleManager.create()
- [ ] GEO utilise LockstyleManager.create()
- [ ] BRD utilise LockstyleManager.create()
- [ ] RDM utilise LockstyleManager.create()

**MacrobookManager (Factory):**

- [ ] WAR utilise MacrobookManager.create()
- [ ] PLD utilise MacrobookManager.create()
- [ ] DNC utilise MacrobookManager.create()
- [ ] THF utilise MacrobookManager.create()
- [ ] COR utilise MacrobookManager.create()
- [ ] GEO utilise MacrobookManager.create()
- [ ] BRD utilise MacrobookManager.create()
- [ ] RDM utilise MacrobookManager.create()

---

### **CATÉGORIE 5: CODE MORT ET DUPLICATION**

**Règles de propreté:**

- ❌ Pas de code commenté > 10 lignes consécutives
- ❌ Pas de fonctions inutilisées
- ❌ Pas de fichiers orphelins (pas chargés par façade)
- ❌ Pas de duplication entre jobs (> 20 lignes identiques)

**Commandes audit:**

```bash
# Chercher gros blocs commentés (> 10 lignes)
for job in war pld dnc thf cor geo brd rdm; do
  echo "=== $job commented blocks ==="
  grep -n "^--" jobs/$job/functions/*.lua | awk -F: '{print $1}' | uniq -c | awk '$1 > 10'
done

# Chercher fichiers orphelins (pas dans façade)
for job in war pld dnc thf cor geo brd rdm; do
  echo "=== $job orphan files check ==="
  # Lister tous les .lua dans functions/
  ls jobs/$job/functions/*.lua > /tmp/${job}_files.txt
  # Lister tous les includes dans façade
  grep "include" jobs/$job/${job}_functions.lua > /tmp/${job}_includes.txt
  # Comparer
  diff /tmp/${job}_files.txt /tmp/${job}_includes.txt
done

# Chercher duplication entre jobs (fonctions identiques)
for file in PRECAST MIDCAST AFTERCAST IDLE ENGAGED STATUS BUFFS COMMANDS MOVEMENT; do
  echo "=== Checking $file duplication ==="
  # Comparer chaque paire de jobs
  for job1 in WAR PLD DNC THF COR GEO BRD RDM; do
    for job2 in WAR PLD DNC THF COR GEO BRD RDM; do
      if [ "$job1" != "$job2" ]; then
        diff jobs/${job1,,}/functions/${job1}_${file}.lua \
             jobs/${job2,,}/functions/${job2}_${file}.lua | head -20
      fi
    done
  done
done
```

**✅ Validation:**

- [ ] WAR: Pas de code mort, pas de duplication
- [ ] PLD: Pas de code mort, pas de duplication
- [ ] DNC: Pas de code mort, pas de duplication
- [ ] THF: Pas de code mort, pas de duplication
- [ ] COR: Pas de code mort, pas de duplication
- [ ] GEO: Pas de code mort, pas de duplication
- [ ] BRD: Pas de code mort, pas de duplication
- [ ] RDM: Pas de code mort, pas de duplication

---

### **CATÉGORIE 6: FORMAT SETS FILES (STANDARD PLD)**

Vérifier que TOUS les sets files suivent le format PLD:

**Standard attendu:**

```lua
---============================================================================
--- [JOB] Equipment Sets - Ultimate [Description]
---============================================================================
--- Features:
---   • Feature 1
---   • Feature 2
---   [...]
---
--- Architecture:
---   • Section 1
---   • Section 2
---   [...]
---
--- @file    jobs/[job]/sets/[job]_sets.lua
--- @author  Tetsouo
--- @version 3.0 - Standardized Organization
--- @date    Updated: 2025-10-15
---============================================================================

--============================================================--
--                  EQUIPMENT DEFINITIONS                     --
--============================================================--
```

**Séparateurs attendus:**

- `--============================================================--` (60 caractères =)
- Pas de `---===` ou `-- ====` (anciens formats)

**Commandes audit:**

```bash
# Pour chaque job, vérifier séparateurs
for job in war pld dnc thf cor geo brd rdm; do
  echo "=== $job sets separators ==="
  grep -n "^--" jobs/$job/sets/${job}_sets.lua | grep "===" | head -10
done

# Vérifier headers
for job in war pld dnc thf cor geo brd rdm; do
  echo "=== $job sets header ==="
  head -35 jobs/$job/sets/${job}_sets.lua | grep -E "Features:|Architecture:|@version"
done

# Compter sections par job
for job in war pld dnc thf cor geo brd rdm; do
  echo "$job sections:"
  grep -c "^--====.*--$" jobs/$job/sets/${job}_sets.lua
done
```

**✅ Validation:**

- [ ] WAR: Format PLD correct (header + séparateurs + sections)
- [ ] PLD: Format PLD correct (référence)
- [ ] DNC: Format PLD correct
- [ ] THF: Format PLD correct
- [ ] COR: Format PLD correct
- [ ] GEO: Format PLD correct
- [ ] BRD: Format PLD correct
- [ ] RDM: Format PLD correct

---

### **CATÉGORIE 7: CONFIGURATION FILES (EXTERNALISATION)**

Vérifier que TOUS les jobs ont leurs configs externalisées:

**Fichiers obligatoires par job:**

```bash
config/[job]/
├── [JOB]_KEYBINDS.lua       # OBLIGATOIRE
├── [JOB]_LOCKSTYLE.lua      # OBLIGATOIRE
└── [JOB]_MACROBOOK.lua      # OBLIGATOIRE
```

**Fichiers optionnels (selon job):**

```bash
config/[job]/
├── [JOB]_TP_CONFIG.lua      # WAR (TP bonus calculator)
├── [JOB]_BLU_MAGIC.lua      # PLD (BLU spell rotation)
├── [JOB]_SONG_CONFIG.lua    # BRD (song packs)
├── [JOB]_TIMING_CONFIG.lua  # BRD (delays)
└── [JOB]_SPELL_DATABASE.lua # RDM (enfeeble types)
```

**Commandes audit:**

```bash
# Vérifier fichiers obligatoires
for job in WAR PLD DNC THF COR GEO BRD RDM; do
  echo "=== $job config files ==="
  ls config/${job,,}/${job}_KEYBINDS.lua 2>/dev/null && echo "✅ Keybinds" || echo "❌ Keybinds MISSING"
  ls config/${job,,}/${job}_LOCKSTYLE.lua 2>/dev/null && echo "✅ Lockstyle" || echo "❌ Lockstyle MISSING"
  ls config/${job,,}/${job}_MACROBOOK.lua 2>/dev/null && echo "✅ Macrobook" || echo "❌ Macrobook MISSING"
done

# Lister tous les configs par job
for job in war pld dnc thf cor geo brd rdm; do
  echo "=== $job all configs ==="
  ls config/$job/*.lua 2>/dev/null
done
```

**✅ Validation obligatoire:**

- [ ] WAR: KEYBINDS + LOCKSTYLE + MACROBOOK présents
- [ ] PLD: KEYBINDS + LOCKSTYLE + MACROBOOK présents
- [ ] DNC: KEYBINDS + LOCKSTYLE + MACROBOOK présents
- [ ] THF: KEYBINDS + LOCKSTYLE + MACROBOOK présents
- [ ] COR: KEYBINDS + LOCKSTYLE + MACROBOOK présents
- [ ] GEO: KEYBINDS + LOCKSTYLE + MACROBOOK présents
- [ ] BRD: KEYBINDS + LOCKSTYLE + MACROBOOK présents
- [ ] RDM: KEYBINDS + LOCKSTYLE + MACROBOOK présents

**✅ Validation optionnelle (vérifier si justifiée):**

- [ ] WAR: TP_CONFIG présent et utilisé dans PRECAST
- [ ] PLD: BLU_MAGIC présent et utilisé dans MIDCAST
- [ ] BRD: SONG_CONFIG + TIMING_CONFIG présents et utilisés

---

## 🔍 MÉTRIQUES QUALITÉ GLOBALES

### **Tailles de fichiers (pas de monolithes)**

**Limites:**

- Hooks modules: < 300 lines (idéal < 200)
- Logic modules: < 400 lines (idéal < 300)
- Sets files: < 800 lines (idéal < 600)

**Commandes:**

```bash
# Vérifier tailles hooks modules
for job in WAR PLD DNC THF COR GEO BRD RDM; do
  echo "=== $job hooks sizes ==="
  wc -l jobs/${job,,}/functions/${job}_*.lua
done

# Vérifier tailles logic modules
for job in war pld dnc thf cor geo brd rdm; do
  echo "=== $job logic sizes ==="
  wc -l jobs/$job/functions/logic/*.lua 2>/dev/null
done

# Vérifier tailles sets files
for job in war pld dnc thf cor geo brd rdm; do
  echo "$job sets: $(wc -l jobs/$job/sets/${job}_sets.lua | awk '{print $1}') lines"
done
```

**✅ Validation:**

- [ ] Tous hooks < 300 lines
- [ ] Tous logic < 400 lines
- [ ] Tous sets < 800 lines

---

### **Documentation coverage**

**Headers obligatoires:**

- Tous les modules doivent avoir header avec @file, @author, @version, @date
- Fonctions publiques doivent avoir @param et @return

**Commandes:**

```bash
# Vérifier headers modules
for job in WAR PLD DNC THF COR GEO BRD RDM; do
  for file in PRECAST MIDCAST AFTERCAST IDLE ENGAGED STATUS BUFFS COMMANDS MOVEMENT LOCKSTYLE MACROBOOK; do
    echo "=== $job $file header ==="
    head -20 jobs/${job,,}/functions/${job}_${file}.lua | grep -E "@file|@author|@version|@date"
  done
done

# Vérifier documentation fonctions publiques
for job in WAR PLD DNC THF COR GEO BRD RDM; do
  echo "=== $job public functions doc ==="
  grep -A 5 "^function.*\." jobs/${job,,}/functions/${job}_*.lua | grep -E "@param|@return"
done
```

**✅ Validation:**

- [ ] 100% des modules ont headers complets
- [ ] 100% des fonctions publiques documentées

---

## 📊 RAPPORT FINAL ATTENDU

À la fin de l'audit, produire un rapport structuré:

```markdown
# AUDIT COMPLET MULTI-JOBS - RÉSULTATS

## Score Global: [X]/100

### Résumé par Catégorie:
1. Structure Modulaire: [8/8] jobs conformes
2. Architecture Hooks/Logic: [8/8] jobs conformes
3. Ordre Precast: [8/8] jobs conformes
4. Systèmes Centralisés: [8/8] jobs conformes
5. Code Mort/Duplication: [8/8] jobs propres
6. Format Sets: [8/8] jobs standardisés
7. Configuration Files: [8/8] jobs externalisés

### Détails par Job:

#### WAR (Warrior)
- ✅ Structure: 12 modules présents
- ✅ Logic: 2 modules (smartbuff_manager, set_builder)
- ✅ Precast ordre: Correct (PrecastGuard >> CooldownChecker >> WS >> Job)
- ✅ Centralisés: 7/7 systèmes utilisés
- ✅ Code: Propre, pas de duplication
- ✅ Sets: Format PLD standard (509 lines)
- ✅ Config: KEYBINDS + LOCKSTYLE + MACROBOOK + TP_CONFIG
- **Score WAR: 100/100** ✓

[... Répéter pour chaque job ...]

### Problèmes Détectés:
- [Liste numérotée si des problèmes trouvés]

### Recommandations:
- [Actions correctives si nécessaire]

### Conclusion:
[Résumé général de l'état du projet]
```

---

## 🚀 ORDRE D'EXÉCUTION AUDIT

1. **Phase 1: Structure** (Catégorie 1 + 2) >> Vérifier tous les fichiers présents
2. **Phase 2: Logique** (Catégorie 3 + 4) >> Vérifier ordre et intégrations
3. **Phase 3: Propreté** (Catégorie 5) >> Chercher code mort et duplication
4. **Phase 4: Format** (Catégorie 6) >> Vérifier standardisation sets
5. **Phase 5: Config** (Catégorie 7) >> Vérifier externalisation
6. **Phase 6: Métriques** >> Calculer tailles et documentation
7. **Phase 7: Rapport** >> Générer rapport final

**Temps estimé:** 30-45 minutes pour audit complet
