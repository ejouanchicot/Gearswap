// GearSwap Atelier · bags_plan.js: the tidy-up plan of the Bags view (bags_view.js), in theory only: nothing moves.
// Every bag has a role (bags_view.js bvRole); every thing gets a category, by itself when the page can tell (a piece a
// set wears, a consumable, a crystal, a slip), from the bag it sits in today when that bag has a role, else by the
// player, who picks things in the list and files them in one click (S.bagTags, kept in the browser by character).
// The plan then counts, category by category, what must be housed against the room of the bags of that role, and says
// where it fits, where it does not, and what is still to file.
// (loaded by atelier/index.html after bags_view.js)

Object.assign(T.fr, {bpPlan: 'Le plan', bpPlanTip: 'Le calcul du rangement : ce que chaque rôle doit loger face à la place de ses sacs. Rien ne bouge en jeu.', bpTitle: 'Le plan de rangement, en théorie',
  bpWhy: 'Chaque objet a une catégorie ; chaque catégorie va dans les sacs qui ont ce rôle. La page compte ce qu’il faut loger face à la place qu’il y a. L’inventaire et le Porter Moogle sont laissés comme ils sont.',
  bpCol: 'Catégorie', bpNeed: 'À loger', bpRoom: 'Place', bpBags: 'Sacs', bpMove: 'À déplacer', bpOk: 'ça rentre', bpOver: 'il manque {n} place(s)', bpNoBag: 'aucun sac n’a ce rôle', bpLeft: '{n} libre(s) après',
  bpC_job: 'Job en cours', bpC_gear: 'Équipement des autres jobs', bpC_lock: 'Lockstyle', bpC_spare: 'Lockstyle et surplus', bpC_craft: 'Craft et pêche', bpC_unused: 'Ce qui ne sert pas (et ne peut pas partir)', bpC_mule: 'À envoyer sur une mule', bpC_npc: 'À déposer chez un NPC', bpNpcNote: 'Seals, crests, vouchers, Rem’s Tales, pierres d’augment, wings : un NPC les garde pour toi, aucun sac à prévoir. La bulle de chaque objet dit quel NPC.', bpNpcAt: 'À déposer chez : {n}', bpMuleNote: 'Dans aucun set, et le jeu permet de l’envoyer à un autre de tes persos.', bpFrees: 'libère {n} place(s)', bpC_usable: 'Consommables', bpC_mats: 'À vendre et composants de craft',
  bpC_currency: 'Currencies', bpC_keys: 'Objets clés (améliorations, accès)', bpC_furnish: 'Meubles et rangement', bpC_unknown: 'Non classé',
  bpJobNote: 'Le job le plus chargé ({j}) prend {n} emplacements ; en {c} : {m}.', bpGearNote: 'Tout ce qu’un set porte, moins le job en cours. Ce qui dépasse va dans « lockstyle et surplus ».', bpSpareNote: 'Dont {n} de surplus venu de l’équipement des autres jobs.',
  bpPorter: 'Le Porter Moogle n’est pas compté : ce qui y est rangé y reste. {n} pièce(s) qu’un set porte s’y trouvent, à ressortir le jour où tu joues ces jobs.',
  bpUnknown: '{n} objet(s) ne sont pas classés. Ouvre « Tous les sacs », filtre « Non classé », sélectionne-les et range-les dans une catégorie.', bpAllGood: 'Tout est classé.',
  bpTo_mule: 'mule', bpTo_npc: 'NPC', bpOpen: 'Préparer {n} déplacement(s) pour le jeu', bpOpenTip: 'Montre ce qui irait d’où à où, puis l’envoie au jeu. Rien ne bouge tant que tu n’as pas tapé la commande en jeu.',
  bpSendTitle: 'Le rangement à faire en jeu', bpSendWhy: 'Voici ce que le plan déplacerait. La page envoie cette liste au jeu ; c’est toi qui la lances, en jeu.',
  bpSafe1: 'Le jeu ne fait que déplacer un objet d’un sac à un autre. Il ne jette, ne vend, n’envoie et n’utilise jamais rien.', bpSafe2: 'Un objet à la fois : il sort de son sac, le jeu confirme, il entre dans le bon sac, le jeu confirme. Sans confirmation, tout s’arrête.',
  bpSafe3: 'Une pièce portée, un sac plein ou un sac du Mog House hors du Mog House : ce déplacement est sauté, et dit.', bpSafe4: 'Chaque déplacement est écrit dans le fichier atelier/bag_moves.log de ton perso.',
  bpSendN: '{n} déplacement(s)', bpSendNone: 'Rien à déplacer : tout ce que la page sait ranger est à sa place.', bpSendNoRoom: '{n} objet(s) n’ont pas de place dans leurs sacs et ne seront pas déplacés : {l}.',
  bpSendGo: 'Envoyer au jeu', bpSendTip: 'Envoie la liste. Ensuite, en jeu : //gs c bags pour la voir, //gs c bags go pour la lancer.', bpSent: 'Plan envoyé : {n} déplacement(s). En jeu, tape //gs c bags pour voir ce qui est prêt (rien ne bouge), puis //gs c bags go pour lancer, //gs c bags stop pour arrêter.',
  bpSendFail: 'Le jeu n’a pas répondu : le plan n’a pas été envoyé.', bpLockOf: 'Lockstyle n° {l}', bpSee: 'Voir', bpSeeCat: 'Voir : {c}', bpMoveN: '{n} à déplacer', bpStOk: 'Ton rangement tient', bpStOkWhy: 'chaque catégorie a assez de place dans ses sacs', bpStBad: '{n} catégorie(s) ne rentrent pas',
  bpChUnk: ' non classé(s)', bpChWrong: ' mal rangé(s)', bpChMule: ' pour la mule', bpChNpc: ' à déposer chez un NPC', bpChPlan: 'Voir le plan', bpPc: 'Catégorie du plan', bpPcTip: 'N’affiche que les objets que le plan range dans cette catégorie.', bpUnk: 'Non classé', bpSel: '{n} sélectionné(s) : ranger dans', bpSelAll: 'Tout sélectionner ({n} affichés)', bpSelNone: 'Désélectionner', bpAuto: 'Automatique', bpAutoTip: 'Oublie ton choix : la page reclasse toute seule.',
  bpPickTip: 'Clique pour sélectionner, puis range la sélection dans une catégorie.', bpCatTip: 'Catégorie : {c}{m}', bpByYou: ' (choisie par toi)'});
