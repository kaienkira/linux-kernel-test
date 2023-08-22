LIBNFTNL_SRC_DIR = $(abspath src/libnftnl-1.2.6)

.PHONY: \
libnftnl-build \
libnftnl-clean \
libnftnl-compile \
libnftnl-install

libnftnl-build: libnftnl-compile libnftnl-install

libnftnl-clean:
	rm -rf $(LIBNFTNL_SRC_DIR)/build

libnftnl-compile:
	mkdir -p $(LIBNFTNL_SRC_DIR)/build
	cd $(LIBNFTNL_SRC_DIR)/build && \
		../configure \
			CFLAGS="-O2 -I$(INSTALL_DIR)/include" \
			LDFLAGS="-L$(INSTALL_DIR)/lib" \
			--prefix=/ \
			--disable-static && \
		make -j$(NPROC) && \
		mkdir -p _install && \
		make DESTDIR=`readlink -f _install` install

libnftnl-install:
	cp -r $(LIBNFTNL_SRC_DIR)/build/_install/include/* \
		$(INSTALL_DIR)/include/
	cp -P $(LIBNFTNL_SRC_DIR)/build/_install/lib/libnftnl.so* \
		$(INSTALL_DIR)/lib/
