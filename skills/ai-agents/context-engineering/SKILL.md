---
name: context-engineering
description: Understand and optimize how context is structured in agent systems — the components, mechanics, and constraints of an agent's context window. Use when writing or tuning commands, skills, and sub-agent prompts, diagnosing context degradation (lost-in-middle, poisoning, distraction), verifying multi-agent output, or deciding what to compact, mask or partition.
author: Mikul Gohil
version: 1.0.0
license: MIT
tags: [ai, agents, context, prompt-engineering]
---

# Context Engineering

Context is everything the model can attend to when it answers: system instructions, tool definitions, retrieved documents, message history and tool outputs. It is a finite budget with diminishing returns. The job is to curate the **smallest high-signal set of tokens** that gets the outcome.

This file is the hub. Read only the reference that matches the task; each is self-contained.

## Which reference to read

| If you are... | Read |
|---|---|
| Learning what context is made of, or writing a skill, command or system prompt (progressive disclosure, descriptions, section structure) | [references/fundamentals.md](references/fundamentals.md) |
| Diagnosing a failure that gets worse in long sessions (lost-in-middle, context poisoning, distraction, confusion, clash) | [references/degradation-patterns.md](references/degradation-patterns.md) |
| Building a multi-agent command or pipeline and need to verify its output: hallucination detection, lost-in-middle tests, error propagation, relevance scoring, health monitoring | [references/multi-agent-verification-workflows.md](references/multi-agent-verification-workflows.md) |
| Running out of room and need to compact, mask observations, use the KV-cache well, or partition work across isolated contexts | [references/optimization-techniques.md](references/optimization-techniques.md) |

## Rules that hold everywhere

1. Treat context as a finite resource with diminishing returns.
2. Put critical information at the attention-favored positions, the beginning and the end.
3. Use progressive disclosure: load detail only when the task needs it.
4. Give system prompts and skills clear section boundaries.
5. Compact at roughly 70-80% utilization, not at the limit.
6. Design for degradation instead of hoping to avoid it.
7. Prefer smaller high-signal context over larger low-signal context.
8. Hand sub-agents a minimal, explicit brief, not the whole conversation.
