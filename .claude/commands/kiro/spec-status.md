Show the current status of the Kiro Spec-Driven Development workflow.

## Workflow

1. Check for the existence of each spec file:
   - `.specs/prd.md` - Product Requirements Document
   - `.specs/requirements.md` - Detailed Requirements
   - `.specs/design.md` - Architecture & Design
   - `.specs/tasks.md` - Implementation Tasks

2. For each file that exists, show a summary:
   - File exists: Yes/No
   - Last modified: Date
   - Brief summary of contents

3. If `.specs/tasks.md` exists, show task completion status:
   - Pending tasks
   - In-progress tasks
   - Completed tasks

## Output Format

```
Kiro SDD Status
===============

Phase           | Status      | File
----------------|-------------|---------------------
1. PRD          | Complete    | .specs/prd.md
2. Requirements | Complete    | .specs/requirements.md
3. Design       | In Progress | .specs/design.md
4. Tasks        | Pending     | -
5. Implementation | Pending   | -

Current Phase: Design

Task Progress (if available):
- Completed: 3/10
- In Progress: 1
- Pending: 6

Next Step: Run /kiro:spec-design to complete the design phase.
```

## Instructions

1. Be concise but informative
2. Clearly indicate the next action the user should take
3. If no specs exist, guide user to start with `/kiro:spec-init`
