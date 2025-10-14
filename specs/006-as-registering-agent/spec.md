# Feature Specification: Agent Registration and Verification Flow

**Feature Branch**: `006-as-registering-agent`  
**Created**: 2025-10-14  
**Status**: Draft  
**Input**: User description: "As registering agent, i will click on the 'Become an Agent' from the header of landing page then it will show the 'Continue with Google' modal with cancel button, and when continue with google is chosen it will immediately initiate the Google Oauth flow. Once the Google OAuth flow is successful, it will redirect to the agent dashboard page as authenticated session. At this point we have already captured the registering agent in our database and have assign the role as agent but pending verification. The system will then intelligently require the new registrant to complete the personal profile page along with all the fields needed. This is accessible through a tab or menu within the agent dashboard. There will also be a tab or menu that the registering agent can click to start the verification flow. Note, only verified agent can create a property or create listings. Also, in unauthenticated session, personal bio of the agent will appear as listed in the page of verified agents that when any user click on their name on the list/card, it will show the full bio details including all their listings."

## Clarifications

### Session 2025-10-14

- Q: When an agent's verification is rejected, can they revise and resubmit their application? → A: Agent can resubmit after rejection with previously submitted data retained and editable
- Q: Who can access the admin verification review functionality? → A: Users with "admin" or "verification_admin" role in the user system
- Q: What happens to saved verification draft data after the agent submits their application? → A: Draft data is permanently retained for audit purposes
- Q: What is the session timeout duration for authenticated agent activities? → A: 30 minutes of inactivity
- Q: What should be displayed when an agent's public profile has no listings? → A: Show message: "This agent has no active listings at this time"
- Q: Can admins request additional information without rejecting the application? → A: Yes, admins can return the application to the agent for updates/additions with no limit on return cycles until admin is satisfied
- Q: What constitutes "inactivity" for the 30-minute session timeout? → A: Inactivity means no HTTP requests from the client for 30 minutes (server-side session timeout based on last request timestamp, not user keyboard/mouse interaction)
- Q: Where should the PRC license number be stored - in the profile form or as a verification document? → A: PRC license NUMBER is stored in the profile form as a text field for quick reference. The actual PRC license DOCUMENT (scan/photo) is uploaded during verification as a required document. Both are required.
- Q: What are "key specializations" for agent cards in the public directory? → A: Display up to 3 specializations per agent card. Priority order: [residential, commercial, luxury] if present, else first 3 alphabetically. This keeps cards visually consistent and highlights primary focus areas.
- Q: What defines an "active listing" for agent public profiles? → A: Active listings are published listings that are not sold, expired, or withdrawn. Query filter: WHERE status IN ('published', 'active') AND NOT (sold = true OR expired = true OR withdrawn = true).

## Terminology

To ensure consistency across specification, plan, and tasks, the following terms are standardized:

- **Agent Profile** / **Personal Profile**: The professional information form agents complete (name, bio, specializations, coverage areas, PRC license number). Database entity: `AgentProfile`. UI label: "Personal Profile" or "Profile". Used in tasks as "agent profile".
- **Verification Application**: The submitted artifact containing documents and data for admin review. Noun form. Used when referring to the record itself (e.g., "review the verification application").
- **Verification Flow** / **Verification Process**: The multi-step wizard UI process agents use to submit verification. Process form. Used when referring to the user experience (e.g., "navigate through verification flow").
- **Submit Verification**: The action/verb for submitting a verification application (e.g., "agent submits verification").
- **PRC License Number** vs **PRC License Document**: NUMBER is a text field in agent profile for quick reference. DOCUMENT is the scanned/photographed license uploaded during verification.
- **Return for Revisions** / **Return Cycles**: Admin action to send application back to agent for updates without rejecting. Supports unlimited cycles.
- **Intelligent Banner**: A UI component that calculates completion percentage, identifies missing required fields, and provides actionable next steps.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Agent Registration via Google OAuth (Priority: P1)

