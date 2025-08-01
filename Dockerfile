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
COPY busybox busybox
COPY linux linux

CMD ["make", "all"]
