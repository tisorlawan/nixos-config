---
name: complexity
description: Analyze code complexity in files or directories. Identifies accidental complexity (reducible/eliminable) vs essential complexity (inherent to the problem). Outputs prioritized recommendations to a markdown report. Use when user asks to analyze complexity, review code quality, identify technical debt, or find simplification opportunities.
---

# Complexity Analysis

Analyze code complexity, distinguishing accidental from essential complexity, with actionable recommendations.

## Definitions

**Accidental complexity**: Complexity from implementation choices, not the problem itself. Examples: unnecessary abstractions, over-engineering, redundant code, poor naming, convoluted control flow.

**Essential complexity**: Inherent to the problem domain. Cannot be eliminated, only managed. Examples: business rules, domain logic, regulatory requirements, algorithmic constraints.

## Workflow

### 1. Scope Identification

Determine target:

- Single file: analyze that file
- Directory/module: identify key files, analyze each, then synthesize

### 2. Analysis Process

For each code unit:

1. **Read and understand** the code's purpose
2. **Identify accidental complexity**:
   - Unnecessary abstractions/indirection
   - Code duplication
   - Over-engineering (features not needed)
   - Poor separation of concerns
   - Convoluted logic that could be simplified
   - Inconsistent patterns
   - Dead code
3. **Identify essential complexity**:
   - Core business logic
   - Domain rules that must exist
   - Algorithmic requirements
   - External constraints (APIs, protocols)

### 3. Recommendations

For **accidental complexity**:

- Recommend elimination or reduction
- Provide concrete refactoring suggestions
- Estimate effort (low/medium/high)

For **essential complexity**:

- Recommend isolation strategies
- Suggest simplification approaches
- Propose robustness improvements
- Identify testing strategies

### 4. Priority Assignment

Assign priority (P0-P3) based on:

- **P0 (Critical)**: Blocks development, causes bugs, high maintenance burden
- **P1 (High)**: Significant impact on readability/maintainability
- **P2 (Medium)**: Moderate improvement opportunity
- **P3 (Low)**: Minor enhancement, nice-to-have

### 5. Report Generation

Write report to `complexity-report.md` in cwd.
