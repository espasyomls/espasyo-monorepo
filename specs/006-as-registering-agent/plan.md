# Implementation Plan: Agent Registration and Verification Flow

**Branch**: `006-as-registering-agent` | **Date**: 2025-10-14 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/006-as-registering-agent/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Implement a complete agent registration and verification workflow that allows prospective agents to register via Google OAuth, complete their professional profile, submit verification documents, and gain full platform access once verified by administrators. The system supports iterative review with admins able to return applications for revisions unlimited times until satisfied. Technical approach: Build with Next.js 15 App Router, shadcn/ui components, NextAuth.js for Google OAuth, Zustand for state management, React Hook Form for multi-step forms, and RESTful API routes for backend operations, with comprehensive role-based access control and document management.

## Technical Context

**Language/Version**: TypeScript 5.x with Next.js 15 (App Router)  
**Primary Dependencies**: NextAuth.js 5.x, shadcn/ui, React Hook Form, Zustand, Framer Motion  
**Storage**: PostgreSQL (for user/agent data), S3-compatible storage via LocalStack (for document uploads)  
**Testing**: Vitest for unit/integration tests, Contract tests for API validation  
**Target Platform**: Web (mobile-first responsive design, 99% mobile browser compatibility)  
**Project Type**: Web application (frontend Next.js + backend Go microservices)  
**Performance Goals**: <60s registration flow, <2s page loads, <5min profile completion, 100 concurrent users  
**Constraints**: 30-minute session timeout, 5MB max file upload per document, PDF/JPG/PNG only  
**Scale/Scope**: Multi-step form with draft persistence, role-based dashboards (agent/admin), public agent directory with SEO optimization

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| **Domain-Driven Organization** | ✅ PASS | Feature spans frontend (espasyo-frontend) and backend (future agent microservice), following domain separation |
| **Specification-First Development** | ✅ PASS | Comprehensive spec.md with 6 clarifications documented, 5 user stories, 60+ functional requirements |
| **Schema Validation** | ✅ PASS | All spec documents follow SpecKit templates and validation |
| **Separation of Concerns** | ✅ PASS | Clear separation: UI (Next.js), auth (NextAuth.js), API (Next.js routes), future backend (Go microservices) |
| **Documentation and Transparency** | ✅ PASS | Comprehensive specification with clarifications, assumptions, and out-of-scope items documented |
| **Complete Tech Stack** | ✅ PASS | Uses Next.js 15, TypeScript, shadcn/ui, TailwindCSS, Zustand, NextAuth.js per constitution |
| **AWS & Cost Optimization** | ✅ PASS | Uses S3-compatible storage, designed for cost-effective AWS deployment |
| **Local Development** | ✅ PASS | LocalStack for S3 emulation, Docker Compose for local orchestration |
| **Troubleshooting Philosophy** | ✅ PASS | Root cause analysis approach, documented edge cases (12 scenarios) |
| **Amendment Process** | ✅ PASS | No constitution amendments required |
| **Governance** | ✅ PASS | Follows peer review and compliance requirements |
| **Six Sigma Quality** | ✅ PASS | Committed to 100% test coverage, zero placeholders, zero failing tests from implementation start per Constitution Principle #13 |

**Overall Status**: ✅ **APPROVED** - All 13 gates passed, Six Sigma quality standard enforced

## Project Structure

### Documentation (this feature)

