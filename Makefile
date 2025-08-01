SHELL := bash
BUILD_DIR := $(shell pwd)
BOOT_DIR := "$(BUILD_DIR)"/boot-files
INITRAMFS_DIR := "$(BUILD_DIR)"/initramfs

.PHONY: all setup kernel busybox initramfs clean

all: kernel busybox initramfs

setup:
	mkdir -p "$(BUILD_DIR)"/boot-files

kernel: setup
	make -C linux debug.config
	make -C linux -j $(shell nproc)
	cp linux/arch/x86/boot/bzImage $(BOOT_DIR)

busybox: busybox/.config
	make -C busybox -j $(shell nproc)
	make -C busybox CONFIG_PREFIX=$(INITRAMFS_DIR) install
	cd $(INITRAMFS_DIR) && rm linuxrc

busybox/.config:
	make -C busybox defconfig
	cd busybox && sed -i 's/^CONFIG_TC=y/# CONFIG_TC is not set/' .config
	cd busybox && sed -i 's/^# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config

initramfs: $(INITRAMFS_DIR)/init setup
	cd $(BUILD_DIR)/initramfs && find . -print0 | cpio --null -ov -H newc | gzip -9 > $(BOOT_DIR)/init.cpio.gz

$(INITRAMFS_DIR)/init:
	mkdir -p $(INITRAMFS_DIR)
	printf '#!/bin/sh\n\n/bin/sh\n' > "$@"
	chmod +x "$@"

clean:
	rm -rf $(BOOT_DIR) $(INITRAMFS_DIR)
	make -C linux clean
	make -C busybox clean
