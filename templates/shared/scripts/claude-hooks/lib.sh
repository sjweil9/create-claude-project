# Shared helpers for Claude quality-gate hooks. Sourced, not executed.

# Put a node >= 22 on PATH if the default one is too old (nvm layouts).
# Needed even for bun projects: package bins (vitest, tsc) carry node
# shebangs, and vitest's jsdom/undici need node >= 22.11.
ensure_node() {
  node -e 'process.exit(+process.versions.node.split(".")[0]>=22?0:1)' 2>/dev/null && return 0
  local best="" d
  for d in "$HOME"/.nvm/versions/node/v*/bin; do
    [ -x "$d/node" ] || continue
    "$d/node" -e 'process.exit(+process.versions.node.split(".")[0]>=22?0:1)' 2>/dev/null && best="$d"
  done
  [ -n "$best" ] && PATH="$best:$PATH"
  return 0
}

# Put bun on PATH (default install location) when not already there.
ensure_bun() {
  command -v bun >/dev/null 2>&1 && return 0
  [ -x "$HOME/.bun/bin/bun" ] && PATH="$HOME/.bun/bin:$PATH"
  return 0
}

# The react scaffold manages packages with bun; repos without a bun lockfile
# fall back to npm.
bun_project() { [ -f bun.lock ] || [ -f bun.lockb ]; }

# has_pkg_script <name>: does package.json define this script?
has_pkg_script() { grep -q "\"$1\"[[:space:]]*:" package.json 2>/dev/null; }

# fail <label> <logfile>: report a gate failure to the agent and block.
fail_gate() {
  echo "GATE FAILED: $1 — fix before proceeding." >&2
  tail -40 "$2" >&2
  exit 2
}

# Dockerized project detection: a compose file with an `app` service and a
# running daemon. When true, app commands must run in the container (the
# host has no toolchain).
dockerized_app() {
  { [ -f docker-compose.yml ] || [ -f compose.yaml ] || [ -f compose.yml ]; } || return 1
  command -v docker >/dev/null 2>&1 || return 1
  docker info >/dev/null 2>&1 || return 1
  docker compose config --services 2>/dev/null | grep -qx app
}

# Run a command in the app context: through docker compose when the project
# is Dockerized, else directly on the host. app_exec skips dependency
# services (fast checks like rubocop); app_exec_deps starts them (tests that
# need the database).
app_exec() {
  if dockerized_app; then docker compose run --rm --no-deps app "$@"; else "$@"; fi
}
app_exec_deps() {
  if dockerized_app; then docker compose run --rm app "$@"; else "$@"; fi
}
