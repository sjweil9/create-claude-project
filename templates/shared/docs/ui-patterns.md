# UI Patterns

Baseline UI/UX principles shipped with the scaffold. The project interview
tailors this doc; project-specific components and conventions get recorded
here as they are established.

## Design Principles

- **Mobile-first** — design for small screens, scale up; every view must be
  usable at every width
- **Simplicity** — clean, minimal UI; earn every element on the screen
- **Consistency** — reuse established components and patterns before inventing
  new ones; record new patterns here once adopted

## Accessibility (target: WCAG 2.1 AA)

- Every interactive element is keyboard-accessible with a visible focus state
- Semantic markup first (`button`, `nav`, `label`, headings in order); ARIA
  only where semantics can't express it
- All form inputs labeled; all meaningful images have alt text
- Color is never the only carrier of meaning; text meets AA contrast in both
  themes

## Styling

- **Tailwind CSS** for all styling; custom CSS only when absolutely necessary
- **Dark mode + light mode** supported by default in every component from day
  one — never bolted on later
- Define theme decisions (palette, spacing, type scale) as design tokens and
  record them here once chosen

## Responsiveness & Feedback

- **Every user action gets immediate, visible feedback** — it should be
  obvious the action was received and whether it succeeded
- Loading: skeleton loaders or spinners for anything not instant; optimistic
  updates where safe
- Every data-driven view handles **loading, error, and empty** states — empty
  states say what the user can do next
- Errors are human-readable and actionable, never raw internals

## Dialogs & Confirmations

- **Never use native JavaScript dialogs** — `alert()`, `confirm()`, `prompt()`
  are prohibited: they block the main thread, cannot be styled, and break
  visual consistency
- Use the app's custom modal/dialog component for confirmations of destructive
  actions
- All modals support: dark mode, Escape-key dismiss, backdrop click to close,
  and focus management (trap focus while open, restore it on close)