Object.assign(T.en, {bpPlan: 'The plan', bpPlanTip: 'The tidy-up sum: what each role must house against the room of its bags. Nothing moves in game.', bpTitle: 'The tidy-up plan, in theory',
  bpWhy: 'Every item has a category; every category goes to the bags of that role. The page counts what must be housed against the room there is. The inventory and the Porter Moogle are left as they are.',
  bpCol: 'Category', bpNeed: 'To house', bpRoom: 'Room', bpBags: 'Bags', bpMove: 'To move', bpOk: 'it fits', bpOver: '{n} slot(s) short', bpNoBag: 'no bag has this role', bpLeft: '{n} free after',
  bpC_job: 'Job loaded', bpC_gear: 'The other jobs’ gear', bpC_lock: 'Lockstyle', bpC_spare: 'Lockstyle and overflow', bpC_craft: 'Crafting and fishing', bpC_unused: 'What is not used (and cannot leave)', bpC_mule: 'To send to a mule', bpC_npc: 'To hand to an NPC', bpNpcNote: 'Seals, crests, vouchers, Rem’s Tales, augment stones, wings: an NPC keeps them for you, no bag to plan. Each item’s tooltip says which NPC.', bpNpcAt: 'To hand to: {n}', bpMuleNote: 'In no set, and the game lets it be sent to another of your characters.', bpFrees: 'frees {n} slot(s)', bpC_usable: 'Consumables', bpC_mats: 'To sell and crafting materials',
  bpC_currency: 'Currencies', bpC_keys: 'Key items (upgrades, entries)', bpC_furnish: 'Furniture and storage', bpC_unknown: 'Not filed',
  bpJobNote: 'The heaviest job ({j}) takes {n} slots; on {c}: {m}.', bpGearNote: 'Everything a set wears, less the job loaded. What overflows goes to "lockstyle and overflow".', bpSpareNote: 'Of which {n} overflow from the other jobs’ gear.',
  bpPorter: 'The Porter Moogle is not counted: what is stored there stays there. {n} piece(s) a set wears are there, to take back the day you play those jobs.',
  bpUnknown: '{n} item(s) are not filed. Open "All the bags", filter "Not filed", select them and file them in a category.', bpAllGood: 'Everything is filed.',
  bpTo_mule: 'mule', bpTo_npc: 'NPC', bpOpen: 'Prepare {n} move(s) for the game', bpOpenTip: 'Shows what would go from where to where, then sends it to the game. Nothing moves until you type the command in game.',
  bpSendTitle: 'The tidy-up to do in game', bpSendWhy: 'This is what the plan would move. The page sends this list to the game; you start it, in game.',
  bpSafe1: 'The game only moves an item from a bag to another. It never drops, sells, sends or uses anything.', bpSafe2: 'One item at a time: out of its bag, the game confirms, into the right bag, the game confirms. With no confirmation, everything stops.',
  bpSafe3: 'A piece worn, a full bag or a Mog House bag outside the Mog House: that move is skipped, and said.', bpSafe4: 'Every move is written to your character’s atelier/bag_moves.log file.',
  bpSendN: '{n} move(s)', bpSendNone: 'Nothing to move: everything the page can place is where it should be.', bpSendNoRoom: '{n} item(s) have no room in their bags and will not be moved: {l}.',
  bpSendGo: 'Send to the game', bpSendTip: 'Sends the list. Then, in game: //gs c bags to see it, //gs c bags go to play it.', bpSent: 'Plan sent: {n} move(s). In game, type //gs c bags to see what is ready (nothing moves), then //gs c bags go to play it, //gs c bags stop to stop.',
  bpSendFail: 'The game did not answer: the plan was not sent.', bpLockOf: 'Lockstyle no. {l}', bpSee: 'See', bpSeeCat: 'See: {c}', bpMoveN: '{n} to move', bpStOk: 'Your tidy-up fits', bpStOkWhy: 'every category has enough room in its bags', bpStBad: '{n} category(ies) do not fit',
  bpChUnk: ' not filed', bpChWrong: ' misplaced', bpChMule: ' for the mule', bpChNpc: ' to hand to an NPC', bpChPlan: 'See the plan', bpPc: 'Plan category', bpPcTip: 'Shows only the items the plan files in this category.', bpUnk: 'Not filed', bpSel: '{n} selected: file in', bpSelAll: 'Select all ({n} shown)', bpSelNone: 'Clear', bpAuto: 'Automatic', bpAutoTip: 'Forgets your choice: the page files it by itself again.',
  bpPickTip: 'Click to select, then file the selection in a category.', bpCatTip: 'Category: {c}{m}', bpByYou: ' (your choice)'});

