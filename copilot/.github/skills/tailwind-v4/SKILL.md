---
name: tailwind-v4
description: Auto-apply when working with Tailwind CSS v4. Trigger this skill when writing Tailwind classes, adding utility styles, using @theme or @apply directives, or styling React/Angular components.
---

# Tailwind v4 Custom Color Detection

## Protocol

When using Tailwind CSS v4, check for custom theme configuration first:

1. Read `src/index.css` (or main CSS entry point).
2. Look for the `@theme { ... }` directive with color variables.
3. If found, use the defined semantic names (e.g., `bg-brand`, `text-primary`).
4. If not found, use Tailwind default color classes (e.g., `bg-blue-500`).
5. Never hardcode hex colors in class names (e.g., `bg-[#3b82f6]`).

## Detection

- Tailwind v4 if `package.json` has `tailwindcss: ^4.x`.
- Load this skill when working with React/Angular/Tailwind projects.

**Docs**: Context7 `/websites/tailwindcss` · Fallback: <https://tailwindcss.com/docs>
