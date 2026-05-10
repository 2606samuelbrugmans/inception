# Inception Project - Subject Compliance Verification Report

## MANDATORY PART COMPLIANCE ✅

### Infrastructure Requirements
- ✅ **Virtual Machine**: Project running on Linux
- ✅ **Everything in srcs folder**: All services in `srcs/requirements/`
- ✅ **Makefile at root**: Present and functional
- ✅ **Docker images named after services**: nginx, wordpress, mariadb, redis, ftp-server, adminer, static_page

### Docker Configuration
- ✅ **Base images**: Alpine 3.20 (penultimate stable) and Alpine 3.19.2
- ✅ **Own Dockerfiles**: 7 custom Dockerfiles written
- ✅ **No pre-built images**: All built from scratch (Alpine/Debian excluded from this rule)

### Service Requirements
- ✅ **NGINX + TLSv1.3**: Configured in `srcs/requirements/nginx/conf/nginx.conf` (line 18)
  - ⚠️ Subject allows TLSv1.2 OR TLSv1.3 - only 1.3 implemented (acceptable but could support both)
- ✅ **WordPress + PHP-FPM**: No nginx in WordPress container
  - Location: `srcs/requirements/wordpress/Dockerfile`
  - PHP-FPM configured to listen on `0.0.0.0:9000`
- ✅ **MariaDB**: No nginx in database container
  - Location: `srcs/requirements/mariadb/Dockerfile`

### Volume Requirements
- ✅ **WordPress database volume**: `mariadb_data` (named volume)
- ✅ **WordPress files volume**: `wordpress_data` (named volume)
- ✅ **Named volumes used**: Confirmed in `srcs/docker-compose.yml` (line 89-90)
- ✅ **Volumes mounted at /home/sbrugman/data**: Confirmed in docker-compose.yml
  - mariadb_data → /home/sbrugman/data
  - wordpress_data → /home/sbrugman/data

### Network Requirements
- ✅ **Docker network**: Bridge network named `network` (line 92-93)
- ✅ **Service communication**: Via container names (wordpress:9000, mariadb:3306)
- ✅ **NOT using network: host**: Confirmed
- ✅ **NOT using --link or links**: Confirmed

### Container Requirements
- ✅ **Containers restart on crash**: `restart: always` on all services
- ✅ **No infinite loops**: Using proper daemon processes (php-fpm, nginx, mysqld_safe)
- ✅ **No tail -f / sleep infinity**: Confirmed

### User & Security Requirements
- ✅ **WordPress admin user**: `sbrugman_user` (does NOT contain admin/Admin/administrator)
- ✅ **Additional user**: `contributor` (second user created)
- ✅ **Domain name**: `sbrugman.42.fr` (login format: sbrugman.42.fr)
- ✅ **No 'latest' tag**: All images use specific versions
- ✅ **No passwords in Dockerfiles**: All passwords via secrets
- ✅ **Environment variables**: Using `.env` file
- ✅ **Docker secrets**: Using `/run/secrets/` for credentials
- ✅ **NGINX only entrypoint**: Port 443 only, TLSv1.3

### Current Issues Found ⚠️

None critical. All mandatory requirements met.

---

## README.md COMPLIANCE ✅

### Required Content
- ✅ **First line italicized**: "*This project has been created as part of the 42 curriculum by sbrugman.*"
- ✅ **Description section**: Present with clear project goals
- ✅ **Instructions section**: Contains setup, execution, and cleanup steps
- ✅ **Resources section**: Lists Docker, WordPress, NGINX, MariaDB, and other resources
- ✅ **AI usage description**: Documented in "AI Usage" section
- ✅ **English language**: Entire README in English

### Required Explanations
- ✅ **Docker explanation**: New "Docker Architecture Overview" section covers:
  - Docker Daemon
  - Docker Client
  - Docker Images (with 7 Dockerfile references)
  - Docker Registries
  - Docker Containers
- ✅ **Design choices comparison**:
  - ✅ Virtual Machines vs Docker
  - ✅ Secrets vs Environment Variables
  - ✅ Docker Network vs Host Network
  - ✅ Docker Volumes vs Bind Mounts

---

## USER_DOC.md COMPLIANCE ✅

### Required Content
- ✅ **Understand services**: Service table explains all 7 services
- ✅ **Start/stop project**: `make up` and `make down` documented
- ✅ **Access website**: URLs for main site, admin panel, Adminer, static page
- ✅ **Locate credentials**: Shows how to access password files from `secrets/`
- ✅ **Check services**: Provides `docker compose -f srcs/docker-compose.yml ps` command
- ✅ **SSL warning explanation**: Explains self-signed certificate
- ✅ **Credentials table**: Shows WordPress users and database access info
- ✅ **FTP access**: Documented with FileZilla/WinSCP examples
- ✅ **Local hosts setup**: Instructions for `/etc/hosts` configuration
- ✅ **Troubleshooting section**: Common issues and solutions
- ✅ **Quick commands reference**: Updated with `-f srcs/docker-compose.yml` paths

