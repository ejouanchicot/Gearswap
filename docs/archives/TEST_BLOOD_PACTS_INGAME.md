# 🧪 GUIDE DE TEST IN-GAME: Blood Pacts Messages

**Date:** 2025-11-01
**Objectif:** Vérifier que les Blood Pacts affichent maintenant des messages
**Temps estimé:** 5-10 minutes

---

## ⚙️ PRÉREQUIS

1. ✅ Fix appliqué: `ability_message_handler.lua` ligne 94-105 (SMN fallback)
2. ✅ Database complète: `SMN_SPELL_DATABASE.lua` (136 spells mergés)
3. ✅ Jobs intégrés: `init_ability_messages.lua` chargé
4. ✅ WAR job disponible avec subjob SMN

---

## 🎯 TEST 1: Blood Pact: Ward (Earthen Ward) - LE TEST CRITIQUE

### Setup

```
1. //lua unload gearswap
2. Change to WAR/SMN in-game (menu job change ou //ja "Summoner" <me>)
3. //lua load gearswap
```

**Vérifications après load:**

```
✅ Devrait voir: "[WAR] SYSTEM LOADED"
✅ Devrait voir: "WAR Functions loaded successfully"
✅ Devrait voir keybinds loaded messages
```

### Test Titan Summon

```
4. Menu Magic >> Summoning Magic >> Titan
   Ou: /ma "Titan" <me>
```

**RÉSULTAT ATTENDU:**

```
[Titan] Summons Titan. ✅
```

**Si pas de message:**

