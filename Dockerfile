# Based on https://github.com/ehough/docker-nfs-server/blob/develop/Dockerfile
ARG BUILD_FROM=alpine:latest
FROM $BUILD_FROM
LABEL maintainer="Chris Wieringa <cwieri39@calvin.edu>"
ARG BUILDDATE=20220829-01

RUN apk --update --no-cache add bash nfs-utils tzdata && \
                                                  \
    # remove the default config files
    rm -v /etc/idmapd.conf /etc/exports

# http://wiki.linux-nfs.org/wiki/index.php/Nfsv4_configuration
RUN mkdir -p /var/lib/nfs/rpc_pipefs && \
    mkdir -p /var/lib/nfs/v4recovery && \
    echo "rpc_pipefs  /var/lib/nfs/rpc_pipefs  rpc_pipefs  defaults  0  0" >> /etc/fstab && \
    echo "nfsd        /proc/fs/nfsd            nfsd        defaults  0  0" >> /etc/fstab

EXPOSE 2049

HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
	CMD exportfs || exit 1

# setup entrypoint
COPY --chmod=0755 ./entrypoint.sh /usr/local/bin
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# environment variables
ENV NFS_SERVER_THREAD_COUNT=8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV TERM xterm-256color
ENV TZ=US/Michigan
