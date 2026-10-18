'use strict';
/* GearSwap Atelier - where the character stands, in the Bags view: the zone, the moogles around and the bags the
   game opens there, as the live link's ping says them (`place`: shared/utils/atelier/atelier_place.lua), and where
   the game's moogles are (BG-Wiki). Shown only while the game is connected; it changes nothing.
   Loaded by ../../index.html (after bags_view.js, whose helpers it uses). */

// Where the moogles are: [zone as the game names it, position on the map]. BG-Wiki, pages "Porter Moogle" and
// "Nomad Moogle", read on 2026-10-12. What a Nomad Moogle gives, same page: Mog Safe, Mog Safe 2, Mog Locker,
// Satchel, Sack, Case, wardrobes, delivery box, job change; not the Storage.
const MOOGLE_PLACES = {
  'Porter Moogle': [['Mog Garden', ''], ['Northern San d\'Oria', 'K-8'], ['Bastok Markets', 'I-9'], ['Port Windurst', 'L-6'], ['Lower Jeuno', 'I-6'],
    ['Tavnazian Safehold', 'F-8'], ['Aht Urhgan Whitegate', 'I-11'], ['Western Adoulin', 'H-11'], ['Selbina', 'I-9'], ['Mhaura', 'I-8'], ['Rabao', 'G-8'],
    ['Kazham', 'H-9'], ['Norg', 'G-7'], ['Nashmau', 'H-6'], ['Southern San d\'Oria [S]', 'M-5'], ['Bastok Markets [S]', 'H-7'], ['Windurst Waters [S]', 'L-10'],
    ['Sheol - Gaol', '']],
  'Nomad Moogle': [['Selbina', 'J-9'], ['Mhaura', 'H-8'], ['Rabao', 'G-8'], ['Kazham', 'H-9, I-10'], ['Norg', 'G-7'], ['Tavnazian Safehold', 'F-8'],
    ['Nashmau', 'H-7, G-6'], ['Ru\'Lude Gardens', 'H-5']]};

Object.assign(T.fr, {plHere: 'En jeu', plHouse: 'dans le Mog House', plNear: '{n} à portée', plFar: '{n} à {d} y', plZone: '{n} dans cette zone{p}',
  plWhere: 'Où sont les moogles ?',
  plTip: 'Ce que le jeu dit en ce moment : ta zone et les moogles autour de toi. Les sacs ouverts là où tu es sont allumés, les sacs fermés sont grisés : //gs c bags go ne touche que les sacs ouverts.', plTileOpen: 'Ouvert là où tu es.', plRun: 'Préparer le job', plRunTip: 'Un Porter Moogle est à portée : PorterPacker sort les pièces du job, puis les wardrobes sont rangés et les consommables remplis.',
  plRunWhy: 'Un Porter Moogle est à portée. Cette commande enchaîne tout ce qu’il faut après un changement de job :', plRun1: 'PorterPacker confie au moogle les pièces des autres jobs et reprend celles du job en cours.', plRun2: 'Les wardrobes sont rangés pour ce job (//gs c wo).', plRun3: 'Le lockstyle est remis et les consommables sont remplis.',
  plRunNaked: 'Ton personnage est déshabillé pendant l’opération : reste debout à côté du moogle, hors combat. //po reset arrête PorterPacker.', plRunCmd: 'En jeu, la même chose : //gs c po', plRunGo: 'Lancer', plRunOk: 'C’est parti : PorterPacker, puis les wardrobes et le refill.', plRunNoMoogle: 'Pas de Porter Moogle à portée : wardrobes et refill seulement.', plRunErr: 'Pas lancé : {e}', plGroupOpen: 'disponible ici', plGroupShut: 'fermé ici', plGroupPart: '{n} sur {m} ici', plGroupTip: 'Ce que le jeu ouvre là où tu es en ce moment.', plPorterShut: 'Aucun Porter Moogle à portée.', plPorterOpen: 'Un Porter Moogle est à portée.',
  plNomad: 'Nomad Moogle : il donne le Mog Safe, le Mog Safe 2 et le Mog Locker, pas le Storage, et seulement dans son propre menu de dialogue. Tu peux y ranger à la main ; //gs c bags go ne peut pas s’en servir.',
  plWhereTip: 'La liste des Porter Moogles et des Nomad Moogles du jeu, zone par zone.', plDlgWhy: 'Les zones où se trouve un Porter Moogle ou un Nomad Moogle, avec sa position sur la carte.', plColZone: 'Zone', plYouAre: 'tu es ici',
  plGives: 'Ce que chacun donne', plGivesPorter: ' : garde tes pièces d’équipement contre des Storage Slips, et te les rend.', plGivesNomad: ' : Mog Safe, Mog Safe 2 et Mog Locker, dans son menu de dialogue seulement (à la main) ; aussi delivery box et changement de job. Pas le Storage.', plGivesHouse: ' : tous les sacs du Mog House, Storage compris.',
  plSrc: 'Source : BG-Wiki, pages Porter Moogle et Nomad Moogle, lues le 2026-10-12. Le Nomad Moogle de Ru’Lude Gardens y est noté comme une version particulière.', plTileShut: 'Fermé là où tu es : {w}',
  plWhy_house: 'seulement dans le Mog House', plWhy_off: 'sac non disponible'});
