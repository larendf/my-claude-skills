---
name: design-fidelity-check
description: Compare a built UI component against its design reference (Figma export or screenshot) at 375/1280/1440 and report measured deltas in px and hex, not impressions. Use when verifying a component matches its design before sign-off or PR.
argument-hint: <component name or path>
---

# Design fidelity check

The rendered, computed result is the truth. Never sign off from a static read of the code.

Component: `$ARGUMENTS`

## Needs

A design reference, a runnable dev server or Storybook, and Playwright (or another headless browser). If any of these is missing, do not guess: report the check as **UNVERIFIED** and name what is missing. Never report PASS from a static read.

## Steps

1. **Find the reference.** Look in the project's `CLAUDE.md` / `AGENTS.md` for where design references live (Figma node, exported PNG, a brief JSON). If a Figma connector is available, use it for resolved values. If there is no reference, stop and ask. Do not compare against memory.
2. **Render the build.** Start the project's own dev server or Storybook. Capture the component with Playwright at **375 / 1280 / 1440** (use the breakpoints the design actually models if the project says otherwise).
3. **Compare per viewport.** For every suspected mismatch, read the computed styles from the running page (font-size, line-height, color, spacing, radius, transitions) and compare against the reference's resolved values. Report **measured deltas** (px, hex).
4. **Report** findings ranked by severity per viewport:
   - **Blocker**: wrong structure, missing element, unreadable text
   - **Major**: spacing, size or color off by a visible margin; wrong breakpoint behavior
   - **Minor**: sub-pixel drift, small radius or tracking differences

   Include the capture paths so a human can eyeball them.
5. **Baselines.** Do not generate CI visual-regression baselines from this machine. If this check should become a standing test, hand off to the project's baseline flow.

For a full review that also covers conventions, tests and provenance of values, use `/ui-component-review`.
