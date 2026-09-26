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
  `0_AugGear_*`, UI_CONFIG, COMMON_KEYBINDS). En cours (2026-09-26) : Gab RDM ;
  Blody BRD, COR. Restent Gab BRD COR GEO SAM THF, Blody BLM GEO THF WHM ;
  UI_CONFIG et COMMON_KEYBINDS pas faits.
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
- [x] BRD (2026-09-25, testé en jeu sur Tetsouo avec l'overlay de Blody) : `buffs` remplacé par
  `//gs c songs` + pack `Gab` ; rotation en file d'attente (fin de cast réelle + 3 s,
  relances), places calculées depuis les instruments possédés et Clarion Call, chants
  bidons seulement si nécessaires. Overlay `_master/Blodykiller/` BRD : sets, états, pack,
  touches BindManager, macrobook 1/1, lockstyle 1.
- [ ] BRD (reste) : Ballad III sous Pianissimo en /WHM dans la rotation ; annonce du recast NT
  en /p ; Loughnashade au sommeil ; instrument propre à un chant par personnage (Blurred
  Harp +1 pour la Ballad, Miracle Cheer pour l'Hymnus) ; contradictions de ses fichiers à
  vérifier avec Gab (EMPY tête/pieds, capes, Brioso +3 vs AF +4, noms d'objets).
- [x] COR : roll actif relancé = Double-Up (2026-09-25, pour tout le monde, décidé avec
  Tetsouo ; `logic/double_up.lua`).
- [x] COR (2026-09-26, testé en jeu sur Kaories) : Flurry I/II (`flurry_tracker.lua`) ;
  RangedMode ; Triple Shot ; Fold seulement avec deux Bust (tout le monde) ;
  Compensator hors combat (Blody, condition `engaged = false`) ; QDMode STP/Enhance
  (Blody ; Potency et TH posaient les mêmes pièces). Pas repris : AM3 / Triple Shot
  Critical (jamais déclenché chez Blody, `player.equipment.ranged`).
- [ ] COR : garde munitions spéciales.
- [x] GEO : Entrust auto sur Indi allié, Full Circle auto avant Geo- (2026-09-25, options
  `geo_entrust`, `geo_full_circle` de `config/AUTO_ABILITIES.lua`, off par défaut).
- [ ] GEO :
  MagicBurst ; repli de tier Cure/Aspir/Sleep.
- [x] SAM : Hasso auto à l'engage (2026-09-25, option `sam_hasso`).
- [ ] SAM : SubSet (grip) / RangedSet.
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
- [x] Binds BindManager (2026-09-26, `90a36fd`) : tout ce qui ne dépend pas d'un job -> `COMMON_KEYBINDS`
  de Gab et Blody (startup, login.all, login.characters, sub_jobs, alt-binds) ; job par job ->
  `<JOB>_KEYBINDS` au fil des conversions (faits : Gab RDM, Blody BRD COR). Pas testé en jeu.
  (`alt-binds.lua` : groupes `all`, par job d'alt, par sous-job, par arme).
- [ ] Macrobooks et lockstyles (tables de BindManager).
- [ ] Sets : conversion job par job avec les tables AF/RELIC/EMPY.
- [x] `combat_mode.lua` de Gab et Blody : `shown = {all = true}, keys = {all = '~f9'}` (son WeaponLock
  sur Shift+F9, BindManager `login.all`) — dans leurs `config_global/`.
- [x] `AUTO_ABILITIES.lua` de Gab : `sam_hasso`, `geo_entrust`, `geo_full_circle` à true (Blody : fichier présent dans son `config_global/`).
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

## 5. Réponses de Gab (2026-09-25, `data/Gab_reponse.txt`)

1. Raccourcis de sorts : addon Shortcuts, son `aliases.xml` reçu (`F:\Telechargement Diversliases.xml`).
   `march3` Honor March, `minuet3/4/5` Valor Minuet III/IV/V, `str2` Herculean Etude,
   `ballad3` Mage's Ballad III, `paeon` Army's Paeon, `minne` Knight's Minne. Ses binds
   gardent ces raccourcis (Shortcuts reste installé chez lui) ; notre code écrit les vrais noms.
2. Scripts BRD (`odybuffs`, `odybuffs2`, `fakes`) : abandonnés, il utilisera nos packs de chants.
3. `PUP_Lib.lua` reçu (`F:\Telechargement Divers\PUP_Lib.lua`, 1320 lignes).
4. Sets de Blody BLM/GEO/PUP/WHM : à jour.
5. Priorités : Blody BRD, COR, THF. Gab, nouveaux jobs : BLU et PUP.
6. Thyrsa / Sephiroph : pas maintenant.
7. AutoCP : rarement, on ne le fait pas (le mode CP à touche suffit).
8. `buffs2` : abandonné.

## 6. Journal

| Date | Étape | Commit | Testé en jeu |
|---|---|---|---|
| 2026-09-25 | A : armes sans set | feat(equipment): weapon states resolved in one place | oui (Tetsouo, BLM inchangé) |
| 2026-09-25 | B : clone + character_db | 34481ae | hors jeu (comparaison de clones) |
| 2026-09-25 | B : dual-box arme + multi-alts, touches `alt` | feat(dualbox) | oui (Tetsouo + Kaories) |
| 2026-09-25 | C : Combat Mode commun, lock CP, Obi/Orpheus, Utsusemi | feat(common) | oui (Tetsouo) |
| 2026-09-25 | C : 4 verrous Combat Mode en double retirés | refactor(combatmode) | oui (Tetsouo BLM, Kaories RDM/GEO) |
| 2026-09-25 | D : COR Double-Up, options Hasso / Entrust / Full Circle | feat(cor,geo,sam) | Double-Up oui ; options hors jeu |
| 2026-09-25 | Temps de cast depuis le stuff, file de chants, overlay BRD Blody | feat(cast), feat(brd), feat(blody) | oui (Tetsouo, sets Blody) |
| 2026-09-25 | Overlay COR Blody, Luzaf par perso | fix(cor), feat(blody) | en cours sur Kaories |
