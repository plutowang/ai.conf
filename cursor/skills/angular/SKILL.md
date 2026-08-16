---
name: angular
description: Auto-apply when working with Angular. Trigger this skill when the user asks to create, modify, or debug Angular components, services, directives, pipes, HTML templates, or run Angular CLI commands.
---

# Angular & Nx Stack Expert

You are an expert in **Modern Angular (v19+)**. You strictly adhere to the latest syntax features and reactive patterns.

<red_lines>

- **Control Flow**: Use `@if`, `@for`, `@switch`, `@case`. No `*ngIf`, `*ngFor`, `ngSwitch`.
- **Variables**: Use `@let` for template vars. Avoid `*ngIf="obs$ | async as val"` aliases.
- **Signals**: Always use `input()`, `output()`, `viewChild()` signal functions — never `@Input()`, `@Output()`, `@ViewChild()` decorators.
- **Template Performance**: Never invoke functions directly in template bindings. Function calls in templates trigger on every change detection cycle, degrading performance. When a value needs transformation, create an Angular `Pipe` (standalone, `pure: true`) and use it in the template instead.
- **Styling**: Tailwind CSS only. No component `.scss` or `.css` files. Use `styles: []` and utility classes in templates.
</red_lines>

<standards>
**Component Architecture**

- **Standalone**: All components must be `standalone: true`.
- **Reactivity**: Use `computed()` for derived values and `effect()` for side effects. Keep `constructor()` empty when possible — use `private _ = effect(() => { ... })` as a field initializer for setup logic instead. The `effect()` runs within injection context and auto-cleans up on component destroy.
- **Unsubscribing**: Use `takeUntilDestroyed()` to automatically complete Observable subscriptions when the component/directive is destroyed. Inject `DestroyRef` when calling outside an injection context, or omit the argument inside `constructor()` or field initializers where it is inferred automatically.
- **Reactivity (Observables)**: Use `*ngrxLet` for Observables. Import `LetDirective` in components.

**Project Layout**

- Use `skill nx-monorepo` if `nx.json` exists.
- Standard layout uses `src/app/`.

**Tooling**

- Package Manager: `pnpm`
- Generator: `pnpm nx g ...` (Nx) or `pnpm ng g ...` (standard)
- Run: `pnpm nx serve <app>` (Nx) or `pnpm start` (standard)
- Format: `pnpm nx format:write` (Nx) or `pnpm format:write` (standard)

**Docs**: Context7 `/websites/angular_dev` · Fallback: <https://angular.dev>
</standards>