A prospective agent visits the landing page and initiates registration through Google OAuth to gain authenticated access to the agent dashboard, establishing their identity in the system as a pending agent.

**Why this priority**: This is the entry point for all agents into the platform. Without authentication and initial account creation, no other agent functionality is possible. This delivers immediate value by allowing agents to create an account and access their dashboard.

**Independent Test**: Can be fully tested by clicking "Become an Agent" from the landing page header, completing Google OAuth flow, and verifying successful redirect to agent dashboard with authenticated session. Delivers value by creating an agent account with pending verification status.

**Acceptance Scenarios**:

1. **Given** I am an unauthenticated user on the landing page, **When** I click "Become an Agent" in the header, **Then** I see a modal with "Continue with Google" button and "Cancel" button
2. **Given** the registration modal is displayed, **When** I click "Cancel", **Then** the modal closes and I remain on the landing page
3. **Given** the registration modal is displayed, **When** I click "Continue with Google", **Then** the Google OAuth consent screen opens immediately
4. **Given** I complete the Google OAuth flow successfully, **When** OAuth redirects back to the platform, **Then** I am redirected to `/dashboard/agent` as an authenticated user
5. **Given** I have successfully authenticated via Google OAuth, **When** I check my account status, **Then** I see my account exists in the database with role "agent" and verification status "pending"
6. **Given** I am authenticated but verification is pending, **When** I access the agent dashboard, **Then** I see a prominent notification indicating my verification status is pending

---

### User Story 2 - Complete Personal Profile (Priority: P1)

A newly registered agent with pending verification status completes their personal profile information through the agent dashboard to provide essential professional details required before starting the verification process.

**Why this priority**: Profile completion is a prerequisite for verification and essential for the agent's public presence. This is the second critical step after registration and must be completed before verification can begin. It provides immediate value by allowing agents to establish their professional identity.

**Independent Test**: Can be fully tested by logging in as a pending agent, accessing the profile tab/menu in the agent dashboard, filling all required profile fields, saving the profile, and verifying the data persists. Delivers value by allowing agents to establish their professional presence.

**Acceptance Scenarios**:

1. **Given** I am a newly registered agent with pending verification, **When** I access the agent dashboard, **Then** I see an intelligent prompt or banner requiring me to complete my personal profile
2. **Given** I am on the agent dashboard, **When** I navigate to tabs/menus, **Then** I see a "Personal Profile" or "Profile" tab/menu option
3. **Given** I click on the Personal Profile tab, **When** the profile page loads, **Then** I see a form with all required fields for agent information including name, contact details, professional bio, specializations, and coverage areas
4. **Given** I am filling the profile form, **When** I attempt to save with incomplete required fields, **Then** I see validation errors indicating which fields are required
5. **Given** I have filled all required profile fields, **When** I save the profile, **Then** the system persists my information and displays a success confirmation
6. **Given** I have completed my profile, **When** I return to the agent dashboard, **Then** the intelligent prompt for profile completion no longer appears
7. **Given** my profile is incomplete, **When** I attempt to access verification flow, **Then** the system redirects me to complete the profile first

---

### User Story 3 - Initiate and Complete Verification Flow (Priority: P1)

An agent with a completed profile initiates and completes the verification process by submitting required documents and information through a step-by-step verification flow accessible from the agent dashboard.

**Why this priority**: Verification is the gateway to full agent functionality. Without verification, agents cannot create listings or properties. This is the third critical step in the agent journey and directly impacts revenue generation capabilities.

**Independent Test**: Can be fully tested by logging in as a pending agent with completed profile, clicking the verification tab/menu, completing all verification steps including document uploads, submitting for admin review, and verifying the application is recorded as pending review. Delivers value by enabling agents to progress toward full platform access.

**Acceptance Scenarios**:

