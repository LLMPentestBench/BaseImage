FROM nestybox/ubuntu-noble-systemd-docker:latest

# auto logon (without restart)
RUN mkdir -p /etc/systemd/system/console-getty.service.d && \
    printf '[Service]\nExecStart=\nExecStart=-/sbin/agetty --autologin root --noclear console linux\nRestart=no\n' \
        > /etc/systemd/system/console-getty.service.d/autologin.conf && \
    systemctl enable console-getty.service

# on logout, poweroff systemd so the container exits
RUN printf 'if command -v systemctl >/dev/null 2>&1; then\n  systemctl poweroff --force --no-wall || poweroff -f || shutdown -h now\nfi\n' \
        > /root/.bash_logout

# quiet systemd output and lower kernel console verbosity
RUN mkdir -p /etc/systemd/system.conf.d /etc/sysctl.d && \
    printf '[Manager]\nShowStatus=no\nLogLevel=err\n' \
        > /etc/systemd/system.conf.d/quiet.conf && \
    printf 'kernel.printk = 3 4 1 3\n' > /etc/sysctl.d/99-silence.conf

RUN userdel admin \
    # Make bash look nicer
    && sed -Ei 's/^#(force_color_prompt=yes)/\1/' /root/.bashrc \
    && rm /etc/update-motd.d/10-help-text /etc/update-motd.d/50-motd-news /etc/update-motd.d/60-unminimize \
    # Allow no auth for SSH to root
    # && passwd -d root \
    # && printf 'PermitRootLogin yes\nPasswordAuthentication yes\nPermitEmptyPasswords yes' >> /etc/ssh/sshd_config \
    # Install useful stuff
    && apt-get update && apt-get install -y dnsutils git nano curl wget ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Proxy setup
COPY certs/my_ca.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates 
RUN printf 'NODE_EXTRA_CA_CERTS=/usr/local/share/ca-certificates/my_ca.crt' >> /etc/environment
