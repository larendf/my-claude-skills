---
name: ui-component-review
description: Skeptical, severity-ranked review of a built UI component against its spec, the project's conventions and its own gates, with a hard check that every design value traces to a source. Use when reviewing a component or PR, or before signing off a component as done.
argument-hint: <component name or path>
---

# UI component review

You are the second pair of eyes. Be skeptical, cite everything (`file:line`), and report actual output, not assumptions.

Component: `$ARGUMENTS`

## Steps

1. **Spec check.** Find what the component was supposed to be: ticket, spec, contract, design brief (see `CLAUDE.md` / `AGENTS.md` for where). Verify every specified item exists in the build. Flag **Missing** items (highest severity) and **Extras** the spec never asked for.
2. **Conventions check.** Read the project's rules (`.claude/rules/`, `CLAUDE.md`, a nearby README) and check the diff against them: structure, naming, server/client boundary, mocks vs real data, no hand edits to generated files.
3. **Re-run the gates.** Read `package.json` and run the project's own lint, type-check, test and build scripts, plus any rendered-output or Storybook test. Paste real results. A gate you could not run is a finding, not a pass.
4. **Provenance check.** For every hardcoded design value in the diff (size, colour, opacity, offset, breakpoint step), find the source it traces to: a design node, a doc section or a recorded decision. Flag any value with **no citation**.
   - A value copied from a sibling component must cite that component's *source*, not the sibling.
   - Flag any breakpoint beyond those the design actually models.
5. **Oracle check.** Each kind of value has one authoritative source (typography, colour and size from the design file; structure and behaviour from the live site or spec; accessibility minimums from WCAG). If the project does not say which wins for what, ask. A value taken from the wrong source is a finding even when it looks right.
6. **Nothing invented.** Flag any value the diff introduces that no source states. The right output for an unsourced value is an open question with the measurement, not a designed answer. Be wary of a plausible rationale (a contrast ratio, a WCAG citation) attached to a value nobody specified.
7. **Accessibility basics.** Semantic elements, keyboard reach and focus visibility, names for controls and images, contrast. Use the `accessibility` skill for depth.
8. **Fidelity.** If a design reference exists, run `/design-fidelity-check` or confirm a recent receipt matches the current commit and tree.

## Output

Findings ranked by severity, each with `file:line` and a one-line fix:

- **Blocker**: spec violation, failed or unrun gate, hand-edited generated file, missing fidelity evidence
- **Major**: convention violation, untested logic, undocumented deviation from design, uncited value
- **Minor**: naming, docs, polish

End with an explicit verdict: **APPROVE** (every step passes) or **REQUEST CHANGES** (list exactly what must change). No APPROVE with any Blocker.
