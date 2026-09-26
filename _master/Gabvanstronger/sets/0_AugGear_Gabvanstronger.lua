---============================================================================
--- AugGear - Gabvanstronger: gear tables used by his sets
---============================================================================
--- Gab's gear lookup tables (AF / RELIC / EMPY, capes, augmented weapons,
--- Chironic, Herculean, Telchine, Amalric, Kaykaus, Vanya, Pursuer,
--- Stikini / Chirich rings, CP cape, Ambuscade pieces) for RDM and THF, kept
--- under HIS names and conventions so his sets read the same as in his own
--- files.
---
--- Sources (his old setup, values copied as they were):
---   * 0_AugGear_Gabvanstronger.lua - RDM and THF blocks (AF/RELIC/EMPY,
---     EMPY.Ear, RDMCape, THFCape), Colada, Grioavolr, CHIR (Refresh,
---     Phalanx, Macc, rings), HERC (FC, Refresh), TELC, CAPACITY.Cape, STIK,
---     AYAN, JHAK, MEGH, MUMM
---   * 0_AugGear_shared.lua - AMAL.Head.HQ.D, KAYK.Body/Hands.HQ.D,
---     VANY.Cure, VANY.Legs.C, VANY.Feet.D, PURS.Hands.A
--- Only the entries his RDM and THF sets use are here.
---
--- Pure data: every table is built here in one pass. His
--- 0_AugGear_shared_dats.lua re-created every global table (AF = {}, ...)
--- each time it was included; nothing here is included twice.
---
--- @file    sets/0_AugGear_Gabvanstronger.lua
--- @author  Tetsouo
--- @version 1.1
--- @date    Created: 2026-09-25 | Updated: 2026-09-26 (THF)
---============================================================================

---============================================================================
--- JOB EMBLEMATIC GEAR (AF / RELIC / EMPY)
---============================================================================

AF = {}
RELIC = {}
EMPY = {}

