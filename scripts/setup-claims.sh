# dir: /talung-sso/scripts
#!/usr/bin/env bash
set -euo pipefail

# ===== CONFIG & ENV =====
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env.local"
if [ -f "$ENV_FILE" ]; then export $(grep -v '^#' "$ENV_FILE" | xargs); fi

BASE="${KEYCLOAK_URL:-http://localhost:18080}"
REALM="${KEYCLOAK_REALM:-talung}"
ADMIN="${KEYCLOAK_ADMIN:-admin}"
PASS="${KEYCLOAK_ADMIN_PASSWORD:-adminpass}"

SCOPE_NAME="talung-user-attrs"

echo "🔐 Getting admin token from $BASE ..."
TOKEN=$(curl -s -X POST "$BASE/realms/master/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=$ADMIN&password=$PASS&grant_type=password&client_id=admin-cli" | jq -r '.access_token')

if [ -z "${TOKEN:-}" ] || [ "$TOKEN" = "null" ]; then
  echo "❌ Cannot get admin token. Check admin credentials & Keycloak status."
  exit 1
fi
echo "✅ Admin token obtained"

# ===== FIND or CREATE CLIENT SCOPE =====
echo "🔎 Looking for client-scope: $SCOPE_NAME"
SCOPE_ID=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "$BASE/admin/realms/$REALM/client-scopes" \
  | jq -r --arg n "$SCOPE_NAME" '.[] | select(.name==$n) | .id')

if [ -z "$SCOPE_ID" ] || [ "$SCOPE_ID" = "null" ]; then
  echo "➕ Creating client-scope: $SCOPE_NAME"
  curl -s -X POST "$BASE/admin/realms/$REALM/client-scopes" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"name":"'"$SCOPE_NAME"'","protocol":"openid-connect","attributes":{"include.in.token.scope":"true"}}' >/dev/null

  # fetch again
  SCOPE_ID=$(curl -s -H "Authorization: Bearer $TOKEN" \
    "$BASE/admin/realms/$REALM/client-scopes" \
    | jq -r --arg n "$SCOPE_NAME" '.[] | select(.name==$n) | .id')
fi

if [ -z "$SCOPE_ID" ] || [ "$SCOPE_ID" = "null" ]; then
  echo "❌ Failed to create/find client-scope '$SCOPE_NAME'"
  exit 1
fi
echo "🆔 Scope id: $SCOPE_ID"

# ===== ADD/ENSURE MAPPERS =====
add_mapper () {
  local name="$1"; local userAttr="$2"; local claim="$3"
  echo "➕ Ensuring mapper $name ($userAttr -> $claim)"
  # Try create; if exists, Keycloak returns 409 and we ignore
  curl -s -o /dev/null -w "%{http_code}" \
    -X POST "$BASE/admin/realms/$REALM/client-scopes/$SCOPE_ID/protocol-mappers/models" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
      \"name\":\"$name\",
      \"protocol\":\"openid-connect\",
      \"protocolMapper\":\"oidc-usermodel-attribute-mapper\",
      \"config\":{
        \"user.attribute\":\"$userAttr\",
        \"claim.name\":\"$claim\",
        \"jsonType.label\":\"String\",
        \"id.token.claim\":\"true\",
        \"access.token.claim\":\"true\",
        \"userinfo.token.claim\":\"true\"
      }
    }" | grep -qE "^(201|409)$" || true
}

add_mapper "employee_id" "employee_id" "employee_id"
add_mapper "department"  "department"  "department"
add_mapper "position"    "position"    "position"

# ===== ATTACH AS REALM DEFAULT CLIENT-SCOPE =====
echo "🔗 Attaching '$SCOPE_NAME' as realm default client scope..."
curl -s -o /dev/null -w "%{http_code}" \
  -X PUT "$BASE/admin/realms/$REALM/default-default-client-scopes/$SCOPE_ID" \
  -H "Authorization: Bearer $TOKEN" >/dev/null || true

# ===== ATTACH TO SPECIFIC CLIENTS =====
attach_to_client () {
  local clientId="$1"
  local cid
  cid=$(curl -s -H "Authorization: Bearer $TOKEN" \
    "$BASE/admin/realms/$REALM/clients?clientId=$clientId" | jq -r '.[0].id')
  if [ -z "$cid" ] || [ "$cid" = "null" ]; then
    echo "⚠️  Client not found: $clientId (skip)"
    return
  fi
  echo "🔗 Attaching scope to client $clientId"
  curl -s -o /dev/null -w "%{http_code}" \
    -X PUT "$BASE/admin/realms/$REALM/clients/$cid/default-client-scopes/$SCOPE_ID" \
    -H "Authorization: Bearer $TOKEN" >/dev/null || true
}

attach_to_client "task-frontend"
attach_to_client "task-backend"

echo "✅ Done. Now set user attributes and re-login to see claims in tokens."
