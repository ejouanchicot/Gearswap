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
