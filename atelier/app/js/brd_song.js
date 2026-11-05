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
  // the songs' CHR under a key of its own (chr is a BST's Charm figure, opt_stat.js), and the instrument's kind: the
  // skill a song adds to Singing is the one of the instrument worn (Category:Song)
  if (v('chr')) out.songchr = v('chr');
  const kind = ((typeof itemOf === 'function' && itemOf(name)) || {})['Skill Type'];
  if (kind === 'Wind Instrument') out.instwind = 1;
  if (kind === 'String Instrument') out.inststring = 1;
  return out;
}

/* ---- the song a set is judged on (its context: statContext, the figures: atelier/opt_song.js) ---- */
// Each family: the song its set is judged on (the highest a BRD 99 sings), its Song+ cap from equipment, its
// potency (buffs.js SONGS: [base, per Song+], the stat shown first) and the combined skill (Singing + instrument)
// past which the potency stops growing.
// Caps: Category:Minuet, March, Ballad, Scherzo +8, Threnody +9 (read 2026-11-05); the others buffs.js SONGS' lim
// (BGWiki:SongPotency, 2026-11-02). Skill caps (Category:Minuet, March, Madrigal, Minne, Paeon, Etude, Scherzo,
// 2026-11-05): Valor Minuet V 871~874, Victory March "> 600" (to verify, the page says), Honor March 900, Blade
// Madrigal "< 850", Knight's Minne V "< 850", Army's Paeon VI 434~778, Herculean Etude 450, Sentinel's Scherzo 800,
// Mage's Ballad "No Effect"; the top of each range kept
const SONG_FAMILY = {
  minuet: {spell: 'Minuet V', skill: 874}, march: {spell: 'Victory March', skill: 600},
  madrigal: {spell: 'Blade Madrigal', skill: 850}, ballad: {spell: "Mage's Ballad III", skill: 0},
  paeon: {spell: "Army's Paeon VI", skill: 778}, minne: {spell: "Knight's Minne V", skill: 850},
  mambo: {spell: 'Dragonfoe Mambo'}, etude: {spell: 'Herculean Etude', skill: 450}, carol: {spell: 'Fire Carol'},
  prelude: {spell: "Archer's Prelude"}, dirge: {spell: "Adventurer's Dirge"}, scherzo: {spell: "Sentinel's Scherzo", cap: 8, skill: 800},
  // Threnody II: "every Threnody +1 ... gives an additional -5 Magic Evasion" from 160 (Category:Threnody); Lullaby:
  // 30 s of sleep, +9 at most (BGWiki:SongPotency: 57 s at +9)
  threnody: {spell: 'Threnody II', cap: 9, pot: {meva: [160, 5]}, debuff: true},
  lullaby: {spell: 'Foe Lullaby II', cap: 9, base: 30, debuff: true}};
const SONG_HONOR = {spell: 'Honor March', cap: 4, skill: 900};
// The debuff songs judged on landing (no Song+ figure of their own here); the songs sung to fill a slot, to be
// overwritten soon: the shortest one wanted (the player, 2026-11-05: "a set for the songs with the shortest duration,
// to replace them"), a party buff's 120 s base
const SONG_DEBUFF = /lullaby|elegy|requiem|finale|nocturne|virelai|threnody|debuffsong|magic finale|pining/i;
const SONG_DUMMY = /dummysong|capriccio|gavotte|aubade|pastoral|fantasia|operetta|puppet's|herb pastoral/i;
// The song a set is cast for, from its names (core.js setNames): null when it is no song set of a Bard
function songOf(s){
  if (S.job !== 'BRD' || !s || family(s.path, s.pieces) !== 'midcast') return null;
  const p = setNames(s);
  if (!/song|singing|dirge|minuet|march|madrigal|ballad|paeon|minne|mambo|etude|carol|prelude|scherzo|lullaby|elegy|requiem|finale|nocturne|virelai|threnody|capriccio|gavotte|aubade|pastoral|honormarch|honor march/i.test(p)) return null;
  if (/aria|passion/i.test(p)) return null;
  if (SONG_DUMMY.test(p)) return {kind: 'dummy'};
  if (/honor ?march/i.test(p)) return Object.assign({kind: 'buff', fam: 'march'}, SONG_HONOR);
  const fam = Object.keys(SONG_FAMILY).find(f => new RegExp(f, 'i').test(p));
  if (fam && SONG_FAMILY[fam].debuff) return Object.assign({kind: 'debuff', fam}, SONG_FAMILY[fam]);
  if (SONG_DEBUFF.test(p)) return {kind: 'debuff', fam: null};
  if (fam) return Object.assign({kind: 'buff', fam}, SONG_FAMILY[fam]);
  // the base set (sets.midcast.BardSong) and the ones an instrument is laid on (sets.midcast.Songs.Gjallarhorn): any
  // song with no set of its own, judged on All songs
  return {kind: 'buff', fam: null};
}
// The character's Singing, Wind and String skills without gear: the export's skills count the pieces worn when it was
// taken (Tetsouo 2026-11-05: Singing and Wind 473 with Gjallarhorn's +25 on, String 448), so those pieces' are taken off
function songSkillsBare(c){
  const worn = {sing: 0, wind: 0, string: 0};
  for (const [slot, p] of Object.entries(c.worn || {})) {
    if (!p || !p.name) continue;
    const r = pieceStats(p, slot), v = r ? songVec(r, p.name) : {};
    for (const k of Object.keys(worn)) worn[k] += v[k] || 0;
  }
  const lv = n => c.skills ? skillLevel(c, n) : 0;
  return {sing: Math.max(0, lv('singing') - worn.sing), wind: Math.max(0, lv('wind instrument') - worn.wind),
    string: Math.max(0, (lv('stringed instrument') || lv('string instrument')) - worn.string)};
}
// The context's part for the figures (stat_opt.js statContext): the song, its cap and potency, the duration's base,
// the character's skills without gear and the job point gift (BG Wiki Bard: "Song Effect Duration +5%", 1200 JP)
function songBase(s){
  const g = songOf(s);
  if (!g) return null;
  const c = measuredChar() || {}, bare = songSkillsBare(c), row = g.spell && typeof SONGS === 'object' ? SONGS[g.spell] : null;
  const potRow = g.pot || (row ? Object.fromEntries(Object.entries(row).filter(([k]) => k !== 'lim')) : {});
  const [stat, pot] = Object.entries(potRow)[0] || [null, null];
  return {songKind: g.kind, songFam: g.fam, songSpell: g.spell || null, songCap: g.cap != null ? g.cap : row ? row.lim : null,
    songPotStat: stat, songPot: pot, songDurBase: g.kind === 'buff' || g.kind === 'dummy' ? 120 : g.base || 0, songSkillCap: g.skill != null ? g.skill : null,
    songGift: (c.jp_spent || 0) >= 1200 ? 5 : 0,
    songSing: bare.sing, songWind: bare.wind, songString: bare.string};
}
