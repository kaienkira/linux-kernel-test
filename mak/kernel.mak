LINUX_KERNEL_SRC_DIR = $(abspath src/linux-6.1-rc1)
LINUX_KERNEL_ENV = O=build ARCH=x86

.PHONY: \
kernel-build \
kernel-clean \
kernel-compile \
kernel-install

kernel-build: kernel-compile kernel-install

kernel-clean:
	rm -rf $(LINUX_KERNEL_SRC_DIR)/build

kernel-compile:
	cd $(LINUX_KERNEL_SRC_DIR) && \
		make $(LINUX_KERNEL_ENV) \
			KCONFIG_ALLCONFIG=../../settings/kernel_config allnoconfig
	cd $(LINUX_KERNEL_SRC_DIR) && \
		make $(LINUX_KERNEL_ENV) bzImage -j$(NPROC)

kernel-install:
	cp $(LINUX_KERNEL_SRC_DIR)/build/arch/x86_64/boot/bzImage bin/vmlinuz
	cd $(LINUX_KERNEL_SRC_DIR) && \
		make $(LINUX_KERNEL_ENV) headers_install \
			INSTALL_HDR_PATH=$(INSTALL_DIR)
