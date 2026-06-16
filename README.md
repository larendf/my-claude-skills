# my-claude-skills

My personal, combined collection of [Claude Code](https://claude.com/claude-code)
skills — the ones I authored plus vendored open-source skills I rely on, all in
one version-controlled place and installable with a single command.

## Install

Symlink every skill into `~/.claude/skills/` so edits here are live everywhere:

```bash
./install.sh            # symlink all skills (skips ones already linked)
./install.sh --dry-run  # preview, change nothing
./install.sh --force    # replace existing entries, even real directories
```

Remove the symlinks this repo created (leaves real dirs / foreign symlinks alone):

```bash
./uninstall.sh
```

Install to a custom location with `CLAUDE_SKILLS_DIR=/path ./install.sh`.

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
