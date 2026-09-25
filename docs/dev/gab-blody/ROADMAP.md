# Feuille de route : Gabvanstronger (main) + Blodykiller (alt)

Créée le 2026-09-25. Mise à jour à chaque étape terminée (cocher, dater, noter le commit).

## 0. Règles non négociables

1. **Rien ne casse notre système.** Tout ajout au code partagé (`shared/`) est soit
   une option désactivée par défaut, soit un repli qui ne s'active que là où rien
   n'existait avant. Avant chaque commit : sortie de Tetsouo et Kaories **identique**
   (tests différentiels hors jeu, comme pour le HUD et les messages).
2. **Factory > duplication.** Une fonction manquante pour Gab/Blody va dans le
   système commun, jamais copiée dans un job.
3. **Conventions de Gab conservées** : tables `AF` / `RELIC` / `EMPY` (`.Set`,
   `.Head` ... `.Feet`, `EMPY.Ear`), capes `<JOB>Cape.X`, tables d'augments
   (`HERC`, `MERL`, `CHIR`...), fichiers `0_AugGear_<Perso>.lua` inclus depuis les sets.
4. **Jamais le mot "Silmaril"** dans un message ; messages au format HelpScreen /
   InfoBlock.
5. **Tests** : syntaxe (`lua5.1 loadfile`) + rendu hors jeu à chaque fichier ;
   liste de tests en jeu à la fin de chaque étape ; commit seulement après validation.
6. **Budget** : lire un fichier source seulement quand on convertit ce job-là.

## 1. Sources (lues)

