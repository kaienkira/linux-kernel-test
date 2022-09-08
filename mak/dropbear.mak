DROPBEAR_SRC_DIR = $(abspath src/dropbear-2022.82)

.PHONY: \
dropbear-build \
dropbear-clean \
dropbear-compile \
dropbear-install

dropbear-build: dropbear-compile dropbear-install

dropbear-clean:
	rm -rf $(DROPBEAR_SRC_DIR)/build

dropbear-compile:
	mkdir -p $(DROPBEAR_SRC_DIR)/build
	cd $(DROPBEAR_SRC_DIR)/build && \
		../configure \
			CFLAGS="-O2 -I$(INSTALL_DIR)/include" \
			LDFLAGS="-L$(INSTALL_DIR)/lib" \
			--prefix=/ \
			--disable-zlib && \
		make -j$(NPROC) && \
		mkdir -p _install && \
		make DESTDIR=`readlink -f _install` install

dropbear-install:
	cp -P $(DROPBEAR_SRC_DIR)/build/_install/sbin/dropbear \
		$(INSTALL_DIR)/sbin/
	cp -P $(DROPBEAR_SRC_DIR)/build/_install/bin/dbclient \
		$(INSTALL_DIR)/bin/
	cp -P $(DROPBEAR_SRC_DIR)/build/_install/bin/dropbearkey \
		$(INSTALL_DIR)/bin/
