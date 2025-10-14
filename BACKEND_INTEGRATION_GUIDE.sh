#!/bin/bash

# Backend Integration Setup Guide
echo "🔧 Backend Integration Setup for Admin Agent Verification"
echo "======================================================"
echo ""

echo "✅ COMPLETED:"
echo "- Frontend configured to call eDSL service (http://localhost:8080)"
echo "- Error handling for backend connection failures"
echo "- Review actions integrated with backend API calls"
echo "- Environment variables configured (NEXT_PUBLIC_EDSL_URL)"
echo ""

echo "🚀 TO START BACKEND SERVICES:"
echo ""
echo "1. Navigate to infrastructure directory:"
echo "   cd /home/boggss/espasyoMLS/espasyo-infrastructure"
echo ""
echo "2. Start essential services:"
echo "   docker compose -f docker-compose.local.yml up -d \\"
echo "     postgres edsl verification-service"
echo ""
echo "3. Verify services are running:"
echo "   docker ps --filter 'name=espasyo'"
echo ""
echo "4. Test eDSL connectivity:"
echo "   curl http://localhost:8080/health"
echo ""

echo "🔍 EXPECTED ENDPOINTS:"
echo "- GET  http://localhost:8080/api/admin/agent-verifications"
echo "- POST http://localhost:8080/api/admin/agent-verifications/{id}/review"
echo ""

echo "📝 NEXT STEPS:"
echo "- Start Docker services"
echo "- Test frontend-backend integration"
echo "- Implement document viewing/download"
echo "- Add bulk actions functionality"
echo ""

echo "⚠️  NOTE: Docker compose paths may need adjustment for correct service locations"