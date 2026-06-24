FROM envoyproxy/envoy:v1.37-latest AS envoy-source

FROM nestybox/ubuntu-noble-systemd-docker:latest

COPY interactive-shell.service /etc/systemd/system/interactive-shell.service
RUN ln -s /etc/systemd/system/interactive-shell.service /etc/systemd/system/multi-user.target.wants/interactive-shell.service

# quiet systemd output and lower kernel console verbosity
RUN mkdir -p /etc/systemd/system.conf.d /etc/sysctl.d && \
    printf '[Manager]\nShowStatus=no\nLogLevel=err\n' \
        > /etc/systemd/system.conf.d/quiet.conf && \
    printf 'kernel.printk = 3 4 1 3\n' > /etc/sysctl.d/99-silence.conf

# Install Envoy with service
COPY --from=envoy-source /usr/local/bin/envoy /usr/local/bin/envoy
COPY envoy-internal.yaml /etc/envoy/envoy.yaml
COPY envoy.service /etc/systemd/system/envoy.service

RUN userdel admin \
    # Make bash look nicer
    && sed -Ei 's/^#(force_color_prompt=yes)/\1/' /root/.bashrc \
    && rm /etc/update-motd.d/10-help-text /etc/update-motd.d/50-motd-news /etc/update-motd.d/60-unminimize \
    # Allow no auth for SSH to root
    # && passwd -d root \
    # && printf 'PermitRootLogin yes\nPasswordAuthentication yes\nPermitEmptyPasswords yes' >> /etc/ssh/sshd_config \
    # Install useful stuff
    && apt-get update && apt-get install -y dnsutils git nano curl wget htop unzip ca-certificates make gpg \
    # Node and Python version managers
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash \
    && env UV_INSTALL_DIR="/usr/local/bin" sh -c "$(curl -LsSf https://astral.sh/uv/install.sh)" \
    # Install tinyproxy
    && apt-get install -y tinyproxy && printf 'Allow 172.16.0.0/12\n' >> /etc/tinyproxy/tinyproxy.conf \
    # Enable Envoy service (without systemctl, as it isn't loaded at build time)
    && ln -s /etc/systemd/system/envoy.service /etc/systemd/system/multi-user.target.wants/envoy.service
    # && rm -rf /var/lib/apt/lists/*

COPY localbin.env /root/.local/bin/env
RUN printf "\n. "$HOME/.local/bin/env"\n" >> /root/.profile

# Proxy setup
COPY my_ca.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates \
    && printf '\
NODE_EXTRA_CA_CERTS=/usr/local/share/ca-certificates/my_ca.crt\n\
REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt\n\
SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt\n' >> /etc/environment

# Docker image loading setup
COPY docker-preload.service /etc/systemd/system/docker-preload.service
COPY docker-preload.sh /usr/local/bin/docker-preload.sh
RUN chmod +x /usr/local/bin/docker-preload.sh && \
    systemctl enable docker-preload.service

# Double env var config, one for systemd bash and the other for processes started with docker exec
ENV NODE_EXTRA_CA_CERTS=/usr/local/share/ca-certificates/my_ca.crt \
    REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt \
    SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

# TODO proof of concept for CA injection
# COPY ca-injector/ca-injector-runtime /usr/local/bin/ca-injector-runtime
# COPY ca-injector/inject-ca-cert.py   /usr/local/bin/inject-ca-cert.py
# COPY ca-injector/daemon.json         /etc/docker/daemon.json

# RUN chmod +x /usr/local/bin/ca-injector-runtime /usr/local/bin/inject-ca-cert.py \
#     && apt-get update && apt-get install -y python3 && rm -rf /var/lib/apt/lists/*