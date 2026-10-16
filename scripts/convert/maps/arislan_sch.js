// The Arislan SCH file (Mote) as our SCH reads it. Its job_post_midcast on a nuke: the Elemental Magic set;
// on a helix that set, then sets.midcast.Helix (LightHelix for Luminohelix, DarkHelix for Noctohelix), then
// sets.Bookworm with HelixMode Duration; then, while its MagicBurst toggle is on, sets.magic_burst.
// Ours (shared/jobs/sch/functions/SCH_MIDCAST.lua) wears one set: Elemental Magic or its .MagicBurst,
// Helix or Helix.Dark / Helix.Light, each with its .MagicBurst; the sets below are his layers put together.
// Its stratagem sets (sets.buff.*) are read by our grimoire layers (logic/grimoire.lua), Penury and
// Parsimony by rules here.
//   opts.cure_weather  the set his Cure / Curaga take on a Light day or in Light weather
//                      ('sets.midcast.CureWeather', 'sets.midcast.Cure.Weather')
//   opts.regen         his Regen Mode values, his default first (['Potency', 'Duration'])
//   opts.helix         his Helix Mode values, his default first
//   opts.arts          his file lays sets.LightArts / sets.DarkArts on Enfeebling Magic of the Arts up
// A player map: module.exports = require('../arislan_sch.js')({...}) and its own fields over it.
const STORMS = ['Firestorm', 'Hailstorm', 'Windstorm', 'Sandstorm', 'Thunderstorm', 'Rainstorm', 'Aurorastorm', 'Voidstorm'];
const HELICES = ['Pyrohelix', 'Cryohelix', 'Anemohelix', 'Geohelix', 'Ionohelix', 'Hydrohelix', 'Luminohelix', 'Noctohelix'];
module.exports = (opts = {}) => ({
  // his Casting Mode values name no set of his
  skip_modes: ['CastingMode'],
  skip_custom: ['CastingMode'],
  modes: {MagicBurst: {state: 'MagicBurstMode', values: {true: 'On', false: 'Off'}}},
  // his FullSublimation set while Sublimation charges: ours lays sets.buff.Sublimation then (logic/set_builder.lua)
  rename: {'buff.FullSublimation': 'buff.Sublimation'},
  rebase: {'midcast.Helix': 'midcast["Elemental Magic"]'},
  derive: {
    'midcast["Elemental Magic"].MagicBurst': {from: ['midcast["Elemental Magic"]', 'magic_burst']},
    'midcast.Helix.MagicBurst': {from: ['midcast.Helix', 'magic_burst']},
    'midcast.Helix.Light': {from: ['midcast["Elemental Magic"]', 'midcast.LightHelix']},
    'midcast.Helix.Dark': {from: ['midcast["Elemental Magic"]', 'midcast.DarkHelix']},
    'midcast.Helix.Light.MagicBurst': {from: ['midcast["Elemental Magic"]', 'midcast.LightHelix', 'magic_burst']},
    'midcast.Helix.Dark.MagicBurst': {from: ['midcast["Elemental Magic"]', 'midcast.DarkHelix', 'magic_burst']},
  },
  custom: [
    {comment: 'His apply_grimoire_bonuses: his Penury and Parsimony sets on every spell while the stratagem is up\n(our grimoire layers have none for them)', entry: {when: {buff: 'Penury'}, midcast: 'sets.buff.Penury'}},
    {entry: {when: {buff: 'Parsimony'}, midcast: 'sets.buff.Parsimony'}},
    {comment: 'His customize_idle_set: his latent refresh pieces under 51% MP, not while Sublimation charges', entry: {
      when: {mp_below: 51, no_buff: 'Sublimation: Activated'}, idle: 'sets.latent_refresh'}},
    {comment: 'His job_post_midcast: a Cure or Curaga on a Light day or in Light weather takes his Light weather set', entry: {
      when: {spell: ['Cure*', 'Cura*'], day_weather: true}, midcast: opts.cure_weather || 'sets.midcast.CureWeather'}},
    {comment: 'His Regen Mode: RegenDuration over every Regen while on Duration (his job_post_midcast)', entry: {
      state: 'RegenMode', desc: 'Regen Mode', values: opts.regen || ['Potency', 'Duration'], section: 'spell',
      Duration: {when: {spell: 'Regen*'}, midcast: 'sets.midcast.RegenDuration'},
    }},
    {comment: 'His Stormsurge toggle: his Stormsurge set over every storm while on', entry: {
      state: 'StormSurge', desc: 'Stormsurge', values: 'onoff', section: 'spell',
      On: {when: {spell: STORMS.map(n => n + '*')}, midcast: 'sets.midcast.Stormsurge'},
    }},
    {comment: 'His Helix Mode: Bookworm (Duration) over every helix', entry: {
      state: 'HelixMode', desc: 'Helix Mode', values: opts.helix || ['Potency', 'Duration'], section: 'spell',
      Duration: {when: {spell: HELICES.map(h => h + '*')}, midcast: 'sets.Bookworm'},
    }},
    ...(opts.arts ? [
      {comment: 'His job_post_midcast: sets.LightArts on white Enfeebling Magic under Light Arts or Addendum: White,\nsets.DarkArts on black Enfeebling Magic under Dark Arts or Addendum: Black', entry: {
        when: {skill: 'Enfeebling Magic', spell_type: 'WhiteMagic', buff: ['Light Arts', 'Addendum: White']}, midcast: 'sets.LightArts'}},
      {entry: {when: {skill: 'Enfeebling Magic', spell_type: 'BlackMagic', buff: ['Dark Arts', 'Addendum: Black']}, midcast: 'sets.DarkArts'}},
    ] : []),
  ],
  scenarios: [
    {label: 'spell:Anemohelix II HelixMode=Duration', status: 'Idle', modes: {HelixMode: 'Duration'},
      action: {kind: 'spell', name: 'Anemohelix II'}},
    {label: 'spell:Fire V MagicBurst off', status: 'Idle', modes: {MagicBurst: false}, action: {kind: 'spell', name: 'Fire V'}},
    {label: 'spell:Noctohelix II MagicBurst off', status: 'Idle', modes: {MagicBurst: false},
      action: {kind: 'spell', name: 'Noctohelix II'}},
  ],
  accept: [
    {label: ' \\+(Rapture|Ebullience|Celerity|Alacrity|Perpetuance|Immanence|Klimaform|Light Arts|Dark Arts|Addendum: White|Addendum: Black)$', line: '.',
      why: 'stratagem gear: our grimoire layers (shared/jobs/sch/functions/logic/grimoire.lua: Rapture on white magic, Ebullience on black magic, Celerity / Alacrity at the start and as the spell lands, Klimaform with the weather) instead of his conditions (Rapture on cures only, Ebullience on nukes only, Celerity / Alacrity on every spell as it lands)'},
    {label: '^spell:(Protect|Shell)', line: 'ring: .* -> Sheltered Ring',
      why: 'Protect / Shell: our system wears Sheltered Ring for them'},
  ],
});
