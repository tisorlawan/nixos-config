---
name: html-communication
description: "Create and publish a self-contained HTML document when the user wants a plan, specification, report, findings, comparison, summary, or UI mockup presented as readable HTML. Do not use for HTML that ships in a product."
disable-model-invocation: true
---

# HTML communication

Present the requested material as a polished, self-contained HTML document. The document is the answer, not a landing page or a demo shell.

## Decide whether to use this skill

Use this skill for plans, specifications, reports, findings, comparisons, summaries, and UI mockups that the user wants to read or review in a browser.

Do not use this skill for HTML, components, templates, or styles that ship as part of a product. Follow the product repository's implementation workflow instead.

## Build the document

Create one `.html` file no larger than 512 KB. Keep every required asset in that file.

- Write dense, scannable content with a clear information hierarchy.
- Start with the title and the information the reader needs most. Do not add a hero, slogan, marketing copy, or decorative chrome.
- Use semantic HTML landmarks, headings in order, lists, tables, figures, and code blocks where they fit the content.
- Use inline CSS. Use inline SVG only when a diagram or icon communicates information.
- Make the layout responsive. It must remain readable at 320 CSS pixels without horizontal page scrolling. Wide tables and code blocks may scroll inside their own containers.
- Use sufficient contrast, visible keyboard focus, descriptive link text, text alternatives for meaningful images, and labels for controls.
- Respect `prefers-reduced-motion`. Do not rely on color alone to convey meaning.

### Use the Kami design system

Follow the [Kami design system](https://kami.tw93.fun/) by default:

- Use a warm parchment canvas (`#f5f4ed`) and near-white paper surfaces.
- Use ink blue (`#1B365D`) as the single primary accent for headings, links, focus rings, and key diagram edges.
- Use editorial whitespace, restrained borders, compact shadows, and clear section rhythm.
- Prefer document structure over app chrome. Cards, tables, and diagrams must organize information rather than decorate it.
- Keep status colors muted. Never rely on color alone to communicate status.
- Use the white-paper variant only when the user asks for print-oriented output.
- Depart from Kami only when the user asks for another visual direction or the content has an established visual identity.

### Use two typography roles

- Use one stack for all normal text and one stack for code. Apply the same normal-text stack to headings, paragraphs, navigation, labels, tables, callouts, captions, SVG text, and pseudo-elements.
- When the delivery target permits embedded fonts, use `IBM Plex Serif` for normal text and `IBM Plex Mono` for code. Embed only the required WOFF2 subsets and weights as data URLs.
- Postplan currently sends `default-src 'none'` without a `font-src` directive. It blocks data-URL and HTTPS web fonts. For Postplan documents, use `Ubuntu, "Noto Sans", sans-serif` for normal text and `"Ubuntu Mono", "Noto Sans Mono", "Roboto Mono", monospace` for code.
- Do not add font families outside the two selected stacks.
- Verify computed styles on the published document, not only the local file. Confirm that rendered text resolves through the normal-text stack and code resolves through the code stack. Embedded font faces must have `loaded` status.

Use HTTPS or data URLs for images. Include dimensions to prevent layout shifts. Do not include secrets, private URLs, machine names, usernames, or local filesystem paths in document content.

## Keep the file sandbox-safe

Prefer a script-free document. If interactivity materially improves the result, use one small inline classic script and keep the content useful when JavaScript is unavailable.

Never include:

- external or module scripts
- linked stylesheets
- inline event-handler attributes
- `javascript:` URLs
- forms or network requests
- frames, embeds, objects, or applets
- workers, storage, popups, or dynamic code evaluation
- meta refresh

The hosting sandbox blocks storage, fetches, workers, frames, forms, and popups. Do not build interactions that depend on them.

For a script-free file, external links may use `target="_blank"` with `rel="noopener noreferrer"`. If the file contains any script, omit `target="_blank"` so a new page cannot access the scripted document through `window.opener`.

## Present UI variants as real mocks

When the user asks for alternatives:

- Render each alternative as a complete styled variant rather than describing it.
- Label variants `A`, `B`, `C`, and so on.
- Place variants close enough for direct comparison. Stack them on narrow screens.
- Keep the same content and state across variants unless the difference itself is being compared.
- Keep one local file across revisions so uploading the same absolute path updates the existing Postplan URL.

## Check the result

Before publishing:

1. Open the local file in a browser.
2. Check the document at desktop width and at 320 CSS pixels.
3. Confirm that headings, links, focus states, overflow, and any interaction work.
4. Confirm that the page remains useful with JavaScript disabled.
5. Remove accidental local paths, private data, placeholder copy, and unused CSS or script.

Fix the document before publishing if any check fails.

## Publish with Postplan

Publishing is part of the task. Do not stop after writing the local file.

1. Write the HTML file locally.
2. Run `npx postplan upload <absolute-file-path>`.
3. Report the local path and the Postplan URL returned by the command.

Upload the same absolute path again to update the existing URL. Use `npx postplan upload <absolute-file-path> --new` only when the user asks for a separate draft or URL.

If Postplan rejects the document, fix the reported markup and retry. If an interactive document requires authentication, ask the user to run `npx postplan auth login`, then retry without removing the requested interactivity.

Do not claim that the document is hosted until the upload succeeds. Do not open the hosted URL unless the user asks.
