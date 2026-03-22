---
description: React and frontend patterns - components, hooks, state management, performance. Auto-loaded when working with React/JSX/TSX files or frontend directories.
globs:
  - "**/*.tsx"
  - "**/*.jsx"
  - "**/components/**"
  - "**/hooks/**"
  - "**/pages/**"
  - "**/app/**/*.tsx"
  - "**/app/**/*.jsx"
  - "**/styles/**"
  - "tailwind.config.*"
  - "next.config.*"
  - "vite.config.*"
---

# React & Frontend

## Component Structure
- One component per file, file name matches component name
- Colocation: component, styles, tests, types in same directory
- Extract hooks when logic is reused or component exceeds ~150 lines
- Props interface defined above component, exported if shared

## State Management
- Local state (`useState`) for component-specific data
- URL state for shareable/bookmarkable state (search params)
- Server state via React Query/SWR/tRPC (not Redux for API data)
- Global state (Zustand/Jotai) only for truly cross-cutting concerns

## Performance
- `React.memo` only when profiler confirms unnecessary re-renders
- `useMemo`/`useCallback` for expensive computations and stable references
- Lazy load routes and heavy components (`React.lazy` + `Suspense`)
- Virtualize long lists (react-window or tanstack-virtual)
- Avoid prop drilling deeper than 2 levels - use composition or context

## Patterns
- Render props and compound components for flexible UI composition
- Error boundaries around independent sections (one crash shouldn't kill the page)
- Optimistic updates for better perceived performance
- Form handling: React Hook Form or Formik, not manual state tracking

## Accessibility
- Semantic HTML first (button, not div with onClick)
- ARIA labels for interactive elements without visible text
- Keyboard navigation for all interactive elements
- Color contrast minimum 4.5:1 (WCAG AA)

## Common Pitfalls
- useEffect as an event handler (use event handlers for events)
- Fetching in useEffect without cleanup (race conditions)
- Mutating state directly instead of creating new references
- Missing key prop in lists (or using index as key for reorderable lists)
