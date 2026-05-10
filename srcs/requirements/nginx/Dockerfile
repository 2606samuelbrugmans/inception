FROM alpine:3.20

# Update packages + install nginx + openssl (needed for self-signed cert)
RUN apk update && apk upgrade && \
    apk add --no-cache \
    nginx \
    openssl && \
    # Create needed directories (nginx needs /run/nginx for pid/socket)
    mkdir -p /run/nginx && \
    # Create folders where we'll put our certificate (you can change paths)
    mkdir -p /etc/nginx/ssl

# Copy your custom nginx configuration
# (this is usually your reverse-proxy config for wordpress, adminer, etc.)
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Optional: generate self-signed certificate directly in the image
# (many do it this way so no need for a tools/setup.sh script)
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx-selfsigned.key \
    -out /etc/nginx/ssl/nginx-selfsigned.crt \
    -subj "/C=BE/ST=Belgium/L=Brussels/O=42 School/OU=student/CN=sbrugman.42.fr"

# Expose only 443 (subject requires TLSv1.2 or TLSv1.3 only — port 80 is usually redirected)
EXPOSE 443

# Start nginx in foreground (mandatory in Docker)
# -g daemon off; is the official way
CMD ["nginx", "-g", "daemon off;"]