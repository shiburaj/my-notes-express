#!/bin/bash

# ==============================================
# Complete Setup Script for Notes Express App
# ==============================================
# Installs everything on a fresh Ubuntu EC2:
#   1. System update
#   2. Docker & Docker Compose
#   3. Configures .env (RDS credentials)
#   4. Builds & starts Docker container
#   5. Runs DB table setup (creates tables on RDS)
# ==============================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

APP_PORT=3000

echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN}   Notes Express App - Complete Setup       ${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

# ----------------------------
# Step 1: System Update
# ----------------------------
echo -e "${YELLOW}[1/5] Updating system packages...${NC}"
sudo apt-get update -y
sudo apt-get upgrade -y
echo -e "${GREEN}  ✔ System updated.${NC}"
echo ""

# ----------------------------
# Step 2: Install Docker
# ----------------------------
echo -e "${YELLOW}[2/5] Installing Docker...${NC}"

if command -v docker &> /dev/null; then
    echo -e "${GREEN}  ✔ Docker is already installed.${NC}"
else
    sudo apt-get install -y ca-certificates curl gnupg lsb-release

    # Add Docker's official GPG key
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # Set up the Docker repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker Engine
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Add current user to docker group
    sudo usermod -aG docker $USER

    # Start and enable Docker
    sudo systemctl start docker
    sudo systemctl enable docker

    echo -e "${GREEN}  ✔ Docker installed successfully.${NC}"
fi
echo ""

# ----------------------------
# Step 3: Configure .env for RDS
# ----------------------------
echo -e "${YELLOW}[3/5] Configuring .env file...${NC}"

if [ ! -f .env ]; then
    cp .env.example .env
    echo -e "${GREEN}  ✔ Created .env from .env.example.${NC}"
else
    echo -e "${GREEN}  ✔ .env file already exists.${NC}"
fi

echo ""
echo -e "${CYAN}  Please enter your RDS credentials:${NC}"
echo ""

read -p "  RDS Endpoint (host): " RDS_HOST
read -p "  RDS Username [root]: " RDS_USER
RDS_USER=${RDS_USER:-root}
read -sp "  RDS Password: " RDS_PASS
echo ""
read -p "  Database name [notes]: " RDS_DB
RDS_DB=${RDS_DB:-notes}

cat > .env << EOF
KEY="jhbjsagasdlkzxmdch892374anmsdad"
APP_PORT=${APP_PORT}
DB_HOST="${RDS_HOST}"
DB_USER="${RDS_USER}"
DB_PASS="${RDS_PASS}"
DB_DATABASE="${RDS_DB}"
EOF

echo -e "${GREEN}  ✔ .env configured with RDS credentials.${NC}"
echo ""

# ----------------------------
# Step 4: Build and start container
# ----------------------------
echo -e "${YELLOW}[4/5] Building and starting app container...${NC}"

sudo docker compose up -d --build

echo -e "${GREEN}  ✔ App container is running.${NC}"
echo ""

# ----------------------------
# Step 5: Run DB table setup
# ----------------------------
echo -e "${YELLOW}[5/5] Creating tables on RDS...${NC}"
sleep 5
sudo docker compose exec -T app npm run setup

echo -e "${GREEN}  ✔ Database tables created on RDS.${NC}"
echo ""

# ----------------------------
# Done!
# ----------------------------
echo -e "${CYAN}============================================${NC}"
echo -e "${GREEN}  ✔ SETUP COMPLETE!${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""
echo -e "  🌐 App running at:  ${GREEN}http://localhost:${APP_PORT}${NC}"
echo ""
echo -e "  📌 Make sure port ${APP_PORT} is open in your"
echo -e "     AWS Security Group (Inbound Rules)."
echo ""
echo -e "  Useful commands:"
echo -e "    ${CYAN}sudo docker compose logs -f${NC}        - View logs"
echo -e "    ${CYAN}sudo docker compose down${NC}           - Stop container"
echo -e "    ${CYAN}sudo docker compose restart${NC}        - Restart"
echo -e "    ${CYAN}sudo docker compose exec app sh${NC}    - Shell into container"
echo ""
