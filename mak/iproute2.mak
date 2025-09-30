IPROUTE2_SRC_DIR = $(abspath src/iproute2-6.17.0)

.PHONY: \
iproute2-build \
iproute2-clean \
iproute2-compile \
iproute2-install

iproute2-build: iproute2-compile iproute2-install

iproute2-clean:
	cd "$(IPROUTE2_SRC_DIR)" && \
		touch config.mk && \
		make distclean && \
		rm -f config.mk

iproute2-compile:
	cp settings/iproute2_config "$(IPROUTE2_SRC_DIR)"/config.mk
	cd "$(IPROUTE2_SRC_DIR)" && \
		echo 'CFLAG+="-I$(INSTALL_DIR)/include' \
			>>"$(IPROUTE2_SRC_DIR)"/config.mak && \
		echo 'LDFLAGS+="-L$(INSTALL_DIR)/lib' \
			>>"$(IPROUTE2_SRC_DIR)"/config.mak && \
		make -j$(NPROC)

iproute2-install:
	rm -f "$(INSTALL_DIR)"/sbin/tc
	cp -P "$(IPROUTE2_SRC_DIR)"/tc/tc \
		"$(INSTALL_DIR)"/sbin/
