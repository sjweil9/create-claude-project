#!/usr/bin/env bash
# PostToolUse[Bash] hook: after any `git merge` or `git pull`, run the full
# quality gate (lint + build + tests) before the session may proceed.
input="$(cat)"
printf '%s' "$input" | python3 -c 'import json,sys,re
c=(json.load(sys.stdin).get("tool_input",{}).get("command","") or "")+" "
sys.exit(0 if re.search(r"git\s+.*(merge|pull)[^a-zA-Z0-9_-]", c) else 1)' 2>/dev/null || exit 0

dir="${CLAUDE_PROJECT_DIR:-.}"
cd "$dir" || exit 0
. "$dir/scripts/claude-hooks/lib.sh"
log=/tmp/cc-merge-gate.$$.log
trap 'rm -f "$log"' EXIT

if [ -f Gemfile ]; then
  if grep -q rubocop Gemfile.lock 2>/dev/null; then
    app_exec bundle exec rubocop --force-exclusion >"$log" 2>&1 || fail_gate "post-merge rubocop" "$log"
  fi
  if [ -d spec ] && grep -q rspec Gemfile.lock 2>/dev/null; then
    app_exec_deps bundle exec rspec >"$log" 2>&1 || fail_gate "post-merge rspec" "$log"
  elif [ -d test ]; then
    app_exec_deps bin/rails test >"$log" 2>&1 || fail_gate "post-merge rails test" "$log"
  fi
elif [ -f package.json ]; then
  ensure_node
  npm run lint --if-present >"$log" 2>&1 || fail_gate "post-merge lint" "$log"
  npm run build --if-present >"$log" 2>&1 || fail_gate "post-merge build" "$log"
  CI=1 npm test --if-present >"$log" 2>&1 || fail_gate "post-merge tests" "$log"
fi
exit 0
