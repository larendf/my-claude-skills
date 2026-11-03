#!/usr/bin/env bash
#
# install.sh — symlink every skill, agent and command in this repo into ~/.claude/
#
#   skills/**/SKILL.md   →  ~/.claude/skills/<name>        (one link per skill folder)
#   agents/*.md          →  ~/.claude/agents/<name>.md     (one link per agent file)
#   commands/*.md        →  ~/.claude/commands/<name>.md   (one link per command file)
#
# Everything stays version-controlled here; edits are live everywhere because the
# target is a symlink, not a copy. Re-run any time you add something new.
#
# Usage:
#   ./install.sh            # symlink everything (skips entries already linked here)
#   ./install.sh --force    # replace existing LINKS that point elsewhere (real files/folders are skipped)
#   ./install.sh --replace-real  # as --force, and also back up and replace real files/folders
#   ./install.sh --dry-run  # print what would happen, change nothing (combine with the flags above)
#
# Override targets with CLAUDE_SKILLS_DIR, CLAUDE_AGENTS_DIR, CLAUDE_COMMANDS_DIR.
# Backups from --force go to CLAUDE_BACKUP_DIR (default ~/.claude/backups/my-claude-skills).

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_TARGET="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
AGENTS_TARGET="${CLAUDE_AGENTS_DIR:-$HOME/.claude/agents}"
COMMANDS_TARGET="${CLAUDE_COMMANDS_DIR:-$HOME/.claude/commands}"
BACKUP_DIR="${CLAUDE_BACKUP_DIR:-$HOME/.claude/backups/my-claude-skills}"
STAMP="$(date +%Y%m%d-%H%M%S)"

FORCE=false
REPLACE_REAL=false
DRY_RUN=false
for arg in "$@"; do
  case "$arg" in
    --force)        FORCE=true ;;
    --replace-real) FORCE=true; REPLACE_REAL=true ;;
    --dry-run)      DRY_RUN=true ;;
    *) echo "unknown flag: $arg" >&2; exit 1 ;;
  esac
done

linked=0; skipped=0; replaced=0

# link_item <kind> <name> <src> <target_dir>
link_item() {
  local kind="$1" name="$2" src="$3" target_dir="$4"
  local dest="$target_dir/$name"

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "  ✓ $name (already linked)"; skipped=$((skipped+1)); return
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    local what
    if [ -L "$dest" ]; then what="a link to $(readlink "$dest")"; else what="a real file/folder"; fi
    if ! $FORCE; then
      echo "  ⚠ $name is $what — skipping (use --force to replace)"
      skipped=$((skipped+1)); return
    fi
    if [ ! -L "$dest" ] && ! $REPLACE_REAL; then
      echo "  ⚠ $name is $what — skipping (--force only replaces links; add --replace-real to back it up and replace it)"
      skipped=$((skipped+1)); return
    fi
    if $DRY_RUN; then
      echo "  ↻ would replace $name ($what)"
    elif [ -L "$dest" ]; then
      rm "$dest"
    else
      mkdir -p "$BACKUP_DIR/$kind"
      mv "$dest" "$BACKUP_DIR/$kind/$name.$STAMP"
      echo "  ↻ backed up real $name → $BACKUP_DIR/$kind/$name.$STAMP"
    fi
    replaced=$((replaced+1))
  fi

  if $DRY_RUN; then
    echo "  → would link $name → $src"
  else
    ln -s "$src" "$dest"
    echo "  + linked $name"
  fi
  linked=$((linked+1))
}

$DRY_RUN || mkdir -p "$SKILLS_TARGET"
echo "skills → $SKILLS_TARGET"
while IFS= read -r skill_md; do
  skill_dir="$(dirname "$skill_md")"
  link_item skills "$(basename "$skill_dir")" "$skill_dir" "$SKILLS_TARGET"
done < <(find "$REPO_DIR/skills" -name SKILL.md | sort)

install_files() {  # install_files <kind> <src_dir> <target_dir>
  local kind="$1" src_dir="$2" target_dir="$3"
  [ -d "$src_dir" ] || return 0
  local files
  files="$(find "$src_dir" -maxdepth 1 -name '*.md' ! -name 'README.md' | sort)"
  [ -n "$files" ] || return 0
  echo
  echo "$kind → $target_dir"
  $DRY_RUN || mkdir -p "$target_dir"
  while IFS= read -r f; do
    link_item "$kind" "$(basename "$f")" "$f" "$target_dir"
  done <<< "$files"
}
install_files agents   "$REPO_DIR/agents"   "$AGENTS_TARGET"
install_files commands "$REPO_DIR/commands" "$COMMANDS_TARGET"

echo
echo "Done. linked=$linked replaced=$replaced skipped=$skipped"
$DRY_RUN && echo "(dry run — nothing changed)"
exit 0
