---============================================================================
--- Set Catalog (BST) - the set names the Beastmaster code reads
---============================================================================
--- What BST's own code adds to shared/utils/atelier/set_catalog_common.lua
--- (format: shared/utils/atelier/set_catalog.lua). BST builds its idle and
--- engaged sets from sets.me.* (the master) and sets.pet.* (the pet), not from
--- Mote's sets.idle / sets.engaged (those are a last fallback only), and its
--- weapons from WeaponSet / SubSet, not MainWeapon / SubWeapon.
---
--- @file    shared/jobs/bst/set_catalog.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-06
---============================================================================

return {
    ---------------------------------------------------------------- idle (master side)
    -- shared/jobs/bst/functions/logic/set_builder.lua idle_without_pet, idle_with_pet (MasterPDT)
    {'me.idle', when = 'Standing with no pet out, or pet out and idle while Pet Idle Mode is MasterPDT', base = 'idle'},
    {'me.idle.PDT', when = 'Pet out and not fighting with Pet Idle Mode MasterPDT; also laid on top of the master idle when Hybrid Mode is PDT',
        base = {'me.idle', 'idle'}},
    -- set_builder.lua with_pdt / pdt_overlay: the group catch-all when sets.me.idle / sets.me.engaged have no PDT
    {'me.PDT', when = 'Hybrid Mode PDT, master idle or fighting, when the master set has no PDT version of its own'},
    -- set_builder.lua apply_common_overlays (BaseSetBuilder.lay_town_set)
    {'me.idle.Town', when = 'Idle in a town (Dynamis excluded), laid on top of the master or pet idle set', base = {'me.idle', 'idle'}},

    ---------------------------------------------------------------- idle (pet side)
    -- set_builder.lua idle_with_pet
    {'pet.idle', when = 'Pet out, not fighting, Pet Idle Mode PetPDT (when pet.idle.PDT is absent); pet fighting without a pet.engaged set',
        base = {'me.idle', 'idle'}},
    {'pet.idle.PDT', when = 'Pet out and not fighting with Pet Idle Mode PetPDT', base = {'pet.idle', 'idle'}},
    {'pet.engaged', when = 'Your pet fights while you stand idle', base = {'pet.idle', 'idle'}},
    {'pet.engaged.PDT', when = 'Your pet fights while you stand idle, Hybrid Mode PDT: laid on top of pet.engaged', base = 'pet.engaged'},
    -- set_builder.lua with_pdt: catch-all PDT of the pet sets
    {'pet.PDT', when = 'Hybrid Mode PDT with a pet set that has no PDT version of its own (pet idle, pet fighting, both fighting)'},

    ---------------------------------------------------------------- engaged
    -- set_builder.lua engaged_for_situation (customize_melee_set: only while you are engaged)
    {'me.engaged', when = 'You fight and your pet does not (or no pet)', base = 'engaged'},
    {'me.engaged.PDT', when = 'You fight and your pet does not, Hybrid Mode PDT: laid on top of me.engaged', base = 'me.engaged'},
    {'pet.engagedBoth', when = 'You and your pet both fight', base = {'me.engaged', 'engaged'}},
    {'pet.engagedBoth.PDT', when = 'You and your pet both fight, Hybrid Mode PDT: laid on top of pet.engagedBoth', base = 'pet.engagedBoth'},
    -- set_builder.lua engaged_for_situation -> shared/utils/party/support_tier.lua SupportTier.engaged (each set and its PDT overlay)
    {'me.engaged.{Group|Solo|Trust}', when = 'You fight and your pet does not, with less support in your zone (Group: one of BRD/COR/GEO; Solo: none; Trust: trusts only)',
        base = 'me.engaged'},
    {'me.engaged.PDT.{Group|Solo|Trust}', when = 'The me.engaged PDT overlay with less support in your zone', base = 'me.engaged.PDT'},
    {'pet.engagedBoth.{Group|Solo|Trust}', when = 'You and your pet both fight, with less support in your zone', base = 'pet.engagedBoth'},
    {'pet.engagedBoth.PDT.{Group|Solo|Trust}', when = 'The pet.engagedBoth PDT overlay with less support in your zone', base = 'pet.engagedBoth.PDT'},

    ---------------------------------------------------------------- weapons
    -- set_builder.lua apply_weapon_sets: sets[state.WeaponSet.value], sets[state.SubSet.value], idle and engaged
    {'{WeaponSet}', when = 'That Weapon value: laid on the idle and engaged sets', needs = {'state:WeaponSet'}},
    {'{SubSet}', when = 'That Sub value: laid on the idle and engaged sets', needs = {'state:SubSet'}},

    ---------------------------------------------------------------- pet summon
    -- BST_PRECAST.lua equip_for_summon: the Call Beast set on Call Beast AND on Bestial Loyalty
    {'precast.JA.Call Beast', when = 'Calling a jug pet (Call Beast, and Bestial Loyalty too, under its own set)'},
    -- BST_PRECAST.lua equip_broth: sets[state.ammoSet.value].ammo, last. The names are the pets of
    -- _master/config/bst/BST_PET_DATA.lua (state.ammoSet is rebuilt from that list by ecosystem_manager.lua)
    {'{Amiable Roche (Fish)|Anklebiter Jedd (Diremite)|Blackbeard Randy (Tiger)|Bouncing Bertha (Chapuli)|Brainy Waluis (Funguar)|Choral Leera (Colibri)|Cursed Annabelle (Antlion)|Daring Roland (Hippogryph)|Energized Sefina (Beetle)|Fatso Fargann (Leech)|Fluffy Bredo (Acuex)|Generous Arthur (Slug)|Headbreaker Ken (Fly)|Jovial Edwin (Crab)|Left-Handed Yoko (Mosquito)|Pondering Peter (Rabbit)|Rhyming Shizuna (Sheep)|Sultry Patrice (Slime)|Suspicious Alice (Eft)|Sweet Caroline (Mandragora)|Swooping Zhivago (Tulfaire)|Threestar Lynn (Ladybug)|Vivacious Vickie (Raaz)|Warlike Patrick (Lizard)|Weevil Familiar (Weevil)}',
        when = 'Calling that pet: only the ammo (its broth) is put on, over the Call Beast set'},

    ---------------------------------------------------------------- pet commands and Ready moves
    -- BST_PRECAST.lua prepare_ready_move: the Sic set on every Ready move, whether sets.precast.PetCommand exists or not
    -- (Mote's own sets.precast.PetCommand / .PetCommand.<command> / .JA.<command> are common lines)
    {'precast.JA.Sic', when = 'Using Sic or any Ready move (pet move)'},
    -- BST_AFTERCAST.lua job_aftercast: by the move's category (ready_move_categorizer.lua), _ww while you are engaged
    {'midcast.pet_physical_moves', when = 'Your pet uses a physical Ready move, you idle'},
    {'midcast.pet_physicalMulti_moves', when = 'Your pet uses a multi-hit physical Ready move, you idle'},
    {'midcast.pet_magicAtk_moves', when = 'Your pet uses a magic damage Ready move, you idle'},
    {'midcast.pet_magicAcc_moves', when = 'Your pet uses a magic accuracy (debuff) Ready move, you idle'},
    {'midcast.pet_physical_moves_ww', when = 'Your pet uses a physical Ready move while you fight', base = 'midcast.pet_physical_moves'},
    {'midcast.pet_physicalMulti_moves_ww', when = 'Your pet uses a multi-hit physical Ready move while you fight', base = 'midcast.pet_physicalMulti_moves'},
    {'midcast.pet_magicAtk_moves_ww', when = 'Your pet uses a magic damage Ready move while you fight', base = 'midcast.pet_magicAtk_moves'},
    {'midcast.pet_magicAcc_moves_ww', when = 'Your pet uses a magic accuracy Ready move while you fight', base = 'midcast.pet_magicAcc_moves'},

    ---------------------------------------------------------------- subjob spells (MidcastManager)
    -- BST_MIDCAST.lua job_post_midcast_enhancing_magic: database_func ENHANCING_MAGIC_DATABASE.get_spell_family (P6, P7).
    -- P1 [skill][base] of every skill (BST_MIDCAST.lua, midcast_fallback.lua) is the common line. The target_func gives
    -- 'Composure' only with the RDM main job's Composure (shared/data/job_abilities/rdm/rdm_mainjob.lua): no target levels.
    {'midcast.Enhancing Magic.{type:Enhancing Magic}', when = 'An enhancing spell of that family (read only when sets.midcast["Enhancing Magic"] exists)',
        base = 'midcast.Enhancing Magic', needs = {'skill:Enhancing Magic'}},
    {'midcast.{type:Enhancing Magic}', when = 'An enhancing spell of that family, before the one under Enhancing Magic (read only when sets.midcast["Enhancing Magic"] exists)',
        base = 'midcast.Enhancing Magic', needs = {'skill:Enhancing Magic'}},

    -- Common lines BST never reads:
    -- idle.Town: Mote's town pick is only the fallback base; BST lays sets.me.idle.Town (apply_common_overlays)
    -- {MainWeapon}, {SubWeapon}, SingleWield: BST lays sets[WeaponSet] / sets[SubSet] (apply_weapon_sets), no WeaponResolver
    skip = {'idle.Town', '{MainWeapon}', '{SubWeapon}', 'SingleWield'},
}
