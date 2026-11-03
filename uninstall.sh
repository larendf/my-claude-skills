#!/usr/bin/env bash
#
# uninstall.sh — remove symlinks this repo created in ~/.claude/{skills,agents,commands}
#
# Only removes symlinks that point back into this repo. Real files/directories and
# symlinks pointing elsewhere are left untouched. Backups made by `install.sh --force`
# are NOT restored automatically; they live in ~/.claude/backups/my-claude-skills.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_TARGET="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
AGENTS_TARGET="${CLAUDE_AGENTS_DIR:-$HOME/.claude/agents}"
COMMANDS_TARGET="${CLAUDE_COMMANDS_DIR:-$HOME/.claude/commands}"

removed=0

# unlink_item <name> <src> <target_dir>
unlink_item() {
  local name="$1" src="$2" dest="$3/$1"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    rm "$dest"; echo "  - removed $name"; removed=$((removed+1))
  fi
}

while IFS= read -r skill_md; do
  skill_dir="$(dirname "$skill_md")"
  unlink_item "$(basename "$skill_dir")" "$skill_dir" "$SKILLS_TARGET"
done < <(find "$REPO_DIR/skills" -name SKILL.md | sort)

for pair in "agents:$AGENTS_TARGET" "commands:$COMMANDS_TARGET"; do
  src_dir="$REPO_DIR/${pair%%:*}"; target_dir="${pair#*:}"
  [ -d "$src_dir" ] || continue
  while IFS= read -r f; do
    [ -n "$f" ] && unlink_item "$(basename "$f")" "$f" "$target_dir"
  done < <(find "$src_dir" -maxdepth 1 -name '*.md' ! -name 'README.md' | sort)
done

echo
echo "Done. removed=$removed"
