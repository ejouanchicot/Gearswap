# Atelier — sources de la page (TypeScript + Svelte 5)

La page que l'on ouvre est **un seul fichier construit** : `atelier/index.html`. On ne le modifie jamais à la main :
on modifie `atelier/src/` puis on reconstruit.

```
cd atelier
npm install          # une fois (les outils, dans atelier/node_modules, jamais livrés)
npm run build        # après tout changement dans src/ : réécrit atelier/index.html
npm run check        # vérifie les types (TypeScript et Svelte)
```

Les joueurs n'ont besoin de rien de tout ça : ils ouvrent le fichier construit, comme avant.

## Où en est la migration

Plan et chiffres : `notes/docs-perso/audit-atelier-ts-svelte-2026-10-17/RAPPORT.md`.

- **Étape 0 (2026-10-18)** : la base. L'application Svelte (`App.svelte`) contient l'ancienne page : son cadre, puis
  ses styles et ses scripts (`atelier/app/`), chargés dans leur ordre par `legacy/load.ts` (la liste est dans
  `legacy/files.ts`). Rien ne change à l'écran.
- **Étape 1 (2026-10-18)** : la barre du haut (`screens/topbar/`). Svelte la dessine à chaque redessin de l'ancienne
  page (`stores/legacy.svelte.ts`, appelé par `window.__atelier.redraw()`) à partir de son état, lu par
  `screens/topbar/model.ts` (les noms de l'ancienne page qu'il lit sont typés dans `legacy/globals.d.ts`). Ses boutons et
  menus gardent les attributs `data-*` et les classes que lisent encore les gestionnaires de clics de l'ancienne page
  (`events.js`, `packages.js`) : les actions passeront en Svelte avec les écrans qui les utilisent.
- **Étape 2 (2026-10-18)** : la configuration du job (`screens/config/` : Touches, Modes, Fonctions, Macrobook &
  lockstyle, Modules, et la liste des jobs à gauche). `#view` contient la zone de l'ancienne page (`#legacyview`) et
  les écrans Svelte, redessinés tout de suite à la fin de chaque redessin (`flushSync`), avant que l'ancienne page
  remette le focus, les blocs dépliés et le défilement. Restent à l'ancienne page : la fenêtre qui change une touche,
  et les contrôles des réglages de Modules (interrupteurs, nombres, listes d'objets, tableaux de lignes, couleurs :
  `ctlHtml`, `modules.js` modControl et `module_ux.js`, `module_items.js`, `module_rows.js`).
- **Étape 3a (2026-10-18)** : Mon perso (`screens/perso/` : l'en-tête, le choix Stats / Sacs, PorterPacker, les
  mérites). Restent à l'ancienne page : la liste des sets à gauche et les cartes de stats (celles de l'écran Sets,
  étape 5).
