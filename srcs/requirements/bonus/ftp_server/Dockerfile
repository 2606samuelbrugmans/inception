FROM alpine:3.20

RUN apk add --no-cache vsftpd shadow

# Copy config + entrypoint
COPY ./tools/ftp.conf /etc/ftpd.conf
COPY ./tools/entry_point.sh /entry_point.sh
RUN chmod +x /entry_point.sh

EXPOSE 21

ENTRYPOINT ["/entry_point.sh"]