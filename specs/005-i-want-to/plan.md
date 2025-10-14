
# Implementation Plan: Progressive Agent Verification Flow

**Branch**: `005-i-want-to` | **Date**: 2025-10-12 | **Spec**: /home/boggss/espasyoMLS/specs/005-i-want-to/spec.md
**Input**: Feature specification from `/spe**Phase Status**Phase Status**:
- [x] Phase 0: Research complete (/plan command)
- [x] Phase 1: Design complete (/plan command)
- [x] Phase 2: Task planning complete (/tasks command - describe approach only)
- [x] Phase 3: Tasks generated (/tasks command)
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passedx] Phase 0: Research complete (/plan command)
- [x] Phase 1: Design complete (/plan command)
- [x] Phase 2: Task planning complete (/tasks command - describe approach only)
- [ ] Phase 3: Tasks generated (/tasks command)
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passedi-want-to/spec.md`

## Execution Flow (/plan command scope)
```
1. Load feature spec from Input path
   → If not found: ERROR "No feature spec at {path}"
2. Fill Technical Context (scan for NEEDS CLARIFICATION)
   → Detect Project Type from file system structure or context (web=frontend+backend, mobile=app+api)
   → Set Structure Decision based on project type
3. Fill the Constitution Check section based on the content of the constitution document.
4. Evaluate Constitution Check section below
   → If violations exist: Document in Complexity Tracking
   → If no justification possible: ERROR "Simplify approach first"
   → Update Progress Tracking: Initial Constitution Check
5. Execute Phase 0 → research.md
   → If NEEDS CLARIFICATION remain: ERROR "Resolve unknowns"
6. Execute Phase 1 → contracts, data-model.md, quickstart.md, agent-specific template file (e.g., `CLAUDE.md` for Claude Code, `.github/copilot-instructions.md` for GitHub Copilot, `GEMINI.md` for Gemini CLI, `QWEN.md` for Qwen Code, or `AGENTS.md` for all other agents).
7. Re-evaluate Constitution Check section
   → If new violations: Refactor design, return to Phase 1
   → Update Progress Tracking: Post-Design Constitution Check
8. Plan Phase 2 → Describe task generation approach (DO NOT create tasks.md)
9. STOP - Ready for /tasks command
```

**IMPORTANT**: The /plan command STOPS at step 7. Phases 2-4 are executed by other commands:
- Phase 2: /tasks command creates tasks.md
- Phase 3-4: Implementation execution (manual or via tools)

## Summary
Implement a progressive agent verification flow where agents authenticate via Gmail, access their dashboard, and complete verification incrementally through a "Verify Me" tab with draft saving capabilities, while administrators can review and request additional documents.

## Technical Context
**Language/Version**: TypeScript (ES2022)  
**Primary Dependencies**: Next.js 15 (App Router), NextAuth.js, React Hook Form, Zod, shadcn/ui, TailwindCSS, Zustand  
**Storage**: In-memory storage for development, PostgreSQL for production  
**Testing**: Vitest  
**Target Platform**: Web browsers (99% compatibility)  
**Project Type**: Web application (frontend + backend)  
**Performance Goals**: <2s page load times, <500ms API responses  
**Constraints**: OAuth 2.0 with minimal Gmail data collection, 30-day draft retention, 1-year application retention  
**Scale/Scope**: Support for multiple concurrent verification applications, admin review workflow

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Compliance Status**: PASS - All constitutional requirements met

**Principle Compliance**:
- ✅ **Domain-Driven Organization**: Feature implemented in espasyo-frontend domain
- ✅ **Specification-First Development**: Complete feature specification created and clarified
- ✅ **Complete Tech Stack**: Using approved Next.js 15, TypeScript, shadcn/ui, TailwindCSS, NextAuth.js
- ✅ **Local Development**: Frontend runs in Docker containers as required
- ✅ **Six Sigma Quality Standard**: Implementation will achieve 100% test coverage with Vitest
- ✅ **Workflow Summary**: Following spec → plan → tasks → implementation sequence

**No violations detected requiring complexity justification.**

## Project Structure

### Documentation (this feature)
```
specs/[###-feature]/
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (/plan command)
├── data-model.md        # Phase 1 output (/plan command)
├── quickstart.md        # Phase 1 output (/plan command)
├── contracts/           # Phase 1 output (/plan command)
└── tasks.md             # Phase 2 output (/tasks command - NOT created by /plan)
```

