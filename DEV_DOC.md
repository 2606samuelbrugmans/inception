# Developer Documentation

## Project Setup from Scratch

### Prerequisites

- Linux system (or WSL on Windows)
- Docker Desktop or Docker Engine
- Docker Compose
- `make` utility
- Git (for version control)
- Text editor

### Installation Steps

1. **Clone or create the project**:
   ```bash
   mkdir inception && cd inception
   ```

2. **Create project structure**:
   ```bash
   mkdir -p srcs/requirements/{nginx,wordpress,mariadb,bonus/{adminer,redis,ftp_server,static_page}}
   mkdir secrets
   ```

3. **Create Makefile** at the root:
   ```bash
   touch Makefile
   ```

4. **Create docker-compose.yml** in `srcs/`:
   ```bash
   touch srcs/docker-compose.yml
   ```

5. **Create configuration files** for each service (Dockerfiles, config files, scripts)

## Building and Launching

### Using the Makefile

```bash
# Generate secrets and build everything
make up

# Build only (without starting)
make build

# Stop containers
make down

# Full cleanup (remove volumes, images, networks)
make clean
```

### Manual Docker Compose Commands

```bash
# Build all images
docker compose -f srcs/docker-compose.yml build

# Start all services
docker compose -f srcs/docker-compose.yml up -d

# Stop all services
docker compose -f srcs/docker-compose.yml down

# Remove volumes
docker compose -f srcs/docker-compose.yml down -v

# View logs
docker compose -f srcs/docker-compose.yml logs
docker compose -f srcs/docker-compose.yml logs -f <service-name>
```

## Architecture & Configuration

### Project Structure

```
inception/
├── Makefile                          # Build automation
├── README.md                         # Project overview
├── USER_DOC.md                       # User guide
├── DEV_DOC.md                        # Developer guide
├── secrets/                          # Runtime secrets (gitignored)
│   ├── mariadb_root_password.txt
│   ├── mariadb_user_password.txt
│   ├── wordpress_password.txt
│   └── ftp_password.txt
└── srcs/
    ├── docker-compose.yml            # Service orchestration
    ├── requirements/
    │   ├── .env                      # Environment variables
    │   ├── nginx/
    │   │   ├── Dockerfile
    │   │   └── conf/
    │   │       └── nginx.conf
    │   ├── wordpress/
    │   │   ├── Dockerfile
    │   │   └── tools/
    │   │       └── wp-entrypoint.sh
    │   ├── mariadb/
    │   │   ├── Dockerfile
    │   │   └── tools/
    │   │       ├── 50-server.cnf
    │   │       └── entry_point.sh
    │   └── bonus/
    │       ├── adminer/Dockerfile
    │       ├── redis/Dockerfile
    │       ├── ftp_server/Dockerfile
    │       └── static_page/Dockerfile
```

## Docker Services Configuration

### NGINX Service

**Purpose**: Reverse proxy, SSL/TLS termination, routing

**Key Files**:
- `srcs/requirements/nginx/Dockerfile`
- `srcs/requirements/nginx/conf/nginx.conf`

**Configuration Points**:
- SSL certificate generation
- Port mapping (443 only, no 80)
- Reverse proxy pass to php-fpm
- Proxy routes for bonus services

**Important Settings**:
```nginx
ssl_protocols TLSv1.3;  # or TLSv1.2
ssl_certificate /etc/nginx/ssl/nginx-selfsigned.crt;
ssl_certificate_key /etc/nginx/ssl/nginx-selfsigned.key;
fastcgi_pass wordpress:9000;  # Connect to PHP-FPM
```

### WordPress Service

**Purpose**: PHP-FPM web application

**Key Files**:
- `srcs/requirements/wordpress/Dockerfile`
- `srcs/requirements/wordpress/tools/wp-entrypoint.sh`

**Entrypoint Logic**:
1. Load environment variables
2. Download WordPress core (if first run)
3. Wait for MariaDB to be ready
4. Create wp-config.php
5. Install WordPress database
6. Create admin user (`sbrugman_user`)
7. Create contributor user
8. Start PHP-FPM in foreground