Object.assign(T.en, {plHere: 'In game', plHouse: 'in the Mog House', plNear: '{n} within reach', plFar: '{n} at {d} y', plZone: '{n} in this zone{p}',
  plWhere: 'Where are the moogles?',
  plTip: 'What the game says right now: your zone and the moogles around you. The bags open where you stand are lit, the closed ones are greyed: //gs c bags go only touches the open bags.', plTileOpen: 'Open where you stand.', plRun: 'Get the job ready', plRunTip: 'A Porter Moogle is within reach: PorterPacker takes the job’s pieces out, then the wardrobes are tidied and the consumables refilled.',
  plRunWhy: 'A Porter Moogle is within reach. This command chains everything a job change needs:', plRun1: 'PorterPacker leaves the other jobs’ pieces with the moogle and takes back those of the job loaded.', plRun2: 'The wardrobes are tidied for this job (//gs c wo).', plRun3: 'The lockstyle is put back and the consumables are refilled.',
  plRunNaked: 'Your character is undressed meanwhile: stand beside the moogle, out of combat. //po reset stops PorterPacker.', plRunCmd: 'In game, the same: //gs c po', plRunGo: 'Start', plRunOk: 'Started: PorterPacker, then the wardrobes and the refill.', plRunNoMoogle: 'No Porter Moogle within reach: wardrobes and refill only.', plRunErr: 'Not started: {e}', plGroupOpen: 'available here', plGroupShut: 'closed here', plGroupPart: '{n} of {m} here', plGroupTip: 'What the game opens where you stand right now.', plPorterShut: 'No Porter Moogle within reach.', plPorterOpen: 'A Porter Moogle is within reach.',
  plNomad: 'Nomad Moogle: it gives the Mog Safe, the Mog Safe 2 and the Mog Locker, not the Storage, and only inside its own dialogue menu. You can tidy there by hand; //gs c bags go cannot use it.',
  plWhereTip: 'The list of the game’s Porter Moogles and Nomad Moogles, zone by zone.', plDlgWhy: 'The zones that have a Porter Moogle or a Nomad Moogle, with its position on the map.', plColZone: 'Zone', plYouAre: 'you are here',
  plGives: 'What each one gives', plGivesPorter: ': keeps your pieces of equipment against Storage Slips, and gives them back.', plGivesNomad: ': Mog Safe, Mog Safe 2 and Mog Locker, inside its dialogue menu only (by hand); also delivery box and job change. Not the Storage.', plGivesHouse: ': every bag of the Mog House, the Storage too.',
  plSrc: 'Source: BG-Wiki, pages Porter Moogle and Nomad Moogle, read on 2026-10-12. The Nomad Moogle of Ru’Lude Gardens is noted there as a special version.', plTileShut: 'Closed where you stand: {w}',
  plWhy_house: 'only in the Mog House', plWhy_off: 'bag not available'});

