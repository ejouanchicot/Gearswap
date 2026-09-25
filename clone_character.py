#!/usr/bin/env python3
"""
Smart Character Clone - Tetsouo GearSwap System
================================================
Clones character data using _master/ as central source and character_db.lua
to determine which jobs each character needs.

Flow:
  1. Parse character_db.lua for known characters + jobs
  2. Ask character name
  3. If known in DB → auto-select their jobs
  4. If unknown → ask which jobs to include
  5. Copy only relevant files from _master/
  6. Configure dualbox + region

Usage:
    python clone_character.py              (French - default)
    python clone_character.py --lang en    (English)

Author: Tetsouo GearSwap Project
Version: 4.1.0 - Keeps the files written in game across a re-clone
Date: 2026-09-25
"""

import os
import re
import shutil
import sys
from datetime import datetime
from pathlib import Path

# ============================================================================
# TRANSLATIONS
# ============================================================================

TRANSLATIONS = {
    'fr': {
        # Banners
        'banner_title': 'CLONE INTELLIGENT - SYSTÈME GEARSWAP TETSOUO',
        'banner_validation': 'VALIDATION',
        'banner_db': 'BASE DE DONNÉES PERSONNAGES',
        'banner_jobs': 'SÉLECTION DES JOBS',
        'banner_dualbox': 'CONFIGURATION DUAL-BOXING',
        'banner_confirmation': 'CONFIRMATION DU CLONE',
        'banner_cloning': 'CLONAGE EN COURS',
        'banner_complete': 'CLONAGE TERMINÉ',

        # Database
        'db_found': "[OK] character_db.lua trouvé",
        'db_not_found': "[ATTENTION] character_db.lua introuvable - mode manuel",
        'db_char_known': "[OK] '{}' trouvé dans la base de données",
        'db_char_jobs': "   Jobs: {}",
        'db_char_role': "   Rôle: {}",
        'db_char_unknown': "[INFO] '{}' n'est pas dans la base de données",
        'db_char_unknown_desc': "   Vous pourrez choisir les jobs manuellement.",

        # Job selection
        'jobs_auto': "[OK] {} jobs sélectionnés automatiquement depuis la DB:",
        'jobs_manual_prompt': "Entrez les jobs séparés par des virgules (ex: WAR,PLD,DNC): ",
        'jobs_manual_error': "ERREUR: Aucun job valide trouvé. Jobs disponibles: {}",
        'jobs_selected': "   Jobs sélectionnés: {}",
        'jobs_no_config': "   [INFO] Pas de config trouvée pour: {} (normal pour certains jobs)",
        'jobs_no_entry': "   [WARN] Pas de fichier d'entrée pour: {} - ces jobs ne chargeront pas",
        'restored': "   [OK] {} (repris de la sauvegarde)",
        'jobs_no_entry': "   [INFO] Pas de fichier entry pour: {} (sera ignoré)",

        # Validation
        'master_not_found': "ERREUR: Dossier _master/ introuvable!",
        'master_location': "   Emplacement attendu: {}",
        'target_empty': "ERREUR: Le nom du personnage ne peut pas être vide!",
        'target_alphanum': "ERREUR: Le nom doit contenir uniquement des lettres et chiffres!",
        'target_length': "ERREUR: Le nom doit faire entre 2 et 15 caractères!",
        'target_exists': "ATTENTION: Le personnage '{}' existe déjà!",
        'target_location': "   Emplacement: {}",
        'replace_existing': "Le remplacer? Il sera mis en sauvegarde après la confirmation finale (o/n): ",
        'backup_ok': "[OK] Ancien répertoire mis en sauvegarde: {}",
        'backup_failed': "ERREUR: Échec de la mise en sauvegarde, rien n'a été modifié: {}",

        # Dual-boxing
        'dualbox_intro': "\nLe dual-boxing permet à 2 personnages de communiquer (ALT >> MAIN).",
        'dualbox_desc': "L'ALT envoie les changements de job au MAIN.\n",
        'role_question': "Est-ce que '{}' est MAIN ou ALT? (main/alt): ",
        'role_error': "ERREUR: Entrez 'main' ou 'alt'",
        'main_desc': "\n'{}' est le personnage MAIN.",
        'main_receives': "Reçoit les mises à jour des personnages ALT.\n",
        'alt_name_prompt': "Nom du personnage ALT (ou Entrée pour ignorer): ",
        'main_will_receive': "[OK] '{}' recevra les mises à jour de '{}'",
        'dualbox_disabled': "[OK] Dual-boxing désactivé pour '{}'",
        'alt_desc': "\n'{}' est un personnage ALT.",
        'alt_sends': "Envoie les mises à jour au personnage MAIN.\n",
        'main_name_prompt': "Nom du personnage MAIN (requis): ",
        'alt_will_send': "[OK] '{}' enverra les mises à jour à '{}'",
        'main_required': "ERREUR: Nom MAIN requis pour un ALT!",

        # Region
        'region_question': "\nRégion PlayOnline pour '{}'? (us/eu/jp): ",
        'region_error': "ERREUR: Entrez 'us', 'eu' ou 'jp'",
        'region_us': "   US = Compte américain (NBCP) - Orange disponible (057)",
        'region_eu': "   EU = Compte européen (BQJS) - Pas d'Orange (utilise 002)",
        'region_jp': "   JP = Compte japonais",
        'region_selected': "[OK] Région '{}' pour '{}'",

        # Cloning steps
        'step_dirs': "\n[1/6] Création de la structure...",
        'step_entry': "\n[2/6] Copie des fichiers entry ({} jobs)...",
        'step_sets': "\n[3/6] Copie des sets ({} jobs)...",
        'step_configs': "\n[4/6] Copie des configs ({} jobs + globaux)...",
        'step_rename': "\n[5/6] Renommage et adaptation des références...",
        'step_generate': "\n[6/6] Génération des configs personnage...",
        'copy_ok': "   [OK] {}",
        'copy_skip': "   [SKIP] {} (introuvable)",
        'rename_ok': "   [OK] {} >> {}",
        'replace_count': "   [OK] {} fichiers adaptés (Tetsouo >> {})",

        # Summary
        'summary_title': "\n[RÉSUMÉ DU CLONAGE]",
        'summary_source': "   Source:          _master/",
        'summary_target': "   Cible:           {}",
        'summary_jobs': "   Jobs:            {} ({})",
        'summary_role': "   Rôle:            {}",
        'summary_partner': "   Partenaire:      {}",
        'summary_entry': "   Fichiers entry:  {}",
        'summary_sets': "   Fichiers sets:   {}",
        'summary_configs': "   Fichiers config: {}",
        'clone_success': "\n[SUCCÈS] Personnage '{}' cloné avec {} jobs!",
        'clone_failed': "\n[ÉCHEC] Le clonage a échoué.",

        # Prompts
        'enter_name': "\nEntrez le nom du nouveau personnage: ",
        'confirm_clone': "\nProcéder au clonage? (o/n): ",
        'cancelled': "\n[ANNULÉ] Clonage annulé.",
        'press_enter': "\nAppuyez sur Entrée pour quitter...",

        # Config
        'conf_summary': "\n[CONFIGURATION DU CLONE]",
        'conf_source': "   Source:  _master/",
        'conf_overlay': "   Overlay: {}",
        'conf_target': "   Cible:   {}",
        'conf_jobs': "   Jobs:    {}",
        'conf_role': "   Rôle:    {}",
        'conf_alt': "   ALT:     {}",
        'conf_main': "   MAIN:    {}",
        'conf_none': "Aucun (dual-boxing désactivé)",

        # Lua comments
        'lua_role_main': 'Reçoit les mises à jour des personnages ALT',
        'lua_role_alt': 'Envoie les mises à jour au personnage MAIN',
    },
    'en': {
        'banner_title': 'SMART CLONE - TETSOUO GEARSWAP SYSTEM',
        'banner_validation': 'VALIDATION',
        'banner_db': 'CHARACTER DATABASE',
        'banner_jobs': 'JOB SELECTION',
        'banner_dualbox': 'DUAL-BOXING CONFIGURATION',
        'banner_confirmation': 'CLONE CONFIRMATION',
        'banner_cloning': 'CLONING IN PROGRESS',
        'banner_complete': 'CLONING COMPLETE',

        'db_found': "[OK] character_db.lua found",
        'db_not_found': "[WARNING] character_db.lua not found - manual mode",
        'db_char_known': "[OK] '{}' found in database",
        'db_char_jobs': "   Jobs: {}",
        'db_char_role': "   Role: {}",
        'db_char_unknown': "[INFO] '{}' not in database",
        'db_char_unknown_desc': "   You can select jobs manually.",

        'jobs_auto': "[OK] {} jobs auto-selected from DB:",
        'jobs_manual_prompt': "Enter jobs separated by commas (e.g., WAR,PLD,DNC): ",
        'jobs_manual_error': "ERROR: No valid jobs found. Available: {}",
        'jobs_selected': "   Selected jobs: {}",
        'jobs_no_config': "   [INFO] No config found for: {} (normal for some jobs)",
        'jobs_no_entry': "   [WARN] No entry file for: {} - these jobs will not load",
        'restored': "   [OK] {} (kept from the backup)",
        'jobs_no_entry': "   [INFO] No entry file for: {} (will be skipped)",

        'master_not_found': "ERROR: _master/ directory not found!",
        'master_location': "   Expected location: {}",
        'target_empty': "ERROR: Character name cannot be empty!",
        'target_alphanum': "ERROR: Name must contain only letters and numbers!",
        'target_length': "ERROR: Name must be between 2 and 15 characters!",
        'target_exists': "WARNING: Character '{}' already exists!",
        'target_location': "   Location: {}",
        'replace_existing': "Replace it? It is moved to a backup after the final confirmation (y/n): ",
        'backup_ok': "[OK] Old directory moved to backup: {}",
        'backup_failed': "ERROR: Backup failed, nothing was changed: {}",

        'dualbox_intro': "\nDual-boxing allows 2 characters to communicate (ALT >> MAIN).",
        'dualbox_desc': "The ALT sends job updates to the MAIN.\n",
        'role_question': "Is '{}' MAIN or ALT? (main/alt): ",
        'role_error': "ERROR: Enter 'main' or 'alt'",
        'main_desc': "\n'{}' is the MAIN character.",
        'main_receives': "Receives updates from ALT characters.\n",
        'alt_name_prompt': "ALT character name (or Enter to skip): ",
        'main_will_receive': "[OK] '{}' will receive updates from '{}'",
        'dualbox_disabled': "[OK] Dual-boxing disabled for '{}'",
        'alt_desc': "\n'{}' is an ALT character.",
        'alt_sends': "Sends updates to the MAIN character.\n",
        'main_name_prompt': "MAIN character name (required): ",
        'alt_will_send': "[OK] '{}' will send updates to '{}'",
        'main_required': "ERROR: MAIN name required for ALT!",

        'region_question': "\nPlayOnline region for '{}'? (us/eu/jp): ",
        'region_error': "ERROR: Enter 'us', 'eu' or 'jp'",
        'region_us': "   US = American account (NBCP) - Orange available (057)",
        'region_eu': "   EU = European account (BQJS) - No Orange (uses 002)",
        'region_jp': "   JP = Japanese account",
        'region_selected': "[OK] Region '{}' for '{}'",

        'step_dirs': "\n[1/6] Creating directory structure...",
        'step_entry': "\n[2/6] Copying entry files ({} jobs)...",
        'step_sets': "\n[3/6] Copying sets ({} jobs)...",
        'step_configs': "\n[4/6] Copying configs ({} jobs + globals)...",
        'step_rename': "\n[5/6] Renaming and adapting references...",
        'step_generate': "\n[6/6] Generating character configs...",
        'copy_ok': "   [OK] {}",
        'copy_skip': "   [SKIP] {} (not found)",
        'rename_ok': "   [OK] {} >> {}",
        'replace_count': "   [OK] {} files adapted (Tetsouo >> {})",

        'summary_title': "\n[CLONING SUMMARY]",
        'summary_source': "   Source:          _master/",
        'summary_target': "   Target:          {}",
        'summary_jobs': "   Jobs:            {} ({})",
        'summary_role': "   Role:            {}",
        'summary_partner': "   Partner:         {}",
        'summary_entry': "   Entry files:     {}",
        'summary_sets': "   Set files:       {}",
        'summary_configs': "   Config files:    {}",
        'clone_success': "\n[SUCCESS] Character '{}' cloned with {} jobs!",
        'clone_failed': "\n[FAILURE] Cloning failed.",

        'enter_name': "\nEnter new character name: ",
        'confirm_clone': "\nProceed with cloning? (y/n): ",
        'cancelled': "\n[CANCELLED] Cloning cancelled.",
        'press_enter': "\nPress Enter to exit...",

        'conf_summary': "\n[CLONE CONFIGURATION]",
        'conf_source': "   Source:  _master/",
        'conf_overlay': "   Overlay: {}",
        'conf_target': "   Target:  {}",
        'conf_jobs': "   Jobs:    {}",
        'conf_role': "   Role:    {}",
        'conf_alt': "   ALT:     {}",
        'conf_main': "   MAIN:    {}",
        'conf_none': "None (dual-boxing disabled)",

        'lua_role_main': 'Receives updates from ALT characters',
        'lua_role_alt': 'Sends updates to MAIN character',
    }
}

