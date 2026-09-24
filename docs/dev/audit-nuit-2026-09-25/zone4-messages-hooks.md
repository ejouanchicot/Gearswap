# Audit de nuit 2026-09-25 — Zone 4 : messages et hooks

Périmètre : `shared/utils/messages/**` (79 fichiers) et `shared/hooks/**` (3 fichiers).
78 fichiers retouchés. 4 fichiers écrits hier et validés en jeu laissés tels quels :
`message_sortie.lua`, `message_tempbind.lua`, `sortie_messages.lua`, `tempbind_messages.lua`.

**Comment c'est vérifié.** Après chaque fichier : `loadfile` en Lua 5.1 et fins de ligne
comparées à la sauvegarde (CRLF gardé en CRLF, LF gardé en LF). Ensuite, pour tout le
périmètre : le bytecode (listing `luac -l`, numéros de ligne retirés) est **identique** à la
sauvegarde, sauf dans les 9 fichiers où du code mort a été retiré exprès (liste plus bas).
Enfin, un test différentiel appelle 28 fonctions d'affichage (sorts, JA, WS, cooldowns,
buffs, intro de job, keybinds, rolls, altcmds, watchdog...) avec l'ancienne et la nouvelle
version : sortie chat identique octet pour octet, aucune erreur. Rien n'a été testé en jeu.

## Fait

Partout : en-tête standard (`@file` avec le chemin complet, `@version`, `@date Created`),
retrait des mentions « NEW SYSTEM / HYBRID / Migrated from old system » qui ne décrivaient
plus rien, docs `@param`/`@return` ajoutées aux fonctions publiques qui n'en avaient pas.

