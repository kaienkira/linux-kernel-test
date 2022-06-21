LINUX_KERNEL_SRC = src/linux-5.19-rc3
LINUX_KERNEL_ENV = O=build ARCH=x86
BUSYBOX_SRC = src/busybox-1.35.0
BUSYBOX_ENV = O=build ARCH=x86
INITRAMFS_TMP_DIR=bin/initramfs.tmp
QEMU_PROG = qemu-system-x86_64
QEMU_ARGS = \
	-enable-kvm \
	-machine q35 \
	-cpu host \
	-smp 4 \
	-nic user,model=e1000,net=192.168.5.0/24,dhcpstart=192.168.5.11,hostfwd=udp:127.0.0.1:5069-192.168.5.5:69 \
	-m 256M \
	-kernel bin/vmlinuz \
	-initrd bin/initramfs.img \
	-append "console=ttyS0"

.PHONY: \
run run-graphic image \
build clean \
kernel-build kernel-clean \
busybox-build busybox-clean

run:
	$(QEMU_PROG) -nographic $(QEMU_ARGS)

run-graphic:
	$(QEMU_PROG) $(QEMU_ARGS)

image:
	rm -rf $(INITRAMFS_TMP_DIR)
	cp -r $(BUSYBOX_SRC)/build/_install $(INITRAMFS_TMP_DIR)
	cd $(INITRAMFS_TMP_DIR)/ && \
		rm -f linuxrc && \
		rm -rf usr && \
		mkdir {etc,opt,proc,sys} && \
		mkdir etc/init.d && \
		cp ../../settings/init init && \
		chmod +x init && \
		cp ../../settings/inittab etc/inittab && \
		cp ../../settings/resolv.conf etc/resolv.conf && \
		cp ../../settings/rcS etc/init.d/rcS && \
		chmod +x etc/init.d/rcS && \
		find . -print0 | cpio --null -ov --format=newc | \
		gzip > ../initramfs.img

build: kernel-build busybox-build image

clean: kernel-clean busybox-clean
	rm -rf $(LINUX_KERNEL_SRC)/build
	rm -rf $(BUSYBOX_SRC)/build
	rm -f bin/vmlinuz
	rm -f bin/initramfs.img
	rm -rf $(INITRAMFS_TMP_DIR)

kernel-build:
	cd $(LINUX_KERNEL_SRC) && \
		make $(LINUX_KERNEL_ENV) \
			KCONFIG_ALLCONFIG=../../settings/kernel_config allnoconfig
	cd $(LINUX_KERNEL_SRC) && \
		make $(LINUX_KERNEL_ENV) bzImage -j4
	cp $(LINUX_KERNEL_SRC)/build/arch/x86_64/boot/bzImage bin/vmlinuz

kernel-clean:
	cd $(LINUX_KERNEL_SRC) && \
		make $(LINUX_KERNEL_ENV) distclean

busybox-build:
	mkdir -p $(BUSYBOX_SRC)/build
	cd $(BUSYBOX_SRC) && \
		make $(BUSYBOX_ENV) defconfig
	sed -i -f settings/busybox_config $(BUSYBOX_SRC)/build/.config
	cd $(BUSYBOX_SRC) && \
		make $(BUSYBOX_ENV) -j4
	cd $(BUSYBOX_SRC) && \
		make $(BUSYBOX_ENV) install

busybox-clean:
	cd $(BUSYBOX_SRC) && \
		if [ -d $(BUSYBOX_SRC)/build ]; then make $(BUSYBOX_ENV) distclean; fi
