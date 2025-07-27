SHELL := /bin/bash
BUILD_DIR := $(shell pwd)/distro
ROOT := $(BUILD_DIR)/rootfs

.PHONY: all setup minkernel bash

all: setup minkernel bash

setup:
	mkdir -p $(ROOT)/{boot,proc,sys,dev,usr/{bin,sbin,lib,lib64}}
	ln -sr $(ROOT)/usr/bin $(ROOT)/bin
	ln -sr $(ROOT)/usr/sbin $(ROOT)/sbin
	ln -sr $(ROOT)/usr/lib $(ROOT)/lib
	ln -sr $(ROOT)/usr/lib64 $(ROOT)/lib64

minkernel: setup
	cp kernel_minimal_config linux/.config
	make -C linux -j$(shell nproc)
	cp linux/arch/x86_64/boot/bzImage $(ROOT)/boot/

bash:
	cd bash/ && ./configure --prefix=/usr
	make -C bash -j$(shell nproc) DESTDIR=$(ROOT) install
	ln -sr $(ROOT)/usr/bin/bash $(ROOT)/usr/bin/sh

clean:
	rm -rf $(BUILD_DIR)
	make -C linux clean
	make -C bash clean
