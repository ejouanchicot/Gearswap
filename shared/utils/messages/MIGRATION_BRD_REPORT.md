# BRD Migration Report - Message System v2.0

**Date:** 2025-10-29
**Status:** ✅ COMPLETED (Partial - Core Functions Migrated)
**Safety:** 🛡️ **BACKUPS CREATED** - Can rollback if issues

---

## 🎯 OBJECTIF

Migrer BRD (Bard) vers le nouveau système de messages global pour:
- ✅ Éliminer duplication de code (message_brd.lua 880 lines → modules globaux)
- ✅ Utiliser fonctions universelles (partagées avec WAR, PLD, DRK, etc.)
- ✅ Organisation par TYPE (abilities/, magic/) au lieu de JOB

---

## 📊 FICHIERS MODIFIÉS

### **1. BRD_BUFFS.lua** ✅ MIGRÉ
**Localisation:** `shared/jobs/brd/functions/BRD_BUFFS.lua`
**Backup:** `BRD_BUFFS.lua.backup` (créé avant modification)

#### **Changements:**

| Ancien (message_brd.lua) | Nouveau (message_ja_buffs.lua) | Ligne |
|--------------------------|--------------------------------|-------|
| `show_soul_voice_activated()` | `show_ja_activated("Soul Voice", "Song power boost!")` | 25 |
| `show_soul_voice_ended()` | `show_ja_ended("Soul Voice")` | 27 |
| `show_nightingale_active()` | `show_ja_active("Nightingale")` | 35 |
| `show_troubadour_active()` | `show_ja_active("Troubadour")` | 43 |

**Fonctions NON migrées:**
- `show_doom_gained()` / `show_doom_removed()` (lignes 51-53)
  - **Raison:** Non critique, gardé en ancien système pour l'instant
  - **Statut:** Fonctionne toujours (via message_brd.lua)

---

### **2. BRD_PRECAST.lua** ✅ MIGRÉ
**Localisation:** `shared/jobs/brd/functions/BRD_PRECAST.lua`
**Backup:** `BRD_PRECAST.lua.backup` (créé avant modification)

#### **Changements:**

| Ancien (message_brd.lua) | Nouveau (Global System) | Ligne |
|--------------------------|-------------------------|-------|
| `show_soul_voice_activated()` | `show_ja_activated("Soul Voice", "Song power boost!")` | 152 |
| `show_nightingale_activated()` | `show_ja_with_description("Nightingale", "Casting Time reduced")` | 154 |
| `show_troubadour_activated()` | `show_ja_with_description("Troubadour", "Song duration extended")` | 156 |
| `show_pianissimo_used()` | `show_song_pianissimo_used()` | 158 |

**Autres fonctions dans ce fichier (NON modifiées):**
- `show_pianissimo_target()` (ligne 92) → message_songs.lua ✓
- `show_marcato_honor_march()` (ligne 126) → message_songs.lua ✓
- `show_honor_march_locked()` (ligne 168) → message_songs.lua ✓

---

### **3. BRD_COMMANDS.lua** ⚠️ NON MIGRÉ
**Localisation:** `shared/jobs/brd/functions/BRD_COMMANDS.lua`
**Backup:** `BRD_COMMANDS.lua.backup` (créé avant modification)

#### **Statut:** GARDÉ ANCIEN SYSTÈME

**Raison:**
- 30+ fonctions spécifiques BRD (lullaby, elegy, requiem, threnody, carol, etude, dummy, etc.)
- Trop de fonctions à migrer en une fois (risque élevé)
- Ces fonctions sont très spécifiques BRD (pas réutilisables par autres jobs)

**Fonctions utilisées (non exhaustif):**
- `show_lullaby_cast()`, `show_elegy_cast()`, `show_requiem_cast()`
- `show_threnody_cast()`, `show_carol_cast()`, `show_etude_cast()`
- `show_dummy_cast()`, `show_song_cast()`, `show_clarion_required()`
- `show_ability_command()`, `show_marcato_used()`

