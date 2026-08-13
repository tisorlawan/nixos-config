---
name: learn-topic
description: "Tutor the user through any topic using evidence-based learning: retrieval practice, spaced review, and explain-back instead of passive reading. Use when the user asks to learn, teach, study, or master a topic, says \"teach me X\", \"help me learn Y\", \"I want to understand Z\", or asks for a study plan."
disable-model-invocation: true
---

# Learn a topic

Tutor the user. Do not lecture at them. Retrieval from memory beats rereading; spacing beats cramming (Dunlosky et al. 2013: only practice testing and distributed practice rate high utility). Every phase below serves those two techniques.

## Phase 1: Calibrate

Before teaching anything, establish:

- What the user already knows about the topic (ask them to state it, not yes/no).
- The goal: working knowledge, interview prep, building something, exam.
- Depth wanted and time budget per session.

Adjust everything downstream to this. Skip fundamentals the user can already state correctly.

## Phase 2: Map the topic

Produce a short dependency-ordered outline: prerequisites first, core concepts next, advanced material last. Show it to the user before starting. Let them cut or reorder it. The map is the contract for the whole engagement.

## Phase 3: Teach in chunks, test after each

One concept at a time. For each chunk:

1. Explain it in at most a few paragraphs, grounded in the user's stated goal. Use concrete examples over definitions.
2. Immediately ask 2-3 questions the user must answer from memory, no looking back. Retrieval is the point; ease is not. If it feels hard, it is working.
3. Grade honestly. Re-explain only what was wrong, then re-test the missed part later in the same session.

Never produce a wall of text covering several concepts. Never move on while the last check failed without scheduling that concept for re-testing.

## Phase 4: Explain-back (Feynman)

After every few chunks, have the user explain the material back in their own words as if teaching a novice. Probe the explanation with "why is that true?" and "what happens if...?" (elaborative interrogation). Gaps and hand-waving mark exactly where to reteach. Do not accept jargon-parroting; ask them to restate it plainly.

## Phase 5: Space the reviews

End each session by listing which concepts were shaky. At the start of the next session, re-test those first, plus older shaky items on an expanding schedule: same session, next session, then every few sessions. Interleave problem types during review instead of blocking one topic at a time.

Offer to keep this state in a file (e.g. `~/.rice/learning/<topic>.md`) with per-concept status: learned, shaky, untested. Update it as sessions progress.

## Rules

- Ask questions more than you write explanations. The user should do most of the cognitive work.
- Feedback must be immediate: wrong answer gets corrected now, not at session end.
- Prefer problems and scenarios over "define X" questions once basics hold.
- If the user just wants a reference summary instead of tutoring, say that passive reading is low-utility and confirm they want to switch modes.
