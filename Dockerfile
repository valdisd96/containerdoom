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
    apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI to interact with host Docker daemon
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu jammy stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

# Install kubectl for Kubernetes support
RUN curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" > /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && \
    apt-get install -y kubectl && \
    rm -rf /var/lib/apt/lists/*

# Clone and build psdoom-ng
WORKDIR /tmp
RUN git clone https://github.com/ChrisTitusTech/psdoom-ng.git

# Build psdoom-ng
WORKDIR /tmp/psdoom-ng/trunk
RUN autoreconf -i && ./configure
# Build but ignore the desktop file error - the binary gets created before that fails
RUN make ; exit 0
# The binary is created as chocolate-doom, copy it to psdoom-ng
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

# Copy all scripts
COPY scripts/ /usr/local/bin/scripts/
RUN chmod +x /usr/local/bin/scripts/*.sh /usr/local/bin/scripts/*/*.sh

# Create startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Set environment variables for psdoom-ng
ENV PSDOOMPSCMD="/usr/local/bin/scripts/ps-wrapper.sh"
ENV PSDOOMKILLCMD="/usr/local/bin/scripts/kill-wrapper.sh"

# Default mode (can be overridden)
ENV PSDOOM_MODE="select"
ENV K8S_CONTEXT=""
ENV K8S_NAMESPACE="default"

# Setup noVNC
RUN ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# Create kubeconfig directory
RUN mkdir -p /root/.kube

EXPOSE 5900 6080

CMD ["/start.sh"]
