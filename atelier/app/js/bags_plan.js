// GearSwap Atelier · bags_plan.js: the tidy-up plan of the Bags view (bags_view.js), in theory only: nothing moves.
// Every bag has a role (bags_view.js bvRole); every thing gets a category, by itself when the page can tell (a piece a
// set wears, a consumable, a crystal, a slip), from the bag it sits in today when that bag has a role, else by the
// player, who picks things in the list and files them in one click (S.bagTags, kept in the browser by character).
// The plan then counts, category by category, what must be housed against the room of the bags of that role, and says
// where it fits, where it does not, and what is still to file.
// (loaded after bags_view.js: see atelier/src/legacy/files.ts)

Object.assign(T.fr, {bpPlan: 'Le plan', bpPlanTip: 'Le calcul du rangement : ce que chaque rôle doit loger face à la place de ses sacs. Rien ne bouge en jeu.', bpTitle: 'Le plan de rangement', bpWhyS: 'Chaque carte : ce que ses sacs contiennent aujourd’hui, ce que le rangement en sort et y amène. Passe la souris sur une carte pour le détail.',
  bpWhy: 'Chaque objet a une catégorie ; chaque catégorie va dans les sacs qui ont ce rôle. Chaque carte montre ce que ses sacs contiennent aujourd’hui, ce que le rangement en sort et y amène, et ce qui n’a pas trouvé de place : c’est exactement ce que la commande en jeu déplacera. L’inventaire est rangé aussi, sauf ce que tu y portes pour t’en servir : l’équipement de tes sets, les pièces à activer, les consommables, et ce que tu classes en « à garder sur moi ». Le Porter Moogle est laissé comme il est.',
  bpOk: 'ça rentre', bpDone: 'déjà rangé', bpOver: '{n} objet(s) sans place', bpJobOver: 'le job le plus chargé dépasse de {n}', bpOutN: '{n} sortent', bpInN: '{n} arrivent', bpAfterN: '{n} après', bpNowTip: 'Ce que ces sacs contiennent aujourd’hui, face à leur place.', bpNoRoomS: 'pas de place', bpReserve: '{n} emplacement(s) gardé(s) pour les Storage Slips (01 à 33) et une marge de 2 : rien d’autre n’y est rangé.', bpNoBag: 'aucun sac n’a ce rôle', bpLeft: '{n} libre(s) après',
  bpC_job: 'Job en cours', bpC_gear: 'Équipement des autres jobs', bpC_lock: 'Lockstyle', bpC_tools: 'Pièces à activer (téléport, bonus d’XP et de CP)', bpC_spare: 'Lockstyle, pièces à activer et surplus', bpC_craft: 'Équipement de craft et de pêche', bpC_unused: 'Ce qui ne sert pas (et ne peut pas partir)', bpC_mule: 'À envoyer sur une mule', bpC_npc: 'À déposer chez un NPC', bpNpcNote: 'Seals, crests, vouchers, Rem’s Tales, pierres d’augment, wings : un NPC les garde pour toi, aucun sac à prévoir. La bulle de chaque objet dit quel NPC.', bpNpcAt: 'À déposer chez : {n}', bpMuleNote: 'Dans aucun set, et le jeu permet de l’envoyer à un autre de tes persos.', bpFrees: 'libère {n} place(s)', bpC_usable: 'Consommables', bpC_mats: 'À vendre et composants de craft',
  bpC_currency: 'Currencies', bpC_keys: 'Objets clés (améliorations, accès)', bpC_furnish: 'Meubles et rangement', bpC_unknown: 'Non classé', bpC_carry: 'À garder sur moi (inventaire)',
  bpJobNote: 'Le job le plus chargé ({j}) prend {n} emplacements ; en {c} : {m}.', bpGearNote: 'Tout ce qu’un set porte, moins le job en cours. Ce qui dépasse va dans « lockstyle et surplus ».', bpSpareNote: 'Dont {n} de surplus venu de l’équipement des autres jobs.',
  bpPorter: 'Le Porter Moogle n’est pas compté : ce qui y est rangé y reste. {n} pièce(s) qu’un set porte s’y trouvent, à ressortir le jour où tu joues ces jobs.',
  bpUnknown: '{n} objet(s) ne sont pas classés. Ouvre « Tous les sacs », filtre « Non classé », sélectionne-les et range-les dans une catégorie.', bpAllGood: 'Tout est classé.',
  bpTo_mule: 'mule', bpTo_npc: 'NPC', bpOpen: 'Préparer {n} déplacement(s) pour le jeu', bpOpenTip: 'Montre ce qui irait d’où à où, puis l’envoie au jeu. Rien ne bouge tant que tu n’as pas tapé la commande en jeu.',
  bpSendTitle: 'Le rangement à faire en jeu', bpSendWhy: 'Voici ce que le plan déplacerait. La page envoie cette liste au jeu ; c’est toi qui la lances, en jeu.',
  bpSafe1: 'Le jeu ne fait que déplacer un objet d’un sac à un autre. Il ne jette, ne vend, n’envoie et n’utilise jamais rien.', bpSafe2: 'Par séries de 30 au plus, selon la place libre dans l’inventaire : les objets sortent de leur sac, le jeu confirme, ils entrent dans le bon sac, le jeu confirme. Sans confirmation, tout s’arrête.',
  bpSafe3: 'Une pièce portée, un sac plein ou un sac du Mog House hors du Mog House : ce déplacement est sauté, et dit.', bpSafe4: 'Chaque déplacement est écrit dans le fichier atelier/bag_moves.log de ton perso.',
  bpSendN: '{n} déplacement(s)', bpSendNone: 'Rien à déplacer : tout ce que la page sait ranger est à sa place.', bpSendNoRoom: '{n} objet(s) n’ont pas de place dans leurs sacs et ne seront pas déplacés : {l}.',
  bpSendGo: 'Envoyer au jeu', bpSendTip: 'Envoie la liste. Ensuite, en jeu : //gs c bags pour la voir, //gs c bags go pour la lancer.', bpSent: 'Plan envoyé : {n} déplacement(s). En jeu, tape //gs c bags pour voir ce qui est prêt (rien ne bouge), puis //gs c bags go pour lancer, //gs c bags stop pour arrêter.',
  bpSendFail: 'Le jeu n’a pas répondu : le plan n’a pas été envoyé.', bpLockOf: 'Lockstyle n° {l}', bpUnsaved: 'gardé dans ce navigateur seulement', bpUnsavedTip: 'Tes rôles et tes classements ne sont pas encore écrits dans tes fichiers : ils le seront au prochain changement, jeu connecté.', bpMuleGo: 'Les amener dans l’inventaire', bpMuleTip: 'Prépare le déplacement de ces objets vers ton inventaire, pour que tu puisses les envoyer. Rien ne part tout seul.',
  bpMuleWhy: 'Voici ce qui irait dans ton inventaire, pour que tu l’envoies toi-même à ta mule. Le jeu ne fait que déplacer ces objets : il n’envoie rien.', bpMuleNoRoom: 'L’inventaire n’a pas la place pour {n} objet(s) de plus (2 emplacements sont gardés libres) : {l}. Envoie d’abord ceux-ci, puis recommence.', bpSee: 'Voir', bpSeeCat: 'Voir : {c}', bpStOk: 'Tout est rangé', bpStOkWhy: 'chaque objet est dans un sac de sa catégorie', bpStTodo: '{n} objet(s) à ranger', bpStTodoWhy: 'chacun a une place : ouvre le plan pour envoyer le rangement au jeu', bpRunDone: 'dernier rangement en jeu le {at} : {n} déplacé(s), {s} sauté(s)', bpRunStop: 'dernier rangement en jeu le {at}, arrêté avant la fin : {n} déplacé(s), {s} sauté(s)', bpStBad: '{n} catégorie(s) ne rentrent pas',
  bpChUnk: ' non classé(s)', bpChWrong: ' mal rangé(s)', bpChMule: ' pour la mule', bpChNpc: ' à déposer chez un NPC', bpChPlan: 'Voir le plan', bpPc: 'Catégorie du plan', bpPcTip: 'N’affiche que les objets que le plan range dans cette catégorie.', bpUnk: 'Non classé', bpSel: '{n} sélectionné(s) : ranger dans', bpSelAll: 'Tout sélectionner ({n} affichés)', bpSelNone: 'Désélectionner', bpAuto: 'Automatique', bpAutoTip: 'Oublie ton choix : la page reclasse toute seule.',
  bpPickTip: 'Clique pour sélectionner, puis range la sélection dans une catégorie.', bpCatTip: 'Catégorie : {c}{m}', bpByYou: ' (choisie par toi)'});
