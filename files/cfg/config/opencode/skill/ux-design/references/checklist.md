# UX Design Checklist

Use this checklist to verify that the UI implementation meets the design standards.

## Cohesion & Consistency
- [ ] Are existing `src/components/ui/` components used instead of custom HTML elements?
- [ ] Do colors match the theme defined in `tailwind.config.ts` / `globals.css`?
- [ ] Is spacing consistent (using Tailwind's spacing scale)?
- [ ] Is typography consistent with the app's font hierarchy?

## Simplicity & Focus
- [ ] Is the primary action the most prominent element on the screen?
- [ ] Are secondary actions less visual (e.g., outline or ghost buttons)?
- [ ] Is unnecessary metadata or clutter removed?
- [ ] Is the "90% use case" achievable with the fewest clicks possible?

## Feedback & States
- [ ] **Loading**: Is there a skeleton or spinner shown while data loads?
- [ ] **Loading**: Is the submit button disabled and showing a spinner during submission?
- [ ] **Error**: Are form validation errors shown inline?
- [ ] **Error**: Are API errors shown via toast or alert?
- [ ] **Empty**: Is there a clear, helpful empty state if no data exists?
- [ ] **Success**: Is there a toast or visual confirmation after a successful action?

## Intuitiveness
- [ ] Are buttons labeled with clear action verbs (e.g., "Save Profile" vs "Submit")?
- [ ] Is the navigation structure logical?
- [ ] Are interactive elements clearly clickable (hover states, cursors)?
- [ ] Is the back button working as expected?
