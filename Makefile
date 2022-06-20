LINUX_KERNEL_SRC = linux-5.19-rc3
LINUX_KERNEL_ENV = O=build ARCH=x86
BUSYBOX_SRC = busybox-1.35.0
BUSYBOX_ENV = O=build ARCH=x86
INITRAMFS_TMP_DIR=initramfs.tmp
QEMU_PROG = qemu-system-x86_64
QEMU_ARGS = \
	-enable-kvm \
	-machine q35 \
	-cpu host \
	-smp 4 \
	-nic user,model=e1000,net=192.168.5.0/24,dhcpstart=192.168.5.11,hostfwd=udp:127.0.0.1:5069-192.168.5.5:69 \
	-m 256M \
	-kernel vmlinuz \
	-initrd initramfs.img \
	-append "console=ttyS0"

.PHONY: \
dummy \
kernel-build kernel-clean \
busybox-build busybox-clean busybox-image \
run run-graphic \

dummy:

kernel-build:
	cd $(LINUX_KERNEL_SRC) && \
		make $(LINUX_KERNEL_ENV) KCONFIG_ALLCONFIG=../kernel_config allnoconfig
	cd $(LINUX_KERNEL_SRC) && \
		make $(LINUX_KERNEL_ENV) bzImage -j4
	cp $(LINUX_KERNEL_SRC)/build/arch/x86_64/boot/bzImage vmlinuz

kernel-clean:
	cd $(LINUX_KERNEL_SRC) && \
		make $(LINUX_KERNEL_ENV) distclean

busybox-build:
	mkdir -p $(BUSYBOX_SRC)/build
	cd $(BUSYBOX_SRC) && \
		make $(BUSYBOX_ENV) defconfig
	sed -i -e 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' \
		$(BUSYBOX_SRC)/build/.config
	cd $(BUSYBOX_SRC) && \
		make $(BUSYBOX_ENV) -j4
	cd $(BUSYBOX_SRC) && \
		make $(BUSYBOX_ENV) install

busybox-clean:
	cd $(BUSYBOX_SRC) && \
		make $(BUSYBOX_ENV) distclean

busybox-image:
	rm -rf $(INITRAMFS_TMP_DIR)
	mkdir -p $(INITRAMFS_TMP_DIR)
	cp -r $(BUSYBOX_SRC)/build/_install $(INITRAMFS_TMP_DIR)
	cd $(INITRAMFS_TMP_DIR)/_install && \
		rm -f linuxrc && \
		rm -rf usr && \
		mkdir {etc,proc,sys} && \
		cp ../../busybox_init init && \
		chmod +x init && \
		find . -print0 | cpio --null -ov --format=newc | \
		gzip > ../../initramfs.img

run:
	$(QEMU_PROG) -nographic $(QEMU_ARGS)

run-graphic:
	$(QEMU_PROG) $(QEMU_ARGS)
