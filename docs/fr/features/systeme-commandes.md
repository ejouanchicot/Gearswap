# Guide des Commandes GearSwap

Un système de commandes intelligent qui s'adapte automatiquement à votre job et configuration dual-boxing.

## 🎯 Commandes de Base

### Menu d'Aide et Information

```bash
//gs c help              # Menu d'aide principal avec toutes les sections
//gs c info               # Informations détaillées du système et cache
//gs c binds              # Keybinds actifs de votre job (détection auto)
//gs c commands           # Liste complète des commandes disponibles  
//gs c dual               # Guide dual-boxing avec commandes alt
```

### Gestion de l'Équipement

```bash
//gs c checksets          # Valide tous vos sets et montre les objets manquants
//gs c ui                 # Active/désactive l'affichage des keybinds
//gs c clear_cache        # Vide le cache système (résout les bugs d'items)
```

### Surveillance des Performances  

```bash
//gs c perf start         # Démarre le monitoring de performance
//gs c perf stop          # Arrête le monitoring
//gs c perf report        # Affiche le rapport détaillé des performances
//gs c perf clear         # Reset métriques performance
```

## 🎮 Dual-Boxing Avancé

Le système détecte automatiquement votre personnage alt et adapte les commandes disponibles.

### Configuration Initiale

```bash
//gs c setjob <JOB>       # Définir le job de votre personnage alt
```

**Exemples :**

```bash
//gs c setjob GEO         # Configure Kaories comme GEO
//gs c setjob RDM         # Configure Kaories comme RDM
//gs c setjob BRD         # Configure Kaories comme BRD
```

### Commandes avec Alt GEO

```bash
//gs c altgeo             # Lance le sort Geo sélectionné sur la bonne cible
//gs c altindi            # Lance le sort Indi sélectionné sur vous
//gs c altentrust         # Entrust l'Indi actuel vers le personnage principal
//gs c altnuke            # Nuke avec le sort élémentaire + tier sélectionné

# Gestion dynamique des sorts  
//gs c cycle altPlayerGeo   # Change le sort Geo (Haste, Malaise, etc.)
//gs c cycle altPlayerIndi  # Change le sort Indi (Fury, Haste, etc.)
```

### Commandes avec Alt RDM

```bash
# Séquences de buffs ciblées
//gs c bufftank           # Haste2 + Refresh3 + Phalanx2 + Regen2 (tank)
//gs c buffmelee          # Haste2 + Phalanx2 + Regen2 (mêlée)
//gs c buffrng            # Flurry2 + Phalanx2 + Regen2 (distance)

# Soins et debuffs
//gs c curaga             # Curaga3 d'urgence sur la party
//gs c debuff             # Distract3 + Dia3 + Slow2 + Blind2 + Paralyze2
```

### Commandes avec Alt BRD

```bash
//gs c song1              # Lance la song slot 1
//gs c song2              # Lance la song slot 2  
//gs c honor              # Honor March sur la party
//gs c victory            # Victory March sur la party
//gs c rotation           # Exécute la séquence complète BRD
```

## ⚔️ Commandes Spécifiques par Job

Le système détecte votre job actuel et active automatiquement les commandes appropriées.

### THF

```bash
//gs c thfbuff            # Auto-buffs : Feint + Bully + Conspirator
```

### WAR

```bash
//gs c berserk            # Active Berserk (annule Defender)
//gs c defender           # Active Defender (annule Berserk + PDT mode)
//gs c thirdeye           # Active Third Eye
//gs c jump               # Lance Jump sur la cible
```

### BLM

```bash
//gs c buffself           # Stoneskin + Blink + autres buffs défensifs
//gs c mainlight          # Lance sort lumière principal + tier actuel
//gs c maindark           # Lance sort sombre principal + tier actuel
//gs c sublight           # Lance sort lumière secondaire + tier actuel
//gs c subdark            # Lance sort sombre secondaire + tier actuel
//gs c aja                # Lance sort Aja sélectionné
//gs c altlight           # Alt cast sort lumière (limité tier V pour RDM)
//gs c altdark            # Alt cast sort sombre (limité tier V pour RDM)
```

### BST

```bash
//gs c ecosystem          # Cycle ecosystem (Beast, Lizard, Vermin, etc.)
//gs c species            # Cycle species dans l'ecosystem actuel
//gs c call               # Call Beast selon ecosystem/species
//gs c reward             # Reward sur votre pet
//gs c ready              # Ready move sur la cible
//gs c charm              # Charm sur la cible
//gs c sic                # Sic sur la cible
//gs c stay               # Stay pour contrôle pet
//gs c heel               # Heel pour rappel pet
```

### BRD

