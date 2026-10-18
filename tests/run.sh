#!/usr/bin/env bash
# Tests the features of this Neovim config (tests/features.lua), using your real config.
#
#   tests/run.sh               every group
#   tests/run.sh review disk   only some: editing pickers git review discard disk
#
# Each group runs in its own headless Neovim, in throwaway git repos in a temp folder. Your files,
# repos and clipboard aren't touched, and no recent-files list or undo files are written.
set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1
groups=("$@")
[ ${#groups[@]} -gt 0 ] || groups=(editing pickers git review discard disk)

failures=0
for group in "${groups[@]}"; do
  echo "Neovim features: $group"
  results=$(mktemp)
  GROUP=$group RESULTS=$results timeout 180 nvim --headless -i NONE -c "luafile $PWD/features.lua" >/dev/null 2>&1
  status=$?
  cat "$results"
  failed=$(grep -c FAIL "$results")
  if [ "$status" -eq 124 ]; then
    printf '  \033[31mFAIL\033[0m the %s tests got stuck (stopped after 3 minutes)\n' "$group"
    failed=$((failed + 1))
  elif [ "$status" -ne 0 ] && [ "$failed" -eq 0 ]; then
    printf '  \033[31mFAIL\033[0m Neovim exited with an error (status %s)\n' "$status"
    failed=1
  fi
  failures=$((failures + failed))
  rm -f "$results"
done

echo
if [ "$failures" -eq 0 ]; then
  echo "All Neovim feature tests passed."
else
  echo "$failures Neovim feature test(s) failed."
  exit 1
fi
