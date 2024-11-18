# Use Ubuntu 24.10 as the base
FROM ubuntu:24.10

# Set environment variables
ENV DISPLAY=:99 \
    NOVNC_PORT=8080 \
    DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8 \
    LC_ALL=C.UTF-8

# Update package lists and install necessary packages
RUN apt-get update && apt-get install -y \
    flatpak \
    x11-xserver-utils \
    xvfb \
    python3 \
    python3-pip \
    wget \
    novnc \
    websockify \
    gnupg2 \
    libxcb-cursor0 \
    && rm -rf /var/lib/apt/lists/*

# Add the GPG key for the MEGA repository
RUN wget -O /etc/apt/trusted.gpg.d/mega.gpg https://mega.nz/linux/repo/xUbuntu_24.10/Release.gpg

# Add repository sources
RUN echo "deb http://archive.ubuntu.com/ubuntu/ jammy main universe" >> /etc/apt/sources.list.d/jammy.list

# Update packages again and install additional dependencies
RUN apt-get update && apt-get install -y \
    libmediainfo0v5 \
    libpcrecpp0v5 \
    libzen0t64 \
    && rm -rf /var/lib/apt/lists/*

# Download and install MEGAcmd
RUN wget https://mega.nz/linux/repo/xUbuntu_24.10/amd64/megacmd-xUbuntu_24.10_amd64.deb && \
    apt-get install -y ./megacmd-xUbuntu_24.10_amd64.deb && \
    rm megacmd-xUbuntu_24.10_amd64.deb

# Create a directory for the game ISOs
RUN mkdir -p /games

# Download game ISOs (using mega-get here as an example)
RUN mega-get "https://mega.nz/file/MSkw2CqQ#Mg7l7x7-bllT2h1S6OxK4TuNSFN1Mn-VzKJtvf6Fzcs" /games/codbo1.iso && \
    mega-get "https://mega.nz/file/EC9B2Cib#sFfnZZv-ukJ8KbkUEPoSEOTlae7jCj_Ws2vigNij6_8" /games/codbo2.iso

# Setup Flatpak and install Dolphin
RUN flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo && \
    flatpak install -y --noninteractive flathub org.DolphinEmu.dolphin-emu || true

# Add the command to run
CMD ["sh", "-c", "\
    Xvfb :99 -screen 0 1024x768x24 & \
    sleep 2; \
    flatpak run --env=DISPLAY=:99 org.DolphinEmu.dolphin-emu --play /games/codbo1.iso /games/codbo2.iso & \
    sleep 5; \
    websockify --web /usr/share/novnc/ $NOVNC_PORT localhost:5900"]
