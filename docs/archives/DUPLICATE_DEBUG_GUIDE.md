# 🐛 DEBUG GUIDE: Messages Doublons - Identifier la Source

**Date:** 2025-11-01
**Issue:** Messages doublons pour certains abilities (Berserk, etc.)
**Status:** 🔍 INVESTIGATION REQUISE

---

## 🎯 PROBLÈME

**User Report:**

- WAR Berserk: Messages en double
- DNC Reverse Flourish: Aucun message
- DNC Haste Samba: Aucun message

**Hypothèses:**

1. 2 systèmes affichent messages (JABuffs + ability_message_handler)
2. ability_message_handler appelle 2 fois
3. Autre système non identifié

---

## 🧪 TESTS DEBUG

### TEST 1: Désactiver ability_message_handler

**Objectif:** Voir si messages persistent sans ability_message_handler

**Procédure:**

```
1. Ouvrir: Tetsouo/Tetsouo_WAR.lua

2. Commenter cette ligne:
   -- include('../shared/hooks/init_ability_messages.lua')

3. Save

4. //lua u gearswap
5. //lua l gearswap

6. Use Berserk
```

**Résultat A (Aucun message):**

```
(Aucun message affiché)
```

→ **Conclusion:** ability_message_handler était la SEULE source
→ **Problème:** ability_message_handler appelé 2 fois (bug interne)

**Résultat B (1 message):**

```
[WAR/SAM] Berserk activated! ATK+25% DEF-25%
```

→ **Conclusion:** Il y a un AUTRE système qui affiche (JABuffs ou autre)
→ **Problème:** Conflit entre 2 systèmes

**Résultat C (2 messages):**

```
[WAR/SAM] Berserk activated! ATK+25% DEF-25%
[WAR/SAM] Berserk activated! ATK+25% DEF-25%
```

→ **Conclusion:** L'AUTRE système appelle 2 fois
→ **Problème:** Bug dans l'autre système

---

### TEST 2: Identifier Format des Messages

**Objectif:** Voir quel format chaque message a

**Procédure:**

```
1. Réactiver ability_message_handler (uncommenter ligne)
2. //lua u gearswap
3. //lua l gearswap
4. Use Berserk
5. Screenshot ou copier EXACTEMENT les 2 messages
```

**Formats Possibles:**

**Format A (JABuffs):**

```
[WAR/SAM] Berserk activated! ATK+25% DEF-25%
```

**Format B (ability_message_handler):**

```
[Berserk] → ATK+25% DEF-25%
```

**Format C (Autre):**

```
(Note le format exact)
```

---

### TEST 3: DNC Abilities (Pas de Messages)

**Objectif:** Vérifier si DNC abilities ont data dans database

**Procédure:**

```lua
//lua e local db = require('shared/data/job_abilities/DNC_JA_DATABASE'); print(db.abilities and 'HAS ABILITIES' or 'NO ABILITIES')
```

**Résultat Attendu:**

```
HAS ABILITIES
```

**Si NO ABILITIES:**
→ Database DNC pas chargée ou corrompue

**Puis tester ability spécifique:**

```lua
//lua e local db = require('shared/data/job_abilities/DNC_JA_DATABASE'); local rf = db.abilities['Reverse Flourish']; print(rf and rf.description or 'NOT FOUND')
```

**Résultat Attendu:**

```
Grants TP bonus based on # of Finishing Moves consumed.
```

**Si NOT FOUND:**
→ Ability pas dans database (nom incorrect ou manquant)

---

### TEST 4: Check ability_message_handler Appelé

**Objectif:** Voir si handler est appelé pour DNC

**Procédure:**

```
1. Ouvrir: shared/utils/messages/ability_message_handler.lua

2. Ajouter debug print ligne 133 (après "if not spell"):
   print("DEBUG ability_message_handler: " .. tostring(spell.name) .. " type=" .. tostring(spell.type))

3. Save

4. //lua u gearswap
5. Change to DNC/WAR
6. //lua l gearswap

7. Use Reverse Flourish
```

**Résultat Attendu:**

```
DEBUG ability_message_handler: Reverse Flourish type=JobAbility
[Reverse Flourish] → Grants TP bonus based on # of Finishing Moves consumed.
```

**Si pas de DEBUG print:**
→ Handler pas appelé du tout (init_ability_messages.lua pas chargé)

**Si DEBUG print mais pas de message:**
→ Handler return early (ability_data not found ou autre check)

---

### TEST 5: Timestamp Duplicates

**Objectif:** Voir si duplicate prevention fonctionne

**Procédure:**

