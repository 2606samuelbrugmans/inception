FROM alpine:3.20

# Install PHP and required extensions from Alpine packages
RUN apk add --no-cache php php-cli php-session php-mysqli php-pdo php-pdo_mysql wget

WORKDIR /var/www

RUN wget -q https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php -O index.php

EXPOSE 8888

CMD ["php", "-S", "0.0.0.0:8888", "-t", "/var/www"]