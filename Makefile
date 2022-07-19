LINUX_KERNEL_SRC_DIR = src/linux-5.19-rc7
LINUX_KERNEL_ENV = O=build ARCH=x86
BUSYBOX_SRC_DIR = src/busybox-1.35.0
BUSYBOX_ENV = O=build ARCH=x86
GRUB_SRC_DIR = src/grub-2.06
QEMU_ARCH = x86_64

.PHONY: \
default build clean \
kernel-build kernel-clean \
busybox-build busybox-clean \
initramfs run run-graphic vmdk

default: run

build: kernel-build busybox-build grub-build initramfs 

clean: kernel-clean busybox-clean grub-clean
	rm -rf $(LINUX_KERNEL_SRC_DIR)/build
	rm -rf $(BUSYBOX_SRC_DIR)/build
	rm -rf $(GRUB_SRC_DIR)/build
	rm -f bin/vmlinuz
	rm -f bin/initramfs.img

kernel-build:
	cd $(LINUX_KERNEL_SRC_DIR) && \
		make $(LINUX_KERNEL_ENV) \
			KCONFIG_ALLCONFIG=../../settings/kernel_config allnoconfig
	cd $(LINUX_KERNEL_SRC_DIR) && \
		make $(LINUX_KERNEL_ENV) bzImage -j4
	cp $(LINUX_KERNEL_SRC_DIR)/build/arch/x86_64/boot/bzImage bin/vmlinuz

kernel-clean:
	cd $(LINUX_KERNEL_SRC_DIR) && \
		make $(LINUX_KERNEL_ENV) distclean

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
	cd $(BUSYBOX_SRC_DIR) && \
		if [ -d $(BUSYBOX_SRC_DIR)/build ]; then make $(BUSYBOX_ENV) distclean; fi

grub-build:
	cd $(GRUB_SRC_DIR) && \
		mkdir -p build && \
		cd build && \
		mkdir -p _install && \
		../configure LDFLAGS="-static" \
			--disable-werror --prefix=/opt/grub \
			--with-platform="pc" --target="i386" && \
		make -j4 && \
		make DESTDIR=`readlink -f _install` install

grub-clean:
	rm -rf $(GRUB_SRC_DIR)/build

initramfs:
	bash tools/build_initramfs.sh $(BUSYBOX_SRC_DIR)

run:
	bash tools/run_qemu.sh $(QEMU_ARCH) nographic

run-graphic:
	bash tools/run_qemu.sh $(QEMU_ARCH) graphic

vmdk:
	bash tools/build_vmdk.sh $(BUSYBOX_SRC_DIR) $(GRUB_SRC_DIR)
