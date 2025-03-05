FROM alpine:3.21


RUN apk add --no-cache \
    openssh \
    sshfs \
    borgbackup \
    supervisor \
    nano \
    bash
RUN addgroup -S borg \
    && adduser -D -u 1000 borg -G borg -h /home/borg \
    && passwd -u borg && \
    mkdir -m 0700 /backups && \
    chown borg:borg /backups && \
    sed -i \
        -e 's/^#PasswordAuthentication yes$/PasswordAuthentication no/g' \
        -e 's/^PermitRootLogin without-password$/PermitRootLogin no/g' \
        /etc/ssh/sshd_config \
    && mkdir -p /home/borg/.ssh \
    && chown -R borg:borg /home/borg/.ssh

COPY supervisord.conf /etc/supervisord.conf
COPY service.sh /usr/local/bin/service.sh

EXPOSE 22
VOLUME /home/borg
VOLUME /backups

CMD ["/usr/bin/supervisord"]
