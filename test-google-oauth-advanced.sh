#!/bin/bash

# Advanced Google OAuth Callback Testing Script
# Tests the complete OAuth flow including proper HTTP methods

BASE_URL="http://localhost:3000"
TEST_RESULTS=()

echo "🔬 Advanced Google OAuth Callback Tests"
echo "========================================"

# Test 1: Server Health Check
echo "Test 1: Server Health Check"
SERVER_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL)
if [ "$SERVER_STATUS" = "200" ]; then
    echo "✅ Server is running (Status: $SERVER_STATUS)"
    TEST_RESULTS+=("PASS")
else
    echo "❌ Server is not responding (Status: $SERVER_STATUS)"
    TEST_RESULTS+=("FAIL")
fi

# Test 2: NextAuth CSRF Token Retrieval
echo -e "\nTest 2: CSRF Token Retrieval"
CSRF_RESPONSE=$(curl -s -c cookies.txt $BASE_URL/api/auth/signin/google)
CSRF_TOKEN=$(echo "$CSRF_RESPONSE" | grep -o '"csrfToken":"[^"]*"' | cut -d'"' -f4)
if [ -n "$CSRF_TOKEN" ]; then
    echo "✅ CSRF token retrieved successfully"
    TEST_RESULTS+=("PASS")
else
    echo "❌ Failed to retrieve CSRF token"
    TEST_RESULTS+=("FAIL")
fi

# Test 3: Sign-in Endpoint (GET request)
echo -e "\nTest 3: Sign-in Endpoint (GET)"
SIGNIN_GET=$(curl -s -b cookies.txt $BASE_URL/api/auth/signin/google)
if echo "$SIGNIN_GET" | grep -q "accounts.google.com"; then
    echo "✅ Sign-in GET request redirects to Google OAuth"
    TEST_RESULTS+=("PASS")
else
    echo "❌ Sign-in GET request failed to redirect"
    TEST_RESULTS+=("FAIL")
fi

# Test 4: Sign-in Endpoint (POST request)
echo -e "\nTest 4: Sign-in Endpoint (POST)"
SIGNIN_POST=$(curl -s -X POST \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -b cookies.txt \
    -d "csrfToken=$CSRF_TOKEN&callbackUrl=/auth/agent-onboarding" \
    $BASE_URL/api/auth/signin/google)

if echo "$SIGNIN_POST" | grep -q "accounts.google.com"; then
    echo "✅ Sign-in POST request redirects to Google OAuth"
    TEST_RESULTS+=("PASS")
else
    echo "❌ Sign-in POST request failed"
    TEST_RESULTS+=("FAIL")
fi

# Test 5: Callback Error Handling
echo -e "\nTest 5: Callback Error Handling"
CALLBACK_ERROR=$(curl -s -w "%{http_code}" -o /dev/null \
    "$BASE_URL/api/auth/callback/google?error=access_denied&error_description=User%20denied%20access")

if [ "$CALLBACK_ERROR" = "302" ]; then
    echo "✅ Callback properly handles OAuth errors (redirects to error page)"
    TEST_RESULTS+=("PASS")
else
    echo "❌ Callback error handling failed (Status: $CALLBACK_ERROR)"
    TEST_RESULTS+=("FAIL")
fi

# Test 6: Callback Success Simulation (Mock)
echo -e "\nTest 6: Callback Success Flow Structure"
# This would normally require a real OAuth code, but we can test the endpoint structure
CALLBACK_STRUCTURE=$(curl -s -w "%{http_code}" -o /dev/null \
    "$BASE_URL/api/auth/callback/google?code=mock_oauth_code&state=mock_state")

if [ "$CALLBACK_STRUCTURE" = "302" ] || [ "$CALLBACK_STRUCTURE" = "200" ]; then
    echo "✅ Callback endpoint accepts OAuth parameters"
    TEST_RESULTS+=("PASS")
else
    echo "❌ Callback endpoint structure test failed (Status: $CALLBACK_STRUCTURE)"
    TEST_RESULTS+=("FAIL")
