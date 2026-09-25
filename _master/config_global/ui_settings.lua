-- UI Settings - starting values for a new character.
-- Rewritten in game on every UI setting change and by //gs c ui save; a
-- re-clone keeps the character's own copy. The position is the one
-- ui_settings_resolver falls back to when no file exists; the old value
-- (x 1946) was past the right edge of a 1920-wide window. On a window 1600
-- pixels wide or less, drag the HUD and //gs c ui save.
return {
    -- Position
    pos_x = 1600,
    pos_y = 300,

    -- Visibility
    enabled = true,
    show_header = false,
    show_legend = true,
    show_column_headers = false,
    show_footer = false,

    -- Background
    bg_r = 15,
    bg_g = 15,
    bg_b = 35,
    bg_a = 180,
    bg_visible = true,

    -- Font
    font_size = 10,
    font_name = "Consolas",

    -- Sections
    section_spells = true,
    section_enhancing = true,
    section_job_abilities = true,
    section_weapons = true,
    section_modes = true
}