### Note
- ⚠️ One command needed updating: Changed `docker compose ps` → `docker compose -f srcs/docker-compose.yml ps` (FIXED)

---

## DEV_DOC.md COMPLIANCE ✅

### Required Content
- ✅ **Environment setup**: Prerequisites, installation steps
- ✅ **Build and launch**: Makefile, docker-compose commands detailed
- ✅ **Container management**: Full commands for ps, logs, exec, restart
- ✅ **Volume management**: Docker volume commands and backup strategies
- ✅ **Data persistence**: Explains mariadb_data and wordpress_data volumes
- ✅ **Data storage location**: Shows `/var/lib/docker/volumes/srcs_*/_data/`
- ✅ **Troubleshooting**: Comprehensive debugging section

---

## BONUS PART COMPLIANCE ✅

### Implemented Bonus Services (4/5)
1. ✅ **Redis Cache**
   - Dockerfile: `srcs/requirements/bonus/redis/Dockerfile`
   - Config: `srcs/requirements/bonus/redis/tools/redis.conf`
   - Listening on 0.0.0.0:6379
   - No external ports (internal only)

2. ✅ **FTP Server**
   - Dockerfile: `srcs/requirements/bonus/ftp_server/Dockerfile`
   - Ports: 21 (control), 10000-10010 (passive)
   - Points to WordPress volume
   - User: `ftp_sbrugman` (from secrets)

3. ✅ **Static Website**
   - Dockerfile: `srcs/requirements/bonus/static_page/Dockerfile`
   - HTML site in `srcs/requirements/bonus/static_page/site/index.html`
   - Accessible via NGINX `/static/` route
   - Non-PHP implementation ✅

4. ✅ **Adminer**
   - Dockerfile: `srcs/requirements/bonus/adminer/Dockerfile`
   - Fixed: Added `php-session` extension (was missing, causing 500 error)
   - Proxied via NGINX `/adminer/` route
   - No external ports (internal proxy only)

### Optional 5th Bonus Service
- Could add: Mail server, monitoring, backup service, etc. (not implemented)

---

## DIRECTORY STRUCTURE COMPLIANCE ✅

```
inception/
├── Makefile                 ✅ At root
├── README.md               ✅ With all required sections
├── USER_DOC.md             ✅ User documentation
├── DEV_DOC.md              ✅ Developer documentation
├── subject                 ✅ Subject file
├── secrets/                ✅ Generated at runtime
│   ├── mariadb_root_password.txt
│   ├── mariadb_user_password.txt
│   ├── wordpress_password.txt
│   └── ftp_password.txt
└── srcs/                   ✅ All configs here
    ├── docker-compose.yml  ✅ Orchestration
    ├── .env                ✅ Environment variables
    └── requirements/
        ├── nginx/          ✅ Dockerfile + config
        ├── wordpress/      ✅ Dockerfile + entrypoint
        ├── mariadb/        ✅ Dockerfile + config + entrypoint
        └── bonus/
            ├── adminer/    ✅ Dockerfile
            ├── ftp_server/ ✅ Dockerfile + config
            ├── redis/      ✅ Dockerfile + config
            └── static_page/ ✅ Dockerfile + HTML
```

---

## FIXES APPLIED DURING SESSION

1. ✅ **WordPress PHP-FPM**: Changed to listen on `0.0.0.0:9000` → Fixed 502 Bad Gateway
2. ✅ **Adminer**: Added `php-session` extension → Fixed 500 Internal Server Error
3. ✅ **USER_DOC.md**: Updated docker compose commands with `-f srcs/docker-compose.yml` path
4. ✅ **README.md**: Added comprehensive Docker Architecture section (Daemon, Client, Images, Registries, Containers)

---

## SUMMARY

| Category | Status | Notes |
|----------|--------|-------|
| **Mandatory Part** | ✅ COMPLIANT | All requirements met |
| **README** | ✅ COMPLIANT | All sections present and complete |
| **USER_DOC** | ✅ COMPLIANT | All guidance sections included |
| **DEV_DOC** | ✅ COMPLIANT | All developer information present |
| **Bonus Part** | ✅ COMPLIANT | 4 bonus services implemented (Redis, FTP, Adminer, Static) |
| **Directory Structure** | ✅ COMPLIANT | Exactly as specified in subject |
| **Security** | ✅ COMPLIANT | Secrets management, no hardcoded passwords |
| **Documentation** | ✅ COMPLIANT | All .md files follow subject requirements |

---

**Project Status**: ✅ **READY FOR SUBMISSION**

All mandatory requirements met. All documentation complete. Bonus services working. No critical issues.

