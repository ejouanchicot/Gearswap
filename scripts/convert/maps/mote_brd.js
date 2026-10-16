// Mote's example BRD file: its job_midcast lays a general song set first, sets.midcast.SongEffect (a song
// on a friend) or SongDebuff (on an enemy; ResistantSongDebuff with Casting Mode Resistant), then Mote
// lays the song's own set (by name or family: March, Minuet, Lullaby...) over it; ExtraSongsMode Dummy
// sings in sets.midcast.DaurdablaDummy. Ours (shared/jobs/brd, set_catalog.lua):
//   - buff songs: MidcastManager's Singing chain over sets.midcast.BardSong (his SongEffect)
//   - debuff songs: Mote's set by name or spell map over sets.midcast.Singing (his SongDebuff); Mote's
//     own Casting Mode lookup reads sets.midcast.Singing.Resistant (his ResistantSongDebuff)
//   - a dummy song: sets.midcast.DummySong, our DummySong switch for his ExtraSongsMode Dummy
// His family sets were laid over his general set; ours wears a family set alone: written over it.
// His ExtraSongsMode FullLength (sets.midcast.Daurdabla over a real song): our Main Instrument Daurdabla.
const BUFF_FAMILIES = ['March', 'Minuet', 'Madrigal', 'Ballad', 'Paeon', 'Mambo', 'Minne', 'Etude', 'Carol', 'Prelude',
  'Mazurka', 'Hymnus', 'Sirvente', 'Dirge', 'Scherzo', 'Aubade', 'Pastoral', 'Fantasia', 'Operetta', 'Capriccio', 'Round', 'Gavotte'];
const DEBUFF_FAMILIES = ['Lullaby', 'Threnody', 'Elegy', 'Requiem', 'Finale', 'Nocturne', 'Virelai'];
// the songs whose name his file gives a set to: buff songs over BardSong, debuff songs over Singing
const DEBUFF_SONGS = /Lullaby|Threnody|Elegy|Requiem|Finale|Nocturne|Virelai/;
module.exports = (opts = {}) => {
  const rebase = {'midcast.BardSong': 'midcast.FastRecast', 'midcast.Singing': 'midcast.FastRecast'};
  for (const f of BUFF_FAMILIES) rebase[`midcast.${f}`] = 'midcast.BardSong';
  for (const f of DEBUFF_FAMILIES) rebase[`midcast.${f}`] = 'midcast.Singing';
  for (const name of opts.songs || []) rebase[`midcast[${JSON.stringify(name)}]`] = DEBUFF_SONGS.test(name) ? 'midcast.Singing' : 'midcast.BardSong';
  return {
    rename: {'midcast.SongEffect': 'midcast.BardSong', 'midcast.SongDebuff': 'midcast.Singing',
      'midcast.ResistantSongDebuff': 'midcast.Singing.Resistant', 'midcast.DaurdablaDummy': 'midcast.DummySong'},
    // only the family sets his file has (write_sets.js: a rebase of a set he does not have is an error)
    rebase_if: rebase,
    modes: {ExtraSongsMode: {state: 'DummySong', values: {None: false, Dummy: true, FullLength: false}}},
    custom: [{comment: 'Our switch for his ExtraSongsMode Dummy: the next song as a dummy, then back off by itself', entry: {
      state: 'DummySong', desc: 'Dummy Song', values: 'onoff', section: 'spell'}}],
  };
};
