---
name: csharp
description: Auto-apply when working with C# and the .NET ecosystem. Trigger this skill when the user asks to create, modify, or debug C#, ASP.NET, Blazor, Entity Framework, MAUI, or use the dotnet CLI.
---

# C# Language Expert

You are an expert in C# and .NET development.

<red_lines>

- Avoid `async void` (except event handlers).
- Assume `<Nullable>enable</Nullable>` is on.
</red_lines>

<execution_protocol>
**Context Protocol**

Before writing code, check the environment:

1. **Check Version**: Run `dotnet --version` (e.g., 6.0, 8.0, 9.0).
2. **Check Project**: Look for `.csproj` files to identify the target framework (`<TargetFramework>net8.0</TargetFramework>`).

**Tooling Commands**

Use the `dotnet` CLI for all tasks:

- **Create**: `dotnet new console -n MyProject`
- **Build**: `dotnet build`
- **Run**: `dotnet run`
- **Test**: `dotnet test`
- **Format**: `dotnet format`
- **Add Package**: `dotnet add package <PackageName>`
</execution_protocol>

<standards>
**Project Structure**

- **`.sln`**: Solution file (groups multiple projects).
- **`.csproj`**: Project definition (dependencies, version).
- **`Program.cs`**: Entry point (often uses Top-Level Statements in .NET 6+).

**Coding Standards**

- **Async/Await**: Always use `async Task` (or `async ValueTask`) for I/O bound operations.
- **Nullable Reference Types**: Use `?` for nullable types (e.g., `string? name`).
- **JSON**: Prefer `System.Text.Json` (modern standard) over `Newtonsoft.Json` unless legacy requires it.

**Common Patterns**

- **Dependency Injection**: Use `Microsoft.Extensions.DependencyInjection` in `Program.cs`.
- **Logging**: Use `ILogger<T>`.
- **LINQ**: Use LINQ for collection manipulation (`.Where()`, `.Select()`).

**Docs**: <https://learn.microsoft.com/dotnet> · Language: <https://learn.microsoft.com/dotnet/csharp> · API: <https://learn.microsoft.com/dotnet/api>
</standards>
