# Guide de Configuration GearSwap

## 📝 Configuration Essentielle

**Principe** : Un seul fichier `Tetsouo/config/settings.lua` à modifier, puis `//gs reload`.

### Personnages

```lua
settings.players = {
    main = 'Tetsouo',     -- Votre personnage principal
    alt_enabled = true,   -- true = dual-box, false = solo uniquement
    alt = 'Kaories',      -- Votre personnage alt
}
```

### Lockstyles

```lua
settings.macros.lockstyles = {
    THF = 1, -- 🗡️ Thief
    DNC = 2, -- 💃 Dancer  
    PLD = 3, -- 🛡️ Paladin
    WAR = 4, -- ⚔️ Warrior
    BLM = 5, -- 🔮 Black Mage
    BST = 6, -- 🐺 Beast Master
    BRD = 7, -- 🎵 Bard
}
```

### Macros Dual-Boxing

```lua
settings.macros.dual_box = {
    THF = {
        WAR = {                           -- THF/WAR subjob
            RDM = { book = 1, page = 1 }, -- + Alt RDM
            GEO = { book = 2, page = 1 }, -- + Alt GEO
            COR = { book = 3, page = 1 }, -- + Alt COR
        },
        DNC = {                           -- THF/DNC subjob
            RDM = { book = 1, page = 1 },
            GEO = { book = 2, page = 1 },
            COR = { book = 3, page = 1 },
        }
    },
    BLM = {
        SCH = {                           -- BLM/SCH subjob
            RDM = { book = 7, page = 1 },
            GEO = { book = 8, page = 1 },
            COR = { book = 9, page = 1 },
        }
    }
    -- ... Plus de jobs dans le fichier complet
}
```

### Macros Solo

```lua
settings.macros.solo = {
    THF = {
        WAR = { book = 1, page = 1 }, -- THF/WAR solo
        DNC = { book = 1, page = 1 }, -- THF/DNC solo
        NIN = { book = 1, page = 1 }, -- THF/NIN solo
    },
    BLM = {
        RDM = { book = 10, page = 1 }, -- BLM/RDM solo
        SCH = { book = 7, page = 1 },  -- BLM/SCH solo
    }
    -- ... Plus de jobs dans le fichier complet
}
```

## 🎨 Personnalisation Avancée

### Interface et Couleurs

```lua
settings.ui = {
    colors = {
        error = 167,   -- 🔴 Rouge - Erreurs
        warning = 057, -- 🟠 Orange - Avertissements  
        info = 050,    -- 🟡 Jaune - Information
        debug = 160,   -- ⚫ Gris - Debug
        success = 158, -- 🟢 Vert - Succès
    },
    messages = {
        show_timestamps = false,
        show_separators = true,
    }
}
```

### Debug et Diagnostics

```lua
settings.debug = {
    enabled = false,       -- Mode debug
    level = 'INFO',        -- ERROR/WARN/INFO/DEBUG
    show_swaps = true,     -- Voir changements équipement
    show_cooldowns = true, -- Voir cooldowns sorts
}
```

### Mouvement et Combat

```lua
settings.movement = {
    threshold = 1.0,        -- Seuil détection mouvement
    check_interval = 15,    -- Fréquence vérification
    engaged_moving = false, -- Équipement mouvement en combat
}

settings.combat = {
    auto_cancel = {
        retaliation_on_move = true, -- Annuler Retaliation si mouvement
        cancel_conflicts = true,    -- Annuler buffs conflictuels
    },
    weaponskill = {
        auto_adjust_ears = true,    -- Ajuster boucles selon TP
        moonshade_threshold = 1750, -- Seuil TP pour Moonshade
        range_check = true,         -- Vérifier portée WS
    }
}
```

### Configuration par Job

```lua
settings.jobs = {
    THF = {
        default_th_mode = 'Tag',           -- Mode TH par défaut
        maintain_sa_ta_idle = true,        -- Garder équipement SA/TA idle
        auto_sa_ta_combat = true,          -- Auto SA/TA combat
        prefer_specialized_th_sets = true, -- Sets TH spécialisés
    },
    BLM = {
        default_mode = 'MagicBurst',       -- Mode par défaut
        auto_buffs = { 'Stoneskin', 'Blink', 'Aquaveil', 'Ice Spikes' },
        save_mp_threshold = 100,           -- Seuil conservation MP
    },
    WAR = {
        default_weapon = 'Chango',         -- Arme par défaut
        auto_restraint = true,             -- Auto restraint
        auto_cancel_retaliation = true,    -- Annuler Retaliation mouvement
    },
    BST = {
        default_jug = 'Dire Broth',       -- Jug pet par défaut
        auto_reward_hp = 50,               -- Seuil HP auto Reward
    }
}
```

### Automation

```lua
settings.automation = {
    buffs = {
        refresh_threshold = 30, -- Temps min avant refresh (sec)
        cast_delay = 2,         -- Délai entre sorts (sec)
    },
    spells = {
        auto_downgrade = true,  -- Auto downgrade si tier supérieur CD
        cancel_on_no_mp = true, -- Annuler si pas assez MP
    }
}
```

## 🛠️ Dépannage

- **Macros ne changent pas** → Orthographe noms + `//gs c status`  
- **Alt pas détecté** → `alt_enabled = true` + orthographe exacte
- **Erreurs syntaxe** → Virgules, crochets dans settings.lua
- **Debug temporaire** → `settings.debug.enabled = true` + `//gs reload`

Le fichier settings.lua contient **toute** la configuration centralisée du système.
