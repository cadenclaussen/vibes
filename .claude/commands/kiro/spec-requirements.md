Generate EARS-format requirements from the initialized PRD.

## Prerequisites
Check that `.specs/prd.md` exists. If not, instruct user to run `/kiro:spec-init` first.

## Workflow

1. Read `.specs/prd.md` to understand the feature scope
2. Analyze the existing codebase for context (patterns, conventions, related features)
3. Generate structured requirements in `.specs/requirements.md`

## EARS Notation Reference

Use these EARS (Easy Approach to Requirements Syntax) patterns:

- **Ubiquitous**: "The [system] shall [action]"
- **Event-Driven**: "When [trigger], the [system] shall [action]"
- **State-Driven**: "While [state], the [system] shall [action]"
- **Optional**: "Where [feature enabled], the [system] shall [action]"
- **Unwanted Behavior**: "If [condition], the [system] shall [action]"
- **Complex**: Combine patterns as needed

## Output Format for `.specs/requirements.md`

```markdown
# [Feature Name] - Requirements

## Functional Requirements

### FR-1: [Requirement Title]
- **Type**: Ubiquitous | Event-Driven | State-Driven | Optional | Unwanted
- **Statement**: [EARS-format requirement]
- **Acceptance Criteria**:
  - [ ] Criterion 1
  - [ ] Criterion 2
- **Priority**: Must | Should | Could
- **Notes**: Additional context

### FR-2: ...

## Non-Functional Requirements

### NFR-1: [Requirement Title]
- **Category**: Performance | Security | Usability | Reliability | Accessibility
- **Statement**: [EARS-format requirement]
- **Acceptance Criteria**:
  - [ ] Criterion 1
- **Priority**: Must | Should | Could

## Constraints
- Technical constraints
- Business constraints

## Assumptions
- What we're assuming to be true

## Edge Cases
- Edge case 1: How it should be handled
- Edge case 2: How it should be handled
```

## Instructions

1. Be thorough - capture all requirements implied by the PRD
2. Include edge cases and error scenarios
3. Make acceptance criteria specific and testable
4. Consider accessibility and performance requirements
5. Keep requirements atomic (one requirement = one thing)

After generating requirements, display them and ask the user to review before proceeding to `/kiro:spec-design`.

**IMPORTANT**: Wait for explicit user approval before proceeding to the design phase.
