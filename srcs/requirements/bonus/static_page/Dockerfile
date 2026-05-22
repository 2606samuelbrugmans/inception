FROM alpine:3.20

RUN apk add --no-cache nginx

# Use absolute paths
RUN rm -rf /var/www/html && mkdir -p /var/www/html

# Copy site to the path nginx.conf expects
COPY site/ /var/www/html/

COPY conf/nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /run/nginx

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
