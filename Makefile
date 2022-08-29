LINUX_KERNEL_SRC_DIR = $(abspath src/linux-6.0-rc3)
LINUX_KERNEL_ENV = O=build ARCH=x86

BUSYBOX_SRC_DIR = $(abspath src/busybox-1.35.0)
BUSYBOX_ENV = O=build ARCH=x86

GRUB_SRC_DIR = $(abspath src/grub-2.06)

LIBMNL_SRC_DIR = $(abspath src/libmnl-1.0.5)
LIBNFTNL_SRC_DIR = $(abspath src/libnftnl-1.2.2)
LIBNFNETLINK_SRC_DIR = $(abspath src/libnfnetlink-1.0.2)
LIBNETFILTER_CONNTRACK_SRC_DIR = $(abspath src/libnetfilter_conntrack-1.0.9)
NFTABLES_SRC_DIR = $(abspath src/nftables-1.0.4)

IPERF_SRC_DIR = $(abspath src/iperf-3.11)

###############################################################################
.PHONY: \
default download build clean \
kernel-build kernel-clean \
busybox-build busybox-clean \
nftables-build nftables-clean \
iperf-build iperf-clean \
initramfs \
initramfs.main run.main run-graphic.main \
initramfs.router vmdk.router run.router \
initramfs.local run.local \

default: run.main

###############################################################################
download:
	bash tools/download_source.sh

build: kernel-build busybox-build grub-build \
       nftables-build iperf-build \
	   initramfs vmdk.router

clean: kernel-clean busybox-clean grub-clean \
       nftables-clean iperf-clean
	rm -f bin/vmlinuz
	rm -f bin/initramfs.*.img
	rm -rf bin/initramfs.*.tmp/
	rm -f bin/BRLinux*

initramfs: initramfs.main initramfs.router initramfs.local

###############################################################################
kernel-build:
	cd $(LINUX_KERNEL_SRC_DIR) && \
		make $(LINUX_KERNEL_ENV) \
			KCONFIG_ALLCONFIG=../../settings/kernel_config allnoconfig
	cd $(LINUX_KERNEL_SRC_DIR) && \
		make $(LINUX_KERNEL_ENV) bzImage -j4
	cp $(LINUX_KERNEL_SRC_DIR)/build/arch/x86_64/boot/bzImage bin/vmlinuz
	mkdir -p $(LINUX_KERNEL_SRC_DIR)/build/_install
	cd $(LINUX_KERNEL_SRC_DIR) && \
		make $(LINUX_KERNEL_ENV) headers_install \
			INSTALL_HDR_PATH=$(LINUX_KERNEL_SRC_DIR)/build/_install

kernel-clean:
	rm -rf $(LINUX_KERNEL_SRC_DIR)/build

###############################################################################
busybox-build:
	mkdir -p $(BUSYBOX_SRC_DIR)/build
	cd $(BUSYBOX_SRC_DIR) && \
		make $(BUSYBOX_ENV) defconfig
	sed -i -f settings/busybox_config $(BUSYBOX_SRC_DIR)/build/.config
	cd $(BUSYBOX_SRC_DIR) && \
		make $(BUSYBOX_ENV) -j4
	cd $(BUSYBOX_SRC_DIR) && \
		make $(BUSYBOX_ENV) install

busybox-clean:
	rm -rf $(BUSYBOX_SRC_DIR)/build

###############################################################################
grub-build:
	cd $(GRUB_SRC_DIR) && \
		mkdir -p build && \
		cd build && \
		mkdir -p _install && \
		../configure \
			LDFLAGS="--static" \
			--disable-werror \
			--prefix=/opt/grub \
			--with-platform="pc" \
			--target="i386" && \
		make -j4 && \
		make DESTDIR=`readlink -f _install` install

grub-clean:
	rm -rf $(GRUB_SRC_DIR)/build

