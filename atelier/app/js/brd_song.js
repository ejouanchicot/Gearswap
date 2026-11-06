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
// Caps, each family's page read on 2026-11-05 ("The maximum ... bonus available from equipment is"): Minuet, March,
// Ballad, Scherzo, Prelude +8; Madrigal, Minne, Paeon, Mambo, Etude, Carol, Threnody, Lullaby +9; Honor March +4
// (buffs.js SONGS' lim holds the same). Whether Song+ past the cap still lengthens the song: not stated, the cap is
// taken for both. Skill caps (Category:Minuet, March, Madrigal, Minne, Paeon, Etude, Scherzo; Honor_March "Skill cap
// is 900"): Valor Minuet V 871~874, Victory March "> 600" (to verify, the page says), Honor March 900, Blade Madrigal
// "< 850", Knight's Minne V "< 850", Army's Paeon VI 434~778, Herculean Etude 450, Sentinel's Scherzo 800, Mage's
// Ballad "No Effect"; the top of each range kept. They are combined skills (Singing + instrument): BG Wiki does not
// name the skill, but one skill cannot reach 874 (459 at ML50, the +13 gift and the gear's ~140)
const SONG_FAMILY = {
  minuet: {spell: 'Minuet V', name: 'Valor Minuet V', skill: 874}, march: {spell: 'Victory March', skill: 600},
  madrigal: {spell: 'Blade Madrigal', skill: 850}, ballad: {spell: "Mage's Ballad III", skill: 0},
  paeon: {spell: "Army's Paeon VI", skill: 778}, minne: {spell: "Knight's Minne V", skill: 850},
  mambo: {spell: 'Dragonfoe Mambo'}, etude: {spell: 'Herculean Etude', skill: 450}, carol: {spell: 'Fire Carol'},
  prelude: {spell: "Archer's Prelude"}, aria: {spell: 'Aria of Passion'}, dirge: {spell: "Adventurer's Dirge", cap: null}, scherzo: {spell: "Sentinel's Scherzo", cap: 8, skill: 800},
  // Threnody II: "every Threnody +1 ... gives an additional -5 Magic Evasion" from 160 (Category:Threnody); Lullaby II
  // (Foe and Horde): "Sleep effect duration is 60 seconds before Lullaby-enhancing gear", 114 s at +9, "The maximum
  // Lullaby bonus available from equipment is +9" (BG Wiki Foe_Lullaby_II, Horde_Lullaby_II, Category:Lullaby)
  threnody: {spell: 'Threnody II', cap: 9, pot: {meva: [160, 5]}, debuff: true},
  lullaby: {spell: 'Foe Lullaby II', cap: 9, base: 60, debuff: true}};
const SONG_HONOR = {spell: 'Honor March', cap: 4, skill: 900};
// A song whose potency does not grow with Song+ (Adventurer's Dirge: SONGS lim 0) has no cap of its own (cap: null):
// "All Songs" gear still lengthens it, "by 10% per +1" (BG Wiki Category:Nocturne, the same kind of song)
// The debuff songs judged on landing (no Song+ figure of their own here); the songs sung to fill a slot, to be
// overwritten soon: the shortest one wanted (the player, 2026-11-05: "a set for the songs with the shortest duration,
// to replace them"), a party buff's 120 s base
const SONG_DEBUFF = /lullaby|elegy|requiem|finale|nocturne|virelai|threnody|debuffsong|magic finale|pining/i;
const SONG_DUMMY = /dummysong|placeholder|capriccio|gavotte|aubade|pastoral|fantasia|operetta|puppet's|herb pastoral/i;
// The song a set is cast for, from its names (core.js setNames): null when it is no song set of a Bard
function songOf(s){
  if (S.job !== 'BRD' || !s || family(s.path, s.pieces) !== 'midcast') return null;
  const p = setNames(s);
  if (!/song|singing|dirge|aria|passion|minuet|march|madrigal|ballad|paeon|minne|mambo|etude|carol|prelude|scherzo|lullaby|elegy|requiem|finale|nocturne|virelai|threnody|capriccio|gavotte|aubade|pastoral|honormarch|honor march/i.test(p)) return null;
  if (SONG_DUMMY.test(p)) return {kind: 'dummy'};
  if (/honor ?march/i.test(p)) return Object.assign({kind: 'buff', fam: 'march'}, SONG_HONOR);
  const fam = Object.keys(SONG_FAMILY).find(f => new RegExp(f, 'i').test(p));
  if (fam && SONG_FAMILY[fam].debuff) return Object.assign({kind: 'debuff', fam}, SONG_FAMILY[fam]);
  if (SONG_DEBUFF.test(p)) return {kind: 'debuff', fam: null};
  if (fam) return Object.assign({kind: 'buff', fam}, SONG_FAMILY[fam]);
  // the base set (sets.midcast.BardSong) and the ones an instrument is laid on (sets.midcast.Songs.Gjallarhorn): any
  // song with no set of its own, judged on All songs; its skill floor the highest a set of its own may need (Minuet V)
  return {kind: 'buff', fam: null, skill: 874};
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
  return {songKind: g.kind, songFam: g.fam, songSpell: g.spell || null, songCap: 'cap' in g ? g.cap : row ? row.lim : null, songName: g.name || g.spell || null,
    songPots: Object.entries(potRow),
    songPotStat: stat, songPot: pot, songDurBase: g.kind === 'buff' || g.kind === 'dummy' ? 120 : g.base || 0, songSkillCap: g.skill != null ? g.skill : null,
    songGift: (c.jp_spent || 0) >= 1200 ? 5 : 0,
    songSing: bare.sing, songWind: bare.wind, songString: bare.string};
}

