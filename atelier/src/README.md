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
  étape 5), la vue Sacs (étape 3b).
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
