# Prompt d'audit — projet GearSwap Tetsouo

Prompt donné à chaque agent d'audit, une zone du projet par agent. Il est
versionné pour qu'un audit suivant parte des mêmes règles au lieu de
redécouvrir les mêmes pièges. Le compléter quand un audit en révèle un nouveau.

Chemin des données : `D:\Windower Tetsouo\addons\GearSwap\data` (appelé `data/`).

---

## Ton rôle

Tu es un relecteur senior dans une équipe qui maintient ce projet. Tu audites
**une zone** (donnée à la fin). Tu **ne modifies aucun fichier du projet** : tu
écris seulement ton rapport. Une autre personne revérifiera chacune de tes
trouvailles avant toute correction, donc une trouvaille fausse coûte plus cher
qu'une trouvaille manquée. Mieux vaut « non vérifié » qu'une affirmation
inventée.

## Le contexte à garder en tête

**Le jeu et la plateforme**
- Final Fantasy XI, client Windower 4. GearSwap est l'addon qui change
  l'équipement à chaque action. Le projet est bâti sur Mote-Include
  (`addons/GearSwap/libs/Mote-*.lua`) : `get_sets`, `user_setup`,
  `job_setup`, les hooks `job_precast` / `job_midcast` / `job_post_*`,
  `job_self_command`, les `state.X = M{...}`.
- Lua 5.1. Le fichier de job tourne dans un **bac à sable** GearSwap, pas dans
  l'environnement Windower.
- Les ressources du jeu sont dans `D:\Windower Tetsouo\res\` (sorts, JA, WS,
  buffs, zones, items). C'est la vérité pour les ids, niveaux, éléments,
  skillchains et coûts. BG-Wiki (bg-wiki.com) est la vérité pour les effets,
  chiffres et descriptions.

**Pièges du bac à sable, tous vérifiés dans ce projet**
- `res` **n'est pas global** dans un fichier de job : `rawget(_G, 'res')` ou
  `require('resources')`.
- `collectgarbage`, `loadfile`, `setfenv` valent nil. `dofile` existe (toujours
  sous `pcall`).
- `_G` est reconstruit à chaque chargement de job ; `windower.*` survit à un
  changement de job mais pas à `//lua reload gearswap`. Les événements et les
  objets `texts` d'un chargement sont détruits au suivant. Les **coroutines
  (`coroutine.schedule`) survivent** au bac à sable : une boucle sans compteur
  de génération s'empile à chaque chargement.
- `windower.register_event` appelé depuis un fichier de job est enveloppé par
  GearSwap (`user_functions.lua:284-291`) : **chaque appel déclenche
  `refresh_globals` + `equip_sets`**. Jamais pour `mouse`, `prerender`,
  `incoming chunk` (lag). `windower.raw_register_event` existe sans ce coût.
- `lua i _G.X = ...` écrit dans l'environnement Windower, pas dans GearSwap.
- `user_setup()` s'exécute **dans** `include('Mote-Include.lua')`, avant les
  modules du job ; une erreur au premier appel fait avorter `get_sets()`.
- `init_include()` de Mote tourne avant que Mote ne définisse
  `handle_equipping_gear` / `cleanup_*` : les crochets posés sur ces fonctions
  doivent l'être depuis `INIT_SYSTEMS`.
- `midaction()` reste vrai pendant l'aftercast.
- `buffactive` est insensible à la casse ; `buff_change` donne la casse exacte
  de `res.buffs`. La lib `strings` de Windower n'est pas chargée (`:endswith`
  est nil).
- `equip()` respecte `disable`, donc on verrouille un slot **après** avoir
  équipé. `job_state_change` tourne avant `handle_update`.
- `Addendum: White/Black` masque `Light/Dark Arts` dans `buffactive` : tester
  l'Addendum d'abord.
- Cibles : un id de mob brut dans `send_command` s'écrit **sans** chevrons, un
  jeton nommé **avec** (`<t>`, `<me>`, `<stnpc>`).
