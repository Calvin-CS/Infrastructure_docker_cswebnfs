# Based on https://github.com/ehough/docker-nfs-server/blob/develop/Dockerfile
FROM calvincs.azurecr.io/base-sssd:latest
LABEL maintainer="Chris Wieringa <cwieri39@calvin.edu>"

# Set versions and platforms
ARG S6_OVERLAY_VERSION=3.1.6.2
ARG BUILDDATE=20231121-1

# Do all run commands with bash
SHELL ["/bin/bash", "-c"]
ENTRYPOINT ["/init"]

# copy new s6-overlay items for NFS/logging
COPY s6-overlay/ /etc/s6-overlay

# Install syslogd-overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/syslogd-overlay-noarch.tar.xz /tmp/
RUN tar -C / -Jxpf /tmp/syslogd-overlay-noarch.tar.xz && \
    rm -f /tmp/syslogd-overlay-noarch.tar.xz

# Access control
RUN echo "ldap_access_filter = memberOf=CN=CS-admins,OU=Groups,OU=CalvinCS,DC=ad,DC=calvin,DC=edu" >> /etc/sssd/sssd.conf

# Setup of NFS
RUN apt update -y && apt install -y nfs-kernel-server acl libcap2-bin rsync nfs-common kmod && \
    # remove the default config files
    rm -v /etc/idmapd.conf /etc/exports && \
    # add export directory for csweb
    mkdir -p /export/csweb && \
    # http://wiki.linux-nfs.org/wiki/index.php/Nfsv4_configuration
    mkdir -p /var/lib/nfs/rpc_pipefs /var/lib/nfs/v4recovery && \
    echo "rpc_pipefs  /var/lib/nfs/rpc_pipefs  rpc_pipefs  defaults  0  0" >> /etc/fstab && \
    echo "nfsd        /proc/fs/nfsd            nfsd        defaults  0  0" >> /etc/fstab

EXPOSE 2049

HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
	CMD exportfs || exit 1

# setup entrypoint
COPY --chmod=0755 inc/entrypoint.sh /usr/local/bin

# environment variables
ENV NFS_SERVER_THREAD_COUNT=8
ENV NFS_VERSION=4.2
ENV NFS_LOG_LEVEL=DEBUG
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV TERM xterm-256color
ENV TZ=US/Michigan
