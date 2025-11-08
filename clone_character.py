#!/usr/bin/env python3
"""
Clone Character Script - Tetsouo GearSwap System
=================================================
Clones the master character template (Tetsouo) to a new character.

Usage:
    python clone_character.py              (French - default)
    python clone_character.py --lang en    (English)
    python clone_character.py --lang fr    (French)

Author: Tetsouo GearSwap Project
Version: 3.0.0 - Multilingual support
Date: 2025-10-22
"""

import os
import shutil
import sys
from pathlib import Path

# ============================================================================
# TRANSLATIONS
# ============================================================================

TRANSLATIONS = {
    'fr': {
        # Banners
        'banner_title': 'CLONE DE PERSONNAGE - SYSTÈME GEARSWAP TETSOUO',
        'banner_validation': 'VALIDATION',
        'banner_dualbox': 'CONFIGURATION DUAL-BOXING',
        'banner_confirmation': 'CONFIRMATION DU CLONE',
        'banner_cloning': 'CLONAGE EN COURS',
        'banner_complete': 'CLONAGE TERMINÉ',

        # Validation messages
        'source_not_found': "ERREUR: Template source '{}' introuvable!",
        'source_location': "   Emplacement attendu: {}",
        'source_not_dir': "ERREUR: '{}' n'est pas un répertoire!",
        'missing_files_warn': "ATTENTION: Certains fichiers de job sont manquants:",
        'continue_anyway': "Continuer quand même? (o/n): ",
        'target_empty': "ERREUR: Le nom du personnage ne peut pas être vide!",
        'target_alphanum': "ERREUR: Le nom du personnage doit contenir uniquement des lettres et des chiffres!",
        'target_length': "ERREUR: Le nom du personnage doit faire entre 2 et 15 caractères!",
        'target_exists': "ERREUR: Le personnage '{}' existe déjà!",
        'target_location': "   Emplacement: {}",
        'delete_existing': "Supprimer l'existant et continuer? (o/n): ",
        'delete_ok': "[OK] Répertoire '{}' existant supprimé",
        'delete_failed': "ERREUR: Échec de suppression du répertoire existant: {}",

        # Dual-boxing prompts
        'dualbox_intro': "\nLe dual-boxing permet à 2 personnages de communiquer (ALT >> MAIN).",
        'dualbox_desc': "L'ALT envoie les changements de job au MAIN pour la sélection dynamique du macrobook.\n",
        'role_question': "Est-ce que '{}' est un personnage MAIN ou ALT? (main/alt): ",
        'role_error': "ERREUR: Veuillez entrer 'main' ou 'alt'",
        'main_desc': "\n'{}' est le personnage MAIN.",
        'main_receives': "Les personnages MAIN reçoivent les mises à jour de job des personnages ALT.\n",
        'alt_name_prompt': "Entrez le nom du personnage ALT (ou Entrée pour ignorer): ",
        'main_will_receive': "[OK] '{}' recevra les mises à jour de '{}'",
        'dualbox_disabled': "[OK] Dual-boxing désactivé pour '{}'",
        'alt_desc': "\n'{}' est un personnage ALT.",
        'alt_sends': "Les personnages ALT envoient les mises à jour de job au personnage MAIN.\n",
        'main_name_prompt': "Entrez le nom du personnage MAIN (requis): ",
        'alt_will_send': "[OK] '{}' enverra les mises à jour à '{}'",
        'main_required': "ERREUR: Le nom du personnage MAIN est requis pour les personnages ALT!",

        # File operations
        'dualbox_created': "\n[OK] DUALBOX_CONFIG.lua créé",
        'dualbox_failed': "\n[ERREUR] Échec de création de DUALBOX_CONFIG.lua: {}",
        'copying_dir': "\n[COPIE] Copie de la structure de répertoires...",
        'copy_from': "   De:   {}",
        'copy_to': "   Vers: {}",
        'copy_ok': "[OK] Répertoire copié avec succès",
        'copy_failed': "[ERREUR] Échec de copie du répertoire: {}",
        'renaming_files': "\n[RENOMMAGE] Renommage des fichiers de job...",
        'no_files_warn': "[ATTENTION] Aucun fichier de job trouvé à renommer!",
        'rename_ok': "[OK] {} fichiers de job renommés",
        'replacing_refs': "\n[REMPLACEMENT] Remplacement des références de caractères...",
        'scan_files': "   Analyse de {} fichiers...",
        'replace_ok': "[OK] {} fichiers modifiés",
        'replace_warn': "[ATTENTION] Aucune référence trouvée à remplacer",

        # Summary
        'summary_title': "\n[RÉSUMÉ DU CLONAGE]",
        'summary_source': "   Source:              Tetsouo",
        'summary_target': "   Cible:               {}",
        'summary_role': "   Rôle:                {}",
        'summary_partner': "   Partenaire:          {}",
        'summary_files': "   Fichiers copiés:     {} fichiers",
        'summary_renamed': "   Fichiers renommés:   {} fichiers de job",
        'summary_replaced': "   Fichiers modifiés:   {} fichiers",
        'clone_success': "\n[SUCCÈS] Personnage '{}' cloné avec succès!",
        'clone_failed': "\n[ÉCHEC] Le clonage a échoué.",

        # Prompts
        'enter_name': "\nEntrez le nom du nouveau personnage: ",
        'confirm_clone': "\nProcéder au clonage? (o/n): ",
        'cancelled': "\n[ANNULÉ] Clonage annulé.",
        'press_enter': "\nAppuyez sur Entrée pour quitter...",
        'kb_interrupt': "\n\n[ANNULÉ] Opération annulée par l'utilisateur.",
        'unexpected': "\n\n[ERREUR] ERREUR INATTENDUE: {}",

        # Config
        'conf_summary': "\n[CONFIGURATION DU CLONE]",
        'conf_source': "   Source:  Tetsouo",
        'conf_target': "   Cible:   {}",
        'conf_role': "   Rôle:    {}",
        'conf_alt': "   ALT:     {}",
        'conf_main': "   MAIN:    {}",
        'conf_none': "Aucun (dual-boxing désactivé)",

        # Config file comments
        'lua_role_main': 'Reçoit les mises à jour des personnages ALT',
        'lua_role_alt': 'Envoie les mises à jour au personnage MAIN',

        # Region config
        'region_question': "\nQuelle région PlayOnline utilisez-vous pour '{}'? (us/eu/jp): ",
        'region_error': "ERREUR: Veuillez entrer 'us', 'eu' ou 'jp'",
        'region_us_desc': "   US = Compte américain (NBCP) - Orange Juice disponible (ID 057)",
        'region_eu_desc': "   EU = Compte européen (BQJS) - Pas d'Orange, utilise Rolanberry (ID 002)",
        'region_jp_desc': "   JP = Compte japonais",
        'region_selected': "[OK] Région '{}' sélectionnée pour '{}'",
        'region_created': "[OK] REGION_CONFIG.lua créé",
        'region_failed': "[ERREUR] Échec de création de REGION_CONFIG.lua: {}",
    },
    'en': {
        # Banners
        'banner_title': 'CHARACTER CLONE - TETSOUO GEARSWAP SYSTEM',
        'banner_validation': 'VALIDATION',
        'banner_dualbox': 'DUAL-BOXING CONFIGURATION',
        'banner_confirmation': 'CLONE CONFIRMATION',
        'banner_cloning': 'CLONING IN PROGRESS',
        'banner_complete': 'CLONING COMPLETE',

        # Validation messages
        'source_not_found': "ERROR: Source template '{}' not found!",
        'source_location': "   Expected location: {}",
        'source_not_dir': "ERROR: '{}' is not a directory!",
        'missing_files_warn': "WARNING: Some job files are missing:",
        'continue_anyway': "Continue anyway? (y/n): ",
        'target_empty': "ERROR: Character name cannot be empty!",
        'target_alphanum': "ERROR: Character name must contain only letters and numbers!",
        'target_length': "ERROR: Character name must be between 2 and 15 characters!",
        'target_exists': "ERROR: Character '{}' already exists!",
        'target_location': "   Location: {}",
        'delete_existing': "Delete existing and continue? (y/n): ",
        'delete_ok': "[OK] Deleted existing '{}' directory",
        'delete_failed': "ERROR: Failed to delete existing directory: {}",

        # Dual-boxing prompts
        'dualbox_intro': "\nDual-boxing allows 2 characters to communicate (ALT >> MAIN).",
        'dualbox_desc': "The ALT sends job updates to the MAIN for dynamic macrobook selection.\n",
        'role_question': "Is '{}' a MAIN or ALT character? (main/alt): ",
        'role_error': "ERROR: Please enter 'main' or 'alt'",
        'main_desc': "\n'{}' is the MAIN character.",
        'main_receives': "MAIN characters receive job updates from ALT characters.\n",
        'alt_name_prompt': "Enter ALT character name (or press Enter to skip): ",
        'main_will_receive': "[OK] '{}' will receive updates from '{}'",
        'dualbox_disabled': "[OK] Dual-boxing disabled for '{}'",
        'alt_desc': "\n'{}' is an ALT character.",
        'alt_sends': "ALT characters send job updates to the MAIN character.\n",
        'main_name_prompt': "Enter MAIN character name (required): ",
        'alt_will_send': "[OK] '{}' will send updates to '{}'",
        'main_required': "ERROR: MAIN character name is required for ALT characters!",

        # File operations
        'dualbox_created': "\n[OK] Created DUALBOX_CONFIG.lua",
        'dualbox_failed': "\n[ERROR] Failed to create DUALBOX_CONFIG.lua: {}",
        'copying_dir': "\n[COPY] Copying directory structure...",
        'copy_from': "   From: {}",
        'copy_to': "   To:   {}",
        'copy_ok': "[OK] Directory copied successfully",
        'copy_failed': "[ERROR] Failed to copy directory: {}",
        'renaming_files': "\n[RENAME] Renaming job files...",
        'no_files_warn': "[WARNING] No job files found to rename!",
        'rename_ok': "[OK] Renamed {} job files",
        'replacing_refs': "\n[REPLACE] Replacing character references...",
        'scan_files': "   Scanning {} files...",
        'replace_ok': "[OK] Modified {} files",
        'replace_warn': "[WARNING] No references found to replace",

        # Summary
        'summary_title': "\n[CLONING SUMMARY]",
        'summary_source': "   Source:              Tetsouo",
        'summary_target': "   Target:              {}",
        'summary_role': "   Role:                {}",
        'summary_partner': "   Partner:             {}",
        'summary_files': "   Files copied:        {} files",
        'summary_renamed': "   Files renamed:       {} job files",
        'summary_replaced': "   Files modified:      {} files",
        'clone_success': "\n[SUCCESS] Character '{}' cloned successfully!",
        'clone_failed': "\n[FAILURE] Cloning failed.",

        # Prompts
        'enter_name': "\nEnter new character name: ",
        'confirm_clone': "\nProceed with cloning? (y/n): ",
        'cancelled': "\n[CANCELLED] Cloning cancelled.",
        'press_enter': "\nPress Enter to exit...",
        'kb_interrupt': "\n\n[CANCELLED] Operation cancelled by user.",
        'unexpected': "\n\n[ERROR] UNEXPECTED ERROR: {}",

        # Config
        'conf_summary': "\n[CLONE CONFIGURATION]",
        'conf_source': "   Source:  Tetsouo",
        'conf_target': "   Target:  {}",
        'conf_role': "   Role:    {}",
        'conf_alt': "   ALT:     {}",
        'conf_main': "   MAIN:    {}",
        'conf_none': "None (dual-boxing disabled)",

        # Config file comments
        'lua_role_main': 'Receives updates from ALT characters',
        'lua_role_alt': 'Sends updates to MAIN character',

        # Region config
        'region_question': "\nWhich PlayOnline region do you use for '{}'? (us/eu/jp): ",
        'region_error': "ERROR: Please enter 'us', 'eu' or 'jp'",
        'region_us_desc': "   US = American account (NBCP) - Orange Juice available (ID 057)",
        'region_eu_desc': "   EU = European account (BQJS) - No Orange, uses Rolanberry (ID 002)",
        'region_jp_desc': "   JP = Japanese account",
        'region_selected': "[OK] Region '{}' selected for '{}'",
        'region_created': "[OK] Created REGION_CONFIG.lua",
        'region_failed': "[ERROR] Failed to create REGION_CONFIG.lua: {}",
    }
}

