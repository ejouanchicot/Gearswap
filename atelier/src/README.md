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

## Ce qu'il y a dans `src/`

La migration vers Svelte est finie (2026-10-20) ; son journal est dans l'historique git.

- `main.ts` monte l'application (`App.svelte`) ; `bridge.ts` est le pont que lisent les tests
  (`window.__atelier`).
- `legacy/` : l'ancienne page (`atelier/app/`), toujours chargée par l'application. `files.ts` donne la liste de
  ses styles et de ses scripts, dans l'ordre où ils sont lus ; `load.ts` les charge.
- `screens/<écran>/` : un dossier par écran, le `.svelte` qui dessine et le `.ts` qui prépare ce qu'il montre :
  `combat`, `config`, `dialogs` (les fenêtres), `home`, `optimizer`, `packages`, `perso` (dont les sacs),
  `profiles`, `sets`, `settings`, `sim`, `topbar`, `update`.
- `screens/update/` : l'écran de mise à jour (le bouton ⬆ de la barre du haut, ou `//gs c upgrade` en jeu). Ses
  règles restent dans l'ancienne page (`atelier/app/js/update.js` sur `update_core.js`), les fichiers passent par
  AtelierLink.
- `components/` (morceaux communs), `stores/`, `styles/`.

## Vérifier une étape

- `node scripts/atelier/page_parity.js scripts/atelier/parity/<écran>.json` : l'ancienne page (le dernier commit,
  ou `--ref <commit>`) et la nouvelle côte à côte, sur les mêmes données figées, comparées au pixel (une vingtaine de
  secondes par écran). `--self` mesure le bruit du contrôle, `--dom` garde le HTML des vues qui diffèrent.
- Les tests de clics (`scripts/atelier/clicks/`, leur README) : `node scripts/atelier/atelier_clicks_test.js
  --compare [noms]` compare ce qu'un joueur lit sur la page du dernier commit et sur la page actuelle.
- Tout en une commande : `bash scripts/atelier/cycle.sh quick <écrans> -- <tests de clics>` pour une étape (quelques
  minutes), `bash scripts/atelier/cycle.sh full` avant un commit qui touche beaucoup d'écrans (une demi-heure).
- Entre deux étapes : `python scripts/run_tests.py` (les tests rapides, une quinzaine de secondes), `npm run check`
  et `npm run build`. La suite complète (`--full`) au moment du commit.

## Ce qui reste en dehors du fichier construit

Lu par la page au moment où elle tourne, comme avant : les exports (`<Perso>/atelier/exports/*.js`,
`atelier/index.js`), le lien au jeu (`atelier/live_*.js`, `atelier/link_*.js`), le moteur (`atelier/calc/`,
`atelier/opt.js` ; l'ancien, `atelier/engine/`, n'est plus chargé depuis le Lot 5), Lua (`atelier/lua/`) et l'ancienne page (`atelier/app/`), chargée pour de bon
(`legacy/files.ts`).

## Les vérifications

- `scripts/atelier/atelier_build_check.js` : la page construite vient bien des sources actuelles (sinon : `npm run build`).
- `scripts/atelier/atelier_test.js` : la page dans Chrome, tous les persos, sets, fenêtres et recherches.
- `scripts/atelier/atelier_layout_check.js` : rien ne dépasse de son cadre, de 1920 à 390 px.
- Les tests attendent `window.__atelier.ready` (`bridge.ts`) avant de commencer.
