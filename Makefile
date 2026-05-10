.PHONY: build up down clean secrets

COMPOSE = docker compose -f srcs/docker-compose.yml

# Generate secrets if they don't exist
secrets:
	mkdir -p secrets
	test -f secrets/mariadb_root_password.txt || openssl rand -base64 16 > secrets/mariadb_root_password.txt
	test -f secrets/mariadb_user_password.txt || openssl rand -base64 16 > secrets/mariadb_user_password.txt
	test -f secrets/wordpress_password.txt || openssl rand -base64 16 > secrets/wordpress_password.txt
	test -f secrets/ftp_password.txt || openssl rand -base64 16 > secrets/ftp_password.txt

# Build all services
build:
	$(COMPOSE) build

# Start stack
up: secrets build
	$(COMPOSE) up -d

# Stop stack
down:
	$(COMPOSE) down

# Clean everything
clean:
	$(COMPOSE) down -v --rmi all --remove-orphans
	rm -rf secrets