**Important**: Must NOT use background processes (`exec` replaces shell)

### MariaDB Service

**Purpose**: Database server

**Key Files**:
- `srcs/requirements/mariadb/Dockerfile`
- `srcs/requirements/mariadb/tools/entry_point.sh`
- `srcs/requirements/mariadb/tools/50-server.cnf`

**Entrypoint Logic**:
1. Configure MySQL network settings
2. Install database (first run only)
3. Create database and users
4. Grant privileges
5. Start mysqld_safe in foreground

**Important Configuration**:
```bash
MYSQL_DATABASE=wordpress
MYSQL_USER=wpsbrugman
# Password from Docker secret
```

### Redis Service (Bonus)

**Purpose**: Caching layer for performance

**Configuration**:
- No external ports (internal only)
- Auto-connected to WordPress via Docker network

### FTP Server Service (Bonus)

**Purpose**: File transfer access to WordPress files

**Key Files**:
- `srcs/requirements/bonus/ftp_server/tools/ftp.conf`
- `srcs/requirements/bonus/ftp_server/tools/entry_point.sh`

**Ports**: 21 (control), 10000-10010 (passive mode)

### Adminer Service (Bonus)

**Purpose**: Web-based database management

**Access**: Via NGINX proxy at `/adminer/`
**No external ports** (proxied through NGINX)

### Static Page Service (Bonus)

**Purpose**: Additional static content

**Access**: Via NGINX proxy at `/static/`
**No external ports** (proxied through NGINX)

## Environment Variables & Secrets

### .env File

Located at `srcs/requirements/.env`:

```env
MYSQL_DATABASE=wordpress
MYSQL_USER=wpsbrugman
WORDPRESS_DB_NAME=wordpress
WORDPRESS_DB_USER=wpsbrugman
WORDPRESS_DB_HOST=mariadb
FTP_USR=ftp_sbrugman
```

**Usage**: Loaded by services via `env_file` in docker-compose.yml

### Docker Secrets

Located in `secrets/` directory:
- `mariadb_root_password.txt`
- `mariadb_user_password.txt`
- `wordpress_password.txt`
- `ftp_password.txt`

**Usage**: Mounted to `/run/secrets/` inside containers
**Generation**: `make secrets` creates random 16-byte passwords

**Access in containers**:
```bash
DB_PASSWORD=$(cat /run/secrets/mariadb_user_password)
```

## Networking

### Docker Network Types

| Type | What it does | Isolation | Use case |
|------|--------------|-----------|----------|
| **bridge** (default) | Creates isolated network, containers reach each other by name | ✅ Isolated | Internal service communication (THIS PROJECT) |
| **host** | Container shares host's network stack | ❌ No isolation | Maximum performance (forbidden in requirements) |
| **none** | No network access | ✅✅ Complete isolation | Not needed |
| **overlay** | Multi-host networking for Docker Swarm | ✅ Distributed | Multi-machine deployments |

**Bridge (what we use)**:
- Docker creates a virtual switch connecting containers
- Each container gets its own IP on the bridge
- Services communicate via container names through Docker's DNS
- Host port 443 → nginx container port 443 only (firewall effect)
- Perfect for multi-container apps on one machine

### Docker Network Configuration

All services connected via bridge network called `network`.

**docker-compose.yml**:
```yaml
networks:
  network:
    driver: bridge

services:
  service_name:
    networks:
      - network
```

**Service Communication**:
- Services access each other via container names (DNS resolution)
- Example: WordPress connects to `mariadb:3306`
- **Only NGINX exposed to host** (port 443)
- **No `network: host` or `links`** (violates requirements)

**Verification**:
```bash
docker network ls
docker network inspect srcs_network
docker exec <container> ping <service-name>
```

## Volume Management

### Named Volumes

Two named volumes for persistence:

```yaml
volumes:
  mariadb_data:        # Database files
  wordpress_data:      # WordPress files
```

