# dir: /talung-sso/scripts
#!/usr/bin/env bash
set -euo pipefail

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

add_mapper () {
  local name="$1"; local userAttr="$2"; local tokenClaim="$3"
  echo "➕ Mapper: $name ($userAttr -> $tokenClaim)"
  curl -s -X POST "$BASE/admin/realms/$REALM/protocol-mappers/models" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
      \"name\":\"$name\",
      \"protocol\":\"openid-connect\",
      \"protocolMapper\":\"oidc-usermodel-attribute-mapper\",
      \"config\":{
        \"user.attribute\":\"$userAttr\",
        \"claim.name\":\"$tokenClaim\",
        \"jsonType.label\":\"String\",
        \"id.token.claim\":\"true\",
        \"access.token.claim\":\"true\",
        \"userinfo.token.claim\":\"true\"
      }
    }" >/dev/null || true
}

add_mapper "employee_id" "employee_id" "employee_id"
add_mapper "department"  "department"  "department"
add_mapper "position"    "position"    "position"

echo "✅ Done. Gắn attributes cho user để thấy claims trong token."
