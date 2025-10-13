# Component Testing Contracts

**Date**: October 12, 2025
**Feature**: 003-vitest-will-be

## Button Component Contract

### Required Tests
- Renders with correct text
- Handles click events
- Supports disabled state
- Applies correct styling variants
- Accessible with keyboard navigation

### Test Example
```typescript
describe('Button', () => {
  it('renders with text', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByRole('button')).toHaveTextContent('Click me')
  })

  it('calls onClick when clicked', async () => {
    const onClick = vi.fn()
    render(<Button onClick={onClick}>Click</Button>)

    await userEvent.click(screen.getByRole('button'))
    expect(onClick).toHaveBeenCalled()
  })
})
```

## Form Component Contract

### Required Tests
- Renders form fields correctly
- Handles form submission
- Validates input data
- Shows validation errors
- Supports different input types

### Validation Rules
- Required field validation
- Email format validation
- Password strength validation
- Custom validation rules

## Modal Component Contract

### Required Tests
- Opens/closes correctly
- Traps focus inside modal
- Closes on overlay click
- Closes on escape key
- Restores focus on close
- Prevents body scroll

## List Component Contract

### Required Tests
- Renders list items
- Handles empty state
- Supports item selection
- Implements virtual scrolling (if applicable)
- Handles loading states

## Navigation Contract

### Required Tests
- Renders navigation items
- Handles active states
- Supports nested navigation
- Works on mobile devices
- Keyboard navigation support