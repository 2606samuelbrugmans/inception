# Inception Project — Personal Setup Guide

Welcome! This project is my custom-built WordPress infrastructure running entirely with Docker. The goal was to create a clean, modular, and secure environment that mimics a real production setup while staying easy to manage locally.

This setup includes several services working together:

* **WordPress** → Main website & content management
* **NGINX** → Handles HTTPS, routing, and acts as reverse proxy
* **MariaDB** → Database for WordPress
* **Redis** *(bonus)* → Speeds things up with caching
* **FTP Server** *(bonus)* → Easy file access
* **Adminer** *(bonus)* → Simple database UI
* **Static Site** *(bonus)* → Extra static content

Everything runs in isolated containers and communicates through Docker networks.


### Start 

```bash
make up
```

This will:

* Generate secure random passwords
* Build all images from alpine 3.20 or 3.19
* Launch containers
* Create volumes & networks

First launch takes a bit longer because WordPress installs itself.

---

### Stop the project

```bash
make down
```

Containers stop, but **your data stays safe**.

---

### Full reset (fresh start)

```bash
make clean
```

Deletes everything — containers, images, volumes, and data.

---

## Accessing the Website

### Step 1 — Update your hosts file

You need to map the domain locally:

**Linux / macOS**

```bash
sudo bash -c 'echo "127.0.0.1 sbrugman.42.fr" >> /etc/hosts'
```

### Step 2 — Open the services

| Service     | URL                              |
| ----------- | -------------------------------- |
| Main site   | https://sbrugman.42.fr           |
| Admin panel | https://sbrugman.42.fr/wp-admin/ |
| Adminer     | https://sbrugman.42.fr/adminer/  |
| Static page | https://sbrugman.42.fr/static/   |

---

##  Credentials

All passwords are generated automatically and stored in `secrets/`.

---

### WordPress Users

| Username        | Role        |
| --------------- | ----------- |
| `sbrugman_user` | Admin       |
| `contributor`   | Contributor |

Get password:

```bash
cat secrets/wordpress_password.txt
```

---

### Database Access

* DB name: `wordpress`
* User: `wpsbrugman`

Password:

```bash
cat secrets/mariadb_user_password.txt
```
---

#### Easy way (Adminer)

* Server: `mariadb`
* Username: `wpsbrugman`
* Password: (from secrets)
* Database: `wordpress`
---
#### CLI access

```bash
DBPASS=$(cat secrets/mariadb_user_password.txt)

docker exec -it mariadb mysql -u wpsbrugman -p"$DBPASS" wordpress
```

---

### FTP Access

* Host: `localhost`
* User: `ftp_sbrugman`

Password:

```bash
cat secrets/ftp_password.txt
```

Use FileZilla, WinSCP, etc.

---

## Common Things I Do

### Add a comment

Just open a post → scroll → comment.
---
### Create a user
WP Admin → Users → Add New
---
### Edit a page

WP Admin → Pages → Edit → Publish

---

### Redis caching

Works automatically — no setup needed.

---

## Checking Everything

### See all containers

```bash
docker compose -f srcs/docker-compose.yml ps
```

---

### Check logs

```bash
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs nginx
```

---

### Monitor usage

```bash
docker stats
```

---

### Check volumes

```bash
docker volume ls
docker volume inspect srcs_wordpress_data
```

---

## Data Persistence

All data is stored inside Docker volumes:

* WordPress → `srcs_wordpress_data`
* Database → `srcs_mariadb_data`

---

### Backup

```bash
# WordPress files
docker run --rm -v srcs_wordpress_data:/data -v $(pwd)/backups:/backup \
  alpine tar czf /backup/wp.tar.gz -C /data .

# Database
docker exec mariadb mysqldump -u wpsbrugman -p$(cat secrets/mariadb_user_password.txt) \
  wordpress > backup.sql
```

---

##  Troubleshooting

### Can't access site

* Check `/etc/hosts`
* Check nginx:

```bash
docker compose ps nginx
```

---

### Wrong password

```bash
cat secrets/wordpress_password.txt
```

Still broken?

```bash
make clean && make up
```

---

### Database issues

```bash
docker compose logs mariadb
```

---

### Service stuck

```bash
docker compose restart <service>
```

---

## Useful Commands (Quick Reference)

Here are the ones I actually use all the time:

```bash
# Start / stop
make up
make down
make clean
# Check everything
docker compose -f srcs/docker-compose.yml ps
docker stats
# Logs
docker compose -f srcs/docker-compose.yml logs
docker compose -f srcs/docker-compose.yml logs -f wordpress
docker ps
docker logs service
# Restart services
docker compose -f srcs/docker-compose.yml restart
docker compose -f srcs/docker-compose.yml restart nginx

# Enter container
docker exec -it wordpress bash
docker exec -it mariadb bash

# Database access
docker exec -it mariadb mysql -u wpsbrugman -p

# Check networks
docker network ls

# Check volumes
docker volume ls

# Disk usage
docker system df
