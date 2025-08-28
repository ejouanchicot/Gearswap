# Documentation GearSwap

## ⚡ Démarrage Rapide

### 5 Minutes pour Commencer

1. **[Guide Démarrage Rapide](guides/demarrage-rapide.md)** - Configuration immédiate
2. Éditez `Tetsouo/config/settings.lua` avec votre nom de personnage  
3. Copiez le fichier job approprié
4. Chargez avec `//gs load VotreNom_JOB`

## 📚 Documentation

### Guides Essentiels

- **[Démarrage Rapide](guides/demarrage-rapide.md)** - Configuration en 5 minutes
- **[Système Commandes](features/systeme-commandes.md)** - Toutes les commandes
- **[Système Équipement](features/systeme-equipement.md)** - Gestion équipement
- **[Système Dual-Boxing](features/systeme-dual-boxing.md)** - Multi-personnage

### Références Techniques

- **[Référence API](reference/api.md)** - APIs de développement
- **[Architecture](reference/architecture.md)** - Structure système
- **[Performance](reference/performance.md)** - Optimisation

## 🎮 Jobs Supportés

### Personnage Principal (10 jobs)

**THF** - **WAR** - **BLM** - **PLD** - **BST**  
**DNC** - **DRG** - **RUN** - **BRD** - **RDM**

### Personnage Alt (4 jobs)

**GEO** - **RDM** - **COR** - **PLD**

## ⚡ Commandes Essentielles

```bash
//gs c help           # Aide complète
//gs c checksets      # Valider équipement
//gs c ui             # Toggle interface
//gs c altgeo         # Alt GEO sorts (si dual-boxing)
```

## 🔧 Configuration Minimale

```lua
-- config/settings.lua
settings.players = {
    main = 'VotreNom',              -- ⚠️ CHANGEZ CECI
    alt_enabled = false             -- true si dual-boxing
}
```

## 🆘 Problèmes Courants

- **Job ne charge pas** → Vérifiez nom fichier exact
- **Équipement manquant** → `//gs c checksets`  
- **UI invisible** → `//gs c ui`
- **Alt non détecté** → `//gs c status`

Le système est conçu pour fonctionner immédiatement avec une configuration minimale.
