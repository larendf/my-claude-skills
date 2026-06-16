# Tool Routing Reference

Per-tool optimization rules. Read only the family you're targeting — never load the whole
file at once. Model behaviour moves fast; treat version-specific notes as "true when written"
and confirm a named version with the user when it matters.

---

## Standard chat LLMs

These follow instructions and benefit from explicit structure, role, format, and length.
Chain-of-thought *helps* here on logic/math/debugging tasks.

### Claude (Opus, Sonnet, Haiku, Fable — 4.x family)

- Assume the current default is **Opus 4.8** unless the user names a version. Other current
  ids: Fable 5, Sonnet 4.6, Haiku 4.5.
- **Be explicit and literal.** Claude 4.x does exactly what you say — no more. Missing
  context yields a narrow literal answer, not a smart guess. Spell out intent, scope, and
  acceptance criteria.
- **Counter over-engineering.** Opus 4.x tends to add unrequested features/refactors. Add:
  "Only make the changes requested. Do not add features, abstractions, or refactors beyond
  what was asked."
- **XML tags** organize multi-section prompts well: `<context>`, `<task>`, `<constraints>`,
  `<output_format>`.
- **Explain the why, not only the what** — Claude generalizes better from reasoning.
- **State output format and length explicitly** every time.
- **Front-load complex tasks** into the first turn — intent, constraints, criteria, relevant
  files. Each extra round-trip adds cost.
- **Do not hardcode thinking depth.** Opus 4.x calibrates adaptively. To nudge: "Think
  carefully before responding" (deeper) or "Prioritize a fast response" (shallower). Don't
  add "think step by step" as a fixed instruction.

### GPT-5.x / OpenAI GPT models

- Start with the **smallest prompt that achieves the goal**; add structure only as needed.
- Make the **output contract explicit** — format, length, and what "done" looks like.
- State **tool-use expectations** if the model has tools available.
- Handles **dense, compact instructions** well; constrain verbosity when needed
  ("Under 150 words. No preamble. No caveats.").
- Strong at long-context synthesis and tone adherence — lean on these.

### Gemini (2.x / 3 Pro)

- Excellent **long-context and multimodal** — good for document-heavy prompts.
- **Guard citations:** "Cite only sources you are certain of. Mark anything uncertain as
  [uncertain]. Do not fabricate references."
- Can **drift from strict formats** — lock the format with a labelled example.
- For grounded work: "Base your response only on the provided context. Do not extrapolate."

### Qwen-instruct (2.5 and Qwen3 non-thinking mode)

- Strong **instruction following and structured/JSON output** — give explicit schemas.
- Define a **clear role** in a system prompt; Qwen responds well to role context.
- Keep prompts **focused** — short and scoped beats long and nested.

### Llama / Mistral / open-weight instruct models

- **Shorter, flatter prompts** work better — they lose coherence with deep nesting.
- Be **more explicit** than with Claude/GPT; instruction following is weaker.
- Always include a **role** in the system prompt.
- For local runs, set temperature ~0.1 for deterministic/coding work, ~0.7–0.8 for creative.
  If the user runs these locally (e.g. Ollama), ask which model and surface the system prompt
  so they can set it in their config.

---

## Reasoning-native models

o-series (e.g. o3, o4-mini), DeepSeek-R1, Qwen3 in thinking mode. These reason across many
internal tokens before answering.

- **SHORT, clean instructions only.** State the goal and the desired output. Nothing more.
- **NEVER add chain-of-thought, "think step by step", or reasoning scaffolding** — it
  actively degrades these models.
- **Prefer zero-shot;** add few-shot only if strictly needed and tightly aligned.
- Keep any system prompt brief — long preambles hurt reasoning-model performance.
- Some emit reasoning in `<think>` tags; add "Output only the final answer, no reasoning" if
  the user wants it suppressed.

---

## Agentic coding tools

These run tools, edit files, and execute commands. The structure that prevents runaway cost
is: **starting state → target state → allowed actions → forbidden actions → stop
conditions → checkpoints.**

### Claude Code

- Default model Opus 4.8 (literal; front-load everything). Effort/thinking is managed by the
  harness — **do not hardcode an effort level or thinking budget.**
- **Scope to specific files/directories** — never a global instruction without a path anchor.
  ("Read every file in `src/auth/` before starting.")
- **Stop conditions are mandatory** — they're the biggest cost control.
- Add **human-review triggers:** "Stop and ask before deleting any file, adding a dependency,
  or changing the database schema."
- It uses fewer tool calls / subagents by default — request them explicitly when wanted.
- Counter over-engineering: "Only the change requested. No extra files, abstractions, or
  features."
- Session hygiene: new task → new session; compact around mid-context, not at the limit.

### Cursor / Windsurf / Cline (IDE agents)