**Décision:**
- ✅ Garder tel quel pour l'instant
- ✅ Ces fonctions continueront d'utiliser message_brd.lua (ancien système)
- ⏳ Migration ultérieure possible si besoin

---

## 🔄 MODULES UTILISÉS

### **Nouveau Système (Migré vers)**

1. **abilities/message_ja_buffs.lua** (Global - ALL jobs)
   ```lua
   MessageFormatter.show_ja_activated("Soul Voice", "Song power boost!")
   MessageFormatter.show_ja_active("Nightingale")
   MessageFormatter.show_ja_ended("Soul Voice")
   MessageFormatter.show_ja_with_description("Troubadour", "Song duration extended")
   ```

2. **magic/message_songs.lua** (BRD-specific, TYPE-organized)
   ```lua
   MessageFormatter.show_song_pianissimo_used()
   MessageFormatter.show_song_pianissimo_target("Kaories")
   MessageFormatter.show_song_marcato_honor_march("Honor March")
   MessageFormatter.show_song_honor_march_locked()
   ```

### **Ancien Système (Toujours utilisé)**

1. **message_brd.lua** (880 lines - Job-specific)
   - Fonctions Doom (show_doom_gained, show_doom_removed)
   - Fonctions Songs BRD_COMMANDS (lullaby, elegy, requiem, etc.)
   - ⚠️ **NE PAS SUPPRIMER** - Toujours nécessaire pour BRD_COMMANDS

---

## ✅ BÉNÉFICES

### **Code Reduction**
- **BRD_BUFFS.lua:** 4 fonctions migrées vers système global
- **BRD_PRECAST.lua:** 4 fonctions migrées vers système global
- **Total:** 8 appels vers ancien système → 8 appels vers nouveau système

### **Réutilisabilité**
- ✅ WAR peut maintenant utiliser `show_ja_activated("Berserk", "Attack boost!")`
- ✅ PLD peut utiliser `show_ja_activated("Sentinel", "Defense boost!")`
- ✅ DRK peut utiliser `show_ja_activated("Last Resort", "Attack boost!")`
- ✅ Même fonction pour TOUS les jobs (0% duplication)

### **Maintenabilité**
- ✅ Modifier format JA activation → 1 fichier (message_ja_buffs.lua)
- ✅ Bug fix → Centralisé (1 fix = tous jobs corrigés)

---

## 🛡️ SÉCURITÉ

### **Backups Créés**
```
BRD_BUFFS.lua.backup      ✅ Créé
BRD_PRECAST.lua.backup    ✅ Créé
BRD_COMMANDS.lua.backup   ✅ Créé
```

### **Rollback Procedure**
Si problème détecté in-game:

```bash
# Restaurer backups
cd "D:\Windower Tetsouo\addons\GearSwap\data\shared\jobs\brd\functions"
cp BRD_BUFFS.lua.backup BRD_BUFFS.lua
cp BRD_PRECAST.lua.backup BRD_PRECAST.lua
cp BRD_COMMANDS.lua.backup BRD_COMMANDS.lua

# Recharger GearSwap in-game
//lua r gearswap
```

### **Backward Compatibility**
- ✅ **100%** - Ancien système (message_brd.lua) toujours chargé
- ✅ Si nouveau système échoue, ancien système fonctionne en fallback
- ✅ BRD_COMMANDS.lua utilise toujours ancien système (0 risque)

---

## 🧪 TESTS À FAIRE

### **Test 1: Chargement GearSwap**
```
1. Changer job vers BRD in-game
2. //lua r gearswap
3. Vérifier: Aucune erreur Lua dans console
4. Vérifier: [BRD] SYSTEM LOADED message affiché
```

**Résultat attendu:** ✅ Pas d'erreur, chargement normal

---

