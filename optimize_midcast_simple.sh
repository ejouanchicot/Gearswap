#!/bin/bash
# Optimize MIDCAST files with simple pattern (MidcastManager + EnhancingSPELLS only)
# Jobs: COR, DNC, DRK, SAM, THF, WHM

JOBS_SIMPLE="cor dnc drk sam thf whm"

for job in $JOBS_SIMPLE; do
    JOB_UPPER=$(echo "$job" | tr '[:lower:]' '[:upper:]')
    MIDCAST_FILE="shared/jobs/${job}/functions/${JOB_UPPER}_MIDCAST.lua"

    echo "=== Processing $JOB_UPPER_MIDCAST.lua ==="

    if [ ! -f "$MIDCAST_FILE" ]; then
        echo "ERROR: File not found: $MIDCAST_FILE"
        continue
    fi

    # Create backup
    cp "$MIDCAST_FILE" "$MIDCAST_FILE.bak_lazy"

    # Read the entire file
    content=$(cat "$MIDCAST_FILE")

    # Check if already optimized
    if echo "$content" | grep -q "local modules_loaded = false"; then
        echo "SKIP: $JOB_UPPER already optimized"
        rm "$MIDCAST_FILE.bak_lazy"
        continue
    fi

    # Replace the dependencies section (lines 17-24 typically)
    # Find the line with "local MidcastManager = require" and replace until the pcall line

    perl -i -pe '
        # Replace direct require with nil declaration
        s/^local MidcastManager = require\(.*\)$/local MidcastManager = nil/;

        # Replace pcall line for EnhancingSPELLS
        if (/^local EnhancingSPELLS_success, EnhancingSPELLS = pcall\(/) {
            $_ = "local EnhancingSPELLS = nil\nlocal EnhancingSPELLS_success = false\n\nlocal modules_loaded = false\n\nlocal function ensure_modules_loaded()\n    if modules_loaded then return end\n\n    MidcastManager = require('"'"'shared/utils/midcast/midcast_manager'"'"')\n    EnhancingSPELLS_success, EnhancingSPELLS = pcall(require, '"'"'shared/data/magic/ENHANCING_MAGIC_DATABASE'"'"')\n\n    modules_loaded = true\nend\n";
        }
    ' "$MIDCAST_FILE"

    # Add ensure_modules_loaded() call at the start of job_post_midcast
    perl -i -pe '
        if (/^function job_post_midcast\(spell, action, spellMap, eventArgs\)$/) {
            $_ .= "    -- Lazy load modules on first spell cast\n    ensure_modules_loaded()\n\n";
        }
    ' "$MIDCAST_FILE"

    echo "SUCCESS: $JOB_UPPER optimized"
done

echo ""
echo "=== MIDCAST Simple Optimization Complete ==="
echo "Backup files created with .bak_lazy extension"
