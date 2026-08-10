#!/usr/bin/env bash
# Installs the create-claude-project and add-claude-scaffolding commands by
# symlinking them into a PATH directory. Safe to re-run; run from anywhere.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Pick an install dir: prefer ~/.local/bin, else /usr/local/bin if writable.
INSTALL_DIR="$HOME/.local/bin"
if [ ! -d "$INSTALL_DIR" ] && [ -w /usr/local/bin ]; then
  INSTALL_DIR=/usr/local/bin
fi
mkdir -p "$INSTALL_DIR"

for cmd in create-claude-project add-claude-scaffolding; do
  BIN="$ROOT/bin/$cmd"
  [ -f "$BIN" ] || { echo "error: $BIN not found" >&2; exit 1; }
  chmod +x "$BIN"
  ln -sf "$BIN" "$INSTALL_DIR/$cmd"
  echo "installed: $INSTALL_DIR/$cmd -> $BIN"
done

# PATH check
case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *)
    echo ""
    echo "NOTE: $INSTALL_DIR is not on your PATH. Add this to your shell profile"
    echo "(~/.zshrc or ~/.bashrc) and restart your shell:"
    echo ""
    echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
    ;;
esac

# Dependency report (nothing here blocks the install; the command itself
# re-checks at runtime and auto-installs the openspec CLI).
echo ""
echo "Dependency check:"
ok() { echo "  [ok]      $1"; }
missing() { echo "  [MISSING] $1"; }

command -v git >/dev/null 2>&1 && ok "git" || missing "git — required"

node_ok=""
if command -v node >/dev/null 2>&1 && node -e 'process.exit(+process.versions.node.split(".")[0]>=20?0:1)' 2>/dev/null; then
  node_ok=1
else
  for d in "$HOME"/.nvm/versions/node/v*/bin; do
    [ -x "$d/node" ] || continue
    "$d/node" -e 'process.exit(+process.versions.node.split(".")[0]>=20?0:1)' 2>/dev/null && node_ok=1
  done
fi
if [ -n "$node_ok" ]; then
  ok "node >= 20 (directly or via nvm; found automatically at runtime)"
else
  missing "node >= 20 — required for the openspec CLI (e.g. 'nvm install 20')"
fi

command -v python3 >/dev/null 2>&1 && ok "python3 (used by the generated Claude hooks)" || missing "python3 — required by the generated Claude hooks"

if command -v gh >/dev/null 2>&1; then
  if gh auth status >/dev/null 2>&1; then
    ok "gh (authenticated)"
  else
    echo "  [warn]    gh installed but not authenticated — run 'gh auth login' to enable GitHub repo creation"
  fi
else
  echo "  [warn]    gh not installed — GitHub repo creation will be skipped (use --no-github, or install gh)"
fi

echo ""
echo "Done. Try: create-claude-project --help  |  add-claude-scaffolding --help"
