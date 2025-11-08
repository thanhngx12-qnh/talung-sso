# dir: /talung-sso/scripts
#!/usr/bin/env bash
set -euo pipefail

# Khởi tạo Keycloak realm + clients + roles (dev)
# Yêu cầu: docker-compose đã chạy và Keycloak dev đang hoạt động ở KEYCLOAK_URL trong .env.local

# Load env from project root .env.local (nếu có)
ENV_FILE="$(cd "$(dirname "$0")/.." && pwd)/.env.local"
if [ -f "$ENV_FILE" ]; then
  export $(grep -v '^#' "$ENV_FILE" | xargs)
fi

KEYCLOAK_URL="${KEYCLOAK_URL:-http://localhost:18080}"
ADMIN_USER="${KEYCLOAK_ADMIN:-admin}"
ADMIN_PASS="${KEYCLOAK_ADMIN_PASSWORD:-adminpass}"
REALM="${KEYCLOAK_REALM:-talung}"

echo "🚀 Initializing Talung SSO (Keycloak) at $KEYCLOAK_URL"
echo "⏳ Waiting for Keycloak to be ready..."

# Wait for keycloak
until curl -s "${KEYCLOAK_URL}" >/dev/null 2>&1; do
  echo "Waiting for Keycloak..."
  sleep 5
done

# Get admin token
echo "🔑 Getting admin token..."
TOKEN=$(curl -s -X POST \
  "${KEYCLOAK_URL}/realms/master/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=${ADMIN_USER}&password=${ADMIN_PASS}&grant_type=password&client_id=admin-cli" \
  | jq -r '.access_token')

if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
  echo "❌ Failed to get admin token. Ensure KEYCLOAK_ADMIN credentials are correct."
  exit 1
fi

echo "✅ Admin token obtained"

# Create realm
echo "🏢 Creating realm: ${REALM} (if not exists)..."
EXISTS=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $TOKEN" "${KEYCLOAK_URL}/admin/realms/${REALM}" || true)
if [ "$EXISTS" = "200" ]; then
  echo "Realm ${REALM} already exists"
else
  curl -s -X POST \
    "${KEYCLOAK_URL}/admin/realms" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"realm\":\"${REALM}\",\"enabled\":true}" >/dev/null
  echo "✅ Realm '${REALM}' created"
fi

# Create a public SPA client (task-frontend)
echo "🔧 Creating client: task-frontend (public, PKCE)"
curl -s -X POST \
  "${KEYCLOAK_URL}/admin/realms/${REALM}/clients" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "clientId": "task-frontend",
    "enabled": true,
    "publicClient": true,
    "protocol": "openid-connect",
    "redirectUris": ["http://localhost:5174/*"],
    "webOrigins": ["http://localhost:5174"]
  }' >/dev/null
echo "✅ Client 'task-frontend' created (public)"

# Create a confidential backend client (task-backend)
echo "🔧 Creating client: task-backend (confidential)"
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
  }' >/dev/null
echo "✅ Client 'task-backend' created (confidential)"

# Create realm roles
echo "👥 Creating realm roles..."
roles=("employee" "manager" "admin" "hr-admin" "system-admin")
for r in "${roles[@]}"; do
  curl -s -X POST \
    "${KEYCLOAK_URL}/admin/realms/${REALM}/roles" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"name\":\"$r\"}" >/dev/null || true
  echo " - role $r ensured"
done

echo "🎉 Initialization finished!"
