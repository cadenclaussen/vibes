Initialize a new Kiro-style Spec-Driven Development project.

Arguments: $ARGUMENTS (the feature/product to build, or path to a PRD file)

## Workflow

1. Create the `.specs/` directory if it doesn't exist
2. If $ARGUMENTS is a file path, read the PRD file
3. Otherwise, treat $ARGUMENTS as the feature description

4. Create `.specs/prd.md` with the initial product requirements:
   - Feature name and summary
   - Problem statement
   - Goals and non-goals
   - Target users
   - High-level scope

5. Display the initialized spec and explain the next steps:
   - `/kiro:spec-requirements` to generate detailed requirements
   - `/kiro:spec-design` to create architecture
   - `/kiro:spec-tasks` to break down implementation

## Output Format

```markdown
# [Feature Name] - Product Requirements

## Summary
Brief description of what we're building.

## Problem Statement
What problem does this solve?

## Goals
- Goal 1
- Goal 2

## Non-Goals
- What we're explicitly NOT doing

## Target Users
Who will use this feature?

## Scope
High-level description of included functionality.
```

After initialization, remind the user to run `/kiro:spec-requirements` to generate detailed requirements.
