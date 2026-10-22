---============================================================================
--- Set Catalog (BRD) - the set names the Bard code reads
---============================================================================
--- What BRD's own code adds to set_catalog_common.lua, for the Atelier's
--- "+ Set" (format: shared/utils/atelier/set_catalog.lua): the idle and
--- engaged sets its set builder picks, the song sets of MidcastManager's
--- Singing chain and of the router (dummy, debuff, instrument), and the
--- Enhancing families of the subjob spells. Every common line is read by
--- BRD skips the common lines a song would wrongly get (re-written below for its other skills).
---
--- Song chain (shared/utils/midcast/midcast_manager.lua select_singing_set):
--- exact name, name without spaces, tier-less name, song type (last word),
--- first word; nothing found: sets.midcast.BardSong; then
--- sets.midcast.Songs[required instrument] and, under Troubadour,
--- sets.midcast.Songs.Duration are laid on top. Not offered, although read:
---   the name without spaces (HonorMarch): no placeholder writes it, and the
---     spaced name (common {spell} line) is read first;
---   the first word (Honor, Valor, Fire...): the element words would also be
---     the sets of the nukes Fire, Water... (MidcastManager P0, Mote).
--- Songs and the common P1 lines: the Singing chain (midcast_manager.lua
--- select_singing_set) has no [skill][base] level, and whenever sets.midcast.BardSong
--- exists it lays its pick over Mote's: sets.midcast.Singing['Valor Minuet'] is
--- never worn, so those lines leave the songs out. A debuff song skips MidcastManager
--- (midcast_router.lua is_no_weapon_song): only Mote reads its set, by exact name or
--- spell map, so the tier-less name (Foe Lullaby for Foe Lullaby II) is left out too.
---
--- @file    shared/jobs/brd/set_catalog.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-06
---============================================================================

