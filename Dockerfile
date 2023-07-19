# Stage 1, build linux QQNT package from AUR
FROM archlinux:latest AS builder
RUN pacman -Sy --noconfirm git base-devel \
    && git clone https://aur.archlinux.org/linuxqq.git --depth=1 \
    && chown -R daemon:daemon /linuxqq \
    && echo "daemon ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
WORKDIR /linuxqq
USER daemon
ENV PKGEXT=.pkg.tar
RUN makepkg --syncdeps --noconfirm --needed \
    && mv linuxqq-*.pkg.tar linuxqq.pkg.tar

# Stage 2, download noVNC and websockify
FROM archlinux:latest AS novnc
RUN pacman -Sy --noconfirm git \
    && git clone --depth=1 https://github.com/novnc/noVNC.git /opt/noVNC \
    && ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html \
    && git clone --depth=1 https://github.com/kanaka/websockify /opt/noVNC/utils/websockify \
    && find /opt/noVNC -name ".git" | xargs rm -rf

# Stage 3, build image
FROM archlinux:latest
COPY --from=novnc /opt/noVNC /opt/noVNC
RUN --mount=type=bind,from=builder,target=/linuxqq,source=/linuxqq \
    pacman -Sy --noconfirm \
    net-tools openssl sudo \
    xorg-server xorg-server-xvfb tigervnc \
    openbox rxvt-unicode wqy-zenhei \
    python supervisor \
    && pacman -U --noconfirm /linuxqq/linuxqq.pkg.tar \
    && yes | pacman -Scc 
COPY ./scripts /scripts
RUN mkdir -p /var/log/supervisor/ \
    && useradd -m -s /bin/bash user \
    && ln -sf /scripts/autostart /etc/xdg/openbox/autostart
WORKDIR /var/log/supervisor/
EXPOSE 8083
CMD ["/usr/bin/supervisord", "-c", "/scripts/supervisord.ini"]
