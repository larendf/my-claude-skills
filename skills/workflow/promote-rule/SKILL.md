---
name: promote-rule
description: Promote a proven learning or mistake-prevention into a checked-in project rule, with a human approval gate. Use when the same lesson keeps recurring and should change how every agent and developer in the repo behaves.
argument-hint: <the rule to propose, or a learning/mistake file path>
---

# Promote a learning into a rule

Rules change how every developer's agent behaves, so this is **human-gated**: draft, show, wait, then write.

Input: `$ARGUMENTS` (a rule statement, or the path of a learning/mistake entry to promote).

## Steps

1. **Find the target.** Prefer a fitting file in `.claude/rules/`. If the project has none, use the relevant section of `CLAUDE.md`. If nothing fits, propose the smallest new rule file that does.
2. **Draft the exact addition:** where it goes, the precise wording, and one line on why, citing the entries that motivated it. Prefer a checkable rule ("run X before Y") over an aspiration ("be careful with Y").
3. **Show it as a diff and WAIT for explicit approval.** Do not write before the user says yes.
4. **On approval,** apply the edit and tell the user to call out the rule change in the PR description. Rule changes get named in review, never slipped in.
5. **Keep the history.** If the rule supersedes an entry, leave the entry in place and reference the rule from it.
