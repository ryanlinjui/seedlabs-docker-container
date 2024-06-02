FROM ubuntu:24.04

# Avoid warnings by switching to noninteractive for the build process
ENV DEBIAN_FRONTEND=noninteractive \
    USER=root

# ====================================================================================
#  Install necessary packages for SEED labs, following the instructions from the lab:
#   
#   Install ubuntu default tools, docker image does not have them
#       sudo, vim, git, curl, tcpdump, iputils-ping

#   Networking Tools
#       telnetd, traceroute, openbsd-inetd, net-tools
#   
#   For Firewalls lab
#       conntrack
#
#   For DNS
#       resolvconf
#
#   Install browser
#       firefox
#
#   Utilities
#       bless, ent, execstack, gdb, ghex, libpcap-dev, nasm, unzip, whois, zip, zsh
#   
#   For 32-bit, 64-bit compile and build, amd64 platform
#       gcc-multilib or gcc
#
#   Install docker and Start docker daemon
#       docker.io, docker-compose
#
#   Install Wireshark
#       wireshark
#
#   Install Xfce GUI and VNC server with lightdm
#       xfce4, xfce4-goodies, x11vnc, tightvncserver, dbus-x11, xterm
#
#   Install pip3 and Python3 modules
#       python3-pip, scapy, pycryptodome
#
#   Install gdbpeda (gdb plugin)
#       gdbpeda
# ====================================================================================

# For installing resolvconf issue
# Fix from: https://stackoverflow.com/questions/40877643/apt-get-install-in-ubuntu-16-04-docker-image-etc-resolv-conf-device-or-reso
RUN echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections

RUN apt-get update && apt-get -y install sudo vim git curl tcpdump iputils-ping \
    telnetd traceroute openbsd-inetd net-tools \
    conntrack resolvconf firefox \
    ent execstack gdb ghex libpcap-dev nasm unzip whois zip zsh \
    gcc \
    docker.io docker-compose wireshark \
    xfce4 xfce4-goodies x11vnc tightvncserver dbus-x11 xterm \
    python3-pip \
    && echo "/usr/sbin/lightdm" > /etc/X11/default-display-manager \
    && git clone https://github.com/longld/peda.git /opt/gdbpeda \
    && apt-get -y install python3-scapy python3-pycryptodome \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ====================================================================================
#  Configure for SEED labs, following the instructions from the lab:
#
#   - src-cloud.zip:        SEED labs configuration files 
#   - seed_gdbinit:         GDB Configuration file
#   - seed_bash_aliases:    Defined a few Aliases for the SEED labs
#   - Desktop/*, Icons/*:   Launcher Icons on the Desktop
#   - Background/*:         Desktop image files
#   - Wireshark/*:          Customization for Wireshark
# ====================================================================================

# Set up Wireshark Permissions, but you are root so no need to do this
# RUN chgrp $USER /usr/bin/dumpcap \
#     && chmod 750 /usr/bin/dumpcap \
#     && setcap cap_net_raw,cap_net_admin+eip /usr/bin/dumpcap

RUN curl -o src-cloud.zip https://seed.nyc3.cdn.digitaloceanspaces.com/src-cloud.zip \
    && unzip src-cloud.zip -d /tmp \
    && cp /tmp/src-cloud/Files/System/seed_gdbinit /root/.gdbinit \
    && cp /tmp/src-cloud/Files/System/seed_bash_aliases /root/.bash_aliases \
    && mkdir -p /root/Desktop /root/.local/icons \
    && cp /tmp/src-cloud/Files/System/Desktop/* /root/Desktop \
    && chmod u+x /root/Desktop/*.desktop \
    && cp /tmp/src-cloud/Files/System/Icons/* /root/.local/icons \
    && cp -f /tmp/src-cloud/Files/System/Background/* /usr/share/backgrounds/xfce/ \
    && mkdir -p /root/.config/wireshark/ \
    && cp /tmp/src-cloud/Files/Wireshark/preferences /root/.config/wireshark/preferences \
    && cp /tmp/src-cloud/Files/Wireshark/recent /root/.config/wireshark/recent \
    && rm -rf /tmp/src-cloud src-cloud.zip

# ===================================================
#  VNC Server setup
#  Setup VNC server with password and startup script
# ===================================================

RUN mkdir -p /root/.vnc \
    && echo "password" | vncpasswd -f > /root/.vnc/passwd \
    && chmod 600 /root/.vnc/passwd \
    && echo -e \
        '#!/bin/bash\n' \
        'dockerd &\n' \
        'xrdb /root/.Xresources\n' \
        'startxfce4 &' > /root/.vnc/xstartup \
    && chmod +x /root/.vnc/xstartup

EXPOSE 5901

CMD ["sh", "-c", "vncserver :1 -geometry 1280x800 -depth 24 && tail -f /dev/null"]