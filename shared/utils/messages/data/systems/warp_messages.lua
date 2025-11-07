---============================================================================
--- WARP Message Data - Warp/Teleport System Messages
---============================================================================
--- Pure data file for warp system messages
--- Used by new message system (api/messages.lua)
---
--- @file data/systems/warp_messages.lua
--- @author Tetsouo
--- @date Created: 2025-11-06
---============================================================================

return {
    ---========================================================================
    --- WARP MESSAGES
    ---========================================================================

    warp_casting = {
        template = "{jobtag}[WARP]{separatorcolor} Casting {spellcolor}{spell_name}{separatorcolor}...",
        color = 1
    },

    warp_equipping = {
        template = "{jobtag}[WARP]{separatorcolor} Equipping {itemcolor}{ring_name}{separatorcolor}...",
        color = 1
    },

    warp_countdown = {
        template = "{jobtag}[WARP]{separatorcolor} Using in {green}{seconds}s{separatorcolor}...",
        color = 1
    },

    warp_using = {
        template = "{jobtag}[WARP]{separatorcolor} Using {itemcolor}{ring_name}{separatorcolor}!",
        color = 1
    },

    warp_level_error = {
        template = "{jobtag}[WARP] {red}{spell_name} requires BLM level {separatorcolor}{required_level}{red} (current: {separatorcolor}{current_level}{red})",
        color = 1
    },

    warp_requires_blm = {
        template = "{jobtag}[WARP] {spellcolor}{spell_name} {warningcolor}requires BLM lvl {required_level}",
        color = 1
    },

    warp_unavailable = {
        template = "{jobtag}[WARP] {red}Cannot warp - Requires BLM main/sub or {ring_text}",
        color = 1
    },

    warp_no_charges = {
        template = "{jobtag}[WARP] {itemcolor}{ring_name} {red}- No charges remaining",
        color = 1
    },

    warp_recast = {
        template = "{jobtag}[WARP] {itemcolor}{ring_name} {red}- Recast: {seconds}s",
        color = 1
    },

    warp_charges_remaining = {
        template = "{jobtag}[WARP] {itemcolor}{ring_name} {separatorcolor}- Charges remaining: {charges}",
        color = 1
    },

    ---========================================================================
    --- TELEPORT MESSAGES
    ---========================================================================

    tele_casting = {
        template = "{jobtag}[TELE]{separatorcolor} Casting {spellcolor}{spell_name}{separatorcolor}...",
        color = 1
    },

    tele_equipping = {
        template = "{jobtag}[TELE]{separatorcolor} Equipping {itemcolor}{ring_name}{separatorcolor}...",
        color = 1
    },

    tele_countdown = {
        template = "{jobtag}[TELE]{separatorcolor} Using in {green}{seconds}s{separatorcolor}...",
        color = 1
    },

    tele_using = {
        template = "{jobtag}[TELE]{separatorcolor} Using {itemcolor}{ring_name}{separatorcolor}!",
        color = 1
    },

    tele_level_error = {
        template = "{jobtag}[TELE] {red}{spell_name} requires WHM level {separatorcolor}{required_level}{red} (current: {separatorcolor}{current_level}{red})",
        color = 1
    },

    tele_requires_whm = {
        template = "{jobtag}[TELE] {spellcolor}{spell_name} {warningcolor}requires WHM lvl {required_level}",
        color = 1
    },

    spell_cannot_cast = {
        template = "{jobtag}[WARP] {warningcolor}Cannot cast: {error_reason}",
        color = 1
    },

    tele_unavailable = {
        template = "{jobtag}[TELE] {red}Cannot teleport - Requires WHM main/sub or {ring_text}",
        color = 1
    },

    tele_no_charges = {
        template = "{jobtag}[TELE] {itemcolor}{ring_name} {red}- No charges remaining",
        color = 1
    },

    tele_recast = {
        template = "{jobtag}[TELE] {itemcolor}{ring_name} {red}- Recast: {seconds}s",
        color = 1
    },

    tele_charges_remaining = {
        template = "{jobtag}[TELE] {itemcolor}{ring_name} {separatorcolor}- Charges remaining: {charges}",
        color = 1
    },

    ---========================================================================
    --- IPC MESSAGES
    ---========================================================================

    ipc_test_sent = {
        template = "{jobtag}[WARP]{separatorcolor} Sending IPC test message...",
        color = 1
    },

    ipc_test_sent_confirm = {
        template = "{jobtag}[WARP]{separatorcolor} IPC test message sent!",
        color = 1
    },

    ipc_test_received = {
        template = "{jobtag}[Warp IPC]{green} TEST message received from: {itemcolor}{sender}",
        color = 1
    },

    ipc_test_received_confirm = {
        template = "{jobtag}[Warp IPC] {green}✓ IPC system is working!",
        color = 1
    },

    ipc_broadcasting = {
        template = "{jobtag}[WARP]{separatorcolor} Broadcasting {itemcolor}\"{command}\"{separatorcolor} to other characters...",
        color = 1
    },

    ipc_command_received = {
        template = "{jobtag}[Warp IPC]{separatorcolor} Command received: {itemcolor}{command}",
        color = 1
    },

    ipc_executing = {
        template = "{jobtag}[Warp IPC]{green} Executing: {itemcolor}//gs c {command}",
        color = 1
    },

    ipc_not_allowed = {
        template = "{jobtag}[Warp IPC] {red}Command not allowed: {command}",
        color = 1
    },

    ---========================================================================
    --- EQUIPMENT MESSAGES
    ---========================================================================

    equipment_locked = {
        template = "{jobtag}[{tag}]{separatorcolor} Equipment locked {green}({duration})",
        color = 1
    },

    equipment_unlocked = {
        template = "{jobtag}[{tag}]{separatorcolor} Equipment unlocked {green}({duration})",
        color = 1
    },

    equipment_lock_error = {
        template = "{jobtag}[WARP] {red}Failed to lock equipment: {error_msg}",
        color = 1
    },

    equipment_unlock_error = {
        template = "{jobtag}[WARP] {red}Failed to unlock equipment: {error_msg}",
        color = 1
    },

    ---========================================================================
    --- COMMAND MESSAGES
    ---========================================================================

    force_unlock = {
        template = "{jobtag}[WARP]{separatorcolor} Force unlocking equipment...",
        color = 1
    },

    fix_ring_start = {
        template = "{jobtag}[WARP]{separatorcolor} Fixing frozen ring slot...",
        color = 1
    },

    fix_ring_complete = {
        template = "{jobtag}[WARP]{green} Ring slot fixed!",
        color = 1
    },

    manual_lock = {
        template = "{jobtag}[WARP]{separatorcolor} Manually locking equipment for 10 seconds...",
        color = 1
    },

    debug_toggle = {
        template = "{jobtag}[WARP]{separatorcolor} Debug mode: {status_color}{status_text}",
        color = 1
    },

    using_destination = {
        template = "{jobtag}[WARP]{separatorcolor} Using {itemcolor}{item_name}{separatorcolor} → {destination}",
        color = 1
    },

    registered_common = {
        template = "{jobtag}[WARP]{green} Registered with common commands",
        color = 1
    },

    ---========================================================================
    --- PRECAST MESSAGES
    ---========================================================================

    precast_fc_warning = {
        template = "{jobtag}[WARP] {red}Warning: sets.precast.FC not found for {spellcolor}{spell_name}",
        color = 1
    },

    force_fc = {
        template = "{jobtag}[WARP]{separatorcolor} Force FC for {spellcolor}{spell_name}",
        color = 1
    },

    ---========================================================================
    --- ITEM COOLDOWN MESSAGES
    ---========================================================================

    all_items_cooldown = {
        template = "{jobtag}[WARP]{warningcolor} All items on cooldown",
        color = 1
    },

    item_cooldown_time = {
        template = "  {itemcolor}{item_name}{separatorcolor} - ready in {time_msg}",
        color = 1
    },

    item_equip_delay = {
        template = "  {itemcolor}{item_name}{separatorcolor} - equip delay",
        color = 1
    },

    next_available_item = {
        template = "{jobtag}[WARP]{separatorcolor} Next available: {itemcolor}{item_name}{separatorcolor} in {time_msg}",
        color = 1
    },

    ---========================================================================
    --- INIT/SYSTEM MESSAGES
    ---========================================================================

    init_error = {
        template = "{jobtag}[Warp Init] {red}Failed to load {module_name}: {error_msg}",
        color = 1
    },
}
