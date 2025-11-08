#!/bin/bash
# scripts/init-local.sh

echo "🚀 Initializing Talung SSO Local Environment..."

# Wait for Keycloak to be ready with longer timeout
echo "⏳ Waiting for Keycloak to start..."
MAX_RETRIES=30
RETRY_COUNT=0

# Keycloak 21+ doesn't have /auth context path
until curl -f http://localhost:8081/realms/master > /dev/null 2>&1; do
  RETRY_COUNT=$((RETRY_COUNT+1))
  if [ $RETRY_COUNT -gt $MAX_RETRIES ]; then
    echo "❌ Keycloak failed to start after $MAX_RETRIES retries"
    exit 1
  fi
  echo "Waiting for Keycloak... ($RETRY_COUNT/$MAX_RETRIES)"
  sleep 10
done

echo "✅ Keycloak is ready!"

# Get admin token
echo "🔑 Getting admin token..."
TOKEN=$(curl -s -X POST \
  http://localhost:8081/realms/master/protocol/openid-connect/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin&password=admin&grant_type=password&client_id=admin-cli" \
  | jq -r '.access_token')

if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
  echo "❌ Failed to get admin token"
  echo "Debug: Trying to access Keycloak directly..."
  curl -v http://localhost:8081/realms/master
  exit 1
fi

echo "✅ Admin token obtained"

# Create talung realm
echo "🏢 Creating talung realm..."
REALM_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
  http://localhost:8081/admin/realms \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "realm": "talung",
    "enabled": true,
    "displayName": "Talung Logistics",
    "loginWithEmailAllowed": true,
    "duplicateEmailsAllowed": false,
    "resetPasswordAllowed": true,
    "editUsernameAllowed": false,
    "bruteForceProtected": true
  }')

if [ "$REALM_RESPONSE" -eq 201 ]; then
  echo "✅ Realm 'talung' created"
else
  echo "⚠️ Realm may already exist (HTTP $REALM_RESPONSE)"
fi

# Create admin-api client
echo "🔧 Creating admin-api client..."
CLIENT_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
  http://localhost:8081/admin/realms/talung/clients \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "clientId": "admin-api",
    "enabled": true,
    "publicClient": false,
    "secret": "admin-api-secret",
    "redirectUris": ["http://localhost:3001/*"],
    "webOrigins": ["http://localhost:3001"],
    "protocol": "openid-connect",
    "attributes": {
      "access.token.lifespan": 300
    }
  }')

if [ "$CLIENT_RESPONSE" -eq 201 ]; then
  echo "✅ Client 'admin-api' created"
else
  echo "⚠️ Client may already exist (HTTP $CLIENT_RESPONSE)"
fi

# Create admin-frontend client
echo "🎨 Creating admin-frontend client..."
FRONTEND_CLIENT_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
  http://localhost:8081/admin/realms/talung/clients \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "clientId": "admin-frontend",
    "enabled": true,
    "publicClient": true,
    "redirectUris": ["http://localhost:5173/*", "http://localhost:5174/*"],
    "webOrigins": ["http://localhost:5173", "http://localhost:5174"],
    "protocol": "openid-connect"
  }')

if [ "$FRONTEND_CLIENT_RESPONSE" -eq 201 ]; then
  echo "✅ Client 'admin-frontend' created"
else
  echo "⚠️ Client may already exist (HTTP $FRONTEND_CLIENT_RESPONSE)"
fi

# Create realm roles
echo "👥 Creating realm roles..."
roles=("employee" "manager" "director" "admin" "hr-admin" "system-admin")

for role in "${roles[@]}"; do
  ROLE_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
    http://localhost:8081/admin/realms/talung/roles \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"$role\"}")
  
  if [ "$ROLE_RESPONSE" -eq 201 ]; then
    echo "✅ Role '$role' created"
  else
    echo "⚠️ Role '$role' may already exist (HTTP $ROLE_RESPONSE)"
  fi
done

echo "🎉 Talung SSO initialization completed!"