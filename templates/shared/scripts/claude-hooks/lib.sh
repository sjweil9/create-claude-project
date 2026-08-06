# Shared helpers for Claude quality-gate hooks. Sourced, not executed.

# Put a node >= 20 on PATH if the default one is too old (nvm layouts).
ensure_node() {
  node -e 'process.exit(+process.versions.node.split(".")[0]>=20?0:1)' 2>/dev/null && return 0
  local best="" d
  for d in "$HOME"/.nvm/versions/node/v*/bin; do
    [ -x "$d/node" ] || continue
    "$d/node" -e 'process.exit(+process.versions.node.split(".")[0]>=20?0:1)' 2>/dev/null && best="$d"
  done
  [ -n "$best" ] && PATH="$best:$PATH"
  return 0
}

# fail <label> <logfile>: report a gate failure to the agent and block.
fail_gate() {
  echo "GATE FAILED: $1 — fix before proceeding." >&2
  tail -40 "$2" >&2
  exit 2
}
