---
name: record-learning
description: Capture a verified engineering learning as a one-file-per-entry record (default docs/learnings/). Use when a session turned up a non-obvious fact, constraint or technique that future sessions or teammates should start with.
argument-hint: <title> :: <the learning>
---

# Record a learning

Capture a verified learning so the next session starts with it.

Input: `$ARGUMENTS`, as `<title> :: <note>`. If `::` is missing, the first line is the title and the rest is the note. If empty, ask for both.

## Steps

1. **Find the home.** Use the location the project's `CLAUDE.md` / `AGENTS.md` names for learnings. Otherwise use `docs/learnings/`. If that folder has a `README.md`, follow its entry format exactly. If not, use the default format below and offer to create the README.
2. **Create a NEW file** `<dir>/<YYYY-MM-DD>-<slug>.md` (today's date; slug = kebab-case of the title). One learning per file. Never edit an existing entry.
3. **Fill the format:**
   ```
   # <title>

   **Context:** <where and when this came up>
   **Learning:** <the verified fact>
   **Apply:** <one line, actionable: name the file, flag or command>
   ```
4. **Verified facts only.** If you did not confirm it by running or reading it, say so or leave it out. No credentials or client-confidential specifics.
5. **Confirm** the path you wrote and remind the user the entry ships with the current branch. If a learning has proven out repeatedly, suggest `/promote-rule`.
