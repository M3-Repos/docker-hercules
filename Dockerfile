# To run this container you need to add --cap-add=net_admin,sys_nice

FROM debian:trixie AS builder
LABEL org.opencontainers.image.source=https://github.com/M3-Repos/docker-hercules

# Install hercules dependencies to builder stage:
#
RUN <<EOF
apt-get update
apt-get install -y apt-utils git net-tools wget curl sudo time ncat build-essential cmake regina-rexx libregina3-dev autoconf automake flex gawk m4 libtool libcap2-bin libbz2-dev zlib1g-dev
apt-get clean
rm -rf /var/lib/apt/lists/*
useradd -ms /bin/bash hercules
adduser hercules sudo
echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
EOF

# Build SDL-Hyperion using 'wrljet/hercules-helper': 
#
USER hercules
WORKDIR /home/hercules/build
RUN <<EOF
git clone https://github.com/wrljet/hercules-helper.git ~/hercules-helper
~/hercules-helper/hercules-buildall.sh --auto --flavor=sdl-hyperion --no-packages --sudo --no-envscript --no-bashrc --prefix=/opt/herc4x --no-setcap
EOF

# Copy SDL-Hyperion build to runtime container.
# Install REXX in runtime container
# Set binary capabilities.
# Create symbolic link to REXX library object for discoverability.  
#
FROM ubuntu:24.04
COPY --from=builder /opt/herc4x /opt/herc4x


RUN <<EOF
apt-get update
apt-get install --no-install-recommends -y libcap2-bin regina-rexx libregina3
apt-get clean
rm -rf /var/lib/apt/lists/*
useradd -ms /bin/bash hercules 
setcap 'cap_sys_nice=eip' /opt/herc4x/bin/hercules
setcap 'cap_sys_nice=eip' /opt/herc4x/bin/herclin
setcap 'cap_net_admin+ep' /opt/herc4x/bin/hercifc
ln -s "/usr/lib/$(uname -m)-linux-gnu/libregina.so.3" "/usr/lib/$(uname -m)-linux-gnu/libregina.so"
EOF


# Set environment variables, user & working directory.
# Configuration files 'hercules.cnf' and 'hercules.rc' are expected within the working directory.
# Set relative paths to configuration files at runtime with `-e=` or in child container build with: 
# ENV HERCULES_CNF="hercules.cnf" HERCULES_RC="hercules.rc"
#
ENV PATH="/opt/herc4x/bin:${PATH}" LD_LIBRARY_PATH="/opt/herc4x/lib"
WORKDIR /home/hercules
USER hercules

CMD ["hercules"]