**Location on Host**: `/var/lib/docker/volumes/srcs_*/_data/`

### Volume Operations

```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect srcs_wordpress_data

# Mount point info
docker volume inspect srcs_wordpress_data | grep Mountpoint

# Backup volume
docker run --rm -v srcs_wordpress_data:/data -v $(pwd):/backup \
  alpine tar czf /backup/backup.tar.gz -C /data .

# Restore volume
docker run --rm -v srcs_wordpress_data:/data -v $(pwd):/backup \
  alpine tar xzf /backup/backup.tar.gz -C /data
```

## Container Management

### Lifecycle Commands

```bash
# Start all services
docker compose up -d

# Stop all services (keep data)
docker compose down

# Restart services
docker compose restart
docker compose restart <service-name>

# Remove everything including volumes
docker compose down -v --rmi all

# View status
docker compose ps
docker compose ps -a  # Include stopped containers
```

### Accessing Containers

```bash
# Execute command in container
docker exec <container-name> <command>

# Interactive shell
docker exec -it <container-name> /bin/ash
docker exec -it <container-name> /bin/bash

# Examples:
docker exec wordpress wp user list --allow-root --path=/home/sbrugman/data
docker exec mariadb mysql -u root -p<password> -e "SHOW DATABASES;"
docker exec ftp-server ls -la /home/sbrugman/data
```

### Viewing Logs

```bash
# View recent logs
docker compose logs <service-name>

# Follow logs in real-time
docker compose logs -f <service-name>

# View all logs
docker compose logs

# Show last 50 lines
docker compose logs --tail=50

# Show with timestamps
docker compose logs --timestamps
```

## Monitoring & Debugging

### Resource Usage

```bash
# Real-time container stats
docker stats

# One-time snapshot
docker stats --no-stream

# Disk usage
docker system df
docker system df -v
```

### Network Debugging

```bash
# Access container shell
docker exec -it <service> /bin/ash

# Inside container, test connectivity:
ping <other-service-name>
nslookup <service-name>
curl http://<service>:<port>

# Example:
docker exec wordpress ping mariadb
docker exec wordpress curl http://nginx:443
```

### Database Debugging

```bash
# Connect to database
DBPASS=$(cat secrets/mariadb_user_password.txt)
docker exec -it mariadb mysql -u wpsbrugman -p"$DBPASS" wordpress

# View WordPress users
SELECT * FROM wp_users;

# View WordPress posts
SELECT * FROM wp_posts WHERE post_type='post';

# View plugins
SELECT * FROM wp_options WHERE option_name='active_plugins';
```
### WordPress Debugging
```bash
# Execute WP-CLI commands
docker exec wordpress wp --allow-root --path=/home/sbrugman/data <command>

# Examples:
docker exec wordpress wp user list --allow-root --path=/home/sbrugman/data
docker exec wordpress wp plugin list --allow-root --path=/home/sbrugman/data
docker exec wordpress wp core version --allow-root --path=/home/sbrugman/data
```
## Data Persistence & Backup
### Understanding Persistence
- **WordPress data**: Stored in `wordpress_data` volume
  - All user uploads
  - Theme customizations
  - Plugin data
  
- **Database data**: Stored in `mariadb_data` volume
  - WordPress posts/pages
  - Users and settings
  - Comments and metadata

### Backup Strategies

#### WordPress Files Backup

```bash
# Create backup
docker run --rm \
  -v srcs_wordpress_data:/wordpress \
  -v $(pwd)/backups:/backup \
  alpine tar czf /backup/wordpress-$(date +%Y%m%d).tar.gz -C /wordpress .

# Restore backup
docker run --rm \
  -v srcs_wordpress_data:/wordpress \
  -v $(pwd)/backups:/backup \
  alpine tar xzf /backup/wordpress-latest.tar.gz -C /wordpress
```

#### Database Backup