if player and player.main_job == 'RDM' then
    -- Atrophy / Vitiation / Lethargy
    AF.Set   = "Atrophy"                RELIC.Set   = "Vitiation"               EMPY.Set   = "Lethargy"
    AF.Head  = "Atrophy Chapeau +3"     RELIC.Head  = "Viti. Chapeau +4"        EMPY.Head  = "Leth. Chappel +3"
    AF.Body  = "Atrophy Tabard +4"      RELIC.Body  = "Viti. Tabard +3"         EMPY.Body  = "Lethargy Sayon +3"
    AF.Hands = "Atrophy Gloves +4"      RELIC.Hands = "Viti. Gloves +3"         EMPY.Hands = "Leth. Ganth. +3"
    AF.Legs  = "Atrophy Tights +3"      RELIC.Legs  = "Viti. Tights +3"         EMPY.Legs  = "Leth. Fuseau +3"
    AF.Feet  = "Atro. Boots +3"         RELIC.Feet  = "Viti. Boots +4"          EMPY.Feet  = "Leth. Houseaux +3"
    EMPY.Ear = { name="Leth. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+13','Mag. Acc.+13','"Dbl.Atk."+4',}}
end

if player and player.main_job == 'THF' then
    -- Pillager's / Plunderer's / Skulker's
    AF.Set   = "Pillager's"             RELIC.Set   = "Plunderer's"             EMPY.Set   = "Skulker's"
    AF.Head  = "Pill. Bonnet +2"        RELIC.Head  = "Plun. Bonnet +2"         EMPY.Head  = "Skulker's Bonnet +1"
    AF.Body  = "Pillager's Vest +3"     RELIC.Body  = "Plunderer's Vest +3"     EMPY.Body  = "Skulker's Vest +1"
    AF.Hands = "Pill. Armlets +2"       RELIC.Hands = "Plun. Armlets +1"        EMPY.Hands = "Skulk. Armlets +1"
    AF.Legs  = "Pill. Culottes +1"      RELIC.Legs  = "Plun. Culottes +3"       EMPY.Legs  = "Skulk. Culottes +1"
    AF.Feet  = "Pill. Poulaines +1"     RELIC.Feet  = "Plun. Poulaines +2"      EMPY.Feet  = "Skulk. Poulaines +3"
    EMPY.Ear = "Skulker's Earring +1"
end

---============================================================================
--- AMBUSCADE CAPES
---============================================================================

RDMCape = {}
RDMCape.WS = {}
RDMCape.Idle     = { name="Sucellos's Cape", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Phys. dmg. taken-10%',}}
RDMCape.TP       = { name="Sucellos's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10','Phys. dmg. taken-10%',}}
RDMCape.STP      = RDMCape.TP
RDMCape.WS.STR   = { name="Sucellos's Cape", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%',}}
RDMCape.WS.MND   = { name="Sucellos's Cape", augments={'MND+20','Accuracy+20 Attack+20','MND+10','Weapon skill damage +10%',}}
RDMCape.WS.MNDma = { name="Sucellos's Cape", augments={'MND+20','Mag. Acc+20 /Mag. Dmg.+20','MND+10','Weapon skill damage +10%',}}
RDMCape.INT      = { name="Sucellos's Cape", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','INT+10','"Mag.Atk.Bns."+10',}}
RDMCape.Ens      = { name="Ghostfyre Cape", augments={'Enfb.mag. skill +10','Enha.mag. skill +10','Enh. Mag. eff. dur. +20',}}

THFCape = {}
THFCape.TP = { name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10','Damage taken -5%',}}
THFCape.WS = { name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','Weapon skill damage +10%',}}

---============================================================================
--- AUGMENTED WEAPONS
---============================================================================

Colada = {}
Colada.Enhancing = { name="Colada", augments={'Enh. Mag. eff. dur. +4','Mag. Acc.+1','"Mag.Atk.Bns."+11','DMG:+10',}}

Grioavolr = {}
Grioavolr.ConserveMP = { name="Grioavolr", augments={'"Conserve MP"+10','MND+10','Mag. Acc.+11','"Mag.Atk.Bns."+1','Magic Damage +4',}}

---============================================================================
--- DOMAIN INVASION / OSEEM ARMOR
---============================================================================

CHIR = {Head = {}, Body = {}, Hands = {}, Legs = {}, Feet = {}}
CHIR.Hands.Refresh = { name="Chironic Gloves", augments={'Attack+8','MND+8','"Refresh"+2','Accuracy+9 Attack+9',}}
CHIR.Legs.Refresh  = { name="Chironic Hose", augments={'"Dbl.Atk."+3','Pet: INT+3','"Refresh"+2','Mag. Acc.+17 "Mag.Atk.Bns."+17',}}
CHIR.Feet.Refresh  = { name="Chironic Slippers", augments={'Pet: INT+4','INT+10','"Refresh"+2','Accuracy+1 Attack+1',}}
CHIR.Hands.Phalanx = { name="Chironic Gloves", augments={'STR+8','"Subtle Blow"+7','Phalanx +5','Mag. Acc.+11 "Mag.Atk.Bns."+11',}}
CHIR.Legs.Phalanx  = { name="Chironic Hose", augments={'"Dbl.Atk."+1','"Occult Acumen"+9','Phalanx +3','Mag. Acc.+10 "Mag.Atk.Bns."+10',}}
CHIR.Feet.Phalanx  = { name="Chironic Slippers", augments={'AGI+6','INT+13','Phalanx +4','Mag. Acc.+16 "Mag.Atk.Bns."+16',}}
CHIR.Legs.Macc     = { name="Chironic Hose", augments={'Mag. Acc.+23','"Drain" and "Aspir" potency +2','STR+1 DEX+1','Accuracy+10 Attack+10','Mag. Acc.+18 "Mag.Atk.Bns."+18',}}

TELC = {Head = {}, Body = {}, Hands = {}, Legs = {}, Feet = {}}
TELC.Head.Enh = { name="Telchine Cap", augments={'Mag. Evasion+23','"Fast Cast"+5','Enh. Mag. eff. dur. +10',}}
TELC.Legs.Enh = { name="Telchine Braconi", augments={'"Cure" potency +8%','Enh. Mag. eff. dur. +10',}}

HERC = {Head = {}, Body = {}, Hands = {}, Legs = {}, Feet = {}}
HERC.Head.Refresh = { name="Herculean Helm", augments={'MND+6','INT+11','"Refresh"+2',}}
HERC.Hands.Refresh = { name="Herculean Gloves", augments={'Attack+25','Weapon skill damage +2%','"Refresh"+2','Accuracy+3 Attack+3',}}
HERC.Head.FC = { name="Herculean Helm", augments={'"Mag.Atk.Bns."+14','"Fast Cast"+6','Mag. Acc.+1',}}
HERC.Feet.FC = { name="Herculean Boots", augments={'"Mag.Atk.Bns."+16','"Fast Cast"+5','INT+6',}}

---============================================================================
--- ESCHA / REISENJIMA ARMOR
---============================================================================

AMAL = {Head = {HQ = {}}}
AMAL.Head.HQ.D = { name="Amalric Coif +1", augments={'INT+12','Mag. Acc.+25','Enmity-6',}}

KAYK = {Body = {HQ = {}}, Hands = {HQ = {}}}
KAYK.Body.HQ.D  = { name="Kaykaus Bliaut +1", augments={'MP+80','"Cure" potency +6%','"Conserve MP"+7',}}
KAYK.Hands.HQ.D = { name="Kaykaus Cuffs +1", augments={'MP+80','"Conserve MP"+7','"Fast Cast"+4',}}

VANY = {Legs = {}, Feet = {}}
VANY.Cure   = { name="Vanya Hood", augments={'MP+50','"Cure" potency +7%','Enmity-6',}}
VANY.Legs.C = { name="Vanya Slops", augments={'MND+10','Spell interruption rate down +15%','"Conserve MP"+6',}}
VANY.Feet.D = { name="Vanya Clogs", augments={'"Cure" potency +5%','"Cure" spellcasting time -15%','"Conserve MP"+6',}}

PURS = {Hands = {}}
PURS.Hands.A = { name="Pursuer's Cuffs", augments={'AGI+7','"Rapid Shot"+8','"Subtle Blow"+5',}}

---============================================================================
--- CAPACITY POINT CAPE
---============================================================================

CAPACITY = {}
CAPACITY.Cape = { name="Mecisto. Mantle", augments={'Cap. Point+50%','STR+2','"Mag.Atk.Bns."+4','DEF+2',}}

---============================================================================
--- RINGS (one per wardrobe: GearSwap cannot tell two copies apart)
---============================================================================

STIK = {}
STIK.One = {name = "Stikini Ring +1", bag = "wardrobe"}
STIK.Two = {name = "Stikini Ring +1", bag = "wardrobe 2"}
CHIR.One = {name = "Chirich Ring +1", bag = "wardrobe"}
CHIR.Two = {name = "Chirich Ring +1", bag = "wardrobe 2"}

---============================================================================
--- AMBUSCADE ARMOR
---============================================================================

AYAN = {Set = "Ayanmo", Head = "Aya. Zucchetto +2", Body = "Ayanmo Corazza +2", Hands = "Aya. Manopolas +2", Legs = "Aya. Cosciales +2", Feet = "Aya. Gambieras +2", Ring = "Ayanmo Ring"}
JHAK = {Set = "Jhakri", Head = "Jhakri Coronal +2", Body = "Jhakri Robe +2", Hands = "Jhakri Cuffs +2", Legs = "Jhakri Slops +2", Feet = "Jhakri Pigaches +2", Ring = "Jhakri Ring"}
MEGH = {Set = "Meghanada", Head = "Meghanada Visor +2", Body = "Meg. Cuirie +2", Hands = "Meg. Gloves +2", Legs = "Meg. Chausses +2", Feet = "Meg. Jam. +2", Ring = "Meghanada Ring"}
MUMM = {Set = "Mummu", Head = "Mummu Bonnet +2", Body = "Mummu Jacket +2", Hands = "Mummu Wrists +2", Legs = "Mummu Kecks +2", Feet = "Mummu Gamash. +2", Ring = "Mummu Ring"}
