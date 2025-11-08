#!/bin/bash
# scripts/create-test-user.sh - Create test user in Keycloak for development

echo "👤 Creating test user in Keycloak..."

# Get admin token
TOKEN=$(curl -s -X POST \
  http://localhost:8081/realms/master/protocol/openid-connect/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin&password=admin&grant_type=password&client_id=admin-cli" \
  | jq -r '.access_token')

if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
  echo "❌ Failed to get admin token"
  exit 1
fi

echo "✅ Admin token obtained"

# Create test user
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
  http://localhost:8081/admin/realms/talung/users \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "test.user",
    "email": "test.user@talunglogistic.com",
    "firstName": "Test",
    "lastName": "User",
    "enabled": true,
    "credentials": [
      {
        "type": "password",
        "value": "TestPassword123!",
        "temporary": false
      }
    ],
    "attributes": {
      "employee_code": ["NV001"],
      "department": ["IT"],
      "position": ["Developer"]
    }
  }')

if [ "$RESPONSE" -eq 201 ]; then
  echo "✅ Test user created successfully!"
  echo ""
  echo "📧 Email: test.user@talunglogistic.com"
  echo "🔑 Password: TestPassword123!"
  echo "👤 Username: test.user"
  echo ""
  echo "You can now test the API with real user data!"
else
  echo "⚠️ User may already exist (HTTP $RESPONSE)"
fi