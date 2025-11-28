# Tool Usage Priority

## Serena (Semantic Code Operations)
- **First**: Call `serena_initial_instructions` if you haven't read the manual
- **Second**: Call `serena_check_onboarding_performed` before working on a project
- Prefer symbolic tools (`find_symbol`, `find_referencing_symbols`) over pattern search
- Use `serena_think_about_collected_information` after gathering context
- Use `serena_think_about_task_adherence` before making edits
- Use `serena_think_about_whether_you_are_done` when task seems complete
- Check `serena_list_memories` for relevant project context

## Context7 (Documentation)
- Use for up-to-date documentation on third-party libraries/frameworks
- Call `context7_resolve-library-id` before `context7_get-library-docs`
- **Key libraries for this project**:
  - `@tanstack/db` - TanStack DB for local-first database
  - `powersync-js` - PowerSync for sync engine
  - Look up both when working on sync, schema, or query logic

## Sequential Thinking
- Use for complex decision-making, multi-step planning, and problem decomposition
- Use when reasoning about sync conflicts, schema design, or offline-first patterns

Read AGENTS.md before starting any work.

$ARGUMENTS

