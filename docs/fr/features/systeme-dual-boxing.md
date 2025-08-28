# Système Dual-Boxing

## 🎯 Principe

Coordination automatique entre votre personnage principal et votre alt avec détection intelligente des jobs et commandes adaptées.

## ⚙️ Configuration

### Configuration Personnages

```lua
settings.players = {
    main = 'Tetsouo',     -- Votre personnage principal
    alt_enabled = true,   -- Activer dual-boxing
    alt = 'Kaories',      -- Votre personnage alt
}
```

### Détection Job Alt

Le système lit automatiquement le job de votre alt via `{nom_alt}_job.txt` et adapte les commandes disponibles.

## 🎮 Commandes Principales

Le système détecte automatiquement le job de votre alt. Si besoin, utilisez `//gs c setjob <JOB>` pour forcer manuellement.

### Alt GEO

```bash
//gs c altgeo             # Sort Geo sur cible appropriée
//gs c altindi            # Sort Indi sur vous
//gs c altentrust         # Entrust Indi vers personnage principal
```

### Alt RDM

```bash
//gs c bufftank           # Haste2 + Refresh3 + Phalanx2 + Regen2
//gs c buffmelee          # Haste2 + Phalanx2 + Regen2
//gs c buffrng            # Flurry2 + Phalanx2 + Regen2
//gs c debuff             # Distract3 + Dia3 + Slow2 + Blind2 + Paralyze2
```

### Alt BRD

```bash
//gs c song1              # Song slot 1
//gs c song2              # Song slot 2
//gs c honor              # Honor March
//gs c victory            # Victory March
```

## 🔧 Fonctionnement

1. **Détection Auto** : Le système détecte le job de votre alt automatiquement
2. **Macros Dynamiques** : Change les livres de macro selon la combinaison main+alt
3. **Ciblage Intelligent** : Buffs sur vous, debuffs sur l'ennemi
4. **Commandes Adaptées** : Seules les commandes du job alt actuel apparaissent

## 🛠️ Dépannage

- **Alt pas détecté** → Vérifiez `alt_enabled = true` et orthographe exacte des noms
- **Commandes manquantes** → `//gs c setjob <JOB>` pour forcer le job alt  
- **Sorts mal ciblés** → Vérifiez la configuration des noms de personnages
