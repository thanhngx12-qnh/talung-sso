# dir: /talung-sso/scripts
#!/usr/bin/env bash
set -euo pipefail

# Tạo thư mục backup
BACKUP_DIR="$(cd "$(dirname "$0")/.." && pwd)/keycloak-backups/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Export realm qua kc.sh (chạy trong container)
echo "📦 Exporting realm via container command..."
docker exec talung-keycloak /opt/keycloak/bin/kc.sh export \
  --dir /opt/keycloak/data/export --users realm_file --realm talung

# Copy ra host
docker cp talung-keycloak:/opt/keycloak/data/export "$BACKUP_DIR"

echo "✅ Backup done → $BACKUP_DIR"
