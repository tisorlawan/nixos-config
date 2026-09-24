---
name: unslop
description: "Rewrite text to remove AI writing tells and add a human voice. Explicit invocation only: run /unslop on a draft, file, commit message, or reply."
disable-model-invocation: true
---

# Unslop

Edit text to remove AI patterns. Preserve the meaning and the intended tone.

## Process

1. Read the target. Use the file, the pasted text, or the last reply. If the text already has none of the patterns below, say so and change nothing.
2. Scan for the patterns below. The reference files hold the full phrase lists, structure tables, and before/after examples.
3. Rewrite. Do not touch code, quotations, identifiers, or exact error strings. For a file, edit it in place. Otherwise return the rewritten text.
4. Audit the result against "Score the result". Revise once more if it scores below 35.
5. End with one line: the final score and the patterns you removed most.

Removing patterns is half the job. Voiceless, uniform text reads as machine-written too, so also apply "Voice".

## Patterns to detect and fix

Full lists: [references/phrases.md](references/phrases.md) and [references/structures.md](references/structures.md).

### Content

1. **Superficial -ing phrases.** "highlighting...", "ensuring...", "reflecting...", "showcasing...", "fostering...". Delete them or state the fact.
2. **Vague attributions.** "Experts believe", "Industry reports suggest", "Some critics argue". Name the source or delete.
3. **Puffery and promotion.** "pivotal moment", "testament to", "evolving landscape", "vibrant", "groundbreaking", "nestled", "stunning". State what happened.
4. **Vague declaratives.** "The reasons are structural", "The implications are significant", "The stakes are high". Name the specific reason, implication, or stake, or cut the sentence.
5. **Telling, not showing.** "This is genuinely hard", "This is what leadership actually looks like". Show the fact that makes it hard.
6. **Lazy extremes.** "every", "always", "never", "everyone", "nobody" doing vague work. Use a count or a specific case.
7. **Generic conclusions.** "The future looks bright." State specific plans or facts, or stop.

### Language

8. **AI vocabulary.** Additionally, crucial, delve, enduring, enhance, fostering, garner, interplay, intricate, landscape (abstract), pivotal, robust, showcase, tapestry (abstract), testament, underscore, vibrant. Replace with plain words.
9. **Fancy ways to say "is".** "serves as", "stands as", "boasts", "features". Write "is" or "has".
10. **Rule of three.** Ideas forced into groups of three. Use the natural number. Two items often beat three when the third is padding.
11. **Synonym cycling.** Protagonist, main character, central figure, and hero in one paragraph. Pick one name and repeat it.
12. **False ranges.** "from X to Y" where X and Y are not on a scale. List the topics.
13. **Business jargon.** "navigate challenges", "unpack", "lean into", "deep dive", "circle back", "game-changer". Use the plain word. See the table in `references/phrases.md`.
14. **Abstract metaphor nouns.** Substrate, wedge, vector, locus, vantage, nexus, primitive, harness, surface (as in "API surface"), bedrock, scaffolding, modality, paradigm, gold-plating, ratchet, evacuate, endgame, north star, flywheel. "Substrate" becomes "base". "Wedge in" becomes "add". "Vector" becomes "way". "Gold-plating" becomes "more than the job needs". "Ratchet" becomes the mechanism's real name or "a limit that only tightens". "Evacuate" becomes "move out". "Endgame" becomes "the last phase".
15. **Mannered prose.** A metaphor or flourish where a literal phrase exists: aphorisms ("wire it or delete it"), personified code ("the plan holds it"), figurative verbs ("rides along", "stands on"). "A dial worth turning" becomes "a parameter worth varying". Say what you mean.
16. **Over-compression.** Dropped articles, verbless fragments, symbol-speak, and abbreviations that make the reader decode. "Parser rejects bad date -> exit 2, no write" becomes "The parser rejects a bad date, exits with code 2, and writes nothing."

### Structure

