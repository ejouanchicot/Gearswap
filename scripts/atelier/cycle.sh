#!/bin/bash
# GearSwap Atelier · the checks of a change to the page, in one command.
#
#   bash scripts/atelier/cycle.sh quick sets opt [-- tip push]   a step: build, built page up to date, pixel parity of
#                                                                 the screens named (scripts/atelier/parity/<name>.json),
#                                                                 the click tests named after -- compared last commit vs
#                                                                 now, the quick tests (a few minutes)
#   bash scripts/atelier/cycle.sh full                           before a commit that touches many screens: every
#                                                                 parity screen, every click test compared, the layout
#                                                                 check, run_tests.py --full (about 30 minutes)
#
# A parity screen at 0/N is run once more: a whole screen at 0 then N/N happens now and then, cause unknown.
# Run from anywhere. Ends with "CYCLE DONE"; every line that is not a pass is printed again at the end.
#
# @file    scripts/atelier/cycle.sh
# @author  ejouanchicot
# @date    Created: 2026-10-20

cd "$(dirname "$0")/../.." || exit 1
mode="$1"; shift
screens=(); clicks=()
while [ $# -gt 0 ]; do
  if [ "$1" = "--" ]; then shift; clicks=("$@"); break; fi
  screens+=("$1"); shift
done
if [ "$mode" = "full" ]; then
  screens=($(ls scripts/atelier/parity/*.json | xargs -n1 basename | sed 's/\.json$//'))
elif [ "$mode" != "quick" ]; then
  sed -n '4,10p' "$0"; exit 1
fi
log=$(mktemp)
say() { echo "$1" | tee -a "$log"; }

(cd atelier && npm run build 2>&1 | tail -1)
say "$(node scripts/atelier/atelier_build_check.js 2>&1 | tail -1)"
for s in "${screens[@]}"; do
  r=$(node scripts/atelier/page_parity.js scripts/atelier/parity/$s.json 2>&1 | grep -v "^    at" | tail -1)
  case "$r" in *" 0/"*|"0/"*) r="$r | retry: $(node scripts/atelier/page_parity.js scripts/atelier/parity/$s.json 2>&1 | grep -v "^    at" | tail -1)";; esac
  say "== $s $r"
done
if [ "$mode" = "full" ]; then
  say "$(node scripts/atelier/atelier_clicks_test.js --compare 2>&1 | tail -1)"
  say "$(node scripts/atelier/atelier_layout_check.js 2>&1 | tail -1)"
  # the click tests just ran, compared: run_tests.py leaves them out
  say "$(RUN_TESTS_SKIP=scripts/atelier/atelier_clicks_test.js python scripts/run_tests.py --full 2>&1 | tail -1)"
else
  [ ${#clicks[@]} -gt 0 ] && say "$(node scripts/atelier/atelier_clicks_test.js --compare "${clicks[@]}" 2>&1 | tail -1)"
  say "$(python scripts/run_tests.py 2>&1 | tail -1)"
fi
echo; echo "---- not passed:"
grep -v -e ' \([0-9]*\)/\1 identical' -e '^ok ' -e 'built from the current sources' -e ' 0 failed' -e '^0 problem' \
  -e '^\([0-9]*\)/\1 passed' "$log" || echo "(none)"
rm -f "$log"
echo CYCLE DONE
