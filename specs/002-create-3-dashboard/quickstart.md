# Quickstart: Create 3 Dashboard Pages

**Date**: October 5, 2025
**Feature**: 002-create-3-dashboard
**Test Environment**: Local development with Docker/LocalStack

## Prerequisites

1. **Environment Setup**:
   ```bash
   # Ensure LocalStack is running
   cd espasyo-infrastructure
   docker compose -f docker-compose.local.yml up -d localstack

   # Start frontend development server
   cd ../espasyo-frontend
   npm install
   npm run dev
   ```

2. **Test Accounts**:
   - Admin: admin@espasyo.test (role: administrator)
   - Agent: agent@espasyo.test (role: agent)
   - User: user@espasyo.test (role: user)

## Test Scenarios

### Scenario 1: Administrator Dashboard Access
**Given** an administrator is logged in
**When** they navigate to their dashboard
**Then** they should see administrative controls and system-wide metrics

**Steps**:
1. Open browser to http://localhost:3000
2. Sign in with admin@espasyo.test
3. Verify automatic redirect to `/dashboard/admin`
4. Confirm presence of:
   - System metrics widgets (total users, active listings)
   - User management section
   - Content moderation tools
   - Platform settings panel

**Expected Results**:
- ✅ Page loads within 2 seconds
- ✅ All admin-specific widgets render
- ✅ Navigation shows admin menu items
- ✅ No unauthorized access errors

### Scenario 2: Real Estate Agent Dashboard Access
**Given** a real estate agent is logged in
**When** they navigate to their dashboard
**Then** they should see their property listings, client interactions, and performance metrics

**Steps**:
1. Sign out current user
2. Sign in with agent@espasyo.test
3. Verify redirect to `/dashboard/agent`
4. Confirm presence of:
   - Property listing management widgets
   - Client communication tools
   - Analytics dashboard
   - Commission tracking metrics

**Expected Results**:
- ✅ Agent-specific widgets load correctly
- ✅ Performance metrics display
- ✅ Navigation appropriate for agent role
- ✅ Real-time data updates work

### Scenario 3: Regular User Dashboard Access
**Given** a regular user is logged in
**When** they navigate to their dashboard
**Then** they should see their saved properties, search history, and account preferences

**Steps**:
1. Sign out current user
2. Sign in with user@espasyo.test
3. Verify redirect to `/dashboard/user`
4. Confirm presence of:
   - Saved searches section
   - Favorite properties list
   - Account settings panel
   - Viewing history

**Expected Results**:
- ✅ User dashboard loads personalized content
- ✅ Saved items display correctly
- ✅ Account preferences are accessible
- ✅ Mobile responsive layout works

### Scenario 4: Unauthorized Access Handling
**Given** a user attempts to access a dashboard they're not authorized for
**When** they try to navigate to a different role's dashboard
**Then** the system shows a generic error message without revealing role information

**Steps**:
1. Sign in as regular user (user@espasyo.test)
2. Attempt to navigate to `/dashboard/admin`
3. Verify generic error message appears
4. Try accessing `/dashboard/agent` as admin user
5. Confirm same generic error handling

**Expected Results**:
- ✅ Generic error message (no role information leaked)
- ✅ User remains on appropriate dashboard
- ✅ No security information disclosure

### Scenario 5: Role-Based Navigation
**Given** users with different roles
**When** they access the application
**Then** they should only see navigation options appropriate to their role

**Steps**:
1. Test each role's navigation menu
2. Verify menu items match role permissions
3. Check that restricted sections are hidden
4. Confirm breadcrumb navigation works

**Expected Results**:
- ✅ Role-appropriate navigation items only
- ✅ No hidden admin/agent features for regular users
- ✅ Consistent navigation experience across roles

## Performance Validation

### Load Time Requirements
- **Dashboard initial load**: < 2 seconds
- **Dashboard switching**: < 100ms
- **Widget updates**: < 500ms

### Responsiveness Tests
- **Mobile viewport**: 375px width
- **Tablet viewport**: 768px width
- **Desktop viewport**: 1440px width

**Validation Command**:
```bash
# Run performance tests
npm run test:performance

# Check bundle size
npm run build && npm run analyze
```

## Troubleshooting

### Common Issues

1. **Dashboard not loading**:
   - Check LocalStack is running: `docker ps | grep localstack`
   - Verify AWS credentials in `.env.local`
   - Check browser console for API errors

2. **Authentication failures**:
   - Ensure Google OAuth is configured
   - Check NextAuth.js configuration
   - Verify user roles in database

3. **Permission errors**:
   - Confirm middleware.ts is active
   - Check role assignment in user session
   - Verify API endpoint permissions

### Debug Commands
```bash
# Check API endpoints
curl -H "Authorization: Bearer <token>" http://localhost:3000/api/dashboard/admin

# View application logs
docker logs espasyo-localstack

# Check database state
docker exec -it espasyo-postgres psql -U postgres -d espasyo
```

## Success Criteria

- ✅ All 3 dashboard types load correctly
- ✅ Role-based access control works
- ✅ Performance requirements met
- ✅ Mobile responsiveness confirmed
- ✅ No security vulnerabilities
- ✅ Contract tests pass (after implementation)

**Ready for implementation when all contract tests are created and failing as expected.**