/* ---- the objectives of a song set (stat_enh.js statDefaultOf, stat_opt.js statRelevant) ---- */
// sets.midcast.Songs.<instrument>: only its range is worn (shared/jobs/brd/functions/logic/midcast_router.lua
// apply_main_instrument; Marsyas and Loughnashade laid for the song that needs them): nothing for the stats optimizer
// to fill. sets.midcast.Songs.Duration (laid on top under Troubadour) stays a set of its own
const songInstrumentSet = s => S.job === 'BRD' && !!s && /^sets\.midcast\.Songs(\.|\[)/.test(s.path) && !/\bDuration\b/.test(s.path);
// A song set's objectives (the player's rules, 2026-11-05): a buff its Song+ (capped), then its length, then damage
// taken; a debuff its landing first (Threnody: its Magic Evasion down next); a filler song the shortest it can be; the
// Troubadour layer its length first
function songObjectives(s){
  const g = songOf(s);
  if (!g) return null;
  if (g.kind === 'dummy') return ['songTimeShort', 'pdtRed', 'mdtRed'];
  if (g.kind === 'debuff') return g.fam === 'threnody' ? ['songAcc', 'songPlus', 'songDurPct'] : ['songAcc', 'songDurPct', 'pdtRed'];
  if (/\bDuration\b/.test(s.path)) return ['songDurPct', 'songPlus', 'pdtRed'];
  return ['songPlus', 'songDurPct', 'pdtRed'];
}
// The floor of a buff song's set: its combined skill at the song's skill cap, past which the potency of BG Wiki's
// tables holds (under it the song is weaker, by how much BG Wiki does not say). A character far under the cap gets
// the skill first (the floor counts before every objective); Tetsouo (448 + 448 without gear) stays over it
function songFloor(s){
  const g = songOf(s);
  return g && g.kind === 'buff' && g.skill ? {min: {songSkill: g.skill}} : null;
}
// What a song set shows and can be after
const songRelevant = () => ['songPlus', 'songPot', 'songDurPct', 'songTime', 'songTimeShort', 'songSkill', 'songAcc', 'pdtRed', 'mdtRed', 'hp'];

Object.assign(T.fr, {statGrp_song: 'Chants',
  statObj_songPlus: 'Song+ (plafonné)', statD_songPlus: 'All songs + le bonus de la famille du set (« Minuet »+1…), jusqu’au plafond de la famille (Minuet, March, Ballad, Scherzo +8, Honor March +4, Madrigal, Minne, Etude… +9 : BG Wiki) ; au-delà, une pièce ne donne plus rien',
  statObj_songPot: 'Puissance du chant', statD_songPot: 'la table de BG Wiki (SongPotency) au Song+ du set, skill au plafond ; mérites et job points du Minuet comptés (5/5, 20/20)',
  statObj_songDurPct: 'Durée du chant (%)', statD_songDurPct: 'durée des pièces + 10 % par Song+ + 5 % du gift (1200 points de job) ; additionnés (BG Wiki Category:Song)',
  statObj_songTime: 'Durée du chant', statD_songTime: '120 s × (1 + durée %) pour un buff, 60 s pour Foe et Horde Lullaby II ; × 2 sous Troubadour ; sans les job points de Clarion Call, Tenuto, Marcato',
  statObj_songTimeShort: 'Durée la plus courte', statD_songTimeShort: 'un chant de remplissage (DummySong) : le plus court possible, pour qu’il soit vite remplacé',
  statObj_songSkill: 'Skill de chant', statD_songSkill: 'Singing + le skill de l’instrument porté (Wind pour un cor, String pour une harpe) : tes skills sans gear + ceux des pièces',
  statObj_songAcc: 'Précision des chants', statD_songAcc: 'CHR + skill de chant + précision magique, chacun compté une fois : BG Wiki dit seulement que la réussite monte avec la CHR et le skill (supposé)'});
Object.assign(T.en, {statGrp_song: 'Songs',
  statObj_songPlus: 'Song+ (capped)', statD_songPlus: 'All songs + the set’s family bonus (“Minuet”+1…), up to the family’s cap (Minuet, March, Ballad, Scherzo +8, Honor March +4, Madrigal, Minne, Etude… +9: BG Wiki); past it, a piece gives nothing',
  statObj_songPot: 'Song potency', statD_songPot: 'BG Wiki’s table (SongPotency) at the set’s Song+, skill at its cap; Minuet merits and job points counted (5/5, 20/20)',
  statObj_songDurPct: 'Song duration (%)', statD_songDurPct: 'the pieces’ duration + 10 % a Song+ + the 5 % gift (1200 job points); added up (BG Wiki Category:Song)',
  statObj_songTime: 'Song duration', statD_songTime: '120 s × (1 + duration %) for a buff, 60 s for Foe and Horde Lullaby II; × 2 under Troubadour; without Clarion Call, Tenuto, Marcato job points',
  statObj_songTimeShort: 'Shortest duration', statD_songTimeShort: 'a filler song (DummySong): as short as it can be, so it is soon replaced',
  statObj_songSkill: 'Song skill', statD_songSkill: 'Singing + the worn instrument’s skill (Wind for a horn, String for a harp): your skills without gear + the pieces’',
  statObj_songAcc: 'Song accuracy', statD_songAcc: 'CHR + song skill + magic accuracy, each counted once: BG Wiki only says landing grows with CHR and skill (assumed)'});

/* ---- the line under a song set's objectives (atelier/src/screens/optimizer/statpage.ts) ---- */
// What a song's potency is called, as the game names the stat (buffs.js SONGS' keys)
const SONG_STAT_FR = {enmity: 'Enmity', atk: 'Attaque', acc: 'Précision', mhaste: 'Haste magique', refresh: 'Refresh (MP/tick)', regen: 'Regen (HP/tick)',
  def: 'DEF', eva: 'Évasion', racc: 'Préc. à distance', str: 'STR', dex: 'DEX', vit: 'VIT', agi: 'AGI', int: 'INT', mnd: 'MND', chr: 'CHR',
  scherzo: 'Scherzo', pdl: 'PDL', meva: 'Éva. magique de la cible −', res_fire: 'Résist. feu', res_ice: 'Résist. glace',
  res_wind: 'Résist. vent', res_earth: 'Résist. terre', res_lightning: 'Résist. foudre', res_water: 'Résist. eau', res_light: 'Résist. lumière', res_dark: 'Résist. ténèbres'};
const SONG_STAT_EN = {enmity: 'Enmity', atk: 'Attack', acc: 'Accuracy', mhaste: 'Magic Haste', refresh: 'Refresh (MP/tick)', regen: 'Regen (HP/tick)',
  def: 'DEF', eva: 'Evasion', racc: 'Ranged Acc.', str: 'STR', dex: 'DEX', vit: 'VIT', agi: 'AGI', int: 'INT', mnd: 'MND', chr: 'CHR',
  scherzo: 'Scherzo', pdl: 'PDL', meva: 'target’s Magic Evasion −', res_fire: 'Fire resist.', res_ice: 'Ice resist.',
  res_wind: 'Wind resist.', res_earth: 'Earth resist.', res_lightning: 'Lightning resist.', res_water: 'Water resist.', res_light: 'Light resist.', res_dark: 'Dark resist.'};
// the songs' stats counted in %
const SONG_PCT = new Set(['mhaste', 'scherzo', 'pdl']);
// The song set's line: the song and its potency, how long it lasts (and under Troubadour), Song+ against its cap and
// what passes it, the skill when under the song's cap (line); what is counted and what is not (more: the Simple view
// shows it as the line's tooltip, sets_simple.js). Null on a set that is no song's
function songNoteParts(s){
  const g = songOf(s);
  if (!g) return null;
  const f = statFigures(s), b = songBase(s) || {}, fr = S.lang === 'fr';
  const num = v => (Math.round(v * 10) / 10).toLocaleString(fr ? 'fr-FR' : 'en-US');
  const time = v => enhTimeText(v), parts = [];
  if (g.kind === 'dummy') return {line: t('songNoteDummy', {d: time(f.songTime)}), more: ''};
  const spell = b.songName || (g.kind === 'debuff' ? t('songNoteDebuffs') : t('songNoteAny'));
  // every stat the song gives at the set's Song+ (Honor March: Haste, Attack and Accuracy), the game's signs and units
  for (const [k, [base, step]] of b.songPots || []) {
    const v = base + f.songPlus * step, name = (fr ? SONG_STAT_FR : SONG_STAT_EN)[k] || k;
    if (!v) continue;
    parts.push(k === 'meva' ? `${name}${num(v)}` : `${name} ${v < 0 ? '−' : '+'}${num(Math.abs(v))}${SONG_PCT.has(k) ? ' %' : ''}`);
  }
  if (g.kind === 'debuff') parts.push(`${t('statObj_songAcc')} ${num(f.songAcc)}`);
  parts.push(f.songTime ? t('songNoteTime', {d: time(f.songTime), t: time(f.songTimeTroub)}) : t('songNoteDurPct', {p: num(f.songDurPct)}));
  parts.push(b.songCap != null ? `Song+ ${f.songPlus}/${b.songCap}` : `Song+ ${f.songPlus}`);
  let line = `${spell} : ${parts.join(' · ')}.`;
  if (f.songLost > 0) line += ' ' + t('songNoteLost', {n: f.songLost});
  if (b.songSkillCap && f.songSkill < b.songSkillCap) line += ' ' + t('songNoteSkill', {k: f.songSkill, c: b.songSkillCap, sp: spell});
  // (only the Minuet's merits and job points are in its potency, buffs.js SONGS)
  return {line, more: t(g.kind !== 'buff' ? 'songNoteLeftDebuff' : g.fam === 'minuet' ? 'songNoteLeft' : 'songNoteLeftAny')};
}
/** The song set's whole line (statpage.ts) */
function songNote(s){
  const p = songNoteParts(s);
  return !p ? '' : p.more ? p.line + ' ' + p.more : p.line;
}
Object.assign(T.fr, {songNoteAny: 'Tout chant sans set à lui', songNoteDebuffs: 'Les chants d’affaiblissement sans set à eux',
  songNoteTime: '{d} ({t} sous Troubadour)', songNoteDurPct: 'durée +{p} %',
  songNoteDummy: 'Chant de remplissage : {d}, le plus court possible pour être vite remplacé. L’instrument reste celui du set (GearSwap le met).',
  songNoteLost: '{n} Song+ perdus au-delà du plafond : une pièce de moins ferait pareil.',
  songNoteSkill: 'Skill de chant {k} / {c} pour {sp} : sous le plafond, la puissance réelle est plus basse (BG Wiki ne donne pas de formule).',
  songNoteLeft: 'Mérites et job points du Minuet comptés (5/5, 20/20), le gift de durée aussi ; pas Soul Voice, Marcato, ni les job points de Clarion Call, Marcato, Tenuto. L’instrument reste celui du set.',
  songNoteLeftAny: 'Le gift de durée compté ; pas Soul Voice, Marcato, ni les job points de Clarion Call, Marcato, Tenuto. L’instrument reste celui du set.',
  songNoteLeftDebuff: 'Pas de taux de réussite : BG Wiki ne donne pas de formule, la précision des chants additionne CHR, skill et précision magique (supposé). L’instrument reste celui du set.'});
Object.assign(T.en, {songNoteAny: 'Any song with no set of its own', songNoteDebuffs: 'The debuff songs with no set of their own',
  songNoteTime: '{d} ({t} under Troubadour)', songNoteDurPct: 'duration +{p} %',
  songNoteDummy: 'Filler song: {d}, as short as can be, so it is soon replaced. The instrument stays the set’s (GearSwap lays it).',
  songNoteLost: '{n} Song+ lost past the cap: one piece fewer would do the same.',
  songNoteSkill: 'Song skill {k} / {c} for {sp}: under the cap, the real potency is lower (BG Wiki gives no formula).',
  songNoteLeft: 'Minuet merits and job points counted (5/5, 20/20), the duration gift too; not Soul Voice, Marcato, nor Clarion Call, Marcato, Tenuto job points. The instrument stays the set’s.',
  songNoteLeftAny: 'The duration gift counted; not Soul Voice, Marcato, nor Clarion Call, Marcato, Tenuto job points. The instrument stays the set’s.',
  songNoteLeftDebuff: 'No landing rate: BG Wiki gives no formula, song accuracy adds CHR, skill and magic accuracy (assumed). The instrument stays the set’s.'});
