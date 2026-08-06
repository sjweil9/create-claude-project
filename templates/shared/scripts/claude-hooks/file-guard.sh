#!/usr/bin/env bash
# PreToolUse[Edit|Write|NotebookEdit] hook: blocks file modifications inside a
# git checkout that is on main. Forces all implementation work into a
# worktree/branch so it lands via PR. Files outside any git repo (scratchpad,
# memory) are unaffected.
input="$(cat)"
file="$(printf '%s' "$input" | python3 -c 'import json,sys
try:
  ti=json.load(sys.stdin).get("tool_input",{})
  print(ti.get("file_path") or ti.get("notebook_path") or "")
except Exception: pass' 2>/dev/null)" || exit 0
[ -n "$file" ] || exit 0

dir="$(dirname "$file")"
while [ ! -d "$dir" ] && [ "$dir" != "/" ]; do dir="$(dirname "$dir")"; done
git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

branch="$(git -C "$dir" branch --show-current 2>/dev/null || echo "")"
if [ "$branch" = "main" ]; then
  echo "BLOCKED by file-guard: this checkout is on main; files may not be modified on main." >&2
  echo "Create a worktree and work there instead:" >&2
  echo "  git worktree add .worktrees/<change-id> -b change/<change-id>" >&2
  echo "Then edit the file inside .worktrees/<change-id>/ and land it via PR." >&2
  exit 2
fi
exit 0