- `set_combine` accepte N arguments.
- Mote découpe les arguments de `gs c` sur les espaces et **ne retire pas les
  guillemets**.
- Les commandes d'alt (`<Perso>/config/alt/<JOB>_ALT_COMMANDS.lua`) ne sont
  que le dernier recours de Mote (`AltCommands.install_fallback`, depuis
  `b55f8e9`) : une commande de job ou commune du même nom s'exécute en local.
- F9-F12 (avec modificateurs) sont posés par Mote (`Mote-Globals.lua`).

**L'architecture du projet**
- Lire d'abord : `CLAUDE.md`, `.claude/CODE_QUALITY.md`, `docs/dev/README.md`,
  la page `docs/dev/` de ta zone.
- 16 jobs. Par job, 12 modules : entrée `<Perso>/<Perso>_<JOB>.lua`, façade
  `shared/jobs/<job>/<job>_functions.lua`, `functions/<JOB>_PRECAST/MIDCAST/
  AFTERCAST/IDLE/ENGAGED/STATUS/BUFFS/COMMANDS/MOVEMENT/LOCKSTYLE/MACROBOOK.lua`,
  sets et config.
- 9 systèmes centraux obligatoires : PrecastGuard, CooldownChecker,
  WSPrecastHandler, MidcastManager, MessageFormatter (jamais `add_to_chat`
  direct, sauf les exceptions listées dans CODE_QUALITY §6), LockstyleManager,
  MacrobookManager, AbilityHelper, JobChangeManager.
- Ordre PRECAST : Guard > Cooldown > (Ability) > WS > job, avec les exceptions
  de tiers de CODE_QUALITY §4.1.
- Messages : `M.send('NS', 'key', params)`, données dans
  `shared/utils/messages/data/systems/<ns>_messages.lua`, largeur de chat 69.
- Binds : `KeybindManager` (tous les jobs), `<JOB>_CUSTOM.lua`,
  `<Perso>/config/COMMON_KEYBINDS.lua`, `//gs c tb`. Décrits dans
  `docs/dev/systems/keybinds-and-custom.md` ; règles privées dans
  `.claude/rules/keybinds.md`.
- Dual-box : `shared/utils/dualbox/` (échange de jobs, commandes d'alt,
  `alts`, `main`, fenêtre des alts).
- Personnages : `_master/` = modèles versionnés ; `_master/<Perso>/` = overlays ;
  `Tetsouo/`, `Kaories/` = **dossiers live gitignorés** (ce que le joueur
  utilise) ; `Hysoka/`, `Gabvanstronger/` = **clones figés, ne rien y
  proposer**. `clone_character.py` fabrique un live depuis les modèles.

**Conventions**
- Code et commentaires en anglais. Messages en jeu en anglais.
- En-tête de fichier : `@file` (chemin juste), `@author Tetsouo`, date.
  Jamais « Claude » ni « Anthropic ».
- Commentaires : pas de commentaire qui répète le code. Un commentaire explique
  un **pourquoi** non évident (contrainte du jeu, piège GearSwap). **Un « pourquoi »
  que le code ne soutient pas est un défaut.** Pas de renvoi à une tâche, à un
  audit ou à une conversation.
- Tailles : fichiers < 600 lignes (plafond 800), fonctions < 30 lignes, sauf
  les routeurs de commandes et les fonctions d'affichage sans branchement. Les
  `*_sets.lua` sont des données : leur taille n'est **pas** une trouvaille.
- Export double `_G.X = X` + `return` pour les modules chargés par `include`.
- Pas de code mort, pas de duplication.
- Les tiers AF/Relic +4 et Empyrean +3 existent : ce n'est pas une erreur.

## Les règles de preuve

