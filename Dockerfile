FROM ubuntu:20.04

# Avoid warnings by switching to noninteractive for the build process
ENV DEBIAN_FRONTEND noninteractive

# Set VNC server display resolution (change as needed)
ENV RESOLUTION=1920x1080
ENV USER=root

RUN apt update

# Install ubuntu default tools, docker image does not have them
RUN apt -y install sudo \
    vim \
    git \
    curl \
    tcpdump

# Networking Tools
RUN apt -y install telnetd \
    traceroute \
    openbsd-inetd \
    net-tools

# For Firewalls lab
RUN apt -y install conntrack

# For DNS
# Fix from: https://stackoverflow.com/questions/40877643/apt-get-install-in-ubuntu-16-04-docker-image-etc-resolv-conf-device-or-reso
RUN echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections
RUN apt -y install resolvconf

# Install browser
RUN apt -y install firefox

# Utilities
RUN apt -y install bless \
    ent \
    execstack \
    gdb \
    ghex \
    libpcap-dev \
    nasm \
    unzip \
    whois \
    zip \
    zsh

# For 32-bit, 64-bit compile and build, amd64 platform
# RUN apt -y install gcc-multilib
RUN apt -y install gcc

# Install pip3 and Python3 modules 
RUN apt -y install python3-pip \
    && pip3 install scapy \
    && pip3 install pycryptodome

# Install gdbpeda (gdb plugin)
RUN git clone https://github.com/longld/peda.git /tmp/gdbpeda \
    && cp -r /tmp/gdbpeda /opt \
    && rm -rf /tmp/gdbpeda

# Install Xfce GUI and VNC server
RUN apt install -y --no-install-recommends \
    xfce4 \
    xfce4-goodies \
    tightvncserver \
    dbus-x11 \
    xfonts-base

RUN curl -o src-cloud.zip https://seed.nyc3.cdn.digitaloceanspaces.com/src-cloud.zip \
    && unzip src-cloud.zip -d /tmp

# Install gdbpeda (gdb plugin)
RUN cp /tmp/src-cloud/Files/System/seed_gdbinit /root/.gdbinit

# We have defined a few aliases for the SEED labs
RUN cp /tmp/src-cloud/Files/System/seed_bash_aliases /root/.bash_aliases

# Create launcher icons on the desktop
RUN mkdir -p /root/Desktop
RUN cp /tmp/src-cloud/Files/System/Desktop/*  /root/Desktop
RUN chmod u+x /root/Desktop/*.desktop
RUN mkdir -p /root/.local/icons
RUN cp /tmp/src-cloud/Files/System/Icons/*  /root/.local/icons

# Copy the desktop image files
RUN cp -f /tmp/src-cloud/Files/System/Background/* /usr/share/backgrounds/xfce/

# Setup VNC server
RUN mkdir /root/.vnc \
    && echo "password" | vncpasswd -f > /root/.vnc/passwd \
    && chmod 600 /root/.vnc/passwd
RUN touch /root/.Xauthority

# Install docker and Start docker daemon
RUN apt install -y docker.io
RUN apt install -y docker-compose

# Install Wireshark
RUN apt -y install wireshark
RUN chgrp $USER /usr/bin/dumpcap
RUN chmod 750 /usr/bin/dumpcap
RUN setcap cap_net_raw,cap_net_admin+eip /usr/bin/dumpcap

# Customization for Wireshark
RUN mkdir -p /root/.config/wireshark/
RUN cp /tmp/src-cloud/Files/Wireshark/preferences /root/.config/wireshark/preferences
RUN cp /tmp/src-cloud/Files/Wireshark/recent /root/.config/wireshark/recent

# Clean apt cache
RUN apt clean  \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /src-cloud.zip

# Set up the startup script
RUN echo '\
#!/bin/bash\n\
dockerd &\n\
HOSTNAME=$(hostname)\n\
echo "127.0.1.1\t$HOSTNAME" >> /etc/hosts\n\
vncserver -kill :1 || true\n\
vncserver -geometry $RESOLUTION &\n\
tail -f /dev/null' > /root/startup.sh && chmod +x /root/startup.sh

EXPOSE 5901

CMD ["bash", "/root/startup.sh"]