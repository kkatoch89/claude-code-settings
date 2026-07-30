#!/usr/bin/env bash
# install.sh — dotfiles installer for claude-code-settings
#
# Called by the coder-emr workspace setup (Phase 2b) when this repo is used
# as the dotfiles_uri. Also safe to run manually on the laptop (no-ops the
# workspace-specific fixups when /opt/instinct doesn't exist).
set -euo pipefail

DEST="$HOME/.claude"
SRC="$(cd "$(dirname "$0")/.claude" && pwd)"

mkdir -p "$DEST"

# Copy everything from .claude/ into ~/.claude/
cp -a "$SRC/." "$DEST/"

# ---------------------------------------------------------------------------
# Workspace fixups — only applies inside a Coder EMR workspace
# (detected by the presence of /opt/instinct, the shared projects mount)
# ---------------------------------------------------------------------------
if [ -d /opt/instinct ]; then
  LAPTOP_PATH="/Users/karankatoch/instinct"
  WORKSPACE_PATH="/opt/instinct"

  # Rewrite the three skills/commands that save files to laptop paths
  for f in \
    "$DEST/commands/plan-doc.md" \
    "$DEST/skills/to-prd/SKILL.md" \
    "$DEST/skills/prd-to-plan/SKILL.md"; do
    [ -f "$f" ] && sed -i "s|$LAPTOP_PATH|$WORKSPACE_PATH|g" "$f"
  done

  # Remove Obsidian-dependent files — the vault doesn't exist in a workspace
  rm -f  "$DEST/commands/obsidian-note.md"
  rm -rf "$DEST/skills/lookup-obsidian"
fi
