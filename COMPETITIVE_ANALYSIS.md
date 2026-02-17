# GearSwap Tetsouo - Analyse Comparative Complète
**Date**: 2026-02-16 | **Frameworks analysés**: 5

---

## 1. VUE D'ENSEMBLE

| Métrique | Tetsouo | Selindrile | SilverLibs | Arislan | Mote |
|----------|---------|------------|------------|---------|------|
| **Fichiers Lua** | ~614 | ~38 | ~47 | ~23 | ~22 |
| **Lignes totales** | ~95,000 | ~15-20,000 | ~35-40,000 | ~15-18,000 | ~8-10,000 |
| **Jobs couverts** | 15 | 22 | 16 | 14 | 19 |
| **Architecture** | 12 modules/job | 1 fichier/job + 14 libs | 1 fichier/job + 1 lib | 1 fichier/job | 1 fichier/job |
| **Taille par job** | 2,000-4,200 (12-17 fichiers) | 450-520 (1 fichier) | 1,800-2,000 (1 fichier) | 1,100-1,400 (1 fichier) | 364-551 (1 fichier) |
| **Code partagé** | ~65,000 lignes | ~6,200 (14 libs) | ~2,800 (SilverLibs.lua) | ~450 (globals) | 0 (Mote-Include séparé) |
| **Statut** | Actif | Actif | Actif | Abandonné | Template |
| **Multi-personnage** | 4 persos + clone tool | 1 par dossier | 3 persos | 2 persos | 1 perso |

---

## 2. ARCHITECTURE

### Tetsouo
```
614 fichiers / 4 couches (Data → Utils → Hooks → Jobs)
Par job: facade + 12 modules (PRECAST/MIDCAST/AFTERCAST/IDLE/ENGAGED/STATUS/BUFFS/
         COMMANDS/MOVEMENT/LOCKSTYLE/MACROBOOK + logic/)
9 systèmes centralisés obligatoires
Config externalisée par job (STATES/KEYBINDS/TP_CONFIG/LOCKSTYLE/MACROBOOK)
```

### Selindrile
```
38 fichiers / 2 couches (libs → data)
Par job: 1 fichier monolithique (450-520 lignes)
14 bibliothèques partagées (Sel-Include ~1850L, Sel-Utility ~2500L, etc.)
Sel-Include fait le gros du travail (30+ systèmes dans 1 fichier)
50+ override hooks pour customisation sans éditer le core
```

### SilverLibs
```
47 fichiers / overlay sur Mote ou Selindrile
Par job: 1 fichier monolithique (1,800-2,000+ lignes)
1 bibliothèque massive: SilverLibs.lua (~2,800 lignes, 23 systèmes)
Monkey-patching de Mote-Include (fragile mais puissant)
```

### Arislan
```
23 fichiers / monolithique pur
Par job: 1 fichier tout-en-un (1,100-1,400 lignes)
1 fichier globals (~450 lignes) pour augments partagés
Aucune abstraction, aucun système partagé
```

### Mote/Kinematics
```
22 fichiers / template minimaliste
Par job: 1 fichier propre (364-551 lignes)
Repose sur Mote-Include (que TOUT le monde utilise comme base)
Créateur du pattern precast/midcast/aftercast
```

**Verdict Architecture**: Tetsouo est le seul framework avec une vraie séparation des concerns. Tous les autres sont monolithiques.

---

## 3. COMPARAISON FEATURES GAMEPLAY (EXHAUSTIVE)

### 3A. Intelligence Spell/Magie

