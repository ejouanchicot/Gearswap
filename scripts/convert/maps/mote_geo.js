// The classic Mote GEO file (sets.idle / sets.idle.Pet / sets.engaged, nukes under Mote's spell maps
// HighTierNuke / LowTierNuke, sets.magic_burst laid by its job_post_midcast while state.MagicBurst is on,
// sets.midcast.Geomancy.Indi.others for an Indi- on another player), as our GEO reads it:
//   - shared/jobs/geo/functions/logic/set_builder.lua builds idle and engaged from sets.me.* (no luopan)
//     and sets.luopan.* (a luopan out): Mote's sets.idle / sets.engaged are never worn there, and
//     sets.me missing is an error
//   - Elemental Magic: MidcastManager reads sets.midcast['Elemental Magic'] (skill), not the spell maps;
//     his LowTierNuke is a copy of HighTierNuke in the files met so far
//   - an Indi- on a party member under Entrust: sets.midcast.Indi.Entrust (read while sets.midcast.Indi exists)
// His idle while an Indi- is up (sets.idle.Indi and kin, Mote's CustomIdleGroups) has no place in ours:
// kept in the file, unread. A player map: module.exports = require('../mote_geo.js')({key: '@`'}).
module.exports = (opts = {}) => ({
  add: {me: {}, luopan: {}},
  alias: Object.assign({
    'me.idle': 'idle',
    'luopan.idle': 'idle.Pet',
    'me.engaged': 'engaged',
    'midcast["Elemental Magic"]': 'midcast.HighTierNuke',
  }, opts.entrust ? {'midcast.Indi': 'midcast.Geomancy.Indi', 'midcast.Indi.Entrust': 'midcast.Geomancy.Indi.others'} : {}),
  custom: [
    {comment: 'His Magic Burst toggle (job_post_midcast): sets.magic_burst over every Elemental Magic spell while it is on', entry: Object.assign({
      state: 'MagicBurst', desc: 'Magic Burst', values: 'onoff', section: 'spell',
      On: {when: {skill: 'Elemental Magic'}, midcast: 'sets.magic_burst'},
    }, opts.key ? {key: opts.key} : {})},
  ],
});
