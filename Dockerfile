FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:99
ENV USER=root

# Install dependencies including autotools for building psdoom-ng
RUN apt-get update && apt-get install -y \
    gcc \
    make \
    autoconf \
    automake \
    libtool \
    libsdl1.2-dev \
    libsdl-mixer1.2-dev \
    libsdl-net1.2-dev \
    bash \
    git \
    x11vnc \
    xvfb \
    fluxbox \
    wget \
    curl \
    unzip \
    net-tools \
    novnc \
    websockify \
    xterm \
    procps \
    python3 \
    python3-numpy \
    autocutsel \
    xdotool \
    xclip \
    x11-utils \
    ca-certificates \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI to interact with host Docker daemon
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu jammy stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

# Clone and build psdoom-ng
WORKDIR /tmp
RUN git clone https://github.com/ChrisTitusTech/psdoom-ng.git

# Build psdoom-ng (sequential build to ensure binary is created before failure)
WORKDIR /tmp/psdoom-ng/trunk
RUN autoreconf -i && ./configure
# Build but ignore the desktop file error - the binary gets created before that fails
RUN make ; exit 0
# The binary is created as chocolate-doom then copied to psdoom-ng, copy it manually
RUN cp src/chocolate-doom /usr/local/bin/psdoom-ng && chmod +x /usr/local/bin/psdoom-ng

# Create doom directory and download WAD
RUN mkdir -p /usr/share/games/doom
WORKDIR /usr/share/games/doom

# Download doom1.wad (shareware) from multiple sources
RUN wget -q --timeout=30 https://distro.ibiblio.org/slitaz/sources/packages/d/doom1.wad -O doom1.wad || \
    wget -q --timeout=30 "https://archive.org/download/DoomsharewareEpisode/doom.WAD" -O doom1.wad || \
    (wget -q --timeout=30 "https://www.quaddicted.com/files/idgames/idstuff/doom/doom19s.zip" -O doom.zip && unzip -o doom.zip DOOM1.WAD && mv DOOM1.WAD doom1.wad && rm doom.zip) || \
    echo "WARNING: Could not download WAD file"

# Setup VNC password
RUN mkdir -p /root/.vnc && \
    x11vnc -storepasswd 1234 /root/.vnc/passwd

# Create startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Copy Docker integration scripts for psdoom-ng
COPY docker-ps.sh /usr/local/bin/docker-ps.sh
COPY docker-kill.sh /usr/local/bin/docker-kill.sh
COPY psdoom-docker.sh /usr/local/bin/psdoom-docker
RUN chmod +x /usr/local/bin/docker-ps.sh /usr/local/bin/docker-kill.sh /usr/local/bin/psdoom-docker

# Set environment variables for Docker container mode
ENV PSDOOMPSCMD="/usr/local/bin/docker-ps.sh"
ENV PSDOOMKILLCMD="/usr/local/bin/docker-kill.sh"

# Setup noVNC
RUN ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html

EXPOSE 5900 6080

CMD ["/start.sh"]
