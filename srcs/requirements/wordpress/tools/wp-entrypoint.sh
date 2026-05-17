#!/bin/sh
set -e

echo "Starting WordPress setup..."

DB_PASSWORD_FILE="/run/secrets/mariadb_user_password"
echo "memory_limit=512M" > /etc/php82/conf.d/memory.ini

if [ ! -f "$DB_PASSWORD_FILE" ]; then
    echo "Missing DB password secret at $DB_PASSWORD_FILE"
    exit 1
fi

DB_PASSWORD=$(cat "$DB_PASSWORD_FILE")
DB_HOST="${WORDPRESS_DB_HOST:-mariadb}"
DB_USER="${WORDPRESS_DB_USER:-wpuser}"

# Ensure WordPress core exists FIRST
if [ ! -f /var/www/html/wp-load.php ]; then
    echo "Downloading WordPress..."
    wp core download --path=/var/www/html --allow-root
fi
# Wait for DB
echo "Waiting for MariaDB..."
until mysqladmin ping -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" --silent; do
    echo "Waiting for MariaDB at $DB_HOST..."
    sleep 2
done

echo "MariaDB is ready!"

# Create config
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Creating wp-config.php..."
    wp config create \
        --dbname="$WORDPRESS_DB_NAME" \
        --dbuser="$WORDPRESS_DB_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="$WORDPRESS_DB_HOST" \
        --path=/var/www/html \
        --allow-root
fi

# Create WordPress users (admin and regular user)
echo "Setting up WordPress users..."
WP_ADMIN_PASS=$(cat /run/secrets/wordpress_password)

# Check if WordPress is already installed
if ! wp core is-installed --path=/var/www/html --allow-root 2>/dev/null; then
    echo "Installing WordPress..."
    wp core install \
        --path=/var/www/html \
        --url="https://sbrugman.42.fr" \
        --title="sbrugman's Website" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --admin_password="$WP_ADMIN_PASS" \
        --allow-root
    
    echo "Creating secondary user (contributor)..."
    wp user create contributor contributor@sbrugman.42.fr \
        --user_pass="$WP_ADMIN_PASS" \
        --role=contributor \
        --path=/var/www/html = \
        --allow-root || echo "Contributor user may already exist"
fi

echo "Configuring PHP-FPM to listen on all interfaces..."
sed -i 's/^listen = 127.0.0.1:9000/listen = 0.0.0.0:9000/' /etc/php82/php-fpm.d/www.conf

echo "Starting PHP-FPM..."
exec php-fpm82 -F
