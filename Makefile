# Makefile for Notes Express App

.PHONY: build up down restart logs setup clean status shell

# Build Docker images
build:
	sudo docker compose build

# Start all services in detached mode
up:
	sudo docker compose up -d

# Build and start all services
up-build:
	sudo docker compose up -d --build

# Stop all services
down:
	sudo docker compose down

# Restart all services
restart:
	sudo docker compose restart

# View logs (follow mode)
logs:
	sudo docker compose logs -f

# Run database setup (create tables)
setup:
	sudo docker compose exec app npm run setup

# Show running containers
status:
	sudo docker compose ps

# Remove all containers and images
clean:
	sudo docker compose down --rmi all

# Shell into the app container
shell:
	sudo docker compose exec app sh
