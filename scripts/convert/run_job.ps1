# ============================================================================
# Foreign GearSwap converter - one job, from the foreign file to a checked sets file
# ============================================================================
# eval (foreign_eval.lua) -> write (write_sets.js, with maps/<player>/<job>.js when
# there is one) -> round trip (roundtrip.lua + check_roundtrip.js).
#
#   .\run_job.ps1 <foreign data dir> <Player> <JOB> <SUB> <file name> <work dir>
#
# @file    scripts/convert/run_job.ps1
# @author  ejouanchicot
# @version 1.0
# @date    Created: 2026-10-16
# ============================================================================
param($Foreign, $Player, $Job, $Sub, $File, $Work)
$here = $PSScriptRoot
$data = (Resolve-Path "$here\..\..").Path
New-Item -ItemType Directory -Force $Work | Out-Null
$j = $Job.ToLower()
Push-Location $data
try {
    lua5.1 scripts/convert/foreign_eval.lua $Foreign $Player $Job $Sub $File "$Work/$Job.eval.json"
    $map = "$here/maps/$($Player.ToLower())/$j.js"
    if (-not (Test-Path $map)) { $map = '-' }
    node scripts/convert/write_sets.js "$Work/$Job.eval.json" $map "$Work/${j}_sets.lua" "$Work/$Job.report.json"
    if ($LASTEXITCODE) { throw "write_sets failed" }
    # the job's config files are all written again: one a map no longer patches must not stay
    if (Test-Path "$Work/config/$j") { Remove-Item -Recurse -Force "$Work/config/$j" }
    New-Item -ItemType Directory -Force "$Work/config/$j" | Out-Null
    node scripts/convert/write_states.js "$Work/$Job.eval.json" $map "_master/config/$j/${Job}_STATES.lua" "$Work/config/$j/${Job}_STATES.lua" "$Work/$Job.states.json"
    node scripts/convert/write_custom.js "$Work/$Job.eval.json" $map "_master/config/$j/${Job}_CUSTOM.lua" "$Work/config/$j/${Job}_CUSTOM.lua" "$Work/$Job.states.json"
    lua5.1 scripts/convert/roundtrip.lua "$Work/${j}_sets.lua" "$Work/$Job.roundtrip.json"
    node scripts/convert/check_roundtrip.js "$Work/$Job.report.json" "$Work/$Job.roundtrip.json"
} finally { Pop-Location }