17. **Binary contrasts and negative listing.** "Not X, but Y", "It's not X, it's Y", "The question isn't X. It's Y", "Not a bug. Not a feature. A design flaw." They telegraph a reversal. State Y.
18. **Dramatic fragmentation.** "Speed. Quality. Cost. That's it. That's the tradeoff." Write a complete sentence.
19. **Throat-clearing and rhetorical setups.** "Here's the thing:", "Here's what I mean:", "The truth is", "It turns out", "What if I told you", "Think about it". Cut to the point.
20. **Meta-commentary.** "In this section, we'll...", "As we'll see", "Let me walk you through". The text should move without announcing its structure.
21. **False agency.** Inanimate things doing human verbs: "the complaint becomes a fix", "the decision emerges", "the data tells us". Name who acts: "the team fixed it that week".
22. **Narrator from a distance.** "Nobody designed this", "This happens because", "People tend to". Put the reader in the scene, or name the cause directly. Use "you" where the text addresses a reader.
23. **Wh- openers that tee up the point.** "What makes this hard is..." becomes "The constraint is..." or, better, the constraint itself.

### Style

24. **Em dashes.** Avoid them entirely. End the sentence or use a comma. Do not swap in parentheses, en dashes, or hyphen-dashes.
25. **Colon overuse.** Colons are fine before a list or an example. Do not use them as mid-sentence connectors. "If you're coming from automation: you describe conditions" becomes "Describe conditions instead of registering handlers."
26. **Boldface overuse.** Do not bold every proper noun or acronym.
27. **Inline-header lists.** A bold label that restates its line: "**Performance:** Performance improved...". Convert to prose. A bold lead-in that names the item and adds new detail ("**Schema in TypeScript.** Tables live in one file.") is fine.
28. **Title case headings.** Use sentence case.
29. **Decorative emojis.** Remove them from headings and bullets.
30. **Curly quotes.** Replace with straight quotes.

### Communication artifacts

31. **Chatbot phrases.** "I hope this helps!", "Let me know if...", "Certainly!", "Found the smoking gun!". Remove.
32. **Sycophancy.** "Great question! You're absolutely right!" Respond directly.
33. **Cutoff disclaimers.** "While specific details are limited..." Find the detail or say what is unknown.

### Filler

34. **Filler phrases.** "In order to" becomes "to". "Due to the fact that" becomes "because". "It is important to note that" and "It's worth noting" are deleted.
35. **Emphasis crutches.** "Full stop.", "Let that sink in.", "Make no mistake", "This matters because". Delete them.
36. **Hedging.** "could potentially possibly be argued that it might" becomes "may".
37. **Intensifiers and softeners.** "really", "just", "literally", "genuinely", "honestly", "actually", "deeply", "fundamentally". Cut them. Keep an adverb that changes the meaning, such as "only" or "not".

### Plain speech

38. **Say what it does, not how it feels.** "The database stays close at hand" and "SQL you can read" name a feeling. "`.toSQL()` returns the exact string sent to the database" and "a column rename fails the build" name a mechanism. If you cannot restate a sentence as a concrete instruction, fact, or number, cut it. If it could appear unchanged in another project's docs, it says nothing about this one. If it reads like a pull-quote, rewrite it.
39. **Dense sentences.** If the reader has to backtrack, split the sentence or drop clauses. One idea per sentence.
40. **Active voice.** Catch "is/are/was/were + past participle" and name the actor. "Queries are validated" becomes "the compiler validates queries". Passive is fine when the actor is unknown or does not matter.
41. **Adverb-propped verbs.** "Runs quickly" becomes "is fast" or the number. "Significantly improves" becomes the measured delta. A weak verb that needs an adverb is the wrong verb.
42. **Plain words.** "utilize" and "leverage" become "use". "facilitate" becomes "help". "numerous" becomes "many". "in the event that" becomes "if".

## Voice

- **Have a view.** React to the facts instead of listing neutral pros and cons.
- **Vary the rhythm.** Do not let three sentences in a row share a length. Do not end every paragraph on a punchy one-liner. End paragraphs differently.
- **Be specific.** Not "this is concerning" but "agents run unattended at 3 a.m."
- **Use "I" when it fits.** First person is not unprofessional.
- **Let some unevenness in.** Perfect structure looks machine-made.
- **Trust the reader.** State the fact. Skip softening, justification, and hand-holding.

## Score the result

Rate the rewrite from 1 to 10 on each dimension.

| Dimension | Question |
|-----------|----------|
| Directness | Does it state points or announce them? |
| Rhythm | Is it varied or metronomic? |
| Trust | Does it respect the reader's intelligence? |
| Authenticity | Does it sound like a person with evidence and a view? |
| Density | Can anything be cut? |

Below 35 out of 50, revise. Then ask what still makes the text obviously AI-generated, and fix that.
