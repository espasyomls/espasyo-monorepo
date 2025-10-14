# Research: Agent Registration and Verification Flow

**Feature**: Agent Registration and Verification Flow  
**Branch**: 006-as-registering-agent  
**Date**: 2025-10-14

## Purpose

This document resolves all technical unknowns and research questions for implementing the agent registration and verification workflow. It provides decisions, rationales, and alternatives considered for each technical aspect.

## Research Questions & Findings

### 1. Multi-Step Form with Draft Persistence

**Question**: How to implement a multi-step verification form with reliable draft persistence that survives session timeouts and browser closes?

**Decision**: Use React Hook Form with custom wizard state management backed by API-persisted drafts

**Rationale**:
- React Hook Form provides excellent validation and form state management per step
- Custom wizard component manages step progression and overall state
- Server-side draft storage ensures data survives browser close/session timeout
- LocalStorage can cache draft for offline resilience before API sync
- Pattern already established in existing codebase (agent-onboarding-wizard.tsx)

**Alternatives Considered**:
- **Formik multi-step**: Rejected - heavier bundle size, less TypeScript-friendly
- **Pure LocalStorage**: Rejected - doesn't survive device changes, no audit trail
- **Redux Form**: Rejected - unnecessary complexity for this use case, not in tech stack

**Implementation Pattern**:
```typescript
// Custom hook for draft management
const useVerificationDraft = () => {
  const saveDraft = async (stepData) => {
    await fetch('/api/agent/verification/draft', {
      method: 'POST',
      body: JSON.stringify({ stepData, currentStep })
    })
  }
  
  const loadDraft = async () => {
    const response = await fetch('/api/agent/verification/draft')
    return response.json()
  }
  
  return { saveDraft, loadDraft, autoSave: debounce(saveDraft, 2000) }
}
```

---

### 2. Document Upload with Security and Validation

**Question**: How to securely handle document uploads (PRC license, ID, certifications) with proper validation, virus scanning, and storage?

**Decision**: Client-side pre-validation + signed upload URLs + S3-compatible storage with server-side post-processing

**Rationale**:
- Client-side validation (file type, size) provides immediate feedback
- Signed upload URLs prevent direct S3 exposure
- S3-compatible storage (LocalStack local, AWS S3 production) aligns with infrastructure
- Server-side processing validates uploaded files asynchronously
- Immutable storage for audit compliance (files never deleted, only marked)

**Alternatives Considered**:
- **Direct form upload to API**: Rejected - large file sizes could timeout API routes, memory intensive
- **Base64 encoding**: Rejected - inefficient for 5MB files, bloats JSON payloads
- **Third-party service (Uploadcare)**: Rejected - adds external dependency, cost, not in constitution

**Implementation Pattern**:
```typescript
// Client-side upload flow
const uploadDocument = async (file: File, type: DocumentType) => {
  // 1. Client-side validation
  if (file.size > 5 * 1024 * 1024) throw new Error('File too large')
  if (!['application/pdf', 'image/jpeg', 'image/png'].includes(file.type)) {
    throw new Error('Invalid file type')
  }
  
  // 2. Request signed URL
  const { uploadUrl, documentId } = await fetch('/api/agent/verification/upload-url', {
    method: 'POST',
    body: JSON.stringify({ fileName: file.name, fileType: file.type, documentType: type })
  }).then(r => r.json())
  
  // 3. Upload to S3
  await fetch(uploadUrl, {
    method: 'PUT',
    body: file,
    headers: { 'Content-Type': file.type }
  })
  
  // 4. Confirm upload
  await fetch(`/api/agent/verification/documents/${documentId}/confirm`, {
    method: 'POST'
  })
  
  return documentId
}
```

**Security Measures**:
- File type validation (MIME type + extension check)
- Size limits enforced client and server-side
- Signed URLs with short expiration (15 minutes)
- S3 bucket policy: no public access
- Server-side virus scanning (future enhancement with ClamAV)
- Audit log for all document operations

---

### 3. Session Timeout with Form Data Preservation

**Question**: How to handle 30-minute session timeout without losing unsaved form data?

**Decision**: Middleware-based timeout detection + automatic draft save + session restore with data recovery

