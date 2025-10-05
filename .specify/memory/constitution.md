<!--
Sync Impact Report

Version change: none → 1.0.0

List of modified principles: none (all new)

Added sections: Project Overview

Removed sections: Additional Constraints, Development Workflow

Templates requiring updates: none

Follow-up TODOs: RATIFICATION_DATE deferred
-->

# EspasyoMLS Constitution

## Project Overview

EspasyoMLS is a comprehensive real estate listing and management platform inspired by housesigma.com, adapted and tailored for the Philippine market. The project aims to provide a modern, scalable, and efficient solution for property search, listing management, agent workflows, and related real estate services, leveraging best practices in software architecture and cloud-native development.

## Core Principles

### 1. Domain-Driven Organization

EspasyoMLS is organized into clear domains (backend, frontend, infrastructure, etc.), each with its own .specify folder containing templates, schemas, and this constitution. All repositories and subprojects within a domain must follow these shared standards.

### 2. Specification-First Development

Every new feature, change, or task begins with a specification document, using the templates and schemas defined in the domain's .specify folder. No implementation starts without an approved, validated spec.

### 3. Schema Validation

All specification files (YAML, JSON, Markdown) are validated against schemas provided in .specify using spec-kit. This ensures documentation and plans are always structured, complete, and machine-checked.

### 4. Separation of Concerns

Each repository or microservice is responsible for its own implementation, but must always align with the domain's constitution and templates.

### 5. Documentation and Transparency

All major architectural decisions, workflows, and processes are documented and accessible in espasyo-docs. Transparency and clear communication are core values.

### 6. Complete Tech Stack

The EspasyoMLS project uses the following technologies and practices, as documented:

Backend:

Language: Go (Golang)
Microservices architecture (see microservices.txt and service-specific docs)
Database: PostgreSQL
Cache: Redis
Containerization: Docker (all services must run in containers for local development)
Local orchestration: Docker Compose
AWS for production deployment, with cost-effectiveness as a guiding principle
LocalStack for AWS service emulation in local development
Infrastructure as Code: Terraform
CI/CD: GitHub Actions
Schema validation: spec-kit
Frontend:

Framework: Next.js (App Router)
Language: TypeScript
UI Components: shadcn/ui (for all components, themes, and styling)
Styling: TailwindCSS
State Management: Zustand
No use of Radix or other UI libraries unless explicitly approved
Other:

All documentation is in Markdown and maintained in espasyo-docs
All contributors must ensure compatibility with this stack

### 7. AWS & Cost Optimization Principles

All deployments and infrastructure choices must prioritize cost-effectiveness within AWS.
Use managed AWS services (e.g., RDS, ElastiCache, S3) where they reduce operational overhead and cost.
Regularly review AWS usage and billing to identify and eliminate unnecessary expenses.
Prefer serverless or on-demand resources where appropriate to minimize idle costs.

### 8. Local Development Principle

Every service and component must be fully runnable in local development using Docker containers.
AWS services must be mimicked locally using LocalStack, and this setup must be maintained and tested as part of the development workflow.

### 9. Troubleshooting Philosophy and LLM Guard Rails

Always seek to understand the root cause before proposing solutions.
Avoid quick, surface-level fixes ("knee-jerk reflexes").
Consult logs, documentation, and relevant specs before making changes.
Document the reasoning behind any fix or suggestion.
Prefer solutions that align with project architecture and the documented tech stack.
All contributors and AI assistants must follow these guidelines to ensure robust, maintainable solutions.

### 10. Amendment Process

Any changes to this constitution or the templates must be proposed, reviewed, and approved according to our governance workflow.
When the constitution or templates change, all dependent specs and plans must be updated to stay in sync.

### 11. Governance

Domain leads are responsible for maintaining the constitution and templates.
Amendments require consensus among domain leads and affected contributors.
Every contributor is expected to understand and follow this constitution.

### 12. Workflow Summary

All work starts with a spec, plan, or task list using the provided templates.
Specs and plans are validated before implementation.
Implementation references the relevant specs.
All changes are peer-reviewed for compliance with this constitution.

## Governance
<!-- Example: Constitution supersedes all other practices; Amendments require documentation, approval, migration plan -->

Amendment procedure: Any changes to this constitution or the templates must be proposed, reviewed, and approved according to our governance workflow. When the constitution or templates change, all dependent specs and plans must be updated to stay in sync.

Versioning policy: Constitution version follows semantic versioning: MAJOR for backward incompatible governance/principle removals or redefinitions, MINOR for new principle/section added or materially expanded guidance, PATCH for clarifications, wording, typo fixes, non-semantic refinements.

Compliance review expectations: All PRs/reviews must verify compliance; Complexity must be justified; Use guidance for runtime development guidance.

**Version**: 1.0.0 | **Ratified**: TODO(RATIFICATION_DATE): Original adoption date unknown, set to 2025-10-03 | **Last Amended**: 2025-10-03