| Source | Emplacement | Lu |
|---|---|---|
| Demande 1 (touches selon le job de Blody) | `data/gab_demande.txt` | oui |
| Demande 2 (armes sans set) | `data/gab_demande_2.txt` | oui |
| Modifs perso de Gab | `F:\...\data\00_GAB_MODIF.md` | oui (5 entrées) |
| BindManager (binds, alt-binds, macrobooks, lockstyles, settings) | `F:\Telechargement Divers\BindManager\BindManager\data\` | oui, en entier |
| GearSwap de Gab | `F:\Telechargement Divers\GearSwap - Copie pour Tetsouo\GearSwap - Copie pour Tetsouo\data\` | inventaire par job (voir §4) ; le détail des sets sera lu job par job |

Absents de la copie (à demander) : `PUP_Lib.lua`, scripts Windower
(`BRD_dummy_CC`, `BRD_Buffs_Odyssey[2]`), alias Windower (`curaga3`, `march3`,
`str2`, `madri2`...).

## 2. Périmètre

| Perso | Jobs | Déjà sur notre système |
|---|---|---|
| Gabvanstronger (main) | RDM, BLU, BRD, COR, GEO, MNK, NIN, PUP, RNG, SAM, SCH, THF | RDM |
| Blodykiller (alt) | BLM, BRD, COR, GEO, PUP, THF, WHM, MNK | aucun |

Hors GearSwap, restent dans un mini-addon ou `scripts/init.txt` : binds de l'écran
titre (`startup` de BindManager) et binds des mules (Gabvansmaller/boulette/tooweak).

## 3. Étapes

### Étape A : armes sans set (demande 2) — partagé, prioritaire — FAIT (2026-09-25)
Écart avec le plan : l'option est **par personnage, off par défaut**
(`config/WEAPON_CONFIG.lua`, `equip_without_set`), car le BLM de Tetsouo compte sur
Hvergelmir sans set (ses sets idle/engaged gardent d'autres bâtons). Off = ancien
comportement à l'identique (audit : 38 valeurs d'armes Tetsouo + Kaories).
- Nouveau `shared/utils/equipment/weapon_resolver.lua` : `set_for('main'|'sub', value)`
  1. `sets[value]` existe **et** contient le slot demandé : le rendre (comportement actuel) ;
  2. sinon, si `value` est un nom d'arme de `res.items` : `{main=value}` / `{sub=value}` ;
  3. sinon `nil` (rien, comme aujourd'hui).
- Remplacer les ~20 `sets[state.MainWeapon.current]` / `SubWeapon` des `set_builder`
  (BLM BRD COR DNC GEO RDM RUN SAM THF WAR + DRK PLD à vérifier).
- **Contrôle** : pour Tetsouo et Kaories, chaque valeur de chaque état d'arme donne
  le même set avant/après, là où un set existe.
- [x] fait, testé en jeu (Tetsouo) — commit : voir journal

### Étape B : fondations
- [x] `clone_character.py` (2026-09-25) : `Tetsouo` remplacé aussi dans les fichiers
  venant du `_master/` générique (hors lignes `@author`) ; l'overlay du perso cible
  `_master/<Nom>/` est pris même sans `--source`, et ses fichiers ne sont pas renommés.
  Vérifié contre l'ancien script : Tetsouo et un nouveau perso identiques, Kaories
  2 commentaires. BLU MNK NIN RNG SCH (+ PUP) iront dans `ALL_VALID_JOBS` quand ils
  existeront (étapes E/F), sinon le clone n'aurait rien à copier.
- [x] `character_db.lua` (2026-09-25) : Gabvanstronger (main : RDM BRD COR GEO SAM THF),
  Blodykiller (alt : BLM BRD COR GEO THF WHM) ; le reste s'ajoute job par job.
- [x] `.gitignore` (local, il s'ignore lui-même ; fait 2026-09-25) : ajouter `!_master/Gabvanstronger/`,
  `!_master/Gabvanstronger/**` (le motif `Gabvanstronger/` masquerait l'overlay) et
  `Blodykiller/` + ses négations, avant de créer les overlays.
- [ ] Overlays `_master/Gabvanstronger/`, `_master/Blodykiller/` (sets, configs,
  `0_AugGear_*`, UI_CONFIG, COMMON_KEYBINDS).
- [x] Dual-box (2026-09-25, code + test hors jeu) : `altjobupdate` porte le type d'arme
  (7e argument, renvoyé quand la main change de type d'arme, paquet 0x050) ;
  `shared/utils/dualbox/alt_states.lua` garde chaque boîte par nom ; `requestjob` part
  vers toute la boîte du groupe ; `_G.AltJobState` inchangé pour COR/macrobook.
- [x] KeybindManager (2026-09-25) : champ `alt = {name, job, subjob, weapon}` ;
  `refresh_active()` à chaque changement d'une boîte ; `refresh()` ne retire plus une
  touche qu'il repose. Sans `alt` = comportement actuel.
- [x] Testé en jeu Tetsouo + Kaories (2026-09-25) : rien n'a changé pour eux.

### Étape C : fonctions communes manquantes (options, off par défaut)
- [x] WeaponLock = Combat Mode commun à tous les jobs (2026-09-25, testé en jeu, décidé
  avec Tetsouo) : `shared/utils/core/combat_mode.lua` + `//gs c combatmode show|hide|key`.
  Les 4 verrous codés à la main (BLM, WHM, RDM, GEO) retirés le 2026-09-25 (modèles,
  overlays, live Tetsouo BLM et Kaories RDM/GEO ; Hysoka et Gab figés, non touchés).
- [x] Mode CP : champ `lock` des états perso (`shared/utils/custom/custom_locks.lua`),
  exemple dans `docs/user/guides/keybinds.md`. AutoCP (Apex/Nostos/Locus < 50 %) non
  repris : demander à Gab s'il y tient (il faudrait des conditions sur la cible).
- [x] Obi / Orpheus (2026-09-25, test hors jeu) : conditions `obi_better`, `orpheus_better`,
  `obi_bonus_above` des règles perso (`shared/utils/equipment/elemental_bonus.lua`).
  Le BLM garde son `elemental_matcher` (non touché).
- [x] Utsusemi (2026-09-25) : annulation des ombres avant Ichi pour tous les jobs
  (`shared/utils/midcast/utsusemi_shadows.lua`, appelée par le hook universel des sorts ;
  retirée de DNC_MIDCAST). Changement de comportement pour les jobs non-DNC sous /NIN.
- [x] Refresh latent : déjà possible, règle perso `mp_below = 51` (exemple dans le guide).
- [ ] Timers (chants, Indi) : déplacé à l'étape D (BRD, GEO).
- [x] AutoMove, corps Adoulin : règle perso `moving` + `zone`. Pas de gear de vitesse
  en combat (décidé 2026-09-25) : l'EngagedMoving de Gab n'est pas repris.
- [ ] Base de WS Marksmanship : déplacée à l'étape F (RNG), données à vérifier sur BG-Wiki.

### Étape D : jobs existants complétés
- [ ] BRD : commande `buffs` (NT + Troubadour + Marcato + rotation selon le nombre
  de chants, repli /WHM Pianissimo + Ballad III, report recast NT en /p) ;
  Loughnashade au sommeil ; mode Daurdabla ; CastingMode Resistant ; Miracle Cheer.
- [ ] COR : roll actif relancé = Double-Up ; Flurry I/II (détection paquet) ;
  QDMode STP/Enhance/Potency/TH ; Fold double bust ; Triple Shot / AM3 ;
  RangedMode ; garde munitions spéciales ; Compensator seulement hors combat (option).
- [ ] GEO : Entrust auto sur Indi allié (option) ; Full Circle auto avant Geo- (option) ;
  MagicBurst ; repli de tier Cure/Aspir/Sleep.
- [ ] SAM : Hasso auto à l'engage ; SubSet (grip) / RangedSet.
- [ ] THF : TreasureMode None/Fulltime ; TH sur Aeolian et au tir ; set Feint.
- [ ] WHM : Cure sous Aurorastorm ; bottes Sandstorm ; Afflatus auto (option).
- [ ] BLM : CastingMode Proc.

### Étape E : PUP réécrit (automate)
- [ ] Configs `_master/config/pup/` (STATES, KEYBINDS, LOCKSTYLE, MACROBOOK, TP_CONFIG,
  CUSTOM) ; retirer la dépendance BST (PET_DATA, écosystème, Ready moves).
- [ ] Modes/styles de pet (TANK/DD/MAGE), manœuvres, déploiement auto, LockPetDT,
  WS du pet (STR/VIT/MND/DEX, FTP), idle.Pet.Engaged.
- Attendre `PUP_Lib.lua` si Gab l'a.

### Étape F : nouveaux jobs (skill `/new-job`, 12 modules chacun)
- [ ] BLU : catégories de sorts (17 maps), Unbridled Learning auto, Chain/Burst
  Affinity, garde Expiacion (option).
- [ ] NIN : Migawari/Doom, Utsusemi, ninjutsu élémentaire, outils.
- [ ] RNG : Flurry, Barrage, Double Shot, munitions (`quiver_manager`), garde AM.
- [ ] SCH : Arts/Addendum, stratagèmes (`utils/scholar/`), Helix, Sublimation, Obi.
- [ ] MNK : Impetus (compteur), Footwork, Counter.
Données déjà présentes : JA, BLU spells, ninjutsu, SCH spells, alt commands.

### Étape G : réglages de Gab et Blody
- [ ] Binds BindManager -> `<JOB>_KEYBINDS` / `COMMON_KEYBINDS` / binds d'alt
  (`alt-binds.lua` : groupes `all`, par job d'alt, par sous-job, par arme).
- [ ] Macrobooks et lockstyles (tables de BindManager).
- [ ] Sets : conversion job par job avec les tables AF/RELIC/EMPY.
- [ ] `combat_mode.lua` de Gab : `shown = {all = true}, keys = {all = '~f9'}` (son WeaponLock
  sur Shift+F9, BindManager `login.all`).
- [ ] UI_CONFIG de Gab : Weapons + Modes en premier, compact, CombatMode dans Weapons,
  touches en gris 125, pas de séparateurs chat.

## 4. Inventaire des fonctions (résumé des rapports du 2026-09-25)

Gab : BLU (maps, UL, Expiacion), BRD (Pianissimo, dummy, FullLength, timers),
COR (QD main/alt, QDMode, Flurry, Obi, Triple Shot, TH), GEO (Entrust/Full Circle
auto, refine tiers, timers), MNK (Impetus, Footwork), NIN (Migawari, outils),
PUP (tout dans PUP_Lib absent), RNG (Flurry, Barrage, DS, ammo), SAM (Hasso auto,
Reraise, 450/480), SCH (stratagèmes, Helix, Obi, Sublimation), THF (TH Fulltime,
Aeolian/ranged TH, Feint).
Blody : BRD `buffs` (seule commande que Gab lui envoie), COR (Double-Up auto),
GEO (Entrust auto), WHM (Aurorastorm), BLM (Proc), PUP (template Faloun), MNK.
Bugs existants chez eux (ne pas reproduire) : AugGear d'un autre perso effacé par
`0_AugGear_shared_dats`, THF de Blody qui ne charge pas, `sub_cheatsheet` /
`unbind_mainjob` / `handle_nuking` inexistants, `check_cpmode` cassé.

## 5. Questions ouvertes (à Gab)

1. Jobs prioritaires.
2. Que doit faire `blody gs c buffs2` (inexistant chez Blody) ?
3. Scripts/alias Windower manquants, ou remplacement par nos commandes d'alt ?
4. `PUP_Lib.lua`.
5. Équipement réel de Blody en BLM, GEO, PUP, WHM.
6. Automatique ou sur commande (Entrust, Full Circle, Afflatus, Double-Up) ?
7. Binds pour Thyrsa et Sephiroph aussi ?
8. AutoCP (cape CP auto sur Apex/Nostos/Locus < 50 %) : il y tient ?

## 6. Journal

| Date | Étape | Commit | Testé en jeu |
|---|---|---|---|
| 2026-09-25 | A : armes sans set | feat(equipment): weapon states resolved in one place | oui (Tetsouo, BLM inchangé) |
| 2026-09-25 | B : clone + character_db | 34481ae | hors jeu (comparaison de clones) |
| 2026-09-25 | B : dual-box arme + multi-alts, touches `alt` | feat(dualbox) | oui (Tetsouo + Kaories) |
| 2026-09-25 | C : Combat Mode commun, lock CP, Obi/Orpheus, Utsusemi | feat(common) | oui (Tetsouo) |
| 2026-09-25 | C : 4 verrous Combat Mode en double retirés | refactor(combatmode) | oui (Tetsouo BLM, Kaories RDM/GEO) |
