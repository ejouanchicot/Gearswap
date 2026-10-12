// GearSwap Atelier · guide_bags.js: the moogle's tutorial of the Bags view (My character > Bags), and that view's
// help. A tutorial is a visit of one page: steps like the welcome visit's ([what it points at, the text]) with a
// third part, the state the view must be in for that step (GUIDE_PREP in guide.js plays it before the step is drawn).
// Short, in the player's words: no file name but the journal's, no code but the commands typed in game.

GUIDE_PAGES.fr.bags = {title: 'Mes sacs', intro: 'Tes sacs et leur rangement, kupo ! La page prépare, une commande en jeu déplace. Je peux tout t’expliquer pas à pas.',
  tips: ['Chaque sac a un rôle : ce qu’on y range. Clique sur un sac pour le changer.',
    'Chaque objet a une catégorie. La page en devine la plupart ; sélectionne des lignes pour classer les autres toi-même.',
    'Le plan montre ce que chaque famille de sacs contient, ce qui en sort et ce qui y arrive : c’est exactement ce que la commande en jeu déplacera.',
    'En jeu : //gs c bags pour voir, //gs c bags go pour lancer, //gs c bags stop pour arrêter. Dans le Mog House pour les sacs du Mog.',
    'Rien n’est jamais jeté, vendu, envoyé ou utilisé : seulement déplacé d’un sac à un autre.']};
GUIDE_PAGES.en.bags = {title: 'My bags', intro: 'Your bags and their tidy-up, kupo! The page prepares, a command in game moves. I can explain it all step by step.',
  tips: ['Every bag has a role: what is kept in it. Click a bag to change it.',
    'Every item has a category. The page guesses most of them; select lines to file the others yourself.',
    'The plan shows what each family of bags holds, what leaves and what arrives: it is exactly what the command in game will move.',
    'In game: //gs c bags to see, //gs c bags go to start, //gs c bags stop to stop. In the Mog House for the Mog bags.',
    'Nothing is ever dropped, sold, sent or used: only moved from one bag to another.']};