###############################################################################
nftables-build:
	cd $(LIBMNL_SRC_DIR) && \
		mkdir -p build && \
		cd build && \
		mkdir -p _install && \
		../configure \
			--prefix=/ \
			--enable-static \
			--disable-shared && \
		make -j4 && \
		make DESTDIR=`readlink -f _install` install
	cd $(LIBNFTNL_SRC_DIR) && \
		mkdir -p build && \
		cd build && \
		mkdir -p _install && \
		../configure \
			CFLAGS="-I$(LINUX_KERNEL_SRC_DIR)/build/_install/include \
			        -I$(LIBMNL_SRC_DIR)/build/_install/include" \
			--prefix=/ \
			--enable-static \
			--disable-shared && \
		make -j4 && \
		make DESTDIR=`readlink -f _install` install
	cd $(LIBNFNETLINK_SRC_DIR) && \
		mkdir -p build && \
		cd build && \
		mkdir -p _install && \
		../configure \
			CFLAGS="-I$(LINUX_KERNEL_SRC_DIR)/build/_install/include" \
			--prefix=/ \
			--enable-static \
			--disable-shared && \
		make -j4 && \
		make DESTDIR=`readlink -f _install` install
	cd $(LIBNETFILTER_CONNTRACK_SRC_DIR) && \
		mkdir -p build && \
		cd build && \
		mkdir -p _install && \
		../configure \
			CFLAGS="-I$(LINUX_KERNEL_SRC_DIR)/build/_install/include \
                    -I$(LIBNFNETLINK_SRC_DIR)/build/_install/include" \
			--prefix=/ \
			--enable-static \
			--disable-shared && \
		make -j4 && \
		make DESTDIR=`readlink -f _install` install
	cd $(NFTABLES_SRC_DIR) && \
		mkdir -p build && \
		cd build && \
		mkdir -p _install && \
		../configure \
			CFLAGS="-I$(NFTABLES_SRC_DIR) \
                    -I$(LINUX_KERNEL_SRC_DIR)/build/_install/include \
                    -I$(LIBMNL_SRC_DIR)/build/_install/include \
                    -I$(LIBNFTNL_SRC_DIR)/build/_install/include \
                    -I$(LIBNFNETLINK_SRC_DIR)/build/_install/include \
                    -I$(LIBNETFILTER_CONNTRACK_SRC_DIR)/build/_install/include" \
			LDFLAGS="--static \
                     -L$(LIBMNL_SRC_DIR)/build/_install/lib \
                     -L$(LIBNFTNL_SRC_DIR)/build/_install/lib \
                     -L$(LIBNFNETLINK_SRC_DIR)/build/_install/lib \
                     -L$(LIBNETFILTER_CONNTRACK_SRC_DIR)/build/_install/lib" \
			--prefix=/ \
			--with-mini-gmp \
			--without-cli \
			--enable-static \
			--disable-shared && \
		make -j4 && \
		make DESTDIR=`readlink -f _install` install

nftables-clean:
	rm -rf $(LIBMNL_SRC_DIR)/build
	rm -rf $(LIBNFTNL_SRC_DIR)/build
	rm -rf $(LIBNFNETLINK_SRC_DIR)/build
	rm -rf $(LIBNETFILTER_CONNTRACK_SRC_DIR)/build
	rm -rf $(NFTABLES_SRC_DIR)/build

###############################################################################
iperf-build:
	cd $(IPERF_SRC_DIR) && \
		mkdir -p build && \
		cd build && \
		mkdir -p _install && \
		../configure \
			--prefix=/ \
			--enable-static-bin \
			--without-sctp \
			--without-openssl && \
		make -j4 && \
		make DESTDIR=`readlink -f _install` install

iperf-clean:
	rm -rf $(IPERF_SRC_DIR)/build

###############################################################################
initramfs.main:
	bash tools/build_initramfs.sh main \
		"$(BUSYBOX_SRC_DIR)" \
		"$(NFTABLES_SRC_DIR)" \
		"$(IPERF_SRC_DIR)"

run.main:
	bash tools/run_qemu.sh main nographic

run-graphic.main:
	bash tools/run_qemu.sh main graphic

###############################################################################
initramfs.router:
	bash tools/build_initramfs.sh router \
		"$(BUSYBOX_SRC_DIR)" \
		"$(NFTABLES_SRC_DIR)" \
		"$(IPERF_SRC_DIR)"

vmdk.router:
	bash tools/build_vmdk.sh router \
		"$(BUSYBOX_SRC_DIR)" "$(GRUB_SRC_DIR)"

run.router:
	bash tools/run_qemu.sh router nographic

###############################################################################
initramfs.local:
	bash tools/build_initramfs.sh local \
		"$(BUSYBOX_SRC_DIR)" \
		"$(NFTABLES_SRC_DIR)" \
		"$(IPERF_SRC_DIR)"

run.local:
	bash tools/run_qemu.sh local nographic
