# dir: /talung-sso/scripts
#!/usr/bin/env bash
set -euo pipefail

# Load env
ENV_FILE="$(cd "$(dirname "$0")/.." && pwd)/.env.local"
if [ -f "$ENV_FILE" ]; then
  export $(grep -v '^#' "$ENV_FILE" | xargs)
fi

KEYCLOAK_URL="${KEYCLOAK_URL:-http://localhost:18080}"
ADMIN_USER="${KEYCLOAK_ADMIN:-admin}"
ADMIN_PASS="${KEYCLOAK_ADMIN_PASSWORD:-adminpass}"
REALM="${KEYCLOAK_REALM:-talung}"

echo "🚀 Initializing Talung SSO (Keycloak) at $KEYCLOAK_URL"
echo "⏳ Waiting for Keycloak (master realm endpoint)..."

# Wait for Keycloak master realm endpoint to respond 200
RETRIES=60
SLEEP=5
for i in $(seq 1 $RETRIES); do
  if curl -fsS "${KEYCLOAK_URL}/realms/master" >/dev/null 2>&1; then
    echo "✅ Keycloak is ready"
    break
  fi
  echo "Waiting ($i/$RETRIES)..."
  sleep $SLEEP
done

# Get admin token
echo "🔑 Getting admin token..."
TOKEN=$(curl -s -X POST \
  "${KEYCLOAK_URL}/realms/master/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=${ADMIN_USER}&password=${ADMIN_PASS}&grant_type=password&client_id=admin-cli" \
  | jq -r '.access_token')

if [ -z "${TOKEN:-}" ] || [ "$TOKEN" = "null" ]; then
  echo "❌ Failed to get admin token (check admin credentials or Keycloak status)."
  exit 1
fi
echo "✅ Admin token obtained"

# Ensure realm exists
echo "🏢 Ensuring realm '${REALM}'..."
EXISTS=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: Bearer $TOKEN" "${KEYCLOAK_URL}/admin/realms/${REALM}" || true)
if [ "$EXISTS" != "200" ]; then
  curl -s -X POST \
    "${KEYCLOAK_URL}/admin/realms" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"realm\":\"${REALM}\",\"enabled\":true}" >/dev/null
  echo "✅ Realm '${REALM}' created"
else
  echo "ℹ️ Realm '${REALM}' exists"
fi

# Create clients (idempotent-ish)
echo "🔧 Creating/ensuring client: task-frontend (public)"
curl -s -X POST \
  "${KEYCLOAK_URL}/admin/realms/${REALM}/clients" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "clientId": "task-frontend",
    "enabled": true,
    "publicClient": true,
    "protocol": "openid-connect",
    "redirectUris": ["http://localhost:5174/*","http://localhost:5173/*"],
    "webOrigins": ["http://localhost:5174","http://localhost:5173"]
  }' >/dev/null || true

echo "🔧 Creating/ensuring client: task-backend (confidential)"
curl -s -X POST \
  "${KEYCLOAK_URL}/admin/realms/${REALM}/clients" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "clientId": "task-backend",
    "enabled": true,
    "publicClient": false,
    "protocol": "openid-connect",
    "redirectUris": ["http://localhost:3001/*"],
    "webOrigins": ["http://localhost:3001"]
  }' >/dev/null || true

# Roles
echo "👥 Ensuring realm roles..."
roles=("employee" "manager" "admin" "hr-admin" "system-admin")
for r in "${roles[@]}"; do
  curl -s -X POST \
    "${KEYCLOAK_URL}/admin/realms/${REALM}/roles" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"name\":\"$r\"}" >/dev/null || true
  echo " - $r"
done

echo "🎉 Initialization finished!"
