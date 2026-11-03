---
name: record-mistake
description: Capture a mistake and the rule that prevents a repeat, as a blameless one-file-per-entry record (default docs/mistakes/). Use when something went wrong and you want future sessions or teammates to make it at most once.
argument-hint: <title> :: <what happened>
---

# Record a mistake

Capture a mistake so it is made at most once. Entries are read by future sessions, so write the prevention as a rule, not a story.

Input: `$ARGUMENTS`, as `<title> :: <note>`. If `::` is missing, the first line is the title and the rest is the note. If empty, ask for both.

## Steps

1. **Find the home.** Use the location the project's `CLAUDE.md` / `AGENTS.md` names for mistakes. Otherwise use `docs/mistakes/`. If that folder has a `README.md`, follow its entry format exactly. If not, use the default format below and offer to create the README.
2. **Create a NEW file** `<dir>/<YYYY-MM-DD>-<slug>.md` (today's date; slug = kebab-case of the title). One mistake per file. Never edit an existing entry.
3. **Fill the format:**
   ```
   # <title>

   **What happened:** <the facts, in order>
   **Root cause:** <why it was possible, not who did it>
   **Prevention:** <one line, written as a rule that stops the repeat>
   ```
   The Prevention line is what future sessions see first. Make it checkable: name the file, flag, command or gate.
4. **Blameless and safe.** Describe the mistake, not the person. No credentials, tokens or client-confidential specifics.
5. **Confirm** the path you wrote. If the same prevention keeps proving necessary, suggest `/promote-rule`.
