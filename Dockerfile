# To run this container you need to add --cap-add=net_admin,sys_nice

FROM debian:trixie as builder
LABEL org.opencontainers.image.source https://github.com/M3-Repos/docker-hercules

RUN apt-get update \
    && apt-get install -y apt-utils \
    git net-tools wget curl sudo \
    time ncat build-essential cmake regina-rexx libregina3-dev\
    autoconf automake flex gawk m4 libtool \
    libcap2-bin libbz2-dev zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -ms /bin/bash hercules \
    && adduser hercules sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER hercules
#WORKDIR /home/hercules
WORKDIR /home/hercules/herctest
RUN git clone https://github.com/wrljet/hercules-helper.git ~/hercules-helper \
    && ~/hercules-helper/hercules-buildall.sh --auto --flavor=sdl-hyperion

FROM ubuntu:24.04
RUN apt-get update \
    && apt-get install --no-install-recommends -y libcap2-bin regina-rexx libregina3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -ms /bin/bash hercules 
USER hercules
WORKDIR /home/hercules
ENV PATH="/home/hercules/herctest/herc4x/bin:${PATH}"
ENV LD_LIBRARY_PATH="/home/hercules/herctest/herc4x/lib"
COPY --from=builder /home/hercules/herctest/herc4x/ /home/hercules/herctest/herc4x
USER root
RUN setcap 'cap_sys_nice=eip' /home/hercules/herctest/herc4x/bin/hercules && \
    setcap 'cap_sys_nice=eip' /home/hercules/herctest/herc4x/bin/herclin && \
    setcap 'cap_net_admin+ep' /home/hercules/herctest/herc4x/bin/hercifc && \
    ln -s "/usr/lib/$(uname -m)-linux-gnu/libregina.so.3" "/usr/lib/$(uname -m)-linux-gnu/libregina.so"
USER hercules
COPY --chmod=755 startup.sh ./startup.sh
COPY hercules.rc ./hercules.rc
CMD ["./startup.sh"]
