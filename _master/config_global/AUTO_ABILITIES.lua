---============================================================================
--- Auto Abilities - job abilities used for you
---============================================================================
--- Off unless set to true here:
--- sam_hasso        SAM: your chosen stance (Hasso, or Seigan after //gs c seigan)
---                  when you engage, unless Hasso or Seigan is up
--- geo_entrust      GEO: an Indi- cast on a party member gets Entrust first
--- geo_full_circle  GEO: a Geo- cast while a luopan is out gets Full Circle first
--- blu_unbridled    BLU: an unbridled spell cast without Unbridled Learning /
---                  Wisdom gets Unbridled Learning first, then goes again
--- blu_expiacion_window  BLU: with Tizona, no Aftermath: Lv.3 and under 3000
---                  TP, Expiacion is cancelled once; pressed again within 3 s,
---                  it goes
---
--- On unless set to false here (they always ran before they could be
--- turned off):
--- sam_third_eye_ws        SAM: Third Eye before a weaponskill
--- pld_divine_emblem       PLD: Divine Emblem before Flash
--- pld_majesty             PLD: Majesty before Protect / Cure
--- blm_dark_arts           BLM/SCH: Dark Arts before a nuke
--- blm_klimaform           BLM/SCH: Klimaform before a storm (//gs c storm)
--- dnc_presto              DNC: Presto before a step (//gs c step)
--- war_retaliation_cancel  WAR: Retaliation cancelled after 5 s of running
---
--- @file _common/combat/AUTO_ABILITIES.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-09-25
---============================================================================

return {
    sam_hasso = false,
    geo_entrust = false,
    geo_full_circle = false,
    blu_unbridled = false,
    blu_expiacion_window = false,

    sam_third_eye_ws = true,
    pld_divine_emblem = true,
    pld_majesty = true,
    blm_dark_arts = true,
    blm_klimaform = true,
    dnc_presto = true,
    war_retaliation_cancel = true,
}
