# Stage 1, build linux QQNT package from AUR
FROM archlinux:latest AS builder
RUN pacman -Syu --noconfirm git base-devel \
    && git clone https://aur.archlinux.org/linuxqq.git --depth=1 \
    && chown -R daemon:daemon /linuxqq \
    && echo "daemon ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
WORKDIR /linuxqq
USER daemon
RUN export PKGEXT=.pkg.tar \
    && makepkg --syncdeps --noconfirm --needed \
    && mv linuxqq-*.pkg.tar linuxqq.pkg.tar

# Stage 2, download noVNC and websockify
FROM archlinux:latest AS novnc
RUN pacman -Syu --noconfirm git \
    && git clone --depth=1 https://github.com/novnc/noVNC.git /opt/noVNC \
    && git clone --depth=1 https://github.com/kanaka/websockify /opt/noVNC/utils/websockify \
    && find /opt/noVNC -name ".git" | xargs rm -rf

# Stage 3, build image
FROM archlinux:latest
COPY --from=novnc /opt/noVNC /opt/noVNC
RUN --mount=type=bind,from=builder,target=/linuxqq,source=/linuxqq \
    pacman -Sy --noconfirm \
    xorg-server xorg-server-xvfb x11vnc \
    openbox rxvt-unicode openjpeg2 adobe-source-han-sans-cn-fonts \
    python supervisor \
    && pacman -U --noconfirm /linuxqq/linuxqq.pkg.tar \
    && pacman -Scc --noconfirm
RUN mkdir -p /var/log/supervisor/ \
    && useradd -m -s /bin/bash user \
    && echo "urxvt -e linuxqq &" >> /etc/xdg/openbox/autostart 
COPY supervisord.ini /etc/supervisor.d/supervisord.ini
WORKDIR /var/log/supervisor/
EXPOSE 8083
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor.d/supervisord.ini"]
