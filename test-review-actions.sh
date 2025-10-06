#!/bin/bash

# Test script for admin agent verification review actions
echo "Testing Admin Agent Verification Review Actions..."

# Test the main API endpoint
echo "Testing main API endpoint..."
curl -s http://localhost:3001/api/admin/agent-verifications | jq '.applications[0] | {id, status, userInfo}' || echo "Failed to fetch applications"

# Test approve action
echo -e "\nTesting approve action..."
curl -s -X POST http://localhost:3001/api/admin/agent-verifications/1/review \
  -H "Content-Type: application/json" \
  -d '{"action":"approve","notes":"Approved after document verification","reviewedBy":"admin-1","reviewedAt":"2024-01-16T10:00:00Z"}' | jq . || echo "Failed to approve application"

# Test decline action
echo -e "\nTesting decline action..."
curl -s -X POST http://localhost:3001/api/admin/agent-verifications/2/review \
  -H "Content-Type: application/json" \
  -d '{"action":"decline","notes":"Documents incomplete","reviewedBy":"admin-1","reviewedAt":"2024-01-16T10:05:00Z"}' | jq . || echo "Failed to decline application"

# Test request more info action
echo -e "\nTesting request more info action..."
curl -s -X POST http://localhost:3001/api/admin/agent-verifications/3/review \
  -H "Content-Type: application/json" \
  -d '{"action":"request_more_info","notes":"Need additional tax documents","reviewedBy":"admin-1","reviewedAt":"2024-01-16T10:10:00Z"}' | jq . || echo "Failed to request more info"

# Check updated applications
echo -e "\nChecking updated applications..."
curl -s http://localhost:3001/api/admin/agent-verifications | jq '.applications[] | {id, status, reviewNotes}' || echo "Failed to fetch updated applications"

echo -e "\nAdmin Agent Verification Review Actions test completed!"