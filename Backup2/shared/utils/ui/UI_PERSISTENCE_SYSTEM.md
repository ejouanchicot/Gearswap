# UI Persistence System - Documentation

## Architecture Moderne (2025-11-08)

### Fichiers du Système

```
shared/
├── config/
│   └── ui_settings.lua           # Manager de persistence (global)
└── utils/
    ├── config/
    │   └── config_loader.lua     # Charge UI_CONFIG et crée _G.ui_display_config
    └── ui/
        ├── UI_MANAGER.lua        # Gestion de l'UI (display, toggle, save)
        └── UI_SETTINGS.lua       # Bridge entre UI_MANAGER et ui_settings.lua

[Personnage]/
└── config/
    ├── ui_settings.lua           # Settings persistants (auto-généré)
    └── UI_CONFIG.lua             # Configuration statique (presets, fonts, etc.)
```

### Fichiers par Personnage

Chaque personnage a son propre fichier de settings persistants :

- `Kaories/config/ui_settings.lua`
- `Tetsouo/config/ui_settings.lua`
- `Morphetrix/config/ui_settings.lua`
- etc.

### Workflow de Persistence

#### 1. **Chargement** (au démarrage de GearSwap)

```lua
-- Dans TETSOUO_BLM.lua (ou autre job)
local ConfigLoader = require('shared/utils/config/config_loader')
local UIConfig = ConfigLoader.load_ui_config('Tetsouo', 'BLM')

-- ConfigLoader fait :
-- 1. Charge UI_CONFIG.lua (presets, fonts, init_delay)
-- 2. Lit ui_settings.lua (position, enabled, show_header, etc.)
-- 3. Crée _G.ui_display_config depuis ui_settings.lua
```

#### 2. **Modification** (quand user fait //gs c ui, //gs c uitoggle, etc.)

```lua
-- Dans UI_MANAGER.lua
function KeybindUI.toggle()
    _G.keybind_ui_visible = not _G.keybind_ui_visible

    -- Sauvegarde immédiate
    if _G.keybind_saved_settings then
        _G.keybind_saved_settings.enabled = _G.keybind_ui_visible
        KeybindSettings.save(_G.keybind_saved_settings)  -- → UISettingsManager.set_enabled()
    end
end
```

#### 3. **Sauvegarde** (automatique à chaque changement)

```lua
-- UI_SETTINGS.lua → shared/config/ui_settings.lua
UISettingsManager.set_enabled(false)
  ↓
_G.UI_SETTINGS.enabled = false
  ↓
save_to_file(_G.UI_SETTINGS)
  ↓
Écrit dans Kaories/config/ui_settings.lua
```

#### 4. **Reload** (//lua reload gearswap)

```lua
-- ConfigLoader.load_ui_config() recharge :
local UISettingsManager = require('shared/config/ui_settings')
_G.ui_display_config = {
    enabled = UISettingsManager.get_enabled()  -- Lit depuis ui_settings.lua
}

-- KeybindUI.init() vérifie :
if not _G.ui_display_config.enabled then
    return  -- N'affiche pas l'UI
end
```

### Settings Persistants

Tous ces settings sont sauvés dans `[Personnage]/config/ui_settings.lua` :

- **Position** : `pos_x`, `pos_y`
- **Visibilité** : `enabled`, `show_header`, `show_legend`, `show_column_headers`, `show_footer`
- **Background** : `bg_r`, `bg_g`, `bg_b`, `bg_a`, `bg_visible`
- **Font** : `font_size`, `font_name`
- **Sections** : `section_spells`, `section_enhancing`, `section_job_abilities`, `section_weapons`, `section_modes`

### Commandes UI

Toutes ces commandes sauvent automatiquement :

