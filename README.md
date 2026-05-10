# Inception

*This project has been created as part of the 42 curriculum by sbrugman.*

## Description

Inception is a system administration project that requires setting up a small infrastructure using Docker and Docker Compose. The project involves containerizing a WordPress website with MariaDB, NGINX as a reverse proxy with SSL/TLS encryption, and additional bonus services including RedisCache, vsftpd (FTP server), Adminer, and a static webpage.

The goal is to understand containerization, orchestration, networking, persistence, and security best practices while building a production-ready infrastructure locally.

## Instructions

### Prerequisites

- Linux system with Docker and Docker Compose installed
- `make` utility
- Internet connection for pulling Docker images and downloading WordPress

### Setup and Execution

1. **Clone the repository** (if applicable):
   ```bash
   git clone <repository-url>
   cd inception
   ```

2. **Generate secrets and start the infrastructure**:
   ```bash
   make up
   ```
   This command will:
   - Create the `secrets/` directory with randomly generated passwords
   - Build all Docker images
   - Start all containers in the background

3. **Access the website**:
   - Add `sbrugman.42.fr` to your `/etc/hosts`:
     ```bash
     echo "127.0.0.1 sbrugman.42.fr" >> /etc/hosts
     ```
   - Open your browser and navigate to: `https://sbrugman.42.fr/`

4. **Stop the infrastructure**:
   ```bash
   make down
   ```

5. **Clean everything** (remove volumes, images, networks):
   ```bash
   make clean
   ```

## Docker Architecture Overview

### Docker Components

Understanding Docker requires knowing these key components:

#### 1. **Docker Daemon** (Server)
- The background process that manages everything
- Runs on your system (usually as root)
- Responsible for: building images, running containers, managing networks/volumes
- **Location in this project**: Runs automatically when you use `docker` commands
- Start it: `sudo systemctl start docker` (or `docker desktop` on macOS/Windows)

#### 2. **Docker Client** (CLI)
- Command-line tool you use to communicate with the daemon
- Commands like `docker ps`, `docker build`, `docker run`
- **Files using it**:
  - [Makefile](Makefile) - Uses docker compose commands (which use the client)
  - All `docker compose` commands in [USER_DOC.md](USER_DOC.md)
  - Terminal commands you type

#### 3. **Docker Images** (Blueprints)
- Read-only templates for creating containers
- Built from instructions in a Dockerfile
- Include OS, dependencies, application code
- **Files defining images in this project**:
  - [srcs/requirements/nginx/Dockerfile](srcs/requirements/nginx/Dockerfile) → NGINX image
  - [srcs/requirements/wordpress/Dockerfile](srcs/requirements/wordpress/Dockerfile) → WordPress PHP-FPM image
  - [srcs/requirements/mariadb/Dockerfile](srcs/requirements/mariadb/Dockerfile) → MariaDB image
  - [srcs/requirements/bonus/redis/Dockerfile](srcs/requirements/bonus/redis/Dockerfile) → Redis image
  - [srcs/requirements/bonus/ftp_server/Dockerfile](srcs/requirements/bonus/ftp_server/Dockerfile) → FTP server image
  - [srcs/requirements/bonus/adminer/Dockerfile](srcs/requirements/bonus/adminer/Dockerfile) → Adminer image
  - [srcs/requirements/bonus/static_page/Dockerfile](srcs/requirements/bonus/static_page/Dockerfile) → Static page image

**Example - NGINX image layers:**
```
FROM alpine:3.20          ← Base image (pulled from registry)
RUN apk add nginx         ← Add nginx package
COPY conf/nginx.conf ...  ← Add config
EXPOSE 443                ← Expose port info
CMD [...]                 ← Default command
```

