# JUSTFILE (Updated for Full Stack)

set dotenv-load

default:
    @just --list

# Variables
APP_NAME := "basepack"
BACKEND_DIR := "cmd/api"
FRONTEND_DIR := "web"
BUILD_DIR := "bin"

# === FULL STACK COMMANDS ===

# Setup entire project
setup:
    @echo "Setting up full stack project..."
    @if [ ! -f .env ]; then cp .env.example .env; echo "Created backend .env"; fi
    @if [ ! -f {{FRONTEND_DIR}}/.env.local ]; then cp {{FRONTEND_DIR}}/.env.example {{FRONTEND_DIR}}/.env.local; echo "Created frontend .env.local"; fi
    @mkdir -p {{BUILD_DIR}} tmp logs
    just install-tools
    just install-frontend
    @echo "Setup completed!"

# Start both backend and frontend
dev-all:
    @echo "Starting full stack development..."
    @trap 'kill 0' SIGINT; \
    just dev-backend & \
    just dev-frontend & \
    wait

# Build both backend and frontend
build-all:
    @echo "Building full stack application..."
    just build-backend
    just build-frontend

# === BACKEND COMMANDS ===

# Start backend development server
dev-backend:
    @echo "Starting Go backend..."
    air -c .air.toml

# Build Go backend
build-backend:
    @echo "Building Go backend..."
    @mkdir -p {{BUILD_DIR}}
    go build -o {{BUILD_DIR}}/{{APP_NAME}} ./{{BACKEND_DIR}}

# Test Go backend
test-backend:
    @echo "Testing Go backend..."
    go test -v ./...

# === FRONTEND COMMANDS ===

# Install frontend dependencies
install-frontend:
    @echo "Installing frontend dependencies..."
    cd {{FRONTEND_DIR}} && npm install

# Start frontend development server
dev-frontend:
    @echo "Starting frontend server..."
    cd {{FRONTEND_DIR}} && npm run dev

# Build Next.js frontend
build-frontend:
    @echo "Building frontend..."
    cd {{FRONTEND_DIR}} && npm run build

# Test frontend
test-frontend:
    @echo "Testing frontend..."
    cd {{FRONTEND_DIR}} && npm run test

# Lint frontend
lint-frontend:
    @echo "Linting frontend..."
    cd {{FRONTEND_DIR}} && npm run lint

# === DOCKER COMMANDS ===

# Build all Docker images
docker-build-all:
    @echo "Building all Docker images..."
    docker build -t {{APP_NAME}}-backend -f Dockerfile.backend .
    docker build -t {{APP_NAME}}-frontend -f Dockerfile.frontend ./{{FRONTEND_DIR}}

# Start full stack with Docker
docker-up:
    @echo "Starting full stack with Docker..."
    docker-compose up -d

# === UTILITY COMMANDS ===

# Clean all build artifacts
clean:
    @echo "Cleaning all build artifacts..."
    rm -rf {{BUILD_DIR}} tmp coverage.out coverage.html
    cd {{FRONTEND_DIR}} && rm -rf .next node_modules

# Install all development tools
install-tools:
    @echo "Installing development tools..."
    go install github.com/cosmtrek/air@latest
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest