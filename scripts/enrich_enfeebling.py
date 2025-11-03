"""
Script pour enrichir le fichier enfeebling.lua avec descriptions et multi-job support
"""

# Mapping complet des sorts Enfeebling avec description, élément et tous les jobs
ENFEEBLING_DATA = {
    # DIA FAMILY
    "Dia": {"desc": "Defense down + DoT", "elem": "Light", "jobs": {"RDM": 1, "WHM": 3}},
    "Dia II": {"desc": "Defense down + DoT (enhanced)", "elem": "Light", "jobs": {"RDM": 31, "WHM": 36}},
    "Dia III": {"desc": "Defense down + DoT (master)", "elem": "Light", "jobs": {"RDM": 75}},
    "Diaga": {"desc": "AoE Defense down + DoT", "elem": "Light", "jobs": {"RDM": 15, "WHM": 18}},

    # POISON FAMILY
    "Poison": {"desc": "Attack down + DoT", "elem": "Water", "jobs": {"BLM": 3, "DRK": 6, "RDM": 5}},
    "Poison II": {"desc": "Attack down + DoT (enhanced)", "elem": "Water", "jobs": {"BLM": 43, "DRK": 46, "RDM": 46}},
    "Poisonga": {"desc": "AoE Attack down + DoT", "elem": "Water", "jobs": {"BLM": 24, "DRK": 26}},

    # BIO FAMILY
    "Bio": {"desc": "Attack down + DoT", "elem": "Dark", "jobs": {"RDM": 10}},
    "Bio II": {"desc": "Attack down + DoT (enhanced)", "elem": "Dark", "jobs": {"RDM": 36}},
    "Bio III": {"desc": "Attack down + DoT (master)", "elem": "Dark", "jobs": {"RDM": 75}},

    # PARALYZE FAMILY
    "Paralyze": {"desc": "Attack speed down", "elem": "Ice", "jobs": {"RDM": 4, "WHM": 6}},
    "Paralyze II": {"desc": "Attack speed down (enhanced)", "elem": "Ice", "jobs": {"RDM": 75}},

    # SLOW FAMILY
    "Slow": {"desc": "Attack speed down", "elem": "Earth", "jobs": {"RDM": 13, "WHM": 13}},
    "Slow II": {"desc": "Attack speed down (enhanced)", "elem": "Earth", "jobs": {"RDM": 75}},

    # BLIND FAMILY
    "Blind": {"desc": "Accuracy down (vision)", "elem": "Dark", "jobs": {"BLM": 4, "RDM": 8}},
    "Blind II": {"desc": "Accuracy down (vision, enhanced)", "elem": "Dark", "jobs": {"RDM": 75}},

    # GRAVITY FAMILY
    "Gravity": {"desc": "Movement speed down + evasion down", "elem": "Wind", "jobs": {"RDM": 21}},
    "Gravity II": {"desc": "Movement speed down + evasion down (enhanced)", "elem": "Wind", "jobs": {"RDM": 98}},

    # DISTRACT FAMILY
    "Distract": {"desc": "Accuracy down", "elem": "Ice", "jobs": {"RDM": 35}},
    "Distract II": {"desc": "Accuracy down (enhanced)", "elem": "Ice", "jobs": {"RDM": 85}},
    "Distract III": {"desc": "Accuracy down (master)", "elem": "Ice", "jobs": {"RDM": 99}},

    # FRAZZLE FAMILY
    "Frazzle": {"desc": "Magic evasion down", "elem": "Dark", "jobs": {"RDM": 42}},
    "Frazzle II": {"desc": "Magic evasion down (enhanced)", "elem": "Dark", "jobs": {"RDM": 92}},
    "Frazzle III": {"desc": "Magic evasion down (master)", "elem": "Dark", "jobs": {"RDM": 99}},

    # ADDLE FAMILY
    "Addle": {"desc": "Magic evasion down", "elem": "Fire", "jobs": {"RDM": 83, "WHM": 93}},
    "Addle II": {"desc": "Magic evasion down (enhanced)", "elem": "Fire", "jobs": {"RDM": 99}},

    # OTHER
    "Bind": {"desc": "Immobilize target", "elem": "Ice", "jobs": {"BLM": 7, "DRK": 20, "RDM": 11}},
    "Silence": {"desc": "Prevent spellcasting", "elem": "Wind", "jobs": {"RDM": 18, "WHM": 15}},
    "Dispel": {"desc": "Remove beneficial effects", "elem": "Dark", "jobs": {"RDM": 32, "SCH": 32}},
    "Sleep": {"desc": "Put target to sleep", "elem": "Dark", "jobs": {"BLM": 20, "DRK": 30, "GEO": 35, "RDM": 25, "SCH": 30}},
    "Sleep II": {"desc": "Put target to sleep (enhanced)", "elem": "Dark", "jobs": {"BLM": 41, "DRK": 56, "GEO": 70, "RDM": 46, "SCH": 65}},
    "Sleepga": {"desc": "AoE Sleep", "elem": "Dark", "jobs": {"BLM": 31}},
    "Sleepga II": {"desc": "AoE Sleep (enhanced)", "elem": "Dark", "jobs": {"BLM": 56}},
    "Break": {"desc": "Petrify target", "elem": "Earth", "jobs": {"BLM": 85, "DRK": 95, "RDM": 87, "SCH": 90}},
    "Breakga": {"desc": "AoE Petrify", "elem": "Earth", "jobs": {"BLM": 95}},
}

print("Enfeebling Data Dictionary Created")
print(f"Total spells: {len(ENFEEBLING_DATA)}")

# Afficher un exemple
print("\nExample (Sleep II):")
print(ENFEEBLING_DATA["Sleep II"])
