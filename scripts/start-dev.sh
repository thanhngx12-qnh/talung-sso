#!/bin/bash
# scripts/start-dev.sh

echo "🚀 Starting Talung SSO Development Environment..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
  echo "❌ Docker is not running. Please start Docker Desktop first."
  exit 1
fi

# Stop existing containers if any
echo "🧹 Cleaning up existing containers..."
docker-compose -f docker/docker-compose.local.yml down

# Start Docker services
echo "🐳 Starting Docker services..."
docker-compose -f docker/docker-compose.local.yml up -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 30

# Initialize Keycloak realm and clients
echo "⚙️ Initializing Keycloak..."
./scripts/init-local.sh

echo ""
echo "✅ Development environment is ready!"
echo ""
echo "📊 Keycloak Admin Console: http://localhost:8081/admin"  # Đổi từ 8080 sang 8081
echo "   👤 Username: admin"
echo "   🔑 Password: admin"
echo ""
echo "🔌 Keycloak Server: http://localhost:8081"  # Đổi từ 8080 sang 8081
echo "🗄️  PostgreSQL: localhost:5433"  # Đổi từ 5432 sang 5433
echo "🔧 Backend API: http://localhost:3001"  # Đổi từ 3000 sang 3001
echo ""
echo "Next steps:"
echo "1. Run backend: cd backend && npm run dev"
echo "2. Run frontend: cd frontend && npm run dev"