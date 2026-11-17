---
name: html-communication
description: "Write a self-contained HTML page for a plan, specification, report, findings, comparison, summary, or UI mockup that the user wants to read in a browser, and publish it to Postplan when the user agrees. Do not use for HTML that ships in a product."
disable-model-invocation: true
---

# HTML communication

Write the requested material as one self-contained HTML page that opens on the content. Use this skill for pages the user reads or reviews in a browser. For HTML, components, templates, or styles that ship in a product, follow that repository's workflow instead.

## Write the page

- Write one `.html` file of at most 512 KB, with every asset inside it. Put CSS in a `<style>` element.
- Open with the title and the facts the reader needs most. Leave out heroes, slogans, marketing copy, and decoration.
- Keep the content dense and easy to scan, with headings in order, lists, tables, figures, and code blocks. Add inline SVG only for a diagram or icon that carries information.
- Use generous whitespace, light borders, and small shadows. Cards, tables, and diagrams organize information and do not decorate.
- Make the layout work at 320 CSS pixels without horizontal page scrolling. Wide tables and code blocks may scroll inside their own boxes.
- Show a visible focus ring, name the destination in link text, add alt text to meaningful images, and label controls.
- Honor `prefers-reduced-motion`. Pair every color that carries meaning with a word, label, or shape.
- Use HTTPS or data URLs for images, with a width and height on each.
- Leave out secrets, private URLs, machine names, usernames, and local file paths.

## Support light and dark mode

Build a light theme and a dark theme, and let the system setting pick one. Build one theme only when the user asks. Then set `color-scheme` to that theme and skip the media query.

- Define every color as a custom property on `:root`. Put the other theme in an `@media (prefers-color-scheme: ...)` block that redefines the same properties.
- Set `color-scheme: light dark`, so scrollbars and form controls follow the theme.
- Color SVG through CSS classes. A `fill="#..."` attribute does not change with the theme.
- Give text on accent fills its own property, such as `--on-accent`. The page background color flips between themes, so it cannot serve as that text color.
- Set the colors of selected text, including SVG text. SVG text keeps its `fill` when selected, so without these rules Chrome draws dark diagram labels on its strong blue selection:

  ```css
  ::selection { background: var(--selection); color: var(--selection-text); }
  svg text::selection { fill: var(--selection-text); }
  ```
- Reach at least 4.5:1 contrast for normal text, and 3:1 for large text and diagram lines, in both themes.
- Do not add a theme toggle. It needs storage, and the hosting sandbox blocks storage.

## Pick the colors

Use these colors: Rice Everforest for light mode and Catppuccin Mocha for dark mode. Every value is below, so do not look colors up anywhere else. Use other colors only when the user gives them. Every text color in this block reaches 4.5:1 on `--page`, `--card`, and `--code` in both themes. Start from the block:

```css
:root {
  color-scheme: light dark;
  /* Catppuccin Mocha */
  --page: #11111b;
  --card: #1e1e2e;
  --code: #181825;
  --border: #313244;
  --border-strong: #45475a;
  --text: #cdd6f4;
  --muted: #a6adc8;
  --heading: #b4befe;
  --green: #a6e3a1;
  --blue: #89b4fa;
  --red: #f38ba8;
  --yellow: #f9e2af;
  --purple: #cba6f7;
  --orange: #fab387;
  --aqua: #94e2d5;
  --on-accent: #11111b;
  --selection: #4c4f69;
  --selection-text: #cdd6f4;
}

@media (prefers-color-scheme: light) {
  :root {
    /* Rice Everforest light, with accents darkened to reach 4.5:1 */
    --page: #f4fef5;
    --card: #ebf9ec;
    --code: #e0eee2;
    --border: #dbe9dd;
    --border-strong: #ccdacd;
    --text: #5c6a72;
    --muted: #626d60;
    --heading: #606d01;
    --green: #606d01;
    --blue: #2b6d91;
    --red: #cf0c08;
    --yellow: #866000;
    --purple: #b8278a;
    --orange: #a84b08;
    --aqua: #257456;
    --on-accent: #ffffff;
    --selection: #c4e1ee;
    --selection-text: #2d353b;
  }
}
```

Use `--on-accent` for text on every accent fill, such as labels and diagram bars. Use `--blue` for links and `--purple` for focus rings. When the user asks for print, use a plain white background.

