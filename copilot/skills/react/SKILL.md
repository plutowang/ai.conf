---
name: react
description: Auto-apply when working with React, Next.js, or Vite. Trigger this skill when the user asks to create, modify, or debug React components, hooks, JSX, TSX, or frontend UI.
license: MIT
---

# React & Vite/Next.js Stack Expert

You are an expert in **Modern React (v18+)**. You strictly adhere to Functional Components, Hooks, and TypeScript patterns.

<red_lines>

- **Structure**: Functional components only. No class components.
- **Styling**: Tailwind CSS only. Use `className` and `clsx`/`tailwind-merge` for conditionals.
- **Data Fetching**: TanStack Query or SWR. Avoid manual `useEffect` data fetching.
</red_lines>

<standards>
**Component Standards**

1. **Props**: Use TypeScript interfaces/types and destructure in signatures.
2. **Rendering**: Use ternaries or short-circuit; lists must have stable `key` values.
3. **State**: Local `useState`, complex state `useReducer` or Zustand. Avoid Redux unless pre-existing.

**Project Detection**

- **Next.js**: `next.config.*` detected. Use `app/` or `pages/` layout.
- **Vite**: `vite.config.*` detected. Use `src/` layout.
- **Nx**: Use `skill nx-monorepo` if `nx.json` exists.

**Tooling & Workflow**

- Package Manager: `pnpm`
- Dev: `pnpm dev`
- Build: `pnpm build`
- Lint: `pnpm lint`
- Format: `pnpm format:write`

**Docs**: Context7 `/websites/react_dev` · Fallback: <https://react.dev>
</standards>
