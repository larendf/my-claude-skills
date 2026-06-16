# my-claude-skills

My personal, combined collection of [Claude Code](https://claude.com/claude-code)
skills — the ones I authored plus vendored open-source skills I rely on, all in
one version-controlled place and installable with a single command.

A **skill** is a folder with a `SKILL.md` that teaches Claude Code a focused
capability (e.g. *"write an Architecture Decision Record"* or *"build an AEM
component the Tourism Australia way"*). Once installed, Claude pulls the right
skill into context automatically when your task matches it.

## Quick start

```bash
git clone <this-repo> my-claude-skills
cd my-claude-skills
./install.sh            # symlink every skill into ~/.claude/skills
```

Then, in any Claude Code session:

1. **Just describe your task** — Claude auto-activates a matching skill.
   *"Help me write an ADR for switching to Postgres"* → the `adr-writer` skill loads.
2. **Or invoke one explicitly** by name: type `/adr-writer` in the prompt.
3. Not sure what's available? Type `/` to browse, or skim the [catalog](#skills-catalog) below.

> Skills are **symlinked**, not copied — edit a `SKILL.md` here and the change is
> live in every session immediately. No reinstall needed.

### Verify it worked

```bash
ls -la ~/.claude/skills        # each entry should be a symlink → this repo
./install.sh --dry-run         # re-run anytime to see what's linked vs missing
```

## How skills work

- **Discovery is automatic.** Each `SKILL.md` has a `description` in its
  frontmatter. Claude reads those descriptions and loads a skill only when your
  request matches — so having 25 skills installed costs nothing until one is relevant.
- **Write good descriptions = better activation.** The `description` is the
  trigger. The clearest ones say *what the skill does* **and** *when to use it*
  (most descriptions below end with a "Use when…" clause). If a skill never fires
  when you expect it to, tighten its description first.
- **Explicit beats implicit.** When you want a specific skill, name it with
  `/<skill-name>` rather than hoping the description matches.

## Skills catalog

Grouped by category. The **When to reach for it** column is the short version of
each skill's trigger.

### `aem` — Tourism Australia AEM platform (mine)

| Skill | When to reach for it |
|-------|----------------------|
| `aem-build-deploy`   | Building/deploying any module, or troubleshooting a build (`build.sh`, Maven profiles, local `localhost:4502`). |
| `aem-component`      | Creating or editing an AEM component, dialog, or Sling Model across the four sites. |
| `aem-osgi-service`   | Writing a backend OSGi service, servlet, scheduler, workflow process, or event listener in a `core/` module. |
| `aem-react-component`| Adding or editing a React feature that mounts inside an AEM component (the `tourismaustralia-react` pipeline). |

### `ai-agents` — building agent systems

| Skill | When to reach for it |
|-------|----------------------|
| `context-engineering`     | Writing or tuning commands, skills, and sub-agent prompts; managing the context window. |
| `multi-agent-patterns`    | A task exceeds one agent's context or splits into specialized subtasks. |
| `prompt-injection-defense`| Vetting external `CLAUDE.md`/`SKILL.md`/MCP descriptions or sanitizing fetched/issue content before it enters context. |
| `rag-retrieval`           | Building or tuning a RAG pipeline (chunking, hybrid search, reranking, pgvector). |

### `devex` — developer experience

| Skill | When to reach for it |
|-------|----------------------|
| `adr-writer`         | Recording a significant technical decision (Nygard-format ADR). |
| `ci-cd`              | Writing or improving a GitHub Actions pipeline. |
| `confluence-formatter`| Turning a Markdown file or code into Confluence Cloud paste-ready, nicely styled Markdown (emoji, status circles, callouts, tables). |
| `playwright-e2e`   | Writing, structuring, or debugging Playwright E2E tests. |
| `structural-search`| Precise, codebase-wide refactors by AST structure (needs the `ast-grep`/`sg` CLI). |

### `frontend`

| Skill | When to reach for it |
|-------|----------------------|
| `react-server-components`| Server-first React in Next.js 16 App Router; server vs client decisions; hydration bugs. |
| `shadcn-ui`              | Adding/customizing shadcn/ui components in a React project. |
| `tailwind-v4`            | Styling with Tailwind v4 or migrating a v3 config. |
| `zustand-state`          | Adding or refactoring client state with Zustand 5.x. |

### `fundamentals`

| Skill | When to reach for it |
|-------|----------------------|
| `accessibility`     | Building or auditing any web UI against WCAG 2.2. |
| `api-design`        | Designing or reviewing a REST/GraphQL API surface. |
| `database-patterns` | Designing schemas or evolving a database with safe migrations. |
| `debugging`         | Tracking down a bug of unknown cause (leaks, races, deadlocks, crashes). |
| `security-patterns` | Handling auth, untrusted input, or sensitive data (OWASP Top 10, secrets, PII). |
| `typescript-patterns`| Modeling types, tightening strictness, or untangling complex generics. |

### `personal`

| Skill | When to reach for it |
|-------|----------------------|
| `proposal-writer`     | Drafting client proposals, quotes, scopes of work, or engagement letters. |
| `task-prioritization` | Ranking features or justifying roadmap order (RICE, WSJF, ICE, MoSCoW). |

### `prompting` / `sitecore`

| Skill | When to reach for it |
|-------|----------------------|
| `promptify`        | Writing, fixing, or optimizing a prompt for a specific AI tool. |
| `sitecore-xmcloud` | Sitecore XM Cloud / JSS work — auto-invoked in Sitecore projects. |

The `aem/*` skills are mine and encode Tourism Australia conventions (multi-site
AEM 6.5, Sling Models, OSGi R6, the React feature pipeline, `build.sh`).

## Install reference

Each skill is symlinked into your Claude skills directory so edits here are live
everywhere. Use the script for your platform.

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

## Add your own skill

1. Create `skills/<category>/<skill-name>/SKILL.md`.
2. Give it frontmatter — `name` (kebab-case, matches the folder) and a
   `description` that says *what it does* and *when to use it*:

   ```markdown
   ---
   name: my-skill
   description: One line on what this does. Use when <the trigger situation>.
   ---

   # My skill

   Body: the guidance, patterns, and examples Claude should follow.
   ```

3. Run `./install.sh` to symlink the new skill (existing links are skipped).
4. Start a fresh Claude Code session and confirm it activates — describe a task
   that matches the description, or invoke `/my-skill` directly.

Keep `SKILL.md` focused; push long references, scripts, or examples into
sibling folders (`references/`, `scripts/`, `examples/`) so the main file stays lean.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Skill doesn't activate automatically | Sharpen its `description` (add a clear "Use when…" trigger), or invoke it explicitly with `/<skill-name>`. |
| Changes to a `SKILL.md` aren't picked up | Start a new Claude Code session — skills are read at session start. |
| `install.sh` skipped a skill | A real directory already exists at the target. Re-run with `--force` to replace it. |
| Symlink fails on Windows | Enable **Developer Mode** or run PowerShell **as Administrator** (see above). |
| Want to undo everything | `./uninstall.sh` removes only the symlinks this repo created — your other skills are untouched. |

## Attribution & license

MIT. The vendored skills are authored by Mikul Gohil and kept with their
original attribution — see [ATTRIBUTION.md](./ATTRIBUTION.md).
</content>
</invoke>
