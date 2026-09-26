# Corrections faites dans tes sets (Gab et Blody)

En convertissant vos jobs, on a trouvé des endroits où **tes fichiers ne faisaient pas ce que
tu avais écrit**. Voici chaque cas, avec **le fichier et la ligne** de ta copie, pour que tu
puisses vérifier toi-même. Les chemins sont relatifs au dossier `data` de la copie que tu nous as
envoyée (`GearSwap - Copie pour Tetsouo\...\data\`).

Vérification faite par nous : aucune pièce ni aucun augment n'a été inventé (tout vient de tes
fichiers), et chaque set a été comparé slot par slot avec l'original. La comparaison reproduit le
vrai `set_combine` de GearSwap (`helper_functions.lua`, `set_merge` et `unify_slots`) : un set
absent passé en argument est **sauté**, les noms de slot **ignorent la casse** (`Feet` = `feet`),
et `ring1` / `ring2` / `ear1` / `ear2` deviennent `left_ring` / `right_ring` / `left_ear` /
`right_ear`. Sur ton RDM, 125 sets : 83 identiques, 8 différents (points 1 et 2), 34 retirés ou
renommés (points 3 et 4, et « Retiré »).

Légende : **Avant** = ce que le jeu équipait vraiment avec ton fichier. **Maintenant** = ce que
notre version équipe.

---

## Gabvanstronger – RDM

### 1. Tête de tes Cures : Vanya Hood jamais équipée

- `Gabvanstronger/sets/rdm_sets.lua`, ligne 492 : `head = VANY.Head.A` (set Healing Magic, dont
  héritent Cure et Curaga).
- `0_AugGear_shared.lua`, ligne 133 : `VANY.Head.A` est **commenté** ; ligne 134, la même Vanya Hood
  s'appelle maintenant `VANY.Cure`.
- `0_AugGear.lua` ligne 293 définit encore `VANY.Head.A`, mais **aucun fichier n'inclut
  `0_AugGear.lua`** (ton RDM charge `0_AugGear_Gabvanstronger.lua` → `0_AugGear_shared.lua` →
  `0_AugGear_shared_dats.lua`).
- **Avant** : la tête du set était vide, donc c'est celle du set de base (`midcast.casting`,
  ligne 421) qui restait : **Leth. Chappel +3**.
- **Maintenant** : **Vanya Hood** (`VANY.Cure`, Cure potency +7 %), ce que tu avais écrit.

### 2. Cape de tes sets Fast Cast : jamais équipée

- `Gabvanstronger/sets/rdm_sets.lua`, ligne 360 : `back = RDMCape.idle` (minuscule).
- `0_AugGear_Gabvanstronger.lua`, ligne 168 : la cape s'appelle `RDMCape.Idle` (majuscule).
- En Lua, `idle` et `Idle` sont deux noms différents (`RDMCape = {}` est une table ordinaire,
  `0_AugGear_shared_dats.lua` ligne 43) : `RDMCape.idle` vaut `nil`, le set Fast Cast n'a pas de
  cape. (Ce n'est pas comme un nom de slot, que GearSwap lit sans tenir compte de la casse.)
- **Avant** : le Fast Cast ne touchait pas à la cape, tu gardais celle que tu portais. Depuis
  l'idle, c'était déjà ta Sucellos (`RDMCape.Idle`, lignes 108 et 125) : aucune différence. En
  combat, tu gardais ta cape de TP pendant le Fast Cast.
- **Maintenant** : **Sucellos's Cape** (`RDMCape.Idle`) sur le Fast Cast, aussi en combat.

### 3. Fast Cast de Stoneskin : jamais utilisé (faute de frappe)

- `Gabvanstronger/sets/rdm_sets.lua`, ligne 366 : `sets.precast.FC['Stonekin']` (il manque le « s »).
- **Avant** : Stoneskin prenait ton Fast Cast Enhancing, jamais ce set.
- **Maintenant** : `sets.precast.FC['Stoneskin']`, utilisé pour Stoneskin.

### 4. Precast des Cures : jamais utilisé

- `Gabvanstronger/sets/rdm_sets.lua`, ligne 375 :
  `sets.precast.cure = set_combine(sets.precast.casting, { back = "Disperser's Cape" })`.
- Mote ne cherche jamais `precast.cure` (il cherche `precast.FC.Cure`, puis `precast.FC`). Ce
  set n'était donc lu par rien. (`sets.precast.casting` n'existe pas non plus, mais ça ne changeait
  rien : `set_combine` saute un set absent, le set contenait juste la cape.)
- **Avant** : tes Cures partaient avec ton Fast Cast général.
- **Maintenant** : `sets.precast.FC.Cure` et `FC.Curaga` = ton Fast Cast + **Disperser's Cape**.

### 5. CureSelf : jamais lu

- `Gabvanstronger/sets/rdm_sets.lua`, ligne 515 : `sets.midcast.CureSelf`.
- **Avant** : aucun code ne lisait ce set.
- **Maintenant** : notre RDM le met par-dessus le set Cure quand tu te soignes toi-même (pas sur
  les Curaga). Il est vide pour l'instant (identique à ton set Healing) : à remplir si tu veux du
  gear défensif sur toi.

### 6. Boucliers : Sacro Bulwark manquant

- `Gabvanstronger/sets/rdm_sets.lua`, lignes 74 à 80 : `sets.shields` liste Ammurapi, Genmei,
  Forfend +1 et Archduke's, pas **Sacro Bulwark**, alors que c'est un de tes choix de sub
  (ligne 58).
- **Avant** : avec Sacro Bulwark en sub, les sets DW (double arme) étaient choisis.
- **Maintenant** : Sacro Bulwark est dans la liste des boucliers.

### Écrit autrement, sans aucun effet en jeu

Ces lignes avaient l'air fausses, mais GearSwap les lisait correctement : **ce n'étaient pas des
bugs**. On les a juste réécrites plus proprement, les pièces portées sont les mêmes.

| Ton fichier | Pourquoi ça marchait quand même |
|---|---|
| Ligne 704, `Regen.Composure = set_combine(sets.midcast['Enhancing Magic'].others, sets.midcast.Regen)` : `.others` n'existe pas | `set_combine` saute un set absent : c'était ton set Regen, il fonctionnait |
| Ligne 187, `engaged['Store TP']` construit sur `engaged.DT`, défini seulement ligne 204 | `engaged.DT` était sauté, mais ton set Store TP remplit tous les slots : même résultat. Construit maintenant sur `sets.engaged`, comme tu l'as demandé |
| Lignes 243 et 244, `body` écrit deux fois dans Subtle Blow | Lua garde la dernière (Volte Harness), c'est celle qu'on a gardée |

### Gardé sous ton nom (ta réponse)

`sets.midcast['Enhancing Magic'].Potency` (ligne 595) : on l'avait renommé en variable locale,
sans rien casser (Gain, Temper, Enspell, BarSpell, BarAilment, Protect, Shell et Aquaveil en
héritaient avec les mêmes pièces). Il a retrouvé son nom pour que tu puisses le modifier comme
avant ; la comparaison le donne identique à ton fichier.

### Retiré (ne servait déjà pas chez toi)

| Set de ton fichier | Pourquoi |
|---|---|
| `engaged.Acc` et `engaged.Acc.DW` | « Acc » n'est pas dans ta liste de modes engagés |
| `idle.Vagary` | « Vagary » n'est pas un de tes modes idle |
| `midcast['Enfeebling Magic'].Mixed` | « Mixed » n'est pas une valeur de ton EnfeebleMode |
| `precast['Ranged']` (ligne 380) | ce nom n'est lu par rien |
| `midcast.casting` | aucun code ne le cherchait ; gardé comme base des sets qui en héritent, sous un nom local |
| Tes 15 sets d'arme simples (Naegling, Excalibur…) | remplacés par « armes sans set », ta demande |
| `sets.Usable` et les alias `warp`, `dem`, `holla`… (`0_AugGear.lua` ligne 185) | remplacés par `//gs c warp`, `//gs c dem`, `//gs c holla`… |

### Touches : un conflit à trancher

`Alt+Z` et `Alt+X` étaient à la fois tes objets (Silent Oil, Prism Powder : BindManager
`login.characters.Gabvanstronger`) et tes sorts RDM (Sneak, Invisible : BindManager
`jobs.main_jobs.RDM`). En RDM, on a gardé **les sorts**. Dis-nous si tu préfères l'inverse.

---

## Gabvanstronger – THF

Converti depuis `Gabvanstronger/THF.lua` (celui que ton GearSwap charge ; `sets/thf_sets.lua` est un
reste de l'ancien clone avec les pièces de Tetsouo, ignoré). Comparaison slot par slot : **tous tes
sets sont identiques** (engaged Normal/DT/Acc/Crit/Evasion/DT TH, idle Normal/Refresh/Regain/Town/Weak,
WS et leurs variantes SA/TA, TH, SA/TA, JA, FC, tir, et tes paires d'armes Abyssea), sauf le point 1.

### Bugs dans tes fichiers

1. **`THF.lua` ligne 375** (idle Regain) : `hands = "Gleti's Gloves"` n'existe pas (le vrai nom est
   Gleti's Gauntlets, comme dans ton `BLU.lua` lignes 675 et 752) : ces gants n'étaient jamais
   équipés. **Maintenant** : Gleti's Gauntlets.
2. **`THF.lua` ligne 598** : `job_state_change` appelle `job_handle_equipping_gear` sans `eventArgs` ;
   avec Sneak ou Trick Attack actif, changer un mode faisait une erreur Lua et le gear ne suivait pas.
   Chez nous : pas ce code.
3. **`THF.lua` lignes 524-525** : `return` puis `send_command(...)` à la ligne se lit
   `return send_command(...)` en Lua : sous silence, sommeil, stun, charme, pétrification ou terreur,
   il lançait une Remedy sans annuler le sort. Chez nous : le sort est bloqué (PrecastGuard), Remedy
   seulement si AutoMedicine est actif.
4. **`THF.lua` lignes 606-613** : SA + TA donnait le mode WS `SATA`, set qui n'existe pas : tu avais
   le set de base, sans la Yetshila +1 prévue (ligne 235). Chez nous : repli sur `.SA`, Yetshila mise.
5. **`0_Shared.lua` ligne 1674** : `equip({range = 'Ammo'})` n'équipe rien (`Ammo` n'est pas une pièce).
   Sans effet réel : tes sets portent déjà la munition.
6. **`0_AutoMove.lua` ligne 22** : `sets.Adoulin` est construit avant `sets.MoveSpeed`, donc sans tes
   Skadi's Jambeaux.
7. **`0_AugGear_shared.lua` ligne 37** : `(player.main_job or player.sub_job) == 'NIN'` ne teste que le
   job principal : en THF/NIN, tes paires Katana d'Abyssea n'existaient pas.

### Tes modes chez nous

- F9 : engaged Normal / DT ; ^F12 : idle Normal / Refresh / Regain ; !F9 : tir Normal / Acc.
- Abyssea : plus dans F9, c'est la bascule `AbyProc` + `AbyWeapon` (tes paires d'armes) sur Ctrl+Numpad4/5.
  Tes alias `ws1` / `ws2` ne sont pas repris.
- Armes : tes WeaponSet / SubSet (Aeneas, Kartika, Tauret, Naegling, Norgish Dagger / Fusetto +2,
  Gleti's Knife, Tanmogayi +1, Ternion Dagger +1, Qutrub Knife, Free).
- RangedSet Ammo / Pull (Win+`) : mode perso, Pull = Antitail +1 avec range/ammo verrouillés.
- CP : mode perso (cape + dos verrouillé), comme ton RDM. Sur ton THF il ne faisait rien
  (`check_cpmode` jamais appelé).
- TH : None / Tag / SATA / Full (!`). Le TH sur Aeolian Edge, sur les WS et sur SA/TA en SATA/Full est
  repris par des règles dans `config/thf/THF_CUSTOM.lua`.
- Macrobook livre 6 (page 2 /DNC, 3 /WAR, 4 /NIN), lockstyle 7 : de ton BindManager.

### Pas encore repris (notre THF ne sait pas le faire)

- TH sur les attaques à distance ; marquage TH par le tir, Aeolian, Provoke, Steps, Flourishes (chez
  nous seule la mêlée marque) ; en Tag, TH gardé sur la première WS.
- Recouvrement SA/TA en idle (chez nous seulement en engaged).
- `sets.Adoulin` (chez nous il remplacerait tout l'idle à Adoulin).

### À vérifier par toi

- Moonshade : notre calcul de TP la met en oreille gauche ; sur Aeolian Edge ta Moonshade est à droite.
  À tester en jeu.

## Gabvanstronger – BLU

Nouveau job chez nous, construit sur ton `Gabvanstronger/BLU.lua`. Comparaison slot par slot : **71 sets
identiques**, sauf les corrections ci-dessous. Tes 18 touches BLU de BindManager sont identiques, et tes
WS du numpad suivent l'arme que tu tiens (épée : Requiescat, Expiacion, Chant du Cygne, Savage Blade ;
Club : True Strike, Black Halo, Judgment), comme BindManager.

### Bugs dans ton fichier

1. **Ligne 794** : Unbridled Learning automatique sur une cible autre que toi : tu envoyais
   `/ja "Pianissimo"` (JA de BRD) au lieu d'Unbridled Learning (la bonne ligne est commentée ligne 793).
   **Maintenant** : Unbridled Learning, puis le sort sur la même cible.
2. **Ligne 885** : `set_combine(idleSet, sets.latent_refresh)` sans garder le résultat : ta Fucho-no-Obi
   sous 51 % de MP n'a jamais été mise. Gardé tel quel (règle en commentaire dans `BLU_CUSTOM.lua`).
3. **Ligne 499** (set Enmity) : « Sapiens Orb » n'existe pas : **Sapience Orb** (comme tes sets Fast Cast).
4. **Ligne 389** : `sets.precast.WS.acc` en minuscule, jamais lu par le mode WS Acc : renommé `.Acc`.
5. **Lignes 212 et 229** : « Tail slap » (vrai nom Tail Slap) et « Winds of Promyvion » (vrai nom
   Winds of Promy.) ne tombaient jamais dans leur catégorie ; maintenant Stun et Buff.
   « Orcish Counterstance » (ligne 228) n'existe dans aucune ressource du jeu : retiré.
6. **Sorts dans deux catégories** (l'ordre de Lua décidait) : Mind Blast -> MagicalMnd,
   Sub-zero Smash -> PhysicalVit, Hecatomb Wave -> Breath, Exuviation -> Enmity.
7. **Ligne 285** : `sets.buff.Enchainment` : aucun buff ni JA de ce nom dans le jeu, ce set ne se pose jamais.
8. **Ligne 382** (Chant du Cygne) : `HERC.Feet.TA` n'est défini que dans `0_AugGear.lua`, qui n'est pas
   chargé : tes pieds étaient les Nyame Sollerets du set WS de base. Gardé ainsi.
9. **Lignes 782-784** : même bug que ton THF (Remedy lancée au lieu d'annuler le sort) ; chez nous le
   sort est bloqué.

### Tes fonctions chez nous

- Classement de tes sorts : `config/blu/BLU_SPELL_MAP.lua` (tes 24 catégories, noms corrigés).
- Sets de buff par-dessus les sorts bleus (Burst / Chain Affinity, Convergence, Diffusion, Efflux),
  `self_healing` sur toi, Magical Resistant (CastingMode).
- Unbridled Learning automatique : option `blu_unbridled` (active pour toi). Aussi pour **Cesspool** et
  **Tearing Gust** : comme tes 16 sorts, ils n'ont pas de points de sort (ressources du jeu) et ne se
  lancent que sous Unbridled Learning. UL en recast : le sort part tel quel (il échouait déjà chez toi).
- Fenêtre Expiacion (Tizona, sans Aftermath 3, sous 3000 TP : premier appui annulé, 3 s) : option
  `blu_expiacion_window` (active pour toi), messages comme les tiens.
- Une seule arme (Genbu's Shield ou rien en sub) : sets `.SW` ; tes modes, armes, Pull, CP ; AzureSets
  chargé en BLU.

### À tester par toi

Une catégorie de chaque (physique, magique en Resistant, Enmity) ; Chain Affinity puis un sort physique ;
un soin sur toi ; Bilgestorm sans UL (sur un mob, puis Harden Shell sur toi) ; Expiacion avec Tizona à
2000 TP ; passer de Tizona à Maxentius (le numpad change) ; Genbu's Shield (sets SW) ; Pull ;
`//gs c trace on` écrit tout dans `Gabvanstronger/trace.log`.

## Blodykiller – BRD

Comparaison slot par slot faite en chargeant ton fichier comme Mote (`job_setup`, `user_setup`,
`init_gear_sets`). Tes chansons ont été comparées telles que ton `job_midcast` les portait :
`SongEffect` ou `SongDebuff`, puis le set de la chanson par-dessus. Toutes (Ballad, March, Honor
March, Minuet, Madrigal, Minne, Paeon, Mambo, Scherzo, Hymnus, Lullaby, Horde Lullaby I et II,
Finale, Threnody, Elegy, Requiem, fausses chansons, Miracle Cheer) donnent **exactement tes pièces**.
Idle : Terpander au slot range, comme ton `check_rangedset` le posait.

| # | Fichier, ligne | Avant | Maintenant |
|---|---|---|---|
| 1 | `Blodykiller/Blodykiller_BRD.lua` 385 | `ammo = LINOS.WS` : un Linos est un instrument (slot range), pas une munition | `range = LINOS.WS` |
| 2 | `Blodykiller/Blodykiller_BRD.lua` 406 | Aeolian Edge : `body = RELIC.Head` (une tête dans le slot du corps) | ligne retirée, le corps reste celui du set de WS |
| 3 | `Blodykiller/Blodykiller_BRD.lua` 476 | `back = BRDCape.Mid` : cette cape n'est définie nulle part, ce set ne changeait pas la cape | `BRDCape.Macc`, ta réponse |

**Ta règle reprise** (`config/brd/BRD_CUSTOM.lua`) : `sets.latent_refresh` (ligne 672),
Fucho-no-Obi en idle quand tes MP passent sous 51 %. En idle normal, ta ceinture est déjà
Fucho-no-Obi ; en idle DT, elle remplace Kasiri Belt, comme chez toi.

**Écrit autrement, sans effet en jeu** : lignes 499 et 704, `Feet =` et `Body =` avec une
majuscule. GearSwap ignore la casse des slots (`slot_map` passe les noms en minuscules) : ça
marchait. Réécrits en minuscules pour la lisibilité seulement.

**À vérifier par toi (nous n'avons rien décidé à ta place)** :

- **Tête et pieds EMPY** : `Blodykiller_BRD.lua` lignes 316 et 320 disent Fili Calot **+3** et
  Fili Cothurnes **+2** ; `0_AugGear_Blodykiller.lua` lignes 15 et 19 disent **+2** et **+3**.
  On a gardé ceux du fichier BRD (chargés en dernier, donc ceux que le jeu équipait).
- **Capes Macc et TP** : leurs augments diffèrent entre `Blodykiller_BRD.lua` et
  `0_AugGear_Blodykiller.lua` (lignes 23-24). On a gardé ceux du fichier BRD, pour la même raison.
- **Brioso +3** : `Blodykiller_BRD.lua` lignes 409, 513 et 514 écrivent « Brioso … +3 » en
  toutes lettres, alors que ton AF est en **+4** (ligne 316). Gardé tel quel.
- **Noms d'objets** : ligne 585, « Loricate's Torque +1 » n'existe pas (le vrai nom est
  « Loricate Torque +1 », comme aux lignes 567, 604, 636 et 654) ; ligne 589, « Fili Earring »
  alors que tu en as un augmenté (ligne 521). Gardé tel quel.

---

## Blodykiller – COR

Même comparaison. Identiques : idle (Normal, Regen), engaged (Normal, Subtle Blow), rolls, Quick
Draw (ton `midcast.CorsairShot`, lu chez nous au precast : rien ne le remplace avant le départ de
l'action, donc ce sont les pièces portées au moment du tir), Light / Dark Shot, Fold, JA, Waltz,
Fast Cast, Utsusemi, Phalanx, Cure, tous les sets de tir (Flurry, Acc, HighAcc, Critical, STP) et
de WS, sauf les points ci-dessous. Nusku Shield en sub : ton `SubSet` par défaut.

| # | Fichier, ligne | Avant | Maintenant |
|---|---|---|---|
| 1 | `Blodykiller/Blodykiller_COR.lua` 203 et 252 | `CORCape.RA` et `CORCape.PreRA` : définies seulement pour Gabvanstronger (`0_AugGear.lua`, bloc `player.name == 'Gabvanstronger'`), donc vides pour Blody | pas de cape sur les rolls ni en precast de tir (comme en jeu) |
| 2 | `Blodykiller/Blodykiller_COR.lua` 290 et 304 | `back = CORCape.WS` : c'est la table des capes, pas une cape, rien n'était équipé | `CORCape.WS.STR`, ta seule cape WSD (**supposition** d'après ton commentaire « WSD+10 », à confirmer) |
| 3 | `Blodykiller/Blodykiller_COR.lua` 315 | `CORCape.WS.AGI` : même cas que le 1 | rien |
| 4 | `Blodykiller/Blodykiller_COR.lua` 135 | `state.RangedMode:options('Normal')` : tes sets de tir Acc, HighAcc, Critical, STP n'étaient **jamais** utilisés | RangedMode Normal / Acc / HighAcc / Critical / STP, sur **Alt+F9**, Normal par défaut. Tu nous as dit que ces sets ne sont pas finis : ils restent tels que dans ton fichier, à compléter quand tu veux |
| 5 | `Blodykiller/Blodykiller_COR.lua` 424 | `sets.TripleShot = {}` : vide | gardé vide (`midcast.RA.TripleShot`), à remplir si tu veux |

**Écrit autrement, sans effet en jeu** : lignes 411 et 419-420, `ring1` / `ring2` dans des sets
construits sur un set en `left_ring` / `right_ring`. `set_combine` traduit `ring1` en `left_ring`
et `ring2` en `right_ring` : tes anneaux remplaçaient bien ceux du set de base. Réécrits en
`left_ring` / `right_ring` pour la lisibilité seulement.

**Erreur de notre part, corrigée** : on avait écrit que `MUMM.Legs` (ligne 418, set de tir
Critical) était vide et on avait retiré la pièce. C'est faux : `0_AugGear_Blodykiller.lua` ligne 62
définit `MUMM.Legs = "Mummu Kecks +2"`. Les **Mummu Kecks +2** sont remises dans ton set Critical.

**Tes règles reprises** (`config/cor/COR_CUSTOM.lua`) :

- **Compensator sur les rolls et Double-Up** (lignes 206 et 706) : seulement hors combat, comme
  chez toi. Ton WeaponLock est remplacé par le Combat Mode (Shift+F9), qui verrouille le slot
  range : Compensator ne remplace alors pas ton fusil.
- **QDMode** (lignes 97 et 768-775) : STP (par défaut, ton set Quick Draw tel quel) et Enhance
  (**Mirke Wardecors** sur les tirs à dégâts, pas Light / Dark Shot). Tes valeurs Potency et TH
  posaient exactement les mêmes pièces que STP (ton `sets.TreasureHunter` ligne 654 est vide),
  donc on ne les a pas gardées. Tu n'avais pas de touche pour QDMode : on l'a mis sur **Ctrl+Numpad7**.

**Jamais déclenché chez toi, donc pas repris** : `TripleShotCritical` et le set Critical sous
Aftermath niveau 3 (lignes 780 et 783) testent `player.equipment.ranged == "Armageddon"`. GearSwap
range l'arme de tir sous `player.equipment.range` (`to_names_set` dans `equip_processing.lua`),
pas `ranged` : la condition était toujours fausse. Et Armageddon n'est dans aucune de tes listes
d'armes.

**Choix faits à ta place, à valider** :

- En `/NIN` et `/DNC`, le sub est **Gleti's Knife** (premier couteau de ta liste, ligne 140).
  Notre COR n'a pas de choix de sub comme ton `SubSet`.
- **Luzaf's Ring** reste sur l'anneau droit (par-dessus Warden's Ring), comme ton
  `sets.precast.LuzafRing` ligne 214.
- **Fold** : tes gants Lanun seulement avec deux Bust, comme chez toi (ta réponse). C'est
  maintenant la règle de notre COR pour tout le monde.

---

## Vos touches BindManager (Gab et Blody)

Vérifié contre le code de `BindManager.lua` (`build_desired_binds`, `merge_alt_bind_layers`), pas
seulement contre vos fichiers de données.

**Même priorité** : startup < login.all < login.characters < job principal < sub < alt-binds.
Dans une section d'alt : `all` < `all.<sub de l'alt>` < `<job de l'alt>.default` <
`<job>.<sub de l'alt>` < `<job>.<type d'arme de l'alt>`. Les touches d'alt `all` ne sont posées
que si un alt est connecté, comme chez toi.

**Mêmes commandes** : chaque touche envoie exactement la commande de BindManager (`/recast` avant
le sort, `[Fake #n]` des fausses chansons, tes alias `blody`, `gab`, `sa`, `they`, `sneak stpc`,
`invi stpc`, `boltersroll`, `curaga3`…). Comparaison touche par touche : RDM 45 identiques,
BRD 28, COR 1, et toutes les touches de sub et d'alt.

**Seules différences, voulues** :
- `gs c cycle <Mode>` devient `gs c cyclestate <Mode>` : même défilement, mais notre HUD se met à
  jour (20 touches du RDM).
- `^``, `^~``, `@`` (WeaponSet, SubSet, RangedSet) font défiler nos choix d'arme principale, de
  sub et d'arme de tir : ces modes n'existent pas sous leur ancien nom chez nous.
- F9 à F12 : c'est Mote qui pose les mêmes commandes. `~f9` WeaponLock = notre Combat Mode.
- Pas repris : `numpad0` (`gs c info`, le HUD montre les modes), `^scrolllock`
  (`bindmanager apply`), Thyrsa et Sephiroph (ta réponse).
- Nos touches en plus (numpad du modèle sur BRD et COR, Enfeeble Tier sur Ctrl+F3 en RDM) : aucune
  n'utilise une de tes touches.
- Les touches de démarrage ne sont posées qu'une fois GearSwap chargé (pas à l'écran titre).

**À faire de votre côté** : désactiver BindManager (sinon les deux posent les mêmes touches) et
garder vos alias Windower / Shortcuts.
