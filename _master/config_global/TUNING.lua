---============================================================================
--- Tuning - thresholds and names a few jobs use
---============================================================================
--- Every line is a comment: the values shown are the defaults. Uncomment a
--- line to change it; in a table, the keys you give are enough.
---
--- @file _common/combat/TUNING.lua
--- @author ejouanchicot
--- @date Created: 2026-09-30
---============================================================================

return {
    -- SAM idle: sets.idle.Weak under this HP %, else sets.idle.Regen under
    -- that one
    -- sam_idle_hp = {weak_below = 50, regen_below = 80},

    -- Idle refresh gear under this MP % (COR: sets.idle.Refresh, WHM:
    -- sets.latent_refresh)
    -- refresh_mp_below = {COR = 50, WHM = 51},

    -- Curing Waltz tier from the missing HP of the target (main DNC or
    -- /DNC): each tier starts at this many HP missing
    -- waltz_from = {['Curing Waltz II'] = 200, ['Curing Waltz III'] = 600,
    --               ['Curing Waltz IV'] = 1100, ['Curing Waltz V'] = 1500},

    -- SMN //gs c skillup: the avatar summoned, and the seconds before the
    -- Release (summon cast time + a margin)
    -- smn_skillup = {avatar = 'Siren', release_after = 5.0},

    -- GEO //gs c escort with no Indi- named
    -- geo_escort_indi = 'Indi-Regen',

    -- BRD debuff song commands (//gs c lullaby, lullaby2, elegy, requiem)
    -- brd_debuff_songs = {lullaby = 'Horde Lullaby', lullaby2 = 'Foe Lullaby II',
    --                     elegy = 'Carnage Elegy', requiem = 'Foe Requiem VII'},
}