- Give: **file path + function name + current behaviour + desired change + do-not-touch
  list + language/version.**
- Never a global instruction without a file anchor.
- A **"Done when:"** clause is required — it defines when the agent stops editing.
- For approval-capable agents (Cline), add "Ask before running terminal commands / installing
  dependencies."
- For complex work, split into **sequential prompts** rather than one giant prompt.

### GitHub Copilot

- Write the exact **function signature, docstring, or comment** right before invoking.
- Describe input types, return type, edge cases, and what the function must **not** do.
- It completes what it predicts — leave no ambiguity in the comment.

### Devin / autonomous SWE agents

- Very explicit **start state + target state**; the **forbidden-actions list is critical** —
  it will make decisions you didn't intend without it.
- **Scope the filesystem:** "Work only within `src/`. Do not touch infra, config, or CI."

---

## App / UI generators (v0, Bolt, Lovable, Figma Make)

- These default to **bloated boilerplate** — scope down explicitly.
- Always specify: **stack, version, what NOT to scaffold, component boundaries.**
- Add: "Do not add auth, dark mode, or any feature not explicitly listed."
- Lovable responds to design-forward, UX-intent descriptions; v0 is Next.js-native (say so if
  you need otherwise); Bolt handles full-stack — be clear which parts are FE/BE/DB; Figma Make
  is design-to-code — reference your Figma component names directly.

---

## Image generation

First detect: **generate from scratch** vs **edit an existing image** (see next section).

- **Midjourney:** comma-separated descriptors, not prose. Subject first, then style, mood,
  lighting, composition. Parameters at the end: `--ar 16:9 --v 6 --style raw`. Exclude with
  `--no [unwanted]`.
- **DALL·E:** prose works. Describe foreground / midground / background separately for complex
  scenes. Add "no text in the image unless specified."
- **Stable Diffusion:** `(token:weight)` emphasis, CFG ~7–12, steps ~20–30 draft / 40–50
  final. **Negative prompt is mandatory.**
- **Flux:** responds well to natural-language descriptions with concrete detail; lighter on
  weight syntax than SD. Be specific about composition and lighting.
- **SeeDream:** strong at stylized/artistic output — name the art style (anime, cinematic,
  painterly) before scene content; mood/atmosphere descriptors land well; negative prompt
  recommended.

---

## Image editing (existing reference image)

Triggered when the user wants to change / edit / modify / adjust an existing image, or
uploads a reference.

- Instruct the user to **attach the reference image** to the tool first.
- Build the prompt around the **delta only** — what changes and what must stay identical.
  ("Keep the subject, pose, and background unchanged. Change only the jacket color to deep
  burgundy.")

---

## Video (Sora, Veo, Runway, Kling, Luma)

- **Direct it like a film shot.** Camera movement is decisive — static vs dolly vs crane
  changes everything. Specify shot type, angle, lens, lighting, and motion intensity.
- Sora / Veo: cinematic, prompt-sensitive — describe the scene as a director would.
- Runway: responds to cinematic-style references for consistent aesthetic.
- Kling: strong realistic human motion — describe body movement explicitly.
- Luma (Dream Machine): cinematic — reference lighting setups, lens, and color grading.
- Keep descriptions concise and visual; specify resolution and aspect ratio.

---

## 3D (Meshy, Tripo, Rodin)

- Describe: **style keyword** (low-poly / realistic / stylized) + **subject** + key features +
  **primary material** + texture detail + technical spec.
- Use the **negative prompt:** "no background, no base, no floating parts."
- Specify the **export target:** game engine (GLB/FBX), 3D printing (STL), web (GLB).
- For riggable characters, specify A-pose or T-pose.
- Meshy → game assets; Tripo → fast clean topology / prototyping; Rodin → highest-quality
  photoreal (slower, pricier).

---

## Voice (ElevenLabs)

- Specify **emotion, pacing, emphasis, and speech rate directly** — prose descriptions don't
  translate.
- Mark which words to stress and where to pause.

---

## Automation / workflow (Zapier, Make, n8n)

- Structure: **trigger app + trigger event → action app + action + field mapping**, step by
  step.
- Note auth assumptions explicitly ("assumes `[app]` is already connected").
- For multi-step flows, number each step and specify what data passes between them.

---

## Research / browser agents (Perplexity, computer-use agents)

- Describe the **end deliverable / outcome, not the navigation steps** — these orchestrators
  decompose internally.
- Specify the **output artifact** (report / table / summary / code).
- Add **citation and confidence requirements:** "Flag any data point you're not confident
  about. Cite sources."
- For agents that control a real browser, add **permission boundaries and a stop condition
  for irreversible actions:** "Research only — do not purchase. Ask before submitting any
  form or completing any transaction."
