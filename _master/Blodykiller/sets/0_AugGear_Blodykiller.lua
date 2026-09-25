---============================================================================
--- AugGear - Blodykiller: gear tables used by his sets
---============================================================================
--- Blody's gear lookup tables (AF / RELIC / EMPY, capes, Linos, Ambuscade,
--- Chironic, Herculean and Carmine pieces) for BRD and COR, kept under HIS names and conventions so his sets
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
---   * COR: AF/RELIC/EMPY and CORCape.TP/WS.STR from the COR block of his
---     0_AugGear_Blodykiller.lua (Blodykiller_COR.lua does not redefine
---     them); HERC.Head/Feet.FC from the same file; CARM.Hands/Legs.HQ.D
---     from his 0_AugGear_shared.lua; MEGH from his 0_AugGear_Blodykiller.lua.
---     CORCape.RA / PreRA / WS.AGI and HERC.*.Phalanx, used by his COR file,
---     were only defined for Gabvanstronger (0_AugGear.lua,
---     0_AugGear_Gabvanstronger.lua): they were nil for him and are not here.
---
--- Pure data: every table is built here in one pass. His
--- 0_AugGear_shared_dats.lua re-created every global table (AF = {}, ...)
--- each time it was included, wiping what an earlier include had filled in;
--- nothing here is included twice or reset afterwards.
---
--- @file    sets/0_AugGear_Blodykiller.lua
--- @author  Tetsouo
--- @version 1.1
--- @date    Created: 2026-09-25 | Updated: 2026-09-25 (COR tables)
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
elseif player and player.main_job == 'COR' then
    -- Laksamana's / Lanun / Chasseur's
    AF.Set   = "Laksamana's"                RELIC.Set   = "Lanun"               EMPY.Set   = "Chasseur"
    AF.Head  = "Laksamana's Tricorne +2"    RELIC.Head  = "Lanun Tricorne +3"   EMPY.Head  = "Chasseur's Tricorne +3"
    AF.Body  = "Laksamana's Frac +3"        RELIC.Body  = "Lanun Frac +3"       EMPY.Body  = "Chasseur's Frac +3"
    AF.Hands = "Laksamana's Gants +3"       RELIC.Hands = "Lanun Gants +3"      EMPY.Hands = "Chasseur's Gants +3"
    AF.Legs  = "Laksamana's Trews +2"       RELIC.Legs  = "Lanun Trews +3"      EMPY.Legs  = "Chasseur's Culottes +3"
    AF.Feet  = "Laksamana's Bottes +2"      RELIC.Feet  = "Lanun Bottes +3"     EMPY.Feet  = "Chasseur's Bottes +3"
    EMPY.Ear = "Chasseur's Earring +1"
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

CORCape = {}
CORCape.WS = {}
CORCape.TP     = { name="Camulus's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','"Dbl.Atk."+10','Phys. dmg. taken-10%',}}
CORCape.WS.STR = { name="Camulus's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%',}}

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

HERC = {}
HERC.Head = {}
HERC.Feet = {}
HERC.Head.FC = { name="Herculean Helm", augments={'"Mag.Atk.Bns."+18','"Fast Cast"+5','VIT+7','Mag. Acc.+11',}}
HERC.Feet.FC = { name="Herculean Boots", augments={'"Mag.Atk.Bns."+11','"Fast Cast"+5',}}

---============================================================================
--- ESCHA ARMOR (Carmine)
---============================================================================

CARM = {}
CARM.Hands = {}
CARM.Hands.HQ = {}
CARM.Legs = {}
CARM.Legs.HQ = {}
CARM.Hands.HQ.D = { name="Carmine Fin. Ga. +1", augments={'Rng.Atk.+20','"Mag.Atk.Bns."+12','"Store TP"+6',}}
CARM.Legs.HQ.D  = { name="Carmine Cuisses +1", augments={'Accuracy+20','Attack+12','"Dual Wield"+6',}}

--[[ Ayanmo Set  ]] AYAN = { Head = "Aya. Zucchetto +2", Body = "Ayanmo Corazza +2", Hands = "Aya. Manopolas +2", Legs = "Aya. Cosciales +2", Feet = "Aya. Gambieras +2" }
--[[ Meghanada   ]] MEGH = { Head = "Meghanada Visor +2", Body = "Meg. Cuirie +2", Hands = "Meg. Gloves +2", Legs = "Meg. Chausses +2", Feet = "Meg. Jam. +1" }
--[[ Inyanga Set ]] INYA ={ Head = "Inyanga Tiara +2", Body = "Inyanga Jubbah +2", Hands = "Inyan. Dastanas +2", Legs = "Inyanga Shalwar +2", Feet = "Inyanga Crackows +2" }
