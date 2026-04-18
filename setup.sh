#!/bin/bash

# ==============================================
# Setup Script for Notes Express App
# ==============================================
# This script automates the full deployment:
#   1. Checks for Docker & Docker Compose
#   2. Copies .env.example to .env (if needed)
#   3. Builds and starts the app container
#   4. Runs the database setup (creates tables)
# ==============================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}   Notes Express App - Setup Script     ${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# ----------------------------
# Step 1: Check prerequisites
# ----------------------------
echo -e "${YELLOW}[1/4] Checking prerequisites...${NC}"

if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed. Please install Docker first.${NC}"
    echo "  -> https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}Error: Docker Compose is not installed. Please install it first.${NC}"
    echo "  -> https://docs.docker.com/compose/install/"
    exit 1
fi

echo -e "${GREEN}  ✔ Docker and Docker Compose found.${NC}"
echo ""

# ----------------------------
# Step 2: Setup .env file
# ----------------------------
echo -e "${YELLOW}[2/4] Setting up environment file...${NC}"

if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        cp .env.example .env
        echo -e "${GREEN}  ✔ Created .env from .env.example.${NC}"
        echo -e "${YELLOW}  ⚠ Please edit .env with your database credentials before proceeding.${NC}"
        echo -e "    DB_HOST, DB_USER, DB_PASS, DB_DATABASE"
        echo ""
        read -p "  Press Enter after editing .env to continue..."
    else
        echo -e "${RED}Error: .env.example not found. Cannot create .env file.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}  ✔ .env file already exists. Skipping.${NC}"
fi
echo ""

# ----------------------------
# Step 3: Build and start app
# ----------------------------
echo -e "${YELLOW}[3/4] Building and starting the app container...${NC}"
docker-compose up -d --build
echo -e "${GREEN}  ✔ App container started.${NC}"
echo ""

# ----------------------------
# Step 4: Run DB setup
# ----------------------------
echo -e "${YELLOW}[4/4] Running database setup...${NC}"
sleep 3  # Give the app a moment to start
docker-compose exec -T app npm run setup
echo -e "${GREEN}  ✔ Database tables created.${NC}"
echo ""

# ----------------------------
# Done!
# ----------------------------
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}  ✔ Setup complete!${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""
echo -e "  App running at:  ${GREEN}http://localhost:3000${NC}"
echo ""
echo -e "  Useful commands:"
echo -e "    ${CYAN}make logs${NC}      - View logs"
echo -e "    ${CYAN}make down${NC}      - Stop container"
echo -e "    ${CYAN}make restart${NC}   - Restart container"
echo -e "    ${CYAN}make shell${NC}     - Shell into app container"
echo ""
