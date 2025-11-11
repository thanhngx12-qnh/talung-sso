# dir: /talung-sso/scripts
# Usage: ./scripts/set-user-attrs.sh email employee_id department position
# Example: ./scripts/set-user-attrs.sh nguyenvana@example.com E001 Operation Staff
# ---
#!/usr/bin/env bash
set -euo pipefail
EMAIL="$1"; EMP="$2"; DEPT="$3"; POS="$4"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env.local"
if [ -f "$ENV_FILE" ]; then export $(grep -v '^#' "$ENV_FILE" | xargs); fi
BASE="${KEYCLOAK_URL:-http://localhost:18080}"
REALM="${KEYCLOAK_REALM:-talung}"
ADMIN="${KEYCLOAK_ADMIN:-admin}"
PASS="${KEYCLOAK_ADMIN_PASSWORD:-adminpass}"
TOKEN=$(curl -s -X POST "$BASE/realms/master/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=$ADMIN&password=$PASS&grant_type=password&client_id=admin-cli" | jq -r .access_token)
USER_ID=$(curl -s "$BASE/admin/realms/$REALM/users?email=$EMAIL" -H "Authorization: Bearer $TOKEN" | jq -r '.[0].id')
[ -z "$USER_ID" ] || [ "$USER_ID" = "null" ] && echo "❌ User not found: $EMAIL" && exit 1
USER=$(curl -s "$BASE/admin/realms/$REALM/users/$USER_ID" -H "Authorization: Bearer $TOKEN")
UPDATED=$(echo "$USER" | jq --arg emp "$EMP" --arg dep "$DEPT" --arg pos "$POS" \
  '.attributes.employee_id = [$emp] | .attributes.department = [$dep] | .attributes.position = [$pos]')
curl -s -X PUT "$BASE/admin/realms/$REALM/users/$USER_ID" \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d "$UPDATED" >/dev/null
echo "✅ Set attributes for $EMAIL: employee_id=$EMP, department=$DEPT, position=$POS"
