---============================================================================
--- RDM Alt Commands - what the alt does when it is on RDM
---============================================================================
--- Read by shared/utils/dualbox/alt_commands.lua when the alt character is on
--- RDM. Type the key on the MAIN (//gs c haste) and the alt performs it.
---
--- Generated from Windower's own res/spells.lua, not written by hand:
---   * only spells RDM can actually cast (levels[5] present)
---   * the highest tier of each family, so the key carries no numeral
---     (//gs c dia fires Dia III)
---   * the target comes from the spell's `targets` bitmask - enemy spells get
---     'lastst', ally spells 'lastst', self-only spells 'me'
---
--- TIER FALLBACK IS AUTOMATIC. Sending the top tier is safe: RDM_PRECAST runs
--- TierRefiner on the ALT side, which walks Dia III -> Dia II -> Dia until it
--- finds one off recast. The main does not know the alt's recasts and does not
--- need to - see shared/data/spells/RDM_ENFEEBLE_TIERS.lua for the families
--- that carry a chain.
---
--- ENTRY FORMAT
---   <name> = {
---       action = 'ma',          -- ma | ja | ws | so | item | pet | ra | raw
---       spell  = 'Haste II',    -- what to use
---       target = 'lastst',      -- 'lastst' = what you subtargeted, 'me' = the alt
---       desc   = 'free text',   -- shown by //gs c altcmds
---   }
---
--- For an ally, select once with `/ta <stpc>` (or bind it in a macro) and every
--- `lastst` command applies to them until you pick someone else.
---
--- @file    config/alt/RDM_ALT_COMMANDS.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2026-08-07 | Updated: 2026-08-08
---============================================================================

local M = {}

M.commands = {
    -- ========================================================================
    -- ENFEEBLING - select the mob first (/ta <stnpc>)
    -- ========================================================================
    addle            = { action = 'ma', spell = 'Addle II',             target = 'lastst', desc = 'Addle II' },
    bind             = { action = 'ma', spell = 'Bind',                 target = 'lastst', desc = 'Bind' },
    bindga           = { action = 'ma', spell = 'Bindga',               target = 'lastst', desc = 'Bindga' },
    blind            = { action = 'ma', spell = 'Blind II',             target = 'lastst', desc = 'Blind II' },
    blindga          = { action = 'ma', spell = 'Blindga',              target = 'lastst', desc = 'Blindga' },
    breakspell       = { action = 'ma', spell = 'Break',                target = 'lastst', desc = 'Break' },
    dia              = { action = 'ma', spell = 'Dia III',              target = 'lastst', desc = 'Dia III' },
    diaga            = { action = 'ma', spell = 'Diaga III',            target = 'lastst', desc = 'Diaga III' },
    altdispel        = { action = 'ma', spell = 'Dispel',               target = 'lastst', desc = 'Dispel' },
    dispelga         = { action = 'ma', spell = 'Dispelga',             target = 'lastst', desc = 'Dispelga' },
    distract         = { action = 'ma', spell = 'Distract III',         target = 'lastst', desc = 'Distract III' },
    frazzle          = { action = 'ma', spell = 'Frazzle III',          target = 'lastst', desc = 'Frazzle III' },
    gravity          = { action = 'ma', spell = 'Gravity II',           target = 'lastst', desc = 'Gravity II' },
    inundation       = { action = 'ma', spell = 'Inundation',           target = 'lastst', desc = 'Inundation' },
    paralyga         = { action = 'ma', spell = 'Paralyga',             target = 'lastst', desc = 'Paralyga' },
    paralyze         = { action = 'ma', spell = 'Paralyze II',          target = 'lastst', desc = 'Paralyze II' },
    poison           = { action = 'ma', spell = 'Poison II',            target = 'lastst', desc = 'Poison II' },
    silence          = { action = 'ma', spell = 'Silence',              target = 'lastst', desc = 'Silence' },
    silencega        = { action = 'ma', spell = 'Silencega',            target = 'lastst', desc = 'Silencega' },
    sleep            = { action = 'ma', spell = 'Sleep II',             target = 'lastst', desc = 'Sleep II' },
    slow             = { action = 'ma', spell = 'Slow II',              target = 'lastst', desc = 'Slow II' },
    slowga           = { action = 'ma', spell = 'Slowga',               target = 'lastst', desc = 'Slowga' },

    -- ========================================================================
    -- ENHANCING - ally spells need /ta <stpc>, self spells go to the alt
    -- ========================================================================
    aquaveil         = { action = 'ma', spell = 'Aquaveil',             target = 'me', desc = 'Aquaveil' },
    baraero          = { action = 'ma', spell = 'Baraero',              target = 'me', desc = 'Baraero' },
    baramnesia       = { action = 'ma', spell = 'Baramnesia',           target = 'me', desc = 'Baramnesia' },
    barblind         = { action = 'ma', spell = 'Barblind',             target = 'me', desc = 'Barblind' },
    barblizzard      = { action = 'ma', spell = 'Barblizzard',          target = 'me', desc = 'Barblizzard' },
    barfire          = { action = 'ma', spell = 'Barfire',              target = 'me', desc = 'Barfire' },
    barparalyze      = { action = 'ma', spell = 'Barparalyze',          target = 'me', desc = 'Barparalyze' },
    barpetrify       = { action = 'ma', spell = 'Barpetrify',           target = 'me', desc = 'Barpetrify' },
    barpoison        = { action = 'ma', spell = 'Barpoison',            target = 'me', desc = 'Barpoison' },
    barsilence       = { action = 'ma', spell = 'Barsilence',           target = 'me', desc = 'Barsilence' },
    barsleep         = { action = 'ma', spell = 'Barsleep',             target = 'me', desc = 'Barsleep' },
    barstone         = { action = 'ma', spell = 'Barstone',             target = 'me', desc = 'Barstone' },
    barthunder       = { action = 'ma', spell = 'Barthunder',           target = 'me', desc = 'Barthunder' },
    barvirus         = { action = 'ma', spell = 'Barvirus',             target = 'me', desc = 'Barvirus' },
    barwater         = { action = 'ma', spell = 'Barwater',             target = 'me', desc = 'Barwater' },
    blazespikes      = { action = 'ma', spell = 'Blaze Spikes',         target = 'me', desc = 'Blaze Spikes' },
    blink            = { action = 'ma', spell = 'Blink',                target = 'me', desc = 'Blink' },
    deodorize        = { action = 'ma', spell = 'Deodorize',            target = 'lastst', desc = 'Deodorize' },
    enaero           = { action = 'ma', spell = 'Enaero II',            target = 'me', desc = 'Enaero II' },
    enblizzard       = { action = 'ma', spell = 'Enblizzard II',        target = 'me', desc = 'Enblizzard II' },
    enfire           = { action = 'ma', spell = 'Enfire II',            target = 'me', desc = 'Enfire II' },
    enstone          = { action = 'ma', spell = 'Enstone II',           target = 'me', desc = 'Enstone II' },
    enthunder        = { action = 'ma', spell = 'Enthunder II',         target = 'me', desc = 'Enthunder II' },
    enwater          = { action = 'ma', spell = 'Enwater II',           target = 'me', desc = 'Enwater II' },
    flurry           = { action = 'ma', spell = 'Flurry II',            target = 'lastst', desc = 'Flurry II' },
    gainagi          = { action = 'ma', spell = 'Gain-AGI',             target = 'me', desc = 'Gain-AGI' },
    gainchr          = { action = 'ma', spell = 'Gain-CHR',             target = 'me', desc = 'Gain-CHR' },
    gaindex          = { action = 'ma', spell = 'Gain-DEX',             target = 'me', desc = 'Gain-DEX' },
    gainint          = { action = 'ma', spell = 'Gain-INT',             target = 'me', desc = 'Gain-INT' },
    gainmnd          = { action = 'ma', spell = 'Gain-MND',             target = 'me', desc = 'Gain-MND' },
    gainstr          = { action = 'ma', spell = 'Gain-STR',             target = 'me', desc = 'Gain-STR' },
    gainvit          = { action = 'ma', spell = 'Gain-VIT',             target = 'me', desc = 'Gain-VIT' },
    haste            = { action = 'ma', spell = 'Haste II',             target = 'lastst', desc = 'Haste II' },
    hastega          = { action = 'ma', spell = 'Hastega',              target = 'me', desc = 'Hastega' },
    icespikes        = { action = 'ma', spell = 'Ice Spikes',           target = 'me', desc = 'Ice Spikes' },
    invisible        = { action = 'ma', spell = 'Invisible',            target = 'lastst', desc = 'Invisible' },
    phalanx          = { action = 'ma', spell = 'Phalanx II',           target = 'lastst', desc = 'Phalanx II' },
    protect          = { action = 'ma', spell = 'Protect V',            target = 'lastst', desc = 'Protect V' },
    refresh          = { action = 'ma', spell = 'Refresh III',          target = 'lastst', desc = 'Refresh III' },
    regen            = { action = 'ma', spell = 'Regen II',             target = 'lastst', desc = 'Regen II' },
    shell            = { action = 'ma', spell = 'Shell V',              target = 'lastst', desc = 'Shell V' },
    shockspikes      = { action = 'ma', spell = 'Shock Spikes',         target = 'me', desc = 'Shock Spikes' },
    altsneak         = { action = 'ma', spell = 'Sneak',                target = 'lastst', desc = 'Sneak' },
    stoneskin        = { action = 'ma', spell = 'Stoneskin',            target = 'me', desc = 'Stoneskin' },
    temper           = { action = 'ma', spell = 'Temper II',            target = 'me', desc = 'Temper II' },

    -- ========================================================================
    -- HEALING - select the ally first (/ta <stpc>)
    -- ========================================================================
    cure             = { action = 'ma', spell = 'Cure IV',              target = 'lastst', desc = 'Cure IV' },
    raise            = { action = 'ma', spell = 'Raise II',             target = 'lastst', desc = 'Raise II' },

    -- ========================================================================
    -- DARK MAGIC - select the mob first (/ta <stnpc>)
    -- ========================================================================
    bio              = { action = 'ma', spell = 'Bio III',              target = 'lastst', desc = 'Bio III' },


    -- ========================================================================
    -- JOB ABILITIES
    -- ========================================================================
    composure    = { action = 'ja', spell = 'Composure',   target = 'me', desc = 'Enhancing duration on others' },
    saboteur     = { action = 'ja', spell = 'Saboteur',    target = 'me', desc = 'Next enfeeble potency+' },
    convert      = { action = 'ja', spell = 'Convert',     target = 'me', desc = 'Swap HP and MP' },

    -- ========================================================================
    -- NUKES THAT FOLLOW THE MAIN'S BLM ELEMENT
    -- ========================================================================
    -- Mirrors state.MainLightSpell / MainDarkSpell while the main is BLM, so
    -- the alt nukes the element you have selected. On any other main job the
    -- state does not exist and `fallback` is used.
    altlight  = {
        action = 'ma',
        spell_from_state = 'MainLightSpell',
        fallback = 'Fire III',
        target = 'lastst',
        desc = 'Nuke, follows the main light element',
    },
    altdark   = {
        action = 'ma',
        spell_from_state = 'MainDarkSpell',
        fallback = 'Blizzard III',
        target = 'lastst',
        desc = 'Nuke, follows the main dark element',
    },
}

return M
