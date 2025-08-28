# Performance Guide

## 📊 Performance Monitoring

### Monitoring Commands

```bash
//gs c perf start           # Start monitoring
//gs c perf stop            # Stop monitoring
//gs c perf report          # Display report
```

### Important Metrics

- **Memory usage** : <100MB normal
- **Equipment changes** : <100ms per change
- **Dual-boxing commands** : <200ms latency

## 🚀 Practical Optimizations

### Reduce Equipment Lag

```lua
-- Avoid repeated equipment changes
local last_gear_set = {}

function optimized_equip(new_set)
    local changes = {}
    for slot, item in pairs(new_set) do
        if last_gear_set[slot] ~= item then
            changes[slot] = item
        end
    end
    
    if next(changes) then
        equip(changes)
        last_gear_set = new_set
    end
end
```

### Optimiser Dual-Boxing

```lua
-- Grouper commandes alt pour réduire latence
local command_queue = {}

function queue_alt_command(command)
    table.insert(command_queue, command)
    
    if #command_queue >= 3 then  -- Envoyer par lots de 3
        local combined = table.concat(command_queue, "; ")
        windower.send_command('send Alt ' .. combined)
        command_queue = {}
    end
end
```

## 🐛 Problèmes Courants

### Mémoire Élevée

**Symptômes** : Jeu qui ralentit, freezes
**Solutions** :

1. Redémarrer GearSwap : `//lua r gearswap`
2. Vider cache : `//gs c cache clear`
3. Réduire jobs chargés simultanément

### Équipement Lent

**Symptômes** : Changements équipement visibles/lents
**Solutions** :

1. Vérifier sets équipement : `//gs c checksets`
2. Réduire priorités équipement inutiles
3. Éviter changements fréquents en combat

### UI Qui Freeze

**Symptômes** : Interface ne se met pas à jour
**Solutions** :

1. Toggle UI : `//gs c ui`
2. Sauvegarder position : `//gs c uisave`
3. Redémarrer si nécessaire

### Dual-Boxing Lent

**Symptômes** : Commandes alt retardées
**Solutions** :

1. Vérifier connexion réseau
2. Réduire fréquence commandes
3. Utiliser connexion filaire si possible

## ⚙️ Configuration Performance

### Settings Optimaux

```lua
-- Dans config/settings.lua
settings.performance = {
    enabled = true,                    -- Monitoring performance
    ui_update_frequency = 1000,       -- UI mise à jour toutes les 1s
    cache_equipment = true,           -- Cache équipement
    batch_commands = true             -- Grouper commandes alt
}
```

### Matériel Recommandé

**Minimum** :

- 8GB RAM
- SSD pour FFXI
- Connexion stable

**Optimal** :

- 16GB RAM
- SSD NVMe
- Connexion filaire
- CPU récent (i5/Ryzen 5+)

## 🔧 Maintenance

### Nettoyage Régulier

```bash
//gs c cache clear          # Vider cache
//gs c perf clear           # Reset métriques
//lua r gearswap           # Redémarrage complet
```

### Vérifications Périodiques

1. **Hebdomadaire** : Vérifier métriques performance
2. **Mensuel** : Nettoyer cache et redémarrer
3. **Après mises à jour** : Tester fonctionnalités

Le système est conçu pour être performant par défaut. Ces optimisations ne sont nécessaires que si vous rencontrez des problèmes spécifiques.