**Rationale**:
- Middleware tracks last activity timestamp
- Auto-save mechanism (debounced) persists draft every 2 seconds of inactivity
- On timeout, user is redirected to login with callback URL
- After re-authentication, draft is automatically restored
- Provides seamless UX while maintaining security

**Alternatives Considered**:
- **No auto-save**: Rejected - poor UX, data loss frustration
- **Longer session (60min)**: Rejected - violates security requirements from clarification
- **Session extension on activity**: Considered but rejected - complicates timeout enforcement

**Implementation Pattern**:
```typescript
// Middleware (middleware.ts)
export async function middleware(request: NextRequest) {
  const session = await getSession(request)
  
  if (!session) {
    const callbackUrl = request.nextUrl.pathname
    return NextResponse.redirect(new URL(`/api/auth/signin?callbackUrl=${callbackUrl}`, request.url))
  }
  
  const lastActivity = session.lastActivity
  const now = Date.now()
  
  if (now - lastActivity > 30 * 60 * 1000) { // 30 minutes
    await signOut()
    return NextResponse.redirect(new URL(`/api/auth/signin?timeout=true&callbackUrl=${callbackUrl}`, request.url))
  }
  
  // Update last activity
  await updateSessionActivity(session.id)
  
  return NextResponse.next()
}

// Auto-save hook
const useAutoSave = (formData) => {
  const debouncedSave = useMemo(
    () => debounce(async (data) => {
      await saveDraft(data)
    }, 2000),
    []
  )
  
  useEffect(() => {
    debouncedSave(formData)
  }, [formData, debouncedSave])
}
```

---

### 4. Role-Based Access Control for Admin Verification

**Question**: How to implement secure role-based access for admin verification review functionality?

**Decision**: NextAuth.js role claims + middleware protection + API-level authorization checks

**Rationale**:
- Extends existing NextAuth.js implementation
- Roles stored in user session JWT
- Middleware blocks unauthorized dashboard access
- API routes double-check roles (defense in depth)
- Aligns with clarification: "admin" or "verification_admin" roles

**Alternatives Considered**:
- **Separate admin auth system**: Rejected - unnecessary complexity, duplicate auth
- **Permission-based (granular)**: Deferred - role-based sufficient for MVP, can evolve later
- **Email whitelist**: Rejected - not scalable, hard to manage

**Implementation Pattern**:
```typescript
// Auth config extension (auth.config.ts)
callbacks: {
  async jwt({ token, user }) {
    if (user) {
      token.role = user.role // 'agent', 'admin', 'verification_admin'
    }
    return token
  },
  async session({ session, token }) {
    session.user.role = token.role
    return session
  }
}

// Middleware protection
export async function middleware(request: NextRequest) {
  const session = await auth()
  
  if (request.nextUrl.pathname.startsWith('/dashboard/admin')) {
    if (!['admin', 'verification_admin'].includes(session?.user?.role)) {
      return NextResponse.redirect(new URL('/dashboard', request.url))
    }
  }
  
  return NextResponse.next()
}

// API route authorization
export async function POST(request: NextRequest) {
  const session = await auth()
  
  if (!['admin', 'verification_admin'].includes(session?.user?.role)) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 403 })
  }
  
  // Process verification review...
}
```

---

### 5. Public Agent Directory with SEO Optimization

**Question**: How to build a public agent directory that is SEO-friendly, performant, and supports future filtering/search?

**Decision**: Next.js Server Components with static generation + incremental static regeneration (ISR)

**Rationale**:
- Server Components enable SEO-friendly HTML rendering
- Static generation for verified agents list provides instant load times
- ISR (revalidate: 60) keeps data fresh without rebuild
- Individual agent profiles generated on-demand and cached
- Supports future client-side filtering without rebuild

**Alternatives Considered**:
- **Client-side only (CSR)**: Rejected - poor SEO, slower initial load
- **Full static generation (SSG)**: Rejected - requires rebuild for each new agent
- **Server-side rendering (SSR)**: Rejected - unnecessary server load for mostly static content