const GUIDE_TUTO = {bags: {
  fr: [[null, 'Kupo ! Ici on range tes sacs. Je t’explique tout en deux minutes. Retiens déjà ceci : la page prépare le rangement, et rien ne bouge en jeu tant que tu n’as pas tapé la commande.', 'all'],
    ['.bvat', 'D’où viennent ces chiffres : ce sont tes sacs tels que le jeu les a lus à cette date. Tu as bougé des choses en jeu depuis ? Tape //gs c atelier pour les relire. Les sacs du Mog House sont ceux de ta dernière visite.', 'all'],
    ['.bvtop', 'Une tuile par sac : son nom, ce qu’il contient sur sa place, et dessous son rôle, c’est-à-dire ce qu’on y range. Une pastille jaune compte ce qui n’y est pas à sa place. Le Porter Moogle est montré aussi, mais je n’y touche jamais.', 'all'],
    ['[data-bagrole]', 'Un clic sur un sac montre son contenu, et ce menu choisit son rôle : job en cours, équipement des autres jobs, lockstyle et surplus, craft, consommables, à vendre, currencies, objets clés… Un sac qui n’est pas un wardrobe peut avoir deux rôles. C’est toi qui décides.', 'bag'],
    ['#bvlist', '« Tous les sacs » montre chaque objet une seule fois : son nom, les jobs dont un set le porte, les sacs où il se trouve. Un objet mal rangé porte une marque avec le sac où il devrait aller.', 'all'],
    ['.bvuse', 'Ces filtres retrouvent vite ce qui te manque : non classé, mal rangé, lockstyle, dans aucun set, porté par un job, par plusieurs.', 'all'],
    ['.bvpick:has([data-bagpc])', 'Chaque objet a une catégorie : équipement, lockstyle, pièces à activer, craft, ce qui ne sert pas, mule, NPC, consommables, à vendre, currencies, objets clés, meubles, à garder sur moi. La page en devine la plupart. Ce menu n’en affiche qu’une.', 'all'],
    ['#bpsel', 'Pour classer toi-même : clique sur des lignes pour les sélectionner, puis choisis la catégorie dans cette barre. « Automatique » rend la main à la page. Tes choix sont gardés dans tes fichiers.', 'all'],
    [null, 'Deux commandes m’aident à bien deviner : //gs c atelier all pour connaître les sets de tous tes jobs, et //gs c lockscan pour connaître les pièces de tes lockstyles. Sans elles, une pièce utile peut me sembler inutile, kupo.', 'all'],
    ['.bpstatus', 'Cette ligne dit toujours où tu en es. Vert : tout est rangé. Jaune : des objets à ranger, chacun a une place. Rouge : une catégorie n’a pas assez de place. À droite, ce qui attend : non classé, pour la mule, à déposer chez un NPC.', 'plan'],
    ['.bpcards', 'Le plan. Une carte par famille de sacs : ce qu’ils contiennent aujourd’hui sur leur place, puis ce qui en sort, ce qui y arrive, et le total après. Passe la souris sur une carte pour le détail.', 'plan'],
    ['.bpcard', 'Mes règles : chaque objet va dans un sac qui a le rôle de sa catégorie. Le surplus ne reste en réserve que si les autres wardrobes sont pleins. Le sac des slips garde la place des 33 Storage Slips, plus 2. De l’inventaire tout sort, sauf l’équipement de tes sets, les pièces à activer, les consommables et ce que tu classes « à garder sur moi ».', 'plan'],
    ['[data-bpopen]', 'Quand le plan te va, ce bouton montre la liste exacte des déplacements, sac par sac. Relis-la, puis « Envoyer au jeu ». Il faut que le jeu soit connecté.', 'plan'],
    [null, 'Ensuite, en jeu : //gs c bags montre ce qui est prêt sans rien bouger, //gs c bags go lance le rangement, //gs c bags stop l’arrête. Va dans ton Mog House, sinon le Mog Safe, le Storage et le Locker sont fermés et leurs objets sont sautés.', 'plan'],
    [null, 'Promis, kupo : je ne fais que déplacer d’un sac à un autre, par séries de 30 objets au plus selon la place libre dans ton inventaire, en vérifiant chaque série avant la suivante. Jamais je ne jette, ne vends, n’envoie ou n’utilise quoi que ce soit. Une pièce portée, un sac plein ou fermé : je saute et je le dis. Tout est noté dans le fichier bag_moves.log de ton perso.', 'plan'],
    ['.bpstatus', 'À la fin, le jeu me prévient et la page se met à jour toute seule. Si tout est bon, tu liras ici « Tout est rangé », avec la date et le nombre d’objets déplacés. Bon rangement, kupo !', 'plan']],
  en: [[null, 'Kupo! This is where your bags get tidied. I explain it all in two minutes. Remember this first: the page prepares the tidy-up, and nothing moves in game until you type the command.', 'all'],
    ['.bvat', 'Where these figures come from: they are your bags as the game read them on that date. Moved things in game since? Type //gs c atelier to read them again. The Mog House bags are those of your last visit.', 'all'],
    ['.bvtop', 'A tile a bag: its name, what it holds against its room, and under it its role, what is kept in it. A yellow dot counts what is misplaced there. The Porter Moogle is shown too, but I never touch it.', 'all'],
    ['[data-bagrole]', 'A click on a bag shows its content, and this menu picks its role: job loaded, the other jobs’ gear, lockstyle and overflow, crafting, consumables, to sell, currencies, key items… A bag that is not a wardrobe can have two roles. You decide.', 'bag'],
    ['#bvlist', '“All the bags” shows each item once: its name, the jobs a set of which wears it, the bags it is in. A misplaced item carries a mark with the bag it should go to.', 'all'],
    ['.bvuse', 'These filters find quickly what you are after: not filed, misplaced, lockstyle, in no set, worn by one job, by several.', 'all'],
    ['.bvpick:has([data-bagpc])', 'Every item has a category: gear, lockstyle, pieces to activate, crafting, what is not used, mule, NPC, consumables, to sell, currencies, key items, furniture, kept on me. The page guesses most of them. This menu shows one only.', 'all'],
    ['#bpsel', 'To file by yourself: click lines to select them, then pick the category in this bar. “Automatic” hands it back to the page. Your choices are kept in your files.', 'all'],
    [null, 'Two commands help me guess well: //gs c atelier all to know the sets of all your jobs, and //gs c lockscan to know the pieces of your lockstyles. Without them a useful piece may look useless to me, kupo.', 'all'],
    ['.bpstatus', 'This line always says where you stand. Green: everything is tidy. Yellow: items to tidy, each with a place. Red: a category has not enough room. On the right, what waits: not filed, for the mule, to hand to an NPC.', 'plan'],
    ['.bpcards', 'The plan. A card a family of bags: what they hold today against their room, then what leaves, what arrives, and the total after. Hover a card for the details.', 'plan'],
    ['.bpcard', 'My rules: every item goes to a bag that has the role of its category. Overflow stays in the reserve only when the other wardrobes are full. The slips’ bag keeps room for the 33 Storage Slips, plus 2. Everything leaves the inventory but the gear of your sets, the pieces to activate, the consumables and what you file as “kept on me”.', 'plan'],
    ['[data-bpopen]', 'When the plan suits you, this button shows the exact list of moves, bag by bag. Read it, then “Send to the game”. The game must be connected.', 'plan'],
    [null, 'Then, in game: //gs c bags shows what is ready and moves nothing, //gs c bags go starts the tidy-up, //gs c bags stop stops it. Go to your Mog House, or the Mog Safe, the Storage and the Locker are closed and their items are skipped.', 'plan'],
    [null, 'Promise, kupo: I only move from one bag to another, in series of 30 items at most as your inventory’s free room allows, checking every series before the next. I never drop, sell, send or use anything. A piece worn, a bag full or closed: I skip it and say so. Everything is written to your character’s bag_moves.log file.', 'plan'],
    ['.bpstatus', 'At the end the game tells me and the page updates by itself. If all is well you will read “Everything is tidy” here, with the date and the number of items moved. Happy tidying, kupo!', 'plan']]}};

// The state a step of the Bags tutorial needs: the list of every bag with no filter, one bag opened (a wardrobe),
// or the plan. True when the view must be drawn again
const GUIDE_PREP = {
  all: () => { const was = [S.bagSel, S.bagUse, S.bagCat, S.bagPc, S.bagQ].join('|'); Object.assign(S, {bagSel: 'all', bagUse: 'all', bagCat: 'all', bagPc: '', bagQ: ''}); return was !== 'all|all|all||'; },
  bag: () => { const B = bvBags(), bag = B && (B.bags.find(b => b.name === 'Wardrobe 3') || B.bags.find(b => b.max)); if (!bag || S.bagSel === bag.name) return false; S.bagSel = bag.name; return true; },
  plan: () => { if (S.bagSel === 'plan') return false; S.bagSel = 'plan'; return true; }};
