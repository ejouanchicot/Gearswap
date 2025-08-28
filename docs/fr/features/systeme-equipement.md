# Système de Gestion d'Équipement

## 🎯 Principe

Validation automatique de l'équipement avec scan complet de tous vos contenants (inventaire, wardrobes, slips moogle) pour identifier les pièces manquantes.

## 🔍 Commande Principale

```bash
//gs c checksets          # Valider tous vos sets et montrer objets manquants
```

## 🛠️ Création d'Équipement

### Equipment Factory

Le système utilise une factory centralisée pour créer les objets d'équipement :

```lua
local factory = require('utils/EQUIPMENT_FACTORY')

-- Équipement simple
local armor = factory.create('Valor Surcoat')

-- Avec priorité (0-15)
local weapon = factory.create('Excalibur', 10)

-- Avec sac spécifique
local ring = factory.create('Stikini Ring +1', nil, 'wardrobe')

-- Avec augments
local cape = factory.create(
    'Intarabus\'s Cape',
    5,
    'inventory',
    {'DEX+20', 'Accuracy+20 Attack+20', '"Store TP"+10'}
)
```

## 🗂️ Contenants Supportés

### Scan Complet

- **Inventaire** : inventory
- **Wardrobes** : wardrobe1 à wardrobe8
- **Stockage** : safe, safe2, storage, locker
- **Slips Moogle** : porter moogle slip 01-28

### Abréviations FFXI

Le système reconnaît les abréviations courantes :

- `Chev.` → `Chevalier's`
- `Assim.` → `Assimilator's`
- `Crep.` → `Crepuscular`

## 📊 Validation des Sets

### Processus

1. **Analyse des Sets** : Examine tous vos sets d'équipement
2. **Scan Complet** : Vérifie tous contenants et slips
3. **Détection Manquants** : Identifie pièces indisponibles
4. **Rapport Détaillé** : Affiche résultats avec recommandations

### Exemple Set

```lua
sets.engaged.Normal = {
    head = factory.create('Adhemar Bonnet +1', 10, 'inventory'),
    body = factory.create('Abnoba Kaftan', 8),
    hands = factory.create('Adhemar Wrist. +1', 10),
    legs = factory.create('Samnuha Tights', 6),
    feet = factory.create('Plun. Poulaines +3', 12, 'wardrobe')
}
```

## 🔧 Fonctionnement

1. **Chargement Job** : Validation automatique au démarrage
2. **Changement Set** : Vérification lors des swaps
3. **Test Manuel** : Via `//gs c checksets`
4. **Cache Intelligent** : Optimisation des performances

## 🛠️ Dépannage

- **Objets non trouvés** → Vérifiez orthographe exacte et emplacement
- **Erreurs augments** → Format correct : `'DEX+20'`, `'"Store TP"+10'`
- **Performance lente** → Utilisez le cache, évitez scans répétés
- **Slips moogle** → Vérifiez contenu avec `/items slips`

## 💡 Bonnes Pratiques

### Priorités Équipement

- **15** : Armes principales et pièces uniques
- **10** : Accessoires critiques
- **5** : Pièces importantes
- **1** : Équipement situationnel

### Format Augments

```lua
-- ✅ Correct
augments = {'DEX+20', 'Accuracy+20 Attack+20', '"Store TP"+10'}

-- ❌ Incorrect
augments = {'DEX +20', 'Acc+20 Att+20', 'Store TP+10'}
```

Le système assure un équipement fiable et validé avec feedback détaillé pour optimiser vos performances en jeu.
