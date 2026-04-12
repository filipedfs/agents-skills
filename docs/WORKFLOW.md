# AI-Driven Code Generation Workflow

This workflow optimizes AI agent coordination to reliably generate high-quality code. Each step is owned by a specialist agent, consumes documented input artifacts, and produces a concrete output artifact. Human review checkpoints ensure quality and alignment at each stage.

---

## Overview

| Phase | Step | Agent/Skill | Reads | Produces | Review |
|-------|------|-------------|-------|----------|--------|
| **Intake** | 1 | Prompter + `refine-prompt` skill | Raw user request | `PROMPT-{slug}.md` | ✅ Approve refined prompt |
| **Discovery** | 2 | Researcher | `PROMPT-{slug}.md` | `PRD-{slug}.md` | ✅ Approve scope & requirements |
| **Planning** | 3 | Architect | `PRD-{slug}.md` | `SPEC-{slug}.md` | ✅ Approve technical plan |
| **Execution** | 4 | Orchestrator → Builder | `PRD-{slug}.md`, `SPEC-{slug}.md` | Code + `STATUS-{slug}.md` | ✅ Per-increment review |
| **Validation** | 5 | Verifier | `PRD-{slug}.md`, `SPEC-{slug}.md`, code | `REVIEW-{slug}.md` | ✅ PASS → Done / FAIL → Rework |

---

## Detailed Workflow

### Phase 1: Intake — Refine Prompt

**Responsible Agent:** `Prompter`  
**Skill:** `refine-prompt` (CREATE framework)

#### Input
- Raw, unstructured user request in conversational language

#### Process
1. The Prompter receives the raw request from the user.
2. Applies the `refine-prompt` skill using the **CREATE framework**:
   - **C**ontext & Role: Define the AI's role and necessary background
   - **R**equest/Task: State the objective assertively with strong action verbs
   - **E**xamples: Provide or reference an example of desired outcome (if applicable)
   - **A**ssertive Constraints: State what must/must not be done, scope boundaries
   - **T**arget Audience: Specify who the output is for
   - **E**xpected Format: Define exact output structure
3. Generates a `kebab-case` slug for the task (e.g., `auth-token-refresh`, `customer-search-api`)
4. Saves the refined prompt to `.spec/features/{slug}/PROMPT-{slug}.md`

#### Output
- **`PROMPT-{slug}.md`** — Structured, assertion-ready prompt with zero ambiguity about the request
- **`{slug}`** — Task identifier used throughout the workflow

#### Human Review Checkpoint
- **Decision:** Approve the refined prompt and confirm the slug, or request clarification/revision
- **Criteria:** 
  - Is the request clear and well-scoped?
  - Does the slug reflect the work accurately?
  - Are there any ambiguities or missing context?

---

### Phase 2: Discovery — Research & Generate PRD

**Responsible Agent:** `Researcher`

#### Input
- `PROMPT-{slug}.md` (the refined, approved prompt)

#### Process
1. The Researcher reads `PROMPT-{slug}.md` as the canonical task definition.
2. Investigates the codebase, existing patterns, relevant documentation, and external dependencies.
3. Synthesizes findings into a complete, implementation-ready Product Requirements Document (PRD):
   - **Summary** of the request and intended outcome
   - **Problem Statement** — what problem is being solved and why it matters
   - **Goals** — concrete objectives the task should achieve
   - **Non-Goals** — what is explicitly not included
   - **User / Stakeholder Context** — who benefits and why
   - **Existing Context** — relevant files, current behavior, established patterns and constraints
   - **Scope** — in-scope and out-of-scope items
   - **Functional Requirements** — observable behaviors required
   - **Non-Functional Requirements** — performance, reliability, security, maintainability, observability, backward compatibility, etc.
   - **Data / API / Integration Considerations** — entities, payloads, contracts, external APIs, events
   - **Edge Cases** — identified edge cases and expected behavior
   - **Risks / Unknowns** — potential blockers, dependencies, assumptions
   - **Assumptions** — explicit assumptions made during discovery
   - **Open Questions** — unresolved items requiring clarification
   - **Acceptance Criteria** — testable conditions for success
   - **Notes for Architecture Phase** — hints for the Architect without prescribing the solution

#### Output
- **`PRD-{slug}.md`** — Complete, grounded product specification
- **`STATUS-{slug}.md`** — Initial status tracking (optional; updated by Orchestrator later)

