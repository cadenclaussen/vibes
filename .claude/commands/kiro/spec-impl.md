Execute the implementation based on approved specs.

Arguments: $ARGUMENTS (optional: specific task number or "all")

## Prerequisites
Check that `.specs/tasks.md` exists. If not, guide user through the workflow.

## Workflow

1. Read all spec files to understand the full context
2. Read `.specs/tasks.md` to get the task list
3. If $ARGUMENTS specifies a task number, implement that task
4. If $ARGUMENTS is "all" or empty, implement tasks in dependency order

## Implementation Process

For each task:

1. **Check Dependencies**
   - Verify all dependent tasks are completed
   - If not, inform user and offer to complete dependencies first

2. **Update Task Status**
   - Mark task as "In Progress" in `.specs/tasks.md`

3. **Implement**
   - Follow the design in `.specs/design.md`
   - Follow the project style guide (`docs/style.md`)
   - Create/modify files as specified in the task
   - Write clean, well-structured code
   - Include inline comments for complex logic only

4. **Verify**
   - Check acceptance criteria from the task
   - Verify requirements are fulfilled
   - Build the project to check for errors

5. **Update Status**
   - Mark task as "Completed" in `.specs/tasks.md`
   - Update the task with any implementation notes

6. **Report Progress**
   - Show what was implemented
   - List files created/modified
   - Report any issues or deviations from the plan

## Progress Tracking

Update `.specs/tasks.md` as you work:

```markdown
### Task 1: [Task Title]
- **Status**: Completed
- **Completed**: 2024-01-15
- **Implementation Notes**:
  - Added notes about what was actually done
  - Any deviations from the original plan
```

## Instructions

1. Implement one task at a time
2. Always verify the build succeeds after each task
3. Follow existing code patterns in the codebase
4. Don't skip ahead - respect task dependencies
5. If blocked, report the issue and suggest solutions

## After Implementation

When all tasks are complete:
1. Generate a summary of what was built
2. List all files created/modified
3. Remind user to test the feature
4. Suggest next steps (testing, documentation, PR)

## Example Usage

- `/kiro:spec-impl` - Implement all tasks in order
- `/kiro:spec-impl 3` - Implement only Task 3
- `/kiro:spec-impl 1-3` - Implement Tasks 1 through 3