# All valid FFXI job abbreviations for this system
# PUP is left out while _master/config/pup/ does not exist: its entry file
# requires a config from there without pcall, so a cloned PUP never loads.
ALL_VALID_JOBS = [
    'BLM', 'BRD', 'BST', 'COR', 'DNC', 'DRK', 'GEO',
    'PLD', 'RDM', 'RUN', 'SAM', 'THF', 'WAR', 'WHM'
]


# ============================================================================
# CHARACTER DATABASE PARSER
# ============================================================================

def parse_character_db(db_path):
    """
    Parse character_db.lua to extract character → jobs mapping.
    Returns dict: { 'Tetsouo': {'jobs': ['BLM','BRD',...], 'role': 'main'}, ... }
    """
    characters = {}

    if not db_path.exists():
        return characters

    try:
        content = db_path.read_text(encoding='utf-8')
    except Exception:
        return characters

    # Parse each character block:
    #   Tetsouo = {
    #       jobs = { 'BLM', 'BRD', ... },
    #       role = 'main',
    #   },
    # Pattern: Name (mixed case, not ALL_CAPS) = { ... jobs = { ... } ... role = '...' }
    char_pattern = r"([A-Z][a-z]\w*)\s*=\s*\{[^}]*jobs\s*=\s*\{([^}]*)\}[^}]*role\s*=\s*['\"](\w+)['\"]"
    for match in re.finditer(char_pattern, content, re.DOTALL):
        name = match.group(1)
        jobs_str = match.group(2)
        role = match.group(3)

        # Extract job abbreviations from the jobs string
        jobs = re.findall(r"'(\w+)'", jobs_str)
        characters[name] = {
            'jobs': [j.upper() for j in jobs],
            'role': role
        }

    return characters