### How Rice Everforest differs from stock Everforest

Rice Everforest replaces stock Everforest's cream backgrounds with mint green. Its text, muted text, and accents are stock.

| Property | Stock Everforest light (medium) | Rice Everforest |
|---|---|---|
| `--page` | `#fdf6e3` | `#f4fef5` |
| `--card` | `#f4f0d9` | `#ebf9ec` |
| `--code` | `#efebd4` | `#e0eee2` |
| `--border` | `#e6e2cc` | `#dbe9dd` |
| Selection | `#e6e2cc` | `#e9f0e9` |
| `--text` | `#5c6a72` | `#5c6a72` |
| `--muted` | `#939f91` | `#939f91` |
| Accents | green `#8da101`, blue `#3a94c5`, red `#f85552`, yellow `#dfa000`, purple `#df69ba`, orange `#f57d26`, aqua `#35a77c` | same |

The theme's accents and muted text reach only 1.8 to 3.3:1 as text on these backgrounds. The block above darkens each one, keeping its hue, until it reaches 4.5:1 on `#dbe9dd`. White text on the darkened accents reaches 5.7:1.

The theme's selection color `#e9f0e9` barely differs from `--card`, so the block uses pale blue `#c4e1ee` instead. `--text` reaches only 4.1:1 on it, so selected text gets the darker `#2d353b`, at 9.1:1.

- Use the theme's exact accents only when the user asks for them, and say which texts then fall below 4.5:1.
- Keep body text off `--border` (4.44:1) and `--border-strong` (3.85:1).

## Use two font stacks

Use `Ubuntu, "Noto Sans", sans-serif` for all normal text, including headings, captions, SVG text, and pseudo-elements. Use `"Ubuntu Mono", "Noto Sans Mono", "Roboto Mono", monospace` for code. Add no other font families.

Do not embed or link fonts. Postplan's policy has `default-src 'none'` and no `font-src`, so it blocks data-URL and web fonts.

Check the computed styles on the published page. Normal text and code must resolve through their stacks.

## Keep the file sandbox-safe

Prefer a page without scripts. Add one small inline classic script only when interaction clearly helps, and keep the content readable without JavaScript.

The sandbox blocks storage, network requests, workers, frames, forms, and popups. Never include:

- external or module scripts, or linked stylesheets
- inline event handlers or `javascript:` URLs
- forms, network requests, workers, storage, popups, or dynamic code evaluation
- frames, embeds, objects, or applets
- meta refresh

External links may use `target="_blank" rel="noopener noreferrer"` only on a page without scripts.

## Show UI alternatives as real mockups

Render each alternative as a complete styled mockup, labeled `A`, `B`, `C`. Place them side by side, stacked on narrow screens. Keep the same content and state in each, unless that difference is what the user is comparing.

## Check the page

Fix any failure before publishing:

1. Open the local file at desktop width and at 320 CSS pixels.
2. Check both color schemes, including code blocks and diagrams. Headless Chrome forces dark with `--blink-settings=preferredColorScheme=0` and light with `=1`, for example `google-chrome --headless=new --blink-settings=preferredColorScheme=1 --window-size=1000,1800 --screenshot=light.png file:///abs/path/page.html`.
3. Check selected text in both color schemes, including diagram labels. Make a test copy with only the page's `<head>` and one diagram, plus a script that selects the diagram's contents on load, then screenshot it. Never publish that copy.
4. Check headings, links, focus rings, overflow, and any interaction, also with JavaScript disabled.
5. Remove local paths, private data, placeholder text, and unused CSS or script.

## Publish with Postplan

Postplan is an external host, and anyone with the URL can read the page.

1. Write the file and tell the user its path.
2. Ask: "Publish this to Postplan (external, public URL)?"
3. If the user says yes, run `npx --yes postplan upload <absolute-file-path>` and report the URL.

To update a page, upload the same absolute path again, or add the `--draft <draft-id>` that the first upload printed. Add `--new` only when the user asks for a separate URL.

If Postplan rejects the page, fix the markup it reports and upload again. If an interactive page needs authentication, ask the user to run `npx postplan auth login`, then retry with the interaction kept.

Say the page is hosted only after the upload succeeds. Open the hosted URL only when the user asks.
