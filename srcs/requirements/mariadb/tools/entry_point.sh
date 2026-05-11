#!/bin/bash
set -e

if [ ! -e /etc/.firstrun ]; then
    cat << EOF >> /etc/my.cnf.d/mariadb-server.cnf
[mysqld]
bind-address=0.0.0.0
skip-networking=0
EOF
    touch /etc/.firstrun
fi

if [ ! -e /var/lib/mysql/.firstmount ]; then
    MYSQL_PASSWORD_FILE="/run/secrets/mariadb_user_password"
    MYSQL_ROOT_PASSWORD_FILE="/run/secrets/mariadb_root_password"

    if [ ! -f "$MYSQL_PASSWORD_FILE" ] || [ ! -f "$MYSQL_ROOT_PASSWORD_FILE" ]; then
        echo "Missing MariaDB secret files: $MYSQL_PASSWORD_FILE or $MYSQL_ROOT_PASSWORD_FILE"
        exit 1
    fi
    MYSQL_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")
    MYSQL_ROOT_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD_FILE")
    mysql_install_db --datadir=/var/lib/mysql --skip-test-db --user=mysql --group=mysql \
        --auth-root-authentication-method=socket >/dev/null 2>/dev/null
    mysqld_safe &
    mysqladmin ping -u root --silent --wait

    cat << EOF | mysql --protocol=socket -u root
CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;

CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';

CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;
EOF

    mysqladmin shutdown
    touch /var/lib/mysql/.firstmount
fi

exec mysqld_safe