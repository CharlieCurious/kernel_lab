FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    make \
    gcc flex bison bc libelf-dev libssl-dev \
    bzip2 bc \
    libncurses-dev cpio syslinux dosfstools\
    git vim \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

COPY Makefile Makefile

RUN git clone --depth=1 https://github.com/torvalds/linux.git
RUN git clone --depth=1 https://git.busybox.net/busybox

CMD ["make", "all"]
