---
name: ux-design
description: Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when the user asks to build web components, pages, artifacts, posters, or applications (examples include websites, landing pages, dashboards, React components, HTML/CSS layouts, or when styling/beautifying any web UI). Generates creative, polished code and UI design that avoids generic AI aesthetics.
---

# UX Design Guidelines

## Core Philosophy

This skill enforces a cohesive, consistent, and user-centric design system across the repository. The goal is to create interfaces that are intuitive, robust, and focused on the user's primary goals.

### Key Principles

1.  **Cohesion & Consistency**: Every component must look and feel like part of the same family. Reuse existing UI components (buttons, inputs, cards) from `src/components/ui/` whenever possible. Do not invent new styles unless absolutely necessary.
2.  **Simplicity**: Avoid clutter. If an element doesn't serve a clear purpose, remove it.
3.  **Focus**: The main feature should be the center of attention. Visual hierarchy must guide the user's eye to the primary action.
4.  **90% Usage Optimization**: The most common workflows (the 90%) must be the easiest and fastest to execute. Optimize for the happy path.
5.  **Feedback is Mandatory**:
    *   **Loading**: NEVER leave the user guessing. Always show a skeleton loader, spinner, or progress bar during async operations.
    *   **Action Feedback**: Provide immediate confirmation (toast, visual state change) for every interaction.
6.  **Intuitive UX**: Use standard patterns. Avoid hidden gestures or confusing navigation. If a user has to ask "how do I do this?", the design has failed.

## Workflow for Implementation

When implementing or modifying UI:

1.  **Analyze**: Understand the "90% use case" for this feature.
2.  **Plan**: Select existing components from `src/components/ui/`.
3.  **Design**:
    *   Ensure the layout focuses on the main action.
    *   Add loading states for *all* data fetching or processing.
    *   Handle empty states and error states gracefully.
4.  **Verify**: Check against the [UX Checklist](references/checklist.md).

## Common Patterns

### Loading States
- **Initial Load**: Use Skeleton loaders that mimic the final layout.
- **Form Submission**: Disable the submit button and show a spinner inside it.
- **Background Process**: Show a non-intrusive progress indicator (toast or status bar).

### Error Handling
- **Form Errors**: Inline validation messages near the input.
- **System Errors**: Dismissible toast notifications or dedicated error boundary screens for fatal errors.
- **Recovery**: Always offer a way to retry or go back.

### Visual Hierarchy
- **Primary Action**: Solid, high-contrast button (e.g., `default` variant).
- **Secondary Action**: Outline or ghost button.
- **Destructive Action**: Red/Danger styling, but placed carefully to avoid accidental clicks.

## Reference Material

- **UX Checklist**: See [checklist.md](references/checklist.md) for a comprehensive review list.
