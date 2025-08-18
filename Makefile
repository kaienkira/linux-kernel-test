INSTALL_DIR = $(abspath src/_install)
NPROC = $(shell expr `nproc` - 1)

.PHONY: \
default \
download_source \
extract_source \
force_extract_source \
build \
clean \
create_install_dir \
clean_install_dir \
strip \
reinstall \
initramfs \
initramfs.main \
initramfs.router \
initramfs.local \
run.main \
run-graphic.main \
run.router \
run.local

default: run.main

download_source:
	bash tools/download_source.sh

extract_source:
	bash tools/extract_source.sh

force_extract_source:
	find src/ -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} \;
	bash tools/extract_source.sh

build: \
create_install_dir \
kernel-build \
glibc-build \
libxcrypt-build \
busybox-build \
libmnl-build \
libnftnl-build \
libnfnetlink-build \
libnetfilter_conntrack-build \
nftables-build \
iproute2-build \
dropbear-build \
grub-build \
strip \
initramfs \
vmdk.router

clean: \
kernel-clean \
glibc-clean \
libxcrypt-clean \
busybox-clean \
libmnl-clean \
libnftnl-clean \
libnfnetlink-clean \
libnetfilter_conntrack-clean \
nftables-clean \
iproute2-clean \
dropbear-clean \
grub-clean \
clean_install_dir
	rm -rf bin/*

create_install_dir:
	mkdir -p "$(INSTALL_DIR)"/bin
	mkdir -p "$(INSTALL_DIR)"/sbin
	mkdir -p "$(INSTALL_DIR)"/etc
	mkdir -p "$(INSTALL_DIR)"/include
	mkdir -p "$(INSTALL_DIR)"/lib

clean_install_dir:
	rm -rf "$(INSTALL_DIR)"

strip:
	find "$(INSTALL_DIR)"/bin -type f -exec strip {} \;
	find "$(INSTALL_DIR)"/sbin -type f -exec strip {} \;
	find "$(INSTALL_DIR)"/lib -type f -exec strip {} \;

reinstall: \
clean_install_dir \
create_install_dir \
kernel-install \
glibc-install \
libxcrypt-install \
busybox-install \
libmnl-install \
libnftnl-install \
libnfnetlink-install \
libnetfilter_conntrack-install \
nftables-install \
iproute2-install \
dropbear-install \
strip

initramfs: initramfs.main initramfs.router initramfs.local

initramfs.main:
	bash tools/build_initramfs.sh main "$(INSTALL_DIR)"

initramfs.router:
	bash tools/build_initramfs.sh router "$(INSTALL_DIR)"

initramfs.local:
	bash tools/build_initramfs.sh local "$(INSTALL_DIR)"

run.main:
	bash tools/run_qemu.sh main nographic

run-graphic.main:
	bash tools/run_qemu.sh main graphic

run.router:
	bash tools/run_qemu.sh router nographic

run.local:
	bash tools/run_qemu.sh local nographic

vmdk.router:
	bash tools/build_vmdk.sh router "$(INSTALL_DIR)" "$(GRUB_SRC_DIR)"

include mak/kernel.mak
include mak/glibc.mak
include mak/libxcrypt.mak
include mak/busybox.mak
include mak/libmnl.mak
include mak/libnftnl.mak
include mak/libnfnetlink.mak
include mak/libnetfilter_conntrack.mak
include mak/nftables.mak
include mak/iproute2.mak
include mak/dropbear.mak
include mak/grub.mak