#### 4. **Docker Registries** (Storage)
- Central repositories where Docker images are stored
- Default registry: **Docker Hub** (registry.hub.docker.com)
- **Images pulled from registries in this project**:
  - `alpine:3.20` → Base OS for NGINX, Adminer, FTP, Static page
  - `alpine:3.19.2` → Base OS for WordPress
  - When you run `docker compose up`, the daemon pulls these from Docker Hub

#### 5. **Docker Containers** (Running Instances)
- Live instances created from images
- Read-write layer on top of the image
- Each container has its own filesystem, processes, network
- **Containers in this project** (created when you run `make up`):
  - `nginx` → Running NGINX web server
  - `wordpress` → Running PHP-FPM application
  - `mariadb` → Running MariaDB database relational fast query
  - `redis` → Running Redis cache generate dynamic pages
  - `ftp-server` → Running FTP server transfer WordPress files, themes, uploads
  - `adminer` → Running Adminer web UI gives access to database
  - `static_page` → Running static NGINX site

**See them:**
```bash
docker ps                  # Running containers
docker images              # All images on your system
docker network ls          # Docker networks
```

### Data Flow

```
dockerfile (code)
    ↓
docker build     → IMAGE (artifact) stored locally or in registry
    ↓
docker run       → CONTAINER (process) created and running
    ↓
docker-compose   → Multiple containers orchestrated together
```

### How This Project Uses Each

The Docker Daemon is the core service that manages everything behind the scenes. It handles building images, running containers, and managing networks and volumes. It runs automatically in the background once Docker is installed and started.

The Docker Client is what you interact with directly. It sends commands to the Docker Daemon. In your project, this includes the docker compose CLI and commands triggered through your Makefile.

Docker Images are the blueprints for your containers. In your case, you have seven custom images, each defined by its own Dockerfile located in srcs/requirements/*/Dockerfile. These images describe exactly how each service should be built.

Docker Registries are where images are stored and pulled from. When you use a base image like Alpine, it is downloaded from a registry such as Docker Hub before being customized into your own images.

Docker Containers are the running instances of your images. When you execute docker compose up, Docker creates and starts seven containers, each corresponding to one of your services (nginx, wordpress, mariadb, etc.). These are the actual processes running your application.

## Project Architecture

### Docker Usage and Design Choices

**Why Docker?**
- **Isolation**: Each service runs in its own environment, preventing conflicts
- **Consistency**: Same configuration works across different machines
- **Scalability**: Easy to replicate or extend services
- **Security**: Separated network and secrets management

### Key Services

NGINX listens on port 443 (HTTPS only) and acts as a reverse proxy. It handles SSL/TLS encryption and routes incoming requests to the appropriate services.

WordPress runs on port 9000 internally using PHP-FPM. It processes dynamic content and generates the pages served to users.

MariaDB is available on port 3306 internally and serves as the database where all persistent data is stored.

Redis runs on port 6379 internally and provides a caching layer to speed up repeated requests and reduce database load.

The FTP Server uses port 21 along with a range from 10000 to 10010 for data transfer, allowing remote file access and uploads.

Adminer is accessible on port 8888 but typically proxied through /adminer/. It provides a web interface to manage the database.

The Static Page service runs on port 80 internally and serves simple static content, usually exposed via /static/.

### Technology Comparisons

#### Virtual Machines vs Docker

With virtual machines, each instance includes a full operating system, which makes them large (often several GB) and slower to start, sometimes taking minutes. They provide strong isolation since each VM is essentially its own complete environment, making them ideal when you need to run entirely different operating systems on the same machine.

With Docker, containers are much lighter because they share the host system’s kernel. They are usually only a few MB in size and start in seconds. Instead of full OS isolation, they provide process-level isolation, which is sufficient for most applications while being far more efficient in terms of resource usage.

In this project, using virtual machines would mean managing multiple heavy environments, whereas Docker containers allow you to run all services efficiently on the same system with minimal overhead.

**Decision**: Docker was chosen for its efficiency, portability, and ease of rapid development/testing.

#### Secrets vs Environment Variables

Docker secrets are designed for securely storing sensitive data like passwords or API keys. They are encrypted and managed by Docker, and only containers that explicitly request them can access the data. They’re not exposed in logs or environment listings.

Environment variables, on the other hand, are a more basic way to pass configuration. They are usually stored in plain text (like in a .env file or docker-compose.yml) and are accessible to all processes inside the container. This makes them easier to use, but also less secure, since they can appear in logs or be inspected. Updating them often requires restarting or redeploying the containers.

#### Docker Network vs Host Network

With a Docker network (like the custom bridge srcs_network), containers are isolated from the host and from unrelated services. They communicate with each other using container names thanks to built-in DNS, and you can reuse the same internal ports across different setups without conflicts. This approach also allows better security, since you can control which containers can talk to each other.

With the host network, containers share the host’s networking stack directly. This means there’s no isolation—services bind directly to the host’s ports, which can easily lead to conflicts. Communication happens through localhost or the host IP, but it also gives containers full access to the host network, making it less secure.

In this project, using a dedicated Docker bridge network (srcs_network) keeps everything clean, isolated, and compliant with the requirements, whereas the host network would break that isolation and is therefore not used.

## Volumes 
   Volumes are a way to store data outside of the lifespan of a docker
   as a result we keep data accross rebuilds and rerun
   Our volumes are mounted at **/home/sbrugman/data** as required by the subject



