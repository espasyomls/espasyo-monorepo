# Quickstart: Logout Button Implementation

**Feature**: Logout Button in Dashboard  
**Date**: 2025-10-19  

## Overview

This guide provides step-by-step instructions for implementing the logout button feature in the dashboard.

## Prerequisites

- Next.js 15 project with NextAuth.js 5.x configured
- shadcn/ui components installed
- Dashboard page exists at `/dashboard`
- Authentication system functional

## Implementation Steps

### 1. Create Logout Button Component

Create `espasyo-frontend/src/components/dashboard/logout-button.tsx`:

```tsx
'use client';

import { useState } from 'react';
import { signOut } from 'next-auth/react';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/button';
import { LogOut, Loader2 } from 'lucide-react';

export function LogoutButton() {
  const [isLoggingOut, setIsLoggingOut] = useState(false);
  const router = useRouter();

  const handleLogout = async () => {
    try {
      setIsLoggingOut(true);

      // Sign out from NextAuth (client-side cleanup)
      await signOut({
        redirect: false, // We'll handle redirect manually
      });

      // Clear any additional client-side storage
      localStorage.removeItem('custom-session-data');
      sessionStorage.clear();

      // Redirect to login page
      router.push('/auth/login');
    } catch (error) {
      console.error('Logout failed:', error);
      // Handle error (show toast, etc.)
    } finally {
      setIsLoggingOut(false);
    }
  };

  return (
    <Button
      onClick={handleLogout}
      disabled={isLoggingOut}
      variant="outline"
      size="sm"
      className="flex items-center gap-2"
    >
      {isLoggingOut ? (
        <Loader2 className="h-4 w-4 animate-spin" />
      ) : (
        <LogOut className="h-4 w-4" />
      )}
      {isLoggingOut ? 'Logging out...' : 'Logout'}
    </Button>
  );
}
```

### 2. Update Dashboard Page

Modify `espasyo-frontend/src/pages/dashboard/page.tsx` to include the logout button:

```tsx
import { LogoutButton } from '@/components/dashboard/logout-button';

export default function DashboardPage() {
  return (
    <div className="container mx-auto p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Dashboard</h1>
        <LogoutButton />
      </div>

      {/* Rest of dashboard content */}
    </div>
  );
}
```

### 3. Add Server-Side Logout (Optional)

If server-side token invalidation is required beyond NextAuth.js, create `espasyo-frontend/src/pages/api/auth/logout.ts`:

```ts
import { NextApiRequest, NextApiResponse } from 'next';
import { getServerSession } from 'next-auth';
import { authOptions } from '@/lib/auth';

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const session = await getServerSession(req, res, authOptions);

    if (!session) {
      return res.status(401).json({
        error: 'Unauthorized',
        message: 'No active session'
      });
    }

    // Additional server-side cleanup if needed
    // e.g., invalidate tokens in database, log logout event

    res.status(200).json({
      success: true,
      message: 'Logged out successfully',
      redirectUrl: '/auth/login'
    });
  } catch (error) {
    console.error('Logout error:', error);
    res.status(500).json({
      error: 'Internal server error',
      message: 'Failed to logout'
    });
  }
}
```

### 4. Add Tests

Create `espasyo-frontend/tests/components/dashboard/logout-button.test.ts`:

```ts
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { LogoutButton } from '@/components/dashboard/logout-button';
import { signOut } from 'next-auth/react';

// Mock next-auth
jest.mock('next-auth/react', () => ({
  signOut: jest.fn(),
}));

// Mock next/navigation
jest.mock('next/navigation', () => ({
  useRouter: () => ({
    push: jest.fn(),
  }),
}));

describe('LogoutButton', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders logout button', () => {
    render(<LogoutButton />);
    expect(screen.getByRole('button', { name: /logout/i })).toBeInTheDocument();
  });

  it('shows loading state during logout', async () => {
    (signOut as jest.Mock).mockResolvedValueOnce(undefined);

    render(<LogoutButton />);

    const button = screen.getByRole('button', { name: /logout/i });
    fireEvent.click(button);

    expect(screen.getByText('Logging out...')).toBeInTheDocument();
    expect(button).toBeDisabled();

    await waitFor(() => {
      expect(signOut).toHaveBeenCalledWith({ redirect: false });
    });
  });

  it('handles logout errors gracefully', async () => {
    const consoleSpy = jest.spyOn(console, 'error').mockImplementation();
    (signOut as jest.Mock).mockRejectedValueOnce(new Error('Logout failed'));

    render(<LogoutButton />);

    const button = screen.getByRole('button', { name: /logout/i });
    fireEvent.click(button);

    await waitFor(() => {
      expect(consoleSpy).toHaveBeenCalledWith('Logout failed:', expect.any(Error));
    });

    consoleSpy.mockRestore();
  });
});
```

## Testing

1. **Unit Tests**: Run `npm test` in espasyo-frontend
2. **Integration Tests**: Test logout flow in browser
3. **E2E Tests**: Verify complete logout and redirect behavior

## Deployment

1. Deploy frontend changes to staging
2. Test logout functionality in staging environment
3. Deploy to production
4. Monitor for any authentication issues

## Troubleshooting

- **Button not visible**: Check user authentication status
- **Logout fails**: Verify NextAuth.js configuration
- **Redirect not working**: Check router configuration
- **Tokens not cleared**: Verify localStorage cleanup