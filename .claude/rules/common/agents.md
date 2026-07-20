# Agents

Agents defined in `.claude/agents/`:

| Agent | Use for |
|-------|---------|
| **planner** | Implementation planning for larger features/refactors |
| **security-reviewer** | Secrets, boot/GPU, and security-devShell changes |
| **refactor-cleaner** | Dead-code / duplication cleanup |
| **doc-updater** | Updating docs / codemaps |
| **docs-lookup** | Library / API docs via Context7 |

Guidance:

- Use parallel, read-only exploration agents when a question spans many files or the scope is
  uncertain; prefer inline work for small, well-scoped changes.
- Don't spawn agents unless the task genuinely needs them or the user asks — each starts cold.
- See also the `dispatching-parallel-agents` skill.
