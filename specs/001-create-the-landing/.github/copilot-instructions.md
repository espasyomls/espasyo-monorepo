# GitHub Copilot Instructions: Create the Landing Page

## Feature Overview
Create a landing page inspired by housesigma.com with:
- Hero section featuring property search
- Header with subtle login/registration buttons
- shadcn/ui modals for Google OAuth authentication
- Mobile-optimized responsive design

## Technical Stack
- Next.js 14+ with App Router
- TypeScript
- shadcn/ui components
- TailwindCSS
- Zustand for state management
- Google OAuth for authentication

## Implementation Guidelines

### 1. Landing Page Structure (`app/page.tsx`)
- Hero section with compelling headline and search bar
- Featured property listings grid
- Responsive design with mobile-first approach
- Clean, professional real estate aesthetic

### 2. Header Component
- Subtle login and registration buttons
- Conditional rendering based on auth state
- Logout button when authenticated

### 3. Authentication Modals
- shadcn/ui Dialog components
- Google OAuth integration
- Form validation
- Mobile-optimized layout

### 4. State Management
- Zustand store for authentication state
- Modal state management
- User session handling

### 5. Styling
- TailwindCSS for responsive design
- shadcn/ui theme consistency
- Mobile breakpoints and touch targets

## Code Patterns
- Use Next.js App Router conventions
- Implement proper TypeScript types
- Follow React best practices
- Ensure accessibility compliance
- Write testable component code

## Testing Approach
- Unit tests for components
- Integration tests for auth flow
- E2E tests for user journeys
- Mobile responsiveness testing

## Deployment
- Static generation for performance
- Image optimization
- CDN for assets
- Environment variable configuration</content>
<parameter name="filePath">/home/boggss/espasyoMLS/specs/001-create-the-landing/.github/copilot-instructions.md