---============================================================================
--- AugGear - Blodykiller: gear tables used by his sets
---============================================================================
--- Blody's gear lookup tables (AF / RELIC / EMPY, capes, Linos, Ambuscade
--- and Chironic pieces), kept under HIS names and conventions so his sets
--- read the same as in his own files.
---
--- Sources (his old setup):
---   * 0_AugGear_Blodykiller.lua      - Set/Ear names, BRDCape.WS.DEX, LINOS,
---                                      CHIR, AYAN, INYA
---   * Blodykiller_BRD.lua (init_gear_sets) - AF/RELIC/EMPY Head..Feet and
---                                      BRDCape.Macc/TP/WS.STR. That function
---                                      ran after 0_AugGear_Blodykiller.lua and
---                                      overwrote those entries, so its values
---                                      are the ones he actually wore.
---
--- Pure data: every table is built here in one pass. His
--- 0_AugGear_shared_dats.lua re-created every global table (AF = {}, ...)
--- each time it was included, wiping what an earlier include had filled in;
--- nothing here is included twice or reset afterwards.
---
--- @file    sets/0_AugGear_Blodykiller.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-25
---============================================================================

---============================================================================
--- JOB EMBLEMATIC GEAR (AF / RELIC / EMPY)
---============================================================================

AF = {}
RELIC = {}
EMPY = {}

if player and player.main_job == 'BRD' then
    -- Brioso / Bihu / Fili
    AF.Set   = "Brioso"                 RELIC.Set   = "Bihu"                    EMPY.Set   = "Fili"
    AF.Head  = "Brioso Roundlet +4"     RELIC.Head  = "Bihu Roundlet +4"        EMPY.Head  = "Fili Calot +3"
    AF.Body  = "Brioso Just. +4"        RELIC.Body  = "Bihu Justaucorps +4"     EMPY.Body  = "Fili Hongreline +3"
    AF.Hands = "Brioso Cuffs +4"        RELIC.Hands = "Bihu Cuffs +3"           EMPY.Hands = "Fili Manchettes +3"
    AF.Legs  = "Brioso Cannions +4"     RELIC.Legs  = "Bihu Cannions +4"        EMPY.Legs  = "Fili Rhingrave +2"
    AF.Feet  = "Brioso Slippers +4"     RELIC.Feet  = "Bihu Slippers +4"        EMPY.Feet  = "Fili Cothurnes +2"
    EMPY.Ear = "Fili Earring +1"
end

---============================================================================
--- AMBUSCADE CAPES
---============================================================================

BRDCape = {}
BRDCape.WS = {}
BRDCape.Macc   = { name="Intarabus's Cape", augments={'CHR+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+7','"Fast Cast"+10','Damage taken-5%',}}
BRDCape.TP     = { name="Intarabus's Cape", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','"Dbl.Atk."+10','Damage taken-5%',}}
BRDCape.WS.STR = { name="Intarabus's Cape", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%',}}
BRDCape.WS.DEX = { name="Intarabus's Cape", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','Weapon skill damage +10%',}}

---============================================================================
--- SKIRMISH / NORG / AMBUSCADE ARMOR
---============================================================================

LINOS = {}
LINOS.TP = { name="Linos", augments={'Accuracy+10 Attack+10','"Dbl.Atk."+2','Quadruple Attack +3',}}
LINOS.WS = { name="Linos", augments={'Attack+15','Weapon skill damage +3%','STR+8',}}

CHIR = {}
CHIR.Hands = {}
CHIR.Legs = {}
CHIR.Hands.WS     = { name="Chironic Gloves", augments={'MND+9','Weapon skill damage +4%','Quadruple Attack +2','Mag. Acc.+19 "Mag.Atk.Bns."+19',}}
CHIR.Legs.Refresh = { name="Chironic Hose", augments={'AGI+10','"Refresh"+2','Accuracy+3 Attack+3','Mag. Acc.+15 "Mag.Atk.Bns."+15',}}

--[[ Ayanmo Set  ]] AYAN = { Head = "Aya. Zucchetto +2", Body = "Ayanmo Corazza +2", Hands = "Aya. Manopolas +2", Legs = "Aya. Cosciales +2", Feet = "Aya. Gambieras +2" }
--[[ Inyanga Set ]] INYA = { Head = "Inyanga Tiara +2", Body = "Inyanga Jubbah +2", Hands = "Inyan. Dastanas +2", Legs = "Inyanga Shalwar +2", Feet = "Inyanga Crackows +2" }