class CharacterCloner:
    """Handles cloning of character configuration from Tetsouo template."""

    def __init__(self, base_dir=None, lang='fr'):
        """Initialize the cloner with base directory and language."""
        if base_dir is None:
            # Get script directory
            self.base_dir = Path(__file__).parent.absolute()
        else:
            self.base_dir = Path(base_dir)

        self.source_name = "Tetsouo"
        self.source_dir = self.base_dir / self.source_name
        self.lang = lang
        self.t = TRANSLATIONS.get(lang, TRANSLATIONS['fr'])

    def validate_source(self):
        """Validate that source template exists."""
        if not self.source_dir.exists():
            print(self.t['source_not_found'].format(self.source_name))
            print(self.t['source_location'].format(self.source_dir))
            return False

        if not self.source_dir.is_dir():
            print(self.t['source_not_dir'].format(self.source_name))
            return False

        # Check for essential files
        required_files = [
            f"{self.source_name}_WAR.lua",
            f"{self.source_name}_PLD.lua",
            f"{self.source_name}_DNC.lua"
        ]

        missing = []
        for file in required_files:
            if not (self.source_dir / file).exists():
                missing.append(file)

        if missing:
            print(self.t['missing_files_warn'])
            for file in missing:
                print(f"   - {file}")
            response = input(self.t['continue_anyway']).lower()
            yes_answers = ['y', 'o', 'yes', 'oui']
            if response not in yes_answers:
                return False

        return True

    def validate_target(self, target_name):
        """Validate target character name."""
        if not target_name:
            print(self.t['target_empty'])
            return False

        if not target_name.isalnum():
            print(self.t['target_alphanum'])
            return False

        if len(target_name) < 2 or len(target_name) > 15:
            print(self.t['target_length'])
            return False

        # Check if target already exists
        target_dir = self.base_dir / target_name
        if target_dir.exists():
            print(self.t['target_exists'].format(target_name))
            print(self.t['target_location'].format(target_dir))
            response = input(self.t['delete_existing']).lower()
            yes_answers = ['y', 'o', 'yes', 'oui']
            if response in yes_answers:
                try:
                    shutil.rmtree(target_dir)
                    print(self.t['delete_ok'].format(target_name))
                except Exception as e:
                    print(self.t['delete_failed'].format(e))
                    return False
            else:
                return False

        return True

    def ask_dualbox_config(self, target_name):
        """Ask user for dual-boxing configuration."""
        print("\n" + "=" * 70)
        print(f"  {self.t['banner_dualbox']}")
        print("=" * 70)
        print(self.t['dualbox_intro'])
        print(self.t['dualbox_desc'])

        # Ask if this character is MAIN or ALT
        while True:
            role = input(self.t['role_question'].format(target_name)).strip().lower()
            if role in ['main', 'alt']:
                break
            print(self.t['role_error'])

        config = {
            'role': role,
            'character_name': target_name,
            'enabled': False,  # Default to disabled
            'alt_character': None,
            'main_character': None,
            'timeout': 30,
            'debug': False
        }

        if role == 'main':
            print(self.t['main_desc'].format(target_name))
            print(self.t['main_receives'])

            # Ask for ALT character name (optional)
            alt_name = input(self.t['alt_name_prompt']).strip()

            if alt_name:
                # Capitalize first letter
                alt_name = alt_name.capitalize()
                config['alt_character'] = alt_name
                config['enabled'] = True
                print(self.t['main_will_receive'].format(target_name, alt_name))
            else:
                print(self.t['dualbox_disabled'].format(target_name))

        else:  # role == 'alt'
            print(self.t['alt_desc'].format(target_name))
            print(self.t['alt_sends'])

            # Ask for MAIN character name (required for ALT)
            while True:
                main_name = input(self.t['main_name_prompt']).strip()
                if main_name:
                    # Capitalize first letter
                    main_name = main_name.capitalize()
                    config['main_character'] = main_name
                    config['enabled'] = True
                    print(self.t['alt_will_send'].format(target_name, main_name))
                    break
                else:
                    print(self.t['main_required'])

        return config

    def create_dualbox_config(self, target_name, dualbox_config):
        """Create DUALBOX_CONFIG.lua file for the new character."""
        target_dir = self.base_dir / target_name
        config_dir = target_dir / "config"
        config_file = config_dir / "DUALBOX_CONFIG.lua"

        # Ensure config directory exists
        config_dir.mkdir(parents=True, exist_ok=True)

        # Generate Lua config file
        role = dualbox_config['role']
        char_name = dualbox_config['character_name']
        enabled = dualbox_config['enabled']
        timeout = dualbox_config['timeout']
        debug = dualbox_config['debug']

        # Use translated role description
        role_desc = self.t['lua_role_main'] if role == 'main' else self.t['lua_role_alt']

        lua_content = f"""---============================================================================
--- Dual-Boxing Configuration - {char_name}
---============================================================================
--- Configuration for dual-boxing system (inter-character communication).
---
--- Role: {'MAIN' if role == 'main' else 'ALT'}
--- {role_desc}
---
--- @file config/DUALBOX_CONFIG.lua
--- @author Tetsouo GearSwap Project
--- @version 2.0
--- @date Created: 2025-10-22
---============================================================================

local DualBoxConfig = {{}}

---============================================================================
--- CHARACTER ROLE CONFIGURATION
---============================================================================

-- Role: "main" (receives updates) or "alt" (sends updates)
DualBoxConfig.role = "{role}"

-- This character's name
DualBoxConfig.character_name = "{char_name}"

"""

        if role == 'main':
            alt_name = dualbox_config.get('alt_character', 'Unknown')
            lua_content += f"""-- ALT character to receive updates from
DualBoxConfig.alt_character = "{alt_name}"

"""
        else:  # alt
            main_name = dualbox_config.get('main_character', 'Unknown')
            lua_content += f"""-- MAIN character to send updates to
DualBoxConfig.main_character = "{main_name}"

"""

        lua_content += f"""---============================================================================
--- SYSTEM SETTINGS
---============================================================================

-- Enable/disable dual-boxing system
DualBoxConfig.enabled = {str(enabled).lower()}

-- Timeout (seconds) - ALT considered offline after this delay
DualBoxConfig.timeout = {timeout}

-- Debug mode (shows communication messages)
DualBoxConfig.debug = {str(debug).lower()}

---============================================================================
--- LEGACY ALIASES (for backward compatibility)
---============================================================================

-- Old variable names (deprecated but kept for compatibility)
DualBoxConfig.main_name = DualBoxConfig.character_name
DualBoxConfig.alt_name = DualBoxConfig.{'alt_character' if role == 'main' else 'main_character'}

---============================================================================
--- MODULE EXPORT
---============================================================================

return DualBoxConfig
"""

        # Write file
        try:
            with open(config_file, 'w', encoding='utf-8') as f:
                f.write(lua_content)
            print(self.t['dualbox_created'])
            return True
        except Exception as e:
            print(self.t['dualbox_failed'].format(e))
            return False

    def ask_region_config(self, target_name):
        """Ask user for PlayOnline region (US/EU/JP) for the new character."""
        print(self.t['region_us_desc'])
        print(self.t['region_eu_desc'])
        print(self.t['region_jp_desc'])

        while True:
            region = input(self.t['region_question'].format(target_name)).strip().upper()
            if region in ['US', 'EU', 'JP']:
                print(self.t['region_selected'].format(region, target_name))
                return region
            print(self.t['region_error'])

    def create_region_config(self, target_name, region):
        """Create REGION_CONFIG.lua file for the new character."""
        target_dir = self.base_dir / target_name
        config_dir = target_dir / "config"
        config_file = config_dir / "REGION_CONFIG.lua"

        # Ensure config directory exists
        config_dir.mkdir(parents=True, exist_ok=True)

        # Generate Lua config file
        lua_content = f"""---============================================================================
--- Region Configuration - Character Region Mapping
---============================================================================
--- Maps character names to their FFXI region (POL account type).
--- This determines which color codes are available for messaging.
---
--- IMPORTANT: Add your character(s) to this list!
---
--- Available regions:
---   "US" - North America / US PlayOnline accounts (NBCP)
---          - Code 057 = Orange (available)
---   "EU" - Europe PlayOnline accounts (BQJS)
---          - Code 057 = Does NOT exist (use 002 Rose instead)
---   "JP" - Japan PlayOnline accounts
---          - Code 057 = Orange (available)
---
--- How to add your character:
---   1. Find your character name (case-sensitive!)
---   2. Add a new line: ["YourCharName"] = "US" or "EU" or "JP"
---   3. Save the file
---   4. Reload GearSwap: //lua r gearswap
---
--- @file config/REGION_CONFIG.lua
--- @author {target_name}
--- @version 1.0
--- @date Created: 2025-10-22
---============================================================================
local RegionConfig = {{}}

---============================================================================
--- CHARACTER >> REGION MAPPING
---============================================================================
--- Add your character(s) below!
--- Format: ["CharacterName"] = "US" or "EU" or "JP"

RegionConfig.characters = {{
    -- {target_name}'s characters
    ["{target_name}"] = "{region}" -- {region} account {"(NBCP) - Has orange (057)" if region == "US" else "(BQJS) - No orange (057)" if region == "EU" else ""}

    -- Add your characters here:
    -- ["MyCharacter"] = "US",
    -- ["AltCharacter"] = "EU",
}}

---============================================================================
--- DEFAULT REGION
---============================================================================
--- If character not found in mapping above, use this region
--- Most players have US accounts, so default to "US"

RegionConfig.default_region = "{region}"

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Get region for a character name
--- @param char_name string Character name (case-sensitive)
--- @return string region Region code ("US", "EU", "JP")
function RegionConfig.get_region(char_name)
    if not char_name then
        return RegionConfig.default_region
    end

    return RegionConfig.characters[char_name] or RegionConfig.default_region
end

--- Get orange/warning color code for a region
--- @param region string Region code ("US", "EU", "JP")
--- @return number color_code FFXI color code for orange/warning
function RegionConfig.get_orange_code(region)
    if region == "EU" then
        -- EU: Code 057 does NOT exist, use 002 (Rose) as closest to orange
        return 002
    else
        -- US/JP: Code 057 = Orange
        return 057
    end
end

--- Get orange/warning color code for current character
--- @param char_name string Character name
--- @return number color_code FFXI color code for orange/warning
function RegionConfig.get_orange_for_character(char_name)
    local region = RegionConfig.get_region(char_name)
    return RegionConfig.get_orange_code(region)
end

---============================================================================
--- REGION INFO (for reference)
---============================================================================

RegionConfig.region_info = {{
    US = {{
        name = "United States / North America",
        pol_type = "NBCP",
        code_057 = "Orange (exists)",
        warning_color = 057,
        example_chars = {{"{target_name if region == "US" else ""}"}}
    }},
    EU = {{
        name = "Europe",
        pol_type = "BQJS",
        code_057 = "Does NOT exist",
        warning_color = 002, -- Rose (closest to orange)
        example_chars = {{"{target_name if region == "EU" else ""}"}}
    }},
    JP = {{
        name = "Japan",
        pol_type = "JP",
        code_057 = "Orange (exists)",
        warning_color = 057,
        example_chars = {{"{target_name if region == "JP" else ""}"}}
    }}
}}

return RegionConfig
"""

        # Write file
        try:
            with open(config_file, 'w', encoding='utf-8') as f:
                f.write(lua_content)
            print(self.t['region_created'])
            return True
        except Exception as e:
            print(self.t['region_failed'].format(e))
            return False

    def copy_directory(self, target_name):
        """Copy entire Tetsouo directory to new character."""
        target_dir = self.base_dir / target_name

        print(self.t['copying_dir'])
        print(self.t['copy_from'].format(self.source_dir))
        print(self.t['copy_to'].format(target_dir))

        try:
            shutil.copytree(self.source_dir, target_dir)
            print(self.t['copy_ok'])
            return True
        except Exception as e:
            print(self.t['copy_failed'].format(e))
            return False

    def rename_job_files(self, target_name):
        """Rename all Tetsouo_*.lua files to TargetName_*.lua."""
        target_dir = self.base_dir / target_name

        print(self.t['renaming_files'])

        # Find all Tetsouo_*.lua files
        pattern = f"{self.source_name}_*.lua"
        files_to_rename = list(target_dir.glob(pattern))

        if not files_to_rename:
            print(self.t['no_files_warn'])
            return True

        renamed_count = 0
        for old_file in files_to_rename:
            # Extract job name (e.g., WAR from Tetsouo_WAR.lua)
            job = old_file.stem.replace(f"{self.source_name}_", "")
            new_name = f"{target_name}_{job}.lua"
            new_file = old_file.parent / new_name

            try:
                old_file.rename(new_file)
                print(f"   [OK] {old_file.name} >> {new_name}")
                renamed_count += 1
            except Exception as e:
                print(f"   [ERROR] Failed to rename {old_file.name}: {e}")

        print(self.t['rename_ok'].format(renamed_count))
        return True

    def replace_character_references(self, target_name):
        """Replace all 'Tetsouo' references with target name in Lua files."""
        target_dir = self.base_dir / target_name

        print(self.t['replacing_refs'])

        # Find all .lua files in target directory
        lua_files = list(target_dir.rglob("*.lua"))
        print(self.t['scan_files'].format(len(lua_files)))

        modified_count = 0
        for lua_file in lua_files:
            try:
                # Read file content
                with open(lua_file, 'r', encoding='utf-8') as f:
                    content = f.read()

                # Check if file contains references to replace
                if self.source_name in content:
                    # Replace all occurrences (case-sensitive)
                    new_content = content.replace(self.source_name, target_name)

                    # Write back
                    with open(lua_file, 'w', encoding='utf-8') as f:
                        f.write(new_content)

                    modified_count += 1

            except Exception as e:
                print(f"   [WARNING] Failed to process {lua_file.name}: {e}")

        if modified_count > 0:
            print(self.t['replace_ok'].format(modified_count))
        else:
            print(self.t['replace_warn'])

        return True

    def clone(self, target_name, dualbox_config, region):
        """Execute complete cloning process."""
        print("\n" + "=" * 70)
        print(f"  {self.t['banner_cloning']}")
        print("=" * 70)

        # Step 1: Copy directory
        if not self.copy_directory(target_name):
            return False

        # Step 2: Rename job files
        if not self.rename_job_files(target_name):
            return False

        # Step 3: Replace character references
        if not self.replace_character_references(target_name):
            return False

        # Step 4: Create dual-boxing config
        if not self.create_dualbox_config(target_name, dualbox_config):
            return False

        # Step 5: Create region config
        if not self.create_region_config(target_name, region):
            return False

        # Success summary
        print("\n" + "=" * 70)
        print(f"  {self.t['banner_complete']}")
        print("=" * 70)

        # Count files
        target_dir = self.base_dir / target_name
        total_files = len(list(target_dir.rglob("*.*")))
        job_files = len(list(target_dir.glob(f"{target_name}_*.lua")))

        print(self.t['summary_title'])
        print(self.t['summary_source'])
        print(self.t['summary_target'].format(target_name))
        print(self.t['summary_role'].format(dualbox_config['role'].upper()))

        if dualbox_config['role'] == 'main':
            partner = dualbox_config.get('alt_character', self.t['conf_none'])
        else:
            partner = dualbox_config.get('main_character', 'Unknown')
        print(self.t['summary_partner'].format(partner))

        print(self.t['summary_files'].format(total_files))
        print(self.t['summary_renamed'].format(job_files))
        print(self.t['summary_replaced'].format(total_files))

        print(self.t['clone_success'].format(target_name))
        return True


