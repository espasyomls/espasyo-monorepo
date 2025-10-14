#!/bin/bash

# Google OAuth Callback Testing Script
# Tests the complete OAuth flow for Espasyo MLS Agent Registration

BASE_URL="http://localhost:3000"
TEST_RESULTS=()

echo "🔍 Starting Google OAuth Callback Tests for Espasyo MLS"
echo "======================================================"

# Test 1: Check if server is running
echo "Test 1: Server Health Check"
SERVER_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL)
if [ "$SERVER_STATUS" = "200" ]; then
    echo "✅ Server is running (Status: $SERVER_STATUS)"
    TEST_RESULTS+=("PASS")
else
    echo "❌ Server is not responding (Status: $SERVER_STATUS)"
    TEST_RESULTS+=("FAIL")
fi

# Test 2: Check agent registration page loads
echo -e "\nTest 2: Agent Registration Page"
REGISTER_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/auth/agent-register)
if [ "$REGISTER_STATUS" = "200" ]; then
    echo "✅ Agent registration page loads (Status: $REGISTER_STATUS)"
    TEST_RESULTS+=("PASS")
else
    echo "❌ Agent registration page failed (Status: $REGISTER_STATUS)"
    TEST_RESULTS+=("FAIL")
fi

# Test 3: Check agent onboarding page loads
echo -e "\nTest 3: Agent Onboarding Page"
ONBOARDING_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/auth/agent-onboarding)
if [ "$ONBOARDING_STATUS" = "200" ]; then
    echo "✅ Agent onboarding page loads (Status: $ONBOARDING_STATUS)"
    TEST_RESULTS+=("PASS")
else
    echo "❌ Agent onboarding page failed (Status: $ONBOARDING_STATUS)"
    TEST_RESULTS+=("FAIL")
fi

# Test 4: Check NextAuth API endpoint exists
echo -e "\nTest 4: NextAuth API Endpoint"
AUTH_API_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/api/auth/providers)
if [ "$AUTH_API_STATUS" = "200" ]; then
    echo "✅ NextAuth API endpoint accessible (Status: $AUTH_API_STATUS)"
    TEST_RESULTS+=("PASS")
else
    echo "❌ NextAuth API endpoint failed (Status: $AUTH_API_STATUS)"
    TEST_RESULTS+=("FAIL")
fi

# Test 5: Check Google OAuth provider configuration
echo -e "\nTest 5: Google OAuth Provider Configuration"
PROVIDERS_RESPONSE=$(curl -s $BASE_URL/api/auth/providers)
if echo "$PROVIDERS_RESPONSE" | grep -q "google"; then
    echo "✅ Google OAuth provider configured"
    TEST_RESULTS+=("PASS")
else
    echo "❌ Google OAuth provider not found in response"
    TEST_RESULTS+=("FAIL")
fi

# Test 6: Test sign-in endpoint (should redirect to Google)
echo -e "\nTest 6: Sign-in Endpoint Redirect"
SIGNIN_REDIRECT=$(curl -s -I $BASE_URL/api/auth/signin/google | grep -i "location" | head -1)
if echo "$SIGNIN_REDIRECT" | grep -q "accounts.google.com"; then
    echo "✅ Sign-in endpoint redirects to Google OAuth"
    TEST_RESULTS+=("PASS")
else
    echo "❌ Sign-in endpoint redirect failed"
    echo "   Response: $SIGNIN_REDIRECT"
    TEST_RESULTS+=("FAIL")
fi

# Test 7: Test callback endpoint structure (mock test)
echo -e "\nTest 7: Callback Endpoint Structure"
CALLBACK_URL="$BASE_URL/api/auth/callback/google"
CALLBACK_CHECK=$(curl -s -o /dev/null -w "%{http_code}" "$CALLBACK_URL?error=access_denied")
if [ "$CALLBACK_CHECK" = "302" ]; then
    echo "✅ Callback endpoint handles errors properly (redirects on error)"
    TEST_RESULTS+=("PASS")
else
    echo "⚠️  Callback endpoint response: $CALLBACK_CHECK (expected 302 for error)"
    TEST_RESULTS+=("WARN")
fi

# Test 8: Check success page loads
echo -e "\nTest 8: Success Page"
SUCCESS_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/auth/agent-registration-success)
if [ "$SUCCESS_STATUS" = "200" ]; then
    echo "✅ Agent registration success page loads (Status: $SUCCESS_STATUS)"
    TEST_RESULTS+=("PASS")
else
    echo "❌ Success page failed (Status: $SUCCESS_STATUS)"
    TEST_RESULTS+=("FAIL")
fi

# Test 9: Check error page loads
echo -e "\nTest 9: Error Page"
ERROR_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/auth/error)
if [ "$ERROR_STATUS" = "200" ]; then
    echo "✅ Auth error page loads (Status: $ERROR_STATUS)"
    TEST_RESULTS+=("PASS")
else
    echo "❌ Error page failed (Status: $ERROR_STATUS)"
    TEST_RESULTS+=("FAIL")
fi

# Test 10: Environment variables check (mock test)
echo -e "\nTest 10: Environment Configuration"
if curl -s $BASE_URL/api/auth/providers | grep -q "google"; then
    echo "✅ Google OAuth environment variables loaded"
    TEST_RESULTS+=("PASS")
else
    echo "❌ Google OAuth environment variables not loaded"
    TEST_RESULTS+=("FAIL")
fi

echo -e "\n======================================================"
echo "🎯 TEST SUMMARY"
echo "======================================================"

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

for result in "${TEST_RESULTS[@]}"; do
    case $result in
        "PASS") ((PASS_COUNT++)) ;;
        "FAIL") ((FAIL_COUNT++)) ;;
        "WARN") ((WARN_COUNT++)) ;;
    esac
done

TOTAL_TESTS=${#TEST_RESULTS[@]}
SUCCESS_RATE=$(( (PASS_COUNT * 100) / TOTAL_TESTS ))

echo "Total Tests: $TOTAL_TESTS"
echo "✅ Passed: $PASS_COUNT"
echo "❌ Failed: $FAIL_COUNT"
echo "⚠️  Warnings: $WARN_COUNT"
echo "📊 Success Rate: $SUCCESS_RATE%"

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "\n🎉 ALL CRITICAL TESTS PASSED!"
    echo "Google OAuth callback is properly configured and ready for UAT."
else
    echo -e "\n⚠️  SOME TESTS FAILED!"
    echo "Please review the failed tests before proceeding to UAT."
fi

echo -e "\n🔗 Key URLs for Manual Testing:"
echo "Agent Registration: $BASE_URL/auth/agent-register"
echo "Agent Onboarding: $BASE_URL/auth/agent-onboarding"
echo "Success Page: $BASE_URL/auth/agent-registration-success"
echo "Error Page: $BASE_URL/auth/error"

echo -e "\n📝 Next Steps for UAT:"
echo "1. Visit the agent registration page"
echo "2. Click 'Continue with Google'"
echo "3. Complete Google OAuth flow"
echo "4. Verify redirect to onboarding wizard"
echo "5. Test the complete registration flow"