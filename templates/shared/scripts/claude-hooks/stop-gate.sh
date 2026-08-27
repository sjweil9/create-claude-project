#!/usr/bin/env bash
# Stop hook: a session may not end with modified source files that fail lint
# or type checks. No-ops gracefully until the app is scaffolded.
dir="${CLAUDE_PROJECT_DIR:-.}"
cd "$dir" || exit 0
. "$dir/scripts/claude-hooks/lib.sh"
log=/tmp/cc-stop-gate.$$.log
trap 'rm -f "$log"' EXIT

if [ -f Gemfile ]; then
  git status --porcelain 2>/dev/null | grep -qE '\.(rb|erb)$' || exit 0
  if grep -q rubocop Gemfile.lock 2>/dev/null; then
    if ! app_exec bundle exec rubocop --force-exclusion --fail-level convention >"$log" 2>&1; then
      fail_gate "rubocop" "$log"
    fi
  fi
elif [ -f package.json ]; then
  git status --porcelain 2>/dev/null | grep -qE '\.(ts|tsx|js|jsx|css)$' || exit 0
  ensure_node
  if ! npm run lint --if-present >"$log" 2>&1; then
    fail_gate "lint" "$log"
  fi
  if [ -f tsconfig.json ]; then
    if ! npx tsc -b >"$log" 2>&1; then
      fail_gate "tsc typecheck" "$log"
    fi
  fi
fi
exit 0