#### Human Review Checkpoint
- **Decision:** Approve the PRD and scope, or request revisions/clarifications
- **Criteria:**
  - Are requirements clear and testable?
  - Does scope match the refined prompt?
  - Are assumptions and open questions documented?
  - Are acceptance criteria verifiable?

---

### Phase 3: Planning — Architecture & Generate SPEC

**Responsible Agent:** `Architect`

#### Input
- `PRD-{slug}.md` (the approved product specification)

#### Process
1. The Architect reads the PRD completely and validates scope.
2. Re-inspects the codebase to confirm the approach is feasible and aligned with existing architecture.
3. Develops a precise, implementation-ready technical specification:
   - **Summary** of the technical solution
   - **Reference PRD** — link to the approved PRD
   - **Technical Goals** — what the design must accomplish
   - **Non-Goals** — what the design intentionally avoids
   - **Relevant Existing Context** — existing files, architecture/patterns, constraints
   - **Proposed Approach** — overall implementation strategy
   - **File Plan** — each file: path, action (create/modify/delete), purpose, key changes
   - **Data Model / Contract Changes** — entity, DTO, and API contract changes
   - **Logic and Control Flow** — runtime behavior, step-by-step with pseudocode where helpful
   - **Interfaces and Boundaries** — component interactions, service boundaries, external integrations
   - **Error Handling Strategy** — failure detection, surfacing, logging
   - **Security / Permissions / Validation** — auth, authz, input validation, data exposure concerns
   - **Test Strategy** — required unit, integration, UI, API, regression tests
   - **Migration / Rollout / Backward Compatibility** — schema changes, feature flags, rollout sequence
   - **Risks and Tradeoffs** — design tradeoffs, fragile areas, technical risks, future refactor needs
   - **Builder Notes** — practical, execution-oriented guidance
   - **Verification Notes** — checks the Verifier should confirm
   - **Open Technical Questions** — unresolved technical decisions

4. If the task is large/complex, includes an **Increment Plan** defining:
   - Increment ID and name
   - Goal and scope for that increment
   - Dependencies (prior increments)
   - Expected affected areas
   - Review criteria

#### Output
- **`SPEC-{slug}.md`** — Complete, implementation-ready technical specification

#### Human Review Checkpoint
- **Decision:** Approve the technical plan, request design changes, or escalate architectural concerns
- **Criteria:**
  - Does the design satisfy the PRD?
  - Is the approach grounded in the real codebase?
  - Is the file plan precise and unambiguous?
  - Are risks and tradeoffs documented?
  - Is the plan safe and testable?
  - For large tasks: is the increment plan clear and well-sequenced?

---

### Phase 4: Execution — Build the Solution

**Responsible Agent:** `Orchestrator` → delegates to `Builder`

#### Input
- `PRD-{slug}.md` (approved product specification)
- `SPEC-{slug}.md` (approved technical specification)

#### Process

**For small tasks:**
1. The Orchestrator calls the Builder once with the full scope.
2. The Builder implements all required changes in a single pass.
3. Produces and reports:
   - Files created/modified/deleted
   - Validation results (tests, lint, typecheck)
   - Blockers or deviations from SPEC

**For large tasks:**
1. The Orchestrator initializes `STATUS-{slug}.md` and tracks increments.
2. The Orchestrator calls the Builder once per increment:
   - Provides only that increment's scope
   - Builder stays strictly within that scope
   - Builder reports files changed, validation, blockers
   - Orchestrator pauses for human review between increments
   - On user approval, moves to next increment
3. Orchestrator updates `STATUS-{slug}.md` after each increment.

#### Output
- **Implementation code** — files created/modified/deleted according to SPEC
- **`STATUS-{slug}.md`** — tracking: phase, current increment, blockers, assumptions, next step
- **Test results** — proof that tests pass

#### Human Review Checkpoint (after each increment for large tasks; once for small tasks)
- **Decision:** Approve and proceed to next increment/phase, request fixes, or escalate blockers
- **Criteria:**
  - Does the code match the SPEC?
  - Does it honor the PRD intent?
  - Are tests passing?
  - Are there unexpected changes or risks?
  - For large tasks: is this increment complete and coherent?

---

### Phase 5: Validation — Verify Solution

**Responsible Agent:** `Verifier` (optional; use when warranted)