Object.assign(T.en, {bpPlan: 'The plan', bpPlanTip: 'The tidy-up sum: what each role must house against the room of its bags. Nothing moves in game.', bpTitle: 'The tidy-up plan', bpWhyS: 'Each card: what its bags hold today, what the tidy-up takes out and brings in. Hover a card for the details.',
  bpWhy: 'Every item has a category; every category goes to the bags of that role. Each card shows what its bags hold today, what the tidy-up takes out and brings in, and what found no room: it is exactly what the command in game will move. The inventory is tidied too, but for what you carry there to use: the gear of your sets, the pieces to activate, the consumables, and what you file as “kept on me”. The Porter Moogle is left as it is.',
  bpOk: 'it fits', bpDone: 'already tidy', bpOver: '{n} item(s) with no room', bpJobOver: 'the heaviest job is {n} over', bpOutN: '{n} leave', bpInN: '{n} arrive', bpAfterN: '{n} after', bpNowTip: 'What these bags hold today, against their room.', bpNoRoomS: 'no room', bpReserve: '{n} slot(s) kept for the Storage Slips (01 to 33) and a margin of 2: nothing else is put there.', bpNoBag: 'no bag has this role', bpLeft: '{n} free after',
  bpC_job: 'Job loaded', bpC_gear: 'The other jobs’ gear', bpC_lock: 'Lockstyle', bpC_tools: 'Pieces to activate (teleport, XP and CP bonus)', bpC_spare: 'Lockstyle, pieces to activate and overflow', bpC_craft: 'Crafting and fishing gear', bpC_unused: 'What is not used (and cannot leave)', bpC_mule: 'To send to a mule', bpC_npc: 'To hand to an NPC', bpNpcNote: 'Seals, crests, vouchers, Rem’s Tales, augment stones, wings: an NPC keeps them for you, no bag to plan. Each item’s tooltip says which NPC.', bpNpcAt: 'To hand to: {n}', bpMuleNote: 'In no set, and the game lets it be sent to another of your characters.', bpFrees: 'frees {n} slot(s)', bpC_usable: 'Consumables', bpC_mats: 'To sell and crafting materials',
  bpC_currency: 'Currencies', bpC_keys: 'Key items (upgrades, entries)', bpC_furnish: 'Furniture and storage', bpC_unknown: 'Not filed', bpC_carry: 'Kept on me (inventory)',
  bpJobNote: 'The heaviest job ({j}) takes {n} slots; on {c}: {m}.', bpGearNote: 'Everything a set wears, less the job loaded. What overflows goes to "lockstyle and overflow".', bpSpareNote: 'Of which {n} overflow from the other jobs’ gear.',
  bpPorter: 'The Porter Moogle is not counted: what is stored there stays there. {n} piece(s) a set wears are there, to take back the day you play those jobs.',
  bpUnknown: '{n} item(s) are not filed. Open "All the bags", filter "Not filed", select them and file them in a category.', bpAllGood: 'Everything is filed.',
  bpTo_mule: 'mule', bpTo_npc: 'NPC', bpOpen: 'Prepare {n} move(s) for the game', bpOpenTip: 'Shows what would go from where to where, then sends it to the game. Nothing moves until you type the command in game.',
  bpSendTitle: 'The tidy-up to do in game', bpSendWhy: 'This is what the plan would move. The page sends this list to the game; you start it, in game.',
  bpSafe1: 'The game only moves an item from a bag to another. It never drops, sells, sends or uses anything.', bpSafe2: 'In series of 30 at most, as the free room of the inventory allows: items leave their bags, the game confirms, they go into the right bag, the game confirms. With no confirmation, everything stops.',
  bpSafe3: 'A piece worn, a full bag or a Mog House bag outside the Mog House: that move is skipped, and said.', bpSafe4: 'Every move is written to your character’s atelier/bag_moves.log file.',
  bpSendN: '{n} move(s)', bpSendNone: 'Nothing to move: everything the page can place is where it should be.', bpSendNoRoom: '{n} item(s) have no room in their bags and will not be moved: {l}.',
  bpSendGo: 'Send to the game', bpSendTip: 'Sends the list. Then, in game: //gs c bags to see it, //gs c bags go to play it.', bpSent: 'Plan sent: {n} move(s). In game, type //gs c bags to see what is ready (nothing moves), then //gs c bags go to play it, //gs c bags stop to stop.',
  bpSendFail: 'The game did not answer: the plan was not sent.', bpLockOf: 'Lockstyle no. {l}', bpUnsaved: 'kept in this browser only', bpUnsavedTip: 'Your roles and categories are not written to your files yet: they will be at the next change, with the game connected.', bpMuleGo: 'Bring them to the inventory', bpMuleTip: 'Prepares the move of these items to your inventory, so that you can send them. Nothing leaves by itself.',
  bpMuleWhy: 'This is what would go to your inventory, for you to send to your mule yourself. The game only moves these items: it sends nothing.', bpMuleNoRoom: 'The inventory has no room for {n} more item(s) (2 slots are kept free): {l}. Send these first, then do it again.', bpSee: 'See', bpSeeCat: 'See: {c}', bpStOk: 'Everything is tidy', bpStOkWhy: 'every item is in a bag of its category', bpStTodo: '{n} item(s) to tidy', bpStTodoWhy: 'each has a place: open the plan to send the tidy-up to the game', bpRunDone: 'last tidy-up in game on {at}: {n} moved, {s} skipped', bpRunStop: 'last tidy-up in game on {at}, stopped before the end: {n} moved, {s} skipped', bpStBad: '{n} category(ies) do not fit',
  bpChUnk: ' not filed', bpChWrong: ' misplaced', bpChMule: ' for the mule', bpChNpc: ' to hand to an NPC', bpChPlan: 'See the plan', bpPc: 'Plan category', bpPcTip: 'Shows only the items the plan files in this category.', bpUnk: 'Not filed', bpSel: '{n} selected: file in', bpSelAll: 'Select all ({n} shown)', bpSelNone: 'Clear', bpAuto: 'Automatic', bpAutoTip: 'Forgets your choice: the page files it by itself again.',
  bpPickTip: 'Click to select, then file the selection in a category.', bpCatTip: 'Category: {c}{m}', bpByYou: ' (your choice)'});