// The categories a thing can be filed in, and the roles of the bags each goes to (the first roles first)
const BP_CATS = ['gear', 'lock', 'craft', 'unused', 'mule', 'npc', 'usable', 'mats', 'currency', 'keys', 'furnish'];
const BP_ROLES = {gear: ['job', 'gear', 'spare'], lock: ['spare'], craft: ['craft'], unused: ['unused'], usable: ['usable'], mats: ['mats'], currency: ['currency'], keys: ['keys'], furnish: ['furnish', 'slips']};
// The category a bag's role suggests for what sits in it today
const BP_HINT = {craft: 'craft', unused: 'unused', archive: 'unused', usable: 'usable', mats: 'mats', currency: 'currency', keys: 'keys', furnish: 'furnish', slips: 'furnish'};
const bpTags = () => (S.bagTags || {})[S.char] || {};
// Whether a thing can be sent to another character of the player's: the export says so (bags from 2026-10-11 on),
// else the gear catalog for a piece (not Ex, or Ex that the account's characters can share)
function bpSendable(B, r){
  if (r.info.send != null) return !!r.info.send;
  const c = typeof catalog === 'function' && catalog(); return !!c && !!c.row[r.info.name] && (!c.ex.has(r.info.name) || c.alt.has(r.info.name));
}
// What an NPC keeps for the player, so that it takes no bag: [the item names, the NPC and where]. From BG-Wiki,
// Inventory 101 (read 2026-10-11): Shami, the Records of Eminence NPCs, Greyson, Monisette, Oseem, Divainy-Gamainy,
// Lola, Lorissa. (Crystals and clusters go to an Ephemeral Moogle too: left with the crafting materials here.)
const BP_NPC = [
  [/^(Beastmen's Seal|Kindred's Seal|Kindred's Crest|H\. Kindred Crest|S\. Kindred Crest)$/, 'Shami, Port Jeuno (H-8)'],
  [/^Copper Voucher$/, 'Rolandienne (Southern San d\'Oria G-10), Isakoth (Bastok Markets E-11), Fhelm Jobeizat (Windurst Woods J-10), Eternal Flame (Western Adoulin H-11)'],
  [/^Silver Voucher$/, 'Greyson, Lower Jeuno (G-11)'],
  [/^Rem's Tale Ch\.\d+$/, 'Monisette, Port Jeuno (I-8)'],
  [/^(Pellucid|Taupe|Fern) Stone$/, 'Oseem, Norg (I-7)'],
  [/^(Snow|Leaf|Dusk)(slit|tip|dim|orb) Stone( \+[12])?$/, 'Divainy-Gamainy, Western Adoulin (J-10)'],
  [/^(Lebondopt|Pulchridopt) Wing$/, 'Lola, Eastern Adoulin (G-8)'],
  [/^Mellidopt Wing$/, 'Lorissa, Yorcia Weald (I-10)'],
];
// The key items the page knows by name: what is traded to upgrade gear or to enter a fight. (Alabaster and Murky
// Matter: traded at the furnace of the new Limbus to upgrade its weapons, armour and accessories; the player, 2026-10-11)
const BP_KEYS = /^(Alabaster|Murky) Matter$/;
// The closed containers of a currency: Beitetsu (parcel, box), Pluton (case, box), Riftborn Boulder (case, box), and the
// pouches of Heavy Metal, Silt and Beads (the player, 2026-10-11)
const BP_BOXES = /^(Beitetsu (Parcel|Box)|Pluton (Case|Box)|Boulder (Case|Box)|Hvy\. Metal Pouch|Silt Pouch|Bead Pouch)$/;
// Crafting materials the game does not tell from the rest (the alabaster parts: the player, 2026-10-11)
const BP_MATS = /^Ala\. Part /;
const bpNpc = name => (BP_NPC.find(([re]) => re.test(name)) || [])[1] || '';
// The pieces of the lockstyle sets the game was seen to apply (export `lock_pieces`: shared/utils/lockstyle/
// lockstyle_pieces.lua): {item id: ['4 (WAR)', ...]}
let BP_LOCK = null;
function bpLock(){
  const key = DATA_GEN + '|' + S.char;
  if (BP_LOCK && BP_LOCK.key === key) return BP_LOCK.by;
  const x = latestExport(S.char, 'lock_pieces'), by = {};
  for (const [set, v] of Object.entries((x && x.lock_pieces) || {})) for (const it of v.items || []) (by[it.id] = by[it.id] || []).push(set + (v.job ? ' (' + v.job + ')' : ''));
  BP_LOCK = {key, by};
  return by;
}
// A thing's category: the player's choice, else what the page can tell, else what its bag suggests, else 'unknown'
function bpCat(B, r){
  const mine = bpTags()[r.id]; if (mine) return mine;
  const hint = () => { for (const w of r.where) { const bag = B.bags.find(b => b.name === w.bag), h = bag && bvRoles(B, bag).map(x => BP_HINT[x]).find(Boolean); if (h) return h; } return ''; };
  if (bvIsGear(r)) {
    // what sits only in a crafting bag is crafting gear, whatever set wears it (the craft and fishing sets)
    const home = r.where.filter(w => w.bag !== 'Porter Moogle').map(w => B.bags.find(b => b.name === w.bag)).filter(Boolean);
    if (home.length && home.every(b => bvRoles(B, b).includes('craft'))) return 'craft';
    if (Object.keys(r.use.jobs).length) return 'gear';
    if (bpLock()[r.id]) return 'lock';                // worn by no set, but by a lockstyle: kept for its look
    // a piece no set wears, in no bag with a say of its own (crafting), that can go to another character: a mule's
    // (a piece is no consumable, material or currency, whatever bag it lies in: only a crafting bag speaks for it)
    const h = hint(); return h === 'craft' ? h : bpSendable(B, r) ? 'mule' : 'unused';
  }
  if (/^Storage Slip/.test(r.info.name)) return 'furnish';
  // seals, crests and vouchers are handed to an NPC that keeps them: they wait in the inventory, they are not housed
  if (bpNpc(r.info.name)) return 'npc';
  if (BP_KEYS.test(r.info.name)) return 'keys';
  if (BP_MATS.test(r.info.name)) return 'mats';
  if (/(Crystal|Cluster)$/.test(r.info.name)) return 'mats';
  // a currency kept in its closed container (it takes less room than opened): filed as currency, not as a consumable.
  // By name, not by ending: a Bullet Pouch, a Card Case or an Old Bolt Box holds ammunition
  if (BP_BOXES.test(r.info.name)) return 'currency';
  return hint() || (r.info.cat === 'Usable' ? 'usable' : 'unknown');
}
const bpCatName = c => t('bpC_' + c);
// Where a thing should go: the bags whose role takes its category (their short names), else the category's own name
// (a mule, an NPC, or a category no bag has the role of yet)
function bpDest(B, r){
  const cat = bpCat(B, r), roles = BP_ROLES[cat] || [], bags = B.bags.filter(b => b.max && bvRoles(B, b).some(x => roles.includes(x))).map(b => bvShort(b.name));
  return bags.length ? bags.slice(0, 3).join(', ') + (bags.length > 3 ? '…' : '') : cat === 'mule' || cat === 'npc' ? t('bpTo_' + cat) : bpCatName(cat);
}
// The plan: one line a role group, {id, need, room, bags, move, note}
function bpPlan(B){
  const where = bvWhere(B), rows = bvRows(B, 'all', where), kept = n => n !== 'Inventory' && n !== 'Porter Moogle';
  const roleOf = Object.fromEntries(B.bags.map(b => [b.name, bvRoles(B, b)])), fits = (name, roles) => (roleOf[name] || []).some(x => roles.includes(x)), bagsOf = roles => B.bags.filter(b => b.max && fits(b.name, roles));
  const room = roles => bagsOf(roles).reduce((n, b) => n + b.max, 0);
  // what a row takes outside the inventory and the Porter Moogle, and what of it is not in a bag of the right role
  const slots = r => r.where.filter(w => kept(w.bag)).reduce((n, w) => n + w.slots, 0), off = (r, roles) => r.where.filter(w => kept(w.bag) && !fits(w.bag, roles)).reduce((n, w) => n + w.slots, 0);
  const by = {}; for (const r of rows) (by[bpCat(B, r)] = by[bpCat(B, r)] || []).push(r);
  const sum = (list, f) => (list || []).reduce((n, r) => n + f(r), 0), gear = by.gear || [];
  // the job loaded: every job must fit in its bags, the heaviest decides
  const perJob = bvUsage().jobs.map(j => [j, sum(gear.filter(r => r.use.jobs[j]), slots)]).sort((a, b) => b[1] - a[1]), heavy = perJob[0] || ['—', 0], cur = (perJob.find(x => x[0] === S.job) || [S.job, 0])[1];
  const others = Math.max(0, sum(gear, slots) - cur), gearRoom = room(['gear']), spill = Math.max(0, others - gearRoom), lock = sum(by.lock, slots);
  const line = (id, need, roles, list, note) => ({id, need, room: room(roles), names: bagsOf(roles).map(b => b.name), bags: bagsOf(roles).map(b => bvShort(b.name)), move: sum(list, r => off(r, BP_ROLES[id] || roles)), note});
  const out = [
    Object.assign(line('job', heavy[1], ['job'], []), {move: null, note: t('bpJobNote', {j: heavy[0], n: heavy[1], c: S.job, m: cur})}),
    Object.assign(line('gear', others - spill, ['gear'], gear), {note: t('bpGearNote')}),
    Object.assign(line('spare', lock + spill, ['spare'], by.lock), {note: spill ? t('bpSpareNote', {n: spill}) : ''}),
    ...['craft', 'unused', 'usable', 'mats', 'currency', 'keys', 'furnish'].map(c => line(c, sum(by[c], slots), BP_ROLES[c], by[c]))];
  // the categories that share a bag (a bag with two roles) are one line: their things against the room they share
  for (let i = 4; i < out.length; i++) for (let j = i + 1; j < out.length; j++) if (out[i].names.some(n => out[j].names.includes(n))) {
    const a = out[i], b = out.splice(j, 1)[0], names = [...new Set([...a.names, ...b.names])];
    out[i] = {id: a.id, ids: [...(a.ids || [a.id]), ...(b.ids || [b.id])], need: a.need + b.need, names, bags: names.map(bvShort), room: names.reduce((n, x) => n + B.bags.find(g => g.name === x).max, 0), move: a.move + b.move};
    j = i; }
  // what leaves for a mule or waits for an NPC is not housed: it frees room
  out.splice(5, 0, {id: 'mule', need: sum(by.mule, slots), room: 0, bags: [], names: [], move: null, free: true, note: t('bpMuleNote')},
    {id: 'npc', need: sum(by.npc, r => r.where.reduce((n, w) => n + w.slots, 0)), room: 0, bags: [], names: [], move: null, free: true, note: t('bpNpcNote')});
  const porter = sum(gear, r => r.where.filter(w => w.bag === 'Porter Moogle').reduce((n, w) => n + w.slots, 0));
  return {lines: out, unknown: (by.unknown || []).length, porter};
}
function bpLineBad(l){ return !l.free && l.need > 0 && (!l.room || l.need > l.room); }
// One category of the plan as a card: its name, a gauge of what must be housed against the room, the bags, the verdict
function bpCardHTML(l){
  const name = (l.ids || [l.id]).map(bpCatName).join(' + '), bad = bpLineBad(l), pct = l.room ? Math.min(100, Math.round(100 * l.need / l.room)) : 0;
  const see = (l.ids || [l.id]).filter(c => BP_CATS.includes(c)).map(c => `<button class="linkbtn" data-bpsee="${c}">${esc(t('bpSeeCat', {c: bpCatName(c)}))}</button>`).join('');
  const verdict = l.free ? `<b class="ok">${esc(t('bpFrees', {n: l.need}))}</b>` : !l.room ? `<b class="bad">${esc(t('bpNoBag'))}</b>` : l.need > l.room ? `<b class="bad">${esc(t('bpOver', {n: l.need - l.room}))}</b>`
    : `<b class="ok">${esc(t('bpOk'))}</b><span>${esc(t('bpLeft', {n: l.room - l.need}))}</span>`;
  return `<div class="bpcard ${bad ? 'bad' : l.free ? 'free' : pct >= 90 ? 'tight' : 'ok'}"><h4>${esc(name)}</h4>` +
    (l.free ? `<p class="bpbig">${l.need}</p>` : `<p class="bpbig">${l.need}<i>/ ${l.room || '—'}</i></p><span class="bpgauge"><i style="width:${pct}%"></i></span>`) +
    `<p class="bpverdict">${verdict}</p>` +
    (l.bags.length ? `<p class="bpbags">${l.bags.map(b => `<i>${esc(b)}</i>`).join('')}</p>` : '') +
    (l.move ? `<p class="bpmove">${esc(t('bpMoveN', {n: l.move}))}</p>` : '') + (l.note ? `<p class="bpwhy">${esc(l.note)}</p>` : '') + (see ? `<p class="bpsee">${see}</p>` : '') + `</div>`;
}
// The state of the tidy-up in one line, over the list whatever is shown: does it all fit, what is left to do
function bpStatusHTML(B){
  const p = bpPlan(B), bad = p.lines.filter(bpLineBad), where = bvWhere(B), wrong = bvRows(B, 'all', where).filter(r => r.bad.length).length;
  const get = id => (p.lines.find(l => l.id === id) || {need: 0}).need, chip = (n, key, attr, cls) => n ? `<button class="bpchip ${cls || ''}" ${attr}><b>${n}</b>${esc(t(key))}</button>` : '';
  return `<div class="bpstatus ${bad.length ? 'bad' : 'ok'}"><span class="bpmain"><i aria-hidden="true">${bad.length ? '✖' : '✔'}</i><b>${esc(bad.length ? t('bpStBad', {n: bad.length}) : t('bpStOk'))}</b>` +
    `<small>${esc(bad.length ? bad.map(l => (l.ids || [l.id]).map(bpCatName).join(' + ')).join(' · ') : t('bpStOkWhy'))}</small></span>` +
    chip(p.unknown, 'bpChUnk', 'data-bpunk', 'warn') + chip(wrong, 'bpChWrong', 'data-bpwrong', 'warn') + chip(get('mule'), 'bpChMule', 'data-bpsee="mule"') + chip(get('npc'), 'bpChNpc', 'data-bpsee="npc"') +
    `<button class="btn ghost" data-bagsel="plan">${esc(t('bpChPlan'))}</button></div>`;
}
function renderBagPlan(B){
  const p = bpPlan(B), shown = p.lines.filter(l => l.need || l.room);
  const n = bpMoves(B).moves.length;
  return `<div class="bpplan"><div class="bpsendbar"><p class="muted small">${esc(t('bpWhy'))}</p><button class="btn" data-bpopen ${n ? '' : 'disabled'} title="${esc(t('bpOpenTip'))}">${esc(t('bpOpen', {n}))}</button></div>${S.toast ? `<p class="toast">${esc(S.toast)}</p>` : ''}<div class="bpcards">${shown.map(bpCardHTML).join('')}</div>` +
    `<p class="bpnote ${p.unknown ? 'warn' : ''}">${esc(p.unknown ? t('bpUnknown', {n: p.unknown}) : t('bpAllGood'))}${p.unknown ? ` <button class="linkbtn" data-bpunk>${esc(t('bpSee'))}</button>` : ''}</p>` +
    (p.porter ? `<p class="bpnote">${esc(t('bpPorter', {n: p.porter}))}</p>` : '') + `</div>`;
}
// The bar over the list while things are selected: the categories to file them in
function bpSelBarHTML(shown){
  const n = (S._bagPick || new Set()).size;
  const all = `<button class="btn ghost" data-bpall>${esc(t('bpSelAll', {n: shown}))}</button>`;
  if (!n) return `<div class="bpsel idle"><span class="muted small">${esc(t('bpPickTip'))}</span><span class="sp"></span>${all}</div>`;
  return `<div class="bpsel"><b>${esc(t('bpSel', {n}))}</b>${BP_CATS.map(c => `<button class="bpcat" data-bptag="${c}">${esc(bpCatName(c))}</button>`).join('')}` +
    `<button class="bpcat auto" data-bptag="" title="${esc(t('bpAutoTip'))}">${esc(t('bpAuto'))}</button><span class="sp"></span>${all}<button class="btn ghost" data-bpnone>${esc(t('bpSelNone'))}</button></div>`;
}
document.addEventListener('click', e => {
  const b = e.target.closest('[data-bptag],[data-bpall],[data-bpnone],[data-bpunk],[data-bpwrong],[data-bpsee],[data-bpick]'); if (!b) return; const d = b.dataset;
  S._bagPick = S._bagPick || new Set();
  if (d.bpsee) { S.bagSel = 'all'; S.bagUse = 'all'; S.bagCat = 'all'; S.bagQ = ''; S.bagPc = d.bpsee; save(); render(); return; }
  if ('bpwrong' in d) { S.bagSel = 'all'; S.bagUse = 'bad'; S.bagCat = 'all'; S.bagQ = ''; S.bagPc = ''; save(); render(); return; }
  if ('bpunk' in d) { S.bagSel = 'all'; S.bagUse = 'unk'; S.bagCat = 'all'; S.bagQ = ''; S.bagPc = ''; save(); render(); return; }
  if ('bpnone' in d) { S._bagPick.clear(); render(); return; }
  if ('bpall' in d) { document.querySelectorAll('#bvlist [data-bpick]').forEach(el => S._bagPick.add(el.dataset.bpick)); render(); return; }
  if (d.bpick) { if (S._bagPick.has(d.bpick)) S._bagPick.delete(d.bpick); else S._bagPick.add(d.bpick); b.classList.toggle('picked');
    const bar = document.getElementById('bpsel'); if (bar) bar.innerHTML = bpSelBarHTML(document.querySelectorAll('#bvlist [data-bpick]').length); return; }
  // file the selection: by item (every copy of it), kept by character
  const tags = Object.assign({}, bpTags()); for (const id of S._bagPick) { if (d.bptag) tags[id] = d.bptag; else delete tags[id]; }
  S.bagTags = Object.assign({}, S.bagTags, {[S.char]: tags}); S._bagPick.clear(); save(); render();
});

/* ---- the moves of the plan, sent to the game ---- */
// What would move: every thing that is not where it should be and has a bag to go to, one line a slot
// {id, name, from, to (bag ids), fromName, toName}. A bag's room is counted down as the moves fill it; a thing that
// finds no room is left out and counted. Nothing goes to a mule or an NPC here: that is the player's to do.
function bpMoves(B){
  const where = bvWhere(B), rows = bvRows(B, 'all', where), free = {}, moves = [], noRoom = [];
  for (const b of B.bags) if (b.max) free[b.name] = b.max - (b.count != null ? b.count : b.items.length);
  for (const r of rows) {
    const cat = bpCat(B, r), roles = BP_ROLES[cat]; if (!roles || !r.bad.length) continue;
    // a piece the job loaded wears goes to its bags first; any other piece to the other jobs' bags first
    const order = cat === 'gear' ? (r.use.jobs[S.job] ? ['job', 'gear', 'spare'] : ['gear', 'spare', 'job']) : roles;
    const homes = order.flatMap(role => B.bags.filter(b => b.max && bvRoles(B, b).includes(role)));
    for (const bad of r.bad) { const from = B.bags.find(b => b.name === bad.bag), n = (r.where.find(w => w.bag === bad.bag) || {slots: 0}).slots;
      if (!from || from.id < 0) continue;
      // never to a bag where it would be out of place again
      const fits = b => bvRoles(B, b).some(role => !bvWrong(r, b.name, role));
      for (let i = 0; i < n; i++) { const to = homes.find(b => b.name !== from.name && free[b.name] > 0 && fits(b));
        if (!to) { noRoom.push(r.info.name); continue; }
        free[to.name]--; free[from.name]++;
        moves.push({id: r.id, name: r.info.name, from: from.id, to: to.id, fromName: from.name, toName: to.name}); } }
  }
  return {moves, noRoom};
}
// The window before sending: what goes from where to where, then the send
function openBagPlanSend(){
  const B = bvBags(), p = bpMoves(B), by = {};
  for (const m of p.moves) (by[m.fromName + ' → ' + m.toName] = by[m.fromName + ' → ' + m.toName] || []).push(m.name);
  const groups = Object.entries(by).sort((a, b) => b[1].length - a[1].length).map(([k, names]) => `<details class="bpgo"><summary><b>${esc(k)}</b><i>${names.length}</i></summary><p>${esc(names.join(', '))}</p></details>`).join('');
  const body = `<p>${esc(t('bpSendWhy'))}</p><ul class="bpsafe">${['bpSafe1', 'bpSafe2', 'bpSafe3', 'bpSafe4'].map(k => `<li>${esc(t(k))}</li>`).join('')}</ul>` +
    (p.moves.length ? `<h4>${esc(t('bpSendN', {n: p.moves.length}))}</h4>${groups}` : `<p class="muted">${esc(t('bpSendNone'))}</p>`) +
    (p.noRoom.length ? `<p class="bpnote warn">${esc(t('bpSendNoRoom', {n: p.noRoom.length, l: [...new Set(p.noRoom)].slice(0, 12).join(', ')}))}</p>` : '');
  showDialog('midlg bpdlg', esc(t('bpSendTitle')), body, p.moves.length ? `<button class="btn" data-bpsend ${liveOk() ? '' : 'disabled'} title="${esc(liveOk() ? t('bpSendTip') : t('ttModRead'))}">${esc(t('bpSendGo'))}</button>` : '');
}
async function bpSend(){
  const p = bpMoves(bvBags()), body = p.moves.map(m => [m.id, m.from, m.to, m.name.replace(/[\t\r\n]/g, ' ')].join('\t')).join('\n');
  let r; try { r = await liveOrder(S.char, '/bag_plan', {method: 'POST', body, timeout: 5000}); } catch (e) { r = null; }
  closeOverlay();
  S.toast = r && r.ok ? t('bpSent', {n: r.moves}) : t('bpSendFail'); render();
}
document.addEventListener('click', e => { const b = e.target.closest('[data-bpopen],[data-bpsend]'); if (!b) return; if ('bpsend' in b.dataset) bpSend(); else openBagPlanSend(); });
