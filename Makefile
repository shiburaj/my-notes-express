# Makefile for Notes Express App

.PHONY: build up down restart logs setup clean status

# Build Docker images
build:
	docker-compose build

# Start all services in detached mode
up:
	docker-compose up -d

# Build and start all services
up-build:
	docker-compose up -d --build

# Stop all services
down:
	docker-compose down

# Restart all services
restart:
	docker-compose restart

# View logs (follow mode)
logs:
	docker-compose logs -f

# Run database setup (create tables)
setup:
	docker-compose exec app npm run setup

# Show running containers
status:
	docker-compose ps

# Remove all containers and images
clean:
	docker-compose down --rmi all

# Shell into the app container
shell:
	docker-compose exec app sh