```
1. Ouvrir: shared/utils/messages/ability_message_handler.lua

2. Ajouter debug print ligne 191 (dans duplicate check):
   if last_shown and (current_time - last_shown) < DUPLICATE_THRESHOLD then
       print("DEBUG: Duplicate prevented for " .. spell.name .. " (last shown " .. string.format("%.3f", current_time - last_shown) .. "s ago)")
       return
   end

3. Save

4. //lua u gearswap
5. //lua l gearswap

6. Use Berserk
```

**Si voir "Duplicate prevented":**
→ Duplicate prevention fonctionne
→ Mais pourquoi 2 appels en premier lieu?

---

## 📊 DIAGNOSTIC WORKFLOW

```
1. Run TEST 1 (Disable ability_message_handler)
   ↓
2a. Si aucun message → ability_message_handler seule source
    → Run TEST 5 (Check duplicates timestamps)
    → Fix: Duplicate prevention

2b. Si 1 message → Autre système existe
    → Run TEST 2 (Identify format)
    → Check où autre système est appelé
    → Fix: Désactiver un des 2 systèmes

2c. Si 2 messages → Autre système a bug
    → Identifier autre système
    → Fix: Bug dans autre système

3. Run TEST 3+4 (DNC abilities)
   ↓
3a. Si database OK mais pas de message → Handler pas appelé
    → Fix: Vérifier init_ability_messages.lua chargé

3b. Si database manquante → Database corrompue
    → Fix: Recréer database

3c. Si handler appelé mais return early → Check logic
    → Fix: Debug find_ability_in_databases()
```

---

## 🔧 FIXES POSSIBLES

### Fix A: Duplicate Prevention (Already Applied)

**Si:** ability_message_handler seule source mais appelé 2 fois

**Solution:** Timestamp-based duplicate prevention (DÉJÀ APPLIQUÉ)

```lua
-- Check if message shown in last 500ms
if last_shown and (current_time - last_shown) < DUPLICATE_THRESHOLD then
    return  -- Skip duplicate
end
```

**Fichier:** `ability_message_handler.lua` ligne 187-197

---

### Fix B: Disable JABuffs for Abilities with Database

**Si:** JABuffs + ability_message_handler conflit

**Solution:** Disable JABuffs calls, keep only ability_message_handler

**Procédure:**

```
1. Find where JABuffs.show_activated() is called
2. Comment out those calls
3. Let ability_message_handler handle all
```

---

### Fix C: Add DNC Abilities to Database

**Si:** DNC abilities manquants dans database

**Solution:** Verify DNC_JA_DATABASE.lua has all abilities

**Check:**

```lua
shared/data/job_abilities/DNC_JA_DATABASE.lua

Should have:
- Reverse Flourish
- Haste Samba
- Drain Samba
- Aspir Samba
- etc.
```

---

### Fix D: Ensure init_ability_messages.lua Loaded

**Si:** Handler pas appelé pour DNC

**Solution:** Verify hook loaded in Tetsouo_DNC.lua

**Check:**

```lua
Tetsouo/Tetsouo_DNC.lua

function get_sets()
    ...
    include('../shared/hooks/init_ability_messages.lua')  ← MUST EXIST
end
```

---

## 📝 RAPPORT DEBUG

Après tests, remplir:

```
========================================
DEBUG REPORT - DUPLICATE MESSAGES
========================================
Date: ___________

TEST 1 (Disable ability_message_handler):
□ Résultat: ___________ (A/B/C)
□ Conclusion: ___________

TEST 2 (Message Format):
□ Format message 1: ___________
□ Format message 2: ___________
□ Systèmes identifiés: ___________

TEST 3 (DNC Database):
□ Database chargée: ___ (YES/NO)
□ Reverse Flourish dans DB: ___ (YES/NO)
□ Description: ___________

TEST 4 (Handler Called):
□ DEBUG print vu: ___ (YES/NO)
□ Message affiché: ___ (YES/NO)
□ Reason si pas de message: ___________

TEST 5 (Duplicate Prevention):
□ Duplicate prevented print: ___ (YES/NO)
□ Timestamps: ___________

CONCLUSION:
□ Problème identifié: ___________
□ Fix requis: ___________
□ Fix appliqué: ___________
□ Re-test: ___ (PASS/FAIL)
```

---

## 🚀 NEXT STEPS

1. **Run Tests 1-5**
2. **Fill Report**
3. **Identify Root Cause**
4. **Apply Appropriate Fix**
5. **Re-test**
6. **Update Documentation**

---

**Créé:** 2025-11-01
**Auteur:** Claude (Anthropic)
**Objectif:** Identifier source messages doublons
**Priority:** HAUTE (blocking commit)

**🔍 DEBUG REQUIS AVANT FIX FINAL 🔍**