def main():
    """Main entry point."""
    try:
        # Parse command-line arguments for language
        lang = 'fr'  # Default to French
        if '--lang' in sys.argv:
            lang_index = sys.argv.index('--lang')
            if lang_index + 1 < len(sys.argv):
                requested_lang = sys.argv[lang_index + 1].lower()
                if requested_lang in TRANSLATIONS:
                    lang = requested_lang
                else:
                    print(f"[WARNING] Language '{requested_lang}' not supported. Using French (fr).")

        # Initialize cloner with language
        cloner = CharacterCloner(lang=lang)
        t = TRANSLATIONS[lang]

        # Title
        print("\n" + "=" * 70)
        print(f"  {t['banner_title']}")
        print("=" * 70)

        # Validation
        print("\n" + "=" * 70)
        print(f"  {t['banner_validation']}")
        print("=" * 70)

        if not cloner.validate_source():
            input(t['press_enter'])
            return 1

        # Get target character name
        target_name = input(t['enter_name']).strip()

        if not target_name:
            print(t['target_empty'])
            input(t['press_enter'])
            return 1

        # Capitalize first letter
        target_name = target_name.capitalize()

        if not cloner.validate_target(target_name):
            input(t['press_enter'])
            return 1

        # Ask for dual-boxing configuration
        dualbox_config = cloner.ask_dualbox_config(target_name)

        # Ask for region configuration
        region = cloner.ask_region_config(target_name)

        # Confirm
        print("\n" + "=" * 70)
        print(f"  {t['banner_confirmation']}")
        print("=" * 70)
        print(t['conf_summary'])
        print(t['conf_source'])
        print(t['conf_target'].format(target_name))
        print(t['conf_role'].format(dualbox_config['role'].upper()))

        if dualbox_config['role'] == 'main':
            if dualbox_config['enabled']:
                print(t['conf_alt'].format(dualbox_config['alt_character']))
            else:
                print(t['conf_alt'].format(t['conf_none']))
        else:
            print(t['conf_main'].format(dualbox_config['main_character']))

        response = input(t['confirm_clone']).lower()
        yes_answers = ['y', 'o', 'yes', 'oui']
        if response not in yes_answers:
            print(t['cancelled'])
            input(t['press_enter'])
            return 1

        # Execute cloning
        if cloner.clone(target_name, dualbox_config, region):
            input(t['press_enter'])
            return 0
        else:
            print(t['clone_failed'])
            input(t['press_enter'])
            return 1

    except KeyboardInterrupt:
        print(t['kb_interrupt'])
        input(t['press_enter'])
        return 1
    except Exception as e:
        print(t['unexpected'].format(e))
        import traceback
        traceback.print_exc()
        input(t['press_enter'])
        return 1


if __name__ == "__main__":
    sys.exit(main())