```bash
//gs c song1              # Lance la song slot 1 configurée
//gs c song2              # Lance la song slot 2 configurée  
//gs c song3              # Lance la song slot 3 configurée
//gs c song4              # Lance la song slot 4 configurée
//gs c song5              # Lance la song slot 5 configurée
//gs c rotation           # Séquence rotation complète

# Songs spécialisées
//gs c lullaby2           # Foe Lullaby II sur la cible
//gs c elegy              # Carnage Elegy sur la cible
//gs c requiem            # Foe Requiem VII sur la cible  
//gs c threnody           # Threnody de l'élément sélectionné
//gs c carol              # Carol de l'élément sélectionné
//gs c etude              # Etude selon le type sélectionné

# Séquences par rôle
//gs c meleesong          # Songs party pour mêlée
//gs c tanksong           # Songs pianissimo pour tank
//gs c healersong         # Songs pianissimo pour healer
//gs c dummy              # Dummy songs pour préparation
//gs c nt                 # Nightingale + Troubadour combo

# Tracking et statut
//gs c setsongs <nom> <nb> # Définit manuellement nb songs sur membre
//gs c checksongs <nom>    # Vérifie songs actives sur membre
//gs c songstatus         # Affiche statut général des songs
```

### DNC

```bash
//gs c steps              # Combo Box Step + Quickstep
//gs c boxstep            # Box Step sur la cible
//gs c quickstep          # Quickstep sur la cible
//gs c featherstep        # Feather Step sur la cible
//gs c stutter            # Stutter Step sur la cible

# Flourishes
//gs c violent            # Violent Flourish sur la cible
//gs c desperate          # Desperate Flourish sur la cible  
//gs c reverse            # Reverse Flourish pour TP

# Waltz et soins
//gs c waltz              # Curing Waltz III sur soi
//gs c waltz party        # Divine Waltz sur la party
//gs c divine             # Divine Waltz sur la party
//gs c samba              # Haste Samba
```

## 🔧 Commandes Techniques

### Diagnostic et Maintenance

```bash
//gs c status             # Statut complet du système
//gs c debug              # Toggle mode debug (verbose)
//gs c version            # Informations de version détaillées
//gs c dependencies       # Vérifie le statut des modules
```

### Cache et Optimisation

```bash
//gs c clear_cache        # Vide tous les caches système
//gs c cache_stats        # Affiche les statistiques du cache
//gs c modules            # Statut et gestion des modules
//gs c modules stats      # Statistiques détaillées des modules
//gs c modules cleanup    # Nettoyage modules non utilisés
```

### Interface et Position

```bash
//gs c ui                 # Toggle visibilité UI keybinds
//gs c uisave             # Sauvegarde position actuelle UI
//gs c ui_update_silent   # Mise à jour silencieuse UI
```

### Commandes Alt Avancées

```bash
//gs c altentrust         # Entrust Indi actuel vers personnage principal
//gs c altnuke            # Nuke élémentaire avec alt character
//gs c cycle altPlayerTier # Cycle tiers sorts alt (IV, V, VI)
//gs c cycle altPlayerLight # Cycle éléments lumière alt
//gs c cycle altPlayerDark  # Cycle éléments sombre alt
```

## 💡 Conseils pour Débutants

### Premier Démarrage

1. **Commencez par** `//gs c help` pour voir le menu principal
2. **Vérifiez votre équipement** avec `//gs c checksets`
3. **Configurez votre alt** avec `//gs c setjob <JOB>`
4. **Explorez les keybinds** avec `//gs c binds`

### Dual-Boxing Facile

1. **Une fois l'alt configuré**, utilisez `//gs c dual` pour voir toutes les commandes
2. **Les commandes s'adaptent** : pas besoin de mémoriser, le système vous guide
3. **Feedback automatique** : chaque commande vous informe du résultat

### Résolution de Problèmes

- **Objets non détectés ?** → `//gs c clear_cache`
- **Commandes qui ne marchent pas ?** → `//gs c status`  
- **Performances lentes ?** → `//gs c perf start` puis `//gs c perf report`

## 🎲 Exemples Pratiques

### Configuration Dual-Box Typique

```bash
# Configurer alt GEO
//gs c setjob GEO

# Vérifier la configuration  
//gs c dual

# Lancer des buffs
//gs c altindi            # Indi-Haste sur vous
//gs c altgeo             # Geo-Malaise sur la cible
```

### Session de Farm Optimisée

```bash
# Monitoring performance
//gs c perf start

# Auto-buffs job principal
//gs c thfbuff

# Buffs alt si RDM configuré
//gs c bufftank

# À la fin, voir les performances
//gs c perf report
```

Le système est conçu pour être **intuitif** : les commandes apparaissent et disparaissent selon votre configuration, vous guidant naturellement vers ce qui est possible.