```
specs/006-as-registering-agent/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
│   ├── agent-registration-api.yaml
│   ├── agent-profile-api.yaml
│   ├── verification-api.yaml
│   └── admin-verification-api.yaml
├── checklists/
│   └── requirements.md  # Quality checklist (already created)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```
espasyo-frontend/
├── app/
│   ├── page.tsx                          # Landing page with "Become an Agent" button
│   ├── (auth)/
│   │   └── auth/
│   │       └── agent-register/
│   │           └── page.tsx              # Agent registration page
│   ├── (dashboard)/
│   │   └── dashboard/
│   │       └── agent/
│   │           ├── page.tsx              # Agent dashboard with profile/verification tabs
│   │           ├── profile/
│   │           │   └── page.tsx          # Agent profile page
│   │           └── verification/
│   │               └── page.tsx          # Verification flow page
│   ├── agents/
│   │   ├── page.tsx                      # Public verified agents directory
│   │   └── [id]/
│   │       └── page.tsx                  # Individual agent public profile
│   └── api/
│       ├── agent/
│       │   ├── profile/
│       │   │   └── route.ts              # Agent profile CRUD API
│       │   └── verification/
│       │       ├── route.ts              # Verification application submit/get
│       │       ├── draft/
│       │       │   └── route.ts          # Draft save/load API
│       │       └── resubmit/
│       │           └── route.ts          # Resubmission after rejection/return
│       ├── admin/
│       │   └── verification/
│       │       ├── route.ts              # List all verification applications
│       │       └── [id]/
│       │           ├── route.ts          # Get single application
│       │           └── review/
│       │               └── route.ts      # Approve/reject/return actions
│       └── public/
│           └── agents/
│               ├── route.ts              # Get verified agents list
│               └── [id]/
│                   └── route.ts          # Get agent public profile
├── src/
│   ├── components/
│   │   ├── auth/
│   │   │   ├── agent-registration-modal.tsx        # "Become an Agent" modal
│   │   │   ├── agent-profile-form.tsx              # Profile completion form
│   │   │   └── verification-flow.tsx               # Multi-step verification component
│   │   ├── agent/
│   │   │   ├── profile-completion-banner.tsx       # Intelligent profile prompt
│   │   │   ├── verification-status-card.tsx        # Status display
│   │   │   └── public-profile-card.tsx             # Agent card for directory
│   │   ├── admin/
│   │   │   ├── verification-review-panel.tsx       # Admin review interface
│   │   │   └── verification-actions.tsx            # Approve/reject/return buttons
│   │   └── ui/
│   │       └── [shadcn/ui components]
│   ├── lib/
│   │   ├── api/
│   │   │   ├── agent.ts                            # Agent API client functions
│   │   │   ├── verification.ts                     # Verification API client
│   │   │   └── admin.ts                            # Admin API client
│   │   ├── auth.config.ts                          # NextAuth configuration
│   │   ├── validation/
│   │   │   ├── profile-schema.ts                   # Zod schemas for profile
│   │   │   └── verification-schema.ts              # Zod schemas for verification
│   │   └── utils/
│   │       ├── document-upload.ts                  # File upload utilities
│   │       └── session-manager.ts                  # Session timeout handling
│   ├── stores/
│   │   ├── agent-store.ts                          # Zustand agent state
│   │   └── verification-store.ts                   # Zustand verification state
│   └── types/
│       ├── agent.ts                                # Agent types
│       ├── verification.ts                         # Verification types
│       └── admin.ts                                # Admin types
├── middleware.ts                                    # Session timeout, auth checks
└── __tests__/
    ├── contracts/
    │   ├── test-agent-registration-api.test.ts
    │   ├── test-verification-api.test.ts
    │   └── test-admin-api.test.ts
    ├── integration/
    │   ├── test-registration-flow.test.ts
    │   ├── test-verification-flow.test.ts
    │   └── test-admin-review-flow.test.ts
    └── unit/
        ├── test-profile-validation.test.ts
        ├── test-document-upload.test.ts
        └── test-session-timeout.test.ts

espasyo-backend/
└── repos/
    └── microservices/
        └── svc-agent/                                # Future: Agent microservice (Go)
            ├── cmd/
            ├── internal/
            │   ├── domain/
            │   │   ├── agent.go
            │   │   └── verification.go
            │   ├── handlers/
            │   └── repository/
            └── tests/

espasyo-infrastructure/
├── docker-compose.local.yml                         # LocalStack S3 for documents
└── localstack/
    └── init-scripts/
        └── create-agent-documents-bucket.sh
```

**Structure Decision**: Web application with Next.js frontend and future Go backend microservice. Agent registration, profile, and verification UI implemented in espasyo-frontend using App Router. API routes handle immediate needs while agent microservice (svc-agent) provides long-term scalability. Public agent directory uses Next.js for SEO-optimized pages. Document uploads managed via S3-compatible storage (LocalStack for local, AWS S3 for production).

## Complexity Tracking

*Fill ONLY if Constitution Check has violations that must be justified*

No complexity violations detected. All technical choices align with constitution:
- Using established tech stack (Next.js, TypeScript, shadcn/ui, NextAuth.js)
- Following domain-driven organization
- Leveraging existing patterns from specs/001 and specs/002
- No unnecessary abstractions or additional projects
- Standard patterns for role-based access control and file uploads