- ❌ Spell handler cassé (Fix #1-5 incomplet)
- Vérifier: `spell_message_handler.lua` ligne 195-197

### Test Earthen Ward (LE TEST PRINCIPAL!)

```
5. Menu Pet Commands >> Blood Pact: Ward >> Earthen Ward
   Ou: /pet "Earthen Ward" <me>
```

**RÉSULTAT ATTENDU:**

```
[Earthen Ward] Grants stoneskin (AoE). ✅
```

**Si pas de message:**

- ❌ Ability handler SMN fallback cassé (Fix #6 incomplet)
- Vérifier: `ability_message_handler.lua` ligne 94-105
- Vérifier: `init_ability_messages.lua` est bien chargé dans Tetsouo_WAR.lua

**Si message affiché:**

- ✅ **FIX #6 FONCTIONNE!**
- ✅ **Blood Pacts 100% opérationnels!**

---

## 🎯 TEST 2: Blood Pact: Rage (Flaming Crush)

### Setup

```
1. Release Titan: /pet "Release" <me>
2. Summon Ifrit: /ma "Ifrit" <me>
```

**RÉSULTAT ATTENDU:**

```
[Ifrit] Summons Ifrit. ✅
```

### Test Flaming Crush

```
3. Menu Pet Commands >> Blood Pact: Rage >> Flaming Crush
   Ou: /pet "Flaming Crush" <t>
```

**RÉSULTAT ATTENDU:**

```
[Flaming Crush] Fire damage + knockback. ✅
```

---

## 🎯 TEST 3: Autres Blood Pacts (Quick Check)

### Blood Pact: Ward (Support/Buffs)

Test 3-5 ward abilities différents:

```
Titan:
- Earthen Ward >> [Earthen Ward] Grants stoneskin (AoE). ✅
- Earthen Armor >> [Earthen Armor] Stoneskin effect (AoE). ✅

Carbuncle:
- Shining Ruby >> [Shining Ruby] Party Regen. ✅
- Glittering Ruby >> [Glittering Ruby] AoE enmity + blinding. ✅

Garuda:
- Aerial Armor >> [Aerial Armor] Party Blink. ✅
```

### Blood Pact: Rage (Offensive)

Test 3-5 rage abilities différents:

```
Ifrit:
- Punch >> [Punch] Deals physical dmg. ✅
- Fire II >> [Fire II] Deals fire damage. ✅
- Flaming Crush >> [Flaming Crush] Fire damage + knockback. ✅

Leviathan:
- Barracuda Dive >> [Barracuda Dive] Water physical attack. ✅
- Spinning Dive >> [Spinning Dive] Physical attack + knockback. ✅

Fenrir:
- Eclipse Bite >> [Eclipse Bite] Dark physical damage. ✅
```

---

## 🎯 TEST 4: Avatar Summons (Validation Complète)

Test quelques avatar summons pour confirmer Fix #1-5 fonctionne aussi:

```
/ma "Carbuncle" <me> >> [Carbuncle] Summons Carbuncle. ✅
/ma "Shiva" <me> >> [Shiva] Summons Shiva. ✅
/ma "Garuda" <me> >> [Garuda] Summons Garuda. ✅
/ma "Ramuh" <me> >> [Ramuh] Summons Ramuh. ✅
/ma "Leviathan" <me> >> [Leviathan] Summons Leviathan. ✅
```

---

## 🎯 TEST 5: Spirit Summons (Optional)

Si niveau bas, tester spirits:

```
/ma "Fire Spirit" <me> >> [Fire Spirit] Summons Fire Spirit. ✅
/ma "Ice Spirit" <me> >> [Ice Spirit] Summons Ice Spirit. ✅
/ma "Light Spirit" <me> >> [Light Spirit] Summons Light Spirit. ✅
```

---

## 📊 RÉSULTATS ATTENDUS

### Si TOUS les tests passent:

```
✅ Avatar summons: Messages affichés (Fix #1-5 OK)
✅ Blood Pact: Ward: Messages affichés (Fix #6 OK)
✅ Blood Pact: Rage: Messages affichés (Fix #6 OK)
✅ Spirit summons: Messages affichés (Fix #1-5 OK)
```

**CONCLUSION:**

```
🎉 SYSTÈME 100% FONCTIONNEL!

Total validé:
- 858 spells (BLU, SMN, Enhancing, Songs, etc.)
- 308 abilities (including 116 Blood Pacts)
= 1,166 messages fonctionnels (100%)
```

### Si certains tests échouent:

**Échec Avatar Summons (Fix #1-5):**

```
❌ Problème: spell_message_handler
   Fichier: shared/utils/messages/spell_message_handler.lua
   Vérifier: Ligne 195-197 (categories SMN)
   Vérifier: Ligne 173-182 (action types)
```

**Échec Blood Pacts (Fix #6):**

```
❌ Problème: ability_message_handler SMN fallback
   Fichier: shared/utils/messages/ability_message_handler.lua
   Vérifier: Ligne 94-105 (SMN spell database fallback)
   Vérifier: init_ability_messages.lua chargé dans job file
```

**Échec Database:**

```
❌ Problème: SMN_SPELL_DATABASE incomplet
   Fichier: shared/data/magic/SMN_SPELL_DATABASE.lua
   Vérifier: Ligne 106-149 (blood_pacts merge)
   Test: //lua l test_blood_pacts.lua (devrait montrer 136 spells)
```

---

## 🐛 TROUBLESHOOTING

### "Aucun message pour Earthen Ward"

**Diagnostic:**

1. **Check ability_message_handler chargé:**

```lua
//lua e print(package.loaded['shared/utils/messages/ability_message_handler'] and 'LOADED' or 'NOT LOADED')
```

**Attendu:** `LOADED`

2. **Check SMN database accessible:**

```lua
//lua e local s = require('shared/data/magic/SMN_SPELL_DATABASE'); print(s.spells['Earthen Ward'] and 'FOUND' or 'NOT FOUND')
```

**Attendu:** `FOUND`

3. **Check init_ability_messages.lua:**

```lua
//lua e print(_G.user_post_precast and 'HOOKED' or 'NOT HOOKED')
```

**Attendu:** `HOOKED`

### "Message pour Titan mais pas pour Earthen Ward"

**Diagnostic:**

- ✅ Spell handler fonctionne (Titan summon = spell)
- ❌ Ability handler ne fonctionne pas (Earthen Ward = ability)

**Fix:**
Vérifier que `init_ability_messages.lua` est bien include dans `Tetsouo_WAR.lua`:

```lua
function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
    include('../shared/utils/core/INIT_SYSTEMS.lua')

    require('shared/utils/data/data_loader')

    include('../shared/hooks/init_spell_messages.lua')
    include('../shared/hooks/init_ability_messages.lua')  ← CRITIQUE!
end
```

### "Aucun message du tout (même Titan)"

**Diagnostic:**

- ❌ Spell handler cassé
- ❌ ou init_spell_messages.lua pas chargé

**Fix:**
Vérifier `init_spell_messages.lua` chargé dans job file.

---

## ✅ VALIDATION FINALE

Après tests complets:

**Si 100% réussite:**

```
□ Avatar summons: 12/12 messages ✅
□ Spirit summons: 8/8 messages ✅
□ Blood Pact: Rage: ~60 messages ✅
□ Blood Pact: Ward: ~58 messages ✅
□ TOTAL: 136/136 SMN messages fonctionnels ✅
```

**Next step:**

- Commit changements
- Mettre à jour documentation
- Tester autres jobs avec subjob SMN (RDM/SMN, SCH/SMN, etc.)

---

**Document créé:** 2025-11-01
**Auteur:** Claude (Anthropic)
**Objectif:** Validation in-game du fix Blood Pacts
**Criticité:** HAUTE (validation finale système 1,166 messages)