### Source Code (repository root)
```
# Web application structure (frontend + backend detected)
espasyo-frontend/
├── app/
│   ├── api/
│   │   ├── agent/
│   │   │   ├── verification/
│   │   │   │   ├── draft/
│   │   │   │   │   └── route.ts          # Draft save/load API
│   │   │   │   └── route.ts              # Application submission API
│   │   │   └── locations/
│   │   │       ├── provinces/
│   │   │       │   └── route.ts          # Province data API
│   │   │       └── municipalities/
│   │   │           └── route.ts          # Municipality data API
│   │   └── admin/
│   │       └── agent-verifications/
│   │           ├── route.ts              # Admin verification list API
│   │           └── [id]/
│   │               └── review/
│   │                   └── route.ts      # Admin review API
│   ├── dashboard/
│   │   └── agent/
│   │       └── page.tsx                 # Agent dashboard with Verify Me tab
│   └── auth/
│       └── agent-register/
│           └── page.tsx                 # Agent registration redirect
├── src/
│   ├── components/
│   │   ├── auth/
│   │   │   ├── progressive-verification-form.tsx  # Main verification component
│   │   │   └── steps/
│   │   │       ├── agent-info-step.tsx   # Personal info step
│   │   │       ├── document-upload-step.tsx  # Document upload step
│   │   │       └── service-area-step.tsx # Service area selection step
│   │   └── ui/                          # shadcn/ui components
│   ├── types/
│   │   └── dashboard.ts                 # TypeScript type definitions
│   └── lib/
│       └── auth.ts                      # NextAuth configuration
└── tests/
    ├── unit/
    ├── integration/
    └── contract/

espasyo-backend/
└── [microservices handling data persistence]
```

**Structure Decision**: Web application structure selected due to frontend/backend separation. Frontend handles UI and client-side logic, backend handles data persistence and business rules. APIs follow REST conventions with proper error handling.

## Phase 0: Outline & Research
1. **Extract unknowns from Technical Context** above:
   - For each NEEDS CLARIFICATION → research task
   - For each dependency → best practices task
   - For each integration → patterns task

2. **Generate and dispatch research agents**:
   ```
   For each unknown in Technical Context:
     Task: "Research {unknown} for {feature context}"
   For each technology choice:
     Task: "Find best practices for {tech} in {domain}"
   ```

3. **Consolidate findings** in `research.md` using format:
   - Decision: [what was chosen]
   - Rationale: [why chosen]
   - Alternatives considered: [what else evaluated]

**Output**: research.md with all NEEDS CLARIFICATION resolved

## Phase 1: Design & Contracts
*Prerequisites: research.md complete*

1. **Extract entities from feature spec** → `data-model.md`:
   - Entity name, fields, relationships
   - Validation rules from requirements
   - State transitions if applicable

2. **Generate API contracts** from functional requirements:
   - For each user action → endpoint
   - Use standard REST/GraphQL patterns
   - Output OpenAPI/GraphQL schema to `/contracts/`

3. **Generate contract tests** from contracts:
   - One test file per endpoint
   - Assert request/response schemas
   - Tests must fail (no implementation yet)

4. **Extract test scenarios** from user stories:
   - Each story → integration test scenario
   - Quickstart test = story validation steps

5. **Update agent file incrementally** (O(1) operation):
   - Run `.specify/scripts/bash/update-agent-context.sh copilot`
     **IMPORTANT**: Execute it exactly as specified above. Do not add or remove any arguments.
   - If exists: Add only NEW tech from current plan
   - Preserve manual additions between markers
   - Update recent changes (keep last 3)
   - Keep under 150 lines for token efficiency
   - Output to repository root

**Output**: data-model.md, /contracts/*, failing tests, quickstart.md, agent-specific file

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:
- Load `.specify/templates/tasks-template.md` as base
- Generate tasks from Phase 1 design docs (contracts, data model, quickstart)
- Each API contract → contract test task [P] (parallel)
- Each entity → model creation task [P]
- Each user story scenario → integration test task
- Implementation tasks to make tests pass, organized by component

**Ordering Strategy**:
- TDD order: Tests before implementation
- Dependency order: Core types → API routes → Components → Integration
- Mark [P] for parallel execution (independent files)
- Sequential for interdependent features (auth before verification)

**Estimated Output**: 41 numbered, ordered tasks in tasks.md covering:
- Setup tasks (4 tasks): Auth config, types, file handling, storage
- Test tasks (9 tasks): 4 contract tests + 5 integration tests
- Core tasks (15 tasks): Type definitions, API routes, React components
- Integration tasks (5 tasks): State management, validation, security
- Polish tasks (8 tasks): Unit tests, performance, documentation

**IMPORTANT**: This phase is executed by the /tasks command, NOT by /plan

**IMPORTANT**: This phase is executed by the /tasks command, NOT by /plan

## Phase 3+: Future Implementation
*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)  
**Phase 4**: Implementation (execute tasks.md following constitutional principles)  
**Phase 5**: Validation (run tests, execute quickstart.md, performance validation)

## Complexity Tracking
*Fill ONLY if Constitution Check has violations that must be justified*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |


## Progress Tracking
*This checklist is updated during execution flow*

**Phase Status**:
- [ ] Phase 0: Research complete (/plan command)
- [ ] Phase 1: Design complete (/plan command)
- [ ] Phase 2: Task planning complete (/plan command - describe approach only)
- [ ] Phase 3: Tasks generated (/tasks command)
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [x] Initial Constitution Check: PASS
- [x] Post-Design Constitution Check: PASS
- [x] All NEEDS CLARIFICATION resolved
- [ ] Complexity deviations documented

---
*Based on Constitution v2.1.1 - See `/memory/constitution.md`*
