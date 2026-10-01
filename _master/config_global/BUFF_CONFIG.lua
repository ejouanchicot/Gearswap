---============================================================================
--- Buffs - what //gs c buff (and WAR's berserk / defender) cast, in order
---============================================================================
--- //gs c buff casts the list of your main job, then the list of your
--- subjob (DNC: its dance and samba first). Write the name of the ability or
--- spell, any works: it is skipped when its buff is already up, when it is on
--- recast, or when your jobs cannot use it (a subjob too low, a spell not
--- learned). One action goes when the previous one has ended.
--- A few names keep a rule of their own:
---   Warcry          Blood Rage instead while Warcry is on cooldown (WAR main)
---   Hasso, Seigan   only with a two-handed weapon in hand
---   Utsusemi        Utsusemi: Ni, else Ichi
---   Haste Samba     only with 350 TP
--- Remove a name and it is no longer cast; a job not listed (or {}) casts
--- nothing. The values below are the defaults; a key removed goes back to
--- its default.
---
--- @file _common/combat/BUFF_CONFIG.lua
--- @author ejouanchicot
--- @date Created: 2026-10-01
---============================================================================

return {
    -- Your main job's buffs. Write the tiers of a buff best first (Refresh
    -- III, Refresh II, Refresh): the first one you have and is ready goes.
    -- No list: BRD (songs), COR (rolls), GEO (bubbles), BST / SMN / PUP
    -- (pets), DNC (its dance and samba come first anyway), WAR (berserk /
    -- defender below), BLU (the game does not tell which spells are set),
    -- DRG, THF. Add one if you like, e.g. BLU = {'Cocoon', 'Barrier Tusk'}.
    -- '$GainSpell': the spell chosen in that state (RDM's GainSpell).
    -- '$EnSpell': tier I only (Enfire...): it hits every swing of the round,
    -- tier II only the first one, so tier I does more with Temper II's
    -- triple attack (BG-Wiki). A list inside the list is a group, the first
    -- ready goes: {'Refresh III', 'Refresh II'}.
    job = {
        BLM = {'Stoneskin', 'Blink', 'Aquaveil', 'Ice Spikes'},
        RDM = {'Composure', 'Haste II', 'Haste', 'Refresh III', 'Refresh II', 'Refresh',
               'Phalanx II', 'Phalanx', 'Temper II', 'Temper', '$GainSpell', '$EnSpell',
               'Regen II', 'Regen', 'Protect V', 'Protect IV', 'Shell V', 'Shell IV',
               '$Barspell', '$BarAilment', 'Stoneskin', 'Blink', 'Aquaveil', '$Spike'},
        WHM = {'Afflatus Solace', 'Reraise IV', 'Reraise III', 'Haste', 'Protect V', 'Protect IV',
               'Shell V', 'Shell IV', 'Auspice', 'Stoneskin', 'Blink', 'Aquaveil'},
        PLD = {'Majesty', 'Crusade', 'Reprisal', 'Enlight II', 'Enlight', 'Phalanx',
               'Protect V', 'Protect IV', 'Shell IV'},
        RUN = {'Swordplay', 'Crusade', 'Temper', 'Phalanx', 'Regen IV', 'Refresh',
               'Protect IV', 'Shell V', 'Shell IV', 'Foil', 'Aquaveil', 'Stoneskin', 'Blink'},
        SCH = {'Protect V', 'Protect IV', 'Shell V', 'Shell IV', 'Regen V', 'Regen IV',
               'Stoneskin', 'Blink', 'Aquaveil'},
        NIN = {'Utsusemi', 'Migawari: Ichi', 'Kakka: Ichi', 'Myoshu: Ichi'},
        SAM = {'Hasso', 'Third Eye'},
        DRK = {'Last Resort', 'Endark II', 'Endark'},
        MNK = {'Impetus', 'Focus'},
        RNG = {'Velocity Shot'},
    },

    -- Added after the job's list when this weapon is in hand (any job).
    -- Example: Naegling = {'Gain-STR', 'Enfire II'},
    weapon = {},

    -- Your subjob's buffs (added after the main job's)
    -- Example: WAR = {'Aggressor', 'Warcry'} keeps Berserk off while tanking
    subjob = {
        WAR = {'Berserk', 'Aggressor', 'Warcry'},
        SAM = {'Hasso', 'Third Eye'},
        NIN = {'Utsusemi'},
        DNC = {'Haste Samba'},
    },

    -- WAR main: //gs c berserk and //gs c defender
    war_berserk  = {'Berserk', 'Aggressor', 'Retaliation', 'Restraint', 'Warcry'},
    war_defender = {'Defender', 'Aggressor', 'Retaliation', 'Restraint', 'Warcry'},

    -- WAR main /SAM: add the stance (Hasso with berserk, Seigan with
    -- defender) and Third Eye to those two commands
    war_add_sam = true,

    -- Seconds between the end of an action and the next one. After a spell
    -- the game refuses a new spell for a moment: too short, and a spell is
    -- refused then sent again.
    wait_after_spell   = 3.0,
    wait_after_ability = 0.5,
}
