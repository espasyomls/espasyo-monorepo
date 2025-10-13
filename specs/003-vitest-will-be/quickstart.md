# Quickstart: Vitest Testing Framework

**Date**: October 12, 2025
**Feature**: 003-vitest-will-be

## Overview

Vitest is now the default testing framework for all frontend development. This guide shows how to write, run, and maintain tests using Vitest.

## Prerequisites

- Node.js 22+
- npm or yarn
- Basic understanding of React/TypeScript

## Installation

Vitest is already installed in the project. No additional setup required.

```bash
# Dependencies are in package.json
npm install  # (already done)
```

## Configuration

### Vitest Config (vitest.config.ts)
```typescript
/// <reference types="vitest" />
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: ['node_modules/', 'src/test/']
    }
  }
})
```

### Test Setup (src/test/setup.ts)
```typescript
import '@testing-library/jest-dom'

// Global test setup
// Mock implementations, custom matchers, etc.
```

## Writing Tests

### Component Testing
```typescript
// src/components/Button.test.tsx
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { Button } from './Button'

describe('Button', () => {
  it('renders with correct text', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByRole('button', { name: /click me/i })).toBeInTheDocument()
  })

  it('calls onClick when clicked', async () => {
    const user = userEvent.setup()
    const handleClick = vi.fn()
    render(<Button onClick={handleClick}>Click me</Button>)

    await user.click(screen.getByRole('button'))
    expect(handleClick).toHaveBeenCalledTimes(1)
  })
})
```

### Hook Testing
```typescript
// src/hooks/useCounter.test.ts
import { renderHook, act } from '@testing-library/react'
import { useCounter } from './useCounter'

describe('useCounter', () => {
  it('starts at 0', () => {
    const { result } = renderHook(() => useCounter())
    expect(result.current.count).toBe(0)
  })

  it('increments count', () => {
    const { result } = renderHook(() => useCounter())

    act(() => {
      result.current.increment()
    })

    expect(result.current.count).toBe(1)
  })
})
```

### Utility Function Testing
```typescript
// src/utils/formatPrice.test.ts
import { formatPrice } from './formatPrice'

describe('formatPrice', () => {
  it('formats PHP currency', () => {
    expect(formatPrice(1000000)).toBe('₱1,000,000')
  })

  it('handles decimals', () => {
    expect(formatPrice(1234.56)).toBe('₱1,235')
  })
})
```

## Running Tests

### Development Mode
```bash
# Run tests in watch mode
npm run test:watch

# Run tests once
npm run test

# Run with UI
npm run test:ui
```

### Coverage Reports
```bash
# Generate coverage report
npm run test -- --coverage

# View HTML report
open coverage/index.html
```

### Specific Test Files
```bash
# Run specific test file
npm run test Button.test.tsx

# Run tests matching pattern
npm run test -- --run --reporter=verbose "Button"
```

## Mocking

### API Calls
```typescript
import { vi } from 'vitest'

// Mock API module
vi.mock('../api/client', () => ({
  apiClient: {
    get: vi.fn(),
    post: vi.fn()
  }
}))
```

### External Libraries
```typescript
// Mock next/router
vi.mock('next/router', () => ({
  useRouter: () => ({
    push: vi.fn(),
    pathname: '/'
  })
}))
```

## Best Practices

### Test Organization
- **File Naming**: `Component.test.tsx` or `Component.spec.tsx`
- **Directory Structure**: Mirror source structure in `__tests__/` or alongside source
- **Describe Blocks**: Group related tests with clear descriptions

### Test Quality
- **User-Centric**: Test user interactions, not implementation details
- **Independent**: Tests should not depend on each other
- **Fast**: Keep tests fast to run frequently
- **Readable**: Clear test names and assertions

### Coverage Goals
- **Lines**: >95%
- **Functions**: >95%
- **Branches**: >85%
- **Statements**: >95%

## Common Patterns

### Async Testing
```typescript
it('handles async operations', async () => {
  const promise = Promise.resolve('data')
  render(<AsyncComponent />)

  await waitFor(() => {
    expect(screen.getByText('data')).toBeInTheDocument()
  })
})
```

### Error Testing
```typescript
it('shows error message', () => {
  // Mock error condition
  vi.mocked(apiClient.get).mockRejectedValue(new Error('API Error'))

  render(<DataComponent />)

  expect(screen.getByText('Error loading data')).toBeInTheDocument()
})
```

## Troubleshooting

### Common Issues
- **Import Errors**: Ensure test files have `.test.tsx` extension
- **DOM Issues**: Use `jsdom` environment for DOM tests
- **Mock Problems**: Clear mocks between tests with `vi.clearAllMocks()`

### Debug Tips
- Use `screen.debug()` to see DOM structure
- Add `console.log` in test setup for debugging
- Run single tests with `--reporter=verbose`

## Integration with CI/CD

Tests run automatically in GitHub Actions:
- **Trigger**: Push to main branch or PR
- **Coverage**: Must maintain 100% coverage
- **Reports**: Coverage reports uploaded to PR

## Resources

- [Vitest Documentation](https://vitest.dev/)
- [Testing Library](https://testing-library.com/)
- [React Testing Examples](https://github.com/testing-library/react-testing-library)

## Next Steps

1. Write tests for new components using Vitest
2. Migrate existing tests gradually
3. Review coverage reports regularly
4. Add integration tests for critical flows