1. **Given** I am an agent with completed profile and pending verification, **When** I view the agent dashboard, **Then** I see a "Verify Me" or "Start Verification" tab/menu option
2. **Given** I click on the verification tab, **When** the verification page loads, **Then** I see a step-by-step verification flow with clear instructions
3. **Given** I am in the verification flow, **When** I progress through steps, **Then** I can upload required documents (PRC license, government ID, professional certifications)
4. **Given** I am in the verification flow, **When** I need to pause, **Then** I can save my progress and return later to complete remaining steps
5. **Given** I have completed all verification steps, **When** I submit for verification, **Then** the system records my application as "pending admin review"
6. **Given** I have submitted verification, **When** I return to the agent dashboard, **Then** I see my verification status as "Under Review" with estimated review timeframe
7. **Given** my verification is under review, **When** I attempt to create a property or listing, **Then** the system blocks the action and displays a message indicating verification is required
8. **Given** an admin has returned my application for revisions, **When** I access the verification flow, **Then** I see the admin's feedback and can edit my previous submission to add/update information or documents
9. **Given** I have made requested changes to a returned application, **When** I resubmit, **Then** the application returns to "under review" status for admin re-evaluation

---

### User Story 4 - Access Restrictions for Unverified Agents (Priority: P2)

An unverified agent encounters appropriate restrictions when attempting to create properties or listings, with clear messaging explaining the verification requirement.

**Why this priority**: This enforces business rules and quality standards by ensuring only verified agents can create listings. It's P2 because it's a constraint rather than a core capability, but it's essential for platform integrity.

**Independent Test**: Can be fully tested by logging in as an unverified agent, attempting to access property creation or listing creation features, and verifying that access is blocked with appropriate messaging. Delivers value by maintaining platform quality standards.

**Acceptance Scenarios**:

1. **Given** I am an unverified agent, **When** I attempt to create a new property, **Then** the system blocks the action and displays a message: "Agent verification required to create properties"
2. **Given** I am an unverified agent, **When** I attempt to create a new listing, **Then** the system blocks the action and displays a message: "Agent verification required to create listings"
3. **Given** I see a verification required message, **When** I view the message, **Then** I see a link or button to start the verification process
4. **Given** I am an unverified agent, **When** I view the agent dashboard, **Then** property and listing creation options are either hidden or disabled with tooltips explaining verification is required
5. **Given** my verification is approved, **When** I return to the agent dashboard, **Then** all property and listing creation features become accessible

---

### User Story 5 - Public Agent Profile Display (Priority: P2)

Unauthenticated users can browse a directory of verified agents, view their public profiles including bio and professional details, and see all listings associated with each agent.

**Why this priority**: This enables agent discoverability and provides value to both agents (exposure) and users (finding qualified agents). It's P2 because it's a marketing/discovery feature that builds on the core verification flow (P1).

**Independent Test**: Can be fully tested by accessing the platform without authentication, navigating to the verified agents page, clicking on an agent's name/card, and viewing their full bio and listings. Delivers value by connecting users with verified agents.

**Acceptance Scenarios**:

1. **Given** I am an unauthenticated user, **When** I navigate to the verified agents page, **Then** I see a list or grid of verified agent cards displaying their name, photo, and key specializations
2. **Given** I am viewing the verified agents list, **When** I see an agent card, **Then** only verified agents are displayed (pending or rejected agents are not shown)
3. **Given** I am viewing an agent card, **When** I click on the agent's name or card, **Then** I am taken to the agent's full public profile page
4. **Given** I am viewing an agent's full profile, **When** the page loads, **Then** I see their complete bio, professional information, specializations, coverage areas, and verified badge
5. **Given** I am viewing an agent's full profile, **When** I scroll down, **Then** I see all active property listings created by this agent, or the message "This agent has no active listings at this time" if none exist
6. **Given** I am viewing an agent's listings, **When** I click on a listing, **Then** I can view the full listing details
7. **Given** an agent's verification status is pending or rejected, **When** unauthenticated users browse the platform, **Then** the agent's profile is not visible in the public directory

