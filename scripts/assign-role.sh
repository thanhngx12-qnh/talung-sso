# dir: /talung-sso/scripts
#!/usr/bin/env bash
set -euo pipefail
EMAIL="${1:-}"; ROLE="${2:-}"
[ -z "$EMAIL" -o -z "$ROLE" ] && echo "Usage: $0 user@example.com role" && exit 1

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
[ -z "$USER_ID" -o "$USER_ID" = "null" ] && echo "❌ User not found: $EMAIL" && exit 1

ROLE_OBJ=$(curl -s "$BASE/admin/realms/$REALM/roles/$ROLE" -H "Authorization: Bearer $TOKEN")
ROLE_ID=$(echo "$ROLE_OBJ" | jq -r '.id'); ROLE_NAME=$(echo "$ROLE_OBJ" | jq -r '.name')
[ -z "$ROLE_ID" -o "$ROLE_ID" = "null" ] && echo "❌ Role not found: $ROLE" && exit 1

RESP=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
  "$BASE/admin/realms/$REALM/users/$USER_ID/role-mappings/realm" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "[{\"id\":\"$ROLE_ID\",\"name\":\"$ROLE_NAME\"}]")
[ "$RESP" != "204" ] && echo "⚠️ Assign role HTTP $RESP" || echo "✅ Assigned role '$ROLE_NAME' to $EMAIL"
