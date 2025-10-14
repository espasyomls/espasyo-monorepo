# Quickstart Guide: Progressive Agent Verification Flow

## Overview
This guide provides end-to-end testing scenarios for the progressive agent verification feature. Each scenario validates a complete user journey from the feature specification.

## Prerequisites
- Next.js development server running on `http://localhost:3000`
- Gmail OAuth configured with test credentials
- Admin user account with verification review permissions
- Test data populated (sample provinces, municipalities)

## Test Scenarios

### Scenario 1: Complete Agent Verification Flow
**User Story**: As a registering agent, I want to authenticate via Gmail and complete verification progressively.

**Steps**:
1. Navigate to `/auth/agent-register`
2. Click "Sign in with Google"
3. Complete OAuth flow with test Gmail account
4. Verify redirect to `/dashboard/agent`
5. Click "Verify Me" tab
6. Complete "Agent Info" step (name, phone, company)
7. Save draft and verify persistence
8. Upload required documents (license, ID)
9. Select service areas (provinces, municipalities)
10. Submit application
11. Verify status changes to "submitted"
12. Verify admin can see application in review queue

**Expected Results**:
- ✅ OAuth authentication succeeds
- ✅ Dashboard loads with "Verify Me" tab
- ✅ Form saves draft data correctly
- ✅ File uploads succeed with validation
- ✅ Application submits successfully
- ✅ Status tracking works throughout flow

### Scenario 2: Draft Save and Resume
**User Story**: As an agent, I want to save my progress and return later to complete verification.

**Steps**:
1. Start verification process as in Scenario 1
2. Complete first step and save draft
3. Close browser/logout
4. Return after 1 hour
5. Re-authenticate
6. Access "Verify Me" tab
7. Verify draft data loads correctly
8. Continue from saved step
9. Complete and submit application

**Expected Results**:
- ✅ Draft saves with timestamp
- ✅ Draft loads on return
- ✅ Progress resumes from correct step
- ✅ No data loss during session break

### Scenario 3: Admin Review Workflow
**User Story**: As an administrator, I want to review agent applications and request additional documents when needed.

**Steps**:
1. Agent submits application (from Scenario 1)
2. Admin logs into admin dashboard
3. Navigate to agent verification section
4. View submitted application details
5. Review uploaded documents
6. Request additional documents with specific requirements
7. Verify application status changes to "returned"
8. Verify agent receives notification
9. Agent uploads additional documents
10. Re-submits application
11. Admin approves final application

**Expected Results**:
- ✅ Admin can view all submitted applications
- ✅ Document review functionality works
- ✅ Status changes correctly on document requests
- ✅ Agent notification system works
- ✅ Re-submission process succeeds
- ✅ Final approval changes status to "approved"

### Scenario 4: Error Handling and Recovery
**User Story**: As an agent, I want clear error messages and recovery options when issues occur.

**Steps**:
1. Attempt authentication with invalid Gmail
2. Verify error message and retry option
3. Start verification with incomplete data
4. Attempt to submit without required documents
5. Verify validation errors
6. Upload invalid file type/size
7. Verify file validation errors
8. Lose internet connection during save
9. Verify offline handling or error recovery

**Expected Results**:
- ✅ Authentication errors show clear messages
- ✅ Form validation prevents invalid submissions
- ✅ File upload validates type and size
- ✅ Network errors handled gracefully
- ✅ Recovery options provided where possible

### Scenario 5: Status Tracking and Notifications
**User Story**: As an agent, I want to see my verification status and receive updates on changes.

**Steps**:
1. Submit application
2. Check dashboard status display
3. Admin requests additional documents
4. Verify status change notification
5. Verify status display updates
6. Complete additional requirements
7. Verify final approval notification

**Expected Results**:
- ✅ Status displays correctly in dashboard
- ✅ Status changes trigger notifications
- ✅ Notification content is clear and actionable
- ✅ Status history is maintained

## Performance Benchmarks

### Response Times
- Page load: <2 seconds
- API responses: <500ms
- File uploads: <10 seconds for 5MB files
- OAuth redirect: <5 seconds

### Scalability Tests
- Concurrent users: Support 100+ simultaneous verifications
- File storage: Handle 10,000+ document uploads
- Admin queue: Support 1,000+ applications in review

## Troubleshooting

### Common Issues
- **OAuth fails**: Check Gmail app credentials and redirect URIs
- **Draft not saving**: Verify localStorage/sessionStorage permissions
- **File upload fails**: Check file size limits and network connectivity
- **Admin permissions**: Ensure user has correct role assignments

### Debug Commands
```bash
# Check API health
curl http://localhost:3000/api/health

# View application logs
tail -f logs/application.log

# Clear test data
npm run db:reset
```

## Success Criteria
- ✅ All 5 scenarios pass without errors
- ✅ Performance benchmarks met
- ✅ No console errors in browser
- ✅ All API contracts return expected responses
- ✅ Database integrity maintained throughout flows</content>
<parameter name="filePath">/home/boggss/espasyoMLS/specs/005-i-want-to/quickstart.md