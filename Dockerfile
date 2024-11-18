# Use Ubuntu 24.10 as the base
FROM ubuntu:24.10

# Set environment variables
ENV DISPLAY=:99 \
    NOVNC_PORT=8080 \
    DEBIAN_FRONTEND=noninteractive

# Update package lists and install dependencies
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
    && rm -rf /var/lib/apt/lists/*

# Add the GPG key for the MEGA repository
RUN wget -O /etc/apt/trusted.gpg.d/mega.gpg https://mega.nz/linux/repo/xUbuntu_22.04/Release.gpg

# Add repository sources
RUN echo "deb http://archive.ubuntu.com/ubuntu/ jammy main universe" >> /etc/apt/sources.list.d/jammy.list

# Update package lists again and install required dependencies
RUN apt-get update && apt-get install -y \
    libmediainfo0v5 \
    libpcrecpp0v5 \
    libzen0t64 \
    && rm -rf /var/lib/apt/lists/*

# Download and install MEGAcmd which includes mega-get command for downloading files
RUN wget https://mega.nz/linux/repo/xUbuntu_24.10/amd64/megacmd-xUbuntu_24.10_amd64.deb && \
    apt-get install -y ./megacmd-xUbuntu_24.10_amd64.deb && \
    rm megacmd-xUbuntu_24.10_amd64.deb

# Create a directory for the game ISOs
RUN mkdir -p /games

# Use mega-get to download the files from MEGA
RUN mega-get "https://mega.nz/file/MSkw2CqQ#Mg7l7x7-bllT2h1S6OxK4TuNSFN1Mn-VzKJtvf6Fzcs" /games/codbo1.iso && \
    mega-get "https://mega.nz/file/EC9B2Cib#sFfnZZv-ukJ8KbkUEPoSEOTlae7jCj_Ws2vigNij6_8" /games/codbo2.iso

# Setup Flatpak and install Dolphin
RUN flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo && \
    flatpak install -y flathub org.DolphinEmu.dolphin-emu

# Add the startup command directly
CMD ["sh", "-c", "Xvfb :99 -screen 0 1024x768x24 & flatpak run --user org.DolphinEmu.dolphin-emu --headless --play /games/codbo1.iso /games/codbo2.iso & websockify --web /usr/share/novnc/ $NOVNC_PORT localhost:5900"]
