BUSYBOX_SRC_DIR = $(abspath src/busybox-1.35.0)
BUSYBOX_ENV = O=build ARCH=x86

.PHONY: \
busybox-build \
busybox-clean \
busybox-compile \
busybox-install

busybox-build: busybox-compile busybox-install

busybox-clean:
	rm -rf $(BUSYBOX_SRC_DIR)/build

busybox-compile:
	mkdir -p $(BUSYBOX_SRC_DIR)/build
	cd $(BUSYBOX_SRC_DIR) && \
		make $(BUSYBOX_ENV) defconfig
	sed -i -f settings/busybox_config $(BUSYBOX_SRC_DIR)/build/.config
	cd $(BUSYBOX_SRC_DIR) && \
		make CFLAGS="-O2 -I$(INSTALL_DIR)/include" \
			 LDFLAGS="-L$(INSTALL_DIR)/lib" \
			 $(BUSYBOX_ENV) -j$(NPROC) && \
		make $(BUSYBOX_ENV) install

busybox-install:
	cp -P $(BUSYBOX_SRC_DIR)/build/_install/bin/* \
		$(INSTALL_DIR)/bin/
	cp -P $(BUSYBOX_SRC_DIR)/build/_install/sbin/* \
		$(INSTALL_DIR)/sbin/
	cp -P $(BUSYBOX_SRC_DIR)/examples/udhcp/simple.script \
		$(INSTALL_DIR)/etc/udhcpc.script