// The place the game last said, while it is connected to this character
const bvPlace = () => { const live = (S._live || {})[S.char]; return live && live.ok && live.place || null; };
const plList = v => Array.isArray(v) ? v : [];
// What makes the view worth drawing again: not the distances, which change at every step
const bvPlaceKey = p => !p ? '' : [p.zone, p.mog_house, plList(p.moogles).map(m => m.name + (m.near ? '!' : '')).join(','), plList(p.bags).filter(b => !b.open).map(b => b.id).join(',')].join('|');
const plWhy = why => t(/Mog House/.test(why || '') ? 'plWhy_house' : 'plWhy_off');
// Why a bag is closed where the character stands ('' when open, or when the game is not connected)
function bvShut(name){
  const p = bvPlace(), bag = p && plList(p.bags).find(b => b.name === name);
  return bag && !bag.open ? plWhy(bag.why) : '';
}
// How a bag's tile is lit: 'open' or 'shut' where the character stands, '' when the game is not connected.
// The Porter Moogle's tile is open with a Porter Moogle within reach.
function bvLit(name){
  const p = bvPlace();
  if (!p) return '';
  if (name === 'Porter Moogle') return plList(p.moogles).some(m => m.name === name && m.near) ? 'open' : 'shut';
  const bag = plList(p.bags).find(b => b.name === name);
  return !bag ? '' : bag.open ? 'open' : 'shut';
}
// Every place of the game's moogles, in a small window: one line a zone, one column a kind of moogle with its
// position on the map; the zone the character stands in is marked
function openMooglePlaces(){
  const kinds = Object.keys(MOOGLE_PLACES), zones = [...new Set(kinds.flatMap(k => MOOGLE_PLACES[k].map(([z]) => z)))], p = bvPlace();
  const cell = (k, z) => { const at = MOOGLE_PLACES[k].find(([n]) => n === z); return `<td class="${at ? 'yes' : ''}">${at ? '✔' + (at[1] ? ` <small>${esc(at[1])}</small>` : '') : '<i>–</i>'}</td>`; };
  const rows = zones.map(z => `<tr class="${p && p.zone === z ? 'here' : ''}"><th>${esc(z)}${p && p.zone === z ? ` <em>${esc(t('plYouAre'))}</em>` : ''}</th>${kinds.map(k => cell(k, z)).join('')}</tr>`).join('');
  const body = `<p>${esc(t('plDlgWhy'))}</p><table class="pltable"><thead><tr><th>${esc(t('plColZone'))}</th>${kinds.map(k => `<th>${esc(k)}</th>`).join('')}</tr></thead><tbody>${rows}</tbody></table>` +
    `<h4>${esc(t('plGives'))}</h4><ul class="plgives"><li><b>Porter Moogle</b>${esc(t('plGivesPorter'))}</li><li><b>Nomad Moogle</b>${esc(t('plGivesNomad'))}</li><li><b>Mog House</b>${esc(t('plGivesHouse'))}</li></ul>` +
    `<p class="muted small">${esc(t('plSrc'))}</p>`;
  showDialog('midlg bpdlg pldlg', esc(t('plWhere')), body, '');
}
// What the chain does, before it is asked: it undresses the character and trades with the Porter Moogle
function openPorterRun(){
  const body = `<p>${esc(t('plRunWhy'))}</p><ol class="plsteps">${['plRun1', 'plRun2', 'plRun3'].map(k => `<li>${esc(t(k))}</li>`).join('')}</ol><p class="bpnote warn">${esc(t('plRunNaked'))}</p><p class="muted small">${esc(t('plRunCmd'))}</p>`;
  showDialog('midlg bpdlg pldlg', esc(t('plRun')), body, `<button class="btn" data-plrungo ${liveOk() ? '' : 'disabled'}>${esc(t('plRunGo'))}</button>`);
}
async function porterRun(){
  let r; try { r = await liveOrder(S.char, '/porter_run', {method: 'POST', body: '', timeout: 6000}); } catch (e) { r = {ok: false, error: e.message}; }
  closeOverlay();
  S.toast = r && r.ok ? t(r.porter ? 'plRunOk' : 'plRunNoMoogle') : t('plRunErr', {e: (r && r.error) || '?'}); render();
}
document.addEventListener('click', e => { if (e.target.closest('[data-plwhere]')) openMooglePlaces(); else if (e.target.closest('[data-plrungo]')) porterRun(); else if (e.target.closest('[data-plrun]')) openPorterRun(); });