---

### Edge Cases

- What happens when a user cancels the Google OAuth consent screen mid-flow?
- How does the system handle if Google OAuth fails or returns an error?
- What happens if an agent closes the browser during profile completion?
- How does the system handle if an agent uploads invalid or corrupted documents during verification?
- What happens if an agent tries to submit verification without completing all required steps?
- How does the system handle if an admin rejects an agent's verification with feedback?
- How does the system handle if an admin returns an agent's verification for revisions?
- What happens if an already verified agent's verification status changes (e.g., license expires)?
- How does the system handle if an agent attempts to access another agent's profile edit page?
- What happens when an agent has multiple pending verification applications?
- How does the system handle session timeout during profile completion or verification flow?
- What happens if an agent deletes their account before verification is completed?
- How does the system prevent duplicate registrations with the same Google account?
- How does the system restore unsaved form data after session timeout and re-authentication?

## Requirements *(mandatory)*

### Functional Requirements

#### Authentication & Registration
- **FR-001**: System MUST provide a "Become an Agent" button/link in the landing page header visible to unauthenticated users
- **FR-002**: System MUST display a modal dialog when "Become an Agent" is clicked, containing "Continue with Google" button and "Cancel" button
- **FR-003**: System MUST close the registration modal and return to landing page when "Cancel" is clicked
- **FR-004**: System MUST initiate Google OAuth flow immediately when "Continue with Google" is clicked
- **FR-005**: System MUST handle Google OAuth callback and create authenticated session upon successful authentication
- **FR-005a**: System MUST implement session timeout of 30 minutes of inactivity for authenticated agents
- **FR-005b**: System MUST preserve unsaved form data (profile or verification) when session timeout occurs and restore it upon re-authentication
- **FR-006**: System MUST create a new agent record in the database upon successful Google OAuth authentication if the user doesn't exist
- **FR-007**: System MUST assign the role "agent" to newly registered users
- **FR-008**: System MUST set verification status to "pending" for newly registered agents
- **FR-009**: System MUST redirect authenticated users to `/dashboard/agent` after successful OAuth completion
- **FR-010**: System MUST prevent duplicate agent registrations for the same Google account

#### Agent Dashboard & Profile
- **FR-011**: System MUST provide an agent dashboard accessible at `/dashboard/agent` for authenticated agents
- **FR-012**: System MUST display an intelligent notification/banner on the agent dashboard prompting profile completion for agents with incomplete profiles
- **FR-013**: System MUST provide a "Personal Profile" or "Profile" tab/menu option in the agent dashboard navigation
- **FR-014**: System MUST display a profile form with fields for: full name, contact information (phone, email), professional bio, specializations, coverage areas, and PRC license number
- **FR-015**: System MUST validate all required profile fields before allowing save
- **FR-016**: System MUST persist agent profile information to the database upon successful save
- **FR-017**: System MUST display success confirmation after profile save
- **FR-018**: System MUST hide/remove profile completion prompt once the profile is completed
- **FR-019**: System MUST allow agents to edit their profile information after initial completion

