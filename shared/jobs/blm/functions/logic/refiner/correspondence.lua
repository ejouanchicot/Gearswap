---  ═══════════════════════════════════════════════════════════════════════════
---   Spell Correspondence - Tier downgrade lookup table
---  ═══════════════════════════════════════════════════════════════════════════
---   Maps each spell tier to its lower replacement tier for automatic
---   downgrade when the higher tier is on cooldown or unavailable.
---
---   Format: SPELL_CORRESPONDENCE[category][tier].replace = next_lower_tier
---   Special value: replace = '' means "base tier" (no roman numeral).
---
---   Example:
---     Fire family: VI -> V -> IV -> III -> II -> I (no numeral)
---     Firaga family: III -> II -> I (no numeral)
---
---   @file    jobs/blm/functions/logic/refiner/correspondence.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-09 (extracted from spell_refiner.lua)
---  ═══════════════════════════════════════════════════════════════════════════

local Correspondence = {}

--- Spell tier correspondence for downgrading.
--- @type table<string, table<string, table>>
Correspondence.SPELL_CORRESPONDENCE = {
    -- Fire spells (VI >> V >> IV >> III >> II >> I)
    Fire = {
        ['VI']  = { replace = 'V'  },
        ['V']   = { replace = 'IV' },
        ['IV']  = { replace = 'III'},
        ['III'] = { replace = 'II' },
        ['II']  = { replace = 'I'  },
        ['I']   = { replace = ''   } -- Base tier (no numeral)
    },
    Blizzard = {
        ['VI']  = { replace = 'V'  },
        ['V']   = { replace = 'IV' },
        ['IV']  = { replace = 'III'},
        ['III'] = { replace = 'II' },
        ['II']  = { replace = 'I'  },
        ['I']   = { replace = ''   }
    },
    Aero = {
        ['VI']  = { replace = 'V'  },
        ['V']   = { replace = 'IV' },
        ['IV']  = { replace = 'III'},
        ['III'] = { replace = 'II' },
        ['II']  = { replace = 'I'  },
        ['I']   = { replace = ''   }
    },
    Stone = {
        ['VI']  = { replace = 'V'  },
        ['V']   = { replace = 'IV' },
        ['IV']  = { replace = 'III'},
        ['III'] = { replace = 'II' },
        ['II']  = { replace = 'I'  },
        ['I']   = { replace = ''   }
    },
    Thunder = {
        ['VI']  = { replace = 'V'  },
        ['V']   = { replace = 'IV' },
        ['IV']  = { replace = 'III'},
        ['III'] = { replace = 'II' },
        ['II']  = { replace = 'I'  },
        ['I']   = { replace = ''   }
    },
    Water = {
        ['VI']  = { replace = 'V'  },
        ['V']   = { replace = 'IV' },
        ['IV']  = { replace = 'III'},
        ['III'] = { replace = 'II' },
        ['II']  = { replace = 'I'  },
        ['I']   = { replace = ''   }
    },
    -- AOE -ga spells (III >> II >> I)
    Firaga    = { ['III'] = { replace = 'II' }, ['II'] = { replace = 'I' }, ['I'] = { replace = '' } },
    Blizzaga  = { ['III'] = { replace = 'II' }, ['II'] = { replace = 'I' }, ['I'] = { replace = '' } },
    Aeroga    = { ['III'] = { replace = 'II' }, ['II'] = { replace = 'I' }, ['I'] = { replace = '' } },
    Stonega   = { ['III'] = { replace = 'II' }, ['II'] = { replace = 'I' }, ['I'] = { replace = '' } },
    Thundaga  = { ['III'] = { replace = 'II' }, ['II'] = { replace = 'I' }, ['I'] = { replace = '' } },
    Waterga   = { ['III'] = { replace = 'II' }, ['II'] = { replace = 'I' }, ['I'] = { replace = '' } },
    -- Sleep / Sleepga
    Sleep   = { ['III'] = { replace = 'II' }, ['II'] = { replace = 'I' }, ['I'] = { replace = '' } },
    Sleepga = { ['II']  = { replace = 'I'  }, ['I']  = { replace = ''  } },
    -- Break (Breakga >> Break handled specially in special_handlers)
    Break = { ['I'] = { replace = '' } },
    -- Bind
    Bind  = { ['II'] = { replace = 'I' }, ['I'] = { replace = '' } },
    -- Bio / Poison
    Bio = {
        ['V']   = { replace = 'IV' },
        ['IV']  = { replace = 'III'},
        ['III'] = { replace = 'II' },
        ['II']  = { replace = 'I'  },
        ['I']   = { replace = ''   }
    },
    Poison = {
        ['V']   = { replace = 'IV' },
        ['IV']  = { replace = 'III'},
        ['III'] = { replace = 'II' },
        ['II']  = { replace = 'I'  },
        ['I']   = { replace = ''   }
    },
    -- Drain / Aspir
    Drain = { ['III'] = { replace = 'II' }, ['II'] = { replace = 'I' }, ['I'] = { replace = '' } },
    Aspir = { ['III'] = { replace = 'II' }, ['II'] = { replace = 'I' }, ['I'] = { replace = '' } },
    -- Elemental enfeebles (single tier each)
    Burn  = { ['I'] = { replace = '' } },
    Frost = { ['I'] = { replace = '' } },
    Choke = { ['I'] = { replace = '' } },
    Rasp  = { ['I'] = { replace = '' } },
    Shock = { ['I'] = { replace = '' } },
    Drown = { ['I'] = { replace = '' } },
}

--- Get the correspondence table for a spell category.
--- @param category string Spell category (e.g. 'Fire', 'Stone', 'Firaga')
--- @return table|nil The tier mapping, or nil if no correspondence exists
function Correspondence.get(category)
    return Correspondence.SPELL_CORRESPONDENCE[category]
end

return Correspondence
