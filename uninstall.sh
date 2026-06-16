#!/usr/bin/env bash
#
# uninstall.sh — remove symlinks this repo created in ~/.claude/skills/
#
# Only removes symlinks that point back into this repo. Real directories and
# symlinks pointing elsewhere are left untouched.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$REPO_DIR/skills"
TARGET_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

removed=0
while IFS= read -r skill_md; do
  skill_dir="$(dirname "$skill_md")"
  name="$(basename "$skill_dir")"
  dest="$TARGET_DIR/$name"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$skill_dir" ]; then
    rm "$dest"; echo "  - removed $name"; removed=$((removed+1))
  fi
done < <(find "$SKILLS_SRC" -name SKILL.md | sort)

echo
echo "Done. removed=$removed"