#### Verification Flow
- **FR-020**: System MUST provide a "Verify Me" or "Start Verification" tab/menu option in the agent dashboard, visible only for agents with pending verification status
- **FR-021**: System MUST block access to verification flow if the agent's profile is incomplete, redirecting to profile completion
- **FR-022**: System MUST display a step-by-step verification flow with progress indicator, including document upload steps (PRC license, government ID, optional certifications)
- **FR-023**: System MUST require upload of PRC license document as part of verification (separate from PRC license number in profile)
- **FR-024**: System MUST require upload of government-issued ID as part of verification
- **FR-025**: System MUST allow upload of additional professional certifications (optional)
- **FR-026**: System MUST validate file types and sizes for document uploads (accept PDF, JPG, PNG; max 5MB per file)
- **FR-027**: System MUST allow agents to save verification progress and return later to complete
- **FR-028**: System MUST store verification draft data securely (encrypted in transit via HTTPS, encrypted at rest via database encryption, row-level security ensuring agents can only access their own drafts) and associate with the agent's account
- **FR-028a**: System MUST permanently retain verification draft data for audit purposes even after submission (database constraint or application logic prevents deletion)
- **FR-029**: System MUST allow agents to submit completed verification application for admin review
- **FR-030**: System MUST update verification status to "under review" upon submission
- **FR-031**: System MUST display estimated review timeframe after verification submission (1-2 business days as target SLA commitment to agents)
- **FR-032**: System MUST notify admins when a new verification application is submitted
- **FR-032a**: System MUST restrict access to verification review functionality to users with "admin" or "verification_admin" role only
- **FR-033**: System MUST allow admins to approve or reject verification applications with feedback
- **FR-033a**: System MUST allow admins to return verification applications to agents for revisions without rejecting
- **FR-033b**: System MUST require admin feedback message when returning application for revisions
- **FR-033c**: System MUST support unlimited return cycles between admin and agent until admin approves or rejects
- **FR-034**: System MUST update agent verification status to "verified" upon admin approval
- **FR-035**: System MUST update agent verification status to "rejected" upon admin rejection with reason stored
- **FR-035a**: System MUST allow agents with rejected verification to access and edit their previous submission data
- **FR-035b**: System MUST allow agents with rejected verification to resubmit their application after making corrections
- **FR-035c**: System MUST update agent verification status to "returned for revisions" when admin returns application for updates
- **FR-035d**: System MUST display admin feedback prominently when agent accesses returned application
- **FR-035e**: System MUST allow agents to edit and add documents/information to returned applications
- **FR-035f**: System MUST notify agents when their application is returned for revisions
- **FR-036**: System MUST notify agents when their verification status changes

#### Access Control & Restrictions
- **FR-037**: System MUST block unverified agents from creating new properties
- **FR-038**: System MUST block unverified agents from creating new listings
- **FR-039**: System MUST display clear error messages when unverified agents attempt restricted actions: "Agent verification required to create properties/listings"
- **FR-040**: System MUST provide a link to verification flow in restriction messages
- **FR-041**: System MUST disable (not hide) property creation and listing creation UI buttons for unverified agents with tooltip explaining verification requirement (better UX than hiding)
- **FR-042**: System MUST enable all property and listing creation features for verified agents
- **FR-043**: System MUST enforce verification requirements at API level, not just UI level

#### Public Agent Directory
- **FR-044**: System MUST provide a public page listing all verified agents, accessible without authentication
- **FR-045**: System MUST display only agents with "verified" status in the public directory
- **FR-046**: System MUST display agent cards showing name, photo (if provided), and key specializations (up to 3, priority: residential/commercial/luxury first)
- **FR-047**: System MUST make agent cards clickable, linking to individual agent profile pages at URL pattern `/agents/[agentId]` where agentId is UUID
- **FR-048**: System MUST provide individual public profile pages for each verified agent at `/agents/[agentId]` (consider adding name slug for SEO: `/agents/[agentId]/[name-slug]`)
- **FR-049**: System MUST display full agent bio, professional information, specializations, coverage areas, and verified badge on public profile pages
- **FR-050**: System MUST display all active listings created by the agent on their public profile page
- **FR-050a**: System MUST display message "This agent has no active listings at this time" when agent has zero listings
- **FR-051**: System MUST hide pending and rejected agents from public directory and direct profile access
- **FR-052**: System MUST return 404 or access denied when attempting to access non-verified agent public profiles

### Key Entities

