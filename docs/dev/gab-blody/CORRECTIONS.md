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
| Ligne 187, `engaged['Store TP']` construit sur `engaged.DT`, défini seulement ligne 204 | `engaged.DT` était sauté, mais ton set Store TP remplit tous les slots : même résultat |
| Lignes 243 et 244, `body` écrit deux fois dans Subtle Blow | Lua garde la dernière (Volte Harness), c'est celle qu'on a gardée |

### Retiré (ne servait déjà pas chez toi)

| Set de ton fichier | Pourquoi |
|---|---|
| `engaged.Acc` et `engaged.Acc.DW` | « Acc » n'est pas dans ta liste de modes engagés |
| `idle.Vagary` | « Vagary » n'est pas un de tes modes idle |
| `midcast['Enfeebling Magic'].Mixed` | « Mixed » n'est pas une valeur de ton EnfeebleMode |
| `precast['Ranged']` (ligne 380) | ce nom n'est lu par rien |
| `midcast.casting` et `midcast['Enhancing Magic'].Potency` | aucun code ne les cherchait ; gardés comme base des sets qui en héritent, sous un nom local |
| Tes 15 sets d'arme simples (Naegling, Excalibur…) | remplacés par « armes sans set », ta demande |
| `sets.Usable` et les alias `warp`, `dem`, `holla`… (`0_AugGear.lua` ligne 185) | remplacés par `//gs c warp`, `//gs c dem`, `//gs c holla`… |

### Touches : un conflit à trancher

`Alt+Z` et `Alt+X` étaient à la fois tes objets (Silent Oil, Prism Powder : BindManager
`login.characters.Gabvanstronger`) et tes sorts RDM (Sneak, Invisible : BindManager
`jobs.main_jobs.RDM`). En RDM, on a gardé **les sorts**. Dis-nous si tu préfères l'inverse.

---

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
| 3 | `Blodykiller/Blodykiller_BRD.lua` 476 | `back = BRDCape.Mid` : cette cape n'est définie nulle part, ce set ne changeait pas la cape | slot laissé vide, comme en jeu |

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
| 4 | `Blodykiller/Blodykiller_COR.lua` 135 | `state.RangedMode:options('Normal')` : tes sets de tir Acc, HighAcc, Critical, STP n'étaient **jamais** utilisés | RangedMode Normal / Acc / HighAcc / Critical / STP, sur **Alt+F9** |
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
- **Fold** : tes gants Lanun vont sur chaque Fold, plus seulement avec deux Bust (ils ne
  servent qu'à Fold).
