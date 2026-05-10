# Start from plain Alpine
FROM alpine:3.20

# Install Nginx
RUN apk add --no-cache nginx

# Remove default content
RUN rm -rf /home/sbrugman/data/nginx/html/*

# Copy your static site files
COPY site/ /home/sbrugman/data/nginx/html/

# Optional: copy custom Nginx config
COPY /conf/nginx.conf /etc/nginx/nginx.conf
# Create required Nginx runtime directories
RUN mkdir -p /run/nginx

# Expose HTTP port
EXPOSE 80

# Start Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]