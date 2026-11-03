---
description: Run a UI component through plan check, build, parallel independent review, and a verification gate, with a bounded fix loop. Use for a new or changed component that should be reviewed by agents that did not write it.
argument-hint: <component name, path, or a one-line spec>
---

# Component pipeline

Target: `$ARGUMENTS`

You are the orchestrator. You plan, delegate, gate and report. Reviewers never see your reasoning, only the code and the brief. Do not commit or push.

## 0. Brief (the context contract)

Every sub-agent gets these three parts, and nothing else of your conversation. If you cannot fill one, ask the user before going on.

- **Main task:** what is being built and why (product, audience, where it lives).
- **Subtask:** the exact files or component this agent looks at.
- **Constraints:** cite the rule files and the spec and design-reference paths instead of paraphrasing them (`CLAUDE.md` / `AGENTS.md` / `.claude/rules/`), plus the accessibility tier and what is out of scope. A paraphrase carries your assumptions into the review.

Look for the spec and design reference now. If neither exists, say so: later stages can only check what was specified.

## 1. Plan check (only if a plan or spec document exists)

Delegate to the `plan-roaster` agent with the document path and the brief. Read its WEAK POINT and SCORE. If the score is 5 or below, stop and show the user before building.

## 2. Build

Implement in this session, following the project's own rules. Keep a list of the files you touch. Run the project's lint and type-check as you go.

## 3. Independent review (parallel)

In ONE message, launch both agents on the touched files, each with the brief and no verdict from you:

- `design-critic`: hierarchy, spacing, contrast, states, responsive, token use.
- `security-reviewer`: only if the component handles input, URLs, auth, data fetching or `dangerouslySetInnerHTML`. Otherwise skip it and say why.

## 4. Verification gate (not run by you)

You wrote the code, so you do not grade it. Launch a fresh `general-purpose` agent with the brief and the touched-files list, and tell it to run, in this order:

1. The `ui-component-review` skill on the component (spec, conventions, gates, provenance of values).
2. The `design-fidelity-check` skill, only if a design reference exists. If the reference, dev server or browser tooling is missing, fidelity is **unverified**, never passed.

Its verdict (APPROVE / REQUEST CHANGES, fidelity PASS / FAIL / unverified) is final. You may fix findings. You may not downgrade, reword or dismiss one.

## 5. Fix loop (at most 2 rounds)

Fix every Blocker and Critical finding. Then re-run, on the diff since the last round, every reviewer that raised something: `design-critic` and/or `security-reviewer` (fresh agents, same brief) and the stage 4 gate agent. A fix that nothing re-reviews is not a fix.

If you think a finding is wrong, do not dismiss it: put it in the report under **Disputed** for the user to decide. After round 2, stop and report what is still open.

## 6. Report

```
COMPONENT PIPELINE: <target>
Plan check:  <score or "no spec">
Build:       <files touched>
Reviews:     design-critic <n critical / n important>, security <n or "skipped: why">
Gate:        ui-component-review <APPROVE | REQUEST CHANGES>, fidelity <PASS | FAIL | unverified> (from the gate agent, unaltered)
Fix rounds:  <0-2>, re-reviewed by: <which agents>
Open items:  <anything unresolved, one line each>
Disputed:    <findings you disagree with and why, for the user to decide>
Note:        design-critic reads code only; contrast, responsive and state findings are not rendered checks
Not verified: <anything the pipeline could not check>
```

Say plainly what you could not verify. Leave all changes uncommitted for the user to review.