- `//gs c ui` - Toggle UI on/off (save `enabled`)
- `//gs c ui s` ou `//gs c ui save` - Save position (save `pos_x`, `pos_y`)
- `//gs c ui h` ou `//gs c ui header` - Toggle header (save `show_header`)
- `//gs c ui l` ou `//gs c ui legend` - Toggle legend (save `show_legend`)
- `//gs c ui c` ou `//gs c ui columns` - Toggle column headers (save `show_column_headers`)
- `//gs c ui f` ou `//gs c ui footer` - Toggle footer (save `show_footer`)
- `//gs c ui on` ou `//gs c ui enable` - Enable UI (save `enabled = true`)
- `//gs c ui off` ou `//gs c ui disable` - Disable UI (save `enabled = false`)
- `//gs c ui bg [preset]` - Change background preset (save `bg_r/g/b/a`)
- `//gs c ui bg [r] [g] [b] [a]` - Custom RGBA (save `bg_r/g/b/a`)
- `//gs c ui bg toggle` - Toggle background visibility (save `bg_visible`)
- `//gs c ui bg list` - List available presets
- `//gs c ui font [name]` - Change font (save `font_name`)
- `//gs c ui help` ou `//gs c ui ?` - Show help

### Migration de l'Ancien Système

#### ❌ **Supprimé**
- `shared/config/ui_settings_[CharName].lua` (ancien emplacement)
- Système regex de sauvegarde dans UI_CONFIG.lua
- ui_position.lua (obsolète)

#### ✅ **Conservé**
- `[CharName]/config/UI_CONFIG.lua` (presets, fonts, init_delay)
- Structure de configuration existante

### Différence UI_CONFIG vs ui_settings

| Fichier | Rôle | Modifié par |
|---------|------|-------------|
| `UI_CONFIG.lua` | Configuration **statique** (presets, fonts, delays) | **Utilisateur manuellement** |
| `ui_settings.lua` | Settings **dynamiques** (position, enabled, toggles) | **Auto-généré par système** |

### Debugging

```lua
-- Voir les settings chargés
//lua print(_G.UI_SETTINGS.enabled)
//lua print(_G.ui_display_config.enabled)

-- Forcer reload des settings
//lua package.loaded['shared/config/ui_settings'] = nil
//lua require('shared/config/ui_settings')

-- Vérifier le fichier de settings
-- Windows: D:\Windower Tetsouo\addons\GearSwap\data\Kaories\config\ui_settings.lua
```

### Notes Importantes

1. **Un fichier par perso** : Chaque personnage a ses propres settings dans son dossier
2. **Sauvegarde immédiate** : Chaque toggle/changement sauve instantanément
3. **Global variables** : `_G.UI_SETTINGS` persiste dans la session, fichier persiste entre sessions
4. **dofile() requis** : Utiliser `dofile()` et non `loadfile()` dans GearSwap
5. **Config_loader centralise** : Un seul point d'initialisation de `_G.ui_display_config`

### Exemple de Fichier Généré

```lua
-- UI Settings (auto-generated)
-- Character: Kaories
-- File: D:/Windower Tetsouo/addons/GearSwap/data/Kaories/config/ui_settings.lua
return {
    -- Position
    pos_x = 1600,
    pos_y = 300,

    -- Visibility
    enabled = false,  -- ← Persisté quand on fait //gs c ui
    show_header = false,
    show_legend = true,
    show_column_headers = false,
    show_footer = false,

    -- Background
    bg_r = 15,
    bg_g = 15,
    bg_b = 35,
    bg_a = 180,
    bg_visible = true,

    -- Font
    font_size = 10,
    font_name = "Consolas",

    -- Sections
    section_spells = true,
    section_enhancing = true,
    section_job_abilities = true,
    section_weapons = true,
    section_modes = true
}
```

## Chronologie des Changements

### 2025-11-08 - Migration Complète
- ✅ Création de `shared/config/ui_settings.lua` (manager)
- ✅ Modification de `config_loader.lua` pour lire depuis `UISettingsManager`
- ✅ Path changé vers `[CharName]/config/ui_settings.lua`
- ✅ Suppression de `shared/config/ui_settings_*.lua`
- ✅ Nettoyage du système regex obsolète
- ✅ Tous les toggles sauvent immédiatement

### Avant 2025-11-08 - Ancien Système
- ❌ Sauvegarde via regex dans UI_CONFIG.lua (fragile)
- ❌ Pas de persistence entre reloads
- ❌ Settings mixés avec config statique