| Feature | Tetsouo | Selindrile | SilverLibs | Arislan | Mote |
|---------|---------|------------|------------|---------|------|
| Fast Cast precast | OUI | OUI | OUI | OUI | OUI |
| Midcast gear selection | OUI (7-level fallback auto) | OUI (manual) | OUI (manual) | OUI (manual) | OUI (manual) |
| Spell tier downgrade (BLM) | OUI (6 tiers: VI→V→IV→III→II→I + Ja→Ga chain) | NON | NON | Partiel (Aspir III→II→I seul) | NON |
| Song tier downgrade (BRD) | OUI (Lullaby, Elegy, Requiem, Threnody) | NON | NON | NON | NON |
| Song rotation manager | OUI (3 phases: buff→dummy→replace, Clarion Call aware) | NON (3-song loop basique) | NON | NON | NON |
| Auto-Pianissimo | OUI (détection target party auto) | OUI | OUI | OUI (commenté/désactivé) | OUI (original) |
| Auto-Marcato | OUI (configurable, combo Nitro) | NON | NON | NON | NON |
| Instrument lock (BRD) | OUI (Marsyas, Loughnashade - protection cast entier) | NON | NON | NON | NON |
| Impact body lock (BLM) | OUI (Twilight Cloak protection) | NON | NON | NON | NON |
| Phalanx auto-swap (RDM) | OUI (Phalanx↔Phalanx II selon target) | NON | NON | NON | NON |
| Saboteur auto-trigger (RDM) | OUI (configurable par spell) | NON | NON | OUI (inline) | NON |
| Storm + Klimaform auto (BLM) | OUI (séquence 4.5s avec recast check) | NON | NON | NON | NON |
| Self-buff automation (BLM) | OUI (Stoneskin→Blink→Aquaveil séquencé) | OUI (check_buff rotation) | NON | NON | NON |
| Aspir cascade (BLM) | OUI (III→II→I spell_refiner) | NON | NON | OUI (III→II→I) | NON |
| Death Mode (BLM) | NON | NON | NON | OUI (pipeline dédié) | NON |
| Mana Wall automation | OUI (JA precast + buff set auto-apply) | NON | NON | OUI (equip+lock+release) | NON |
| Magic Burst mode | OUI (BLM MagicBurstMode toggle + MB sets) | OUI (Single/Lock + elemental wheel) | NON | OUI | NON |
| Elemental nuke auto | NON | OUI (auto-cycle éléments) | NON | NON | NON |
| GEO spell refiner | OUI (module dédié) | NON | NON | NON | NON |

### 3B. Intelligence Combat/WS

| Feature | Tetsouo | Selindrile | SilverLibs | Arislan | Mote |
|---------|---------|------------|------------|---------|------|
| WS precast centralisé | OUI (WSPrecastHandler: range+TP bonus+gear) | NON (per-job) | Partiel (cancel outranged) | NON | NON |
| TP Bonus Calculator | OUI (centralisé) | NON | NON | NON | NON |
| WS variant par buff (DNC) | OUI (SaberDance/FanDance/Climactic: 6 niveaux) | NON | NON | N/A | NON |
| SA/TA variant (THF) | OUI (SATA>SA>TA>Base avec pending flags) | NON | OUI (Feint/SA/TA priority) | NON | NON |
| Dark Seal variant (DRK) | OUI (DarkSeal/NetherVoid pending detection) | NON | NON | NON | NON |
| Climactic auto-trigger (DNC) | OUI (multi-condition: TP, target HP%, FM count) | NON | NON | N/A | NON |
| Step + Presto chain (DNC) | OUI (alternation Main/Alt, level-gating) | NON | OUI (inline) | N/A | NON |
| Jump/High Jump rotation (DRG sub) | OUI (fallback, Odyssey aware) | OUI (check_jump) | NON | NON | NON |
| Auto-WS at TP threshold | NON | OUI (autowstp) | NON | NON | NON |
| Skillchain mode | NON | OUI (Single/Lock) | NON | NON | NON |
| Attack-capped WS variants | NON | NON | OUI (THF documented stats) | NON | NON |
| Aftermath detection | OUI (Lv.3: THF/DRK/SAM/WAR) | OUI (Lv1/2/3 tracking) | OUI | OUI (BRD/COR) | NON |

### 3C. Intelligence Rolls/Party (COR)