# ============================================================================
# CHARACTER CLONER
# ============================================================================

# Files the game session writes into a character folder (HUD position, message
# modes, alt window and alt orders, owned warp items, temporary binds). A
# re-clone moves the old folder aside; these are copied back from it so the
# player does not lose them. dualbox_role.lua is left out on purpose: the
# re-clone writes DUALBOX_CONFIG.lua from the role asked for, and an old role
# file would silently override it.
KEPT_ON_RECLONE = [
    ('config', 'ui_settings.lua'),
    ('config', 'message_modes.lua'),
    ('config', 'alt_window.lua'),
    ('config', 'alt_state.lua'),
    ('config', 'WARP_ITEMS_OWNED.lua'),
    ('temp_binds.lua',),
]


class SmartCharacterCloner:
    """Smart character cloner using _master/<source>/ and character_db.

    The _master/ folder now contains per-character template subfolders:
        _master/Tetsouo/   <- default source (8-wardrobe MAIN setup)
        _master/Kaories/   <- ALT setup (4 wardrobes, COR/GEO/PLD/RDM)

    The cloner picks one as the source via `source_name` (default: Tetsouo).
    Use `--source Kaories` (CLI) to clone from the Kaories template instead.
    The overlay is applied only to the character it belongs to (target ==
    source) or when `--source` names it; any other character is built from
    the generic _master/ files alone.
    """

    DEFAULT_SOURCE = "Tetsouo"  # Default template character

    def __init__(self, base_dir=None, lang='fr', source_name=None):
        if base_dir is None:
            self.base_dir = Path(__file__).parent.absolute()
        else:
            self.base_dir = Path(base_dir)

        # Source character (template name used in file headers etc.)
        self.TEMPLATE_NAME = source_name or self.DEFAULT_SOURCE
        self.source_explicit = source_name is not None
        # Master dir = generic Tetsouo-based template (root of _master/).
        self.master_dir = self.base_dir / '_master'
        # Override dir = per-character overlay. Files found here REPLACE the
        # corresponding files from master_dir during clone (e.g.
        # _master/Kaories/sets/cor_sets.lua wins over _master/sets/cor_sets.lua).
        # clone() drops it (None) when the target is another character.
        self.override_dir = self.master_dir / self.TEMPLATE_NAME
        self.db_path = self.base_dir / 'character_db.lua'
        self.lang = lang
        self.t = TRANSLATIONS.get(lang, TRANSLATIONS['fr'])
        self.yes_answers = ['y', 'o', 'yes', 'oui']

        # Counters for summary
        self.count_entry = 0
        self.count_sets = 0
        self.count_configs = 0
        self._generic_files = set()

    def banner(self, key):
        """Print a section banner."""
        print("\n" + "=" * 70)
        print(f"  {self.t[key]}")
        print("=" * 70)

    # ------------------------------------------------------------------
    # VALIDATION
    # ------------------------------------------------------------------

    def validate_master(self):
        """Check that _master/ exists with required subdirectories."""
        if not self.master_dir.exists() or not self.master_dir.is_dir():
            print(self.t['master_not_found'])
            print(self.t['master_location'].format(self.master_dir))
            return False

        required = ['entry', 'sets', 'config', 'config_global']
        for subdir in required:
            if not (self.master_dir / subdir).exists():
                print(f"   ERREUR: _master/{subdir}/ manquant!")
                return False

        return True

    def validate_target(self, name):
        """Validate target character name."""
        if not name:
            print(self.t['target_empty'])
            return False
        if not name.isalnum():
            print(self.t['target_alphanum'])
            return False
        if len(name) < 2 or len(name) > 15:
            print(self.t['target_length'])
            return False

        target_dir = self.base_dir / name
        if target_dir.exists():
            print(self.t['target_exists'].format(name))
            print(self.t['target_location'].format(target_dir))
            response = input(self.t['replace_existing']).lower()
            if response not in self.yes_answers:
                return False
            # Nothing is touched here: clone() moves the folder aside, and it
            # only runs once the final confirmation has been answered yes.

        return True

    def _backup_existing(self, target_dir, target_name):
        """Move an existing character folder aside instead of deleting it.

        The backup goes next to data/, not inside it: GearSwap only searches
        data/<name>/, data/common/ and data/ for job files, and the wardrobe
        and refill scanners only walk data/, so a backup is never loaded.
        Returns the backup folder, or None when the move failed.
        """
        stamp = datetime.now().strftime('%Y%m%d-%H%M%S')
        backup_dir = self.base_dir.parent / 'clone_backups' / f'{target_name}_{stamp}'
        try:
            backup_dir.parent.mkdir(parents=True, exist_ok=True)
            shutil.move(str(target_dir), str(backup_dir))
        except Exception as e:
            print(self.t['backup_failed'].format(e))
            return None
        print(self.t['backup_ok'].format(backup_dir))
        return backup_dir

    def _restore_kept_files(self, backup_dir, target_dir):
        """Copy the files written in game back from the backup."""
        for parts in KEPT_ON_RECLONE:
            src = backup_dir.joinpath(*parts)
            if src.is_file():
                dst = target_dir.joinpath(*parts)
                dst.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(src, dst)
                print(self.t['restored'].format('/'.join(parts)))

    # ------------------------------------------------------------------
    # DATABASE LOOKUP + JOB SELECTION
    # ------------------------------------------------------------------

    def lookup_character(self, name):
        """Look up character in database. Returns (jobs, role) or (None, None)."""
        self.banner('banner_db')

        if not self.db_path.exists():
            print(self.t['db_not_found'])
            return None, None

        print(self.t['db_found'])
        characters = parse_character_db(self.db_path)

        # Case-insensitive lookup
        for char_name, data in characters.items():
            if char_name.lower() == name.lower():
                print(self.t['db_char_known'].format(char_name))
                print(self.t['db_char_jobs'].format(', '.join(data['jobs'])))
                print(self.t['db_char_role'].format(data['role'].upper()))
                return data['jobs'], data['role']

        print(self.t['db_char_unknown'].format(name))
        print(self.t['db_char_unknown_desc'])
        return None, None

    def select_jobs(self, name, db_jobs):
        """Select jobs for the character (auto from DB or manual)."""
        self.banner('banner_jobs')

        if db_jobs:
            print(self.t['jobs_auto'].format(len(db_jobs)))
            print(self.t['jobs_selected'].format(', '.join(db_jobs)))
            return db_jobs

        # Manual selection
        print(f"   Jobs disponibles: {', '.join(ALL_VALID_JOBS)}")
        while True:
            raw = input(self.t['jobs_manual_prompt']).strip().upper()
            jobs = [j.strip() for j in raw.split(',') if j.strip() in ALL_VALID_JOBS]
            if jobs:
                print(self.t['jobs_selected'].format(', '.join(jobs)))
                return jobs
            print(self.t['jobs_manual_error'].format(', '.join(ALL_VALID_JOBS)))

    # ------------------------------------------------------------------
    # DUALBOX + REGION CONFIG (reused from v3)
    # ------------------------------------------------------------------

    def ask_dualbox(self, name, db_role):
        """Ask for dual-boxing configuration. Pre-fills role from DB."""
        self.banner('banner_dualbox')
        print(self.t['dualbox_intro'])
        print(self.t['dualbox_desc'])

        config = {
            'role': db_role or 'main',
            'character_name': name,
            'enabled': False,
            'alt_character': None,
            'main_character': None,
        }

        # If role from DB, confirm; otherwise ask
        if db_role:
            print(f"   [DB] Rôle détecté: {db_role.upper()}")
            role = db_role
        else:
            while True:
                role = input(self.t['role_question'].format(name)).strip().lower()
                if role in ['main', 'alt']:
                    break
                print(self.t['role_error'])

        config['role'] = role

        if role == 'main':
            print(self.t['main_desc'].format(name))
            print(self.t['main_receives'])
            alt_name = input(self.t['alt_name_prompt']).strip()
            if alt_name:
                config['alt_character'] = alt_name.capitalize()
                config['enabled'] = True
                print(self.t['main_will_receive'].format(name, config['alt_character']))
            else:
                print(self.t['dualbox_disabled'].format(name))
        else:
            print(self.t['alt_desc'].format(name))
            print(self.t['alt_sends'])
            while True:
                main_name = input(self.t['main_name_prompt']).strip()
                if main_name:
                    config['main_character'] = main_name.capitalize()
                    config['enabled'] = True
                    print(self.t['alt_will_send'].format(name, config['main_character']))
                    break
                print(self.t['main_required'])

        return config

    def ask_region(self, name):
        """Ask for PlayOnline region."""
        print(self.t['region_us'])
        print(self.t['region_eu'])
        print(self.t['region_jp'])
        while True:
            region = input(self.t['region_question'].format(name)).strip().upper()
            if region in ['US', 'EU', 'JP']:
                print(self.t['region_selected'].format(region, name))
                return region
            print(self.t['region_error'])

    # ------------------------------------------------------------------
    # OVERLAY RESOLUTION
    # ------------------------------------------------------------------

    def _resolve_src(self, relative_parts):
        """Return overlay path if the file exists in the per-char overlay,
        otherwise the generic master path.

        relative_parts: tuple/list of path components relative to master root,
                        e.g. ('sets', 'cor_sets.lua') or
                             ('entry', f'{self.TEMPLATE_NAME}_{job}.lua').
        """
        if self.override_dir is not None:
            overlay = self.override_dir.joinpath(*relative_parts)
            if overlay.exists():
                return overlay
        return self.master_dir.joinpath(*relative_parts)

    def _select_overlay(self, target_name):
        """Return the overlay folder to use for target_name, or None.

        _master/<source>/ holds one character's own files (Tetsouo's
        wardrobe layout and refill lists, his SMN). A new character must not
        inherit them just because Tetsouo is the default source, so the
        overlay applies only when the target is that character or when
        --source asked for it. Otherwise a target with its own overlay
        (_master/<target>/) gets that one.
        """
        if self.source_explicit or target_name.lower() == self.TEMPLATE_NAME.lower():
            return self.master_dir / self.TEMPLATE_NAME
        own = self.master_dir / target_name
        if own.is_dir():
            return own
        return None

    # ------------------------------------------------------------------
    # CLONING ENGINE
    # ------------------------------------------------------------------

    def clone(self, target_name, jobs, dualbox_config, region):
        """Execute smart cloning: only selected jobs from _master/."""
        self.banner('banner_cloning')

        target_dir = self.base_dir / target_name
        jobs_lower = [j.lower() for j in jobs]
        jobs_upper = [j.upper() for j in jobs]

        backup_dir = None
        if target_dir.exists():
            backup_dir = self._backup_existing(target_dir, target_name)
            if backup_dir is None:
                return False

        self.override_dir = self._select_overlay(target_name)

        # ── Step 1: Create directory structure ─────────────────────────
        print(self.t['step_dirs'])
        (target_dir / 'sets').mkdir(parents=True, exist_ok=True)
        (target_dir / 'config').mkdir(parents=True, exist_ok=True)
        print(self.t['copy_ok'].format(f"{target_name}/sets/"))
        print(self.t['copy_ok'].format(f"{target_name}/config/"))

        # Note: each file is resolved via _resolve_src() so that any file
        # present under the overlay (_master/<TEMPLATE_NAME>/, when selected
        # above) overrides its counterpart in _master/. Without an overlay the
        # clone uses _master/ alone.

        # Determine entry-file basename. Kaories overlay stores "Kaories_<JOB>"
        # files; the Tetsouo template uses "Tetsouo_<JOB>". We try the
        # template-name form first, then fall back to Tetsouo-prefixed form
        # (since the overlay's file may use the source name as the prefix).
        def find_entry_src(job_upper):
            # Try overlay with TEMPLATE_NAME prefix
            if self.override_dir is not None:
                owner = self.override_dir.name
                cand = self.override_dir / 'entry' / f'{owner}_{job_upper}.lua'
                if cand.exists():
                    return cand, f'{owner}_{job_upper}.lua'
            # Try master with Tetsouo prefix (the canonical generic template)
            cand = self.master_dir / 'entry' / f'{self.DEFAULT_SOURCE}_{job_upper}.lua'
            if cand.exists():
                return cand, f'{self.DEFAULT_SOURCE}_{job_upper}.lua'
            return None, None

        # ── Step 2: Copy entry files (only selected jobs) ─────────────
        print(self.t['step_entry'].format(len(jobs)))
        self.count_entry = 0
        no_entry_jobs = []
        for job_upper, job_lower in zip(jobs_upper, jobs_lower):
            src, src_label = find_entry_src(job_upper)
            dst = target_dir / f'{target_name}_{job_upper}.lua'
            if src and src.exists():
                self._copy(src, dst)
                print(self.t['copy_ok'].format(f"{target_name}_{job_upper}.lua"))
                self.count_entry += 1
            else:
                print(self.t['copy_skip'].format(f"entry/{src_label or job_upper}"))
                no_entry_jobs.append(job_upper)
        if no_entry_jobs:
            print(self.t['jobs_no_entry'].format(', '.join(no_entry_jobs)))

        # ── Step 3: Copy set files (only selected jobs) ───────────────
        print(self.t['step_sets'].format(len(jobs)))
        self.count_sets = 0
        for job_lower in jobs_lower:
            src = self._resolve_src(('sets', f'{job_lower}_sets.lua'))
            dst = target_dir / 'sets' / f'{job_lower}_sets.lua'
            modular_src = self.override_dir / 'sets' / job_lower if self.override_dir else None
            if modular_src is not None and modular_src.is_dir():
                # The character plays this job with modular sets (Tetsouo:
                # sets/<job>/{armor,capes,weapons,<job>_sets}.lua) and his
                # overlay entry includes sets/<job>/<job>_sets.lua: the
                # modular tree wins over the generic flat file.
                shutil.copytree(modular_src, target_dir / 'sets' / job_lower, dirs_exist_ok=True)
                print(self.t['copy_ok'].format(f"sets/{job_lower}/"))
                self.count_sets += 1
            elif src.exists():
                self._copy(src, dst)
                print(self.t['copy_ok'].format(f"sets/{job_lower}_sets.lua"))
                self.count_sets += 1
            else:
                print(self.t['copy_skip'].format(f"sets/{job_lower}_sets.lua"))

        # Files the modular sets and the craft/fish commands need, whatever
        # the jobs: sets/common/ (shared rings) and loose sets at the root of
        # the overlay's sets/ (bonecraft_sets.lua, fishing_sets.lua).
        if self.override_dir is not None and (self.override_dir / 'sets').is_dir():
            overlay_sets = self.override_dir / 'sets'
            if (overlay_sets / 'common').is_dir():
                shutil.copytree(overlay_sets / 'common', target_dir / 'sets' / 'common', dirs_exist_ok=True)
                print(self.t['copy_ok'].format("sets/common/"))
            for loose in sorted(overlay_sets.glob('*.lua')):
                self._copy(loose, target_dir / 'sets' / loose.name)
                print(self.t['copy_ok'].format(f"sets/{loose.name}"))

        # ── Step 4: Copy configs (job-specific + global) ──────────────
        print(self.t['step_configs'].format(len(jobs)))
        self.count_configs = 0

        # Job-specific configs (per-file overlay so REFILL etc. can be Kaories-specific)
        no_config_jobs = []
        for job_lower in jobs_lower:
            master_jobdir = self.master_dir / 'config' / job_lower
            override_jobdir = self.override_dir / 'config' / job_lower if self.override_dir else None
            dst_dir = target_dir / 'config' / job_lower
            if not master_jobdir.exists() and not (override_jobdir and override_jobdir.exists()):
                no_config_jobs.append(job_lower.upper())
                continue
            dst_dir.mkdir(parents=True, exist_ok=True)
            # Union of filenames in master and overlay
            seen = set()
            for d in (master_jobdir, override_jobdir):
                if d and d.exists():
                    for f in d.glob('*.lua'):
                        seen.add(f.name)
            file_count = 0
            for fname in sorted(seen):
                src = self._resolve_src(('config', job_lower, fname))
                if src.exists():
                    self._copy(src, dst_dir / fname)
                    file_count += 1
            self.count_configs += file_count
            print(self.t['copy_ok'].format(f"config/{job_lower}/ ({file_count} files)"))

        # Config folders that belong to no single job: the dual-box alt
        # commands (config/alt/, read whatever the job) and craft/fish
        # refills (config/craft/). Same per-file rule: the overlay wins.
        # config/alt/ is how a MAIN drives its alt; an alt given the folder
        # would send its own command names to the main instead.
        shared_dirs = ['craft']
        if (dualbox_config or {}).get('role') == 'main':
            shared_dirs.insert(0, 'alt')
        for shared_dir in shared_dirs:
            names = set()
            for d in (self.master_dir / 'config' / shared_dir,
                      self.override_dir / 'config' / shared_dir if self.override_dir else None):
                if d and d.exists():
                    names.update(f.name for f in d.glob('*.lua'))
            if not names:
                continue
            dst_dir = target_dir / 'config' / shared_dir
            dst_dir.mkdir(parents=True, exist_ok=True)
            for fname in sorted(names):
                src = self._resolve_src(('config', shared_dir, fname))
                if src.exists():
                    self._copy(src, dst_dir / fname)
            self.count_configs += len(names)
            print(self.t['copy_ok'].format(f"config/{shared_dir}/ ({len(names)} files)"))

        if no_config_jobs:
            print(self.t['jobs_no_config'].format(', '.join(no_config_jobs)))

        # Global configs (overlay-aware: Kaories' DUALBOX/WARDROBE/REGION
        # override generic templates; new files in overlay are also copied).
        master_globals = self.master_dir / 'config_global'
        override_globals = self.override_dir / 'config_global' if self.override_dir else None
        seen_globals = set()
        for d in (master_globals, override_globals):
            if d and d.exists():
                for f in d.glob('*.lua'):
                    seen_globals.add(f.name)
        for fname in sorted(seen_globals):
            src = self._resolve_src(('config_global', fname))
            if src.exists():
                dst = target_dir / 'config' / fname
                self._copy(src, dst)
                self.count_configs += 1
                print(self.t['copy_ok'].format(f"config/{fname} (global)"))

        # ── Step 5: Rename references (Tetsouo → target) ─────────────
        print(self.t['step_rename'])
        modified = self._replace_references(target_dir, target_name)
        print(self.t['replace_count'].format(modified, target_name))


        # ── Step 6: Generate character-specific configs ───────────────
        print(self.t['step_generate'])
        self._create_dualbox_config(target_dir, dualbox_config)
        self._create_region_config(target_dir, target_name, region)
        self.count_configs += 2  # DUALBOX + REGION

        # After the rename: these already carry the right names, including
        # the other characters' (an alt_state follow leader, for instance).
        if backup_dir is not None:
            self._restore_kept_files(backup_dir, target_dir)

        # ── Summary ───────────────────────────────────────────────────
        self.banner('banner_complete')
        print(self.t['summary_title'])
        print(self.t['summary_source'])
        print(self.t['summary_target'].format(target_name))
        print(self.t['summary_jobs'].format(len(jobs), ', '.join(jobs_upper)))
        print(self.t['summary_role'].format(dualbox_config['role'].upper()))

        partner = (dualbox_config.get('alt_character') or
                   dualbox_config.get('main_character') or
                   self.t['conf_none'])
        print(self.t['summary_partner'].format(partner))
        print(self.t['summary_entry'].format(self.count_entry))
        print(self.t['summary_sets'].format(self.count_sets))
        print(self.t['summary_configs'].format(self.count_configs))
        print(self.t['clone_success'].format(target_name, len(jobs)))

        return True

    # ------------------------------------------------------------------
    # INTERNAL HELPERS
    # ------------------------------------------------------------------

    def _copy(self, src, dst):
        """shutil.copy2, remembering which files come from the generic
        _master/ rather than from an overlay (see _replace_references)."""
        shutil.copy2(src, dst)
        if self.override_dir is None or self.override_dir not in Path(src).parents:
            self._generic_files.add(Path(dst))

    def _replace_references(self, target_dir, target_name):
        """Replace the source name (TEMPLATE_NAME) with target_name in .lua files.

        Files from the generic _master/ are written for Tetsouo
        (require('Tetsouo/config/...')), whatever --source says: in those,
        DEFAULT_SOURCE is replaced too, except on @author lines. Without it a
        job with no overlay entry would load another character's configs.
        Files from the target's own overlay are already written for it and
        may name its partner (Tetsouo in Kaories' files): left as they are.
        """
        modified = 0
        own_overlay = (self.override_dir is not None and
                       self.override_dir.name.lower() == target_name.lower())
        for lua_file in target_dir.rglob('*.lua'):
            try:
                content = lua_file.read_text(encoding='utf-8')
                generic = lua_file in self._generic_files
                if own_overlay and not generic:
                    continue
                new_content = content.replace(self.TEMPLATE_NAME, target_name)
                if generic and self.DEFAULT_SOURCE != self.TEMPLATE_NAME:
                    new_content = ''.join(
                        line if '@author' in line else line.replace(self.DEFAULT_SOURCE, target_name)
                        for line in new_content.splitlines(keepends=True))
                if new_content != content:
                    lua_file.write_text(new_content, encoding='utf-8')
                    modified += 1
            except Exception:
                pass
        return modified

    def _create_dualbox_config(self, target_dir, config):
        """Generate DUALBOX_CONFIG.lua."""
        config_dir = target_dir / 'config'
        config_dir.mkdir(parents=True, exist_ok=True)

        role = config['role']
        char_name = config['character_name']
        enabled = str(config['enabled']).lower()
        role_desc = self.t['lua_role_main'] if role == 'main' else self.t['lua_role_alt']

        partner_block = ""
        if role == 'main':
            partner = config.get('alt_character') or 'Unknown'
            partner_block = f'DualBoxConfig.alt_character = "{partner}"'
        else:
            partner = config.get('main_character') or 'Unknown'
            partner_block = f'DualBoxConfig.main_character = "{partner}"'
        # //gs c main and //gs c alts find the other boxes through the group.
        if config.get('enabled'):
            partner_block += f'\nDualBoxConfig.group = {{"{char_name}", "{partner}"}}'

        lua = f"""---============================================================================
--- Dual-Boxing Configuration - {char_name}
---============================================================================
--- Role: {'MAIN' if role == 'main' else 'ALT'} - {role_desc}
---
--- @file config/DUALBOX_CONFIG.lua
--- @version 2.0
---============================================================================

local DualBoxConfig = {{}}

DualBoxConfig.role = "{role}"
DualBoxConfig.character_name = "{char_name}"
{partner_block}

DualBoxConfig.enabled = {enabled}
DualBoxConfig.timeout = 30
DualBoxConfig.debug = false

-- Legacy aliases
DualBoxConfig.main_name = DualBoxConfig.character_name
DualBoxConfig.alt_name = DualBoxConfig.{'alt_character' if role == 'main' else 'main_character'}

return DualBoxConfig
"""
        (config_dir / 'DUALBOX_CONFIG.lua').write_text(lua, encoding='utf-8')
        print(self.t['copy_ok'].format("DUALBOX_CONFIG.lua"))

    def _create_region_config(self, target_dir, char_name, region):
        """Generate REGION_CONFIG.lua."""
        config_dir = target_dir / 'config'

        orange_note = {
            'US': '(NBCP) - Has orange (057)',
            'EU': '(BQJS) - No orange (057)',
            'JP': 'Has orange (057)',
        }

        lua = f"""---============================================================================
--- Region Configuration - {char_name}
---============================================================================
--- @file config/REGION_CONFIG.lua
--- @version 1.0
---============================================================================

local RegionConfig = {{}}

RegionConfig.characters = {{
    ["{char_name}"] = "{region}", -- {region} account {orange_note.get(region, '')}
}}

RegionConfig.default_region = "{region}"

function RegionConfig.get_region(name)
    if not name then return RegionConfig.default_region end
    return RegionConfig.characters[name] or RegionConfig.default_region
end

function RegionConfig.get_orange_code(reg)
    if reg == "EU" then return 002 else return 057 end
end

function RegionConfig.get_orange_for_character(name)
    return RegionConfig.get_orange_code(RegionConfig.get_region(name))
end

return RegionConfig
"""
        (config_dir / 'REGION_CONFIG.lua').write_text(lua, encoding='utf-8')
        print(self.t['copy_ok'].format("REGION_CONFIG.lua"))


