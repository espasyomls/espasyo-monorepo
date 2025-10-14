# Quickstart: Create the Landing Page

## Prerequisites
- Node.js 18+
- Docker and Docker Compose
- Google OAuth credentials configured

## Local Development Setup

1. **Clone and navigate to frontend:**
   ```bash
   cd espasyo-frontend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Configure environment:**
   ```bash
   cp .env.example .env.local
   # Edit .env.local with Google OAuth credentials
   ```

4. **Start development server:**
   ```bash
   npm run dev
   ```

5. **Access the landing page:**
   Open http://localhost:3000 in your browser

## Docker Development

1. **Start full stack with Docker Compose:**
   ```bash
   cd espasyo-infrastructure
   docker-compose -f docker-compose.local.yml up
   ```

2. **Access the application:**
   Frontend: http://localhost:3000

## Testing

1. **Run unit tests:**
   ```bash
   npm run test
   ```

2. **Run E2E tests:**
   ```bash
   npm run test:e2e
   ```

## Key Files
- `app/page.tsx` - Main landing page component
- `components/auth/` - Authentication modals
- `lib/auth.ts` - OAuth configuration
- `stores/auth.ts` - Zustand auth store

## Troubleshooting
- Ensure Google OAuth is configured in Google Cloud Console
- Check browser console for authentication errors
- Verify Docker containers are running for full stack</content>
<parameter name="filePath">/home/boggss/espasyoMLS/specs/001-create-the-landing/quickstart.md