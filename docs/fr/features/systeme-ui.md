# Système Interface Utilisateur

## 🎯 Principe

Interface visuelle temps réel affichant les états GearSwap avec keybinds organisés par job, couleurs dynamiques et positionnement sauvegardé.

## 🎮 Commande Principale

```bash
//gs c ui                 # Toggle visibilité UI
//gs c uisave             # Sauvegarder position manuellement
```

## 🎨 Système Couleurs

### Couleurs Élémentaires

- **Fire** → Rouge brillant
- **Ice** → Bleu clair
- **Wind** → Vert clair
- **Earth** → Marron
- **Lightning** → Violet-rose
- **Water** → Bleu
- **Light** → Blanc
- **Dark** → Violet foncé

### Couleurs Stats

- **STR** → Rouge
- **DEX** → Violet-rose
- **VIT** → Marron
- **AGI** → Vert
- **INT** → Violet
- **MND** → Bleu clair
- **CHR** → Blanc

### Indicateurs Statut

- **Actif** → Vert brillant
- **Inactif** → Rouge brillant
- **Inconnu** → Jaune

## 🗂️ Jobs Supportés

### Layouts Exemple

#### BRD (Barde)

```text
Key    Fonction         Actuel
1      BRD Rotation     Honor March
2      Victory March    Victory March
3      Type Etude       STR
4      Élément Carol    Fire
5      Élément Threnody Ice
       Slot 1           Honor March
       Slot 2           Victory March
       Slot 3           Minuet V
```

#### BLM (Mage Noir)

```text
── Sorts ──
Key    Fonction         Actuel
F1     Main Light       Fire
F2     Main Dark        Drain
F3     Sub Light        Thunder
F5     Sort Aja         Firaja
F6     Tier Sort        III

── Modes ──
F9     Mode Casting     MagicBurst
```

#### THF (Voleur)

```text
Key    Fonction         Actuel
F1     Arme Principale  Twashtar
F2     Arme Sub         Taming Sari
F3     Abyssea Proc     false
F5     Mode Hybride     Normal
F6     Mode Treasure    Tag
```

## 🔧 Fonctionnalités

### Auto-Positionnement

- **Interface Draggable** : Clic-glisser pour repositionner
- **Sauvegarde Auto** : Position sauvée automatiquement
- **Restauration** : Position restaurée au reload/changement zone

### Organisation Intelligente

#### Jobs Magiques (BLM, GEO, RDM)

- **Section Sorts** : Magie élémentaire, tiers, spéciaux
- **Section Colure** : (GEO) Sorts Geo/Indi
- **Section Armes** : Principal/Sub
- **Section Modes** : Combat, casting

#### Jobs Mêlée (THF, WAR, DNC)

- **Section Armes** : Sets d'armes multiples
- **Section Abilities** : (DNC) Steps spécialisées
- **Section Modes** : Hybride, treasure, combat

#### Jobs Support (BRD, BST)

- **Songs/Pet** : Mécaniques principales
- **Slots Temps Réel** : (BRD) Tracking songs actifs
- **Section Armes** : Standard
- **Section Modes** : Support spécifique

### Affichage Dynamique

```lua
-- Exemple couleur élémentaire
local element_colors = {
    Fire = "\\cs(255,100,100)",      -- Rouge brillant
    Ice = "\\cs(150,200,255)",       -- Bleu clair
    Wind = "\\cs(150,255,150)",      -- Vert clair
}

-- Gestion tier spéciale
if state_name == "TierSpell" and result == "" then
    result = "I"  -- Afficher Tier I au lieu de vide
end
```

## 🚀 Configuration

### Structure Settings

```lua
local ui_settings = {
    pos = { 
        x = saved_settings.pos.x,
        y = saved_settings.pos.y 
    },
    text = { 
        size = 12,
        font = 'Consolas',
        stroke = { width = 2, alpha = 255, red = 0, green = 0, blue = 0 }
    },
    bg = { 
        alpha = 200,
        red = 10, green = 10, blue = 25,
        visible = true 
    },
    flags = { 
        draggable = true,
        bold = true
    }
}
```

### Auto-Sauvegarde

```lua
-- Position sauvegardée quand UI déplacée
function save_position(x, y)
    saved_settings.pos.x = x
    saved_settings.pos.y = y
    KeybindSettings.save(saved_settings)
end
```

## 🔄 Intégration Système

### Gestion États

```lua
-- UI se met à jour automatiquement
function update_display()
    for _, keybind in ipairs(current_job_keybinds) do
        local current_value = get_state_value(keybind.state, keybind.key)
        local color = get_value_color(current_value, keybind.description)
    end
end
```

### Détection Job

```lua
function get_current_job_keybinds()
    local job = player and player.main_job or "UNK"
    
    if job == "BLM" then
        return blm_keybind_layout
    elseif job == "GEO" then  
        return geo_keybind_layout
    end
end
```

## 🛠️ Dépannage

### Problèmes Courants

- **UI invisible** → `//gs c ui` pour toggle visibilité
- **Couleurs manquantes** → Vérifiez support couleur Windower
- **Position non sauvée** → `//gs c uisave` pour forcer sauvegarde
- **Performance lente** → Vérifiez fuites mémoire, redémarrez GearSwap

### Debug

```lua
settings.ui = {
    debug_updates = true,
    debug_colors = true,
    debug_positioning = true,
    show_performance_metrics = true
}
```

## 💡 Optimisation

### Performance

- **Rendu Paresseux** : Éléments rendus seulement si visibles
- **Cache Couleurs** : Lookups couleur mis en cache
- **Limitation Mise à Jour** : Vérifications position optimisées
- **Nettoyage Mémoire** : Ressources libérées au changement job

Le système UI fournit une interface intuitive avec feedback visuel temps réel pour tous les jobs, positionnement personnalisable et integration complète avec les systèmes GearSwap.
