---============================================================================
--- Smartbuff - the abilities your buff commands cast, in order
---============================================================================
--- Write the name of the ability (or spell). Any works: it is skipped when
--- its buff is already up, when it is on cooldown, or when your jobs do not
--- have it. A few names keep a rule of their own:
---   Warcry       Blood Rage instead while Warcry is on cooldown (WAR main)
---   Hasso        only with a two-handed weapon in hand
---   Utsusemi     Utsusemi: Ni, else Ichi
---   Haste Samba  only with 350 TP
--- Remove a name and it is no longer cast; an empty list {} casts nothing.
--- The values below are the defaults; a key removed goes back to its default.
---
--- @file _common/combat/SMARTBUFF_CONFIG.lua
--- @author ejouanchicot
--- @date Created: 2026-10-01
---============================================================================

return {
    -- //gs c smartbuff (every job; DNC adds its dance and samba first): what
    -- each subjob casts. A subjob not listed casts nothing.
    -- Example: {'Berserk', 'Aggressor', 'Warcry'} -> {'Aggressor', 'Warcry'}
    -- to keep Berserk off while tanking.
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
}
