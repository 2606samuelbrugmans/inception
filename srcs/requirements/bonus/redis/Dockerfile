FROM alpine:3.20

RUN apk add --no-cache redis

COPY ./tools/redis.conf /etc/redis/redis.conf

CMD ["redis-server", "/etc/redis/redis.conf"]