---
name: research
description: Research a codebase topic by spawning parallel research agents, waiting for all results, and synthesizing findings into a structured document.
---

# /research

Run the `researching-codebase` skill. Spawn parallel research agents to investigate the topic, wait for all agents to complete, then synthesize findings into a structured research document.

## Usage

```
/research <topic or question>
```

## Examples

```
/research How does authentication work in this app?
/research What is the data flow for order processing?
/research How are background jobs scheduled and executed?
```

## What It Does

1. Decomposes the research question into sub-topics
2. Confirms the research plan with you
3. Spawns parallel agents to investigate each sub-topic
4. Waits for ALL agents to return before synthesizing
5. Produces a structured research document with `file:line` references
6. Asks if you have follow-up questions
