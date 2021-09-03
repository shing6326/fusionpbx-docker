FROM debian:10
MAINTAINER Billy Chan <shing@shing.cloud>

ARG PBX_DOMAIN=default
ARG PBX_ADMIN_PASS=Om9RafTDX5iH3KcSIMoHlURqz04

COPY fusionpbx-install.sh.patch /tmp/fusionpbx-install.sh.patch
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start-freeswitch.sh /usr/bin/start-freeswitch.sh

# Install Required Dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y tini wget sudo supervisor postgresql memcached && \
    supervisord && \
    wget -O - https://raw.githubusercontent.com/fusionpbx/fusionpbx-install.sh/master/debian/pre-install.sh | sh && \
    cd /usr/src/fusionpbx-install.sh/debian && \
    patch -p2 < /tmp/fusionpbx-install.sh.patch && \
    sed -i -e "s|system_password=random|system_password=$PBX_ADMIN_PASS|g" -e "s|domain_name=ip_address|domain_name=$PBX_DOMAIN|g" resources/config.sh && \
    ./install.sh && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER root
VOLUME ["/etc/freeswitch","/etc/fusionpbx","/usr/share/freeswitch/scripts","/usr/share/freeswitch/sounds/music","/var/lib/freeswitch/recordings","/var/lib/freeswitch/storage","/var/lib/postgresql","/var/log/freeswitch"]
CMD ["/usr/bin/supervisord","-n"]
ENTRYPOINT ["/usr/bin/tini", "--"]
