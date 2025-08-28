# Equipment Management System

## 🎯 Concept

Automatic equipment validation with complete scan of all your containers (inventory, wardrobes, moogle slips) to identify missing pieces.

## 🔍 Main Command

```bash
//gs c checksets          # Validate all your sets and show missing items
```

## 🛠️ Equipment Creation

### Equipment Factory

The system uses a centralized factory to create equipment objects:

```lua
local factory = require('utils/EQUIPMENT_FACTORY')

-- Simple equipment
local armor = factory.create('Valor Surcoat')

-- With priority (0-15)
local weapon = factory.create('Excalibur', 10)

-- With specific bag
local ring = factory.create('Stikini Ring +1', nil, 'wardrobe')

-- With augments
local cape = factory.create(
    'Intarabus\'s Cape',
    5,
    'inventory',
    {'DEX+20', 'Accuracy+20 Attack+20', '"Store TP"+10'}
)
```

## 🗂️ Supported Containers

### Complete Scan

- **Inventory** : inventory
- **Wardrobes** : wardrobe1 to wardrobe8
- **Storage** : safe, safe2, storage, locker
- **Moogle Slips** : porter moogle slip 01-28

### FFXI Abbreviations

The system recognizes common abbreviations:

- `Chev.` → `Chevalier's`
- `Assim.` → `Assimilator's`
- `Crep.` → `Crepuscular`

## 📊 Set Validation

### Process

1. **Set Analysis** : Examines all your equipment sets
2. **Complete Scan** : Checks all containers and slips
3. **Missing Detection** : Identifies unavailable pieces
4. **Detailed Report** : Displays results with recommendations

### Set Example

```lua
sets.engaged.Normal = {
    head = factory.create('Adhemar Bonnet +1', 10, 'inventory'),
    body = factory.create('Abnoba Kaftan', 8),
    hands = factory.create('Adhemar Wrist. +1', 10),
    legs = factory.create('Samnuha Tights', 6),
    feet = factory.create('Plun. Poulaines +3', 12, 'wardrobe')
}
```

## 🔧 How It Works

1. **Job Loading** : Automatic validation at startup
2. **Set Changes** : Verification during swaps
3. **Manual Test** : Via `//gs c checksets`
4. **Smart Cache** : Performance optimization

## 🛠️ Troubleshooting

- **Items not found** → Check exact spelling and location
- **Augment errors** → Correct format: `'DEX+20'`, `'"Store TP"+10'`
- **Slow performance** → Use cache, avoid repeated scans
- **Moogle slips** → Check contents with `/items slips`

## 💡 Best Practices

### Equipment Priorities

- **15** : Main weapons and unique pieces
- **10** : Critical accessories
- **5** : Important pieces
- **1** : Situational equipment

### Augment Format

```lua
-- ✅ Correct
augments = {'DEX+20', 'Accuracy+20 Attack+20', '"Store TP"+10'}

-- ❌ Incorrect
augments = {'DEX +20', 'Acc+20 Att+20', 'Store TP+10'}
```

The system ensures reliable and validated equipment with detailed feedback to optimize your in-game performance.
