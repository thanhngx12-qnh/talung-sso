# dir: /talung-sso/scripts
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env.local"
if [ -f "$ENV_FILE" ]; then export $(grep -v '^#' "$ENV_FILE" | xargs); fi

BASE="${KEYCLOAK_URL:-http://localhost:18080}"
REALM="${KEYCLOAK_REALM:-talung}"
ADMIN="${KEYCLOAK_ADMIN:-admin}"
PASS="${KEYCLOAK_ADMIN_PASSWORD:-adminpass}"

# admin token
TOKEN=$(curl -s -X POST "$BASE/realms/master/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=$ADMIN&password=$PASS&grant_type=password&client_id=admin-cli" | jq -r .access_token)

[ -z "$TOKEN" -o "$TOKEN" = "null" ] && echo "❌ Cannot get admin token" && exit 1

# find built-in client scope "roles"
ROLES_SCOPE_ID=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "$BASE/admin/realms/$REALM/client-scopes" \
  | jq -r '.[] | select(.name=="roles") | .id')

[ -z "$ROLES_SCOPE_ID" -o "$ROLES_SCOPE_ID" = "null" ] && echo "❌ Built-in client scope 'roles' not found" && exit 1

# attach as realm default (optional but good)
curl -s -X PUT \
  "$BASE/admin/realms/$REALM/default-default-client-scopes/$ROLES_SCOPE_ID" \
  -H "Authorization: Bearer $TOKEN" >/dev/null || true

attach_to_client () {
  local clientId="$1"
  local cid
  cid=$(curl -s -H "Authorization: Bearer $TOKEN" \
    "$BASE/admin/realms/$REALM/clients?clientId=$clientId" | jq -r '.[0].id')
  if [ -z "$cid" -o "$cid" = "null" ]; then
    echo "⚠️ Client not found: $clientId"
    return
  fi
  curl -s -X PUT \
    "$BASE/admin/realms/$REALM/clients/$cid/default-client-scopes/$ROLES_SCOPE_ID" \
    -H "Authorization: Bearer $TOKEN" >/dev/null || true
  echo "✅ Attached 'roles' scope to client $clientId"
}

attach_to_client "task-frontend"
attach_to_client "task-backend"
echo "✅ Done attaching 'roles' scope"
