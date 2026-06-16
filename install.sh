#!/usr/bin/env bash
#
# install.sh — symlink every skill in this repo into ~/.claude/skills/
#
# Skills stay version-controlled here; edits are live everywhere because the
# target is a symlink, not a copy. Re-run any time you add a new skill.
#
# Usage:
#   ./install.sh            # symlink all skills (skips ones already linked here)
#   ./install.sh --force    # replace existing entries, even real directories
#   ./install.sh --dry-run  # print what would happen, change nothing

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$REPO_DIR/skills"
TARGET_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

FORCE=false
DRY_RUN=false
for arg in "$@"; do
  case "$arg" in
    --force)   FORCE=true ;;
    --dry-run) DRY_RUN=true ;;
    *) echo "unknown flag: $arg" >&2; exit 1 ;;
  esac
done

mkdir -p "$TARGET_DIR"

linked=0; skipped=0; replaced=0
while IFS= read -r skill_md; do
  skill_dir="$(dirname "$skill_md")"
  name="$(basename "$skill_dir")"
  dest="$TARGET_DIR/$name"

  if [ -L "$dest" ]; then
    current="$(readlink "$dest")"
    if [ "$current" = "$skill_dir" ]; then
      echo "  ✓ $name (already linked)"; skipped=$((skipped+1)); continue
    fi
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if ! $FORCE; then
      echo "  ⚠ $name exists at $dest — skipping (use --force to replace)"
      skipped=$((skipped+1)); continue
    fi
    $DRY_RUN || rm -rf "$dest"
    replaced=$((replaced+1))
  fi

  if $DRY_RUN; then
    echo "  → would link $name → $skill_dir"
  else
    ln -s "$skill_dir" "$dest"
    echo "  + linked $name"
  fi
  linked=$((linked+1))
done < <(find "$SKILLS_SRC" -name SKILL.md | sort)

echo
echo "Done. linked=$linked replaced=$replaced skipped=$skipped"
echo "Target: $TARGET_DIR"
$DRY_RUN && echo "(dry run — nothing changed)"
exit 0
