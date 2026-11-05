// GearSwap Atelier · brd_song.js: what a Bard's piece brings to its songs, read from the game's own text
// (notes/docs-perso/chants-brd-2026-11-05/SPEC.md). stats.js parseLine already turns each line into a key
// (x:all songs, x:minuet, x:song effect duration, skill:singing skill...); this file gives them their names for the
// stats optimizer (stat_opt.js statVec, on a BRD only).
//
// Sources (BG Wiki, read 2026-11-05):
//   Category:Song: "Whether equipment says "Song effect duration +10" or "Song effect duration +10%", these values
//     are the same +10% duration increase"; its "Song Effect Duration" table gives the pieces whose text has no
//     figure (SONG_DUR_TEXT below); "The Instrument skill consists of either Wind or String depending on the
//     instrument type equipped".
//   Carnwenhan: "Increases song effect duration" then II to V by level, the table's +10 % to +50 % (Level 90 and 95
//     both IV, +40 %): a tenth per step.
//   Daurdabla (Level 99, 99 II): "Allows a third and fourth song to be active on party members".
//
// @file    atelier/app/js/brd_song.js
// @author  ejouanchicot

// The song families a piece can name ("Minuet"+1, "Etude"+2): each its own key song_<family>
const SONG_FAMILIES = ['minuet', 'march', 'madrigal', 'ballad', 'paeon', 'minne', 'mambo', 'etude', 'carol', 'prelude',
  'scherzo', 'threnody', 'lullaby', 'elegy', 'requiem', 'finale', 'nocturne', 'virelai', 'mazurka', 'hymnus', 'dirge', 'sirvente'];
// The pieces whose text says "Increases song effect duration" with no figure: the % of Category:Song's table, by
// item id where one name covers several (Daurdabla Level 90: +25 %, Level 95 and 99: +30 %)
const SONG_DUR_TEXT = {"Aoidos' Matinee": 10, 'Mdk. Shalwar +1': 10, "Marduk's Shalwar +1": 10, 'Legato Dagger': 5,
  Daurdabla: {18575: 25, 18576: 30, 18571: 30, 18839: 30}};
const SONG_ROMAN = {I: 1, II: 2, III: 3, IV: 4, V: 5};
// The duration a piece's text gives without a figure, in %
function songDurText(r, name){
  const line = (r.free || []).concat(r.cond || []).find(t => /^Increases? song effect duration\b/i.test(t));
  if (!line) return 0;
  const step = /duration\s+(I{1,3}|IV|V)\b/.exec(line);
  if (/^Carnwenhan$/.test(name)) return 10 * (step ? SONG_ROMAN[step[1]] : 1);
  const known = SONG_DUR_TEXT[name];
  return typeof known === 'number' ? known : known && known[r.id] || 0;
}
// "Grants an additional song effect" (Terpander, Daurdabla Level 90 and 95), "two additional" (Daurdabla Level 99,
// Loughnashade): how many songs more
function songExtra(r){
  const line = (r.free || []).find(t => /^Grants (an|one|two) additional song effects?/i.test(t));
  return !line ? 0 : /two/i.test(line) ? 2 : 1;
}
// What a piece brings to songs, for the stats optimizer (statVec): songall (All songs), song_<family>, songdur (%),
// songrecast (seconds, negative), songextra, sing, wind, string (skills). CHR, Magic Accuracy and the songs' casting
// time are read for every job (the stats, enfVec, castVec): no key of their own here (chr is a BST's Charm figure)
function songVec(r, name){
  const out = {}, v = k => r.stats[k] ? r.stats[k].v || 0 : 0;
  if (v('x:all songs')) out.songall = v('x:all songs');
  for (const f of SONG_FAMILIES) if (v('x:' + f)) out['song_' + f] = v('x:' + f);
  // both wordings: "Song effect duration +17%" (Inyanga Shalwar), "Song duration +15%" (Brioso Slippers +4)
  const dur = v('x:song effect duration') + v('x:song duration') + songDurText(r, name);
  if (dur) out.songdur = dur;
  if (v('x:song recast delay')) out.songrecast = v('x:song recast delay');
  if (songExtra(r)) out.songextra = songExtra(r);
  if (v('skill:singing skill')) out.sing = v('skill:singing skill');
  if (v('skill:wind instrument skill')) out.wind = v('skill:wind instrument skill');
  if (v('skill:string instrument skill') + v('skill:stringed instrument skill')) out.string = v('skill:string instrument skill') + v('skill:stringed instrument skill');
  return out;
}