#### Input
- `PRD-{slug}.md` (approved product specification)
- `SPEC-{slug}.md` (approved technical specification)
- Implemented code (from Build phase)

#### Process
1. The Verifier audits the implemented changes against the PRD and SPEC.
2. Verifies:
   - **Requirements coverage** — does code satisfy required behaviors?
   - **Technical compliance** — does code follow the SPEC, file plan, contracts, logic?
   - **Behavioral correctness** — does code work logically, including branches, validation, error cases?
   - **Regression safety** — is unchanged behavior preserved where required?
   - **Code quality and consistency** — does code fit the architecture and patterns?
   - **Risk detection** — are there fragile areas, missing checks, unsafe assumptions, missing test coverage?
3. Produces a structured review artifact with:
   - **Status: PASS or FAIL**
   - **Coverage map** — which requirements and specs are verified
   - **Issues found** — if any, with severity (critical/major/minor), location, and recommended fix
   - **Non-blocking observations** — suggestions that do not require FAIL
   - **Recommendations** — next action (accept / fix specific issues / escalate)

#### Output
- **`REVIEW-{slug}.md`** — Audit report with PASS/FAIL decision and findings

#### Human Review Checkpoint
- **Decision:** Accept the work (PASS) or return to Builder for rework (FAIL with specific issues)
- **Criteria:**
  - Is the review thorough and evidence-based?
  - Are issues actionable and concrete?
  - Is PASS/FAIL clearly justified?

---

## Artifact Storage Convention

All workflow artifacts live in a task-specific folder:

```
.spec/features/{slug}/
├── PROMPT-{slug}.md        (Step 1)
├── PRD-{slug}.md           (Step 2)
├── SPEC-{slug}.md          (Step 3)
├── STATUS-{slug}.md        (ongoing tracking)
└── REVIEW-{slug}.md        (Step 5, optional)
```

Example:
```
.spec/features/auth-token-refresh/
├── PROMPT-auth-token-refresh.md
├── PRD-auth-token-refresh.md
├── SPEC-auth-token-refresh.md
├── STATUS-auth-token-refresh.md
└── REVIEW-auth-token-refresh.md
```

---

## Rework Loops

If the Verifier returns **FAIL**, or if any step identifies a blocker:

- **Scope/requirement mismatch** → return to Researcher (revise PRD)
- **Design/decomposition issue** → return to Architect (revise SPEC)
- **Implementation defect** → return to Builder (revise code and re-run tests)

The Orchestrator routes rework back to the appropriate specialist. Do not restart the entire workflow unless fundamental assumptions have changed.

---

## When to Skip Phases (Small Tasks)

For very small, low-risk tasks (typo fixes, trivial refactors, minor config changes):
- **Skip to SPEC directly:** Prompter → skip PRD → Architect (compact) → Builder → (optional) Verifier
- **Or skip to Build:** Orchestrator creates lightweight SPEC inline and delegates to Builder
- Use judgment based on scope and risk

---

## Quality Gates by Phase

| Phase | Gate | Enforcer | Fail = Rework |
|-------|------|----------|---------------|
| Intake | Prompt clarity & scope | Human | Prompter revises PROMPT |
| Discovery | Requirements and scope | Human | Researcher revises PRD |
| Planning | Technical design and feasibility | Human | Architect revises SPEC |
| Execution | Code matches SPEC, tests pass | Orchestrator + Verifier | Builder fixes code |
| Validation | Compliance with PRD/SPEC | Verifier | Builder reworks or Architect revises |

---

## Best Practices for AI Agent Coordination

1. **Each artifact is a contract:** The downstream agent receives a complete, unambiguous artifact from the previous step.
2. **No lost context:** Each artifact includes sufficient context (references to prior artifacts, assumptions, constraints) so the next agent is never guessing.
3. **Explicit hand-offs:** After each human checkpoint, the user confirms the artifact and the workflow continues to the next phase.
4. **Incremental delivery for large tasks:** Break complex work into reviewable increments to catch issues early.
5. **Validate at every step:** Each agent self-checks their output before passing it downstream.
6. **Escalate early:** If a blocker is found, escalate to the right specialist rather than forcing a workaround.
7. **Test coverage is built in:** The SPEC defines test strategy; the Builder executes it; the Verifier audits it.
8. **Rework is cheap:** If verification fails, the feedback is concrete and actionable, and the Builder knows exactly what to fix.

