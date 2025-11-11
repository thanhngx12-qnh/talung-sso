# dir: /talung-sso/scripts
#!/usr/bin/env bash
set -euo pipefail

USER_EMAIL="${1:-}"
if [ -z "$USER_EMAIL" ]; then
  echo "Usage: $0 user@example.com"
  exit 1
fi

# Load env
ENV_FILE="$(cd "$(dirname "$0")/.." && pwd)/.env.local"
if [ -f "$ENV_FILE" ]; then export $(grep -v '^#' "$ENV_FILE" | xargs); fi

BASE="${KEYCLOAK_URL:-http://localhost:18080}"
REALM="${KEYCLOAK_REALM:-talung}"
ADMIN="${KEYCLOAK_ADMIN:-admin}"
PASS="${KEYCLOAK_ADMIN_PASSWORD:-adminpass}"

echo "🔐 Getting admin token..."
TOKEN=$(curl -s -X POST "$BASE/realms/master/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=$ADMIN&password=$PASS&grant_type=password&client_id=admin-cli" | jq -r .access_token)

USER_ID=$(curl -s -X GET "$BASE/admin/realms/$REALM/users?email=$USER_EMAIL" \
  -H "Authorization: Bearer $TOKEN" | jq -r '.[0].id')

if [ "$USER_ID" = "null" ] || [ -z "$USER_ID" ]; then
  echo "❌ User not found: $USER_EMAIL"
  exit 1
fi

NEW_PASS="Talung@123"
curl -s -X PUT "$BASE/admin/realms/$REALM/users/$USER_ID/reset-password" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"type\":\"password\",\"value\":\"$NEW_PASS\",\"temporary\":false}"

echo "✅ Password reset done for $USER_EMAIL"
echo "🔑 New password: $NEW_PASS"
