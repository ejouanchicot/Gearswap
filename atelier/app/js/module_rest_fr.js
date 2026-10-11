// GearSwap Atelier · module_rest_fr.js: the French of the Advanced view of the Modules part (modules.js): every setting
// of every settings file that the options catalog (module_catalog.js) does not already explain, by file and by path.
//   MOD_REST_FR[file] = [[path, name, what it does, flag], ...]     ({JOB}_X.lua: a job's own file)
// A path is the setting's place in the file (`layout.compact`); `*` stands for one name the player chose or that
// repeats (a job, a weapon, a pet), said back in the texts as {1}, {2}. The first line that fits wins, then the lines
// of '*' (names that mean the same in every file). Flag 'map': a table of named entries (`Name = value`), which the
// page shows but does not change (an empty one looks like a plain list). The texts say what the file's own comments
// say (read 2026-10-11); in English the page shows those comments as they are.
// scripts/atelier/atelier_text_check.js fails when a setting of a character's files has no line here.
// (loaded by atelier/index.html before modules.js)

const MOD_REST_FR = {
  '*': [
    ['*.r', 'Rouge', 'De 0 à 255.'], ['*.g', 'Vert', 'De 0 à 255.'], ['*.b', 'Bleu', 'De 0 à 255.'], ['*.a', 'Opacité', 'De 0 (transparent) à 255 (opaque).'],
    ['*.red', 'Rouge', 'De 0 à 255.'], ['*.green', 'Vert', 'De 0 à 255.'], ['*.blue', 'Bleu', 'De 0 à 255.'], ['*.alpha', 'Opacité', 'De 0 (transparent) à 255 (opaque).'],
    ['*.name', 'Nom', ''], ['*.desc', 'Description', 'Le texte affiché pour cette commande.'], ['*.description', 'Description', ''],
    ['debug', 'Messages de debug', 'Des messages détaillés dans le chat, pour chercher une panne.'], ['store_bag', 'Sac où ranger le surplus', 'Un seul sac : case, sack ou satchel.'],
  ],
  'BUFF_CONFIG.lua': [
    ['job', 'Buffs de ton job principal', 'Ce que //gs c buff lance, job par job. Pour un sort à tiers, écris le meilleur en premier : le premier que tu as et qui est prêt part.'],
    ['job.*', 'Quand tu es {1}', 'Lancés dans cet ordre.'],
    ['weapon', 'Buffs selon l’arme en main', 'Ajoutés après la liste du job quand cette arme est en main, quel que soit le job. Exemple dans le fichier : Naegling = {\'Gain-STR\', \'Enfire II\'}.', 'map'],
    ['weapon.*', 'Avec {1} en main', 'Ajoutés après la liste du job.'],
    ['subjob', 'Buffs de ton sub', 'Ajoutés après ceux du job principal.'],
    ['subjob.*', 'Avec le sub /{1}', 'Lancés après ceux du job principal.'],
  ],
  'CLEANSE_CONFIG.lua': [
    ['skip', 'Debuffs jamais retirés', 'Par exemple dia, bio. Les noms sont ceux de la liste des debuffs de GearSwap, en minuscules.'],
    ['first', 'Debuffs retirés en premier', 'Avant les autres, dans cet ordre. Par exemple silence.'],
    ['items', 'Objets par debuff', 'Essayés dans l’ordre. « erasable » couvre tout ce qu’Erase retire (Slow, Weight, Bind, Addle, les Down, Bio, Dia…).'],
    ['items.*', 'Objets contre {1}', 'Essayés dans l’ordre.'],
  ],
  'CRAFT_CONFIG.lua': [
    ['craft_file', 'Fichier de sets du craft', 'Le fichier lu par //gs c craft, dans _common/sets/ : son nom sans « _sets.lua ».'],
    ['fish_file', 'Fichier de sets de la pêche', 'Le fichier lu par //gs c fish, dans _common/sets/ : son nom sans « _sets.lua ».'],
  ],
  'DUALBOX_CONFIG.lua': [
    ['report_on_load', 'Demander l’état de l’automatisation à chaque chargement', 'À chaque chargement, chaque perso est prié de dire si son automatisation tourne. Demande l’ajout local StateReport de l’addon d’automatisation ; éteint : jamais envoyé.'],
  ],
  'DW_CONFIG.lua': [
    ['haste', 'Haste', 'Le pourcentage de haste magique compté pour ce buff.'], ['haste2', 'Haste II, Erratic Flutter', 'Le pourcentage de haste magique compté.'],
    ['geo_haste', 'Geo-Haste / Indi-Haste', 'Le pourcentage de haste magique compté pour la bulle.'], ['mighty_guard', 'Mighty Guard', 'Le pourcentage de haste magique compté.'],
    ['embrava', 'Embrava', 'Le pourcentage de haste magique compté.'], ['honor_march', 'Honor March', 'Le pourcentage de haste magique compté. Une estimation un peu basse exprès : elle dépend de l’équipement du Bard.'],
    ['victory_march', 'Victory March', 'Le pourcentage de haste magique compté.'], ['advancing_march', 'Advancing March', 'Le pourcentage de haste magique compté.'],
    ['unknown_march', 'March inconnue', 'Une March dont le chant n’a pas été vu : le pourcentage compté.'],
  ],
  'RECAST_CONFIG.lua': [
    ['party_announce', 'Message au groupe quand un recast refuse', 'Un message /p quand une ability ou un sort est refusé parce qu’il recharge. Une entrée par nom (« Phantom Roll » couvre tous les rolls) ; le fichier donne les exemples.', 'map'],
    ['party_announce.*', 'Message pour {1}', 'Le texte envoyé avec /p, ou true pour le message standard.'],
    ['party_announce_every', 'Délai avant de renvoyer le même message', 'En secondes : évite qu’un double appui envoie deux fois le message.'],
  ],
  'REFILL_CONFIG.lua': [
    ['foreign_characters', 'Persos dont les listes comptent', 'Avec « Celles des autres persos aussi » : les persos dont les listes de refill sont lues. Vide : tous les dossiers de perso.'],
    ['quiver_open_at', 'Ouvrir un carquois / une pochette', 'Après une attaque à distance, quand il reste ce nombre de munitions ou moins (inventaire + wardrobes), par job. false : ce job n’en ouvre jamais.'],
    ['quiver_open_at.*', 'En {1}', 'Le nombre de munitions restantes sous lequel un carquois est ouvert.'],
    ['subjobs', 'Listes communes par sub', 'La liste commune pour un sub, pour tout job qui n’a pas sa propre liste avec ce sub.'],
    ['subjobs.*', 'Liste commune avec le sub /{1}', 'Remplace la liste commune avec ce sub.'],
  ],
  'CRAFT_REFILL.lua': [['subjobs', 'Listes par sub', 'Pas utilisé pour le craft.'], ['subjobs.*', 'Avec le sub /{1}', '']],
  'REGION_CONFIG.lua': [
    ['characters', 'Région de chaque perso', 'US, EU ou JP : la région du compte décide des couleurs disponibles dans le chat.'],
    ['characters.*', 'Région de {1}', 'US, EU ou JP.'],
    ['default_region', 'Région par défaut', 'Pour un perso qui n’est pas dans la liste.'],
    ['region_info', 'Fiche de chaque région', 'Pour mémoire seulement : aucun module ne lit ce tableau.'],
    ['region_info.*', 'Région {1}', ''], ['region_info.*.pol_type', 'Type de PlayOnline', ''], ['region_info.*.code_057', 'Couleur du code 057', ''],
    ['region_info.*.warning_color', 'Couleur des avertissements', 'Le numéro de couleur du chat.'], ['region_info.*.example_chars', 'Persos de cette région', ''],
  ],
  'SUBJOB_CONFIG.lua': [['waltz_from', 'Paliers de Curing Waltz', 'Le tier choisi d’après les HP qui manquent à la cible (DNC ou /DNC) : chaque tier commence à ce nombre de HP manquants.']],
  'UI_COLOR_CONFIG.lua': [
    ['elements', 'Couleurs des éléments', 'Rouge, vert, bleu (0 à 255) pour chaque élément.'], ['elements.*', '{1}', 'Rouge, vert, bleu.'],
    ['stats', 'Couleurs des attributs', 'STR, DEX, VIT… : rouge, vert, bleu.'], ['stats.*', '{1}', 'Rouge, vert, bleu.'],
    ['bar_spells', 'Sorts Bar-', ''], ['bar_spells.ailment', 'Bar- contre les altérations', 'Barsilence, Barparalyze… Aujourd’hui ces sorts prennent la couleur de leur élément : cette couleur ne sert pas.'],
    ['spells', 'Couleurs des sorts', ''], ['spells.en', 'Sorts En-', 'Enfire, Enblizzard…'], ['spells.spikes', 'Sorts Spikes', ''], ['spells.storms', 'Storms (SCH)', ''],
    ['spells.*.*', '{2}', 'Rouge, vert, bleu.'],
    ['jobs', 'Couleurs propres à un job', ''], ['jobs.quick_draw', 'Quick Draw (COR)', 'Les huit tirs.'], ['jobs.quick_draw.*', '{1}', 'Rouge, vert, bleu.'],
    ['jobs.runes', 'Runes (RUN)', 'Ce tableau n’est pas lu. Pour changer la couleur d’une rune, ajoute-la sous son nom dans les couleurs des éléments, plus haut.', 'map'],
    ['modes', 'Couleurs des modes', ''], ['modes.*', 'Mode {1}', 'Rouge, vert, bleu.'],
    ['special', 'Couleurs des états', ''], ['special.true', 'Allumé / actif', 'Rouge, vert, bleu.'], ['special.false', 'Éteint / inactif', 'Rouge, vert, bleu.'],
    ['special.unknown', 'Inconnu', 'Rouge, vert, bleu.'], ['special.default', 'Par défaut', 'La couleur utilisée quand aucune autre ne s’applique.'], ['special.*', '{1}', 'Rouge, vert, bleu.'],
  ],
  'UI_CONFIG.lua': [
    ['default_position', 'Position de départ du HUD', 'Utilisée tant que //gs c ui save n’en a pas enregistré une.'], ['default_position.x', 'Horizontale', 'En pixels.'], ['default_position.y', 'Verticale', 'En pixels.'],
    ['text', 'Texte du HUD', ''], ['text.stroke', 'Contour des lettres', ''], ['text.stroke.width', 'Épaisseur du contour', ''], ['text.stroke.alpha', 'Opacité du contour', 'De 0 (transparent) à 255 (opaque).'],
    ['text.stroke.red', 'Rouge du contour', 'De 0 à 255.'], ['text.stroke.green', 'Vert du contour', 'De 0 à 255.'], ['text.stroke.blue', 'Bleu du contour', 'De 0 à 255.'],
    ['background', 'Fond du HUD', 'Sa couleur et son opacité.'],
    ['background_presets', 'Fonds tout prêts', 'Des couleurs de fond à choisir d’un coup.'], ['background_presets.*', 'Fond « {1} »', ''],
    ['flags', 'Comportement du HUD', ''], ['sections', 'Sections affichées', 'Chaque section du HUD, allumée ou éteinte.'],
    ['layout', 'Disposition du HUD', ''],
    ['layout.section_order', 'Ordre des sections', 'Pour tous les jobs. Noms : spells, enhancing, abilities, weapons, modes. Une section absente de la liste va à la fin.'],
    ['layout.compact', 'HUD compact', 'Allumé : pas de ligne vide sous les titres de section, colonnes plus serrées. La largeur de la fenêtre suit.'],
    ['layout.column_gap', 'Espace entre la touche et le nom', 'En espaces. Standard : 4, ou 2 en compact.'],
    ['layout.value_gap', 'Espace entre le nom et la valeur', 'En espaces. Suit le réglage précédent quand lui seul est donné.'],
    ['layout.margin_top', 'Lignes vides au-dessus', 'De 0 à 3. Standard : 1, ou 0 en compact.'], ['layout.margin_bottom', 'Lignes vides en dessous', 'De 0 à 3. Standard : 1, ou 0 en compact.'],
    ['layout.margin_side', 'Espaces à gauche et à droite', 'De 0 à 3. Standard : 2, ou 1 en compact.'],
    ['layout.padding', 'Marge du fond autour du texte', 'En pixels, de 0 à 20 : plus fin qu’une ligne vide. Standard : 0, ou 4 en compact. Pris en compte à la création du HUD (//lua reload gearswap).'],
    ['layout.key_style', 'Écriture des touches', '« symbols » (^f1 !1 ~f9) ou « words » (CTRL+F1 ALT+1 SHIFT+F9). Avec « words », la légende des symboles est cachée.'],
    ['layout.bullet', 'Symbole devant chaque valeur', 'Un nom (dot, circle, square, smallsquare, triangle, diamond, arrow, gt, dash, star, none) ou le symbole lui-même.'],
    ['layout.move_to_section', 'Lignes déplacées dans une autre section', 'À gauche le nom du mode (comme dans le fichier des touches du job) ou la touche, à droite la section. Exemple dans le fichier : CombatMode = \'weapons\'.', 'map'],
    ['layout.row_order', 'Ordre des lignes', 'Pour tous les jobs : les lignes nommées ici passent en premier dans leur section, dans cet ordre. Noms : les modes comme dans le fichier des touches du job (majuscules comprises), ou les touches. Un job peut avoir son propre ordre dans son fichier HUD.'],
    ['layout.hide_rows', 'Lignes cachées', 'La touche marche toujours. Nom du mode ou touche.'],
    ['layout.section_titles', 'Titres de section renommés', 'Pour tous les jobs. Exemple dans le fichier : weapons = \'Armes\'.', 'map'],
    ['colors', 'Couleurs du HUD', 'Le titre, les titres de section, les touches, les noms… Le fichier liste chaque couleur avec son exemple.', 'map'],
    ['colors.*', 'Couleur « {1} »', 'Rouge, vert, bleu.'],
    ['chat', 'Messages dans le chat', ''], ['chat.separator_char', 'Caractère de la ligne de séparation', 'Un caractère simple (= - * ~ #) : le chat du jeu n’affiche pas les symboles de dessin.'],
    ['chat.separator_color', 'Couleur de la ligne de séparation', 'Un numéro de couleur du chat, de 1 à 255. Standard : 160 (gris).'],
    ['auto_save_position', 'Enregistrer la position toute seule', 'Pas lu aujourd’hui : la position s’enregistre avec //gs c ui save.'], ['auto_save_delay', 'Délai de cet enregistrement', 'Pas lu aujourd’hui.'],
    ['update_throttle', 'Délai entre deux mises à jour', 'Pas lu aujourd’hui.'],
    ['rolls', 'Messages des rolls (COR)', ''], ['rolls.lucky', 'Chiffres chanceux et malchanceux', 'Affichés dans le message de chaque roll.'], ['rolls.party', 'Joueurs touchés et manqués', 'Affichés dans le message de chaque roll.'], ['rolls.remote_style', 'Roll envoyé par ton alt COR', 'La forme de son message sur ce perso : same, full, compact, line ou off.'],
    ['rolls.bust', 'Risque de bust', 'Affiché dans le message de chaque roll.'], ['rolls.eleven', 'La ligne « 11 ! »', 'Affichée quand un roll fait 11.'], ['rolls.*', 'Détail « {1} »', 'Un détail du message de chaque roll, allumé ou éteint.'],
  ],
  'WARDROBE_CONFIG.lua': [
    ['SCOPE', 'Jobs rangés', 'Plus de jobs que de wardrobes : le rangement travaille sur le job chargé. Relance //gs c wo après un changement de job.'],
    ['KEEP', 'Pièces gardées dans les premiers wardrobes', 'En plus de ce que tes sets nomment. Les anneaux de warp n’en ont pas besoin : ils marchent depuis n’importe quel wardrobe.'],
  ],
  'HP_PRIORITY_CONFIG.lua': [],
  'FIGHTS_CONFIG.lua': [
    ['hits_alt', 'Alt prévenu pendant une mesure', 'Le perso qui reçoit les commandes ci-dessous quand le journal démarre et s’arrête. Sans nom : rien n’est envoyé.'],
    ['hits_on', 'Commandes envoyées à l’alt au démarrage', 'Dans l’ordre.'], ['hits_off', 'Commandes envoyées à l’alt à l’arrêt', 'Arrêté en plein combat, l’alt continue jusqu’à la mort du monstre.'],
    ['sequence', 'Suite d’étapes de « run »', '//gs c fights hits run joue ces étapes l’une après l’autre, chacune lancée quand la précédente a atteint son objectif, puis arrête le journal.'],
    ['sheet', 'Ce que « sheet » mesure', '//gs c fights hits sheet : ce que chacune de ces abilities ajoute à la fiche du perso, lu au repos. Seules celles que le job et le sub ont sont utilisées.'],
    ['sequences', 'Autres suites d’étapes', '//gs c fights hits run <nom> joue la suite de ce nom.'], ['sequences.*', 'Suite « {1} »', 'Ses étapes, dans l’ordre.'],
    ['steps', 'Étapes de mesure', '//gs c fights hits <étape> lance les commandes de l’étape et écrit une ligne STEP dans le journal. Les coups et les weaponskills sont comptés à partir de cette ligne.'],
    ['steps.*', 'Étape « {1} »', 'Ses commandes, puis ses réglages.'],
    ['steps.*.goal', 'Objectif', 'Le compte est affiché face à lui, et sa fin est dite dans le chat.'], ['steps.*.unit', 'Ce que l’objectif compte', '« ws » : des weaponskills, pas des coups.'],
    ['steps.*.ws', 'Weaponskill lancée toute seule', 'Dès que le TP est là.'], ['steps.*.tp', 'TP attendu', '1000 quand il n’est pas donné.'],
    ['steps.*.keep', 'Abilities gardées actives', 'Relancées dès qu’elles manquent et sont prêtes ; l’objectif ne compte alors que ce qui se passe sous elles.'],
    ['steps.*.under', 'Buff exigé', 'L’objectif ne compte que ce qui se passe sous ce buff.'], ['steps.*.raise', 'TP attendu pour reprendre le buff', 'Tant que le buff manque, la weaponskill attend ce TP.'],
    ['steps.*.tp_max', 'TP maximum', 'Au-dessus, le TP est dépensé avec l’autre weaponskill ci-dessous.'], ['steps.*.dump', 'Weaponskill qui dépense le TP en trop', ''],
    ['steps.*.strip', 'Emplacements vidés', 'Vidés et verrouillés pendant l’étape, rendus à la suivante : moins de pièces, moins de précision.'],
  ],
  'SORTIE_CONFIG.lua': [
    ['alt', 'Alt piloté', 'Le perso que l’addon d’automatisation pilote pendant Sortie.'],
    ['profile_root', 'Dossier de ses profils', 'Où sont les profils Sortie de l’alt, à partir de Windower/Settings.'],
    ['stances', 'Tes postures', 'Chaque posture est une liste de « mode valeur » posés d’un coup.'], ['stances.*', 'Posture « {1} »', 'Les modes posés, sous la forme « mode valeur ».'],
    ['by_job', 'Réglages pour un autre job principal', 'Ce qui est écrit ici remplace les réglages du dessus quand tu fais Sortie avec ce job.'], ['by_job.*', 'Quand tu es {1}', ''],
    ['by_job.*.profile_root', 'Dossier des profils de l’alt', ''], ['by_job.*.stances', 'Tes postures', ''], ['by_job.*.stances.*', 'Posture « {2} »', 'Les modes posés, sous la forme « mode valeur ».'],
    ['by_job.*.targets', 'Cibles', ''], ['by_job.*.targets.*', 'Cible « {2} »', ''], ['by_job.*.targets.*.*', '{3}', ''],
    ['target_states', 'Modes posés pour chaque cible', 'Seulement sur un job qui les a. Les modes propres à une cible passent avant.'],
    ['targets', 'Cibles', '//gs c sortie <cible> : pour chaque cible, le profil de l’alt, son Indi-, ta posture et le résumé affiché.'], ['targets.*', 'Cible « {1} »', ''],
    ['targets.*.profile', 'Profil de l’alt', 'Le nom du profil chargé.'], ['targets.*.indi', 'Indi- de l’alt', 'Lancé au chargement du profil.'],
    ['targets.*.stance', 'Ta posture', 'Une des postures définies plus haut.'], ['targets.*.summary', 'Résumé affiché', 'Le texte montré en jeu quand la cible est choisie.'],
    ['targets.*.states', 'Modes propres à cette cible', 'Sous la forme « mode valeur ».'],
    ['targets.*.prep', 'Préparation avant le pull', 'Un profil chargé d’abord, avec son propre Indi- et son résumé.'],
    ['targets.*.prep.profile', 'Profil de préparation', ''], ['targets.*.prep.indi', 'Indi- de préparation', ''], ['targets.*.prep.summary', 'Résumé affiché', ''],
    ['aliases', 'Cibles identiques', 'Les boss combattus exactement pareil partagent une cible.'], ['aliases.*', '{1} se combat comme', 'Le nom de la cible utilisée.'],
    ['escort', 'Escorte', '//gs c sortie escort : l’alt pose son Indi- et te suit.'], ['escort.indi', 'Indi- de l’escorte', 'Celui utilisé quand aucun n’est nommé.'], ['escort.profile', 'Profil de l’escorte', ''],
    ['escort.states', 'Modes posés pendant l’escorte', 'Par sub.'], ['escort.states.*', 'Avec le sub /{1}', 'Sous la forme « mode valeur ».'],
    ['orders', 'Ordres en un coup à l’alt', 'Une commande console, et l’action affichée.'], ['orders.*', 'Ordre « {1} »', ''],
    ['orders.*.command', 'Commande envoyée', ''], ['orders.*.action', 'Action affichée', ''],
  ],
  '{JOB}_ALT_CUSTOM.lua': [
    ['commands', 'Tes commandes d’alt', 'Ajoutées par-dessus celles générées : un nouveau nom s’ajoute, un nom existant est remplacé par le tien.'],
    ['commands.*', 'Commande « {1} »', 'Le nom tapé pour envoyer cet ordre à l’alt.'],
    ['commands.*.action', 'Type d’action', '« ja » : une job ability, « ma » : un sort.'], ['commands.*.spell', 'Ability ou sort lancé', 'Son nom comme dans le jeu.'],
    ['commands.*.target', 'Cible', '« me » : l’alt lui-même.'], ['commands.*.level', 'Niveau requis', ''],
    ['commands.*.main_only', 'Seulement en job principal', 'L’alt doit avoir ce job en principal, pas en sub.'], ['commands.*.group', 'Groupe', 'La famille dans laquelle la commande est rangée.'],
    ['commands.*.spell_from_state', 'Sort lu dans un mode', 'Le mode dont la valeur donne le sort à lancer.'], ['commands.*.fallback', 'Sort de secours', ''],
    ['commands.*.step_delay', 'Pause entre deux étapes', 'En secondes.'], ['commands.*.chain', 'Étapes de la chaîne', 'Lancées l’une après l’autre.'],
    ['commands.*.sets_alt_buff', 'Buff marqué actif tout de suite', 'Pour que la suite le sache même si l’alt ne signale pas ses buffs.'], ['commands.*.alt_buff_duration', 'Durée de ce buff', 'En secondes.'],
    ['commands.*.sync_after', 'Redemander ses buffs à l’alt après', 'En secondes.'], ['commands.*.*', '{2}', ''],
  ],
  '{JOB}_CONFIG.lua': [
    ['idle_hp', 'Sets idle selon tes HP', 'sets.idle.Weak sous le premier pourcentage de HP, sinon sets.idle.Regen sous le second.'],
    ['skillup', 'Skill-up', '//gs c skillup : l’avatar invoqué, et les secondes avant le Release.'],
    ['*', '{1}', ''], ['*.*', '{2}', ''],
  ],
  '{JOB}_CURE_CONFIG.lua': [
    ['auto_tier_enabled', 'Choix du tier (pas lu)', 'Aujourd’hui c’est le mode Cure Auto-Tier qui allume ou éteint le choix du tier : ce réglage ne change rien.'],
    ['debug_messages', 'Messages de debug', 'Écrit « il manque X HP à la cible : Cure Y choisie ». Les messages habituels du WHM s’affichent de toute façon.'],
    ['message_color', 'Couleur de ces messages', 'Un numéro de couleur du chat.'],
  ],
  '{JOB}_ELEMENTAL_CONFIG.lua': [
    ['auto_hachirin', 'Obi élémentaire automatique', 'Quand une des conditions ci-dessous est remplie, sets.midcast.ElementalMatch se pose sur le midcast.'],
    ['check_storm', 'Compter le storm', 'Un storm actif du même élément que le sort.'], ['check_day', 'Compter le jour', 'Le jour du même élément que le sort.'],
    ['check_weather', 'Compter la météo', 'La météo du même élément que le sort.'],
  ],
  '{JOB}_MP_CONFIG.lua': [['mp_threshold', 'Seuil de MP', 'Sous ce nombre de MP, sets.midcast.MPConservation se pose. Standard : 1000.']],
  '{JOB}_REFILL.lua': [
    ['subjobs', 'Tes listes par sub', 'Avec un de ces subs, sa liste remplace celle du job.'], ['subjobs.*', 'Avec le sub /{1}', 'Remplace la liste du job avec ce sub.'],
    ['extra', 'Objets ajoutés à la liste commune', 'Un objet déjà dans la liste commune prend la quantité écrite ici.'], ['default', 'Ta liste sur ce job', 'Remplace la liste commune.'],
  ],
  '{JOB}_SABOTEUR_CONFIG.lua': [
    ['auto_trigger_spells', 'Sorts avant lesquels Saboteur part', 'Un interrupteur par sort.'], ['auto_trigger_spells.*', '{1}', 'Allumé : Saboteur est lancé avant ce sort.'],
    ['wait_time', 'Pause après Saboteur', 'En secondes, avant que le sort parte. Standard : 2.'],
  ],
  '{JOB}_SPELL_MAP.lua': [
    ['HealingHP', 'Catégorie HealingHP', 'Les sorts de soin qui dépendent des HP max (White Wind) : chacun porte son propre set de midcast.'],
    ['*', 'Catégorie {1}', 'Les sorts de Blue Magic qui portent le set de midcast de cette catégorie.'],
  ],
  '{JOB}_TIMING_CONFIG.lua': [
    ['ROTATION_DELAYS', 'Pauses d’une rotation de chants', 'En secondes.'], ['ROTATION_DELAYS.after_song', 'Après un chant', 'En secondes, avant le suivant. Monte-la si des chants sont refusés parce qu’ils partent trop tôt.'],
    ['ROTATION_DELAYS.after_locked_song', 'En plus après Honor March / Aria of Passion', 'En secondes, ajoutées à la pause précédente.'], ['ROTATION_DELAYS.*', '{1}', 'En secondes.'],
    ['ABILITY_DELAYS', 'Pauses des abilities', 'En secondes.'], ['ABILITY_DELAYS.nt_combo_delay', 'Entre Nightingale et Troubadour', 'En secondes, pour //gs c nt.'], ['ABILITY_DELAYS.*', '{1}', 'En secondes.'],
  ],
  '{JOB}_TP_CONFIG.lua': [
    ['moonshade', 'Moonshade Earring', 'La boucle à TP Bonus et le bonus qu’elle donne.'], ['moonshade.tp_bonus', 'TP Bonus', ''],
    ['pieces', 'Pièces à TP Bonus', ''], ['weapons', 'Armes à TP Bonus', ''],
  ],
  '{JOB}_WEAPONS.lua': [
    ['shields', 'Bouclier de chaque arme', 'Par posture, puis par arme.'], ['shields.*', 'Posture {1}', ''], ['shields.*.*', 'Avec {2}', 'Le bouclier porté avec cette arme dans cette posture.'],
    ['stance_weapon', 'Arme imposée par une posture', 'Quoi que dise MainWeapon.'], ['stance_weapon.*', 'Posture {1}', 'L’arme tenue dans cette posture.'],
    ['grips', 'Grip de chaque arme', ''], ['grips.*', 'Avec {1}', 'Le grip porté avec cette arme.'],
  ],
  '{JOB}_WS_CONFIG.lua': [
    ['climactic_ws', 'Weaponskills avec Climactic Flourish', 'Climactic Flourish part tout seul avant une de ces weaponskills quand les conditions ci-dessous sont remplies.'],
    ['min_tp', 'TP minimum pour Climactic Flourish', 'Sous 1000 la weaponskill ne peut pas partir : une valeur plus basse revient à 1000.'],
    ['min_target_hpp', 'HP minimum de la cible', 'En pourcentage : évite de gâcher Climactic Flourish sur un monstre presque mort.'],
    ['max_slots', 'Nombre d’emplacements', 'Combien de macros //gs c wsN sont branchées.'],
    ['by_weapon', 'Weaponskills par arme', 'Dans l’ordre des emplacements : la première est //gs c ws1.'], ['by_weapon.*', 'Avec {1}', 'ws1, ws2… dans cet ordre.'],
    ['default', 'Sans arme connue', 'Les weaponskills utilisées quand l’arme en main n’a pas de liste.'],
  ],
  '{JOB}_HUD.lua': [['*', '{1}', ''], ['*.*', '{2}', '']],
  '{JOB}_CUSTOM.lua': [['*', '{1}', ''], ['*.*', '{2}', ''], ['*.*.*', '{3}', '']],
  '{JOB}_ECOSYSTEM_DATA.lua': [
    ['correlation_matrix', 'Forces et faiblesses des écosystèmes', 'Aquan bat Amorph, qui bat Bird, qui bat Aquan ; Beast bat Lizard, qui bat Plantoid, qui bat Beast. Aucun module ne lit ce fichier aujourd’hui.'],
    ['correlation_matrix.*', '{1}', ''], ['correlation_matrix.*.strong_against', 'Fort contre', ''], ['correlation_matrix.*.weak_to', 'Faible contre', ''],
    ['correlation_matrix.*.cycle_type', 'Type de cycle', ''], ['correlation_matrix.*.group', 'Groupe', ''], ['correlation_matrix.*.note', 'Note', ''],
  ],
  '{JOB}_PET_DATA.lua': [
    ['pets', 'Pets à jug', 'Pour chaque pet : son jug, son espèce, son écosystème.'], ['pets.*', '{1}', ''], ['pets.*.broth', 'Jug', 'L’objet qui l’appelle.'],
    ['pets.*.species', 'Espèce', ''], ['pets.*.ecosystem', 'Écosystème', ''], ['pets.*.job', 'Job du pet', ''], ['ecosystems', 'Écosystèmes', ''],
  ],
  '{JOB}_SONG_CONFIG.lua': [
    ['SONG_PACKS', 'Packs de chants', 'Un pack par valeur du mode Song Mode : //gs c songs chante celui qui est choisi.'], ['SONG_PACKS.*', 'Pack {1}', ''],
    ['SONG_PACKS.*.name', 'Nom affiché', ''], ['SONG_PACKS.*.songs', 'Chants', 'Chantés dans cet ordre.'], ['SONG_PACKS.*.*', '{2}', ''],
    ['DUMMY_SONGS', 'Chants factices', 'Les chants lancés par //gs c dummy.'], ['DUMMY_SONGS.*', 'Liste « {1} »', ''],
    ['ETUDES', 'Etude de chaque attribut', ''], ['ETUDES.*', 'Pour {1}', 'Le chant utilisé.'],
    ['VICTORY_MARCH_REPLACE', 'Remplacer Victory March', 'Le chant mis à la place de Victory March, d’après le mode Victory March.'],
    ['VICTORY_MARCH_REPLACE.enabled', 'Remplacement actif', ''], ['VICTORY_MARCH_REPLACE.default', 'Choix par défaut', ''],
    ['VICTORY_MARCH_REPLACE.replacements', 'Chant de chaque choix', ''], ['VICTORY_MARCH_REPLACE.replacements.*', 'Choix {1}', 'Le chant utilisé.'],
    ['SHORT_NAMES', 'Noms courts des chants', 'Le nom affiché à la place du nom complet.'], ['SHORT_NAMES.*', '{1}', 'Son nom court.'],
    ['SONG_REFINE', 'Chant de remplacement pendant un recast', 'Quand un chant de la liste recharge, celui qui lui correspond est lancé à la place (souvent le tier du dessous).'], ['SONG_REFINE.enabled', 'Actif', ''],
    ['SONG_REFINE.tiers', 'Tier de remplacement', 'Pour chaque chant, celui qui le remplace.'], ['SONG_REFINE.tiers.*', '{1}', 'Le chant qui le remplace.'], ['SONG_REFINE.tiers.*.*', '{2}', ''],
    ['DEBUFF_SONGS', 'Chant de chaque commande de debuff', '//gs c lullaby, lullaby2, elegy, requiem.'], ['DEBUFF_SONGS.*', '//gs c {1}', 'Le chant lancé.'],
    ['REFRESH_BELOW', 'Ne rien rechanter s’il reste plus de', 'En secondes : //gs c songs n’envoie rien tant que tous les chants du pack sont les tiens avec plus de temps que ça. 0 : toujours chanter.'],
  ],
};

// The French of one setting: {title, desc, map} (null: no line fits). `file`: the file's name; `path`: the setting's place
const MOD_REST_RE = new Map();
function modRestMatch(list, path){
  for (const row of list || []) {
    if (!MOD_REST_RE.has(row[0])) MOD_REST_RE.set(row[0], new RegExp('^' + row[0].split('*').map(s => s.replace(/[.+?^${}()|[\]\\]/g, '\\$&')).join('\u0000').replace(/\u0000(?=.)/g, '([^.]+)').replace(/\u0000$/, '(.+)') + '$'));
    const m = MOD_REST_RE.get(row[0]).exec(path);
    if (m) { const fill = s => s.replace(/\{(\d)\}/g, (all, i) => m[+i] || ''); return {title: fill(row[1]), desc: fill(row[2] || ''), map: row[3] === 'map'}; }
  }
  return null;
}
function modRestFr(file, path){
  const base = file.split('/').pop(), own = MOD_REST_FR[base] || MOD_REST_FR[base.replace(/^[A-Z]{3}_/, '{JOB}_')];
  return modRestMatch(own, path) || modRestMatch(MOD_REST_FR['*'], path);
}