# ============================================================================
# MAIN
# ============================================================================

def main():
    """Main entry point."""
    try:
        # Parse language
        lang = 'fr'
        if '--lang' in sys.argv:
            idx = sys.argv.index('--lang')
            if idx + 1 < len(sys.argv):
                req = sys.argv[idx + 1].lower()
                if req in TRANSLATIONS:
                    lang = req

        # Parse source template (default: Tetsouo). Use Kaories to rebuild
        # her with her own saved sets/configs in _master/Kaories/.
        source_name = None
        if '--source' in sys.argv:
            idx = sys.argv.index('--source')
            if idx + 1 < len(sys.argv):
                source_name = sys.argv[idx + 1]

        cloner = SmartCharacterCloner(lang=lang, source_name=source_name)
        t = cloner.t

        # Title
        cloner.banner('banner_title')

        # Validate _master/ exists
        cloner.banner('banner_validation')
        if not cloner.validate_master():
            input(t['press_enter'])
            return 1

        # Get character name
        target_name = input(t['enter_name']).strip()
        if not target_name:
            print(t['target_empty'])
            input(t['press_enter'])
            return 1

        target_name = target_name.capitalize()

        if not cloner.validate_target(target_name):
            input(t['press_enter'])
            return 1

        # Database lookup
        db_jobs, db_role = cloner.lookup_character(target_name)

        # Job selection
        jobs = cloner.select_jobs(target_name, db_jobs)

        # Dualbox config (pre-fills role from DB)
        dualbox_config = cloner.ask_dualbox(target_name, db_role)

        # Region config
        region = cloner.ask_region(target_name)

        # Confirmation
        cloner.banner('banner_confirmation')
        print(t['conf_summary'])
        print(t['conf_source'])
        overlay = cloner._select_overlay(target_name)
        if overlay is not None:
            print(t['conf_overlay'].format(f"_master/{overlay.name}/"))
        print(t['conf_target'].format(target_name))
        print(t['conf_jobs'].format(', '.join(jobs)))
        print(t['conf_role'].format(dualbox_config['role'].upper()))

        if dualbox_config['role'] == 'main':
            partner = dualbox_config.get('alt_character') or t['conf_none']
            print(t['conf_alt'].format(partner))
        else:
            print(t['conf_main'].format(dualbox_config.get('main_character', '?')))

        response = input(t['confirm_clone']).lower()
        if response not in cloner.yes_answers:
            print(t['cancelled'])
            input(t['press_enter'])
            return 1

        # Execute clone
        if cloner.clone(target_name, jobs, dualbox_config, region):
            input(t['press_enter'])
            return 0
        else:
            print(t['clone_failed'])
            input(t['press_enter'])
            return 1

    except KeyboardInterrupt:
        print("\n\n[CANCELLED] Operation cancelled.")
        return 1
    except Exception as e:
        print(f"\n\n[ERROR] {e}")
        import traceback
        traceback.print_exc()
        input("\nPress Enter to exit...")
        return 1


if __name__ == "__main__":
    sys.exit(main())