// The categories a thing can be filed in, and the roles of the bags each goes to (the first roles first)
const BP_CATS = ['gear', 'lock', 'tools', 'craft', 'unused', 'mule', 'npc', 'usable', 'mats', 'currency', 'keys', 'furnish', 'carry'];
const BP_ROLES = {gear: ['job', 'gear', 'spare'], lock: ['spare'], tools: ['spare', 'gear', 'job'], craft: ['craft'], unused: ['unused'], usable: ['usable'], mats: ['mats'], currency: ['currency'], keys: ['keys'], furnish: ['furnish', 'slips']};
// The category a bag's role suggests for what sits in it today
const BP_HINT = {craft: 'craft', unused: 'unused', archive: 'unused', usable: 'usable', mats: 'mats', currency: 'currency', keys: 'keys', furnish: 'furnish', slips: 'furnish'};
const BP_GEAR_ONLY = ['gear', 'lock', 'tools', 'craft'];
// A piece that is put on to be activated (a teleport ring, a Retrace staff): its description names an enchantment
const bpEnch = r => { const c = typeof catalog === 'function' && catalog(), row = c && c.row[r.info.name]; return !!row && /Enchantment/i.test(String(row[6] || '')); };
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
  // the player's choice; a category of equipment given to what is no equipment cannot hold (a wardrobe takes
  // equipment only): crafting gear said of a material is a crafting material, the others are left to the page
  const mine = bpTags()[r.id];
  if (mine && (bvIsGear(r) || !BP_GEAR_ONLY.includes(mine))) return mine;
  if (mine === 'craft') return 'mats';
  const hint = () => { for (const w of r.where) { const bag = B.bags.find(b => b.name === w.bag), h = bag && bvRoles(B, bag).map(x => BP_HINT[x]).find(Boolean); if (h) return h; } return ''; };
  if (bvIsGear(r)) {
    // what sits only in a crafting bag is crafting gear, whatever set wears it (the craft and fishing sets)
    const home = r.where.filter(w => w.bag !== 'Porter Moogle').map(w => B.bags.find(b => b.name === w.bag)).filter(Boolean);
    if (home.length && home.every(b => bvRoles(B, b).includes('craft'))) return 'craft';
    if (Object.keys(r.use.jobs).length) return 'gear';
    if (bpLock()[r.id]) return 'lock';
    if (bpEnch(r)) return 'tools';                    // worn by no set, but put on to be used: kept within reach                // worn by no set, but by a lockstyle: kept for its look
    // a piece no set wears, in no bag with a say of its own (crafting), that can go to another character: a mule's
    // (a piece is no consumable, material or currency, whatever bag it lies in: only a crafting bag speaks for it)
    const h = hint(); return h === 'craft' ? h : bpSendable(B, r) ? 'mule' : 'unused';
  }
  if (/^Storage Slip/.test(r.info.name)) return 'furnish';
  // seals, crests and vouchers are handed to an NPC that keeps them: they wait in the inventory, they are not housed
  if (bpNpc(r.info.name)) return 'npc';
  if (BP_KEYS.test(r.info.name)) return 'keys';
  if (BP_MATS.test(r.info.name)) return 'mats';
  // the crafting crystals and their clusters, by name: a Heroism Crystal or an Oneiros Cluster is no crafting crystal
  if (/^((Fire|Ice|Wind|Earth|Lightning|Water|Light|Dark) Cluster|(Fire|Ice|Wind|Earth|Lightng\.|Water|Light|Dark|Inferno|Glacier|Cyclone|Terra|Plasma|Torrent|Aurora|Twilight) Crystal)$/.test(r.info.name)) return 'mats';
  // a currency kept in its closed container (it takes less room than opened): filed as currency, not as a consumable.
  // By name, not by ending: a Bullet Pouch, a Card Case or an Old Bolt Box holds ammunition
  if (BP_BOXES.test(r.info.name)) return 'currency';
  return hint() || (r.info.cat === 'Usable' ? 'usable' : 'unknown');
}
const bpCatName = c => t('bpC_' + c);
// Where a thing should go: the bags whose role takes its category (their short names), else the category's own name
// (a mule, an NPC, or a category no bag has the role of yet)
function bpDest(B, r){
  if (r.bad && r.bad.length) { const to = [...new Set(r.bad.map(x => x.to).filter(Boolean))].map(bvShort); return to.length ? to.join(', ') : t('bpNoRoomS'); }
  const cat = bpCat(B, r), roles = BP_ROLES[cat] || [], bags = B.bags.filter(b => b.max && bvRoles(B, b).some(x => roles.includes(x))).map(b => bvShort(b.name));
  return bags.length ? bags.slice(0, 3).join(', ') + (bags.length > 3 ? '…' : '') : cat === 'mule' || cat === 'npc' ? t('bpTo_' + cat) : bpCatName(cat);
}
// The plan: one line a role group, {id, need, room, bags, move, note}
function bpPlan(B){
  const where = bvWhere(B), rows = bvRows(B, 'all', where), kept = n => n !== 'Inventory' && n !== 'Porter Moogle';
  const roleOf = Object.fromEntries(B.bags.map(b => [b.name, bvRoles(B, b)])), fits = (name, roles) => (roleOf[name] || []).some(x => roles.includes(x)), bagsOf = roles => B.bags.filter(b => b.max && fits(b.name, roles));
  const room = roles => bagsOf(roles).reduce((n, b) => n + b.max, 0);
  // what a row takes outside the inventory and the Porter Moogle
  const slots = r => r.where.filter(w => kept(w.bag)).reduce((n, w) => n + w.slots, 0);
  const by = {}; for (const r of rows) (by[bpCat(B, r)] = by[bpCat(B, r)] || []).push(r);
  const sum = (list, f) => (list || []).reduce((n, r) => n + f(r), 0), gear = by.gear || [];
  // the job loaded: every job must fit in its bags, the heaviest decides
  const perJob = bvUsage().jobs.map(j => [j, sum(gear.filter(r => r.use.jobs[j]), slots)]).sort((a, b) => b[1] - a[1]), heavy = perJob[0] || ['—', 0], cur = (perJob.find(x => x[0] === S.job) || [S.job, 0])[1];
  const others = Math.max(0, sum(gear, slots) - cur), gearRoom = room(['gear']), spill = Math.max(0, others - gearRoom), lock = sum(by.lock, slots);
  const line = (id, need, roles, list, note) => ({id, need, room: room(roles), names: bagsOf(roles).map(b => b.name), bags: bagsOf(roles).map(b => bvShort(b.name)), note});
  const out = [
    Object.assign(line('job', heavy[1], ['job'], []), {note: t('bpJobNote', {j: heavy[0], n: heavy[1], c: S.job, m: cur})}),
    Object.assign(line('gear', others - spill, ['gear'], gear), {note: t('bpGearNote')}),
    Object.assign(line('spare', lock + spill, ['spare'], by.lock), {note: spill ? t('bpSpareNote', {n: spill}) : ''}),
    // (the slips' bag is not the furniture's: a bag that keeps the slips beside something else stays that thing's card)
    ...['craft', 'unused', 'usable', 'mats', 'currency', 'keys', 'furnish'].map(c => line(c, sum(by[c], slots), c === 'furnish' ? ['furnish'] : BP_ROLES[c], by[c]))];
  // the categories that share a bag (a bag with two or three roles, a wardrobe too) are one line: their things against
  // the room they share
  for (let i = 0; i < out.length; i++) for (let j = i + 1; j < out.length; j++) if (out[i].names.some(n => out[j].names.includes(n))) {
    const a = out[i], b = out.splice(j, 1)[0], names = [...new Set([...a.names, ...b.names])];
    out[i] = {id: a.id, ids: [...(a.ids || [a.id]), ...(b.ids || [b.id])], need: a.need + b.need, names, bags: names.map(bvShort), room: names.reduce((n, x) => n + B.bags.find(g => g.name === x).max, 0)};
    j = i; }
  // what leaves for a mule or waits for an NPC is not housed: it frees room
  out.splice(5, 0, {id: 'mule', need: sum(by.mule, slots), room: 0, bags: [], names: [], free: true, note: t('bpMuleNote')},
    {id: 'npc', need: sum(by.npc, r => r.where.reduce((n, w) => n + w.slots, 0)), room: 0, bags: [], names: [], free: true, note: t('bpNpcNote')});
  const porter = sum(gear, r => r.where.filter(w => w.bag === 'Porter Moogle').reduce((n, w) => n + w.slots, 0));
  // what is in each line's bags today, what the moves take out and bring, and what found no room (bags_target.js)
  const T = bpTarget(B), catsOf = l => (l.ids || [l.id]).flatMap(c => c === 'spare' ? ['lock', 'tools'] : c === 'job' ? [] : [c]);
  for (const l of out) if (!l.free) Object.assign(l, btFlow(B, l.names), {over: T.noRoom.filter(x => catsOf(l).includes(x.cat)).length});
  return {lines: out, unknown: (by.unknown || []).length, porter};
}
// A line that does not hold: things with no room, a category no bag takes, or the heaviest job over its bags
function bpLineBad(l){ return !l.free && (l.over > 0 || (l.need > 0 && !l.room) || (l.id === 'job' && l.need > l.room)); }
// Where the list and the tab are scrolled, put back after a redraw: picking things and filing them must leave the list
// where the player is (it went back to its top, the player, 2026-10-24); again a frame later, after bvFit sized it
function bpKeepScroll(){
  const at = ['#bvlist', '.tabmain'].map(q => { const el = document.querySelector(q); return el ? [q, el.scrollTop] : null; }).filter(Boolean);
  const put = () => at.forEach(([q, top]) => { const el = document.querySelector(q); if (el && el.scrollTop !== top) el.scrollTop = top; });
  return () => { put(); requestAnimationFrame(put); };
}
document.addEventListener('click', e => {
  const b = e.target.closest('[data-bptag],[data-bpall],[data-bpnone],[data-bpunk],[data-bpwrong],[data-bpsee],[data-bpick]'); if (!b) return; const d = b.dataset;
  S._bagPick = S._bagPick || new Set();
  const back = bpKeepScroll(), redraw = () => { render(); back(); };
  if (d.bpsee) { S.bagSel = 'all'; S.bagUse = 'all'; S.bagCat = 'all'; S.bagQ = ''; S.bagPc = d.bpsee; save(); render(); return; }
  if ('bpwrong' in d) { S.bagSel = 'all'; S.bagUse = 'bad'; S.bagCat = 'all'; S.bagQ = ''; S.bagPc = ''; save(); render(); return; }
  if ('bpunk' in d) { S.bagSel = 'all'; S.bagUse = 'unk'; S.bagCat = 'all'; S.bagQ = ''; S.bagPc = ''; save(); render(); return; }
  if ('bpnone' in d) { S._bagPick.clear(); redraw(); return; }
  if ('bpall' in d) { document.querySelectorAll('#bvlist [data-bpick]').forEach(el => S._bagPick.add(el.dataset.bpick)); redraw(); return; }
  // the page drawn again: the Bags view (atelier/src/screens/perso) marks the item and redraws the selection's bar only
  if (d.bpick) { if (S._bagPick.has(d.bpick)) S._bagPick.delete(d.bpick); else S._bagPick.add(d.bpick); redraw(); return; }
  // file the selection: by item (every copy of it), kept by character
  const tags = Object.assign({}, bpTags()); for (const id of S._bagPick) { if (d.bptag) tags[id] = d.bptag; else delete tags[id]; }
  S.bagTags = Object.assign({}, S.bagTags, {[S.char]: tags}); S._bagPick.clear(); bpTouch(); redraw();
});