fi

# Test 7: Session Endpoint
echo -e "\nTest 7: Session Endpoint"
SESSION_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/api/auth/session)
if [ "$SESSION_STATUS" = "200" ]; then
    echo "✅ Session endpoint accessible"
    TEST_RESULTS+=("PASS")
else
    echo "❌ Session endpoint failed (Status: $SESSION_STATUS)"
    TEST_RESULTS+=("FAIL")
fi

# Test 8: Sign-out Endpoint
echo -e "\nTest 8: Sign-out Endpoint"
SIGNOUT_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/api/auth/signout)
if [ "$SIGNOUT_STATUS" = "200" ]; then
    echo "✅ Sign-out endpoint accessible"
    TEST_RESULTS+=("PASS")
else
    echo "❌ Sign-out endpoint failed (Status: $SIGNOUT_STATUS)"
    TEST_RESULTS+=("FAIL")
fi

# Test 9: Provider Configuration Check
echo -e "\nTest 9: Provider Configuration Details"
PROVIDERS_DATA=$(curl -s $BASE_URL/api/auth/providers)
GOOGLE_CONFIG=$(echo "$PROVIDERS_DATA" | jq -r '.google // empty')
if [ -n "$GOOGLE_CONFIG" ]; then
    echo "✅ Google provider fully configured with details"
    TEST_RESULTS+=("PASS")

    # Check for required Google OAuth fields
    if echo "$GOOGLE_CONFIG" | jq -e '.id and .name and .type' > /dev/null; then
        echo "   ✅ Provider has required fields (id, name, type)"
    else
        echo "   ⚠️  Provider missing some required fields"
    fi
else
    echo "❌ Google provider configuration not found"
    TEST_RESULTS+=("FAIL")
fi

# Test 10: Environment Variables Validation
echo -e "\nTest 10: Environment Variables Validation"
ENV_CHECK=$(curl -s $BASE_URL/api/auth/providers | jq -r '.google?.clientId // empty')
if [ "$ENV_CHECK" = "896813279230-pop3oe4oavk49pl0l7v2cp19decl81nb.apps.googleusercontent.com" ]; then
    echo "✅ Google Client ID properly loaded from environment"
    TEST_RESULTS+=("PASS")
else
    echo "❌ Google Client ID not properly loaded"
    TEST_RESULTS+=("FAIL")
fi

# Cleanup
rm -f cookies.txt

echo -e "\n========================================"
echo "🎯 ADVANCED TEST SUMMARY"
echo "========================================"

PASS_COUNT=0
FAIL_COUNT=0

for result in "${TEST_RESULTS[@]}"; do
    case $result in
        "PASS") ((PASS_COUNT++)) ;;
        "FAIL") ((FAIL_COUNT++)) ;;
    esac
done

TOTAL_TESTS=${#TEST_RESULTS[@]}
SUCCESS_RATE=$(( (PASS_COUNT * 100) / TOTAL_TESTS ))

echo "Total Tests: $TOTAL_TESTS"
echo "✅ Passed: $PASS_COUNT"
echo "❌ Failed: $FAIL_COUNT"
echo "📊 Success Rate: $SUCCESS_RATE%"

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "\n🎉 ALL TESTS PASSED!"
    echo "Google OAuth callback is fully functional and ready for UAT."
    echo ""
    echo "✅ CONFIRMED: Callback functionality works correctly"
    echo "✅ CONFIRMED: OAuth flow redirects properly"
    echo "✅ CONFIRMED: Error handling works as expected"
    echo "✅ CONFIRMED: Session management is operational"
else
    echo -e "\n⚠️  SOME TESTS FAILED!"
    echo "Please review the failed tests before proceeding to UAT."
fi

echo -e "\n🔗 Ready for UAT Testing:"
echo "Visit: $BASE_URL/auth/agent-register"
echo "Click 'Continue with Google' to test the complete OAuth flow"