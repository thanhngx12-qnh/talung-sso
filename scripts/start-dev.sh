# dir: /talung-sso/scripts
#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Starting Talung SSO Development Environment..."

# Check Docker
if ! docker info >/dev/null 2>&1; then
  echo "❌ Docker not running. Start Docker Desktop and retry."
  exit 1
fi

# Start docker-compose
echo "🐳 Starting docker-compose services..."
docker-compose -f docker/docker-compose.local.yml up -d --remove-orphans

# Wait a bit then run init script
echo "⏳ Waiting 10s for containers to start..."
sleep 10

echo "⚙️ Running Keycloak initialization..."
./scripts/init-local.sh

echo ""
echo "✅ Development environment ready!"
echo "Keycloak admin console: http://localhost:18080/"
echo "Backend API: http://localhost:3001"
echo "Frontend (dev): http://localhost:5174"