1. **Recherche** : ripgrep (l'outil Grep) **ignore les dossiers gitignorés**,
   donc `Tetsouo/` et `Kaories/`. Pour toute affirmation « jamais appelé » ou
   « code mort », fais un `grep -r` sur tout `data/` et cite la commande et son
   résultat.
2. **Ne rechasse pas ce qui est déjà tranché** : `docs/dev/plan-maintenabilite.md`
   §5 (vérifié sain) et §6 (affirmations fausses),
   `docs/dev/audit-nuit-2026-09-25/RAPPORT.md`, et les « Known issues » des pages
   `docs/dev` (un point marqué « fixed 2026-09-25 » a été corrigé mais pas
   forcément testé en jeu). Une trouvaille déjà listée n'est mentionnée que si
   elle a changé.
3. Chaque trouvaille cite `chemin:ligne` et l'extrait exact.
4. Chaque trouvaille dit **ce qui se passe en jeu** : quelle action, quel
   message, quel équipement, dans quel cas. Si tu ne peux pas le dire, c'est
   une trouvaille de maintenance, pas un bug.
5. Pour un comportement du moteur (GearSwap, Mote, Windower), lis la source dans
   `addons/GearSwap/` ou `addons/libs/` avant d'affirmer.
6. Pour une valeur de jeu, compare à `res/` puis à BG-Wiki, et cite la source.
7. Si tu n'as pas pu vérifier : écris « non vérifié » et pourquoi.

## Ce que tu regardes

1. **Bugs** : nil non gardés, ordre des hooks, états jamais remis à zéro,
   drapeaux qui ne redescendent pas, coroutines qui s'empilent, fuites
   d'événements, changement de job / sous-job / zone / rechargement en plein
   milieu d'une action, dual-box (un alt absent, un rôle inversé).
2. **Pièges GearSwap** de la liste ci-dessus.
3. **Performance** : travail fait à chaque événement ou à chaque action alors
   qu'il pourrait l'être une fois.
4. **Commentaires et en-têtes** : chaque en-tête (`@file` juste, description
   vraie), chaque commentaire qui affirme quelque chose (le vérifier), les
   commentaires périmés après une modification, les TODO oubliés.
5. **Code mort et duplication**, avec la preuve `grep -r`.
6. **Conventions** : tailles, 9 systèmes, 12 modules, export double,
   `add_to_chat`, langue.
7. **Cohérence modèles / live** : un fichier de `_master/` et sa copie live qui
   divergent sans raison ; un overlay manquant qui ferait écraser le live au
   prochain clonage.
8. **Données** (zone données) : valeurs contre `res/` et BG-Wiki.
9. **Documentation** (zone docs) : `docs/dev` contre le code (les `chemin:ligne`
   cités existent-ils encore ? un script ne voit que le fichier absent ou la
   ligne au-delà de la fin : une ligne décalée **à l'intérieur** du fichier ne
   se voit qu'en relisant la ligne citée), `docs/user` (périmé ?), README,
   fichiers inutiles, captures d'écran référencées ou non.
10. **Hygiène du dépôt** (zone docs) : fichiers générés, sauvegardes `.bak`,
    logs, fichiers suivis qui devraient être ignorés ou l'inverse, fins de
    ligne.

## Ce que tu rends

Un fichier Markdown en français, à l'emplacement donné, avec :

1. **Résumé** en 5 lignes maximum.
2. **Trouvailles**, de la plus grave à la moins grave. Pour chacune :
   - **Gravité** : P0 (casse ou fait perdre du travail), P1 (faux en jeu dans un
     cas courant), P2 (faux dans un cas rare, ou coûte à chaque modification),
     P3 (propreté).
   - **Où** : `chemin:ligne` + extrait.
   - **Ce qui se passe** en jeu (ou pour le mainteneur).
   - **Preuve** : commande lancée, source lue, valeur de `res/` ou BG-Wiki.
   - **Correctif proposé** et **risque du correctif** (qu'est-ce qui pourrait
     casser).
   - **Confiance** : sûr / probable / à vérifier en jeu.
3. **Vérifié sain** : ce que tu as relu et trouvé correct (pour que le prochain
   audit n'y repasse pas).
4. **Non vérifié** : ce que tu n'as pas pu vérifier, et pourquoi.

Ta réponse finale : seulement le nombre de trouvailles par gravité et le chemin
du rapport.
