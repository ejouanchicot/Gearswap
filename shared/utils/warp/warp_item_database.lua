---============================================================================
--- Warp Item Database - WRAPPER (Redirects to Modular Database)
---============================================================================
--- This file is now a thin wrapper that redirects to the modular database system.
--- The actual data is split across 6 specialized modules in database/ folder.
---
--- @file warp_item_database.lua
--- @author Tetsouo
--- @version 4.0 - Modular Architecture (WRAPPER)
--- @date 2025-10-28
---============================================================================

-- Simply export the modular database core
return require('shared/utils/warp/database/warp_database_core')