- **Agent**: Represents a real estate agent user with professional credentials. Attributes include: user reference, role (agent), verification status (pending, under review, verified, rejected, returned for revisions), profile information (bio, specializations, coverage areas, PRC license number), contact details, and timestamps
- **Agent Profile**: Stores detailed professional information about an agent including bio, specializations (residential, commercial, luxury, etc.), coverage areas (geographical locations), experience level, and professional credentials
- **Verification Application**: Represents an agent's verification submission. Attributes include: agent reference, application status (draft, submitted, under review, approved, rejected, returned for revisions), submitted documents (PRC license, government ID, certifications), submission timestamp, review notes, reviewer reference, review timestamp, resubmission count, and return count. Rejected applications retain data to allow agents to revise and resubmit. Returned applications remain editable for agent updates with no limit on return cycles. Draft data is permanently retained for audit purposes.
- **Verification Document**: Represents uploaded documents for verification. Attributes include: file reference, document type (PRC license, ID, certification), upload timestamp, file metadata (size, type), verification status, and permanent retention flag for audit compliance
- **Property**: Represents a real estate property listing. Attributes include: agent reference (creator), property details, and access restricted to verified agents only
- **Listing**: Represents a property listing. Attributes include: property reference, agent reference (creator), listing details, status, and creation restricted to verified agents
- **Admin User**: Represents administrative users with permissions to review verification applications. Attributes include: user reference, role (admin or verification_admin), and permissions for verification management

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Prospective agents can complete registration from landing page through OAuth and reach agent dashboard in under 60 seconds
- **SC-002**: Agents can complete profile information in under 5 minutes with all required fields
- **SC-003**: Agents can save verification progress and return later without data loss
- **SC-004**: System blocks 100% of attempts by unverified agents to create properties or listings
- **SC-005**: Only verified agents appear in public agent directory (0% pending or rejected agents shown)
- **SC-006**: Agent profile pages display within 2 seconds for unauthenticated users
- **SC-007**: 90% of agents successfully complete profile on first attempt without validation errors (indicates clear field labeling and validation)
- **SC-008**: Verification submission flow has less than 5% abandonment rate at final submission step
- **SC-009**: 95% of Google OAuth authentication attempts succeed (excluding user cancellation)
- **SC-010**: Admin verification review completion occurs within displayed timeframe (1-2 business days) for 90% of applications
- **SC-010a**: Applications returned for revisions are re-reviewed within 1 business day of resubmission in 90% of cases
- **SC-011**: Public agent profile pages include all agent listings with accurate association (100% data integrity)
- **SC-012**: System handles 100 concurrent agent registrations without performance degradation

### Assumptions

- Google OAuth is the primary authentication method for agent registration (email/password not required)
- Agents must have a Google account to register on the platform
- Profile completion is required before verification can begin (enforced workflow)
- PRC license verification is mandatory for all Philippine real estate agents
- Document uploads are stored securely with access control (implementation detail deferred)
- Admin review is manual process (no automated verification)
- Verification status changes trigger email notifications (notification implementation details deferred)
- Agent public profiles are SEO-friendly and indexable by search engines
- Agent profile photos are optional but recommended
- Coverage areas follow standard Philippine geographical divisions (provinces/cities)
- Specializations use predefined categories (residential, commercial, luxury, land, etc.)
- Session management follows standard web application security practices with 30-minute inactivity timeout
- File upload size limit of 5MB per document is sufficient for typical ID/license scans
- Agent dashboard is mobile-responsive
- Public agent directory supports filtering and search (basic implementation assumed, advanced features may require clarification)

## Out of Scope

The following items are explicitly out of scope for this feature:

- Email/password authentication for agents (Google OAuth only)
- Agent subscription plans or paid features
- Multi-language support for agent profiles
- Agent-to-agent messaging or collaboration features
- Integration with external license verification APIs
- Automated background checks or identity verification
- Agent performance analytics or ratings
- Client review and rating system for agents
- Agent team or brokerage management
- Commission calculation or payment processing
- Advanced search filters for agent directory (beyond basic implementation)
- Agent certifications or training module
- Integration with social media platforms for profile import
- Video introductions or virtual tours for agent profiles
- Appointment scheduling between users and agents