/* ---- the moves of the plan, sent to the game ---- */
// What would move: every thing that is not where it should be and has a bag to go to, one line a slot
// {id, name, from, to (bag ids), fromName, toName}, from the one sum the cards and the list read too
// (bags_target.js bpTarget). Nothing goes to a mule or an NPC here: that is the player's to do.
function bpMoves(B){ const T = bpTarget(B); return {moves: T.moves, noRoom: T.noRoom.map(x => x.name)}; }
// What leaves for a mule, brought to the inventory so the player can send it: every thing of that category that is
// in another bag (not the Porter Moogle's), as far as the inventory has room, two slots kept free
function bpMuleMoves(B){
  const inv = B.bags.find(b => b.name === 'Inventory'), moves = [], noRoom = [];
  if (!inv) return {moves, noRoom};
  let free = inv.max - (inv.count != null ? inv.count : inv.items.length) - 2;
  for (const r of bvRows(B, 'all', bvWhere(B))) { if (bpCat(B, r) !== 'mule') continue;
    for (const w of r.where) { const from = B.bags.find(b => b.name === w.bag); if (!from || from.id <= 0) continue;
      for (let i = 0; i < w.slots; i++) { if (free <= 0) { noRoom.push(r.info.name); continue; }
        free--; moves.push({id: r.id, name: r.info.name, from: from.id, to: inv.id, fromName: from.name, toName: inv.name}); } } }
  return {moves, noRoom};
}
// The window before sending: what goes from where to where (atelier/src/screens/dialogs/bagdlg.ts), then the send
function openBagPlanSend(mule){
  S._bpMule = !!mule;
  const p = mule ? bpMuleMoves(bvBags()) : bpMoves(bvBags());
  ATELIER_DIALOG.show({cls: 'midlg bpdlg', titleHtml: esc(t('bpSendTitle')), bags: ATELIER_DIALOG.bagSendView(!!mule),
    buttonsHtml: p.moves.length ? `<button class="btn" data-bpsend ${liveOk() ? '' : 'disabled'} title="${esc(liveOk() ? t('bpSendTip') : t('ttModRead'))}">${esc(t('bpSendGo'))}</button>` : ''});
}
async function bpSend(){
  const p = S._bpMule ? bpMuleMoves(bvBags()) : bpMoves(bvBags()), body = p.moves.map(m => [m.id, m.from, m.to, m.name.replace(/[\t\r\n]/g, ' ')].join('\t')).join('\n');
  let r; try { r = await liveOrder(S.char, '/bag_plan', {method: 'POST', body, timeout: 5000}); } catch (e) { r = null; }
  closeOverlay();
  S.toast = r && r.ok ? t('bpSent', {n: r.moves}) : t('bpSendFail'); render();
}
document.addEventListener('click', e => { const b = e.target.closest('[data-bpopen],[data-bpmule],[data-bpsend]'); if (!b) return; if ('bpsend' in b.dataset) bpSend(); else openBagPlanSend('bpmule' in b.dataset); });

