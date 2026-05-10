FROM alpine:3.20

# Install MariaDB, bash
RUN apk add --no-cache mariadb mariadb-client bash

# Copy config and entrypoint
COPY tools/50-server.cnf /etc/my.cnf.d/50-server.cnf
COPY tools/entry_point.sh /entry_point.sh

# Make entrypoint executable
RUN chmod +x /entry_point.sh

ENTRYPOINT ["/entry_point.sh"]