**Implementation Pattern**:
```typescript
// app/agents/page.tsx
export const revalidate = 60 // Revalidate every 60 seconds

export default async function AgentsPage() {
  const agents = await fetch('http://localhost:3000/api/public/agents', {
    next: { revalidate: 60 }
  }).then(r => r.json())
  
  return (
    <div>
      <h1>Verified Real Estate Agents</h1>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {agents.map(agent => (
          <AgentCard key={agent.id} agent={agent} />
        ))}
      </div>
    </div>
  )
}

// app/agents/[id]/page.tsx
export async function generateMetadata({ params }): Promise<Metadata> {
  const agent = await fetchAgent(params.id)
  
  return {
    title: `${agent.name} - Verified Real Estate Agent`,
    description: agent.bio.substring(0, 160),
    openGraph: {
      title: agent.name,
      description: agent.bio,
      images: [agent.photo],
    }
  }
}

export default async function AgentProfilePage({ params }) {
  const agent = await fetchAgent(params.id)
  const listings = await fetchAgentListings(params.id)
  
  return (
    <div>
      <AgentProfile agent={agent} />
      <AgentListings listings={listings} />
    </div>
  )
}
```

**SEO Considerations**:
- Semantic HTML with proper heading hierarchy
- Meta tags with agent info and image
- Structured data (JSON-LD) for rich snippets
- Canonical URLs for each agent
- Image optimization with Next.js Image component

---

### 6. Verification Status Lifecycle Management

**Question**: How to manage the verification status lifecycle with multiple possible states and transitions?

**Decision**: Finite state machine pattern with explicit transitions and audit logging

**Rationale**:
- Clear state transitions prevent invalid states
- Audit log tracks all status changes with reasons
- Supports unlimited return cycles per clarification
- Enables analytics on verification metrics
- Type-safe implementation with TypeScript enums

**States**:
- `pending` → Initial state after registration
- `under_review` → After submission by agent
- `returned_for_revisions` → Admin requests changes (unlimited cycles)
- `approved` → Admin approves, agent becomes verified
- `rejected` → Admin rejects, agent can resubmit from scratch

**Transitions**:
```typescript
type VerificationStatus = 
  | 'pending'
  | 'under_review'
  | 'returned_for_revisions'
  | 'approved'
  | 'rejected'

const validTransitions: Record<VerificationStatus, VerificationStatus[]> = {
  'pending': ['under_review'], // Agent submits
  'under_review': ['approved', 'rejected', 'returned_for_revisions'], // Admin actions
  'returned_for_revisions': ['under_review'], // Agent resubmits
  'rejected': ['under_review'], // Agent resubmits (new attempt)
  'approved': [] // Terminal state
}

function transitionStatus(
  currentStatus: VerificationStatus,
  newStatus: VerificationStatus,
  reason?: string
): void {
  if (!validTransitions[currentStatus].includes(newStatus)) {
    throw new Error(`Invalid transition from ${currentStatus} to ${newStatus}`)
  }
  
  // Update status
  updateVerificationStatus(newStatus)
  
  // Log transition
  logStatusChange({
    from: currentStatus,
    to: newStatus,
    reason,
    timestamp: new Date(),
    actor: getCurrentUser()
  })
}
```

---

### 7. Admin Feedback Mechanism for Returned Applications

**Question**: How to present admin feedback when applications are returned for revisions?

**Decision**: Structured feedback with field-specific comments + general notes + action items

**Rationale**:
- Field-specific feedback helps agents know exactly what to fix
- General notes provide context
- Action items create checklist for agent to follow
- Feedback persists across resubmissions for reference
- Supports both approval and return scenarios

**Implementation Pattern**:
```typescript
interface AdminFeedback {
  general: string                       // Overall feedback
  fieldComments: {
    [field: string]: string             // Specific field issues
  }
  actionItems: string[]                 // Checklist for agent
  returnCount: number                   // How many times returned
  reviewer: {
    id: string
    name: string
    timestamp: Date
  }
}

// In verification-flow component
function FeedbackDisplay({ feedback }: { feedback: AdminFeedback }) {
  return (
    <Alert variant="warning">
      <AlertCircle className="h-4 w-4" />
      <AlertTitle>Action Required</AlertTitle>
      <AlertDescription>
        <p>{feedback.general}</p>
        
        {Object.keys(feedback.fieldComments).length > 0 && (
          <div className="mt-4">
            <h4 className="font-semibold">Field-Specific Issues:</h4>
            <ul>
              {Object.entries(feedback.fieldComments).map(([field, comment]) => (
                <li key={field}>
                  <strong>{field}:</strong> {comment}
                </li>
              ))}
            </ul>
          </div>
        )}
        
        {feedback.actionItems.length > 0 && (
          <div className="mt-4">
            <h4 className="font-semibold">Required Actions:</h4>
            <ul className="list-disc pl-5">
              {feedback.actionItems.map((item, idx) => (
                <li key={idx}>{item}</li>
              ))}
            </ul>
          </div>
        )}
      </AlertDescription>
    </Alert>
  )
}
```