## Resources

### Docker Documentation
- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Docker Networking Guide](https://docs.docker.com/network/)
- [Docker Volumes Guide](https://docs.docker.com/storage/volumes/)

### WordPress & PHP-FPM
- [WordPress Official Documentation](https://wordpress.org/support/)
- [PHP-FPM Documentation](https://www.php.net/manual/en/install.fpm.php)
- [WP-CLI Reference](https://developer.wordpress.org/cli/commands/)

### NGINX & SSL/TLS
- [NGINX Documentation](https://nginx.org/en/docs/)
- [Mozilla SSL Configuration Guide](https://ssl-config.mozilla.org/)
- [Self-Signed Certificates Guide](https://www.ssl.com/article/how-to-create-and-install-self-signed-ssl-certificate/)

### MariaDB
- [MariaDB Official Documentation](https://mariadb.com/kb/en/documentation/)
- [MySQL/MariaDB User Management](https://mariadb.com/kb/en/user-account-management/)

### Other Services
- [Redis Documentation](https://redis.io/documentation)
- [vsftpd Configuration](https://security.appspot.com/vsftpd.html)
- [Adminer Documentation](https://www.adminer.org/)

## AI Usage

AI was used to assist with the following tasks:

1. **Docker configuration and best practices**: Generated docker-compose.yml structure, Dockerfile patterns, and networking setup examples.
2. **Entrypoint script creation**: Helped write sh/bash scripts for WordPress installation, MariaDB initialization, and FTP server setup.
3. **NGINX configuration**: Provided SSL/TLS configuration examples and reverse proxy setup for multiple services.
4. **Troubleshooting**: Assisted with debugging container connectivity, volume mounting, and user creation issues.
5. **Documentation**: Helped structure and write this README with comparisons and architecture explanations.

Specific AI tasks:
- Helped finding documentations
- Explained Docker networking, volumes, and security best practices
## Troubleshooting

### Cannot access the website
- Verify `/etc/hosts` contains `127.0.0.1 sbrugman.42.fr`
- Check NGINX is running: `docker compose ps nginx`
- Verify SSL certificate warning is shown (self-signed)

### Database connection errors
- Ensure MariaDB container is running: `docker compose ps mariadb`
- Check logs: `docker compose logs mariadb`

### Volume not persisting data
- Verify volumes exist: `docker volume ls`
- Check volume mount: `docker volume inspect srcs_wordpress_data`

See `USER_DOC.md` and `DEV_DOC.md` for more details.
