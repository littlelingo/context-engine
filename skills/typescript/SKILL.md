---
name: typescript
description: TypeScript patterns and type safety. Auto-loaded when working with .ts files, tsconfig.json, or type definition files (.d.ts).
---

# TypeScript

## Type Safety
- Prefer `unknown` over `any` — narrow with type guards instead of casting
- Use `satisfies` for type validation without widening: `const config = { ... } satisfies Config`
- Prefer `interface` for object shapes (extendable), `type` for unions/intersections/mapped types
- Use discriminated unions over optional fields for state variants: `{ status: 'loading' } | { status: 'done'; data: T }`
- Avoid `as` casts — use type predicates (`function isUser(x): x is User`) or `satisfies` instead
- Use `readonly` for arrays/objects that shouldn't be mutated: `readonly string[]`, `Readonly<Config>`

## Configuration
- Enable `strict: true` in tsconfig.json — never disable individual strict checks
- Use `noUncheckedIndexedAccess: true` for safer array/object access
- Prefer `moduleResolution: "bundler"` or `"node16"` over legacy `"node"`
- Use path aliases sparingly — they complicate tooling. Prefer relative imports for project files

## Generics
- Name type params descriptively when meaning isn't obvious: `TItem` over `T`, `TResponse` over `R`
- Constrain generics: `<T extends Record<string, unknown>>` not bare `<T>`
- Use `infer` in conditional types to extract nested types: `type UnwrapPromise<T> = T extends Promise<infer U> ? U : T`

## Utility Types
- `Partial<T>`, `Required<T>`, `Pick<T, K>`, `Omit<T, K>` for object transformations
- `Record<K, V>` for dictionaries — prefer over `{ [key: string]: V }`
- `Extract<T, U>` and `Exclude<T, U>` for union filtering
- `ReturnType<typeof fn>` to derive types from functions
- `Parameters<typeof fn>` to extract function argument types

## Patterns
- Exhaustive switch: use `never` in default to catch missing cases at compile time
- Branded types for domain safety: `type UserId = string & { readonly __brand: 'UserId' }`
- Use `const` assertions for literal types: `as const`
- Prefer `Map<K, V>` over plain objects when keys are dynamic

## Common Pitfalls
- `Object.keys()` returns `string[]`, not `(keyof T)[]` — use a typed wrapper or `for...in`
- Optional chaining (`?.`) returns `undefined`, not `null` — check your null handling
- `enum` generates runtime code — prefer `const` objects with `as const` for zero-cost enums
- Type narrowing doesn't persist across `async` boundaries — re-narrow after `await`
- `JSON.parse()` returns `any` — always validate with a schema (zod, valibot) or type guard
