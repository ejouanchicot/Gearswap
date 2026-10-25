---============================================================================
--- default.lua - loaded by GearSwap when the character has no file for its job
---============================================================================
--- GearSwap opens <Char>/<Char>_<JOB>.lua when there is one; for a job with no
--- file it ends here. Nothing is equipped, but the Atelier can reach the game:
--- its "+ Add a job" makes the job's files, then //gs reload loads them.
--- The code is in shared/entry/no_job_file.lua.
---
--- @file    default.lua
--- @author  ejouanchicot
---============================================================================

include('shared/entry/no_job_file.lua')
