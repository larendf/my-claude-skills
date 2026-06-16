---
name: confluence-formatter
description: Convert a Markdown file or code into Confluence Cloud paste-ready Markdown that auto-formats on paste — section emoji, colored status circles, callout blockquotes, syntax-highlighted code, and clean tables. Use when turning a README, doc, notes, or code into a nicely styled Confluence page.
author: Laren Dela Fuente
version: 1.0.0
license: MIT
tags: [confluence, markdown, documentation, formatting, atlassian]
allowed-tools: [Read, Glob, Grep]
---

# Confluence formatter

Turn a Markdown file, doc, or code into **Confluence Cloud paste-ready Markdown**:
the user copies the output, pastes it into a Confluence Cloud page, and the editor
auto-converts it into a clean, colorful, well-structured page — first try, no manual
re-formatting of structure.

## How Confluence Cloud markdown paste works

When you paste Markdown-looking text into a Confluence **Cloud** page, the editor
auto-converts it to rich text. **What converts vs. what does not** is the whole game —
optimize for the first column, and use the workarounds for the second.

| ✅ Converts on paste (use freely) | ⚠️ Does NOT survive paste (workaround needed) |
|---|---|
| Headings `#`–`######` | Colored panels (info/note/warning) → use emoji blockquote, or `/info` after paste |
| **Bold**, *italic*, ~~strike~~, `inline code` | Status lozenges (Green DONE) → use colored circle emoji, or `/status` after paste |
| Fenced code blocks ```` ```lang ```` (syntax highlighted) | Table cell / row background colors → tint cells in editor after paste |
| Pipe tables (styled header row) | Text color → set in editor after paste |
| Bullet / numbered / nested lists | Embedded images → use a link, or attach + insert after paste |
| Task lists `- [ ]` → action items | |
| Blockquotes `>`, dividers `---`, links | |
| Unicode emoji 🚀 ✅ ⚠️ (always render) | |

**Golden rule:** deliver color with **Unicode emoji** (they paste perfectly), not with
panel/lozenge/cell-color macros (they don't). Reserve the macros for the optional
post-paste touch-up.

## Procedure

1. **Read the source.** If given a file path, read it. If given code, treat the code as
   the content to document/showcase. Ask for the file/content only if none was provided.
2. **Detect the intent** — release notes, runbook, design doc, status update, API doc,
   meeting notes — and structure accordingly. Don't invent content; reshape what's there.
3. **Convert** using the rules below.
4. **Deliver** the result in a single fenced code block (so the user copies the raw
   Markdown, not rendered text), followed by a short **post-paste touch-up** checklist for
   any color the paste can't carry.

## Conversion rules

### Headings & sections
- One `#` H1 title at top. Use `##`/`###` for sections.
- Lead each major section heading with one relevant emoji for scannability:
  `## 🚀 Deployment`, `## 🐛 Known issues`, `## ✅ Acceptance criteria`.
- Insert a `---` divider between top-level sections.

### Status & color via emoji (paste-safe)
Use colored circles as inline "badges" — they read like Confluence status lozenges and
survive paste perfectly:

| Meaning | Emoji | Meaning | Emoji |
|---|---|---|---|
| Done / pass / go | 🟢 | Blocked / fail / stop | 🔴 |
| In progress / warn | 🟡 | Info / planned | 🔵 |
| Not started / N/A | ⚪ | Note / neutral | ⚫ |

Example in a table cell: `🟢 Done`, `🔴 Blocked`, `🟡 In review`.

### Callouts (panels)
Confluence has no Markdown for colored panels, so emit an **emoji blockquote** — it paks
the visual cue and survives paste. Map by emoji:

```
> ℹ️ **Info** — neutral context the reader should know.
> ✅ **Success** — confirmation that something is done/correct.
> ⚠️ **Warning** — risk, gotcha, or breaking change.
> 🛑 **Danger** — do-not-do / destructive action.
> 💡 **Tip** — optional helpful shortcut.
> 📌 **Note** — something to remember.
```

(For a *real* colored panel, the user converts the blockquote with `/info`, `/note`,
`/warning`, `/success` after paste — list this in the touch-up checklist.)

### Tables
- Always include a header row (Confluence styles it automatically).
- Put status circles in cells for visual color instead of cell background colors.
- Keep cell content short; move prose into the surrounding text.
- Left-align by default; only specify alignment when it aids readability.

### Code
- Fenced blocks with an explicit language tag so Confluence applies syntax highlighting:
  ```` ```java ````, ```` ```bash ````, ```` ```json ````.
- Use inline `code` for identifiers, paths, commands, flags.

### Lists & tasks
- `- [ ]` / `- [x]` become Confluence action items — use for checklists and acceptance criteria.
- Keep nesting ≤ 2 levels; deep nesting reads poorly after conversion.

### Emoji style
- Prefer **Unicode** emoji (🚀 ✅ ⚠️ 🟢) — they paste reliably from any source.
- `:shortcode:` emoji also work but are less reliable on paste; only use when typed directly in the editor.
- One emoji per heading; don't pepper body text.

## Output format

Return exactly this shape:

1. A single fenced code block containing the full converted Markdown (the thing to copy).
2. **📋 Post-paste touch-up** — a short bullet list, only for color the paste can't carry,
   e.g.:
   - Convert the ⚠️ / ℹ️ blockquotes to colored panels: select the quote → `/warning`, `/info`.
   - Turn 🟢/🔴 circles into real status lozenges if preferred: `/status`.
   - Tint table header/cells: select cells → cell background color.

Keep the touch-up list to only what's actually present in the output. If the page is pure
structure + emoji with nothing to upgrade, say "Paste and you're done — no touch-up needed."

## Quick example

Source (Markdown):
```markdown
# Payments service v2.3
## Changes
- Added refund endpoint (done)
- Migrated to Postgres (in progress)
Warning: the old /v1/refund route is removed.
```

Converted (paste-ready) output:
```markdown
# 💳 Payments service v2.3

---

## 🚀 Changes

| Change | Status |
|--------|--------|
| Added `POST /v2/refund` endpoint | 🟢 Done |
| Migrate datastore to Postgres | 🟡 In progress |

> ⚠️ **Warning** — the old `GET /v1/refund` route is **removed**. Update callers before deploy.
```

**📋 Post-paste touch-up:** convert the ⚠️ blockquote to a warning panel (`/warning`); optionally swap 🟢/🟡 for real status lozenges (`/status`).
</content>