### **Test 2: Soul Voice**
```
1. //ja "Soul Voice" <me>
2. Vérifier message affiché:
   [BRD/WHM] Soul Voice activated! Song power boost!
```

**Résultat attendu:**
- ✅ Message affiché avec couleurs (cyan [BRD/WHM], yellow Soul Voice, green activated!, white description)
- ✅ Format identique à avant migration

---

### **Test 3: Nightingale**
```
1. //ja "Nightingale" <me>
2. Vérifier message affiché:
   [BRD/WHM] Nightingale: Casting Time reduced
```

**Résultat attendu:**
- ✅ Message affiché avec format colon (: au lieu de activated!)
- ✅ Couleurs correctes

---

### **Test 4: Troubadour**
```
1. //ja "Troubadour" <me>
2. Vérifier message affiché:
   [BRD/WHM] Troubadour: Song duration extended
```

**Résultat attendu:**
- ✅ Message affiché avec format colon
- ✅ Couleurs correctes

---

### **Test 5: Buff Ended**
```
1. Attendre que Soul Voice expire (buff wear off)
2. Vérifier message affiché:
   [BRD/WHM] Soul Voice ended
```

**Résultat attendu:**
- ✅ Message "ended" affiché quand buff disparaît
- ✅ Couleurs correctes

---

### **Test 6: BRD Commands (Ancien système)**
```
1. //gs c lullaby
2. Vérifier message affiché (ancien système)
```

**Résultat attendu:**
- ✅ Message affiché normalement (via message_brd.lua)
- ✅ Pas de changement vs avant migration

---

## 📝 NOTES TECHNIQUES

### **Duplication Messages PRECAST vs BUFFS**
**Observation:** Messages peuvent apparaître 2 fois:
1. PRECAST: Quand ability utilisée (instant)
2. BUFFS: Quand buff gagné (1-2s après, confirmation serveur)

**Exemple:**
```
[BRD/WHM] Soul Voice activated! Song power boost!  ← PRECAST (instant)
[BRD/WHM] Soul Voice activated! Song power boost!  ← BUFFS (1s après)
```

**Solutions possibles:**
1. **Option A:** Garder les deux (feedback immédiat + confirmation)
2. **Option B:** Supprimer messages BUFFS (garder seulement PRECAST)
3. **Option C:** Afficher message différent dans BUFFS (ex: "Soul Voice active" au lieu de "activated!")

**Décision actuelle:** Option A (garder les deux) - À évaluer in-game

---

## 🚀 PROCHAINES ÉTAPES

### **Immédiat**
- [ ] Tester in-game BRD (tous tests ci-dessus)
- [ ] Valider que messages s'affichent correctement
- [ ] Vérifier pas d'erreurs Lua

### **Court Terme**
- [ ] Décider si on garde duplication PRECAST/BUFFS ou pas
- [ ] Migrer fonctions Doom vers nouveau système (optionnel)
- [ ] Migrer BRD_COMMANDS.lua vers nouveau système (optionnel, bas priorité)

### **Long Terme**
- [ ] Migrer autres jobs (BLM, RDM, GEO, BST, COR)
- [ ] Supprimer message_brd.lua (après migration complète BRD_COMMANDS)
- [ ] Cleanup wrappers backward compatibility

---

## 📚 RÉFÉRENCES

**Fichiers Modifiés:**
- `shared/jobs/brd/functions/BRD_BUFFS.lua` (lignes 22-55)
- `shared/jobs/brd/functions/BRD_PRECAST.lua` (lignes 148-160)

**Modules Nouveau Système:**
- `shared/utils/messages/abilities/message_ja_buffs.lua`
- `shared/utils/messages/magic/message_songs.lua`
- `shared/utils/messages/message_formatter.lua` (façade)

**Documentation:**
- `shared/utils/messages/README_MESSAGES.md` - Guide complet nouveau système
- `.claude/standards.md` - Standards projet Tetsouo

---

**FIN RAPPORT - BRD Migration Phase 1 Completed ✅**
