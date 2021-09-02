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
    apt-get install -y wget sudo supervisor postgresql memcached && \
    supervisord && \
    wget -O - https://raw.githubusercontent.com/fusionpbx/fusionpbx-install.sh/master/debian/pre-install.sh | sh && \
    cd /usr/src/fusionpbx-install.sh/debian && \
    patch -p2 < /tmp/fusionpbx-install.sh.patch && \
    sed -i -e "s|system_password=random|system_password=$PBX_ADMIN_PASS|g" -e "s|domain_name=ip_address|domain_name=$PBX_DOMAIN|g" resources/config.sh && \
    ./install.sh
USER root
VOLUME ["/var/lib/postgresql", "/etc/freeswitch", "/var/lib/freeswitch", "/usr/share/freeswitch", "/var/www/fusionpbx"]
CMD /usr/bin/supervisord -n
