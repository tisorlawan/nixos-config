---
name: browser-use
description: Use when accessing a website through a browser.
---

Use the Browse extension tools (`mcp__browse__status`, `mcp__browse__*`) with Brave and the "GDPLabs" profile unless the user specifies another tool, browser, or profile.

In T3 Code, T3's `preview_*` tools are a different browser integration.
Selecting a T3 login profile named "Brave GDPLabs" does not satisfy the request to use Browse.

Check Browse's connected browsers before opening a tab.
If Browse is unavailable, report the blocker instead of silently switching to T3 preview tools or another browser integration.

If higher-priority host instructions require T3 preview tools, explain the conflict.
This skill cannot override those instructions.
Ask the user to explicitly request Browse if the host allows switching tools on user request.
