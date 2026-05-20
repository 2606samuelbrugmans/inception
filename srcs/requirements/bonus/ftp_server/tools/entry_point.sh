#!/bin/sh
set -e

# Read password from Docker secret
FTP_PWD=$(cat /run/secrets/ftp_password)

# Create user if missing
if ! id "$FTP_USR" >/dev/null 2>&1; then
    useradd -m "$FTP_USR"
fi

# Set password
echo "$FTP_USR:$FTP_PWD" | chpasswd

# Give access to wordpress volume
chown -R "$FTP_USR":"$FTP_USR" /var/www/html

# Start FTP server
exec /usr/sbin/vsftpd /etc/vsftpd.conf
