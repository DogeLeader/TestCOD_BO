# Use the latest Alpine Linux image as the base
FROM alpine:latest

# Set environment variables
ENV DISPLAY=:99 \
    NOVNC_PORT=8080

# Install dependencies
RUN apk add --no-cache \
    dolphin-emu \
    xvfb \
    git \
    python3 \
    py3-pip \
    wget && \
    pip3 install websockify

# Clone and set up noVNC
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc && \
    git clone https://github.com/novnc/websockify /opt/novnc/utils/websockify && \
    chmod +x /opt/novnc/utils/launch.sh

# Download the file from Mega.nz
RUN wget -O /path/to/downloaded/file.iso "https://mega.nz/#!MSkw2CqQ!Mg7l7x7-bllT2h1S6OxK4TuNSFN1Mn-VzKJtvf6Fzcs"

# Add the startup commands directly
CMD Xvfb :99 -screen 0 1024x768x24 & \
    dolphin-emu --headless --exec="/path/to/downloaded/file.iso" & \
    /opt/novnc/utils/launch.sh --vnc localhost:5900 --listen $NOVNC_PORT