---

## Technical Approach Summary

**Frontend Architecture**:
- Next.js 15 App Router for routing and pages
- React Hook Form for multi-step form validation
- shadcn/ui components (Dialog, Form, Button, Card, Progress, Alert)
- TailwindCSS for styling with mobile-first approach
- Framer Motion for step transitions
- Zustand for global state (agent profile, verification status)

**Authentication & Authorization**:
- NextAuth.js 5 for Google OAuth
- JWT-based sessions with role claims
- Middleware for route protection and session timeout
- Role-based access control (agent, admin, verification_admin)
- Session timeout: 30 minutes with auto-save preservation

**Data Management**:
- API routes for immediate functionality
- PostgreSQL for structured data (agents, profiles, verifications)
- S3-compatible storage for documents (LocalStack local, AWS S3 production)
- Draft persistence with audit trail
- Finite state machine for verification lifecycle

**File Upload Strategy**:
- Client-side validation (type, size)
- Signed upload URLs for security
- Direct S3 upload (bypasses API for large files)
- Server-side confirmation and metadata storage
- Immutable storage for compliance (never delete, only mark)

**Performance Optimizations**:
- ISR for public agent directory (60s revalidation)
- Server Components for SEO and initial load
- Debounced auto-save (2s) to reduce API calls
- Optimistic UI updates for better perceived performance
- Code splitting with dynamic imports

**SEO Strategy**:
- Server-side rendering for agent profiles
- Semantic HTML and proper meta tags
- JSON-LD structured data for rich snippets
- Image optimization with Next.js Image
- Canonical URLs and sitemap generation

**Testing Strategy**:
- Vitest for unit tests (validation, utilities)
- Contract tests for API routes (request/response validation)
- Integration tests for full flows (registration → verification → approval)
- E2E tests for critical paths (Playwright)
- 100% test coverage for Six Sigma compliance

## Dependencies and Libraries

**Core Dependencies** (Already in Project):
- Next.js 15+
- React 18+
- TypeScript 5+
- NextAuth.js 5+
- shadcn/ui components
- TailwindCSS
- Zustand
- Framer Motion

**New Dependencies** (To Install):
- `react-hook-form` - Multi-step form management
- `@hookform/resolvers` - Zod integration for RHF
- `zod` - Schema validation (may already exist)
- `date-fns` - Date formatting and calculations
- `lodash.debounce` - Auto-save debouncing

**Dev Dependencies**:
- Vitest (already installed)
- @testing-library/react (already installed)
- @testing-library/user-event
- msw (Mock Service Worker for API mocking)

## Risks and Mitigation

| Risk | Impact | Mitigation |
|------|--------|-----------|
| Session timeout during file upload | High | Auto-save draft before upload, extend session on upload activity |
| Large file upload failures | Medium | Chunked upload with resume capability (future enhancement), clear error messages |
| Concurrent admin review conflicts | Low | Last-write-wins with timestamp, admin sees "reviewed by X at Y" warning |
| S3 upload failures | Medium | Retry logic with exponential backoff, clear error recovery path |
| Form validation complexity | Low | Zod schemas provide type-safe validation, comprehensive testing |
| Mobile browser compatibility | Medium | Progressive enhancement, fallback for unsupported features, 99% compatibility target |
| Draft data inconsistency | Low | API-side validation on load, migration scripts for schema changes |

## Implementation Readiness

✅ All technical unknowns resolved  
✅ Technical approach defined and aligned with constitution  
✅ Architecture patterns established from existing specs (001, 002, 005)  
✅ Dependencies identified (minimal new additions)  
✅ Performance and security considerations addressed  
✅ Risks identified with mitigation strategies  

**Ready for Phase 1: Design & Contracts**