return {
    skip = {'midcast.{spellbase}', 'midcast.{spellbase.skill}.{spellbase}', 'midcast.{spellplain.skill}.{spellplain}'},
    -- the common lines without the songs (see the header); a buff song's tier-less name stays: step 2 of the Singing chain
    {'midcast.{spellbase}', when = 'Any tier of that spell, over the job\'s mode and family sets (read while the skill\'s set exists)', fr = 'Quand tu lances ce sort, à n’importe quel tier : passe avant les sets de mode et de famille du job, si tu as le set de son skill.',
        base = 'midcast.{spellbase.skill}', needs = {'not:spellbase:Lullaby|Threnody|Requiem|Elegy|Virelai|Nocturne|Finale'}},
    {'midcast.{spellbase.skill}.{spellbase}', when = 'Any tier of that spell (read while the skill\'s set exists)', fr = 'Quand tu lances ce sort, à n’importe quel tier, si tu as le set de son skill.', base = 'midcast.{spellbase.skill}',
        needs = {'not:spellbase.skill:Singing', 'absent:midcast.{spellbase}'}},
    {'midcast.{spellplain.skill}.{spellplain}', when = 'That spell (read while the skill\'s set exists)', fr = 'Quand tu lances ce sort, si tu as le set de son skill.', base = 'midcast.{spellplain.skill}',
        needs = {'not:spellplain.skill:Singing', 'absent:midcast.{spellplain}'}},

    ---------------------------------------------------------------- idle
    -- logic/set_builder.lua select_idle_base (sets.idle[IdleMode] outside town); Mote get_idle_set too
    {'idle.{IdleMode}', when = 'Standing, not fighting, with that Idle Mode', fr = 'Quand tu ne combats pas, avec ce Idle Mode.', base = 'idle'},
    -- Mote get_idle_set in a city, laid by base_set_builder.lua select_idle_base_town over sets.idle[IdleMode]
    {'idle.Town.{IdleMode}', when = 'Idle in a town with that Idle Mode, laid on top of the idle set', fr = 'En ville, avec ce Idle Mode : mis par-dessus ton set idle.', base = 'idle.Town'},

    ---------------------------------------------------------------- engaged
    -- logic/set_builder.lua select_engaged_base, priority 1 (player.equipment.sub == 'Kraken Club')
    {'engaged.PDTKC', when = 'Fighting with Kraken Club in the off hand (before the Engaged Mode set)', fr = 'Quand tu combats avec la Kraken Club en main secondaire : passe avant le set de l’Engaged Mode.', base = 'engaged'},
    -- logic/set_builder.lua select_engaged_base, priority 2
    {'engaged.{EngagedMode}', when = 'Weapon out, fighting, with that Engaged Mode', fr = 'Quand tu combats, arme sortie, avec cet Engaged Mode.', base = 'engaged'},
    -- Mote get_melee_set (sets.engaged[OffenseMode]): the base select_engaged_base falls back to
    {'engaged.{OffenseMode}', when = 'Fighting while the Engaged Mode value has no set of its own', fr = 'Quand tu combats et que la valeur de ton Engaged Mode n’a pas de set à elle.', base = 'engaged'},

    ---------------------------------------------------------------- precast
    -- Mote get_precast_set: sets.precast.FC[spell.type] when sets.precast.FC.Singing does not exist
    -- (BRD_PRECAST.lua job_post_precast shows the same walk; sets.precast.BardSong is never read)
    {'precast.FC.BardSong', when = 'Starting any song (read only while sets.precast.FC.Singing does not exist)', fr = 'Quand tu commences n’importe quelle chanson, si tu n’as pas de set precast.FC.Singing.',
        base = 'precast.FC', needs = {'absent:precast.FC.Singing'}},

    ---------------------------------------------------------------- songs (logic/midcast_router.lua handle_singing)
    -- midcast_manager.lua select_singing_set step 6 (base set of the Singing chain); Mote's type step
    {'midcast.BardSong', when = 'Singing a song with no set of its own (name, base name or type)', fr = 'Quand tu chantes une chanson qui n’a pas de set à elle (ni par son nom, ni par son nom sans tier, ni par son type).'},
    -- step 1 (exact name); also Mote by name, the only set a debuff song gets
    {'midcast.{spell:Singing}', when = 'Singing that song', fr = 'Quand tu chantes cette chanson.', base = {'midcast.{spell.base}', 'midcast.BardSong'}},
    -- step 3 (song type = last word of the tier-less name, MidcastManager.get_song_type); the buff songs.
    -- The words: every BardSong of the game's spell list
    {'midcast.{Aubade|Ballad|Capriccio|Carol|Dirge|Etude|Fantasia|Fugue|Gavotte|Hum|Hymnus|Madrigal|Mambo|March|Mazurka|Minne|Minuet|Operetta|Paeon|Passion|Pastoral|Prelude|Round|Scherzo|Sirvente}',
        when = 'Singing any song of that family (the last word of its name; Aria of Passion is Passion)', fr = 'Quand tu chantes une chanson de cette famille (le dernier mot de son nom ; Aria of Passion compte comme Passion).', base = 'midcast.BardSong'},
    -- debuff songs skip MidcastManager (is_no_weapon_song): Mote's spell map only
    -- (docs/dev/jobs/brd.md, docs/user/jobs/brd/sets.md; Mote-Mappings is not in the repo)
    {'midcast.{Lullaby|Threnody|Elegy|Requiem}', when = 'Singing a debuff song of that family with no set by name (Mote\'s spell map; no weapon swap, no instrument or Duration layer)', fr = 'Quand tu chantes une chanson de debuff de cette famille qui n’a pas de set à son nom (pas de changement d’arme, ni de set d’instrument ou de Duration).'},
    -- midcast_router.lua layer_lullaby: laid over Mote's set, by name, tier-less name, then Lullaby
    {'midcast.{Lullaby|Horde Lullaby|Foe Lullaby}.{LullabyMode}', when = 'Singing that Lullaby with that Lullaby Mode (a state of your CUSTOM file): laid on top of its set', fr = 'Quand tu chantes ce Lullaby avec ce Lullaby Mode (un state de ton fichier CUSTOM) : mis par-dessus son set.',
        base = 'midcast.Lullaby', needs = {'state:LullabyMode'}},
    {'midcast.Lullaby.Troubadour', when = 'Singing a Lullaby while Troubadour is up: laid on top of its set (and of the Lullaby Mode set)', fr = 'Quand tu chantes un Lullaby sous Troubadour : mis par-dessus son set (et par-dessus celui du Lullaby Mode).',
        base = 'midcast.Lullaby'},
    -- Mote get_midcast_set: sets.midcast[spell.skill] before sets.midcast.BardSong
    {'midcast.Singing', when = 'Mote\'s set for any song with no set by name or map: debuff songs keep it, the Singing chain is laid over it for the others', fr = 'Pour toute chanson sans set à son nom ou à son type : les chansons de debuff gardent ce set, les autres reçoivent leur set de chanson par-dessus.'},
    -- step 4 (layer_instrument: InstrumentLockConfig.LOCKED_SONGS); also BRD_PRECAST instrument lock
    {'midcast.Songs.{Marsyas|Loughnashade}', when = 'Singing Honor March (Marsyas) or Aria of Passion (Loughnashade): laid on top of the song\'s set', fr = 'Quand tu chantes Honor March (Marsyas) ou Aria of Passion (Loughnashade) : mis par-dessus le set de la chanson.',
        base = 'midcast.BardSong'},
    -- midcast_router.lua apply_main_instrument: only its range is taken, for songs without a required instrument
    {'midcast.Songs.{MainInstrument}', when = 'Singing with that Main Instrument: only the instrument (range) is taken', fr = 'Quand tu chantes avec ce Main Instrument : seul l’instrument (slot range) est pris.',
        needs = {'state:MainInstrument'}},
    -- step 5 (layer_troubadour)
    {'midcast.Songs.Duration', when = 'Singing while Troubadour is up: laid on top of the song\'s set', fr = 'Quand tu chantes sous Troubadour : mis par-dessus le set de la chanson.'},
    -- midcast_router.lua handle_dummy_song (BRDSongConfig.DUMMY_SONGS.standard, or the DummySong switch);
    -- song_slots.lua reads its range
    {'midcast.DummySong', when = 'Singing a dummy song (your dummy list, or a song turned dummy by the DummySong switch)', fr = 'Quand tu chantes une chanson dummy (de ta liste de dummies, ou rendue dummy par le switch DummySong).'},

    ---------------------------------------------------------------- subjob magic (logic/midcast_router.lua)
    -- handle_enhancing: select_set{skill = 'Enhancing Magic', database_func = get_spell_family} P7 [skill][type]
    -- (target_func gives 'Composure' only under Composure, a RDM main job ability: never on BRD)
    {'midcast.Enhancing Magic.{type:Enhancing Magic}', when = 'Casting an Enhancing spell of that family (read only when sets.midcast[\'Enhancing Magic\'] exists)', fr = 'Quand tu lances un sort d’Enhancing de cette famille, si tu as un set Enhancing Magic.',
        base = 'midcast.Enhancing Magic'},
}
