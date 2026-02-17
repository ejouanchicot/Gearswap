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
Version: 4.0.0 - Smart clone with character_db
Date: 2026-02-16
"""

import os
import re
import shutil
import sys
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
        'jobs_no_entry': "   [INFO] Pas de fichier entry pour: {} (sera ignoré)",

        # Validation
        'master_not_found': "ERREUR: Dossier _master/ introuvable!",
        'master_location': "   Emplacement attendu: {}",
        'target_empty': "ERREUR: Le nom du personnage ne peut pas être vide!",
        'target_alphanum': "ERREUR: Le nom doit contenir uniquement des lettres et chiffres!",
        'target_length': "ERREUR: Le nom doit faire entre 2 et 15 caractères!",
        'target_exists': "ATTENTION: Le personnage '{}' existe déjà!",
        'target_location': "   Emplacement: {}",
        'delete_existing': "Supprimer l'existant et continuer? (o/n): ",
        'delete_ok': "[OK] Répertoire '{}' supprimé",
        'delete_failed': "ERREUR: Échec de suppression: {}",

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
        'jobs_no_entry': "   [INFO] No entry file for: {} (will be skipped)",

        'master_not_found': "ERROR: _master/ directory not found!",
        'master_location': "   Expected location: {}",
        'target_empty': "ERROR: Character name cannot be empty!",
        'target_alphanum': "ERROR: Name must contain only letters and numbers!",
        'target_length': "ERROR: Name must be between 2 and 15 characters!",
        'target_exists': "WARNING: Character '{}' already exists!",
        'target_location': "   Location: {}",
        'delete_existing': "Delete existing and continue? (y/n): ",
        'delete_ok': "[OK] Deleted '{}' directory",
        'delete_failed': "ERROR: Failed to delete: {}",

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
ALL_VALID_JOBS = [
    'BLM', 'BRD', 'BST', 'COR', 'DNC', 'DRK', 'GEO',
    'PLD', 'PUP', 'RDM', 'RUN', 'SAM', 'THF', 'WAR', 'WHM'
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

class SmartCharacterCloner:
    """Smart character cloner using _master/ source and character_db."""

    TEMPLATE_NAME = "Tetsouo"  # Name used in template files

    def __init__(self, base_dir=None, lang='fr'):
        if base_dir is None:
            self.base_dir = Path(__file__).parent.absolute()
        else:
            self.base_dir = Path(base_dir)

        self.master_dir = self.base_dir / '_master'
        self.db_path = self.base_dir / 'character_db.lua'
        self.lang = lang
        self.t = TRANSLATIONS.get(lang, TRANSLATIONS['fr'])
        self.yes_answers = ['y', 'o', 'yes', 'oui']

        # Counters for summary
        self.count_entry = 0
        self.count_sets = 0
        self.count_configs = 0

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
            response = input(self.t['delete_existing']).lower()
            if response in self.yes_answers:
                try:
                    shutil.rmtree(target_dir)
                    print(self.t['delete_ok'].format(name))
                except Exception as e:
                    print(self.t['delete_failed'].format(e))
                    return False
            else:
                return False

        return True

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
    # CLONING ENGINE
    # ------------------------------------------------------------------

    def clone(self, target_name, jobs, dualbox_config, region):
        """Execute smart cloning: only selected jobs from _master/."""
        self.banner('banner_cloning')

        target_dir = self.base_dir / target_name
        jobs_lower = [j.lower() for j in jobs]
        jobs_upper = [j.upper() for j in jobs]

        # ── Step 1: Create directory structure ─────────────────────────
        print(self.t['step_dirs'])
        (target_dir / 'sets').mkdir(parents=True, exist_ok=True)
        (target_dir / 'config').mkdir(parents=True, exist_ok=True)
        print(self.t['copy_ok'].format(f"{target_name}/sets/"))
        print(self.t['copy_ok'].format(f"{target_name}/config/"))

        # ── Step 2: Copy entry files (only selected jobs) ─────────────
        print(self.t['step_entry'].format(len(jobs)))
        self.count_entry = 0
        for job_upper, job_lower in zip(jobs_upper, jobs_lower):
            src = self.master_dir / 'entry' / f'{self.TEMPLATE_NAME}_{job_upper}.lua'
            dst = target_dir / f'{target_name}_{job_upper}.lua'
            if src.exists():
                shutil.copy2(src, dst)
                print(self.t['copy_ok'].format(f"{target_name}_{job_upper}.lua"))
                self.count_entry += 1
            else:
                print(self.t['copy_skip'].format(f"entry/{self.TEMPLATE_NAME}_{job_upper}.lua"))

        # ── Step 3: Copy set files (only selected jobs) ───────────────
        print(self.t['step_sets'].format(len(jobs)))
        self.count_sets = 0
        for job_lower in jobs_lower:
            src = self.master_dir / 'sets' / f'{job_lower}_sets.lua'
            dst = target_dir / 'sets' / f'{job_lower}_sets.lua'
            if src.exists():
                shutil.copy2(src, dst)
                print(self.t['copy_ok'].format(f"sets/{job_lower}_sets.lua"))
                self.count_sets += 1
            else:
                print(self.t['copy_skip'].format(f"sets/{job_lower}_sets.lua"))

        # ── Step 4: Copy configs (job-specific + global) ──────────────
        print(self.t['step_configs'].format(len(jobs)))
        self.count_configs = 0

        # Job-specific configs
        no_config_jobs = []
        for job_lower in jobs_lower:
            src_dir = self.master_dir / 'config' / job_lower
            dst_dir = target_dir / 'config' / job_lower
            if src_dir.exists() and src_dir.is_dir():
                shutil.copytree(src_dir, dst_dir)
                file_count = len(list(dst_dir.glob('*.lua')))
                self.count_configs += file_count
                print(self.t['copy_ok'].format(f"config/{job_lower}/ ({file_count} files)"))
            else:
                no_config_jobs.append(job_lower.upper())

        if no_config_jobs:
            print(self.t['jobs_no_config'].format(', '.join(no_config_jobs)))

        # Global configs (LOCKSTYLE_CONFIG, RECAST_CONFIG, UI_*, etc.)
        global_src = self.master_dir / 'config_global'
        if global_src.exists():
            for f in global_src.glob('*.lua'):
                dst = target_dir / 'config' / f.name
                shutil.copy2(f, dst)
                self.count_configs += 1
                print(self.t['copy_ok'].format(f"config/{f.name} (global)"))

        # ── Step 5: Rename references (Tetsouo → target) ─────────────
        print(self.t['step_rename'])
        modified = self._replace_references(target_dir, target_name)
        print(self.t['replace_count'].format(modified, target_name))

        # Rename entry files content (already copied with Tetsouo_ prefix name in content)
        # The file names were already set correctly in step 2

        # ── Step 6: Generate character-specific configs ───────────────
        print(self.t['step_generate'])
        self._create_dualbox_config(target_dir, dualbox_config)
        self._create_region_config(target_dir, target_name, region)
        self.count_configs += 2  # DUALBOX + REGION

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

    def _replace_references(self, target_dir, target_name):
        """Replace all 'Tetsouo' references with target_name in .lua files."""
        modified = 0
        for lua_file in target_dir.rglob('*.lua'):
            try:
                content = lua_file.read_text(encoding='utf-8')
                if self.TEMPLATE_NAME in content:
                    new_content = content.replace(self.TEMPLATE_NAME, target_name)
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
            alt = config.get('alt_character') or 'Unknown'
            partner_block = f'DualBoxConfig.alt_character = "{alt}"'
        else:
            main = config.get('main_character') or 'Unknown'
            partner_block = f'DualBoxConfig.main_character = "{main}"'

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

        cloner = SmartCharacterCloner(lang=lang)
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