- **Étape 3b (2026-10-18)** : la vue Sacs de Mon perso (`screens/perso/bags.ts`, `Bags.svelte` : les sacs en tuiles,
  où est le perso, l'état du rangement, la liste avec sa recherche et ses filtres, la sélection, les cartes du plan).
  La recherche et la sélection d'objets redessinent la page (`render()`) au lieu d'écrire dans la liste : Svelte ne
  change que ce qui bouge, le champ garde son curseur. Les données (les sacs, le plan, qui porte quoi) restent
  celles de l'ancienne page (`bags_*.js`).
- **Étape 4a (2026-10-18)** : Buffs & cible (`screens/combat/` : l'en-tête et ses actions, le groupe en onglets avec
  ce que donne chaque membre, la cible, ce que ça change pour le set ouvert, le total). Restent à l'ancienne page : la
  barre des profils et les onglets des situations (`profiles.js`), le panneau du membre choisi (`pbYouBody`,
  `pbBody`), le choix de la cible et les autres debuffs (`buff_panels.js`), la liste des sets à gauche (étape 5).
- **Étape 4b (2026-10-18)** : le panneau du membre choisi (`screens/combat/panel.ts`, `Panel.svelte` : un
  formulaire en données, sections → lignes → contrôles, pour toi, GEO, BRD, COR, WHM, RDM, SCH et les jobs à
  capacités). Restent à l'ancienne page, parce qu'ils y sont aussi dessinés ailleurs : la barre des profils et les
  situations (leur forme courte au-dessus des sets, étape 5), la cible et les autres debuffs (l'ancienne fenêtre des
  buffs, étape 7), la ligne de l'aftermath, les puces des rolls, Warcry et Haste Samba (`buff_panels.js`).
- **Étape 5a (2026-10-18)** : l'écran Sets (`screens/sets/` : son cadre) et la liste des sets à gauche
  (`setlist.ts`, `SetList.svelte`), la même pour Sets, Buffs & cible et Mon perso. Elle laisse dans l'état de la page
  ce que l'ancienne y laissait (le set montré, les catégories ouvertes, les lignes des flèches du clavier). Une
  autre vue repart du haut de la liste, comme quand l'ancienne page la recréait (`render`, sets_view.js). Restent à
  l'ancienne page : la ligne au-dessus des sets (`ui2CtxBar`), la tête des catégories, les marques et actions d'une
  ligne, tes sections à toi, le haut de la liste et son menu (`list_prefs.js`), la fiche du set (étape 5b) et la
  colonne de ses chiffres (étape 5c).
- **Étape 5b (2026-10-18)** : la fiche du set (`screens/sets/card.ts`, `Card.svelte` : sa tête et ses versions,
  en rangée ou en grille pour les weaponskills DNC, les seize cases d'équipement, la ligne sous elles). Restent à
  l'ancienne page : le titre et les menus des armes (`setTitleBox`, `weaponMenus`), la tête d'un weaponskill
  (`ws_page.js`), la barre de l'essai (`trial.js`), le bouton pour équiper (`live.js`), la légende, les notes, les
  chiffres du set (étape 5c) et la page de l'optimiseur (étape 6).
- **Étape 5c (2026-10-18)** : la colonne des chiffres du set (`screens/sets/figures.ts`, `Figures.svelte`,
  `StatBox.svelte` : les boîtes en données, l'attaque et la défense calculées ici). L'ancienne page dessine ces
  mêmes boîtes par ce code (`window.ATELIER_FIGURES`, engine.js `tankHTML` / `offenseHTML`) pour ses écrans à elle
  (la fenêtre des buffs, les cartes de Mon perso) : un seul calcul. Restent à l'ancienne page : la boîte du nuke
  (`fight_stats.js`), le cycle des HP (`stat_opt.js`), la Luopan (`luopan.js`), la feuille des stats (`stats.js`),
  toutes les stats (`globalsHTML`), les lignes de tank en plus (`tankExtraHTML`).
- **Étape 5d (2026-10-19)** : les situations et les profils (`screens/profiles/` : `profiles.ts`,
  `Situations.svelte`, `Picker.svelte`), la même chose dans la barre de Buffs & cible et dans la ligne au-dessus des
  sets. La recherche et le filtre de situation de la fenêtre des profils redessinent la page au lieu de cacher les
  lignes à la main (`profiles.js`). Reste à l'ancienne page : l'avertissement de sub (`subWarnHTML`).
- **Étape 6a (2026-10-19)** : la page de l'optimiseur d'un set (`screens/optimizer/optpage.ts`, `OptPage.svelte` :
  l'en-tête, les objectifs et leurs réglages, le gros chiffre et son verdict, l'image du résultat — courbe, jauge,
  rounds, facteurs, barres —, le tableau). Ce que valent les chiffres reste à `opt_page.js` (`opFigures`, `opRows`).
  Restent à l'ancienne page : les blocs partagés avec l'optimiseur de stats (limites, onglets de recherche, pièces
  changées) et cet optimiseur lui-même (`stat_opt.js`), les boutons de recherche, la situation d'un nuke.
- **Étape 6b (2026-10-19)** : la fenêtre de recherche en cours (`screens/optimizer/run.svelte.ts`, `OptRun.svelte` :
  l'horloge, le meilleur trouvé et son gain, sa courbe, une carte par marche, le fil des changements, puis le
  résultat). Le composant est monté une fois dans une boîte à lui que l'ancienne page déplace entre `#overlay` et la
  réserve des recherches cachées ; `optimizer.js`, `opt_all.js` et `moogle.js` changent l'état de la recherche
  (`S._optRun`) puis le préviennent (`window.ATELIER_RUN.changed`) au lieu d'écrire dans la page. Restent à
  l'ancienne page : les scènes du Mog (`moogle.js`), les boutons du résultat, le tableau final de « tout optimiser »
  (`opt_all.js`).
- **Étape 6c, 1re partie (2026-10-19)** : les fenêtres par-dessus la page (`screens/dialogs/` : `dialogs.svelte.ts`,
  `Dialog.svelte`, montées une fois comme la fenêtre de recherche ; `showDialog`, trial.js, ne fait plus que les
  ouvrir, chaque ouverture redessinée à neuf) et Comparer (`compare.ts`, `Compare.svelte`). Les autres fenêtres
  gardent le HTML de leur corps (le choix d'une chanson, de la cible, pousser dans GearSwap...).
- **Étape 6c, 2e partie (2026-10-19)** : la fenêtre des pièces d'une case (`gearpick.ts`, `GearPick.svelte` : ses
  filtres, les pièces en cartes avec leur valeur et leur écart). Sa recherche cache toujours les cartes sur place
  (events.js `#drawq`) : la fenêtre n'est redessinée qu'à un filtre.
- **Étape 6c, 3e partie (2026-10-19)** : le choix de la cible (`target.ts`, `Target.svelte` : son cadre à lui, la
  recherche, l'ordre, les zones, les favoris et les derniers choisis, chaque monstre). La recherche et la zone
  redessinent la fenêtre en place (`ATELIER_DIALOG.update` : le champ garde son curseur) au lieu de cacher et
  déplacer les cartes à la main (`tgFilter`, retiré).
- **Étape 6c, 4e partie (2026-10-19)** : les fenêtres de choix du groupe (`partypick.ts`, `PartyPick.svelte` :
  une chanson, un roll, une bulle, une tempête, une nourriture, un membre à ajouter). Leur recherche est dans la
  fenêtre elle-même (`pbDlgSearch`, retiré).
- **Étape 6c, 5e partie (2026-10-19)** : pousser un set dans GearSwap, le supprimer, en ajouter un vide
  (`pushview.ts`, `PushView.svelte`), une fois que le jeu a dit ce qui changerait ; le plan, les avertissements et la
  réponse du jeu restent à `push.js`.
- **Étape 6c, 6e partie (2026-10-19)** : « Selon la PT » (`tiercost.ts`, `TierCost.svelte` : chaque version d'un set
  dans chaque situation) et l'historique des écritures dans GearSwap (`history.ts`, `History.svelte`).
- **Étape 6c, 7e partie (2026-10-19)** : « Tout optimiser » une fois cherché (`optall.ts`, `OptAll.svelte`, redessiné
  en place pendant l'écriture des versions : le tableau garde son défilement, le Mog son saut) et la fenêtre du Lua à
  coller (`openLua`, trial.js, par le cadre commun).
- **Ménage (2026-10-19)** : l'ancienne fenêtre des buffs et l'ancienne fenêtre de la cible sont retirées (`openBuffs`,
  `openTarget`, `buffPanelHTML` et ce qu'elles seules appelaient) : la nouvelle disposition ne les ouvrait plus
  (`ui2()` vaut toujours vrai, la colonne complète de l'ancienne disposition n'était plus dessinée). Buffs & cible lit
  la carte de la cible et les autres debuffs directement (`targetCardPanel`, `foePanelHTML`). Le bouton Debug de
  l'ancienne fenêtre de la cible ne s'ouvre plus de nulle part : `openDebug` (engine.js) est gardé en attendant une
  décision.
- **Étape 6c, 8e partie (2026-10-19)** : « Filtrer les stats » (`statpick.ts`, `StatPick.svelte` : son cadre à lui, un
  bloc par groupe de stats ; redessiné en place, la liste garde son défilement aussi après « Tous / Aucun » d'un
  groupe, l'ancienne remontait en haut). Les outils du haut (ordre, presets) restent le HTML de `statPickTools`.
- **Étape 6c, 9e partie (2026-10-19)** : « Ajouter un set » (`addset.ts`, `AddSet.svelte` : son cadre à lui, les trois
  étapes ; `add_set.js` garde les étapes, la recherche qui cache des lignes en place et ce qui part au jeu). Un export
  sans catalogue garde la liste des WS de `push.js` (`addWsList`) en HTML.

## Vérifier une étape

- `node scripts/atelier/page_parity.js scripts/atelier/parity/<écran>.json` : l'ancienne page (le dernier commit,
  ou `--ref <commit>`) et la nouvelle côte à côte, sur les mêmes données figées, comparées au pixel (une vingtaine de
  secondes par écran). `--self` mesure le bruit du contrôle, `--dom` garde le HTML des vues qui diffèrent.
- Entre deux étapes : `python scripts/run_tests.py` (les tests rapides, une quinzaine de secondes), `npm run check`
  et `npm run build`. La suite complète (`--full`) au moment du commit.
- Les étapes suivantes déplacent un écran entier à la fois dans `src/screens/` ; ses fichiers sortent alors des
  listes de `legacy/files.ts`.

## Ce qui reste en dehors du fichier construit

Lu par la page au moment où elle tourne, comme avant : les exports (`<Perso>/atelier/exports/*.js`,
`atelier/index.js`), le lien au jeu (`atelier/live_*.js`, `atelier/link_*.js`), les moteurs (`atelier/engine/`,
`atelier/calc/`, `atelier/opt.js`), Lua (`atelier/lua/`) et, pendant la migration, l'ancienne page (`atelier/app/`).

## Les vérifications

- `scripts/atelier/atelier_build_check.js` : la page construite vient bien des sources actuelles (sinon : `npm run build`).
- `scripts/atelier/atelier_test.js` : la page dans Chrome, tous les persos, sets, fenêtres et recherches.
- `scripts/atelier/atelier_layout_check.js` : rien ne dépasse de son cadre, de 1920 à 390 px.
- Les tests attendent `window.__atelier.ready` (`bridge.ts`) avant de commencer.