- `hooks/init_ability_messages.lua`, `init_spell_messages.lua`, `init_ws_messages.lua` : exemple d'utilisation corrigé (chemins `../shared/...` réels), date de création. **Aucune garde d'idempotence ajoutée** (volontaire).
- `message_core.lua` : en-tête (explique pourquoi ce module appelle `add_to_chat`), commentaire bruit retiré.
- `message_colors.lua` : en-tête et commentaires disaient que `//gs c setregion` existe — faux, corrigé ; explication du chargement de `_G.RegionConfig`.
- `message_formatter.lua` : en-tête ajouté (il n'en avait pas), doc de `show_debug`, commentaires d'historique retirés.
- `message_validator.lua` : en-tête décrivait des tests qui n'existent pas (« paramètres = signatures ») ; décrit maintenant ce qui est vraiment vérifié ; date 2025-01-07 (antérieure au dépôt) corrigée.
- `api/messages.lua` : en-tête (exemples avec des clés inexistantes remplacés), `@return` ajoutés, note sur `Messages.ability` (namespace sans fichier) et sur le lanceur de tests (les suites sont dans `_dev/`, voir plus bas).
- `core/message_engine.lua` : commentaire faux sur un cache qui « survit aux reloads » corrigé ; `{/}` documenté comme non reconnu ; commentaire français traduit. **Code** : appel `find("{/}")` dont le résultat n'était jamais lu retiré, variable de boucle inutilisée renommée `_`.
- `core/message_renderer.lua` : en-tête, doc des `options` réellement lues, commentaires bruit.
- `handlers/ability_message_handler.lua`, `spell_message_handler.lua` : commentaires de longueur de séparateur faux (la longueur est ignorée), bloc de doc orphelin remis sur `show_message`, en-tête du handler de sorts à jour (11 compétences, exemple Bio faux retiré). **Code** : variable `db_name` inutilisée retirée (×2).
- `formatters/combat/message_combat.lua` : en-tête, docs de toutes les fonctions publiques.
- `formatters/combat/message_cooldowns.lua` : en-tête, `job_name` documenté optionnel (il était marqué REQUIRED), commentaire « White base color » faux corrigé. **Code** : variable `actionColor` jamais lue retirée.
- `formatters/combat/message_ja_buffs.lua` : modes documentés `full/on/off` (le doc parlait de `name_only/disabled`), wrappers BRD documentés comme sans appelant.
- `formatters/combat/message_weaponskill.lua` : en-tête (qui l'utilise), docs.
- `formatters/jobs/message_blm|brd|bst|cor|drg|geo|rdm|whm|blm_midcast|rdm_midcast.lua` : en-têtes, docs, notes sur les fonctions désactivées ou cassées (voir Bugs). **Code** (rdm_midcast) : constante `CHAT_DEFAULT` inutilisée retirée.
- `formatters/magic/*` (buffs, debuffs, midcast, precast, songs) : en-têtes, valeurs de statut réelles (`ready` manquait), note d'historique retirée.
- `formatters/system/message_equipment|init|system|warp|watchdog.lua` : en-têtes, docs, note sur la double définition de `show_item_equip_delay`. **Code** : `message_system` — fonction locale `calculate_content_width` jamais appelée + son `require` retirés ; `message_watchdog` — variable `id_label` inutilisée retirée.
- `formatters/ui/message_commands.lua` : en-tête, 37 docs ajoutées, commentaire de largeur faux (« ~68 caractères » : c'est 81) corrigé.
- `formatters/ui/message_alt_commands.lua` : `@file`, doc de `header`. **Code** : deux fonctions locales jamais appelées (`target_note`, `job_label`) retirées.
- `formatters/ui/message_ui.lua` : en-tête. **Code** : `require` de `message_renderer` et `Colors` jamais utilisés retirés.
- `formatters/ui/message_dualbox|info|keybinds|status.lua` : en-têtes, commentaires bruit.
- `utilities/roll_messages.lua`, `party_messages.lua` : `@file`, commentaires de couleur faux ou bruit retirés, commentaire région (« EU=002 », override manuel inexistant) corrigé, `raw( x)` → `raw(x)`.
- `data/**` (33 fichiers de templates) : `@file` complet (celui de `magic_messages.lua` pointait sur `data/jobs/`), `@version`, phrase « new message system » remplacée. Aucun template touché.

## Bugs suspectés

Non corrigés (changement de comportement ou fichier hors zone).

1. **`formatters/system/message_warp.lua:516` et `:602` — `show_item_equip_delay` défini deux fois.** La 2e définition `(tag, activation_delay)` écrase la 1re `(item_name)`. `shared/utils/warp/casting/item_user.lua:292` appelle la version à 1 argument → `activation_delay` vaut `nil` → erreur Lua « concatenate a nil value » quand un objet de warp n'est pas en cooldown mais inutilisable. Déjà listé dans `warp.md`. *Correctif* : renommer la 1re (ex. `show_item_unavailable`) et l'appeler à `item_user.lua:292`.
2. **Couleurs passées comme texte : le joueur voit `{green}` au lieu d'une couleur.** Le moteur n'interprète pas les balises contenues dans un paramètre. Visible aujourd'hui : `message_warp.lua:453` `show_debug_toggle` (`//gs c warp debug` affiche « Debug mode: {green}ENABLED »). Même défaut, sans appelant : `message_blm.lua` `show_mp_conservation`, `message_bst.lua` `show_auto_engage_status`, `show_pet_tp_status`, `show_pet_hp_status`, `show_ready_move_tp_check`. *Correctif* : passer `string.char(0x1F, code)` comme le fait `message_system` (`key_color`), ou un template par état.
3. **`MessageRenderer.send(1, texte)` — arguments inversés** dans `message_cooldowns`, `message_debuffs`, `message_rdm_midcast`, `message_warp` (déjà connu, ~105 appels). Ça marche par accident : l'`add_to_chat` de GearSwap détecte la chaîne et imprime en couleur 8 ; les couleurs en ligne masquent le problème. Conséquences réelles : le découpage multi-ligne, l'horodatage et les stats du renderer ne s'appliquent pas, et les couleurs `CHAT_*` de `message_rdm_midcast` ne servent à rien. *Correctif* : inverser les arguments, puis vérifier en jeu que la couleur de base ne change rien.
4. **`hooks/init_ws_messages.lua:118` — seuil de TP relu côté client** (connu) : un WS lancé à 1000 TP avec du lag peut ne rien afficher. Et en mode `full`, un WS absent de la base n'affiche rien du tout (`:126-129`). *Correctif* : ne pas filtrer sur le TP, et retomber sur `show_ws_tp` si la base ne connaît pas le WS.
5. **`message_brd.lua` `show_dummy_cast`** envoie la clé `BRD.dummy_cast`, commentée dans `brd_messages.lua:144` → message d'erreur si appelée (ses appelants sont commentés aussi).
6. **`api/messages.lua` `//gs c testmsg`** : les suites de tests ont été déplacées dans `_dev/message_api_tests/`, hors du chemin de `require` (`api/tests/` n'existe pas). Résultat : « 0/0 tests PASSED » sans rien tester, ou « Test file not found ». Connu.
7. **`formatters/magic/message_midcast.lua` `show_debug_step`** ne protège pas `value` (`nil` → message d'erreur de format), contrairement à la version precast (`value or ""`). À vérifier dans les appelants de `midcast_manager.lua`.
8. **`formatters/ui/message_commands.lua` `show_region_detection_failed`** et le template `commands_messages.lua:67` conseillent `//gs c setregion us/eu`, commande qui n'existe pas (connu).

## Doutes / à décider

- `message_engine.lua:25-32` — le bloc `_G.MESSAGE_ENGINE_LOADED` ne fait rien (les tables viennent d'être créées). Gardé parce que `debug/global_probe.lua:56` liste ce global. Supprimer les deux ensemble ?
- `message_engine.lua:195-210, 232-235` — `error()` suivi d'un `return false` inatteignable, et une branche de repli dans `format` jamais atteinte (connu). Nettoyage à faire en connaissance de cause.
- `message_colors.lua:40-51` — priorités 1 et 2 (`_G.ORANGE_COLOR_CODE`, `_G.DETECTED_FFXI_REGION`) : rien ne les pose. Implémenter `setregion` ou les supprimer ?
- `message_geo.lua:54-60` — entrées `Fira/Blizzara/...` de `ELEMENT_COLORS` : `show_geo_cast` n'est appelée que pour les `Geo-`, ces entrées ne servent pas.
- `message_precast.lua` `show_equipment` : ne lit que `left_ear/right_ear/left_ring/right_ring` ; un set écrit avec `ear1/ring1` n'affiche aucune ligne d'oreille/anneau dans le debug.
- `party_messages.lua:45` — séparateur fixe de 40 `=` (pas `SEPARATOR_WIDTH`). Pas touché (largeurs validées en jeu).
- `roll_messages.lua` `show_roll_bust_rate` duplique les seuils de `BUST_BANDS` et utilise un séparateur de 48 ; elle n'a pas d'appelant.
- Bio : `spell_message_handler` le trouve dans `DARK_MAGIC_DATABASE` (catégorie `Dark`), donc il suit la config Enhancing et pas Enfeebling. Sans effet visible tant que `spellmsg` règle les deux ensemble.
- `message_rdm_midcast.lua` contient des émojis (🔍 ⚠️ 📊) dans le texte ; FFXI ne sait pas les afficher. Texte joueur : pas touché.
- `message_commands.lua` fait maintenant 719 lignes (651 avant, déjà au-dessus de 600) à cause des docs ajoutées ; ses deux grosses fonctions sont couvertes par l'exemption « affichage sans branchement ».

## Code mort probable

Rien n'a été supprimé à part des variables et fonctions locales (voir « Fait »). Preuves obtenues par grep sur tout `data/`, `Tetsouo/` et `Kaories/` compris, appels dynamiques (`M.send` avec clé construite, `MessageCommands['show_' .. prefix ..]`) vérifiés à la main.

- **Façade `message_formatter.lua`** : au moins 56 wrappers qui ne sont mentionnés **nulle part** ailleurs (la doc `messages.md` en compte 163 sans appelant). Entre autres : `show_ja_active/ended/with_description/using/using_double`, les 10 `show_song_*`, les 4 `*_new`, les 6 `show_convert_*/show_chainspell_*/show_composure_*` (qui pointent en plus vers des fonctions **inexistantes** de `message_rdm.lua`, lignes 303-308), `show_rdm_doom_removed`, 30 `show_bst_*`.
- **`formatters/magic/message_songs.lua` en entier** : seulement joignable par les `show_song_*` de la façade, qui n'ont aucun appelant (BRD utilise `message_brd.lua`).
- **`message_ja_buffs.lua`** : les 7 raccourcis BRD (`show_soul_voice_activated`...`show_marcato_used`) et `show_using_double` — aucun appel.
- **`message_brd.lua`** : `show_song_cast_generic` (0 appel), `show_dummy_cast` (appels commentés, `BRD_COMMANDS.lua:404,415`).
- **`message_blm.lua`** : `show_buff_status` (pas dans la façade, 0 appel), `show_mp_conservation` (0 appel ; BLM utilise celle de `message_blm_midcast`).
- **`message_bst.lua`** : `show_auto_engage_status`, `show_pet_tp_status`, `show_pet_hp_status`, `show_ready_move_tp_check` (grep sur ces noms hors `utils/messages/` : 0 résultat).
- **`roll_messages.lua`** : `show_roll_natural_eleven`, `show_roll_bust_rate`, `show_roll_not_found` (0 appel).
- **`message_init.lua`** : `show_watchdog_load_failed`, `show_module_loaded`, `show_init_complete` (INIT_SYSTEMS n'utilise que `show_module_load_failed`).
- **`message_warp.lua`** : `show_warp_countdown/unavailable/no_charges/recast/charges_remaining` et leurs 5 équivalents `show_tele_*` (0 appel, y compris dynamique dans `shared/utils/warp/`).
- **`message_watchdog.lua`** : `show_stopped`, `show_debug_midcast_spell`. **`message_midcast.lua`** : `show_target_details_header`, `show_target_property`.
- **`message_commands.lua`** : tout le bloc région (`show_detect_region_*`, `show_windower_info_*`, `show_region_*`, `show_setregion_usage`, `show_invalid_region`, `show_color_sample`) — la commande `detectregion` n'existe plus.
- **Fichiers de templates jamais envoyés** : `data/systems/info_messages.lua` (namespace `INFO` : 0 `M.send`, `message_info.lua` écrit tout à la main) et `data/jobs/run_messages.lua` (namespace `RUN` : 0 envoi, clés `valiance_expired`/`vallation_expired`).
- **Clés de templates jamais envoyées** (le formateur imprime à la main à la place) : `COMMANDS` `testcolors_header/footer/separator`, `debugsubjob_header/instructions`, `detectregion_header/footer`, `detection_results_header`, `region_detection_failed`, `jamsg|spellmsg|wsmsg_current_mode` et `_status_header` ; `EQUIPMENT` `check_header_separator/title`, `summary_missing/separator/storage/valid_sets` ; `KEYBINDS` `keybind_line` ; `SYSTEM` `colortest_sample` ; `WATCHDOG` `stats_header`.
- **API sans appelant** (connu) : `Messages.ability` (pas de `ability_messages.lua`), `custom/config/toggle/set_filter_level/set_color_mode/toggle_timestamp/show_stats/reset_stats/list/get_engine_stats/clear_cache/help`, les fonctions de configuration du renderer, `MessageColors.get_action_color`, `MessageCore.success`, `MessageFormatter.COLORS`, le champ `prefix_style` du renderer.
