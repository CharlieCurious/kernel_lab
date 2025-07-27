SHELL := /bin/bash
BUILD_DIR := distro
ROOT := $(BUILD_DIR)/rootfs

.PHONY: all setup minkernel

all: setup minkernel

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


clean:
	rm -rf $(BUILD_DIR)
	make -C linux clean
