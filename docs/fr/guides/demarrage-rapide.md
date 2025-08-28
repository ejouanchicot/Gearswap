# Démarrage Rapide GearSwap

## ⚡ 5 Minutes pour Commencer

### Étape 1 : Configuration Minimale

Éditez **Tetsouo/config/settings.lua** :

```lua
settings.players = {
    main = 'VotreNomPersonnage',    -- ⚠️ CHANGEZ CECI
    alt_enabled = false             -- true si dual-boxing
}
```

### Étape 2 : Copier Votre Job

Copiez le fichier job approprié :

- **THF** : `TETSOUO_THF.lua` → `VotreNom_THF.lua`
- **BLM** : `TETSOUO_BLM.lua` → `VotreNom_BLM.lua`
- **WAR** : `TETSOUO_WAR.lua` → `VotreNom_WAR.lua`

### Étape 3 : Charger

```bash
//gs load VotreNom_THF
```

## ✅ Vérification Rapide

Messages de succès à rechercher :

```text
[GearSwap] VotreNom_THF.lua loaded successfully
[KeybindUI] UI initialized successfully
```

## 🎮 Utilisation Immédiate

### Keybinds Essentiels

- **F1-F6** : Cycle des états (armes, modes)
- **//gs c ui** : Toggle interface
- **//gs c help** : Aide complète

### Commandes Principales

```bash
//gs c help          # Menu aide
//gs c checksets     # Valider équipement
//gs c ui             # Toggle UI
```

## 🔧 Si Ça Ne Marche Pas

1. **Job ne charge pas** → Vérifiez nom fichier exact
2. **Équipement manquant** → `//gs c checksets`
3. **UI invisible** → `//gs c ui`

## 📖 Documentation Complète

- **Configuration** : `docs/fr/features/systeme-configuration.md`
- **Équipement** : `docs/fr/features/systeme-equipement.md`
- **Dual-Boxing** : `docs/fr/features/systeme-dual-boxing.md`
- **Interface UI** : `docs/fr/features/systeme-ui.md`
- **Commandes** : `docs/fr/features/systeme-commandes.md`

Le système est conçu pour fonctionner immédiatement avec une configuration minimale.
