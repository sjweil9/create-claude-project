#!/usr/bin/env bash
# PreToolUse[Bash] hook: blocks git operations that bypass the PR workflow.
# Exit 2 = block the tool call and feed stderr back to the agent.
input="$(cat)"
cmd="$(printf '%s' "$input" | python3 -c 'import json,sys
try: print(json.load(sys.stdin).get("tool_input",{}).get("command",""))
except Exception: pass' 2>/dev/null)" || exit 0
[ -n "$cmd" ] || exit 0

branch="$(git -C "${CLAUDE_PROJECT_DIR:-.}" branch --show-current 2>/dev/null || echo "")"
block() { echo "BLOCKED by bash-guard: $1" >&2; exit 2; }

# Force pushes: never.
if [[ "$cmd" =~ git[[:space:]].*push ]] && [[ "$cmd" =~ (--force|--force-with-lease|[[:space:]]-f[[:space:]]) ]]; then
  block "force pushes are not allowed."
fi

# Pushing to main: never (main only moves via merged PRs).
if [[ "$cmd" =~ git[[:space:]].*push ]]; then
  if [[ "$cmd" =~ (^|[^A-Za-z0-9_/-])main([^A-Za-z0-9_-]|$) ]] || [ "$branch" = "main" ]; then
    block "pushing to main is not allowed. Push your change/* branch and open a PR (gh pr create)."
  fi
fi

# Committing or merging while checked out on main: never.
if [ "$branch" = "main" ]; then
  if [[ "$cmd" =~ git[[:space:]].*(commit|merge|cherry-pick|rebase) ]]; then
    block "you are on main. Create a worktree first: git worktree add .worktrees/<change-id> -b change/<change-id>"
  fi
fi

# Bypassing the committed git hooks: never for agents.
if [[ "$cmd" =~ --no-verify ]] || [[ "$cmd" =~ core\.hooksPath ]]; then
  block "bypassing git hooks (--no-verify / core.hooksPath) is not allowed."
fi

exit 0