| Feature | Tetsouo | Selindrile | SilverLibs | Arislan | Mote |
|---------|---------|------------|------------|---------|------|
| Roll tracking | OUI (packet parsing, 732 lignes) | Basique (roll_data + display) | OUI (22 rolls inline) | OUI (24 rolls inline) | NON |
| Bonus calculation avec gear | OUI (Rostam +8, Regal +7, etc.) | NON | NON | NON | NON |
| Job bonus detection (party) | OUI (scan party member jobs) | NON | NON | NON | NON |
| Natural 11 tracking | OUI (recast+bust immunity) | NON | NON | NON | NON |
| Crooked Cards multiplier | OUI (20% persistence) | NON | NON | NON | NON |
| Bust rate calculation | OUI (probabilité next Double-Up) | NON | NON | NON | NON |
| Party member miss detection | OUI (range depuis Luzaf's Ring) | NON | NON | NON | NON |
| Double-Up optimization | OUI | Minimal | NON | NON | NON |

### 3D. Intelligence Pet (BST)

| Feature | Tetsouo | Selindrile | SilverLibs | Arislan | Mote |
|---------|---------|------------|------------|---------|------|
| Pet status tracking | OUI (3-layer cache) | OUI (basique) | NON | NON | OUI (basique) |
| Ecosystem cycling | OUI (7 ecosystems, dynamic state) | NON | NON | NON | NON |
| Ready move categorization | OUI (Physical/Multi/MagAtk/MagAcc, 90+ moves) | NON | NON | NON | NON |
| Pet gear optimization | OUI (4 catégories de sets) | OUI (basique) | NON | NON | OUI (basique) |

### 3E. Systèmes Défensifs

| Feature | Tetsouo | Selindrile | SilverLibs | Arislan | Mote |
|---------|---------|------------|------------|---------|------|
| PrecastGuard (debuff blocking) | OUI (centralisé, priorité ranking) | OUI (check_disable inline) | OUI (status block) | NON | NON |
| Doom Manager | OUI (auto slot lock/unlock, death safety) | OUI (inline) | OUI (inline) | OUI (inline) | NON |
| Cooldown Checker | OUI (centralisé, multi-charge exclusion) | OUI (check_recast) | OUI (can_recast) | NON | NON |
| Midcast Watchdog | OUI (timeout dynamique par spell, FC reduction) | NON | NON | NON | NON |
| Debuff categorization | OUI (5 catégories: magic/JA/WS/universal/item) | OUI (inline) | NON | NON | NON |
| Cure set builder | OUI (self vs other, PLD/RUN/WHM) | NON | NON | NON | NON |
| Rune manager | OUI (PLD/RUN, cooldown validation) | OUI (check_rune) | NON | NON | OUI (original) |
| AOE manager (PLD BLU) | OUI (rotation Blue Magic, spell tracking) | NON | NON | NON | NON |
| Waltz tier selection | OUI (HP-based, level detection DNC main/sub) | OUI (refine_waltz) | OUI (potency formulas) | NON | NON |

### 3F. Systèmes Warp/Navigation

| Feature | Tetsouo | Selindrile | SilverLibs | Arislan | Mote |
|---------|---------|------------|------------|---------|------|
| Warp detection | OUI (81 sources: 13 spells + 68 items) | OUI (check_warps basique) | NON | NON | NON |
| Warp databases | OUI (6 fichiers: core/home/nations/teleports/cities/adoulin) | NON | NON | NON | NON |
| Warp equipment lock | OUI (FC pendant warp) | NON | NON | NON | NON |
| Warp IPC dual-box | OUI (multi-character sync) | NON | NON | NON | NON |

### 3G. Systèmes UI/Messages

| Feature | Tetsouo | Selindrile | SilverLibs | Arislan | Mote |
|---------|---------|------------|------------|---------|------|
| Message engine | OUI (17,550 lignes, 80 fichiers) | NON (add_to_chat) | NON (add_to_chat) | NON (add_to_chat) | NON |
| UI Display system | OUI (8 fichiers, 3,096 lignes) | OUI (Sel-Display) | OUI (Luopan UI seul) | NON | NON |
| Color system configurable | OUI (COLOR_SYSTEM.lua) | OUI (inline) | NON | OUI (hardcoded) | NON |
| Performance profiler | OUI (timer par module) | NON | NON | NON | NON |
| Debug midcast command | OUI (//gs c debugmidcast) | NON | NON | NON | NON |
| Message validators | OUI | NON | NON | NON | NON |
| 24 fichiers de tests | OUI | NON | NON | NON | NON |

### 3H. Systèmes Data/Databases

| Feature | Tetsouo | Selindrile | SilverLibs | Arislan | Mote |
|---------|---------|------------|------------|---------|------|
| Spell databases | OUI (93 fichiers, ~14,000 lignes) | NON | NON | NON | NON |
| JA databases | OUI (90 fichiers, 22 jobs) | NON | NON | NON | NON |
| WS databases | OUI (14 fichiers, ~200 WS) | NON | NON | NON | NON |
| Warp item database | OUI (68 items) | NON | NON | NON | NON |
| BST ecosystem data | OUI (2 fichiers) | NON | NON | NON | NON |
| Roll data | OUI (fichier dédié) | OUI (inline) | OUI (inline) | OUI (inline) | NON |
| Monster abilities | NON | OUI (Sel-MonsterAbilities) | NON | NON | NON |
| **Total data** | **~31,300 lignes** | **~500 lignes** | **~200 lignes** | **0** | **0** |

### 3I. Quality of Life / Divers

| Feature | Tetsouo | Selindrile | SilverLibs | Arislan | Mote |
|---------|---------|------------|------------|---------|------|
| Dualbox manager | OUI (IPC coordination) | NON | NON | NON | NON |
| Character clone tool | OUI (Python) | NON | NON | NON | NON |
| Equipment checker | OUI (validation gear) | NON | OUI (checkgear) | NON | NON |
| Wardrobe auditor | OUI (inventaire manquant) | NON | NON | NON | NON |
| Job Change debouncing | OUI (3.0s + full reload) | NON | NON | NON | NON |
| Factory lockstyle | OUI (LockstyleManager.create) | NON | OUI (auto) | NON | NON |
| Factory macrobook | OUI (MacrobookManager.create) | NON | OUI (manual) | OUI (manual) | OUI |
| Config externalisée | OUI (5 fichiers/job) | NON | NON | NON | NON |
| Treasure Hunter | OUI (TreasureMode: Tag/SATA/Full, 6 sets) | OUI (Sel-TreasureHunter) | OUI (AOE-aware mob tagging) | OUI | NON |
| Ammo management | NON | OUI (check_ammo) | OUI (catégories) | OUI (COR warnings) | NON |
| No-swap gear protection | NON | NON | OUI (80+ items) | OUI (rings) | NON |
| Weapon rearm auto | NON | NON | OUI (auto re-equip) | NON | NON |
| Auto-Reraise | NON | NON | OUI (HP threshold) | NON | NON |
| Snapshot auto-equip | NON | NON | OUI | NON | NON |
| Auto-nuke cycling | NON | OUI (elemental wheel) | NON | NON | NON |
| Auto-WS at TP | NON | OUI (autowstp + ranged) | NON | NON | NON |
| Auto-Trust summon | NON | OUI (trust list management) | NON | NON | NON |
| Auto-Food | NON | OUI (check_food) | NON | NON | NON |
| Crafting mode | NON | OUI (8 professions + HQ/NQ) | NON | NON | NON |
| Time-based gear (day/night) | NON | OUI (daytime/dusk detection) | NON | NON | NON |
| Zone-specific handling | NON | OUI (cities/Abyssea/Omen/Assault) | NON | NON | NON |
| Haste/DW tier detection | NON | OUI (latency-based) | OUI (HasteInfo addon) | OUI (5 tiers) | NON |
| Flurry packet reading | NON | NON | OUI | OUI (COR) | NON |
| Buff conflict cancellation | NON | OUI (cancel_conflicting_buffs) | OUI (auto-cancel) | NON | NON |
| Sleep timer display | NON | NON | NON | OUI (RDM détaillé) | NON |
| Utsusemi image cancel | OUI (DNC Ichi auto-cancel) | OUI (check_shadows) | OUI | OUI (3+ images) | NON |
| Pending flag detection | OUI (DRK/DNC/THF - 0.1-0.3s avant buff) | NON | NON | NON | NON |
| Anti-spam temporal | OUI (0.2-2.0s par système) | NON | NON | NON | NON |
| Packet-driven party intel | OUI (COR roll + party jobs) | NON | NON | NON | NON |

---

## 4. COMPTAGE FEATURES

| Framework | Features gameplay uniques | Features totales | Systèmes centralisés |
|-----------|--------------------------|-----------------|---------------------|
| **Tetsouo** | **21** | **~50** | **9 obligatoires + 14 additionnels** |
| **Selindrile** | 8 | ~35 | 0 (tout dans Sel-Include) |
| **SilverLibs** | 15 | ~30 | 0 (tout dans 1 fichier) |
| **Arislan** | 5 | ~20 | 0 |
| **Mote** | 3 | ~10 | 0 |

### Features UNIQUES à Tetsouo (que personne d'autre n'a) :
1. Architecture 12 modules/job
2. MidcastManager 7-level fallback automatique
3. MessageFormatter (17,550 lignes, 80 fichiers)
4. Spell tier downgrade complet BLM (6 niveaux, Ja→Ga chain)
5. Song rotation manager 3 phases (BRD)
6. Song tier downgrade (4 types de songs)
7. Instrument lock protection (Marsyas/Loughnashade)
8. Impact body lock (Twilight Cloak)
9. Phalanx auto-swap RDM
10. Auto-Marcato (BRD configurable)
11. Storm + Klimaform séquence auto (BLM)
12. Roll tracker avancé (packet parsing, bonus gear, Natural 11, Crooked Cards, bust rate)
13. Party job detection (COR packets)
14. BST ecosystem cycling (7 ecosystems, dynamic state)
15. BST ready move categorization (90+ moves, 4 catégories)
16. DNC Climactic auto-trigger (multi-condition)
17. DRK buff anticipation (pending flags)
18. Warp system complet (81 sources, 6 DBs, IPC)
19. Dualbox manager IPC
20. Spell/JA/WS databases (31,300 lignes data pure)
21. Pending flag detection pattern (0.1-0.3s avant buffactive)

### Features que Tetsouo n'a PAS (et que d'autres ont) :
1. Haste/DW tier detection (Selindrile + SilverLibs + Arislan)
2. Ammo management (Selindrile + SilverLibs + Arislan)
3. No-swap gear protection (SilverLibs: 80+ items)
4. Weapon rearm auto (SilverLibs)
5. Auto-Reraise HP threshold (SilverLibs)
6. Auto-WS at TP threshold (Selindrile)
7. Auto-nuke elemental cycling (Selindrile)
8. Auto-Trust summon (Selindrile)
9. Auto-Food (Selindrile)
10. Crafting mode (Selindrile)
11. Zone-specific gear (Selindrile)
12. Time-based gear day/night (Selindrile)
13. Death Mode BLM pipeline (Arislan)
14. Sleep timer display (Arislan)
15. Buff conflict auto-cancel (Selindrile + SilverLibs)
16. Monster abilities DB (Selindrile)
17. Flurry packet reading (SilverLibs + Arislan)

---

## 5. INNOVATION & SOPHISTICATION TECHNIQUE

### Niveaux de sophistication par framework

| Niveau | Description | Tetsouo | Selindrile | SilverLibs | Arislan |
|--------|------------|---------|------------|------------|---------|
| L1 | Simple toggle/switch | OUI | OUI | OUI | OUI |
| L2 | Single condition → action | OUI | OUI | OUI | OUI |
| L3 | Multi-condition + fallback | OUI | OUI | OUI | OUI |
| L4 | State machine + pending detection | OUI | NON | NON | NON |
| L5 | Mathematical modeling (probabilités) | OUI (bust rate) | NON | OUI (waltz potency) | OUI (sleep timer) |
| L6 | Packet parsing low-level | OUI (COR party+rolls) | NON | OUI (Flurry) | OUI (Flurry) |
| L7 | Dynamic runtime state generation | OUI (BST ecosystem) | NON | NON | NON |

### Innovations uniques

**Tetsouo**: Pending flag pattern, 7-level midcast fallback, packet-driven party intelligence, dynamic M{} state generation, midcast watchdog timeout adaptatif

**Selindrile**: Delayed action queue avec latency compensation, 50+ override hooks cascade, crafting mode system

**SilverLibs**: Multi-layer gear slot locking, monkey-patching de Mote-Include, waltz potency CHR/VIT formulas, 500+ pet exclusion list pour Luopan

**Arislan**: Sleep timer calculator avec merits/JP/relic/augments, Death Mode pipeline complet

---

## 6. VERDICT FINAL

### Par domaine

| Domaine | #1 | #2 | #3 |
|---------|-----|-----|-----|
| **Architecture** | Tetsouo | SilverLibs | Selindrile |
| **Intelligence spell/magie** | Tetsouo | Selindrile | Arislan |
| **Intelligence combat/WS** | Tetsouo | Selindrile | SilverLibs |
| **Intelligence COR rolls** | Tetsouo (très loin devant) | Arislan | SilverLibs |
| **Intelligence BRD songs** | Tetsouo | Mote (original) | Arislan |
| **Intelligence BST pets** | Tetsouo (seul à ce niveau) | Mote (basique) | - |
| **Intelligence DNC** | Tetsouo (seul à ce niveau) | SilverLibs | - |
| **Systèmes défensifs** | Tetsouo | Selindrile | SilverLibs |
| **Messages/UI** | Tetsouo (très loin devant) | Selindrile | SilverLibs |
| **Databases** | Tetsouo (31,300 lignes, seul) | - | - |
| **Warp/Navigation** | Tetsouo (seul) | - | - |
| **Dualbox** | Tetsouo (seul) | - | - |
| **QoL automation** | Selindrile | SilverLibs | Tetsouo |
| **Treasure Hunter** | Tetsouo (3 modes + SA/TA combos) | SilverLibs | Selindrile |
| **Haste/DW** | SilverLibs | Selindrile | Arislan |
| **Couverture jobs** | Selindrile (22) | Mote (19) | SilverLibs (16) |
| **Facilité d'adoption** | Mote | Arislan | Selindrile |

### Score global

| Framework | Architecture | Gameplay Intel | Features QoL | Data/DB | Messages/UI | TOTAL |
|-----------|-------------|---------------|-------------|---------|------------|-------|
| **Tetsouo** | 10/10 | 9/10 | 6/10 | 10/10 | 10/10 | **9.0/10** |
| **Selindrile** | 4/10 | 6/10 | 9/10 | 1/10 | 3/10 | **4.6/10** |
| **SilverLibs** | 3/10 | 5/10 | 8/10 | 1/10 | 2/10 | **3.8/10** |
| **Arislan** | 2/10 | 5/10 | 5/10 | 0/10 | 1/10 | **2.6/10** |
| **Mote** | 3/10 | 2/10 | 2/10 | 0/10 | 1/10 | **1.6/10** |

### Conclusion

Tetsouo domine dans : architecture, intelligence par job, databases, messages/UI, systèmes défensifs, warp, dualbox.

Selindrile domine dans : QoL automation (auto-food, auto-trust, auto-nuke, auto-WS, crafting, zones), couverture jobs, et features "convenience".

Les features manquantes de Tetsouo (haste tracking, ammo, auto-food, crafting, etc.) sont des features QoL/"convenience" - utiles mais pas du gameplay intelligence. Les features uniques de Tetsouo (roll tracker, song rotation, spell refinement, ecosystem cycling, pending flags, packet parsing) sont de la vraie intelligence de gameplay qui nécessite une compréhension profonde des mécaniques du jeu.

**En résumé** : Selindrile fait beaucoup de choses correctement pour beaucoup de joueurs. Tetsouo fait moins de choses mais les fait à un niveau de sophistication incomparable.
