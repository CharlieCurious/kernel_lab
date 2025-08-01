SHELL := /bin/bash
BUILD_DIR := $(shell pwd)/distro
ROOT := $(BUILD_DIR)/rootfs

.PHONY: all setup linux bash coreutils glibc cpio

all: setup linux bash coreutils cpio

setup:
	mkdir -p $(ROOT)/{boot,proc,sys,dev,usr/{bin,sbin,lib,lib64}}
	ln -sr $(ROOT)/usr/bin $(ROOT)/bin
	ln -sr $(ROOT)/usr/sbin $(ROOT)/sbin
	ln -sr $(ROOT)/usr/lib $(ROOT)/lib
	ln -sr $(ROOT)/usr/lib64 $(ROOT)/lib64

linux:
	make -C linux -j$(shell nproc)
	cp linux/arch/x86/boot/bzImage $(ROOT)/boot/

bash:
	cd bash/ && ./configure --prefix=/usr --enable-static-link
	make -C  bash -j$(shell nproc)
	make -C bash DESTDIR=$(ROOT) install
	ln -sr $(ROOT)/usr/bin/bash $(ROOT)/usr/bin/sh

coreutils:
	cd coreutils && ./bootstrap
	cd coreutils && ./configure --prefix=/usr CFLAGS="-static -O2" LDFLAGS="-static" --disable-nls
	make -C coreutils -j$(shell nproc)
	make -C coreutils DESTDIR=$(ROOT) install

glibc:
	mkdir -p glibc/glibc-build
	cd glibc/glibc-build && ../configure --libdir=/lib --prefix=/usr
	make -C glibc/glibc-build -j$(shell nproc)
	make -C glibc/glibc-build DESTDIR=$(ROOT) install

cpio:
	ln -sfr $(ROOT)/usr/bin/bash $(ROOT)/init
	cd distro/rootfs && find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../init.cpio.gz

clean:
	rm -rf $(BUILD_DIR)
	make -C linux clean
	make -C bash clean
	make -C coreutils distclean || true
	rm -rf glibc/glibc-build
