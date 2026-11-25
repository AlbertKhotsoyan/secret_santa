# Vue / Frontend Standards

## Principles

- Prefer Composition API over Options API
- Follow Clean Architecture and SOLID principles
- Use TypeScript strictly; `any` is allowed only in exceptional cases and with explicit justification
- Account for accessibility (WCAG) and performance (Core Web Vitals)
- Evaluate impact on bundle size and re-render count before writing code
- Describe folder structure and data flow first when creating a feature

## Code Style

- **Readability first**: short functions, descriptive names, early returns, no complex constructs
- **Modern JS (ES6+)**: destructuring, optional chaining (`?.`), nullish coalescing (`??`), template literals, array methods (`map` / `filter` / `reduce`)
- **Function style**: prefer `function foo() {}` for named handlers and exported functions
  - Arrow functions are fine for short callbacks and inline logic
- **No duplication**: if logic is repeated more than twice — extract it into a composable, computed property, or utility
- **No magic strings**: extract repeated and immutable values into constants

## Vue Components

- Use Composition API; do not use `Options API`
- Block order in `.vue` files: `<script setup>` → `<template>` → `<style>`
- Each component must have a single responsibility
- Separation by type:
  - UI components: `props` + `emits`, minimal local state, no direct API calls
  - Page/orchestrator components: routing, state, data fetching, calling stores/services
- Use `useTemplateRef` for DOM access if supported by the project version

## Styles

- Use SCSS
- Apply `scoped` only when genuinely necessary
- Prefer existing Redmine/PrimeVue classes; do not hardcode theme colors unnecessarily

## Structure and Reuse

- No repeated logic: extract into:
  - `computed` — for derived state
  - `utils` — for pure functions
  - `composables` — for reusable reactive logic
- Do not duplicate formatters and label resolvers across multiple components — extract them into a shared layer

## API Layer

- Network requests must live outside components in a dedicated layer (`src/api/**`)
- Components and views call `stores` / `services` / `api layer`
- Components must not construct URLs or call `fetch` directly

## Constants

Create in `src/constants/**` for:
- route names and paths
- query keys
- record types
- magic strings
- UI option lists

## Code Quality

- Use `const` / `let`, never `var`; compare with `===` / `!==`
- Use `Number.parseInt` / `Number.isNaN` instead of global `parseInt` / `isNaN`; use `globalThis` instead of `window` in new code
- Do not declare functions inside loops
- Promises must handle errors (`try/catch` around `await` or `.catch()`); empty `catch` blocks are prohibited
- Do not leave `console.log` or commented-out code; use `console.error` only for actual errors
- Never assign untrusted data to `innerHTML`
