# my-claude-skills

My personal, combined collection of [Claude Code](https://claude.com/claude-code)
skills — the ones I authored plus vendored open-source skills I rely on, all in
one version-controlled place and installable with a single command.

## Install

Each skill is symlinked into your Claude skills directory so edits here are
live everywhere. Use the script for your platform.

### macOS / Linux

```bash
./install.sh            # symlink all skills (skips ones already linked)
./install.sh --dry-run  # preview, change nothing
./install.sh --force    # replace existing entries, even real directories

./uninstall.sh          # remove only the symlinks this repo created
```

Install to a custom location with `CLAUDE_SKILLS_DIR=/path ./install.sh`.

### Windows (PowerShell)

```powershell
.\install.ps1           # symlink all skills (skips ones already linked)
.\install.ps1 -DryRun   # preview, change nothing
.\install.ps1 -Force    # replace existing entries, even real directories

.\uninstall.ps1         # remove only the symlinks this repo created
```

Creating symlinks on Windows needs one of:

- **Developer Mode** — Settings → Privacy & security → For developers → turn on
  *Developer Mode* (no admin rights needed afterward), or
- an **elevated PowerShell** session (right-click → *Run as Administrator*).

If PowerShell blocks the script, allow it for the current session with
`Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`.

Install to a custom location with `$env:CLAUDE_SKILLS_DIR = 'D:\skills'` before
running the script.

> Using WSL or Git Bash on Windows? Use the macOS / Linux `./install.sh` instead.

Both platforms install the same skills — they only differ in how symlinks are
created. The target defaults to `~/.claude/skills` (`%USERPROFILE%\.claude\skills`
on Windows).

## What's inside

| Category        | Skills |
|-----------------|--------|
| `aem`           | aem-build-deploy, aem-component, aem-osgi-service, aem-react-component |
| `ai-agents`     | context-engineering, multi-agent-patterns, prompt-injection-defense, rag-retrieval |
| `devex`         | adr-writer, ci-cd, playwright-e2e, structural-search |
| `frontend`      | react-server-components, shadcn-ui, tailwind-v4, zustand-state |
| `fundamentals`  | accessibility, api-design, database-patterns, debugging, security-patterns, typescript-patterns |
| `personal`      | proposal-writer, task-prioritization |
| `prompting`     | promptify |
| `sitecore`      | sitecore-xmcloud |

The `aem/*` skills are mine and encode Tourism Australia conventions (multi-site
AEM 6.5, Sling Models, OSGi R6, the React feature pipeline, `build.sh`).

## Layout

```
skills/
  <category>/
    <skill-name>/
      SKILL.md        # required — frontmatter (name, description) + body
      ...             # optional references/, scripts/, examples/, etc.
```

`install.sh` discovers skills by finding every `SKILL.md`, so nesting depth and
new categories work automatically — just drop a folder under `skills/`.

## Attribution & license

MIT. The vendored skills are authored by Mikul Gohil and kept with their
original attribution — see [ATTRIBUTION.md](./ATTRIBUTION.md).
