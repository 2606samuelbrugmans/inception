FROM alpine:3.20

RUN apk add --no-cache vsftpd shadow

# Copy config + entrypoint
COPY ./tools/ftp.conf /etc/vsftpd.conf
COPY ./tools/entry_point.sh /entry_point.sh
RUN chmod +x /entry_point.sh


ENTRYPOINT ["/entry_point.sh"]
