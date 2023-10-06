#########################################################################
#                    Setup Stage: install apps                          #
#########################################################################
FROM ubuntu:22.04 as setup

ENV IB_GATEWAY_VERSION=10.19.2d
ENV IB_GATEWAY_RELEASE_CHANNEL=stable
ENV IBC_VERSION=3.18.0

# Set environment variables to prevent apt from asking questions during install
ENV DEBIAN_FRONTEND=noninteractive

# Prepare system
RUN apt-get update -y && apt-get install --no-install-recommends --yes \
    curl \
    ca-certificates \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/setup

# Copy optional pre-downloaded distribution files.
# If they exist, the install scripts will not download them. If not - they will.
COPY ./dist/* ./

# Copy the install scripts to the container
COPY ./build-scripts/*.sh ./
RUN chmod +x ./*.sh

# Install java
RUN ./install-java.sh
ENV JAVA_HOME=/opt/java
ENV PATH=$JAVA_HOME/bin:$PATH

# Install IB Gateway
RUN ./install-ib-gateway.sh ${IB_GATEWAY_VERSION} ${IB_GATEWAY_RELEASE_CHANNEL}

# Install IBC
RUN curl -sSL https://github.com/IbcAlpha/IBC/releases/download/${IBC_VERSION}-Update.1/IBCLinux-${IBC_VERSION}.zip --output IBCLinux-${IBC_VERSION}.zip
RUN mkdir /root/ibc
RUN unzip ./IBCLinux-${IBC_VERSION}.zip -d /root/ibc
RUN chmod -R u+x /root/ibc/*.sh
RUN chmod -R u+x /root/ibc/scripts/*.sh
COPY ./config/ibc/config.ini.tmpl /root/ibc/config.ini.tmpl

# Copy scripts
COPY ./run-scripts /root/scripts

# Clone noVNC
RUN git clone https://github.com/novnc/noVNC.git /root/novnc

#########################################################################
#                  Build Stage: production image                        #
#########################################################################
FROM ubuntu:22.04

ENV IB_GATEWAY_VERSION=10.19.2d

# Set environment variables to prevent apt from asking questions during install
ENV DEBIAN_FRONTEND=noninteractive

# Prepare system
RUN apt-get update && \
    apt-get install -q --no-install-recommends --yes \
    libxext-dev \
    libxrender-dev \
    libxtst-dev \
    tzdata \
    gettext \
    xvfb \
    libxslt-dev \
    libxrender1 \
    libxtst6 \
    libxext6 \
    libxi6 \
    libgtk2.0-bin \
    socat \
    x11vnc \
    git \
    python3 \
    python3-pip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN echo 'tzdata tzdata/Areas select Etc' | debconf-set-selections && \
    echo 'tzdata tzdata/Zones/Etc select UTC' | debconf-set-selections

RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata

# Copy Java from the setup stage
COPY --from=setup /opt/java /opt/java

# Set environment variables for Java
ENV JAVA_HOME=/opt/java
ENV PATH=$JAVA_HOME/bin:$PATH

# Expose the VNC port for noVNC
EXPOSE 6080

# Copy files from setup stage
COPY --from=setup /root/ /root/
RUN chmod a+x /root/scripts/*.sh /root/novnc/utils/novnc_proxy

# IBC env vars
ENV TWS_MAJOR_VRSN ${IB_GATEWAY_VERSION}
ENV TWS_PATH /root/Jts
ENV IBC_PATH /root/ibc
ENV IBC_INI /root/ibc/config.ini
ENV TWOFA_TIMEOUT_ACTION exit

# Start run script
CMD ["/root/scripts/run.sh"]
