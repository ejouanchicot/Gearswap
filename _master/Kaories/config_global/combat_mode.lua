-- Combat Mode on COR (Ctrl+Numpad8): On keeps Naegling / Anarchy on a Phantom
-- Roll while fighting (TP kept, no Rostam +8); Off lets the roll set put
-- Rostam and Compensator on. Her other jobs keep their own setting.
-- Rewritten by //gs c combatmode.
return {
    shown = {COR = true},
    hidden = {},
    keys = {COR = '^numpad8'},
}