```bash
# Create backup
DBPASS=$(cat secrets/mariadb_user_password.txt)
docker exec mariadb mysqldump \
  -u wpsbrugman -p"$DBPASS" wordpress \
  > backups/wordpress-$(date +%Y%m%d).sql

# Restore backup
DBPASS=$(cat secrets/mariadb_user_password.txt)
docker exec -i mariadb mysql \
  -u wpsbrugman -p"$DBPASS" wordpress \
  < backups/wordpress-latest.sql
```

## Common Development Tasks

### Adding a New Service

1. Create service directory in `srcs/requirements/<service-name>/`
2. Write `Dockerfile`
3. Create entrypoint script if needed
4. Add to `docker-compose.yml`:
   ```yaml
   services:
     new-service:
       build: ./requirements/<service-name>
       networks:
         - network
   ```
5. Rebuild: `docker compose build`

### Modifying NGINX Configuration

1. Edit `srcs/requirements/nginx/conf/nginx.conf`
2. Reload without rebuild:
   ```bash
   docker compose exec nginx nginx -s reload
   ```
3. Or rebuild completely:
   ```bash
   docker compose build nginx
   docker compose up -d nginx
   ```

### Updating WordPress Plugins/Themes

```bash
# Connect to WordPress container
docker exec -it wordpress /bin/ash

# Install plugin
wp plugin install <plugin-name> --allow-root --path=/home/sbrugman/data

# Activate theme
wp theme activate <theme-name> --allow-root --path=/home/sbrugman/data
```

### Viewing File Locations

```bash
# WordPress root
WORDPRESS_VOL=$(docker volume inspect srcs_wordpress_data --format '{{.Mountpoint}}')
ls -la "$WORDPRESS_VOL"

# Database files
DB_VOL=$(docker volume inspect srcs_mariadb_data --format '{{.Mountpoint}}')
ls -la "$DB_VOL"
```

## Troubleshooting Development

### "Docker daemon not running"
```bash
# Start Docker
sudo systemctl start docker

# Or on macOS
open /Applications/Docker.app
```

### "Cannot connect between services"
```bash
# Verify service is running
docker compose ps <service>

# Test network connectivity
docker exec <service1> ping <service2>

# Check network
docker network inspect srcs_network
```

### "Port already in use"
```bash
# Find what's using port 443
sudo lsof -i :443

# Kill the process or choose different port in docker-compose.yml
```

### "Volume permission errors"
```bash
# Check volume ownership
docker volume inspect <volume-name>

# Fix permissions inside container
docker exec <container> chown -R www-data:www-data /home/sbrugman/data
```

### "Service keeps restarting"
```bash
# Check logs for errors
docker compose logs <service-name>

# Verify entrypoint script has correct shebang
head -1 srcs/requirements/<service>/tools/entrypoint.sh

# Ensure script is executable
chmod +x srcs/requirements/<service>/tools/entrypoint.sh
```

## Git Workflow

### .gitignore

Should include:
```
secrets/
.env.local
*.log
docker-compose.override.yml
```

### Committing Code

```bash
git add srcs/ Makefile README.md USER_DOC.md DEV_DOC.md
git commit -m "Initial project setup"
git push origin main
```

**Important**: Never commit secrets, passwords, or sensitive data

## Performance Optimization

### Reducing Build Time

- Use `.dockerignore` to exclude unnecessary files
- Layer reuse: put stable dependencies first in Dockerfile
- Cache Alpine packages: `apk add --no-cache`

### Memory Usage

```bash
# Limit container memory
services:
  wordpress:
    mem_limit: 512m
```

### Volume I/O

- Use `delegated` or `cached` for macOS:
  ```yaml
  volumes:
    - wordpress_data:/home/sbrugman/data:delegated
  ```

## Security Best Practices

1. **Secrets Management**: Use Docker secrets, never hardcode passwords
2. **Network Isolation**: No `network: host`
3. **Port Exposure**: Only expose necessary ports (443 only)
4. **SSL/TLS**: Always use HTTPS in production
5. **Updates**: Regularly update base images
6. **Scanning**: `docker scout cves <image>` for vulnerabilities

## References

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [OWASP Docker Security](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)