/* ---- the roles and the categories kept in the character's files ---- */
// <Char>/atelier/overrides/bag_plan.js: what each bag is for (the player's choices only) and the category the player
// gave to an item, by item id. Written a moment after each change, through the game or to the folder the page was
// given; read at start, where it replaces the browser's when it is newer. Without either, they stay in the browser.
const BP_FILE = 'bag_plan.js';
const bpFileText = c => `// GearSwap Atelier: ${c}'s bags plan, as chosen in the page (My character > Bags): what each bag is for, and the\n` +
  `// category given by hand to an item (by item id). Written by the page; deleting this file puts the page's own guesses back.\n` +
  `(window.ATELIER_BAGS = window.ATELIER_BAGS || {})[${JSON.stringify(c)}] = ${JSON.stringify({at: (S.bagAt || {})[c] || '', roles: (S.bagRoles || {})[c] || {}, tags: (S.bagTags || {})[c] || {}})};\n`;
function bpRead(){
  const files = window.ATELIER_BAGS || {};
  for (const c in files) { const f = files[c], mine = (S.bagAt || {})[c] || '';
    if (f && (f.at || '') > mine) { S.bagRoles = Object.assign({}, S.bagRoles, {[c]: f.roles || {}}); S.bagTags = Object.assign({}, S.bagTags, {[c]: f.tags || {}}); S.bagAt = Object.assign({}, S.bagAt, {[c]: f.at}); } }
  // choices made before the file existed (kept in the browser only): written once the page has settled
  const c = S.char, has = o => !!o && Object.keys(o).length > 0;
  if (c && !files[c] && (has((S.bagRoles || {})[c]) || has((S.bagTags || {})[c]))) setTimeout(() => { if (S.char === c) bpTouch(); }, 5000);
}
let BP_TIMER = null;
// after a role or a category changed: dated, kept in the browser now, written to the files a moment later
function bpTouch(){
  S.bagAt = Object.assign({}, S.bagAt, {[S.char]: new Date().toISOString()}); save();
  clearTimeout(BP_TIMER); const c = S.char;
  BP_TIMER = setTimeout(async () => { const done = await charFileSave(c, BP_FILE, bpFileText(c), false), was = S._bagUnsaved; S._bagUnsaved = !done; if (was !== S._bagUnsaved) render(); }, 1200);
}
